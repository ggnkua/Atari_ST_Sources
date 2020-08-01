                                       // Chapter 11 - Program 4
#include "supervsr.h"
#include <iostream.h>
#include <stdio.h>
#include <string.h>

// In all cases, init_data assigns values to the class variables and
//  display outputs the values to the monitor for inspection.

void
supervisor::init_data(char in_name[], int in_salary, char in_title[])
{
   strcpy(name,in_name);
   salary = in_salary;
   strcpy(title, in_title);
}




void
supervisor::display(void)
{
   cout << "Supervisor --> " << name << "'s salary is " << salary <<
                                 " and is the " << title << ".\n\n";
}




void
programmer::init_data(char in_name[], int in_salary, char in_title[],
                  char in_language[])
{
   strcpy(name,in_name);
   salary = in_salary;
   strcpy(title, in_title);
   strcpy(language, in_language);
}




void
programmer::display(void)
{
   cout << "Programmer --> " << name << "'s salary is " << salary <<
                                        " and is " << title << ".\n";
   cout << "               " << name << "'s specialty is " << 
                                                 language << ".\n\n";
}




void
secretary::init_data(char in_name[], int in_salary, 
                             char in_shorthand, char in_typing_speed)
{
   strcpy(name,in_name);
   salary = in_salary;
   shorthand = in_shorthand;
   typing_speed = in_typing_speed;
}




void
secretary::display(void)
{
   cout << "Secretary ---> " << name << "'s salary is " << salary <<
                                                                 ".\n";
   cout << "               " << name << " types " << typing_speed <<
              " per minute and can ";
   if (!shorthand) cout << "not ";
   cout << "take shorthand.\n\n";
}
