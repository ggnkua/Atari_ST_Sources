/********************************************************************
 *
 *  asciidat.c		gebiet : xcfile		projekt : xcarpet
 *-------------------------------------------------------------------
 *  ein-/ausgaben mit ascii-dateien fÅr 3d-daten
 *-------------------------------------------------------------------
 *  fi_open (name)	datei zum lesen îffnen
 *  fi_head (head)	einlesen des headers
 *  fi_row (y,z,inc,array)	y-vektor einlesen
 *  fi_close ()		datei schlieûen
 *  fi_rewind()		datei zurÅckspulen
 *
 *  fo_... (..)		wie fi_... (..) , nur zum schreiben
 *
 ********************************************************************/
 
 /*   2. 6.88  stock  */

#include "..\carpet.h"
#include "filehead.h"	/*  typendefinitionen und makros	*/
#include <stdio.h>
#include <portab.h>
#if COMPILER==TURBOC
	#include "..\asciidat.h"
	#include <string.h>
#endif

/* from XFILES */
extern FILE *fopen_wr();
#if COMPILER==TURBOC
	#include "..\xfiles.h"
#endif

/* from SCANCHAR */
#if COMPILER==TURBOC
	#include "..\scanchar.h"
#endif


#define ELEMENT		3
#define LINECHARS	80
#define inc_check()	((inc > 0) && (inc <= ELEMENT))

static FILE *infile, *outfile;
static int  yin, zin, yout, zout;
static char string [LINECHARS+2], outname [80];

static int fget_line (
#if COMPILER==TURBOC
	void
#endif	
							)
{
  int ok;
  char *zeiger;

  do
  {
    ok = fgets (zeiger = string, LINECHARS, infile) != NULL;
#ifdef FILETEST
    fputs (string, stdout);
#endif
  }
  while (ok  &&  kommentar (&zeiger));
  
  return (ok); 
}

int fi_rewind ( )
{
  if (! infile)  return (FALSE);
  rewind (infile);
  return (TRUE);
}

void fi_close ( )
{
  if (infile) fclose (infile);
  
  infile = NULL;
}

int fi_open (name)
  char *name;
{
  fi_close ();
  
  return ((infile = fopen (name, "r")) != NULL);
}

int fi_head (head)
  fileheader *head;
{ 
  int i,line=0, ok=1;
  double d1, d2;
  
  while (ok && line++ < HEADERLINES  && fget_line())
  {
    switch (line)
    {
    case 1:
      ok = 1 == sscanf (string, "%d", &FORMAT);
      break;
    case 2:
      i = sscanf (string, "%d%d%d", &XRES, &YRES, &ZRES);
      ok = (i == 2) || (i == 3);
      if (i == 2) ZRES = 1;		/* z=1 : standard	*/
      break;
    default:
    	ok= (2 == sscanf (string, "%lf%lf", &d1, &d2));
#if SCANFERROR
		ok= TRUE;
#endif
      if (ok)
        if (line == 3)
        {
          XMIN = d1;  XMAX = d2;
        }
        else
        {
          YMIN = d1;  YMAX = d2;
        }
      break;
    }  	/*    switch (line)	*/
  }	/*    endwhile		*/
  
  if (ok)		/*  statische parameter Åbernehmen	*/
  {
    zin = ZRES;  yin = YRES;
  }
  return (ok);
}

int fi_row (y, z, inc, array)
  int y, z, inc;
  double *array;
{
  int i,n=0, ok=1;
  char *zeiger, wort [30];

  if (y > yin || y <= 0 || z > zin || z <= 0 || !inc_check()) 
    return (-1);			/* parameterfehler */
  
  array += inc - 1;
  
  while (ok  &&  n < y  &&  fget_line())
  {
    zeiger = string;
    for (i = 0; i < z; i++)
      ok = ein_wort (&zeiger, wort);
	 if (ok)
	 	{
		 ok = (1 == sscanf (wort, "%lf", array));
#if SCANFERROR
		 ok = TRUE;
#endif
	    if (ok)
	    	 {
		      n++;
		      array += inc;
		    }
		}
  }
  return (n);
}

void fo_close ( )
{
  if (outfile)  fclose (outfile);
  
  outfile = NULL;
}

int fo_open (name)
  char *name;
{
  fo_close();
  outfile = fopen_wr (name);
  strcpy (outname, name);

  return (outfile != NULL);
}

int fo_head (head)
  fileheader *head;
{
  static char extremform [] = "%15.6g%15.6g  *  %c-extremwerte \n";

  yout = YRES;  
  fprintf (outfile, "*  datei : %s \n*\n*  header :\n*\n", outname);
  fprintf (outfile, "%6d              *  format \n",FORMAT);
  fprintf (outfile, "%6d%6d%6d  *  x-y-z-auflîsung \n",XRES,YRES,ZRES);
  fprintf (outfile, extremform,XMIN, XMAX,'x');
  fprintf (outfile, extremform,YMIN, YMAX,'y');
  return (EOF != fputs (
    "*EOR\n*\n*  daten : z in einer zeile, y zeilen-, x blockorientiert \n*\n",
    outfile));
}

int fo_row (y, z, inc, array)
  int y, z, inc;
  double *array;
{
/* z never used ! */

  int n=-1, ok=1;

  if (y > yout || y <= 0 || !inc_check())  return (n);

  array += inc - 1;
  
  while (ok  &&  ++n < y)
  {
    ok = 0 < fprintf (outfile, "%12.6g\n", *array);
    array += inc;
  }
  fputs ("*EOR \n", outfile);

  return (n);
}

/*******************************************************************/
