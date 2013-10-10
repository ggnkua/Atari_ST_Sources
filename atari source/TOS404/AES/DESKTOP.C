/*	DESKTOP.C		3/15/89 - 7/26/89	Derek Mui	*/
/*	Take out vdi_handle	6/28/89					*/
/*	Read in icn file	9/23/89			D.Mui		*/
/*	New adj_menu to adjust menu	6/27/90		D.Mui		*/
/*	Take the wind_update in deskmain	8/9/90	D.Mui		*/
/*	Add m_cpu to check CPU	9/19/90			D.Mui		*/
/*	Fix the cache menu so that it checks the cache when menu is down*/
/*					10/24/90	D.Mui		*/
/*	Moved the wind_set in the main to just before menu_bar. It is 	*/
/*	to fix the acc problem			12/4/90	D.Mui		*/
/*	Change appl_init to ap_init and appl_exit to ap_exit 4/3/91	*/
/*	Add wm_update before bringing up the menu bar 4/18/91 Mui	*/
/*	Install desktop critical error handler	4/22/91	D.Mui		*/
/*	Check control key for nodisk system at re_icon 8/13/91	D.Mui	*/
/*	Change all the iconblk to ciconblk	7/11/92	D.Mui		*/
/*      Added adjobjects() to adjust objects    8/06/92 cgee		*/
	
/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include <portab.h>
#include <mobdefs.h>
#include <defines.h>
#include <window.h>
#include <gemdefs.h>
#include <deskusa.h>
#include <osbind.h>
#include <extern.h>

EXTERN	BYTE	*get_fstring();
EXTERN	OBJECT	*get_tree();
EXTERN	WORD	pglobal[];
EXTERN	BYTE	*lp_mid;
EXTERN	BYTE	*lp_start;
EXTERN	WORD	gl_restype;
EXTERN	WORD	gl_rschange;
EXTERN	WORD	d_exit;
EXTERN	BYTE	afile[];
EXTERN	BYTE	*q_addr;
EXTERN	WORD	gl_ws[];
EXTERN	UWORD	apsize;
EXTERN	WORD	gl_apid;
EXTERN	WORD	gl_hbox;
EXTERN	GRECT	gl_rfull;
EXTERN	WORD	do_once;

WORD	m_st;		/* machine type flag	*/	
WORD	m_cpu;		/* cpu type		*/
WORD	numicon;	/* the number of icon in the resource	*/	
BYTE	*iconmem;	/* icon data memory address	*/
WORD	xprint;		/* do it once flag	*/
BYTE	restable[6];	/* resolution table	*/
			/* Low , Medium, High, TT Medium, TT High, TT Low */

WORD		d_maxcolor;
USERBLK		chxcache;
CICONBLK	*ciconaddr;

	WORD
ch_xcache()
{
	ch_cache( FALSE );
	return( 0 );
}


EXTERN	WORD	ctldown;


/*	Read in icn file	*/

	WORD
re_icon( )
{
	REG WORD	i;
	BYTE	temp[30];
	LONG	*ptr;
	BYTE	buf2[18];	
	BYTE	*iaddr;

	LBCOPY( temp, pglobal, 30 );	/* save the pglobal	*/ 

	strcpy( icndata, buf2 );
	buf2[0] = ( isdrive() & 0x4 ) ? 'C' : 'A';
 
	if ( ctldown )
	  return( FALSE );

	if ( !rsrc_load( buf2 ) )
	  return( FALSE );

	ptr = &pglobal[7];		/* get the new rsc address	*/
	iaddr = *ptr;  
	
	if ( iconmem )			/* free up memory	*/
	{				/* use rs_free to free memory */
	  *ptr = iconmem;		/* because it may have color icons */
	  rs_free( pglobal );
	}

	iconmem = iaddr;
	iconaddr = get_tree( 0 );	
	numicon = iconaddr[0].ob_tail;
	iconaddr++;			/* get the icon address	*/
	LBCOPY( pglobal, temp, 30 );

	rs_sglobe( pglobal );		/* restore the pglobal	*/
	return( TRUE );
}


/*	Initalize the icon and allocate backid memory	*/
/*	Change the G_ICON to G_CICON			*/

	WORD
