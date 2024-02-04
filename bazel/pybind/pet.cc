#include "pet.h"

#include <iostream>
#include <string>

Pet::Pet(const std::string &name) : name(name) {}

void Pet::set_name(const std::string &new_name) { name = new_name; }

const std::string &Pet::get_name() const { return name; }

void print_pet(const Pet &pet) { std::cout << pet.get_name() << std::endl; }
