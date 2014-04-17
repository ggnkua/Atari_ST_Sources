/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemcli.c,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:21:22 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemcli.c,v $
* Revision 2.2  89/04/26  18:21:22  mui
* TT
* 
* Revision 2.1  89/02/22  05:25:02  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:31:09  lozben
* Initial revision
* 
*************************************************************************
*/
/*	Crunch at ldaccs	3/18/88			D.Mui		*/
/*	Take out sysacc define		2/11/88		D.Mui		*/
/*	Fix at ldaccs .. load accessory from root  10/23/85 D.Mui	*/
/*	Fix at ldaccs for *.acc file	09/09/85	Derek Mui	*/
/*	Fix at ldaccs for no disk 	08/28/85	Derek Mui	*/
/*	Change ldaccs	07/15/85 - 07/16/85	Derek Mui		*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	to 68k		02/22/85 - 05/20/85	LKW			*/
/*	GEMCLI.C	1/28/84 - 02/02/85	Lee Jay Lorenzen	*/
/*	Make used_acc as global	7/16/90		D.Mui			*/
/*	Start the process in to be suspended state 8/9/90	D.Mui	*/

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <portab.h>
#include <machine.h>
#include <struct88.h>
#include <baspag88.h>
#include <obdefs.h>
#include <gemusa.h>
#include <gemlib.h>
#include <dos.h>


#define ROPEN 0
#define WOPEN 1
#define RWOPEN 2
#define TEXTBASE 8
						/* in PD88.C		*/
EXTERN PD	*pstart();
						/* in DISPA88.A86	*/
EXTERN VOID	gotopgm();
						/* in DOSIF.A86		*/
EXTERN VOID	pgmld();
EXTERN WORD	DOS_ERR;
EXTERN LONG	dos_avail();
EXTERN LONG	dos_alloc();
						/* in GEMRSLIB.C	*/
EXTERN BYTE	*rs_str();

EXTERN LONG	ad_shcmd;

EXTERN THEGLO	D;

EXTERN WORD	isdrive();
EXTERN WORD	cart_init();
EXTERN WORD	ld_cartacc();

EXTERN VOID	pinit();

EXTERN WORD	diskin;		/* in gemjstrt.s	*/

GLOBAL ACCPD	*gl_pacc[MAX_ACCS];	/* total of 6 desk acc, 1 from rom	*/
GLOBAL WORD	gl_naccs;
GLOBAL BYTE	*gl_adacc[MAX_ACCS];	/* addresses of accessories	*/
EXTERN WORD	DOS_AX;

GLOBAL	BYTE	*sys_adacc;

GLOBAL	BYTE	stacc[] = "\\*.ACC";

WORD	used_acc;			/* currently number of acc	*/

EXTERN	PD	*slr;


/*	Make sure everybody is on the suspend list before going on	*/

release()
{
	REG PD	*p;

	while( TRUE )
	{
	  if ( !rlr )	/* make sure everyone is finished its stuff	*/
	    break;
	
	  if ( ( ( !rlr->p_pid ) || ( rlr->p_pid == 1 ) )
		&& ( !rlr->p_link ) ) 
	    break;

	  dsptch();
	}

	p = slr;
	
	while( p )			
	{
	  p->p_stat = PS_MWAIT;
	  p = p->p_link;
	}

	if ( !nrl )		/* append all the processes to	*/
	  nrl = slr;		/* the end of the waiting list	*/
	else
	{
	  p = nrl;

	  while( p )
	  {
	    if ( !p->p_link )
	    {
	      p->p_link = slr;
	      break;
	    }
	    else
	      p = p->p_link;
	  }
	}

	slr = (PD*)0;
}


/*	Give everyone a chance to run, at least once	*/

all_run()
{
	WORD		i;

	for( i = 0; i < used_acc; i++ )
	  dsptch();
						/* then get in the wait	*/
						/*   line		*/
	wm_update(TRUE);
	wm_update(FALSE);
}


/*
*	Routine to load program file pointed at by pfilespec, then
*	create new process context for it.  This uses the load overlay
*	function of DOS.  The room for accessories variable will be
*	decremented by the size of the accessory image.  If the
*	accessory is too big to fit it will be not be loaded.
*/
	WORD