ini_icon()
{
	REG WORD	i;
	REG OBJECT	*obj;
	REG IDTYPE	*itype;
	    CICONBLK 	*icblk;	

	backid = Malloc( (LONG)( sizeof( IDTYPE ) * ( maxicon + 1 ) ) );

	if ( !backid )
	  return( FALSE );
	
	obj = background;
	
	for ( i = 1; i <= maxicon; i++ )
	{
	  itype = &backid[i];
	  obj[i].ob_type = G_CICON;	/* 7/11/92 */
	  obj[i].ob_flags = HIDETREE;
	  obj[i].ob_state = NORMAL;
	  obj[i].ob_width = dicon.w;
	  obj[i].ob_height = dicon.h;
	  icblk = (CICONBLK*)(iconaddr[0].ob_spec);
	  itype->i_cicon = *icblk;
	  itype->i_cicon.monoblk.ib_ptext = &itype->i_name[0]; 	
	  obj[i].ob_spec = &itype->i_cicon;
	  itype->i_path = (BYTE*)0;
	}

	return( TRUE );
}

/*	Shift the menu	*/

	VOID
adj_menu( which )
	WORD	which;
{
	OBJECT	*obj;
	WORD	w,x,y;

	obj = menu_addr;		/* shift the menu	*/
	objc_offset( menu_addr, which, &x, &y );
	
	w = obj[which].ob_width + x;
	if ( w >= ( full.w + full.x ) )
	{
	  x = w - ( full.w + full.x ) + gl_wchar;
	  obj[which].ob_x -= x;	
	}			
}


/*	Initalize the desktop resource		*/

	VOID
ini_rsc()
{
	REG OBJECT	*obj;
	GRECT	pt;
	ICONBLK		*iblk;
	WORD		w,i;
	CICONBLK	*icblk;
				
	rom_ram( 1, pglobal );		/* load in resource		*/
					
	menu_addr = get_tree( ADMENU );	/* get the menu address		*/
			
	adj_menu( IDSKITEM - 1 );
	adj_menu( ICONITEM - 1 );			

	if ( !iconaddr )	/* if icon hasn't read in then read it again	*/
	{				
	  if ( !re_icon() )
	  {
	    iconaddr = get_tree( ADICON );
	    numicon = iconaddr[0].ob_tail;
	    iconaddr++;
	  }
	}

	background = get_tree( BACKGROUND );
					
	maxicon = background[0].ob_tail;/* max background icon		*/

/* 	Allocate memory for color icons 
 * 	These should go away if we have a RCS that can handle color icon 
 */

	if ( !ciconaddr )	/* 7/10/92 */
	{
	  if ( ciconaddr = Malloc( (LONG)( sizeof(CICONBLK) * maxicon ) ) )
	  {		
	    for ( i = 0; i < maxicon; i++ )
	    {
/*	      ciconaddr[i].monoblk = *((ICONBLK*)background[i+1].ob_spec);	*/
              background[i+1].ob_spec = &ciconaddr[i];
	      backgroubd[i+1].ob_type = G_CICON;
	    }
	  }
	  else
	  {
 	    Cconws( "Color icon failed \r\n" );
	    return(FALSE);
	  }
	}

	rc_copy( &full, &background[0].ob_x );

	/* Precalculate the disk icon's pline values	*/

	if ( iconaddr[0].ob_type == G_CICON )
	{
	  icblk = (CICONBLK*)iconaddr[0].ob_spec;
	  iblk = &icblk->monoblk; 
	}
	else
	  iblk = (ICONBLK*)(iconaddr[0].ob_spec);

	rc_copy( &iblk->ib_xicon, &pt );	/* get the icon's xywh	*/

	d_xywh[0] = pt.x;			/* disk icon outline	*/
	d_xywh[3] = d_xywh[1] = pt.y;
	d_xywh[4] = d_xywh[2] = d_xywh[0] + pt.w; 
	d_xywh[5] = d_xywh[3] + pt.h;
	
	rc_copy( &iblk->ib_xtext, &pt );
	d_xywh[8] = d_xywh[6] = pt.x + pt.w;
	d_xywh[13] = d_xywh[7] = pt.y;
	d_xywh[11] = d_xywh[9] = d_xywh[7] + pt.h;
	d_xywh[12] = d_xywh[10] = pt.x;
	d_xywh[16] = d_xywh[14] = d_xywh[0];
	d_xywh[15] = d_xywh[5];
	d_xywh[17] = d_xywh[1];
				
	dicon.x = 0;			/* precalculate text icon's x,y,w,h */
	dicon.y = 0;
	dicon.w = iblk->ib_wtext;
	dicon.h = iblk->ib_hicon + iblk->ib_htext;

	rc_copy( &dicon, &r_dicon );
	r_dicon.w += 5;
	r_dicon.h += 7;
	r_dicon.w += ( full.w % r_dicon.w ) / ( full.w / r_dicon.w );
	r_dicon.h += ( full.h % r_dicon.h ) / ( full.h / r_dicon.h );
				
	w = gl_wchar * 14;		/* text outline	*/

	obj = get_tree( TEXTLINES );
	f_xywh[9] = f_xywh[8] = f_xywh[6] = f_xywh[3] = f_xywh[1] = f_xywh[0] = 0;
	f_xywh[2] = w;
	f_xywh[4] = w;
	f_xywh[5] = obj[TSTYLE].ob_height;
	f_xywh[7] = obj[TSTYLE].ob_height;	
}



	WORD
