/* ------------------------------------------------------------------- *
 * Module Version       : 1.20                                         *
 * Module Date          : 21-05-94                                     *
 * Last Change          : 21-05-94                                     *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        <stdio.h>
#include        <string.h>
#include        <stdlib.h>
#include        <sys_gem.h>

/* ------------------------------------------------------------------- */

#include	"demo.h"
#include	"demo.rh"
#include	"demo.rsh"

/* ------------------------------------------------------------------- */

#pragma		warn -par

/* ------------------------------------------------------------------- */

#define		PRG_NAME	"SysGem-Demo"
#define		PRG_ID		'DEMO'
#define		ACC_NAME	""
#define		USR_NAME	"Andreas Pietsch"
#define		USR_ID		'ANPI'
#define		USR_KEY		0L

/* ------------------------------------------------------------------- */

#define 	ASK_TERM        "[2][ Wollen Sie das Demo | wirklich verlassen? ][ [Nein | [Ja ]"
#define         NO_DRAG		"[1][ Auf dieses Fenster k”nnen | Sie keine Objekte ziehen! ][ [Abbruch ]"

/* ------------------------------------------------------------------- */

PARAMETER	par;
LONG		win_id   = 'TX00';
INT		pop      = 1;
BYTE		slid_txt [20][33];  /* Textbuffer fr die Sliderbox    */

/* ------------------------------------------------------------------- */

VOID LoadText ( BYTE *fname );

/* ------------------------------------------------------------------- */

#define rsc_main	rs_trindex [MAIN]
#define rsc_menu        rs_trindex [MENUE1]
#define rsc_info        rs_trindex [SGINFO]
#define rsc_bits        rs_trindex [BITS]
#define rsc_tool        rs_trindex [TOOLS]
#define rsc_pop         rs_trindex [SPOPUP]
#define rsc_edit        rs_trindex [SEDIT]

/* -------------------------------------------------------------------
 * Zeichnet die "Uhr" im Fenster jede Sekunde
 * ------------------------------------------------------------------- */

VOID draw_bits ( VOID )

{
  LOCAL LONG zeit = 0L;
  LOCAL BYTE s [10];

  zeit++;
  sprintf ( s, "%5ld", zeit );
  SetText ( rsc_bits, BI_SEC, s );
  RedrawObj ( rsc_bits, BI_SEC, 0, NONE, UPD_STATE );
}

/* -------------------------------------------------------------------
 * Behandelt die Aktivit„ten des "Uhren"-Fensters. Wenn das Fenster
 * ausgeblendet oder Iconifiziert wird, mssen die Timer-Funktion
 * ausgeschaltet werden.
 * ------------------------------------------------------------------- */

INT handle_bits ( INT msg, INT button, DIALOG_INFO *inf )

{
  switch ( msg )
    {
      case SG_START     : SetText ( rsc_bits, BI_SEC, "" );
                          SetProcTimer ( draw_bits );
                          SetTimer ( 700, 0 );
                          break;
      case SG_INVISIBLE : SetTimer ( 0, 0 );
                          break;
      case SG_VISIBLE   : SetTimer ( 700, 0 );
                          break;
      case SG_QUIT      :
      case SG_END       : SetTimer ( 0, 0 );
                          return ( SG_CLOSE );
    }
  return ( SG_CONT );
}

/* -------------------------------------------------------------------
 * Wertet Nachrichten von SysInfo aus.
 * ------------------------------------------------------------------- */

LONG GetMessage ( BYTE msg, BYTE sub, LONG from, LONG parm )

{
  if ( from == 'SINF' )
    {
      if (( msg == MSG_SYSTEM ) || ( msg == MSG_OPEN ))
        {
          if (( sub == 1 ) && ( parm == 'SIAG' ))
            {
              LoadText ( "C:\\CLIPBRD\\SCRAP.TXT" );
            }
          if ( sub == 0 ) Alert ( ALERT_NORM, 1, "[1][ Irgendwas ist schiefgegangen! ][ [Aha ]" );
        }
    }
  return ( 0L );
}

/* -------------------------------------------------------------------
 * Ruft die Funktionen von SysInfo auf
 * ------------------------------------------------------------------- */

VOID SysInfo ( LONG todo )

{
  if ( ProgramExist ( 'SINF' ) == -1 )
    {
      Alert ( ALERT_NORM, 1, "[1][ SysInfo ist (noch) nicht | installiert! ][ [Ok ]" );
      return;
    }
  if ( todo == 'SIAG' ) SendSgMsg ( MSG_SYSTEM, 4, 'SINF', 0L );
                   else SendSgMsg ( MSG_OPEN,   0, 'SINF', todo );
}

