/*  	GEMRSLIB.C	5/14/84 - 04/09/85	Lowell Webster		*/
/*	Reg Opt		03/08/85 - 03/09/85	Derek Mui		*/
/*	Fix the get_addr for imagedata	4/16/86	Derek Mui		*/
/*	Unfix the get_addr		10/24/86	Derek Mui	*/
/*	Replace LSTRLEN as strlen	3/15/88		D.Mui		*/
/*	Dos_alloc in rs_load should belong child process 1/4/91	D.Mui	*/
/*	Change at rs_readit of sh_path	3/12/92			D.Mui	*/
/*	Fix rs_load to include new resource type	7/11/92	D.Mui	*/
/*	Fix rs_readit, if extended format is invalid, ignore it		*/
/*	Fix at dos_lseek and if not extended format make sure the word 	*/
/*	is zero				7/13/92		D.Mui		*/
/*	Check the RT_VRSN make sure it is greater or equal to RS_SIZE	*/
/*	Check the RT_VRSN make sure it is 0x0004 for extended type	*/
/*	02/23/93	cjg	Convert to Lattice C 5.51		*/
/*				Force the use of prototypes		*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.1
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "objaddr.h"
#include "rslib.h"
#include "gemdos.h"



#define RT_VRSN 	0		/* these must coincide w/ rshdr */
#define RT_OB 		1
#define RT_TEDINFO 	2
#define RT_ICONBLK 	3
#define RT_BITBLK 	4
#define RT_FREESTR 	5
#define RT_STRING 	6
#define RT_IMAGEDATA 	7
#define	RT_FREEIMG 	8
#define RT_TRINDEX 	9


EXTERN	LONG	trap();


EXTERN	PD	*currpd;
EXTERN 	LONG	ad_sysglo;
EXTERN  WORD	gl_width;
EXTERN  WORD	gl_wchar;
EXTERN  WORD	gl_hchar;
EXTERN  THEGLO	D;
EXTERN	BYTE	PATHEQUAL[];

LONG		rs_hdr;
LONG		rs_global;
UWORD		hdr_buff[HDR_LENGTH/2];


/*
*	Fix up a character position, from offset,row/col to a pixel value.
*	If column or width is 80 then convert to rightmost column or 
*	full screen width. 
*/
	VOID
fix_chpos(pfix, ifx)
	LONG		pfix;
	WORD		ifx;
{
	REG WORD	cpos,coffset;

	cpos = LWGET(pfix);
	coffset = (cpos >> 8) & 0x00ff;
	cpos &= 0x00ff;
	if ( (ifx) &&
	     (cpos == 80) )
	  cpos = gl_width;
	else
	  cpos *= (ifx) ? gl_wchar : gl_hchar;
	cpos += ( coffset > 128 ) ? (coffset - 256) : coffset;
	LWSET(pfix, cpos);
}



	VOID
rs_obfix(tree, curob)
	LONG		tree;
	WORD		curob;
{
	REG WORD		i, val;
	REG LONG		p;
						/* set X,Y,W,H with	*/
						/*   fixch, use val	*/
						/*   to alternate TRUEs	*/
						/*   and FALSEs		*/
	p = OB_X(curob);

	val = TRUE;
	for (i=0; i<4; i++)
	{
	  fix_chpos(p+(LONG)(2*i), val);
	  val = !val;
	}
}


	BYTE
*rs_str(stnum)
UWORD stnum;
{
	LONG		ad_string;

	rs_gaddr(ad_sysglo, R_STRING, stnum, &ad_string);
	LSTCPY( &D.g_loc1[0], ( BYTE *)ad_string);
	return( &D.g_loc1[0] );
}

	LONG
get_sub(rsindex, rtype, rsize)
	WORD		rsindex, rtype, rsize;
{
	UWORD		offset;

	offset = LWGET( rs_hdr + LW(rtype*2) );
						/* get base of objects	*/
						/*   and then index in	*/
	return( rs_hdr + LW(offset) + LW(rsize * rsindex) );
}


/*
 *	return address of given type and index, INTERNAL ROUTINE
*/
	LONG
