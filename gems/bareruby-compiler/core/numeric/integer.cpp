#include <cstdint>

#include "integer.native.hpp"

bool BareRuby::Integer::eq_ovl_int(int32_t self, int32_t other) {
  return self == other;
}

bool BareRuby::Integer::lt_ovl_int(int32_t self, int32_t other) {
  return self < other;
}

int32_t BareRuby::Integer::plus_ovl_int(int32_t self, int32_t other) {
  return self + other;
}
