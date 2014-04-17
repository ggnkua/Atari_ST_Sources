/*	DOSBIND.C		8/31/90					*/
/*	.title	'GEMDOS Bindings for AES/Desktop'			*/
/*	Bug fixed 2/5/87						*/
/*	Added global definition	11/30/87	D.Mui			*/
/*	Add do_cdir		1/28/88		D.Mui			*/
/*	Use MAC to assemble	6/29/90		D.Mui			*/
/*	Restore into C language	from 3.01	8/31/90	D.Mui		*/
/*	Convert to Lattice C 5.51		2/17/93	C.Gee		*/
/*	Force the use of prototypes		2/25/93 C.Gee		*/
/*	Added dos_create() and dos_delete()     7/8/93  C.Gee		*/
/*
 *	Set the DESKPRG flag to compile this file for a
 *	replacement Desktop. Clear it for making GEM.SYS
 *
 *	See the Defines in SOFTLOAD.H
 */


#include "pgem.h"
#include "pmisc.h"
#include "gemdos.h"
#include "machine.h"
#include "softload.h"

EXTERN	LONG	trap();

GLOBAL	WORD	DOS_AX;

#if DESKPRG
EXTERN	WORD	d_multi;
#else
EXTERN	WORD	gl_multi;
#endif

/*  I know what this does, but I don't
*  know why it's supposed to do it.
*/
	WORD
isdrive( VOID )
{
	return( dos_sdrv( dos_gdrv() ) );
}


	LONG
dos_pexec( mode, name, tail, envr )
	WORD	mode;
	BYTE	*name,*tail,*envr;
{
	return( trap( X_EXEC,mode,name,tail,envr ) );
}
	

	WORD				/* 8/31/90	*/
pgmld( pname, ldaddr, tail, envrn )
  	BYTE	*pname,*tail,*envrn;
  	LONG	**ldaddr;
{
  	LONG	length;
  	LONG	*temp;
  
	if ( *ldaddr = ( LONG *)trap( X_EXEC, 3, pname, tail, envrn ) )
	{
  	  temp = *ldaddr;		/* code+data+bss lengths */
#if DESKPRG
	  if (d_multi)
#else
	  if (gl_multi)
#endif
  	    length = temp[3] + temp[5] + temp[7] + 0x150;
	  else
	  {
	    length = temp[3] + temp[5] + temp[7] + 0x1100;	/* gives 4K of stack, +256 bytes for basepage */
	    temp[1] = temp[0] + length;		/* save top of TPA for user stack */
	  }
	  if ( !trap( X_MSHRINK, 0, *ldaddr, length ) )
  	    return( TRUE );
	}

	return(-1);
}


	WORD				/* 8/31/90	*/
dos_sfirst(pspec, attr)
  	LONG		pspec;
  	WORD		attr;
{
  	REG LONG		ret;

  	if ( !( ret = trap(X_SFIRST,pspec,attr) ) )
  	  return(TRUE);

  	if ( ret == ENMFIL || ret == EFILNF )
  	  DOS_AX = E_NOFILES;

 	return(FALSE);
}


	WORD			/* 8/31/90	*/
dos_snext( VOID )
{
  	REG LONG		ret;

  	if ( !( ret = trap(X_SNEXT) ) )
  	  return(TRUE);

  	if ( ret == ENMFIL || ret == EFILNF )
  	  DOS_AX = E_NOFILES;

  	return(FALSE);
}


	WORD
dos_create( pname, access)
  	BYTE		*pname;
  	WORD		access;
{
  	return( (WORD)trap( X_CREAT, pname, access ) );
}



	WORD
dos_open(pname, access)
  	BYTE		*pname;
  	WORD		access;
{
  	return( (WORD)trap( X_OPEN, pname, access ) );
}

	VOID
dos_rename( old, new )
	BYTE	*old,*new;
{
	trap( X_RENAME, 0, old, new );
}

	
	WORD
