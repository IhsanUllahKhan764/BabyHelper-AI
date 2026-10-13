---
name: flutter-provider-architecture
description: >
  Use this skill when building, reviewing, or extending any Flutter mobile
  application that follows the Provider + go_router architecture pattern.
  Covers folder structure, architecture rules, data layer contracts, routing,
  dependency injection, WebSocket setup, module blueprint, and coding
  standards. Trigger whenever the user mentions a new Flutter app, a new
  feature module, a ViewModel, a repository, routing, or any layer of a
  Flutter project using this stack.
stack: Flutter · Dart · Provider (ChangeNotifier) · go_router · REST · WebSocket (optional)
---

# Flutter Provider Architecture Skill

## Architecture Principles (Non-Negotiable)

### Rule A — No business logic in UI
- **Pages (Widgets):** UI rendering only — no logic
- **ViewModels (ChangeNotifier):** state + UI logic only
- **Repositories:** data access only — no UI logic

### Rule B — No inline styles
- No inline `Color(0xFF...)` or `TextStyle(...)` anywhere
- All styles come from shared design tokens in `core/constants/`
- See `design.md` for the full design system reference

### Rule C — No direct API calls from UI or ViewModels
- ViewModels call → Repositories
- Repositories call → `ApiClient`

### Rule D — One-way data flow
```
Widget → ViewModel (Provider) → Repository → ApiClient / WsClient → Backend
```

---

## Folder Structure

```
lib/
  main.dart
  app/
    app.dart
    config/
      env.dart               # Environment variables (base URL, keys)
      app_config.dart        # App-wide configuration object
    routes/
      app_routes.dart        # All route path constants
      app_router.dart        # go_router setup + fadePage helper
      route_guards.dart      # Guard functions (auth, role, etc.)
    di/
      app_providers.dart     # Composition root — all DI wiring
  core/
    constants/
      app_colors.dart
      app_text_styles.dart
      app_dimens.dart
      app_assets.dart
      app_strings.dart
    theme/
      theme.dart
      typography.dart
    utils/
      logger.dart
      validators.dart
      formatters.dart
      debouncer.dart
      extensions.dart
    widgets/
      app_button.dart
      app_text_field.dart
      app_loader.dart
      app_bar_widget.dart
      app_empty_state.dart
      app_toast.dart
      app_avatar.dart
      app_divider.dart
      app_chip.dart
      app_bottom_sheet.dart
    errors/
      failure.dart
      api_error_mapper.dart
  data/
    api/
      api_client.dart        # HTTP client wrapper
      api_endpoints.dart     # Endpoint string constants only
      api_headers.dart       # Header builders
      api_response.dart      # Generic response wrapper
    realtime/                # Optional — include if app uses WebSockets
      ws_client.dart
      ws_events.dart
      ws_message.dart
    models/                  # Pure data classes (no logic)
      # e.g. user_model.dart, product_model.dart, order_model.dart
    repositories/            # One file per domain
      # e.g. auth_repository.dart, product_repository.dart
    storage/
      local_store.dart       # SharedPreferences wrapper
      token_store.dart       # Auth token read/write
      cache_store.dart       # Optional response cache
  modules/
    # One folder per feature:
    auth/
      pages/
      viewmodels/
      widgets/
    onboarding/
      pages/
      viewmodels/
      widgets/
    home/
      pages/
      viewmodels/
      widgets/
    # ... repeat for every feature
  l10n/       # Optional — ARB files for localization
  generated/  # Optional — generated code (l10n, json_serializable, etc.)
```

---

## Routing (go_router)

### Route constants
**File:** `app/routes/app_routes.dart`

All route path strings live here — nowhere else.

```dart
class AppRoutes {
  static const String splash    = '/splash';
  static const String login     = '/auth/login';
  static const String otp       = '/auth/otp';
  static const String onboarding = '/onboarding';
  static const String home      = '/home';
  // Add app-specific paths here
}
```

### Router
**File:** `app/routes/app_router.dart`

- Configures `GoRouter`
- All redirects and guards centralized here
- Every route uses the shared `fadePage()` helper (see `design.md §4`)

### Guards
**File:** `app/routes/route_guards.dart`

Pure helper functions — no navigation code inside guards.

```dart
// Common guards — add/remove per app requirements
String? authGuard(BuildContext context, GoRouterState state) { ... }
String? onboardingGuard(BuildContext context, GoRouterState state) { ... }
String? roleGuard(BuildContext context, GoRouterState state, String role) { ... }
```

Guards are wired via `redirect` in `app_router.dart`.

---

## Dependency Injection (Provider)

**File:** `app/di/app_providers.dart`

This is the **only** place where dependencies are wired. Nothing else creates repositories or services.

```dart
List<SingleChildWidget> appProviders() => [
  // Infrastructure
  Provider<LocalStore>(create: (_) => LocalStore()),
  Provider<TokenStore>(create: (_) => TokenStore()),
  Provider<ApiClient>(create: (ctx) => ApiClient(ctx.read())),

  // Optional — WebSocket
  Provider<WsClient>(create: (ctx) => WsClient(ctx.read())),

  // Repositories
  Provider<AuthRepository>(create: (ctx) => AuthRepository(ctx.read())),
  // ... all repositories

  // App-wide ViewModels
  ChangeNotifierProvider<SessionViewModel>(create: (ctx) => SessionViewModel(ctx.read())),
];
```

`appProviders()` wraps `MyApp` with `MultiProvider` in `main.dart`.

### Feature ViewModels
- Provide at **route/page level** (preferred)
- Provide app-wide only when truly shared across multiple top-level sections

