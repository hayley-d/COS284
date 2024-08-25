#include <stdio.h>

// Declaration of the assembly function
extern float convert_string_to_float(const char *str);

int main() {
    const char *test_str1 = "123.45";
    const char *test_str2 = "-678.90";
    const char *test_str3 = "0.001";
    const char *test_str4 = "abc"; // Invalid input

    float result1 = convert_string_to_float(test_str1);
    float result2 = convert_string_to_float(test_str2);
    float result3 = convert_string_to_float(test_str3);
    float result4 = convert_string_to_float(test_str4);

    printf("Test 1: Input: %s, Result: %f\n", test_str1, result1);
    printf("Test 2: Input: %s, Result: %f\n", test_str2, result2);
    printf("Test 3: Input: %s, Result: %f\n", test_str3, result3);
    printf("Test 4: Input: %s, Result: %f\n", test_str4, result4);

    return 0;
}

