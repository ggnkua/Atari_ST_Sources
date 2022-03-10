/********************************************
 * Ausgabe auf Drucker ueber VDI und GDOS
 * sk 07.93 - 09.94
********************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <portab.h>
#include <osbind.h>
#include <vdibind.h>
#include <aesbind.h>
#include "gdos.h"
#include "gprint.h"

PROGRAMFLAGS PF;
FONT *fontp, *afp;
char datei[200], null_string[4];
char fname[40], fpath[200], lpath[200], spath[200];
int  work_in[12], work_out[57], cb[256];
int  ldrive, sdrive, xo, pagen, einr;

/*********************************************************/
/* Diese Funktionen sind global verfuegbar               */
void print_vek_on_workstation (int wk_handle, char *pmem, long tlen);
void print_pix_on_workstation (int wk_handle, char *pmem, long tlen);
int open_wkst(int wk_handle);
void m_v_clswk(int handle);

/*********************************************************/
/* Diese Funktionen werden nur in diesem Modul verwendet */
void update        (int wkh, int *pa);
void put_raster    (int wkh);
int  get_ext       (int wkh, char *ps);
void make_headline (int wkh, int xoff, int c_h);
int  print         (int wkh, int xoff, int c_h, int texty, int pagey,
                    int page, int *ab, char *ps);
void new_page_norm (int wkh, int xoff, int c_h, long tlen,
                    int *page, int *ty, long *text);
int  new_page_quer (int wkh, int xoff, int c_h, long textende,
                    int *pagenumber, int *texty, int *spalte, int *printy, long *text);
char *korr_textzeiger(char *pmem, char *string, int *ab);
int  einruecken      (char *last, char *neu);
void underline       (int wkh, int y);
void rahmen          (int wkh);
void locher_marke    (int wkh, int page);