sndcli(pfilespec,acc)
	REG BYTE		*pfilespec;
	WORD		acc;
{
	REG WORD		handle;
	WORD		err_ret;
	LONG		ldaddr;
	PD		*p;

	strcpy(pfilespec, &D.s_cmd[0]);
	handle = dos_open( ad_shcmd, ROPEN );
	if (!DOS_ERR)
	{				/* allocate PD memory for accessory */
	  err_ret = ( acc != 0 ) ? cre_aproc() : TRUE;

	  if (err_ret)
	  {
	    err_ret = pgmld(handle, &D.s_cmd[0], &ldaddr);	/*, paccroom);*/
	    dos_close(handle);
						/* create process to	*/
						/*   execute it		*/
	    if (err_ret != -1)
	    {
	      if (acc == 0)
	        sys_adacc = ldaddr;
	      else
	        gl_adacc[gl_naccs] = ldaddr;	/* save acc address	*/
	      
	      p = pstart(&gotopgm, pfilespec, ldaddr);
	      p->p_stat |= PS_TRYSUSPEND;
	      return(TRUE);
	    }
	  }
	}

	return(FALSE);

}


/*
*	Routine to load in desk accessory's.  Files by the name of *.ACC
*	will be loaded, if there is sufficient room for them in the system.
*	If SYSTEM.ACC is not zero, it is treated as the beginning of a
*	desk accessory in system rom and is executed.
*	The cartridge is searched for *.ACC and each one is executed.
*	If there is any space left, *.ACC etc. are then loaded from disk.
*	It will first try the hard disk, if there is no acc files then it
*	will go back to the boot drive.
*/


	VOID
ldaccs()
{
	REG WORD		i;
	    WORD		ret;
 	    BYTE		*psp;
	    WORD		defdrv;
	    BYTE		tempadds[50];
	    BYTE		*name;


	gl_naccs = 0;
	used_acc = 0;

	if ( cart_init() )
	  used_acc += ld_cartacc();

	if ( isdrive() && diskin )
	{
	  defdrv = dos_gdrv();	/* save the default drive	*/
	  name = tempadds;
	  dos_sdta ( name );	/* set the DMA address		*/

	  if ( isdrive() & 0x04 )
	    dos_sdrv( 0x02 );	/* set the hard disk	*/
				/* search the file	*/
	  dos_chdir("\\");	/* always at root	*/
	  if ( !dos_sfirst( stacc, 0 ) )
	    dos_sdrv( defdrv );	/* if not at the hard 	*/
				/* disk go back to defa */

	  dos_chdir("\\");	/* always at root	*/
	  ret = dos_sfirst( stacc, 0 );

	  name += 0x1EL;

	  for ( i = 0; i < MAX_ACCS && used_acc < MAX_ACCS && ret; i++ )
  	  {
	    if ( sndcli(name,used_acc) )
	      used_acc++;

	    ret = dos_snext();
	  }

	}
}

free_accs()
{
	REG WORD	i;
	REG BYTE	*ptmp;

	if (sys_adacc)
	{
	  dos_free( LLGET(sys_adacc + 0x2c));	/* free envr string	*/
	  dos_free(sys_adacc);
	}

	for (i=0; i < gl_naccs; i++)
	{
	  ptmp = gl_adacc[i];
	  dos_free( LLGET(ptmp + 0x2c));	/* free envr string	*/
	  dos_free(ptmp);		/* free acc's memory		*/
	  dos_free(gl_pacc[i]);		/* free process descriptors	*/
	}
}

	WORD
cre_aproc()
{
	REG PD			*ppd;
	UDA		*puda;
	CDA		*pcda;
	REG EVB			*pevb;
	REG ACCPD		*paccpd;
	REG WORD		i;

	paccpd = (ACCPD *)dos_alloc((ULONG)sizeof(ACCPD));
	if (paccpd)
	{
	  bfill( sizeof(ACCPD), 0, paccpd );
	  gl_pacc[gl_naccs] = paccpd;
	  ppd = &paccpd->ac_pd;
	  puda = &paccpd->ac_uda;
	  pcda = &paccpd->ac_cda;
	  pevb = &paccpd->ac_evb;

	  pinit(ppd, pcda);
	  ppd->p_uda = puda;
	  puda->u_spsuper = &puda->u_supstk;
	  for(i=0; i<EVB_PROC; i++)
 	  {
	    pevb[i].e_nextp = eul;
	    eul = &pevb[i];
	  }
	  return(TRUE);
	}
	return(FALSE);
}