### UI consumption rules

```dart
// Reactive rebuild — use in build()
context.watch<MyViewModel>()
context.select<MyViewModel, T>((vm) => vm.someField)  // preferred — narrow rebuild

// Action only — use in callbacks
context.read<MyViewModel>().doSomething()
```

---

## Data Layer Contracts

### ApiClient
**File:** `data/api/api_client.dart`

Responsibilities:
1. Build request URL from base URL + endpoint
2. Attach auth headers
3. Parse JSON response
4. Normalize errors → `Failure`
5. Return `ApiResponse<T>`

```dart
class ApiClient {
  Future<ApiResponse<T>> get<T>(String endpoint, ...) async { ... }
  Future<ApiResponse<T>> post<T>(String endpoint, Map body, ...) async { ... }
  Future<ApiResponse<T>> put<T>(String endpoint, Map body, ...) async { ... }
  Future<ApiResponse<T>> delete<T>(String endpoint, ...) async { ... }
}
```

### Endpoints
**File:** `data/api/api_endpoints.dart`

Only string constants — no logic.

```dart
class ApiEndpoints {
  static const String login   = '/auth/login';
  static const String profile = '/user/profile';
  // Add endpoints per app
}
```

### Repositories
**Folder:** `data/repositories/`

Rules:
- Accept `ApiClient` (and optionally `WsClient`) via constructor
- Return **model objects**, never raw JSON
- No UI logic, no navigation

```dart
// Pattern
class ProductRepository {
  final ApiClient _api;
  ProductRepository(this._api);

  Future<List<ProductModel>> getProducts() async { ... }
  Future<ProductModel> getProduct(String id) async { ... }
  Future<ProductModel> createProduct(ProductModel data) async { ... }
}
```

---

## WebSocket Architecture (Optional)

Include only if the app requires real-time features (chat, live updates, notifications).

### WsClient
**File:** `data/realtime/ws_client.dart`

Responsibilities:
- `connect()` / `disconnect()`
- Auth handshake on connect
- Subscribe / unsubscribe to rooms or topics
- Send messages
- Expose typed `Stream` listeners
- Reconnect with exponential backoff (capped)

### Ws Events
**File:** `data/realtime/ws_events.dart`

All event name strings declared in one place.

```dart
class WsEvents {
  static const String chatNewMessage     = 'chat:new_message';
  static const String chatTyping         = 'chat:typing';
  static const String orderStatusUpdated = 'order:status_updated';
  // Add per app
}
```

### Repositories using WsClient

Repositories that mix REST and real-time (e.g., `ChatRepository`) inject both `ApiClient` and `WsClient`:

```dart
class ChatRepository {
  final ApiClient _api;
  final WsClient _ws;
  ChatRepository(this._api, this._ws);

  // REST: history, thread list
  Future<List<MessageModel>> getThreadHistory(String threadId) async { ... }

  // Real-time: stream
  Stream<MessageModel> get incomingMessages => _ws.on(WsEvents.chatNewMessage);
}
```

---

## Module Blueprint

Every feature follows the same three-folder structure:

```
modules/<feature>/
  pages/        ← Screens only — UI rendering, no logic
  viewmodels/   ← ChangeNotifiers — state + UI logic, calls repositories
  widgets/      ← UI components scoped to this feature only
```

### Rules
- Pages call ViewModel methods via `context.read<VM>().method()`
- Pages read state via `context.watch<VM>()` or `context.select<VM, T>(...)`
- ViewModels call Repositories — never `ApiClient` or `WsClient` directly
- Pages never call `ApiClient` or `WsClient` directly

### ViewModel pattern

```dart
class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repo;
  ProductViewModel(this._repo);

  List<ProductModel> products = [];
  bool isLoading = false;
  Failure? error;

  Future<void> loadProducts() async {
    isLoading = true;
    notifyListeners();
    try {
      products = await _repo.getProducts();
      error = null;
    } catch (e) {
      error = ApiErrorMapper.map(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## Error Handling

### Failure model
**File:** `core/errors/failure.dart`

```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure      extends Failure { const NetworkFailure() : super('No internet connection'); }
class TimeoutFailure      extends Failure { const TimeoutFailure() : super('Request timed out'); }
class UnauthorizedFailure extends Failure { const UnauthorizedFailure() : super('Session expired'); }
class ValidationFailure   extends Failure { const ValidationFailure(String msg) : super(msg); }
class UnknownFailure      extends Failure { const UnknownFailure() : super('Something went wrong'); }
```

**File:** `core/errors/api_error_mapper.dart` — maps HTTP status codes and exceptions to `Failure` types.

---

## Coding Standards Checklist

### ✅ Required
- [ ] Provider + ChangeNotifier for all state management
- [ ] `context.select` to minimize unnecessary widget rebuilds
- [ ] All data access through Repositories
- [ ] Design tokens only for colors, text, spacing (`AppColors`, `AppTextStyles`, `AppDimens`)
- [ ] Modules are isolated — no cross-module widget/ViewModel imports
- [ ] All WebSocket logic inside `WsClient` + relevant Repository
- [ ] All route paths in `app_routes.dart`
- [ ] All validators in `core/utils/validators.dart`
- [ ] All environment values in `app_config.dart` / `env.dart`

### ❌ Forbidden
- GetX, Bloc, Riverpod, or any other state management mixed in
- API calls from Pages or ViewModels directly
- WebSocket code scattered across UI files
- Inline colors, text styles, or spacing values
- Creating repositories inside pages
- Hardcoded strings or asset paths in widgets
- Mixing multiple state management approaches
