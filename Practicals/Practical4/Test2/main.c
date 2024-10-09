#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Student {
  int id;
  char name[64];
  float gpa;
};

// Declaration of the external assembly function
extern struct Student *createStudent(int id, char *name, float gpa);
extern void addStudent(struct Student *array, int max_size, char *name,float gpa);

int main() {
  int max_size = 3;
  struct Student students[3] = {0};
  int current_size = 2;

  students[0].id = 12345;
  strcpy(students[0].name, "John Doe");
  students[0].gpa = 3.75;

  students[1].id = 67890;
  strcpy(students[1].name, "Jane Smith");
  students[1].gpa = 3.85;

  char new_student_name[] = "Alice Johnson";
  float new_student_gpa = 3.95;

  addStudent(students, max_size, new_student_name, new_student_gpa);

  current_size++;

  for (int i = 0; i < current_size; i++) {
    printf("Student %d:\n", i + 1);
    printf("ID: %d\n", students[i].id);
    printf("Name: %s\n", students[i].name);
    printf("GPA: %.2f\n\n", students[i].gpa);
  }

  return 0;
}
