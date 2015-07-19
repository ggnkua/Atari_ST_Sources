/*  fsmain.c - GEMDOS file system notes and misc routines		*/
/*  xgetdrv,xsetdrv,xsetdta,xgetdta,uc,usr2xfr,xfr2usr	*/

/*
**
** GEMDOS file system
** ------------------
** Originally written by JSL as noted below.
**
** MODIFICATION HISTORY
**
**	13 Mar 85	SCC	Changed xgetfree() to return values into longs.
**				(As per spec).
**
**				Changed handling of getbpb() return to allow 
**				flagging of bad getbpb().
**
**	14 Mar 85	JSL	Modified getrec() to clear b_dirty flag.
**
**				Modified ixcreat() to force flush
**				(for the sake of xmkdir() ).
**
**	22 Mar 85	SCC	Modified xsetdrv() to return drive map (to 
**				bring up to spec functionality, specifically 
**				at request of Steve Schmitt (DR Logo) ).
**
**				Extended good/bad returns based on ckdrv() 
**				results.
**
**	26 Mar 85	JSL	Modified xsfirst() to be a front end to 
**				ixsfirst().  ixsfirst() is used internally by 
**				xexec() to force a disk access prior to 
**				xpgmld() so that media change info can be 
**				updated sooner.
**
**				Modified ixlseek() because of bug when pointer 
**				is at end of cluster prior to forward seek.
**
**			SCC	Made above actual changes from JSL's notes.
**
**	27 Mar 85	SCC	Modifed dcrack() and findit() to terminate with
**				indication of no file found if bad return from 
**				ckdrv().
**
**	28 Mar 85	SCC	Modified xchdir() to look for NEGATIVE return 
**				from ckdrv().
**
**	29 Mar 85	JSL	Fixed xrmdir() bug of "ghost" subdirectories.
**				Fixed problem creating files in unaccessed 
**				subdir.
**
**	 4 Apr 85	SCC	Modified several functions to improve 
**				readability.
**
**				Removed a number of old 'SCC  ?? ??? 85' 
**				modification marks, and began adding formfeeds 
**				between routines and routine headers.
**
**				Modified dup() to return long value and distinct
**				error codes.
**
**				Modified xforce() and ixforce() to return long 
**				value and distinct error codes, and to range 
**				check 'h'.
**
**				Now includes gemerror.h.
**
**				Modified xclose() and ixclose() to return long 
**				value and distinct error codes.
**
**	 5 Apr 85	SCC	Modified ixforce() to range check 'std', and 
**				moved it after xforce().
**
**	 8 Apr 85	SCC	Added declaration of 'drv' parameter to log().
**
**				Added 'long' type to declaration of flush() 
**				and error returns.
**
**				Added 'long' type to declaration of usrio().
**
**				Added 'int' type to declaration of getpath() 
**				and 'flg' parameter.
**
**				Added 'long' type to declaration of getcl() 
**				and error returns.
**
**				Added 'long' type to declaration of ckdrv() 
**				and error returns.
**
**				Added 'long' type to declaration of opnfil().
**
**				Added 'long' type to declaration of makopn().
**
**	 9 Apr 85	SCC	Added 'int' type to declaration of log2().
**
**				Added 'int' type to declaration of divmod().
**
**	10 Apr 85	SCC	Removed 'long' return from flush(), reversing
**				modification of 8 Apr 85, since errors from 
**				the BIOS are handled by longjmp()ing back to 
**				top of dispatcher.
**
**				Removed 'long' return from usrio(), reversing
**				modification of 8 Apr 85, since errors from 
**				the BIOS are handled by longjmp()ing back to 
**				top of dispatcher.
**
**				Changed definition of rwerr from 'int' to 'long'
**
**				Modified ixlseek() to return ERANGE and EINTRN.
**
**				Modified xwrite() to check validity of handle.
**
**				Modified ixclose() to check error returns from 
**				ixlseek().
**
**				Modified ixclose() to return EINTRN where JSL 
**				had marked 'some kind of internal error', and 
**				to return E_OK at end.
**
**				Modified getcl() to return EINTRN.
**
**				Modified nextcl() to return EINTRN and E_OK.
**
**				Added rc to scan() to check error returns from 
**				ixlseek().
**
**				Modified xsnext() to return E_OK and ENMFIL.
**
**				Modified xsfirst() to return E_OK and ENMFIL.
**
**	11 Apr 85	SCC	Modified opnfil() to return ENHNDL.
**
**				Modified ixcreat() to return EPTHNF, EACCDN.
**
**				Modified xrename() to return errors.
**
**				Added xfreset() and ixfreset().
**
**	12 Apr 85	SCC	Removed spurious ',0' from parameters passed 
**				to xclose() by xfreset().
**
**	14 Apr 85	SCC	Backed out modification of 11 Apr 85 that added
**				xfreset() and ixfreset().  They were not the 
**				solution to the problem they were aimed at 
**				fixing.  See corresponding note in the CLI 
**				about the ^C problem.
**
**				Modified ixdel() to not delete an open file.
**
**				Backed out modifications to getcl() (it is now 
**				'int' and returns -1).
**
**				Backed out modifications to nextcl() (it now 
**				returns -1).
**
**				Backed out modifications to clfix() (it us 
**				untyped).
**
**	16 Apr 85	SCC	Modified ixdel() to close the file if it is 
**				open, and then go ahead and delete it.  This 
**				fix was in response to the fact that AS68 
**				routinely deletes its files without closing 
**				them.
**
**	29 Apr 85	SCC	Modified xrename() to check for existence of 
**				new file name before attempting to rename old 
**				file.
**
**	 1 May 85	SCC	Did slight code optimization on ixsfirst().
**
**	 6 May 85	SCC	Modified ixsfirst() to report EFILNF on error 
**				return from findit().
**
**				Modified ixcreat() to return EPTHNF for null 
**				file name.
**
**	 7 May 85	SCC	Modified xchdir() to return EPTHNF on failure of
**				findit().
**
**	 8 May 85	SCC	Modified xchdir() to not change path on failure
**				of findit().
**
**	 9 May 85	SCC	Modified xrename() to return EACCDN if 
**				destination filename already exists.
**
**	13 May 85	SCC	Modified xchdir() to call ucase() before path 
**				string is used.
**
**				Modified findit() to call ucase() before name 
**				string is used.
**
**				Modified builds() to truncate pre-'.' portion 
**				of file name to 8 characters.
**
**				Modified xmkdir() to use ixcreat() instead of 
**				xcreat().
**
**				Modified xcreat() to prevent external caller 
**				from creating a subdirectory.
**
**	15 May 85	SCC	Modified xgetfree() to be 0=default, 1=A:, etc.
**
**	16 May 85	SCC	Modified builds() to terminate post-'.' 
**				portion of file name upon scanning a '.' as 
**				well as the other characters it was checking.
**
**	26 Jun 85       LTG     Fixed bug in xrename to return err from open.
**
**	27 Jun 85       LTG     Added "o_mod" parm to OFD data structure.
**
**				Modified xopen() & ixopen() to return EACCDN
**				if try to open file with read only mode in
**				read/write or write mode.
** 
**				Mod to xread() to return EACCDN err if try to
**				read file opened as write only.
** 
**				Modifiedixwrite()toreturnEACCDNerriftry
**				to write file opend as read only.
**
**				Modified getdmd() to return NULPTR if MGET 
**				failed.
**
**				Modified log() to return a long indicating 
**				ENSMEM if getdmd() failed.
**
**				Modified makofd() to return NULPTR if MGET 
**				fails.
**
**				Modified makdnd() to return NULPTR if MGET 
**				fails.
** 
**				Modified makopn() to return ENSMEM if MGET 
**				fails.
**
**				Modified scan() to return NULPTR if makofd()
**				or makdnd() fails.
**
**				Modified xcreate() to return (ENSMEM) if 
**				makofd() fails.
**
**				Modified xmkdir() to return ENSMEM if makofd()
**				or makdnd() fails.
**
**				Modified rmdir() to return ENSMEM if makofd() 
**				fails.
**
**	19 Jul 85       LTG	Modified scan() to make sure a file has not be 
**				deleted before creating a DND for it.  This 
**				fixes the bug that prevented some directories 
**				from being removed.
**
**	19 Jul 85	SCC	Modified scan() to prevent creation of a new 
**				DND for a subdirectory that already has one.
**
**				Added routine uc() to upper-case a single 
**				character and removed up_string().
**
**				Modified dcrack() to use uc().
**
**				Modified xcmps() to use uc().
**
**				Modified xchdir() to use uc().
**
**				Modified findit() to not use up_string().
**
**				Modified builds() to use uc().
**
**				Modified match() to use uc().
**
**	22 Jul 85	LTG	Modified ixcreate() to pass mode parameter to 
**				opnfl(), 0 for RO, 2 for RW.
**
**			SCC	Modified scan().  Modification of 19 Jul 85 
**				was not correct.
**
**				Modified ixcreat().  Modification of 22 Jul 85 
**				did not check for R/O status correctly.
**
**	23 Jul 85	SCC	Modified scan().  Still in pursuit of 
**				corrections to mods made on 22 Jul 85.
**
** 	23 Jul 85	LTG	Modified builds() to chk for SLASH when namd is
**				8 chs long.  This fixes the bug with 8 char 
**				directory nms.
**
**	24 Jul 85	SCC	Modified scan().  (Snide comment about still not
**				having fixed the DND problem last referred to on
**				23 Jul 85.)
**
**	25 Jul 85	SCC	Modified xunlink().  It now reports correctly 
**				EACCDN if the file being removed is read-only.
**
** 	26 Jul 85	LTG	Modified xrename(). Fixed call to getofd() to 
**				pass an int instead of a long.
**
**			SCC	Modified ixread().  Caller could pass in long
**				negative length, which was causing problems.
**
**	29 Jul 85	SCC	Modified ixcreat() to disallow creation of an 
**				entry beginning with '.', specifically to fix 
**				'MD .'.
**
**				Modified xrmdir() to disallow 'RD .' or 
**				'RD ..'.
**
**	31 Jul 85	LTG	Modified ixlseek(). Now chks to see if at front of
** 				file before bumping cluster num when on cluster 
** 				boundry.
**
**	 6 Aug 85	LTG	Modified xchdir().  No longer removes drive 
**				specification from path name before sending it 
**				to findit().
**
**	 7 Aug 85	LTG	Modified getdmd() to deallocate memory of just 
**				allocated data structures if it runs out of 
**				mem before it's done.
**
**  mod       who date		what
**  --------- --- ---------	----
**  M00.14.01	ktb 02 Aug 85	Fix to xrw enabling proper deblocking of 
**				requests where cluster sizes are not 2.
**
**  M00.16.01	scc 09 Aug 85	Start of modification to add F_IOCtl():
**				Add use of B_16 equate to log().
**				Added F_IOCtl().
**
**  M00.16.02	scc 11 Aug 85	Rename fixed/removeable media flag to B_FIX
**				in F_IOCtl().
**				Modified xmkdir() to deallocate DND it creates
**				if it cannot allocate the OFD immediately
**				afterwards.
**				Modified xchmod().  An 'if (!wrt)' was followed
**				by an 'if (wrt)'.  Changed the latter to 'else'.
**				Added bios_dev[] for conversion from BDOS level
**				character device handel to BIOS level handle.
**
**  M00.16.03	scc 16 Aug 85	Modified F_IOCtl().  It was doing a handle
**				transform even for functions that were being
**				passed a drive number.
**
**  M00.16.04	scc 17 Aug 85	Modified Chk_Drv() to use temp int for return
**				of GetDM().
**				Modified F_IOCtl() to call Chk_Drv() once,
**				rather than for each drive related function.
**
**  M00.16.05	scc 18 Aug 85	Modified F_IOCtl() to call constat() rather
**				than CIStat(), and case outstat for new devs.
**				Added extern for constat().
**
**  M00.01.01	ktb 19 Aug 85	Modified code in ixlseek which determines if
**				we are on cluster boundary or not
**  M00.01.01a	ktb 20 Aug 85	Try Try again
**  M00.01.01b	ktb 20 Aug 85	These mods actually revert back to the original
**				logic in ixlseek which special cases cluster
**				boundaries.  We aren't sure why it works, but
**				it does.
**
**  M01.01.01	ktb 15 Oct 85	accomodate split of fs.h into fs.h and bios.h
**
** --------------------------------------------------------------------------
**	fs.c has now been broken up into separate modules.
**
**	Modification notices from this point onward are recorded in the file
**	containing the module modified.
**		- kral
** --------------------------------------------------------------------------
**
**  27 May 86 ktb M01.01.0527.04	moved xcmps to fsdir.c
**  15 Sep 86 scc M01.01.0915.02	F_IOCtl:  check for error returns from
**					GetBPB()
**
** NOTES
**	SCC	 4 Apr 85	Note about bcb management in getrec().
**
** NAMES
**
**	JSL	Jason S. Loveman
**	SCC	Steven C. Cavender
**	LTG     Louis T. Garavaglia
**	KTB	Karl T. Braun (kral)
**
** ---------------------------------------------------------------------
** 
** Notes:
**	1. Cluster size must be < 32K bytes (strictly less)
**	2. Cluster size, record size must all be powers of two
**	3. With current 12-bit FAT implemented,
**		maximum media size is approx. 4000 clusters
**	4. 16-bit FAT entries not implemented yet	<<<< NO LONGER TRUE <<<<
**	5. swap routines must be defined accordingly for media
**		compatibility with 8086 (high-low) processors
**
*/



