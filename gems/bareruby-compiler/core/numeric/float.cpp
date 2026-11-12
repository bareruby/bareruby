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
