/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

                        Copyright 1988 Hybrid Arts, Inc.

	module:	EDPEDR -- edit pitch and rhythm patterns

	ex_pitch, ex_rhythm, edit_rhythm, edit_pitch

******************************************************************************/

overlay "edit"

/* include header files .....................................................*/

#include <asm.h>				  /* needed for in-line assembly language */
#include "defines.h"         /* program-specific */
#include <gemdefs.h>         /* AES                  */
#include <obdefs.h>          /* more AES  */
#include <osbind.h>          /* GEMDOS, BIOS, XBIOS  */
#include "ludwig.h"          /* created by RCS       */

/* global variables .........................................................*/

#include "externs.h"
char *used_ptr;
#define NGRPROWS 10				/* # rows and # cols in GRPTREE matrix */
#define NGRPCOLS 3
int edprtempo=72;					/* tempo inside pattern editors */
int end_colp,end_colr;			/* end column (0-31) */

/* initialize/name pitch groups .............................................*/

ex_pitch()
{
	register int i,j,k;
	register char *ptr;
	char which_used[NCELL];

	used_ptr= which_used;
	set_bytes(which_used,NCELL,0);
	for (j=0; j<NSEQ; j++)
	{
		ptr= seq1data[j] + S_PSERIES;
		for (i=0; i<NCELL; i++,ptr+=2)
		{
			if ( (ptr[0]==0) || (ptr[0]==3) )
			{
				k=which_used[ptr[1]];
				if (!k)
					k= j+1;
				else
				{
					if ( (k>0) && (k!=j+1) ) k= -k;
				}
				which_used[ptr[1]]=k;
			}
		}
	}
	ex_grp(0);
}	/* end ex_pitch()	*/

/* initialize/name rhythm groups ............................................*/

ex_rhythm()
{
	register int i,j,k;
	register char *ptr;
	char which_used[NCELL];

	used_ptr= which_used;
	set_bytes(which_used,NCELL,0);
	for (j=0; j<NSEQ; j++)
	{
		ptr= seq1data[j] + S_RSERIES;
		for (i=0; i<NCELL; i++,ptr+=2)
		{
			if ( (ptr[0]==0) || (ptr[0]==3) )
			{
				k=which_used[ptr[1]];
				if (k>0)
					k= -k;
				else
				{
					if (!k) k=j+1;
				}
				which_used[ptr[1]]=k;
			}
		}
	}
	ex_grp(1);
}	/* end ex_rhythm() */

ex_grp(kind)
int kind;		/* 0 for pitch, 1 for rhythm */
{
	long grpleng;	/* length of one group */
	static int pagebase;
	int exit_obj,edit_obj,done,page_chg,mstate;
	register int grp_i,i,j;
	char alertstr[120];
	char *from_ptr,*to_ptr,*title,*ptr;

	if (kind)
	{
		title= RGRP_MSG;
		ptr= rhythmdata;
		grpleng= RHYTH1LENG;
	}
	else
	{
		title= PGRP_MSG;
		ptr= pitchdata;
		grpleng= PITCH1LENG;
	}

	/* text pointers */
	strcpy( ((TEDINFO*)(grpaddr[GRPTITL].ob_spec))->te_ptext , title );
	from_ptr= ((TEDINFO*)(grpaddr[GRPFROM].ob_spec))->te_ptext;
	to_ptr=   ((TEDINFO*)(grpaddr[GRPTO].ob_spec))->te_ptext;

	/* numbers and names */
	grp_page(pagebase,ptr,grpleng);
	putdial(grpaddr,1,0);

	edit_obj= GRPFROM;
	done=0;
	do
	{
		exit_obj= my_form_do(grpaddr,&edit_obj,&mstate);
		waitmouse();	/* don't allow mouse repeat */
		page_chg=0;
		switch (exit_obj)
		{
			case GRPCOPY:
			
			i= atoi(from_ptr);
			j= atoi(to_ptr);
			if ( (i<0) || (i>95) || (j<0) || (j>95) )
				form_alert(1,BADGRPN);
			else
			{
				if (i!=j)
				{
					strcpy(alertstr,CHEKFROM);
					strcat(alertstr,from_ptr);
					strcat(alertstr,": ");
					strcat(alertstr,ptr+i*grpleng);
					strcat(alertstr,CHEKTO);
					strcat(alertstr,to_ptr);
					strcat(alertstr,": ");
					strcat(alertstr,ptr+j*grpleng);
					strcat(alertstr,CHEKYESNO);
					if (form_alert(1,alertstr)==1)
					{
						copy_bytes(ptr+i*grpleng,ptr+j*grpleng,(int)grpleng);
						if ((j>=pagebase)&&(j<=((pagebase+NGRPCOLS*NGRPROWS)%NGRP)))
						{
							j-=pagebase;
							j= 2*NGRPROWS*(j/NGRPROWS) + (j%NGRPROWS) ;
							draw_object(grpaddr, GRPNAME+j );
						}
					}
				}
			}
			break;

			case GRPEXIT:	done=1;	break;
			case GRPPREV:	page_chg=(-1);
			case GRPNEXT:	if (!page_chg) page_chg=1;

			pagebase += page_chg*20 ;
			if (pagebase<0) pagebase = 80;
			if (pagebase>=100) pagebase=0;
			grp_page(pagebase,ptr,grpleng);
			edit_obj= GRPFROM;
			draw_object(grpaddr,GRPBOX);
			break;

			default:

			grp_i= exit_obj-GRPNUMB;
			if ( grp_i >= NGRPCOLS*NGRPROWS )
				grp_i -= (NGRPCOLS-1)*NGRPROWS;
			else
			{
				if (grp_i>=NGRPROWS) grp_i -= NGRPROWS;
			}
			grp_i += pagebase;	/* grp_i = 0 - NGRP-1 */
			if (mstate>0)			/* right button: initialize */
			{
				strcpy(alertstr,int2char[grp_i]);
				strcat(alertstr,": ");
				strcat(alertstr,ptr+grpleng*grp_i);
				if (big_alert(1,CHEKINIT,alertstr,CHEKYESNO)==1)
				{
					if (kind)
						def_rhyth1(ptr+grpleng*grp_i);
					else
						def_pitch1(ptr+grpleng*grp_i);
					draw_object(grpaddr,exit_obj+NGRPROWS);
				}
			}
			else		/* left button: edit */
			{
				putdial(0L,0,exit_obj);
				if (i=masterdata[M_LINK]) edrwith= edpwith= grp_i;
				i *= SELECTED ;
				edraddr[EDRLINK].ob_state = i;
				edpaddr[EDPLINK].ob_state = i;
				for (i=grp_i,j=kind; i>=0; j=!j)
					i= j ? edit_rhythm(i,rhythmdata+RHYTH1LENG*i) :
							  edit_pitch(i, pitchdata+PITCH1LENG*i) ;
				putdial(grpaddr,1,0);
			}
		}	/* end switch */
	}
	while (!done);
	putdial(0L,0,exit_obj);
}	/* end ex_grp() */