get_addr(rstype, rsindex)
	REG UWORD		rstype;
	REG UWORD		rsindex;
{
	REG LONG		psubstruct;
	REG WORD		size;
	REG WORD		rt;
	WORD		valid;
	UWORD		junk;

	valid = TRUE;
	switch(rstype)
	{
	  case R_TREE:
#if ALCYON
		junk = ( UWORD )LW(rsindex*4);
		return( LLGET( LLGET(APP_LOPNAME) + junk ) );
#else
		return( LLGET( LLGET(APP_LOPNAME) + LW(rsindex*4) ) );
#endif
	  case R_OBJECT:
		rt = RT_OB;
		size = sizeof(OBJECT);
		break;
	  case R_TEDINFO:
	  case R_TEPTEXT:
		rt = RT_TEDINFO;
		size = sizeof(TEDINFO);
		break;
	  case R_ICONBLK:
	  case R_IBPMASK:
		rt = RT_ICONBLK;
		size = sizeof(ICONBLK);
		break;
	  case R_BITBLK:
	  case R_BIPDATA:
		rt = RT_BITBLK;
		size = sizeof(BITBLK);
		break;
	  case R_OBSPEC:
		psubstruct = get_addr(R_OBJECT, rsindex);
		return( ROB_SPEC );
	  case R_TEPTMPLT:
	  case R_TEPVALID:
		psubstruct = get_addr(R_TEDINFO, rsindex);
	  	if (rstype == R_TEPTMPLT)
	  	  return( RTE_PTMPLT );
	  	else
	  	  return( RTE_PVALID );
	  case R_IBPDATA:
	  case R_IBPTEXT:
	  	psubstruct = get_addr(R_ICONBLK, rsindex);
	 	if (rstype == R_IBPDATA)
		  return( RIB_PDATA );
		else
		  return( RIB_PTEXT );
	  case R_STRING:
		return( LLGET( get_sub(rsindex, RT_FREESTR, sizeof(LONG)) ) );
	  case R_IMAGEDATA:
		return( LLGET( get_sub(rsindex, RT_FREEIMG, sizeof(LONG)) ) );
	  case R_FRSTR:
		rt = RT_FREESTR;
		size = sizeof(LONG);
		break;
	  case R_FRIMG:
		rt = RT_FREEIMG;
		size = sizeof(LONG);
		break;
	  default:
		valid = FALSE;
		break;
	}
	if (valid)
	  return( get_sub(rsindex, rt, size) );
	else
	  return(-1L);
} /* get_addr() */


	VOID
fix_trindex()
{
	REG WORD		ii;
	REG LONG		ptreebase;

	ptreebase = get_sub(0, RT_TRINDEX, sizeof(LONG) );
	LLSET(APP_LOPNAME, ptreebase );

	for (ii = NUM_TREE-1; ii >= 0; ii--)
	  fix_long(ptreebase + LW(ii*4));
}


/*	Fix up the G_ICON table		*/

	VOID
fix_cicon()
{
	LONG	*ctable;
	UWORD	*header;	

	header = ( UWORD *)rs_hdr;
	if ( header[RT_VRSN] & 0x0004 )	/* if extended type */
	{
	  ctable = ( LONG *)( rs_hdr + (LONG)header[RS_SIZE]);
	  if ( ctable[1] && ( ctable[1] != -1 ) )
	    get_color_rsc( ( BYTE *)( ctable[1] + rs_hdr) );
	}
}


/*	Fix up the objects including color icons	*/

	VOID	
fix_objects()
{
	REG WORD		ii;
	REG WORD		obtype;
	REG LONG		psubstruct;
	LONG			*ctable;	
	UWORD			*header;

	header = ( UWORD *)rs_hdr;
 
	if ( header[RT_VRSN] & 0x0004 )
	{
	  ctable = ( LONG *)(rs_hdr + (LONG)header[RS_SIZE]);    	
	  ctable = ( LONG *)( ctable[1] + rs_hdr );
	}
	else
	  ctable = 0x0L; 

	for (ii = NUM_OBS-1; ii >= 0; ii--)
	{
	  psubstruct = get_addr(R_OBJECT, ii);
	  rs_obfix(psubstruct, 0);
	  obtype = (LWGET( ROB_TYPE ) & 0x00ff);
	  if ( ( obtype == G_CICON ) && ctable )
	    *((LONG*)ROB_SPEC) = ctable[*((LONG*)(ROB_SPEC))];	
		
	  if ( (obtype != G_BOX) && (obtype != G_IBOX) && (obtype != G_BOXCHAR) && 
		( obtype != G_CICON ) )
	    fix_long(ROB_SPEC);
	}
}


	VOID
