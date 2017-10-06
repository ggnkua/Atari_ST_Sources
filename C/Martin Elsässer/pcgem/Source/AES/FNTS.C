/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - FNTS-Bibliothek													*/
/*																										*/
/*	(c) 1998-2000 by Martin ElsÑsser															*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	#include <AES.H>
#else
	#include <ACSAES.H>
#endif
#include <String.H>

/******************************************************************************/
/*																										*/
/* Lokale Datentypen																				*/
/*																										*/
/******************************************************************************/

typedef struct
{
	INT16 contrl[5];
	GLOBAL *globl;
	INT16 intin[16];
	INT16 intout[7];
	void *addrin[5];
	void *addrout[1];
} AESData;

/******************************************************************************/
/*																										*/
/* AES 185:	fnts_add																				*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fnts_add( const FNT_DIALOG *fnt_dialog, const FNTS_ITEM *user_fonts )
#else
	INT16 fnts_add( GLOBAL *globl, const FNT_DIALOG *fnt_dialog, const FNTS_ITEM *user_fonts )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{185, 1, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=fnt_dialog;
	data.addrin[1]=user_fonts;
	
	data.intin[0]=0;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 183:	fnts_close																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fnts_close( const FNT_DIALOG *fnt_dialog, INT16 *x, INT16 *y )
#else
	INT16 fnts_close( GLOBAL *globl, const FNT_DIALOG *fnt_dialog, INT16 *x, INT16 *y )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{183, 0, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=fnt_dialog;
	
	/* Wegen alten WDIALOG-Versionen vorbeugen */
	data.intout[1]=-1;
	data.intout[2]=-1;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die erhaltenen Werte speichern */
	if( x!=NULL )
		*x=data.intout[1];
	if( y!=NULL )
		*y=data.intout[2];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 180:	fnts_create																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	FNT_DIALOG *fnts_create( const INT16 vdi_handle, const INT16 no_fonts,
						const INT16 font_flags, const INT16 dialog_flags,
						const CHAR *sample, const CHAR *opt_button )
#else
	FNT_DIALOG *fnts_create( GLOBAL *globl, const INT16 vdi_handle, const INT16 no_fonts,
						const INT16 font_flags, const INT16 dialog_flags,
						const CHAR *sample, const CHAR *opt_button )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{180, 0, 4, 2, 1}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=sample;
	data.addrin[1]=opt_button;
	
	data.intin[0]=vdi_handle;
	data.intin[1]=no_fonts;
	data.intin[2]=font_flags;
	data.intin[3]=dialog_flags;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 181:	fnts_delete																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fnts_delete( const FNT_DIALOG *fnt_dialog, const INT16 vdi_handle )
