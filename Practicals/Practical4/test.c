#include <stdio.h>
#include <stdlib.h>

// Function prototypes (assuming these are implemented in assembly)
extern void multiplyScalarToMatrix(float **matrix, float scalar, int rows, int cols);
extern float** addMatrices(float **matrix1, float **matrix2, int rows, int cols);
extern float calculateMatrixDotProduct(float **matrix1, float **matrix2, int rows, int cols);

// Helper function to allocate a matrix
float** allocateMatrix(int rows, int cols) {
    float **matrix = (float **)malloc(rows * sizeof(float *));
    for (int i = 0; i < rows; i++) {
        matrix[i] = (float *)malloc(cols * sizeof(float));
    }
    return matrix;
}

// Helper function to free a matrix
void freeMatrix(float **matrix, int rows) {
    for (int i = 0; i < rows; i++) {
        free(matrix[i]);
    }
    free(matrix);
}

// Helper function to print a matrix
void printMatrix(float **matrix, int rows, int cols) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            printf("%.2f ", matrix[i][j]);
        }
        printf("\n");
    }
}

// Main function to test the external functions
int main() {
    int rows = 2, cols = 2;

    // Allocate and initialize two matrices
    float **matrix1 = allocateMatrix(rows, cols);
    float **matrix2 = allocateMatrix(rows, cols);

    // Initialize matrix1
    matrix1[0][0] = 1.0; matrix1[0][1] = 2.0;
    matrix1[1][0] = 3.0; matrix1[1][1] = 4.0;

    // Initialize matrix2
    matrix2[0][0] = 5.0; matrix2[0][1] = 6.0;
    matrix2[1][0] = 7.0; matrix2[1][1] = 8.0;

    // Test 1: Scalar multiplication
    float scalar = 2.0;
    printf("Matrix 1 before scalar multiplication:\n");
    printMatrix(matrix1, rows, cols);

    multiplyScalarToMatrix(matrix1, scalar, rows, cols);

    printf("Matrix 1 after scalar multiplication by %.2f:\n", scalar);
    printMatrix(matrix1, rows, cols);

    // Test 2: Matrix addition
    printf("Matrix 1:\n");
    printMatrix(matrix1, rows, cols);
    printf("Matrix 2:\n");
    printMatrix(matrix2, rows, cols);

    float **resultMatrix = addMatrices(matrix1, matrix2, rows, cols);

    printf("Result of adding Matrix 1 and Matrix 2:\n");
    printMatrix(resultMatrix, rows, cols);

    // Test 3: Dot product
    float dotProduct = calculateMatrixDotProduct(matrix1, matrix2, rows, cols);
    printf("Dot product of Matrix 1 and Matrix 2: %.2f\n", dotProduct);

    // Free allocated memory
    freeMatrix(matrix1, rows);
    freeMatrix(matrix2, rows);
    freeMatrix(resultMatrix, rows);

    return 0;
}

/// Expected output:

/*
Matrix 1 before scalar multiplication:
1.00 2.00 
3.00 4.00 
Matrix 1 after scalar multiplication by 2.00:
2.00 4.00 
6.00 8.00 
Matrix 1:
2.00 4.00 
6.00 8.00 
Matrix 2:
5.00 6.00 
7.00 8.00 
Result of adding Matrix 1 and Matrix 2:
7.00 10.00 
13.00 16.00 
Dot product of Matrix 1 and Matrix 2: 140.00
*/
