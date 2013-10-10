/*	DESKFPD.C	06/11/84 - 03/29/85		Lee Lorenzen	*/
/*	source merge	5/19/87  - 5/28/87		mdf		*/
/*	for 3.0		11/4/87				mdf		*/

/*
*       Copyright 1999, Caldera Thin Clients, Inc.                      
*       This software is licenced under the GNU Public License.         
*       Please see LICENSE.TXT for further information.                 
*                                                                       
*                  Historical Copyright                                 
*	-------------------------------------------------------------
*	GEM Desktop					  Version 3.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1987			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <stddef.h>
#include <string.h>
#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <aes.h>
#include <tos_intr.h>
#endif
#else
#include <dos.h>
#include <obdefs.h>
#include <gembind.h>
#endif
#include "deskapp.h"
#include "deskfpd.h"
#include "deskwin.h"
#include "deskinf.h"
#include "deskrsrc.h"
#include "desktop.h"
#include "optimize.h"
#include "deskbind.h"

EXTERN WORD	DOS_AX;
EXTERN GLOBES	G;

GLOBAL FNODE	*ml_pfndx[NUM_FNODES];

/* Initialize the list of fnodes */
VOID fn_init(VOID)
{
	WORD	i;

	for(i=NUM_FNODES - 2; i >= 0; i--)
		G.g_flist[i].f_next = &G.g_flist[i + 1];
	G.g_favail = &G.g_flist[0];
	G.g_flist[NUM_FNODES - 1].f_next = (FNODE *) NULL;
}

/* Initialize the list of pnodes */
VOID pn_init(VOID)
{
	WORD	i;

	for(i=NUM_PNODES - 2; i >= 0; i--)
		G.g_plist[i].p_next = &G.g_plist[i + 1];
	G.g_pavail = &G.g_plist[0];
	G.g_phead = (PNODE *) NULL;
	G.g_plist[NUM_PNODES - 1].p_next = (PNODE *) NULL;
}

/* Start up by initializing global variables */
VOID fpd_start(VOID)
{
	G.a_wdta = (LONG)ADDR(&G.g_wdta);
	G.a_wspec = (LONG)ADDR(&G.g_wspec[0]);
	fn_init();
	pn_init();
}

/*
*	Build a filespec out of drive letter, a pointer to a path, a pointer
*	to a filename, and a pointer to an extension.
*/
WORD fpd_bldspec(WORD drive, BYTE *ppath, BYTE *pname, BYTE *pext, BYTE *pspec)
{
	if ( (strlen(ppath) + LEN_ZFNAME) >= (LEN_ZPATH-3) )
		return(FALSE);
	else
	{
		*pspec++ = drive;
		*pspec++ = ':';
		*pspec++ = '\\';
		if (*ppath)
		{
			while (*ppath)
				*pspec++ = *ppath++;
			if (*pname)
				*pspec++ = '\\';
		}

		if (*pname)
		{
			while (*pname)
				*pspec++ = *pname++;
			if (*pext)
			{
				*pspec++ = '.';
				while (*pext)
					*pspec++ = *pext++;
			}
		}
		*pspec++ = '\0';
		return(TRUE);
	}
}

/*
*	Parse a filespec into its drive, path, name, and extension
*	parts.
*/
VOID fpd_parse(BYTE *pspec, WORD *pdrv, BYTE *ppath, BYTE *pname, BYTE *pext)
{
	BYTE	*pstart, *p1st, *plast, *pperiod;

	pstart = pspec;
	/* get the drive */
	while ( (*pspec) && (*pspec != ':') )
		pspec++;
	if (*pspec == ':')
	{
		pspec--;
		*pdrv = (WORD) *pspec;
		pspec++;
		pspec++;
		if ( *pspec == '\\')
			pspec++;
	}
	else
	{
#if GEMDOS
		*pdrv = (WORD) (Dgetdrv() + 'A');
#else
		*pdrv = (WORD) (dos_gdrv() + 'A');
#endif
		pspec = pstart;
	}
	/* scan for key bytes	*/
	p1st = pspec;
	plast = pspec;
	pperiod = NULL;
	while ( *pspec )
	{
		if (*pspec == '\\')
			plast = pspec;
		if (*pspec == '.')
			pperiod = pspec;
		pspec++;
	}
	if (pperiod == NULL)
		pperiod = pspec;
	/* get the path	*/
	while (p1st != plast)
		*ppath++ = *p1st++;
	*ppath = '\0';
	if (*plast == '\\')
		plast++;
	/* get the name	*/
	while (plast != pperiod)
		*pname++ = *plast++;
	*pname = '\0';
	/* get the ext	*/
	if ( *pperiod )
	{
		pperiod++;
		while (pperiod != pspec)
			*pext++ = *pperiod++; 
	}
	*pext = '\0';
}

