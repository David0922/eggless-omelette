#include "my_str.h"

#include <iostream>

std::ostream &operator<<(std::ostream &os, const MyStr &s) { return os << s.s; }

MyStr::MyStr(const char *s) : s(s) {}

const char *MyStr::c_str() const { return s; }
