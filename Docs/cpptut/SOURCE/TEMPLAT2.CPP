				// Chapter 9 - Program 7
#include <stdio.h>

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
int x = 12, y = -7;
float real = 3.1415;

stack<int> int_stack;
stack<float> float_stack;
stack<char *> string_stack;

   int_stack.push(x);
   int_stack.push(y);
   int_stack.push(77);
   float_stack.push(real);
   float_stack.push(-12.345);
   float_stack.push(100.01);
   string_stack.push("This is line 1");
   string_stack.push("This is the second line");
   string_stack.push("This is the third line");
   string_stack.push(name);

   printf("Integer stack ---> ");
   printf("%8d ", int_stack.pop());
   printf("%8d ", int_stack.pop());
   printf("%8d\n", int_stack.pop());

   printf("  Float stack ---> ");
   printf("%8.3f ", float_stack.pop());
   printf("%8.3f ", float_stack.pop());
   printf("%8.3f\n", float_stack.pop());

   printf("\n     Strings\n");
   do {
      printf("%s\n", string_stack.pop());
   } while (!string_stack.empty());
}


// Result of execution

// Integer stack --->       12       -7       77
//   Float stack --->    3.141  -12.345  100.010
//
//      Strings
// John Herkimer Doe
// This is the third line
// This is the second line
// This is line 1
