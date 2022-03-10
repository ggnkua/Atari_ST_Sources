/* Output from p2c, the Pascal-to-C translator */
/* From input file "dist/examples/fact.p" */


#include <p2c/p2c.h>


Static long i;



Static long fact(n)
long n;
{
  if (n > 1)
    return (n * fact(n - 1));
  else
    return 1;
}



main(argc, argv)
int argc;
Char *argv[];
{
  PASCAL_MAIN(argc, argv);
  for (i = 1; i <= 10; i++)
    printf("The factorial of %ld is %ld\n", i, fact(i));
  exit(EXIT_SUCCESS);
}






/* End. */