grp_page(base,ptr,grpleng)
register int base;
char *ptr;
long grpleng;
{
	register int row,col,k;
	char charbuf[2];
	char *charptr;

	charbuf[1]=0;
	for (col=0; col<NGRPCOLS; col++)
	{
		for (row=0; row<NGRPROWS; row++)
		{
			k= 2*NGRPROWS*col + row ;
			if ( base >= NGRP )
			{
				grpaddr[GRPNUMB+k].ob_flags |= HIDETREE ;
				grpaddr[GRPNUMB+k].ob_flags &= ~TOUCHEXIT ;
				grpaddr[GRPNAME+k].ob_flags |= HIDETREE ;
				grpaddr[GRPNAME+k].ob_flags &= ~EDITABLE ;
			}
			else
			{
				grpaddr[GRPNUMB+k].ob_flags &= ~HIDETREE ;
				grpaddr[GRPNUMB+k].ob_flags |= TOUCHEXIT ;
				grpaddr[GRPNAME+k].ob_flags &= ~HIDETREE ;
				grpaddr[GRPNAME+k].ob_flags |= EDITABLE ;
				charptr= grpaddr[GRPNUMB+k].ob_spec;
				asm { move.w k,-(a7) }
				k= used_ptr[base];
				charbuf[0]= k<0 ? '*' : ' ' ;
				strcpy(charptr,charbuf);
				if (k<0) k= -k;
				charbuf[0]= k ? k+'0' : ' ';
				asm { move.w (a7)+,k }
				strcat(charptr,charbuf);
				strcat(charptr," ");
				strcat(charptr,int2char[base]);
				((TEDINFO*)(grpaddr[GRPNAME+k].ob_spec))->te_ptext=
					ptr+grpleng*base;
			}
			base++;
		}
	}
}	/* end grp_page() */

/* edit a rhythm group ......................................................*/
/* returns # of pitch group to flip to, or -1 */