/* Find the file node that matches a particular object id. */
FNODE *fpd_ofind(FNODE *pf, WORD obj)
{
	while(pf)
	{
		if (pf->f_obid == obj)
			return(pf);
		pf = pf->f_next;
	}
	return(NULL);
}

/* Find the list item that is after start and points to stop item. */
BYTE *fpd_elist(FNODE *pfpd, FNODE *pstop)
{
	while( pfpd->f_next != pstop )
		pfpd = pfpd->f_next;
	return( (BYTE *) pfpd);
}

/* Free a single file node */
VOID fn_free(FNODE *thefile)
{
	thefile->f_next = G.g_favail;
	G.g_favail = thefile;
}

/* Free a list of file nodes. */
VOID fl_free(FNODE *pflist)
{
	FNODE	*thelast;

	if (pflist)
	{
		thelast = (FNODE *) fpd_elist(pflist, NULL);
		thelast->f_next = G.g_favail;
		G.g_favail = pflist;
	}
}

/* Allocate a file node. */
FNODE *fn_alloc(VOID)
{
	FNODE	*thefile;

	if ( G.g_favail )
	{
		thefile = G.g_favail;
		G.g_favail = G.g_favail->f_next;
		return(thefile);
	}
	else
		return(NULL);
}

/* Allocate a path node. */
PNODE *pn_alloc(VOID)
{
	PNODE	*thepath;
	
	if ( G.g_pavail )
	{
		/* get up off the avail list */
		thepath = G.g_pavail;
		G.g_pavail = G.g_pavail->p_next;
		/* put us on the active list */
		thepath->p_next = G.g_phead;
		G.g_phead = thepath;
		/* init. and return	*/
		thepath->p_flags = 0x0;
		thepath->p_flist = (FNODE *) NULL;
		return(thepath);
	}
	else
		return(NULL);
}

/* Free a path node. */
VOID pn_free(PNODE *thepath)
{
	PNODE	*pp;

	/* free our file list	*/
	fl_free(thepath->p_flist);
	/* if first in list unlink by changing phead */
	/* else by finding and change our previouse guy	*/
	pp = (PNODE *) &G.g_phead;
	while (pp->p_next != thepath)
		pp = pp->p_next;
	pp->p_next = thepath->p_next;
	/* put us on the avail list */
	thepath->p_next = G.g_pavail;
	G.g_pavail = thepath;
}

/* Close a particular path. */
VOID pn_close(PNODE *thepath)
{
	pn_free(thepath);
}

/* Open a particular path. */
PNODE *pn_open(WORD drive, BYTE *path, BYTE *name, BYTE *ext, WORD attr)
{
	PNODE	*thepath;

	thepath = pn_alloc();
	if (thepath)
	{
		if ( fpd_bldspec(drive, path, name, ext, &thepath->p_spec[0]) )
		{
			thepath->p_attr = attr;
			return(thepath);
		}
		else 
		{
			pn_close(thepath);
			return(NULL);
		}
	}
	else
		return(NULL);
}

