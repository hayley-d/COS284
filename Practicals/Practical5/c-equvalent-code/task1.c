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

/**
 * Prints the PPM image file byte by byte
 *
 * @param filename The file name
 */
void printBinaryFile(const char *filename) {
    FILE *file = fopen(filename, "rb");  // Open file in binary mode
    if (!file) {
        printf("Error: Could not open file %s\n", filename);
        exit(1);
    }

    int byte;
    while ((byte = fgetc(file)) != EOF) {  // Read each byte
        printf("%02x ", (unsigned char)byte);  // Print each byte in hexadecimal
    }

    printf("\n");
    fclose(file);
}

/**
* Allocates and initilizes a new PixelNode with the RGB values.
*
* @param r The red component of the pixel
* @param g The green component of the pixel
* @param b The blue component of the pixel
* @return A pointer fo the new node.
*/
PixelNode* createNode(unsigned char r, unsigned char g, unsigned char b){
    // Allocate memory for the pixel
    PixelNode* newPixel = (PixelNode*) malloc(sizeof(PixelNode));

    // exit the program if the allocation fails
    if(!newPixel){
        printf("Memory allocation failed\n");
    }

    // Set the values
    newPixel->red = r;
    newPixel->green = g;
    newPixel->blue = b;

    // Initialize the references to NULL
    newPixel->up = NULL;
    newPixel->down = NULL;
    newPixel->left = NULL;
    newPixel->right = NULL;

    return newPixel;
}

/**
 * Skips the comment lines in the header of the image file.
 *
 * @param file A pointer to the open file.
 */
void skip_comments(FILE* file){
    int c = fgetc(file);

    while((c=fgetc(file) != EOF)){
        // Check if whitespace
        if(c == ' ' || c == '\t' || c == '\n'){
            continue;
        }

        if(c == '#'){
            while(c != '\n' && c != EOF){
                // Skip to the end of the line
                c = fgetc(file);
            }
        } else {
            // If a normal character push back to stream
            ungetc(c,file); 
            break;
        }
    }
}

/**
* Reads a binary P6 PPM image file and constructs a 2D array of linked pixel nodes.
*
* @param file_name The name of the PPM image file to read.
* @param width Pointer to an integer where the width of the image will be stored.
* @param height Pointer to an integer where the height of the image will be stored.
* @return A pointer to a 2D array of PixelNodes pointers representing the image.
*/
PixelNode*** readPPMImage(const char* file_name,int* width,int* height){
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

    // Allocate memory for the 2D array of PixelNode pointers
    PixelNode*** image = (PixelNode***) malloc((*height) * sizeof(PixelNode**));
    if(image == NULL) {
        printf("Memory allocation failed\n");
        fclose(file);
        exit(1);
    }

    for(int i = 0; i < *height; i++){
        image[i] = (PixelNode**) malloc((*width) * sizeof(PixelNode*));
    }

    // Read the pixel data row by row
    for(int row = 0; row < *height; row++){
        for(int col = 0; col < *width; col++){
            unsigned char red = fgetc(file);
            unsigned char green = fgetc(file);
            unsigned char blue = fgetc(file);

            // Create pixel node
            image[row][col] = createNode(red,green,blue);

            // Link the neighbors
            if(row > 0){
                image[row][col]->up = image[row-1][col];
            }

            if(col > 0){
                image[row][col]->left = image[row][col-1];
            }
        }
    }

    printf("Finished parsing\n");

    // fill in right and down references
    for(int row = 0; row < *height; row++){
        for(int col = 0; col < *width; col++){
            if(col < *width -1){
                image[row][col]->right = image[row][col+1];
            }

            if(row < *height-1){
                image[row][col]->down = image[row+1][col];
            }
        } 
    }

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

//    printBinaryFile("image.ppm");

    // Read the PPM image and construct the 2D linked list of PixelNodes
    PixelNode*** image = readPPMImage(filename, &width, &height);
    
    printf("Finished construction\n");

    // Free the memory used by the image
    free_image(image, width, height);

    return 0;
}
