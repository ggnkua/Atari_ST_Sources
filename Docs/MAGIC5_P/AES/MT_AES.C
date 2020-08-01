/****************************************************************
*
* Dieses Modul enth„lt MT-sichere AES-Funktionen.
*
* Man beachte, daž die MT-Variante einiger Funktionen gegenber
* dem Standard-Binding zus„tzliche Parameter ben”tigt.
* Betroffen sind:
*
*	WORD MT_appl_init( WORD *global );
*	WORD MT_rsrc_load( char *filename, WORD *global );
*	WORD MT_rsrc_free( WORD *global );
*	WORD MT_rsrc_gaddr( WORD type, WORD index, OBJECT **addr,
*				WORD *global )
*	WORD MT_rsrc_saddr( WORD type, WORD index, OBJECT *o, WORD *global );
*	WORD MT_rsrc_rcfix( RSHDR *rsh, WORD *global );
*
* Bei einigen Funktionen wurde ein einfacheres Binding
* verwendet. Betroffen sind:
*
*	evnt_button( WORD nclicks, WORD mask, WORD state,
*				EVNTDATA *ev );
*	evnt_mouse( WORD flg_leave, GRECT *g, EVNTDATA *ev );
*	objc_draw( OBJECT *tree, WORD start, WORD depth, GRECT *g );
*	form_center( OBJECT *tree, GRECT *g );
*
* Bei anderen Funktionen ist nur die erweiterte Variante
* vorhanden:
*
*	WORD form_xdo( OBJECT *tree, WORD startob,
*			WORD *cursor_obj, void *scantab, void *flyinf );
*	WORD form_xdial( WORD subfn,
*				GRECT *lg, GRECT *bg,
*				void **flyinf );
*
*
* Jeder Thread muž also sein eigenes Array:
*	WORD global[15]
* haben.
*
* Entwickelt mit und fr PureC 1.1.
* Damit sich der Quelltext leicht portieren l„žt, wird mit
* portab.h gearbeitet.
*
* Andreas Kromke
* 16.3.96
*
****************************************************************/

#include "mt_aes.h"

/****************************************************************
*
* Inititialisiert den AESPB (ohne global[] !!! )
* Setzt die contrl-Felder und ruft das AES auf.
*
****************************************************************/

static void __aes( AESPB *pb, PARMDATA *d, WORD *ctrldata )
{
	register WORD *c = d->contrl;

	pb->contrl	= c;
	pb->intin		= d->intin;
	pb->intout	= d->intout;
	pb->addrin	= d->addrin;
	pb->addrout	= d->addrout;

	*c++ = *ctrldata++;
	*c++ = *ctrldata++;
	*c++ = *ctrldata++;
	*c = *ctrldata;

	_crystal( pb );
}


/****************************************************************
*
* (10)	appl_init
*
****************************************************************/

WORD MT_appl_init( WORD *global )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {10,0,1,0};

	d.intout[0] = -1;		/* wichtig, falls AES nicht da */
	pb.global = global;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (11)	appl_read
*
****************************************************************/

WORD appl_read( WORD apid, WORD len, void *buf )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {11,2,1,1};

	d.intin[0]	= apid;
	d.intin[1]	= len;
	d.addrin[0]	= buf;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (12)	appl_write
*
****************************************************************/

WORD appl_write( WORD apid, WORD len, void *buf )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {12,2,1,1};

	d.intin[0]	= apid;
	d.intin[1]	= len;
	d.addrin[0]	= buf;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (13)	appl_find
*
****************************************************************/

WORD appl_find( char *apname )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {13,0,1,1};

	d.addrin[0]	= apname;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (14)	appl_tplay
*
****************************************************************/

WORD appl_tplay( void *mem, WORD len, WORD scale )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {14,2,1,1};

	d.intin[0]	= len;
	d.intin[1]	= scale;
	d.addrin[0]	= mem;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (15)	appl_trecord
*
****************************************************************/

WORD appl_trecord( void *mem, WORD len )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {15,1,1,1};

	d.intin[0]	= len;
	d.addrin[0]	= mem;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (16)	appl_bvset
*
****************************************************************/

/* ... gibt's nich */


/****************************************************************
*
* (17)	appl_yield
*
****************************************************************/

void appl_yield( void )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {17,0,1,0};

	__aes( &pb, &d, c );
}


/****************************************************************
*
* (18)	appl_search
*
****************************************************************/

WORD appl_search( WORD mode, char *name, WORD *type, WORD *id )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {18,0,1,0};

	d.intin[0]	= mode;
	d.addrin[0]	= name;
	__aes( &pb, &d, c );
	*type	= pb.intout[1];
	*id		= pb.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (19)	appl_exit
*
****************************************************************/

WORD appl_exit( void )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {19,0,1,0};

	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (20)	evnt_keybd
*
****************************************************************/

WORD evnt_keybd( void )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {20,0,1,0};

	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (21)	evnt_button
*
****************************************************************/

WORD evnt_button( WORD nclicks, WORD mask, WORD state,
				EVNTDATA *ev )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {21,3,5,0};

	d.intin[0]	= nclicks;
	d.intin[1]	= mask;
	d.intin[2]	= state;
	__aes( &pb, &d, c );
	ev->x		= pb.intout[1];
	ev->y		= pb.intout[2];
	ev->bstate	= pb.intout[3];
	ev->kstate	= pb.intout[4];
	return(d.intout[0]);			/* nclicks */
}


/****************************************************************
*
* (22)	evnt_mouse
*
****************************************************************/

WORD evnt_mouse( WORD flg_leave, GRECT *g, EVNTDATA *ev )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {22,5,5,0};

	d.intin[0]	= flg_leave;
	*((GRECT *)(d.intin+1))	= *g;
	__aes( &pb, &d, c );
	ev->x		= pb.intout[1];
	ev->y		= pb.intout[2];
	ev->bstate	= pb.intout[3];
	ev->kstate	= pb.intout[4];
	return(d.intout[0]);
}


