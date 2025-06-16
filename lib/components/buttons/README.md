# Button Component System

This directory contains a complete button system with clean naming conventions and best practices.

## 🏗️ **Architecture Overview**

The button system follows a **variant-based approach** similar to the

### **Core Components:**

- `button.dart` - Main Button component with all variants
- `button_variants.dart` - Convenience constructors for common variants
- `index.dart` - Clean export API

### **Legacy Components (Deprecated):**

- `app_button.dart` - Old base class (deprecated)
- `primary_button.dart` - Old primary button (deprecated)
- `secondary_button.dart` - Old secondary button (deprecated)
- `ghost_button.dart` - Old ghost button (deprecated)
- Other old components...

## 🎨 **Button Variants**

### **Available Variants:**

```dart
enum ButtonVariant {
  primary,      // Filled primary color
  secondary,    // Light gray background
  destructive,  // Red background for dangerous actions
  outline,      // Transparent with border
  ghost,        // Transparent background
  link,         // Text with underline
}
```

### **Available Sizes:**

```dart
enum ButtonSize {
  small,        // 36px height
  medium,       // 44px height (default)
  large,        // 52px height
  icon,         // Square button for icons
}
```

## 📝 **Usage Examples**

### **Main Button Component:**

```dart
import '../components/buttons/index.dart';

// Using main Button component
Button(
  variant: ButtonVariant.primary,
  size: ButtonSize.large,
  onPressed: () => print('Pressed'),
  child: Text('Click me'),
)
```

### **Convenience Constructors:**

```dart
// These are easier to use and cleaner
PrimaryButton(
  onPressed: () => print('Primary'),
  child: Text('Primary Action'),
)

SecondaryButton(
  size: ButtonSize.small,
  onPressed: () => print('Secondary'),
  child: Text('Secondary Action'),
)

DestructiveButton(
  onPressed: () => print('Delete'),
  child: Text('Delete Item'),
)

OutlineButton(
  onPressed: () => print('Outline'),
  child: Text('Outline Style'),
)

GhostButton(
  onPressed: () => print('Ghost'),
  child: Text('Ghost Style'),
)

LinkButton(
  onPressed: () => print('Link'),
  child: Text('Link Style'),
)

IconButton(
  variant: ButtonVariant.primary,
  onPressed: () => print('Icon'),
  child: Icon(CupertinoIcons.heart),
)
```

### **Advanced Usage:**

```dart
// With loading state
PrimaryButton(
  isLoading: true,
  onPressed: () => print('Loading...'),
  child: Text('Save Changes'),
)

// Disabled state
SecondaryButton(
  disabled: true,
  onPressed: () => print('Disabled'),
  child: Text('Disabled Button'),
)

// Custom width
PrimaryButton(
  width: 200,
  onPressed: () => print('Custom width'),
  child: Text('Wide Button'),
)

// Custom border radius
OutlineButton(
  borderRadius: BorderRadius.circular(20),
  onPressed: () => print('Rounded'),
  child: Text('Rounded Button'),
)
```

## 🎯 **Key Features**

- Same variant names and approach
- Clean, predictable API
- Proper separation of concerns

### **✅ Comprehensive Sizing:**

- Responsive height system
- Proper padding based on size
- Icon button support

### **✅ Full State Management:**

- Loading states with activity indicators
- Disabled states with proper styling
- Hover and press feedback

### **✅ Customizable:**

- Custom widths and border radius
- Flexible content (text, icons, rows)
- Theme-based color system

### **✅ Best Practices:**

- Proper accessibility
- Performance optimized
- Clean documentation

## 🔄 **Migration Guide**

### **From Old System:**

```dart
// OLD WAY (deprecated)
PrimaryButton(
  size: AppButtonSize.medium,
  width: AppButtonWidth.large,
  onPressed: () {},
  child: Text('Button'),
)

// NEW WAY (recommended)
PrimaryButton(
  size: ButtonSize.medium,
  width: 200, // explicit width
  onPressed: () {},
  child: Text('Button'),
)
```

### **Import Changes:**

```dart
// OLD WAY
import '../components/buttons/primary_button.dart';
import '../components/buttons/ghost_button.dart';

// NEW WAY (clean)
import '../components/buttons/index.dart';
```

## 🎨 **Styling System**

All buttons use the centralized theme system:

- Colors from `AppColors`
- Text styles from `AppTextStyles`
- Dimensions from `AppDimensions`

This ensures consistency across the entire application and makes theme changes easy to implement.

## 🔧 **Technical Details**

### **Text Centering:**

The new button system properly handles text centering by:

- Using `DefaultTextStyle` with `textAlign: TextAlign.center`
- Proper container constraints
- Consistent padding system

### **Performance:**

- Minimal widget rebuilds
- Efficient color calculations
- Optimized for various screen sizes

This button system provides a solid foundation for the entire application with clean code, proper naming conventions, and excellent maintainability.
