/*******************************************/
/* Auswert.c                               */
/* Benutzereinstellungen aus den Dialogen  */
/* holen und in die Programmstruktur PF    */
/* eintragen                               */
/*******************************************/
#ifdef __GNUC__
#define __TCC_COMPAT__
#endif
#include <osbind.h>
#include <stdlib.h>
#include <vdibind.h>
#include <aesbind.h>
#include <portab.h>
#include "gprint.h"
#include "gdos.h"

extern int bestimme_datei(char *n);

void ausgabe_vorbereiten(void);

/******************************************/
void ausgabe_vorbereiten(void)
{
  extern OBJECT *dial_tree, *pop_tree, *font_tree, *opt_tree, *ppop_tree;
  int h;
  PF.height = 6;
  PF.lh = 21;

  for(h = ID21; h <= ID30; h++)
  {
    if(pop_tree[h].ob_state & (SELECTED|CHECKED))
      PF.lh = h - ID21 + 21;
  }
  /*  PF.lh = Getrez() + 2;*/ /* fuer Screen */

  if(font_tree[ZHBEL].ob_state & SELECTED)
  {
    PF.height = atoi(font_tree[ZHBELIEBIG].ob_spec.tedinfo->te_ptext);
    if(PF.height < 3)
    {
      PF.height = 3;
    }
  }
  else
  {
    if(font_tree[ZH6].ob_state & SELECTED)
      PF.height = 6;
    else if(font_tree[ZH8].ob_state & SELECTED)
      PF.height = 8;
    else if(font_tree[ZH10].ob_state & SELECTED)
      PF.height = 10;
  }

  if(opt_tree[MEMDYN].ob_state & SELECTED)
    PF.dyna_mem = TRUE;
  else
    PF.dyna_mem = FALSE;

  if(opt_tree[ABSATZMODE].ob_state & SELECTED)
    PF.absatz = TRUE;
  else
    PF.absatz = FALSE;

  if(opt_tree[SPARMODE].ob_state & SELECTED)
    PF.sparmod = TRUE;
  else
    PF.sparmod = FALSE;

  if(opt_tree[FROMPAGE].ob_state & SELECTED)
    PF.beginpage = atoi(opt_tree[FROMPAGENUM].ob_spec.tedinfo->te_ptext);
  else
    PF.beginpage = 1;

  if(opt_tree[COPYS].ob_state & SELECTED)
    PF.anz_copies = atoi(opt_tree[ANZCOPYS].ob_spec.tedinfo->te_ptext);
  else
    PF.anz_copies = 1;

  if(dial_tree[PAGENUM].ob_state & SELECTED)
    PF.pagenum = TRUE;
  else
    PF.pagenum = FALSE;

  if(dial_tree[DATUM].ob_state & SELECTED)
    PF.datum = TRUE;
  else
    PF.datum = FALSE;

  if(dial_tree[DATEINAME].ob_state & SELECTED)
    PF.headline = TRUE;
  else
    PF.headline = FALSE;

  if(dial_tree[UNTERSTRICH].ob_state & SELECTED)
    PF.strich = TRUE;
  else
    PF.strich = FALSE;

  if(ppop_tree[PPAGEALL].ob_state & (SELECTED|CHECKED))
    PF.print_all = TRUE;
  else
    PF.print_all = FALSE;

  if(ppop_tree[PPAGEGERADE].ob_state & (SELECTED|CHECKED))
    PF.print_even = TRUE;
  else
    PF.print_even = FALSE;

  if(ppop_tree[PPAGEUNGERADE].ob_state & (SELECTED|CHECKED))
    PF.print_odd = TRUE;
  else
    PF.print_odd = FALSE;

  if(dial_tree[UMLAUTE].ob_state & SELECTED)
    PF.umlaut_ers = TRUE;
  else
    PF.umlaut_ers= FALSE;

  if(dial_tree[TAB2SPACE].ob_state & SELECTED)
  {
    PF.tab2space = TRUE;
    PF.tabspace = atoi(dial_tree[TABSPACE].ob_spec.tedinfo->te_ptext);
    if(PF.tabspace == 0)
      PF.tabspace = 1;
  }
  else
     PF.tab2space = FALSE;

  if(dial_tree[HEFTRAND].ob_state & SELECTED)
  {
    PF.leftspace = atoi(dial_tree[LEFTSPACE].ob_spec.tedinfo->te_ptext);

    if(PF.leftspace == 0)
      PF.leftspace = 15;                         /* Default 15 mm Rand */

    PF.xo = (int)(PF.leftspace * PF.res / 25.4) - 118;  /* 118 -> Rand ATARI SLM 605 */
  }
  else
    PF.xo = 0;

  if(dial_tree[SEITENRAHMEN].ob_state & SELECTED)
  {
    PF.rahmen = TRUE;
    PF.xo += 10;              /* sonst beginnt der Text auf dem Rahmen */
  }
  else
    PF.rahmen = FALSE;
  if(dial_tree[LOCHERMARKE].ob_state & SELECTED)
    PF.locher = TRUE;
  else
    PF.locher = FALSE;

  if(dial_tree[PAGEBREAK].ob_state & SELECTED)
    PF.pagebreak = TRUE;
  else
    PF.pagebreak = FALSE;

  if(dial_tree[PAGEQUER].ob_state & SELECTED)
    PF.pagequer = TRUE;
  else
    PF.pagequer = FALSE;

  PF.ask = FALSE;

} /* ausgabe_vorbereiten() */

