/*	DESKAPP.C	06/11/84 - 07/11/85		Lee Lorenzen */
/*	for 3.0		3/6/86   - 5/6/86		MDF		*/
/*	for 2.3		9/25/87					mdf		*/

/*
*       Copyright 1999, Caldera Thin Clients, Inc.                      
*       This software is licenced under the GNU Public License.         
*       Please see LICENSE.TXT for further information.                 
*                                                                       
*                  Historical Copyright                                 
*	-------------------------------------------------------------
*	GEM Desktop					  Version 2.3
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1987			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#endif
#else
#include <obdefs.h>
#include <gembind.h>
#include <dos.h>
#endif
#include "deskapp.h"
#include "deskfpd.h"
#include "deskwin.h"
#include "desktop.h"
#include "deskbind.h"
#include "deskfun.h"
#include "deskobj.h"
#include "deskgraf.h"
#include "deskrsrc.h"
#include "optimize.h"

#define MIN_WINT 4
#define MIN_HINT 2

EXTERN WORD	gl_wchar;
EXTERN WORD	gl_hchar;
EXTERN WORD	gl_wschar;
EXTERN WORD	gl_hschar;
EXTERN WORD	gl_width;
EXTERN WORD	gl_height;
EXTERN WORD	gl_hbox;
EXTERN WORD	DOS_ERR;
EXTERN WORD	DOS_AX;

EXTERN GRECT	gl_savewin[NUM_WNODES];
EXTERN ICONBLK	gl_icons[];

EXTERN GLOBES	G;

#if ALCYON_C
GLOBAL BYTE	*gl_pstart;
#else
#if I8086
GLOBAL WORD	gl_pstart;
#else
GLOBAL ULONG	gl_pstart;
#endif
#endif

GLOBAL WORD	gl_poffset;
GLOBAL WORD	gl_numics;

GLOBAL WORD	gl_stdrv;

GLOBAL BYTE	gl_afile[SIZE_AFILE];
GLOBAL BYTE	gl_buffer[SIZE_BUFF];

#if MULTIAPP
GLOBAL ACCNODE	gl_caccs[3];
#endif

#define max(x,y) ((x)>(y)?(x):(y))

/* Allocate an application object. */
ANODE *app_alloc(WORD tohead)
{
	ANODE	*pa, *ptmpa;

	pa = G.g_aavail;
	if (pa)
	{
		G.g_aavail = pa->a_next;
		if ( (tohead) || (!G.g_ahead) )
		{
			pa->a_next = G.g_ahead;
			G.g_ahead = pa;
		}
		else
		{
			ptmpa = G.g_ahead;
			while( ptmpa->a_next )
				ptmpa = ptmpa->a_next;
			ptmpa->a_next = pa;
			pa->a_next = (ANODE *)NULL;
		}
	}
	return(pa);
}

/* Free an application object. */
VOID app_free(ANODE *pa)
{
	ANODE	*ptmpa;

	if (G.g_ahead == pa)
		G.g_ahead = pa->a_next;
	else
	{
		ptmpa = G.g_ahead;
		while ( (ptmpa) && (ptmpa->a_next != pa) )
			ptmpa = ptmpa->a_next;
		if (ptmpa)
			ptmpa->a_next = pa->a_next;
	}
	pa->a_next = G.g_aavail;
	G.g_aavail = pa;
}

/* Convert a single hex ASCII digit to a number */
WORD hex_dig(BYTE achar)
{
	if ( (achar >= '0') && (achar <= '9') )
		return(achar - '0');	
	else if ( (achar >= 'A') && (achar <= 'F') )
		return(achar - 'A' + 10);
	else
		return(0);
}

/* Reverse of hex_dig(). */
BYTE uhex_dig(WORD wd)
{
	if ( (wd >= 0) && (wd <= 9) )
		return(wd + '0');
	else if ( (wd >= 0x0a) && (wd <= 0x0f) )
		return(wd + 'A' - 0x0a);
	else
		return(' ');
}
	
/*
*	Scan off and convert the next two hex digits and return with
*	pcurr pointing one space past the end of the four hex digits
*/
BYTE *scan_2(BYTE *pcurr, UWORD *pwd)
{
	UWORD	temp;

	/* In newdesk.inf for TOS > 1.XX we can have spaces between */
	/* the values. If we read AES Environment and this TOS has  */
	/* bootet, we must be able to handle spaces. */
	while (*pcurr == ' ')
		pcurr++;
	temp = 0x0;
	temp |= hex_dig(*pcurr++) << 4;
	temp |= hex_dig(*pcurr++);
	if (temp == 0x00ff)
		temp = NIL;
	*pwd = temp;
	return(	pcurr );
}

