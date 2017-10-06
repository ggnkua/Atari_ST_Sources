/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1995, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        <sys_gem2.h>
#include        <string.h>
#include        <stdio.h>

/* ------------------------------------------------------------------- */

#include        "demo.h"

/* -------------------------------------------------------------------
 * Zeiger auf die verschiedenen Dialoge / ObjektbÑume
 * ------------------------------------------------------------------- */

OBJECT  *rsc_menu;
OBJECT  *rsc_main;
OBJECT  *rsc_txw1;
OBJECT  *rsc_icon;
OBJECT  *rsc_wmen;
OBJECT  *rsc_edit;
OBJECT  *rsc_slid;
OBJECT  *rsc_reiter;
OBJECT  *rsc_button;
OBJECT  *rsc_rahmen1;
OBJECT  *rsc_rahmen2;
OBJECT  *rsc_boxchar;
OBJECT  *rsc_texte;
OBJECT  *rsc_frame;
OBJECT  *rsc_info;

/* -------------------------------------------------------------------
 * Lokale Buffer fÅr die Sliderboxen
 * ------------------------------------------------------------------- */

BYTE    sl_box1         [20][90];
BYTE    sl_box2         [20][90];

/* -------------------------------------------------------------------
 * LÑdt das Beispielmodul und startet es
 * ------------------------------------------------------------------- */

VOID HandleModul ( VOID )

{
  BYTE  modul_name [] = "TEST";

  /* -----------------------------------------------------------------
   * Wenn Modul schon im Speicher, dann nur noch starten
   * Nochmal laden wÑre aber auch nicht schlimm, SysGem wÅrde es
   * merken...
   * ----------------------------------------------------------------- */

  if ( ModulAvail ( modul_name ))
    {
      StartSysGemModul ( modul_name, NULL );
    }
  else
    {
      /* -------------------------------------------------------------
       * Modul noch nicht im Speicher, also laden...
       * ------------------------------------------------------------- */

      if ( LoadSysGemModul ( modul_name ))
        {
          StartSysGemModul ( modul_name, NULL );
        }
      else
        {
          /* ---------------------------------------------------------
           * Modul wurde nicht gefunden, Benutzer informieren...
           * --------------------------------------------------------- */

          Alert ( ALERT_NORM, 1, "[3][ Konnte das Modul | TEST.SGM | nicht finden! ][ [Abbruch ]" );
        }
    }
}

/* -------------------------------------------------------------------
 * Verwaltet die Drag&Drop-Aktionen des Benutzers
 * ------------------------------------------------------------------- */

VOID HandleDragDrop ( DRAG_DROP *d )

{
  LOCAL LONG    win_id  = 'disp';

  /* -----------------------------------------------------------------
   * Das Logfenster îffnen, um den Dateinamen anzuzeigen. Ist das
   * Fenster schon offen, dann toppen...
   * ----------------------------------------------------------------- */

  OpenLogWindow ( 'xlog', "Drag&Drop-Protokoll", "", 60, 10, 20, 20, (APROC) NULL );

  /* -----------------------------------------------------------------
   * Die Datei, die geladen werden soll, im Logfenster ausgeben
   * ----------------------------------------------------------------- */

  wprintf ( 'xlog', "Lade Datei %s\n", d->data );

  /* -----------------------------------------------------------------
   * Datei laden und anzeigen
   * ----------------------------------------------------------------- */

  Display ( d->data, "Dateiinhalt", d->data, 250, win_id, 50, 50, 300, 200, (APROC) NULL );

  /* -----------------------------------------------------------------
   * Fenster-Id hochzÑhlen, um eine neue Id zu erhalten
   * ----------------------------------------------------------------- */

  win_id++;
}

/* -------------------------------------------------------------------
 * Fragt nach, ob das Programm beendet werden soll. Wenn ja, dann mit
 * TerminateSysGem das Programm beenden...
 * ------------------------------------------------------------------- */

VOID AskTerm ( VOID )

