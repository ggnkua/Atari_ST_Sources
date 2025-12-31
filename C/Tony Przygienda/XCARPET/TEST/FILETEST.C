/********************************************************************
 *
 *  filetest.c		projekt : xcarpet
 *-------------------------------------------------------------------
 *  test fÅr die module FILEIO, ASCIIDAT, XFILES, ARRAY3D
 *-------------------------------------------------------------------
 *
 ********************************************************************/
 
 /*   2. 6.88  stock  */

#include <stdio.h>
#include <portab.h>

#define FILETEST

#include "..\\xcfile\\asciidat.c"

int xres,yres,xlines,ylines;
double xstart,xend,ystart,yend;

extern double *row_vector();

static int titel,punkt,unterpunkt;
static double wert;

static cls()	{  fputs ("\033E",stdout); fflush (stdout);	}

static put_get (text)
  char *text;
{
  int ret;
  
  printf ("%60s  ? ",text);
  fflush (stdout);
  
  return (1 != scanf ("%d",&ret))?  -1: ret;
}

put_extrem (index)
  int index;
{
  double min, max;
  static char xyz[3] = { 'x','y','z' };
  
  if (array_minimax (index,&min,&max))
    printf (" %c-min = %12.6g  %c-max = %12.6g \n",
      xyz[index],min,xyz[index],max);
}

put_single (index)
  int index;
{
  int x,y;
  double *p;
  
  for (x = 0; x < xres; x++)
  {
    p = row_vector (x) + index;
    
    for (y = 0; y < yres; y++)
    {
      printf ("%14.6g  ",*p);
      p += ELEMENT;
    }
    puts ("");
  }
  put_extrem (index);
}

put_all ()
{
  int x,y;
  double *p;
  
  for (x = 0; x < xres; x++)
  {
    p = row_vector (x);
    
    for (y = 0; y < yres; y++)
    {
      printf ("%13.6g%13.6g%13.6g ",*p,*(p+1),*(p+2));
      p += ELEMENT;
    }
    puts ("");
  }
  put_extrem (0);
  put_extrem (1);
  put_extrem (2);

}

put_header ()
{
  puts ("\n header-ausgabe ...\n");
}

static menu()
{
  puts("\n");
  titel = put_get 
    (" dateiop's (1), ausgabe (2), manipulation (3), ende (0)");
  switch (titel)
  {
  case 0: return (FALSE);
  
  case 1: 
    punkt = put_get ("lesen (1), schreiben (2)");  break;
  case 2:
  case 3:
    punkt = put_get ("x (1), y (2), z (3), xyz (4)");
    if (titel == 3)
      {
      unterpunkt = put_get ("add (1), mul (2), init (0)");
      if (unterpunkt == 1  ||  unterpunkt == 2)
        wert = (double) put_get ("wert");
      }
    break;
  }
  return (TRUE);
}

static verzweig ()
{
  int i;
  
  switch (titel)
  {
  case 1:
    if (punkt == 1)		/*     datei lesen	*/
    {
      if (inp_filename())
      {
        cls();
        if (read_header())
        {
          free_xyz();
          if (reserve_xyz (xres, yres))
          {
            put_header();
            read_data();
          }
          else
          {
            form_alert (1,"[3][abbruch mangels|speicherplatz| ][ bye ]");
            return (FALSE);
          }
        }
      }
    }
    else if (punkt == 2)	/*    datei schreiben	*/
    {
      if (out_filename())
      {
        cls();
        if (write_header())
          write_data();
      }
    }
    break;
  case 2:		/*  felder ausgeben	*/
    if (punkt >= 1  &&  punkt <= 3)
      put_single (punkt-1);
    else if (punkt == 4)
      put_all ();
    break;
  case 3:		/*  felder manipulieren	*/
    if (punkt >= 1  &&  punkt <= 3)	/* x, y oder z	*/
      switch (unterpunkt)
      {
      case 1:  array_add (punkt-1,wert);  break;
      case 2:  array_mul (punkt-1,wert);  break;
      case 0:  array_set (punkt-1)       ;break;
      }
    else if (punkt == 4)		/* x, y und z	*/
    {
      for (i = 1; i <= 3; i++)
      {
        punkt = i;
        verzweig();
      }
    }
    break;
  }
  return (TRUE);
}

main ()
{
  appl_init();
  
  cls();
  puts ("\n\n******  filetest  ******\n\n");
  
  xres=yres=5;
  xstart=ystart=-10.;
  xend=yend=10.;
  
  if (reserve_xyz (xres,yres))
  {
    while (menu() && verzweig());	/*  programmschleife	*/
    
    free_xyz();
  }
  appl_exit();
}

/*******************************************************************/
