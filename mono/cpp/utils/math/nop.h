#pragma once

#include "types.h"

namespace utils::math {

NOPRes nop(NOPReq req) { return NOPRes{.a = req.a}; }

}  // namespace utils::math