/****************************************************************
*
* (23)	evnt_mesag
*
****************************************************************/

WORD evnt_mesag( WORD *buf )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {23,0,1,1};

	d.addrin[0]	= buf;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (24)	evnt_timer
*
****************************************************************/

WORD evnt_timer( ULONG ms )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {24,2,1,0};

	d.intin[0] = (WORD) ms;			/* Intel: erst Low */
	d.intin[1] = (WORD) (ms>>16L);	/* Intel: dann High */
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (25)	evnt_multi
*
****************************************************************/

WORD evnt_multi(
			WORD evtypes,
			WORD nclicks, WORD bmask, WORD bstate,
			WORD flg1_leave, GRECT *g1,
			WORD flg2_leave, GRECT *g2,
			WORD *msgbuf,
			ULONG ms,
			EVNTDATA *ev,
			WORD *keycode,
			WORD *nbclicks
			)
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {25,16,7,1};

	d.intin[0] = evtypes;
	d.intin[1] = nclicks;
	d.intin[2] = bmask;
	d.intin[3] = bstate;
	if	(evtypes & 4)
		{
		d.intin[4] = flg1_leave;
		*((GRECT *)(d.intin+5))	= *g1;
		}
	if	(evtypes & 8)
		{
		d.intin[9] = flg2_leave;
		*((GRECT *)(d.intin+10))	= *g2;
		}
	d.intin[14] = (WORD) ms;			/* Intel: erst Low */
	d.intin[15] = (WORD) (ms>>16L);	/* Intel: dann High */
	d.addrin[0] = msgbuf;
	__aes( &pb, &d, c );
	ev->x		= d.intout[1];
	ev->y		= d.intout[2];
	ev->bstate	= d.intout[3];
	ev->kstate	= d.intout[4];
	*keycode		= d.intout[5];
	*nbclicks		= d.intout[6];
	return(d.intout[0]);
}


/****************************************************************
*
* (26)	evnt_dclicks
*
****************************************************************/

WORD evnt_dclicks( WORD val, WORD setflg )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {26,2,1,0};

	d.intin[0] = val;
	d.intin[1] = setflg;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (30)	menu_bar
*
****************************************************************/

WORD menu_bar( OBJECT *tree, WORD show )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {30,1,1,1};

	d.intin[0] 	= show;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (31)	menu_icheck
*
****************************************************************/