/* Compare file nodes pf1 & pf2, using a field determined by which */
WORD pn_fcomp(FNODE *pf1, FNODE *pf2, WORD which)
{
	WORD	chk;
	BYTE	*ps1, *ps2;

	ps1 = &pf1->f_name[0];
	ps2 = &pf2->f_name[0];

	switch (which)
	{
		case S_SIZE:
			if (pf2->f_size > pf1->f_size)
				return(1);
			else if (pf2->f_size < pf1->f_size)
				return(-1);
			else
				return( strcmp(ps1, ps2) );
		case S_TYPE:
			chk = strcmp(scasb(ps1, '.'), scasb(ps2, '.'));
			if (chk)
				return(chk);
			/* == falls thru */
		case S_NAME:
			return( strcmp(ps1, ps2) );
		case S_DATE:
			chk = pf2->f_date - pf1->f_date;
			if (chk)
				return(chk);
			else
			{
				chk = (pf2->f_time >> 11) - (pf1->f_time >> 11);
				if (chk)
					return(chk);
				else
				{
					chk = ((pf2->f_time >> 5) & 0x003F) -
						((pf1->f_time >> 5) & 0x003F);
					if (chk)
						return(chk);
					else
						return ( (pf2->f_time & 0x001F) - (pf1->f_time & 0x001F) );
				}
			} /* else */
		case S_DISK:
			return(pf1->f_junk - pf2->f_junk);
	} /* of switch */
	return(-1);
}

/*
*	Routine to compare two fnodes to see which one is greater.
*	Folders always sort out first, and then it is based on
*	the G.g_isort parameter.  Return (-1) if pf1 < pf2, (0) if
*	pf1 == pf2, and (1) if pf1 > pf2.
*/
WORD pn_comp(FNODE *pf1, FNODE *pf2)
{
#if GEMDOS
	if (pf1->f_attr & FA_FAKE)
#else
	if (pf1->f_attr & F_FAKE)
#endif
		return( -1 );
#if GEMDOS
	else if (pf2->f_attr & FA_FAKE)
#else
	else if (pf2->f_attr & F_FAKE)
#endif
		return( 1 );
	else
	{
#if GEMDOS
		if ( (pf1->f_attr ^ pf2->f_attr) & FA_SUBDIR)
			return ((pf1->f_attr & FA_SUBDIR)? -1: 1);
#else
		if ( (pf1->f_attr ^ pf2->f_attr) & F_SUBDIR)
			return ((pf1->f_attr & F_SUBDIR)? -1: 1);
#endif
		else
			return (pn_fcomp(pf1,pf2,G.g_isort)); 
	}
}

FNODE *pn_sort(WORD lstcnt, FNODE *pflist)
{
	FNODE	*pf, *pftemp;
	FNODE	*newlist;
	WORD	gap, i, j;

	/* build index array if necessary */
	if (lstcnt == -1)
	{
		lstcnt = 0;
		for (pf=pflist; pf; pf=pf->f_next)
			ml_pfndx[lstcnt++] = pf;
	}
	/* sort files using shell sort on page 108 of K&R C Prog. Lang. */
	for (gap = lstcnt/2; gap > 0; gap /= 2)
	{
		for (i = gap; i < lstcnt; i++)
		{
			for (j = i-gap; j >= 0; j -= gap)
			{
				if ( pn_comp(ml_pfndx[j], ml_pfndx[j+gap]) <= 0 )
					break;
				pftemp = ml_pfndx[j];
				ml_pfndx[j] = ml_pfndx[j+gap];
				ml_pfndx[j+gap] = pftemp;
			}
		}
	}
	/* link up the list in order */
	newlist = (FNODE *) NULL;
	pf = (FNODE *) &newlist;
	for(i=0; i<lstcnt; i++)
	{
		pf->f_next = ml_pfndx[i];
		pf = ml_pfndx[i];
	}
	pf->f_next = (FNODE *) NULL;
	return(newlist);
}

