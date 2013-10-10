/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - PDLG-Bibliothek													*/
/*																										*/
/*	(c) 1998-2003 by Martin ElsÑsser															*/
/******************************************************************************/

#include <ACSAES.H>
#include <String.H>

/******************************************************************************/
/*																										*/
/* Lokale Konstanten																				*/
/*																										*/
/******************************************************************************/

/* Anzahl der Byte des contrl-Arrays */
#define CTRL_BYTES	5

/******************************************************************************/

/* öbertragen des contrl-Arrays */
#ifndef __USE_MEMCPY__
	#if CTRL_BYTES==4
		#define CTRLCPY(dest, src)	{((int32 *)dest)[0] = ((int32 *)src)[0];((int32 *)dest)[1] = ((int32 *)src)[1];}
	#elif CTRL_BYTES==5
		#define CTRLCPY(dest, src)	{((int32 *)dest)[0] = ((int32 *)src)[0];((int32 *)dest)[1] = ((int32 *)src)[1];((int16 *)dest)[4] = ((int16 *)src)[4];}
	#elif CTRL_BYTES==6
		#define CTRLCPY(dest, src)	{((int32 *)dest)[0] = ((int32 *)src)[0];((int32 *)dest)[1] = ((int32 *)src)[1];((int32 *)dest)[3] = ((int32 *)src)[3];}
	#else
		#define CTRLCPY(dest, src)	memcpy(dest, src, CTRL_BYTES*sizeof(int16))
	#endif
#else
	#define CTRLCPY(dest, src)	memcpy(dest, src, CTRL_BYTES*sizeof(int16))
#endif

/******************************************************************************/
/*																										*/
/* Lokale Datentypen																				*/
/*																										*/
/******************************************************************************/

typedef struct
{
	int16 contrl[CTRL_BYTES];
	GlobalArray *globl;
	int16 intin[16];
	int16 intout[7];
	void *addrin[5];
	void *addrout[1];
} AESData;

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_add_printers																	*/
/*																										*/
/******************************************************************************/

int16 mt_pdlg_add_printers( PRN_DIALOG *prn_dialog, DRV_INFO *drv_info, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {205, 1, 1, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = prn_dialog;
	data.addrin[1] = drv_info;
	
	data.intin[0] = 0;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_add_sub_dialogs																*/
/*																										*/
/******************************************************************************/

int16 mt_pdlg_add_sub_dialogs( PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialog,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {205, 1, 1, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = prn_dialog;
	data.addrin[1] = sub_dialog;
	
	data.intin[0] = 3;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 203:	pdlg_close																			*/
/*																										*/
/******************************************************************************/

int16 mt_pdlg_close( PRN_DIALOG *prn_dialog, int16 *x, int16 *y, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {203, 0, 3, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = prn_dialog;
	
	data.intout[1] = data.intout[2] = -1;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	if( x!=NULL )
		*x = data.intout[1];
	if( y!=NULL )
		*y = data.intout[2];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 200:	pdlg_close																			*/
/*																										*/
/******************************************************************************/

PRN_DIALOG *mt_pdlg_create( const int16 dialog_flags, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {200, 1, 0, 0, 1};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.intin[0] = dialog_flags;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 201:	pdlg_delete																			*/
/*																										*/
/******************************************************************************/

int16 mt_pdlg_delete( PRN_DIALOG *prn_dialog, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {201, 0, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = prn_dialog;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_dflt_settings																*/
/*																										*/
/******************************************************************************/

int16 mt_pdlg_dflt_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {205, 1, 1, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = prn_dialog;
	data.addrin[1] = settings;
	
	data.intin[0] = 7;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 207:	pdlg_do																				*/
/*																										*/
/******************************************************************************/

int16 mt_pdlg_do( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name,
				const int16 option_flags, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {207, 1, 1, 3, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = prn_dialog;
	data.addrin[1] = settings;
	data.addrin[2] = document_name;
	
	data.intin[0] = option_flags;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 206:	pdlg_evnt																			*/
/*																										*/
/******************************************************************************/

int16 mt_pdlg_evnt( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *evnt, int16 *button,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {206, 0, 2, 3, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = prn_dialog;
	data.addrin[1] = settings;
	data.addrin[2] = evnt;
	
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

int16 mt_pdlg_free_settings( PRN_SETTINGS *settings, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {205, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = settings;
	
	data.intin[0] = 6;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 204:	pdlg_get_setsize																	*/
/*																										*/
/******************************************************************************/

int32 mt_pdlg_get_setsize( GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {204, 1, 2, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.intin[0] = 0;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return *(int32 *)&data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_new_settings																	*/
/*																										*/
/******************************************************************************/

PRN_SETTINGS *mt_pdlg_new_settings( PRN_DIALOG *prn_dialog, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {205, 1, 0, 1, 1};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = prn_dialog;
	
	data.intin[0] = 5;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 202:	pdlg_open																			*/
/*																										*/
/******************************************************************************/

int16 mt_pdlg_open( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name,
				const int16 option_flags, const int16 x, const int16 y, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {202, 3, 1, 3, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = prn_dialog;
	data.addrin[1] = settings;
	data.addrin[2] = document_name;
	
	data.intin[0] = option_flags;
	data.intin[1] = x;
	data.intin[2] = y;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_remove_printers																*/
/*																										*/
/******************************************************************************/

int16 mt_pdlg_remove_printers( PRN_DIALOG *prn_dialog, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {205, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = prn_dialog;
	
	data.intin[0] = 1;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_remove_sub_dialogs															*/
/*																										*/
/******************************************************************************/

int16 mt_pdlg_remove_sub_dialogs( PRN_DIALOG *prn_dialog, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {205, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = prn_dialog;
	
	data.intin[0] = 4;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_update																			*/
/*																										*/
/******************************************************************************/

int16 mt_pdlg_update( PRN_DIALOG *prn_dialog, char *document_name, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {205, 1, 1, 3, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = prn_dialog;
	data.addrin[1] = 0;
	data.addrin[2] = document_name;
	
	data.intin[0] = 2;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_use_settings																	*/
/*																										*/
/******************************************************************************/

int16 mt_pdlg_use_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {205, 1, 1, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = prn_dialog;
	data.addrin[1] = settings;
	
	data.intin[0] = 9;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_validate_settings															*/
/*																										*/
/******************************************************************************/

int16 mt_pdlg_validate_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {205, 1, 1, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = prn_dialog;
	data.addrin[1] = settings;
	
	data.intin[0] = 8;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}
