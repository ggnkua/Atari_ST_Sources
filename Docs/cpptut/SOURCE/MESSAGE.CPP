                                   // Chapter 1 - Program 3
#include <iostream.h>
#include <string.h>

main()
{
int index;
float distance;
char letter;
char name[25];

   index = -23;
   distance = 12.345;
   letter = 'X';
   strcpy(name,"John Doe");

   cout << "The value of index is "    << index    << "\n";
   cout << "The value of distance is " << distance << "\n";
   cout << "The value of letter is "   << letter   << "\n";
   cout << "The value of name is "     << name     << "\n";

   index = 31;
   cout << "The decimal value of index is " << dec << index << "\n";
   cout << "The octal value of index is " << oct << index << "\n";
   cout << "The hex value of index is " << hex << index << "\n";
   cout << "The character letter is " << (char)letter << "\n";

   cout << "Input a decimal value --> ";
   cin  >> index;
   cout << "The hex value of the input is " << index << "\n";
}




// Result of execution
//
// The value of index is -23
// The value of distance is 12.345
// The value of letter is X
// The value of name is John Doe
// The decimal value of index is   31
// The octal value of index is   37
// The hex value of index is   1f
// The character letter is X
// Input a decimal value --> 999
// The hex value of the input is 3e7
