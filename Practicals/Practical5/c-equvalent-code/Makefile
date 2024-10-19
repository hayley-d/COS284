# Compiler
CC = gcc

# Compiler flags
CFLAGS = -Wall -g

# Target executable
TARGET = task1 

# Source files
SRCS = task1.c

# Object files
OBJS = $(SRCS:.c=.o)

# Default target: Build the program
all: $(TARGET)

# Compile the program
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

# Compile the .c files into .o files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Run the program with the PPM file (modify image.ppm with your actual file)
run: $(TARGET)
	./$(TARGET) image.ppm

# Clean up the build files
clean:
	rm -f $(OBJS) $(TARGET)