WORD menu_icheck( OBJECT *tree, WORD objnr, WORD chkflg )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {31,2,1,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= chkflg;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (32)	menu_ienable
*
****************************************************************/

WORD menu_ienable( OBJECT *tree, WORD objnr, WORD chkflg )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {32,2,1,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= chkflg;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (33)	menu_tnormal
*
****************************************************************/

WORD menu_tnormal( OBJECT *tree, WORD objnr, WORD chkflg )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {33,2,1,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= chkflg;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (34)	menu_text
*
****************************************************************/

WORD menu_text( OBJECT *tree, WORD objnr, const char *text )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {34,1,1,2};

	d.intin[0] 	= objnr;
	d.addrin[0]	= tree;
	d.addrin[1] 	= text;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (35)	menu_register
*
****************************************************************/

WORD menu_register( WORD apid, const char *text )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {35,1,1,1};

	d.intin[0] 	= apid;
	d.addrin[0]	= text;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (36)	menu_unregister
*
****************************************************************/

WORD menu_unregister( WORD menuid )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {36,1,1,0};

	d.intin[0] 	= menuid;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
*  		menu_popup
*
****************************************************************/

WORD menu_popup( MENU *menu, WORD x, WORD y, MENU *data)
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {36,2,1,2};

	d.intin[0] 	= x;
	d.intin[1] 	= y;
	d.addrin[0] 	= menu;
	d.addrin[1] 	= data;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (37)	menu_click
*
****************************************************************/

WORD menu_click( WORD val, WORD setflag )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {37,2,1,0};

	d.intin[0] 	= val;
	d.intin[1] 	= setflag;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* 		menu_attach
*
****************************************************************/

WORD menu_attach( WORD flag, OBJECT *tree, WORD obj, MENU *data )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {37,2,1,2};

	d.intin[0] 	= flag;
	d.intin[1] 	= obj;
	d.addrin[0] 	= tree;
	d.addrin[1] 	= data;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (38)	menu_istart
*
****************************************************************/

WORD menu_istart( WORD flag, OBJECT *tree, WORD menu, WORD item )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {38,3,1,1};

	d.intin[0] 	= flag;
	d.intin[1] 	= menu;
	d.intin[2] 	= item;
	d.addrin[0] 	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (39)	menu_settings
*
****************************************************************/

WORD menu_settings( WORD flag, MN_SET *values )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {39,1,1,1};

	d.intin[0] 	= flag;
	d.addrin[0] 	= values;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (40)	objc_add
*
****************************************************************/

WORD objc_add( OBJECT *tree, WORD parent, WORD child )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {40,2,1,1};

	d.intin[0] 	= parent;
	d.intin[1] 	= child;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (41)	objc_delete
*
****************************************************************/

WORD objc_delete( OBJECT *tree, WORD objnr )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {41,1,1,1};

	d.intin[0] 	= objnr;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (42)	objc_draw
*
****************************************************************/

WORD objc_draw( OBJECT *tree, WORD start, WORD depth, GRECT *g )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {42,6,1,1};

	d.intin[0] 	= start;
	d.intin[1] 	= depth;
	*((GRECT *)(d.intin+2))	= *g;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (43)	objc_find
*
****************************************************************/

WORD objc_find( OBJECT *tree, WORD start, WORD depth,
			WORD x, WORD y )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {43,4,1,1};

	d.intin[0] 	= start;
	d.intin[1] 	= depth;
	d.intin[2] 	= x;
	d.intin[3] 	= y;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (44)	objc_offset
*
****************************************************************/

WORD objc_offset( OBJECT *tree, WORD objnr, WORD *x, WORD *y )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {44,1,3,1};

	d.intin[0] 	= objnr;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	*x	= d.intout[1];
	*y	= d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (45)	objc_order
*
****************************************************************/

WORD objc_order( OBJECT *tree, WORD objnr, WORD newpos )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {45,2,1,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= newpos;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (46)	objc_edit
*
****************************************************************/

WORD objc_edit( OBJECT *tree, WORD objnr, WORD key,
			WORD *cursor_xpos, WORD subfn )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {46,4,2,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= key;
	d.intin[2] 	= *cursor_xpos;
	d.intin[3] 	= subfn;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	*cursor_xpos	= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (47)	objc_change
*
****************************************************************/

WORD objc_change( OBJECT *tree, WORD objnr, WORD resvd,
				GRECT *g, WORD newstate, WORD redraw )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {47,8,1,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= resvd;		/* ggf. sp„ter: WindowHandle */
	*((GRECT *)(d.intin+2))	= *g;
	d.intin[6] 	= newstate;
	d.intin[7] 	= redraw;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (48)	objc_sysvar
*
****************************************************************/

WORD	objc_sysvar( WORD ob_smode, WORD ob_swhich,
				WORD ob_sival1, WORD ob_sival2,
				WORD *ob_soval1, WORD *ob_soval2 )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {48,4,3,0};

	d.intin[0] = ob_smode;
	d.intin[1] = ob_swhich;
	d.intin[2] = ob_sival1;
	d.intin[3] = ob_sival2;
	__aes( &pb, &d, c );
	*ob_soval1 = d.intout[1];
	*ob_soval2 = d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (50)	form_xdo
*
****************************************************************/

WORD form_xdo( OBJECT *tree, WORD startob,
			WORD *cursor_obj,
			XDO_INF *scantab, void *flyinf )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {50,1,2,3};

	d.intin[0] 	= startob;
	d.addrin[0]	= tree;
	d.addrin[1]	= scantab;
	d.addrin[2]	= flyinf;
	__aes( &pb, &d, c );
	*cursor_obj	= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (51)	form_xdial
*
****************************************************************/

WORD form_xdial( WORD subfn,
				GRECT *lg, GRECT *bg,
				void **flyinf )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {51,9,1,2};

	d.intin[0] 	= subfn;
	if	((subfn == 1) || (subfn == 2))
		{
		*((GRECT *)(d.intin+1))	= *lg;
		*((GRECT *)(d.intin+5))	= *bg;
		}
	d.addrin[0]	= flyinf;
	d.addrin[1]	= 0;		/* reserviert */
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (52)	form_alert
*
****************************************************************/

WORD form_alert( WORD defbutton, const char *string )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {52,1,1,1};

	d.intin[0] 	= defbutton;
	d.addrin[0]	= string;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (53)	form_error
*
****************************************************************/

WORD form_error( WORD dosenkot )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {53,1,1,0};

	d.intin[0] 	= dosenkot;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (54)	form_center
*
****************************************************************/

WORD form_center( OBJECT *tree, GRECT *g )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {54,0,5,1};

	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	*g = *((GRECT *)(d.intout+1));
	return(d.intout[0]);
}


/****************************************************************
*
* (55)	form_keybd
*
****************************************************************/

WORD form_keybd( OBJECT *tree, WORD obj, WORD nxt, WORD key,
				WORD *nextob, WORD *nextchar )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {55,3,3,1};

	d.intin[0]	= obj;
	d.intin[1]	= key;
	d.intin[2]	= nxt;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	*nextob		= d.intout[1];
	*nextchar		= d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (56)	form_button
*
****************************************************************/

WORD form_button( OBJECT *tree, WORD obj, WORD nclicks,
				WORD *nextob )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {56,2,2,1};

	d.intin[0]	= obj;
	d.intin[1]	= nclicks;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	*nextob		= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (70)	graf_rubberbox
*
****************************************************************/

WORD graf_rubberbox( int x, int y, int begw, int begh,
				int *endw, int *endh)
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {70,4,3,0};

	d.intin[0]	= x;
	d.intin[1]	= y;
	d.intin[2]	= begw;
	d.intin[3]	= begh;
	__aes( &pb, &d, c );
	*endw		= d.intout[1];
	*endh		= d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (71)	graf_dragbox
*
****************************************************************/

WORD graf_dragbox( WORD w, WORD h, WORD begx, WORD begy,
				GRECT *g, WORD *endx, WORD *endy )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {71,8,3,0};

	d.intin[0]	= w;
	d.intin[1]	= h;
	d.intin[2]	= begx;
	d.intin[3]	= begy;
	*((GRECT *)(d.intin+4))	= *g;
	__aes( &pb, &d, c );
	*endx		= d.intout[1];
	*endy		= d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (72)	graf_movebox
*
****************************************************************/

WORD graf_movebox( WORD w, WORD h, WORD begx, WORD begy,
				WORD endx, WORD endy )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {72,6,1,0};

	d.intin[0]	= w;
	d.intin[1]	= h;
	d.intin[2]	= begx;
	d.intin[3]	= begy;
	d.intin[4]	= endx;
	d.intin[5]	= endy;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (73)	graf_growbox
*
****************************************************************/

WORD graf_growbox( GRECT *startg, GRECT *endg )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {73,8,1,0};

	*((GRECT *)(d.intin))	= *startg;
	*((GRECT *)(d.intin+4))	= *endg;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (74)	graf_shrinkbox
*
****************************************************************/

WORD graf_shrinkbox( GRECT *endg, GRECT *startg )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {74,8,1,0};

	*((GRECT *)(d.intin))	= *endg;
	*((GRECT *)(d.intin+4))	= *startg;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (75)	graf_watchbox
*
****************************************************************/

WORD graf_watchbox( OBJECT *tree, WORD obj, WORD instate,
				WORD outstate )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {75,4,1,1};

	d.intin[0]	= 0;
	d.intin[1]	= obj;
	d.intin[2]	= instate;
	d.intin[3]	= outstate;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (76)	graf_slidebox
*
****************************************************************/

WORD graf_slidebox( OBJECT *tree, WORD parent, WORD obj,
				WORD h )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {76,3,1,1};

	d.intin[0]	= parent;
	d.intin[1]	= obj;
	d.intin[2]	= h;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (77)	graf_(x)handle
*
****************************************************************/

WORD graf_handle( WORD *wchar, WORD *hchar,
				WORD *wbox, WORD *hbox )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {77,0,5,0};

	__aes( &pb, &d, c );
	*wchar	= d.intout[1];
	*hchar	= d.intout[2];
	*wbox	= d.intout[3];
	*hbox	= d.intout[4];
	return(d.intout[0]);
}
WORD graf_xhandle( WORD *wchar, WORD *hchar,
				WORD *wbox, WORD *hbox, WORD *device )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {77,0,6,0};

	__aes( &pb, &d, c );
	*wchar	= d.intout[1];
	*hchar	= d.intout[2];
	*wbox	= d.intout[3];
	*hbox	= d.intout[4];
	*device	= d.intout[5];
	return(d.intout[0]);
}


/****************************************************************
*
* (78)	graf_mouse
*
****************************************************************/

WORD graf_mouse( WORD code, MFORM *adr )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {78,1,1,1};

	d.intin[0]	= code;
	d.addrin[0]	= adr;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (79)	graf_mkstate
*
****************************************************************/

WORD graf_mkstate( EVNTDATA *ev )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {79,0,5,0};

	__aes( &pb, &d, c );
	*ev		= *((EVNTDATA *) (d.intout+1));
	return(d.intout[0]);
}


/****************************************************************
*
* (80)	scrp_read
*
****************************************************************/

WORD scrp_read( char *path )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {80,0,1,1};

	d.addrin[0]	= path;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (81)	scrp_write
*
****************************************************************/

WORD scrp_write( char *path )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {81,0,1,1};

	d.addrin[0]	= path;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (82)	scrp_clear
*
****************************************************************/

WORD scrp_clear( void )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {82,0,1,0};

	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (90)	fsel_input
*
****************************************************************/

WORD fsel_input( char *path, char *name, WORD *button )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {90,0,2,2};

	d.addrin[0]	= path;
	d.addrin[1]	= name;
	__aes( &pb, &d, c );
	*button	= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (91)	fsel_exinput
*
****************************************************************/

WORD fsel_exinput( char *path, char *name, WORD *button,
				char *label )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {91,0,2,3};

	d.addrin[0]	= path;
	d.addrin[1]	= name;
	d.addrin[2]	= label;
	__aes( &pb, &d, c );
	*button	= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (100)	wind_create
*
****************************************************************/

WORD wind_create( WORD kind, GRECT *maxsize )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {100,5,1,0};

	d.intin[0]	= kind;
	*((GRECT *)(d.intin+1))	= *maxsize;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (101)	wind_open
*
****************************************************************/

WORD wind_open( WORD whdl, GRECT *g )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {101,5,1,0};

	d.intin[0]	= whdl;
	*((GRECT *)(d.intin+1))	= *g;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (102)	wind_close
*
****************************************************************/

WORD wind_close( WORD whdl )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {102,1,1,0};

	d.intin[0]	= whdl;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (103)	wind_delete
*
****************************************************************/

WORD wind_delete( WORD whdl )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {103,1,1,0};

	d.intin[0]	= whdl;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (104)	wind_get
*
****************************************************************/

WORD wind_get( WORD whdl, WORD subfn,
			WORD *g1, WORD *g2, WORD *g3, WORD *g4 )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {104,2,5,0};

	d.intin[0]	= whdl;
	d.intin[1]	= subfn;
	__aes( &pb, &d, c );
	*g1 = d.intout[1];
	*g2 = d.intout[2];
	*g3 = d.intout[3];
	*g4 = d.intout[4];
	return(d.intout[0]);
}


WORD wind_get_grect( WORD whdl, WORD subfn, GRECT *g )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {104,2,5,0};

	d.intin[0]	= whdl;
	d.intin[1]	= subfn;
	__aes( &pb, &d, c );
	*g		= *((GRECT *) (d.intout+1));
	return(d.intout[0]);
}


