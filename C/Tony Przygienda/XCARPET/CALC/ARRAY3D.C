/*********************************************************************/
/*																							*/
/*  array3d.c		gebiet : calc		projekt: xcarpet						*/
/*------------------------------------------------------------------	*/
/*  operationen mit dem 3d-datenfeld											*/
/*------------------------------------------------------------------	*/
/*  array_minimax (index,&min,&max)	extremwertsuche						*/
/*  array_setx ()		x-werte initialisieren									*/
/*  array_sety ()		y-werte        "											*/
/*  array_set (index)		x oder y ...										*/
/*  array_add (index,const)	addition jedes elements mit 'const'		*/
/*  array_mul (index,const)	multiplikation etc.							*/
/*																							*/
/*  static :																			*/
/*  array_op (op,index,const)	operation auf jedes element anwenden	*/
/*------------------------------------------------------------------	*/
/*  'index' steht fÅr x, y oder z												*/
/*																							*/
/*********************************************************************/
 
 /*   3. 6.88  stock  */
 /*  12.10.88  tp  Umschreiben in ANSI-Standard */

#include "..\carpet.h"
#include <portab.h>
#if COMPILER==TURBOC
	#include "..\array3d.h"
#endif

#if COMPILER==MEGAMAX
	overlay "calc"
#endif


/* from XCARPET */
extern int xres,yres;
extern double xstart,xend,ystart,yend;
#if COMPILER==TURBOC
	#include "..\xcarpet.h"
#endif

/* from MEMORY  */
extern double *row_vector();
#if COMPILER==TURBOC
	#include "..\memory.h"
#endif

#define ADD	0
#define MUL	1

#define ELEMENT	3

#define X	0
#define Y	1
#define Z	2

#define check_index()	(index >= X  &&  index <= Z)

int array_op(op, index, konst)
int op, index;
double konst;
{
  int x,y;
  double *p;
  
  if (!check_index())  return (FALSE);
  
  for (x = 0; x < xres; x++)
  {
    p = row_vector(x) + index;
    
    for (y = 0; y < yres; y++)
    {
      switch (op)
      {
      case ADD:  (*p) += konst;  break;
      case MUL:  (*p) *= konst;  break;
      default :  return (FALSE);
      }
      p += ELEMENT;
    }	/* for (y)	*/
  }	/* for (x)	*/
  return (TRUE);
}

int array_add (index, konst)
  int index;
  double konst;
{
#if COMPILER==TURBOC
	int array_op(int, int, double);
#endif

  return array_op (ADD, index, konst);
}

int array_mul (index, konst)
  int index;
  double konst;
{
#if COMPILER==TURBOC
	int array_op(int, int, double);
#endif

  return array_op (MUL, index, konst);
}

int array_minimax (index, min, max)
  int index;
  double *min,*max;
{
  int x,y;
  double *p;
  
  if (! check_index())
  {
    *min = *max = 0.;
    return (FALSE);
  }
  for (x = 0; x < xres; x++)
  {
    p = row_vector(x) + index;
    if (!x)  *min = *max = *p;
    
    for (y = 0; y < yres; y++)
    {
      if      (*p < *min) *min = *p;
      else if (*p > *max) *max = *p;
      p += ELEMENT;
    }
  }
  return (*min != *max);
}

void arrayxset()
{
  int x,y;
  double *p,delta,wert;
  
  wert  = xstart;
  delta = (xend - xstart) / (xres - 1);
  
  for (x = 0; x < xres; x++)
  {
    p = row_vector(x) + X;
    
    for (y = 0; y < yres; y++)
    {
      *p = wert;
      p += ELEMENT;
    }
    wert += delta;
  }
}

void arrayyset()
{
  int x,y;
  double *p,delta,wert;
  
  wert  = ystart;
  delta = (yend - ystart) / (yres - 1);
  
  for (y = 0; y < yres; y++)
  {
    for (x = 0; x < xres; x++)
      *(row_vector(x) + y * ELEMENT + Y) = wert;
    wert += delta;
  }
}

void arrayset (index)
int index;
{
#if COMPILER==TURBOC
	void arrayxset(void);
	void arrayyset(void);
#endif

  if      (index == X) arrayxset();
  else if (index == Y) arrayyset();
}

/*******************************************************************/

