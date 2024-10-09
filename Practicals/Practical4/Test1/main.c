#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Student {
    int id;
    char name[64];
    float gpa;
};
// Declaration of the external assembly function
extern struct Student* createStudent(int id, char *name, float gpa);

int main() {
  struct Student* s = createStudent(1, "John Doe", 3.75);

  // Access and print the student data from the allocated structure
  printf("Student ID: %d\n",s->id); // Access id
  printf("Student Name: %s\n",s->name); // Access name
  printf("Student GPA: %.2f\n", s->gpa);
  free(s);

  return 0;
}