/* Reverse of scan_2(). */
BYTE *save_2(BYTE *pcurr, UWORD wd)
{
	*pcurr++ = uhex_dig((wd >> 4) & 0x000f);
	*pcurr++ = uhex_dig(wd & 0x000f);
	return(	pcurr );
}

#if MULTIAPP

/*
*	Scan off and convert the next four hex digits and return with
*	pcurr pointing one space past the end of the four hex digits.
*	Start of field is marked with an 'R'.  If no field, set it to
*	default memory size -- DEFMEMREQ.
*/
BYTE *scan_memsz(BYTE *pcurr, UWORD *pwd)
{
	UWORD	temp1, temp2;

	temp1 = 0x0;
	while (*pcurr == ' ')
		pcurr++;
	if (*pcurr == 'R')
	{
		pcurr++;				
		pcurr = scan_2(pcurr, &temp1);		/* hi byte	*/
		pcurr = scan_2(pcurr, &temp2);		/* lo byte	*/
		temp1 = ((temp1 << 8) & 0xff00) | temp2;
	}
	if (temp1 == 0)
		temp1 = DEFMEMREQ;
	*pwd = temp1;
	return(	pcurr );
}

/* Reverse of scan_memsz(). */
BYTE *save_memsz(BYTE *pcurr, UWORD wd)
{
	*pcurr++ = 'R';
	pcurr = save_2(pcurr, LHIBT(wd));
	pcurr = save_2(pcurr, LLOBT(wd));
	return(	pcurr );
}

#endif

/*
*	Scan off spaces until a string is encountered.  An @ denotes
*	a null string.  Copy the string into a string buffer until
*	a @ is encountered.  This denotes the end of the string.  Advance
*	pcurr past the last byte of the string.
*/
BYTE *scan_str(BYTE *pcurr, BYTE **ppstr)
{
	while(*pcurr == ' ')
		pcurr++;
	*ppstr = G.g_pbuff;
	while(*pcurr != '@')
		*G.g_pbuff++ = *pcurr++;
	*G.g_pbuff++ = '\0';
	pcurr++;
	return(pcurr);
}

/* Reverse of scan_str. */
BYTE *save_str(BYTE *pcurr, BYTE *pstr)
{
	while (*pstr)
		*pcurr++ = *pstr++;
	*pcurr++ = '@';
	*pcurr++ = ' ';
	return(pcurr);
}

/* Parse a single line from the DESKTOP.INF file. */
BYTE *app_parse(BYTE *pcurr, ANODE *pa)
{
	WORD	chk_newdesk;

	chk_newdesk = FALSE;
	switch (*pcurr)
	{
		case 'M':
			/* Storage Media */
			pa->a_type = AT_ISDISK;
			pa->a_flags = AF_ISCRYS | AF_ISGRAF | AF_ISDESK;
			break;
		case 'G':
			/* GEM App File */
			pa->a_type = AT_ISFILE;
			pa->a_flags = AF_ISCRYS | AF_ISGRAF;
			chk_newdesk = TRUE;
			break;
		case 'F':
			/* DOS File no parms */
		case 'f':
			/* needs full memory */
			pa->a_type = AT_ISFILE;
			pa->a_flags = (*pcurr == 'F') ? NONE : AF_ISFMEM;
			break;
		case 'P':
			/* DOS App needs parms */
		case 'p':
			/* needs full memory */
			pa->a_type = AT_ISFILE;
			pa->a_flags = (*pcurr == 'P') ? AF_ISPARM : AF_ISPARM | AF_ISFMEM;
			break;
		case 'D':
			/* Directory (Folder) */
			pa->a_type = AT_ISFOLD;
			break;
	}
	pcurr++;
	if (pa->a_flags & AF_ISDESK)
	{
		pcurr = scan_2(pcurr, (UWORD *)&pa->a_xspot);
		pcurr = scan_2(pcurr, (UWORD *)&pa->a_yspot);
	}
	pcurr = scan_2(pcurr, (UWORD *)&pa->a_aicon);
	pcurr = scan_2(pcurr, (UWORD *)&pa->a_dicon);
	pcurr++;
	if (pa->a_flags & AF_ISDESK)
	{
		pa->a_letter = (*pcurr == ' ') ? '\0' : *pcurr;
		pcurr += 2;
	}
	if (chk_newdesk)
	{
		/* In newdesk.inf for TOS > 1.XX we have an additional  */
		/* values with 3 digits. If we read AES Environment and */
		/* this TOS has bootet, we must be able to handle this. */
		while(*pcurr == ' ')
			pcurr++;
		if (isdigit(*pcurr) && isdigit(*(pcurr+1)) &&
			isdigit(*(pcurr+2)) && *(pcurr+3) == ' ')
		{
			pcurr += 4;
		}
	}
	pcurr = scan_str(pcurr, &pa->a_pappl);
	pcurr = scan_str(pcurr, &pa->a_pdata);
#if MULTIAPP
	if (!(pa->a_flags & AF_ISDESK))	/* only for apps */
		pcurr = scan_memsz(pcurr, &pa->a_memreq);
#endif
	return(pcurr);
}