edit_rhythm(grp,ptr)
int grp;
char *ptr;
{
	char *nameptr, *linkptr, *tchanptr, *mchanptr;
	char charbuf[3];
	int vals[NCHD],newvals[NCHD];
	char ntrst[NCHD],newntrst[NCHD];
	int edit_obj,done,exit_obj,mstate;
	register int i,j,temp;
	char savethru,savechan,saveport;
	int xdot,xwith,xplex;
	int notes[NCHD];
	char notebase[NCHD];
	int ret_code= (-1);

	static int edrtnote=MIDDLE_C;
	static int edrmchan=15,edrmnote=MIDDLE_C-21;	/* R100 rim */
	static int edrmplex;
	static int edrcount=4,edrquant=2;
	static char edrthru=1,edrmetro=1,edrcorrect;

	objc_offset(edraddr,EDRSPEED,&xdot,&dummy);
	xdot+=24;
	objc_offset(edraddr,EDRWITH,&xwith,&dummy);
	xwith += edraddr[EDRWITH].ob_width/2 ;
	objc_offset(edraddr,EDRTCHAN,&xplex,&dummy);
	xplex += 16;

	if (!edrcorrect)
	{
		edraddr[EDRPLAY].ob_height--;	
		edraddr[EDRTNOTE].ob_height--;	
		edraddr[EDRTCHAN].ob_height--;	
		edraddr[EDRMETRO].ob_height--;	
		edraddr[EDRMNOTE].ob_height--;	
		edraddr[EDRMCHAN].ob_height--;	
		edraddr[EDRQUANT].ob_height--;	
		edraddr[EDRCOUNT].ob_height--;	
		edraddr[EDRRECRD].ob_height--;	
		edraddr[EDRRULE1].ob_y += 4;
		edraddr[EDRRULE2].ob_y += 4;
		edrcorrect=1;
	}

	strcpy( edraddr[EDRNUMB ].ob_spec , int2char[grp] );
	strcpy( edraddr[EDRWITH].ob_spec , int2char[edrwith] );
	strcpy( ((TEDINFO*)(edraddr[EDRNAMEP].ob_spec))->te_ptext ,
		pitchdata+PITCH1LENG*edrwith );
	nameptr= ((TEDINFO*)(edraddr[EDRNAME].ob_spec))->te_ptext;
	strcpy(nameptr,ptr);	

	/* copy rhythm group to edit buffer */
	copy_words(ptr+R_DUR,vals,NCHD);
	copy_bytes(ptr+R_NTRST,ntrst,NCHD);
	end_colr= *(int*)(ptr+R_NCOLS);

	/* encode */
	rhythm_end(end_colr);
	rhythm_ntrst(ntrst);
	if (edrthru)
		edraddr[EDRTHRU].ob_state |= SELECTED;
	else
		edraddr[EDRTHRU].ob_state &= ~SELECTED;
	if (edrmetro)
		edraddr[EDRMETRO].ob_state |= SELECTED;
	else
		edraddr[EDRMETRO].ob_state &= ~SELECTED;
	tchanptr= edraddr[EDRTCHAN].ob_spec;
	mchanptr= edraddr[EDRMCHAN].ob_spec;
	strcpy(tchanptr,int2char[edprchan+1]);
	tchanptr[2]= midiplex>=0 ? 'A'+edrtplex : ' ' ;
	strcpy(mchanptr,int2char[edrmchan+1]);
	mchanptr[2]= midiplex>=0 ? 'A'+edrmplex : ' ' ;
	tempotoa(edprtempo,edraddr[EDRSPEED].ob_spec);
	strcpy(edraddr[EDRCOUNT].ob_spec,int1char[edrcount]);
	strcpy(edraddr[EDRQUANT].ob_spec,timechar[edrquant-1]+1);
	miditoa(0,edrtnote,edraddr[EDRTNOTE].ob_spec);
	miditoa(0,edrmnote,edraddr[EDRMNOTE].ob_spec);
	draw_dur(end_colr,vals,0);

	putdial(edraddr,1,0);

	/* encode and draw values */
	rhythm_vals(vals,-1);

	/* midi thru */
	savethru=midithru;
	savechan=thruchan;
	saveport=thruport;
	midithru=edrthru;
	thruchan=edprchan;
	thruport=edrtplex;

	edit_obj= EDRNAME;
	done=0;
	do
	{
		exit_obj= my_form_do(edraddr,&edit_obj,&mstate);
		switch (exit_obj)
		{
			case CANEDR:	done=1;	break;

			case EDRNAMEP:			/* ok and flip to pitch group */
			ret_code= edrwith;
			edpwith= grp;
			edpaddr[EDPLINK].ob_state= edraddr[EDRLINK].ob_state ;

			case OKEDR:
			/* copy edit buffer to rhythm group */
			copy_words(vals,ptr+R_DUR,NCHD);
			copy_bytes(ntrst,ptr+R_NTRST,NCHD);
			*(int*)(ptr+R_NCOLS)= end_colr;
			strcpy(ptr,nameptr);	
			done=1;
			break;

			case EDRWITH:
			if (*Mousex < xwith)
			{
				edrwith+= 10*mstate;
				if (edrwith<0) edrwith+=100;
				if (edrwith>=100) edrwith-=100;
			}
			else
				edrwith+= mstate;
			if (edrwith<0) edrwith=NGRP-1;
			if (edrwith>=NGRP) edrwith=0;
			strcpy( edraddr[EDRWITH].ob_spec , int2char[edrwith] );
			strcpy( ((TEDINFO*)(edraddr[EDRNAMEP].ob_spec))->te_ptext ,
				pitchdata+PITCH1LENG*edrwith );
			draw_object(edraddr,EDRWITH);
			draw_object(edraddr,EDRNAMEP);
			waitmouse();
			break;

			case EDRCOND:
			for (i=0,j=(-1); i<=end_colr; i++)
			{
				if ( (!i) || (ntrst[i]) )
				{
					newvals[++j]=vals[i];
					newntrst[j]=ntrst[i];
				}
				else
				{
					temp= newvals[j]+vals[i]+2;
					if (temp<=32)
						newvals[j]=temp-1;
					else
					{
						newvals[j++]=31;
						newvals[j]= temp-33;
						newntrst[j]= ntrst[i];
					}
				}
			}
			for (i=0; i<=j; i++)
			{
				ntrst[i]=newntrst[i];
				vals[i]= newvals[i];
			}
			if (edraddr[EDRLINK].ob_state & SELECTED)
			{
				linkptr= pitch1data[edrwith];
				for (i=0; i<=end_colr; i++) if (*(int*)(linkptr+P_NOTE+2*i)) break;
				asm { move.w j,-(a7) }
				for (j=i; (i<=end_colr); i++)
				{
					if (temp= *(int*)(linkptr+P_NOTE+2*i))
					{
						*(int*)(linkptr+P_NOTE+2*j)= temp;
						linkptr[P_NTREF+j++]= linkptr[P_NTREF+i];
					}
				}
				asm { move.w (a7)+,j }
				*(int*)(linkptr+P_NCOLS)=j;
				for (i=j+1; i<NCHD; i++)			/* erase after end point */
				{
					linkptr[P_NTREF+i]= MIDDLE_C;
					*(int*)(linkptr+P_NOTE+2*i)= 0;
				}
			}
			rhythm_vals(vals,-1);
			rhythm_ntrst(ntrst);
			draw_object(edraddr,EDRNTR1);
			draw_object(edraddr,EDRNTR2);
			rhythm_end(-1);			draw_end(end_colr);
			rhythm_end(end_colr=j);	draw_end(end_colr);
			draw_dur(end_colr,vals,1);
			waitmouse();
			break;

			case EDRTNOTE:
			if (Kbshift(-1)&LRSHIFT) mstate*=12;
			edrtnote= transp_it(edrtnote,mstate);
			miditoa(0,edrtnote,edraddr[EDRTNOTE].ob_spec);
			draw_object(edraddr,EDRTNOTE);
			mouserepeat();
			break;

			case EDRMNOTE:
			if (Kbshift(-1)&LRSHIFT) mstate*=12;
			edrmnote= transp_it(edrmnote,mstate);
			miditoa(0,edrmnote,edraddr[EDRMNOTE].ob_spec);
			draw_object(edraddr,EDRMNOTE);
			mouserepeat();
			break;

			case EDRPLAY:
			edraddr[EDRPLAY].ob_state |= SELECTED ;
			draw_object(edraddr,EDRPLAY);
			graf_mouse(BEE_MOUSE);
			waitmouse();
			play_rhythm(end_colr,vals,ntrst,edrtnote,edprchan,edrtplex,edprtempo,
				edrmetro ? edrmnote : -1 , edrmchan , edrmplex ,
				edraddr[EDRLINK].ob_state & SELECTED ?
					pitchdata+PITCH1LENG*edrwith : 0L , mstate>0 );
			graf_mouse(ARROWMOUSE);
			edraddr[EDRPLAY].ob_state &= ~SELECTED ;
			draw_object(edraddr,EDRPLAY);
			waitmouse();
			break;

			case EDRSPEED:
			if (*Mousex < xdot) mstate*=8;
			edprtempo-=mstate;
			if (edprtempo<MINTEMPO) edprtempo += NTEMPO-MINTEMPO;
			if (edprtempo>=NTEMPO) edprtempo -= NTEMPO-MINTEMPO;
			tempotoa(edprtempo,edraddr[EDRSPEED].ob_spec);
			draw_object(edraddr,EDRSPEED);
			mouserepeat();
			break;

			case EDRCOUNT:
			edrcount += mstate;
			if (edrcount<1) edrcount=9;
			if (edrcount>9) edrcount=1;
			strcpy(edraddr[EDRCOUNT].ob_spec,int1char[edrcount]);
			draw_object(edraddr,EDRCOUNT);
			mouserepeat();
			break;

			case EDRQUANT:
			if (mstate<0)
				edrquant /= 2 ;
			else
				edrquant *= 2 ;
			if (!edrquant) edrquant=8;
			if (edrquant>8) edrquant=1;
			strcpy(edraddr[EDRQUANT].ob_spec,timechar[edrquant-1]+1);
			draw_object(edraddr,EDRQUANT);
			mouserepeat();
			break;

			case EDRTHRU:
			edrthru= !edrthru;
			if (edrthru)
				edraddr[EDRTHRU].ob_state |= SELECTED;
			else
				edraddr[EDRTHRU].ob_state &= ~SELECTED;
			draw_object(edraddr,EDRTHRU);
			midithru=edrthru;
			waitmouse();
			break;

			case EDRMETRO:
			edrmetro= !edrmetro;
			if (edrmetro)
				edraddr[EDRMETRO].ob_state |= SELECTED;
			else
				edraddr[EDRMETRO].ob_state &= ~SELECTED;
			draw_object(edraddr,EDRMETRO);
			waitmouse();
			break;

			case EDRTCHAN:
			if ( (*Mousex>xplex) && (midiplex>=0) )
			{
				edrtplex += mstate;
				if (edrtplex<0) edrtplex=3;
				if (edrtplex>3) edrtplex=0;
				tchanptr[2]= 'A'+edrtplex;
				thruport= edrtplex;
			}
			else
			{
				edprchan += mstate;
				if (edprchan<0) edprchan=15;
				if (edprchan>15) edprchan=0;
				thruchan=edprchan;
				strcpy(tchanptr,int2char[edprchan+1]);
				tchanptr[2]= midiplex>=0 ? 'A'+edrtplex : ' ' ;
			}
			draw_object(edraddr,EDRTCHAN);
			mouserepeat();
			break;

			case EDRMCHAN:
			if ( (*Mousex>xplex) && (midiplex>=0) )
			{
				edrmplex += mstate;
				if (edrmplex<0) edrmplex=3;
				if (edrmplex>3) edrmplex=0;
				mchanptr[2]= 'A'+edrmplex;
			}
			else
			{
				edrmchan += mstate;
				if (edrmchan<0) edrmchan=15;
				if (edrmchan>15) edrmchan=0;
				strcpy(mchanptr,int2char[edrmchan+1]);
				mchanptr[2]= midiplex>=0 ? 'A'+edrmplex : ' ' ;
			}
			draw_object(edraddr,EDRMCHAN);
			mouserepeat();
			break;

			case EDRRECRD:
			edraddr[EDRRECRD].ob_state |= SELECTED ;
			draw_object(edraddr,EDRRECRD);
			graf_mouse(BEE_MOUSE);
			i=record_r(edprtempo,edrmetro ? edrmnote : -1 ,edrmchan,edrmplex);
			graf_mouse(ARROWMOUSE);
			edraddr[EDRRECRD].ob_state &= ~SELECTED ;
			draw_object(edraddr,EDRRECRD);
			if (i)
			{
				rhythm_end(-1);		draw_end(end_colr);
				r_extract(edrquant,vals,ntrst,&end_colr,edrcount);
				if ( edraddr[EDRLINK].ob_state & SELECTED )
				{
					def_pitch1 ( linkptr= pitch1data[edrwith] ) ;
					p_extract(notes,notebase,&dummy);
					for (i=j=0; i<=end_colr; i++)
					{
						*(int*)(linkptr+P_NOTE+2*i)= ntrst[i] ? notes[j] : 0 ;
						linkptr[P_NTREF+i]= ntrst[i] ? notebase[j++] : MIDDLE_C ;
					}
					*(int*)(linkptr+P_NCOLS)= end_colr;
				}
				rhythm_end(end_colr);	draw_end(end_colr);
				rhythm_vals(vals,-1);
				rhythm_ntrst(ntrst);
				draw_object(edraddr,EDRNTR1);
				draw_object(edraddr,EDRNTR2);
				draw_dur(end_colr,vals,1);
			}
			waitmouse();
			break;

			default:

			i=(-1);
			if ( (exit_obj>=EDRVALUA) && (exit_obj<EDRVALUA+NCHD/2) )
				i= exit_obj-EDRVALUA;
			if ( (exit_obj>=EDRVALUB) && (exit_obj<EDRVALUB+NCHD/2) )
				i= exit_obj-EDRVALUB+NCHD/2;
			if (i>=0)
			{
				j= vals[i]+mstate;
				if (j<0) j=31;
				if (j>31) j=0;
				if (Kbshift(-1)&LRSHIFT) j= exact_val(j,mstate);
				vals[i]=j;
				rhythm_vals(vals,i);
				draw_dur(end_colr,vals,1);
				mouserepeat();
			}
			i=(-1);
			if ( (exit_obj>=EDRNTRTA) && (exit_obj<EDRNTRTA+NCHD/2) )
				i= exit_obj-EDRNTRTA;
			if ( (exit_obj>=EDRNTRTB) && (exit_obj<EDRNTRTB+NCHD/2) )
				i= exit_obj-EDRNTRTB+NCHD/2;
			if (i>=0)
			{
				ntrst[i]= !ntrst[i];
				rhythm_ntrst(ntrst);
				draw_object(edraddr,exit_obj);
				waitmouse();
			}
			i=(-1);
			if ( (exit_obj>=EDRENDA) && (exit_obj<EDRENDA+NCHD/2) )
				i= exit_obj-EDRENDA;
			if ( (exit_obj>=EDRENDB) && (exit_obj<EDRENDB+NCHD/2) )
				i= exit_obj-EDRENDB+NCHD/2;
			if (i>=0)
			{
				if (i!=end_colr)
				{
					rhythm_end(-1);			draw_end(end_colr);
					rhythm_end(end_colr=i);	draw_end(end_colr);
				/* linked editing: also move pitch last column */
					if ( edraddr[EDRLINK].ob_state & SELECTED )
						*(int*)(	pitch1data[edrwith]+P_NCOLS ) = end_colr;
					draw_dur(end_colr,vals,1);
					waitmouse();
				}
			}
		}	/* end switch */
	}
	while (!done);
	waitmouse();	/* don't allow mouse repeat */

	/* restore midi thru */
	thruport=saveport;
	midithru=savethru;
	thruchan=savechan;

	putdial(0L,0,exit_obj);
	return(ret_code);

}	/* end edit_rhythm() */

