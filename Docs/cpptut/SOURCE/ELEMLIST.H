                                      // Chapter 11 - Program 6
#ifndef ELEMLIST_H
#define ELEMLIST_H

#define NULL 0
#include "person.h"

class employee_list;                // Forward declaration

class employee_element {            // One element of the linked list
   person *employee_data;
   employee_element *next_employee;
public:
   employee_element(person *new_employee)
                   {next_employee = NULL;
                    employee_data = new_employee;};
   friend class employee_list;
};



class employee_list {                // The linked list
   employee_element *start;
   employee_element *end_of_list;
public:
   employee_list() {start = NULL;}
   void add_person(person *new_employee);
   void display_list(void);
};

#endif
