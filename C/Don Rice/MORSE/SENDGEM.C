/* GEM routines used by SENDER.C */

short	xpos, ypos;

/* GEM globals */
short	contrl[12], intin[128], ptsin[128], intout[128], ptsout[128],
	pxyarray[12], int_in[11], int_out[57];

/* Working storage */
short	handle, wi_handle, ap_id, gl_hchar, gl_wchar,
	gl_wbox, gl_hbox, xwork, ywork, wwork, hwork, xdesk, ydesk,
	wdesk, hdesk, xold, yold, hold, wold, xobj, yobj, wobj, hobj,
	xmouse, ymouse;

long	resrcs;

char	*no_rsc_file = "[3][Resource (.RSC) file is missing!][Abort]",
	*bad_rsc_file = "[3][Resource (.RSC) file is defective.][Abort]",
	infile[128], dirspec[128];

#define OB_SPEC( x )	(long *) (tree + (x) * sizeof( OBJECT ) + 12)
#define OB_STATE( x )	(short *) (tree + (x) * sizeof( OBJECT ) + 10)
#define TE_PTEXT( x )	(long *) (x)

clear_window( top )
short top;
{
	short wbound[4];

	graf_mouse( M_OFF, 0x0L );
	wind_update( BEG_UPDATE );
	wbound[0] = xwork;
	wbound[1] = top;
	wbound[2] = xwork + wwork;
	wbound[3] = ywork + hwork;
	vsf_color( handle, BLACK );
	vsf_style( handle, 5 );
	vsf_interior( handle, 2 );
	vr_recfl( handle, wbound );
	ypos = top + (gl_hchar<<1);
	xpos = xwork + gl_wchar;
	wind_update( END_UPDATE );
	graf_mouse( M_ON, 0x0L );
}	/* clear_window */

close_window()
{
	wind_close( wi_handle );
	graf_shrinkbox( xwork+wwork/2, ywork+hwork/2, gl_wbox, gl_hbox, xwork,
	  ywork, wwork, hwork );
	wind_delete( wi_handle );
}	/* close_window */

deselect( object )	/* Turn off deselected object in resrcs */
short object;
{
	objc_change( resrcs, object, 0, xwork, ywork, wwork, hwork, NORMAL,
	  1 );
}	/* deselect */

gem_init()
{
	/* Initialize application and open windows */
	ap_id = appl_init();
	handle = graf_handle( &gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox );
	open_vwork();
	open_window();
	graf_mouse( ARROW, 0x0L );
}	/* gem_init */

getfspec( finit, fspec, wcard )
char *finit, *fspec, *wcard;
{
	short drive, okay;
	char fname[128];

	if( strlen( finit ) == 0 )
	{
		drive = Dgetdrv();	/* current drive */
		finit[0] = drive + 'A';
		finit[1] = ':';
		Dgetpath( &finit[2], drive+1 );	/* current directory level */
		strcat( finit, wcard );
	}
	graf_mouse( ARROW, 0x0L );
	if( !fsel_input( finit, fname, &okay ) )
	{
		form_alert( 1, "[3][Invalid filespec][Continue]" );
		return( FALSE );
	}

	/* Redraw main window */
	clear_window( ywork );
	graf_mouse( BUSYBEE, 0x0L );

	if( !okay ) return( FALSE );	/* CANCEL */
	if( fname[0] == ' ' || fname[0] == '\0' )
		return( FALSE );
	merge( fspec, finit, fname );
	return( TRUE );
}	/* getfspec */

merge( spec, dir, file )	/* combine directory and filenames */
char *spec, *dir, *file;
{
	char *ldir, *strrchr();

	strcpy( spec, dir );
	ldir = strrchr( spec, '\\' );
	if( ldir == NULL ) ldir = spec;
	else ldir++;
	strcpy( ldir, file );
}	/* merge */

open_vwork()
{
	short i;

	for( i=1; i<10; i++ ) int_in[i] = 1;
	int_in[10] = 2;
	v_opnvwk( int_in, &handle, int_out );
}	/* open_vwork */

open_window()
{
	wind_get( 0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk );
	wi_handle = wind_create( 0, xdesk, ydesk, wdesk, hdesk );
	graf_growbox( xdesk+wdesk/2, ydesk+hdesk/2, gl_wbox, gl_hbox, xdesk,
	  ydesk, wdesk, hdesk );
	wind_open( wi_handle, xdesk, ydesk, wdesk, hdesk );
	wind_get( wi_handle, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork );
}	/* open_window */

select( object )	/* Highlight selected object in resrcs */
short object;
{
	objc_change( resrcs, object, 0, xwork, ywork, wwork, hwork, SELECTED,
	  1 );
}	/* select */

terminate( dialog )	/* Show final dialog, close everything and quit */
char *dialog;
{
	if( dialog != NULL ) form_alert( 1, dialog );
	close_window();
	m_wait( 10 );	/* Clear event queue */
	v_clsvwk( handle );
	appl_exit();
	exit(0);
}	/* terminate */

textbox( box )
short box[4];
{
	short outline[10];

	graf_mouse( M_OFF, 0x0L );
	wind_update( BEG_UPDATE );
	vsf_color( handle, 0 );
	vsf_interior( handle, 1 );
	v_bar( handle, box );
	ypos = box[1] + gl_hchar;
	xpos = box[0] + gl_wchar;
	vsf_color( handle, 1 );
	outline[0] = outline[2] = outline[8] = box[0];
	outline[1] = outline[7] = outline[9] = box[1];
	outline[3] = outline[5] = box[3];
	outline[4] = outline[6] = box[2];
	v_pline( handle, 5, outline );
	wind_update( END_UPDATE );
	graf_mouse( M_ON, 0x0L );
}	/* textbox */

wputs( str )
char *str;
{
	v_gtext( handle, xpos, ypos, str );
	ypos += gl_hchar;
}	/* wputs */
