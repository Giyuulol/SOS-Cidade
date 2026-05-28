# ⚠️ Guia de Implementação — Funcionalidade: Urgência

> Adiciona a opção de marcar chamados como urgentes, com tela dedicada e destaque visual.

---

## 📋 Visão Geral

| # | Arquivo | Ação |
|---|---------|------|
| 1 | `lib/models/chamado.dart` | Adicionar campo `urgente` |
| 2 | `lib/database/db_helper.dart` | Adicionar coluna na tabela |
| 3 | `lib/providers/chamado_provider.dart` | Getter + método `toggleUrgente` |
| 4 | `lib/widgets/chamado_card.dart` | Botão ⚠️ no card |
| 5 | `lib/screens/urgentes_screen.dart` | **Criar arquivo novo** |
| 6 | `lib/screens/dashboard_screen.dart` | Botão de navegação no AppBar |

---

## PASSO 1 — `lib/models/chamado.dart`

### 1a. Adicionar o campo nos atributos da classe

```dart
String responsavel;
DateTime dataCriacao;
bool urgente;        // ← ADICIONAR
String? imagemPath;
```

### 1b. Adicionar no construtor

```dart
required this.dataCriacao,
this.urgente = false,   // ← ADICIONAR
this.imagemPath,
```

### 1c. Adicionar no `toMap()`

```dart
'dataCriacao': dataCriacao.toIso8601String(),
'urgente': urgente ? 1 : 0,   // ← ADICIONAR
'imagemPath': imagemPath,
```

### 1d. Adicionar no `fromMap()`

```dart
dataCriacao: DateTime.parse(map['dataCriacao']),
urgente: map['urgente'] == 1,   // ← ADICIONAR
imagemPath: map['imagemPath'],
```

---

## PASSO 2 — `lib/database/db_helper.dart`

Dentro do `CREATE TABLE`, adicionar a coluna `urgente`:

```dart
CREATE TABLE chamados(
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  titulo      TEXT    NOT NULL,
  descricao   TEXT    NOT NULL,
  categoria   TEXT    NOT NULL,
  prioridade  TEXT    NOT NULL,
  status      TEXT    NOT NULL,
  bairro      TEXT    NOT NULL,
  responsavel TEXT    NOT NULL,
  dataCriacao TEXT    NOT NULL,
  urgente     INTEGER DEFAULT 0,   // ← ADICIONAR
  imagemPath  TEXT
)
```

> ⚠️ **Atenção:** se o banco já existir no emulador/celular, delete o app e instale de novo. O banco não atualiza sozinho.

---

## PASSO 3 — `lib/providers/chamado_provider.dart`

Adicionar dentro da classe `ChamadoProvider`, após os outros getters:

```dart
// Retorna apenas os chamados marcados como urgentes
List<Chamado> get urgentes =>
    _chamados.where((c) => c.urgente).toList();

// Liga/desliga a urgência e salva no banco
Future<void> toggleUrgente(Chamado c) async {
  c.urgente = !c.urgente;
  await _db.atualizar(c);
  notifyListeners();
}
```

---

## PASSO 4 — `lib/widgets/chamado_card.dart`

Dentro do `trailing` do `ListTile`, adicionar o botão de urgência:

```dart
trailing: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [

    // ← ADICIONAR ESTE BLOCO
    GestureDetector(
      onTap: () => context.read<ChamadoProvider>().toggleUrgente(chamado),
      child: Icon(
        chamado.urgente
            ? Icons.warning_amber           // ícone cheio = urgente
            : Icons.warning_amber_outlined, // ícone vazio = normal
        color: chamado.urgente ? Colors.red : Colors.grey,
        size: 26,
      ),
    ),
    SizedBox(height: 4),

    // ... botão de editar já existente
  ],
),
```

> 💡 Se o import do provider ainda não existir, adicione no topo:
> ```dart
> import 'package:provider/provider.dart';
> ```

---

## PASSO 5 — `lib/screens/urgentes_screen.dart` *(arquivo novo)*

Criar o arquivo `lib/screens/urgentes_screen.dart` com o conteúdo abaixo:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chamado_provider.dart';
import '../widgets/chamado_card.dart';

class UrgentesScreen extends StatelessWidget {
  const UrgentesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final urgentes = context.watch<ChamadoProvider>().urgentes;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        title: const Text('⚠️ Chamados Urgentes'),
      ),
      body: urgentes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 70, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Nenhum chamado marcado como urgente',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Toque em ⚠ em um chamado para marcar',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: urgentes.length,
              itemBuilder: (_, i) => ChamadoCard(chamado: urgentes[i]),
            ),
    );
  }
}
```

---

## PASSO 6 — `lib/screens/dashboard_screen.dart`

### 6a. Adicionar o import no topo do arquivo

```dart
import 'urgentes_screen.dart'; // ← ADICIONAR
```

### 6b. Adicionar botão no `AppBar`

```dart
AppBar(
  title: Text('SOS Cidade'),
  actions: [

    // ← ADICIONAR ESTE BLOCO
    IconButton(
      icon: const Icon(Icons.warning_amber),
      tooltip: 'Chamados Urgentes',
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UrgentesScreen()),
      ),
    ),

  ],
),
```

---

## ✅ Checklist final

- [ ] `chamado.dart` — campo `urgente` adicionado nos 4 lugares
- [ ] `db_helper.dart` — coluna `urgente` no `CREATE TABLE`
- [ ] `chamado_provider.dart` — getter `urgentes` e método `toggleUrgente`
- [ ] `chamado_card.dart` — botão ⚠️ no `trailing`
- [ ] `urgentes_screen.dart` — arquivo criado
- [ ] `dashboard_screen.dart` — import e botão no `AppBar`
