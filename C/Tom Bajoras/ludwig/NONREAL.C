/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

                        Copyright 1988 Hybrid Arts, Inc.
								 
	module:	NONREAL -- non-real-time editing

	ex_init, ex_velmap, ex_copy, ex_fill, ex_scales, ex_tempo, ex_tracks
	ex_tsync, ex_thru, ex_patches, send_patches

	def_seq1, def_nonr1, def_master, def_pitch1, def_rhyth1

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
int trakobj[NSEQ]= { TRAKINF1,TRAKINF2,TRAKINF3,TRAKINF4,
							TRAKINF5,TRAKINF6,TRAKINF7,TRAKINF8 };
#define TRK_NAME 1
#define TRK_MUTE 2
#define TRK_CHAN 3
#define TRK_PLEX 4
#define TRK_LEGA 5
#define TRK_PACH 7
#define TRK_SEND 8
#define TRK_MESH 9

/* initialize parameters ....................................................*/

ex_init()
{
	char *titlptr,*fnameptr;
	register int i,j;
	int n_init;

	/* text fields */
	titlptr= ((TEDINFO*)(ldsvaddr[LDSVTITL].ob_spec))->te_ptext;
	fnameptr= ((TEDINFO*)(ldsvaddr[LDSVFILE].ob_spec))->te_ptext;
	strcpy(titlptr,INIT_MSG);	/* dialog box top line */
	fnameptr[0]=0;					/* dialog box second line: nothing */

	/* enable and select all buttons */
	for (i=0; i<NSEG; i++)
	{
		ldsvaddr[ldsvobj[i]].ob_state &= ~DISABLED;
		ldsvaddr[ldsvobj[i]].ob_state |= SELECTED;
	}

	if (do_ldsv()==OKLDSV)
	{
		/* initialize and display the selected data segments */
		for (i=n_init=0; i<NSEG; i++)
		{
			if ( ldsvaddr[ldsvobj[i]].ob_state & SELECTED )
			{
				n_init++;
				def_seg(i);
			}	/* end if data segment selected */
		}	/* end for all data segments */
		if (n_init)
		{
		/* copy initialized parameters into global variables */
			menu_icheck(menuaddr,LUSYNC,masterdata[M_SYNC]);
			menu_icheck(menuaddr,LUPATCH,masterdata[M_PATCH]);
			menu_icheck(menuaddr,LU_LINK,masterdata[M_LINK]);
			midithru= masterdata[M_THRUON];
			thruchan= masterdata[M_THRUCHON] ? masterdata[M_THRUCHAN]-1 : -1 ;
			if (midiplex>=0) thruport= masterdata[M_PLEXER];
		/* re-display screen */
			draw_screen();
		/* initialize name, if initialized all segments */
			if (n_init==NSEG)
			{
				strcpy(songname,INITNAME);
				disp_name();
			}
		}	/* end if initialized anything */
	}	/* end if OK from dialog box */
}	/* end ex_init() */

/* default parameters .......................................................*/

def_seg(i)
register int i;
{
	register int j;

	switch (i)
	{
		case NSEQ:
		for (j=0; j<NSEQ; j++) def_nonr1(j,nonr1data[j]);
		break;

		case NSEQ+1:
		def_master(masterdata);
		break;

		case NSEQ+2:
		for (j=0; j<NGRP; j++) def_pitch1(pitch1data[j]);
		break;

		case NSEQ+3:
		for (j=0; j<NGRP; j++) def_rhyth1(rhyth1data[j]);
		break;

		default:
		def_seq1(i,seqdata + SEQ1LENG*i);
	}	/* end switch */
}	/* end def_seg() */

def_seq1(seq,cptr)
int seq;
register char *cptr;
{
	register int i;

	set_bytes(cptr,(int)SEQ1LENG,0);				/* clear out unused */
	for (i=2; i<2*NCELL; i+=2) cptr[S_PSERIES+i]= cptr[S_RSERIES+i]= 2;
	cptr[S_PSERIES+1]= cptr[S_RSERIES+1]= 10*seq;
	set_bytes(cptr+S_VSERIES,NPERPAGE,4);		/* velocity series = all mf */
	cptr[S_VOPTS+S_VTIME]=7;						/* step size = quarter note */
	cptr[S_VOPTS+S_VATON]=12;						/* no accent or un-accent */
	cptr[S_VOPTS+S_VUTON]=12;
	cptr[S_VOPTS+S_VADUR]=32;
	cptr[S_VOPTS+S_VUDUR]=32;
}	/* end def_seq1() */

