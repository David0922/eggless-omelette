#ifndef PET_H
#define PET_H

#include <string>

class Pet {
  std::string name;

 public:
  Pet(const std::string &name);
  void set_name(const std::string &new_name);
  const std::string &get_name() const;
};

void print_pet(const Pet &pet);

#endif /* PET_H */
