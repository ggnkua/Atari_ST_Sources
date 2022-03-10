/**********************************************/
/* GEM-Rahmen-Programm                        */
/* Eigene Dialoge in das EXAMPLE.C der        */
/* Enhanced-GEM-Lib von Christian Grunenberg  */
/* eingehaengt (v1.40)                        */
/* aktuelle Versionen der Libary @ S2, @ FL   */
/**********************************************/
#ifdef __PUREC__
#define ZAHL_NACH_ASCII itoa
#include <ext.h>
#endif
#ifdef __GNUC__
#define __TCC_COMPAT__
#define ZAHL_NACH_ASCII _itoa
#include <support.h>
#include <unistd.h>
#include <ostruct.h>
#include <mintbind.h>
#endif
#include <osbind.h>
#include <vdibind.h>
#include <aesbind.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <e_gem.h>
#include "gdos.h"
#include "gprint.h"

#define DND                /* Drag & Drop */
/*#define CMD_DEBUG */     /* Comandline  */
/*#define FONT_DEBUG*/     /* Font-ID's usw */

#define AP_DRAGDROP  63
#define ERROR        -1
#define ERANGE      -64
#define EACCDN      -36

/*************** Prototypen ******************/
extern int  bestimme_datei      (char *n, char *dn, char *dp);
extern int  bestimme_datei_v    (char *name, char *pfad);
extern long text_laden          (const char *text_name, unsigned long *laenge);
extern void ausgabe_vorbereiten (void);
extern void get_font_height     (void);
extern void dd_recieve          (int msg[]);
extern int  get_fonts           (int wk_handle);
extern void print_pic           (int wk_handle, char *pfad);
extern int  open_wkst           (int wk_handle);
extern int  save_opt            (void);
extern int  load_opt            (void);

/* extern int  save_fontliste      (FONT *fonts, int anzahl);*/
/* extern long load_datei          (const char *name, unsigned long *laenge);*/
/* extern int  set_font            (int wk_handle, int font_id);*/

#ifdef SBEDARF
extern void ausgabe_quer_sim    (int lh, int height, int xo);
extern void ausgabe_norm_sim    (int lh, int height, int xo);
#endif

extern int ap_id, oldhandle, akt_font, anz_font;

void CycleCloseWindow(int mode);
void OpenDialog(DIAINFO *info, OBJECT *tree, int obj,
                DIAINFO *parent, int dial_mode, char *name);
void CloseDialog(DIAINFO *info);
int  InitMsg(EVENT *evt);
void Messag(EVENT *event);
void ExitExample(int all);
void set_font_state(DIAINFO *exinf);
void drucken(char *text, long size);

/*****************************************************/
EVENT event;
static int double_click, exobj;

/* Zeiger auf Objektb„ume sowie DIAINFO-Strukturen fr Dialoge */
OBJECT *dial_tree, *help_tree, *font_tree, *opt_tree, *pop_tree, *ppop_tree, *dev_tree;
DIAINFO dial_info, help_info, font_info, opt_info, pop_info, ppop_info, dev_info, *ex_info;

POPUP pop = { &dial_info, 0, 0, POPBTN, 0, TRUE, TRUE };
POPUP ppop = { &opt_info, 0, 0, PPAGEPOP, 0, TRUE, TRUE };

/* Liste von Zeigern auf DIAINFO-Strukturen der ge”ffneten Dialoge */
DIAINFO *wins[6];
int win_cnt;                      /* Anzahl der ge”ffneten Dialoge */

/***********************************************************************
 Alle Dialoge schliežen sowie optional Beenden der Applikation
 (Menleiste l”schen, Resource freigeben, Abmeldung bei AES und VDI)
***********************************************************************/
void ExitExample(int all)
{
  while (--win_cnt >= 0)    /* alle ge”ffneten Dialoge schliežen */
    close_dialog(wins[win_cnt],FALSE);
  if(fontp != NULL)
    free((void *)fontp);
  fontp = NULL;
  afp   = NULL;
  akt_font = 0;
  oldhandle = 0;

  if(all)
  {
    close_rsc();    /* Resource freigeben, Abmelden */
    exit(0);        /* Programm beenden */
  }

  win_cnt=0;
}

