# Form Input Sanitization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restrict chamado titles to letters, accented letters, numbers, and spaces, and show a 1000-character remaining counter for descriptions.

**Architecture:** Keep validation and input behavior in the existing `TelaCadastro` form. Use Flutter's built-in input formatter and counter builder so models, providers, and persistence remain unchanged.

**Tech Stack:** Flutter, Dart, flutter_test

---

### Task 1: Add Widget Coverage

**Files:**
- Modify: `test/widget_test.dart`
- Test: `test/widget_test.dart`

- [ ] **Step 1: Write a failing title sanitization test**

Pump `TelaCadastro`, enter `!#Buraco na Rua 10%^`, and expect the title field
to contain `Buraco na Rua 10`.

- [ ] **Step 2: Write a failing description counter test**

Pump `TelaCadastro`, expect `1000 caracteres restantes`, enter a short
description, and verify the remaining count and the 1000-character limit.

- [ ] **Step 3: Run the focused tests**

Run: `flutter test test/widget_test.dart`

Expected: FAIL because the title still accepts most symbols and the description
still hides a 300-character counter.

### Task 2: Implement Form Input Behavior

**Files:**
- Modify: `lib/telas/cadastro.dart`
- Test: `test/widget_test.dart`

- [ ] **Step 1: Restrict title input**

Replace the title formatter with:

```dart
FilteringTextInputFormatter.allow(
  RegExp(r'[a-zA-ZÀ-ÖØ-öø-ÿ0-9 ]'),
)
```

- [ ] **Step 2: Add the description limit and remaining counter**

Set `maxLength: 1000`, remove the hidden `counterText`, and use `buildCounter`
to render the number of remaining characters.

- [ ] **Step 3: Run verification**

Run:

```bash
dart format lib/telas/cadastro.dart test/widget_test.dart
flutter test
flutter analyze
```

Expected: all tests pass and static analysis reports no issues.

