#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <limits.h>
#include <linux/limits.h>

#define MAX_HEADER_SIZE 512

typedef struct PixelNode {
    unsigned char Red;
    unsigned char Green;
    unsigned char Blue;
    unsigned char CdfValue;
    struct PixelNode* up;
    struct PixelNode* down;
    struct PixelNode* left;
    struct PixelNode* right;
} PixelNode;

extern PixelNode* readPPM(const char* filename); 
extern void computeCDFValues(PixelNode* head);
extern void applyHistogramEqualization(PixelNode* head);
extern void writePPM(const char* filename, const PixelNode* head);

int main() {
    const char* inputFilename = "image01.ppm";
    const char* outputFilename = "output.ppm";

    PixelNode* head = readPPM(inputFilename);
    if (head == NULL) {
        fprintf(stderr, "Failed to read the image.\n");
        return 1;
    }

    //computeCDFValues(head);

    //applyHistogramEqualization(head);

    //writePPM(outputFilename, head);

    return 0;
}
