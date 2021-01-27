/* -------------------------------------------------------------------- *
 * Module Version       : 2.00                                          *
 * Author               : Gerhard Stoll                                 *
 * Programming Language : Pure-C                                        *
 * Copyright            : (c) 1999, Gerhard Stoll, 67547 Worms          *
 * -------------------------------------------------------------------- */

#include  "kernel.h"
#include  <tos.h>
#include	<string.h>



/* -------------------------------------------------------------------- */

EXTERN	SYSGEM 	sysgem;

/* -------------------------------------------------------------------- */

LOCAL PRN_DIALOG *prn_dialog;
LOCAL WORD prn_hndl;

/* -------------------------------------------------------------------- */
/*  

/* -------------------------------------------------------------------- */
/*    WDialog Druckdialog                                              	*/
/* -------------------------------------------------------------------- */

WORD DoPrinterDialog( PRN_SETTINGS *settings, BYTE *document_name, WORD Dialog_flags )
{
	INT dummy;
	
	if ( !sysgem.wdialog )									/* Kein WDialog vorhanden			*/
		return FALSE;

	if ( gprn_dialog )											/* Dialog bereits ge”ffnet? 	*/
	{
		wind_set( prn_hndl, WF_TOP, 0, 0, 0, 0 );		/* Fenster nach vorne bringen */
		return TRUE;
	}
	else
	{
		prn_dialog = pdlg_create( PDLG_3D );
		if( prn_dialog )
		{
			prn_hndl = pdlg_open( prn_dialog, settings, document_name, Dialog_flags, gprn_x, gprn_y );
			if( prn_hndl==0)
			{
				pdlg_delete( prn_dialog );				/* Speicher freigeben 				*/
				return FALSE;
			}
			else
			{
	  		sysgem.wdialog=TRUE;
  	  	MenuLock ();
    		do 
    		{
	    		HandleEvents ();
  	    } while( pdlg_exit );
				pdlg_close( prn_dialog, &dummy, &dummy );
				pdlg_delete( prn_dialog );
 				MenuUnlock ();
  			sysgem.wdialog=FALSE;
			}
		}
		else
			return FALSE;
	}
	return TRUE;
}
/*
   .                       pdlg_create()
   .
   .
   .
Aufruf des Druckdialogs:   pdlg_open()
   .
   .
   .
Event-Loop:                pdlg_evnt()
   .                             .
   .                             .
   .                             .
   .                             .
Schliežen des Druckdialogs: pdlg_close()
   .
   .
   .
   .                       pdlg_delete()
*/

/* ------------------------------------------------------------------- */

VOID HandlePdlg ( EVENT *evt )
{
	INT i;
	EVNT events;
	
	events.mwhich=evt->ev_mwich;
	events.mx=evt->ev_mmox;
	events.my=evt->ev_mmoy;
	events.mbutton=evt->ev_mmobutton;
	events.kstate=evt->ev_mmokstate;
	events.key=evt->ev_mkreturn;
	events.mclicks=evt->ev_mbreturn;
	for( i = 0; i < 8 ; i++)
		events.msg[i]=evt->ev_mmgpbuf[i];
	pdlg_exit=pdlg_evnt(prn_dialog,settings,&events,&button);
	evt->ev_mwich=events.mwhich;
	evt->ev_mmox=events.mx;
	evt->ev_mmoy=events.my;
	evt->ev_mmobutton=events.mbutton;
	evt->ev_mmokstate=events.kstate;
	evt->ev_mkreturn=events.key;
	evt->ev_mbreturn=events.mclicks;
	for( i = 0; i < 8 ; i++)
		evt->ev_mmgpbuf[i]=events.msg[i];
}
