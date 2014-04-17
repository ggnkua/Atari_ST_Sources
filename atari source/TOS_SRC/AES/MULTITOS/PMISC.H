/* p_misc.h */

#include "portab.h"
#include "obdefs.h"
#include "mnstuf.h"

#ifndef _PMISC_H_
#define _PMISC_H_
LONG	gemdos( WORD,... );
LONG	bios( WORD,...);
LONG	xbios( WORD,... );
WORD	form_do( OBJECT *, WORD );
VOID	wind_delete( WORD );
VOID	d_xlines( WORD, WORD * );
WORD	rsrc_load( BYTE * );
VOID	rsrc_free( VOID );
WORD	graf_handle( WORD *,WORD *,WORD *, WORD * );
VOID	menu_register( WORD, BYTE * );
VOID	asm1( VOID );
VOID	asm2( VOID );
VOID	asm3( VOID );
VOID	asm4( VOID );
VOID	objc_gclip( OBJECT *,WORD,WORD *,WORD *,WORD *,WORD *,WORD *,WORD *);
WORD	shel_get( BYTE *, WORD );
VOID	evnt_button( WORD,WORD,WORD,WORD *,WORD *,WORD *,WORD * );
VOID	menu_icheck( OBJECT *,WORD,WORD );
VOID	objc_add( OBJECT *, WORD, WORD );
VOID	rsrc_obfix( OBJECT *, WORD );
WORD	wind_create( WORD,WORD,WORD,WORD,WORD );
VOID	wind_calc( WORD,WORD,WORD,WORD,WORD,WORD,WORD *,WORD *,WORD *,WORD * );
VOID	ins_wicons( VOID );
VOID	shel_put( BYTE *,UWORD );
VOID	v_hardcopy( VOID );
WORD	appl_read( WORD,WORD,WORD * );
VOID	lbintoas( LONG,BYTE * );
VOID	form_center( OBJECT *,WORD *,WORD *,WORD *,WORD * );
VOID	wind_delete( WORD );
WORD	evnt_dclick( WORD, WORD );

/* FILE: CTRLBIND.C
 * --------------------------------------------------------------------
 */
/* Note:  This was moved from pgem.h.  Used by desktop sources. */
WORD 	crys_if(int opcode);
VOID	kickaes(VOID);
UWORD	appl_init(VOID);
WORD 	appl_exit(VOID);
WORD 	appl_find(BYTE *name);
WORD 	appl_search(WORD mode, BYTE *name, WORD *type, WORD *id);
VOID	appl_term(WORD id);
WORD 	appl_write(WORD rwid, WORD length, BYTE *pbuff);
WORD 	evnt_multi(UWORD flags, UWORD blck, UWORD bmsk, UWORD bst,
			UWORD m1flags, UWORD m1x, UWORD m1y, UWORD m1w,
			UWORD m1h, UWORD m2flags, UWORD m2x,
			UWORD m2y, UWORD m2w, UWORD m2h, LONG mepbuff,
			UWORD tlc, UWORD thc, UWORD *pmx, UWORD *pmy,
			UWORD *pmb, UWORD *pks, UWORD *pkr, UWORD *pbr);
WORD	evnt_timer(UWORD locnt, UWORD hicnt);
WORD	form_error(WORD number);
WORD 	form_alert(WORD button, BYTE *string);
WORD 	form_dial(WORD dtype, WORD ix, WORD iy, WORD iw, WORD ih,
			WORD x, WORD y, WORD w, WORD h);
WORD 	fsel_exinput(LONG pipath, LONG pisel, WORD *pbutton, BYTE *label);
WORD 	graf_mouse(WORD state, LONG form);
WORD 	graf_dragbox(WORD w, WORD h, WORD sx, WORD sy, WORD xc, WORD yc,
			WORD wc, WORD hc, WORD *pdx, WORD *pdy);
