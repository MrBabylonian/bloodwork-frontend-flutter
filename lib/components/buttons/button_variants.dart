import 'button.dart';

/// Convenience constructors for common button variants
/// These provide a more convenient API similar to the React implementation

class PrimaryButton extends Button {
  const PrimaryButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.size = ButtonSize.medium,
    super.isLoading = false,
    super.disabled = false,
    super.width,
    super.borderRadius,
  }) : super(variant: ButtonVariant.primary);
}

class SecondaryButton extends Button {
  const SecondaryButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.size = ButtonSize.medium,
    super.isLoading = false,
    super.disabled = false,
    super.width,
    super.borderRadius,
  }) : super(variant: ButtonVariant.secondary);
}

class DestructiveButton extends Button {
  const DestructiveButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.size = ButtonSize.medium,
    super.isLoading = false,
    super.disabled = false,
    super.width,
    super.borderRadius,
  }) : super(variant: ButtonVariant.destructive);
}

class OutlineButton extends Button {
  const OutlineButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.size = ButtonSize.medium,
    super.isLoading = false,
    super.disabled = false,
    super.width,
    super.borderRadius,
  }) : super(variant: ButtonVariant.outline);
}

class GhostButton extends Button {
  const GhostButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.size = ButtonSize.medium,
    super.isLoading = false,
    super.disabled = false,
    super.width,
    super.borderRadius,
  }) : super(variant: ButtonVariant.ghost);
}

class LinkButton extends Button {
  const LinkButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.size = ButtonSize.medium,
    super.isLoading = false,
    super.disabled = false,
    super.width,
    super.borderRadius,
  }) : super(variant: ButtonVariant.link);
}

class IconButton extends Button {
  const IconButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.variant = ButtonVariant.primary,
    super.isLoading = false,
    super.disabled = false,
    super.borderRadius,
  }) : super(size: ButtonSize.icon);
}