rhythm_ntrst(ntrst)
char *ntrst;
{
	register int i;

	for (i=0; i<NCHD/2; i++)
		edraddr[EDRNTRTA+i].ob_spec= ntrst[i] ? "N" : "R" ;
	for (i=NCHD/2; i<NCHD; i++)
		edraddr[EDRNTRTB+i-NCHD/2].ob_spec= ntrst[i] ? "N" : "R" ;

}	/* end rhythm_ntrst() */
	
rhythm_end(end_col)
int end_col;
{
	register int i;
	static char upstr[4]= "  ";	/* up-arrow */
	static char spstr[4]= "   ";
	
	for (i=0; i<NCHD/2; i++)
		edraddr[EDRENDA+i].ob_spec= i==end_col ? upstr : spstr ;
	for (i=NCHD/2; i<NCHD; i++)
		edraddr[EDRENDB+i-NCHD/2].ob_spec= i==end_col ? upstr : spstr ;

}	/* end rhythm_end() */

draw_end(end_col)
int end_col;
{
	if (end_col<NCHD/2)
		draw_object(edraddr,EDRENDA+end_col);
	else
		draw_object(edraddr,EDRENDB+end_col-NCHD/2);
}	/* end draw_end() */

draw_dur(end_col,vals,draw)
int end_col;
int *vals;
int draw;
{
	register int i,total;

	for (i=total=0; i<=end_col; i++) total+= (vals[i]+1);
	i= total>>3;
	strcpy(edraddr[INTGRDUR].ob_spec,int1char[i/100]);
	strcat(edraddr[INTGRDUR].ob_spec,int2char[i%100]);
	strcpy(edraddr[FRACTDUR].ob_spec,int1char[total%8]);
	if (draw)
	{
		draw_object(edraddr,INTGRDUR);
		draw_object(edraddr,FRACTDUR);
	}
}	/* end draw_dur() */

