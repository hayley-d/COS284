# Makefile for assembling and linking an assembly program with YASM

# Compiler and linker settings
ASM = yasm
LD = ld

# Flags for YASM and ld
ASM_FLAGS = -f elf64
LD_FLAGS =

# Output executable
OUTPUT = app

# Source and object files
SRC = multiply_scalar_to_matrix.asm
OBJ = multiply_scalar_to_matrix.o

# Target to create the executable
$(OUTPUT): $(OBJ)
	$(LD) $(LD_FLAGS) -o $(OUTPUT) $(OBJ)

# Target to assemble the .asm file into an object file
$(OBJ): $(SRC)
	$(ASM) $(ASM_FLAGS) -o $(OBJ) $(SRC)

# Clean target to remove object files and executable
clean:
	rm -f $(OBJ) $(OUTPUT)

