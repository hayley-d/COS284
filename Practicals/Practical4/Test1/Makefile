# Compiler and assembler settings
CC=gcc
ASM=yasm
CFLAGS=-no-pie -Wall -g
ASMFLAGS=-f elf64 -g dwarf2

# Files
C_SRC=main.c
ASM_SRC=task1_student_struct.asm
C_OBJ=main.o
ASM_OBJ=task1_student_struct.o
EXEC=program

# Default target, builds and runs the program
run: $(EXEC)
	./$(EXEC)

# Build only (compiles and links without running)
build: $(EXEC)

# Link the object files to create the executable
$(EXEC): $(C_OBJ) $(ASM_OBJ)
	$(CC) $(CFLAGS) -o $(EXEC) $(C_OBJ) $(ASM_OBJ)

# Compile C file
$(C_OBJ): $(C_SRC)
	$(CC) $(CFLAGS) -c $(C_SRC) -o $(C_OBJ)

# Assemble the assembly file
$(ASM_OBJ): $(ASM_SRC)
	$(ASM) $(ASMFLAGS) $(ASM_SRC) -o $(ASM_OBJ)

# Clean up the object files and executable
clean:
	rm -f $(C_OBJ) $(ASM_OBJ) $(EXEC)

# Phony targets (targets not referring to files)
.PHONY: run build clean

