#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Student {
    int id;
    char name[64];
    float gpa;
};

struct StudentNode {
    struct Student *student;
    struct StudentNode *next;
};

extern struct Student* createStudent(int id, char *name, float gpa);
extern void addStudent(struct Student *array, int max_size, char *name, float gpa);
extern void addStudentToList(struct StudentNode **head, char *name, float gpa);

int main() {
    printf("Task 1:\n");
    struct Student* student = createStudent("01", "John Doe", 3.75);
    printf("\n");

    printf("Task 2:\n");
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

    printf("Task 3:\n");

    struct StudentNode *head = NULL;

    struct Student *student1 = malloc(sizeof(struct Student));
    student1->id = 12345;
    strcpy(student1->name, "John Doe");
    student1->gpa = 3.75;

    struct StudentNode *node1 = malloc(sizeof(struct StudentNode));
    node1->student = student1;
    node1->next = NULL;
    head = node1;

    struct Student *student2 = malloc(sizeof(struct Student));
    student2->id = 67890;
    strcpy(student2->name, "Jane Smith");
    student2->gpa = 3.85;

    struct StudentNode *node2 = malloc(sizeof(struct StudentNode));
    node2->student = student2;
    node2->next = NULL;
    node1->next = node2;

    char new_list_student_name[] = "Alice Johnson";
    float new_list_student_gpa = 3.95;

    addStudentToList(&head, new_list_student_name, new_list_student_gpa);

    struct StudentNode *current = head;
    int index = 1;
    while (current != NULL) {
        printf("Student %d:\n", index);
        printf("ID: %d\n", current->student->id);
        printf("Name: %s\n", current->student->name);
        printf("GPA: %.2f\n\n", current->student->gpa);
        current = current->next;
        index++;
    }

    current = head;
    while (current != NULL) {
        struct StudentNode *next = current->next;
        free(current->student);
        free(current);
        current = next;
    }

    return 0;
}