{
  if ( Alert ( ALERT_NORM, 1, "[2][ Wollen Sie wirklich beenden? ][   [Ja   |  [Nein  ]" ) == 1 )
    {
      TerminateSysGem ();
    }
}

/* -------------------------------------------------------------------
 * Verwaltet die Reiter und den Dialog von "MultipleDialog"
 * ------------------------------------------------------------------- */

INT HandleObjects ( INT msg, INT button, DIALOG_INFO *inf )

{
  switch ( msg )
    {
      case SG_START    : /* ------------------------------------------
                          * Voreinstellungen
                          * ------------------------------------------ */

                         SetText ( rsc_texte, TE_EDTEXT, "Ein kleiner Test" );
                         break;

      case SG_END      : /* ------------------------------------------
                          * Fenster schlieûen
                          * ------------------------------------------ */

                         switch ( button )
                           {
                             case -1     : return ( SG_CLOSE );
                             default     : break;
                           }
                         break;

      case SG_HELP     : /* ------------------------------------------
                          * User hat HELP gedrÅckt oder auf den HILFE-
                          * Button geklickt
                          * ------------------------------------------ */

                         Alert ( ALERT_NORM, 1, "[3][ Noch keine Hilfe verfÅgbar! ][   [OK   ]" );
                         break;

      case SG_NEWDIAL  : /* ------------------------------------------
                          * Je nachdem, welcher Reiter angewÑhlt wurde,
                          * wird hier der richtige Dialog dazu einge-
                          * tragen
                          * ------------------------------------------ */

                         switch ( button )
                           {
                             case RE_BUTTON1  : inf->tree = rsc_button;   break;
                             case RE_RAHMEN1  : inf->tree = rsc_rahmen1;  break;
                             case RE_RAHMEN2  : inf->tree = rsc_rahmen2;  break;
                             case RE_BOXCHAR  : inf->tree = rsc_boxchar;  break;
                             case RE_TEXT     : inf->tree = rsc_texte;    break;
                             case RE_FRAME    : inf->tree = rsc_frame;    break;
                             default          : return ( SG_CONT );
                           }
                         return ( SG_TAKEDIAL );

      case SG_DRAGDROP : /* ------------------------------------------
                          * Drag&Drop-Aktionen auswerten
                          * ------------------------------------------ */

                         HandleDragDrop ( inf->dd );
                         break;
      default          : break;
    }
  return ( SG_CONT );
}

/* -------------------------------------------------------------------
 * Erzeugt die Sliderboxen und die Icons und "hÑngt" sie in den Dialog
 * ------------------------------------------------------------------- */

VOID MakeSlider ( BOOL icons )

