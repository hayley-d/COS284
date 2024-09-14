# Compiler and assembler
CC = gcc
ASM = yasm

# Compiler and assembler flags
CFLAGS = -Wall -g
ASMFLAGS = -f elf64

# Output executable name
OUTPUT = app

# Source files
ASM_SRC = calculate_matrix_dot_product.asm
C_SRC = test.c

# Object files
OBJ = test.o calculate_matrix_dot_product.o

# Default target to build the executable
all: $(OUTPUT)

# Rule to build the executable
$(OUTPUT): $(OBJ)
	$(CC) $(OBJ) -o $(OUTPUT)

# Compile C source files to object files
test.o: $(C_SRC)
	$(CC) $(CFLAGS) -c $(C_SRC)

# Assemble the assembly file into an object file using YASM
calculate_matrix_dot_product.o: $(ASM_SRC)
	$(ASM) $(ASMFLAGS) -o calculate_matrix_dot_product.o $(ASM_SRC)

# Clean up object files and the executable
clean:
	rm -f $(OBJ) $(OUTPUT)

