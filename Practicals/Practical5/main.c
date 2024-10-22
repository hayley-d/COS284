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
    printf("Size of struct: %zu bytes\n", sizeof(struct Pixel));

    struct Pixel* p = createPixel(77,128,64,NULL,NULL,NULL,NULL);
    struct Pixel* other_pixel = createPixel(20,40,60,NULL,NULL,NULL,NULL);
    struct Pixel* other_pixel2 = createPixel(40,50,60,NULL,NULL,NULL,NULL);
    struct Pixel* p2 = createPixel(255,128,64,p,NULL,NULL,NULL);


    // Access and print the pixel data from the allocated structure
    printf("red: %u\n", p->red); 
    printf("green: %u\n", p->green);
    printf("blue: %u\n", p2->blue);
    printf("CDF Value: %u\n", p2->cdfValue);

    if (p2->up != NULL && p2->up == p) {
        printf("Up pixel - Red: %u\n", p2->up->red);
    } else {
        printf("Up pixel is NULL\n");
    }

    if(p2->down == NULL && p2->left == NULL && p2->right == NULL) {
        printf("Test Passed\n");
    }

    struct Pixel* p3 = createPixel(45,33,23,p,p2,other_pixel,other_pixel2);

    if(p3->up != NULL && p3->up == p) {
        if(p3->up->blue == 64) {
            printf("P3 up is correct\n");
        } else {
            printf("P3 up is wrong\n");
        }
    }

    if(p3->down != NULL && p3->down == p2) {
        if(p3->down->green == 128) {
            printf("P3 down is correct\n");
        } else {
            printf("P3 down is wrong\n");
        }
    }

    if(p3->left != NULL && p3->left == other_pixel) {
        if(p3->left->cdfValue == 0) {
            printf("P3 left is correct\n");
        } else {
            printf("P3 left is wrong\n");
        }
    }
    free(p);

  return 0;
}
