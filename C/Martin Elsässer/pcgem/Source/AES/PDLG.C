/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - PDLG-Bibliothek													*/
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
/* AES 205:	pdlg_add_printers																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 pdlg_add_printers( PRN_DIALOG *prn_dialog, DRV_INFO *drv_info )
#else
	INT16 pdlg_add_printers( GLOBAL *globl, PRN_DIALOG *prn_dialog, DRV_INFO *drv_info )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{205, 1, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=prn_dialog;
	data.addrin[1]=drv_info;
	
	data.intin[0]=0;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_add_sub_dialogs																*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 pdlg_add_sub_dialogs( PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialog )
#else
	INT16 pdlg_add_sub_dialogs( GLOBAL *globl, PRN_DIALOG *prn_dialog,
					PDLG_SUB *sub_dialog )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{205, 1, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=prn_dialog;
	data.addrin[1]=sub_dialog;
	
	data.intin[0]=3;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 203:	pdlg_close																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 pdlg_close( PRN_DIALOG *prn_dialog, INT16 *x, INT16 *y )
#else
	INT16 pdlg_close( GLOBAL *globl, PRN_DIALOG *prn_dialog, INT16 *x, INT16 *y )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{203, 0, 3, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=prn_dialog;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	if( x!=NULL )
		*x=data.intout[1];
	if( y!=NULL )
		*y=data.intout[2];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 200:	pdlg_close																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	PRN_DIALOG *pdlg_create ( INT16 dialog_flags )
#else
	PRN_DIALOG *pdlg_create ( GLOBAL *globl, INT16 dialog_flags )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{200, 1, 0, 0, 1}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.intin[0]=dialog_flags;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 201:	pdlg_delete																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 pdlg_delete( PRN_DIALOG *prn_dialog )
#else
	INT16 pdlg_delete( GLOBAL *globl, PRN_DIALOG *prn_dialog )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{201, 0, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=prn_dialog;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_dflt_settings																*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 pdlg_dflt_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings )
#else
	INT16 pdlg_dflt_settings( GLOBAL *globl, PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{205, 1, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=prn_dialog;
	data.addrin[1]=settings;
	
	data.intin[0]=7;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 207:	pdlg_do																				*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 pdlg_do( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
						CHAR *document_name, const INT16 option_flags )
#else
	INT16 pdlg_do( GLOBAL *globl, PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
						CHAR *document_name, const INT16 option_flags )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{207, 1, 1, 3, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=prn_dialog;
	data.addrin[1]=settings;
	data.addrin[2]=document_name;
	
	data.intin[0]=option_flags;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 206:	pdlg_evnt																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 pdlg_evnt( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
						EVNT *evnt, INT16 *button )
#else
	INT16 pdlg_evnt( GLOBAL *globl, PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
						EVNT *evnt, INT16 *button )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{206, 0, 2, 3, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=prn_dialog;
	data.addrin[1]=settings;
	data.addrin[2]=evnt;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* RÅckgabewert */
	if( button!=NULL )
		*button = data.intout[1];
		
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_free_settings																*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 pdlg_free_settings( PRN_SETTINGS *settings )
#else
	INT16 pdlg_free_settings( GLOBAL *globl, PRN_SETTINGS *settings )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{205, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=settings;
	
	data.intin[0]=6;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 204:	pdlg_get_setsize																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT32 pdlg_get_setsize( void )
#else
	INT32 pdlg_get_setsize( GLOBAL *globl )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{204, 1, 2, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.intin[0]=0;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return *(INT32 *)&data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_new_settings																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	PRN_SETTINGS *pdlg_new_settings( PRN_DIALOG *prn_dialog )
#else
	PRN_SETTINGS *pdlg_new_settings( GLOBAL *globl, PRN_DIALOG *prn_dialog )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{205, 1, 0, 1, 1}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=prn_dialog;
	
	data.intin[0]=5;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 202:	pdlg_new_settings																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 pdlg_open( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
						CHAR *document_name, const INT16 option_flags,
						const INT16 x, const INT16 y )
#else
	INT16 pdlg_open( GLOBAL *globl, PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
						CHAR *document_name, const INT16 option_flags,
						const INT16 x, const INT16 y )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{202, 3, 1, 3, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=prn_dialog;
	data.addrin[1]=settings;
	data.addrin[2]=document_name;
	
	data.intin[0]=option_flags;
	data.intin[1]=x;
	data.intin[2]=y;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_remove_printers																*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 pdlg_remove_printers( PRN_DIALOG *prn_dialog )
#else
	INT16 pdlg_remove_printers( GLOBAL *globl, PRN_DIALOG *prn_dialog )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{205, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=prn_dialog;
	
	data.intin[0]=1;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_remove_sub_dialogs															*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 pdlg_remove_sub_dialogs( PRN_DIALOG *prn_dialog )
#else
	INT16 pdlg_remove_sub_dialogs( GLOBAL *globl, PRN_DIALOG *prn_dialog )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{205, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=prn_dialog;
	
	data.intin[0]=4;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_update																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 pdlg_update( PRN_DIALOG *prn_dialog, CHAR *document_name )
#else
	INT16 pdlg_update( GLOBAL *globl, PRN_DIALOG *prn_dialog, CHAR *document_name )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{205, 1, 1, 3, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=prn_dialog;
	data.addrin[1]=0;
	data.addrin[2]=document_name;
	
	data.intin[0]=2;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_use_settings																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 pdlg_use_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings )
#else
	INT16 pdlg_use_settings( GLOBAL *globl, PRN_DIALOG *prn_dialog,
						PRN_SETTINGS *settings )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{205, 1, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=prn_dialog;
	data.addrin[1]=settings;
	
	data.intin[0]=9;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_validate_settings															*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 pdlg_validate_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings )
#else
	INT16 pdlg_validate_settings( GLOBAL *globl, PRN_DIALOG *prn_dialog,
						PRN_SETTINGS *settings )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{205, 1, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=prn_dialog;
	data.addrin[1]=settings;
	
	data.intin[0]=8;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

