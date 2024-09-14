#include <stdio.h>
#include <stdlib.h>

// Declare the external assembly function
extern float calculateMatrixDotProduct(float **matrix1, float **matrix2, int rows, int cols);

// Helper function to allocate a 2D matrix
float **allocateMatrix(int rows, int cols) {
    float **matrix = (float **)malloc(rows * sizeof(float *));
    for (int i = 0; i < rows; i++) {
        matrix[i] = (float *)malloc(cols * sizeof(float));
    }
    return matrix;
}

// Helper function to free the matrix
void freeMatrix(float **matrix, int rows) {
    for (int i = 0; i < rows; i++) {
        free(matrix[i]);
    }
    free(matrix);
}

// Helper function to initialize a matrix with values
void initializeMatrix(float **matrix, int rows, int cols, float values[]) {
    int k = 0;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            matrix[i][j] = values[k++];
        }
    }
}

// Function to print the matrix (for debugging purposes)
void printMatrix(float **matrix, int rows, int cols) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            printf("%6.2f ", matrix[i][j]);
        }
        printf("\n");
    }
}

int main() {
    int rows = 2;
    int cols = 2;

    // Allocate two matrices
    float **matrix1 = allocateMatrix(rows, cols);
    float **matrix2 = allocateMatrix(rows, cols);

    // Initialize the matrices with values
    float matrix1_values[] = {1.0, 2.0, 3.0, 4.0};  // Matrix 1: 1.0 2.0  3.0 4.0
    float matrix2_values[] = {5.0, 6.0, 7.0, 8.0};  // Matrix 2: 5.0 6.0  7.0 8.0

    initializeMatrix(matrix1, rows, cols, matrix1_values);
    initializeMatrix(matrix2, rows, cols, matrix2_values);

    // Print matrices
    printf("Matrix 1:\n");
    printMatrix(matrix1, rows, cols);

    printf("\nMatrix 2:\n");
    printMatrix(matrix2, rows, cols);

    // Call the assembly function to calculate the dot product
    float result = calculateMatrixDotProduct(matrix1, matrix2, rows, cols);

    // Print the result
    printf("\nDot Product: %.2f\n", result);

    // Free the allocated matrices
    freeMatrix(matrix1, rows);
    freeMatrix(matrix2, rows);

    return 0;
}