VOID	graf_mkstate(WORD *pmx, WORD *pmy, WORD *pmstate, WORD *pkstate);
WORD 	graf_rwind( WORD xorigin, WORD yorigin, WORD wmin, WORD hmin,
			GRECT *goff, WORD *pwend, WORD *phend);
WORD 	graf_rubbox( WORD xorigin, WORD yorigin, WORD wmin, WORD hmin,
			WORD *pwend, WORD *phend);
WORD 	graf_slidebox(OBJECT *tree, WORD parent, WORD obj, WORD isvert);
WORD 	graf_watchbox(OBJECT *tree, WORD obj, UWORD instate, UWORD outstate);
WORD 	menu_bar(OBJECT *tree, WORD showit);
 
/* FILE: CTRLBIND.C
 * --------------------------------------------------------------------
 */
/* Note:  This was moved from pgem.h.  Used by desktop sources. */
WORD 	menu_popup(MENU *Menu, WORD xpos, WORD ypos, MENU *MData);
WORD 	menu_attach(WORD flag, OBJECT *tree, WORD item, MENU *Menu);
WORD 	menu_settings(WORD flag, MN_SET *Values);
WORD 	menu_tnormal(LONG tree, WORD titlenum, WORD normalit);
WORD 	menu_istart(WORD flag, OBJECT *tree, WORD menu, WORD item);
WORD 	objc_change( LONG tree, WORD drawob, WORD depth, WORD xc, WORD yc,
			WORD wc, WORD hc, WORD newstate, WORD redraw);
WORD 	objc_delete(LONG tree, WORD delob);
WORD 	objc_find(OBJECT *tree, WORD startob, WORD depth, WORD mx, WORD my);
WORD 	objc_xfind(OBJECT *tree, WORD startob, WORD depth, WORD mx, WORD my);
WORD 	objc_offset(OBJECT *tree, WORD obj, WORD *poffx, WORD *poffy);
WORD 	objc_draw(LONG tree, WORD drawob, WORD depth, WORD xc, WORD yc,
			WORD wc, WORD hc);
WORD 	rsrc_gaddr(WORD rstype, WORD rsid, LONG *paddr);
WORD 	rsrc_rcfix(LONG header);
WORD	shel_envrn(LONG ppath, LONG psrch);
WORD 	shel_write(WORD doex, WORD isgr, WORD iscr, LONG pcmd, LONG ptail);
WORD 	wind_find(WORD mx, WORD my);
WORD 	wind_get(WORD w_handle, WORD w_field, WORD *pw1, WORD *pw2,
			WORD *pw3, WORD *pw4);
WORD 	wind_close(WORD handle);
WORD 	wind_open(WORD handle, WORD wx, WORD wy, WORD ww, WORD wh);
WORD 	wind_set(WORD w_handle, WORD w_field, WORD w2, WORD w3,
			WORD w4, WORD w5);
WORD 	wind_update(WORD mode);

/* FILE: DOSBIND.C
 * --------------------------------------------------------------------
 */
LONG	isdrive( VOID );

LONG	dos_pexec( WORD mode, BYTE *name, BYTE *tail, BYTE *envr );

WORD	pgmld( BYTE *pname, LONG **ldaddr, BYTE *tail, BYTE *envrn );

WORD	dos_sfirst( LONG pspec, WORD attr);

WORD	dos_snext( VOID );

WORD	dos_create( BYTE *pname, WORD access );

WORD	dos_open( BYTE *pname, WORD access );

VOID	dos_rename( BYTE *old, BYTE *new );

WORD	dos_read( WORD handle, UWORD cnt, LONG pbuffer );

UWORD	dos_write( WORD handle, LONG cnt, BYTE *pbuffer );

LONG	dos_lseek( WORD handle, WORD smode, LONG sofst );

WORD	dos_delete( BYTE *pdrvpath );

WORD	dos_gdir( WORD drive, LONG pdrvpath );

LONG	dos_xalloc( LONG nbytes, WORD type );

