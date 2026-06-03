# Dashboard Extras Design

## Goal

Add the remaining challenge extras to SOS Cidade without weakening the existing
business rules, persistence, dark mode, or dashboard readability:

- filtro por bairro;
- busca;
- notificações locais;
- animações;
- favoritos;
- ranking de bairros.

Dark mode is already implemented and remains part of the completed extras.

## Scope

The work extends the existing Flutter, Riverpod, and SQLite architecture. It
does not add a backend, remote push notifications, user accounts, maps, or an
external API.

## Approved Product Behavior

### Search

The dashboard search matches the following chamado fields:

- título;
- descrição;
- bairro;
- categoria;
- responsável.

Matching is case-insensitive and accent-insensitive. Search affects only the
visible chamado list. It does not change dashboard totals, summary cards, the
critical alert, or the bairro ranking.

### Bairro Filter

The bairro filter options are derived from saved chamados and sorted
alphabetically. The user can select one bairro or return to `Todos os bairros`.
The bairro filter combines with search and the favorites filter.

### Favorites

Every chamado can be marked as favorite, including concluded chamados.
Favorites are persisted in SQLite and remain available after the app restarts.
A `Somente favoritos` filter limits the visible list to favorite chamados.

Favorite persistence failures must not leave the UI showing an unsaved state.
The app shows an error message and keeps the previous favorite value.

### Ranking de Bairros

The dashboard displays a compact ranking of bairros based on active chamados:

- active means `Aberto` or `Em Andamento`;
- bairros are sorted by active chamado count, descending;
- ties are resolved by critical active chamado count, descending;
- remaining ties are resolved by bairro name, ascending.

The ranking is global and does not change when list filters are active. Each
ranking row shows position, bairro, active count, and critical active count.

### Local Notifications

The app sends local device notifications in two situations:

- a new chamado is created with priority `Alta` or `Crítica`;
- an existing chamado changes status.

Notification permission is requested through the notification plugin. A denied
permission, initialization problem, or notification delivery failure must never
block creating, editing, or updating a chamado.

Remote push notifications and background synchronization are outside this
scope.

### Animations

Animations communicate state changes without adding continuous or decorative
motion:

- favorite star changes animate;
- visible list and empty-state changes animate;
- result count changes animate;
- dashboard statistic values animate when their counts change.

## Architecture

### Persistence

SQLite moves from schema version 1 to version 2. The `chamados` table gains:

```sql
favorito INTEGER NOT NULL DEFAULT 0
```

The upgrade path uses `ALTER TABLE` so existing chamados remain intact and
default to not favorite.

The `Chamado` model gains a `bool favorito` property. `fromMap` treats a missing
or zero value as `false`; `toMap` stores `true` as `1` and `false` as `0`.

Favorite changes use a dedicated database update operation. This is required
because concluded chamados cannot be edited, but they are allowed to be
favorited.

### Provider State

`ChamadoProvider` remains the source of truth for chamado state. It keeps:

- the complete persisted chamado list;
- the sorted global list;
- the current search term;
- the selected bairro;
- the `Somente favoritos` flag;
- the filtered visible list.

Global dashboard counts use the complete list. The `chamados` getter exposes
the visible filtered list for the dashboard.

The provider exposes commands to update search, bairro, favorite filtering,
clear filters, and toggle a chamado favorite. It also exposes sorted bairro
options, visible result count, and the active bairro ranking.

Search text normalization lives in a focused utility so the matching behavior
can be tested independently.

### Notification Service

Local notification plugin integration is isolated behind a small notification
service. The service owns initialization, permission requests, notification
channels/details, and safe error handling.

`ChamadoProvider` triggers notifications after successful persistence:

- after adding an `Alta` or `Crítica` chamado;
- after detecting a real status transition during an update.

The provider does not wait for notification success before reporting that the
chamado operation succeeded.

### Dashboard Components

The dashboard remains an operational screen rather than a marketing layout.
New controls appear between the summary content and the chamado list:

- a compact search field with search and clear icons;
- a wrapping filter row with bairro selection, favorites toggle, and result
  count;
- an unframed `Ranking de bairros` section;
- a theme-aware empty state with a clear-filters command.

Each chamado card gains a 48-pixel favorite icon button with a tooltip. New
surfaces and text use `ColorScheme` values so they remain readable in light and
dark modes.

The growing dashboard file should be split only where the new responsibilities
create clear component boundaries. Search/filter controls, ranking, and chamado
cards are suitable focused widgets; unrelated refactoring is excluded.

## Error Handling

- A database migration error remains a startup-level persistence error.
- Favorite update errors show a snackbar and preserve the previous favorite
  state.
- Notification errors are swallowed by the notification service after safe
  handling so core chamado operations continue.
- If no chamados match filters, the dashboard shows `Nenhum chamado encontrado`
  and offers `Limpar filtros`.
- If there are no chamados at all, the dashboard shows a distinct initial empty
  state that directs the user to create one.
- If there are no active chamados, the ranking section shows a concise empty
  message instead of blank space.

## Testing

### Model and Persistence

- `Chamado.fromMap` defaults `favorito` to false for legacy rows.
- `Chamado.toMap` stores the favorite flag as an integer.
- The SQLite schema upgrade adds the favorite column without removing existing
  data where practical in the test environment.

### Provider and Utilities

- search matches all approved fields;
- search is case-insensitive and accent-insensitive;
- bairro and favorites filters combine;
- global counts remain unchanged while the visible list changes;
- bairro options are sorted;
- ranking uses only active chamados and follows all tie-break rules;
- concluded chamados can be favorited;
- notifications trigger only for approved creation and status-change cases;
- notification failures do not block chamado operations.

### Widgets

- dashboard exposes search, bairro, favorites, and ranking controls;
- empty states render correctly;
- favorite buttons are accessible and visible in dark mode;
- list filtering updates the visible result count;
- existing dark-mode, status-action, form, and FAB-clearance tests remain
  passing.

## Acceptance Criteria

- All requested extras are visible and usable in the app.
- Favorites persist across app restarts.
- Existing SQLite data survives the schema upgrade.
- Dashboard totals remain global while filters affect only the list.
- Notifications never block chamado operations.
- New UI remains readable in light and dark modes.
- `flutter test`, `flutter analyze`, and simulator builds pass.