/* -------------------------------------------------------------------
 * Soll ein Fensterdialog ge”ffnet werden und steht kein Fenster mehr
 * zur Verfgung, so kann der Dialog entweder abgebrochen (DIAL_ABORT)
 * werden, oder als "normale" Dialogbox weitergefhrt werden.
 * ------------------------------------------------------------------- */

LOCAL INT no_window_left ( VOID )

{
  if ( Alert ( ALERT_NORM, 1, "[4][ Kein Fenster mehr frei! | M”chten Sie mit einer | Dialogbox weiterarbeiten? ][ [Ja | [Nein ]" ) == 1 )
    {
      return ( SG_CONT );
    }
  return ( SG_ABORT );
}

/* -------------------------------------------------------------------
 * Mit Hilfe von einer solchen Funktion, k”nnen ohne Probleme bestimmte
 * Werte oder Zust„nde in einem Dialog geprft werden.
 *
 * ed ist dabei die positive Nummer des Editfeldes, wenn der Cursor das
 * Feld verlassen soll, negativ, wenn der Cursor das Feld betritt.
 *
 * Id ist die Id, die bei WindowDialog angegeben wurde. So kann man eine
 * Routine zum Testen mehrerer Dialoge verwenden.
 *
 *
 * Rckgabe:  -1   Der Cursor soll im Feld bleiben
 *             0   Cursor wurde mittels SetEditField schon gesetzt
 *             1   ok. Weitermachen!
 * ------------------------------------------------------------------- */

LOCAL INT check_range ( OBJECT *tree, INT ed, LONG id )

{
  BYTE  s [100];
  INT   i;

  if ( tree == rsc_edit )
    {
      if ( ed > 0 )
        {
          GetText ( rsc_edit, ed, s );
          i = atoi ( s );
          switch ( ed )
            {
              case SE_Z50_100 : if (( i < 50 ) || ( i > 100 ))
                                  {
                                    Alert ( ALERT_NORM, 1, "[1][ Die Zahl soll zwischen | 50..100 liegen! ][ [Nochmal ]" );
                                    return ( -1 );
                                  }
                                break;
              case SE_Z90_200 : if (( i < 90 ) || ( i > 200 ))
                                  {
                                    Alert ( ALERT_NORM, 1, "[1][ Die Zahl soll zwischen | 90..200 liegen! ][ [Nochmal ]" );
                                    return ( -1 );
                                  }
                                break;
              case SE_Z99_101 : if (( i < 99 ) || ( i > 101 ))
                                  {
                                    Alert ( ALERT_NORM, 1, "[1][ Die Zahl soll zwischen | 99..101 liegen! ][ [Nochmal ]" );
                                    return ( -1 );
                                  }
                                break;
            }
        }
    }
  return ( 1 );
}

/* -------------------------------------------------------------------
 * Behandelt alle Aktionen w„rend einem Dialog.
 *
 * SG_NOWIN     Kein Fenster mehr da. SG_CONT bedeutet, als Dialog
 *              darstellen --> ist wichtig!
 *
 * SG_START     Der Dialog wird gleich gezeichnet. Hier ist Zeit fr
 *              eine eventuelle Initialisierung des Dialogs, Buttons,
 *              Editfelder etc...
 *
 * SG_END       Dialog soll geschlossen werden. button enth„lt das
 *              Objekt, den der Benutzer gew„hlt hat.
 *
 * SG_QUIT      wird nach dem Schliessen aufgerufen. Evtl. Speicher
 *              sollte hier freigegeben werden.
 *
 * SG_DRAGDROP  Der User hat Objekte auf das Fenster gezogen. Ob Sie die
 *              Nachricht auswerten oder nicht, liegt allein bei Ihnen.
 * ------------------------------------------------------------------- */

LOCAL INT handle_edit ( INT msg, INT button, DIALOG_INFO *inf )

{
  switch ( msg )
    {
      case SG_NOWIN       : return (( no_window_left ()));
      case SG_START       : ClearEditFields ( rsc_edit );
                            SetReturn ( TRUE );
                            SetFieldProc ( check_range );
                            SetText ( rsc_edit, SE_Z50_100, "20"  );
                            SetText ( rsc_edit, SE_Z90_200, "100" );
                            SetText ( rsc_edit, SE_Z99_101, "100" );
                            break;
      case SG_END         : switch ( button )
                              {
                                case SE_CLR : ClearEditFields ( rsc_edit );
                                              SetEditField ( rsc_edit, SE_Z50_100 );
                                              SetText ( rsc_edit, SE_Z50_100, "20"  );
                                              SetText ( rsc_edit, SE_Z90_200, "100" );
                                              SetText ( rsc_edit, SE_Z99_101, "100" );
                                              return ( SG_REDRAW );
                                default     : return ( SG_CLOSE );
                              }
      case SG_QUIT        : break;
      case SG_DRAGDROP    : Alert ( ALERT_NORM, 1, "[1][ Drag & Drop Aktionen | in dieses Fenster | sind nicht m”glich! ][ [Abbruch ]" );
                            break;
    }
  return ( SG_CONT );
}

