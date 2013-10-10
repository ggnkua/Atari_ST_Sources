/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - LBOX-Bibliothek													*/
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
/* AES 175:	lbox_ascroll_to																	*/
/*																										*/
/******************************************************************************/

void mt_lbox_ascroll_to( LIST_BOX *box, const int16 first, GRECT *box_rect, GRECT *slider_rect,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {175, 2, 0, 3, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	data.addrin[1] = box_rect;
	data.addrin[2] = slider_rect;
	
	data.intin[0] = 4;
	data.intin[1] = first;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_scroll_to																		*/
/*																										*/
/******************************************************************************/

void mt_lbox_scroll_to( LIST_BOX *box, const int16 first, GRECT *box_rect, GRECT *slider_rect,
				GlobalArray *globl )
{
	mt_lbox_ascroll_to(box, first, box_rect, slider_rect, globl);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_bscroll_to																	*/
/*																										*/
/******************************************************************************/

void mt_lbox_bscroll_to( LIST_BOX *box, const int16 first, GRECT *box_rect, GRECT *slider_rect,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {175, 2, 0, 3, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	data.addrin[1] = box_rect;
	data.addrin[2] = slider_rect;
	
	data.intin[0] = 7;
	data.intin[1] = first;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_cnt_items																		*/
/*																										*/
/******************************************************************************/

int16 mt_lbox_cnt_items( LIST_BOX *box, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {174, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	data.intin[0] = 0;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 170:	lbox_create																			*/
/*																										*/
/******************************************************************************/

LIST_BOX *mt_lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set, LBOX_ITEM *items,
				const int16 visible_a, const int16 first_a, const int16 *ctrl_objs,
				const int16 *objs, const int16 flags, const int16 pause_a, void *user_data,
				DIALOG *dialog, const int16 visible_b, const int16 first_b, const int16 entries_b,
				const int16 pause_b, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {170, 8, 0, 8, 1};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = tree;
	data.addrin[1] = slct;
	data.addrin[2] = set;
	data.addrin[3] = items;
	data.addrin[4] = ctrl_objs;
	data.addrin[5] = objs;
	data.addrin[6] = user_data;
	data.addrin[7] = dialog;
	
	data.intin[0] = visible_a;
	data.intin[1] = first_a;
	data.intin[2] = flags;
	data.intin[3] = pause_a;
	data.intin[4] = visible_b;
	data.intin[5] = first_b;
	data.intin[6] = entries_b;
	data.intin[7] = pause_b;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 173:	lbox_delete																			*/
/*																										*/
/******************************************************************************/

int16 mt_lbox_delete( LIST_BOX *box, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {173, 0, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 172:	lbox_do																				*/
/*																										*/
/******************************************************************************/

int16 mt_lbox_do( LIST_BOX *box, const int16 obj, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {172, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	data.intin[0] = obj;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_free_items																	*/
/*																										*/
/******************************************************************************/

void mt_lbox_free_items( LIST_BOX *box,GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {175, 1, 0, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	data.intin[0] = 2;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_free_list																		*/
/*																										*/
/******************************************************************************/

void mt_lbox_free_list( LBOX_ITEM *items, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {175, 1, 0, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = items;
	
	data.intin[0] = 3;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_afirst																	*/
/*																										*/
/******************************************************************************/

int16 mt_lbox_get_afirst( LIST_BOX *box, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {174, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	data.intin[0] = 4;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_first																		*/
/*																										*/
/******************************************************************************/

int16 mt_lbox_get_first( LIST_BOX *box, GlobalArray *globl )
{
	return mt_lbox_get_afirst(box, globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_avis																		*/
/*																										*/
/******************************************************************************/

int16 mt_lbox_get_avis( LIST_BOX *box, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {174, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	data.intin[0] = 2;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_visible																	*/
/*																										*/
/******************************************************************************/

int16 mt_lbox_get_visible( LIST_BOX *box, GlobalArray *globl )
{
	return mt_lbox_get_avis(box, globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_bentries																	*/
/*																										*/
/******************************************************************************/

int16 mt_lbox_get_bentries( LIST_BOX *box, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {174, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	data.intin[0] = 11;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_bfirst																	*/
/*																										*/
/******************************************************************************/

int16 mt_lbox_get_bfirst( LIST_BOX *box, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {174, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	data.intin[0] = 12;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_bvis																		*/
/*																										*/
/******************************************************************************/

int16 mt_lbox_get_bvis( LIST_BOX *box, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {174, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	data.intin[0] = 10;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_idx																		*/
/*																										*/
/******************************************************************************/

int16 mt_lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {174, 1, 1, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = items;
	data.addrin[1] = search;
	
	data.intin[0] = 9;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_item																		*/
/*																										*/
/******************************************************************************/

LBOX_ITEM *mt_lbox_get_item( LIST_BOX *box, const int16 n, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {174, 2, 0, 1, 1};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	data.intin[0] = 7;
	data.intin[1] = n;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_items																		*/
/*																										*/
/******************************************************************************/

LBOX_ITEM *mt_lbox_get_items( LIST_BOX *box, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {174, 1, 0, 1, 1};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	data.intin[0] = 6;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_slct_idx																	*/
/*																										*/
/******************************************************************************/

int16 mt_lbox_get_slct_idx( LIST_BOX *box, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {174, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	data.intin[0] = 5;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_slct_item																*/
/*																										*/
/******************************************************************************/

LBOX_ITEM *mt_lbox_get_slct_item( LIST_BOX *box, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {174, 1, 0, 1, 1};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	data.intin[0] = 8;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_tree																		*/
/*																										*/
/******************************************************************************/

OBJECT *mt_lbox_get_tree( LIST_BOX *box, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {174, 1, 0, 1, 1};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	data.intin[0] = 1;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_udata																		*/
/*																										*/
/******************************************************************************/

void *mt_lbox_get_udata( LIST_BOX *box, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {174, 1, 0, 1, 1};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl=globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	data.intin[0] = 3;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_set_asldr																		*/
/*																										*/
/******************************************************************************/

void mt_lbox_set_asldr( LIST_BOX *box, const int16 first, GRECT *rect, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {175, 2, 0, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	data.addrin[1] = rect;
	
	data.intin[0] = 0;
	data.intin[1] = first;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_set_slider																	*/
/*																										*/
/******************************************************************************/

void mt_lbox_set_slider( LIST_BOX *box, const int16 first, GRECT *rect, GlobalArray *globl )
{
	mt_lbox_set_asldr(box, first, rect, globl);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_set_bentries																	*/
/*																										*/
/******************************************************************************/

void mt_lbox_set_bentries( LIST_BOX *box, const int16 entries, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {175, 2, 0, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	
	data.intin[0] = 6;
	data.intin[1] = entries;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_set_bsldr																		*/
/*																										*/
/******************************************************************************/

void mt_lbox_set_bsldr( LIST_BOX *box, const int16 first, GRECT *rect, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {175, 2, 0, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	data.addrin[1] = rect;
	
	data.intin[0] = 5;
	data.intin[1] = first;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_set_items																		*/
/*																										*/
/******************************************************************************/

void mt_lbox_set_items( LIST_BOX *box, LBOX_ITEM *items, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {175, 1, 0, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	data.addrin[1] = items;
	
	data.intin[0] = 1;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 171:	lbox_update																			*/
/*																										*/
/******************************************************************************/

void mt_lbox_update( LIST_BOX *box, GRECT *rect, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {171, 0, 0, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0] = box;
	data.addrin[1] = rect;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}