#else
	INT16 fnts_delete( GLOBAL *globl, const FNT_DIALOG *fnt_dialog, const INT16 vdi_handle )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{181, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=fnt_dialog;
	
	data.intin[0]=vdi_handle;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 187:	fnts_do																				*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fnts_do( FNT_DIALOG *fnt_dialog, const INT16 button_flags, const INT32 id_in,
						const INT32 pt_in, const INT32 ratio_in, INT16 *check_boxes, 
						INT32 *id, fix31 *pt, INT32 *ratio )
#else
	INT16 fnts_do( GLOBAL *globl, FNT_DIALOG *fnt_dialog, const INT16 button_flags,
						const INT32 id_in, const INT32 pt_in, const INT32 ratio_in,
						INT16 *check_boxes, INT32 *id, fix31 *pt, INT32 *ratio )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{187, 7, 8, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=fnt_dialog;
	
	data.intin[0]=button_flags;
	*(INT32 *)&data.intin[1]=id_in;
	*(INT32 *)&data.intin[3]=pt_in;
	*(INT32 *)&data.intin[5]=ratio_in;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die RÅkgabewerte eintragen */
	if( check_boxes!=NULL )
		*check_boxes=data.intout[1];
	if( id!=NULL )
		*id=*(INT32 *)&data.intout[2];
	if( pt!=NULL )
		*pt=*(INT32 *)&data.intout[4];
	if( ratio!=NULL )
		*ratio=*(INT32 *)&data.intout[6];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 186:	fnts_evnt																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fnts_evnt( FNT_DIALOG *fnt_dialog, EVNT *events, INT16 *button,
						INT16 *check_boxes, INT32 *id, fix31 *pt, fix31 *ratio )
#else
	INT16 fnts_evnt( GLOBAL *globl, FNT_DIALOG *fnt_dialog, EVNT *events, INT16 *button,
						INT16 *check_boxes, INT32 *id, fix31 *pt, fix31 *ratio )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{186, 0, 9, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=fnt_dialog;
	data.addrin[1]=events;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die RÅkgabewerte eintragen */
	if( button!=NULL )
		*button=data.intout[1];
	if( check_boxes!=NULL )
		*check_boxes=data.intout[2];
	if( id!=NULL )
		*id=*(INT32 *)&data.intout[3];
	if( pt!=NULL )
		*pt=*(fix31 *)&data.intout[5];
	if( ratio!=NULL )
		*ratio=*(fix31 *)&data.intout[7];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 184:	fnts_get_info																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fnts_get_info( FNT_DIALOG *fnt_dialog, const INT32 id, INT16 *mono,
						INT16  *outline )
#else
	INT16 fnts_get_info( GLOBAL *globl, FNT_DIALOG *fnt_dialog, const INT32 id, INT16 *mono,
						INT16  *outline )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{184, 3, 3, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=fnt_dialog;
	
	data.intin[0]=3;
	*(INT32 *)&data.intin[0]=id;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die RÅkgabewerte eintragen */
	if( mono!=NULL )
		*mono=data.intout[1];
	if( outline!=NULL )
		*outline=data.intout[2];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 184:	fnts_get_name																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fnts_get_name( FNT_DIALOG *fnt_dialog, const INT32 id, CHAR *full_name,
						CHAR *family_name, CHAR *style_name )
#else
	INT16 fnts_get_name( GLOBAL *globl, FNT_DIALOG *fnt_dialog, const INT32 id,
						CHAR *full_name, CHAR *family_name, CHAR *style_name )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{184, 3, 1, 4, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=fnt_dialog;
	data.addrin[1]=full_name;
	data.addrin[2]=family_name;
	data.addrin[3]=style_name;
	
	data.intin[0]=2;
	*(INT32 *)&data.intin[0]=id;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 184:	fnts_get_no_styles																*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fnts_get_no_styles( FNT_DIALOG *fnt_dialog, const INT32 id )
#else
	INT16 fnts_get_no_styles( GLOBAL *globl, FNT_DIALOG *fnt_dialog, const INT32 id )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{184, 3, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=fnt_dialog;
	
	data.intin[0]=0;
	*(INT32 *)&data.intin[0]=id;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 184:	fnts_get_style																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT32 fnts_get_style( FNT_DIALOG *fnt_dialog, const INT32 id, const INT16 index )
#else
	INT32 fnts_get_style( GLOBAL *globl, FNT_DIALOG *fnt_dialog,
						const INT32 id, const INT16 index )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{184, 4, 2, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=fnt_dialog;
	
	data.intin[0]=1;
	*(INT32 *)&data.intin[0]=id;
	data.intin[3]=index;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return *(INT32 *)&data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 182:	fnts_open																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fnts_open( FNT_DIALOG *fnt_dialog, const INT16 button_flags, const INT16 x,
						const INT16 y, const INT32 id, const fix31 pt, const fix31 ratio )
#else
	INT16 fnts_open( GLOBAL *globl, FNT_DIALOG *fnt_dialog, const INT16 button_flags,
						const INT16 x, const INT16 y, const INT32 id, const fix31 pt,
						const fix31 ratio )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{182, 9, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=fnt_dialog;
	
	data.intin[0]=button_flags;
	data.intin[1]=x;
	data.intin[2]=y;
	*(INT32 *)&data.intin[3]=id;
	*(fix31 *)&data.intin[5]=pt;
	*(fix31 *)&data.intin[7]=ratio;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 185:	fnts_remove																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	void fnts_remove( FNT_DIALOG *fnt_dialog )
#else
	void fnts_remove( GLOBAL *globl, FNT_DIALOG *fnt_dialog )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{185, 1, 0, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=fnt_dialog;
	
	data.intin[0]=1;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 185:	fnts_update																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fnts_update( FNT_DIALOG *fnt_dialog, const INT16 button_flags,
						const INT32 id, const fix31 pt, const INT32 ratio )
#else
	INT16 fnts_update( GLOBAL *globl, FNT_DIALOG *fnt_dialog, const INT16 button_flags,
						const INT32 id, const fix31 pt, const INT32 ratio )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{185, 1, 0, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=fnt_dialog;
	
	data.intin[0]=2;
	data.intin[1]=button_flags;
	*(INT32 *)&data.intin[2]=id;
	*(INT32 *)&data.intin[4]=pt;
	*(INT32 *)&data.intin[6]=ratio;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}