/* -------------------------------------------------------------------
 * Verwaltet die Textfenster. Beim Klick ins Fenster k”nnen die Stati
 * der Zeile eingestellt werden (SG_.CLICK), oder beim Klick in die
 * Toolbar wird sortiert (SG_BUTTON).
 * ------------------------------------------------------------------- */

INT handle_text ( INT msg, WINDOW_INFO *inf )

{
  BYTE  s [200];

  switch ( msg )
    {
      case SG_END     : return ( SG_CLOSE );
      case SG_BUTTON  : if ( inf->obj_id == 'TOOL' )
                          {
                            switch ( inf->item )
                              {
                                case TO_SORT : switch ( Alert ( ALERT_NORM, 3, "[2][ Wie soll sortiert werden? ][ [Auf | A[b | [Nix ]" ))
                                                 {
                                                   case 1  : do_qsort ( inf->id, cmp_strings_up );
                                                             break;
                                                   case 2  : do_qsort ( inf->id, cmp_strings_dn );
                                                   default : break;
                                                 }
                                               break;
                                default      : break;
                              }
                          }
                        break;
      case SG_KEY     : switch ( inf->key )
                          {
                            case 0x4800 : ScrollWindow ( inf->handle, SCROLL_UP );
                                          break;
                            case 0x4b00 : ScrollWindow ( inf->handle, SCROLL_LEFT );
                                          break;
                            case 0x5000 : ScrollWindow ( inf->handle, SCROLL_DOWN );
                                          break;
                            case 0x4d00 : ScrollWindow ( inf->handle, SCROLL_RIGHT );
                                          break;
                            case 0x4838 : ScrollWindow ( inf->handle, SCROLL_PG_UP );
                                          break;
                            case 0x4b34 : ScrollWindow ( inf->handle, SCROLL_PG_LEFT );
                                          break;
                            case 0x5032 : ScrollWindow ( inf->handle, SCROLL_PG_DOWN );
                                          break;
                            case 0x4d36 : ScrollWindow ( inf->handle, SCROLL_PG_RIGHT );
                                          break;
                          }
                        break;
      case SG_LCLICK1 :
      case SG_LCLICK2 :
      case SG_RCLICK1 :
      case SG_RCLICK2 : if ( inf->line_ptr != NULL )
                          {
                            sprintf ( s, "[2][ Sie haben Zeile %ld, Spalte %ld angeklickt. | Darstellung „ndern: ][ [Fett | [Kursiv | [Unterst. | [Nix ]", inf->line, inf->column );
                            switch ( Alert ( ALERT_NORM, 4, s ))
                              {
                                case  1 : inf->line_ptr [0] |= 1;
                                          RedrawArea ( inf->handle, &inf->draw_area );
                                          break;
                                case  2 : inf->line_ptr [0] |= 4;
                                          RedrawArea ( inf->handle, &inf->draw_area );
                                          break;
                                case  3 : inf->line_ptr [0] |= 8;
                                          RedrawArea ( inf->handle, &inf->draw_area );
                                          break;
                                default : break;
                              }
                          }
                        break;
      case SG_DRAGDROP: LoadText ( inf->dd->data );
      default         : break;
    }
  return ( SG_CONT );
}

/* -------------------------------------------------------------------
 * L„dt eine Textdatei und stellt sie im Fenster dar. Die Fenster
 * werden von SysGem verwaltet. Wrde statt 'handle_text' NULL ber-
 * geben, wrde auf keine Nachricht reagiert, aužer auf das Schliežen
 * des Fensters.
 * ------------------------------------------------------------------- */

VOID LoadText ( BYTE *fname )

{
  UINT	i;

  if ( length ( fname ) > 4 )
    {
      ShowBee ();
      i = Display ( fname, fname, "", 255, win_id, 8, 90, 300, 200, handle_text );
      ShowArrow ();
      if ( i == 0 )
        {
          Alert ( ALERT_NORM, 1, "[1][ Die Datei konnte nicht | geladen werden! ][ [Abbruch ]" );
        }
      else
        {
          i = (UINT) SetWindowParm ( GetHandle ( win_id ), SET_W, -1L );
          SetWinMaxSize ( win_id, i, -1 );
          LinkTree ( win_id, rsc_tool, 'TOOL', LINK_TOP );
          win_id++;
        }
    }
}

