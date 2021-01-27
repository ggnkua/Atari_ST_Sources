/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        <sys_mod2.h>

/* ------------------------------------------------------------------- */

FUNCTIONS       *fkt;

/* ------------------------------------------------------------------- */

LONG    win_id     = 'slog';

/* ------------------------------------------------------------------- */

BYTE    m_name  [] = "@(#) Testmodul fr SysGem / V1.00";
BYTE    m_copy  [] = "1995 by Andreas Pietsch";

/* ------------------------------------------------------------------- */

INT HandleLogWindow ( INT msg, WINDOW_INFO *inf )

{
  BYTE  c;

  switch ( msg )
    {
      case SG_LCLICK1   : c = wgetchar ( win_id, (INT)( inf->line ), (INT)( inf->column ), NULL );
                          wprintf ( win_id, "An der Position (%2ld, %ld) ist das Zeichen: \'%c\'\n", inf->line, inf->column, c );
                          break;
      case SG_LCLICK2   :
      case SG_RCLICK1   :
      case SG_RCLICK2   : Alert ( ALERT_NORM, 1, "[1][ Dieser Mausklick hat | keine Bedeutung! ][ [Ach so... ]" );
                          break;
      case SG_END       : return ( SG_CLOSE );
      default           : break;
    }
  return ( SG_CONT );
}

/* ------------------------------------------------------------------- */

VOID MakeWindow ( VOID )

{
  OpenLogWindow ( win_id, "|Modul-Fensterli", "", 48, 10, 10, 10, HandleLogWindow );
  wprintf ( win_id, "Ich bin das Modul:\n%s\n%s\n\n", &m_name [5], m_copy );
}

/* ------------------------------------------------------------------- */

LONG ModuleMain ( INT msg, INT user, VOID *p )

{
  IDENTIFY      *ident;

  switch ( msg )
    {
      case SGM_IDENTIFY : ident = (IDENTIFY *) p;
                          ident->name   = &m_name [5];
                          ident->author = m_copy;
                          break;
      case SGM_INIT     : fkt = (FUNCTIONS *) p;
                          break;
      case SGM_START    : MakeWindow ();
                          break;
      case SGM_QUIT     : CloseWindowById ( win_id );
                          break;
      case SGM_USER     : switch ( user )
                            {
                              default : break;
                            }
                          break;
    }
  return ( 0L );
}

/* ------------------------------------------------------------------- */
