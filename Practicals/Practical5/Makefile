# Variables
ASM_SOURCES = create_pixel.asm task1_read_ppm_file.asm task2_compute_cdf_values.asm task3_histogram_equalisation.asm task4_write_ppm.asm
ASM_OBJECTS = $(ASM_SOURCES:.asm=.o)
C_SOURCE = test.c
C_OBJECT = test.o
EXECUTABLE = program

# Compiler and assembler flags
ASM_FLAGS = -f elf64 -g dwarf2
CFLAGS = -Wall -g -fPIE
LDFLAGS = -no-pie

# Default target
all: $(EXECUTABLE)

# Build executable
$(EXECUTABLE): $(ASM_OBJECTS) $(C_OBJECT)
	$(CC) $(LDFLAGS) -o $@ $^

# Compile C source
$(C_OBJECT): $(C_SOURCE)
	$(CC) $(CFLAGS) -c $< -o $@

# Assemble each .asm file
%.o: %.asm
	yasm $(ASM_FLAGS) -o $@ $<

# Run the program
run: $(EXECUTABLE)
	./$(EXECUTABLE)

# Clean up
clean:
	rm -f $(ASM_OBJECTS) $(C_OBJECT) $(EXECUTABLE)

