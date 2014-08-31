/*
*
* Erweiterung fÅr MT_AES, enthÑlt das
* Binding fÅr die Editor-Funktionen
*
*/

/****************************************************************
*
* (210)	edit_create
*
****************************************************************/

XEDITINFO *mt_edit_create( WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 210, 0, 0, 0 };

	__aes( &d, c, global );
	return( d.addrout[0] );
}


/****************************************************************
*
* (211)	edit_open
*
****************************************************************/

WORD mt_edit_open(OBJECT *tree, WORD obj, WORD *global)
{
	PARMDATA d;
	static WORD	c[] = { 211, 1, 1, 1 };

	d.intin[0] = obj;
	d.addrin[0] = tree;
	__aes( &d, c, global );
	return( d.intout[0] );
}


/****************************************************************
*
* (212)	edit_close
*
****************************************************************/

void mt_edit_close(OBJECT *tree, WORD obj, WORD *global)
{
	PARMDATA d;
	static WORD	c[] = { 212, 1, 0, 1 };

	d.intin[0] = obj;
	d.addrin[0] = tree;
	__aes( &d, c, global );
}


/****************************************************************
*
* (213)	edit_delete
*
****************************************************************/

void mt_edit_delete( XEDITINFO *xi, WORD *global)
{
	PARMDATA d;
	static WORD	c[] = { 213, 0, 0, 1 };

	d.addrin[0] = xi;
	__aes( &d, c, global );
}


/****************************************************************
*
* (214)	edit_cursor
*
****************************************************************/

WORD mt_edit_cursor(OBJECT *tree, WORD obj, WORD whdl,
					WORD show, WORD *global)
{
	PARMDATA d;
	static WORD	c[] = { 214, 3, 1, 1 };

	d.intin[0] = obj;
	d.intin[1] = whdl;
	d.intin[2] = show;
	d.addrin[0] = tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}

/****************************************************************
*
* (215)	edit_evnt
*
****************************************************************/

WORD mt_edit_evnt(OBJECT *tree, WORD obj, WORD whdl,
				EVNT *ev, WORD *global)
{
	PARMDATA d;
	static WORD	c[] = { 215, 2, 1, 2 };

	d.intin[0] = obj;
	d.intin[1] = whdl;
	d.addrin[0] = tree;
	d.addrin[1] = ev;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (216)	edit_get
*
****************************************************************/

WORD mt_edit_get_buf( OBJECT *tree, WORD obj,
					char **buf, LONG *buflen,
					LONG *txtlen,
					WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 216, 2, 5, 1 };

	d.intin[0] = obj;
	d.intin[1] = 0;		/* Subcode 0 */
	d.addrin[0] = tree;
	__aes( &d, c, global );
	*buf = d.addrout[0];
	*buflen = *((LONG *) (d.intout+1));
	*txtlen = *((LONG *) (d.intout+3));
	return(d.intout[0]);
}

WORD mt_edit_get_format( OBJECT *tree, WORD obj,
					WORD *tabwidth, WORD *autowrap,
					WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 216, 2, 3, 1 };

	d.intin[0] = obj;
	d.intin[1] = 1;		/* Subcode 1 */
	d.addrin[0] = tree;
	__aes( &d, c, global );
	*tabwidth = d.intout[1];
	*autowrap = d.intout[2];
	return(d.intout[0]);
}

WORD mt_edit_get_colour( OBJECT *tree, WORD obj,
					WORD *tcolour, WORD *bcolour,
					WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 216, 2, 3, 1 };

	d.intin[0] = obj;
	d.intin[1] = 2;		/* Subcode 2 */
	d.addrin[0] = tree;
	__aes( &d, c, global );
	*tcolour = d.intout[1];
	*bcolour = d.intout[2];
	return(d.intout[0]);
}

WORD mt_edit_get_font( OBJECT *tree, WORD obj,
					WORD *fontID, WORD *fontH, WORD *mono,
					WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 216, 2, 4, 1 };

	d.intin[0] = obj;
	d.intin[1] = 3;		/* Subcode 3 */
	d.addrin[0] = tree;
	__aes( &d, c, global );
	*fontID = d.intout[1];
	*fontH = d.intout[2];
	*mono = d.intout[3];
	return(d.intout[0]);
}

WORD mt_edit_get_cursor( OBJECT *tree, WORD obj,
					char **cursorpos, WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 216, 2, 1, 1 };

	d.intin[0] = obj;
	d.intin[1] = 4;		/* Subcode 4 */
	d.addrin[0] = tree;
	__aes( &d, c, global );
	*cursorpos = d.addrout[0];
	return(d.intout[0]);
}

void mt_edit_get_pos( OBJECT *tree, WORD obj,
					WORD *xscroll,
					LONG *yscroll,
					char **cyscroll,
					char **cursorpos,
					WORD *cx,
					WORD *cy,
					WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 216, 2, 6, 1 };

	d.intin[0] = obj;
	d.intin[1] = 5;		/* Subcode 5 */
	d.addrin[0] = tree;
	__aes( &d, c, global );
	*xscroll = d.intout[1];
	*yscroll = *((LONG *) (d.intout+2));
	*cyscroll = d.addrout[0];
	*cx = d.intout[4];
	*cy = d.intout[5];
	*cursorpos = d.addrout[1];
}