rhythm_vals(vals,which)
int *vals;
int which;
{
	register int i,j,k;
	int x,y,v[3];

	HIDEMOUSE;

	for (i=0; i<NCHD; i++,x+=4)
	{
		k=0;
		if (i==0)
		{
			objc_offset(edraddr,EDRVALUA,&x,&y);
			k=1;
		}
		if (i==(NCHD/2))
		{
			objc_offset(edraddr,EDRVALUB,&x,&y);
			k=1;
		}
		if (k)
		{
			y += edraddr[EDRVALUA].ob_height / 2 ;
			y -= 8;
			x /= 8;	/* column */
		}
		if ((which<0)||(which==i))
		{
			for (k=0,j=vals[i]+1; j&&(k<3); k++)
			{
				for (v[k]=9; v[k]>=0; v[k]--)
					if (exactdur[v[k]]<=j) break;
				j-=exactdur[v[k]];
			}
			for (j=0; j<k; j++) outnote(v[j],x+j,y);
			for (; j<3; j++) outnote(10,x+j,y);
		}
	}

	SHOWMOUSE;

}	/* end rhythm_vals() */

/* edit a pitch group .......................................................*/
/* returns # of rhythm group to flip to, or -1 */

edit_pitch(grp,ptr)
int grp;
char *ptr;
{
	register int i,j;
	char *nameptr,*plexptr;
	char charbuf[3];
	int edit_obj,exit_obj,done,mstate;
	unsigned int temp;
	static int pagebase;
	static char edpthru=1,edpcorrect;
	int notes[NCHD];
	char notebase[NCHD];
	int accid,my,y,pagechange,kstate,xdot,xwith;
	char savethru,savechan,saveport;
	int ret_code= -1;

	objc_offset(edpaddr,EDPSPEED,&xdot,&dummy);
	xdot+=24;
	objc_offset(edpaddr,EDPWITH,&xwith,&dummy);
	xwith += edpaddr[EDPWITH].ob_width/2 ;

	if (!edpcorrect)
	{
		edpaddr[EDPJUST].ob_height--;
		edpaddr[EDPTRANS].ob_height--;
		edpaddr[EDPRAND].ob_height--;
		edpcorrect=1;
	}

	strcpy(edpaddr[EDPNUMB].ob_spec , int2char[grp] );
	strcpy(edpaddr[EDPWITH].ob_spec, int2char[edpwith] );
	strcpy( ((TEDINFO*)(edpaddr[EDPNAMER].ob_spec))->te_ptext ,
		rhythmdata+RHYTH1LENG*edpwith );
	nameptr= ((TEDINFO*)(edpaddr[EDPNAME].ob_spec))->te_ptext;
	strcpy(nameptr,ptr);
	plexptr= edpaddr[EDPPLEX].ob_spec;

	/* copy pitch group to edit buffer */
	copy_words(ptr+P_NOTE,notes,NCHD);
	copy_bytes(ptr+P_NTREF,notebase,NCHD);
	end_colp= *(int*)(ptr+P_NCOLS);
	accid= ptr[P_ACCID];

	/* encode */
	pitch_end(pagebase,end_colp);
	pitch_ruler(pagebase);
	pitch_base(pagebase);
	strcpy(edpaddr[EDPCHAN].ob_spec,int2char[edprchan+1]);
	plexptr[0]= midiplex>=0 ? 'A'+edpplex : ' ' ;
	tempotoa(edprtempo,edpaddr[EDPSPEED].ob_spec);
	if (edpthru)
		edpaddr[EDPTHRU].ob_state |= SELECTED;
	else
		edpaddr[EDPTHRU].ob_state &= ~SELECTED;
	putdial(edpaddr,1,0);

	/* encode and draw notes */
	pitch_notes(accid,pagebase,notes,notebase,-1,-1);

	/* midi thru */
	savethru=midithru;
	savechan=thruchan;
	saveport=thruport;
	midithru=edpthru;
	thruchan=edprchan;
	thruport=edpplex;

	edit_obj= EDPNAME;
	done=0;
	do
	{
		exit_obj= my_form_do(edpaddr,&edit_obj,&mstate);
		pagechange=0;
		switch (exit_obj)
		{
			case CANEDP:	done=1;	break;

			case EDPNAMER:		/* ok and flip to rhythm group */
			ret_code= edpwith;
			edrwith= grp;
			edraddr[EDRLINK].ob_state= edpaddr[EDPLINK].ob_state ;

			case OKEDP:
			/* copy edit buffer to pitch group */
			copy_words(notes,ptr+P_NOTE,NCHD);
			copy_bytes(notebase,ptr+P_NTREF,NCHD);
			*(int*)(ptr+P_NCOLS) = end_colp;
			ptr[P_ACCID]= accid;
			strcpy(ptr,nameptr);
			done=1;
			break;

			case EDPACCID:
			pitch_notes(accid=!accid,pagebase,notes,notebase,-1,-1);
			waitmouse();
			break;

			case EDPWITH:
			if (*Mousex < xwith)
			{
				edpwith+= 10*mstate;
				if (edpwith<0) edpwith+=100;
				if (edpwith>=100) edpwith-=100;
			}
			else
				edpwith+= mstate;
			if (edpwith<0) edpwith=NGRP-1;
			if (edpwith>=NGRP) edpwith=0;
			strcpy(edpaddr[EDPWITH].ob_spec, int2char[edpwith] );
			strcpy( ((TEDINFO*)(edpaddr[EDPNAMER].ob_spec))->te_ptext ,
				rhythmdata+RHYTH1LENG*edpwith );
			draw_object(edpaddr,EDPWITH);
			draw_object(edpaddr,EDPNAMER);
			waitmouse();
			break;

			case EDPTRANS:
			if (Kbshift(-1)&LRSHIFT)
				for (i=0; i<NCHD; i++) transpose(12*mstate,&notes[i],&notebase[i]);
			else
			{
				/* don't allow shift-out */
				for (i=0; i<NCHD; i++)
				{
					j= notes[i];
					if (mstate<0)
					{
						if (BITTEST(0,j)) break;
					}
					else
					{
						if (BITTEST(15,j)) break;
					}
				}
				if (i<NCHD)
				{
					waitmouse();
					break;
				}
				for (i=0; i<NCHD; i++)
				{
					j= notes[i];
					if (mstate<0)
					{	asm { lsr.w #1,j } }
					else
					{	asm { lsl.w #1,j } }
					notes[i]=j;
				}
			}
			pitch_notes(accid,pagebase,notes,notebase,-1,-1);
			mouserepeat();
			break;

			case EDPJUST:
			for (i=0; i<=end_colp; i++)
			{
				if (temp=notes[i])
				{
					for (j=0; j<16; j++)
					{
						if (mstate<0)
						{
							if (BITTEST(0,temp)) break;
							if (notebase[i]==127) break;
							temp>>=1;
							notebase[i]++;
						}
						else
						{
							if (BITTEST(15,temp)) break;
							if (!notebase[i]) break;
							temp<<=1;
							notebase[i]--;
						}
					}
					notes[i]=temp;
				}
			}
			pitch_notes(accid,pagebase,notes,notebase,-1,-1);
			waitmouse();
			break;

			case EDPPLAY:
			edpaddr[EDPPLAY].ob_state |= SELECTED ;
			draw_object(edpaddr,EDPPLAY);
			graf_mouse(BEE_MOUSE);
			waitmouse();
			play_pitch(end_colp,notes,notebase,edprchan,edpplex,edprtempo,
				edpaddr[EDPLINK].ob_state & SELECTED ?
					rhythmdata+RHYTH1LENG*edpwith : 0L , mstate>0 );
			graf_mouse(ARROWMOUSE);
			edpaddr[EDPPLAY].ob_state &= ~SELECTED ;
			draw_object(edpaddr,EDPPLAY);
			waitmouse();
			break;

			case EDPTHRU:
			edpthru= !edpthru;
			if (edpthru)
				edpaddr[EDPTHRU].ob_state |= SELECTED;
			else
				edpaddr[EDPTHRU].ob_state &= ~SELECTED;
			draw_object(edpaddr,EDPTHRU);
			midithru=edpthru;
			waitmouse();
			break;

			case EDPCHAN:
			edprchan += mstate;
			if (edprchan<0) edprchan=15;
			if (edprchan>15) edprchan=0;
			thruchan=edprchan;
			strcpy(edpaddr[EDPCHAN].ob_spec,int2char[edprchan+1]);
			draw_object(edpaddr,EDPCHAN);
			mouserepeat();
			break;

			case EDPPLEX:
			if (midiplex>=0)
			{
				edpplex += mstate;
				if (edpplex<0) edpplex=3;
				if (edpplex>3) edpplex=0;
				plexptr[0]= 'A'+edpplex;
				thruport=edpplex;
				draw_object(edpaddr,EDPPLEX);
			}
			mouserepeat();
			break;

			case EDPSPEED:
			if (*Mousex < xdot) mstate*=8;
			edprtempo-=mstate;
			if (edprtempo<MINTEMPO) edprtempo += NTEMPO-MINTEMPO;
			if (edprtempo>=NTEMPO) edprtempo -= NTEMPO-MINTEMPO;
			tempotoa(edprtempo,edpaddr[EDPSPEED].ob_spec);
			draw_object(edpaddr,EDPSPEED);
			mouserepeat();
			break;

			case EDPRAND:
			kstate= Kbshift(-1)&LRSHIFT;
			for (i=0; i<=end_colp; i++)
			{
				if (mstate>0) notes[i]=0;
				BITSET(random(15),notes[i]);
				if (kstate) notebase[i]=random(127);
			}
			pitch_notes(accid,pagebase,notes,notebase,-1,-1);
			waitmouse();
			break;

			case EDPRECRD:
			edpaddr[EDPRECRD].ob_state |= SELECTED ;
			draw_object(edpaddr,EDPRECRD);
			graf_mouse(BEE_MOUSE);
			rectail=recstart;
			timestamp=0L;
			record_on=1;
			*keyb_head= *keyb_tail;
			waitmouse();
			while ( (*keyb_head==*keyb_tail) && (rectail!=recend) &&
					 !(*Mstate&3) ) ;
			*keyb_head= *keyb_tail;
			record_on=0;
			graf_mouse(ARROWMOUSE);
			edpaddr[EDPRECRD].ob_state &= ~SELECTED ;
			draw_object(edpaddr,EDPRECRD);
			if (rectail==recend)
				form_alert(1,BADMIDINP);
			else
			{
				p_extract(notes,notebase,&end_colp);
				pitch_end(pagebase,end_colp);
				pitch_notes(accid,pagebase,notes,notebase,-1,-1);
				draw_object(edpaddr,EDPENDS);
			}
			waitmouse();
			break;

			case EDPNEXT:
			pagebase += NCHD/4 ;
			pagechange=1;
			case EDPPREV:
			if (!pagechange) pagebase -= NCHD/4 ;
			pitch_base(pagebase);
			pitch_end(pagebase,end_colp);
			pitch_ruler(pagebase);
			draw_object(edpaddr,EDPPREV);
			draw_object(edpaddr,EDPNEXT);
			draw_object(edpaddr,EDPENDS);
			draw_object(edpaddr,EDPRULES);
			pitch_notes(accid,pagebase,notes,notebase,-1,-1);
			waitmouse();	/* don't allow mouse repeat */
			break;

			default:
			if ( (exit_obj>=EDPEDIT) && (exit_obj<(EDPEDIT+NCHD/2)) )
			{
				i= exit_obj-EDPEDIT+pagebase;
				kstate= Kbshift(-1);
				if (!kstate)
				{
					j= notes[i];
					asm { move.w i,-(a7) }
					if (mstate<0)
					{
						asm {
							lsr.w #1,j
							scs	i
						}
					}
					else
					{
						asm {
							lsl.w #1,j
							scs	i
						}
					}
					if (!i)		/* don't allow shift-out */
					{
						asm { move.w (a7)+,i }
						notes[i]=j;
						pitch_notes(accid,pagebase,notes,notebase,-1,
										exit_obj-EDPEDIT);
						mouserepeat();
					}
					else
					{
						asm { move.w (a7)+,i }
						waitmouse();
					}
					break;
				}
				if (kstate&ALT)
				{
					j=i;
					i=0;	/* redraw flag */
					if (j&&(mstate<0))	/* copy to left */
					{
						notes[j-1]=notes[j];
						notebase[j-1]=notebase[j];
						i=1;
					}
					if ((j<NCHD-1)&&(mstate>0))	/* copy to right */
					{
						notes[j+1]=notes[j];
						notebase[j+1]=notebase[j];
						i=1;
					}
					j -= (pagebase-mstate) ;
					if (i && (j>=0) && (j<NCHD/2) )
						pitch_notes(accid,pagebase,notes,notebase,-1,j);
					waitmouse();
					break;
				}
				if (kstate&LRSHIFT) mstate*=12;
				transpose(mstate,&notes[i],&notebase[i]);
				pitch_notes(accid,pagebase,notes,notebase,-1,exit_obj-EDPEDIT);
				mouserepeat();
				break;
			}
			if ( (exit_obj>=EDPEND) && (exit_obj<(EDPEND+NCHD/2)) )
			{
				end_colp= exit_obj - EDPEND + pagebase ;
				pitch_end(pagebase,end_colp);
			/* linked editing: also move rhythm last column */
				if ( edpaddr[EDPLINK].ob_state & SELECTED )
					*(int*)(	rhyth1data[edpwith]+R_NCOLS ) = end_colp;
				draw_object(edpaddr,EDPENDS);
				waitmouse();	/* don't allow mouse repeat */
				break;
			}
			/* clicked within note area */
			my= *Mousey;
			i= exit_obj-EDPAREA;	/* column */
			objc_offset(edpaddr,EDPAREA,&dummy,&y);
			y += 8*rez;
			for (j=0; j<NCHD/2; j++,y+=(8*rez))
				if (my<y) break;
			if (mstate>0) notes[i+pagebase]=0;
			if (BITTEST(j,notes[i+pagebase]))
				BITCLR(j,notes[i+pagebase]);
			else
				BITSET(j,notes[i+pagebase]);
			if (mstate>0) j=(-1);
			pitch_notes(accid,pagebase,notes,notebase,j,i);
			waitmouse();	/* don't allow mouse repeat */

		}	/* end switch */
	}
	while (!done);
	waitmouse();	/* don't allow mouse repeat */

	/* restore midi thru */
	thruport=saveport;
	midithru=savethru;
	thruchan=savechan;

	putdial(0L,0,exit_obj);
	return(ret_code);

}	/* end edit_pitch() */

pitch_end(pagebase,end_col)
int pagebase,end_col;
{
	register int i;
	static char upstr[5]= "  ";	/* up arrows */
	static char spstr[5]= "    ";

	for (i=0; i<NCHD/2; i++)
		edpaddr[EDPEND+i].ob_spec= end_col==(i+pagebase) ? upstr : spstr ;

}	/* end pitch_end() */

pitch_ruler(pagebase)
int pagebase;
{
	register int i;

	for (i=0; i<NCHD/2; i++)
		strcpy( ((TEDINFO*)(edpaddr[EDPRULER+i].ob_spec))->te_ptext , 
			int2char[pagebase+i+1] );
}	/* end pitch_ruler() */

pitch_base(pagebase)
int pagebase;
{
	if (pagebase==NCHD/2)
	{
		edpaddr[EDPNEXT].ob_state |= DISABLED;
		edpaddr[EDPNEXT].ob_flags &= ~TOUCHEXIT;
	}
	else
	{
		edpaddr[EDPNEXT].ob_state &= ~DISABLED;
		edpaddr[EDPNEXT].ob_flags |= TOUCHEXIT;
	}
	if (!pagebase)
	{
		edpaddr[EDPPREV].ob_state |= DISABLED;
		edpaddr[EDPPREV].ob_flags &= ~TOUCHEXIT;
	}
	else
	{
		edpaddr[EDPPREV].ob_state &= ~DISABLED;
		edpaddr[EDPPREV].ob_flags |= TOUCHEXIT;
	}
}	/* end pitch_base() */

pitch_notes(accid,pagebase,notes,notebase,row,col)
int accid,pagebase,notes[];
char notebase[];
int row,col;	/* which to draw, -1 for all */
{
	char charbuf[5];
	register int i,j,x,y;
	int x0,y0;

	objc_offset(edpaddr,EDPAREA,&x0,&y0);
	HIDEMOUSE;
	for (i=0,x=x0>>3; i<NCHD/2; i++,x+=4)
	{
		if ( (col<0) || (i==col) )
		{
			for (j=0,y=y0; j<NCHD/2; j++,y+=(8*rez))
			{
				if ( (row<0) || (row==j) )
				{
					miditoa(accid,j+notebase[pagebase+i],charbuf);
					gr_text(charbuf,x,y);
					if (BITTEST(j,notes[pagebase+i])) xortext(4,x,y);
				}
			}
		}
	}
	SHOWMOUSE;
}	/* end pitch_note() */

/* convert record buffer into pitch pattern .................................*/

p_extract(notefield,notebase,end_col)
int *notefield;
char *notebase;
int *end_col;
{
	register char *ptr;
	register int i,n;
	unsigned int c;
	char on;
	char notestat[128];
	char notes[128];
	int nnotes,field;

	for (i=0,ptr=recstart; (i<NCHD)&&(ptr<rectail);)
	{
		set_bytes(notestat,128,0);
		n=nnotes=0;
		do
		{
			c= *ptr++; ptr++;
			if (c==0xff) continue;		/* NOP */
			if (c==0x90) on=1;
			if (c==0x80) on=0;
			if ((c==0x80)||(c==0x90)) { c= *ptr++; ptr++; }
			if (!(*ptr++)) on=0;		/* velocity 0 means note off */
			ptr++;
			if (on)
			{
				if (!notestat[c])
				{
					notestat[c]=1;
					notes[n++]=c;
					nnotes++;
				}
			}
			else
			{
				if (notestat[c])
				{
					notestat[c]=0;
					nnotes--;
				}
			}
		}
		while ( nnotes && (ptr<rectail) && (n<128) ) ;
		if (n)
		{
			asm { move.w n,-(a7) }
			notebase[i]=127;
			field=0;
			for (--n; n>=0; --n) notebase[i]= min(notebase[i],notes[n]);
			asm { move.w (a7)+,n }
			for (--n; n>=0; --n)
			{
				c= notes[n] - notebase[i];
				if ( c<16 ) BITSET(c,field);
			}
			notefield[i]=field;
			i++;
		}
	}

	*end_col= i? i-1 : 0 ;
	for (; i<NCHD; i++) { notefield[i]=0; notebase[i]=MIDDLE_C; }

}	/* end p_extract() */

/* convert record buffer into rhythm pattern ................................*/

r_extract(quant,vals,ntrst,end_col,count)
int quant;
int *vals;
char *ntrst;
int *end_col;
int count;
{
	register char *ptr;
	register int n,i,on;
	register unsigned int dur;
	unsigned int c;

	/* quantize */
	dur=i=0;
	quant*=12;		/* convert to 96 ppq */
	count*=96;
	for (ptr=recstart; ptr<rectail; ptr+=2)
	{
		dur+=ptr[1];				/* this byte's absolute time */
		n= dur%quant;
		n= n<quant/2 ? dur-n : dur-n+quant ;
		n-= count;					/* relative to beat 0 */
		if (n<0) n=0;
		ptr[1]= n-i;				/* quantized delta time */
		i=n;
	}

	dur=0;
	n=0;
	for (i=0,ptr=recstart; (i<NCHD)&&(ptr<rectail);)
	{
		c= *ptr++;				/* status byte */
		dur += *ptr++;			/* its time stamp */
		if (c==0xff) continue;	/* NOP */
		if (c==0x90) on=1;
		if (c==0x80) on=0;
		if ((c==0x80)||(c==0x90)) ptr+=2;	/* skip note # and its time stamp */
		if (!(*ptr++)) on=0;		/* velocity 0 means note off */
		ptr++;						/* skip velocity time stamp */
		if (on) n++; else n--;	/* # of notes currently on */
		switch (n)
		{
			case 0:					/* end of chord: enter note from before it */
			if (!on)
			{
				if (dur<quant)
				{
					ptr[1]-=(quant-dur);
					if (ptr[1]<0) ptr[1]=0;
					dur=quant;
				}
				dur= dur/12 - 1;
				if (dur>31)
				{
					form_alert(1,BADRECDUR);
					i=0;
					goto exit;
				}
				vals[i]= dur;
				ntrst[i++]=1;
				dur=0;
			}
			break;

			case 1:					/* start of chord: enter rest from before it */
			if (dur&&on)
			{
				do
				{
					vals[i]= min(31,dur/12-1);
					dur-= 12*(vals[i]+1);
					ntrst[i++]=0;
				}
				while (dur&&(i<NCHD));
			}
		}	/* end switch (n) */
	}

exit:
	*end_col= i? i-1 : 0 ;
	/* round up to integral # beats, by adding a rest (if necessary) */
	for (i=n=0; i<=(*end_col); i++) n+= (vals[i]+1);
	if ( (n%=8) && ( *end_col < (NCHD-1) ) )
	{
		n= 8-n;
		i= *end_col + 1;
		ntrst[i]=0;
		vals[i]= n-1;
		*end_col= i;
	}
	for (i= *end_col+1; i<NCHD; i++) { vals[i]=7; ntrst[i]=1; }

}	/* end r_extract() */

/* transpose one column of a pitch pattern ..................................*/

transpose(amt,notefield,notebase)
int amt;
int *notefield;
char *notebase;
{
	register unsigned int n;
	register int j;

	n= *notefield;
	if (amt==(-1))
	{
		if (BITTEST(15,n)) return;		/* don't allow shift out */
		*notefield= n<<1;
	}
	if (amt==1)
	{
		if (BITTEST(0,n)) return;		/* don't allow shift out */
		*notefield= n>>1;
	}
	*notebase= transp_it(*notebase,amt);
}	/* end transpose() */

transp_it(val,amt)
int val,amt;
{
	val += amt;
	if (val<0)
	{
		if (amt==(-1))
			val+=128;
		else
			val+=132;
		if (val>127) val-=12;
	}
	if (val>127)
	{
		if (amt==1)
			val-=128;
		else
			val-=132;
		if (val<0) val+=12;
	}
	return(val);
}	/* end transp_it() */

/* EOF edpedr.c */