/***********************************************************************
 Resource und Objektb„ume initialsieren
***********************************************************************/
void init_resource(void)
{
    /* Adressen der Objektb„ume (Dialoge,Mens,Popups) ermitteln */
    rsrc_gaddr(R_TREE, GDOSUTIL,      &dial_tree);
    rsrc_gaddr(R_TREE, HILFE,         &help_tree);
    rsrc_gaddr(R_TREE, FONTEINST,     &font_tree);
    rsrc_gaddr(R_TREE, OPTIONENEINST, &opt_tree);
    rsrc_gaddr(R_TREE, IDPOP,         &pop_tree);
    rsrc_gaddr(R_TREE, PAGEPOP,       &ppop_tree);
    rsrc_gaddr(R_TREE, DEVICEINFO,    &dev_tree);
	pop.p_menu  = pop_tree;
	ppop.p_menu = ppop_tree;

    /* erweiterte Objekte sowie Images/Icons anpassen */
    fix_objects(dial_tree, NO_SCALING);
    fix_objects(help_tree, NO_SCALING);
    fix_objects(font_tree, NO_SCALING);
    fix_objects(opt_tree,  NO_SCALING);
    fix_objects(pop_tree,  NO_SCALING);
    fix_objects(ppop_tree, NO_SCALING);
    fix_objects(dev_tree,  NO_SCALING);
}

/***********************************************************************
 Fensterdialog rotieren (mode==0) oder schliežen (mode!=0)
***********************************************************************/
void CycleCloseWindow(int mode)
{
  /* Dialog ge”ffnet ? */
  if (win_cnt > 0)
  {
    register int i, handle = FAIL;
    int top, dummy;

    /* Handle des obersten Fensters ermitteln */
    wind_get(0, WF_TOP, &top, &dummy, &dummy, &dummy);

    /* DIAINFO-Struktur des obersten Fensterdialoges suchen */
    for(i = 0; i < win_cnt; i++)
    {
      if(wins[i]->di_flag >= WINDOW && wins[i]->di_handle == top)
      {
        /* Dialog schliežen ? */
        if(mode)
        {
          /* Falls Hauptdialog geschlossen wird, auch alle
             anderen Dialoge schliežen */
          if(wins[i] == &dial_info)
            ExitExample(0);
           /* ansonsten nur obersten Dialog schliežen */
          else
            CloseDialog(wins[i]);
        }
        /* Dialog rotieren ? */
        else if (i < (win_cnt-1))
          handle = wins[i+1]->di_handle;
        else
          handle = wins[0]->di_handle;
        break;
      }
     /* Dialog nach Rotation in Vordergrund bringen */
     if(handle > 0)
       wind_set(handle, WF_TOP);
    }
  }
}

