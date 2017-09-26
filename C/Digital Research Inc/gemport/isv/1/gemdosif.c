/*	JDOS.C		11/12/84 - 04/14/85	Lowell Webster		*/
/*	GEMDOSIF.C 	5/15/85 - 6/4/85	MDF			*/

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.1
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <portab.h>
#include <machine.h>
#include <dos.h>

GLOBAL UWORD	DOS_AX;	/* really a "DOS_RET"	*/
GLOBAL UWORD	DOS_ERR;

EXTERN	LONG	gemdos();
BYTE *		str_copy();


#define X_TABOUT 0x02
#define X_PRTOUT 0x05
#define X_RAWCON 0x06
#define X_SETDRV 0x0E
#define X_GETDRV 0x19
#define X_SETDTA 0x1A
#define X_GETFREE 0x36
#define X_MKDIR 0x39
#define X_RMDIR 0x3A
#define X_CHDIR 0x3B
#define X_CREAT 0x3C
#define X_OPEN 0x3D
#define X_CLOSE 0x3E
#define X_READ 0x3F
#define X_WRITE 0x40
#define X_UNLINK 0x41
#define X_LSEEK 0x42
#define X_CHMOD 0x43
#define X_GETDIR 0x47
#define X_MALLOC 0x48
#define X_MFREE 0x49
#define X_SETBLOCK 0x4A
#define X_EXEC 0x4B
#define X_SFIRST 0x4E
#define X_SNEXT 0x4F
#define X_RENAME 0x56
#define X_GSDTOF 0x57

	WORD
isdrive()
{
	return ( dos_sdrv( dos_gdrv() ) );
}


	WORD
pgmld(handle, pname, ldaddr)
	WORD	handle;
	BYTE	*pname;
	LONG	**ldaddr;
{
	LONG	length;
	LONG	*temp;

	*ldaddr = gemdos(X_EXEC,3,pname,"",NULLPTR);
	if (!DOS_ERR)
	{						 /* code+data+bss lengths */
	  temp = *ldaddr;
	  length = temp[3] + temp[5] + temp[7] + 0x100;	/* and base page length	*/
	  gemdos(X_SETBLOCK,0, *ldaddr, length);
	  if (!DOS_ERR)
	    return(TRUE);
	  else
	    return(-1);
	}
	else
	  return(-1);
}


	VOID
chrout(chr)
	WORD	chr;
{
	return( gemdos(X_TABOUT,chr) );
}
	BYTE
rawcon(parm)
	WORD	parm;
{
	return( (BYTE)gemdos(X_RAWCON, parm) );
}

	VOID
prt_chr(chr)
	WORD	chr;
{
	return( gemdos(X_PRTOUT,chr) );
}

	VOID
dos_func(function, parm)
	UWORD		function;
	LONG		parm;
{
	return( gemdos(function,parm) );
}

	WORD
dos_gdrv()
{
	return( gemdos(X_GETDRV) );
}

	VOID
dos_sdta(ldta)
	LONG		ldta;
{
	return(gemdos(X_SETDTA,ldta));
}

	WORD
dos_sfirst(pspec, attr)
	LONG		pspec;
	WORD		attr;
{
	return(!gemdos(X_SFIRST,pspec,attr));
}

	WORD
dos_snext()
{
	return(!gemdos(X_SNEXT));
}

	WORD
dos_open(pname, access)
	BYTE		*pname;
	WORD		access;
{
	LONG		ret;

	ret = gemdos(X_OPEN,pname,access);
	if (DOS_ERR)
	  return(FALSE);
	else
	  return((UWORD)ret);
}

	WORD
dos_close(handle)
	WORD		handle;
{
	return( gemdos(X_CLOSE,handle) );
}

	UWORD
dos_read(handle, cnt, pbuffer)
	WORD		handle;
	UWORD		cnt;
	LONG		pbuffer;
{
	return(gemdos(X_READ,handle,(ULONG)cnt,pbuffer));
}

	UWORD
dos_write(handle, cnt, pbuffer)
	WORD		handle;
	UWORD		cnt;
	LONG		pbuffer;
{
	return(gemdos(X_WRITE,handle,(ULONG)cnt,pbuffer));
}

	LONG
