/// Error and failure display widgets module
///
/// Provides widgets for displaying failures, empty states, and message banners
/// following ADR-002 (Exception Isolation Strategy).
///
/// ## Widget Categories
///
/// ### For [Failure] objects (from Domain layer)
/// Use `FailureView` and related widgets:
/// ```dart
/// FailureView(
///   failure: NetworkFailure(message: 'No internet'),
///   onRetry: () => bloc.add(RetryEvent()),
///   compact: false, // or true for inline display
/// )
///
/// // Access styling directly via extension
/// final style = failure.displayStyle;
/// Icon(style.icon, color: style.color);
/// ```
///
/// ### For generic messages (String)
/// Use `MessageBanner`:
/// ```dart
/// MessageBanner(
///   message: 'Changes saved successfully',
///   type: MessageBannerType.success,
///   onDismiss: () => hideBanner(),
/// )
/// ```
///
/// ### For empty lists/states
/// Use `EmptyStateView`:
/// ```dart
/// EmptyStateView(
///   title: 'No data',
///   subtitle: 'Add items to get started',
///   action: () => addItem(),
///   actionLabel: 'Add Item',
/// )
/// ```
library;

export 'empty_state_view.dart';
export 'failure_display_style.dart';
export 'failure_view.dart';
export 'message_banner.dart';
