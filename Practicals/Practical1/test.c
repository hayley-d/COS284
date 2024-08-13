#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h> 
#include <stdbool.h>

extern void greeting(void);
extern int get_user_choice(void);
extern void encrypt_and_print(const char *input);
extern void decrypt_and_print(int num1, int num2, int num3, int num4);

typedef struct {
    void (*function)(void);
    const char *name;    
} TestCase;

int containsSubstring(const char *subStr, const char *mainStr) {
    if (mainStr == NULL || subStr == NULL) {
        return 0;
    }
    if (strstr(mainStr, subStr) != NULL) {
        return 1; 
    } else {
        return 0; 
    }
}

void test_greeting(void) {
    greeting();
}

void test_get_user_choice(void) {
    int choice = get_user_choice();
    if (choice != 1 && choice != 2) {
        printf("Test failed. Expected 1 or 2, got %d.\n", choice);
    } else {
        printf("Test passed.\n");
    }
}

void test_encrypt_and_print(void) {
    char input_buffer[100];
    char input[] = "TEST";
    printf("Original: %s\n", input);
    encrypt_and_print(input);
    printf("\nEnter encrypted values (space-separated): ");
    if (fgets(input_buffer, sizeof(input_buffer), stdin) == NULL) {
        printf("Failed to read input.\n");
        return;
    }
    if(containsSubstring("1930506807 1930507047 1930506823 1930506807", input_buffer)) {
        printf("Encryption Succeeded\n");
        return;
    }
    printf("Encryption Failed\n");
}

void test_decrypt_and_print(void) {
    char input_buffer[100];
    char input[] = "TEST";
    int numbers[4] = {0};
    int count = 0;

    printf("Enter encrypted values (space-separated): ");
    if (fgets(input_buffer, sizeof(input_buffer), stdin) == NULL) {
        printf("Failed to read input.\n");
        return;
    }

    char *token = strtok(input_buffer, " ");
    while (token != NULL && count < 4) {
        numbers[count++] = strtol(token, NULL, 10);
        token = strtok(NULL, " ");
    }

    if (count != 4) {
        printf("Invalid input. Expected 4 numbers.\n");
        return;
    }

    decrypt_and_print(numbers[0], numbers[1], numbers[2], numbers[3]);

    printf("\nEnter decrypted text: ");
    if (fgets(input_buffer, sizeof(input_buffer), stdin) == NULL) {
        printf("Failed to read input.\n");
        return;
    }

    if(containsSubstring("TEST", input_buffer)) {
        printf("Decryption Succeeded\n");
        return;
    }
    printf("Decryption Failed\n");
}

TestCase test_cases[] = {
    {test_greeting, "greeting"},
    {test_get_user_choice, "get_user_choice"},
    {test_encrypt_and_print, "encrypt_and_print"},
    {test_decrypt_and_print, "decrypt_and_print"},
};

int main(void) {
    size_t num_tests = sizeof(test_cases) / sizeof(TestCase);
    for (size_t i = 0; i < num_tests; i++) {
        printf("\nRunning test %s...\n", test_cases[i].name);
        test_cases[i].function();
        printf("$\n");
    }
    return 0;
}