deskmain()
{
	REG WORD	i;
	WORD		ret;
	WORD		handle,x;
	WORD		*ptr;
	BYTE		temp[30];
	LONG		*lptr;

	if ( !inf_path[0] )	/* Not set up yet		*/	
	  m_infpath( inf_path );

#if 0
	ciconaddr = (BYTE*)0;	/* 7/10/92 */
#endif

top:	
	gl_apid = ap_init( pglobal );	/* initalize the application	*/

	deskerr();		/* install our critical error	*/

	ret = TRUE;		/* assume everything is OK	*/
	d_exit = L_NOEXIT;

	appnode = (BYTE*)0;	/* No app buffer yet		*/
	applist = (BYTE*)0;	/* No app list yet		*/
	apsize = 0;		/* Initalize app size		*/

	desk_wait( TRUE );
					/* get the full window size	*/
	wind_get( 0, WF_WORKXYWH, &full.x, &full.y, &full.w, &full.h );

	ini_rsc();			/* init the resource		*/

	if ( !ini_icon() )		/* hide all the desktop icons	*/
	  goto m_2;

	if ( !mem_init() )		/* init the app path buffer	*/
	{				/* and desk app buffer		*/
m_2:	  desknoerr();
	  goto m_1;
	}		

	/* initalize all the windows before reading in inf file	*/

	ini_windows( );	 

	d_maxcolor = gl_ws[13];

	if ( !do_once )			/* do it once only	*/
	{
	  adjdcol( WHITE );		/* adjust dialogue box's color  */
	  adjobjects();			/* adjust object positions      */
	  do_once = TRUE;
	}

	read_inf();			/* Let see what the user want	*/

	q_inf();			/* make a copy of inf file	*/

	desknoerr();

	pref_save = gl_restype;		/* get the real res		*/
					/* change the menu bar		*/
	do_view( ( s_view == S_ICON ) ? ICONITEM : TEXTITEM );

	switch( s_sort )
	{
	  case S_NAME:
	    i = NAMEITEM;
	    break;
	  case S_DATE:
	    i = DATEITEM;
	    break;
	  case S_SIZE:
	    i = SIZEITEM;
	    break;
	  case S_TYPE:
	    i = TYPEITEM;
	    break;
	  case S_NO:
	    i = NOSORT;
	}

	wind_set( 0, WF_NEWDESK, background, 0, 0 );

	do_view( i );			/* fix up the menu bar	*/

	ch_machine( );			/* check the machine	*/
					/* set up the right menu text */
					/* do it here!!!!!!	*/
#if 0	/* take out for sparrow */		
	strcpy( get_fstring( ( m_cpu == 30 ) ? CACHETXT : BLTTXT ), menu_addr[BITBLT].ob_spec );

	
	menu_addr[SUPERITEM].ob_type = G_USERDEF;
	chxcache.ub_code = ch_xcache;
	menu_addr[SUPERITEM].ob_spec = &chxcache;
#endif
	

	ch_cache( TRUE );		/* set the cache	*/

	xprint = TRUE;
					/* check desktop file	*/	
	put_keys();			/* set up the key menu	*/

	wind_update( TRUE );
	menu_bar( menu_addr, TRUE );	/* show the menu	*/

	do_redraw( 0, &full, 0 );
	wind_update( FALSE );

	open_def();			/* open default windows	*/
	desk_wait( FALSE );

	actions();			/* handle the events	*/

	wind_update( TRUE );		/* Block out any more events	*/
	desk_wait( TRUE );		
	free_windows( );		/* free up all windows	*/	

	wind_set( 0, WF_NEWDESK, 0x0L, 0, 0 );

	Mfree( lp_start );		/* free string buffer	*/
	Mfree( appnode );		/* free app buffer	*/
	Mfree( backid );
	Mfree( q_addr );		/* update inf file on disk	*/
	menu_bar( 0x0L, FALSE );
	wind_update( FALSE );		/* release window	*/
m_1:
	ap_exit();
					/* Loop again		*/
	if ( d_exit == L_READINF )
	{
	  wind_new();			/* Read inf file	*/
	  goto top;
	}

	if ( d_exit == L_CHGRES )	/* if reschange free the memory */
	{				/* start everything over again	*/
	  if ( ciconaddr )		/* 7/10/92	*/
	  {
	    Mfree( ciconaddr );
	    ciconaddr = (BYTE*) 0;
	  }

	  iconaddr = (OBJECT*) 0;
	  if ( iconmem )
	  {
	    LBCOPY( temp, pglobal, 30 ); /* construct the pglobal	*/ 
	    ptr = temp;
	    lptr = &ptr[7];
	    *lptr = iconmem;	
	    rs_free( temp );
	    iconmem = (BYTE*) 0;
	  }
	  ret = FALSE;			/* resolution change	*/
	  inf_path[0] = 0;
   	  gl_rschange = TRUE;
	}

	return( ret );
}


