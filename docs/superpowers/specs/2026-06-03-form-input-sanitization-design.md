# Form Input Sanitization Design

## Goal

Improve the `Novo chamado` and `Editar chamado` form inputs so titles cannot
contain symbols and descriptions clearly communicate the remaining character
limit.

## Approved Behavior

- The title continues to accept letters, Portuguese accented letters, numbers,
  and spaces.
- Symbols and punctuation are removed while the user types or pastes text.
- The existing title maximum of 50 characters and minimum-length validation
  remain unchanged.
- The description maximum increases from 300 to 1000 characters.
- The description shows a visible remaining-character counter, starting at
  `1000 caracteres restantes` and updating as the user types.
- Existing description required and minimum-length validation remain unchanged.

## Implementation

The behavior belongs in `lib/telas/cadastro.dart`, where the form fields are
already defined. Flutter's built-in `FilteringTextInputFormatter.allow` will
enforce the title character allow-list. The description field will use
`maxLength: 1000` and `buildCounter` to render the remaining count.

No model, provider, database, or dependency changes are required.

## Testing

Widget tests will open `TelaCadastro`, enter mixed title input, and confirm that
only allowed characters remain. A second test will verify the initial
description counter, its update after typing, and the 1000-character limit.