{
  INT   i;

  memset ( sl_box1, 0, sizeof ( sl_box1 ));
  memset ( sl_box2, 0, sizeof ( sl_box2 ));

  for ( i = 0; i < 20; i++ )
    {
      if (( i % 2 ) == 0 )
        {
          sprintf ( sl_box1 [i], "+....+\tLinks\tZentriert\tRechts\t1.234,56\tZeile\t%d\tdie auch etwas lÑnger ist ", i + 1 );
        }
      else
        {
          sprintf ( sl_box1 [i], "+....+\tLeft\tCenter\tRight\t1,234.56\tLine\t%d\tdie auch etwas lÑnger ist ", i + 1 );
        }

      /* -------------------------------------------------------------
       * Die Zeiger auf das Icon eintragen
       * ------------------------------------------------------------- */

      sl_box1 [i][0] = 255;
      sl_box1 [i][1] = (BYTE)((LONG)( rsc_icon ) >> 24 );
      sl_box1 [i][2] = (BYTE)((LONG)( rsc_icon ) >> 16 );
      sl_box1 [i][3] = (BYTE)((LONG)( rsc_icon ) >>  8 );
      sl_box1 [i][4] = (BYTE)((LONG)( rsc_icon ) >>  0 );
      sl_box1 [i][5] = (BYTE)( IC_BAR );
    }

  for ( i = 0; i < 20; i++ )
    {
      sprintf ( sl_box2 [i], "+....+      Eine Textzeile Nr. %2d ohne Tab\'s, die aber trotzdem relativ lang ist ", i + 1 );

      /* -------------------------------------------------------------
       * Die Zeiger auf das Icon eintragen
       * ------------------------------------------------------------- */

      sl_box2 [i][0] = 255;
      sl_box2 [i][1] = (BYTE)((LONG)( rsc_icon ) >> 24 );
      sl_box2 [i][2] = (BYTE)((LONG)( rsc_icon ) >> 16 );
      sl_box2 [i][3] = (BYTE)((LONG)( rsc_icon ) >>  8 );
      sl_box2 [i][4] = (BYTE)((LONG)( rsc_icon ) >>  0 );
      sl_box2 [i][5] = (BYTE)( IC_BAR );
    }

  /* -----------------------------------------------------------------
   * Die Sliderboxen im Dialog anmelden
   * ----------------------------------------------------------------- */

  if ( icons )
    {
      LinkSlider ( rsc_slid, SL_UP,  SL_DN,  SL_SHOW,  SL_HIDE,  20, SL_BOX,  sl_box1, 90, TRUE );
      LinkSlider ( rsc_slid, SL_UP2, SL_DN2, SL_SHOW2, SL_HIDE2, 20, SL_BOX2, sl_box2, 90, TRUE );
    }
  else
    {
      LinkSlider ( rsc_slid, SL_UP,  SL_DN,  SL_SHOW,  SL_HIDE,  20, SL_BOX,  &sl_box1 [0][6], 90, FALSE );
      LinkSlider ( rsc_slid, SL_UP2, SL_DN2, SL_SHOW2, SL_HIDE2, 20, SL_BOX2, &sl_box2 [0][6], 90, FALSE );
    }

  /* -----------------------------------------------------------------
   * Die Sliderboxen mit horizontalen Slidern versehen
   * ----------------------------------------------------------------- */

  LinkHorSlider ( rsc_slid, SL_BOX,  SL_LF,  SL_RT,  SL_HSHOW,  SL_HHIDE );
  LinkHorSlider ( rsc_slid, SL_BOX2, SL_LF2, SL_RT2, SL_HSHOW2, SL_HHIDE2 );

  /* -----------------------------------------------------------------
   * Die Tabulatoren in der ersten Sliderbox definieren
   * ----------------------------------------------------------------- */

  SetSliderTab  ( rsc_slid, SL_BOX,  6, TAB_LEFT    );
  SetSliderTab  ( rsc_slid, SL_BOX, 18, TAB_CENTER  );
  SetSliderTab  ( rsc_slid, SL_BOX, 31, TAB_RIGHT   );
  SetSliderTab  ( rsc_slid, SL_BOX, 39, TAB_DECIMAL );
  SetSliderTab  ( rsc_slid, SL_BOX, 44, TAB_LEFT    );
  SetSliderTab  ( rsc_slid, SL_BOX, 52, TAB_RIGHT   );
  SetSliderTab  ( rsc_slid, SL_BOX, 54, TAB_LEFT    );
}

/* -------------------------------------------------------------------
 * KÅmmert sich um die Verwaltung der Sliderboxen bzw., des Dialogs
 * ------------------------------------------------------------------- */

INT HandleSliderWindow ( INT msg, INT button, DIALOG_INFO *inf )

