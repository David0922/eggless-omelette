CC = clang++

SRC := $(shell find src/ -name '*.cc')

CC_FLAGS = -Wall -Wextra -Werror -std=c++20 -pedantic

EXE = main

all: build

build: $(SRC)
	$(CC) $(SRC) $(CC_FLAGS) -o $(EXE)

clean:
	rm -rf $(EXE)