def_nonr1(seq,cptr)
int seq;
register char *cptr;
{
	set_bytes(cptr,(int)NONR1LENG,0);			/* clear out unused */
	copy_bytes(maj_scale,cptr+N_SCALE,12);		/* major scale (tonic=0 = C) */
	copy_bytes(def_velmap,cptr+N_VELMAP,8);	/* default velocity map */
	*(int*)(cptr+N_LEGATO)= 95;
	*(int*)(cptr+N_MIDICH) = seq;					/* midi channel = seq # */
	cptr[N_VWHICH]=1;				/* attack velocity mapped */
	cptr[N_VDEFAT]= cptr[N_VDEFRL]= MIDDLE_V;
	cptr[N_ACCENT]= 10;		/* accent */
	cptr[N_MUTE]=1;			/* mute */
	cptr[N_PSYNCTRK]=	cptr[N_RSYNCTRK]= (-1);	/* no sync */
	cptr[N_PATCH]= -1;		/* no patch */
}	/* end def_nonr1() */

def_master(cptr)
register char *cptr;
{
	register int i;

	set_bytes(cptr,(int)MASTERLENG,0);	/* clear out unused */
	cptr[M_TEMPO]=72;							/* 120 BPM */
	for (i=0; i<NWIND; i++)
	{
		wind_seq[i]= i;	/* these are actually pointers into masterdata */
		wind_type[i]= P_TYPE;
	}
}	/* end def_master() */

def_pitch1(cptr)
char *cptr;
{
	set_bytes(cptr,(int)PITCH1LENG,0);			/* clear out unused */
	strcpy(cptr+P_NAME,INIT_PNAME);				/* initialize name */
	set_bytes(cptr+P_NTREF,NCHD,MIDDLE_C);		/* note base */
}	/* end def_pitch1() */

def_rhyth1(cptr)
char *cptr;
{
	set_bytes(cptr,(int)RHYTH1LENG,0);		/* clear out unused */
	strcpy(cptr+R_NAME,INIT_RNAME);			/* initialize name */
	set_words(cptr+R_DUR,NCHD,7);				/* all quarter notes */
	set_bytes(cptr+R_NTRST,NCHD,1);
}	/* end def_rhyth1() */

/* MIDI thru ................................................................*/

ex_thru()
{
	char *thruptr,*plexptr;
	register int temp;
	int exit_obj,edit_obj,mstate,done;

	thruptr= ((TEDINFO*)(thruaddr[THRUCHAN].ob_spec))->te_ptext;
	strcpy(thruptr,int2char[masterdata[M_THRUCHAN]+1]);
	if (masterdata[M_THRUON])
		thruaddr[THRUON].ob_state |= SELECTED ;
	else
		thruaddr[THRUON].ob_state &= ~SELECTED ;
	if (masterdata[M_THRUCHON])
		thruaddr[THRUCHON].ob_state |= SELECTED ;
	else
		thruaddr[THRUCHON].ob_state &= ~SELECTED ;
	plexptr= thruaddr[THRUPLEX].ob_spec;
	plexptr[0]= midiplex>=0 ? 'A' + masterdata[M_PLEXER] : ' ' ;

	edit_obj=THRUCHAN;
	putdial(thruaddr,1,0);
	done=0;
	do
	{
		exit_obj= my_form_do(thruaddr,&edit_obj,&mstate);
		if (exit_obj==OKTHRU)
		{	
			temp= atoi(thruptr);
			if ((temp<1)||(temp>16))
			{
				thruaddr[OKTHRU].ob_state &= ~SELECTED;
				draw_object(thruaddr,OKTHRU);
				form_alert(1,BADMIDICH);
			}
			else
			{
				midithru= masterdata[M_THRUON]=
													thruaddr[THRUON].ob_state & SELECTED ;
				masterdata[M_THRUCHON]= thruaddr[THRUCHON].ob_state & SELECTED ;
				masterdata[M_THRUCHAN]= temp-1;
				thruchan= masterdata[M_THRUCHON] ? temp-1 : -1 ;
				done=1;
			}
			if (midiplex>=0) thruport= plexptr[0]-'A';
		}
		else
		{
			if (midiplex>=0)
			{
				temp= masterdata[M_PLEXER]+mstate;
				if (temp<0) temp=3;
				if (temp>3) temp=0;
				masterdata[M_PLEXER]=temp;
				plexptr[0]= 'A'+temp;
				draw_object(thruaddr,THRUPLEX);
			}
		}
		waitmouse();
	}
	while (!done);
	putdial(0L,0,exit_obj);

}	/* ex_thru() */

