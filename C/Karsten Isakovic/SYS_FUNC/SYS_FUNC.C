/* -=-=-=-=-=-=-=-=-=-  SysMon  -=-=-=-=-=-=-=-=-=-=-=-

      Example file for the SysMon debugging functions

     sys_func.x      (c) Karsten Isakovic, Berlin 04.94

   -=-=-=-=-=-=-  (ki@cs.tu-berlin.de)  -=-=-=-=-=-=-=- */

/* 

 The GEMDOS(4200) call has the name Sys_Break. The function
 directly calls SysMon, as if the key combination is given.
 
 The GEMDOS(4201) call has the name Sys_Printf. The function
 outputs strings and values into the tracer output of
 SysMon. All parameters are passed on the stack.
 
 The first parameter is a format string that contains
 placeholders for the other parameters. Valid placeholders
 are:
 
   %d   decimal integer
   %ld  decimal long
   %x   hex     integer
   %lx  hex     long
   %s   string
   %c   character
   %%   a % character
 
 If the first character of the format string is a '#', then 
 the next parameter must be an integer value that sets the
 debug-level of this output line. If the given debug-level 
 is higher or equal to the debug-level in the SysMon/Display
 window, the line is output. If the debug-level is smaller,
 the whole line is supressed. If there is no debug-level
 given (ie no '#' at the start of the format string), the
 line is always displayed.
 
 If the first character (or after a leading '#') of the format
 string is a '>' or '<', the indentation of the following
 output is set.

 Karsten Isakovic, 01.04.94
*/

#include <tos.h>


/* 
 * If the following line is comented out, none of the debug
 * functions are compiled into the program code.
 */
#define SYS_DEBUG

#include "sys_func.h"


/*
 * Forward declarations
 */
void Plotter(int a,int b);
int  Polynom(int a,int b,int c,int d,int x);
int  Square(int a);
long Fac(long a);

/* 
 * A simple demo program 
 */
int main(void)
{
 Plotter(-8,8);
 SYS_BREAK();

 Fac(12);
 Cconws("Press Return to quit");
 Cconin();

 return 0;
}


/* -=-=-=-=-=-=-=-=-=-
   The functions Plotter(), Polynom() and Square() are
   nested and all have different debug-levels. The lowlevel-
   function Square() is level zero and the high-level 
   function Plotter() has debug-level two. 
   You can change the debug-level in the SysMon/Display
   window. All functions with a smaller debug-level will
   not be shown in the tracer output.
   -=-=-=-=-=-=-=-=-=- */

/* 
 * Calculates and 'draws' a polynom in the given range 
 */
void Plotter(int a,int b)
{
int  i,k,value;
char str[100];

 SYS_PRINTF3("#>Plotter(%d,%d)",2,a,b);
 
 Cconws("  a X^3 + b X^2 + c X +d      Table\n\r");
 Cconws("-----------------------------------\n\r\n\r");
 for(i=a;i<b;i++)
 {
   value = Polynom(1,5,-3,-10,i)>>4; 
   if (value > 35) 
   { 
     SYS_PRINTF2("#Overflow %d",2,value);
     value = 35;
   }
   else if (value < -35) 
   {
     SYS_PRINTF2("#Underflow %d",2,value);
     value = -35;
   }
   
   
   k = 0;
   while(k<value+35)
   {
     str[k++] = '.';
   }
   str[k++] = 'X';
   str[k++] = '\n';
   str[k++] = '\r';
   str[k]   = 0;
     
   Cconws(str);
   }
 SYS_PRINTF1("#<Plotter",2);
}

/*
 * Calculates the value of the polynom at X
 */
int Polynom(int a,int b,int c,int d,int x)
{
int x2;

 SYS_PRINTF6("#>Polynom(%d,%d,%d,%d,  %d)",1,a,b,c,d,x);

 x2 = Square(x);
 a =a * x * x2  +  b * x2  +  c * x  +  d;

 SYS_PRINTF2("#<Polynom -> %d",1, a);
 return a;
}

/* 
 * Calculates the square of the value a 
 */
int  Square(int a)
{
int b;

 b = a*a;

 SYS_PRINTF3("#Square(%d) -> %d",0,a,b);
 return b;
}


/* -=-=-=-=-=-=-=-=-=-
   The rekursive function fac(n) is an example for the
   automatic indentation of SysMon.
   
   A '>' at the start of the format string indents
   a level, a '<' de-indents.
   
   Since there is no debug-level, all output is traced.
   -=-=-=-=-=-=-=-=-=- */

/*
 * Calculates the faculty
 */
long Fac(long i)
{
long k;

  k = i;
  SYS_PRINTF1(">Fac(%ld)",k);
  if (i>1) 
    i = i*Fac(i-1);
    
  SYS_PRINTF2("<Fac(%ld)->%ld",k,i);
  return i;
}