#include	"gportab.h"
#include	"fs.h"
#include	"bios.h"		
#include	"gemerror.h"



/*
**  xfr2usr -
*/

xfr2usr(n,s,d)
	REG int n;
	REG char *s,*d;
{
	while (n--)
		*d++ = *s++;
}


/*
**  usr2xfr -
*/

usr2xfr(n,d,s)
	REG int n;
	REG char *s,*d;
{
	while (n--)
		*d++ = *s++;
}

/*
**  uc - utility routine to return the upper-case of character passed in
**
**	Last modified	19 Jul 85	SCC
*/

uc(c)
REG char c;
{
	return((c >= 'a') && (c <= 'z') ? c & 0x5F : c);
}


/*
**  xgetdta - Function 0x2F	f_getdta
*/

char
*xgetdta() /*+ return address of dta */
{
	return(run->p_xdta);
}


/*
**  xsetdta - Function 0x1A	f_setdta
*/

xsetdta(addr) /*+ set transfer address to addr */
	char *addr;
{
	run->p_xdta = addr;
}



/*
**  xsetdrv - set default drive
**	( 0 = A, etc )
**	Function 0x0E	d_setdrv
*/

long	xsetdrv(drv) 
	int	drv ;
{
	int drvmap ;

	drvmap = trap13(0x0a) ;

	if( drvmap & (1<<drv)  )
	{
		run->p_curdrv = drv ;
		return( drvmap ) ;
	}

	return( EDRIVE );					
}