/****************************************************************
*
* (105)	wind_set
*
****************************************************************/

WORD wind_set( WORD whdl, WORD subfn,
			WORD g1, WORD g2, WORD g3, WORD g4 )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {105,6,1,0};

	d.intin[0]	= whdl;
	d.intin[1]	= subfn;
	d.intin[2]	= g1;
	d.intin[3]	= g2;
	d.intin[4]	= g3;
	d.intin[5]	= g4;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


WORD wind_set_grect( WORD whdl, WORD subfn, GRECT *g )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {105,6,1,0};

	d.intin[0]	= whdl;
	d.intin[1]	= subfn;
	*((GRECT *) (d.intin+2)) = *g;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (106)	wind_find
*
****************************************************************/

WORD wind_find( WORD x, WORD y )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {106,2,1,0};

	d.intin[0]	= x;
	d.intin[1]	= y;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (107)	wind_update
*
****************************************************************/

WORD wind_update( WORD subfn )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {107,1,1,0};

	d.intin[0]	= subfn;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (108)	wind_calc
*
****************************************************************/

WORD wind_calc( WORD subfn, WORD kind,
			GRECT *ing, GRECT *outg )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {108,6,5,0};

	d.intin[0]	= subfn;
	d.intin[1]	= kind;
	*((GRECT *) (d.intin+2)) = *ing;
	__aes( &pb, &d, c );
	*outg		= *((GRECT *) (d.intout+1));
	return(d.intout[0]);
}


