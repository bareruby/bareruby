#include <cstdint>

#include "basic_object.native.hpp"

uint64_t BareRuby::BasicObject::address(BareRuby::generated::BasicObject* self) {
  return reinterpret_cast<uintptr_t>(self);
}