{
  switch ( msg )
    {
      case SG_START     : /* -----------------------------------------
                           * Voreinstellungen
                           * ----------------------------------------- */

                          MakeSlider ( FALSE );
                          DelState ( inf->tree, SL_ICONS, SELECTED );
                          break;
      case SG_SELECT    :
      case SG_DESELECT  : /* -----------------------------------------
                           * Sliderboxen abmelden und dann wieder
                           * mit/ohne Icons anmelden
                           * ----------------------------------------- */

                          UnLinkSlider ( inf->tree, SL_BOX  );
                          UnLinkSlider ( inf->tree, SL_BOX2 );
                          ShowBee ();
                          MakeSlider ( msg == SG_SELECT );

                          /* -----------------------------------------
                           * Die Sliderboxen neuzeichnen
                           * ----------------------------------------- */

                          RedrawSliderBox ( inf->tree, SL_BOX  );
                          RedrawSliderBox ( inf->tree, SL_BOX2 );
                          ShowArrow ();
                          break;

      case SG_END       : /* -----------------------------------------
                           * Fenster wieder schlieûen
                           * ----------------------------------------- */

                          if ( button == -1 )
                            {
                              return ( SG_CLOSE );
                            }
                          break;

      case SG_NEWFONT   : /* -----------------------------------------
                           * Im Fontselector wurde der Font gewechselt,
                           * hier wird der Text in den Sliderboxen auf
                           * diesen neuen Font eingestellt
                           * ----------------------------------------- */

                          SetSliderFont ( inf->tree, SL_BOX,  button, -1, TRUE );
                          SetSliderFont ( inf->tree, SL_BOX2, button, -1, TRUE );
                          break;

      case SG_QUIT      : /* -----------------------------------------
                           * Fenster wird geschlossen, Sliderboxen
                           * wieder abmelden
                           * ----------------------------------------- */

                          UnLinkSlider ( inf->tree, SL_BOX  );
                          UnLinkSlider ( inf->tree, SL_BOX2 );
                          break;

      case SG_DRAGDROP  : /* -----------------------------------------
                           * Drag&Drop-Aktionen auswerten
                           * ----------------------------------------- */

                          HandleDragDrop ( inf->dd );
                          break;
    }
  return ( SG_CONT );
}

/* -------------------------------------------------------------------
 * Verwaltet den Dialog mit den Editfeldern
 * ------------------------------------------------------------------- */

INT HandleEditWindow ( INT msg, INT button, DIALOG_INFO *inf )

{
  switch ( msg )
    {
      case SG_START     : /* -----------------------------------------
                           * Voreinstellungem, Editfelder leeren
                           * ----------------------------------------- */

                          ClearEditFields ( inf->tree );
                          break;

      case SG_END       : /* -----------------------------------------
                           * Fenster schlieûen
                           * ----------------------------------------- */

                          if ( button == 12 ) return ( SG_CLOSE );
                          break;

      case SG_DRAGDROP  : /* -----------------------------------------
                           * Drag&Drop-Aktionen auswerten
                           * ----------------------------------------- */

                          HandleDragDrop ( inf->dd );
                          break;
    }
  return ( SG_CONT );
}

/* -------------------------------------------------------------------
 * Erzeugt die Textzeilen fÅr das Textfenster
 * ------------------------------------------------------------------- */

VOID MakeText ( BOOL icons )

{
  BYTE  string [100];
  INT   i;
  INT   z;

  z = 0;
  if ( icons ) z = 4;

  /* -----------------------------------------------------------------
   * Die Tabulatoren fÅr das Textfenster definieren
   * ----------------------------------------------------------------- */

  SetListTab ( 'text',  4 + z, TAB_LEFT );
  SetListTab ( 'text', 22 + z, TAB_CENTER );
  SetListTab ( 'text', 41 + z, TAB_RIGHT );
  SetListTab ( 'text', 54 + z, TAB_DECIMAL );
  SetListTab ( 'text', 61 + z, TAB_LEFT );
  SetListTab ( 'text', 75 + z, TAB_RIGHT );

  /* -----------------------------------------------------------------
   * "Bescheidsagen", daû das Fenster aufgebaut wird...
   * ----------------------------------------------------------------- */

  BeginListUpdate ( 'text' );

  /* -----------------------------------------------------------------
   * Den Status anzeigen, wie weit der Fensteraufbau ist
   * ----------------------------------------------------------------- */

  ShowStatus ( "Fenster wird aufgebaut...", "", 0L, 199L );
  for ( i = 0; i < 200; i++ )
    {
      if (( i % 2 ) == 0 )
        {
          sprintf ( string, "\tLinksbÅndig\tZentriert\tRechtsbÅndig\t1.234.567,89\tZeile Nr.\t%d ", i + 1 );
        }
      else
        {
          sprintf ( string, "\tLinks\tZentr\tRechts\t1,234.56\tZeile Nr.\t%d ", i + 1 );
        }
      if ( i == 0 )
        {
          /* ---------------------------------------------------------
           * Die erste Textzeile einhÑngen
           * --------------------------------------------------------- */

          LinkList ( 'text', string );
        }
      else
        {
          /* ---------------------------------------------------------
           * Weitere Zeilen einhÑngen
           * --------------------------------------------------------- */

          AddToList ( 'text', string );
        }
      if ( icons )
        {
          /* ---------------------------------------------------------
           * Wenn icons, dann das Icon vor der Zeile platzieren
           * --------------------------------------------------------- */

          xSetLineIcon ( 'text', i, rsc_icon, IC_FOLDER );
        }
      ShowStatus ( NULL, NULL, (LONG)( i ), 199L );
    }
  /* -----------------------------------------------------------------
   * Das Statusfenster wieder entfernen
   * ----------------------------------------------------------------- */

  EndStatus ();

  /* -----------------------------------------------------------------
   * Fensteraufbau ist beendet, Redraw erzwingen
   * ----------------------------------------------------------------- */

  EndListUpdate ( 'text' );
}

