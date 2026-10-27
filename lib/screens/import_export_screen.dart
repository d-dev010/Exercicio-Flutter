import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../store/contacts_store.dart';

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({super.key, required this.store});

  final ContactsStore store;

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _importCtrl = TextEditingController();
  String _exportPreview = '';
  String _selectedExportType = 'CSV';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _updateExportPreview();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _importCtrl.dispose();
    super.dispose();
  }

  void _updateExportPreview() {
    setState(() {
      if (_selectedExportType == 'CSV') {
        _exportPreview = widget.store.exportToCsv();
      } else {
        _exportPreview = widget.store.exportToJson();
      }
    });
  }

  void _copyExportToClipboard() {
    Clipboard.setData(ClipboardData(text: _exportPreview));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Backup $_selectedExportType copiado para a área de transferência!',
        ),
      ),
    );
  }

  void _loadSampleCsv() {
    const sample =
        '''Nome,Telefone,Email,Categorias,Cidade,Empresa,Aniversario,Observacoes
"Marcos Oliveira","(11) 91111-2222","marcos@exemplo.com","Trabalho;Clientes","Campinas","Soluções TI","1989-05-14","Cliente importante"
"Fernanda Rocha","(21) 93333-4444","fernanda@email.com","Amigos;Família","Niterói","Design Co","1994-11-20","Prima de Florianópolis"
"Gabriel Souza","(31) 95555-6666","gabriel@empresa.com","Trabalho","Belo Horizonte","Construtora ABC","1985-08-30","Engenheiro civil"''';

    setState(() {
      _importCtrl.text = sample;
    });
  }

  void _executeImport() {
    final text = _importCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insira os dados CSV ou JSON para importar.'),
        ),
      );
      return;
    }

    int count = 0;
    if (text.startsWith('{')) {
      count = widget.store.importFromJson(text);
    } else {
      count = widget.store.importFromCsv(text);
    }

    if (count > 0) {
      _importCtrl.clear();
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Importação Concluída'),
            ],
          ),
          content: Text(
            '$count contato(s) foram importados com sucesso para sua agenda.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Ver Contatos'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nenhum contato pôde ser importado. Verifique a formatação.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importação e Exportação'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.file_download_outlined),
              text: 'Exportar Backup',
            ),
            Tab(
              icon: Icon(Icons.file_upload_outlined),
              text: 'Importar Contatos',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba 1: Exportar
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Exportar Contatos para Backup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Exporte seus dados em CSV compatível com Excel e Google Planilhas ou em JSON completo.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('CSV (Excel)'),
                              selected: _selectedExportType == 'CSV',
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedExportType = 'CSV');
                                  _updateExportPreview();
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('JSON (Backup)'),
                              selected: _selectedExportType == 'JSON',
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedExportType = 'JSON');
                                  _updateExportPreview();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pré-visualização dos Dados:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copiar'),
                      onPressed: _copyExportToClipboard,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _exportPreview,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text('Exportar $_selectedExportType para Backup'),
                    onPressed: _copyExportToClipboard,
                  ),
                ),
              ],
            ),
          ),

          // Aba 2: Importar
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Importar Contatos (CSV / Excel)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Cole os dados no formato CSV (colunas: Nome, Telefone, Email, Categorias, Cidade, Empresa, Aniversario, Observacoes) ou clique abaixo para testar um exemplo.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _loadSampleCsv,
                          icon: const Icon(Icons.playlist_add),
                          label: const Text('Carregar Exemplo CSV'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Conteúdo a ser Importado:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _importCtrl,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'Cole aqui o conteúdo CSV ou JSON...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Processar e Importar Contatos'),
                    onPressed: _executeImport,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
