# Agenda de Contatos - Flutter

Projeto desenvolvido como atividade prática para a disciplina de Desenvolvimento Mobile em Flutter.

A aplicação expande a tela inicial de cadastro de contatos, implementando uma solução completa de gerenciamento de contatos com Material 3 e arquitetura baseada em componentes nativos e `ChangeNotifier`.

---

## Telas e Funcionalidades

1. **Listagem de Contatos (`contacts_list_screen.dart`)**
   - Exibição de todos os contatos agrupados por ordem alfabética (A-Z).
   - Barra de busca dinâmica por nome, e-mail ou telefone.
   - Acesso rápido para favoritar e visualizar detalhes.

2. **Detalhes do Contato (`contact_detail_screen.dart`)**
   - Visualização completa: foto/avatar, nome, telefone, e-mail, categorias, cidade, empresa, aniversário e observações.
   - Opções para editar dados ou excluir o contato.

3. **Cadastro e Edição de Contato (`add_edit_contact_screen.dart`)**
   - Formulário com validações de campos obrigatórios.
   - Personalização de foto/avatar com seleção de ícone e paleta de cores.
   - Associação de categorias múltiplas via chips.
   - Botões para salvar ou cancelar as alterações.

4. **Favoritos (`favorites_screen.dart`)**
   - Listagem filtrada apenas com contatos marcados com estrela.
   - Adicionar ou remover favoritos em tempo real.

5. **Categorias (`categories_screen.dart`)**
   - Categorias padrão: Família, Amigos, Trabalho, Clientes e Outros.
   - Criação de novas categorias personalizadas.
   - Visualização expansível dos contatos associados a cada categoria.

6. **Grupos (`groups_screen.dart`)**
   - Criação e gerenciamento de grupos (ex: Projetos, Futebol).
   - Inclusão e remoção de membros por grupo.

7. **Aniversários (`birthdays_screen.dart`)**
   - Listagem dos aniversariantes do mês atual.
   - Geração de lembretes para aniversários próximos (próximos 30 dias).
   - Indicador de dias restantes e aniversariantes do dia.

8. **Pesquisa Avançada (`advanced_search_screen.dart`)**
   - Filtros combinados por texto (nome/email/telefone), categoria, cidade, empresa e data mínima de cadastro.

9. **Importação e Exportação (`import_export_screen.dart`)**
   - Exportação da agenda em formato CSV (compatível com Excel) ou JSON.
   - Importação em lote a partir de texto CSV ou backup, com botão de dados de exemplo.

10. **Configurações (`settings_screen.dart`)**
    - Alternância entre tema claro e tema escuro.
    - Configuração de rotina de backup automático e frequência.
    - Gerenciamento de preferências do usuário (ordem de exibição, alertas de aniversário, restauração de dados padrão).

---

## Estrutura do Projeto

```
lib/
├── main.dart
├── models/
│   ├── contact.dart
│   └── contact_group.dart
├── store/
│   └── contacts_store.dart
├── theme/
│   └── app_theme.dart
├── widgets/
│   └── contact_avatar.dart
└── screens/
    ├── add_edit_contact_screen.dart
    ├── advanced_search_screen.dart
    ├── birthdays_screen.dart
    ├── categories_screen.dart
    ├── contact_detail_screen.dart
    ├── contacts_list_screen.dart
    ├── favorites_screen.dart
    ├── groups_screen.dart
    ├── import_export_screen.dart
    └── settings_screen.dart
```

---

## Como Executar

Certifique-se de ter o Flutter instalado e configurado no ambiente:

```bash
flutter run
```