/* -------------------------------------------------------------------
 * Verwaltet die BenutzeraktivitÑten im Textfenster
 * ------------------------------------------------------------------- */

INT HandleTextWindow ( INT msg, WINDOW_INFO *inf )

{
  INT   id;
  INT   pt;
  BYTE  str [200];
  BYTE  c;
  BYTE  *p;

  switch ( msg )
    {
      case SG_3DSTATE   : /* -----------------------------------------
                           * Wenn sich der 3D-Status Ñndert, reagieren
                           * ----------------------------------------- */

                          if ( SysGem3D ())
                            {
                              SetWinBackground ( inf->id, LWHITE );
                            }
                          else
                            {
                              SetWinBackground ( inf->id, WHITE );
                            }
                          if ( msg == SG_3DSTATE )
                            {
                              break;
                            }

      case SG_START     : /* -----------------------------------------
                           * Voreinstellungen, Baum einhÑngen und den
                           * Text erzeugen
                           * ----------------------------------------- */

                          LinkTree ( inf->id, rsc_txw1, 'xwn1', LINK_TOP );
                          MakeText ( FALSE );
                          SetWinMinSize ( inf->id, 500, 108 );
                          break;

      case SG_SELECT    : /* -----------------------------------------
                           * Icons sollen angezeigt werden
                           * ----------------------------------------- */

                          DelCompleteList ( inf->id );
                          MakeText ( TRUE );
                          break;

      case SG_DESELECT  : /* -----------------------------------------
                           * Icons vor den Zeilen entfernen
                           * ----------------------------------------- */

                          DelCompleteList ( inf->id );
                          MakeText ( FALSE );
                          break;

      case SG_LCLICK1   : /* -----------------------------------------
                           * Linksklick im Fenster
                           * ----------------------------------------- */

                          if ( SetLineFlags ( inf->id, (UINT) inf->line, -1 ) & 1 )
                            {
                              SetLineFlags ( inf->id, (UINT) inf->line, 0 );
                            }
                          else
                            {
                              SetLineFlags ( inf->id, (UINT) inf->line, 1 );
                            }
                          RedrawLine ( inf->id, (UINT) inf->line );
                          break;

      case SG_LCLICK2   : /* -----------------------------------------
                           * Doppelklick ins Fenster, Info ausgeben
                           * ----------------------------------------- */

                          c = ' ';
                          if ( inf->column != -1L )
                            {
                              p = GetLinePtr ( inf->id, (UINT) inf->line );
                              if ( p ) c = p [inf->column];
                            }
                          sprintf ( str, "[1][ Angeklickt wurde: | Zeile: %ld (%ld) | Spalte: %ld | Zeichen: '%c' | mit \"Doppelklick links\" ][   [OK   ]", inf->line, inf->line + 1L, inf->column, c );
                          Alert ( ALERT_NORM, 1, str );
                          break;

      case SG_RCLICK1   : /* -----------------------------------------
                           * Rechtsklick ins Fenster, info ausgeben
                           * ----------------------------------------- */

                          c = ' ';
                          if ( inf->column != -1L )
                            {
                              p = GetLinePtr ( inf->id, (UINT) inf->line );
                              if ( p ) c = p [inf->column];
                            }
                          sprintf ( str, "[1][ Angeklickt wurde: | Zeile: %ld (%ld) | Spalte: %ld | Zeichen: '%c' | mit \"Einfachklick rechts\" ][   [OK   ]", inf->line, inf->line + 1L, inf->column, c );
                          Alert ( ALERT_NORM, 1, str );
                          break;

      case SG_RCLICK2   : /* -----------------------------------------
                           * Doppelklick ins Fenster, Info ausgeben
                           * ----------------------------------------- */

                          c = ' ';
                          if ( inf->column != -1L )
                            {
                              p = GetLinePtr ( inf->id, (UINT) inf->line );
                              if ( p ) c = p [inf->column];
                            }
                          sprintf ( str, "[1][ Angeklickt wurde: | Zeile: %ld (%ld) | Spalte: %ld | Zeichen: '%c' | mit \"Doppelklick rechts\" ][   [OK   ]", inf->line, inf->line + 1L, inf->column, c );
                          Alert ( ALERT_NORM, 1, str );
                          break;

      case SG_MENU      : /* -----------------------------------------
                           * Klick in die FenstermenÅzeile
                           * ----------------------------------------- */

                          switch ( inf->mItem )
                            {
                              case WI_INFO : WindowDialog ( 'info', -1, -1, "| Information ", "", TRUE, FALSE, rsc_info, NULL, -2, NULL, (DPROC) NULL );
                                             break;
                              case WI_CLOSE: return ( SG_CLOSE );
                            }
                          break;

      case SG_BUTTON    : /* -----------------------------------------
                           * Fontselektor wurde gewÑhlt
                           * ----------------------------------------- */

                          switch ( inf->item )
                            {
                              case TE_FONT      : GetWindowFont ( inf->id, &id, &pt );
                                                  if ( FontSelect ( BUT_OK | BUT_SYSTEM | BUT_ABORT, &id, &pt, "WÑhle Font", NULL, FALSE, (TPROC) NULL ))
                                                    {
                                                      ShowMessage ( "Fenster wird umgerechnet..." );
                                                      SetWindowFont ( inf->id, id, pt );
                                                      EndMessage ();
                                                    }
                                                  break;
                            }
                          break;

      case SG_DRAGDROP  : /* -----------------------------------------
                           * Drag&Drop-Aktionen auswerten
                           * ----------------------------------------- */

                          HandleDragDrop ( inf->dd );
                          break;
      case SG_BEGINHELP : switch ( inf->item )
                            {
                              case TE_ICONS : BeginHelp ( rsc_txw1, TE_ICONS, " Wenn aktiviert, werden vor den | Zeilen jeweils Icons gezeichnet " );
                                              break;
                              case TE_FONT  : BeginHelp ( rsc_txw1, TE_FONT,  " Ruft den Fontselektor auf, um | den Font der Zeilen zu Ñndern " );
                                              break;
                            }
                          break;
      case SG_ENDHELP   : EndHelp ();
                          break;

      case SG_END       : /* -----------------------------------------
                           * Das Fenster soll geschlossen werden
                           * ----------------------------------------- */

                          return ( SG_CLOSE );
    }
  return ( SG_CONT );
}

