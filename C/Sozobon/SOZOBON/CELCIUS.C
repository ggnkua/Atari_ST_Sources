/* Celsius-Fahrenheit-Umrechnung nach K&R S.16 */
/* CC celsius.c -f -N -O -o celcius.tos        */

#include <stdio.h>
#define LOWER 0
#define UPPER 300
#define STEP 20
main()

{
  int fahr;

  for (fahr = LOWER; fahr <= UPPER; fahr = fahr + STEP)
     printf("%4d %6.1f\n", fahr, (5.0/9.0)*(fahr-32));

  getchar();
}

