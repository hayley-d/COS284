#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h> 
struct Pixel {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
    unsigned char cdfValue;
    struct Pixel* up;
    struct Pixel* down;
    struct Pixel* left;
    struct Pixel* right;
};
// Declaration of the external assembly function
extern struct Pixel* createPixel(unsigned char red, unsigned char green, unsigned char blue ,struct Pixel* up, struct Pixel* down, struct Pixel* left, struct Pixel* right);

int main() {
    printf("Offset of red: %zu\n", offsetof(struct Pixel, red));
    printf("Offset of green: %zu\n", offsetof(struct Pixel, green));
    printf("Offset of blue: %zu\n", offsetof(struct Pixel, blue));
    printf("Offset of cdfValue: %zu\n", offsetof(struct Pixel, cdfValue));
    printf("Offset of up: %zu\n", offsetof(struct Pixel, up));
    printf("Offset of down: %zu\n", offsetof(struct Pixel, down));
    printf("Offset of left: %zu\n", offsetof(struct Pixel, left));
    printf("Offset of right: %zu\n", offsetof(struct Pixel, right));

    struct Pixel* p = createPixel(255,128,64,NULL,NULL,NULL,NULL);

    // Access and print the pixel data from the allocated structure
    printf("red: %u\n", p->red); 
    printf("green: %u\n", p->green);
    printf("blue: %u\n", p->blue);
    printf("CDF Value: %u\n", p->cdfValue);
    free(p);

  return 0;
}