/*
**  xgetdrv - get default drive
**	(0 = A, etc )
**
**	Function 0x19	d_getdrv
**
**	Last modified	SCC	1 May 85
*/

long	xgetdrv() 
{
	return(run->p_curdrv);
}


/*
**  makofd -
*/

OFD	*makofd(p)
	REG DND *p;
{
	REG OFD *f;

	if (!(f = MGET(OFD)))
		return ( (OFD *) 0 );

	f->o_strtcl = p->d_strtcl;
	f->o_fileln = 0x7fffffffL;
	f->o_dirfil = p->d_dirfil;
	f->o_dnode = p->d_parent;
	f->o_dirbyt = p->d_dirpos;
	f->o_date = p->d_date;
	f->o_time = p->d_time;
	f->o_dmd = p->d_drv;

	return(f);
}




/*
**  getofd -
*/

OFD	*getofd(h)
	int h;
{
	return(sft[syshnd(h)].f_ofd);
}





/*
**  divmod - do divide and modulo arithmetic
**	the divide is accomplished with the log2 shift factor passed in as
**	as psuedo divisor, the remainder (modulo) is left in the varable 
**	pointed to by the third argument.
*/

int	divmod(modp,divdnd,divsor)
	REG int		*modp;
	REG int		divsor;	/* divsor is log2 of actual divisor */
	REG long	divdnd;
{
	*modp = divdnd & logmsk[divsor];

	return(divdnd >> divsor);
}