/* toggle patches option, send patches ......................................*/

ex_patches()
{
	register int temp;

	temp= masterdata[M_PATCH]= !masterdata[M_PATCH];
	menu_icheck(menuaddr,LUPATCH,temp);
	if (temp) send_patches();

}	/* end ex_patches() */

/* send all patches .........................................................*/

send_patches()
{
	register int i,j,temp;

	for (i=0; i<NSEQ; i++)
	{
		temp= nonr1data[i][N_PLEXER];
		j= nonr1data[i][N_PATCH];
		if (j>=0)
		{
			tran_byte(0xC0 | *(int*)(nonr1data[i]+N_MIDICH) , temp);
			tran_byte(j,temp);
		}
	}
}	/* end send_patches() */

/* edit master tempo ........................................................*/

ex_tempo()
{
	int edit_obj,exit_obj,done,mstate;
	int xdot;
	unsigned int tempo;

	/* copy current value into dialog box */
	tempo= masterdata[M_TEMPO];
	tempotoa(tempo,tempaddr[TEMPTEMP].ob_spec);
	
	putdial(tempaddr,1,0);

	objc_offset(tempaddr,TEMPTEMP,&xdot,&dummy);
	xdot+=24;
	edit_obj= (-1);
	done=0;
	do
	{
		exit_obj= my_form_do(tempaddr,&edit_obj,&mstate);
		if (exit_obj==TEMPTEMP)
		{
			if (*Mousex < xdot) mstate*=8;
			tempo-=mstate;
			if (tempo<MINTEMPO) tempo += NTEMPO-MINTEMPO;
			if (tempo>=NTEMPO) tempo -= NTEMPO-MINTEMPO;
			tempotoa(tempo,tempaddr[TEMPTEMP].ob_spec);
			draw_object(tempaddr,TEMPTEMP);
			mouserepeat();
		}	/* end switch */
		else
			done=1;
	}
	while (!done);
	waitmouse();
	putdial(0L,0,exit_obj);
	masterdata[M_TEMPO] = tempo;
}	/* end ex_tempo() */

/* edit velocity maps .......................................................*/

ex_velmap()
{
	static int seq;
	int edit_obj,exit_obj,mstate,done,error;

	/* copy current values to dialog box */
	set_velmap(seq);

	putdial(veloaddr,1,0);

	edit_obj= VELMAP0;
	done=0;
	do
	{
		do
		{
			exit_obj= my_form_do(veloaddr,&edit_obj,&mstate);
			waitmouse();	/* don't allow mouse repeat */
			error= unset_velmap(seq);
			if ( error && (exit_obj==VELEXIT) )
			{
				veloaddr[VELEXIT].ob_state &= ~SELECTED;
				draw_object(veloaddr,VELEXIT);
			}
			if (error==1) form_alert(1,BADVEL);
			if (error==2) form_alert(1,BADACCNT);
		}
		while (error);

		if ( exit_obj == VELEXIT )
			done=1;
		else				/* VELSEQ */
		{
			seq += mstate;
			if (seq<0) seq += NSEQ;
			if (seq>=NSEQ) seq -= NSEQ;
			set_velmap(seq);
			draw_object(veloaddr,0);
		}
	}
	while (!done);
	putdial(0L,0,exit_obj);

}	/* end ex_velmap() */

set_velmap(seq)
int seq;
{
	register int i,temp;
	char *ptr;
	static int teds[3]= { VELACCNT, VELDEFAT, VELDEFRL } ;
	static int vels[3]= { N_ACCENT, N_VDEFAT, N_VDEFRL } ;
	char charbuf[2];

	strcpy(veloaddr[VELSEQ].ob_spec,TRK_MSG);
	charbuf[0]='1'+seq;
	charbuf[1]= 0;
	strcat(veloaddr[VELSEQ].ob_spec,charbuf);

	for (i=0; i<8; i++)
	{
		ptr= ((TEDINFO*)(veloaddr[VELMAP0+i].ob_spec))->te_ptext;
		temp= nonr1data[seq][N_VELMAP+i];
		strcpy(ptr,int1char[temp/100]);
		strcpy(ptr+1,int2char[temp%100]);
	}

	for (i=0; i<3; i++)
	{
		ptr= ((TEDINFO*)(veloaddr[teds[i]].ob_spec))->te_ptext;
		temp= nonr1data[seq][vels[i]];
		strcpy(ptr,int1char[temp/100]);
		strcpy(ptr+1,int2char[temp%100]);
	}

	if (BITTEST(0,nonr1data[seq][N_VWHICH]))
		veloaddr[VELATTAC].ob_state |= SELECTED;
	else
		veloaddr[VELATTAC].ob_state &= ~SELECTED;
	if (BITTEST(1,nonr1data[seq][N_VWHICH]))
		veloaddr[VELRELEA].ob_state |= SELECTED;
	else
		veloaddr[VELRELEA].ob_state &= ~SELECTED;

}	/* end set_velmap() */