fix_tedinfo()
{
	REG WORD		ii, i;
	REG LONG		psubstruct;
	LONG		tl[2], ls[2];


	for (ii = NUM_TI-1; ii >= 0; ii--)
	{
	  psubstruct = get_addr(R_TEDINFO, ii);
	  tl[0] = tl[1] = 0x0L;
	  if (fix_ptr(R_TEPTEXT, ii) )
	  {
	    tl[0] = RTE_TXTLEN;
	    ls[0] = RTE_PTEXT;
	  }
	  if (fix_ptr(R_TEPTMPLT, ii) )
	  {
	    tl[1] = RTE_TMPLEN;
	    ls[1] = RTE_PTMPLT;
	  }
	  for(i=0; i<2; i++)
	  {
	    if (tl[i])
	      LWSET( tl[i], strlen( ( BYTE *)( LLGET(ls[i]) ) ) + 1 );
	  }
	  fix_ptr(R_TEPVALID, ii);
	}
}


	VOID
fix_nptrs(cnt, type)
	WORD		cnt;
	WORD		type;
{
	REG WORD		i;

	for(i=cnt; i>=0; i--)
	  fix_long( get_addr(type, i) );
}


	WORD
fix_ptr(type, index)
	WORD		type;
	WORD		index;
{
	return( fix_long( get_addr(type, index) ) );
}


	WORD
fix_long(plong)
	REG LONG		plong;
{
	REG LONG		lngval;

	lngval = LLGET(plong);
	if (lngval != -1L)
	{
	  LLSET(plong, rs_hdr + lngval);
	  return(TRUE);
	}
	else
	  return(FALSE);
}


/*
*	Set global addresses that are used by the resource library 
*	subroutines
*/
	WORD
rs_sglobe( pglobal )
	LONG		pglobal;
{
	rs_global = pglobal;
	rs_hdr = LLGET(APP_RSCADDR);
	return( TRUE );
}


/*
*	Free the memory associated with a particular resource load.
*/
	WORD
rs_free( pglobal )
	LONG	pglobal;
{
	UWORD		*header;
	LONG		*ctable;

	rs_sglobe(pglobal);
	header = ( UWORD *)rs_hdr;

	if ( header )
	{
	  if ( header[RT_VRSN] & 0x0004 )	/* extended format */
	  {
	    ctable = ( LONG *)( rs_hdr + (LONG)header[RS_SIZE]);    	
	    if ( ctable[1] && ( ctable[1] != -1 ) )
	    {
	      ctable = ( LONG *)( ctable[1] + rs_hdr );
	      free_cicon( (CICONBLK **)ctable );
	    }
	  }

	  LLSET( APP_RSCADDR, 0x0L );
	  return( !dos_free( rs_hdr ) );
	}
	
	return( FALSE );
}


/*
*	Get a particular ADDRess out of a resource file that has been
*	loaded into memory.
*/
	WORD
rs_gaddr(pglobal, rtype, rindex, rsaddr)
	LONG		pglobal;
	UWORD		rtype;
	UWORD		rindex;
	REG LONG		*rsaddr;
{
	if ( rs_sglobe(pglobal) )
	{
	  *rsaddr = get_addr(rtype, rindex);
	  return( *rsaddr != -1L );
	}

	return( FALSE );
}


/*
*	Set a particular ADDRess in a resource file that has been
*	loaded into memory.
*/

	WORD
rs_saddr( pglobal, rtype, rindex, rsaddr )
	LONG		pglobal;
	UWORD		rtype;
	UWORD		rindex;
	LONG		rsaddr;
{
	REG LONG		psubstruct;

	if ( rs_sglobe( pglobal ) )
	{
	  psubstruct = get_addr(rtype, rindex);
	  if (psubstruct != -1L)
	  {
	    LLSET( psubstruct, rsaddr);
	    return(TRUE);
	  }
	}

	return( FALSE );
}


/*
*	Read resource file into memory and fix everything up except the
*	x,y,w,h, parts which depend upon a GSX open workstation.  In the
*	case of the GEM resource file this workstation will not have
*	been loaded into memory yet.
*/
	WORD
