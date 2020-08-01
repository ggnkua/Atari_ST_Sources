				// Chapter 9 - Program 8
#include <stdio.h>
#include "date.h"

const int MAXSIZE = 128;

template<class ANY_TYPE>
class stack
{
   ANY_TYPE array[MAXSIZE];
   int stack_pointer;
public:
   stack(void) { stack_pointer = 0; };
   void push(ANY_TYPE in_dat) { array[stack_pointer++] = in_dat; };
   ANY_TYPE pop(void)    { return array[--stack_pointer]; };
   int empty(void)       { return (stack_pointer == 0); };
}

char name[] = "John Herkimer Doe";

void main(void)
{
stack<char *> string_stack;
stack<date *> class_stack;
date cow, pig, dog, extra;

   class_stack.push(&cow);
   class_stack.push(&pig);
   class_stack.push(&dog);
   class_stack.push(&extra);

   string_stack.push("This is line 1");
   string_stack.push("This is the second line");
   string_stack.push("This is the third line");
   string_stack.push(name);

   for (int index = 0 ; index < 5 ; index++) {
      extra = *class_stack.pop();
      printf("Date = %d %d %d\n", extra.get_month(),
                                  extra.get_day(), extra.get_year());
   };

   printf("\n     Strings\n");
   do {
      printf("%s\n", string_stack.pop());
   } while (!string_stack.empty());
}


// Result of execution

// Date = 1 7 1992
// Date = 1 7 1992
// Date = 1 7 1992
// Date = 1 7 1992
//
//      Strings
// John Herkimer Doe
// This is the third line
// This is the second line
// This is line 1
