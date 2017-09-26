/*----------------------------------------------------------------------------------------
	aes.c, part of TOS Linker for CodeWarrior

	AES system calls for TOS
	
	27.10.1998 by Manfred Lippert
	based on MT_AES from Andreas Kromke

	last change: 11.2.1999

	Don't edit this file.

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#include <aes.h>

/****************************************************************
*
* (0)		recalc_cicon_colours - ab MagiC 5.20 vom 20.11.97!
*
****************************************************************/

void recalc_cicon_colours( int16 palette[256][3], int16 *global ) {
	PARMDATA d;
	static int16 c[] = {0, 1, 1, 0};
	d.intin[0] = 5;
	d.addrin[0] = palette;
	_mt_aes( &d, c, global);
}

/****************************************************************
*
* (10)	appl_init
*
****************************************************************/

int16	appl_init( int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 10, 0, 1, 0 };

	d.intout[0] = -1;			/* for case of no AES */
	_mt_aes( &d, c, global );
	return( d.intout[0] );
}


/****************************************************************
*
* (11)	appl_read
*
****************************************************************/

int16 appl_read( int16 apid, int16 len, void *buf, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {11,2,1,1};

	d.intin[0]	= apid;
	d.intin[1]	= len;
	d.addrin[0]	= buf;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (12)	appl_write
*
****************************************************************/

int16 appl_write( int16 apid, int16 len, void *buf, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {12,2,1,1};

	d.intin[0]	= apid;
	d.intin[1]	= len;
	d.addrin[0]	= buf;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (13)	appl_find
*
****************************************************************/

int16 appl_find( char *apname, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {13,0,1,1};

	d.addrin[0]	= apname;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (14)	appl_tplay
*
****************************************************************/

int16 appl_tplay( void *mem, int16 len, int16 scale, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {14,2,1,1};

	d.intin[0]	= len;
	d.intin[1]	= scale;
	d.addrin[0]	= mem;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (15)	appl_trecord
*
****************************************************************/

int16 appl_trecord( void *mem, int16 len, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {15,1,1,1};

	d.intin[0]	= len;
	d.addrin[0]	= mem;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (16)	appl_bvset
*
****************************************************************/

/* ignored */


/****************************************************************
*
* (17)	appl_yield
*
****************************************************************/

void appl_yield( int16 *global )
{
	PARMDATA d;
	static int16 c[] = {17,0,1,0};

	_mt_aes( &d, c, global );
}


/****************************************************************
*
* (18)	appl_search
*
****************************************************************/

int16 appl_search( int16 mode, char *name, int16 *type, int16 *id,
						int16 *global )
{
	PARMDATA d;
	static int16 c[] = {18,1,3,1};

	d.intin[0]	= mode;
	d.addrin[0]	= name;
	_mt_aes( &d, c, global );
	*type	= d.intout[1];
	*id = d.intout[2];
	return( d.intout[0] );
}


/****************************************************************
*
* (19)	appl_exit
*
****************************************************************/

int16 appl_exit( int16 *global )
{
	PARMDATA d;
	static int16 c[] = {19,0,1,0};

	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (130)	appl_getinfo
*
****************************************************************/

int16	appl_getinfo( int16 ap_gtype,
				int16 *ap_gout1, int16 *ap_gout2,
				int16 *ap_gout3, int16 *ap_gout4, int16 *global )
{
	PARMDATA d;
	static int16 c[] = { 130, 1, 5,0 };

	d.intin[0]	= ap_gtype;
	_mt_aes( &d, c, global );

	if ( ap_gout1 )
		*ap_gout1 = d.intout[1];
	if ( ap_gout2 )
		*ap_gout2 = d.intout[2];
	if ( ap_gout3 )
		*ap_gout3 = d.intout[3];
	if ( ap_gout4 )
		*ap_gout4 = d.intout[4];

	return( d.intout[0] );
}


/****************************************************************
*
* (20)	evnt_keybd
*
****************************************************************/

int16 evnt_keybd( int16 *global )
{
	PARMDATA d;
	static int16 c[] = {20,0,1,0};

	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (21)	evnt_button
*
****************************************************************/

int16 evnt_button( int16 nclicks, int16 mask, int16 state,
				EVNTDATA *ev, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {21,3,5,0};

	d.intin[0]	= nclicks;
	d.intin[1]	= mask;
	d.intin[2]	= state;
	_mt_aes( &d, c, global );
	ev->x = d.intout[1];
	ev->y = d.intout[2];
	ev->bstate = d.intout[3];
	ev->kstate = d.intout[4];
	return(d.intout[0]);			/* nclicks */
}


/****************************************************************
*
* (22)	evnt_mouse
*
****************************************************************/

int16 evnt_mouse( int16 flg_leave, GRECT16 *g, EVNTDATA *ev,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = {22,5,5,0};

	d.intin[0]	= flg_leave;
	*((GRECT16 *)(d.intin+1))	= *g;
	_mt_aes( &d, c, global );
	ev->x = d.intout[1];
	ev->y = d.intout[2];
	ev->bstate = d.intout[3];
	ev->kstate = d.intout[4];
	return(d.intout[0]);
}


/****************************************************************
*
* (23)	evnt_mesag
*
****************************************************************/

int16 evnt_mesag( int16 *buf, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {23,0,1,1};

	d.addrin[0]	= buf;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (24)	evnt_timer
*
****************************************************************/

int16 evnt_timer( uint32 ms, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {24,2,1,0};

	d.intin[0] = (int16) ms;			/* Intel: erst Low */
	d.intin[1] = (int16) (ms>>16L);	/* Intel: dann High */
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (25)	evnt_multi
*
****************************************************************/

int16 evnt_multi(
			int16 evtypes,
			int16 nclicks, int16 bmask, int16 bstate,
			int16 flg1_leave, GRECT16 *g1,
			int16 flg2_leave, GRECT16 *g2,
			int16 *msgbuf,
			uint32 ms,
			EVNTDATA *ev,
			int16 *keycode,
			int16 *nbclicks,
			int16 *global
			)
{
	PARMDATA d;
	static int16 c[] = {25,16,7,1};

	d.intin[0] = evtypes;
	d.intin[1] = nclicks;
	d.intin[2] = bmask;
	d.intin[3] = bstate;

	if	( evtypes & MU_M1 )
	{
		d.intin[4] = flg1_leave;
		*((GRECT16 *)(d.intin+5))	= *g1;
	}

	if	( evtypes & MU_M2 )
	{
		d.intin[9] = flg2_leave;
		*((GRECT16 *)(d.intin+10)) = *g2;
	}

	d.intin[14] = (int16) ms;			/* Intel: first low */
	d.intin[15] = (int16) (ms>>16L);	/* Intel: then high */
	d.addrin[0] = msgbuf;
	_mt_aes( &d, c, global );
	ev->x		= d.intout[1];
	ev->y		= d.intout[2];
	ev->bstate	= d.intout[3];
	ev->kstate	= d.intout[4];
	*keycode		= d.intout[5];
	*nbclicks		= d.intout[6];
	return(d.intout[0]);
}

void	EVNT_multi( int16 evtypes, int16 nclicks, int16 bmask, int16 bstate,
							MOBLK *m1, MOBLK *m2, uint32 ms,
							EVNT *event, int16 *global )
{
	static int16	c[] = { 25, 16, 7, 1 };
	PARMDATA	d;
	int16	*intout;
	int16	*ev;

	d.intin[0] = evtypes;
	d.intin[1] = nclicks;
	d.intin[2] = bmask;
	d.intin[3] = bstate;

	if	( evtypes & MU_M1 )					/* maus rectangle 1? */
		*((MOBLK *)( d.intin + 4 )) = *m1;

	if	( evtypes & MU_M2 )					/* maus rectangle 2? */
		*((MOBLK *)( d.intin + 9 )) = *m2;

	d.intin[14] = (int16) ms;				/* swap words */
	d.intin[15] = (int16) ( ms >> 16L );
	d.addrin[0] = event->msg;				/* message buffer */
	_mt_aes( &d, c, global );

	ev = (int16 *) event;					/* EVNT-Struktur besetzen */
	intout = d.intout;
	*ev++ = *intout++;						/* mwhich */
	*ev++ = *intout++;						/* mx */
	*ev++ = *intout++;						/* my */
	*ev++ = *intout++;						/* mbutton */
	*ev++ = *intout++;						/* kstate */
	*ev++ = *intout++;						/* key */
	*ev++ = *intout++;						/* mclicks */
}

/* fastest version: */
int16 EvntMulti(EVENT *evnt_struct, int16 *global) {
	PARMDATA d;
	static int16 c[] = {25,16,7,1};
/*	memcpy(d.intin, evnt_struct, 16 * sizeof(int16)); */
	*(EVENT_in *)&d.intin = evnt_struct->i;
	d.addrin[0] = &evnt_struct->msg[0];
	_mt_aes( &d, c, global );
/*	memcpy(&evnt_struct->which, d.intout, 7 * sizeof(int16)); */
	evnt_struct->o = *(EVENT_out *)&d.intout;
	return(d.intout[0]);
}

/****************************************************************
*
* (26)	evnt_dclick
*
****************************************************************/

int16 evnt_dclick( int16 val, int16 setflg, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {26,2,1,0};

	d.intin[0] = val;
	d.intin[1] = setflg;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (30)	menu_bar
*
****************************************************************/

int16 menu_bar( OBJECT *tree, int16 show, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {30,1,1,1};

	d.intin[0] 	= show;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (31)	menu_icheck
*
****************************************************************/

int16 menu_icheck( OBJECT *tree, int16 objnr, int16 chkflg,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = {31,2,1,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= chkflg;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (32)	menu_ienable
*
****************************************************************/

int16 menu_ienable( OBJECT *tree, int16 objnr, int16 chkflg,
					int16 *global )
{
	PARMDATA d;
	static int16 c[] = {32,2,1,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= chkflg;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (33)	menu_tnormal
*
****************************************************************/

int16 menu_tnormal( OBJECT *tree, int16 objnr, int16 chkflg,
					int16 *global )
{
	PARMDATA d;
	static int16 c[] = {33,2,1,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= chkflg;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (34)	menu_text
*
****************************************************************/

int16 menu_text( OBJECT *tree, int16 objnr, const char *text,
			int16 *global )
{
	PARMDATA d;
	static int16 c[] = {34,1,1,2};

	d.intin[0]  = objnr;
	d.addrin[0] = tree;
	d.addrin[1] = (void *)text;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (35)	menu_register
*
****************************************************************/

int16 menu_register( int16 apid, const char *text, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {35,1,1,1};

	d.intin[0] 	= apid;
	d.addrin[0]	= (void *)text;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (36)	menu_unregister
*
****************************************************************/

int16 menu_unregister( int16 menuid, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {36,1,1,0};

	d.intin[0] 	= menuid;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
*  		menu_popup
*
****************************************************************/

int16 menu_popup( MENU *menu, int16 x, int16 y, MENU *data,
				int16 *global)
{
	PARMDATA d;
	static int16 c[] = {36,2,1,2};

	d.intin[0] 	= x;
	d.intin[1] 	= y;
	d.addrin[0] 	= menu;
	d.addrin[1] 	= data;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (37)	menu_click
*
****************************************************************/

int16 menu_click( int16 val, int16 setflag, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {37,2,1,0};


	d.intin[0] 	= val;
	d.intin[1] 	= setflag;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* 		menu_attach
*
****************************************************************/

int16 menu_attach( int16 flag, OBJECT *tree, int16 obj,
				MENU *data, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {37,2,1,2};

	d.intin[0] 	= flag;
	d.intin[1] 	= obj;
	d.addrin[0] 	= tree;
	d.addrin[1] 	= data;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (38)	menu_istart
*
****************************************************************/

int16 menu_istart( int16 flag, OBJECT *tree, int16 menu, int16 item,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = {38,3,1,1};

	d.intin[0] 	= flag;
	d.intin[1] 	= menu;
	d.intin[2] 	= item;
	d.addrin[0] 	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (39)	menu_settings
*
****************************************************************/

int16 menu_settings( int16 flag, MN_SET *values, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {39,1,1,1};

	d.intin[0] 	= flag;
	d.addrin[0] 	= values;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (40)	objc_add
*
****************************************************************/

int16 objc_add( OBJECT *tree, int16 parent, int16 child, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {40,2,1,1};

	d.intin[0] 	= parent;
	d.intin[1] 	= child;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (41)	objc_delete
*
****************************************************************/

int16 objc_delete( OBJECT *tree, int16 objnr, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {41,1,1,1};

	d.intin[0] 	= objnr;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (42)	objc_draw
*
****************************************************************/

int16 objc_draw( OBJECT *tree, int16 start, int16 depth, GRECT16 *g,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = {42,6,1,1};

	d.intin[0] 	= start;
	d.intin[1] 	= depth;
	*((GRECT16 *)(d.intin+2))	= *g;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (43)	objc_find
*
****************************************************************/

int16 objc_find( OBJECT *tree, int16 start, int16 depth,
				int16 x, int16 y, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {43,4,1,1};

	d.intin[0] 	= start;
	d.intin[1] 	= depth;
	d.intin[2] 	= x;
	d.intin[3] 	= y;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (44)	objc_offset
*
****************************************************************/

int16 objc_offset( OBJECT *tree, int16 objnr, int16 *x, int16 *y,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = {44,1,3,1};

	d.intin[0] 	= objnr;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	*x	= d.intout[1];
	*y	= d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (45)	objc_order
*
****************************************************************/

int16 objc_order( OBJECT *tree, int16 objnr, int16 newpos, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {45,2,1,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= newpos;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (46)	objc_edit
*
****************************************************************/

int16 objc_edit( OBJECT *tree, int16 objnr, int16 key,
				int16 *cursor_xpos, int16 subfn, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {46,4,2,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= key;
	d.intin[2] 	= *cursor_xpos;
	d.intin[3] 	= subfn;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	*cursor_xpos	= d.intout[1];
	return(d.intout[0]);
}

int16 objc_xedit( OBJECT *tree, int16 objnr, int16 key,
				int16 *cursor_xpos, int16 subfn, GRECT16 *r, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {46,4,2,2};

	d.intin[0] 	= objnr;
	d.intin[1] 	= key;
	d.intin[2] 	= *cursor_xpos;
	d.intin[3] 	= subfn;
	d.addrin[0]	= tree;
	d.addrin[1]	= r;
	_mt_aes( &d, c, global );
	*cursor_xpos	= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (47)	objc_change
*
****************************************************************/

int16 objc_change( OBJECT *tree, int16 objnr, int16 resvd,
				GRECT16 *g, int16 newstate, int16 redraw, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {47,8,1,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= resvd;		/* ggf. später: WindowHandle */
	*((GRECT16 *)(d.intin+2))	= *g;
	d.intin[6] 	= newstate;
	d.intin[7] 	= redraw;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (48)	objc_sysvar
*
****************************************************************/

int16	objc_sysvar( int16 ob_smode, int16 ob_swhich, int16 ob_sival1,
				int16 ob_sival2, int16 *ob_soval1, int16 *ob_soval2,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = {48,4,3,0};

	d.intin[0] = ob_smode;
	d.intin[1] = ob_swhich;
	d.intin[2] = ob_sival1;
	d.intin[3] = ob_sival2;
	_mt_aes( &d, c, global );
	*ob_soval1 = d.intout[1];
	*ob_soval2 = d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (50)	form_(x)do
*
****************************************************************/

int16 form_do( OBJECT *tree, int16 startob, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {50,1,1,1};

	d.intin[0] 	= startob;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16 form_xdo( OBJECT *tree, int16 startob,
			int16 *cursor_obj,
			XDO_INF *scantab, void *flyinf,
			int16 *global )
{
	PARMDATA d;
	static int16 c[] = {50,1,2,3};

	d.intin[0] 	= startob;
	d.addrin[0]	= tree;
	d.addrin[1]	= scantab;
	d.addrin[2]	= flyinf;
	_mt_aes( &d, c, global );
	*cursor_obj	= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (51)	form_(x)dial
*
****************************************************************/

int16	form_dial( int16 subfn, GRECT16 *lg, GRECT16 *bg, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {51,9,1,0};

	d.intin[0] 	= subfn;
	if	(lg) {
		*((GRECT16 *)(d.intin+1))	= *lg;
	} else {
		*(int32 *)(d.intin+1) = 0L;	/* problems with Alice */
		*(int32 *)(d.intin+3) = 0L;
	}
	*((GRECT16 *)(d.intin+5))	= *bg;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16 form_xdial( int16 subfn, GRECT16 *lg, GRECT16 *bg,
				void **flyinf,	int16 *global )
{
	PARMDATA d;
	static int16 c[] = {51,9,1,2};

	d.intin[0] 	= subfn;
	if	(lg) {
		*((GRECT16 *)(d.intin+1))	= *lg;
	} else {
		*(int32 *)(d.intin+1) = 0L;	/* problems with alice */
		*(int32 *)(d.intin+3) = 0L;
	}
	*((GRECT16 *)(d.intin+5))	= *bg;
	d.addrin[0]	= flyinf;
	d.addrin[1]	= 0;		/* reserved */
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (52)	form_alert
*
****************************************************************/

int16 form_alert( int16 defbutton, const char *string, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {52,1,1,1};

	d.intin[0] 	= defbutton;
	d.addrin[0]	= (void *)string;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (53)	form_error
*
****************************************************************/

int16 form_error( int16 dosenkot, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {53,1,1,0};

	d.intin[0] 	= dosenkot;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (54)	form_center
*
****************************************************************/

int16 form_center( OBJECT *tree, GRECT16 *g, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {54,0,5,1};

	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	*g = *((GRECT16 *)(d.intout+1));
	return(d.intout[0]);
}


/****************************************************************
*
* (55)	form_keybd
*
****************************************************************/

int16 form_keybd( OBJECT *tree, int16 obj, int16 nxt, int16 key,
				int16 *nextob, int16 *nextchar, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {55,3,3,1};

	d.intin[0]	= obj;
	d.intin[1]	= key;
	d.intin[2]	= nxt;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );

	*nextob		= d.intout[1];
	*nextchar		= d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (56)	form_button
*
****************************************************************/

int16 form_button( OBJECT *tree, int16 obj, int16 nclicks,
				int16 *nextob, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {56,2,2,1};

	d.intin[0]	= obj;
	d.intin[1]	= nclicks;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	*nextob		= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (60)	objc_wdraw	(ab 11.12.96, V5.10)
*
****************************************************************/

void objc_wdraw(	OBJECT *tree, int16 object, int16 depth,
				GRECT16 *clip, int16 windowhandle,
				int16 *global)
{
	PARMDATA d;
	static int16 c[] = {60,3,0,2};

	d.intin[0] = object;
	d.intin[1] = depth;
	d.intin[2] = windowhandle;

	d.addrin[0] = tree;
	d.addrin[1] = clip;

	_mt_aes( &d, c, global );
}


/****************************************************************
*
* (61)	objc_wchange	(ab 11.12.96, V5.10)
*
****************************************************************/

void objc_wchange( OBJECT *tree, int16 object, int16 newstate,
				GRECT16 *clip, int16 windowhandle,
				int16 *global)
{
	PARMDATA d;
	static int16 c[] = {61,3,0,2};

	d.intin[0] = object;
	d.intin[1] = newstate;
	d.intin[2] = windowhandle;

	d.addrin[0] = tree;
	d.addrin[1] = clip;

	_mt_aes( &d, c, global );
}


/****************************************************************
*
* (62)	graf_wwatchbox	(ab 11.12.96, V5.10)
*
****************************************************************/

int16 graf_wwatchbox( OBJECT *tree, int16 object, int16 instate,
				int16 outstate,	int16 windowhandle,
				int16 *global)
{
	PARMDATA d;
	static int16 c[] = {62,4,1,1};

	d.intin[0] = object;
	d.intin[1] = instate;
	d.intin[2] = outstate;
	d.intin[3] = windowhandle;

	d.addrin[0] = tree;

	_mt_aes( &d, c, global );

	return(d.intout[0]);
}


/****************************************************************
*
* (63)	form_wbutton	(ab 11.12.96, V5.10)
*
****************************************************************/

int16 form_wbutton( OBJECT *tree, int16 object, int16 nclicks,
				int16 *nextob, int16 windowhandle,
				int16 *global)
{
	PARMDATA d;
	static int16 c[] = {63,3,2,1};

	d.intin[0] = object;
	d.intin[1] = nclicks;
	d.intin[2] = windowhandle;

	d.addrin[0] = tree;

	_mt_aes( &d, c, global );

	*nextob = d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (64)	form_wkeybd	(ab 11.12.96, V5.10)
*
****************************************************************/

int16 form_wkeybd( OBJECT *tree,	int16 object, int16 nextob,
				int16 ichar, int16 *onextob, int16 *ochar,
				int16 windowhandle,
				int16 *global)
{
	PARMDATA d;
	static int16 c[] = {64,3,3,1};

	d.intin[0] = object;
	d.intin[1] = ichar;
	d.intin[2] = nextob;
	d.intin[3] = windowhandle;

	d.addrin[0] = tree;

	_mt_aes( &d, c, global );

	*ochar = d.intout[2];
	*onextob = d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (65)	objc_wedit	(ab 11.12.96, V5.10)
*
****************************************************************/

int16 objc_wedit( OBJECT *tree, int16 object, int16 edchar,
				int16 *didx, int16 kind, int16 windowhandle,
				int16 *global)
{
	PARMDATA d;
	static int16 c[] = {65,5,2,1};

	d.intin[0] = object;
	d.intin[1] = edchar;
	d.intin[2] = *didx;
	d.intin[3] = kind;
	d.intin[4] = windowhandle;

	d.addrin[0] = tree;

	_mt_aes( &d, c, global );

	*didx = d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (70)	graf_rubberbox
*
****************************************************************/

int16 graf_rubberbox( int16 x, int16 y, int16 begw, int16 begh,
				int16 *endw, int16 *endh, int16 *global)
{
	PARMDATA d;
	static int16 c[] = {70,4,3,0};

	d.intin[0]	= x;
	d.intin[1]	= y;
	d.intin[2]	= begw;
	d.intin[3]	= begh;
	_mt_aes( &d, c, global );
	*endw		= d.intout[1];
	*endh		= d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (71)	graf_dragbox
*
****************************************************************/

int16 graf_dragbox( int16 w, int16 h, int16 begx, int16 begy,
				GRECT16 *g, int16 *endx, int16 *endy, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {71,8,3,0};

	d.intin[0]	= w;
	d.intin[1]	= h;
	d.intin[2]	= begx;
	d.intin[3]	= begy;
	*((GRECT16 *)(d.intin+4))	= *g;
	_mt_aes( &d, c, global );
	*endx		= d.intout[1];
	*endy		= d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (72)	graf_movebox
*
****************************************************************/

int16 graf_movebox( int16 w, int16 h, int16 begx, int16 begy,
				int16 endx, int16 endy, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {72,6,1,0};

	d.intin[0]	= w;
	d.intin[1]	= h;
	d.intin[2]	= begx;
	d.intin[3]	= begy;
	d.intin[4]	= endx;
	d.intin[5]	= endy;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (73)	graf_growbox
*
****************************************************************/

int16 graf_growbox( GRECT16 *startg, GRECT16 *endg, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {73,8,1,0};

	*((GRECT16 *)(d.intin))	= *startg;
	*((GRECT16 *)(d.intin+4))	= *endg;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (74)	graf_shrinkbox
*
****************************************************************/

int16 graf_shrinkbox( GRECT16 *endg, GRECT16 *startg, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {74,8,1,0};

	*((GRECT16 *)(d.intin))	= *endg;
	*((GRECT16 *)(d.intin+4))	= *startg;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (75)	graf_watchbox
*
****************************************************************/

int16 graf_watchbox( OBJECT *tree, int16 obj, int16 instate,
				int16 outstate, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {75,4,1,1};

	d.intin[0]	= 0;
	d.intin[1]	= obj;
	d.intin[2]	= instate;
	d.intin[3]	= outstate;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (76)	graf_slidebox
*
****************************************************************/

int16 graf_slidebox( OBJECT *tree, int16 parent, int16 obj,
				int16 h, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {76,3,1,1};

	d.intin[0]	= parent;
	d.intin[1]	= obj;
	d.intin[2]	= h;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (77)	graf_(x)handle
*
****************************************************************/

int16 graf_handle( int16 *wchar, int16 *hchar,
				int16 *wbox, int16 *hbox, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {77,0,5,0};

	_mt_aes( &d, c, global );
	*wchar	= d.intout[1];
	*hchar	= d.intout[2];
	*wbox	= d.intout[3];
	*hbox	= d.intout[4];
	return(d.intout[0]);
}
int16 graf_xhandle( int16 *wchar, int16 *hchar,
				int16 *wbox, int16 *hbox, int16 *device,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = {77,0,6,0};

	_mt_aes( &d, c, global );
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

int16 graf_mouse( int16 code, MFORM *adr, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {78,1,1,1};

	d.intin[0]	= code;
	d.addrin[0]	= adr;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (79)	graf_mkstate
*
****************************************************************/

int16 graf_mkstate( EVNTDATA *ev, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {79,0,5,0};

	_mt_aes( &d, c, global );
	*ev		= *((EVNTDATA *) (d.intout+1));
	return(d.intout[0]);
}


/****************************************************************
*
* (80)	scrp_read
*
****************************************************************/

int16 scrp_read( char *path, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {80,0,1,1};

	d.addrin[0]	= path;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (81)	scrp_write
*
****************************************************************/

int16 scrp_write( char *path, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {81,0,1,1};

	d.addrin[0]	= path;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (82)	scrp_clear
*
****************************************************************/

int16 scrp_clear( int16 *global )
{
	PARMDATA d;
	static int16 c[] = {82,0,1,0};

	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (90)	fsel_input
*
****************************************************************/

int16 fsel_input( char *path, char *name, int16 *button,
					int16 *global )
{
	PARMDATA d;
	static int16 c[] = {90,0,2,2};

	d.addrin[0]	= path;
	d.addrin[1]	= name;
	_mt_aes( &d, c, global );
	*button	= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (91)	fsel_exinput
*
****************************************************************/

int16 fsel_exinput( char *path, char *name, int16 *button,
				char *label, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {91,0,2,3};

	d.addrin[0]	= path;
	d.addrin[1]	= name;
	d.addrin[2]	= label;
	_mt_aes( &d, c, global );
	*button	= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (100)	wind_create
*
****************************************************************/

int16 wind_create( int16 kind, GRECT16 *maxsize, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {100,5,1,0};

	d.intin[0]	= kind;
	*((GRECT16 *)(d.intin+1))	= *maxsize;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (101)	wind_open
*
****************************************************************/

int16 wind_open( int16 whdl, GRECT16 *g, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {101,5,1,0};

	d.intin[0]	= whdl;
	*((GRECT16 *)(d.intin+1))	= *g;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (102)	wind_close
*
****************************************************************/

int16 wind_close( int16 whdl, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {102,1,1,0};

	d.intin[0]	= whdl;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (103)	wind_delete
*
****************************************************************/

int16 wind_delete( int16 whdl, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {103,1,1,0};

	d.intin[0]	= whdl;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (104)	wind_get
*
****************************************************************/

int16 wind_get( int16 whdl, int16 subfn,
			int16 *g1, int16 *g2, int16 *g3, int16 *g4, int16 *global )
{
	PARMDATA d;
	static int16 c[] = { 104, 3, 5, 0 };	/* 3 (!) intin */

	d.intin[0] = whdl;
	d.intin[1] = subfn;
	if	(g1)
		d.intin[2] = *g1;		/* für WF_DCOLOR */
	_mt_aes( &d, c, global );

	if ( g1 )
		*g1 = d.intout[1];
	if ( g2 )
		*g2 = d.intout[2];
	if ( g3 )
		*g3 = d.intout[3];
	if ( g4 )
		*g4 = d.intout[4];

	return( d.intout[0] );
}

int16 wind_get_rect( int16 whdl, int16 subfn, GRECT16 *g, int16 *global )
{
	PARMDATA d;
	static int16 c[] = { 104, 2, 5, 0 };

	d.intin[0] = whdl;
	d.intin[1] = subfn;
	_mt_aes( &d, c, global );
	*g = *((GRECT16 *) (d.intout+1));

	return( d.intout[0] );
}

int16 wind_get_ptr( int16 whdl, int16 subfn, void **v, int16 *global )
{
	PARMDATA d;
	static int16 c[] = { 104, 2, 5, 0 };

	d.intin[0] = whdl;
	d.intin[1] = subfn;
	_mt_aes( &d, c, global );
	*v = *((void **) (d.intout+1));

	return( d.intout[0] );
}

int16 wind_get_int16( int16 whdl, int16 subfn, int16 *g1, int16 *global )
{
	PARMDATA d;
	static int16 c[] = { 104, 2, 5, 0 };

	d.intin[0] = whdl;
	d.intin[1] = subfn;
	_mt_aes( &d, c, global );
	if ( g1 )
		*g1 = d.intout[1];

	return( d.intout[0] );
}


/****************************************************************
*
* (105)	wind_set
*
****************************************************************/

int16 wind_set( int16 whdl, int16 subfn,
		int16 g1, int16 g2, int16 g3, int16 g4, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {105,6,1,0};

	d.intin[0]	= whdl;
	d.intin[1]	= subfn;
	d.intin[2]	= g1;
	d.intin[3]	= g2;
	d.intin[4]	= g3;
	d.intin[5]	= g4;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16 wind_set_string( int16 whdl, int16 subfn, char *s, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {105,4,1,0};

	d.intin[0]	= whdl;
	d.intin[1]	= subfn;
	*((char **) (d.intin+2)) = s;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16 wind_set_rect( int16 whdl, int16 subfn, GRECT16 *g, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {105,6,1,0};

	d.intout[0] = 1;	/* Workaround um Alice-Bug!!!! Mani 20.4.98 */

	d.intin[0]	= whdl;
	d.intin[1]	= subfn;
	*((GRECT16 *) (d.intin+2)) = *g;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16 wind_set_int( int16 whdl, int16 subfn,
				int16 g1, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {105,4,1,0};

	d.intin[0]	= whdl;
	d.intin[1]	= subfn;
	d.intin[2]	= g1;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16 wind_set_ptr_int( int16 whdl, int16 subfn, void *s,
				int16 g3, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {105,4,1,0};

	d.intin[0]	= whdl;
	d.intin[1]	= subfn;
	*((void **) (d.intin+2)) = s;
	d.intin[4]	= g3;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}




/****************************************************************
*
* (106)	wind_find
*
****************************************************************/

int16 wind_find( int16 x, int16 y, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {106,2,1,0};

	d.intin[0]	= x;
	d.intin[1]	= y;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (107)	wind_update
*
****************************************************************/

int16 wind_update( int16 subfn, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {107,1,1,0};

	d.intin[0]	= subfn;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (108)	wind_calc
*
****************************************************************/

int16 wind_calc( int16 subfn, int16 kind,
			GRECT16 *ing, GRECT16 *outg, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {108,6,5,0};

	d.intin[0]	= subfn;
	d.intin[1]	= kind;
	*((GRECT16 *) (d.intin+2)) = *ing;
	_mt_aes( &d, c, global );
	*outg		= *((GRECT16 *) (d.intout+1));
	return(d.intout[0]);
}


/****************************************************************
*
* (109)	wind_new
*
****************************************************************/

void wind_new( int16 *global )
{
	PARMDATA d;
	static int16 c[] = {109,0,0,0};

	_mt_aes( &d, c, global );
}


/****************************************************************
*
* (110)	rsrc_load
*
****************************************************************/

int16 rsrc_load( char *filename, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {110,0,1,1};

	d.addrin[0]	= filename;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (111)	rsrc_free
*
****************************************************************/

int16 rsrc_free( int16 *global )
{
	PARMDATA d;
	static int16 c[] = {111,0,1,0};

	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (112)	rsrc_gaddr
*
****************************************************************/

int16 rsrc_gaddr( int16 type, int16 index, void *addr, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {112,2,1,0};

	d.intin[0]	= type;
	d.intin[1]	= index;
	_mt_aes( &d, c, global );
	*((void **) addr) = d.addrout[0];
	return(d.intout[0]);
}


/****************************************************************
*
* (113)	rsrc_saddr
*
****************************************************************/

int16 rsrc_saddr( int16 type, int16 index, void *o, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {113,2,1,1};

	d.intin[0]	= type;
	d.intin[1]	= index;
	d.addrin[0]	= o;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (114)	rsrc_obfix
*
****************************************************************/

int16 rsrc_obfix( OBJECT *tree, int16 obj, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {114,1,1,1};

	d.intin[0]	= obj;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (115)	rsrc_obfix
*
****************************************************************/

int16 rsrc_rcfix( RSHDR *rsh, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {115,0,1,1};

	d.addrin[0]	= rsh;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (120)	shel_read
*
****************************************************************/

int16 shel_read( char *cmd, char *tail, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {120,0,1,2};

	d.addrin[0]	= cmd;
	d.addrin[1]	= tail;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (121)	shel_write
*
****************************************************************/

int16 shel_write( int16 doex, int16 isgr, int16 isover,
				char *cmd, char *tail, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {121,3,1,2};

	d.intin[0]	= doex;
	d.intin[1]	= isgr;
	d.intin[2]	= isover;
	d.addrin[0]	= cmd;
	d.addrin[1]	= tail;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (122)	shel_get
*
****************************************************************/

int16 shel_get( char *buf, int16 len, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {122,1,1,1};

	d.intin[0]	= len;
	d.addrin[0]	= buf;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (123)	shel_put
*
****************************************************************/

int16 shel_put( char *buf, int16 len, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {123,1,1,1};

	d.intin[0]	= len;
	d.addrin[0]	= buf;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (124)	shel_find
*
****************************************************************/

int16 shel_find( char *path, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {124,0,1,1};

	d.addrin[0]	= path;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (125)	shel_envrn
*
****************************************************************/

int16 shel_envrn( char **val, char *name, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {125,0,1,2};

	d.addrin[0]	= val;
	d.addrin[1]	= name;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (126)	shel_rdef
*
****************************************************************/

void shel_rdef( char *fname, char *dir, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {126,0,1,2};

	d.addrin[0]	= fname;
	d.addrin[1]	= dir;
	_mt_aes( &d, c, global );
}


/****************************************************************
*
* (127)	shel_wdef
*
****************************************************************/

void shel_wdef( char *fname, char *dir, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {127,0,1,2};

	d.addrin[0]	= fname;
	d.addrin[1]	= dir;
	_mt_aes( &d, c, global );
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

/* ignored */


/****************************************************************
*
* (135)	form_popup
*		xfrm_popup (ab MagiC 5.03)
*
****************************************************************/

int16 form_popup( OBJECT *tree, int16 x, int16 y, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {135,2,1,1};

	d.intin[0]	= x;
	d.intin[1]	= y;
	d.addrin[0]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}
int16 xfrm_popup(	OBJECT *tree, int16 x, int16 y,	int16 firstscrlob,
				int16 lastscrlob, int16 nlines,
				void	CDECL (*init)(OBJECT *tree, int16 scrollpos,
						 int16 nlines, void *param),
				void *param, int16 *lastscrlpos,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = {135,6,2,3};

	d.intin[0]	= x;
	d.intin[1]	= y;
	d.intin[2]	= firstscrlob;
	d.intin[3]	= lastscrlob;
	d.intin[4]	= nlines;
	d.intin[5]	= *lastscrlpos;
	d.addrin[0]	= tree;
	d.addrin[1]	= init;
	d.addrin[2]	= param;

	d.intout[1] = *lastscrlpos;		/* vorbesetzen */

	_mt_aes( &d, c, global );
	*lastscrlpos = d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (136)	form_xerr
*
****************************************************************/

int16 form_xerr( int32 errcode, char *errfile, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {136,2,1,1};

	*(int32 *) (d.intin)	= errcode;
	d.addrin[0]	= errfile;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (160)	wdlg_create
*
****************************************************************/

DIALOG *wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree,
				void *user_data, int16 code, void *data,
				int16 flags, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {160,2,0,4};

	d.intin[0]	= code;
	d.intin[1]	= flags;
	d.addrin[0]	= handle_exit;
	d.addrin[1]	= tree;
	d.addrin[2]	= user_data;
	d.addrin[3]	= data;
	_mt_aes( &d, c, global );
	return (DIALOG *)d.addrout[0];
}


/****************************************************************
*
* (161)	wdlg_open
*
****************************************************************/

int16	wdlg_open( DIALOG *dialog, char *title, int16 kind,
				int16 x, int16 y, int16 code, void *data,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = {161,4,1,3};

	d.intin[0]	= kind;
	d.intin[1]	= x;
	d.intin[2]	= y;
	d.intin[3]	= code;
	d.addrin[0]	= dialog;
	d.addrin[1]	= title;
	d.addrin[2]	= data;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (162)	wdlg_close
*
****************************************************************/

int16	wdlg_close( DIALOG *dialog, int16 *x, int16 *y, int16 *global )
{
	PARMDATA d;
	static int16 c[] = { 162, 0, 3, 1 };

	d.intout[1] = -1;
	d.intout[2] = -1;

	d.addrin[0]	= dialog;
	_mt_aes( &d, c, global );

	if	( x )
		*x = d.intout[1];
	if	( y )
		*y = d.intout[2];

	return( d.intout[0] );
}


/****************************************************************
*
* (163)	wdlg_delete
*
****************************************************************/

int16	wdlg_delete( DIALOG *dialog, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {163,0,1,1};

	d.addrin[0]	= dialog;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (164)	wdlg_get
*
****************************************************************/

int16	wdlg_get_tree( DIALOG *dialog, OBJECT **tree, GRECT16 *r,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = {164,1,1,3};

	d.intin[0]	= 0;
	d.addrin[0]	= dialog;
	d.addrin[1]	= tree;
	d.addrin[2]	= r;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16	wdlg_get_edit( DIALOG *dialog, int16 *cursor, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {164,1,2,1};

	d.intin[0]	= 1;
	d.addrin[0]	= dialog;
	_mt_aes( &d, c, global );
	*cursor		= d.intout[1];
	return(d.intout[0]);
}

void	*wdlg_get_udata( DIALOG *dialog, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {164,1,0,1};

	d.intin[0]	= 2;
	d.addrin[0]	= dialog;
	_mt_aes( &d, c, global );
	return(d.addrout[0]);
}

int16	wdlg_get_handle( DIALOG *dialog, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {164,1,1,1};

	d.intin[0]	= 3;
	d.addrin[0]	= dialog;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (165)	wdlg_set
*
****************************************************************/

int16	wdlg_set_edit( DIALOG *dialog, int16 obj, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {165,2,1,1};

	d.intin[0]	= 0;
	d.intin[1]	= obj;
	d.addrin[0]	= dialog;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16	wdlg_set_tree( DIALOG *dialog, OBJECT *new_tree, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {165,1,1,2};

	d.intin[0]	= 1;
	d.addrin[0]	= dialog;
	d.addrin[1]	= new_tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16	wdlg_set_size( DIALOG *dialog, GRECT16 *new_size, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {165,1,1,2};

	d.intin[0]	= 2;
	d.addrin[0]	= dialog;
	d.addrin[1]	= new_size;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16	wdlg_set_iconify( DIALOG *dialog, GRECT16 *g, char *title,
					OBJECT *tree, int16 obj,	int16 *global )
{
	PARMDATA d;
	static int16 c[] = {165,2,1,4};

	d.intin[0]	= 3;
	d.intin[1]	= obj;
	d.addrin[0]	= dialog;
	d.addrin[1]	= g;
	d.addrin[2]	= title;
	d.addrin[3]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16	wdlg_set_uniconify( DIALOG *dialog, GRECT16 *g, char *title,
					OBJECT *tree, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {165,1,1,4};

	d.intin[0]	= 4;
	d.addrin[0]	= dialog;
	d.addrin[1]	= g;
	d.addrin[2]	= title;
	d.addrin[3]	= tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (166)	wdlg_evnt
*
****************************************************************/

int16	wdlg_evnt( DIALOG *dialog, EVNT *events, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {166,0,1,2};

	d.addrin[0]	= dialog;
	d.addrin[1]	= events;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (167)	wdlg_redraw
*
****************************************************************/

void	wdlg_redraw( DIALOG *dialog, GRECT16 *rect, int16 obj,
				int16 depth, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {167,2,0,2};

	d.intin[0]	= obj;
	d.intin[1]	= depth;
	d.addrin[0]	= dialog;
	d.addrin[1]	= rect;
	_mt_aes( &d, c, global );
}



/****************************************************************
*
* (170)	lbox_create
*
****************************************************************/

LIST_BOX *lbox_create( OBJECT *tree, SLCT_ITEM slct,
					SET_ITEM set, LBOX_ITEM *items,
					int16 visible_a, int16 first_a,
					int16 *ctrl_objs, int16 *objs, int16 flags,
					int16 pause_a, void *user_data,
					void *dialog, int16 visible_b,
					int16 first_b, int16 entries_b,
					int16 pause_b, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {170,8,0,8};

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
	_mt_aes( &d, c, global );
	return (LIST_BOX *)d.addrout[0];
}


/****************************************************************
*
* (171)	lbox_update
*
****************************************************************/

void	lbox_update( LIST_BOX *box, GRECT16 *rect, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {171,0,0,2};

	d.addrin[0]	= box;
	d.addrin[1]	= rect;
	_mt_aes( &d, c, global );
}


/****************************************************************
*
* (172)	lbox_do
*
****************************************************************/

int16	lbox_do( LIST_BOX *box, int16 obj, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {172,1,1,1};

	d.intin[0]	= obj;
	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (173)	lbox_delete
*
****************************************************************/

int16	lbox_delete( LIST_BOX *box, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {173,0,1,1};

	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (174)	lbox_get
*
****************************************************************/

int16	lbox_cnt_items( LIST_BOX *box, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {174,1,1,1};

	d.intin[0]	= 0;
	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

OBJECT  *lbox_get_tree( LIST_BOX *box, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {174,1,0,1};

	d.intin[0]	= 1;
	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
	return (OBJECT *)d.addrout[0];
}

int16	lbox_get_visible( LIST_BOX *box, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {174,1,1,1};

	d.intin[0]	= 2;
	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

void	*lbox_get_udata( LIST_BOX *box, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {174,1,0,1};

	d.intin[0]	= 3;
	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
	return(d.addrout[0]);
}

int16	lbox_get_afirst( LIST_BOX *box, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {174,1,1,1};

	d.intin[0]	= 4;
	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16	lbox_get_slct_idx( LIST_BOX *box, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {174,1,1,1};

	d.intin[0]	= 5;
	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

LBOX_ITEM  *lbox_get_items( LIST_BOX *box, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {174,1,0,1};

	d.intin[0]	= 6;
	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
	return (LBOX_ITEM *)d.addrout[0];
}

LBOX_ITEM  *lbox_get_item( LIST_BOX *box, int16 n, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {174,2,0,1};

	d.intin[0]	= 7;
	d.intin[1]	= n;
	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
	return (LBOX_ITEM *)d.addrout[0];
}

LBOX_ITEM	*lbox_get_slct_item( LIST_BOX *box, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {174,1,0,1};

	d.intin[0]	= 8;
	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
	return (LBOX_ITEM *)d.addrout[0];
}

int16	lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {174,1,1,2};

	d.intin[0]	= 9;
	d.addrin[0]	= items;
	d.addrin[1]	= search;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16	lbox_get_bvis( LIST_BOX *box, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {174,1,1,1};

	d.intin[0]	= 10;
	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16	lbox_get_bentries( LIST_BOX *box, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {174,1,1,1};

	d.intin[0]	= 11;
	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16	lbox_get_bfirst( LIST_BOX *box, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {174,1,1,1};

	d.intin[0]	= 12;
	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (175)	lbox_set
*
****************************************************************/

void	lbox_set_asldr( LIST_BOX *box, int16 first, GRECT16 *rect,
					int16 *global )
{
	PARMDATA d;
	static int16 c[] = {175,2,0,2};

	d.intin[0]	= 0;
	d.intin[1]	= first;
	d.addrin[0]	= box;
	d.addrin[1]	= rect;
	_mt_aes( &d, c, global );
}

void	lbox_set_items( LIST_BOX *box, LBOX_ITEM *items, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {175,1,0,2};

	d.intin[0]	= 1;
	d.addrin[0]	= box;
	d.addrin[1]	= items;
	_mt_aes( &d, c, global );
}

void	lbox_free_items( LIST_BOX *box, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {175,1,0,1};

	d.intin[0]	= 2;
	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
}

void	lbox_free_list( LBOX_ITEM *items, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {175,1,0,1};

	d.intin[0]	= 3;
	d.addrin[0]	= items;
	_mt_aes( &d, c, global );
}

void	lbox_ascroll_to( LIST_BOX *box, int16 first, GRECT16 *box_rect,
					GRECT16 *slider_rect, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {175,2,0,3};

	d.intin[0]	= 4;
	d.intin[1]	= first;
	d.addrin[0]	= box;
	d.addrin[1]	= box_rect;
	d.addrin[2]	= slider_rect;
	_mt_aes( &d, c, global );
}

void	lbox_set_bsldr( LIST_BOX *box, int16 first, GRECT16 *rect, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {175,2,0,2};

	d.intin[0]	= 5;
	d.intin[1]	= first;
	d.addrin[0]	= box;
	d.addrin[1]	= rect;
	_mt_aes( &d, c, global );
}

void	lbox_set_bentries( LIST_BOX *box, int16 entries, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {175,2,0,1};

	d.intin[0]	= 6;
	d.intin[1]	= entries;
	d.addrin[0]	= box;
	_mt_aes( &d, c, global );
}

void	lbox_bscroll_to( LIST_BOX *box, int16 first, GRECT16 *box_rect,
					GRECT16 *slider_rect, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {175,2,0,3};

	d.intin[0]	= 7;
	d.intin[1]	= first;
	d.addrin[0]	= box;
	d.addrin[1]	= box_rect;
	d.addrin[2]	= slider_rect;
	_mt_aes( &d, c, global );
}


/****************************************************************
*
* (180)	fnts_create
*
****************************************************************/

FNT_DIALOG *fnts_create( int16 vdi_handle, int16 no_fonts,
					int16 font_flags, int16 dialog_flags,
					char *sample, char *opt_button,
					int16 *global )
{
	PARMDATA d;
	static int16 c[] = {180,4,0,4};

	d.intin[0] = vdi_handle;
	d.intin[1] = no_fonts;
	d.intin[2] = font_flags;
	d.intin[3] = dialog_flags;
	d.addrin[0] = sample;
	d.addrin[1] = opt_button;
	_mt_aes( &d, c, global );
	return (FNT_DIALOG *)d.addrout[0];
}


/****************************************************************
*
* (181)	fnts_delete
*
****************************************************************/

int16	fnts_delete( FNT_DIALOG *fnt_dialog, int16 vdi_handle,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = {181,1,1,1};

	d.intin[0] = vdi_handle;
	d.addrin[0] = fnt_dialog;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (182)	fnts_open
*
****************************************************************/

int16	fnts_open( FNT_DIALOG *fnt_dialog, int16 button_flags,
			int16 x, int16 y, int32 id, int32 pt, int32 ratio,
			int16 *global )
{
	PARMDATA d;
	static int16 c[] = {182,9,1,1};

	d.intin[0] = button_flags;
	d.intin[1] = x;
	d.intin[2] = y;
	*((int32 *)(d.intin+3))	= id;
	*((int32 *)(d.intin+5))	= pt;
	*((int32 *)(d.intin+7))	= ratio;
	d.addrin[0] = fnt_dialog;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (183)	fnts_close
*
****************************************************************/

int16	fnts_close( FNT_DIALOG *fnt_dialog, int16 *x, int16 *y, int16 *global )
{
	PARMDATA d;
	static int16 c[] = { 183, 0, 3, 1};

	d.intout[1] = -1;
	d.intout[2] = -1;

	d.addrin[0] = fnt_dialog;
	_mt_aes( &d, c, global );

	if ( x )
		*x = d.intout[1];
	if ( y )
		*y = d.intout[2];

	return( d.intout[0] );
}


/****************************************************************
*
* (184)	fnts_get_info
*
****************************************************************/

int16	fnts_get_no_styles( FNT_DIALOG *fnt_dialog, int32 id,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = {184,3,1,1};

	d.intin[0] = 0;
	*((int32 *) (d.intin+1)) = id;
	d.addrin[0] = fnt_dialog;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int32	fnts_get_style( FNT_DIALOG *fnt_dialog, int32 id, int16 index,
					int16 *global )
{
	PARMDATA d;
	static int16 c[] = {184,4,1,1};

	d.intin[0] = 1;
	*((int32 *) (d.intin+1)) = id;
	d.intin[3] = index;
	d.addrin[0] = fnt_dialog;
	_mt_aes( &d, c, global );
	return(*((int32 *) (d.intout+0)));
}

int16	fnts_get_name( FNT_DIALOG *fnt_dialog, int32 id,
				char *full_name, char *family_name,
				char *style_name, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {184,3,1,4};

	d.intin[0] = 2;
	*((int32 *) (d.intin+1)) = id;
	d.addrin[0] = fnt_dialog;
	d.addrin[1] = full_name;
	d.addrin[2] = family_name;

	d.addrin[3] = style_name;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

int16	fnts_get_info( FNT_DIALOG *fnt_dialog, int32 id, int16 *mono,
				int16 *outline, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {184,3,0,1};

	d.intin[0] = 3;
	*((int32 *) (d.intin+1)) = id;
	d.addrin[0] = fnt_dialog;
	_mt_aes( &d, c, global );
	*mono = d.intout[1];
	*outline = d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (185)	fnts_set
*
****************************************************************/

int16	fnts_add( FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = {185,1,1,2};

	d.intin[0] = 0;
	d.addrin[0] = fnt_dialog;
	d.addrin[1] = user_fonts;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

void	fnts_remove( FNT_DIALOG *fnt_dialog, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {185,1,0,1};

	d.intin[0] = 1;
	d.addrin[0] = fnt_dialog;
	_mt_aes( &d, c, global );
}


int16	fnts_update( FNT_DIALOG *fnt_dialog, int16 button_flags,
				int32 id, int32 pt, int32 ratio, int16 *global )
{
	static int16	c[] = { 185, 8, 1, 1 };
	PARMDATA	d;

	d.intin[0] = 2;
	d.intin[1] = button_flags;
	*((int32 *) &d.intin[2] ) = id;
	*((int32 *) &d.intin[4] ) = pt;
	*((int32 *) &d.intin[6] ) = ratio;
	d.addrin[0] = fnt_dialog;
	_mt_aes( &d, c, global );
	return( d.intout[0] );
}

/****************************************************************
*
* (186)	fnts_evnt
*
****************************************************************/

int16	fnts_evnt( FNT_DIALOG *fnt_dialog, EVNT *events,
				int16 *button, int16 *check_boxes, int32 *id,
				int32 *pt, int32 *ratio, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {186,0,9,2};

	d.addrin[0] = fnt_dialog;
	d.addrin[1] = events;
	_mt_aes( &d, c, global );
	*button		= d.intout[1];
	*check_boxes	= d.intout[2];
	*id			= *((int32 *)(d.intout+3));
	*pt			= *((int32 *)(d.intout+5));
	*ratio		= *((int32 *)(d.intout+7));
	return(d.intout[0]);
}


/****************************************************************
*
* (187)	fnts_do
*
****************************************************************/

int16	fnts_do( FNT_DIALOG *fnt_dialog, int16 button_flags,
			int32 id_in, int32 pt_in, int32 ratio_in,
			int16 *check_boxes, int32 *id, int32 *pt,
			int32 *ratio, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {187,7,0,1};

	d.intin[0] = button_flags;
	*((int32 *) (d.intin+1)) = id_in;
	*((int32 *) (d.intin+3)) = pt_in;
	*((int32 *) (d.intin+5)) = ratio_in;
	d.addrin[0] = fnt_dialog;
	_mt_aes( &d, c, global );
	*check_boxes = d.intout[1];
	*id = *((int32 *) (d.intout+2));
	*pt = *((int32 *) (d.intout+4));
	*ratio = *((int32 *) (d.intout+6));
	return(d.intout[0]);
}


/****************************************************************
*
* (190)	fslx_open
*
****************************************************************/

void *fslx_open(
			char *title,
			int16 x, int16 y,
			int16	*handle,
			char *path, int16 pathlen,
			char *fname, int16 fnamelen,
			char *patterns,
			XFSL_FILTER filter,
			char *paths,
			int16 sort_mode,
			int16 flags,
			int16 *global)
{
	PARMDATA d;
	static int16 c[] = {190,6,1,6};

	int16 *intin = d.intin;
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

	_mt_aes( &d, c, global );

	*handle = d.intout[0];
	return(d.addrout[0]);
}


/****************************************************************
*
* (191)	fslx_close
*
****************************************************************/

int16 fslx_close( void *fsd, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {191,0,1,1};

	d.addrin[0] = fsd;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (192)	fslx_getnxtfile
*
****************************************************************/

int16 fslx_getnxtfile(
			void *fsd,
			char *fname, int16 *global
			)
{
	PARMDATA d;
	static int16 c[] = {192,0,1,2};

	d.addrin[0] = fsd;
	d.addrin[1] = fname;
	_mt_aes( &d, c, global );
	return(d.intout[0]);

}


/****************************************************************
*
* (193)	fslx_evnt
*
****************************************************************/

int16 fslx_evnt(
			void *fsd,
			EVNT *events,
			char *path,
			char *fname,
			int16 *button,
			int16 *nfiles,
			int16 *sort_mode,
			char **pattern, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {193,0,4,4};

	void **addrin = d.addrin;

	*addrin++ = fsd;
	*addrin++ = events;
	*addrin++ = path;
	*addrin = fname;
	_mt_aes( &d, c, global );
	*button = d.intout[1];
	*nfiles = d.intout[2];
	*sort_mode = d.intout[3];
	*pattern = (char *)d.addrout[0];

	return(d.intout[0]);
}


/****************************************************************
*
* (194)	fslx_do
*
****************************************************************/

void * fslx_do(
			char *title,
			char *path, int16 pathlen,
			char *fname, int16 fnamelen,
			char *patterns,
			XFSL_FILTER filter,
			char *paths,
			int16 *sort_mode,
			int16 flags,
			int16 *button,
			int16 *nfiles,
			char **pattern, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {194,4,4,6};

	int16 *intin = d.intin;
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

	_mt_aes( &d, c, global );

	*button = d.intout[1];
	*nfiles = d.intout[2];
	*sort_mode = d.intout[3];
	*pattern = (char *)d.addrout[1];
	return(d.addrout[0]);
}


/****************************************************************
*
* (195)	fslx_set_flags
*
****************************************************************/

int16 fslx_set_flags( int16 flags,
				int16 *oldval, int16 *global )
{
	PARMDATA d;
	static int16 c[] = {195,2,2,0};

	d.intin[0] = 0;
	d.intin[1] = flags;
	_mt_aes( &d, c, global );
	*oldval = d.intout[1];
	return(d.intout[0]);
}

/****************************************************************
*
* (200)	pdlg_create
*
****************************************************************/

PRN_DIALOG *pdlg_create( int16 dialog_flags, int16 *global )
{
	PARMDATA d;
	static int16 c[] = { 200, 1, 0, 0 };

	d.intin[0] = dialog_flags;
	_mt_aes( &d, c, global );
	return (PRN_DIALOG *)d.addrout[0];
}


/****************************************************************
*
* (201)	pdlg_delete
*
****************************************************************/

int16	pdlg_delete( PRN_DIALOG *prn_dialog, int16 *global )
{
	PARMDATA d;
	static int16 c[] = { 201, 0, 1, 1 };

	d.addrin[0] = prn_dialog;
	_mt_aes( &d, c, global );
	return( d.intout[0] );
}


/****************************************************************
*
* (202)	pdlg_open
*
****************************************************************/

int16	pdlg_open( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
				char *document_name, int16 option_flags,
				int16 x, int16 y, int16 *global )
{
	PARMDATA d;
	static int16 c[] = { 202, 3, 1, 3 };

	d.intin[0] = option_flags;
	d.intin[1] = x;
	d.intin[2] = y;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = settings;
	d.addrin[2] = document_name;
	_mt_aes( &d, c, global );
	return( d.intout[0] );
}


/****************************************************************
*
* (203)	pdlg_close
*
****************************************************************/

int16	pdlg_close( PRN_DIALOG *prn_dialog, int16 *x, int16 *y,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = { 203, 0, 3, 1 };

	d.intout[1] = -1;
	d.intout[2] = -1;

	d.addrin[0] = prn_dialog;
	_mt_aes( &d, c, global );

	if ( x )
		*x = d.intout[1];
	if ( y )
		*y = d.intout[2];

	return( d.intout[0] );
}


/****************************************************************
*
* (204)	pdlg_get
*
****************************************************************/

int32	pdlg_get_setsize( int16 *global )
{
	PARMDATA d;
	static int16 c[] = { 204, 1, 2, 0 };

	d.intin[0] = 0;
	_mt_aes( &d, c, global );
	return( *(int32 *) &d.intout[0] );
}

/****************************************************************
*
* (205)	pdlg_set
*
****************************************************************/

int16	pdlg_add_printers( PRN_DIALOG *prn_dialog,
					DRV_INFO *drv_info, int16 *global )
{
	static int16	c[] = { 205, 1, 1, 2 };
	PARMDATA	d;

	d.intin[0] = 0;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = drv_info;
	_mt_aes( &d, c, global );
	return( d.intout[0] );
}

int16	pdlg_remove_printers( PRN_DIALOG *prn_dialog, int16 *global )
{
	static int16	c[] = { 205, 1, 1, 1 };
	PARMDATA	d;

	d.intin[0] = 1;
	d.addrin[0] = prn_dialog;
	_mt_aes( &d, c, global );
	return( d.intout[0] );
}

int16	pdlg_update( PRN_DIALOG *prn_dialog, char *document_name,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = { 205, 1, 1, 3 };

	d.intin[0] = 2;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = 0L;
	d.addrin[2] = document_name;
	_mt_aes( &d, c, global );
	return( d.intout[0] );
}

int16	pdlg_add_sub_dialogs( PRN_DIALOG *prn_dialog,
					PDLG_SUB *sub_dialogs, int16 *global )
{
	static int16	c[] = { 205, 1, 1, 2 };
	PARMDATA	d;

	d.intin[0] = 3;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = sub_dialogs;
	_mt_aes( &d, c, global );
	return( d.intout[0] );
}

int16	pdlg_remove_sub_dialogs( PRN_DIALOG *prn_dialog,
						int16 *global )
{
	static int16	c[] = { 205, 1, 1, 1 };
	PARMDATA	d;

	d.intin[0] = 4;
	d.addrin[0] = prn_dialog;
	_mt_aes( &d, c, global );
	return( d.intout[0] );
}

PRN_SETTINGS *pdlg_new_settings( PRN_DIALOG *prn_dialog,
							int16 *global )
{
	static int16	c[] = { 205, 1, 0, 1 };
	PARMDATA	d;

	d.intin[0] = 5;
	d.addrin[0] = prn_dialog;
	_mt_aes( &d, c, global );
	return (PRN_SETTINGS *)d.addrout[0];
}

int16	pdlg_free_settings( PRN_SETTINGS *settings, int16 *global )
{
	static int16	c[] = { 205, 1, 1, 1 };
	PARMDATA	d;

	d.intin[0] = 6;
	d.addrin[0] = settings;
	_mt_aes( &d, c, global );
	return( d.intout[0] );
}

int16	pdlg_dflt_settings( PRN_DIALOG *prn_dialog,
					PRN_SETTINGS *settings, int16 *global )
{
	static int16	c[] = { 205, 1, 1, 2 };
	PARMDATA	d;

	d.intin[0] = 7;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = settings;
	_mt_aes( &d, c, global );
	return( d.intout[0] );
}

int16	pdlg_validate_settings( PRN_DIALOG *prn_dialog,
					PRN_SETTINGS *settings, int16 *global )
{
	static int16	c[] = { 205, 1, 1, 2 };
	PARMDATA	d;

	d.intin[0] = 8;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = settings;
	_mt_aes( &d, c, global );
	return( d.intout[0] );
}

int16	pdlg_use_settings( PRN_DIALOG *prn_dialog,
					PRN_SETTINGS *settings, int16 *global )
{
	static int16	c[] = { 205, 1, 1, 2 };
	PARMDATA	d;

	d.intin[0] = 9;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = settings;
	_mt_aes( &d, c, global );
	return( d.intout[0] );
}

int16	pdlg_save_default_settings( PRN_DIALOG *prn_dialog,
					PRN_SETTINGS *settings, int16 *global )
{
	static int16	c[] = { 205, 1, 1, 2 };
	PARMDATA	d;

	d.intin[0] = 10;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = settings;
	_mt_aes( &d, c, global );
	return( d.intout[0] );
}


/****************************************************************
*
* (206)	pdlg_evnt
*
****************************************************************/

int16	pdlg_evnt( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
				EVNT *events, int16 *button, int16 *global )
{
	PARMDATA d;
	static int16 c[] = { 206, 0, 2, 3 };

	d.addrin[0] = prn_dialog;
	d.addrin[1] = settings;
	d.addrin[2] = events;
	_mt_aes( &d, c, global );
	*button		= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (207)	pdlg_do
*
****************************************************************/

int16	pdlg_do( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
				char *document_name, int16 option_flags,
				int16 *global )
{
	PARMDATA d;
	static int16 c[] = { 207, 1, 1, 3 };

	d.intin[0] = option_flags;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = settings;
	d.addrin[2] = document_name;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (210)	edit_create
*
****************************************************************/

XEDITINFO *edit_create( int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 210, 0, 0, 0 };

	_mt_aes( &d, c, global );
	return( d.addrout[0] );
}


/****************************************************************
*
* (211)	edit_open
*
****************************************************************/

int16 edit_open(OBJECT *tree, int16 obj, int16 *global)
{
	PARMDATA d;
	static int16	c[] = { 211, 1, 1, 1 };

	d.intin[0] = obj;
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
	return( d.intout[0] );
}


/****************************************************************
*
* (212)	edit_close
*
****************************************************************/

void edit_close(OBJECT *tree, int16 obj, int16 *global)
{
	PARMDATA d;
	static int16	c[] = { 212, 1, 0, 1 };

	d.intin[0] = obj;
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
}


/****************************************************************
*
* (213)	edit_delete
*
****************************************************************/

void edit_delete( XEDITINFO *xi, int16 *global)
{
	PARMDATA d;
	static int16	c[] = { 213, 0, 0, 1 };

	d.addrin[0] = xi;
	_mt_aes( &d, c, global );
}


/****************************************************************
*
* (214)	edit_cursor
*
****************************************************************/

int16 edit_cursor(OBJECT *tree, int16 obj, int16 whdl,
					int16 show, int16 *global)
{
	PARMDATA d;
	static int16	c[] = { 214, 3, 1, 1 };

	d.intin[0] = obj;
	d.intin[1] = whdl;
	d.intin[2] = show;
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

/****************************************************************
*
* (215)	edit_evnt
*
****************************************************************/

int16 edit_evnt(OBJECT *tree, int16 obj, int16 whdl,
				EVNT *ev, int32 *errc, int16 *global)
{
	PARMDATA d;
	static int16	c[] = { 215, 2, 3, 2 };

	d.intin[0] = obj;
	d.intin[1] = whdl;
	d.addrin[0] = tree;
	d.addrin[1] = ev;
	*((int32 *) (d.intout+1)) = 0L;	/* fÅr alte SLB */
	_mt_aes( &d, c, global );
	*errc = *((int32 *) (d.intout+1));
	return(d.intout[0]);
}


/****************************************************************
*
* (216)	edit_get
*
****************************************************************/

int16 edit_get_buf( OBJECT *tree, int16 obj,
					char **buf, int32 *buflen,
					int32 *txtlen,
					int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 216, 2, 5, 1 };

	d.intin[0] = obj;
	d.intin[1] = 0;		/* Subcode 0 */
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
	*buf = (char *)d.addrout[0];
	*buflen = *((int32 *) (d.intout+1));
	*txtlen = *((int32 *) (d.intout+3));
	return(d.intout[0]);
}

int16 edit_get_format( OBJECT *tree, int16 obj,
					int16 *tabwidth, int16 *autowrap,
					int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 216, 2, 3, 1 };

	d.intin[0] = obj;
	d.intin[1] = 1;		/* Subcode 1 */
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
	*tabwidth = d.intout[1];
	*autowrap = d.intout[2];
	return(d.intout[0]);
}

int16 edit_get_colour( OBJECT *tree, int16 obj,
					int16 *tcolour, int16 *bcolour,
					int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 216, 2, 3, 1 };

	d.intin[0] = obj;
	d.intin[1] = 2;		/* Subcode 2 */
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
	*tcolour = d.intout[1];
	*bcolour = d.intout[2];
	return(d.intout[0]);
}

int16 edit_get_font( OBJECT *tree, int16 obj,
					int16 *fontID, int16 *fontH, int16 *fontPix, int16 *mono,
					int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 216, 2, 5, 1 };

	d.intin[0] = obj;
	d.intin[1] = 3;		/* Subcode 3 */
	d.addrin[0] = tree;
	d.intout[4] = 0;		/* fÅr alte SLB */
	_mt_aes( &d, c, global );
	*fontID = d.intout[1];
	*fontH = d.intout[2];
	*mono = d.intout[3];
	*fontPix = d.intout[4];
	return(d.intout[0]);
}

int16 edit_get_cursor( OBJECT *tree, int16 obj,
					char **cursorpos, int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 216, 2, 1, 1 };

	d.intin[0] = obj;
	d.intin[1] = 4;		/* Subcode 4 */
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
	*cursorpos = (char *)d.addrout[0];
	return(d.intout[0]);
}

void edit_get_pos( OBJECT *tree, int16 obj,
					int16 *xscroll,
					int32 *yscroll,
					char **cyscroll,
					char **cursorpos,
					int16 *cx,
					int16 *cy,
					int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 216, 2, 6, 1 };

	d.intin[0] = obj;
	d.intin[1] = 5;		/* Subcode 5 */
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
	*xscroll = d.intout[1];
	*yscroll = *((int32 *) (d.intout+2));
	*cyscroll = (char *)d.addrout[0];
	*cx = d.intout[4];
	*cy = d.intout[5];
	*cursorpos = (char *)d.addrout[1];
}

int16 edit_get_dirty( OBJECT *tree, int16 obj,
					int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 216, 2, 1, 1 };

	d.intin[0] = obj;
	d.intin[1] = 7;		/* Subcode 7 */
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}

void edit_get_sel( OBJECT *tree, int16 obj,
					char **bsel, char **esel,
					int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 216, 2, 0, 1 };

	d.intin[0] = obj;
	d.intin[1] = 8;		/* Subcode 8 */
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
	*bsel = (char *)d.addrout[0];
	*esel = (char *)d.addrout[1];
}

void edit_get_scrollinfo( OBJECT *tree, int16 obj,
					int32 *nlines, int32 *yscroll, int16 *yvis, int16 *yval,
					int16 *ncols, int16 *xscroll, int16 *xvis,
					int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 216, 2, 6, 1 };

	d.intin[0] = obj;
	d.intin[1] = 9;		/* Subcode 9 */
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
	*nlines = *((int32 *) (d.intout+1));
	*yscroll = *((int32 *) (d.intout+3));
	*yvis = d.intout[5];
	*yval = d.intout[6];
	*ncols = d.intout[7];
	*xscroll = d.intout[8];
	*xvis = d.intout[9];
}


/****************************************************************
*
* (217)	edit_set
*
****************************************************************/

void edit_set_buf( OBJECT *tree, int16 obj,
					char *buf, int32 buflen, int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 217, 4, 0, 2 };

	d.intin[0] = obj;
	d.intin[1] = 0;		/* Subcode 0 */
	*(int32 *) (d.intin+2) = buflen;
	d.addrin[0] = tree;
	d.addrin[1] = buf;
	_mt_aes( &d, c, global );
}

void edit_set_format( OBJECT *tree, int16 obj,
					int16 tabwidth, int16 autowrap,
					int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 217, 4, 0, 1 };

	d.intin[0] = obj;
	d.intin[1] = 1;		/* Subcode 1 */
	d.intin[2] = tabwidth;
	d.intin[3] = autowrap;
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
}

void edit_set_colour( OBJECT *tree, int16 obj,
					int16 tcolour, int16 bcolour,
					int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 217, 4, 0, 1 };

	d.intin[0] = obj;
	d.intin[1] = 2;		/* Subcode 2 */
	d.intin[2] = tcolour;
	d.intin[3] = bcolour;
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
}

void edit_set_font( OBJECT *tree, int16 obj,
					int16 fontID, int16 fontH, int16 fontPix, int16 mono,
					int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 217, 6, 0, 1 };

	d.intin[0] = obj;
	d.intin[1] = 3;		/* Subcode 3 */
	d.intin[2] = fontID;
	d.intin[3] = fontH;
	d.intin[4] = mono;
	d.intin[5] = fontPix;
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
}

void edit_set_cursor( OBJECT *tree, int16 obj,
					char *cursorpos,
					int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 217, 2, 0, 2 };

	d.intin[0] = obj;
	d.intin[1] = 4;		/* Subcode 4 */
	d.addrin[0] = tree;
	d.addrin[1] = cursorpos;
	_mt_aes( &d, c, global );
}

void edit_set_pos( OBJECT *tree, int16 obj,
					int16 xscroll,
					int32 yscroll,
					char *cyscroll,
					char *cursorpos,
					int16 cx,
					int16 cy,
					int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 217, 7, 0, 3 };

	d.intin[0] = obj;
	d.intin[1] = 5;		/* Subcode 5 */
	d.intin[2] = xscroll;
	*(int32 *) (d.intin+3) = yscroll;
	d.intin[5] = cx;
	d.intin[6] = cy;
	d.addrin[0] = tree;
	d.addrin[1] = cyscroll;
	d.addrin[2] = cursorpos;
	_mt_aes( &d, c, global );
}

int16 edit_resized( OBJECT *tree, int16 obj,
					int16 *oldrh, int16 *newrh,
					int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 217, 2, 3, 1 };

	d.intin[0] = obj;
	d.intin[1] = 6;		/* Subcode 6 */
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
	*oldrh = d.intout[1];
	*newrh = d.intout[2];
	return(d.intout[0]);
}

void edit_set_dirty( OBJECT *tree, int16 obj,
					int16 dirty,
					int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 217, 2, 0, 2 };

	d.intin[0] = obj;
	d.intin[1] = 7;		/* Subcode 7 */
	d.intin[2] = dirty;
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
}

int16 edit_scroll( OBJECT *tree, int16 obj,
				int16 whdl,
				int32 yscroll, int16 xscroll, int16 *global )
{
	PARMDATA d;
	static int16	c[] = { 217, 6, 1, 1 };

	d.intin[0] = obj;
	d.intin[1] = 9;		/* Subcode 9 */
	d.intin[2] = whdl;
	*(int32 *) (d.intin+3) = yscroll;
	d.intin[5] = xscroll;
	d.addrin[0] = tree;
	_mt_aes( &d, c, global );
	return(d.intout[0]);
}
