import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/import_cubit.dart';
import '../cubit/import_state.dart';
import 'widgets/drop_zone.dart';

class ImportPage extends StatelessWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImportCubit(),
      child: const ImportView(),
    );
  }
}

class ImportView extends StatelessWidget {
  const ImportView({super.key});

  static const _grey = Color(0xFF8A9399);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImportCubit, ImportState>(
      listener: (context, state) async {
        if (state is ImportSuccess) {
          final cubit = context.read<ImportCubit>();
          await Navigator.of(context)
              .pushNamed('/report', arguments: state.data);
          cubit.reset();
        }
      },
      builder: (context, state) {
        final cubit = context.read<ImportCubit>();
        final loading = state is ImportLoading;
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x2E000000),
                        offset: Offset(0, 4),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Logo(),
                        const SizedBox(height: 16),
                        const Text(
                          'Open a report file',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF33434C),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropZone(
                          dragging: state is ImportDragging,
                          loading: loading,
                          onDragging: cubit.setDragging,
                          onDrop: cubit.dropFiles,
                          onPick: cubit.pickFile,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'JSON or base64-encoded JSON (.json, .txt, .b64)',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: _grey),
                        ),
                        if (state is ImportError) ...[
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFC3202A),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: loading ? null : cubit.loadSample,
                            child: const Text('Load sample'),
                          ),
                        ),
                      ],
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
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF8D2525);
    return const Center(
      child: Text.rich(
        TextSpan(
          text: 'charder',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: color,
          ),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.top,
              child: Text('®', style: TextStyle(fontSize: 8, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