rs_readit( pglobal, rsfname )
	LONG		pglobal;
	LONG		rsfname;
{
	REG UWORD	ret;
	BYTE		rspath[128];
	REG WORD	fd;
	LONG		rslsize;
						/* make sure its there	*/
	LSTCPY( rspath, ( BYTE *)rsfname );

	if ( !sh_find( ( LONG )rspath, ( WORD(*)())NULLPTR, PATHEQUAL, TRUE ) )
	  return(FALSE);
						/* init global		*/
	rs_global = pglobal;
						/* open then file and	*/
						/*   read the header	*/
	ret = FALSE;

	if ( ( fd = dos_open( rspath, RMODE_RD) ) >= 0 )
	{
	  if ( dos_read( fd, HDR_LENGTH, ( LONG )&hdr_buff[0] ) > 0 )
	  {
						/* get size of resource	*/

						/* New format		*/
	     if ( hdr_buff[RT_VRSN] & 0x0004 )		
	     {					/* seek to the 1st entry*/
						/* of the table		*/
	       if ( dos_lseek( fd, SMODE, (LONG)(hdr_buff[RS_SIZE]) ) 
		    != hdr_buff[RS_SIZE] )
	       {
	         goto rs_end;
	       }
						/* read the size	*/
	       if ( dos_read( fd, sizeof(LONG), ( LONG)&rslsize ) != sizeof(LONG) )
	       {
	         goto rs_end;
	       }

	     }
	     else 	
	       rslsize = hdr_buff[RS_SIZE];
						/* allocate memory	*/
	     if ( rs_hdr = dos_xalloc( rslsize, 3 ) )
	     {
						/* read it all in 	*/
	        dos_lseek( fd, SMODE, 0x0L );
	        if ( trap( X_READ, fd, rslsize, rs_hdr ) == rslsize )
		{
	          do_rsfix( rs_hdr, (UWORD)rslsize );	/* do all the fixups	*/
		  ret = TRUE;
		}
		else
		  dos_free( rs_hdr );
	     }
	  }
rs_end:
	  dos_close( fd );
	}

	return( ret );
}


/* do all the fixups. rs_hdr must be initialized	*/

	VOID
do_rsfix(hdr,size)
	LONG	hdr;
	WORD	size;
{
	REG WORD		ibcnt;

	LLSET( APP_RSCADDR, hdr );
	LWSET( APP_RSCSIZE, size );
					/* xfer RT_TRINDEX to global	*/
					/*   and turn all offsets from	*/
					/*   base of file into pointers	*/

	fix_cicon();			/* fix color icon		*/
	fix_trindex();
	fix_tedinfo();
	ibcnt = NUM_IB-1;
	fix_nptrs(ibcnt, R_IBPMASK);
	fix_nptrs(ibcnt, R_IBPDATA);
	fix_nptrs(ibcnt, R_IBPTEXT);
	fix_nptrs(NUM_BB-1, R_BIPDATA);
	fix_nptrs(NUM_FRSTR-1, R_FRSTR);
	fix_nptrs(NUM_FRIMG-1, R_FRIMG);
}



/*
*	Fix up objects separately so that we can read GEM resource before we
*	do an open workstation, then once we know the character sizes we
*	can fix up the objects accordingly.
*/
	VOID
rs_fixit( pglobal )
	LONG		pglobal;
{
	rs_sglobe( pglobal );
	fix_objects();
}


/*	Fix a resource that is already in the memory	*/

	VOID
rs_rcfix( pglobal, header )
	LONG		pglobal;
	BYTE		*header;
{
	rs_global = pglobal;	/* set the macro 	*/
	rs_hdr = ( LONG)header;	/* set the address	*/
	do_rsfix( rs_hdr, header[17] );
	rs_fixit( pglobal );
}


/*	RS_LOAD		mega resource load	*/

	WORD
rs_load( pglobal, rsfname )
	REG LONG	pglobal;
	LONG		rsfname;
{
	REG WORD		ret;

	Debug7( "Resource load " );
	Debug7( rsfname );
	Debug7( "\r\n" );
	if ( ret = rs_readit(pglobal, rsfname) )
	  rs_fixit(pglobal);		/* save the memory address */
	else
	  Debug1( "Rsrc_load fails\r\n" );

	return( ret );
}

