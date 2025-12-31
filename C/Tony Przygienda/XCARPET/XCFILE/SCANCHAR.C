/*********************************************************************
 *
 *  scanchar.c		gebiet : extra		projekt : bpm
 *--------------------------------------------------------------------
 *  zeichen/zeilen interpretieren
 *--------------------------------------------------------------------
 *  isblank (c)		leerzeichen bei c = ' ' oder TAB
 *  iscomment (c)	kommentar    "  c = '*' oder ';' oder '\0'
 *  kommentar (adr)	    "     suchen , sonst zeichen Åberspringen
 *  ein_wort (adr,wort)	von **adr bis zum ersten blank- oder
 *				kommentar-zeichen
 *--------------------------------------------------------------------
 *  char **adr		wird bei der suche erhîht
 *  char *wort,c
 *
 ********************************************************************/
 
 /*  17. 9.87  stock  */
 
#include "..\carpet.h" 
#if COMPILER==TURBOC
	#include "..\scanchar.h"
	#include <string.h>
#endif
 
 
static int iscomment (
#if COMPILER==TURBOC
								char c)
#else
								c)
  char c;
#endif
{
  return ((c == '*') || (c == ';') || (!c) || (c == '\n'));
}

static int isblank (
#if COMPILER==TURBOC
								char c)
#else
								c)
  char c;
#endif
{
  return ((c == ' ') || (c == 9));
}

int kommentar (adr)
  char ** adr;
{
  while (isblank (**adr)) (*adr)++;
  return (iscomment (**adr));
}

int ein_wort (adr,wort)
  char **adr,*wort;
{
  char c;
  int n=0;
  
  while (isblank (**adr)) (*adr)++;
  while ((! iscomment (c = (*adr)[n])) && (! isblank (c))) n++;

  strncpy (wort,*adr,n);
  wort [n] = '\0';
  *adr += n;
  
  return (n);
}

/*****************************************************************/