/*****************************************************************/
/* Mit einem Vektorfont auf die geoeffnete Workstation ausgeben  */
/*****************************************************************/
void print_vek_on_workstation(int wk_handle, char *pmem, long tlen)
{
  char *hpmem;
  char hs[1000], h2[1000], h3[1000], ls[1000];
  static int y, fak, sp_breite, absf, py, pymax, sw, i;
  static int char_width, char_height, cell_width, cell_height;
  static int advx, advy, remx, remy;

  pagen = 1;                                       /* Seitennummer           */
  y = 0;                                           /* Oben anfangen          */
  fak = 1;                                         /* Spaltenindikator (1/2) */
  einr = absf = FALSE;
  *ls = 0x0;

  vswr_mode(wk_handle, MD_REPLACE);
  vst_color(wk_handle, BLACK);
  vst_height(wk_handle, PF.height, &char_width, &char_height,
             &cell_width, &cell_height);

  for(i = 32; i < 256; i++)
  {
    vqt_advance(wk_handle, i, &advx, &advy, &remx, &remy);
    if(remx > 7500)
      advx++;
    cb[i] = advx;
  }
  if(PF.rahmen)                                    /* Rahmen um den Text     */
    rahmen(wk_handle);
  if(PF.locher)                                    /* Markierung fuer Lochen */
    locher_marke(wk_handle, pagen);

  if(PF.headline || PF.datum || PF.pagenum)        /* Kopfzeile ?            */
  {
    make_headline(wk_handle, PF.xo, cell_height);
    if(PF.strich)                                  /* Kopfzeile untersteichen*/
      underline(wk_handle, y + cell_height + cell_height / 2);
    if(!PF.pagequer)                               /* norm. Seite: Leerzeile */
      y += 2 * cell_height;
  }

  if(PF.pagequer)                        /* maximale Spaltenbreite ermitteln */
  {
    underline    (wk_handle, work_out[1] / 2 + 1);
    vst_rotation (wk_handle, 900);
    sp_breite = work_out[1] / 2 - 90;              /* maximale Textbreite    */
    py        = work_out[1];                  /* unten auf d. Seite anfangen */
    pymax     = work_out[0] - PF.xo - cell_height;
  }
  else
  {
    vst_rotation(wk_handle, 0);                    /* Seite normal bedrucken */
    if(PF.print_all)                             /* alle Seiten nacheinander */
      sp_breite = work_out[0] - PF.xo - 30;
    else                                 /* sonst: rechts Platz fuer Lochung */
      sp_breite = work_out[0] - 2 * PF.xo;
    pymax       = work_out[1] - 2 * cell_height;
  }

  do
  {
    sw  = i = 0;
    *hs = 0x0;                                     /* Strings loeschen       */
    *h2 = 0x0;
    *h3 = 0x0;

    if(einr)                        /* Einrueckung einer umgebrochenen Zeile */
      einr = einruecken(ls, hs);

    while(*(hs + i))
    {
      sw += cb[(int)*(hs + i)];
      i++;
    }
    hpmem = pmem;                             /* Kopie auf Anfang des Textes */
    if(!PF.absatz)                            /* Text einfach ausgeben       */
    {
                   /* bis zum Zeilenende oder bis Spaltenbreite erreicht ist */
      while(*pmem != 0xA && *pmem != 0xD && sw < sp_breite && pmem < (char *)tlen)
      {
        sw += cb[(int)*pmem];                 /* Textbreite berechnen     */
        pmem++;
      }

      strncat(hs, hpmem, pmem - hpmem);

      while(sw > sp_breite)                      /* Spaltenbreite erreicht ? */
      {
        while(*pmem != 0x20 && *pmem != 0x2D)    /* zurÅck bis SPACE oder '-'*/
        {
          pmem--;
          sw -= cb[(int)*pmem];
        }
        if(pmem < hpmem) break;                  /* zu weit zurueck?         */
        if(*pmem == 0x2D)                        /* zeigt auf '-' ?          */
                                           /* Bindestrich ans Ende der Zeile */
          hs[(int)((char *)pmem - (char *)hpmem) + 1] = 0x00;
        else                               /* Das SPACE mit Null ueberschr.  */
          hs[(int)((char *)pmem - (char *)hpmem)] = 0x00;

        strcpy(ls, hs);                          /* String kopieren          */
        einr = TRUE;                             /* naechste Zeile einruecken*/
        pmem--;
      }
      pmem += 2;                                 /* '\r\n' Åbergehen         */
      if(*pmem == 0x0A)
        pmem++;
    }
    else                               /* Absatzmodus: Text neu formatieren  */
    {
      static int sl, cc;
      cc = 0;                                    /* Char-Counter             */
      sl = (int)strlen(hpmem);                   /* Zeichenzahl des Absatzes */

      do
      {
        while(*pmem == 0x20 || *pmem == 0x2D)
        {
          sw += cb[(int)*pmem]; /* '-' und ' ' zu Beginn der Zeile uebergehen */
          pmem++;               /* und Breite mitzaehlen                     */
          cc++;
        }
                              /* vorwaerts bis Zeiger auf ' ' oder '-' zeigt */
        while(*pmem != 0x20 && *pmem != 0x2D && *pmem != 0x00 && sw < sp_breite)
        {
          sw += cb[(int)*pmem];                        /* Breite des Textes  */
          pmem++;
          cc++;                                        /* Anzahl der Zeichen */
        }

        strncpy(h2, hpmem, cc + 1) ;                   /* der Text           */
        h2[cc + 1] = 0x00;                             /* Stringende         */
        strcpy(h3, hs);                          /* Leerzeichenstring retten */
        strcat(hs, h2);                                /* Text anhaengen     */
        strcpy(hs, h3);                         /* Leerzeichenstring zurueck */

      } while((sw < sp_breite) && (*pmem != 0x00) && pmem < (char *)tlen);

      if(sw > sp_breite)   /* Text zu breit: letztes SPACE muss also OK sein */
      {
        pmem--;
        sw -= cb[(int)*pmem];
        while(*pmem != 0x20 && *pmem != 0x2D)
        {
          sw -= cb[(int)*pmem];                          /* zurueck im Text  */
          pmem--;
          cc--;
        }
        strncpy(h2, hpmem, cc);                          /* gueltiger Text   */
        h2[cc] = 0x00;                                   /* Stringende       */
        einr = TRUE;                                     /* Umbruch merken   */
      }
      strcat(hs, h2);
      strcpy(ls, hs);                                /* Kopie fÅr einruecken */

      pmem = korr_textzeiger(pmem, hs, &absf);
    }

    y = print(wk_handle, PF.xo, cell_height, y, py, pagen, &absf, hs);

    if(y >= pymax)                                  /* Seitenende erreicht ? */
    {
      if(!PF.pagequer)                              /* Seite normal drucken  */
      {
        new_page_norm(wk_handle, PF.xo, cell_height, tlen, &pagen, &y, (long *)&pmem);
      }
      else                         /* Seite gedreht mit zwei Spalten drucken */
      {
        fak = new_page_quer(wk_handle, PF.xo, cell_height, tlen,
                            &pagen, &y, &fak, &py, (long *)&pmem);
      }
    }
  } while(pmem < (char *)tlen);         /* das alles bis der Text zuende ist */

           /* falls der Text auf eine Seite passt:                   y<pymax */
           /* wenn nichts auf der Seite ist, wÅrde sonst ein FF folgen: y!=0 */
  if(y < pymax && y != 0 && PF.sparmod) /* Raster ueberlagern?               */
    put_raster(wk_handle);

} /* print_vek_on_workstation() */

