/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - EDIT-Bibliothek (scrollbare Edit-Felder in MagiC)		*/
/*																										*/
/*	(c) 1998-2003 by Martin ElsÑsser															*/
/******************************************************************************/

#include <ACSAES.H>
#include <String.H>
#include <StdArg.H>

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
	int16 intin[17];
	int16 intout[7];
	void *addrin[3];
	void *addrout[1];
} AESData;

/******************************************************************************/
/*																										*/
/* AES 210:	edit_create																			*/
/*																										*/
/******************************************************************************/

XEDITINFO *mt_edit_create( GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {210, 0, 0, 0, 1};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 211:	edit_open																			*/
/*																										*/
/******************************************************************************/

int16 mt_edit_open( OBJECT *tree, const int16 obj, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {211, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 212:	edit_open																			*/
/*																										*/
/******************************************************************************/

void mt_edit_close( OBJECT *tree, const int16 obj, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {212, 1, 0, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 213:	edit_delete																			*/
/*																										*/
/******************************************************************************/

void mt_edit_delete( XEDITINFO *editinfo, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {213, 0, 0, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.addrin[0] = editinfo;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 214:	edit_cursor																			*/
/*																										*/
/******************************************************************************/

int16 mt_edit_cursor( OBJECT *tree, const int16 obj, const int16 whdl, const int16 show,
				GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {214, 3, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = whdl;
	data.intin[2] = show;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 215:	edit_evnt																			*/
/*																										*/
/******************************************************************************/

int16 mt_edit_evnt( OBJECT *tree, const int16 obj, const int16 whdl,
				EVNT *events, int32 *errcode, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {215, 2, 3, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = whdl;
	
	data.addrin[0] = tree;
	data.addrin[1] = events;
	
	/* KompatiblitÑt mit alter SLB, die noch keinen Errorcode kennt */
	*(int32 *)&data.intout[1] = 0;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* RÅckgabewerte liefern */
	if( errcode!=NULL )
		*errcode = *(int32 *)&data.intout[1];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 216, 0:	edit_get_buf																	*/
/*																										*/
/******************************************************************************/

int16 mt_edit_get_buf( OBJECT *tree, const int16 obj, char **buffer,
				int32 *buflen, int32 *txtlen, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {216, 2, 5, 1, 1};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 0;	/* Opcode edit_get_buf */
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* RÅckgabewerte liefern */
	if( buflen!=NULL )
		*buflen = *(int32 *)&data.intout[1];
	if( txtlen!=NULL )
		*txtlen = *(int32 *)&data.intout[3];
	if( buffer!=NULL )
		*buffer = (char *)&data.addrout[0];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 216, 1:	edit_get_format																*/
/*																										*/
/******************************************************************************/

int16 mt_edit_get_format( OBJECT *tree, const int16 obj, int16 *tabwidth, int16 *autowrap,
				GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {216, 2, 3, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 1;	/* Opcode edit_get_format */
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* RÅckgabewerte liefern */
	if( tabwidth!=NULL )
		*tabwidth = data.intout[1];
	if( autowrap!=NULL )
		*autowrap = data.intout[2];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 216, 2:	edit_get_colour																*/
/*																										*/
/******************************************************************************/

int16 mt_edit_get_colour( OBJECT *tree, const int16 obj, int16 *tcolour, int16 *bcolour,
				GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {216, 2, 3, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 2;	/* Opcode edit_get_colour */
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* RÅckgabewerte liefern */
	if( tcolour!=NULL )
		*tcolour = data.intout[1];
	if( bcolour!=NULL )
		*bcolour = data.intout[2];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 216, 2:	edit_get_color - ein Schreibfeher in der MagiC-Dokumentation?	*/
/*																										*/
/******************************************************************************/

int16 mt_edit_get_color( OBJECT *tree, const int16 obj, int16 *tcolor, int16 *bcolor,
				GlobalArray *globl )
{
	return mt_edit_get_colour(tree, obj, tcolor, bcolor, globl);
}

/******************************************************************************/
/*																										*/
/* AES 216, 3:	edit_get_font																	*/
/*																										*/
/******************************************************************************/

int16 mt_edit_get_font( OBJECT *tree, const int16 obj, int16 *fontID, int16 *fontH,
				boolean *fontPix, boolean *mono, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {216, 2, 5, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 3;	/* Opcode edit_get_font */
	
	data.addrin[0] = tree;
	
	/* KompatiblitÑt mit alter SLB, die dies noch nicht kennt */
	data.intout[4] = 0;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* RÅckgabewerte liefern */
	if( fontID!=NULL )
		*fontID = data.intout[1];
	if( fontH!=NULL )
		*fontH = data.intout[2];
	if( mono!=NULL )
		*mono = data.intout[3];
	if( fontPix!=NULL )
		*fontPix = data.intout[4];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 216, 4:	edit_get_cursor																*/
/*																										*/
/******************************************************************************/

int16 mt_edit_get_cursor( OBJECT *tree, const int16 obj, char **cursorpos,
				GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {216, 2, 1, 1, 1};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 4;	/* Opcode edit_get_cursor */
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* RÅckgabewerte liefern */
	if( cursorpos!=NULL )
		*cursorpos = data.addrout[0];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 216, 5:	edit_get_pos																	*/
/*																										*/
/******************************************************************************/

void mt_edit_get_pos( OBJECT *tree, const int16 obj, int16 *xscroll, int32 *yscroll,
				char **cyscroll, char **cursorpos, int16 *cx, int16 *cy,
				GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {216, 2, 6, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 5;	/* Opcode edit_get_pos */
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* RÅckgabewerte liefern */
	if( xscroll!=NULL )
		*xscroll = data.intout[1];
	if( yscroll!=NULL )
		*yscroll = *((int32 *) (data.intout+2));
	if( cyscroll!=NULL )
		*cyscroll = data.addrout[0];
	if( cx!=NULL )
		*cx = data.intout[4];
	if( cy!=NULL )
		*cy = data.intout[5];
	if( cursorpos!=NULL )
		*cursorpos = data.addrout[1];
}

/******************************************************************************/
/*																										*/
/* AES 216, 7:	edit_get_cursor																*/
/*																										*/
/******************************************************************************/

boolean mt_edit_get_dirty( OBJECT *tree, const int16 obj, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {216, 2, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 7;	/* Opcode edit_get_dirty */
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 216, 8:	edit_get_sel																	*/
/*																										*/
/******************************************************************************/

void mt_edit_get_sel( OBJECT *tree, const int16 obj, char **bsel, char **esel,
				GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {216, 2, 0, 1, 2};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 8;	/* Opcode edit_get_sel */
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* RÅckgabewerte liefern */
	if( bsel!=NULL )
		*bsel = data.addrout[0];
	if( esel!=NULL )
		*esel = data.addrout[1];
}

/******************************************************************************/
/*																										*/
/* AES 216, 9:	edit_get_scrollinfo															*/
/*																										*/
/******************************************************************************/

void mt_edit_get_scrollinfo( OBJECT *tree, const int16 obj, int32 *nlines,
				int32 *yscroll, int16 *yvis, int16 *yval, int16 *ncols,
				int16 *xscroll, int16 *xvis, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {216, 2, 10, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl=globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 9;	/* Opcode edit_get_scrollinfo */
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* RÅckgabewerte liefern */
	if( nlines!=NULL )
		*nlines = *(int32 *)&data.intout[1];
	if( yscroll!=NULL )
		*yscroll = *(int32 *)&data.intout[3];
	if( yvis!=NULL )
		*yvis = data.intout[5];
	if( yval!=NULL )
		*yval = data.intout[6];
	if( ncols!=NULL )
		*ncols = data.intout[7];
	if( xscroll!=NULL )
		*xscroll = data.intout[8];
	if( xvis!=NULL )
		*xvis = data.intout[9];
}

/******************************************************************************/
/*																										*/
/* AES 217, 0:	edit_set_buf																	*/
/*																										*/
/******************************************************************************/

void mt_edit_set_buf( OBJECT *tree, const int16 obj, char *buffer, const int32 buflen,
				GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {217, 4, 0, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 0;	/* Opcode edit_set_buf */
	*(int32 *)&data.intin[2] = buflen;
	
	data.addrin[0] = tree;
	data.addrin[1] = buffer;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 217, 1:	edit_set_format																*/
/*																										*/
/******************************************************************************/

void mt_edit_set_format( OBJECT *tree, const int16 obj, const int16 tabwidth,
				const int16 autowrap, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {217, 4, 0, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 1;	/* Opcode edit_set_format */
	data.intin[2] = tabwidth;
	data.intin[3] = autowrap;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 217, 2:	edit_set_colour																*/
/*																										*/
/******************************************************************************/

void mt_edit_set_colour( OBJECT *tree, const int16 obj, const int16 tcolour,
				const int16 bcolour, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {217, 4, 0, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 2;	/* Opcode edit_set_colour */
	data.intin[2] = tcolour;
	data.intin[3] = bcolour;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 217, 2:	edit_set_color - ein Schreibfeher in der MagiC-Dokumentation?	*/
/*																										*/
/******************************************************************************/

void mt_edit_set_color( OBJECT *tree, const int16 obj, const int16 tcolor, const int16 bcolor,
				GlobalArray *globl )
{
	mt_edit_set_colour(tree, obj, tcolor, bcolor, globl);
}

/******************************************************************************/
/*																										*/
/* AES 217, 3:	edit_set_font																	*/
/*																										*/
/******************************************************************************/

void mt_edit_set_font( OBJECT *tree, const int16 obj, const int16 fontID, const int16 fontH,
				const int16 fontPix, const int16 mono, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {217, 6, 0, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 3;	/* Opcode edit_set_font */
	data.intin[2] = fontID;
	data.intin[3] = fontH;
	data.intin[4] = mono;
	data.intin[5] = fontPix;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 217, 4:	edit_set_cursor																	*/
/*																										*/
/******************************************************************************/

void mt_edit_set_cursor( OBJECT *tree, const int16 obj, char *cursorpos, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {217, 2, 0, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 4;	/* Opcode edit_set_cursor */
	
	data.addrin[0] = tree;
	data.addrin[1] = cursorpos;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 217, 4:	edit_set_cursor																	*/
/*																										*/
/******************************************************************************/

void mt_edit_set_pos( OBJECT *tree, const int16 obj, const int16 xscroll,
				const int32 yscroll, char *cyscroll, char *cursorpos, const int16 cx,
				const int16 cy, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {217, 7, 0, 3, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 5;	/* Opcode edit_set_pos */
	data.intin[2] = xscroll;
	*(int32 *)(&data.intin[3]) = yscroll;
	data.intin[5] = cx;
	data.intin[6] = cy;
	
	data.addrin[0] = tree;
	data.addrin[1] = cyscroll;
	data.addrin[2] = cursorpos;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 217, 6:	edit_resized																	*/
/*																										*/
/******************************************************************************/

int16 mt_edit_resized( OBJECT *tree, const int16 obj, int16 *oldrh, int16 *newrh,
				GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {217, 2, 3, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 6;	/* Opcode edit_resized */
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* RÅckgabewerte liefern */
	if( oldrh!=NULL )
		*oldrh = data.intout[1];
	if( newrh!=NULL )
		*newrh = data.intout[2];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 217, 7:	edit_set_dirty																	*/
/*																										*/
/******************************************************************************/

void mt_edit_set_dirty( OBJECT *tree, const int16 obj, const boolean dirty, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {217, 3, 0, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 7;	/* Opcode edit_set_dirty */
	data.intin[2] = dirty;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 217, 9:	edit_scroll																		*/
/*																										*/
/******************************************************************************/

int16 mt_edit_scroll( OBJECT *tree, const int16 obj, const int16 whdl, const int32 yscroll,
				const int16 xscroll, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {217, 6, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = 9;	/* Opcode edit_set_dirty */
	data.intin[2] = whdl;
	*(int32 *)&data.intin[3] = yscroll;
	data.intin[5] = xscroll;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}
