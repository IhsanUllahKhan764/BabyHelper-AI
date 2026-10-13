# Flutter Design System
> Universal design token and UI standards for Flutter apps using Provider + go_router architecture

---

## 1. Design Tokens

All tokens are defined **once** in `core/constants/` and imported everywhere.  
Inline values (`Color(0xFF...)`, `TextStyle(...)`, hardcoded numbers) are strictly forbidden.

### Colors
**File:** `core/constants/app_colors.dart`

```dart
class AppColors {
  static const Color primary       = Color(0xFF0057FF);
  static const Color primaryLight  = Color(0xFFE8F0FF);
  static const Color secondary     = Color(0xFF00C896);
  static const Color error         = Color(0xFFD32F2F);
  static const Color warning       = Color(0xFFFFA000);
  static const Color success       = Color(0xFF388E3C);
  static const Color background    = Color(0xFFF5F5F5);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color border        = Color(0xFFE0E0E0);
  static const Color disabled      = Color(0xFFBDBDBD);
}
```

### Typography
**File:** `core/constants/app_text_styles.dart`

```dart
class AppTextStyles {
  static const TextStyle heading1   = TextStyle(fontSize: 28, fontWeight: FontWeight.w700);
  static const TextStyle heading2   = TextStyle(fontSize: 22, fontWeight: FontWeight.w600);
  static const TextStyle heading3   = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const TextStyle bodyLarge  = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  static const TextStyle bodySmall  = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  static const TextStyle label      = TextStyle(fontSize: 13, fontWeight: FontWeight.w500);
  static const TextStyle caption    = TextStyle(fontSize: 11, fontWeight: FontWeight.w400);
  static const TextStyle button     = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
}
```

### Spacing / Dimensions
**File:** `core/constants/app_dimens.dart`

```dart
class AppDimens {
  static const double d4  = 4;
  static const double d8  = 8;
  static const double d12 = 12;
  static const double d16 = 16;
  static const double d20 = 20;
  static const double d24 = 24;
  static const double d32 = 32;
  static const double d40 = 40;
  static const double d48 = 48;
  static const double d64 = 64;

  // Border radius
  static const double radiusSm   = 6;
  static const double radiusMd   = 12;
  static const double radiusLg   = 20;
  static const double radiusFull = 999;

  // Icon sizes
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
}
```

### Assets
**File:** `core/constants/app_assets.dart`

```dart
class AppAssets {
  static const String logo        = 'assets/images/logo.png';
  static const String placeholder = 'assets/images/placeholder.png';
  static const String icHome      = 'assets/icons/ic_home.svg';
  static const String animLoading = 'assets/animations/loading.json';
}
```

### Strings
**File:** `core/constants/app_strings.dart`

All static user-facing strings live here. For multi-language support, move to `l10n/`.

---

## 2. Theme

**File:** `core/theme/theme.dart`  
**Companion:** `core/theme/typography.dart`

- Builds a single `ThemeData` consumed by `MaterialApp`
- Global styles for buttons, inputs, and app bars defined here
- `typography.dart` maps `AppTextStyles` tokens into Flutter's `TextTheme`

```dart
ThemeData buildAppTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  textTheme: buildTextTheme(),
  elevatedButtonTheme: ElevatedButtonThemeData(...),
  inputDecorationTheme: InputDecorationTheme(...),
  appBarTheme: AppBarTheme(...),
);
```

---

## 3. Shared Widgets

**Folder:** `core/widgets/`

Use these everywhere instead of raw Flutter widgets. Never duplicate UI components per feature.

| Widget | Purpose |
|--------|---------|
| `app_button.dart` | Primary / secondary / outlined / text buttons |
| `app_text_field.dart` | Styled input with validation and error display |
| `app_loader.dart` | Loading indicator — full-screen or inline |
| `app_bar_widget.dart` | Consistent app bar with back/action support |
| `app_empty_state.dart` | Empty / no-data placeholder with icon + message |
| `app_toast.dart` | In-app snackbar / toast notification |
| `app_avatar.dart` | User/entity avatar with fallback initials |
| `app_divider.dart` | Styled divider with optional label |
| `app_chip.dart` | Tag / status chip |
| `app_bottom_sheet.dart` | Reusable bottom sheet wrapper |

---

## 4. Screen Transitions

**Requirement:** All screen transitions use **fade animation** by default.

**File:** `app/routes/app_router.dart`

```dart
CustomTransitionPage<T> fadePage<T>({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
```

Every route uses:
```dart
pageBuilder: (context, state) => fadePage(child: SomePage(), state: state)
```

---

## 5. State & Error UX

| App State | Widget to Use |
|-----------|--------------|
| Loading | `app_loader.dart` |
| Empty / no data | `app_empty_state.dart` |
| Success / info feedback | `app_toast.dart` |
| Form field error | inline inside `app_text_field.dart` |

---

## 6. Form Validation

**File:** `core/utils/validators.dart`

All validator functions live here. No inline validation logic inside pages or ViewModels.

```dart
class Validators {
  static String? email(String? v)               { ... }
  static String? phone(String? v)               { ... }
  static String? required(String? v)            { ... }
  static String? minLength(String? v, int min)  { ... }
  static String? password(String? v)            { ... }
}
```

---

## 7. Enforcement Rules

| ✅ Required | ❌ Forbidden |
|------------|------------|
| `AppColors.*` for all colors | Inline `Color(0xFF...)` |
| `AppTextStyles.*` for all text styles | Inline `TextStyle(...)` |
| `AppDimens.*` for all spacing and sizing | Hardcoded numeric values |
| Shared widgets from `core/widgets/` | Duplicating components per feature |
| `fadePage()` for all route transitions | Custom per-route transition code |
| `Validators.*` for all form validation | Inline validation logic |
| `AppAssets.*` for all asset paths | Hardcoded string paths |
