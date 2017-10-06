/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - LBOX-Bibliothek													*/
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
/* AES 175:	lbox_ascroll_to																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	void lbox_ascroll_to( LIST_BOX *box, const INT16 first,
						Axywh *box_rect, Axywh *slider_rect )
#else
	void lbox_ascroll_to( GLOBAL *globl, LIST_BOX *box, const INT16 first,
						Axywh *box_rect, Axywh *slider_rect )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{175, 2, 0, 3, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	data.addrin[1]=box_rect;
	data.addrin[2]=slider_rect;
	
	data.intin[0]=4;
	data.intin[1]=first;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_scroll_to																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	void lbox_scroll_to( LIST_BOX *box, const INT16 first,
						Axywh *box_rect, Axywh *slider_rect )
#else
	void lbox_scroll_to( GLOBAL *globl, LIST_BOX *box, const INT16 first,
						Axywh *box_rect, Axywh *slider_rect )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{175, 2, 0, 3, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	data.addrin[1]=box_rect;
	data.addrin[2]=slider_rect;
	
	data.intin[0]=4;
	data.intin[1]=first;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_bscroll_to																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	void lbox_bscroll_to( LIST_BOX *box, const INT16 first,
						Axywh *box_rect, Axywh *slider_rect )
#else
	void lbox_bscroll_to( GLOBAL *globl, LIST_BOX *box, const INT16 first,
						Axywh *box_rect, Axywh *slider_rect )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{175, 2, 0, 3, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	data.addrin[1]=box_rect;
	data.addrin[2]=slider_rect;
	
	data.intin[0]=7;
	data.intin[1]=first;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_cnt_items																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 lbox_cnt_items( LIST_BOX *box )
#else
	INT16 lbox_cnt_items( GLOBAL *globl, LIST_BOX *box )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{174, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=0;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 170:	lbox_create																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	LIST_BOX *lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set,
						LBOX_ITEM *items, const INT16 visible_a, const INT16 first_a,
						const INT16 *ctrl_objs, const INT16 *objs, const INT16 flags, 
						const INT16 pause_a, void *user_data, DIALOG *dialog,
						const INT16 visible_b, const INT16 first_b, const INT16 entries_b, 
						const INT16 pause_b )
#else
	LIST_BOX *lbox_create( GLOBAL *globl, OBJECT *tree, SLCT_ITEM slct, SET_ITEM set,
						LBOX_ITEM *items, const INT16 visible_a, const INT16 first_a,
						const INT16 *ctrl_objs, const INT16 *objs, const INT16 flags, 
						const INT16 pause_a, void *user_data, DIALOG *dialog,
						const INT16 visible_b, const INT16 first_b, const INT16 entries_b, 
						const INT16 pause_b )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{170, 8, 0, 8, 1}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=tree;
	data.addrin[1]=slct;
	data.addrin[2]=set;
	data.addrin[3]=items;
	data.addrin[4]=ctrl_objs;
	data.addrin[5]=objs;
	data.addrin[6]=user_data;
	data.addrin[7]=dialog;
	
	data.intin[0]=visible_a;
	data.intin[1]=first_a;
	data.intin[2]=flags;
	data.intin[3]=pause_a;
	data.intin[4]=visible_b;
	data.intin[5]=first_b;
	data.intin[6]=entries_b;
	data.intin[7]=pause_b;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 173:	lbox_delete																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 lbox_delete( LIST_BOX *box )
#else
	INT16 lbox_delete( GLOBAL *globl, LIST_BOX *box )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{170, 0, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 173:	lbox_do																				*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 lbox_do( LIST_BOX *box, INT16 obj )
#else
	INT16 lbox_do( GLOBAL *globl, LIST_BOX *box, INT16 obj )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{172, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=obj;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_free_items																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	void lbox_free_items( LIST_BOX *box )
#else
	void lbox_free_items( GLOBAL *globl, LIST_BOX *box )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{175, 1, 0, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=2;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_free_list																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	void lbox_free_list( LBOX_ITEM *items )
#else
	void lbox_free_list( GLOBAL *globl, LBOX_ITEM *items )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{175, 1, 0, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=items;
	
	data.intin[0]=3;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_afirst																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 lbox_get_afirst( LIST_BOX *box )
#else
	INT16 lbox_get_afirst( GLOBAL *globl, LIST_BOX *box )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{174, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=4;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_first																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 lbox_get_first( LIST_BOX *box )
#else
	INT16 lbox_get_first( GLOBAL *globl, LIST_BOX *box )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{174, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=4;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_avis																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 lbox_get_avis( LIST_BOX *box )
#else
	INT16 lbox_get_avis( GLOBAL *globl, LIST_BOX *box )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{174, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=2;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_visible																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 lbox_get_visible( LIST_BOX *box )
#else
	INT16 lbox_get_visible( GLOBAL *globl, LIST_BOX *box )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{174, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=2;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_bentries																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 lbox_get_bentries( LIST_BOX *box )
#else
	INT16 lbox_get_bentries( GLOBAL *globl, LIST_BOX *box )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{174, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=11;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_bfirst																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 lbox_get_bfirst( LIST_BOX *box )
#else
	INT16 lbox_get_bfirst( GLOBAL *globl, LIST_BOX *box )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{174, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=12;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_bvis																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 lbox_get_bvis( LIST_BOX *box )
#else
	INT16 lbox_get_bvis( GLOBAL *globl, LIST_BOX *box )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{174, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=10;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_idx																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search )
#else
	INT16 lbox_get_idx( GLOBAL *globl, LBOX_ITEM *items, LBOX_ITEM *search )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{174, 1, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=items;
	data.addrin[1]=search;
	
	data.intin[0]=9;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_item																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	LBOX_ITEM *lbox_get_item( LIST_BOX *box, INT16 n )
#else
	LBOX_ITEM *lbox_get_item( GLOBAL *globl, LIST_BOX *box, INT16 n )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{174, 2, 0, 1, 1}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=7;
	data.intin[1]=n;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_items																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	LBOX_ITEM *lbox_get_items( LIST_BOX *box )
#else
	LBOX_ITEM *lbox_get_items( GLOBAL *globl, LIST_BOX *box )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{174, 2, 0, 1, 1}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=6;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_slct_idx																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 lbox_get_slct_idx( LIST_BOX *box )
#else
	INT16 lbox_get_slct_idx( GLOBAL *globl, LIST_BOX *box )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{174, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=5;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_slct_item																*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	LBOX_ITEM *lbox_get_slct_item( LIST_BOX *box )
#else
	LBOX_ITEM *lbox_get_slct_item( GLOBAL *globl, LIST_BOX *box )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{174, 1, 0, 1, 1}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=8;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_tree																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	OBJECT *lbox_get_tree( LIST_BOX *box )
#else
	OBJECT *lbox_get_tree( GLOBAL *globl, LIST_BOX *box )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{174, 1, 0, 1, 1}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=1;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_udata																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	void *lbox_get_udata( LIST_BOX *box )
#else
	void *lbox_get_udata( GLOBAL *globl, LIST_BOX *box )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{174, 1, 0, 1, 1}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=3;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_set_asldr																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	void lbox_set_asldr( LIST_BOX *box, INT16 first, Axywh *rect )
#else
	void lbox_set_asldr( GLOBAL *globl, LIST_BOX *box, INT16 first, Axywh *rect )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{175, 2, 0, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	data.addrin[1]=rect;
	
	data.intin[0]=0;
	data.intin[1]=first;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_set_slider																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	void lbox_set_slider( LIST_BOX *box, INT16 first, Axywh *rect )
#else
	void lbox_set_slider( GLOBAL *globl, LIST_BOX *box, INT16 first, Axywh *rect )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{175, 2, 0, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	data.addrin[1]=rect;
	
	data.intin[0]=0;
	data.intin[1]=first;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_set_bentries																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	void lbox_set_bentries( LIST_BOX *box, INT16 entries )
#else
	void lbox_set_bentries( GLOBAL *globl, LIST_BOX *box, INT16 entries )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{175, 2, 0, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	
	data.intin[0]=6;
	data.intin[1]=entries;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_set_bsldr																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	void lbox_set_bsldr( LIST_BOX *box, INT16 first, Axywh *rect )
#else
	void lbox_set_bsldr( GLOBAL *globl, LIST_BOX *box, INT16 first, Axywh *rect )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{175, 2, 0, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	data.addrin[1]=rect;
	
	data.intin[0]=5;
	data.intin[1]=first;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_set_items																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	void lbox_set_items( LIST_BOX *box, LBOX_ITEM *items )
#else
	void lbox_set_items( GLOBAL *globl, LIST_BOX *box, LBOX_ITEM *items )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{175, 1, 0, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	data.addrin[1]=items;
	
	data.intin[0]=1;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 171:	lbox_update																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	void lbox_update( LIST_BOX *box, Axywh *rect )
#else
	void lbox_update( GLOBAL *globl, LIST_BOX *box, Axywh *rect )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{171, 0, 0, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Werte in die Arrays Åbertragen */
	data.addrin[0]=box;
	data.addrin[1]=rect;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