/*	Check the machine type and set res table	*/

	WORD
ch_machine()
{
	LONG	value;

	m_st = TRUE;		
			/* _VDO	*/
	if ( getcookie( 0x5F56444FL, &value ) )
	{			/* 7/16/92 */
	  if ( ( ( value >> 16 ) & 0x0000FFFFL ) >= 0x02 )	/* TT	*/
	    m_st = FALSE;
	}
			/* _CPU	*/
	getcookie( 0x5F435055L, &value );
	m_cpu = value;

	/* the restable is set according to gl_restype value	*/

	bfill( 6, 0, restable );	/* zero the table	*/

	if ( !m_st )			/* TT machine	*/
	{
	  if ( gl_restype == 5 )	/* TT High	*/
	    restable[4] = 1;
	  else
	  {
	    bfill( 4, 1, restable );	/* LOW MEDIUM HIGH	*/
	    restable[5] = 1;		/* TT-LOW MEDIUM	*/
	  }
	}	
	else
	{
	  if ( gl_restype == 3 )	/* ST HIGH		*/
	    restable[2] = 1;
	  else
	  {
	    restable[0] = 1;
	    restable[1] = 1;	
	  }		
	}
}


	LONG
inq_cache( data )
	REG LONG	data;
{
	  asm( ".dc.w $4e7a,$0002" ); /* movec.l cacr,d0		*/

	  if ( data != -1 )
	    asm( ".dc.w $4e7b,$7002" ); /* movec.l d7,cacr		*/

	  asm( ".dc.w $4e7a,$0002" ); /* movec.l cacr,d0		*/
}


/*	Turn on the cache or bitblt 	*/

ch_cache( set )
	WORD	set;
{
	WORD	value;
	LONG	data;
	WORD	temp;
#if 0	/* take out for sparrow	*/
	menu_addr[BITBLT].ob_state &= ~DISABLED;
#endif
/*	menu_ienable( menu_addr, BITBLT, TRUE );	*/

	if ( m_cpu == 30 )
	{
	  if ( set )
	    data = ( s_cache ) ? CACHE_ON : CACHE_OFF;
	  else
	    data = 0xFFFFFFFFL;

	  if ( inq_cache( data ) == XCA_ON )
	    s_cache = TRUE;
	  else
	    s_cache = FALSE;

	  value = s_cache;


	}
	else
	{				/* turn the blt on	*/
					/* blt is there		*/
ch_1:	  if ( ( temp = trap14( 64, -1 ) ) & 0x2 )	
	  {
	    if ( set )
	    {
	      trap14( 64, ( cbit_save ) ? 1 : 0  );
	      set = FALSE;
	      goto ch_1;	/* check status again	*/
	    }
	    else
	      cbit_save = ( temp & 0x1 ) ? TRUE : FALSE; 	
	      		
	    value = cbit_save;
	  }
	  else
	  {
	    value = FALSE;
#if 0	/* take out for sparrow	*/
	    menu_addr[BITBLT].ob_state |= DISABLED;
#endif	    
/*	    menu_ienable( menu_addr, BITBLT, FALSE );	*/
	  }
	}

/*	menu_icheck( menu_addr, BITBLT, value ? TRUE : FALSE );	*/
#if 0	/* take out for sparrow	*/
	if ( value )
	  menu_addr[BITBLT].ob_state |= CHECKED;
	else 
	  menu_addr[BITBLT].ob_state &= ~CHECKED;
#endif
}



