#include <pybind11/pybind11.h>

#include <string>

#include "pet.h"

namespace py = pybind11;

PYBIND11_MODULE(pet_pybind, m) {
  py::class_<Pet>(m, "Pet")
      .def(py::init<const std::string &>())
      .def("set_name", &Pet::set_name)
      .def("get_name", &Pet::get_name);

  m.def("print_pet", &print_pet);
}
