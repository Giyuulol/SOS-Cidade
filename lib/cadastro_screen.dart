import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atividade/models/chamado_model.dart';
import 'package:atividade/providers/chamado_provider.dart';

class CadastroScreen extends StatefulWidget {
  final Chamado? chamadoExistente;

  const CadastroScreen({super.key, this.chamadoExistente});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _bairroController;
  late TextEditingController _responsavelController;
  late String _categoriaSelecionada;
  late String _prioridadeSelecionada;

  final _atualizacaoFormKey = GlobalKey<FormState>();
  final _nomeAtualizadorController = TextEditingController();
  final _relatoAtualizacaoController = TextEditingController();
  String _novoStatusSelecionado = 'em andamento';

  final List<String> _categorias = [
    'trânsito',
    'iluminação',
    'saneamento',
    'segurança',
    'limpeza urbana',
    'desastre natural'
  ];
  final List<String> _prioridades = ['baixa', 'média', 'alta', 'crítica'];
  final List<String> _statusOptions = ['aberto', 'em andamento', 'concluído'];

  @override
  void initState() {
    super.initState();
    final editando = widget.chamadoExistente;

    _tituloController = TextEditingController(text: editando?.titulo ?? '');
    _descricaoController =
        TextEditingController(text: editando?.descricao ?? '');
    _bairroController = TextEditingController(text: editando?.bairro ?? '');
    _responsavelController =
        TextEditingController(text: editando?.responsavelOriginal ?? '');
    _categoriaSelecionada = editando?.categoria ?? 'trânsito';
    _prioridadeSelecionada = editando?.prioridade ?? 'baixa';

    if (editando != null) {
      _novoStatusSelecionado = editando.status;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _bairroController.dispose();
    _responsavelController.dispose();
    _nomeAtualizadorController.dispose();
    _relatoAtualizacaoController.dispose();
    super.dispose();
  }

  void _gravarNovoChamado() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ChamadoProvider>(context, listen: false);

    if (provider.existeTituloRepetido(_tituloController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('⚠️ Erro: Já existe um chamado com este título!'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    final novoChamado = Chamado(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim(),
      categoria: _categoriaSelecionada,
      prioridade: _prioridadeSelecionada,
      bairro: _bairroController.text.trim(),
      responsavelOriginal: _responsavelController.text.isEmpty
          ? 'Cidadão Anônimo'
          : _responsavelController.text.trim(),
      dataAbertura: DateTime.now(),
      status: 'aberto',
      dataUltimaAtualizacao: DateTime.now(),
      historico: [],
    );

    await provider.adicionarChamado(novoChamado);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Chamado aberto com Status: EM ABERTO!'),
          backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  void _gravarNovaAtualizacao() async {
    if (!_atualizacaoFormKey.currentState!.validate()) return;

    final provider = Provider.of<ChamadoProvider>(context, listen: false);

    final novaEtapa = Atualizacao(
      responsavel: _nomeAtualizadorController.text.trim(),
      descricao: _relatoAtualizacaoController.text.trim(),
      statusAlterado: _novoStatusSelecionado,
      data: DateTime.now(),
    );

    await provider.atualizarChamado(widget.chamadoExistente!.id, novaEtapa);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Histórico do chamado atualizado com sucesso!'),
          backgroundColor: Colors.blue),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.chamadoExistente != null;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(isEdicao ? 'Visualizar e Atualizar' : 'Abertura de Chamado'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                      isEdicao
                          ? 'Dados Originais (Imutáveis)'
                          : 'Informações do Problema',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tituloController,
                    enabled: !isEdicao,
                    decoration: const InputDecoration(
                        labelText: 'Título do Chamado *',
                        border: OutlineInputBorder()),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'O título é obrigatório.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descricaoController,
                    enabled: !isEdicao,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Descrição do Problema *',
                        border: OutlineInputBorder()),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'A descrição é obrigatória.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _bairroController,
                    enabled: !isEdicao,
                    decoration: const InputDecoration(
                        labelText: 'Bairro Afetado *',
                        border: OutlineInputBorder()),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'O bairro é obrigatório.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _responsavelController,
                    enabled: !isEdicao,
                    decoration: const InputDecoration(
                        labelText: 'Quem está abrindo o chamado',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _categoriaSelecionada,
                    decoration: const InputDecoration(
                        labelText: 'Categoria', border: OutlineInputBorder()),
                    items: isEdicao
                        ? [
                            DropdownMenuItem(
                                value: _categoriaSelecionada,
                                child:
                                    Text(_categoriaSelecionada.toUpperCase()))
                          ]
                        : _categorias
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text(c.toUpperCase())))
                            .toList(),
                    onChanged: isEdicao
                        ? null
                        : (val) => setState(() => _categoriaSelecionada = val!),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _prioridadeSelecionada,
                    decoration: const InputDecoration(
                        labelText: 'Prioridade', border: OutlineInputBorder()),
                    items: isEdicao
                        ? [
                            DropdownMenuItem(
                                value: _prioridadeSelecionada,
                                child:
                                    Text(_prioridadeSelecionada.toUpperCase()))
                          ]
                        : _prioridades
                            .map((p) => DropdownMenuItem(
                                value: p, child: Text(p.toUpperCase())))
                            .toList(),
                    onChanged: isEdicao
                        ? null
                        : (val) =>
                            setState(() => _prioridadeSelecionada = val!),
                  ),
                  const SizedBox(height: 20),
                  if (!isEdicao)
                    ElevatedButton(
                      onPressed: _gravarNovoChamado,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('ABRIR CHAMADO',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            if (isEdicao) ...[
              const Divider(height: 40, thickness: 2),
              Text(
                  'Status Atual: ${widget.chamadoExistente!.status.toUpperCase()}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              const SizedBox(height: 10),
              const Text('Histórico de Atualizações:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              widget.chamadoExistente!.historico.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                          'Nenhuma alteração registrada ainda por outros operadores.',
                          style: TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic)),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.chamadoExistente!.historico.length,
                      itemBuilder: (context, idx) {
                        final log = widget.chamadoExistente!.historico[idx];
                        return Card(
                          color: Colors.grey.withAlpha(20),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Modificado por: ${log.responsavel}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                Text('Relato técnico: ${log.descricao}',
                                    style: const TextStyle(fontSize: 13)),
                                Text(
                                    'Alterou status para: ${log.statusAlterado.toUpperCase()}',
                                    style: const TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      '${log.data.day}/${log.data.month} às ${log.data.hour}:${log.data.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              const Divider(height: 40, thickness: 2),
              const Text('Registrar Nova Atualização',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange)),
              const SizedBox(height: 12),
              Form(
                key: _atualizacaoFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nomeAtualizadorController,
                      decoration: const InputDecoration(
                          labelText: 'Seu Nome (Técnico/Operador) *',
                          border: OutlineInputBorder()),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Informe seu nome.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _relatoAtualizacaoController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                          labelText: 'Descrição do que está acontecendo *',
                          border: OutlineInputBorder()),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Descreva o andamento.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _novoStatusSelecionado,
                      decoration: const InputDecoration(
                          labelText: 'Status Atual do Chamado',
                          border: OutlineInputBorder()),
                      items: _statusOptions
                          .map((s) => DropdownMenuItem(
                              value: s, child: Text(s.toUpperCase())))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _novoStatusSelecionado = val!),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _gravarNovaAtualizacao,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('SALVAR ATUALIZAÇÃO',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