unset_velmap(seq)	/* returns: 0 ok, 1 bad velocity, 2 bad accent */
int seq;
{
	register int i,temp;
	char *ptr;
	static int teds[3]= { VELACCNT, VELDEFAT, VELDEFRL } ;
	static int vels[3]= { N_ACCENT, N_VDEFAT, N_VDEFRL } ;

	for (i=0; i<8; i++)
	{
		ptr= ((TEDINFO*)(veloaddr[VELMAP0+i].ob_spec))->te_ptext;
		temp= atoi(ptr);
		if ((temp<1)||(temp>127)) return(1);
		nonr1data[seq][N_VELMAP+i] = temp;
	}

	for (i=0; i<3; i++)
	{
		ptr= ((TEDINFO*)(veloaddr[teds[i]].ob_spec))->te_ptext;
		temp= atoi(ptr);
		if (i)
		{
			if ((temp<1)||(temp>127)) return(1);
		}
		else
		{
			if ((temp<0)||(temp>126)) return(2);
		}
		nonr1data[seq][vels[i]] = temp;
	}

	nonr1data[seq][N_VWHICH]= 0;
	if (veloaddr[VELATTAC].ob_state & SELECTED)
		nonr1data[seq][N_VWHICH]= 1;

	if (veloaddr[VELRELEA].ob_state & SELECTED)
		nonr1data[seq][N_VWHICH] |= 2;

	return(0);
}	/* end unset_velmap() */

/* copy sequence real-time parameters (in non-real-time) ....................*/

ex_copy()
{
	register int i,j,k;
	int wind;
	static int off1[NTYPE]= { S_PSERIES, S_RSERIES, S_VSERIES } ;
	static int len1[NTYPE]= { 2*NCELL, 2*NCELL, 32 } ;
	static int off2[NTYPE]= { S_PRAND,   S_RRAND,   S_VOPTS } ;
	static int len2[NTYPE]= { 40, 40, 64 } ;

	do_dial(copyaddr,-1);

	i=	which_rbutton(copyaddr,NSEQ,FROMSEQA);
	for (j=0; j<NSEQ; j++)
	{
		if ( copyaddr[TOSEQA+j].ob_state & SELECTED )
		{
			for (k=0; k<NTYPE; k++)
			{
				if (copyaddr[COPYTYPE+k].ob_state & SELECTED)
				{
					copy_bytes(seq1data[i]+off1[k],seq1data[j]+off1[k],len1[k]);
					copy_bytes(seq1data[i]+off2[k],seq1data[j]+off2[k],len2[k]);
					wind= get_wind(j,k);
					if (wind>=0) disp_window(wind);
				}
			}
		}
	}
}	/* end ex_copy() */

/* fill a series ............................................................*/

ex_fill()
{
	register char *ptr;
	register int i,wind,seq;
	int type,to,start,operator,operand;

	if (do_dial(filladdr,-1)==CANFILL) return;

	type=	which_rbutton(filladdr,2,FILLTYPE);			/* P or R */
	to=	which_rbutton(filladdr,2,FILLTO);			/* fill up to where */

	for (seq=0; seq<NSEQ; seq++)
	{
		if (filladdr[FILLTRK1+seq].ob_state & SELECTED )
		{
			wind=get_wind(seq,type);
			if (wind>=0)
			{
				ptr= seq1data[seq];
				ptr += ( type ? S_RSERIES : S_PSERIES ) ;
				start= wind_start[wind];
				to= to ? NCELL : start+NPERPAGE ;
				ptr += 2*start;
				operator= ptr[0];
				operand=  ptr[1];
				for (i=start; i<to; i++)
				{
					*ptr++= operator;
					*ptr++= operand;
				}
				disp_window(wind);
			}
		}
	}
}	/* end ex_fill() */

/* edit scales ..............................................................*/