dos_lseek(handle, smode, sofst)
	WORD		handle;
	WORD		smode;
	LONG		sofst;
{
	return( gemdos(X_LSEEK,sofst, handle, smode) );
}


#if 0
						/* just for an example	*/
	VOID
dos_exec(pcspec, segenv, pcmdln)
	LONG		pcspec;
	WORD		segenv;
	LONG		pcmdln;
{
	gemdos(X_EXEC,segenv,pcspec,pcmdln,NULLPTR); 
}	
#endif


	LONG
dos_chdir(pdrvpath)
	LONG		pdrvpath;
{
	return(gemdos(X_CHDIR,pdrvpath));
}

	WORD
dos_gdir(drive, pdrvpath)
	WORD		drive;
	REG BYTE *	pdrvpath;
{
	REG WORD ret;

	ret = gemdos(X_GETDIR,pdrvpath,drive);
	if (pdrvpath[0] == '\\')
	  str_copy(&pdrvpath[1],pdrvpath);	/* remove leading '\' */
	return(ret);
}

	WORD
dos_sdrv(newdrv)
	WORD		newdrv;
{
	return( gemdos(X_SETDRV,newdrv) );
}

	LONG
dos_create(name, attr)
	BYTE	*name;
	WORD	attr;
{
	return(gemdos(X_CREAT,name,attr));
}


	WORD
dos_mkdir(path,attr)
	BYTE	*path;
	WORD	attr;
{
	gemdos(X_MKDIR,path);
	return( !DOS_ERR );
}

	WORD
dos_chmod(name,wrt,mod)
	BYTE	*name;
	WORD	wrt,mod;
{
	return( gemdos(X_CHMOD,name,wrt,mod) );
}


	WORD
dos_set(h,time,date)
	UWORD	h,time,date;
{
	UWORD	buf[2];

	buf[0] = time;
	buf[1] = date;
	return( gemdos(X_GSDTOF,&buf[0],h,TRUE) );
}
	WORD
dos_label(drive,plabel)
	BYTE	drive;
	BYTE	*plabel;
{
	BYTE	buf[50];		/* 44 bytes used	*/
	BYTE	path[8];
	REG WORD i;

	for (i=0;i<50;)
	  buf[i++] = 0;
	gemdos(X_SETDTA,&buf[0]);
	str_copy(" :\\*.*",path);
	path[0] = (drive + 'A') - 1;
	if (!gemdos(X_SFIRST,path,0x08))
	{
	  str_copy(&buf[30],plabel);
	  return(TRUE);
	}
	else
	  return(FALSE);
}

	LONG
dos_delete(name)
	BYTE	*name;
{
	return (gemdos(X_UNLINK,name) );
}

	WORD
dos_space(drv,ptotal, pavail)
	WORD	drv;
	LONG	*ptotal, *pavail;
{
	LONG	buf[4];
	LONG	mult;

	gemdos(X_GETFREE,buf,drv);	/* 0=default, 1=A for gemdos	*/
	mult = buf[3] * buf[2];
	*ptotal = mult * buf[1];
	*pavail = mult * buf[0];
	return(TRUE);
}

	WORD
dos_rename(p1,p2)
	BYTE	*p1;
	BYTE	*p2;
{
	return(gemdos(X_RENAME,0x0,p1,p2) );
}

	WORD
dos_rmdir(path)
	BYTE	*path;
{
	return ( gemdos(X_RMDIR,path) );
}



	LONG
dos_alloc(nbytes)
	LONG		nbytes;
{
	REG LONG ret;

	ret = gemdos(X_MALLOC,nbytes);
	if (ret == 0)
	  DOS_ERR = TRUE;		/* gemdos() sets it to FALSE	*/
	return(ret);
}

/*
*	Returns the amount of memory available in bytes
*/
	LONG
dos_avail()
{
	return( gemdos( X_MALLOC, -1L) );
}

	WORD
dos_free(maddr)
	LONG		maddr;
{
	return( gemdos(X_MFREE,maddr) );
}

	BYTE
*str_copy(ps, pd)
	REG BYTE	*ps, *pd;
{
	while(*pd++ = *ps++)
	  ;
	return(pd);
}
