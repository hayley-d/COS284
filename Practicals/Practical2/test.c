#include <stdio.h>

extern float convertStringToFloat(const char *str);
extern float* extractAndConvertFloats(int *numFloats);
extern double processArray(float *arr, int size);

int main() {
    int numFloats;
    float *floats = extractAndConvertFloats(&numFloats);

    if (floats != NULL) {
        printf("Converted numbers:\n");
        for (int i = 0; i < numFloats; i++) {
            printf("%f\n", floats[i]);
        }

        double sum = processArray(floats, numFloats);
        printf("The sum of the processed array is: %f\n", sum);

        free(floats);
    }

    return 0;
}