/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

                        Copyright 1988 Hybrid Arts, Inc.

	module: EVENT -- high-level user-interface

	do_menu, do_key, do_mouse, do_nonedit, do_edit, do_fakedial,
	do_playmouse, do_tagmouse, do_fillmode, link_edit

******************************************************************************/

overlay "event"

/* include header files .....................................................*/

#include <asm.h>				  /* needed for in-line assembly language */
#include "defines.h"         /* program-specific */
#include <gemdefs.h>         /* AES                  */
#include <obdefs.h>          /* more AES  */
#include <osbind.h>          /* GEMDOS, BIOS, XBIOS  */
#include "ludwig.h"          /* created by RCS       */

/* global variables .........................................................*/

#include "externs.h"
extern long _base;
int savelazy_x,savelazy_y;

/* handle menu command selected .............................................*/
/* returns 1= quit, 0= don't quit */

do_menu()
{
	int done=0;		/* default: don't quit */

	/* desk title must de-select BEFORE handling, else mouse interrupt can
		falsely detect an accessory running */
	if ((messbuf[4]==LUINFO)||(messbuf[4]==LUSWITCH)||
		 (messbuf[4]==LUPLAY)||(messbuf[4]==LUAGAIN) )
		if (!play_mode) menu_tnormal(menuaddr,messbuf[3],1);

	switch (messbuf[4])
	{
		case LUINFO:
		#if DEMOFLAG
			form_alert(1,DEMOMSG2);
		#else
			do_tongue();
		#endif
		break;

		case LULOAD:	ex_load();		break;
		case LUSAVE:	ex_save();		break;
		case LUSNG:		ex_sng();		break;
		case LUDRIVE:	ex_drive();		break;
		case LUDELETE:	ex_delete();	break;
		case LUFORMAT:	ex_format();	break;
		case LUSWITCH:	ex_switch(-1);	break;
		case LUQUIT:
			done= (play_safe&&play_buffer()) ? form_alert(2,CHEKQUIT)==1 : 1 ;
			/* tell switcher, quit for real */
			if (done) { asm { move.l _base(a4),a0		move.l #-1,8(a0) } }
			break;

		case LUPITCH:	ex_pitch();		break;
		case LURHYTHM:	ex_rhythm();	break;

		case LUSUMARY: ex_tracks();	break;
		case LUTSYNC:	ex_tsync();		break;
		case LUSCALES:	ex_scales();	break;
		case LUVELMAP:	ex_velmap();	break;
		case LUCOPY:	ex_copy();		break;
		case LUFILL:	ex_fill();		break;

		case LUSAFE:
			play_safe= !play_safe;
			menu_icheck(menuaddr,LUSAFE,play_safe);
			break;
		case LULAZY:
			lazy_mouse= !lazy_mouse;
			menu_icheck(menuaddr,LULAZY,lazy_mouse);
			break;
		case LUSYNC:
			masterdata[M_SYNC]= !masterdata[M_SYNC];
			menu_icheck(menuaddr,LUSYNC,masterdata[M_SYNC]);
			break;
		case LUPATCH:	ex_patches();	break;
		case LU_LINK:
			masterdata[M_LINK]= !masterdata[M_LINK];
			menu_icheck(menuaddr,LU_LINK,masterdata[M_LINK]);
			break;
		case LUTHRU:	ex_thru();		break;
		case LUTEMPO:  ex_tempo();		break;
		case LUPLAY:	ex_play();		break;
		case LUAGAIN:	ex_again();		break;
		case LUINIT:	ex_init();
	}

	/* deselect menu title */
	if ((messbuf[4]!=LUINFO)&&(messbuf[4]!=LUSWITCH)&&
		 (messbuf[4]!=LUPLAY)&&(messbuf[4]!=LUAGAIN) )
		if (!play_mode) menu_tnormal(menuaddr,messbuf[3],1);

	return(done);
}	/* end do_menu() */

/* handle key typed .........................................................*/

do_key(key,kstate)
int key;		/* high byte is scan code, low byte is ascii */
int kstate;
{
	int st;
	int scan,asci;
	register int i;
	int *cmds;
	long save_but,save_mot;
	int save_pause;

	scan= key >> 8;
	asci= key & 0x7f;

	switch ( editmode + 3*fillmode )
	{
		case 0:

		/* alt-function keys: switcher */
		if ( (kstate&ALT) && (scan>=0x3b) && (scan<=0x44) && sw_ptr )
			ex_switch(scan-0x3b);

		if (play_mode)
		{
			if (asci==9)		/* tab= toggle pause mode */
			{
				play_pause= !play_pause;
				if ( play_pause && (!(kstate&LRSHIFT)) )
					for (i=0; i<NSEQ; i++) seq_off(i);
				HIDEMOUSE;
				xortext(2,X_PAUSE,1);
				SHOWMOUSE;
			}
			if (scan==0x1c) do_playmouse(X_CLOSE);		/* return= exit play mode */
		}
		cmds= play_mode ? playkeycmds : keycmds ;
		for (i=0; cmds[i]; i+=4)
		{
			if ((scan==cmds[i])&&(kstate==cmds[i+1]))
			{
				messbuf[3]=cmds[i+2];
				messbuf[4]=cmds[i+3];
				if ( menuaddr[messbuf[4]].ob_state & DISABLED )
					return(0);
				else
				{
					if (play_mode)
					{
						save_pause= play_pause;
						if (!save_pause)
						{
							play_pause=1;
							for (i=0; i<NSEQ; i++) seq_off(i);
							HIDEMOUSE;
							xortext(2,X_PAUSE,1);
							SHOWMOUSE;
						}
					/* swap in normal butv/motv vectors */
						save_but= *(long*)(Abase-58L);
						save_mot= *(long*)(Abase-50L);
						*(long*)(Abase-58L)= save_butv;
						*(long*)(Abase-50L)= save_motv;
					}
					else
						menu_tnormal(menuaddr,messbuf[3],0);
					i=do_menu();
					if (play_mode)
					{
						asm { move.w i,-(a7) }
						i= midi_sync;
						set_play();
						if (midi_sync && !i)
						{
							nextclock=masterclock;
							tran_byte(MIDISTART);
						}
						asm { move.w (a7)+,i }
						if (!save_pause)
						{
							HIDEMOUSE;
							xortext(2,X_PAUSE,1);
							SHOWMOUSE;
							play_pause=0;
						}
						*(long*)(Abase-58L)= save_but;
						*(long*)(Abase-50L)= save_mot;
					}
					return(i);
				}
			}
		}

		break;

		case 1:

		st=0;
		if (scan==0x52) st=(-1);	/* <insert> */
		if (scan==0x47) st=1;		/* <clr/home> */
		if (st) end_edit(st);
		break;

		case 2:

		if (scan==0x1c) do_fakedial(0,0);	/* cancel fake dialog box */

	/* case 3:  no key commands in fill mode */

	}	/* end switch editmode+3*fillmode */

}	/* end do_key() */

/* handle mouse button clicked.............................................. */

do_mouse(mx,my,st)
int mx,my,st;	/* st= 1 left button, else right button */
{
	st= st==1 ? -1 : 1 ;	/* convert button to +/- 1 */

	switch ( editmode + 3*fillmode )
	{
		case 0:	do_nonedit(mx>>3,my,st); break;
		case 1:  do_edit(mx>>3,my,st);	 break;
		case 2:	do_fakedial(mx,my);		 break;
		case 3:	do_fillmode(mx>>3,my,st);
	}
	return(1);		/* prevent mouse button repeat */
}	/* end do_mouse() */

/* mouse button clicked, we're not in edit mode..............................*/

do_nonedit(mx,my,st)
int mx,my,st;
{
	register int wind,row,i;
	int type,start,seq,save_pause,kstate,operator,operand;
	int param;

	kstate=Kbshift(-1);

	if (my<wind_y[0])		/* clicked in menu bar */
	{
		if (play_mode) do_playmouse(mx,st);
		return;
	}

	if (mx<X_SERIES)	/* clicked in tag area: change window layout */
	{
		do_tagmouse(mx,my,st);
		return;
	}

	if (play_mode==2) return;	/* can't do anything else in play-again mode */

	/* what parameter was clicked on? */
	wind= find_wind(my);
	row= find_row(my,wind_y[wind]);
	if (row<0) return;
	type= wind_type[wind];
	start= wind_start[wind];
	seq= wind_seq[wind];
	param= find_param(mx,row,type);
	if (param<0) return;

	/* is it an operator or operand? */
	operator=operand=0;
	if ( ((type==P_TYPE)||(type==R_TYPE)) && (param<2*NPERPAGE) )
		if (param%2)
			operand=1;
		else
			operator=1;

	/* alt-click on operator or operand or velocity cell:  enter fill mode */
	if ( (kstate&ALT) &&
		  ( operator || operand || ((type==V_TYPE)&&(param<NPERPAGE)) )
		)
	{
		fillwind= wind;
		if (operand) param--;	/* use only operator */
		fillparnum= param;
		fillparam=	params[type][fillparnum];
		fill_y= wind_y[wind]+val_y[fillparam.row];
		HIDEMOUSE;
		xortext(fillparam.ncols,fillparam.col,fill_y);
		if (type!=V_TYPE) xortext(fillparam.ncols,fillparam.col,
										  fill_y2= wind_y[wind]+val_y[fillparam.row+1]);
		SHOWMOUSE;
		graf_mouse(FINGERMOUSE);
		fillmode=1;
		return;
	}

	/* control-click on operator:  insert or delete cell */
	if ( (kstate&CTRL) && operator )
	{
		param+=2*start;		/* cell # */
		insdel_it(seq,type,param,st);
		if (masterdata[M_LINK]) insdel_it(seq,!type,param,st);
		return;
	}

	editparam[0]= params[type][param];
	editptr[0]=	seq1data[seq] + editparam[0].offset;
	/* operator or operand must be offset by window start amount */
	if (operator || operand) editptr[0] += 2*start;
	editval[0]= editparam[0].nbytes>1 ? *(int*)(editptr[0]) : editptr[0][0] ;

	/* shift-click on operand of 'U' or '?': edit a pitch or rhythm pattern */
	if ( (kstate&LRSHIFT) && operand )
	{
		i= editptr[0][-1];
		if ((i==0)||(i==3))
		{
			save_pause= play_pause;
			if (play_mode && !play_pause)
			{
				play_pause=1;
				for (i=0; i<NSEQ; i++) seq_off(i);
				HIDEMOUSE;
				xortext(2,X_PAUSE,1);
				SHOWMOUSE;
			}
			edprchan= *(int*)(nonr1data[seq]+N_MIDICH);
			edpplex= edrtplex= nonr1data[seq][N_PLEXER];
			if (i=masterdata[M_LINK])
			{
				edrwith= edpwith= editval[0];
				type= R_TYPE;
			}
			i *= SELECTED ;
			edraddr[EDRLINK].ob_state = i;
			edpaddr[EDPLINK].ob_state = i;
			for (i=editval[0]; i>=0; type= type==P_TYPE ? R_TYPE : P_TYPE )
				i= type==R_TYPE ? edit_rhythm(i,rhythmdata+RHYTH1LENG*i) :
						  				edit_pitch( i, pitchdata+PITCH1LENG*i) ;
			if (!(Kbshift(-1)&LRSHIFT) && play_mode && !save_pause)
			{
				HIDEMOUSE;
				xortext(2,X_PAUSE,1);
				SHOWMOUSE;
				play_pause=0;
			}
			return;
		}
	}

	/* shift-click on operator: manually set a series computation pointer */
	if ( (kstate&LRSHIFT) && operator && play_mode )
	{
		if (type==P_TYPE)
		{

			px[seq]= param+2*start;
			pready[seq]=0;
		}
		else
		{
			rx[seq]= param+2*start;
			rready[seq]=0;
		}
		set_bytes(loopcnt + seq*2*NCELL + type*NCELL , NCELL , 0 );
		return;
	}

	editparnum[0]=param;
	editparnum[1]= -1;	/* default: no co-editing */
	editwind=wind;
	oldval[0]=editval[0];

	/* enter edit mode */
	HIDEMOUSE;
	if (editparam[0].dial<0)
	{
		edit_it(0,mx,st);
		gr_text(editparam[0].encode[editval[0]],editparam[0].col,
					i=wind_y[wind]+val_y[editparam[0].row]);
		if (editval[0]!=oldval[0])
		{
			xortext(editparam[0].ncols,editparam[0].col,i);
			editmode=1;
		/* set up co-editing !!! */
			if (operand)
			{
				editparam[1]=editparam[0];
				editptr[1]=editptr[0];
				editparnum[1]=editparnum[0];
				oldval[1]=oldval[0];
				editval[1]=editval[0];
				editparam[0]= params[type][editparnum[0]=editparnum[1]-1];
				editptr[0]=	seq1data[seq] + editparam[0].offset + 2*start;
				oldval[0]= editval[0]= editparam[0].nbytes>1 ? 
												*(int*)(editptr[0]) : editptr[0][0] ;
				xortext(editparam[0].ncols,editparam[0].col,
							wind_y[wind]+val_y[editparam[0].row]);
			}
		}
	}
	else
	{
	/* set up co-editing */
		if (operator)
		{
			editparam[1]= params[type][editparnum[1]=editparnum[0]+1];
			editptr[1]=	seq1data[seq] + editparam[1].offset + 2*start;
			oldval[1]= editval[1]= editparam[1].nbytes>1 ? *(int*)(editptr[1]) : 
																		editptr[1][0] ;
		}

		dialwind= editwind<2 ? 2 : 0 ;
		editmode=2;
		save_screen(1,wind_y[dialwind],
						dialwind ? 200*rez-1 : wind_y[dialwind+2] );
		draw_dial(editparam[0].dial,dialwind);
		if (lazy_mouse)
		{
			savelazy_x= *Mousex;
			savelazy_y= *Mousey;
			*Mousey= wind_y[dialwind];
		}
	}
	SHOWMOUSE;
}	/* end do_nonedit() */

insdel_it(seq,type,param,st)
int seq,type,param,st;
{
	register char *ptr;
	register int i;
		
	ptr= type==P_TYPE ? seq1data[seq]+S_PSERIES : seq1data[seq]+S_RSERIES ;
	if (st>0)
		for (i=param; i<(2*NCELL-2); i+=2)
		{
			ptr[i]=ptr[i+2];
			ptr[i+1]=ptr[i+3];
		}
	else
		for (i=2*NCELL-2; i>param; i-=2)
		{
			ptr[i]=	ptr[i-2];
			ptr[i+1]=ptr[i-1];
		}
	if (type==P_TYPE) pready[seq]=0; else rready[seq]=0;
	set_bytes(loopcnt + seq*2*NCELL + type*NCELL , NCELL , 0 );
	i= get_wind(seq,type);
	if (i<0) return;
	if (xorc_col[i]) outcurs(xorc_col[i],xorc_row[i]);
	xorc_col[i]=0;
	if (xorp_col[i]) outcurs(xorp_col[i],xorp_row[i]);
	xorp_col[i]=0;
	disp_window(i);
	if (play_mode)
		if (type==P_TYPE)
			move_xorp(seq,0,pxor_pp[seq]);
		else
			move_xorp(seq,1,pxor_rr[seq]);
}	/* end insdel_it() */

/* fill mode ................................................................*/

do_fillmode(mx,my,st)
int mx,my,st;
{
	int row,type,start,seq,param,fillval;
	int par1,par2;
	register int i;
	register char *fillptr;

	if (my<wind_y[0]) return;	/* clicked in menu bar */
	if (mx<X_SERIES) return;	/* clicked in tag area */
	if (find_wind(my)!=fillwind) return;		/* clicked in correct window? */
	row= find_row(my,wind_y[fillwind]);
	if (row<0) return;			/* clicked in a valid row? */
	type= wind_type[fillwind];
	param= find_param(mx,row,type);
	if (param<0) return;			/* clicked on a valid parameter? */
	if (type==V_TYPE)
	{
		if (param>=NPERPAGE) return;	/* must click on one of velocity cells */
	}
	else
	{
		BITCLR(0,param);	/* use only operator */
		if (param>=2*NPERPAGE) return;	/* must click on operator or operand */
	}

	HIDEMOUSE;						/* confirm or cancel the fill */
	fillmode=0;
	xortext(fillparam.ncols,fillparam.col,fill_y);
	if (type!=V_TYPE) xortext(fillparam.ncols,fillparam.col,fill_y2);

	if (param!=fillparnum)		/* clicked on different param: confirm */
	{
		seq= wind_seq[fillwind];
		par1= min(fillparnum,param);
		par2= max(fillparnum,param);
		if (type==V_TYPE)
		{
			fillval=	seq1data[seq][fillparam.offset];
			fillparam=	params[type][fillparnum];
			fillptr= seq1data[seq] + params[type][par1].offset;
			set_bytes(fillptr,par2-par1+1,fillval);
			disp_window(fillwind);
		}
		else
		{
			start= 2*wind_start[fillwind];
			fill_it(start,seq,fillparam.offset,type,par1,par2);
			disp_window(fillwind);
			if (masterdata[M_LINK])
			{
				i=	seq1data[seq][fillparam.offset+start];
				if (i<=2)
				{
					fill_it(start,seq,fillparam.offset,!type,par1,par2);
					i= get_wind(seq,!type);
					if (i>=0) disp_window(i);
				}
			}
		}
	}

	SHOWMOUSE;
	graf_mouse(ARROWMOUSE);

}	/* end do_fillmode() */

fill_it(start,seq,offset,type,par1,par2)
int start,seq,offset,type,par1,par2;
{
	int fillval;
	register int i;
	register char *fillptr;

	for (i=0; i<=1; i++,start++)	/* for operator and operand */
	{
		fillval=	seq1data[seq][offset+start];
		fillptr= seq1data[seq] + params[type][par1].offset + start;
		asm { move.w i,-(a7) }
		for (i=par1; i<=par2; i+=2,fillptr+=2) *fillptr=fillval;
		asm { move.w (a7)+,i }
	}
	/* reset looping */
	if (type==P_TYPE) pready[seq]=0; else rready[seq]=0;
	set_bytes(loopcnt + seq*2*NCELL + type*NCELL , NCELL , 0 );
}	/* end fill_it() */

/* change the window layout on the screen ...................................*/

do_tagmouse(mx,my,st)
int mx,my,st;
{
	int wind,type,start,seq,row;
	int new_seq,new_type,new_start;
	register int i;

	wind= find_wind(my);					/* clicked in which window? */
	row= find_tag(my,wind_y[wind]);
	if (row<0) return;

	new_type= type= wind_type[wind];
	new_start= start= wind_start[wind];
	new_seq= seq= wind_seq[wind];

	switch (row)
	{
		case 0:		/* change sequence */

		if (mx==X_SEQX)
		{
			for (i=0; i<NSEQ-1; i++)
			{
				new_seq+=st;
				if (new_seq==NSEQ) new_seq=0;
				if (new_seq<0) new_seq= NSEQ-1;
				if (get_wind(new_seq,new_type)<0) break;
			}
			if (i==NSEQ-1) new_seq=seq;
		}
		break;

		case 1:			/* change type */

		if ( (mx>=X_TYPE-2) && (mx<=X_TYPE+2) )
		{
			for (i=0; i<NTYPE-1; i++)
			{
				new_type+=st;
				if (new_type==NTYPE) new_type=0;
				if (new_type<0) new_type= NTYPE-1;
				if (get_wind(new_seq,new_type)<0) break;
			}
			if (i==NTYPE-1) new_type=type;
		}
		break;

		case 2:			/* change start of P_ or R_TYPE */
		if ( (type==P_TYPE) || (type==R_TYPE) )
		{
			if ((mx>=X_TYPE-1)&&(mx<=X_TYPE+1))
			{
				if (mx<X_TYPE+1) st*=10;
				if (mx<X_TYPE) st*=10;
				new_start= start+st;
				if (new_start<0) new_start += NCELL-NPERPAGE+1;
				if (new_start>NCELL-NPERPAGE) new_start -= NCELL-NPERPAGE+1;
			}
		}
	}	/* end switch */

	if ( (new_seq!=seq) || (new_type!=type) || (new_start!=start) )
	{
		HIDEMOUSE;				/* V <--> P/R requires frame change */
		if (xorc_col[wind]) outcurs(xorc_col[wind],xorc_row[wind]);
		xorc_col[wind]=0;
		if (xorp_col[wind]) outcurs(xorp_col[wind],xorp_row[wind]);
		xorp_col[wind]=0;
		if ( (type!=new_type) && ( (type==V_TYPE) || (new_type==V_TYPE) ) )
			draw_wind(new_type,wind);
		wind_type[wind]=new_type;
		wind_seq[wind]=new_seq;
		wind_start[wind]=new_start;
		tag_window(wind);
		disp_window(wind);
		if (play_mode)
		{
			if (new_type==P_TYPE) move_xorp(new_seq,0,pxor_pp[new_seq]);
			if (new_type==R_TYPE) move_xorp(new_seq,1,pxor_rr[new_seq]);
		}
		SHOWMOUSE;
	}
}	/* end do_tagmouse() */

/* mouse clicked in menu bar, in play mode ..................................*/

do_playmouse(mx,st)
int mx,st;
{
	register int i,j;
	char charbuf[6];

	if (mx==X_CLOSE)
	{
		if (play_mode==1) stop_time=masterclock;
		play_mode=0;		/* exit play mode */
	}

	if ((mx>=X_TEMPO)&&(mx<=X_TEMPO+4))	/* tempo change */
	{
		st*=(-1);
		if (mx<X_TEMPO+3) st*=8;
		i= (unsigned)(masterdata[M_TEMPO]) + st ;
		if (i<MINTEMPO) i += NTEMPO-MINTEMPO;
		if (i>=NTEMPO) i -= NTEMPO-MINTEMPO;
		tempotoa(i,charbuf);
		HIDEMOUSE;
		gr_text(charbuf,X_TEMPO,1);
		SHOWMOUSE;
		masterdata[M_TEMPO]= i;
		set_tempo(i);
	}

	if ((mx>=X_MUTE)&&(mx<=X_MUTE+2*NSEQ-1))	/* mute/unmute */
	{
		i= (mx-X_MUTE)/2;	/* which sequence */
		if (st<0)			/* mute/unmute */
		{
			if ( !(nonr1data[i][N_MUTE]=!nonr1data[i][N_MUTE]) ) seq_off(i);
			asm { bchg i,mutebyte(a4) }
			HIDEMOUSE;
			j= nonr1data[i][N_MUTE] ? 1 : 2 ;
			outchar(j,X_MUTE+2*i,1);
			SHOWMOUSE;
		}
		else					/* solo/unsolo */
		{
			st= !nonr1data[i][N_MUTE];
			HIDEMOUSE;
			for (j=0; j<NSEQ; j++)
			{
				if (j!=i)
				{
					nonr1data[j][N_MUTE]=st;
					if (st)
					{
						asm { bset j,mutebyte(a4) }
					}
					else
					{
						seq_off(j);
						asm { bclr j,mutebyte(a4) }
					}
					outchar(2-st,X_MUTE+2*j,1);
				}
			}
			SHOWMOUSE;
		}
	}

	if ( (mx>=X_PAUSE) && (mx<=X_PAUSE+1) )
	{
		play_pause= !play_pause;
		if ( play_pause && (st<0) )
			for (i=0; i<NSEQ; i++) seq_off(i);
		HIDEMOUSE;
		xortext(2,X_PAUSE,1);
		SHOWMOUSE;
	}

}	/* end do_playmouse() */

/* mouse clicked in edit mode, no fake dial on screen .......................*/

do_edit(mx,my,st)
int mx,my,st;
{
	register int wind,row;
	int parnum= (-1);

	wind= find_wind(my);					/* clicked in which window? */
	if (wind==editwind)					/* clicked in the edit window */
	{
		row=	find_row(my,wind_y[wind]);	/* clicked in which row? */
		if (row>=0)
		{
			parnum= find_param(mx,row,wind_type[wind]);
			if ( parnum == editparnum[0] )
			{	/* continue editing the same parameter */
				HIDEMOUSE;
				if (editparam[0].dial<0)
				{
					edit_it(0,mx,st);
					gr_text(editparam[0].encode[editval[0]],editparam[0].col,
								my=wind_y[wind]+val_y[editparam[0].row]);
					if (editval[0]==oldval[0])
						editmode=0;
					else
						xortext(editparam[0].ncols,editparam[0].col,my);
				}
				else
				{
					dialwind= editwind<2 ? 2 : 0 ;
					editmode=2;
					save_screen(1,wind_y[dialwind],
								dialwind ? 200*rez-1 : wind_y[dialwind+2] );
					draw_dial(editparam[0].dial,dialwind);
					if (lazy_mouse) *Mousey= wind_y[dialwind];
				}
				SHOWMOUSE;
			}	/* end if clicked on the parameter being edited */
			if ( (parnum==editparnum[1]) && (parnum>=0) )
			{	/* co-editing */
				HIDEMOUSE;
				edit_it(1,mx,st);
				gr_text(editparam[1].encode[editval[1]],editparam[1].col,
							my=wind_y[wind]+val_y[editparam[1].row]);
				xortext(editparam[1].ncols,editparam[1].col,my);
				SHOWMOUSE;
				parnum=editparnum[0];	/* prevent end_edit */
			}	/* end if clicked on co-edit param */
		}	/* end if clicked on a row */
	}	/* end if clicked within window currently being edited */

	if ((editmode==1)&&(parnum!=editparnum[0])) end_edit(st);

}	/* end do_edit() */

/* exit edit mode ...........................................................*/

end_edit(st)
int st;		/* >0 cancel, else confirm */
{
	int seq,type,maxval,p;
	PARAM nextparam;
	int coedit;

	seq= wind_seq[editwind];
	type= wind_type[editwind];

	nextparam= params[type][editparnum[0]+1];
	coedit= nextparam.high<0;	/* if param 0 is an operator */

	HIDEMOUSE;
	if (st>0)			/* cancel */
	{
		editval[0]=oldval[0];
		editval[1]=oldval[1];
	}
	else					/* confirm */
	{
		if (coedit)
		{
			/* limit the associated operand according to operator */
			maxval= oper_hlim[nextparam.high+2][editval[0]];
			if (editval[1]>maxval) editval[1]= maxval;
		}
		if ( (editparam[0].high<0) || (nextparam.high<0) )
		{
			/* reset looping */
			p= editparnum[0]/2 + wind_start[editwind];
			loopcnt[ seq*(2*NCELL) + type*NCELL + p]= 0;
		}
	}	/* end if confirming */
/* complete the edit */
	if (editparam[0].nbytes>1)
		*(int*)(editptr[0])= editval[0];
	else
		editptr[0][0]= editval[0];
	gr_text(editparam[0].encode[editval[0]],editparam[0].col,
				wind_y[editwind]+val_y[editparam[0].row]);
	if (coedit)
	{
		if (editparam[1].nbytes>1)
			*(int*)(editptr[1])= editval[1];
		else
			editptr[1][0]= editval[1];
		gr_text(editparam[1].encode[editval[1]],editparam[1].col,
					wind_y[editwind]+val_y[editparam[1].row]);

		/* linked co-edit */
		if ( masterdata[M_LINK] )
			if ( (editval[0]!=oldval[0]) || (editval[1]!=oldval[1]) )
			{
				p=link_edit(editval[0],editval[1],editparnum[0],
								editparnum[1],editwind);
				if (p>=0) disp_window(p);
			}
	}
	SHOWMOUSE;
	editmode=0;
}	/* end end_edit() */

/* linked P/R edit ......................................................... */
/* returns window # or -1 */

link_edit(val0,val1,par0,par1,wind)
int val0;	/* operator value */
int val1;	/* operand value */
int par0,par1;	/* parameter numbers */
int wind;	/* window linked to */
{
	int seq,type,start;
	register int i;
	register char *ptr;

	/* param 0 is operator, param 1 is operand */
	if (par0&1)
	{
		i=par0;		par0=par1;		par1=i;
		i=val0;		val0=val1;		val1=i;
	}
	if (val0>2) return(-1);		/* operator must be U, <, or > */

	/* find the parameter to be link-edited */
	type= wind_type[wind]==P_TYPE ? R_TYPE : P_TYPE ;
	start= wind_start[wind];
	seq= wind_seq[wind];

	/* edit it */
	ptr= seq1data[seq] + 2*start + params[type][par0].offset ;
	ptr[0]= val0;
	ptr[1]= val1;

	return(get_wind(seq,type));
	
}	/* end link_edit() */

/* change editval[i], possible digit-by-digit............................... */

edit_it(i,col,st)
register int i;
int col,st;
{
	int maxval,minval;

	if (editparam[i].high<0)	/* operand's limit is enforced by operator */
	{
		maxval= i ? editval[0] : editptr[0][-1];
		maxval= oper_hlim[2+editparam[i].high][maxval];
	}
	else
		maxval= editparam[i].high ;
	minval= editparam[i].low ;

	if ( (editparam[i].ndigits==2) && (col==editparam[i].col) ) st*=10;
	editval[i]+=st;
	if (editval[i]<minval) editval[i]=maxval;
	if (editval[i]>maxval) editval[i]=minval;
	/* shift-click on rhythmic values steps by exact values */
	if ( (editparam[i].encode == timechar) && (Kbshift(-1)&LRSHIFT) )
		editval[i]= exact_val(editval[i],st);
}	/* end edit_it() */

/* mouse clicked in edit mode, fake dial on screen ..........................*/

do_fakedial(mx,my0)
int mx,my0;
{
	int newmode=editmode;
	int my1,kind,ndialrows,ndialcols;

	kind= editparam[0].dial;			/* kind of fake dial (0 - NDIAL-1) */
	/* click outside of fake dial to cancel */
	if (my0 < wind_y[dialwind] ) newmode=1;
	if ( !dialwind && (my0 >= wind_y[2]) ) newmode=1;
	/* mouse y-coord referenced to bottom edge of fake dial title bar */
	my0 -= (wind_y[dialwind]+TITLEH*rez) ;
	if ( (newmode==2) && (my0>=0) )
	{
		if ((kind==P_DIAL)||(kind==R_DIAL))
		{
			ndialrows= 10;
			ndialcols= 3;
		}
		else
		{
			ndialrows= 3;
			ndialcols= 4;
		}
		my0 /= ( (84*rez) / ndialrows ) ;
		if (my0<ndialrows)
		{
			editval[0]= ndialrows * ((ndialcols*mx)/640) + my0 ;
			newmode=1;
		}
	}
	if (newmode==1)
	{
		HIDEMOUSE;
		save_screen(0);
		gr_text(editparam[0].encode[editval[0]],editparam[0].col,
					my0=wind_y[editwind]+val_y[editparam[0].row]);
		if (editparnum[1]>=0)
			gr_text(editparam[1].encode[editval[1]],editparam[1].col,
				my1=wind_y[editwind]+val_y[editparam[1].row]);
		if (lazy_mouse)
		{
			*Mousex= savelazy_x;
			*Mousey= savelazy_y;
		}

		if ( (editval[0]==oldval[0]) && 
			  ( (editparnum[1]<0) || (editval[1]==oldval[1]) )
			)
			newmode=0;
		else
		{
			xortext(editparam[0].ncols,editparam[0].col,my0);
			if (editparnum[1]>=0)
				xortext(editparam[1].ncols,editparam[1].col,my1);
		}
		SHOWMOUSE;
	}
	editmode=newmode;
}	/* end do_fakedial() */

/* copyright box, with tongue ...............................................*/

do_tongue()
{
	int exit_obj,edit_obj,tongue;

	tongue= rez==2 ? TONGUEM : TONGUEC ;
	infoaddr[tongue].ob_flags |= HIDETREE;
	putdial(infoaddr,1,0);
	exit_obj= -1;

	if (!tonguewait(0x1ffffL))
	{
		infoaddr[tongue].ob_flags &= ~HIDETREE;
		draw_object(infoaddr,tongue);
		if (!tonguewait(0xffffL))
		{
			infoaddr[tongue].ob_flags |= HIDETREE;
			draw_object(infoaddr,tongue);
			edit_obj= -1;
			exit_obj= my_form_do(infoaddr,&edit_obj,&dummy);
		}
	}
	putdial(0L,0,exit_obj);

}	/* end do_tongue() */

tonguewait(time)		/* returns non-0 if mouse clicked */
long time;
{
	register long cnt;

	for (cnt=time; (cnt>0L)&&(!(*Mstate&3)); cnt--) ;
	return (cnt>0L);
}

/* EOF event.c */
