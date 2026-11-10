#include <cstdint>

#include "integer.native.hpp"

bool BareRuby::Integer::eq_ovl_int(int32_t self, int32_t other) {
  return self == other;
}
