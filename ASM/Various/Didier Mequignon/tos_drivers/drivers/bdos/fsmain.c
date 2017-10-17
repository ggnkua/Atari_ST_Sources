/*
 * fsmain.c - GEMDOS file system notes and misc routines          
 *
 * Copyright (c) 2001 Lineo, Inc.
 *
 * Authors:
 *  xxx <xxx@xxx>
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */



#define  _MINT_OSTRUCT_H
#include <osbind.h>
#include "config.h"
#ifdef NETWORK
#ifdef LWIP
#include "../../include/vars.h"
#endif
#endif
#include "portab.h"
#include "asm.h"
#include "fs.h"
#include "bios.h"
#include "mem.h"
#include "gemerror.h"

#define DBGFMAIN 0

extern void display_string(char *string);
extern void ltoa(char *buf, long n, unsigned long base);

/*
**
** GEMDOS file system
** ------------------
** Originally written by JSL as noted below.
**
** MODIFICATION HISTORY
**
**      13 Mar 85       SCC     Changed xgetfree() to return values into longs.
**                              (As per spec).
**
**                              Changed handling of getbpb() return to allow 
**                              flagging of bad getbpb().
**
**      14 Mar 85       JSL     Modified getrec() to clear b_dirty flag.
**
**                              Modified ixcreat() to force flush
**                              (for the sake of xmkdir() ).
**
**      22 Mar 85       SCC     Modified xsetdrv() to return drive map (to 
**                              bring up to spec functionality, specifically 
**                              at request of Steve Schmitt (DR Logo) ).
**
**                              Extended good/bad returns based on ckdrv() 
**                              results.
**
**      26 Mar 85       JSL     Modified xsfirst() to be a front end to 
**                              ixsfirst().  ixsfirst() is used internally by 
**                              xexec() to force a disk access prior to 
**                              xpgmld() so that media change info can be 
**                              updated sooner.
**
**                              Modified ixlseek() because of bug when pointer 
**                              is at end of cluster prior to forward seek.
**
**                      SCC     Made above actual changes from JSL's notes.
**
**      27 Mar 85       SCC     Modifed dcrack() and findit() to terminate with
**                              indication of no file found if bad return from 
**                              ckdrv().
**
**      28 Mar 85       SCC     Modified xchdir() to look for NEGATIVE return 
**                              from ckdrv().
**
**      29 Mar 85       JSL     Fixed xrmdir() bug of "ghost" subdirectories.
**                              Fixed problem creating files in unaccessed 
**                              subdir.
**
**       4 Apr 85       SCC     Modified several functions to improve 
**                              readability.
**
**                              Removed a number of old 'SCC  ?? ??? 85' 
**                              modification marks, and began adding formfeeds 
**                              between routines and routine headers.
**
**                              Modified dup() to return long value and distinct
**                              error codes.
**
**                              Modified xforce() and ixforce() to return long 
**                              value and distinct error codes, and to range 
**                              check 'h'.
**
**                              Now includes gemerror.h.
**
**                              Modified xclose() and ixclose() to return long 
**                              value and distinct error codes.
**
**       5 Apr 85       SCC     Modified ixforce() to range check 'std', and 
**                              moved it after xforce().
**
**       8 Apr 85       SCC     Added declaration of 'drv' parameter to log().
**
**                              Added 'long' type to declaration of flush() 
**                              and error returns.
**
**                              Added 'long' type to declaration of usrio().
**
**                              Added 'int' type to declaration of getpath() 
**                              and 'flg' parameter.
**
**                              Added 'long' type to declaration of getcl() 
**                              and error returns.
**
**                              Added 'long' type to declaration of ckdrv() 
**                              and error returns.
**
**                              Added 'long' type to declaration of opnfil().
**
**                              Added 'long' type to declaration of makopn().
**
**       9 Apr 85       SCC     Added 'int' type to declaration of log2().
**
**                              Added 'int' type to declaration of divmod().
**
**      10 Apr 85       SCC     Removed 'long' return from flush(), reversing
**                              modification of 8 Apr 85, since errors from 
**                              the BIOS are handled by longjmp()ing back to 
**                              top of dispatcher.
**
**                              Removed 'long' return from usrio(), reversing
**                              modification of 8 Apr 85, since errors from 
**                              the BIOS are handled by longjmp()ing back to 
**                              top of dispatcher.
**
**                              Changed definition of rwerr from 'int' to 'long'
**
**                              Modified ixlseek() to return ERANGE and EINTRN.
**
**                              Modified xwrite() to check validity of handle.
**
**                              Modified ixclose() to check error returns from 
**                              ixlseek().
**
**                              Modified ixclose() to return EINTRN where JSL 
**                              had marked 'some kind of internal error', and 
**                              to return E_OK at end.
**
**                              Modified getcl() to return EINTRN.
**
**                              Modified nextcl() to return EINTRN and E_OK.
**
**                              Added rc to scan() to check error returns from 
**                              ixlseek().
**
**                              Modified xsnext() to return E_OK and ENMFIL.
**
**                              Modified xsfirst() to return E_OK and ENMFIL.
**
**      11 Apr 85       SCC     Modified opnfil() to return ENHNDL.
**
**                              Modified ixcreat() to return EPTHNF, EACCDN.
**
**                              Modified xrename() to return errors.
**
**                              Added xfreset() and ixfreset().
**
**      12 Apr 85       SCC     Removed spurious ',0' from parameters passed 
**                              to xclose() by xfreset().
**
**      14 Apr 85       SCC     Backed out modification of 11 Apr 85 that added
**                              xfreset() and ixfreset().  They were not the 
**                              solution to the problem they were aimed at 
**                              fixing.  See corresponding note in the CLI 
**                              about the ^C problem.
**
**                              Modified ixdel() to not delete an open file.
**
**                              Backed out modifications to getcl() (it is now 
**                              'int' and returns -1).
**
**                              Backed out modifications to nextcl() (it now 
**                              returns -1).
**
**                              Backed out modifications to clfix() (it us 
**                              untyped).
**
**      16 Apr 85       SCC     Modified ixdel() to close the file if it is 
**                              open, and then go ahead and delete it.  This 
**                              fix was in response to the fact that AS68 
**                              routinely deletes its files without closing 
**                              them.
**
**      29 Apr 85       SCC     Modified xrename() to check for existence of 
**                              new file name before attempting to rename old 
**                              file.
**
**       1 May 85       SCC     Did slight code optimization on ixsfirst().
**
**       6 May 85       SCC     Modified ixsfirst() to report EFILNF on error 
**                              return from findit().
**
**                              Modified ixcreat() to return EPTHNF for null 
**                              file name.
**
**       7 May 85       SCC     Modified xchdir() to return EPTHNF on failure of
**                              findit().
**
**       8 May 85       SCC     Modified xchdir() to not change path on failure
**                              of findit().
**
**       9 May 85       SCC     Modified xrename() to return EACCDN if 
**                              destination filename already exists.
**
**      13 May 85       SCC     Modified xchdir() to call ucase() before path 
**                              string is used.
**
**                              Modified findit() to call ucase() before name 
**                              string is used.
**
**                              Modified builds() to truncate pre-'.' portion 
**                              of file name to 8 characters.
**
**                              Modified xmkdir() to use ixcreat() instead of 
**                              xcreat().
**
**                              Modified xcreat() to prevent external caller 
**                              from creating a subdirectory.
**
**      15 May 85       SCC     Modified xgetfree() to be 0=default, 1=A:, etc.
**
**      16 May 85       SCC     Modified builds() to terminate post-'.' 
**                              portion of file name upon scanning a '.' as 
**                              well as the other characters it was checking.
**
**      26 Jun 85       LTG     Fixed bug in xrename to return err from open.
**
**      27 Jun 85       LTG     Added "o_mod" parm to OFD data structure.
**
**                              Modified xopen() & ixopen() to return EACCDN
**                              if try to open file with read only mode in
**                              read/write or write mode.
** 
**                              Mod to xread() to return EACCDN err if try to
**                              read file opened as write only.
** 
**                              Modifiedixwrite()toreturnEACCDNerriftry
**                              to write file opend as read only.
**
**                              Modified getdmd() to return NULLPTR if MGET 
**                              failed.
**
**                              Modified log() to return a long indicating 
**                              ENSMEM if getdmd() failed.
**
**                              Modified makofd() to return NULLPTR if MGET 
**                              fails.
**
**                              Modified makdnd() to return NULLPTR if MGET 
**                              fails.
** 
**                              Modified makopn() to return ENSMEM if MGET 
**                              fails.
**
**                              Modified scan() to return NULLPTR if makofd()
**                              or makdnd() fails.
**
**                              Modified xcreate() to return (ENSMEM) if 
**                              makofd() fails.
**
**                              Modified xmkdir() to return ENSMEM if makofd()
**                              or makdnd() fails.
**
**                              Modified rmdir() to return ENSMEM if makofd() 
**                              fails.
**
**      19 Jul 85       LTG     Modified scan() to make sure a file has not be 
**                              deleted before creating a DND for it.  This 
**                              fixes the bug that prevented some directories 
**                              from being removed.
**
**      19 Jul 85       SCC     Modified scan() to prevent creation of a new 
**                              DND for a subdirectory that already has one.
**
**                              Added routine uc() to upper-case a single 
**                              character and removed up_string().
**
**                              Modified dcrack() to use uc().
**
**                              Modified xcmps() to use uc().
**
**                              Modified xchdir() to use uc().
**
**                              Modified findit() to not use up_string().
**
**                              Modified builds() to use uc().
**
**                              Modified match() to use uc().
**
**      22 Jul 85       LTG     Modified ixcreate() to pass mode parameter to 
**                              opnfl(), 0 for RO, 2 for RW.
**
**                      SCC     Modified scan().  Modification of 19 Jul 85 
**                              was not correct.
**
**                              Modified ixcreat().  Modification of 22 Jul 85 
**                              did not check for R/O status correctly.
**
**      23 Jul 85       SCC     Modified scan().  Still in pursuit of 
**                              corrections to mods made on 22 Jul 85.
**
**      23 Jul 85       LTG     Modified builds() to chk for SLASH when namd is
**                              8 chs long.  This fixes the bug with 8 char 
**                              directory nms.
**
**      24 Jul 85       SCC     Modified scan().  (Snide comment about still not
**                              having fixed the DND problem last referred to on
**                              23 Jul 85.)
**
**      25 Jul 85       SCC     Modified xunlink().  It now reports correctly 
**                              EACCDN if the file being removed is read-only.
**
**      26 Jul 85       LTG     Modified xrename(). Fixed call to getofd() to 
**                              pass an int instead of a long.
**
**                      SCC     Modified ixread().  Caller could pass in long
**                              negative length, which was causing problems.
**
**      29 Jul 85       SCC     Modified ixcreat() to disallow creation of an 
**                              entry beginning with '.', specifically to fix 
**                              'MD .'.
**
**                              Modified xrmdir() to disallow 'RD .' or 
**                              'RD ..'.
**
**      31 Jul 85       LTG     Modified ixlseek(). Now chks to see if at front of
**                              file before bumping cluster num when on cluster 
**                              boundry.
**
**       6 Aug 85       LTG     Modified xchdir().  No longer removes drive 
**                              specification from path name before sending it 
**                              to findit().
**
**       7 Aug 85       LTG     Modified getdmd() to deallocate memory of just 
**                              allocated data structures if it runs out of 
**                              mem before it's done.
**
**  mod       who date          what
**  --------- --- ---------     ----
**  M00.14.01   ktb 02 Aug 85   Fix to xrw enabling proper deblocking of 
**                              requests where cluster sizes are not 2.
**
**  M00.16.02   scc 11 Aug 85   Modified xmkdir() to deallocate DND it creates
**                              if it cannot allocate the OFD immediately
**                              afterwards.
**                              Modified xchmod().  An 'if (!wrt)' was followed
**                              by an 'if (wrt)'.  Changed the latter to 'else'.
**
**  M00.01.01   ktb 19 Aug 85   Modified code in ixlseek which determines if
**                              we are on cluster boundary or not
**  M00.01.01a  ktb 20 Aug 85   Try Try again
**  M00.01.01b  ktb 20 Aug 85   These mods actually revert back to the original
**                              logic in ixlseek which special cases cluster
**                              boundaries.  We aren't sure why it works, but
**                              it does.
**
**  M01.01.01   ktb 15 Oct 85   accomodate split of fs.h into fs.h and bios.h
**
** --------------------------------------------------------------------------
**      fs.c has now been broken up into separate modules.
**
**      Modification notices from this point onward are recorded in the file
**      containing the module modified.
**              - kral
** --------------------------------------------------------------------------
**
**  27 May 86 ktb M01.01.0527.04        moved xcmps to fsdir.c
**
** NOTES
**      SCC      4 Apr 85       Note about bcb management in getrec().
**
** NAMES
**
**      JSL     Jason S. Loveman
**      SCC     Steven C. Cavender
**      LTG     Louis T. Garavaglia
**      KTB     Karl T. Braun (kral)
**
** ---------------------------------------------------------------------
** 
** Notes:
**      1. Cluster size must be < 32K bytes (strictly less)
**      2. Cluster size, record size must all be powers of two
**      3. With current 12-bit FAT implemented,
**              maximum media size is approx. 4000 clusters
**      4. 16-bit FAT entries not implemented yet       <<<< NO LONGER TRUE <<<<
**      5. swap routines must be defined accordingly for media
**              compatibility with 8086 (high-low) processors
**
*/