/***********************************************************************
 Dialog ”ffnen und in Liste der ge”ffneten Dialoge eintragen bzw. falls
 der Dialog schon ge”ffnet ist, diesen in den Vordergrund bringen. Aužerdem
 Verwaltung der ge”ffneten Dialoge und Auswertung der Benutzeraktionen
***********************************************************************/
void OpenDialog(DIAINFO *info, OBJECT *tree, int obj,
                DIAINFO *parent, int dial_mode, char *name)
{
  exobj = win_cnt;
  if(parent && obj > FAIL)
  {
    ob_undostate(parent->di_tree, obj, SELECTED);
    ob_draw_chg(parent, obj, NULL, FAIL, FALSE);
  }

  switch(info->di_flag)
  {
    case WINDOW:                             /* Fensterdialog bereits ge”ffnet ? */
    case WIN_MODAL:
         wind_set(info->di_handle, WF_TOP);  /* Dialog in den Vordergrund holen */
         break;
    case CLOSED:    /* Dialog geschlossen ? */
                    /* Dialog ”ffnen und bei Erfolg in Liste eintragen */
        if(open_dialog(tree, info, name, TRUE, FALSE, dial_mode))
          wins[win_cnt++] = info;
  }

                /* Waren bereits vorher Dialoge ge”ffnet ? */
  if(exobj > 0)
                /* Ja, also wird die Verwaltung bereits an anderer Stelle bernommen */
    return;

  while(win_cnt > 0)
  {
    /* exit -> angew„hltes Objekt (Bit 15 = Doppelklick)
       ex_info -> Zeiger auf DIAINFO-Struktur des angew„hlten Dialogs
    */
    exobj = X_Form_Do(&ex_info, 0, InitMsg, Messag);

    if(exobj == W_CLOSED)            /* Dialog schliežen */
    {
      if(ex_info == &dial_info && _app)
        ExitExample(1);
      else if(ex_info == &dial_info && !_app)
        ExitExample(0);
      else
        CloseDialog(ex_info);
    } /* Dialog wurde geschlossen, aber kein Objekt angew„hlt
         (z.B. durch AC_CLOSE) */
    else if(exobj == W_ABANDON)
      ExitExample(0);
    else
    { /* Doppelklick erfassen und aus Wert fr Exit-Objekt ausmaskieren */
      exobj ^= (double_click = exobj & 0x8000);

      if(ob_isstate(ex_info->di_tree, exobj, SELECTED))
      {
        /* angew„hltes Objekt deselektieren und neu zeichnen */
        ob_undostate(ex_info->di_tree, exobj, SELECTED);
        ob_draw_chg(ex_info, exobj, NULL, FAIL, FALSE);
      }
      if(ex_info == &dial_info)      /* Haupt-Dialog */
      {
        char devstr[128];
        int ret, wk_handle, fn, devexits;
        int g_slice, g_page, a_slice, a_page, div_fac;
        long mem;
        unsigned long laenge;
        switch(exobj)
        {
                /* Hilfe-Button -> Hilfe-Dialog ”ffnen */
          case POPBTN:
               Popup(&pop, (double_click) ? POPUP_CYCLE_CHK : POPUP_BTN_CHK,
                     OBJPOS, 0, 0, NULL, FAIL);
               break;
          case AKTUELLERPFAD:
               break;
          case EINSTELLUNGEN:
/*             opt_tree[AUTOCHK].ob_state  = PF.dev_chk; */
               opt_tree[SAVEPFAD].ob_state   = PF.s_pfad;
               opt_tree[ABSATZMODE].ob_state = PF.abs_mode;
               opt_tree[MEMDYN].ob_state     = PF.memory;
/*             opt_tree[STATFONT].ob_state   = PF.stat_fontl; */
               opt_tree[COPYS].ob_state      = PF.copies;
               opt_tree[SPARMODE].ob_state   = PF.sparmod;

               if(PF.beginpage == 1)
                 opt_tree[FROMPAGE].ob_state = NORMAL;
               OpenDialog(&opt_info, opt_tree, exobj, ex_info, AUTO_DIAL|MODAL, " GDOS-Print ");
               break;
          case HELP:
               OpenDialog(&help_info, help_tree, exobj, ex_info,
                          AUTO_DIAL, " Hilfe ");
               break;
          case NAMEDATEI:
               *fname = 0x0;
               if(bestimme_datei(datei, fname, fpath))
               {
                 dial_tree[NAMEDATEI].ob_spec.tedinfo->te_ptext = fname;
                 dial_tree[AKTUELLERPFAD].ob_spec.tedinfo->te_ptext = fpath;
                 ob_draw_chg(ex_info, NAMEDATEI, NULL, FAIL, FALSE);
                 ob_draw_chg(ex_info, AKTUELLERPFAD, NULL, FAIL, FALSE);
               }
               break;
          case FONTSELECT:
               ausgabe_vorbereiten();
               if(get_fonts(PF.lh))
               {
                 ZAHL_NACH_ASCII(anz_font - 1, font_tree[FONTSINSGESAMT].ob_spec.tedinfo->te_ptext, 10);
                 set_font_state(ex_info);
                 OpenDialog(&font_info, font_tree, exobj, ex_info, AUTO_DIAL|MODAL, " GDOS-Print ");
               }
               break;
          case DEVINFO:
               ausgabe_vorbereiten();
               if((wk_handle = open_wkst(PF.lh)) != 0)
               {
                 ZAHL_NACH_ASCII(PF.lh, dev_tree[DEVID].ob_spec.tedinfo->te_ptext, 10);
                 ZAHL_NACH_ASCII(PF.res, dev_tree[DEVDPI].ob_spec.tedinfo->te_ptext, 10);
                 ZAHL_NACH_ASCII(work_out[0] + 1, dev_tree[DEVX].ob_spec.tedinfo->te_ptext, 10);
                 ZAHL_NACH_ASCII(work_out[1] + 1, dev_tree[DEVY].ob_spec.tedinfo->te_ptext, 10);
                 vqt_devinfo(wk_handle, PF.lh, &devexits, devstr);
                 if(devexits)
                   dev_tree[DEVNAME].ob_spec.tedinfo->te_ptext = devstr;
                 vq_scan(wk_handle, &g_slice, &g_page, &a_slice, &a_page, &div_fac);
                 ZAHL_NACH_ASCII(g_slice, dev_tree[DEVSLICES].ob_spec.tedinfo->te_ptext, 10);
                 ZAHL_NACH_ASCII(g_page,  dev_tree[DEVSLICESH].ob_spec.tedinfo->te_ptext, 10);
                 ZAHL_NACH_ASCII(a_slice, dev_tree[DEVTEXTZ].ob_spec.tedinfo->te_ptext, 10);
                 ZAHL_NACH_ASCII(a_page,  dev_tree[DEVTEXTZH].ob_spec.tedinfo->te_ptext, 10);
                 m_v_clswk(wk_handle);
                 OpenDialog(&dev_info, dev_tree, exobj, ex_info, AUTO_DIAL|MODAL, " GDOS-Print ");
               }
               break;
          case CATALOG:
               ausgabe_vorbereiten();
               ret = bestimme_datei_v(datei, fpath);
               if(ret && get_fonts(PF.lh))
               {
                 if((wk_handle = open_wkst(PF.lh)) != 0)
                 {
                   anz_font = vst_load_fonts(wk_handle, 0) + work_out[10] + 1;
                   fn = vst_font(wk_handle, afp->font_id);
                   if(fn == afp->font_id)
                   {
                     print_pic(wk_handle, fpath);
                   }
                   vst_unload_fonts(wk_handle, 0);
                   m_v_clswk(wk_handle);
                 }
               }
               break;
          case GDUOK:
               ausgabe_vorbereiten();
               if(strlen(fname) == 0)                            /* schon eine Datei gewaehlt? */
               {
                 ret = bestimme_datei(datei, fname, fpath);
                 dial_tree[NAMEDATEI].ob_spec.tedinfo->te_ptext = fname;
                 dial_tree[AKTUELLERPFAD].ob_spec.tedinfo->te_ptext = fpath;
                 ob_draw_chg(ex_info, NAMEDATEI, NULL, FAIL, FALSE);
                 ob_draw_chg(ex_info, AKTUELLERPFAD, NULL, FAIL, FALSE);
               }
               else
               {
                 strcpy(datei, fname);
                 ret = TRUE;
               }
               if(ret && get_fonts(PF.lh))
               {
                 mem = 0L;
                 mem = text_laden(datei, &laenge);
                 if(mem == 0L)
                 {
                   form_alert(1, "[3][ GDOS-Print: |  Datei nicht gefunden!  ][Abbruch]");
                 }
                 else
                 {
                   drucken((char *)mem, laenge);
                   free((void *)mem);
                   mem = NULL;
                   strcpy(fname, "");
                   ob_draw_chg(ex_info, NAMEDATEI, NULL, FAIL, FALSE);
                 }
               }
               break;
          default:
               CloseDialog(ex_info);
        }
      }
      else if(ex_info == &font_info)      /* Font-Dialog */
      {
        switch(exobj)
        {
          case FONTVORHER :
               if((afp - 1)->font_id != -1 && akt_font > 1)
               {
                 akt_font--;
                 afp--;
#ifdef FONT_DEBUG
                 printf("%d- %d %d %d \n",akt_font, afp->font_id, afp->font_spd, afp->font_prop);
#endif
                 set_font_state(ex_info);
               }
               break;
          case FONTDANACH :
               if(akt_font < anz_font)
               {
                 akt_font++;
                 afp++;
#ifdef FONT_DEBUG
                 printf("%d+ %d %d %d \n",akt_font, afp->font_id, afp->font_spd, afp->font_prop);
#endif
                 set_font_state(ex_info);
               }
               break;
          case FONTOK     :
               dial_tree[FONTSELECT].ob_spec.tedinfo->te_ptext = afp->font_name;
               dial_tree[SPECIAL].ob_state = NORMAL;
               if(font_tree[ZHBEL].ob_state & SELECTED)
                 dial_tree[SPECIAL].ob_spec.tedinfo->te_ptext = font_tree[ZHBELIEBIG].ob_spec.tedinfo->te_ptext;
               else if(font_tree[ZH6].ob_state & SELECTED)
                 dial_tree[SPECIAL].ob_spec.tedinfo->te_ptext = font_tree[SZH6].ob_spec.tedinfo->te_ptext;
               else if(font_tree[ZH8].ob_state & SELECTED)
                 dial_tree[SPECIAL].ob_spec.tedinfo->te_ptext = font_tree[SZH8].ob_spec.tedinfo->te_ptext;
               else if(font_tree[ZH10].ob_state & SELECTED)
                 dial_tree[SPECIAL].ob_spec.tedinfo->te_ptext = font_tree[SZH10].ob_spec.tedinfo->te_ptext;
               set_font_state(ex_info);
          case FONTABBR   :
               ob_draw_chg(&dial_info, FONTSELECT, NULL, FAIL, FALSE);
               ob_draw_chg(&dial_info, PROFONT, NULL, FAIL, FALSE);
               ob_draw_chg(&dial_info, SPDFONT, NULL, FAIL, FALSE);
               ob_draw_chg(&dial_info, SPECIAL, NULL, FAIL, FALSE);

               CloseDialog(ex_info);
          break;
        }
      }
      else if(ex_info == &opt_info)  /* Einstellungen-Dialog */
      {
        switch(exobj)
        {
          case PPAGEPOP:
               Popup(&ppop, (double_click) ? POPUP_CYCLE_CHK : POPUP_BTN_CHK,
                     OBJPOS, 0, 0, NULL, FAIL);
               break;
/*          case STATFONTSICHERN:
               if(afp == NULL)
                 form_alert(1, "[3][ GDOS-PRINT| Fontliste kann nicht |   gesichert werden! | Keine Fonts geladen! ][ Ok ]");
               else
               {
                 if(!save_fontliste(fontp, anz_font))
                 form_alert(1, "[3][ GDOS-PRINT| Fehler beim schreiben | der Fontliste! ][ Ok ]");
               }
               break;
*/
          case SAVEOPT:
               if(!save_opt())
                 form_alert(1, "[3][ GDOS-PRINT| Fehler beim speichern! ][ Ok ]");
          case OKOPT  :
/*             PF.dev_chk  = opt_tree[AUTOCHK].ob_state;     */
               PF.s_pfad   = opt_tree[SAVEPFAD].ob_state;
               PF.abs_mode = opt_tree[ABSATZMODE].ob_state;
               PF.memory   = opt_tree[MEMDYN].ob_state;
/*             PF.stat_fontl = opt_tree[STATFONT].ob_state;  */
               PF.sparmod    = opt_tree[SPARMODE].ob_state;
               PF.copies     = opt_tree[COPYS].ob_state;
               if(opt_tree[FROMPAGE].ob_state & SELECTED)
                 PF.beginpage = atoi(opt_tree[FROMPAGENUM].ob_spec.tedinfo->te_ptext);
               else
                 PF.beginpage = 1;
               CloseDialog(ex_info);
               break;
          default:
               CloseDialog(ex_info);
        }
      }
      else      /* andere Dialoge schliežen */
        CloseDialog(ex_info);

    }
  }
}

