main()
{
int a;              /* simple integer type             */
long int b;         /* long integer type               */
short int c;        /* short integer type              */
unsigned int d;     /* unsigned integer type           */
char e;             /* character type                  */
float f;            /* floating point type             */
double g;           /* double precision floating point */

   a = 1023; 
   b = 2222;
   c = 123;
   d = 1234;
   e = 'X';
   f = 3.14159;
   g = 3.1415926535898;

   printf("a = %d\n",a);      /* decimal output        */
   printf("a = %o\n",a);      /* octal output          */
   printf("a = %x\n",a);      /* hexadecimal output    */
   printf("b = %ld\n",b);     /* decimal long output   */
   printf("c = %d\n",c);      /* decimal short output  */
   printf("d = %u\n",d);      /* unsigned output       */
   printf("e = %c\n",e);      /* character output      */
   printf("f = %f\n",f);      /* floating output       */
   printf("g = %f\n",g);      /* double float output   */
   printf("\n");
   printf("a = %d\n",a);      /* simple int output          */
   printf("a = %7d\n",a);     /* use a field width of 7     */
   printf("a = %-7d\n",a);    /* left justify in field of 7 */
   printf("\n");
   printf("f = %f\n",f);      /* simple float output   */
   printf("f = %12f\n",f);    /* use field width of 12 */
   printf("f = %12.3f\n",f);  /* use 3 decimal places  */
   printf("f = %12.5f\n",f);  /* use 5 decimal places  */ 
   printf("f = %-12.5f\n",f); /* left justify in field */
}