#include <cstdint>
#include <cstdlib>

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

int32_t BareRuby::Integer::mul_ovl_int(int32_t self, int32_t other) {
  return self * other;
}

uint64_t BareRuby::Integer::rshift_ovl_u64(uint64_t self, int32_t other) {
  return self >> other;
}

uint8_t BareRuby::Integer::to_u8_ovl_int(int32_t self) {
  return static_cast<uint8_t>(self);
}

uint8_t BareRuby::Integer::to_u8_ovl_u64(uint64_t self) {
  return static_cast<uint8_t>(self);
}

bool BareRuby::Integer::eq_ovl_u8(uint8_t self, uint8_t other) {
  return self == other;
}

bool BareRuby::Integer::gt_ovl_int(int32_t self, int32_t other) {
  return self > other;
}

int32_t BareRuby::Integer::cmp_ovl_int(int32_t self, int32_t other) {
  return (self > other) - (self < other);
}

int32_t BareRuby::Integer::abs_ovl_int(int32_t self) {
  return std::abs(self);
}