/* ------------------------------------------------------------------- */

INT handle_main ( INT msg, INT button, DIALOG_INFO *inf )

{
  switch ( msg )
    {
      case SG_START    : LinkSlider ( rsc_main, MA_UP, MA_DN, MA_SHOW, MA_HIDE, 20, MA_BOX, &slid_txt [0][0], (INT) sizeof ( slid_txt [0] ), 0 );
                         break;
      case SG_END      : switch ( button )
                           {
                             case -1       : if ( Alert ( ALERT_NORM, 1, ASK_TERM ) == 2 ) return ( SG_TERM );
                                             break;
                             case MA_POP1  : xPopUp ( rsc_main, MA_POP1, rsc_pop, 0, &pop );
                                             RedrawObj ( rsc_main, MA_POP2, 0, NONE, UPD_STATE );
                                             break;
                             case MA_POP2  : Cycle ( rsc_main, MA_POP1, rsc_pop, SP_1, SP_16, &pop );
                                             RedrawObj ( rsc_main, MA_POP2, 0, NONE, UPD_STATE );
                                             break;
                             case MA_LIST1 :
                             case MA_LIST2 : Listbox ( " Weiž| Schwarz| Rot| Grn| Blau| Cyan| Gelb| Magenta| Hellgrau| Dunkelgrau| Hellrot| Hellgrn| Hellblau| Hellcyan| Hellgelb| Hellmagenta", 0, 0, rsc_main, MA_LIST1 );
                                             break;
                             case MA_SYS   : SysInfo ( 'SISI' ); break;
                             case MA_LAUF  : SysInfo ( 'SILI' ); break;
                             case MA_MEM   : SysInfo ( 'SIMI' ); break;
                             case MA_VEK   : SysInfo ( 'SIVI' ); break;
                             case MA_COOK  : SysInfo ( 'SICI' ); break;
                             case MA_XBRA  : SysInfo ( 'SIXI' ); break;
                             case MA_HD    : SysInfo ( 'SIHD' ); break;
                             case MA_GRAF  : SysInfo ( 'SIGI' ); break;
                             case MA_SGEM  : SysInfo ( 'SISG' ); break;
                             case MA_WRT   : SysInfo ( 'SIAG' ); break;
                             default       : break;
                           }
                         break;
      case SG_MENU     : switch ( button )
                           {
                             case M2_INFO : DoDialog ( rsc_info, 0, " Information " );
                                            break;
                             case M2_QUIT : if ( Alert ( ALERT_NORM, 1, ASK_TERM ) == 2 ) return ( SG_TERM );
                             default      : break;
                           }
                         break;
      case SG_KEY      : switch ( button )
                           {
                             case 0x4800 : ScrollSlider ( rsc_main, MA_BOX, SCROLL_UP );
                                           return ( SG_KEYUSED );
                             case 0x5000 : ScrollSlider ( rsc_main, MA_BOX, SCROLL_DOWN );
                                           return ( SG_KEYUSED );
                             default     : break;
                           }
                         return ( SG_KEYCONT );
      case SG_DRAGDROP : LoadText ( inf->dd->data );
                         break;
      case SG_QUIT     : break;
    }
  return ( SG_CONT );
}

/* -------------------------------------------------------------------
 * Behandelt die Desktop-Menzeile
 * ------------------------------------------------------------------- */

INT handle_menu ( INT msg, WINDOW_INFO *inf )

{
  if ( msg == SG_MENU )
    {
      switch ( inf->mItem )
        {
          case ME_INFO : DoDialog ( rsc_info, 0, "| Information " );
                         break;
          case ME_QUIT : if ( Alert ( ALERT_NORM, 1, ASK_TERM ) == 2 ) return ( SG_TERM );
                         break;
          case ME_EDIT : WindowDialog ( 'EDIT', -1, -1, " Edit-Felder ", "", TRUE, FALSE, rsc_edit, NULL, SE_Z50_100, NULL, handle_edit );
        }
    }
  return ( SG_CONT );
}

/* ------------------------------------------------------------------- */

VOID first_info ( VOID )