ex_scales()
{
	int edit_obj,done,exit_obj,mstate,obj1,obj2;
	register int i,j,k;
	static int seq;		/* scale for which sequence */
	char alertstr[80];
	char *from_ptr,*to_ptr;

	/* copy current values into dialog box  */
	set_scale(seq);

	putdial(scaladdr,1,0);

	edit_obj= (-1);
	done=0;
	do
	{
		exit_obj= my_form_do(scaladdr,&edit_obj,&mstate);
		waitmouse();	/* don't allow mouse repeat */
		i=(-1);
		switch (exit_obj)
		{
			case KEYEXIT:
			done=1;
			break;

			case KEYMAJOR:
			case KEYMINOR:
			copy_bytes(exit_obj==KEYMAJOR ? maj_scale : min_scale,
				nonr1data[seq]+N_SCALE,12);	/* preset scale */
			set_scale(seq);
			draw_object(scaladdr,KEYBOX);
			break;

			case KEYSHARP:
			case KEYFLAT:
			nonr1data[seq][N_ACCID]= exit_obj==KEYFLAT;
			set_scale(seq);
			draw_object(scaladdr,KEYBOX);
			break;

			case COPYSCAL:
			from_ptr= ((TEDINFO*)(scaladdr[FROMSCAL].ob_spec))->te_ptext ;
			to_ptr= ((TEDINFO*)(scaladdr[TO_SCAL].ob_spec))->te_ptext ;
			i= atoi(from_ptr);
			j= atoi(to_ptr);
			if ( (i>=1) && (i<=8) && (j>=1) && (j<=8) )
			{
				i--; j--;
				if (i!=j)
				{
					strcpy(alertstr,CHEKSFRM);
					strcat(alertstr,from_ptr);
					strcat(alertstr,CHEKSTO);
					strcat(alertstr,to_ptr);
					strcat(alertstr,CHEKYESNO);
					if (form_alert(1,alertstr)==1)
					{
						nonr1data[j][N_TONIC]= nonr1data[i][N_TONIC];
						nonr1data[j][N_ACCID]= nonr1data[i][N_ACCID];
						copy_bytes(nonr1data[i]+N_SCALE,nonr1data[j]+N_SCALE,12);
						if (j==seq)
						{
							set_scale(seq);
							draw_object(scaladdr,KEYBOX);
						}
					}
				}
			}
			else
				form_alert(1,BADSCLN);
			break;

			case KEYSEQ:
			seq+=mstate;
			if (seq<0) seq += NSEQ;
			if (seq>=NSEQ) seq -= NSEQ;
			set_scale(seq);
			draw_object(scaladdr,KEYSEQ);
			draw_object(scaladdr,KEYBOX);
			break;

			default:
			for (j=0; j<12; j++) if (exit_obj==(TONIC+j)) break;
			if (!j)		/* transpose */
			{
				k= nonr1data[seq][N_TONIC] + mstate;
				if (k>11) k=0;
				if (k<0) k=11;
				nonr1data[seq][N_TONIC]=k;
				set_scale(seq);
				draw_object(scaladdr,KEYBOX);
			}
			else
			{
				obj1=obj2=(-1);	/* what needs to be redrawn */
				k= Kbshift(-1)&LRSHIFT;
				switch (nonr1data[seq][N_SCALE+j])
				{
					case 0:
					if (k)
					{
						if ( nonr1data[seq][N_SCALE+j-1]<1 )
						{
							nonr1data[seq][N_SCALE+j]=(-1);
							obj1=j;
						}
						break;
					}
					if ( (mstate<0) && nonr1data[seq][N_SCALE+j-1] )
					{
						nonr1data[seq][N_SCALE+j]=(-1);
						nonr1data[seq][N_SCALE+j-1]=0;
						obj1= j-1;		obj2=j;
					}
					if ( (mstate>0) && (j<11) && nonr1data[seq][N_SCALE+j+1] )
					{
						nonr1data[seq][N_SCALE+j]=1;
						nonr1data[seq][N_SCALE+j+1]=0;
						obj1=j;			obj2= j+1;
					}
					break;

					case 1:
					if (k)
					{
						nonr1data[seq][N_SCALE+j]=0;
						obj1=j;
						break;
					}
					if ( nonr1data[seq][N_SCALE+j-1] <= 0 )
					{
						nonr1data[seq][N_SCALE+j]=(-1);
						obj1=j;
					}
					break;

					case -1:
					if (k)
					{
						nonr1data[seq][N_SCALE+j]=0;
						obj1=j;
						break;
					}
					if ( (j<11) && (nonr1data[seq][N_SCALE+j+1] >= 0) )
					{
						nonr1data[seq][N_SCALE+j]=1;
						obj1=j;
					}
				}	/* end switch */
				set_scale(seq);
				if (obj1>=0) draw_object(scaladdr,TONIC+obj1);
				if (obj2>=0) draw_object(scaladdr,TONIC+obj2);
			}
		}	/* end switch */
	}
	while (!done);
	putdial(0L,0,exit_obj);

}	/* end ex_scales() */

