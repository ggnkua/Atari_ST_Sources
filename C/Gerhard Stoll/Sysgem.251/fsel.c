/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include  "kernel.h"
#include  <tos.h>															/* [GS]	*/
#include	<string.h>

LOCAL INT magic_fslx( BYTE *title, BYTE *suffix);			/* [GS] */


/* ------------------------------------------------------------------- */

EXTERN	SYSGEM 	sysgem;
/* ------------------------------------------------------------------- */

#define FS_SEL 30															/* [GS] */
#define FS_PATH 130														/* [GS] */

LOCAL	BYTE fs_sel	[FS_SEL];										/* [GS] */
LOCAL	BYTE fs_path	[FS_PATH];                /* [GS]	*/
LOCAL BYTE *pattern;													/* [GS] */
LOCAL INT fslx_exit;													/* [GS] */
LOCAL VOID *fsel;															/* [GS] */
LOCAL INT button, nfiles, sort_mode;					/* [GS] */

/* --------------------------------------------------------------------- */
/*    GEM Dateiselektor                                                  */
/* --------------------------------------------------------------------- */

WORD FileSelect( BYTE *name, BYTE *path, BYTE *suffix, BYTE *label, BYTE *filename )
{
	BOOL selectric;															 /* [GS]									 */
	BYTE *b,s[82];
	WORD magic;																	 /* [GS] 									 */
	WORD fs_button=0;                            /* Lokale Variablen       */
	LONG Cookie_Wert;														 /* [GS]									 */

	/* ------------------------------------------------------------------- */

	strcpy( fs_sel,name );                       /* Name vorbelegen        */
  strcpy( fs_path,path );                      /* Pfad vorbelegen        */

/* [GS]
  b = strrchr( fs_path,'\\' );              	 /* Letzter Backslash      */
 	if( b != NULL) b[1] = 0;                   	 /* Suffix l”schen         */
*/
	if(fs_path[strlen(fs_path)-1]!='\\')				 /* [GS] 									 */
		strcat(fs_path,"\\");											 /* [GS]									 */

/* 	strcat( fs_path,suffix );                    /* Neuer Suffix           */    [GS] */

	/* ------------------------------------------------------------------- */
	
	magic=0;																		 /* [GS]									 */
	selectric=GetCookie( 'FSEL',&Cookie_Wert );	 /* [GS] 									 */

	if( !selectric )														 /* [GS]                   */
		magic=magic_fslx ( label,suffix );		 		 /* [GS] 									 */
	if ( !magic )																 /* [GS]									 */
	{
	  if( sysgem.tos_version >= 0x104U || selectric )    /* [GS]           */
    {
   		if( !fsel_exinput( fs_path,fs_sel,&fs_button,label ) ) return( FALSE );
  	}
  	else
		{
   		if( !fsel_input( fs_path,fs_sel,&fs_button ) ) return( FALSE );
		}
	}
	else
		fs_button=button;													 /* [GS]									 */

	/* ------------------------------------------------------------------- */

  	strcpy( s,fs_path );                         /* Pfad aufbereiten       */
  	b = strrchr( s,'\\' );
  	if( b != NULL ) b[1] = 0;

	/* ------------------------------------------------------------------- */

  	if( *fs_sel )                                /* Dateinamen gew„hlt     */
  	{
   		strcpy( filename,s );
    	strcat( filename,fs_sel );
   		if( name != NULL ) strcpy( name,fs_sel ); 
  	}
  	else filename[0] = 0;                      /* Keinen Dateinamen      */

	/* ------------------------------------------------------------------- */

  	if( fs_button != 0 )
  	{
   	if( (path != NULL) && (*path) )  
      	strcpy( path,s );

   	if( (name != NULL) && (*name) && (*fs_sel) )
      	strcpy( name,fs_sel );
  	}

	/* ------------------------------------------------------------------- */

  	return(fs_button != 0);       /* Dateiname + OK gew„hlt */
}

/* ---------------------------------------------------------------------- */
/* Alles folgende [GS]																										*/

INT magic_fslx( BYTE *title, BYTE *suffix )
{
	INT whdl;
  INT x0, y0;
	INT ap_gout1,ap_gout2,ap_gout3,ap_gout4;
	
	if ( sysgem.param.agi == AGI_4 && sysgem.magx_version >= 0x0500 )
		{
			if( appl_getinfo ( 7, &ap_gout1, &ap_gout2, &ap_gout3, &ap_gout4) )
				{
					if( (ap_gout1 & 8) == 0)		/* MagiC Dateiauswahl nicht vorhanden		*/
						return FALSE;
				}
		}
	else
		{
			return FALSE;
		}

  if ( sysgem.center == FALSE )
    {
      MouseClicked ( &x0, &y0 );
      x0 = x0 - 50;					/*  einfach irgend etwas angenommen	*/
      y0 = y0 - 50;
    }
  else
  	{
  		x0=-1;
  		y0=-1;
  	}
	
	fsel = fslx_open(title, x0, y0, &whdl, fs_path, FS_PATH, fs_sel,
                   FS_SEL, suffix,
                   0L, 												/* keine Filter							*/
             		   NULL, SORTBYNAME,0);

  if( fsel )
  	{
  		sysgem.fslx=TRUE;
    	MenuLock ();
    	do 
    	{
    		HandleEvents ();
      } while( fslx_exit );
			fslx_close( fsel );
 			MenuUnlock ();
  		sysgem.fslx=FALSE;
			return TRUE;
  	}
	return FALSE;  	
}

/* ---------------------------------------------------------------------- */

VOID HandleFslx ( EVENT *evt )
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
	fslx_exit=fslx_evnt(fsel,&events, fs_path, fs_sel,
                   &button, &nfiles, &sort_mode,&pattern);
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
