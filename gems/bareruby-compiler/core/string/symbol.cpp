#include <cstdint>
#include <cstring>

#include "symbol.native.hpp"
#include "symbol_table.hpp"

bool BareRuby::Symbol::eq_ovl_symbol(uint32_t self, uint32_t other) {
  return self == other;
}

int32_t BareRuby::Symbol::cmp_ovl_symbol(uint32_t self, uint32_t other) {
  const SymbolName& left = symbol_names[self];
  const SymbolName& right = symbol_names[other];
  uint32_t length = left.length < right.length ? left.length : right.length;
  int order = std::memcmp(left.bytes, right.bytes, length);
  if (order == 0) {
    return (left.length > right.length) - (left.length < right.length);
  }
  return (order > 0) - (order < 0);
}
