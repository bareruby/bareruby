#include "symbol.native.hpp"

bool BareRuby::Symbol::eq_ovl_symbol(uint32_t self, uint32_t other) {
  return self == other;
}
