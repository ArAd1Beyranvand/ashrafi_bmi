import 'dart:io' show Platform, Process;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ValueListenable, kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/report_colors.dart';
import '../../../core/theme/report_text.dart';
import '../../../core/utils/format.dart';
import '../../../data/models/report_data.dart';
import '../cubit/report_cubit.dart';
import '../export/export_service.dart';
import 'a4_sheet.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, required this.data});

  final ReportData data;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _sheetKey = GlobalKey();
  final _zoom = TransformationController();
  Size _viewport = Size.zero;

  /// Zoom about the viewport centre, clamped to 1–4 like the InteractiveViewer.
  void _zoomBy(double factor) {
    final m = _zoom.value;
    final next = (m.getMaxScaleOnAxis() * factor).clamp(1.0, 4.0);
    if (next == 1.0) {
      _zoom.value = Matrix4.identity();
      return;
    }
    final c = Offset(_viewport.width / 2, _viewport.height / 2);
    final k = next / m.getMaxScaleOnAxis();
    final t = Matrix4.identity()
      ..translateByDouble(c.dx, c.dy, 0, 1)
      ..scaleByDouble(k, k, 1, 1)
      ..translateByDouble(-c.dx, -c.dy, 0, 1);
    _zoom.value = t * m;
  }

  /// True while the sheet is being captured: wave paused, border/shadow off.
  final _capturing = ValueNotifier<bool>(false);

  late final _export = ExportService(capture: _capture);

  @override
  void dispose() {
    _capturing.dispose();
    _zoom.dispose();
    super.dispose();
  }

  Future<Uint8List> _capture() async {
    _capturing.value = true;
    try {
      // Let the paused (TickerMode) frame render before grabbing it.
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _sheetKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return bytes!.buffer.asUint8List();
    } finally {
      _capturing.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportCubit(widget.data),
      child: Scaffold(
        backgroundColor: ReportColors.canvas,
        body: SafeArea(
          child: Column(
            children: [
              _Toolbar(
                export: _export,
                baseName: widget.data.person.name,
                onZoom: _zoomBy,
                onReset: () => _zoom.value = Matrix4.identity(),
              ),
              Expanded(
                child: BlocBuilder<ReportCubit, ReportState>(
                  builder: (context, state) => _SheetViewer(
                    state: state,
                    sheetKey: _sheetKey,
                    capturing: _capturing,
                    controller: _zoom,
                    onViewport: (size) => _viewport = size,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Canvas → InteractiveViewer → (viewport-sized box) → FittedBox → A4Sheet.
class _SheetViewer extends StatelessWidget {
  const _SheetViewer({
    required this.state,
    required this.sheetKey,
    required this.capturing,
    required this.controller,
    required this.onViewport,
  });

  final ReportState state;
  final GlobalKey sheetKey;
  final ValueListenable<bool> capturing;
  final TransformationController controller;
  final ValueChanged<Size> onViewport;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      onViewport(Size(c.maxWidth, c.maxHeight));
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onDoubleTap: () => controller.value = Matrix4.identity(),
        child: InteractiveViewer(
          transformationController: controller,
          minScale: 1,
          maxScale: 4,
          constrained: false,
          child: SizedBox(
            width: c.maxWidth,
            height: c.maxHeight,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                // scaleDown: never enlarge above 1.0 (decision D1).
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: capturing,
                    builder: (_, busy, _) => TickerMode(
                      enabled: !busy,
                      child: RepaintBoundary(
                        key: sheetKey,
                        child: A4Sheet(state: state, forExport: busy),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

enum _ExportAction { pdf, png, print }

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.export,
    required this.baseName,
    required this.onZoom,
    required this.onReset,
  });

  final ValueChanged<double> onZoom;
  final VoidCallback onReset;

  final ExportService export;
  final String baseName;

  static final _canOpen =
      !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

  static Future<void> _open(String path) {
    if (Platform.isWindows) {
      return Process.run('cmd', ['/c', 'start', '', path]);
    }
    return Process.run(Platform.isMacOS ? 'open' : 'xdg-open', [path]);
  }

  Future<void> _run(BuildContext context, _ExportAction a) async {
    final messenger = ScaffoldMessenger.of(context);
    final name = 'report_$baseName';
    try {
      final saved = switch (a) {
        _ExportAction.pdf => await export.savePdf(name),
        _ExportAction.png => await export.savePng(name),
        _ExportAction.print => await export.printPdf(name).then((_) => null),
      };
      if (saved != null) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Saved'),
            action: _canOpen && saved.isNotEmpty
                ? SnackBarAction(label: 'Open', onPressed: () => _open(saved))
                : null,
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  static final _border = Border.all(color: ReportColors.uiLine);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportCubit>();
    final state = context.watch<ReportCubit>().state;
    final ms = state.data.measurements;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _Box(
            onTap: () => Navigator.of(context).maybePop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 16,
                  color: ReportColors.uiInk,
                ),
                const SizedBox(width: 6),
                Text('Back', style: ReportText.toolbar),
              ],
            ),
          ),
          const Spacer(),
          // Narrow (phone) windows rely on pinch; the buttons would not fit.
          if (MediaQuery.sizeOf(context).width >= 560)
            for (final (icon, tip, tap) in [
              (Icons.remove, 'Zoom out', () => onZoom(1 / 1.25)),
              (Icons.add, 'Zoom in', () => onZoom(1.25)),
              (Icons.fit_screen, 'Reset zoom', onReset),
            ]) ...[
              Tooltip(
                message: tip,
                child: _Box(
                  onTap: tap,
                  child: Icon(icon, size: 16, color: ReportColors.uiInk),
                ),
              ),
              const SizedBox(width: 8),
            ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: _border,
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                key: const Key('measurementSelector'),
                value: state.selectedIndex,
                style: ReportText.toolbar,
                isDense: true,
                dropdownColor: Colors.white,
                items: [
                  for (var i = 0; i < ms.length; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text(formatSelectorLabel(ms[i].timestamp)),
                    ),
                ],
                onChanged: (i) {
                  if (i != null) cubit.select(i);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<_ExportAction>(
            key: const Key('exportMenu'),
            tooltip: 'Export',
            position: PopupMenuPosition.under,
            onSelected: (a) => _run(context, a),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _ExportAction.pdf,
                child: Text('Save as PDF'),
              ),
              PopupMenuItem(
                value: _ExportAction.png,
                child: Text('Save as PNG'),
              ),
              PopupMenuItem(
                value: _ExportAction.print,
                child: Text('Print / Share…'),
              ),
            ],
            child: IgnorePointer(
              child: _Box(child: Text('Export', style: ReportText.toolbar)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
      side: const BorderSide(color: ReportColors.uiLine),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: child,
      ),
    ),
  );
}