/*****************************************************/
/* Pixelzeichensatz-Ausgabe                          */
/* Die Zeilenbreite laesst sich schneller berechnen. */
/* Ausserdem andere VDI-Aufrufe                      */
/*****************************************************/
void print_pix_on_workstation(int wk_handle, char *pmem, long tlen)
{
  char *hpmem;
  char hs[800], help[800], ls[800];
  static int y, fak, len, rlen, py, pymax, absf, sp_breite;
  int char_width, char_height, cell_width, cell_height;

  pagen = 1;
  y = 0;
  fak = 1;
  einr = FALSE;
  *ls = 0x0;

  vst_height(wk_handle, PF.height, &char_width, &char_height,
             &cell_width, &cell_height);

  if(PF.rahmen)
    rahmen(wk_handle);
  if(PF.locher)
    locher_marke(wk_handle, pagen);
  if(PF.headline || PF.datum || PF.pagenum)
  {
    make_headline(wk_handle, PF.xo, cell_height);
    if(PF.strich)
      underline(wk_handle, y + cell_height + cell_height / 2);
    if(!PF.pagequer)
      y += 2 * cell_height;
  }

  if(PF.pagequer)
  {
    underline    (wk_handle, work_out[1] / 2 + 1);
    vst_rotation (wk_handle, 900);
    sp_breite = work_out[1] / 2 - 20;
    py        = work_out[1] / fak;
    pymax     = work_out[0] - PF.xo - 2 * cell_height;
  }
  else
  {
    vst_rotation(wk_handle, 0);
    if(PF.print_all)
      sp_breite = work_out[0] - PF.xo;
    else
      sp_breite = work_out[0] - 2 * PF.xo;
    pymax       = work_out[1] - 2 * cell_height;
  }

  len = sp_breite / cell_width;

  do
  {
    *hs = 0x0;
    if(einr)                        /* Einrueckung einer umgebrochenen Zeile */
    {
      einr = einruecken(ls, hs);
    }
    hpmem = pmem;
    if(!PF.absatz)
    {
      while(*pmem != 0xA && *pmem != 0xD && pmem < (char *)tlen)
      {
        strncat(hs, pmem++, 1);
      }

      pmem++;
      if(*pmem == 0xA)
        pmem++;
    }
    else                                           /* Absatz neu formatieren */
    {
      static int cc;
      cc = 0;
      while(*pmem != 0x00 && cc < len && pmem < (char *)tlen)
      {
        pmem++;
        cc++;
      }
      if(*pmem != 0x00)
      {
        pmem--;
        while(*pmem != 0x20 && *pmem !=0x2D)
        {
          pmem--;
          cc--;
        }
        einr = TRUE;
      }
      strncat(hs, hpmem, cc);
      hs[cc] = 0x00;

      strcpy(ls, hs);

      pmem = korr_textzeiger(pmem, hs, &absf);
    }

    if(!PF.pagequer)
    {
      if((strlen(hs) * cell_width) > sp_breite)
      {
        do
        {
          strncpy(help, hs, len--);
        } while(len > 1  && *(help + len) != 32 && *(help + len) != 45);
        *(help + len + 1) = 0x0;

        rlen = (int)strlen(hs) - len;
        pmem = pmem - rlen - 1;
        strcpy(hs, help);
        strcpy(ls, help);
        einr = TRUE;
      }
    }
    else
    {
      if((strlen(hs) * cell_width) > sp_breite)            /* String zu lang */
      {
        len = sp_breite / cell_width;                /* max- Laenge bestimmen */

        do
        {
          strncpy(help, hs, len--);                    /* solange verkuerzen */
          *(help + len + 1) = 0x0;
        } while(len > 1  && *(help + len) != 32 && *(help + len) != 45);
                                    /* bis ein SPACE oder "-" gefunden wurde */

        rlen = (int)strlen(hs) - len; /* restl. Laenge der urspruenglichen Zeile  */
        pmem = pmem - rlen - 1 ; /* den glob. Textzeiger auf das SPACE setzen */

        strcpy(hs, help);       /* Hilfsstring in die zu druckende Var. kop. */
        strcpy(ls, help);                        /* 2. Kopie fuer einruecken */
        einr = TRUE;
      }
    }

    y = print(wk_handle, PF.xo, cell_height, y, py, pagen, &absf, hs);

    if(y >= pymax)
    {
      if(!PF.pagequer)                               /* Seite normal drucken */
      {
        new_page_norm(wk_handle, PF.xo, cell_height, tlen, &pagen, &y, (long *)&pmem);
      }
      else                         /* Seite gedreht mit zwei Spalten drucken */
      {
        fak = new_page_quer(wk_handle, PF.xo, cell_height, tlen,
                            &pagen, &y, &fak, &py, (long *)&pmem);
      }
    }
  } while(pmem < (char *)tlen);

  if(y < pymax && y != 0 && PF.sparmod)
    put_raster(wk_handle);

} /* print_pix_on_workstation() */

