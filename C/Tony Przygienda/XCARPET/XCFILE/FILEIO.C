/********************************************************************
 *
 *  fileio.c		gebiet : xcfile		projekt : xcarpet
 *-------------------------------------------------------------------
 *  ein-/ausgaben von xcarpet-variablen unter benutzung 
 *  des asciidat-moduls
 *-------------------------------------------------------------------
 *  inp_filename()	dateinamen holen, datei zum lesen îffnen
 *  read_header()	dateikopf einlesen, variable setzen
 *  read_data()		daten lesen, Åbertragung zum internen feld
 *  inp_seekdata()	datei auf den datenbereich positionieren
 *
 *  out_filename()	dasselbe rÅckwÑrts
 *  write_header()
 *  write_data()
 *
 *  static :
 *  signal (x)		hinweis : zu wenig datenblîcke Åbertragen
 *
 ********************************************************************/
 
 /*   3. 6.88  stock  */

#include "..\carpet.h"
#include <portab.h>
#include "filehead.h"
#if COMPILER==TURBOC
	#include <stdio.h>
	#include <aes.h>
	#include "..\fileio.h"
#endif

extern int xres,yres,xlines,ylines;
extern double xstart,xend,ystart,yend;
extern double *row_vector();
#if COMPILER==TURBOC
	#include "..\memory.h"
#endif


#if COMPILER==TURBOC
	#include "..\asciidat.h"
#endif

/* from XFILES */
extern int file_select (char *,char *);
#if COMPILER==TURBOC
	#include "..\xfiles.h"
#endif


static int zres;	/*  zres nicht global	*/
static int ok;
static char inputpath [80] = "\\*.*", outputpath [80] = "\\*.*";
static fileheader header;

#define head	(&header)
#define ELEMENT	3

int inp_filename()
{
  char name [80];
  
  ok = file_select (inputpath, name);  
  if (ok)
    ok = fi_open (name);

  return (ok);
}

int out_filename()
{
  char name [80];
  
  ok = file_select (outputpath, name);
  if (ok)
    ok = fo_open (name);
  return (ok);
}

int read_header()
{
  ok = fi_head (head);
  if (ok)
  {
    xres = XRES; xlines = xres - 1; xstart = XMIN; xend = XMAX;
    yres = YRES; ylines = yres - 1; ystart = YMIN; yend = YMAX;
    zres = ZRES;
  }
  return (ok && check_resolution (xres, yres));
}

int write_header()
{
  XRES = xres; XMIN = xstart; XMAX = xend;
  YRES = yres; YMIN = ystart; YMAX = yend;
  ZRES = 1;
  FORMAT = 3;
  
  return (fo_head (head));
}

int inp_seekdata()
{
  return (fi_rewind())?  read_header() : FALSE;
}

static void signal (
#if COMPILER==TURBOC
	int x)
#else
	x)
  int x;
#endif
{
  char string [80];
  
  sprintf (string, 
    "[1][ Nur %d von %d | Datenblîcken Åbertragen| ][ Weiter ]",x,xres);
  form_alert (1, string);
}

int read_data()
{
  int x=0, y, z=1, ok=1;
  
  if (zres >= 2)
  {
    z = form_alert (1, "[0][Z-Index auswÑhlen| |][ 1 | 2 | 3 ]");
    if (z > zres) z = zres;
  }
  
  do
    y = fi_row (yres, z, ELEMENT, row_vector(x));
  while (y == yres  &&  ++x < xres);
  
  /* fi_close(); */
  
  (ok = x == xres);
  if (!ok)
  {
    ok = check_resolution (xres, yres);
    if (ok)
      signal (x);
    xres = x;
  }
  return (ok);
}

int write_data()
{
  int x=0, y;
  
  do
    y = fo_row (yres, 1, ELEMENT, row_vector(x));
  while (y == yres  &&  ++x < xres);
  
  fo_close();

  (ok = x == xres);  
  if (!ok)
    signal (x);
  
  return (ok);
}

/*******************************************************************/