/****************************************************************
*
* (109)	wind_new
*
****************************************************************/

void wind_new( void )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {109,0,0,0};

	__aes( &pb, &d, c );
}


/****************************************************************
*
* (110)	rsrc_load
*
****************************************************************/

WORD MT_rsrc_load( char *filename, WORD *global )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {110,0,1,1};

	d.addrin[0]	= filename;
	pb.global = global;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (111)	rsrc_free
*
****************************************************************/

WORD MT_rsrc_free( WORD *global )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {111,0,1,0};

	pb.global = global;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (112)	rsrc_gaddr
*
****************************************************************/

WORD MT_rsrc_gaddr( WORD type, WORD index, void *addr,
				WORD *global )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {112,2,1,0};

	d.intin[0]	= type;
	d.intin[1]	= index;
	pb.global = global;
	__aes( &pb, &d, c );
	*((void **) addr) = d.addrout[0];
	return(d.intout[0]);
}


/****************************************************************
*
* (113)	rsrc_saddr
*
****************************************************************/

WORD MT_rsrc_saddr( WORD type, WORD index, void *o,
		WORD *global )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {113,2,1,1};

	d.intin[0]	= type;
	d.intin[1]	= index;
	d.addrin[0]	= o;
	pb.global = global;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (114)	rsrc_obfix
*
****************************************************************/

WORD rsrc_obfix( OBJECT *tree, WORD obj )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {114,1,1,1};

	d.intin[0]	= obj;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (115)	rsrc_obfix
*
****************************************************************/

WORD MT_rsrc_rcfix( RSHDR *rsh, WORD *global )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {115,0,1,1};

	d.addrin[0]	= rsh;
	pb.global = global;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (120)	shel_read
*
****************************************************************/

WORD shel_read( char *cmd, char *tail )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {120,0,1,2};

	d.addrin[0]	= cmd;
	d.addrin[1]	= tail;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (121)	shel_write
*
****************************************************************/

WORD shel_write( WORD doex, WORD isgr, WORD isover,
				char *cmd, char *tail )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {121,3,1,2};

	d.intin[0]	= doex;
	d.intin[1]	= isgr;
	d.intin[2]	= isover;
	d.addrin[0]	= cmd;
	d.addrin[1]	= tail;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (122)	shel_get
*
****************************************************************/

WORD shel_get( char *buf, WORD len )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {122,1,1,1};

	d.intin[0]	= len;
	d.addrin[0]	= buf;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (123)	shel_put
*
****************************************************************/

WORD shel_put( char *buf, WORD len )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {123,1,1,1};

	d.intin[0]	= len;
	d.addrin[0]	= buf;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (124)	shel_find
*
****************************************************************/

WORD shel_find( char *path )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {124,0,1,1};

	d.addrin[0]	= path;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (125)	shel_envrn
*
****************************************************************/

WORD shel_envrn( char **val, char *name )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {125,0,1,2};

	d.addrin[0]	= val;
	d.addrin[1]	= name;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (126)	shel_rdef
*
****************************************************************/

void shel_rdef( char *fname, char *dir )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {126,0,1,2};

	d.addrin[0]	= fname;
	d.addrin[1]	= dir;
	__aes( &pb, &d, c );
}


/****************************************************************
*
* (127)	shel_wdef
*
****************************************************************/

void shel_wdef( char *fname, char *dir )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {127,0,1,2};

	d.addrin[0]	= fname;
	d.addrin[1]	= dir;
	__aes( &pb, &d, c );
}


/****************************************************************
*
* (130)	xgrf_stepcalc
*
****************************************************************/

/****************************************************************
*
* (131)	xgrf_2box
*
****************************************************************/

/* ... brauchen wir nicht ... */


/****************************************************************
*
* (135)	form_popup
*
****************************************************************/

WORD form_popup( OBJECT *tree, WORD x, WORD y )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {135,2,1,1};

	d.intin[0]	= x;
	d.intin[1]	= y;
	d.addrin[0]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (136)	form_xerr
*
****************************************************************/

WORD form_xerr( LONG errcode, char *errfile )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {136,2,1,1};

	*(LONG *) (d.intin)	= errcode;
	d.addrin[0]	= errfile;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (160)	wdlg_create
*
****************************************************************/

void *wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree,
				void *user_data, WORD code,
				void *data, WORD flags )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {160,2,0,4};

	d.intin[0]	= code;
	d.intin[1]	= flags;
	d.addrin[0]	= handle_exit;
	d.addrin[1]	= tree;
	d.addrin[2]	= user_data;
	d.addrin[3]	= data;
	__aes( &pb, &d, c );
	return(d.addrout[0]);
}


/****************************************************************
*
* (161)	wdlg_open
*
****************************************************************/

WORD wdlg_open( void *dialog, char *title, WORD kind,
			WORD x, WORD y, WORD code, void *data )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {161,4,1,3};

	d.intin[0]	= kind;
	d.intin[1]	= x;
	d.intin[2]	= y;
	d.intin[3]	= code;
	d.addrin[0]	= dialog;
	d.addrin[1]	= title;
	d.addrin[2]	= data;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (162)	wdlg_close
*
****************************************************************/

WORD wdlg_close( void *dialog )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {162,0,1,1};

	d.addrin[0]	= dialog;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (163)	wdlg_delete
*
****************************************************************/

WORD wdlg_delete( void *dialog )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {163,0,1,1};

	d.addrin[0]	= dialog;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (164)	wdlg_get
*
****************************************************************/

WORD wdlg_get_tree( void *dialog, OBJECT **tree, GRECT *r )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {164,1,1,3};

	d.intin[0]	= 0;
	d.addrin[0]	= dialog;
	d.addrin[1]	= tree;
	d.addrin[2]	= r;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}