/********************************************************/
/* gewuenschte Workstation oeffnen                      */
/* korrekte Schriftgroesse und Aufloesung berechnen     */
/********************************************************/
int open_wkst(int wk_handle)
{
    int i;
    float f;

    ausgabe_vorbereiten();

    work_in[0] = wk_handle;
    for(i = 1; i < 10; work_in[i++] = 1);
    work_in[10] = 2;

    if(wk_handle > 20)
    {
      PF.dev_typ = TRUE;        /* Drucker */
      v_opnwk(work_in, &wk_handle, work_out);
      if(wk_handle)
        f = 25400 / work_out[3];
    }
    else  /* Dieser Teil ist nur zum debuggen, da keine Screen-ID mîglich ist */
    {
      PF.dev_typ = FALSE;
      v_opnvwk(work_in, &wk_handle, work_out);
      if(wk_handle)
        f = 25400 / 90;
    }

    if(wk_handle == 0)
      form_alert(1, "[3][ GDOS-Print: |  Workstation konnte  |    nicht geîffnet  |       werden! |Drucker eingeschaltet ?][Abbruch]");
    else
    {
      PF.res = (int)f;
      PF.xo = (int)(PF.leftspace * PF.res / 25.4) - 118;  /* 118 -> Rand ATARI SLM 605 */
      PF.height *= PF.res;
      PF.height /= 72;
    }

    return wk_handle;
} /* open_wkst() */

/********************************************************/
void m_v_clswk(int handle)
{
  if(PF.dev_typ == TRUE)
    v_clswk(handle);
  else
    v_clsvwk(handle);
} /* m_v_clswk() */

