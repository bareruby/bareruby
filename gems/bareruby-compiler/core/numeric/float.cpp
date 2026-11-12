#include <cmath>
#include <cstring>
#include <limits>

#include "float.native.hpp"

float BareRuby::Float::infinity() {
  return std::numeric_limits<float>::infinity();
}

bool BareRuby::Float::eq_ovl_float(float self, float other) {
  return self == other;
}

float BareRuby::Float::plus_ovl_float(float self, float other) {
  return self + other;
}

float BareRuby::Float::minus_ovl_float(float self, float other) {
  return self - other;
}

float BareRuby::Float::mul_ovl_float(float self, float other) {
  return self * other;
}

float BareRuby::Float::div_ovl_float(float self, float other) {
  return self / other;
}

float BareRuby::Float::uminus_ovl_float(float self) {
  return -self;
}

float BareRuby::Float::modulo_ovl_float(float self, float other) {
  return std::fmod(self, other);
}

bool BareRuby::Float::lt_ovl_float(float self, float other) {
  return self < other;
}

bool BareRuby::Float::le_ovl_float(float self, float other) {
  return self <= other;
}

bool BareRuby::Float::gt_ovl_float(float self, float other) {
  return self > other;
}

bool BareRuby::Float::ge_ovl_float(float self, float other) {
  return self >= other;
}

bool BareRuby::Float::equal_p_ovl_float(float self, float other) {
  return std::memcmp(&self, &other, sizeof(float)) == 0;
}

bool BareRuby::Float::zero_p_ovl_float(float self) {
  return self == 0.0f;
}

bool BareRuby::Float::positive_p_ovl_float(float self) {
  return self > 0.0f;
}

bool BareRuby::Float::negative_p_ovl_float(float self) {
  return self < 0.0f;
}

float BareRuby::Float::abs_ovl_float(float self) {
  return std::fabs(self);
}

bool BareRuby::Float::finite_p_ovl_float(float self) {
  return std::isfinite(self);
}

float BareRuby::Float::plus_ovl_float_int(float self, int32_t other) {
  return self + static_cast<float>(other);
}

float BareRuby::Float::minus_ovl_float_int(float self, int32_t other) {
  return self - static_cast<float>(other);
}

float BareRuby::Float::mul_ovl_float_int(float self, int32_t other) {
  return self * static_cast<float>(other);
}

float BareRuby::Float::div_ovl_float_int(float self, int32_t other) {
  return self / static_cast<float>(other);
}

float BareRuby::Float::modulo_ovl_float_int(float self, int32_t other) {
  return std::fmod(self, static_cast<float>(other));
}

bool BareRuby::Float::eq_ovl_float_int(float self, int32_t other) {
  return self == static_cast<float>(other);
}

bool BareRuby::Float::lt_ovl_float_int(float self, int32_t other) {
  return self < static_cast<float>(other);
}

bool BareRuby::Float::le_ovl_float_int(float self, int32_t other) {
  return self <= static_cast<float>(other);
}

bool BareRuby::Float::gt_ovl_float_int(float self, int32_t other) {
  return self > static_cast<float>(other);
}

bool BareRuby::Float::ge_ovl_float_int(float self, int32_t other) {
  return self >= static_cast<float>(other);
}

int32_t BareRuby::Float::to_i_ovl_float(float self) {
  return static_cast<int32_t>(self);
}

int32_t BareRuby::Float::truncate_ovl_float(float self) {
  return static_cast<int32_t>(std::trunc(self));
}

int32_t BareRuby::Float::floor_ovl_float(float self) {
  return static_cast<int32_t>(std::floor(self));
}

int32_t BareRuby::Float::ceil_ovl_float(float self) {
  return static_cast<int32_t>(std::ceil(self));
}

int32_t BareRuby::Float::round_ovl_float(float self) {
  return static_cast<int32_t>(std::round(self));
}
