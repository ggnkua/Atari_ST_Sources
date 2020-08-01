                                      // Chapter 11 - Program 3
#ifndef SUPERVSR_H
#define SUPERVSR_H

// This defines three subclasses of the parent type person. Different
//  data is stored for the different job classifications to illustrate
//  that it can be done.

#include "person.h"

class supervisor : public person {
   char title[25];
public:
   void init_data(char in_name[], int in_salary, char in_title[]);
   void display(void);
};



class programmer : public person {
   char title[25];
   char language[25];
public:
   void init_data(char in_name[], int in_salary, char in_title[],
                  char in_language[]);
   void display(void);
};



class secretary : public person {
   char shorthand;
   int typing_speed;
public:
   void init_data(char in_name[], int in_salary,
                  char in_shorthand, char in_typing_speed);
   void display(void);
};

#endif
