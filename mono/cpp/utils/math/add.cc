#include "add.h"

namespace utils::math {

AddRes add(AddReq req) { return AddRes{.c = req.a + req.b}; }

}  // namespace utils::math
