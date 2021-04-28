/* a test of some simple floating point operations and output */
/* 08/25/91 - added a few more tests, now that we can do trig */

#include <stdio.h>
#include <stdarg.h>
#include <math.h>

#define deg_to_rad(degrees) (((M_PI*2)*(degrees))/360.0)

void test_varg(fmt)
    char    *fmt;
{
    va_list args;
    
    va_start(args, fmt);
    vprintf(fmt, args);
    va_end(args);
}

void main()
{
    char    buffer[256];
    
    printf("Floating point support is working if...\n\n");

    printf("      2.0 ==  %f\n", 2.0);
    printf("      7.3 ==  %f\n", 9.2-1.9);
    printf("     10.0 == %f\n", sqrt(100.0));
    
    printf("%9.6f == %9.6f (approx)\n", sin(deg_to_rad(45.0)), cos(deg_to_rad(45.0)));
    
    sprintf(buffer, "     22.5 == %f (approx)\n", 20.3+2.2);
    printf(buffer);
    fprintf(stdout, "     33.3 == %f\n", 3.33*10);
    fprintf(stderr, "     20.0 == %f\n", 200.0 / 10.0);
    
    
    test_varg("    %3.1f == %f\n", 127.0, 123.0+10/2.0-1.0);
}