{
  if ( OpenLogWindow ( 'SGEM', " SysGem-Information ", "", 61, 15, 8, 20, (APROC) NULL ))
    {
      wprintf ( 'SGEM', "Willkommen bei \033pSysGem\033q V%x.%x\n\n", (INT)( SYSGEM_VERSION >> 8 ), (INT)((BYTE) SYSGEM_VERSION ));
      wprintf ( 'SGEM', "Mit \033pSysGem\033q wird das Erstellen von GEM-Programmen zum Kinder-\n" );
      wprintf ( 'SGEM', "spiel! (Text-)Fenster und Fensterdialoge werden komplett\n" );
      wprintf ( 'SGEM', "von \033pSysGem\033q verwaltet, so daž \033+Sie\033- sich in Ruhe um\n" );
      wprintf ( 'SGEM', "die wichtigeren Dinge kmmern k”nnen.\n" );
      wprintf ( 'SGEM', "\033pSysGem\033q bernimmt z.B. auch die Verwaltung der \033+Iconifizierung\n" );
      wprintf ( 'SGEM', "(ICFS/MTos)\033- und des \033+Drag & Drop (unter Gemini/MTos)\033-. Pro-\n" );
      wprintf ( 'SGEM', "bieren Sie es doch einfach mal mit diesem Demo aus!\n\n" );
      wprintf ( 'SGEM', "Schauen Sie sich doch danach einfach mal die Quelle an,\n" );
      wprintf ( 'SGEM', "Sie werden berrascht sein, wie einfach und schnell es\n" );
      wprintf ( 'SGEM', "gehen kann...\n\n" );
      wprintf ( 'SGEM', "\033(Schliež mich...\033)" );
    }
}

/* ------------------------------------------------------------------- */

INT main ( VOID )

{
  INT   i;

  if ( Init_GEM ( &par, ACC_NAME, PRG_ID, PRG_NAME, USR_ID, USR_NAME, USR_KEY ) > 0 )
    {

      /* --------------------------------------------------------------
       * Initialisiert die Resource
       * -------------------------------------------------------------- */

      for ( i = 0; i < NUM_OBS; i++ ) rsrc_obfix ( &rs_object [i], 0 );

      /* --------------------------------------------------------------
       * šberschrift fr die Alertbox
       * -------------------------------------------------------------- */

      SetAlertTitle ( "| SysGem-Demo " );

      /* --------------------------------------------------------------
       * Dialoge anmelden
       * -------------------------------------------------------------- */

      NewDialog ( rsc_main );
      NewDialog ( rsc_info );
      NewDialog ( rsc_bits );
      NewDialog ( rsc_tool );
      NewDialog ( rsc_edit );

      /* --------------------------------------------------------------
       * Die Texte fr die Sliderbox in Buffer schreiben
       * -------------------------------------------------------------- */

      for ( i = 0; i < 20; i++ )
        {
          sprintf ( slid_txt [i], " Dieses ist die Textzeile Nr %2d ", i + 1 );
        }

      /* --------------------------------------------------------------
       * Nachrichten-Funktion anmelden
       * -------------------------------------------------------------- */

      SetMessageProc ( GetMessage );

      /* --------------------------------------------------------------
       * Menzeile anmelden
       * -------------------------------------------------------------- */

      SetDeskTopMenu ( rsc_menu, handle_menu );

      /* --------------------------------------------------------------
       * Zeituhr starten
       * -------------------------------------------------------------- */

      WindowDialog ( 'ZEIT', 8, 0, "| Zeit ", "", TRUE, FALSE, rsc_bits, NULL, 0, NULL, handle_bits );

      /* --------------------------------------------------------------
       * Hauptfenster ”ffnen
       * -------------------------------------------------------------- */

      WindowDialog ( 'MAIN', -1, -1, " SysGem-Demo ", "", TRUE, FALSE, rsc_main, NULL, 0, NULL, handle_main );

      /* --------------------------------------------------------------
       * Text laden und anzeigen
       * -------------------------------------------------------------- */

      LoadText ( "DEMO.H" );

      /* --------------------------------------------------------------
       * Tastendrcke an die Dialoge leiten...
       * -------------------------------------------------------------- */

      TellKeyStrokes ( TRUE );

      /* --------------------------------------------------------------
       * Info vom Demo anzeigen
       * -------------------------------------------------------------- */

      first_info ();

      /* --------------------------------------------------------------
       * Kontrolle an SysGem abgeben
       * -------------------------------------------------------------- */

      HandleSysGem ();

      /* --------------------------------------------------------------
       * Programm abmelden und Speicher freigeben
       * -------------------------------------------------------------- */

      Exit_GEM ();
    }
  return ( 0 );
}

/* ------------------------------------------------------------------- */
