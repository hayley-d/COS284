# Makefile for converting a string to a float using assembly and C

# Compiler and assembler
CC = gcc
ASM = yasm

# Compiler and assembler flags
CFLAGS = -c -g -Wall
ASMFLAGS = -f elf64
LDFLAGS = -no-pie

# Target executable
TARGET = test_convert

# Object files
OBJS = test_convert.o convert_string_to_float.o

# Source files
C_SRC = test_convert.c
ASM_SRC = convert_string_to_float.asm

# Default target
all: $(TARGET)

# Linking
$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $(TARGET) $(OBJS)

# Compiling C source files
test_convert.o: $(C_SRC)
	$(CC) $(CFLAGS) -o $@ $<

# Assembling assembly source files
convert_string_to_float.o: $(ASM_SRC)
	$(ASM) $(ASMFLAGS) -o $@ $<

# Clean up build files
clean:
	rm -f $(OBJS) $(TARGET)

# Phony targets
.PHONY: all clean

