
/* varg - Demo */

#include "stdio.h"
#include "varg.h"

main()

{ double summe = 0.0, r_sum();

  printf ("\33E");
  summe += r_sum( "ilfc", 5, 80000L, 32.88, 'A' );
  summe += r_sum( "fdi", 99.1, (double)12.678456673, 15 );
  
  printf( "\nSumme = %lf\n", summe );
  getchar();
} 

double r_sum( typestr )
  char *typestr;
  
{ va_list pointer;
  char    c;
  double  s = 0.0;

  va_start( pointer, typestr );
  while( c=*typestr++ ) {
    switch( c ) {
      case 'c' : 
      case 'i' : s += va_arg( pointer, int ); break;
      case 'l' : s += va_arg( pointer, long ); break;
      case 'f' :
      case 'd' : s += va_arg( pointer, double ); break;
    }
    s += a;
  }
  va_end( pointer );
  return( s );
}

