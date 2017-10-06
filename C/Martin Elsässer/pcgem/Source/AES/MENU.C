/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - MENU-Bibliothek													*/
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
	INT16 intin[17];
	INT16 intout[7];
	void *addrin[2];
	void *addrout[1];
} AESData;

/******************************************************************************/
/*																										*/
/* AES 30:	menu_bar																				*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 menu_bar( OBJECT *tree, INT16 show )
#else
	INT16 menu_bar( GLOBAL *globl, OBJECT *tree, INT16 show )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{30, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=(show ? 1 : 0);
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 31:	menu_icheck																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 menu_icheck( OBJECT *tree, INT16 item, INT16 check )
#else
	INT16 menu_icheck( GLOBAL *globl, OBJECT *tree, INT16 item, INT16 check )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{31, 2, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=item;
	data.intin[1]=(check ? 1 : 0);
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 32:	menu_ienable																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 menu_ienable( OBJECT *tree, INT16 item, INT16 enable )
#else
	INT16 menu_ienable( GLOBAL *globl, OBJECT *tree, INT16 item,
					INT16 enable )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{32, 2, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=item;
	data.intin[1]=(enable ? 1 : 0);
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 33:	menu_tnormal																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 menu_tnormal( OBJECT *tree, INT16 title, INT16 normal )
#else
	INT16 menu_tnormal( GLOBAL *globl, OBJECT *tree, INT16 title, INT16 normal )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{33, 2, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=title;
	data.intin[1]=(normal ? 1 : 0);
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 34:	menu_text																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 menu_text( OBJECT *tree, INT16 item, char *text )
#else
	INT16 menu_text( GLOBAL *globl, OBJECT *tree, INT16 item, char *text )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{34, 1, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=item;
	
	data.addrin[0]=tree;
	data.addrin[1]=text;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 35:	menu_register																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 menu_register( INT16 apid, char *string )
#else
	INT16 menu_register( GLOBAL *globl, INT16 apid, char *string )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{35, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=apid;
	
	data.addrin[0]=string;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 36:	menu_unregister																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 menu_unregister( INT16 apid )
#else
	INT16 menu_unregister( GLOBAL *globl, INT16 apid )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{36, 1, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=apid;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 37:	menu_click																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 menu_click( INT16 click, INT16 setit )
#else
	INT16 menu_click( GLOBAL *globl, INT16 click, INT16 setit )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{37, 2, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=( click ? 1 : 0);
	data.intin[1]=( setit ? 1 : 0);
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 37:	menu_attach																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 menu_attach( INT16 flag, OBJECT *tree, INT16 item, MENU *mdata )
#else
	INT16 menu_attach( GLOBAL *globl, INT16 flag, OBJECT *tree, INT16 item, MENU *mdata )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{37, 2, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=flag;
	data.intin[1]=item;
	
	data.addrin[0]=tree;
	data.addrin[1]=mdata;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 38:	menu_istart																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 menu_istart( INT16 flag, OBJECT *tree, INT16 imenu, INT16 item )
#else
	INT16 menu_istart( GLOBAL *globl, INT16 flag, OBJECT *tree, INT16 imenu, INT16 item )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{38, 3, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=flag;
	data.intin[1]=imenu;
	data.intin[2]=item;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 36:	menu_popup																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 menu_popup( MENU *menu, INT16 xpos, INT16 ypos, MENU *mdata )
#else
	INT16 menu_popup( GLOBAL *globl, MENU *menu, INT16 xpos, INT16 ypos, MENU *mdata )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{36, 2, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=xpos;
	data.intin[1]=ypos;
	
	data.addrin[0]=menu;
	data.addrin[1]=mdata;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 39:	menu_settings																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 menu_settings( INT16 flag, MN_SET *set )
#else
	INT16 menu_settings( GLOBAL *globl, INT16 flag, MN_SET *set )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{39, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=flag;
	
	data.addrin[0]=set;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}
