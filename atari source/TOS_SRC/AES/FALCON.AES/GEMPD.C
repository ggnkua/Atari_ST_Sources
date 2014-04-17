/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gempd.c,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:26:10 $	$Locker: kbad $
* =======================================================================
*  $Log:	gempd.c,v $
* Revision 2.2  89/04/26  18:26:10  mui
* TT
* 
* Revision 2.1  89/02/22  05:29:02  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:34:49  lozben
* Initial revision
* 
*************************************************************************
*/
/*	GEMPD.C		1/27/84 - 02/09/85	Lee Jay Lorenzen	*/
/*	pstart bugs	2/12/85 - 03/22/85	LKW			*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	Move insert_process to GEMDISP	07/12/85	Derek Mui	*/

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.1
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <portab.h>
#include <machine.h>
#include <struct88.h>
#include <baspag88.h>
#include <obdefs.h>
#include <gemlib.h>

EXTERN THEGLO	D;

EXTERN WORD	gl_naccs;
EXTERN ACCPD	*gl_pacc[];

	WORD
fapd(pname, pid, ppd)
	BYTE	*pname;
	WORD	pid;
	REG PD		*ppd;
{
	REG WORD	ret;
	BYTE		temp[9];
	ret = FALSE;
	temp[8] = NULL;
	if (pname != NULLPTR)
	{
	  movs(8, ppd->p_name, &temp[0]);
	  ret = strcmp( pname, &temp[0]);
	}
	else
	  ret = (ppd->p_pid == pid);
	return(ret);
}

	PD
*fpdnm(pname, pid)
	BYTE		*pname;
	UWORD		pid;
{
	REG WORD		i;
	PD		*ppd;

	for(i=0; i<NUM_PDS; i++)
	{
	  if (fapd(pname, pid, &D.g_pd[i]) )
	    return(&D.g_pd[i]);
	}
	for(i=0; i<gl_naccs; i++)
	{
	  if (fapd(pname, pid, &gl_pacc[i]->ac_pd) )
	    return(&gl_pacc[i]->ac_pd);
	}
	return(NULLPTR);
}

	PD 
*getpd()
{
	PD		*p;
						
	if (curpid < NUM_PDS)			/* get a new PD		*/
	{
 	  p = &D.g_pd[curpid];
	  p->p_pid = curpid++;
	}
	else					/* otherwise get it 	*/ 
	{					/* accessory's PD list	*/
	  p = &gl_pacc[gl_naccs]->ac_pd;
	  p->p_pid = NUM_PDS + gl_naccs++;
	}
						/* initialize his DS&SS	*/
						/*   registers so	*/
						/*   stproc works	*/
						/* setdsss(p->p_uda);	*/
/*	setdsss(puda)
*		UDA	*puda;
*
*	set "segment " into u_ssuper and u_ssuser
*	and set u_insuper to TRUE
*
*	in 68k u_ssuper and u_ssuser do not exist
*/

	p->p_uda->u_insuper = 1;
						/* return the pd we got	*/
	return(p);
}


	VOID
p_nameit(p, pname)
	PD		*p;
	BYTE		*pname;
{
	bfill(8, ' ',  &p->p_name[0]);
	strscn(pname, &p->p_name[0], '.');
}


	PD
*pstart(pcode, pfilespec, ldaddr)
	BYTE		*pcode;
	BYTE		*pfilespec;
	LONG		ldaddr;
{
	REG PD		*px;
						/* create process to	*/
						/*   execute it		*/
	px = getpd();
	px->p_ldaddr = ldaddr;
						/* copy in name of file	*/
	p_nameit(px, pfilespec);
						/* cs, ip, use 0 flags	*/
	psetup(px, pcode);
						/* link him up		*/
	px->p_stat = PS_RUN;
	px->p_link = drl;
	drl = px;

	return(px);
}
#if UNLINKED

						/* put pd pi into list 	*/
						/*   *root at the end	*/
	VOID
insert_process(pi, root)
	PD		*pi, **root;
{
	REG PD		*p, *q;
						/* find the end		*/
	for ( p = (q = (PD *) root) -> p_link ; p ; p = (q = p) -> p_link); 
						/* link him in		*/
	pi->p_link = p;
	q->p_link = pi;
}
#endif

