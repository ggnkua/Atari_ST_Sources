/*
**
** Dies ist das Hauptmodul des CD-XFS fuer MagiX
** Entwickelt mit PureC und Pasm.
**
** (C) Andreas Kromke 1997
**
**
*/

#include "cd-mxfs.h"

static void cdecl	xfs_sync( MX_DMD *dmd );
static void cdecl	xfs_pterm( MX_DMD *dmd, PD *pd );
static LONG cdecl	xfs_garbcoll( MX_DMD *dmd );
static void cdecl	xfs_freeDD( MX_DD *dd );
static LONG cdecl   xfs_drv_open( MX_DMD *dmd );
static LONG cdecl   xfs_drv_close( MX_DMD *dmd, WORD mode );
static MX_DD *cdecl xfs_path2DD( MX_DD *dd, char *path, WORD mode,
     						char **restp, MX_DD **symlink_dd,
     						void **symlink );
static LONG cdecl	xfs_sfirst( MX_DD *dd, char *name, DTA *dta,
     						WORD attrib, void **symlink );
static LONG cdecl	xfs_snext( DTA *dta, MX_DMD *dmd, void **symlink );
static LONG cdecl	xfs_fopen( MX_DD *dd, char *name, WORD omode,
     						WORD attrib, void **symlink );
static LONG cdecl	xfs_fdelete( MX_DD *dd, char *name );
static LONG cdecl	xfs_link( MX_DD *altdd, MX_DD *neudd,
							char *altname, char *neuname,
							WORD flag );
static LONG cdecl	xfs_xattr( MX_DD *dd, char *name, XATTR *xa,
							WORD mode );
static LONG cdecl	xfs_attrib( MX_DD *dd, char *name, WORD mode,
							WORD attrib );
static LONG cdecl   xfs_chown( MX_DD *dd, char *name, WORD uid,
							WORD gid );
static LONG cdecl   xfs_chmod( MX_DD *dd, char *name, WORD mode );
static LONG cdecl   xfs_dcreate( MX_DD *dd , char *name );
static LONG cdecl   xfs_ddelete( MX_DD *dd );
static LONG cdecl   xfs_DD2name( MX_DD *dd, char *buf, WORD buflen );
static LONG cdecl   xfs_dopendir( MX_DD *d, WORD tosflag );
static LONG cdecl   xfs_dreaddir( void *dh, WORD len, char *buf,
							XATTR *xattr, LONG *xr );
static LONG cdecl   xfs_drewinddir( void *dh );
static LONG cdecl   xfs_dclosedir( void *dh );
static LONG cdecl   xfs_dpathconf( MX_DD *dd, WORD which );
static LONG cdecl   xfs_dfree( MX_DD *dd, LONG buf[4] );
static LONG cdecl   xfs_wlabel( MX_DD *dd, char *name );
static LONG cdecl   xfs_rlabel( MX_DD *dd, char *name, char *buf,
     						WORD buflen );
static LONG cdecl   xfs_symlink( MX_DD *dd, char *name, char *to);
static LONG cdecl   xfs_readlink( MX_DD *dd, char *name, char *buf,
     						WORD buflen );
static LONG cdecl   xfs_dcntl( MX_DD *dd, char *name, WORD cmd,
     						LONG arg );



static LONG cdecl	dev_close( MX_FD *f );
static LONG cdecl	dev_read( MX_FD *f, LONG count, void *buf );
static LONG cdecl	dev_write( MX_FD *f, LONG count, void *buf );
static LONG cdecl	dev_stat( MX_FD *f, LONG *unselect,
							WORD rwflag, LONG apcode );
static LONG cdecl	dev_seek( MX_FD *f, LONG where, WORD mode );
static LONG cdecl	dev_datime( MX_FD *f, WORD d[2], WORD set);
static LONG cdecl	dev_ioctl( MX_FD *f, WORD cmd, void *buf );
static LONG cdecl	dev_getc( MX_FD *f, WORD mode );
static LONG cdecl	dev_getline( MX_FD *f, char *buf, LONG size,
							WORD mode );
static LONG cdecl	dev_putc( MX_FD *f, WORD mode, LONG val );



MX_KERNEL *kernel;
MX_DFSKERNEL *dfskernel;

CDECL_MX_XFS cdecl_cdxfs = {
	"CDROM",
	NULL,
	0L,
	NULL,
	xfs_sync,
	xfs_pterm,
	xfs_garbcoll,
	xfs_freeDD,
	xfs_drv_open,
	xfs_drv_close,
	xfs_path2DD,
	xfs_sfirst,
	xfs_snext,
	xfs_fopen,
	xfs_fdelete,
	xfs_link,
	xfs_xattr,
	xfs_attrib,
	xfs_chown,
	xfs_chmod,
	xfs_dcreate,
	xfs_ddelete,
	xfs_DD2name,
	xfs_dopendir,
	xfs_dreaddir,
	xfs_drewinddir,
	xfs_dclosedir,
	xfs_dpathconf,
	xfs_dfree,
	xfs_wlabel,
	xfs_rlabel,
	xfs_symlink,
	xfs_readlink,
	xfs_dcntl
	};

