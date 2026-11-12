#include <cmath>
#include <cstring>

#include "float.native.hpp"

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
