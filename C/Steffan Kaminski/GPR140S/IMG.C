/*******************************************************/
/* Ein Verzeichnis nach IMG-Dateien durchsuchen und    */
/* anschliessend drucken                               */
/*******************************************************/
#ifdef __PUREC__
#include <ext.h>
#endif
#ifdef __GNUC__
#include <unistd.h>
#include <ostruct.h>
#endif
#include <portab.h>
#include <osbind.h>
#include <vdibind.h>
#include <aesbind.h>
#include <string.h>
#include <stdlib.h>
#include "gdos.h"

extern void locher_marke (int wkh, int y);

void print_pic (int wk_handle, char *pfad);

/***********************************************************/
/* Druckt alle Bilder eines Verzeichnisses                 */
/* voreingestellte Groesse 640 * 400                       */
/* Auf den Atari Laser passen so 3 * 8 Bilder auf eine     */
/* Seite                                                   */
/* int wkh    - Handle der zuvor geoeffneten Workstation   */
/* char *pfad - Laufwerksbuchstabe + Pfad                  */
/***********************************************************/
void print_pic(int wkh, char *pfad)
{
  char d_attrib, filename[256], akt_path[256];
  char *afname;
  int  aspect, x_scale, y_scale, h_align, v_align, xyarray[4];
  int  char_width, char_height, cell_width, cell_height;
  int  i, j, xmax, ymax, xpk, ypk, exit, page_clr;

#ifdef __PUREC__
  DTA  mdta;
  DTA  *dta, *old_dta;
#else
  _DTA mdta;
  _DTA *dta, *old_dta;
#endif

  dta = &mdta;                               /* Zeiger auf eigene DTA             */
  aspect = x_scale = y_scale = h_align = v_align = 0;
  i = j = exit = 0;
  getcwd(akt_path, 128);                     /* aktuellen Pfad merken             */

#ifdef __PUREC__
  setdisk(*pfad - 65);                       /* neuen Pfad setzen                 */
#else                                        /* GNU C                             */
  Dsetdrv(*akt_path - 65);
#endif
  chdir(&pfad[2]);

  vst_height(wkh, 7 * PF.res / 72, &char_width, &char_height, &cell_width, &cell_height);
  xpk = (work_out[0] - PF.xo) / 3;           /* X-Pixel eines Bildes              */
  ypk = (work_out[1] - cell_height) / 7;     /* Y-Pixel    -"-                    */
  xmax = 3;                                  /* maximale Zahl Bilder horizontal   */
  ymax = 7;                                  /*   -"-                vertikal     */
  page_clr = TRUE;                           /* noch ist die Seite leer           */

  old_dta = Fgetdta();
  Fsetdta(dta);

#ifdef __PUREC__
  afname = mdta.d_fname;                     /* nur eine DTA -> Adresse konstant  */
#else
  afname = mdta.dta_name;
#endif

  exit = Fsfirst("*.IMG", 16);               /* feststellen, ob es die Datei gibt */

  while(exit == 0)
  {

#ifdef __PUREC__
  d_attrib = mdta.d_attrib;
#else
  d_attrib = mdta.dta_attribute;
#endif

    if(*afname != '.' && !(d_attrib & 16))
    {
      xyarray[0] = PF.xo + xpk * i;          /* Position fuer das Bild berechnen  */
      xyarray[1] = ypk * j + cell_height;
      xyarray[2] = PF.xo + xpk * i + xpk;
      xyarray[3] = ypk * j + ypk + cell_height;
      page_clr = FALSE;                      /* jetzt ist was drauf auf der Seite */
      strcpy(filename, pfad);
      strcat(filename, afname);              /* Laufwerk + Pfad des Bildes        */
      v_bit_image(wkh, filename, aspect, x_scale, y_scale, h_align, v_align, (int *)&xyarray);
      v_gtext(wkh, xyarray[0], xyarray[1] + cell_height, afname);

      i++;                                   /* naechste Spalte                   */
      if(i >= xmax)
      {
        i = 0;
        j++;                                 /* naechste Zeile                    */
        if(j >= ymax)                        /* Seite voll ?                      */
        {
          j = 0;
          if(PF.locher)
            locher_marke(wkh, 1);
          v_gtext(wkh, PF.xo, cell_height, pfad);/* Pfad in den Kopf der Seite    */
          v_updwk(wkh);
          v_clrwk(wkh);
          page_clr = TRUE;                   /* nun ist die Seite leer            */
        }
      }
    }
    exit = Fsnext();
  }
  if(!page_clr)                              /* Seite nicht voll ?                */
  {
    if(PF.locher)                            /* noetige Dinge zeichenen           */
      locher_marke(wkh, 1);
    v_gtext(wkh, PF.xo, cell_height, pfad);
    v_updwk(wkh);                            /* und Seite drucken                 */
  }

  Fsetdta(old_dta);

#ifdef __PUREC__
  setdisk(*akt_path - 65);
#else
  Dsetdrv(*akt_path - 65);
#endif
  chdir(akt_path + 2);                       /* Pfad restaurieren                 */

} /* print_pic() */