/* adjust object colors if it is invalid */
/* This routine should no longer be necessary, but is left
 * in for the TOS 4.02 release as a precautionary measure.
 * objc_draw now understands that "hollow, white, 3D" objects
 * should be drawn in the appropriate 3D color, or white if
 * there aren't enough colors, and the resources have been
 * updated accordingly	++ERS 1/19/93
 */

	VOID
adjdcol(color)
unsigned int color;
{
    REG OBJECT  *obj;

    if (gl_ws[13] > LWHITE)
	return;

    obj = get_tree(ADFILEIN);
    obj[FILEFT].ob_spec = (obj[FILEFT].ob_spec & 0xfffffff0) | color;
    obj[FIRIGHT].ob_spec = (obj[FIRIGHT].ob_spec & 0xfffffff0) | color;

    obj = get_tree(ADINSDIS);
    obj[IUP].ob_spec = (obj[IUP].ob_spec & 0xfffffff0) | color;
    obj[IDOWN].ob_spec = (obj[IDOWN].ob_spec & 0xfffffff0) | color;

    obj = get_tree(ADFORMAT);
    obj[SRCDRA].ob_spec = (obj[SRCDRA].ob_spec & 0xfffffff0) | color;
    obj[SRCDRB].ob_spec = (obj[SRCDRB].ob_spec & 0xfffffff0) | color;
    obj[ADRIVE].ob_spec = (obj[ADRIVE].ob_spec & 0xfffffff0) | color;
    obj[BDRIVE].ob_spec = (obj[BDRIVE].ob_spec & 0xfffffff0) | color;

    obj = get_tree(INWICON);
    obj[WUP].ob_spec = (obj[WUP].ob_spec & 0xfffffff0) | color;
    obj[WDOWN].ob_spec = (obj[WDOWN].ob_spec & 0xfffffff0) | color;

    obj = get_tree(MNSYSTEM);
    obj[ MFLEFT ].ob_spec = ( obj[ MFLEFT ].ob_spec & 0xfffffff0L ) | color;
    obj[ MFRIGHT ].ob_spec = ( obj[ MFRIGHT ].ob_spec & 0xfffffff0L ) | color;
    obj[ MFUP ].ob_spec = ( obj[ MFUP ].ob_spec & 0xfffffff0L ) | color;
    obj[ MFDOWN ].ob_spec = ( obj[ MFDOWN ].ob_spec & 0xfffffff0L ) | color;
    obj[ MKUPS ].ob_spec = ( obj[ MKUPS ].ob_spec & 0xfffffff0L ) | color;
    obj[ MKDOWNS ].ob_spec = ( obj[ MKDOWNS ].ob_spec & 0xfffffff0L ) | color;
}
	

/* Adjust Object Positions */

	VOID
adjobjects()
{
    REG		OBJECT *obj;
    WORD	x,y,w,h,dx,dy;	    
	
    obj = get_tree( ADINSDIS );
    objc_gclip( obj, IUP, &dx, &dy, &x, &y, &w, &h );
    obj[ IDOWN ].ob_y = h + obj[IUP].ob_y;   
    obj[ IDRIVE ].ob_y += 2;
    obj[ ITRASH ].ob_y += 2;
    obj[ IPRINTER ].ob_y += 2;

    obj = get_tree( INWICON );
    objc_gclip( obj, WUP, &dx, &dy, &x, &y, &w, &h );
    obj[ WDOWN ].ob_y = h + obj[ WUP ].ob_y;
    obj[ WFOLDER ].ob_height = gl_hchar;
    obj[ WNONE ].ob_height = gl_hchar;
    obj[ WOK ].ob_height = gl_hchar;
    obj[ WREMOVE ].ob_height = gl_hchar;
    obj[ WSKIP ].ob_height = gl_hchar;
    obj[ WQUIT ].ob_height = gl_hchar;    

    obj = get_tree( MNSYSTEM );
    objc_gclip( obj, MFUP, &dx, &dy, &x, &y, &w, &h );
    obj[ MFDOWN ].ob_y = h + obj[ MFUP ].ob_y;
    objc_gclip( obj, MKUPS, &dx, &dy, &x, &y, &w, &h );    
    obj[ MKDOWNS ].ob_y = h + obj[ MKUPS ].ob_y;
    obj[ MFBASE ].ob_height += 2;

    obj = get_tree( ADFILEIN );
    obj[ FIOK ].ob_y   += 2;
    obj[ FISKIP ].ob_y += 2;
    obj[ FICNCL ].ob_y += 2;
    obj[ FIRONLY ].ob_y -= 1;
    obj[ FIRWRITE ].ob_y -= 1;
}