/****************************************************************************/
/* Anfang einer umgebrochenen Zeile  wie die vorangehende Zeile einruecken  */
/****************************************************************************/
int einruecken(char *last, char *neu)
{
  int cp = 0;

  if(last[0] == '-')                    /* Alle fuehrenden '-' uebergehen    */
  {
    strcat(neu, " ");
    cp++;
  }
  while(last[cp] == ' ')               /* fÅr jedes SPACE in der alten Zeile */
  {
    strcat(neu, " ");                  /* eins in die neue einfuegen         */
    cp++;
  };
  return FALSE;                        /* Das Einrueckflag zuruecksetzen     */
} /* einruecken() */

/*******************************************************/
/* Kopfzeile erzeugen (Dateiname, Datum, Seitennummer) */
/*******************************************************/
void make_headline(int wkh, int xoff, int c_h)
{
  char akt_datum[10], hl[250];

  *hl = 0x0;
  if(PF.headline)
    strcpy(hl, datei);
  strcat(hl, "            ");
  if(PF.datum)                                    /* Datum in die Kopfzeile? */
  {
    long t, ht, hm, hj;
    t = Gettime();
    hj = t & 0xFE000000L;
    hj = (hj>>25) + 80;
    hm = t &  0x1E00000L;
    hm = (hm>>21);
    ht = t &   0x1F0000L;
    ht = (ht>>16);

    *akt_datum = 0x0;
    sprintf(akt_datum, "%ld.%ld.%ld", ht, hm, hj);
    strcat(hl, akt_datum);
  }
  if(PF.print_all)
    strcat(hl, "            ");

  if(PF.pagenum && PF.print_all)                           /* Seitennummer?  */
  {
    sprintf(akt_datum, "%d", pagen);
    strcat(hl, akt_datum);
  }
  else if(PF.pagenum && !PF.print_all)  /* gerade/ungerade: Sonderbehandlung */
    sprintf(akt_datum, "%d", pagen);

  if(PF.pagequer)                 /* bei Querdruck: Textwinkel zuruecksetzen */
    vst_rotation(wkh, 0);

  if(pagen >= PF.beginpage)           /* Soll diese Seite gedruckt werden?   */
  {
    if(PF.print_all ||                /* Alle Seiten drucken                 */
      ((pagen & 1) && PF.print_odd) ||/* ungerade Seite UND ungerade drucken */
      (!(pagen & 1) && PF.print_even))/* gerade Seite UND gerade drucken     */
                          /* alle anderen Seiten MUESSEN leer bleiben: sonst */
                          /* wird ein leeres Blatt mit Kopfzeile ausgegeben  */
    {
      if(afp->font_prop)              /* Proportionaler Zeichensatz (Speedo) */
      {
        if(PF.print_all)              /* ALLE SEITEN: normale Kopfzeile      */
          v_ftext(wkh, xoff, c_h, hl);

        if(PF.pagenum && PF.print_odd) /* SEITENNUMMER und UNGERADE SEITEN   */
        {
          v_ftext(wkh, xoff, c_h, hl);      /* Dateiname und Datum links     */
                                            /* Seitennummer rechts drucken   */
          v_ftext(wkh, work_out[0] - get_ext(wkh, akt_datum) - xoff, c_h, akt_datum);
        }
        if(PF.pagenum && PF.print_even) /* SEITENNUMMER und GERADE SEITEN    */
        {                               /* Dateiname und Datum rechts        */
          v_ftext(wkh, work_out[0] - get_ext(wkh, hl) - xoff, c_h, hl);
          v_ftext(wkh, xoff, c_h, akt_datum);  /* Seitennummer links drucken */
        }
      }
      else                            /* normaler GDOS-Zeichensatz           */
      {
        if(PF.print_all)                       /* analog zu Proportionalfont */
          v_gtext(wkh, xoff, c_h, hl);

        if(PF.pagenum && PF.print_odd)
        {
          v_gtext(wkh, xoff, c_h, hl);
          v_gtext(wkh, work_out[0] - get_ext(wkh, akt_datum) - xoff, c_h, akt_datum);
        }
        if(PF.pagenum && PF.print_even)
        {
          v_gtext(wkh, work_out[0] - get_ext(wkh, hl) - xoff, c_h, hl);
          v_gtext(wkh, xoff, c_h, akt_datum);
        }
      }
    }
  }

  if(PF.pagequer)                     /* Textwinkel bei Bedarf zuruecksetzen */
    vst_rotation(wkh, 900);
} /* make_headline() */

