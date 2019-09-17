/* The purpose of this file is to introduce additional data types */

main()
{
int a,b,c;            /* -32768 to 32767 with no decimal point */
char x,y,z;           /* 0 to 255 with no decimal point */
float num,toy,thing;  /* 10E-38 to 10E+38 with decimal point */

   a = b = c = -27;
   x = y = z = 'A';
   num = toy = thing = 3.6792;

   a = y;           /* a is now 65 (character A) */
   x = b;           /* x will now be a funny number */
   num = b;         /* num will now be -27.00 */
   a = toy;         /* a will now be 3 */

}
