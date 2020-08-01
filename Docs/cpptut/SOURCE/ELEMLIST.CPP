                                    // Chapter 11 - Program 7
#include "elemlist.h"



void
employee_list::add_person(person *new_employee)
{
employee_element *temp;

   temp = new employee_element(new_employee);
   if (start == NULL)
      start = end_of_list = temp;
   else {
      end_of_list->next_employee = temp;
      end_of_list = temp;
   }
}




void
employee_list::display_list(void)
{
employee_element *temp;

   temp = start;
   do {
      temp->employee_data->display();
      temp = temp->next_employee;
   } while (temp != NULL);
}