WORD wdlg_get_edit( void *dialog, WORD *cursor )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {164,1,2,1};

	d.intin[0]	= 1;
	d.addrin[0]	= dialog;
	__aes( &pb, &d, c );
	*cursor		= d.intout[1];
	return(d.intout[0]);
}
void *wdlg_get_udata( void *dialog )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {164,1,0,1};

	d.intin[0]	= 2;
	d.addrin[0]	= dialog;
	__aes( &pb, &d, c );
	return(d.addrout[0]);
}
WORD wdlg_get_handle( void *dialog )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {164,1,1,1};

	d.intin[0]	= 3;
	d.addrin[0]	= dialog;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (165)	wdlg_set
*
****************************************************************/

WORD wdlg_set_edit( void *dialog, WORD obj )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {165,2,1,1};

	d.intin[0]	= 0;
	d.intin[1]	= obj;
	d.addrin[0]	= dialog;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}
WORD wdlg_set_tree( void *dialog, OBJECT *new_tree )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {165,1,1,2};

	d.intin[0]	= 1;
	d.addrin[0]	= dialog;
	d.addrin[1]	= new_tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}
WORD wdlg_set_size( void *dialog, GRECT *new_size )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {165,1,1,2};

	d.intin[0]	= 2;
	d.addrin[0]	= dialog;
	d.addrin[1]	= new_size;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}
WORD wdlg_set_iconify( void *dialog, GRECT *g,
					char *title, OBJECT *tree, WORD obj )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {165,2,1,4};

	d.intin[0]	= 3;
	d.intin[1]	= obj;
	d.addrin[0]	= dialog;
	d.addrin[1]	= g;
	d.addrin[2]	= title;
	d.addrin[3]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}
WORD wdlg_set_uniconify( void *dialog, GRECT *g,
					char *title, OBJECT *tree )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {165,1,1,4};

	d.intin[0]	= 4;
	d.addrin[0]	= dialog;
	d.addrin[1]	= g;
	d.addrin[2]	= title;
	d.addrin[3]	= tree;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (166)	wdlg_evnt
*
****************************************************************/

WORD wdlg_evnt( void *dialog, EVNT *events )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {166,0,1,2};

	d.addrin[0]	= dialog;
	d.addrin[1]	= events;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (167)	wdlg_redraw
*
****************************************************************/

void wdlg_redraw( void *dialog, GRECT *rect, WORD obj, WORD depth )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {167,2,0,2};

	d.intin[0]	= obj;
	d.intin[1]	= depth;
	d.addrin[0]	= dialog;
	d.addrin[1]	= rect;
	__aes( &pb, &d, c );
}



/****************************************************************
*
* (170)	lbox_create
*
****************************************************************/

void *lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set,
				LBOX_ITEM *items, WORD visible_a, WORD first_a,
				WORD *ctrl_objs, WORD *objs, WORD flags,
				WORD pause_a, void *user_data, void *dialog,
				WORD visible_b, WORD first_b,
				WORD entries_b, WORD pause_b )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {170,8,0,8};

	d.intin[0]	= visible_a;
	d.intin[1]	= first_a;
	d.intin[2]	= flags;
	d.intin[3]	= pause_a;
	d.intin[4]	= visible_b;
	d.intin[5]	= first_b;
	d.intin[6]	= entries_b;
	d.intin[7]	= pause_b;
	d.addrin[0]	= tree;
	d.addrin[1]	= slct;
	d.addrin[2]	= set;
	d.addrin[3]	= items;
	d.addrin[4]	= ctrl_objs;
	d.addrin[5]	= objs;
	d.addrin[6]	= user_data;
	d.addrin[7]	= dialog;
	__aes( &pb, &d, c );
	return(d.addrout[0]);
}


/****************************************************************
*
* (171)	lbox_update
*
****************************************************************/

void lbox_update( void *box, GRECT *rect )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {171,0,0,2};

	d.addrin[0]	= box;
	d.addrin[1]	= rect;
	__aes( &pb, &d, c );
}


/****************************************************************
*
* (172)	lbox_do
*
****************************************************************/

WORD lbox_do( void *box, WORD obj )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {172,1,1,1};

	d.intin[0]	= obj;
	d.addrin[0]	= box;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (173)	lbox_delete
*
****************************************************************/

WORD lbox_delete( void *box )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {173,0,1,1};

	d.addrin[0]	= box;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (174)	lbox_get
*
****************************************************************/

WORD lbox_cnt_items( void *box )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {174,1,1,1};

	d.intin[0]	= 0;
	d.addrin[0]	= box;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}
OBJECT  *lbox_get_tree( void *box )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {174,1,0,1};

	d.intin[0]	= 1;
	d.addrin[0]	= box;
	__aes( &pb, &d, c );
	return(d.addrout[0]);
}
WORD lbox_get_visible( void *box )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {174,1,1,1};

	d.intin[0]	= 2;
	d.addrin[0]	= box;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}
void *lbox_get_udata( void *box )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {174,1,0,1};

	d.intin[0]	= 3;
	d.addrin[0]	= box;
	__aes( &pb, &d, c );
	return(d.addrout[0]);
}
WORD lbox_get_first( void *box )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {174,1,1,1};

	d.intin[0]	= 4;
	d.addrin[0]	= box;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}
WORD lbox_get_slct_idx( void *box )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {174,1,1,1};

	d.intin[0]	= 5;
	d.addrin[0]	= box;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}
