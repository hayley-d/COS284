#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Structure of a pixel
typedef struct PixelNode {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
    unsigned char CdfValue;
    struct PixelNode* up;
    struct PixelNode* down;
    struct PixelNode* left;
    struct PixelNode* right;
} PixelNode;

extern PixelNode* readPPM(FILE* file,int width, int height); 

PixelNode* readPPMImage(const char* file_name,int* width,int* height){
    // Open the PPM file in binary mode
    FILE* file = fopen(file_name,"rb");

    // Exit the program if the file is not opended
    if(!file){
        printf("Failed to open file\n");
        fclose(file);
        exit(1);
    } else {
        printf("File has been opened\n");
    }

    char format[3];

    // read format
    fscanf(file,"%2s",format);

    // Read image width, height and maximum colour value while skipping any comment lines
    fscanf(file, "%d %d", width,height);
    if(*width > 1281) {
        printf("Width is the wrong size ");
        printf("%d\n",*width);
        fclose(file);
        exit(1);
    }

    int max_colour_value;
    fscanf(file,"%d",&max_colour_value);
    //skip_comments(file);

    printf("Finished reading the header\n");
    printf("Width: %d\t",*width);
    printf("Height: %d\n",*height);

    //skip new line after the header
    fgetc(file); 
    struct PixelNode* image = readPPM(file,*width,*height);
    fclose(file);
    return image;
}


/**
 * Frees the memory allocated for the 2D array of PixelNodes.
 *
 * @param image The 2D array of PixelNode pointers to free.
 * @param width The width of the image.
 * @param height The height of the image.
 */
void free_image(PixelNode*** image, int width, int height){
    for(int row = 0; row < height; row++){
        for(int col = 0; col < width; col++){
            free(image[row][col]);
        }
        free(image[row]);
    }
    free(image);
}


/**
 * Main function to demonstrate reading a PPM image and constructing a 2D linked list.
 */
int main() {
    const char* filename = "image.ppm";  // Path to the PPM file
    int width, height;

    // Read the PPM image and construct the 2D linked list of PixelNodes
    PixelNode* image = readPPMImage(filename, &width, &height);
    
    printf("Finished construction\n");

    // Free the memory used by the image
    //free_image(image, width, height);

    return 0;
}
