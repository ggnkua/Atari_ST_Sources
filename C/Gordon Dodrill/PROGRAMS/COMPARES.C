main()  /* This file will illustrate logical compares */
{
int x = 11,y = 11,z = 11;
char a = 40,b = 40,c = 40;
float r = 12.987,s = 12.987,t = 12.987;

                         /* First group of compare statements */

   if (x == y) z = -13;   /* This will set z = -13 */
   if (x > z)  a = 'A';   /* This will set a = 65  */
   if (!(x > z)) a = 'B'; /* This will change nothing */
   if (b <= c) r = 0.0;   /* This will set r = 0.0 */
   if (r != s) t = c/2;   /* This will set t = 20  */

                         /* Second group of compare statements */
   
   if (x = (r != s)) z = 1000; /* This will set x = some positive
                                  number and z = 1000 */
   if (x = y) z = 222;   /* This sets x = y, and z = 222 */
   if (x != 0) z = 333;  /* This sets z = 333 */
   if (x) z = 444;       /* This sets z = 444 */

                         /* Third group of compare statements */

   x = y = z = 77;
   if ((x == y) && (x == 77)) z = 33; /* This sets z = 33 */
   if ((x > y) || (z > 12))   z = 22; /* This sets z = 22 */
   if (x && y && z) z = 11;           /* This sets z = 11 */
   if ((x = 1) && (y = 2) && (z = 3)) r = 12.00; /* This sets
                             x = 1, y = 2, z = 3, r = 12.00 */
   if ((x == 2) && (y = 3) && (z = 4)) r = 14.56; /* This doesn't
                             change anything */
   
                         /* Fourth group of compares */

   if (x == x); z = 27.345;  /* z always gets changed */
   if (x != x)  z = 27.345;  /* Nothing gets changed */
   if (x = 0)   z = 27.345;  /* This sets x = 0, z is unchanged */

}
