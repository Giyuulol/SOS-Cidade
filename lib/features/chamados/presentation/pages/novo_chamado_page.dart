import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/chamado_business_exception.dart';
import '../../application/chamados_providers.dart';
import '../../domain/bairros_joao_pessoa.dart';
import '../../domain/chamado.dart';
import '../../domain/chamado_enums.dart';

final class NovoChamadoPage extends ConsumerStatefulWidget {
  const NovoChamadoPage({super.key});

  @override
  ConsumerState<NovoChamadoPage> createState() => _NovoChamadoPageState();
}

final class _NovoChamadoPageState extends ConsumerState<NovoChamadoPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _responsavelController = TextEditingController();
  final _dataController = TextEditingController();

  DateTime _data = DateTime.now();
  String _bairro = bairrosJoaoPessoa.first;
  ChamadoCategoria _categoria = ChamadoCategoria.transito;
  ChamadoPrioridade _prioridade = ChamadoPrioridade.media;
  ChamadoStatus _status = ChamadoStatus.aberto;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dataController.text = _formatDate(_data);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _responsavelController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo chamado')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              _EnumDropdown(
                label: 'Categoria',
                value: _categoria,
                values: ChamadoCategoria.values,
                labelBuilder: (value) => value.label,
                onChanged: (value) => setState(() => _categoria = value),
              ),
              const SizedBox(height: 12),
              _EnumDropdown(
                label: 'Prioridade',
                value: _prioridade,
                values: ChamadoPrioridade.values,
                labelBuilder: (value) => value.label,
                onChanged: (value) => setState(() => _prioridade = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _bairro,
                decoration: const InputDecoration(labelText: 'Bairro'),
                isExpanded: true,
                items: [
                  for (final bairro in bairrosJoaoPessoa)
                    DropdownMenuItem(value: bairro, child: Text(bairro)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _bairro = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _responsavelController,
                decoration: const InputDecoration(labelText: 'Responsável'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                validator: _required,
                onTap: _selectDate,
              ),
              const SizedBox(height: 12),
              _EnumDropdown(
                label: 'Status',
                value: _status,
                values: ChamadoStatus.values,
                labelBuilder: (value) => value.label,
                onChanged: (value) => setState(() => _status = value),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Cadastrar chamado'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final chamado = Chamado(
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim(),
      categoria: _categoria,
      prioridade: _prioridade,
      bairro: _bairro,
      responsavel: _responsavelController.text.trim(),
      data: _data,
      status: _status,
    );

    try {
      await ref
          .read(chamadosControllerProvider.notifier)
          .createChamado(chamado);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chamado cadastrado com sucesso.')),
      );
      Navigator.of(context).pop();
    } on ChamadoBusinessException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected == null) return;

    setState(() {
      _data = DateTime(
        selected.year,
        selected.month,
        selected.day,
        _data.hour,
        _data.minute,
      );
      _dataController.text = _formatDate(_data);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

final class _EnumDropdown<T extends Enum> extends StatelessWidget {
  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in values)
          DropdownMenuItem(value: item, child: Text(labelBuilder(item))),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