/*******************************************/
/*******************************************/
void drucken(char *text, long size)
{
  int wk_handle, fn;
  long tlen;

  if(get_fonts(PF.lh))
  {
    tlen = text + size;
    if((wk_handle = open_wkst(PF.lh)) != 0)
    {
      anz_font = vst_load_fonts(wk_handle, 0) + work_out[10] + 1;
      fn = vst_font(wk_handle, afp->font_id);
      if(fn == afp->font_id)
      {
        if(afp->font_spd && afp->font_prop)
          print_vek_on_workstation(wk_handle, text, tlen);
        else
          print_pix_on_workstation(wk_handle, text, tlen);
      }
      else
      {
        form_alert(1, "[3][ GDOS-Print: | Gewnschter Zeichensatz | nicht verfgbar!][Abbruch]");
      }
      vst_unload_fonts(wk_handle, 0);
      m_v_clswk(wk_handle);
    }
  }
} /* drucken() */

/*******************************************/
/* Die Fontinformationen in den Dialogen   */
/* eintragen : p S xx Fontname             */
/*******************************************/
void set_font_state(DIAINFO *exinf)
{
  font_tree[FONTNAME].ob_spec.tedinfo->te_ptext = afp->font_name;
  ob_draw_chg(exinf, FONTNAME, NULL, FAIL, FALSE);

  if(afp->font_spd == TRUE)
  {
    font_tree[SPEEDFONT].ob_state = NORMAL;
    font_tree[ZHBEL].ob_state    &= ~DISABLED;
    dial_tree[SPDFONT].ob_state   = NORMAL;
  }
  else
  {
    font_tree[SPEEDFONT].ob_state = DISABLED;
    font_tree[ZHBEL].ob_state    |= DISABLED;
    dial_tree[SPDFONT].ob_state   = DISABLED;
  }
  ob_draw_chg(&font_info, SPEEDFONT, NULL, FAIL, FALSE);
  ob_draw_chg(&font_info, ZHBEL, NULL, FAIL, FALSE);

  if(afp->font_prop == TRUE)
  {
    font_tree[PROPFONT].ob_state = NORMAL;
    dial_tree[PROFONT].ob_state = NORMAL;
  }
  else
  {
    font_tree[PROPFONT].ob_state = DISABLED;
    dial_tree[PROFONT].ob_state = DISABLED;
  }
  ob_draw_chg(&font_info, PROPFONT, NULL, FAIL, FALSE);
}