set_scale(seq)
register int seq;
{
	register int j,k;
	static char negastr[2]= { 4,0 };
	static char plusstr[2]= { 3,0 };
	char charbuf[2];

	charbuf[0]='1'+seq;
	charbuf[1]=0;
	strcpy(scaladdr[KEYSEQ].ob_spec,charbuf);

	for (j=0,k=nonr1data[seq][N_TONIC]; j<12; j++,k=(++k)%12)
	{
		switch ( nonr1data[seq][N_SCALE+j] )
		{
			case 0:
				scaladdr[TONIC+j].ob_spec=
					nonr1data[seq][N_ACCID] ? chromaf[k] : chromas[k] ;
				break;
			case -1:
				scaladdr[TONIC+j].ob_spec= negastr;
				break;
			case 1:
				scaladdr[TONIC+j].ob_spec= plusstr;
		}
	}
}	/* end set_scale() */

/* tracks summary ...........................................................*/

ex_tracks()
{
	static int trakthru,trakplex;
	register int i,j;
	char charbuf[3];
	char *plexptr;
	int done,edit_obj,exit_obj,mstate;
	int legax,patchx,x;
	int savethru,savechan,saveport;

	/* copy current values into dialog box */
	strcpy(trakaddr[TRAKTHRU].ob_spec,int2char[trakthru+1]);
	plexptr= trakaddr[TRAKPLEX].ob_spec;
	plexptr[0]= midiplex>=0 ? 'A'+trakplex : ' ' ;
	savethru=midithru;	savechan=thruchan;		saveport=thruport;
	midithru=1;				thruchan=trakthru;		thruport=trakplex;
	draw_summary();

	putdial(trakaddr,1,0);
	objc_offset(trakaddr,trakobj[0]+TRK_LEGA,&legax,&dummy);  legax+=8;
	objc_offset(trakaddr,trakobj[0]+TRK_PACH,&patchx,&dummy);  patchx+=16;

	edit_obj= trakobj[0]+TRK_NAME;
	done=0;
	do
	{
		exit_obj= my_form_do(trakaddr,&edit_obj,&mstate);
		x= *Mousex;		/* mouse x-coord needed for digit-by-digit edit */
		switch (exit_obj)
		{
			case TRAKEXIT:
			done=1;
			break;

			case TRAKTHRU:
			trakthru+=mstate;
			if (trakthru<0) trakthru=15;
			if (trakthru>15) trakthru=0;
			thruchan=trakthru;
			strcpy(trakaddr[TRAKTHRU].ob_spec,int2char[trakthru+1]);
			draw_object(trakaddr,TRAKTHRU);
			waitmouse();
			break;

			case TRAKPLEX:
			if (midiplex>=0)
			{
				trakplex+=mstate;
				if (trakplex<0) trakplex=3;
				if (trakplex>3) trakplex=0;
				plexptr[0]= 'A'+trakplex;
				thruport=trakplex;
				draw_object(trakaddr,TRAKPLEX);
			}
			waitmouse();
			break;

			default:

			for (i=0; i<(NSEQ-1); i++) if (exit_obj<trakobj[i+1]) break;
			switch (exit_obj-trakobj[i])
			{
				case TRK_MUTE:
				if (mstate<0)		/* mute/un-mute */
				{
					nonr1data[i][N_MUTE]= !nonr1data[i][N_MUTE] ;
					charbuf[1]=0;
					charbuf[0]= nonr1data[i][N_MUTE] ? 1 : 2 ;
					i= trakobj[i]+TRK_MUTE;
					strcpy(trakaddr[i].ob_spec,charbuf);
					draw_object(trakaddr,i);
				}
				else					/* solo/un-solo */
				{
					mstate= !nonr1data[i][N_MUTE];
					for (j=0; j<NSEQ; j++)
					{
						if ( (j!=i) && (nonr1data[j][N_MUTE]!=mstate) )
						{
							nonr1data[j][N_MUTE]=mstate;
							charbuf[1]=0;
							charbuf[0]= nonr1data[j][N_MUTE] ? 1 : 2 ;
							asm { move.w i,-(a7) }
							i= trakobj[j]+TRK_MUTE;
							strcpy(trakaddr[i].ob_spec,charbuf);
							draw_object(trakaddr,i);
							asm { move.w (a7)+,i }
						}
					}
				}
				waitmouse();
				break;

				case TRK_CHAN:
				j= *(int*)(nonr1data[i]+N_MIDICH);
				j += mstate;
				if (j<0) j+=16;
				if (j>15) j-=16;
				*(int*)(nonr1data[i]+N_MIDICH) = j;
				i= trakobj[i]+TRK_CHAN;
				strcpy(trakaddr[i].ob_spec,int2char[j+1]);
				draw_object(trakaddr,i);
				waitmouse();
				break;
		
				case TRK_PLEX:
				if (midiplex>=0)
				{
					j= nonr1data[i][N_PLEXER] + mstate;
					if (j<0) j=3;
					if (j>3) j=0;
					nonr1data[i][N_PLEXER]= j;
					charbuf[0]= j+'A';
					charbuf[1]=0;
					i= trakobj[i]+TRK_PLEX;
					strcpy(trakaddr[i].ob_spec,charbuf);
					draw_object(trakaddr,i);
				}
				waitmouse();
				break;

				case TRK_LEGA:
				j= *(int*)(nonr1data[i]+N_LEGATO);
				if (x<legax) mstate*=10;
				j += mstate;
				if (j<0) j+=100;
				if (j>99) j-=100;
				if ( !j && (mstate<0) ) j=99;
				if ( !j && (mstate>0) ) j=1;
				*(int*)(nonr1data[i]+N_LEGATO) = j;
				i= trakobj[i]+TRK_LEGA;
				strcpy(trakaddr[i].ob_spec,int2char[j]);
				draw_object(trakaddr,i);
				waitmouse();
				break;

				case TRK_PACH:
				j= nonr1data[i][N_PATCH];
				if (x<patchx) mstate*=10;
				j += mstate;
				if (j<-1) j+=129;
				if (j>127) j-=129;
				nonr1data[i][N_PATCH] = j;
				j++;
				i= trakobj[i]+TRK_PACH;
				if (j)
				{
					strcpy(trakaddr[i].ob_spec,int1char[j/100]);
					strcat(trakaddr[i].ob_spec,int2char[j%100]);
				}
				else
					strcpy(trakaddr[i].ob_spec,"---");
				draw_object(trakaddr,i);
				waitmouse();
				break;

				case TRK_SEND:
				j= nonr1data[i][N_PATCH];
				if (j>=0)
				{
					x= nonr1data[i][N_PLEXER];
					tran_byte( 0xC0|(*(int*)(nonr1data[i]+N_MIDICH)) , x );
					tran_byte(j,x);
				}
				waitmouse();
				break;

				case TRK_MESH:
				j= (nonr1data[i][N_MESH] = !nonr1data[i][N_MESH]);
				i= trakobj[i]+TRK_MESH;
				strcpy(trakaddr[i].ob_spec,yesnochar[j]);
				draw_object(trakaddr,i);
				waitmouse();

			}	/* end switch */
		}
	}
	while (!done);
	waitmouse();
	putdial(0L,0,exit_obj);

	/* update the names */
	for (i=0; i<NSEQ; i++)
		strcpy( nonr1data[i]+N_NAME ,
			((TEDINFO*)(trakaddr[trakobj[i]+TRK_NAME].ob_spec))->te_ptext ) ;

	thruchan=savechan;
	midithru=savethru;
	thruport=saveport;

}	/* end ex_tracks() */