/* -------------------------------------------------------------------
 * Textfenster îffnen
 * ------------------------------------------------------------------- */

VOID ShowTextWindow ( VOID )

{
  OpenWindow ( 'text', "Textfenster", " Die Info-Zeile des Fensters ", 0xfef | INFO | 0x4000, rsc_wmen, 8, TRUE, GetParam ( PAR_CHARW ), GetParam ( PAR_CHARH ), 1L, 1L, 20, 20, 600, 182, NULL, (RPROC) NULL, HandleTextWindow );
}

/* -------------------------------------------------------------------
 * Verwaltet das Hauptfenster
 * ------------------------------------------------------------------- */

INT HandleMainWindow ( INT msg, INT button, DIALOG_INFO *inf )

{
  LOCAL INT     circ = IC_POP;
        INT     i;

  switch ( msg )
    {
      case SG_START     : /* -----------------------------------------
                           * Voreinstellungen, Editfelder leeren
                           * ----------------------------------------- */

                          ClearEditFields ( inf->tree );
                          SetState ( inf->tree, MA_ROUND, SELECTED );
                          SetState ( inf->tree, MA_3D,    SELECTED );
                          if ( ! SysGem3D ()) DelState ( inf->tree, MA_3D, SELECTED );
                          if ( GetParam ( PAR_ACTCOLOR ) < 16 ) DisableObj ( inf->tree, MA_3D, FALSE );
                          break;

      case SG_MENU      : /* -----------------------------------------
                           * Klick in die FenstermenÅzeile auswerten
                           * ----------------------------------------- */

                          switch ( button )
                            {
                              case ME_INFO      : WindowDialog ( 'info', -1, -1, "| Information ", "", TRUE, FALSE, rsc_info, NULL, -2, NULL, (DPROC) NULL );
                                                  break;
                              case ME_EDIT      : WindowDialog ( 'edit', -1, -1, "Editfelder", "", FALSE, FALSE, rsc_edit, NULL, -2, NULL, HandleEditWindow );
                                                  break;
                              case ME_SLIDER    : WindowDialog ( 'slid', -1, -1, "Sliderboxen", "", TRUE, FALSE, rsc_slid, NULL, -2, NULL, HandleSliderWindow );
                                                  break;
                              case ME_TEXT      : ShowTextWindow ();
                                                  break;
                              case ME_OBJECT    : MultipleDialog ( 'xobj', -1, -1, "Objekttypen", "", rsc_reiter, RE_BUTTON1, rsc_button, -2, NULL, HandleObjects );
                                                  break;
                              case ME_QUIT      : AskTerm ();
                                                  break;
                              default           : break;
                            }
                          break;

      case SG_SELECT    : /* -----------------------------------------
                           * Select-Button wurde angeklickt
                           * ----------------------------------------- */

                          switch ( button )
                            {
                              case MA_3D    : Enable3D ();
                                              break;
                              case MA_ROUND : UseRoundButtons ( TRUE );
                                              return ( SG_REDRAWALL );
                            }
                          break;

      case SG_DESELECT  : /* -----------------------------------------
                           * Select-Button wurde deaktiviert
                           * ----------------------------------------- */

                          switch ( button )
                            {
                              case MA_3D    : Disable3D ();
                                              break;
                              case MA_ROUND : UseRoundButtons ( FALSE );
                                              return ( SG_REDRAWALL );
                            }
                          break;

      case SG_END       : /* -----------------------------------------
                           * Button wurde angeklickt
                           * ----------------------------------------- */

                          switch ( button )
                            {
                              case -1       :
                              case MA_EXIT  : AskTerm ();
                                              break;
                              case MA_MOD   : HandleModul ();
                                              break;
                              case MA_LIST  : Listbox ( " Eine | kleine | Listbox | in | der | bis | zu | 60000 | Elemente | Platz | finden | kînnen ", -1, -1, inf->tree, button );
                                              break;
                              case MA_CIRC  : i = circ;
                                              if ( i == IC_POP ) i++;
                                              if (( i = xPopUp ( inf->tree, button, rsc_icon, IC_POP, &i )) != -1 )
                                                {
                                                  circ = i;
                                                }
                                              break;
                              default       : break;
                            }
                          break;

      case SG_LCIRCLE   : /* -----------------------------------------
                           * Circle-Button wurde angeklickt
                           * ----------------------------------------- */

                          Cycle ( inf->tree, button, rsc_icon, IC_FIRST, IC_LAST, &circ );
                          break;

      case SG_RCIRCLE   : /* -----------------------------------------
                           * Circle-Button wurde angeklickt
                           * ----------------------------------------- */

                          CycleBack ( inf->tree, button, rsc_icon, IC_FIRST, IC_LAST, &circ );
                          break;

      case SG_DRAGDROP  : /* -----------------------------------------
                           * Drag&Drop-Aktionen auswerten
                           * ----------------------------------------- */

                          HandleDragDrop ( inf->dd );
                          break;
    }
  return ( SG_CONT );
}