WORD mt_edit_get_dirty( OBJECT *tree, WORD obj,
					WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 216, 2, 1, 1 };

	d.intin[0] = obj;
	d.intin[1] = 7;		/* Subcode 7 */
	d.addrin[0] = tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}

void mt_edit_get_sel( OBJECT *tree, WORD obj,
					char **bsel, char **esel,
					WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 216, 2, 0, 1 };

	d.intin[0] = obj;
	d.intin[1] = 8;		/* Subcode 8 */
	d.addrin[0] = tree;
	__aes( &d, c, global );
	*bsel = d.addrout[0];
	*esel = d.addrout[1];
}

void mt_edit_get_scrollinfo( OBJECT *tree, WORD obj,
					LONG *nlines, LONG *yscroll, WORD *yvis, WORD *yval,
					WORD *ncols, WORD *xscroll, WORD *xvis,
					WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 216, 2, 6, 1 };

	d.intin[0] = obj;
	d.intin[1] = 9;		/* Subcode 9 */
	d.addrin[0] = tree;
	__aes( &d, c, global );
	*nlines = *((LONG *) (d.intout+1));
	*yscroll = *((LONG *) (d.intout+3));
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

void mt_edit_set_buf( OBJECT *tree, WORD obj,
					char *buf, LONG buflen, WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 217, 4, 0, 2 };

	d.intin[0] = obj;
	d.intin[1] = 0;		/* Subcode 0 */
	*(LONG *) (d.intin+2) = buflen;
	d.addrin[0] = tree;
	d.addrin[1] = buf;
	__aes( &d, c, global );
}

void mt_edit_set_format( OBJECT *tree, WORD obj,
					WORD tabwidth, WORD autowrap,
					WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 217, 4, 0, 1 };

	d.intin[0] = obj;
	d.intin[1] = 1;		/* Subcode 1 */
	d.intin[2] = tabwidth;
	d.intin[3] = autowrap;
	d.addrin[0] = tree;
	__aes( &d, c, global );
}

void mt_edit_set_colour( OBJECT *tree, WORD obj,
					WORD tcolour, WORD bcolour,
					WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 217, 4, 0, 1 };

	d.intin[0] = obj;
	d.intin[1] = 2;		/* Subcode 2 */
	d.intin[2] = tcolour;
	d.intin[3] = bcolour;
	d.addrin[0] = tree;
	__aes( &d, c, global );
}

void mt_edit_set_font( OBJECT *tree, WORD obj,
					WORD fontID, WORD fontH, WORD mono,
					WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 217, 5, 0, 1 };

	d.intin[0] = obj;
	d.intin[1] = 3;		/* Subcode 3 */
	d.intin[2] = fontID;
	d.intin[3] = fontH;
	d.intin[4] = mono;
	d.addrin[0] = tree;
	__aes( &d, c, global );
}

void mt_edit_set_cursor( OBJECT *tree, WORD obj,
					char *cursorpos,
					WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 217, 2, 0, 2 };

	d.intin[0] = obj;
	d.intin[1] = 4;		/* Subcode 4 */
	d.addrin[0] = tree;
	d.addrin[1] = cursorpos;
	__aes( &d, c, global );
}

void mt_edit_set_pos( OBJECT *tree, WORD obj,
					WORD xscroll,
					LONG yscroll,
					char *cyscroll,
					char *cursorpos,
					WORD cx,
					WORD cy,
					WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 217, 7, 0, 3 };

	d.intin[0] = obj;
	d.intin[1] = 5;		/* Subcode 5 */
	d.intin[2] = xscroll;
	*(LONG *) (d.intin+3) = yscroll;
	d.intin[5] = cx;
	d.intin[6] = cy;
	d.addrin[0] = tree;
	d.addrin[1] = cyscroll;
	d.addrin[2] = cursorpos;
	__aes( &d, c, global );
}

WORD mt_edit_resized( OBJECT *tree, WORD obj,
					WORD *oldrh, WORD *newrh,
					WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 217, 2, 3, 1 };

	d.intin[0] = obj;
	d.intin[1] = 6;		/* Subcode 6 */
	d.addrin[0] = tree;
	__aes( &d, c, global );
	*oldrh = d.intout[1];
	*newrh = d.intout[2];
	return(d.intout[0]);
}

void mt_edit_set_dirty( OBJECT *tree, WORD obj,
					WORD dirty,
					WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 217, 2, 0, 2 };

	d.intin[0] = obj;
	d.intin[1] = 7;		/* Subcode 7 */
	d.intin[2] = dirty;
	d.addrin[0] = tree;
	__aes( &d, c, global );
}

WORD mt_edit_scroll( OBJECT *tree, WORD obj,
				WORD whdl,
				LONG yscroll, WORD xscroll, WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 217, 6, 1, 1 };

	d.intin[0] = obj;
	d.intin[1] = 9;		/* Subcode 9 */
	d.intin[2] = whdl;
	*(LONG *) (d.intin+3) = yscroll;
	d.intin[5] = xscroll;
	d.addrin[0] = tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}