/*
*	Make a particular path the active path.  This involves
*	reading its directory, initializing a file list, and filling
*	out the information in the path node.
*/
WORD pn_folder(PNODE *thepath)
{
	WORD	ret, firstime;
	FNODE	*thefile, *prevfile;

	thepath->p_count = 0;
	thepath->p_size = 0x0L;
	fl_free(thepath->p_flist);
	thefile = (FNODE *)NULL;
	prevfile = (FNODE *)&thepath->p_flist;
	/* set of fake new folder entry */
	thefile = fn_alloc();
	thefile->f_junk = 0x0;
#if GEMDOS
	thefile->f_attr = FA_FAKE | FA_SUBDIR;
#else
	thefile->f_attr = F_FAKE | F_SUBDIR;
#endif
	thefile->f_time = 0x0;
	thefile->f_date = 0x0;
	thefile->f_size = 0x0L;
	strcpy(&thefile->f_name[0], ini_str(STNEWFOL));
	/* init for while loop */
#if GEMDOS
	G.g_wdta.d_fname[0] = '\0';
	Fsetdta((DTA *)G.a_wdta);
#else
	G.g_wdta.fcb_fname[0] = '\0';
	dos_sdta(G.a_wdta);
#endif
	ret = firstime = TRUE;
	while ( ret )
	{
		if ( !thefile )
		{
			thefile = fn_alloc();
			if ( !thefile )
			{
				ret = FALSE;
				DOS_AX = E_NOFNODES;
			}
		}
		else
		{
			/* make so each dir. has a available new folder */
#if GEMDOS
			if ( G.g_wdta.d_fname[0] != '.' && G.g_wdta.d_attrib != 0xF )
#else
			if ( G.g_wdta.fcb_fname[0] != '.' && G.g_wdta.fcb_attrib != 0xF )
#endif
			{
				/* if it is a real file	or directory then save it */
				if (!firstime)
				{
					memcpy(&thefile->f_junk, ((BYTE *)&G.g_wdta)+20, 23);
#if GEMDOS
					thefile->f_attr &= ~(FA_DESKTOP | FA_FAKE);
#else
					thefile->f_attr &= ~(F_DESKTOP | F_FAKE);
#endif
				}
				thepath->p_size += thefile->f_size;
				prevfile->f_next = ml_pfndx[thepath->p_count++] = thefile;
				prevfile = thefile;
				thefile = (FNODE *)NULL;
			}
			if (firstime)
			{
#if GEMDOS
				ret = Fsfirst(ADDR(&thepath->p_spec[0]), thepath->p_attr) == 0;
#else
				ret = dos_sfirst(ADDR(&thepath->p_spec[0]), thepath->p_attr);
#endif
				firstime = FALSE;
			}
			else
#if GEMDOS
				ret = Fsnext() == 0;
#else
				ret = dos_snext();
#endif
		}
	}
	prevfile->f_next = (FNODE *)NULL;
	if (thefile)
		fn_free(thefile);
	thepath->p_flist = pn_sort(thepath->p_count, thepath->p_flist);
	return(DOS_AX);
}

/*
*	Make a particular path the active path.  This involves
*	reading its directory, initializing a file list, and filling
*	out the information in the path node.
*/
WORD pn_desktop(PNODE *thepath)
{
	FNODE	*thefile, *prevfile;
	ANODE	*pa;
	WORD	sortsave;

	thepath->p_count = 0;
	thepath->p_size = 0x0L;
	fl_free(thepath->p_flist);
	thefile = (FNODE *)NULL;
	prevfile = (FNODE *)&thepath->p_flist;
	pa = G.g_ahead;
	while ( pa )
	{
		if ( !thefile )
		{
			thefile = fn_alloc();
			if ( !thefile )
			{	
				pa = 0;
				DOS_AX = E_NOFNODES;
			}
		}
		else
		{
			if (pa->a_flags & AF_ISDESK)
			{
				thefile->f_junk = (0x00ff & pa->a_letter);
#if GEMDOS
				thefile->f_attr = FA_DESKTOP | FA_SUBDIR;
#else
				thefile->f_attr = F_DESKTOP | F_SUBDIR;
#endif
				thefile->f_time = 0x0;
				thefile->f_date = 0x0;
				thefile->f_size = 0x0L;
				thefile->f_isap = TRUE;
				strcpy(&thefile->f_name[0], pa->a_pappl);
				thefile->f_obid = pa->a_obid;
				thefile->f_pa = pa;
				thepath->p_size += thefile->f_size;
				prevfile->f_next = ml_pfndx[thepath->p_count++] = thefile;
				prevfile = thefile;
				thefile = (FNODE *)NULL;
			}
			pa = pa->a_next;
		}
	}
	prevfile->f_next = (FNODE *)NULL;
	if ( thefile )
		fn_free(thefile);
	sortsave = G.g_isort;
	G.g_isort = S_DISK;			/* sort by drive letter	*/
	thepath->p_flist = pn_sort(thepath->p_count, thepath->p_flist);
	G.g_isort = sortsave;
	return(0);
}

WORD pn_active(PNODE *thepath)
{
	if (thepath->p_spec[0] == '@')
		return( pn_desktop(thepath) );
	else
		return( pn_folder(thepath) );
}
