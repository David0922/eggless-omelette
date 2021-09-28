#include "my_str.h"

#include <iostream>

MyStr::MyStr(const char *s) : s(s) {}

std::ostream &operator<<(std::ostream &os, const MyStr &s) { return os << s.s; }
