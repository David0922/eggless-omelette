from pybind.pet_pybind import Pet, print_pet


def main():
  lucky = Pet('Lucky')
  print(lucky.get_name())

  lucky.set_name('Lucky 🐶')
  print_pet(lucky)


if __name__ == '__main__':
  main()
