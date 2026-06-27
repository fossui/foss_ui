// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'foss_shadows.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$FossShadowsTailorMixin on ThemeExtension<FossShadows> {
  List<BoxShadow> get xs;
  List<BoxShadow> get sm;
  List<BoxShadow> get md;
  List<BoxShadow> get lg;

  @override
  FossShadows copyWith({
    List<BoxShadow>? xs,
    List<BoxShadow>? sm,
    List<BoxShadow>? md,
    List<BoxShadow>? lg,
  }) {
    return FossShadows(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
    );
  }

  @override
  FossShadows lerp(covariant ThemeExtension<FossShadows>? other, double t) {
    if (other is! FossShadows) return this as FossShadows;
    return FossShadows(
      xs: const BoxShadowListLerpEncoder().lerp(xs, other.xs, t),
      sm: const BoxShadowListLerpEncoder().lerp(sm, other.sm, t),
      md: const BoxShadowListLerpEncoder().lerp(md, other.md, t),
      lg: const BoxShadowListLerpEncoder().lerp(lg, other.lg, t),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FossShadows &&
            const DeepCollectionEquality().equals(xs, other.xs) &&
            const DeepCollectionEquality().equals(sm, other.sm) &&
            const DeepCollectionEquality().equals(md, other.md) &&
            const DeepCollectionEquality().equals(lg, other.lg));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(xs),
      const DeepCollectionEquality().hash(sm),
      const DeepCollectionEquality().hash(md),
      const DeepCollectionEquality().hash(lg),
    );
  }
}