dos_read(handle, cnt, pbuffer)
  	WORD		handle;
  	UWORD		cnt;
  	LONG		pbuffer;
{
 	LONG		ret;

  	ret = trap(X_READ,handle,(ULONG)cnt,pbuffer);
  	return((UWORD)ret);
}


	UWORD
dos_write(handle, cnt, pbuffer)
  	WORD		handle;
  	LONG		cnt;
	BYTE		*pbuffer;
{
 	return( (UWORD)trap(X_WRITE,handle,cnt,pbuffer));
}


	WORD			/* 7/8/93	*/
dos_delete( pdrvpath )
	BYTE *pdrvpath;
{
	return( ( WORD )trap( X_UNLINK, pdrvpath ) );
}



	LONG
dos_lseek(handle, smode, sofst)
  	WORD		handle;
  	WORD		smode;
  	LONG		sofst;
{
  	return( trap(X_LSEEK,sofst, handle, smode) );
}


	WORD
dos_gdir(drive, pdrvpath)
  	WORD		drive;
  	LONG		pdrvpath;
{
 	return( ( WORD )trap(X_GETDIR,pdrvpath,drive) );
}



	LONG
dos_xalloc(nbytes, type)
  	LONG		nbytes;
	WORD		type;
{
	LONG		ret;
#if DESKPRG
	if (!d_multi) {
#else
	if (!gl_multi) {
#endif
		type &= 0x03;
	}
	ret = trap( X_XMALLOC, nbytes, type );
	Debug1( "AES Dos_xalloc " );
	Ndebug1( nbytes );

	return( ret );
}


	WORD
dos_gdrv( VOID )
{
	return( ( WORD )trap(X_GETDRV) );
}

/*	Set dta buffer	*/

	WORD
dos_dta(ldta)
	LONG		ldta;
{
	return( ( WORD )trap(X_SETDTA,ldta));
}


	LONG
dos_gdta( VOID )
{
	return( trap(X_GETDTA) );
}


	WORD
dos_close(handle)
	WORD		handle;
{
	return( ( WORD )trap(X_CLOSE,handle) );
}


	LONG			/* 9/4/90	*/
dos_chdir(pdrvpath)
	LONG		pdrvpath;
{
	return( trap( X_CHDIR, pdrvpath ) );
}



	WORD
dos_free(maddr)
	LONG		maddr;
{
	Debug7( "AES frees " );
	Ndebug7( maddr );
	return( ( WORD )trap(X_MFREE,maddr) );
}


	WORD
dos_sdrv(newdrv)
	WORD		newdrv;
{
	return( ( WORD )trap(X_SETDRV,newdrv) );
}


	WORD		/* 8/30/90	*/
do_cdir( drive, path )
	WORD	drive;
	BYTE	*path;
{
	trap( X_SETDRV, drive );
	return( ( WORD )trap( X_CHDIR, path ) );
}


	VOID
dos_term( code )
	WORD	code;
{
	trap( X_TERM, code );
}


/*	Set the current directory				*/
/*	The path should look like A:\ or A:\FOLDER for mode 1	*/
/*	The path should look like A:\FILENAME or 		*/
/*	A:\FOLDER\FILENAME for mode 0				*/


	VOID
dos_setdir( path, mode )
	REG BYTE	path[];
	WORD		mode;
{
	REG BYTE	*ptr;

	if ( path[0] == '\\' )		/* at the current root	*/
	{
	   dos_chdir( ( LONG )"\\" );
	   return;
	}

	if ( path[1] == ':' )		/* drive id	*/
	  dos_sdrv( (WORD)( toupper( path[0] ) - 'A') );
	else
	  return; 
	
	if ( mode )
	  dos_chdir( ( LONG )&path[2] );
	else
	{
	  ptr = r_slash( path );
	  if ( &path[2] == ptr )
	  {
	    Debug1( "Set to root\r\n" );		
	    dos_chdir( ( LONG )"\\" );
	  }
	  else
	  {
	    *ptr = 0;
	    dos_chdir( ( LONG )&path[2] );
	    *ptr = '\\';	
	  }
	}
}