CDECL_MX_DEV cdecl_cddev = {
	dev_close,
	dev_read,
	dev_write,
	dev_stat,
	dev_seek,
	dev_datime,
	dev_ioctl,
	dev_getc,
	dev_getline,
	dev_putc
	};


/********************** MAIN ***********************/

WORD main( void )
{
	LONG ret;

	ret = Dcntl (KER_GETINFO, NULL, 0L);
	if (ret < E_OK) return ((WORD) ret);		/* Fehler */

	kernel = (MX_KERNEL *) ret;

	ret = Dcntl (DFS_GETINFO, "U:\\", 0L);
	if (ret < E_OK) return((WORD) ret);		/* Fehler */

	dfskernel = (MX_DFSKERNEL *) ret;

	ret = Dcntl(KER_INSTXFS, NULL, (LONG) &cdxfs);
	if	(ret < E_OK)
		return((WORD) ret);		/* Fehler */

	Ptermres(-1L, (WORD) E_OK);
	return(-1);
}

#pragma warn -par

/*******************************************************************
*
*
*
*******************************************************************/

static void cdecl	xfs_sync( MX_DMD *dmd )
{
}


/*******************************************************************
*
*
*
*******************************************************************/

static void cdecl	xfs_pterm( MX_DMD *dmd, PD *pd )
{
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	xfs_garbcoll( MX_DMD *dmd )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static void cdecl	xfs_freeDD( MX_DD *dd )
{
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_drv_open( MX_DMD *dmd )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_drv_close( MX_DMD *dmd, WORD mode )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static MX_DD *cdecl xfs_path2DD( MX_DD *dd, char *path, WORD mode,
     						char **restp, MX_DD **symlink_dd,
     						void **symlink )
{
	return((MX_DD *) EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	xfs_sfirst( MX_DD *dd, char *name, DTA *dta,
     						WORD attrib, void **symlink )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	xfs_snext( DTA *dta, MX_DMD *dmd, void **symlink )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	xfs_fopen( MX_DD *dd, char *name, WORD omode,
     						WORD attrib, void **symlink )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	xfs_fdelete( MX_DD *dd, char *name )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	xfs_link( MX_DD *altdd, MX_DD *neudd,
							char *altname, char *neuname,
							WORD flag )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	xfs_xattr( MX_DD *dd, char *name, XATTR *xa,
							WORD mode )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	xfs_attrib( MX_DD *dd, char *name, WORD mode,
							WORD attrib )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_chown( MX_DD *dd, char *name, WORD uid,
							WORD gid )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_chmod( MX_DD *dd, char *name, WORD mode )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_dcreate( MX_DD *dd , char *name )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_ddelete( MX_DD *dd )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_DD2name( MX_DD *dd, char *buf, WORD buflen )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_dopendir( MX_DD *d, WORD tosflag )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_dreaddir( void *dh, WORD len, char *buf,
							XATTR *xattr, LONG *xr )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_drewinddir( void *dh )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_dclosedir( void *dh )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_dpathconf( MX_DD *dd, WORD which )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_dfree( MX_DD *dd, LONG buf[4] )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_wlabel( MX_DD *dd, char *name )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_rlabel( MX_DD *dd, char *name, char *buf,
     						WORD buflen )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_symlink( MX_DD *dd, char *name, char *to)
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_readlink( MX_DD *dd, char *name, char *buf,
     						WORD buflen )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl   xfs_dcntl( MX_DD *dd, char *name, WORD cmd,
     						LONG arg )
{
	return(EINVFN);
}



/***************** GERŽTETREIBER ***************/


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	dev_close( MX_FD *f )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	dev_read( MX_FD *f, LONG count, void *buf )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	dev_write( MX_FD *f, LONG count, void *buf )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	dev_stat( MX_FD *f, LONG *unselect,
							WORD rwflag, LONG apcode )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	dev_seek( MX_FD *f, LONG where, WORD mode )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	dev_datime( MX_FD *f, WORD d[2], WORD set)
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	dev_ioctl( MX_FD *f, WORD cmd, void *buf )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	dev_getc( MX_FD *f, WORD mode )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	dev_getline( MX_FD *f, char *buf, LONG size,
							WORD mode )
{
	return(EINVFN);
}


/*******************************************************************
*
*
*
*******************************************************************/

static LONG cdecl	dev_putc( MX_FD *f, WORD mode, LONG val )
{
	return(EINVFN);
}
