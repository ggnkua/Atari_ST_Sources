/*	DESKPRO.C	4/18/84 - 03/19/85	Lee Lorenzen		*/
/*	for 3.0		3/11/86 - 01/28/87	MDF			*/
/*	merge source	5/27/87	- 5/28/87	mdf			*/

/*
*       Copyright 1999, Caldera Thin Clients, Inc.                      
*       This software is licenced under the GNU Public License.         
*       Please see LICENSE.TXT for further information.                 
*                                                                       
*                  Historical Copyright                                 
*	-------------------------------------------------------------
*	GEM Desktop					  Version 2.3
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985 - 1987			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <tos.h>
#include <aes.h>
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
#include "desktop.h"
#include "deskbind.h"
#include "desksupp.h"
#include "deskpro.h"
#if GEMDOS
#include "deskfun.h"
#endif

#if MULTIAPP
GLOBAL WORD	pr_kbytes;
GLOBAL LONG	pr_beggem;		/* first paragraph of AES	*/
GLOBAL LONG	pr_begacc;		/* first paragraph of acces.	*/
GLOBAL LONG	pr_begdsk;		/* first paragraph of desktop	*/
GLOBAL LONG	pr_topdsk;		/* first paragraph above desktop  */
GLOBAL LONG	pr_topmem;		/* next paragraph above free area */
GLOBAL LONG	pr_ssize;		/* size of channel system overhead */
GLOBAL LONG	pr_itbl;		/* base of GDOS default int table  */
EXTERN WORD	gl_fmemflg;
#endif

EXTERN WORD	gl_stdrv;
EXTERN WORD	DOS_ERR;
EXTERN WORD	DOS_AX;
EXTERN GLOBES	G;

#if MULTIAPP

#define LMIN(x,y) ((x)<(y)?(x):(y))

/* in pro_chcalc long addresses are flattened out with no segment */
VOID pro_chcalc(LONG appsize, LONG *begaddr, LONG *chsize)
{
	static LONG	begfree = 0l;
	LONG	maxmem;

	if (appsize == -1)	/* full step */
	{
		*begaddr = LSEGOFF(pr_beggem); 
		*chsize = pr_topmem - pr_beggem;
	}
	else
	{
		if ((begfree >= pr_topmem) || (begfree < pr_topdsk))
			begfree = pr_topdsk;	

		maxmem = pr_topmem - pr_begdsk;
		*chsize = LMIN(appsize+pr_ssize, maxmem);

		if ((begfree + *chsize) < pr_topmem)
			*begaddr = LSEGOFF(begfree);
		else
			*begaddr = LSEGOFF(pr_topmem - *chsize);
		begfree += *chsize;	
	}
}
#endif

WORD pro_chdir(WORD drv, BYTE *ppath)
{
	WORD	tmpdrv;

	/* change to directory that application is in */
	if (!drv)
		return( (DOS_ERR = TRUE) );
	else
	{
		if ( drv != '@' ) 
		{
#if GEMDOS
			tmpdrv = Dgetdrv();
			Dsetdrv(drv - 'A');
			DOS_AX = tmpdrv;
			DOS_ERR = Dgetdrv() != (drv - 'A');
#else
			tmpdrv = dos_gdrv();
			dos_sdrv(drv - 'A');
#endif
			if (DOS_ERR)
			{
#if GEMDOS
				Dsetdrv(tmpdrv);
#else
				dos_sdrv(tmpdrv);
#endif
				return(FALSE);
			}
			G.g_srcpth[0] = drv;
			G.g_srcpth[1] = ':';
			G.g_srcpth[2] = '\\';
			strcpy(&G.g_srcpth[3],ppath);
#if GEMDOS
			DOS_AX = Dsetpath(&G.g_srcpth[0]);
			DOS_ERR = DOS_AX != 0;
#else
			dos_chdir(ADDR(&G.g_srcpth[0]));
#endif
		}
		else
		{
#if GEMDOS
			Dsetdrv(gl_stdrv);	/* don't leave closed drive hot	*/
			DOS_AX = 0;
			DOS_ERR = 0;
#else
			dos_sdrv(gl_stdrv);	/* don't leave closed drive hot	*/
#endif
		}
		return(TRUE);
	}
} /* pro_chdir */