/* set up objects in trakaddr ...............................................*/

draw_summary()
{
	register int i,j,t;
	char *charptr;

	for (i=0; i<NSEQ; i++)
	{
		t= trakobj[i];

		/* names */
		strcpy( ((TEDINFO*)(trakaddr[t+TRK_NAME].ob_spec))->te_ptext ,
					nonr1data[i]+N_NAME ) ;

		/* mutes */
		trakaddr[t+TRK_MUTE].ob_spec[0]=
			nonr1data[i][N_MUTE] ? 1 : 2 ;

		/* midi channel */
		strcpy(trakaddr[t+TRK_CHAN].ob_spec,
					int2char[*(int*)(nonr1data[i]+N_MIDICH)+1]);
		
		/* midiplexer port */
		trakaddr[t+TRK_PLEX].ob_spec[0]=
			midiplex>=0 ? 'A' + nonr1data[i][N_PLEXER] : ' ' ;

		/* legato percentage */
		strcpy(trakaddr[t+TRK_LEGA].ob_spec,
					int2char[*(int*)( nonr1data[i] + N_LEGATO )]);

		/* patch #s */
		charptr= trakaddr[t+TRK_PACH].ob_spec;
		if (j=nonr1data[i][N_PATCH]+1)
		{
			strcpy(charptr,int1char[j/100]);
			strcat(charptr,int2char[j%100]);
		}
		else
			strcpy(charptr,"---");

		/* meshing */
		strcpy(trakaddr[t+TRK_MESH].ob_spec,yesnochar[nonr1data[i][N_MESH]]);
	}
}	/* end draw_summary() */

