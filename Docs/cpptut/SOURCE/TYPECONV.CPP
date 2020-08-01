                                      // Chapter 2 - Program 5
#include <iostream.h>

main()
{
int a = 2;
float x = 17.1, y = 8.95, z;
char c;

   c = (char)a + (char)x;
   c = (char)(a + (int)x);
   c = (char)(a + x);
   c = a + x;

   z = (float)((int)x * (int)y);
   z = (float)((int)x * (int)y);
   z = (float)((int)(x * y));
   z = x * y;

   c = char(a) + char(x);
   c = char(a + int(x));
   c = char(a + x);
   c = a + x;

   z = float(int(x) * int(y));
   z = float(int(x) * int(y));
   z = float(int(x * y));
   z = x * y;
}




// Result of execution
//
// (There is no output from this program)

