# Compiler and assembler settings
CC=gcc
ASM=yasm
CFLAGS=-no-pie -Wall -g
ASMFLAGS=-f elf64 -g dwarf2

# Files
C_SRC=main.c
ASM_SRC=task2_student_array.asm
ASM_SRC1=task1_student_struct.asm  # Add the new assembly file
C_OBJ=main.o
ASM_OBJ=task2_student_array.o
ASM_OBJ1=task1_student_struct.o  # Object file for task1_student_struct.asm
EXEC=program

# Default target, builds and runs the program
run: $(EXEC)
	./$(EXEC)

# Build only (compiles and links without running)
build: $(EXEC)

# Link the object files to create the executable
$(EXEC): $(C_OBJ) $(ASM_OBJ) $(ASM_OBJ1)  # Link the new object file as well
	$(CC) $(CFLAGS) -o $(EXEC) $(C_OBJ) $(ASM_OBJ) $(ASM_OBJ1)

# Compile C file
$(C_OBJ): $(C_SRC)
	$(CC) $(CFLAGS) -c $(C_SRC) -o $(C_OBJ)

# Assemble the assembly file for task2_student_array.asm
$(ASM_OBJ): $(ASM_SRC)
	$(ASM) $(ASMFLAGS) $(ASM_SRC) -o $(ASM_OBJ)

# Assemble the assembly file for task1_student_struct.asm
$(ASM_OBJ1): $(ASM_SRC1)
	$(ASM) $(ASMFLAGS) $(ASM_SRC1) -o $(ASM_OBJ1)

# Clean up the object files and executable
clean:
	rm -f $(C_OBJ) $(ASM_OBJ) $(ASM_OBJ1) $(EXEC)

# Phony targets (targets not referring to files)
.PHONY: run build clean

