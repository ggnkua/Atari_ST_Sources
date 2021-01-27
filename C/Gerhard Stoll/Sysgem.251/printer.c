/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include	"kernel.h"
#include  "sgem.h"
#include	<string.h>
#include	<stdlib.h>

/* ------------------------------------------------------------------- */

EXTERN	SYSGEM	sysgem;

/* ------------------------------------------------------------------- */

LOCAL	BYTE	dev_tab		[20][48];
LOCAL	LONG	result_id	= 0L;
LOCAL	INT	result_bt	= 0;
LOCAL	INT	result_dv	= 0;
LOCAL	INT	anz_dev		= 0;

/* ------------------------------------------------------------------- */

#define         rsc_main        sysgem.cycle_win

/* ------------------------------------------------------------------- */

LOCAL INT sgem_hdl_device ( INT msg, INT button, DIALOG_INFO *inf )

{
  switch ( msg )
    {
      case SG_START  : LinkSlider    ( rsc_main, CY_UP, CY_DN, CY_SHOW, CY_HIDE, anz_dev, CY_BOX, &dev_tab [0][0], 48, FALSE );
                       SelectSldItem ( rsc_main, CY_BOX, result_dv, FALSE );
                       break;
      case SG_SLIDER : if (( button >= 0 ) && ( button != result_dv ))
                         {
                           result_dv = button;
                           SelectSldItem ( rsc_main, CY_BOX, result_dv, TRUE );
                         }
                       break;
      case SG_QUIT   : UnLinkSlider  ( rsc_main, CY_BOX );
                       break;
      case SG_END    : result_id = inf->id;
                       result_bt = button;
                       break;
    }
  return ( SG_CONT );
}

/* ------------------------------------------------------------------- */

LOCAL BOOL BeginDevice ( LONG win_id, OBJECT *tree, INT edit, BYTE *title )

{
  return ( WindowDialog ( win_id, -1, -1, title, "", FALSE, TRUE, tree, NULL, edit, NULL, sgem_hdl_device ));
}

/* ------------------------------------------------------------------- */

LOCAL INT HandleDevice ( LONG win_id )

{
  if ( find_window ( -1, win_id ) == NULL ) return ( -1 );
  forever
    {
      result_id = 0L;
      result_bt = 0;

      HandleEvents ();

      if ( result_id == win_id )
        {
          return ( result_bt );
        }
    }
}

/* ------------------------------------------------------------------- */

LOCAL VOID FinishDevice ( LONG win_id )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      DestroyWindow ( win, TRUE );
    }
}

/* ------------------------------------------------------------------- */

INT SelectPrinter ( VOID )

{
  INT		i;
  INT		open;
  BYTE		s [100];

  anz_dev	= 0;
  result_dv	= 0;
  result_id	= 0L;
  result_bt	= 0;
  
  memset ( &dev_tab, 0, sizeof ( dev_tab ));  
  if ( ! vq_gdos ()) return ( -1 );
  
  for ( i = 21; i < 100; i++ )
    {
      VqtDevice ( i, &open, s );
      if ( length ( s ) > 0 )
        {
          sprintf ( dev_tab [anz_dev], " %2d  %-36.36s ", i, s );
          anz_dev++;
        }
      memset ( s, 0, sizeof ( s ));  
    }
  
  if ( anz_dev == 0 ) return ( -1 );
  
  if ( sysgem.english )
    {
      ChangeButton ( rsc_main, CY_ABORT, "[Abort" );
    }
  else
    {
      ChangeButton ( rsc_main, CY_ABORT, "[Abbruch" );
    }
  if ( BeginDevice ( 'xdeV', rsc_main, 0, (( sysgem.english != FALSE ) ? "Select Device" : "|Ger„teauswahl:" )))
    {
      i = HandleDevice ( 'xdeV' );
      FinishDevice ( 'xdeV' );
      if ( i == CY_OK )
        {
          dev_tab [result_dv][3] = 0;
          return ( atoi ( &dev_tab [result_dv][1] ));
        }
    }
  return ( -1 );
}

/* ------------------------------------------------------------------- */