/*
 *  uc - utility routine to return the upper-case of character passed in
 */

char    uc(char c)
{
    return((c >= 'a') && (c <= 'z') ? c & 0x5F : c);
}



/*
 *  xgetdta - Function 0x2F     f_getdta
 */

char    *xgetdta(void)      /* return address of dta */
{
    return(run->p_xdta);
}


/*
 *  xsetdta - Function 0x1A     f_setdta
 */

void    xsetdta(char *addr)     /* set transfer address to addr */
{
    run->p_xdta = addr;
}



/*
 *  xsetdrv - set default drive
 *      ( 0 = A, etc )
 *      Function 0x0E   d_setdrv
 */

long    xsetdrv(short drv)
{
    long drvmap ;

#if DBGFMAIN
    char buf[10];
    display_string("xsetdrv(");
    ltoa(buf, (long)drv, 10);
    display_string(buf);
    display_string(") => ");
#endif
    {
#ifdef NETWORK
#ifdef LWIP
        extern long pxCurrentTCB, tid_TOS;
        if(pxCurrentTCB != tid_TOS)
            drvmap = *(unsigned long *)_drvbits;
        else       
#endif
#endif       
        drvmap = Drvmap();
    }
    
    if( drvmap & (1<<drv)  )
    {
        run->p_curdrv = drv ;
#if DBGFMAIN
        display_string("0x");
        ltoa(buf, drvmap, 16);
        display_string(buf);
        display_string("\r\n");
#endif
        return( drvmap ) ;
    }

#if DBGFMAIN
    display_string("EDRIVE (drvmap 0x");
    ltoa(buf, drvmap, 16);
    display_string(buf);
    display_string(")\r\n");
#endif
    return( EDRIVE );
}


/*
 * xgetdrv - get default drive
 *
 * (0 = A, etc )
 *
 *      Function 0x19   d_getdrv
 *
 *      Last modified   SCC     1 May 85
 */

long    xgetdrv(void) 
{
#if DBGFMAIN
    char buf[10];
    display_string("xgetdrv() => ");
    ltoa(buf, (long)run->p_curdrv, 10);
    display_string(buf);
    display_string("\r\n");
#endif
    return(run->p_curdrv);
}



/*
 *  makofd -
 */

OFD     *makofd(register DND *p)
{
    register OFD *f;

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
 *  getofd -
 */

OFD     *getofd(short h)
{
    return(sft[syshnd(h)].f_ofd);
}