/**********************************************/
/* Die Breite eines Textes in Pixel ermitteln */
/**********************************************/
int get_ext(int wkh, char *ps)
{
  int i, sw;
  sw = i = 0;

  while(*(ps + i))
  {
    sw += cb[*ps + i];              /* Breite der einzelnen Zeichen addieren */
  }
  return sw;
} /* get_ext() */

/******************************************/
/* Die Seite zum Drucker schicken,        */
/* Seitenzaehler erhoehen                 */
/* bei Bedarf die Seite wegwerfen         */
/* (gerade/ungerade)                      */
/******************************************/
void update(int wkh, int *seitennummer)
{

  if(*seitennummer >= PF.beginpage &&
    (  PF.print_all                       ||     /* entweder: alles          */
     ((*seitennummer & 1) && PF.print_odd)||     /* ungerade Seite           */
     (!(*seitennummer & 1) && PF.print_even) ) ) /* gerade Seite             */
  {
    int i;
    PF.ask = TRUE;  /* Flag um zu Verhindern, dass z.B. beim Verwerfen einer */
                    /* geraden Seite beim Drucken der ungeraden Seiten       */
                    /* gefragt wird, ob weitergedruckt werden soll           */
    if(PF.sparmod)
    {
      put_raster(wkh);
    }

    for(i = 1; i <= PF.anz_copies; i++)           /* mehrere Kopien?         */
      v_updwk(wkh);
    v_clrwk(wkh);
  }

  (*seitennummer)++;
} /* update() */

/******************************************************************************/
/* Toner-Sparmodus (aehnlich HP 4L)                                           */
/* Durch Verknuepfung mit einem Raster werden nicht mehr alle Punkte gedruckt */
/******************************************************************************/
void put_raster(int wkh)
{
  int pxyarray[4];

  pxyarray[0] = 0;                                           /* Rechteck mit */
  pxyarray[1] = 0;                                           /* Seitengroesse*/
  pxyarray[2] = work_out[0];
  pxyarray[3] = work_out[1];
  vswr_mode    (wkh, MD_ERASE);                              /* Zeichenmodus */
  vsf_color    (wkh, WHITE);
  vsf_interior (wkh, IP_2PATT);                              /* gemustert    */
  vsf_perimeter(wkh, IP_HOLLOW);                             /* kein Rahmen  */
  vsf_style    (wkh, IP_5PATT);                              /* Fuellstil    */
  v_bar        (wkh, pxyarray);
  vswr_mode    (wkh, MD_REPLACE);

} /* put_raster() */

/***********************************************/
/* Kopfzeile unterstreichen oder bei Querdruck */
/* die Seite in der Mitte unterteilen          */
/***********************************************/
void underline(int wkh, int y)
{
  int pxyarray[4];

  if(PF.print_all || ((pagen & 1) && PF.print_odd) )
  {
    pxyarray[0] = PF.xo - 10;              /* wegen Zwischenraum Rahmen/Text */
    pxyarray[2] = work_out[0];             /* bis zum rechten Rand           */
  }
  else if(!(pagen & 1) && PF.print_even)
  {
    pxyarray[0] = 0;                       /* gerade Seiten links anfangen   */
    pxyarray[2] = work_out[0] - PF.xo;     /* rechts Rand zum Lochen         */
  }
  pxyarray[1] = y;
  pxyarray[3] = y;
  vswr_mode    (wkh, MD_REPLACE);
  vsl_color    (wkh, BLACK);
  vsf_interior (wkh, IP_1PATT);
  vsf_perimeter(wkh, IP_HOLLOW);
  vsf_style    (wkh, IP_5PATT);
  if(pagen >= PF.beginpage && ( PF.print_all ||
    ((pagen & 1) && PF.print_odd) || (!(pagen & 1) && PF.print_even) ) )
  {
    v_pline    (wkh, 2, pxyarray);
  }
  vswr_mode    (wkh, MD_REPLACE);

} /* underline() */