WORD pro_cmd(BYTE *psubcmd, BYTE *psubtail, WORD exitflag)
{
	LONG	lp;
	WORD	i, ii, drv;
	BYTE	save_ch;

	shel_envrn((BYTE FAR **)ADDR(&lp), (BYTE FAR *)ADDR("COMSPEC="));
	if (lp)
	{
		LSTCPY(ADDR(&G.g_cmd[0]), lp);
		if (!exitflag)
		{
			i = 0;
			while(G.g_cmd[i] != '\\')	/* find first backslash */
				i++;
			/* change to drive specified by COMSPEC */
			drv = G.g_cmd[i - 2] - 'A';
#if GEMDOS
			Dsetdrv(drv);
			DOS_AX = 0;
			DOS_ERR = 0;
#else
			dos_sdrv(drv);
#endif
			/* chdir to path specified by COMSPEC */
			ii = (WORD)strlen(&G.g_cmd[0]);
			while (G.g_cmd[--ii] != '\\')	/* find last backslash */
				;
			if (i == ii)	/* root directory? */
				ii++;	/* keep backslash in path name */
			save_ch = G.g_cmd[ii];	/* save char for later */
			G.g_cmd[ii] = NULL;	/* make a null-term. string */
#if GEMDOS
			DOS_AX = Dsetpath(&G.g_cmd[0]);	/* change to that dir. */
			DOS_ERR = DOS_AX < 0;
#else
			dos_chdir(ADDR(&G.g_cmd[0]));	/* change to that dir. */
#endif
			G.g_cmd[ii] = save_ch;	/* put the char back */
		}
		if (exitflag)
		{
#if PCDOS
			strcpy(&G.g_tail[1], "/C ");
#endif
			strcat(psubcmd, &G.g_tail[1]);
			strcat(" ", &G.g_tail[1]);
			strcat(psubtail, &G.g_tail[1]);
		}
		else
			G.g_tail[1] = NULL;
		return(TRUE);
	} /* if lp */
	else
		return(FALSE);
} /* pro_cmd */

WORD pro_run(WORD isgraf, WORD isover, WORD wh, WORD curr)
{
	WORD	ret, len, i;

	len = (WORD)strlen(&G.g_tail[1]);
	if ( (len) && (!isgraf) )
	{
		for (i = len; i; i--)
			G.g_tail[i+1] = G.g_tail[i];
		G.g_tail[1] = ' ';
		len++;
	} /* if */
	G.g_tail[0] = len;
	G.g_tail[len+1] = 0x0D;
#if MULTIAPP
	if (isover != 3)	/* keep icon SELECTED during FORMAT */
		do_wopen(FALSE, wh, curr, G.g_xdesk, G.g_ydesk, G.g_wdesk, G.g_hdesk);
#endif
	ret = pro_exec(isgraf, isover, G.a_cmd, G.a_tail);
	if (isover == -1)
		ret = FALSE;
	else
	{
#if MULTIAPP
		if (isover == 3)	/* for FORMAT */
#else
		if (wh != -1)
#endif
			do_wopen(FALSE, wh, curr, G.g_xdesk, G.g_ydesk,
				G.g_wdesk, G.g_hdesk);
	} /* else */
	return(ret);
} /* pro_run */

WORD pro_exec(WORD isgraf, WORD isover, LONG pcmd, LONG ptail)
{
/*#if !GEMDOS*/
	WORD	ret;
/*#endif*/
#if MULTIAPP
	WORD	chnum;
	LONG	begaddr, csize;

	if (isover != 3)
#endif
	graf_mouse(HOURGLASS, 0x0L);

#if MULTIAPP
	if ((isover == -1) || (isover == 2) || (isover == 3))
	{
		if (isover == 2)	/* full step */
			pro_chcalc((LONG)-1, &begaddr, &csize);
		else
			pro_chcalc((LONG)pr_kbytes << 10, &begaddr, &csize);
/*
dbg("NEW START ADDRESS = %X\r\n", begaddr);
dbg("NEW CHANNEL SIZE  = %X\r\n", csize);
*/
		ret = proc_create(begaddr, csize, 1, isgraf, &chnum);
		if (!ret)
		{
			fun_alert(1,STNOROOM,NULLPTR);
			return(FALSE);
		}
		if (isover == 2)
			gl_fmemflg |= (1 << chnum);
/*
dbg("CREATE = %d\r\n", ret);
dbg("CHNUM  = %d\r\n", chnum);
dbg("PCMD   = %s\r\n", pcmd);
dbg("PTAIL  = %s\r\n", ptail);
*/
		ret = proc_run(chnum, isgraf, isover, pcmd, ptail);
		if (isover==3)
			ret = 0;
	}
	else
#endif
/*
#if GEMDOS
	{
		GRECT ar;
		int	win;

		wind_update(END_UPDATE);
		Pexec(0, (BYTE *)pcmd, (BYTE *)ptail, NULL);
		wind_update(BEG_UPDATE);
		menu_bar((OBJECT FAR *)G.a_trees[ADMENU], TRUE);
		for (win=0; win<G.g_wcnt; win++)
		{
			wind_get(G.g_wlist[0].w_id, WF_WORKXYWH,
				&ar.g_x, &ar.g_y, &ar.g_w, &ar.g_h);
			fun_msg(WM_REDRAW, G.g_wlist[0].w_id,
				ar.g_x, ar.g_y, ar.g_w, ar.g_h);
		}
	}
	return( 0 );
#else
*/
		ret = shel_write(TRUE, isgraf, isover, (BYTE FAR *)pcmd, (BYTE FAR *)ptail);
	if (!ret)
		graf_mouse(ARROW, 0x0L);
	return( ret );
/*#endif*/
} /*  */

WORD pro_exit(LONG pcmd, LONG ptail)
{
	WORD	ret;

	ret = shel_write(FALSE, FALSE, 1, (BYTE FAR *)pcmd, (BYTE FAR *)ptail);
	return( ret );
} /* pro_exit */
