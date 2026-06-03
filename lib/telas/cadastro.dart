import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chamado.dart';
import '../provedores/chamado_provider.dart';
import '../utilitarios/constantes.dart';
import '../utilitarios/formatadores_data.dart';

class TelaCadastro extends ConsumerStatefulWidget {
  final Chamado? chamado;

  const TelaCadastro({super.key, this.chamado});

  @override
  ConsumerState<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends ConsumerState<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descricao = TextEditingController();
  final _bairro = TextEditingController();
  final _responsavel = TextEditingController();

  String _categoria = ConstantesChamado.categorias.first;
  String _prioridade = ConstantesChamado.prioridades.first;

  late final DateTime _dataAbertura;
  late final String _status;

  bool _canEdit = true;

  @override
  void initState() {
    super.initState();
    final existente = widget.chamado;
    _dataAbertura = existente?.dataAbertura ?? DateTime.now();
    _status = existente?.status ?? ConstantesChamado.status.first;
    if (existente != null) {
      _titulo.text = existente.titulo;
      _descricao.text = existente.descricao;
      _bairro.text = existente.bairro;
      _responsavel.text = existente.responsavel;
      _categoria = existente.categoria;
      _prioridade = existente.prioridade;
      _canEdit =
          existente.status == 'Aberto' || existente.status == 'Em Andamento';
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    _bairro.dispose();
    _responsavel.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = ref.read(chamadoProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (provider.existeTituloRepetido(
      _titulo.text,
      idIgnorar: widget.chamado?.id,
    )) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Já existe um chamado com este título.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      if (widget.chamado == null) {
        final novo = Chamado(
          id: DateTime.now().millisecondsSinceEpoch,
          titulo: _titulo.text.trim(),
          descricao: _descricao.text.trim(),
          categoria: _categoria,
          prioridade: _prioridade,
          bairro: _bairro.text.trim(),
          responsavel: _responsavel.text.trim(),
          dataAbertura: _dataAbertura,
          status: _status,
        );

        final ok = await provider.adicionarChamado(novo);
        if (ok) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Chamado criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          navigator.pop();
        } else {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Falha ao criar chamado.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        final existente = widget.chamado!;
        final atualizado = existente.copyWith(
          titulo: _titulo.text.trim(),
          descricao: _descricao.text.trim(),
          categoria: _categoria,
          prioridade: _prioridade,
          bairro: _bairro.text.trim(),
          responsavel: _responsavel.text.trim(),
        );
        await provider.atualizarChamado(atualizado);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Chamado atualizado.'),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop();
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Não foi possível salvar o chamado: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chamado == null ? 'Novo chamado' : 'Editar chamado'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titulo,
                  enabled: _canEdit,
                  maxLength: 50,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                    counterText: '',
                    errorMaxLines: 2,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-ZÀ-ÖØ-öø-ÿ0-9 ]'),
                    ),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o título';
                    }
                    if (v.trim().length < 5) {
                      return 'O título deve ter no mínimo 5 letras';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descricao,
                  enabled: _canEdit,
                  maxLines: 4,
                  maxLength: 1000,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        required maxLength,
                      }) {
                        final restantes = (maxLength ?? 0) - currentLength;
                        final texto = restantes == 1
                            ? '1 caractere restante'
                            : '$restantes caracteres restantes';

                        return Text(texto);
                      },
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe a descrição';
                    }
                    if (v.trim().length < 10) {
                      return 'Dê mais detalhes (mínimo 10 caracteres)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bairro,
                  enabled: _canEdit,
                  maxLength: 50,
                  decoration: const InputDecoration(
                    labelText: 'Bairro',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-ZÀ-ÿ0-9\s\-]'),
                    ),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o bairro';
                    }
                    if (v.trim().length < 3) {
                      return 'Bairro muito curto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _responsavel,
                  enabled: _canEdit,
                  maxLength: 50,
                  decoration: const InputDecoration(
                    labelText: 'Responsável',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s]')),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o responsável';
                    }
                    if (v.trim().split(RegExp(r'\s+')).length < 2) {
                      return 'Informe nome e sobrenome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: formatarDataHora(_dataAbertura),
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Data de abertura',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _status,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _categoria,
                  items: ConstantesChamado.categorias
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: _canEdit
                      ? (v) => setState(() => _categoria = v ?? _categoria)
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _prioridade,
                  items: ConstantesChamado.prioridades
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: _canEdit
                      ? (v) => setState(() => _prioridade = v ?? _prioridade)
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Prioridade',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.tonal(
                  onPressed: _canEdit ? _salvar : null,
                  child: Text(
                    widget.chamado == null
                        ? 'Registrar chamado'
                        : 'Salvar alterações',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
