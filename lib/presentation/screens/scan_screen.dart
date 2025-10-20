
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tp3_v2/presentation/widgets/app_scaffold.dart';
import 'package:tp3_v2/presentation/widgets/plate_ocr_camera.dart';
import 'package:tp3_v2/utils/plate.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  late final TabController _tab;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _startWithPlate(String plate) {
    final norm = PlateValidator.normalize(plate);
    if (!PlateValidator.isValid(norm)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Patente inválida. Formatos: ABC123 o AB123CD')),
      );
      return;
    }
    context.go('/active', extra: norm);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);     
    return AppScaffold(
      title: 'Escanear patente',
      body: Column(
        children: [
          const SizedBox(height: 8),
          TabBar(
            controller: _tab,
            onTap: (i) => setState(() {}),
            labelColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.photo_camera), text: 'Cámara (OCR)'),
              Tab(icon: Icon(Icons.keyboard_alt_outlined), text: 'Manual'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                PlateOcrCamera(onPlateFound: _startWithPlate),
                _ManualTab(onSubmit: _startWithPlate), // <- pestaña independiente
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ----------  Widget privado que MANTIENE su propio controller  ---------- */
class _ManualTab extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  const _ManualTab({required this.onSubmit});

  @override
  State<_ManualTab> createState() => _ManualTabState();
}

class _ManualTabState extends State<_ManualTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Patente',
              hintText: 'AB123CD o ABC123',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => widget.onSubmit(_controller.text),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar estadía'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _controller.clear,
            icon: const Icon(Icons.clear),
            label: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}