/***********************************************************************
 Dialog schliežen und aus Liste der ge”ffneten Dialoge entfernen
***********************************************************************/
void CloseDialog(DIAINFO *info)
{
  if (info->di_flag > CLOSED)
  {
    int i;

    close_dialog(info, FALSE);

    for (i = 0; i < win_cnt; i++)
      if (wins[i] == info)
        break;

    for (win_cnt--; i < win_cnt; i++)
      wins[i] = wins[i+1];
  }
}

/***********************************************************************
 Initialisierungs-Routine, welche von X_Form_Do aufgerufen wird und
 die Event-Struktur setzt sowie die Ereignisse, die von der Applikation
 ben”tigt werden, zurckgibt
***********************************************************************/
int InitMsg(EVENT *evt)
{  /* Nachrichten und Tastendrcke auswerten */
  evt->ev_mflags |= MU_MESAG|MU_KEYBD;
  return (MU_MESAG|MU_KEYBD);
}

/***********************************************************************
 Ereignisauswertung (AES-Nachrichten und Tastendrcke), welche sowohl
 von der Hauptschleife in der Funktion main() als auch von X_Form_Do()
 aufgerufen wird
***********************************************************************/
void Messag(EVENT *event)
{
  register int ev = event->ev_mwich, *msg = event->ev_mmgpbuf;

  if(ev & MU_MESAG)
  {
    switch(*msg)
    {
      case WM_CLOSED:
           if(ex_info != &dial_info)
             CloseDialog(ex_info);
           else if(ex_info == &dial_info)
           ExitExample(1);
           break;
#ifdef DND
      case AP_DRAGDROP:
           dd_recieve(event->ev_mmgpbuf);
           dial_tree[AKTUELLERPFAD].ob_spec.tedinfo->te_ptext = fpath;
           dial_tree[NAMEDATEI].ob_spec.tedinfo->te_ptext = fname;
           ob_draw_chg(&dial_info, AKTUELLERPFAD, NULL, FAIL, FALSE);
           ob_draw_chg(&dial_info, NAMEDATEI, NULL, FAIL, FALSE);
           break;
#endif
      case AP_TERM:               /* Applikation beenden/ruecksetzen  */
      case AC_CLOSE:
           dial_tree[FONTSELECT].ob_spec.tedinfo->te_ptext = null_string;
           ExitExample(0);
           break;
      case AC_OPEN:
           OpenDialog(&dial_info, dial_tree, 0, NULL, AUTO_DIAL, " GDOS-Print ");
           return;
      default: ;
    }
  }

  if((ev & MU_KEYBD) && (event->ev_mmokstate & K_CTRL))
  {
    switch(scan_2_ascii(event->ev_mkreturn, event->ev_mmokstate))
    {
      case 'Q':
           dial_tree[FONTSELECT].ob_spec.tedinfo->te_ptext = null_string;
           if(_app)
             ExitExample(1);
           else
             ExitExample(0);
           break;
      default: ;
    }
  }
} /* Message() */