WORD	dos_gdrv( VOID );

WORD	dos_dta( LONG ldta );

LONG	dos_gdta( VOID );

WORD	dos_close( WORD handle );

LONG	dos_chdir( LONG pdrvpath );

WORD	dos_free( LONG maddr );

LONG	dos_sdrv( WORD newdrv );

WORD	do_cdir( WORD drive, BYTE *path );

VOID	dos_term( WORD code );

VOID	dos_setdir( REG BYTE path[], WORD mode );

/* FILE: KBALLOC.C
 * --------------------------------------------------------------------
 */
MLOCAL WORD mvalid(VOID);

GLOBAL VOIDP lmalloc( REG LONG size );

GLOBAL VOID free( VOIDP xfb);

GLOBAL VOIDP malloc( size_t size );

GLOBAL VOIDP lcalloc( LONG count, REG LONG size );

GLOBAL VOIDP calloc( size_t count, size_t size );

GLOBAL VOIDP lrealloc( VOIDP xrb, REG LONG size );

GLOBAL VOIDP realloc( VOIDP ptr, size_t size );

GLOBAL VOID mdump( VOID );

GLOBAL LONG mavail( VOID );

GLOBAL VOID mheap( VOIDP add, size_t size );

VOID initkballoc( VOID );
/* FILE: ROMCART.C
 * --------------------------------------------------------------------
 */
WORD	 cart_init( VOID );

/*CARTNODE *cart_find( WORD fill );*/

WORD	cart_sfirst( BYTE *pdta, WORD attr );

WORD	cart_snext( VOID );

VOID	ld_cartacc( VOID );

WORD	cart_exec( BYTE *pcmd, BYTE *ptail );

WORD	c_sfirst( BYTE *path );








/* FILE: UTILITY.C
 * --------------------------------------------------------------------
 */
BYTE	*r_slash( REG BYTE *path );

VOID	lbintohex( LONG longval, BYTE buffer[] );

VOID	lbintoasc( REG LONG longval, REG BYTE buffer[] );

WORD	asctobin( BYTE *ptr, LONG *value );

VOID	r_get( REG WORD *pxywh, WORD *px, WORD *py, WORD *pw, WORD *ph );

VOID	r_set( REG WORD *pxywh, WORD x, WORD y, WORD w, WORD h );

VOID	rc_constrain( REG GRECT *pc, REG GRECT *pt );

VOID	rc_copy( REG WORD *psxywh, REG WORD *pdxywh );

VOID	rc_union( REG GRECT *p1, REG GRECT *p2 );

WORD	rc_intersect( REG GRECT *p1, REG GRECT *p2 );

UWORD	inside( REG WORD x, REG WORD y, REG GRECT *pt );

WORD	rc_equal( REG WORD *p1, REG WORD *p2 );

VOID	movs( REG WORD num, REG BYTE *ps, REG BYTE *pd );

WORD	min( WORD a, WORD b );

WORD	max( WORD a, WORD b );

VOID	bfill( REG WORD num, REG BYTE bval, REG BYTE *addr );

BYTE	toupper( REG BYTE ch );

VOID	upperstr( BYTE *str );

BYTE	*scasb( REG BYTE *p, REG BYTE b );

WORD	strlen( REG BYTE *p1 );

WORD	strcmp( REG BYTE *p1, REG BYTE *p2 );

WORD	nstrcmp( BYTE *p1, BYTE **dest );

WORD	strchk( REG BYTE s[], REG BYTE t[] );

BYTE	*strcpy( REG BYTE *ps, REG BYTE *pd );

BYTE	*strscn( REG BYTE *ps, REG BYTE *pd, REG BYTE stop );

BYTE	*strcat( REG BYTE *ps, REG BYTE *pd );

VOID	fmt_str( REG BYTE *instr, REG BYTE *outstr );

VOID	unfmt_str( REG BYTE *instr, REG BYTE *outstr );