LBOX_ITEM  *lbox_get_items( void *box )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {174,1,0,1};

	d.intin[0]	= 6;
	d.addrin[0]	= box;
	__aes( &pb, &d, c );
	return(d.addrout[0]);
}
LBOX_ITEM  *lbox_get_item( void *box, WORD n )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {174,2,0,1};

	d.intin[0]	= 7;
	d.intin[1]	= n;
	d.addrin[0]	= box;
	__aes( &pb, &d, c );
	return(d.addrout[0]);
}
LBOX_ITEM *lbox_get_slct_item( void *box )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {174,1,0,1};

	d.intin[0]	= 8;
	d.addrin[0]	= box;
	__aes( &pb, &d, c );
	return(d.addrout[0]);
}
WORD lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {174,1,1,2};

	d.intin[0]	= 9;
	d.addrin[0]	= items;
	d.addrin[1]	= search;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}
WORD lbox_get_bvis( void *box )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {174,1,1,1};

	d.intin[0]	= 10;
	d.addrin[0]	= box;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}
WORD lbox_get_bentries( void *box )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {174,1,1,1};

	d.intin[0]	= 11;
	d.addrin[0]	= box;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}
WORD lbox_get_bfirst( void *box )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {174,1,1,1};

	d.intin[0]	= 12;
	d.addrin[0]	= box;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (175)	lbox_set
*
****************************************************************/

void lbox_set_slider( void *box, WORD first, GRECT *rect )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {175,2,0,2};

	d.intin[0]	= 0;
	d.intin[1]	= first;
	d.addrin[0]	= box;
	d.addrin[1]	= rect;
	__aes( &pb, &d, c );
}
void lbox_set_items( void *box, LBOX_ITEM *items )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {175,1,0,2};

	d.intin[0]	= 1;
	d.addrin[0]	= box;
	d.addrin[1]	= items;
	__aes( &pb, &d, c );
}
void lbox_free_items( void *box )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {175,1,0,1};

	d.intin[0]	= 2;
	d.addrin[0]	= box;
	__aes( &pb, &d, c );
}
void lbox_free_list( LBOX_ITEM *items )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {175,1,0,1};

	d.intin[0]	= 3;
	d.addrin[0]	= items;
	__aes( &pb, &d, c );
}
void lbox_scroll_to( void *box, WORD first, GRECT *box_rect,
			GRECT *slider_rect )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {175,2,0,3};

	d.intin[0]	= 4;
	d.intin[1]	= first;
	d.addrin[0]	= box;
	d.addrin[1]	= box_rect;
	d.addrin[2]	= slider_rect;
	__aes( &pb, &d, c );
}
void lbox_set_bsldr( void *box, WORD first, GRECT *rect )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {175,2,0,2};

	d.intin[0]	= 5;
	d.intin[1]	= first;
	d.addrin[0]	= box;
	d.addrin[1]	= rect;
	__aes( &pb, &d, c );
}
void lbox_set_bentries( void *box, WORD entries )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {175,2,0,1};

	d.intin[0]	= 6;
	d.intin[1]	= entries;
	d.addrin[0]	= box;
	__aes( &pb, &d, c );
}
void lbox_bscroll_to( void *box, WORD first, GRECT *box_rect,
		GRECT *slider_rect )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {175,2,0,3};

	d.intin[0]	= 7;
	d.intin[1]	= first;
	d.addrin[0]	= box;
	d.addrin[1]	= box_rect;
	d.addrin[2]	= slider_rect;
	__aes( &pb, &d, c );
}


/****************************************************************
*
* (180)	fnts_create
*
****************************************************************/

void *fnts_create(WORD vdi_handle, WORD no_fonts, WORD font_flags,
			WORD dialog_flags, char *sample, char *opt_button )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {180,4,0,4};

	d.intin[0] = vdi_handle;
	d.intin[1] = no_fonts;
	d.intin[2] = font_flags;
	d.intin[3] = dialog_flags;
	d.addrin[0] = sample;
	d.addrin[1] = opt_button;
	__aes( &pb, &d, c );
	return(d.addrout[0]);
}


/****************************************************************
*
* (181)	fnts_delete
*
****************************************************************/

int fnts_delete( void *fnt_dialog, WORD vdi_handle )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {181,1,1,1};

	d.intin[0] = vdi_handle;
	d.addrin[0] = fnt_dialog;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (182)	fnts_open
*
****************************************************************/

WORD fnts_open( void *fnt_dialog, WORD button_flags,
			WORD x, WORD y, LONG id, LONG pt, LONG ratio )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {182,9,1,1};

	d.intin[0] = button_flags;
	d.intin[1] = x;
	d.intin[2] = y;
	*((LONG *)(d.intin+3))	= id;
	*((LONG *)(d.intin+5))	= pt;
	*((LONG *)(d.intin+7))	= ratio;
	d.addrin[0] = fnt_dialog;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (183)	fnts_close
*
****************************************************************/

WORD fnts_close( void *fnt_dialog )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {183,0,1,1};

	d.addrin[0] = fnt_dialog;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (184)	fnts_get_info
*
****************************************************************/

WORD fnts_get_no_styles( void *fnt_dialog, LONG id )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {184,3,1,1};

	d.intin[0] = 0;
	*((LONG *) (d.intin+1)) = id;
	d.addrin[0] = fnt_dialog;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}
LONG fnts_get_style( void *fnt_dialog, LONG id, WORD index )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {184,4,1,1};

	d.intin[0] = 1;
	*((LONG *) (d.intin+1)) = id;
	d.intin[3] = index;
	d.addrin[0] = fnt_dialog;
	__aes( &pb, &d, c );
	return(*((LONG *) (d.intout+0)));
}
WORD fnts_get_name( void *fnt_dialog, LONG id,
				BYTE *full_name, BYTE *family_name,
				BYTE *style_name )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {184,3,1,4};

	d.intin[0] = 2;
	*((LONG *) (d.intin+1)) = id;
	d.addrin[0] = fnt_dialog;
	d.addrin[0] = full_name;
	d.addrin[0] = family_name;
	d.addrin[0] = style_name;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}
