/*
    RSC2C - Resourcewandler fÅr INSTGUCK.PRG (Turbo C)

    AUFRUFE:
    - Als Applikation
    - Als Accessory
    - Als GEM-Programm mit Parameter
      (Dateiname vom ersten Parameter, Fehlermeldungen mit Alerts)

    BUGS:
    - Disk voll wird beim Schreiben nicht erkannt. Der Compiler
      merkt es danach aber garantiert (fehlendes "};").
    - Fehlerbehandlung allgemein sehr primitiv.
*/


/* includes ********************************************************/

#include <aes.h>
#include <tos.h>
#include <string.h>
#include <stdio.h>

#include "fsel.h"


/* defines *********************************************************/

#define BUFSIZE 32767 /* Immer weniger als 64 KB */

/* externals *******************************************************/

extern int _app;


/* typedefs ********************************************************/

typedef enum {FALSE, TRUE} bool;


/* globals *********************************************************/

FSEL si, so;
bool initialized = FALSE;

int buf[BUFSIZE];

/* prototypes ******************************************************/


/* remainder *******************************************************/


void arrow(void)
/**************/
{
  graf_mouse(ARROW, 0L);
}


void busy(void)
/*************/
{
  graf_mouse(HOURGLASS, 0L);
}


int show_err(const char *s1, const char *s2, const char *s3)
/**********************************************************/
{
  char s[150];

  strcpy(s, s1);
  strcat(s, s2);
  strcat(s, s3);
  arrow();
  return form_alert(1, s);
}


void err_read(const char *fn)
/***************************/
{
  show_err("[1][|Kann Datei|>>", fn, "<<|nicht lesen!|(Existiert sie nicht?)][Abbruch]");
}


void err_write(const char *fn)
/****************************/
{
  show_err("[1][|Kann Datei|>>", fn, "<<|nicht schreiben!|(Disk voll/schreibgeschÅtzt?)][Abbruch]");
}


int toascii(FILE *i, FILE *o)
/****************************/
{
  int rd;
  int idx;

  rd = (int) fread(buf, sizeof(int), BUFSIZE, i);
  fprintf(o, "/*\n"
             "  \035Resourcedatei\035\n"
             "*/\n"
             "\n"
             "unsigned int rsc_datei[] = {\n");

  for (idx=0; idx < (rd-16); idx += 16)
    vfprintf(o, "%uU,%uU,%uU,%uU,%uU,%uU,%uU,%uU,%uU,%uU,%uU,%uU,%uU,%uU,%uU,%uU,\n",
                &buf[idx]);
  for(; idx < (rd-1); idx++)
    fprintf(o, "%uU,", buf[idx]);
  fprintf(o, "%uU\n};\n\n", buf[idx]);
  return 0;
}


void convert(char *inname, char *outname)
/***************************************/
{
  FILE *fi, *fo;

  fi = fopen(inname, "rb");
  if (fi)
  {
    fo = fopen(outname, "w");
    if (fo)
    {
      busy();
      toascii(fi, fo);
      fclose(fo);
    }
    else
      err_write(so.both);
    fclose(fi);
  }
  else
    err_read(si.both);
  arrow();
}


void rsc2c(void)
/**************/
{
  wind_update(BEG_UPDATE);
  arrow();
  if (!initialized)
    init_fsel(&si, NULL, "\\*.RSC");
  if (do_fsel(&si, "SUCHE RESOURCE"))
  {
    /* Berechne Ausgabedatei */
    strcpy(so.path, si.path); force_ext(so.path, ".C");
    strcpy(so.file, si.file); force_ext(so.file, "RSC.C");
    calc_fsel(&so);
    if (do_fsel(&so, "AUSGABE NACH"))
      convert(si.both, so.both);
  }
  wind_update(END_UPDATE);
}


int main(int argc, char *argv[])
/******************************/
{
  int msg[8]; /* Dummy */

  _GemParBlk.global[2] = _GemParBlk.intout[0] = -1;
  /* FÅr appl_init(): Hat AES geantwortet (nicht aus AUTO-Ordner)? */

  if (appl_init()<0)
    return(-99);
  else /* appl_init geglÅckt */
  {
    if (argc == 2)
    {
      strcpy(si.both, argv[1]); force_ext(si.both, ".RSC");
      strcpy(so.both, si.both); force_ext(so.both, "RSC.C");
      convert(si.both, so.both);
    }
    else
    {
      if (_app) /* Applikation? */
        rsc2c();
      else /* Nein, Accessory! */
        while (TRUE)
        {
          evnt_mesag(msg);
          if (msg[0] == AC_OPEN)
            rsc2c();
        }
    }
    appl_exit();
  }
  return 0;
}