/***********************************************************/
void main(int argc, char *argv[])
{
  int  mint;
  long sem, mversion;

  getcwd(fpath, 128);
  if(*(fpath + strlen(fpath)) != 92)
    strcat(fpath, "\\");
  *fname = 0x0;
  *null_string = 0x0;

  if(argc > 1)                /* Datei auf Ikon gezogen */
  {
    strcpy(fname, argv[1]);
  }

  ldrive = (*fpath) - 65;
  sdrive = ldrive;
  strcpy(lpath, fpath+2);     /* Ohne Laufwerksbuchstabe */
  strcpy(spath, lpath);       /* Startpfad */
  mint = get_cookie('MiNT', &mversion);

  if(mint && mversion >= 0x100)
  {
    sem = Psemaphore(2, (long)'SGPR', 1000);        /* Semaphor frei?      */

    switch((int)sem)
    {
      case ERANGE: Psemaphore(0, (long)'SGPR', 0);  /* kein Semaphor da: erzeugen */
                   break;
      case EACCDN: form_alert(1, "[3][ GDOS-Print: | Programm befindet sich | bereits im Speicher!][Abbruch]");
                   exit(0);
                   break;
      default:     ;
    }
  }

  switch(open_rsc("GPRINT.RSC","  GDOS-Print"))  /* open_rsc() geaendert !!! */
  {
    case FAIL:
         form_alert(1, "[3][GPRINT.RSC nicht gefunden!][Abbruch]");
         break;
    case FALSE:
         form_alert(1, "[3][Workstation konnte|nicht ge”ffnet werden!][Abbruch]");
         break;
    case TRUE:
    {
      wind_update(BEG_UPDATE);

      init_resource();

      if(load_opt())
      {
        ausgabe_vorbereiten();
/*        set_font(lh, id_akt_font);  <- ersetzen: akt_font = id_akt_font;
                                                   get_fonts(); */
        if(afp != NULL)
        {
          set_font_state(&font_info);
          dial_tree[FONTSELECT].ob_spec.tedinfo->te_ptext = afp->font_name;
        }
      }

      dial_options(TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE);
      dial_tree[AKTUELLERPFAD].ob_spec.tedinfo->te_ptext = fpath;
      dial_tree[NAMEDATEI].ob_spec.tedinfo->te_ptext = fname;

/*    PF.speedo     = get_cookie('_SPD', NULL);*/
/*    PF.dev_chk    = opt_tree[AUTOCHK].ob_state;*/
      PF.s_pfad     = opt_tree[SAVEPFAD].ob_state;
      PF.abs_mode   = opt_tree[ABSATZMODE].ob_state;
      PF.memory     = opt_tree[MEMDYN].ob_state;
/*    PF.stat_fontl = opt_tree[STATFONT].ob_state;*/
      PF.copies     = opt_tree[COPYS].ob_state;
      PF.sparmod    = opt_tree[SPARMODE].ob_state;

      /* testen ob ein Device angeschlossen ist */
/*    if(PF.dev_chk == SELECTED)
      {
        for(wh = 21; wh < 30; wh++)
        {
          work_in[0] = wh;
          for(i = 1; i < 10; work_in[i++] = 1);
          work_in[10] = 2;
          v_opnwk(work_in, &ret, work_out);
          if(ret == 0)
            pop_tree[(wh-21) + ID21].ob_state |= DISABLED;
        }
      }
*/
      wind_update(END_UPDATE);

      if(_app)
      {
        /*menu_bar(menu, 1);*/
        OpenDialog(&dial_info, dial_tree, 0, NULL, AUTO_DIAL, " GDOS-Print ");
      }
      event.ev_mflags = MU_MESAG|MU_KEYBD;

      for(;;)
      {
        EvntMulti(&event);
        Messag(&event);
      }
    }
  }

  if(!_app)
#ifdef __PUREC__
    for(;;) evnt_timer(0, 32000);
#endif
#ifdef __GNUC__
    for(;;) evnt_timer(32000L);
#endif
}

