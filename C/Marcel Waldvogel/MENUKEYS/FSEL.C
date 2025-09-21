/*
** FSEL.C - Vereinfachter Umgang mit dem Fileselector
**
** Beschreibungen jeweils am Anfang der Funktionen
*/

/* includes ********************************************************/

#include <stddef.h>
#include <aes.h>
#include <tos.h>
#include <string.h>
#include "fsel.h"

/* typedefs ********************************************************/

typedef enum{FALSE, TRUE} bool;


/* remainder *******************************************************/


void calc_fsel(FSEL *fsel)
/************************/
{
  /*
  ** Bestimmt aus Fileselector-Pfad und -Name den vollen Zugriffspfad
  ** der angew„hlten Datei.
  */
  char *name, *backslash, *concat;
  char cont;

  name = backslash = fsel->path;
  concat = fsel->both;

  /* Ganzen Pfad kopieren und sich jede Backslash-Position merken */
  do{
    if ((cont = *concat++ = *name++)=='\\')
      backslash = concat;
  }while (cont);
  /* backslash zeigt jetzt eins nach den letzten Backslash */

  /* Filenamen anhn„ngen */
  name = fsel->file;
  while ((*backslash++ = *name++) != '\0');
}


void init_fsel(FSEL *fsel, const char *fname, const char *ext)
/************************************************************/
{
  /*
  ** Initialisiert einen Fileselector mit dem aktuellen Pfad,
  ** der gewnschten Datei und der gewnschten Dateimaske.
  ** - Wenn fname == NULL ist, wird der Name des ersten passenden
  **   Files im aktuellen Directory genommen.
  **   Kann natrlich auch leergelassen werden (fname == "").
  ** - Bei ext sollte eine volle Dateimaske angegeben werden. Weiterhin
  **   muss am Anfang ein Backslash (escapen nicht vergessen!) stehen
  **   (also "\\*.*", "\\*.TXT" etc.)
  */
  fsel->path[0] = Dgetdrv()+'A';
  fsel->path[1] = ':';
  Dgetpath(&(fsel->path[2]), 0);
  strcat(fsel->path, ext);

  if (fname == NULL)	/* Selbst bestimmen */
  {
    DTA dta, *olddta;

    olddta = Fgetdta();
    Fsetdta(&dta);
    if (Fsfirst(fsel->path, 0x00) == 0)
      strcpy(fsel->file, dta.d_fname);
    else
      fsel->file[0] = '\0';
    Fsetdta(olddta);
  }
  else
    strcpy(fsel->file, fname);
  calc_fsel(fsel);
}


int do_fsel(FSEL *par, char *title)
/*********************************/
{
  /*
  ** Ruft den eigentlichen Fileselector auf.
  ** title == NULL oder title == "": fsel_input, sonst fsel_exinput.
  ** Liefert TRUE, falls der Benutzer etwas ausgew„hlt hat (file
  ** kann auch leer sein).
  */
  int button, ok;
  FSEL my_fsel;

  my_fsel = *par; /* Structure Assignment */

#if FSEL_WITHIN_MOUSECONTROL
  wind_update(BEG_MCTRL);
#endif

  /* fsel_exinput benutzen? */
  if (title != NULL && title[0] != '\0' && _GemParBlk.global[0] >= 0x140)
    ok = fsel_exinput(my_fsel.path, my_fsel.file, &button, title);
  else
    ok = fsel_input(my_fsel.path, my_fsel.file, &button);

#if FSEL_WITHIN_MOUSECONTROL
  wind_update(END_MCTRL);
#endif

  if (button && ok)
  {
    *par = my_fsel;
    calc_fsel(par);
    return TRUE;
  }
  return FALSE;
}


void force_ext(char *name, char *ext)
/***********************************/
{
  /*
  ** Žndert die Extension auf einen bestimmten Wert. Dabei
  ** k”nnen ebenfalls noch die letzten paar Buchstaben vor der
  ** Extension mitbestimmt werden. Falls nur die Extension
  ** abge„ndert werden soll, _MUSS_ der Punkt davor angegeben werden!
  **
  ** Beispiele:
  ** force_ext("HALLO.C", ".ASM")         -> "HALLO.ASM"
  ** force_ext("HALLO.C", "")             -> "HALLO"
  ** force_ext("HALLO_DU.C", "TXT")       -> "HALLOTXT"      (!!!)
  ** force_ext("HALLO.C", "RSC.TXT")      -> "HALLORSC.TXT"
  ** force_ext("FILENAME.C", "RSC.TXT")   -> "FILENRSC.TXT"
  ** force_ext("F:\HALLO\C.RSC", "RSC.S") -> "F:\HALLO\CRSC.S"
  */
  char *backslash;
  char *dot;
  long fnl; /* File Name Length */
  long nel; /* Non-Extension Filename Length */
            /* L„nge des nicht-Extension-Teiles von ext */

  dot = ext;
  while (*dot && *dot != '.')
    dot++;
  nel = dot-ext; /* L„nge */

  if (*name && name[1]==':') name += 2; /* Laufwerksdoppelpunkt? */
  backslash = name; /* Falls kein Backslash */

  /* Liefere in backslash den Zeiger auf den Dateinamen: */
  while (*name)
  {
    if (*name++ == '\\')
      backslash = name;
  }

  /* Finde '.' oder '\0': */
  dot = backslash;
  while (*dot && *dot != '.')
    dot++;
  fnl = dot-backslash;

  if (fnl+nel > 8) /* Zusammen l„nger als 8 Zeichen */
  {
    dot -= fnl+nel-8;
  }

  /* Kopiere neue Extension: */
  while ((*dot++ = *ext++) != 0);
}


