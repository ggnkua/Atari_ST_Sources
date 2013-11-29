/****************************************************************
*
* Dieses Modul enth„lt MT-sichere AES-Funktionen.
*
*
* Entwickelt mit und fr PureC 1.1.
* Damit sich der Quelltext leicht portieren l„žt, wird mit
* portab.h gearbeitet.
*
* Andreas Kromke
* 16.3.96
*
****************************************************************/

#include "wdlg_aes.h"

/****************************************************************
*
* Inititialisiert den AESPB (ohne global[] !!! )
* Setzt die contrl-Felder und ruft das AES auf.
*
****************************************************************/

void __asm _trap2( register __d0 int c8, register __d1 AESPB *pb )
{
	__builtin_emit(0x4e42);	/* trap #2 */
}

static void __aes( AESPB *pb, PARMDATA *d, WORD *ctrldata )
{
	register WORD *c = d->contrl;

	pb->contrl	= c;
	pb->intin	= d->intin;
	pb->intout	= d->intout;
	pb->addrin	= d->addrin;
	pb->addrout	= d->addrout;

	*c++ = *ctrldata++;
	*c++ = *ctrldata++;
	*c++ = *ctrldata++;
	*c = *ctrldata;

/*	_crystal( pb ); */
	_trap2( 0xc8, pb );
}


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
	d.addrout[0]= NULL;
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
	d.intout[0] = 0;
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


