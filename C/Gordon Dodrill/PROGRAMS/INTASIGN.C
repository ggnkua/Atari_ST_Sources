/* This program will illustrate the assignment statements */

main()
{
int a,b,c;    /* Integer variables for examples */

   a = 12;
   b = 3;
   c = a + b;          /* simple addition */
   c = a - b;          /* simple subtraction */
   c = a * b;          /* simple multiplication */
   c = a / b;          /* simple division */
   c = a % b;          /* simple modulo (remainder) */
   c = 12*a + b/2 - a*b*2/(a*c + b*2);
   c = c/4+13*(a + b)/3 - a*b + 2*a*a;
   a = a + 1;          /* incrementing a variable */
   b = b * 5;

   a = b = c = 20;     /* multiple assignment */
   a = b = c = 12*13/4; 
}