/*
**  bios_dev - 
**	Array of BIOS device handles.  Used by HXFORM macro
**	to convert BDOS level handle to BIOS level handle.
*/

GLOBAL	int bios_dev[] = { BFHPRN, BFHAUX, BFHCON, BFHCLK, BFHMOU };


/*****************************************************************************
**
** F_IOCtl - Function 0x44:  File, character and disk device I/O control
**
**	Last modified	SCC	9 Aug 85
**
*******************************************************************************
*/

long
F_IOCtl(fn, h, n, buf)
int	fn, n;
int	h;
char	*buf;
{
	register long	rv;			/* return value		    */
	register OFD	*pofd;			/* pointer to OFD	    */
	BPB		*tmp ;

	if ( (fn != DREADC) && (fn != DWRITEC) && (fn != REMEDIA) )
	{					/* If handle,		    */
		if (h >= 0)			/* If file handle,	    */
		{
		    h = syshnd( h );		/* Resolve it		    */
		    if ((fn != GETINFO) && (fn != INSTAT) && (fn != OUTSTAT))
			return(EINVFN);		/* check subfunction number */
		    pofd = sft[h].f_ofd;	/* Resolve OFD pointer	    */
		}
	}
	else					/* 'h' is drive number	    */
		if ( !Chk_Drv( &h )  )		/* Check for valid drive    */
			return ( EDRIVE );

	switch (fn)
	{
	    case XCVECTOR:			/* Exchange char vector	    */
		return (CVE(HXFORM(h),buf));

	    case GETINFO:			/* Get device information   */
		if (h >= 0)			/* For disk file:	    */
		{
						/* Init rv with drive number*/
			rv = h = pofd->o_dmd->m_drvnum;
			if (!DIOCR(h,0,0L))	/* 'or' in CONTROL bit	    */
				rv |= Does_IOCtl;
			return (rv);
		}

		/* else */			/* For character devices:   */
		rv = Is_Character;

		if (h == H_Null)
			rv |= Is_NUL;
		else
		{
			if (h == H_Console)
				rv |= Is_Console;
			else if (h == H_Clock)
				rv |= Is_Clock;

			if (!CIOCR(HXFORM(h),0,0L))
				rv |= Does_IOCtl;
		}

		return (rv);

	    case CREADC:			/* Read character control   */
		return (CIOCR(HXFORM(h),n,buf));

	    case CWRITEC:			/* Write character control  */
		return (CIOCW(HXFORM(h),n,buf));

	    case DREADC:			/* Read disk control string */
		return (DIOCR(h,n,buf));

	    case DWRITEC:			/* Write disk control string*/
		return (DIOCW(h,n,buf));

	    case INSTAT:			/* Get input status	    */
		if (h < 0)			/* For Character Device:    */
		{
			if (h == H_Null)
				return(0);

			return (constat(HXFORM(h)));
		}

		/* else fall through to common code for disk files	    */

	    case OUTSTAT:			/* Get output status	    */
		if (h < 0)			/* For Character Device:    */
		{
			if (h == H_Null)
				return(0);

			return (COStat(HXFORM(h)));
		}

		/* else */			/* For disk file:	    */
		return (pofd->o_bytnum != pofd->o_fileln);

	    case REMEDIA:			/* Get removeable media sts */
		tmp = GetBPB(h) ;

		if (tmp == 0)			/* M01.01.0915.02 */
			return(ERR);
		if (tmp < 0)
			return((long)tmp);

		return( !(tmp->b_flags & B_FIX) ) ;

	    default:				/* No function 1, etc. yet. */
		return (EINVFN);
	}
}

/******************************************************************************
**
** Chk_Drv - Check drive number
**
**	Utility routine used by F_IOCtl
**
*******************************************************************************
*/

int	Chk_Drv(d)				/* Check for valid drive.   */
	int	*d;
{
	int map;

	*d = *d ? *d-1 : run->p_curdrv;		/* Resolve drive number	    */
	map = GetDM();

	return( map & ( 1 << *d ) );		/* Check for existence	    */
}

