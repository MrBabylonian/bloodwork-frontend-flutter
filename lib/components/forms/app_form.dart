import 'package:flutter/cupertino.dart';

/// A form field validation result
class FormFieldValidationResult {
  final String? error;
  final bool isValid;

  const FormFieldValidationResult({this.error, required this.isValid});

  static const FormFieldValidationResult valid = FormFieldValidationResult(
    isValid: true,
  );

  static FormFieldValidationResult invalid(String error) {
    return FormFieldValidationResult(error: error, isValid: false);
  }
}

/// A form field validator function
typedef FormFieldValidator<T> = FormFieldValidationResult Function(T? value);

/// A form field data holder
class FormFieldData<T> {
  T? value;
  String? error;
  bool isDirty;
  bool isValid;

  FormFieldData({
    this.value,
    this.error,
    this.isDirty = false,
    this.isValid = true,
  });

  void setValue(T? newValue) {
    value = newValue;
    isDirty = true;
  }

  void setError(String? newError) {
    error = newError;
    isValid = newError == null;
  }

  void validate(FormFieldValidator<T>? validator) {
    if (validator != null) {
      final result = validator(value);
      setError(result.error);
    }
  }

  void reset() {
    value = null;
    error = null;
    isDirty = false;
    isValid = true;
  }
}

/// A form controller that manages form state and validation
class AppFormController extends ChangeNotifier {
  final Map<String, FormFieldData> _fields = {};
  final Map<String, FormFieldValidator<dynamic>> _validators = {};

  /// Register a form field with optional validator
  void registerField<T>(
    String name, {
    FormFieldValidator<T>? validator,
    T? initialValue,
  }) {
    _fields[name] = FormFieldData<T>(value: initialValue);
    if (validator != null) {
      _validators[name] = validator as FormFieldValidator<dynamic>;
    }
  }

  /// Get form field data
  FormFieldData<T>? getField<T>(String name) {
    return _fields[name] as FormFieldData<T>?;
  }

  /// Set field value
  void setFieldValue<T>(String name, T? value) {
    final field = _fields[name];
    if (field != null) {
      field.setValue(value);
      _validateField(name);
      notifyListeners();
    }
  }

  /// Get field value
  T? getFieldValue<T>(String name) {
    return _fields[name]?.value as T?;
  }

  /// Get field error
  String? getFieldError(String name) {
    return _fields[name]?.error;
  }

  /// Validate a specific field
  void _validateField(String name) {
    final field = _fields[name];
    final validator = _validators[name];
    if (field != null && validator != null) {
      field.validate(validator);
    }
  }

  /// Validate all fields
  bool validateAll() {
    bool allValid = true;
    for (final name in _fields.keys) {
      _validateField(name);
      if (!(_fields[name]?.isValid ?? true)) {
        allValid = false;
      }
    }
    notifyListeners();
    return allValid;
  }

  /// Check if form is valid
  bool get isValid {
    return _fields.values.every((field) => field.isValid);
  }

  /// Check if form has any changes
  bool get isDirty {
    return _fields.values.any((field) => field.isDirty);
  }

  /// Get all form data as a map
  Map<String, dynamic> getData() {
    final data = <String, dynamic>{};
    for (final entry in _fields.entries) {
      data[entry.key] = entry.value.value;
    }
    return data;
  }

  /// Reset the form
  void reset() {
    for (final field in _fields.values) {
      field.reset();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _fields.clear();
    _validators.clear();
    super.dispose();
  }
}

/// A widget that provides form context to its children
class AppForm extends StatefulWidget {
  final AppFormController? controller;
  final Widget child;
  final VoidCallback? onChanged;

  const AppForm({
    super.key,
    this.controller,
    required this.child,
    this.onChanged,
  });

  @override
  State<AppForm> createState() => _AppFormState();
}

class _AppFormState extends State<AppForm> {
  late AppFormController _controller;
  bool _isControllerOwned = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = AppFormController();
      _isControllerOwned = true;
    }
    _controller.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onFormChanged);
    if (_isControllerOwned) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFormChanged() {
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormProvider(controller: _controller, child: widget.child);
  }
}

/// An inherited widget that provides form controller to descendants
class AppFormProvider extends InheritedWidget {
  final AppFormController controller;

  const AppFormProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  static AppFormController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppFormProvider>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(AppFormProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// A form field widget that integrates with AppForm
class AppFormField<T> extends StatefulWidget {
  final String name;
  final Widget Function(
    BuildContext context,
    T? value,
    String? error,
    ValueChanged<T?> onChanged,
  )
  builder;
  final FormFieldValidator<T>? validator;
  final T? initialValue;

  const AppFormField({
    super.key,
    required this.name,
    required this.builder,
    this.validator,
    this.initialValue,
  });

  @override
  State<AppFormField<T>> createState() => _AppFormFieldState<T>();
}

class _AppFormFieldState<T> extends State<AppFormField<T>> {
  AppFormController? _formController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _formController = AppFormProvider.of(context);
    if (_formController != null) {
      _formController!.registerField<T>(
        widget.name,
        validator: widget.validator,
        initialValue: widget.initialValue,
      );
    }
  }

  void _onChanged(T? value) {
    _formController?.setFieldValue(widget.name, value);
  }

  @override
  Widget build(BuildContext context) {
    if (_formController == null) {
      throw FlutterError('AppFormField must be used within an AppForm');
    }

    return ListenableBuilder(
      listenable: _formController!,
      builder: (context, child) {
        final value = _formController!.getFieldValue<T>(widget.name);
        final error = _formController!.getFieldError(widget.name);
        return widget.builder(context, value, error, _onChanged);
      },
    );
  }
}

/// Common form validators
class AppFormValidators {
  static FormFieldValidator<String> required([String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return FormFieldValidationResult.invalid(
          message ?? 'This field is required',
        );
      }
      return FormFieldValidationResult.valid;
    };
  }

  static FormFieldValidator<String> email([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return FormFieldValidationResult.valid;
      }
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(value)) {
        return FormFieldValidationResult.invalid(
          message ?? 'Please enter a valid email address',
        );
      }
      return FormFieldValidationResult.valid;
    };
  }

  static FormFieldValidator<String> minLength(
    int minLength, [
    String? message,
  ]) {
    return (value) {
      if (value == null || value.length < minLength) {
        return FormFieldValidationResult.invalid(
          message ?? 'Must be at least $minLength characters long',
        );
      }
      return FormFieldValidationResult.valid;
    };
  }

  static FormFieldValidator<String> maxLength(
    int maxLength, [
    String? message,
  ]) {
    return (value) {
      if (value != null && value.length > maxLength) {
        return FormFieldValidationResult.invalid(
          message ?? 'Must be no more than $maxLength characters long',
        );
      }
      return FormFieldValidationResult.valid;
    };
  }

  static FormFieldValidator<T> combine<T>(
    List<FormFieldValidator<T>> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (!result.isValid) {
          return result;
        }
      }
      return FormFieldValidationResult.valid;
    };
  }
}
