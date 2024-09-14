#include <stdio.h>
#include <stdlib.h>

// Declare the assembly function
extern void multiplyScalarToMatrix(float **matrix, float scalar, int rows, int cols);

// Helper function to allocate memory for a matrix
float** allocateMatrix(int rows, int cols) {
    float **matrix = (float **)malloc(rows * sizeof(float *));
    for (int i = 0; i < rows; ++i) {
        matrix[i] = (float *)malloc(cols * sizeof(float));
    }
    return matrix;
}

// Helper function to print the matrix
void printMatrix(float **matrix, int rows, int cols) {
    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
            printf("%.2f ", matrix[i][j]);
        }
        printf("\n");
    }
}

int main() {
    int rows = 2, cols = 2;
    float scalar = 2.5;

    // Allocate memory for a 2x2 matrix
    float **matrix = allocateMatrix(rows, cols);

    // Initialize the matrix
    matrix[0][0] = 1.0; matrix[0][1] = 2.0;
    matrix[1][0] = 3.0; matrix[1][1] = 4.0;

    //printf("Original Matrix:\n");
    //printMatrix(matrix, rows, cols);

    // Call the assembly function to multiply matrix by scalar
    multiplyScalarToMatrix(matrix, scalar, rows, cols);

    // Print the result
   // printf("Result after multiplying by %.2f:\n", scalar);
    //printMatrix(matrix, rows, cols);
    
    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
           matrix[i][j]) = 1;
        }
    }

    // Free the allocated memory
    for (int i = 0; i < rows; ++i) {
        free(matrix[i]);
    }
    free(matrix);

    return 0;
}

