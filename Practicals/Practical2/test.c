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

/** Console input: `| 32.133 45.66 -21.255 |`'s expected output: 

Enter values separated by whitespace and enclosed in pipes (|):
| 32.133 45.66 -21.255 |
Converted numbers:
32.132999
45.660000
-21.254999
The sum of the processed array is: 475.434491

*/