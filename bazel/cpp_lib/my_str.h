#ifndef MY_STR_H
#define MY_STR_H

#include <iostream>

class MyStr {
  friend std::ostream &operator<<(std::ostream &, const MyStr &);

  const char *s;

 public:
  MyStr(const char *);

  const char* c_str() const;
};

std::ostream &operator<<(std::ostream &, const MyStr &);

#endif /* MY_STR_H */