VOID app_tran(WORD bi_num)
{
	LONG	lpbi;
	BITBLK	lb;

	rsrc_gaddr(R_BITBLK, bi_num, &lpbi);
	LBCOPY(ADDR(&lb), lpbi, sizeof(BITBLK));
	gsx_trans((LONG)lb.bi_pdata, lb.bi_wb, (LONG)lb.bi_pdata, lb.bi_wb, lb.bi_hl);
}

MLOCAL FILE *app_getfh(WORD openit, BYTE *pname)
{
	FILE	*handle;
	WORD	tmpdrv;
	LONG	lp;

	handle = 0;
	strcpy(&G.g_srcpth[0], pname);
	lp = (LONG)ADDR(&G.g_srcpth[0]);
#if GEMDOS
	tmpdrv = Dgetdrv();
#else
	tmpdrv = dos_gdrv();
#endif
	if (tmpdrv != gl_stdrv)
#if GEMDOS
		Dsetdrv(gl_stdrv);
#else
		dos_sdrv(gl_stdrv);
#endif
	if ( shel_find((BYTE FAR *)lp) )
	{
		if (openit)
			handle = fopen((const char *)lp, "rb");
		else
			handle = fopen((const char *)lp, "wb");
	}
	if (tmpdrv != gl_stdrv)
#if GEMDOS
		Dsetdrv(tmpdrv);
#else
		dos_sdrv(tmpdrv);
#endif
	return(handle);
}