VOID	fs_sset( LONG tree, WORD obj, LONG pstr, REG LONG *ptext, WORD *ptxtlen );

VOID	inf_sset( LONG tree, WORD obj, BYTE *pstr );

VOID	fs_sget( LONG tree, WORD obj, LONG pstr );

VOID	inf_sget( LONG tree, WORD obj, BYTE *pstr );

VOID	inf_fldset( LONG tree, WORD obj, UWORD testfld, UWORD testbit,
		    UWORD truestate, UWORD falsestate );

WORD	inf_gindex( LONG tree, WORD baseobj, WORD numobj );

WORD	inf_what( REG LONG tree, REG WORD ok, REG WORD cncl );

VOID	merge_str( REG BYTE *pdst, REG BYTE *ptmp, UWORD parms[] );

WORD	wildcmp( REG BYTE *pwild, REG BYTE *ptest );

BYTE	*nstrcpy( BYTE *src, BYTE *dest, WORD n );

WORD	mode2res( WORD mode );
WORD	res2mode( WORD res );

/* LARGE.S */
VOID	expand_data(BYTE *saddr,BYTE *daddr,BYTE *mask,WORD splanes,WORD  dplanes, 
	WORD w,WORD h);
WORD	LSTCPY(BYTE *src,BYTE *dst);
WORD	LBWMOV(BYTE *dst,BYTE *src);
VOID	LWCOPY(WORD *dest,WORD *source,WORD size);
VOID	LBCOPY(BYTE *dest,BYTE *source,WORD size);
LONG	lmul(LONG, LONG);
LONG	ldiv(LONG, LONG);
WORD	reverse(WORD);

/* MEDIACH.S */
int	mediach( int devno );

/* TRAPS.S */
/* Note: I didn't include prototypes for trap* since the number of params
 * varies.
 */
VOID	kickit( LONG );
LONG	trap( WORD,... );
LONG	trap13( WORD,... );
LONG	trap14( WORD,... );


/* INTERRUPT.S */
/* Note: No prototype for forkq because of varying no. of params. */
WORD	far_bchange(VOID);
WORD	far_mchange(VOID);
VOID	justretf( VOID );

/* GSX2.S */
VOID	gsx2( VOID );
WORD	mul_div( WORD, WORD, WORD );
VOID	i_ptsin( LONG );
VOID	i_intin( LONG );
VOID	i_intout( LONG );
VOID	i_ptsout( LONG );
VOID	i_ptr( LONG );
VOID	i_ptr2( LONG );
VOID	i_lptr1( LONG );
VOID	m_lptr2( LONG );

/* DESKSTAR.S */
VOID	desktop( VOID );
WORD	crystal( LONG );
VOID	desk_vdi( LONG * );

/* AESTRAP.S */
VOID	givecpm( VOID );
VOID	takecpm( VOID );
WORD	retake( VOID );
WORD	giveerr( VOID );
WORD	takeerr( VOID );
VOID	deskerr( VOID );
VOID	desknoerr( VOID );
VOID	releaes( VOID );
VOID	waitforaes( VOID );
BYTE	*dos_exec( LONG, WORD, LONG );
LONG	newchkkbd( VOID );
WORD	vdicode( LONG );
VOID	Bigstack( VOID );

/* AESDISPA.S */
VOID	cli( VOID );
VOID	sti( VOID );

WORD	spl7( VOID );
VOID	spl( WORD );

#pragma inline d0=spl7()  {"40c0007c0700";}	/* move.w sr,d0; ori.w #$700,sr */
#pragma inline spl(d0)    {"46c0";}		/* move.w d0,sr */

WORD	rundisp( VOID );
VOID	dispret( VOID );
VOID	toaes( LONG, LONG, WORD );
VOID	savestate( VOID );
VOID	switchto( LONG );
WORD	runaes( VOID );
WORD	setrunacc( VOID );

#endif