WORD fnts_get_info( void *fnt_dialog, LONG id,
			WORD *mono, WORD *outline )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {184,3,0,1};

	d.intin[0] = 3;
	*((LONG *) (d.intin+1)) = id;
	d.addrin[0] = fnt_dialog;
	__aes( &pb, &d, c );
	*mono = d.intout[1];
	*outline = d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (185)	fnts_set
*
****************************************************************/

WORD fnts_add( void *fnt_dialog, FNTS_ITEM *user_fonts )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {185,1,1,2};

	d.intin[0] = 0;
	d.addrin[0] = fnt_dialog;
	d.addrin[1] = user_fonts;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}
void fnts_remove( void *fnt_dialog )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {185,1,0,1};

	d.intin[0] = 1;
	d.addrin[0] = fnt_dialog;
	__aes( &pb, &d, c );
}


/****************************************************************
*
* (186)	fnts_evnt
*
****************************************************************/

WORD fnts_evnt( void *fnt_dialog, EVNT *events, WORD *button,
		WORD *check_boxes, LONG *id, LONG *pt, LONG *ratio )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {186,0,9,2};

	d.addrin[0] = fnt_dialog;
	d.addrin[1] = events;
	__aes( &pb, &d, c );
	*button		= d.intout[1];
	*check_boxes	= d.intout[2];
	*id			= *((LONG *)(d.intout+3));
	*pt			= *((LONG *)(d.intout+5));
	*ratio		= *((LONG *)(d.intout+7));
	return(d.intout[0]);
}


/****************************************************************
*
* (182)	fnts_do
*
****************************************************************/

int fnts_do( void *fnt_dialog, WORD button_flags, LONG id_in,
			LONG pt_in, LONG ratio_in,
			WORD *check_boxes, LONG *id, LONG *pt, LONG *ratio )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {182,7,0,1};

	d.intin[0] = button_flags;
	*((LONG *) (d.intin+1)) = id_in;
	*((LONG *) (d.intin+3)) = pt_in;
	*((LONG *) (d.intin+5)) = ratio_in;
	d.addrin[0] = fnt_dialog;
	__aes( &pb, &d, c );
	*check_boxes = d.intout[1];
	*id = *((LONG *) (d.intout+2));
	*pt = *((LONG *) (d.intout+4));
	*ratio = *((LONG *) (d.intout+6));
	return(d.intout[0]);
}


/****************************************************************
*
* (190)	fslx_open
*
****************************************************************/

void * fslx_open(
			char *title,
			WORD x, WORD y,
			WORD	*handle,
			char *path, WORD pathlen,
			char *fname, WORD fnamelen,
			char *patterns,
			XFSL_FILTER *filter,
			char *paths,
			WORD sort_mode,
			WORD flags)
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {190,6,1,6};

	WORD *intin = d.intin;
	void **addrin = d.addrin;

	*intin++ = x;
	*intin++ = y;
	*intin++ = pathlen;
	*intin++ = fnamelen;
	*intin++ = sort_mode;
	*intin = flags;

	*addrin++ = title;
	*addrin++ = path;
	*addrin++ = fname;
	*addrin++ = patterns;
	*addrin++ = filter;
	*addrin = paths;

	__aes( &pb, &d, c );

	*handle = d.intout[0];
	return(d.addrout[0]);
}


/****************************************************************
*
* (191)	fslx_close
*
****************************************************************/

WORD fslx_close( void *fsd )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {191,0,1,1};

	d.addrin[0] = fsd;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (192)	fslx_getnxtfile
*
****************************************************************/

WORD fslx_getnxtfile(
			void *fsd,
			char *fname
			)
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {192,0,1,2};

	d.addrin[0] = fsd;
	d.addrin[1] = fname;
	__aes( &pb, &d, c );
	return(d.intout[0]);
}


/****************************************************************
*
* (193)	fslx_evnt
*
****************************************************************/

WORD fslx_evnt(
			void *fsd,
			EVNT *events,
			char *path,
			char *fname,
			WORD *button,
			WORD *nfiles,
			WORD *sort_mode,
			char **pattern )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {193,0,4,4};

	void **addrin = d.addrin;

	*addrin++ = fsd;
	*addrin++ = events;
	*addrin++ = path;
	*addrin = fname;
	__aes( &pb, &d, c );
	*button = d.intout[1];
	*nfiles = d.intout[2];
	*sort_mode = d.intout[3];
	*pattern = d.addrout[0];

	return(d.intout[0]);
}


/****************************************************************
*
* (194)	fslx_do
*
****************************************************************/

void * fslx_do(
			char *title,
			char *path, WORD pathlen,
			char *fname, WORD fnamelen,
			char *patterns,
			XFSL_FILTER *filter,
			char *paths,
			WORD *sort_mode,
			WORD flags,
			WORD *button,
			WORD *nfiles,
			char **pattern )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {194,4,4,6};

	WORD *intin = d.intin;
	void **addrin = d.addrin;

	*intin++ = pathlen;
	*intin++ = fnamelen;
	*intin++ = *sort_mode;
	*intin = flags;

	*addrin++ = title;
	*addrin++ = path;
	*addrin++ = fname;
	*addrin++ = patterns;
	*addrin++ = filter;
	*addrin = paths;

	__aes( &pb, &d, c );

	*button = d.intout[1];
	*nfiles = d.intout[2];
	*sort_mode = d.intout[3];

	*pattern = d.addrout[1];
	return(d.addrout[0]);
}


/****************************************************************
*
* (195)	fslx_set_flags
*
****************************************************************/

extern WORD fslx_set_flags(
			WORD flags,
			WORD *oldval )
{
	AESPB pb;
	PARMDATA d;
	static WORD c[] = {195,2,2,0};

	d.intin[0] = 0;
	d.intin[1] = flags;
	__aes( &pb, &d, c );
	*oldval = d.intout[1];
	return(d.intout[0]);
}