/* synchronize tracks .......................................................*/

ex_tsync()
{
	int edit_obj,exit_obj,done,mstate;
	static char *synctrak[NSEQ+1]=
	{ "NONE", "1", "2", "3", "4", "5", "6", "7", "8" } ;
	static char *synctype[2]= { "Pitch", "Rhythm" };
	register int i,j,trk,type;

	/* copy current values into dialog box */
	for (i=0; i<2*NSEQ; i+=2)
	{
		strcpy(syncaddr[SYNCTRAK+i].ob_spec,
				 synctrak[nonr1data[i/2][N_PSYNCTRK]+1]);
		strcpy(syncaddr[SYNCTRAK+i+1].ob_spec,
				 synctrak[nonr1data[i/2][N_RSYNCTRK]+1]);
		strcpy(syncaddr[SYNCTYPE+i].ob_spec,
				 synctype[nonr1data[i/2][N_PSYNCTYP]]);
		strcpy(syncaddr[SYNCTYPE+i+1].ob_spec,
				 synctype[nonr1data[i/2][N_RSYNCTYP]]);
	}
	
	putdial(syncaddr,1,0);

	edit_obj= (-1);
	done=0;
	do
	{
		exit_obj= my_form_do(syncaddr,&edit_obj,&mstate);
		if (exit_obj==SYNCEXIT)
			done=1;
		else
		{
			i= exit_obj-SYNCTRAK;
			if (i<2*NSEQ)
			{
				trk= i%2 ? N_RSYNCTRK : N_PSYNCTRK ;
				type= i%2 ? N_RSYNCTYP : N_PSYNCTYP ;
				/* anything slaved to this track and type? */
				for (j=0; j<NSEQ; j++)
				{
					if ( (nonr1data[j][N_PSYNCTRK]==i/2) &&
						  (nonr1data[j][N_PSYNCTYP]==i%2) ) break;
					if ( (nonr1data[j][N_RSYNCTRK]==i/2) &&
						  (nonr1data[j][N_RSYNCTYP]==i%2) ) break;
				}
				if (j==NSEQ)	/* can't edit it if it's a master */
				{
					j= nonr1data[i/2][trk];			/* what track are we sync'd to */
					type= nonr1data[i/2][type];	/* what type are we sync'd to */
					j+=mstate;
					if (j==NSEQ) j= -1;
					if (j<(-1)) j= NSEQ-1;
					/* can't sync it to a slave or to itself */
					while ( (j>=0)
							  && 
							  ( ((j==i/2)&&(type==i%2))
							  	 ||
								 (nonr1data[j][type ? N_RSYNCTRK : N_PSYNCTRK] >= 0)
							  )
							)
					{
						j+=mstate;
						if (j==NSEQ) j= -1;
						if (j<(-1)) j= NSEQ-1;
					}
					nonr1data[i/2][trk]=j;
					strcpy(syncaddr[exit_obj].ob_spec,synctrak[j+1]);
					draw_object(syncaddr,exit_obj);
				}
			}
			else
			{
				i= exit_obj-SYNCTYPE;
				trk= i%2 ? N_RSYNCTRK : N_PSYNCTRK ;
				type= i%2 ? N_RSYNCTYP : N_PSYNCTYP ;
				i /= 2;
				j= nonr1data[i][type];
				trk= nonr1data[i][trk];
				j= !j;
				if ( (trk<0) ||
					  (nonr1data[trk][j ? N_RSYNCTRK : N_PSYNCTRK] < 0 )
					)
				{
					nonr1data[i][type]=j;
					strcpy(syncaddr[exit_obj].ob_spec,synctype[j]);
					draw_object(syncaddr,exit_obj);
				}
			}
			waitmouse();
		}
	}
	while (!done);
	waitmouse();
	putdial(0L,0,exit_obj);

}	/* end ex_tsync() */
	
/* EOF nonreal.c */