/*******************************************/
/* Text mit einem Rahmen umgeben           */
/*******************************************/
void rahmen(int wkh)
{
  int pxyarray[4];

  if(PF.print_all || ((pagen & 1) && PF.print_odd) )
  {
    pxyarray[0] = PF.xo - 10;
    pxyarray[2] = work_out[0];
  }
  else if(!(pagen & 1) && PF.print_even)
  {
    pxyarray[0] = 0;
    pxyarray[2] = work_out[0] - PF.xo;
  }
  pxyarray[1] = 0;
  pxyarray[3] = work_out[1];
  vswr_mode    (wkh, MD_REPLACE);
  vsl_color    (wkh, BLACK);
  vsf_color    (wkh, BLACK);
  vsf_interior (wkh, IP_HOLLOW);
  vsf_style    (wkh, IP_HOLLOW);
  if(pagen >= PF.beginpage && ( PF.print_all ||
    ((pagen & 1) && PF.print_odd) || (!(pagen & 1) && PF.print_even) ) )
  {
    v_bar      (wkh, pxyarray);
  }
  vswr_mode    (wkh, MD_REPLACE);

} /* rahmen() */

/**********************************************/
/* Mitte der Seite fuer den Locher markieren  */
/**********************************************/
void locher_marke(int wkh, int page)
{
  int pxyarray[4];

  if(page & 1)                  /* nur auf ungeraden Seiten */
  {
    pxyarray[0] = 0;
    pxyarray[1] = work_out[1] / 2;
    pxyarray[2] = 10;
    pxyarray[3] = work_out[1] / 2;
    vswr_mode    (wkh, MD_REPLACE);
    vsf_color    (wkh, BLACK);
    vsf_interior (wkh, IP_1PATT);
    vsf_perimeter(wkh, IP_HOLLOW);
    vsf_style    (wkh, IP_5PATT);
    v_pline      (wkh, 2, pxyarray);
    vswr_mode    (wkh, MD_REPLACE);
  }
} /* locher_marke() */

/***********************************************/
/* Den Text einer Zeile ueber das VDI ausgeben */
/***********************************************/
int print(int wkh, int xoff, int c_h, int texty, int pagey, int page, int *ab, char *ps)
{
  if(page >= PF.beginpage &&
    ( PF.print_all ||                     /* Das uebliche zur Unterdrueckung */
    ((page & 1) && PF.print_odd) ||       /* leerer Seiten                   */
    (!(page & 1) && PF.print_even) ) )
  {
    if(afp->font_prop)                              /* Speedo-Zeichensaetze  */
    {
      if(PF.pagequer)                               /* Seite quer?           */
        v_ftext(wkh, xoff + texty + c_h, pagey, ps);
      else
        v_ftext(wkh, xoff, texty + c_h, ps);
    }
    else                                            /* Pixel-Zeichensaetze   */
    {
      if(PF.pagequer)
        v_gtext(wkh, xoff + texty + c_h, pagey, ps);
      else
        v_gtext(wkh, xoff, texty + c_h, ps);
    }
  }

  texty += c_h;                                     /* neue Zeichenposition  */

  if(PF.absatz && *ab)                              /* Absatzmodus?          */
  {
    texty += c_h;                                   /* Leerzeile nicht verg. */
    *ab = FALSE;
  }
  return(texty);                        /* neue Y-Pos. auf der Seite zurueck */
} /* print() */