/* -------------------------------------------------------------------
 * Main
 * ------------------------------------------------------------------- */

INT main ( VOID )

{
  /* -----------------------------------------------------------------
   * SysGem Initialisieren
   * ----------------------------------------------------------------- */

  if ( InitGem ( "", 'DEMO', "SysGem-Demo" ) > 0 )
    {
      SetKey ( 0L, 0L );

      /* -------------------------------------------------------------
       * Eigene Editfelder anmelden
       * ------------------------------------------------------------- */

      UseOwnEditFields ();

      /* -------------------------------------------------------------
       * Resource Datei laden und die Baumadressen ermitteln
       * ------------------------------------------------------------- */

      if ( LoadResource ( "DEMO.RSC", FALSE ))
        {
          rsc_menu      = RscAdr ( R_TREE, MENUE );
          rsc_main      = RscAdr ( R_TREE, MAIN  );
          rsc_txw1      = RscAdr ( R_TREE, TEXTWIN1 );
          rsc_icon      = RscAdr ( R_TREE, ICONS );
          rsc_wmen      = RscAdr ( R_TREE, WIN_MENUE );
          rsc_edit      = RscAdr ( R_TREE, EDIT );
          rsc_slid      = RscAdr ( R_TREE, SLIDER );
          rsc_reiter    = RscAdr ( R_TREE, REITER );
          rsc_button    = RscAdr ( R_TREE, BUTTONS );
          rsc_rahmen1   = RscAdr ( R_TREE, RAHMEN1 );
          rsc_rahmen2   = RscAdr ( R_TREE, RAHMEN2 );
          rsc_boxchar   = RscAdr ( R_TREE, BOXCHARS );
          rsc_texte     = RscAdr ( R_TREE, TEXTE );
          rsc_frame     = RscAdr ( R_TREE, FRAME );
          rsc_info      = RscAdr ( R_TREE, SGINFO );

          /* ---------------------------------------------------------
           * Die Dialoge bei SysGem anmelden
           * --------------------------------------------------------- */

          NewDialog ( rsc_main );
          NewDialog ( rsc_txw1 );
          NewDialog ( rsc_icon );
          NewDialog ( rsc_edit );
          NewDialog ( rsc_slid );
          NewDialog ( rsc_reiter );
          NewDialog ( rsc_button );
          NewDialog ( rsc_rahmen1 );
          NewDialog ( rsc_rahmen2 );
          NewDialog ( rsc_boxchar );
          NewDialog ( rsc_texte );
          NewDialog ( rsc_frame );
          NewDialog ( rsc_info );

          /* ---------------------------------------------------------
           * Logfenster fÅr die Drag-Drop-Aktionen îffnen
           * --------------------------------------------------------- */

          OpenLogWindow ( 'xlog', "Drag&Drop-Protokoll", "", 60, 10, 20, 20, (APROC) NULL );

          /* ---------------------------------------------------------
           * Das Hauptfenster îffnen
           * --------------------------------------------------------- */

          if ( WindowDialog ( 'main', -1, -1, "Hauptfenster", "", TRUE, FALSE, rsc_main, rsc_menu, -2, NULL, HandleMainWindow ))
            {
              /* -----------------------------------------------------
               * Kontrolle an SysGem abgeben...
               * ----------------------------------------------------- */

              HandleSysGem ();
            }
        }
      /* -------------------------------------------------------------
       * Lib wieder abmelden und allen benutzen Speicher freigeben
       * ------------------------------------------------------------- */

      ExitGem ();
    }
  return ( 0 );
}

/* ------------------------------------------------------------------- */