/* app_rdicon */
WORD app_rdicon(VOID)
{
	LONG	temp, stmp, dtmp;
	FILE	*handle;
	WORD	length, i, iwb, ih;
	WORD	num_icons, num_masks, last_icon, num_wds, 
			num_bytes, msk_bytes, tmp;
#if ALCYON_C
	WORD	stlength;
	BYTE	*fixup, **namelist;
	LONG	poffset;
#else
#if I8086
	WORD	poffset;
	UWORD	fixup;
#else
	LONG	poffset, fixup;
#endif
#endif

	/* open the file	*/
	handle = app_getfh(TRUE, ini_str( (gl_height <= 300) ? STGEMLOI : STGEMHIC));
	if (!handle)
		return(FALSE);
	else
	{
		/* how much to read? */
		length = NUM_IBLKS * (WORD)sizeof(ICONBLK);
#if ALCYON_C
		fread(ADDR(&stlength), 2, 1, handle);
#endif
		fread(ADDR(&gl_pstart), sizeof(BYTE *), 1, handle);
		fread(ADDR(&poffset), sizeof(BYTE *), 1, handle);
		poffset += (2 * (WORD)sizeof(BYTE *)) + length;
		gl_pstart -= poffset;
		/* read it */
		fread(ADDR(&G.g_idlist[0]), 1, length, handle);
		memcpy(&G.g_iblist[0], &G.g_idlist[0], length);
		/* find no. of icons actually used */
		num_icons = last_icon = 0;
		while ( (last_icon < NUM_IBLKS) &&
			(G.g_idlist[last_icon].ib_pmask != (WORD *)-1L) )
		{
			tmp = max( LLOWD(G.g_idlist[last_icon].ib_pmask),
			LLOWD(G.g_idlist[last_icon].ib_pdata) );
			num_icons = max(num_icons, tmp);
			last_icon++;
		}
		num_icons++;
		/* how many words of data to read? */
		/* assume all icons are	same w,h as first */
		num_wds = (G.g_idlist[0].ib_wicon * G.g_idlist[0].ib_hicon) / 16;
		num_bytes = num_wds * 2;
		/* allocate some memory	in bytes */
		/* gl_pstart = size of icon bit blocks	*/
		/* and strings on Lattice C */
		/* NUM_NAMICS is for string pointers */
		/* stlength is strings on ALCYON C */
#if ALCYON_C
		length = (WORD)(gl_pstart + ((NUM_NAMICS + 1) * 4) + stlength);
#else
#if I8086
		length = (WORD)(gl_pstart + (NUM_NAMICS * 2));
#else
		length = (WORD)(gl_pstart + (NUM_NAMICS * 4));
#endif
#endif
		G.a_datastart = (LONG)malloc( LW(length) );
		/* read it */
		fread((void *)G.a_datastart, 1, length, handle);
		fclose(handle);
		/* fix up str ptrs */
		gl_numics = 0;
#if ALCYON_C
		namelist = (BYTE **)(G.a_datastart + gl_pstart);
		for (i = 0; i < NUM_NAMICS; i++)
		{
			fixup = *namelist - poffset;
			*namelist++ = fixup;
#else
		for (i = 0; i < NUM_NAMICS; i++)
		{
#if I8086
			fixup = (UWORD)(LWGET(G.a_datastart + gl_pstart + (i*2)) - poffset);
			LWSET((G.a_datastart + gl_pstart + (i*2)), fixup);
#else
			fixup = LLGET(G.a_datastart + gl_pstart + (i*4)) - poffset - gl_pstart;
			LLSET((G.a_datastart + gl_pstart + (i*4)), fixup);
#endif
#endif
			if ( LBGET(G.a_datastart + fixup) )
				gl_numics++;
		}
		/* figure out which are	mask & which data */
		for (i=0; i<last_icon; i++)
		{
			G.g_ismask[ (WORD)G.g_idlist[i].ib_pmask ] = TRUE;
			G.g_ismask[ (WORD)G.g_idlist[i].ib_pdata ] = FALSE;
		}
		/* fix up mask ptrs	*/
		num_masks = 0;
		for (i=0; i<num_icons; i++)
		{
			if (G.g_ismask[i])
			{
				G.g_ismask[i] = num_masks;
				num_masks++;
			}
			else
				G.g_ismask[i] = -1;
		}
		/* allocate memory for transformed mask forms */
		msk_bytes = num_masks * num_bytes;
		G.a_buffstart = (LONG)malloc( LW(msk_bytes) );
		/* fix up icon pointers	*/
		for (i=0; i<last_icon; i++)
		/* fix up icon pointers	*/
		for (i=0; i<last_icon; i++)
		{
			/* first the mask */
			temp = ( G.g_ismask[ G.g_idlist[i].ib_pmask ] * ((LONG) num_bytes));
			G.g_iblist[i].ib_pmask = (WORD *)(G.a_buffstart + LW(temp));
			temp = ( (LONG)G.g_idlist[i].ib_pmask * (LONG)num_bytes );
			G.g_idlist[i].ib_pmask = (WORD *)(G.a_datastart + LW(temp));
			/* now the data */
			temp = ( (LONG)G.g_idlist[i].ib_pdata * (LONG)num_bytes );
			G.g_iblist[i].ib_pdata = G.g_idlist[i].ib_pdata = 
				(WORD *)(G.a_datastart + LW(temp));
			/* now the text ptrs	*/
			G.g_idlist[i].ib_ytext = G.g_iblist[i].ib_ytext = 
				G.g_idlist[0].ib_hicon;
			G.g_idlist[i].ib_wtext = G.g_iblist[i].ib_wtext = 12 * gl_wschar;
			G.g_idlist[i].ib_htext = G.g_iblist[i].ib_htext = gl_hschar + 2;
		}
		/* transform forms	*/
		iwb = G.g_idlist[0].ib_wicon / 8;
		ih = G.g_idlist[0].ib_hicon;

		for (i=0; i<num_icons; i++)
		{
			if (G.g_ismask[i] != -1)
			{
				/* preserve standard form of masks */
				stmp = G.a_datastart + (i * num_bytes);
				dtmp = G.a_buffstart + (G.g_ismask[i] * num_bytes);
				LWCOPY(dtmp, stmp, num_wds);
			}
			else
			{
				/* transform over std. form of datas */
				dtmp = G.a_datastart + (i * num_bytes);
			}
			gsx_trans(dtmp, iwb, dtmp, iwb, ih);
		}
#if 0
		for (i=0; i<last_icon; i++)
		{
			if ( i == IG_FOLDER )
				G.g_iblist[i].ib_pmask = G.g_iblist[IG_TRASH].ib_pmask;
			if ( ( i == IG_FLOPPY ) || ( i == IG_HARD ) )
				G.g_iblist[i].ib_pmask = G.g_iblist[IG_TRASH].ib_pdata;
			if ( (i >= IA_GENERIC) && (i < ID_GENERIC) )
				G.g_iblist[i].ib_pmask = G.g_iblist[IA_GENERIC].ib_pdata;
			if ( (i >= ID_GENERIC) && (i < (NUM_ANODES - 1)) )
				G.g_iblist[i].ib_pmask = G.g_iblist[ID_GENERIC].ib_pdata;
		}
#endif
		return(TRUE);
	}
}

/*
*	Initialize the application list by reading in the DESKTOP.INF
*	file, either from memory or from the disk if the shel_get
*	indicates no message is there.
*/
WORD app_start(VOID)
{
	WORD	i, x, y, w, h;
	ANODE	*pa;
	WSAVE	*pws;
	BYTE	*pcurr, *ptmp, prevdisk;
	FILE	*fh;
	WORD	envr, xcnt, ycnt, xcent, wincnt;
#if MULTIAPP
	WORD	numaccs;
	BYTE	*savbuff;

	numaccs = 0;
#endif		
	/* remember start drive	*/
#if GEMDOS
	gl_stdrv = Dgetdrv();
#else
	gl_stdrv = dos_gdrv();
#endif

	G.g_pbuff = &gl_buffer[0];

	for (i=NUM_ANODES - 2; i >= 0; i--)
		G.g_alist[i].a_next = &G.g_alist[i + 1];
	G.g_ahead = (ANODE *)NULL;
	G.g_aavail = &G.g_alist[0];
	G.g_alist[NUM_ANODES - 1].a_next = (ANODE *)NULL;

	shel_get(ADDR(&gl_afile[0]), SIZE_AFILE);
	if (gl_afile[0] != '#')
	{
		/* invalid signature so read from disk */
		fh = app_getfh(TRUE, ini_str(STGEMAPP));
		if (!fh)
			return(FALSE);
		G.g_afsize = (WORD)fread(ADDR(&gl_afile[0]), 1, SIZE_AFILE, fh);
		fclose(fh);
		gl_afile[G.g_afsize] = '\0';
	}

	wincnt = 0;
	pcurr = &gl_afile[0];
	prevdisk = ' ';
	/* add a default, maybe it is not present */
	strcat(pcurr, "\n#G0828 *.APP@ @");
	strcat(pcurr, "\n#G0828 *.PRG@ @");
	strcat(pcurr, "\n#F0828 *.TOS@ @");
	strcat(pcurr, "\n#P0828 *.TTP@ @");
	while (*pcurr)
	{
		if (*pcurr != '#')
			pcurr++;
		else
		{
			pcurr++;
			switch (*pcurr)
			{
				case 'M':	/* Media (Hard/Floppy) */
				case 'G':	/* GEM Application */
				case 'F':	/* File	(DOS w/o parms)	*/
				case 'f':	/*   use full memory */
				case 'P':	/* Parm	(DOS w/ parms) */
				case 'p':	/*   use full memory */
				case 'D':	/* Directory */
					if ( *pcurr == 'M' )
						prevdisk = 'M';
					else
					{
						/* rest of standards after last disk */
						if (prevdisk == 'M')
						{
							for (i = 0; i < 6; i++)
							{
								pa = app_alloc(TRUE);
								app_parse(ini_str(ST1STD+i)+1, pa);
							}
						}
						prevdisk = ' ';
					}
					pa = app_alloc(TRUE);
					pcurr = app_parse(pcurr, pa);
					break;
#if MULTIAPP			
				case 'A':	/* Desk Accessory */
					pcurr++;
					pcurr = scan_2(pcurr, &(gl_caccs[numaccs].acc_swap));
					savbuff = G.g_pbuff;
					G.g_pbuff = &(gl_caccs[numaccs].acc_name[0]);
					pcurr = scan_str(pcurr, &ptmp);
					G.g_pbuff = savbuff;
					numaccs++;
					break;
#endif
				case 'W':	/* Window */
					pcurr++;
					if ( wincnt < NUM_WNODES )
					{
						pws = &G.g_cnxsave.win_save[wincnt];
						pcurr = scan_2(pcurr, (UWORD *)&pws->hsl_save);
						pcurr = scan_2(pcurr, (UWORD *)&pws->vsl_save);
	 					pcurr = scan_2(pcurr, (UWORD *)&x);
						pcurr = scan_2(pcurr, (UWORD *)&y);
						pcurr = scan_2(pcurr, (UWORD *)&w);
						pcurr = scan_2(pcurr, (UWORD *)&h);
						pcurr = scan_2(pcurr, (UWORD *)&pws->obid_save);
						ptmp = &pws->pth_save[0];
						pcurr++;
						while ( *pcurr != '@' )
							*ptmp++ = *pcurr++;
						*ptmp = '\0';
						gl_savewin[wincnt].g_x = x * gl_wchar;
						gl_savewin[wincnt].g_y = y * gl_hchar;
						gl_savewin[wincnt].g_w = w * gl_wchar;
						gl_savewin[wincnt++].g_h = h * gl_hchar;
					}
					break;
				case 'E':
					pcurr++;
					pcurr = scan_2(pcurr, (UWORD *)&envr);
					G.g_cnxsave.vitem_save = ( (envr & 0x80) != 0);
					G.g_cnxsave.sitem_save = ( (envr & 0x60) >> 5);
					G.g_cnxsave.cdele_save = ( (envr & 0x10) != 0);
					G.g_cnxsave.ccopy_save = ( (envr & 0x08) != 0);
					G.g_cnxsave.cdclk_save = envr & 0x07;
					pcurr = scan_2(pcurr, (UWORD *)&envr);
					G.g_cnxsave.covwr_save = ( (envr & 0x10) == 0);
					G.g_cnxsave.cmclk_save = ( (envr & 0x08) != 0);
					G.g_cnxsave.cdtfm_save = ( (envr & 0x04) == 0);
					G.g_cnxsave.ctmfm_save = ( (envr & 0x02) == 0);
#if GEM & (GEM2 | GEM3 | XGEM)
					sound(FALSE, !(envr & 0x01), 0);
#endif
					break;
			}
		}
	}
	if (!app_rdicon())
		return(FALSE);
	else
	{
		G.g_wicon = (12 * gl_wschar) + (2 * G.g_idlist[0].ib_xtext);
		G.g_hicon = G.g_idlist[0].ib_hicon + gl_hschar + 2;

		G.g_icw = (gl_height <= 300) ? 0 : 8;
		G.g_icw += G.g_wicon;
		xcnt = (gl_width/G.g_icw);
		G.g_icw += (gl_width % G.g_icw) / xcnt;
		G.g_ich = G.g_hicon + MIN_HINT;
		ycnt = ((gl_height-gl_hbox) / G.g_ich);
		G.g_ich += ((gl_height-gl_hbox) % G.g_ich) / ycnt;

		xcent = (G.g_wicon - G.g_idlist[0].ib_wicon) / 2;
		G.g_nmicon = 9;
		G.g_xyicon[0] = xcent;
		G.g_xyicon[1] = 0;
		G.g_xyicon[2]=xcent;
		G.g_xyicon[3]=G.g_hicon-gl_hschar-2;
		G.g_xyicon[4] = 0;
		G.g_xyicon[5] = G.g_hicon-gl_hschar-2;
		G.g_xyicon[6] = 0;
		G.g_xyicon[7] = G.g_hicon;
		G.g_xyicon[8] = G.g_wicon;
		G.g_xyicon[9] = G.g_hicon;
		G.g_xyicon[10]=G.g_wicon;
		G.g_xyicon[11] = G.g_hicon-gl_hschar-2;
		G.g_xyicon[12]=G.g_wicon - xcent;
		G.g_xyicon[13]=G.g_hicon-gl_hschar-2;
		G.g_xyicon[14] = G.g_wicon - xcent;
		G.g_xyicon[15] = 0;
		G.g_xyicon[16] = xcent;
		G.g_xyicon[17] = 0;
		G.g_nmtext = 5;
		G.g_xytext[0] = 0;
		G.g_xytext[1] = 0;
		G.g_xytext[2] = gl_wchar * 12;
		G.g_xytext[3] = 0;
		G.g_xytext[4] = gl_wchar * 12;
		G.g_xytext[5] = gl_hchar;
		G.g_xytext[6] = 0;
		G.g_xytext[7] = gl_hchar;
		G.g_xytext[8] = 0;
		G.g_xytext[9] = 0;
		return(TRUE);
	}
}

/* Reverse list when we write so that we can read it in naturally */
VOID app_revit(VOID)
{
	ANODE	*pa;
	ANODE	*pnxtpa;

	/* reverse list */
	pa = G.g_ahead;
	G.g_ahead = (ANODE *)NULL;
	while (pa)
	{
		pnxtpa = pa->a_next;
		pa->a_next = G.g_ahead;
		G.g_ahead = pa;
		pa = pnxtpa;
	}
}

/*
*	Save the current state of all the icons to a file called 
*	DESKTOP.INF
*/
WORD app_save(WORD todisk)
{
	FILE	*fh;
	WORD	i, ret, envr;
	BYTE	*pcurr, *ptmp;
	ANODE	*pa;
	WSAVE	*pws;

	memset(&gl_afile[0], 0, SIZE_AFILE);
	pcurr = &gl_afile[0];
	/* save evironment */
	*pcurr++ = '#';
	*pcurr++ = 'E';
	envr = 0x0;
	envr |= (G.g_cnxsave.vitem_save) ? 0x80 : 0x00;
	envr |= ((G.g_cnxsave.sitem_save) << 5) & 0x60;
	envr |= (G.g_cnxsave.cdele_save) ? 0x10 : 0x00;
	envr |= (G.g_cnxsave.ccopy_save) ? 0x08 : 0x00;
	envr |= G.g_cnxsave.cdclk_save;
	pcurr = save_2(pcurr, envr);
	envr = (G.g_cnxsave.covwr_save) ? 0x00 : 0x10;
	envr |= (G.g_cnxsave.cmclk_save) ? 0x08 : 0x00;
	envr |= (G.g_cnxsave.cdtfm_save) ? 0x00 : 0x04;
	envr |= (G.g_cnxsave.ctmfm_save) ? 0x00 : 0x02;
#if GEM & (GEM2 | GEM3 | XGEM)
	envr |= sound(FALSE, 0xFFFF, 0)  ? 0x00 : 0x01;
#endif
	pcurr = save_2(pcurr, envr );

	*pcurr++ = 0x0d;
	*pcurr++ = 0x0a;
	/* save windows */
	for (i=0; i<NUM_WNODES; i++)
	{
		*pcurr++ = '#';
		*pcurr++ = 'W';
		pws = &G.g_cnxsave.win_save[i];
		pcurr = save_2(pcurr, pws->hsl_save);
		pcurr = save_2(pcurr, pws->vsl_save);
		pcurr = save_2(pcurr, pws->x_save / gl_wchar);
		pcurr = save_2(pcurr, pws->y_save / gl_hchar);
		pcurr = save_2(pcurr, pws->w_save / gl_wchar);
		pcurr = save_2(pcurr, pws->h_save / gl_hchar);
		pcurr = save_2(pcurr, pws->obid_save);
		ptmp = &pws->pth_save[0];
		*pcurr++ = ' ';
		if (*ptmp != '@')
		{
			while (*ptmp)
				*pcurr++ = *ptmp++;
		}
		*pcurr++ = '@';
		*pcurr++ = 0x0d;
		*pcurr++ = 0x0a;
	}		
#if MULTIAPP
	for (i=0; i<3; i++)
		if (gl_caccs[i].acc_name[0])
		{
			*pcurr++ = '#';
			*pcurr++ = 'A';
			pcurr = save_2(pcurr, gl_caccs[i].acc_swap);
			*pcurr++ = ' ';
			pcurr = save_str(pcurr, &(gl_caccs[i].acc_name[0]));
			pcurr--;
			*pcurr++ = 0x0d;
			*pcurr++ = 0x0a;
		}
#endif
	/* reverse ANODE list	*/
	app_revit();
	/* save ANODE list	*/
	for (pa=G.g_ahead; pa; pa=pa->a_next)
	{
		*pcurr++ = '#';
		switch (pa->a_type)
		{
			case AT_ISDISK:
				*pcurr++ = 'M';
				break;
			case AT_ISFILE:
				if ( (pa->a_flags & AF_ISCRYS) && (pa->a_flags & AF_ISGRAF) )
					*pcurr++ = 'G';
				else
				{
					*pcurr = (pa->a_flags & AF_ISPARM) ? 'P' : 'F';
					if (pa->a_flags & AF_ISFMEM)
						*pcurr += 'a' - 'A';
					pcurr++;
				}
				break;
			case AT_ISFOLD:
				*pcurr++ = 'D';
				break;
		}
		if (pa->a_flags & AF_ISDESK)
		{
			pcurr = save_2(pcurr, pa->a_xspot / G.g_icw);
			pcurr = save_2(pcurr, (pa->a_yspot - G.g_ydesk) / G.g_ich);
		}
		pcurr = save_2(pcurr, pa->a_aicon);
		pcurr = save_2(pcurr, pa->a_dicon);
		*pcurr++ = ' ';
		if (pa->a_flags & AF_ISDESK)
		{
			*pcurr++ = (pa->a_letter == '\0') ? ' ' : pa->a_letter;
			*pcurr++ = ' ';
		}
		pcurr = save_str(pcurr, pa->a_pappl);
		pcurr = save_str(pcurr, pa->a_pdata);
		pcurr--;
#if MULTIAPP
		if (!(pa->a_flags & AF_ISDESK))	/* only for apps */
		{
			pcurr++;	/* leave blank */
			pcurr = save_memsz(pcurr, pa->a_memreq);
		}
#endif
		*pcurr++ = 0x0d;
		*pcurr++ = 0x0a;
		/* skip standards */
		if ( (pa->a_type == AT_ISDISK) && (pa->a_next->a_type != AT_ISDISK) )
		{
			for (i=0; i<6; i++)
				pa = pa->a_next;
		}
	}
	*pcurr++ = 0x1a;
	*pcurr++ = 0x0;
	/* reverse list back */
	app_revit();
	/* calculate size */
	G.g_afsize = (WORD)(pcurr - &gl_afile[0]);
	/* save in memory */
	shel_put(ADDR(&gl_afile[0]), G.g_afsize);
	/* save to disk */
	if (todisk)
	{
		G.g_afsize--;
		fh = 0;
		while (!fh)
		{
			fh = app_getfh(FALSE, ini_str(STGEMAPP));
			if (!fh)
			{
				ret = fun_alert(1, STNOINF, NULL);
				if (ret == 2)
					return(FALSE);
			}
		}
		G.g_afsize = (WORD)fwrite(ADDR(&gl_afile[0]), 1, G.g_afsize, fh);
		fclose(fh);
	}
	return(TRUE);
}

/*
*	Build the desktop list of objects based on this current 
*	application list.
*/
BYTE app_blddesk(VOID)
{
	WORD	obid;
	UWORD	bvdisk, bvhard, bvect;
	ANODE	*pa;
	OBJECT	*pob;
	ICONBLK	*pic;
#if ALCYON_C
	LONG	*ptr;
#endif

	/* free all this windows kids and set size */
	obj_wfree(DROOT, 0, 0, gl_width, gl_height);
#if ALCYON_C
	ptr = &global[3];
	G.g_screen[DROOT].ob_spec = LLGET(ptr);
#else
#if TURBO_C
	G.g_screen[DROOT].ob_spec.index = LW(_GemParBlk.global[3]) + HW(_GemParBlk.global[4]);
#else
	G.g_screen[DROOT].ob_spec = LW(global[3]) + HW(global[4]);
#endif
#endif
	bvdisk = bvhard = 0x0;

	for (pa = G.g_ahead; pa; pa = pa->a_next)
	{
		if (pa->a_flags & AF_ISDESK)
		{
			obid = obj_ialloc(DROOT, pa->a_xspot, pa->a_yspot,
				G.g_wicon, G.g_hicon);
			if (!obid)
			{
				/* error case, no more obs */
			}
			/* set up disk vector	*/
			if (pa->a_type == AT_ISDISK)
			{
				bvect = ((UWORD) 0x8000) >> ((UWORD) (pa->a_letter - 'A'));
				bvdisk |= bvect;
#if GEMDOS
				if (pa->a_letter != 'A' && pa->a_letter != 'B')
#else
				if (pa->a_aicon == IG_HARD)
#endif
					bvhard |= bvect;
			}
			/* remember it */
			pa->a_obid = obid;
			/* build object */
			pob = &G.g_screen[obid];
			pob->ob_state = NORMAL;
			pob->ob_flags = NONE;
			pob->ob_type = G_ICON;
			G.g_index[obid] = pa->a_aicon;
#if TURBO_C
			pob->ob_spec.iconblk = ADDR( pic = &gl_icons[obid] );
#else
			pob->ob_spec = ADDR( pic = &gl_icons[obid] );
#endif
			memcpy(pic, &G.g_iblist[pa->a_aicon], sizeof(ICONBLK));
			pic->ib_xicon = ((G.g_wicon - pic->ib_wicon) / 2);
			pic->ib_ptext = ADDR(pa->a_pappl);
			pic->ib_char |= (0x00ff & pa->a_letter);
		}
	}
	appl_bvset(bvdisk, bvhard);
	return( get_defdrv(bvdisk, bvhard) );
}

/* Find the ANODE that is appropriate for this object. */
ANODE *app_afind(WORD isdesk, WORD atype, WORD obid, BYTE *pname, WORD *pisapp)
{
	ANODE	*pa;

	for (pa = G.g_ahead; pa; pa = pa->a_next)
	{
		if (isdesk)
		{
			if (pa->a_obid == obid)
				return(pa);
		}
		else
		{
			if ( (pa->a_type == atype) && !(pa->a_flags & AF_ISDESK) )
			{
				if ( wildcmp(pa->a_pdata, pname) )
				{
					*pisapp = FALSE;
					return(pa);
				}
	 			if ( wildcmp(pa->a_pappl, pname) )
				{
					*pisapp = TRUE;
					return(pa);
				}
			}
		}
	}
	return(0);
}

/* get_defdrv */
/* this routine returns the drive letter of the lowest drive: lowest */
/* lettered hard disk if possible, otherwise lowest lettered floppy */
/* (which is usually A) */
/* in dr_exist, MSbit = A */
BYTE get_defdrv(UWORD dr_exist, UWORD dr_hard)
{
	UWORD	mask, hd_disk;
	WORD	ii;
	BYTE	drvletr;

	mask = 0x8000;
	hd_disk = dr_exist & dr_hard;
	if (hd_disk)
	{
		/* there's a hard disk out there somewhere	*/
		for (ii = 0; ii <= 15; ii++)
		{
			if (mask & hd_disk)
			{
				drvletr = ii + 'A';
				break;
			}
			mask >>= 1;
		}
	}
	else
		drvletr = 'A'; /* assume A is always lowest floppy */
	return(drvletr);
}