/*******************************************/
/* Zeilenumbrueche und Leerzeichen am Ende */
/* einer Zeile uebergehen                   */
/*******************************************/
char *korr_textzeiger(char *pmem, char *string, int *ab)
{
  if(*pmem == 0x00)                                 /* wirklich Stringende?  */
  {
    pmem++;                                         /* uebergehen            */
    if(*pmem == 0x0A)                               /* newline?              */
    {
      pmem++;                                       /* uebergehen            */
      *ab = TRUE;                                   /* Absatzflag setzen     */
    }
  }
  else if(*pmem == 0x20)                /* Leerzeichen nur am Ende der Zeile */
    pmem++;

  if(string[strlen(string) - 1] == 0x2D && *pmem == 0x2D)/* '-' am Zeilenanfang weg */
    pmem++;                             /* weil das ein Trennstrich war      */

  return(pmem);                         /* neue Position im Text             */
} /* korr_textzeiger() */

/******************************************/
/* Seitenende                             */
/* Seite ausgeben                         */
/* evtl. auf Benutzereingabe warten       */
/******************************************/
void new_page_norm(int wkh, int xoff, int c_h, long textende,
                   int *pagenumber, int *texty, long *text)
{
  int fb;
  update(wkh, pagenumber);                 /* Seite ausgeben                 */
  *texty = 0;

  if(PF.pagebreak && PF.ask)               /* Seitenweise und warten noetig? */
  {
    fb = form_alert(2, "[2][ GDOS-Print: |  Wollen Sie weiterdrucken?  ][Nein| Ja ]");
    if(fb == 1)                            /* Abbruch                        */
     *text = textende + 1;                 /* Textzeiger hinter den Text     */
    if(!PF.print_all)                      /* Flag zuruecksetzen             */
      PF.ask = FALSE;
  }

  if(*text < textende)                     /* Text zu Ende?                  */
  {
    if(PF.rahmen)                          /* neue Seite vorbereiten         */
      rahmen(wkh);
    if(PF.locher)
      locher_marke(wkh, *pagenumber);
    if(PF.headline || PF.datum || PF.pagenum)
    {
      make_headline(wkh, xoff, c_h);
      if(PF.strich)
        underline(wkh, *texty + c_h + c_h / 2);

      *texty += 2 * c_h;
    }
  }
} /* new_page_norm() */

/******************************************/
/* Seitenende beim Querdruck              */
/******************************************/
int new_page_quer(int wkh, int xoff, int c_h, long textende,
                  int *pagenumber, int *texty, int *spalte, int *printy, long *text)
{
  int fb;
  *texty = 0;

  if(*spalte == 2)                             /* zweite Spalte schon voll?  */
  {
    update(wkh, pagenumber);                   /* dann ausgeben              */
    *printy = work_out[1];  /* Zeichenposition an unteren Rand zuruecksetzen */

    if(PF.pagebreak && PF.ask)              /* auf Benutzerentscheid warten? */
    {
      fb = form_alert(2, "[2][ GDOS-Print: |  Wollen Sie weiterdrucken?  ][Nein| Ja ]");
      if(fb == 1)
        *text = textende + 1;                  /* s. new_page_norm()         */
      if(!PF.print_all)
        PF.ask = FALSE;
    }

    if(*text < textende)
    {
      if(PF.rahmen)                         /* Rahmen, Locher-Marke und      */
        rahmen(wkh);                        /* Mittelstrich sind unabhaengig */
      if(PF.locher)                         /* von der Kopfzeile             */
        locher_marke(wkh, *pagenumber);
      underline(wkh, work_out[1] / 2 + 1);
      if(PF.headline || PF.datum || PF.pagenum)
      {
        make_headline(wkh, xoff, c_h);
        if(PF.strich)                       /* abhaengig von Kopfzeile       */
          underline(wkh, *texty + c_h + c_h / 2);
      }
      return(1);                            /* Spaltennummer 1 zureuckgeben  */
    }
  }
  else if(*spalte == 1)                     /* wenn erst in Spalte eins      */
  {
    *printy = work_out[1] / 2;              /* Text jetzt ab Mitte der Seite */
    return(2);                              /* Spaltennummer gleich zwei     */
  }
  return(1);                            /* bis hier sollte man nicht kommen! */
} /* new_page_quer() */
