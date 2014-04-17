/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                         Copyright 1990/1991 Tom Bajoras

	module CNXINTER : CNX language interpreter

	exec_seg, exec_cnx, reset_cnx

	init_device, set_device, get_device, find_device

******************************************************************************/

overlay "cnxinter"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "scan.h"			/* keyboard scan codes */
#include "externs.h"		/* global variables */
#include "genedit.h"		/* created by RSC */

/* local defines ............................................................*/

#define FLICKERX0 1
#define FLICKERX1 78
#define MAXCURX 37		/* maximum cnx window coordinates (min's are 0) */
#define MAXCURY 11
#define MAXGOSUB 16		/* maximum nesting level for cnx subroutines */
#define MAXLOOP 16		/* maximum nesting level for loops */
#define TABLELENG 4096L	/* total combined size of tables */
#define NTABLES 16L		/* how many tables */
#define ASCIBREAK 1		/* key for keyboard break */

long val_of_cv(),oper_d0d1();

/* local globals ............................................................*/

DEV_STRUCT cnx_context;		/* device context */
int old_cnxcrc;				/* CRC of previously executed CMMN segment */
char *cnxlabel[NLABELS];	/* pointers to labels */
long cnxfuncs[NCNXCMDS];	/* cnx command handlers */
int cnxopenwind;				/* whether cnx "window" is on screen */
char *nextcnx;					/* next command to be executed */
char divbyzero;				/* set in oper_d0d1() */
char *cnxdata;					/* start of data buffer */
char *cnxpatch;				/* start of edit buffer */
int cnxhomex,cnxhomey;		/* row 0 / col 0 screen coords */
char *cnxstack[MAXGOSUB];	/* stack for gosub cnx command */
int cnxstackx;					/* index into cnxstack */
char *cnxend;					/* first byte past cnx code to be exec'd */
int cnxpnum_i;					/* index into cnxpnumfmt */
int cnxnpats;					/* total # patches formatted */
int cnxflicker;				/* whether to do the midi activity indicator */
int cnxkillmouse;				/* whether to kill mouse */

	/* info for looping */
struct {
char *start[MAXLOOP];	/* command after Loop N */
char *end[MAXLOOP];		/* command after EndLoop */
long initctr[MAXLOOP];	/* loop initial counter (0= infinite) */
long ctr[MAXLOOP];		/* loop counter */
} loopstruct;
int cnxloopx;				/* index into loopstruct */

	/* info for tables */
int tablestart[NTABLES];	/* index into cnxtables */
int tableleng[NTABLES];		/* bytes in each table */
int tabletotal;				/* sum of bytes in all tables */
int savestart[NTABLES];		/* saved/restored around all segs other than CMMN */
int saveleng[NTABLES];
int savetotal;
char cnxtables[TABLELENG];
char savetables[TABLELENG];

extern saveA4();				/* in main.c */

/* manage device structures .................................................*/

init_device(dev)
DEV_STRUCT *dev;
{
	dev->midichan= -1;
	dev->in_port= midi_rport;
	dev->out_port= midi_tport;
	dev->speed= midi_speed;
	dev->filter= midi_filter;
	strcpy(dev->initstring,"");
	strcpy(dev->exitstring,"");
}

set_device(devnum)
int devnum;
{
	DEV_STRUCT *dev;

	if (devnum<0)			/* initialize */
	{
		init_device(&cnx_context);
	}
	else if (devnum<NDEVICES) /* from studio description */
	{
		cnx_context= studioDev[devnum];
	} else if (devnum>=NDEVICES) /* from a window */
	{
		cnx_context= wind_device[devnum-NDEVICES];
	}
}

get_device(dev)
DEV_STRUCT *dev;
{
	*dev= cnx_context;
}

/* find device with specified extent */
/* returns 0-(NDEVICES-1), -1 none */

find_device(extent)
char *extent;		/* might not be null-term'd ! */
{
	register int i;

	for (i=0; i<NDEVICES; i++)
		if (!comp_bytes(extent,studioLink[i].extent,3L)) break;
	if (i==NDEVICES) return -1;
	return i;
}

/* execute CNX segment ......................................................*/
/* returns 0= error, 1= ok */

exec_seg(hand,seg,datastart,dataend,editstart,editend,prompt)
int hand,seg;	/* heap contains a single config */
long datastart,dataend,editstart,editend;
char *prompt;	/* info line prompt (recv, tran) */
{
	long cnxstart,cnxend,start,end;
	int result;
	int new_cnxcrc;

	/* start and end of configuration */
	cnxstart= heap[hand].start;
	cnxend= cnxstart + heap[hand].nbytes;
	if (cnxstart==cnxend) return 0;

	/* if there's a Common segment, and it's different than the last Common
		segment that was executed, then execute it */
	if ( _findcnxseg( (int)(cnxCMMN),cnxstart,cnxend,&start,&end) )
	{
		new_cnxcrc= checksum(start,end);
		if (new_cnxcrc!=old_cnxcrc)
		{
			reset_cnx();
			exec_cnx((int)(cnxCMMN),start,end,&dummy,&dummy,&dummy,&dummy,0L);
			if (!cnxvars[VAR_ERR]) old_cnxcrc= new_cnxcrc;
		}
	}
	else
		reset_cnx();
	if (_findcnxseg(seg,cnxstart,cnxend,&start,&end))
	{
		exec_cnx(seg,start,end,datastart,dataend,editstart,editend,prompt);
		result= !cnxvars[VAR_ERR];
	}
	else
		result=0;
	return result;
}	/* end exec_seg() */

/* clear tables built by CMMN segment .......................................*/

reset_cnx()
{
	set_words(tablestart,NTABLES,0);
	set_words(tableleng,NTABLES,0);
	tabletotal= old_cnxcrc= 0;
}	/* end reset_cnx() */

/* execute CNX code .........................................................*/

exec_cnx(seg,start,end,datastart,dataend,editstart,editend,prompt)
int seg;							/* cnxXXXX, which seg is being exec'd */
char *start,*end;				/* --> 1st byte of code, --> 1st byte after code */
char *datastart,*dataend;	/* start and end of data buffer */
char *editstart,*editend;
char *prompt;					/* info line prompt (recv, tran) */
{
#if CNXFLAG
	register char *ptr;
	register int cmd;

	/* build command interpreter jump table */
	init_funcs();

	/* find all labels */
	set_longs(cnxlabel, (long)(NLABELS), 0L);		/* 0L means undef'd label */
	for (ptr=start; ptr<end; )
	{
		cmd= ptr[0];										/* byte 0 is command */
		if (cmd==GE_LABEL) cnxlabel[ptr[3]]=ptr;	/* byte 3 is label # */
		ptr += (ptr[1]&0xFF);							/* byte 1 is length */
	}

	/* find all loops */
	if (set_loops(start,end,1))
	{
		form_alert(1,BADLOOP);
		set_loops(start,end,0);
		return;
	}

	/* reset CNX control variables */
	cnxopenwind=0;									/* cnx window not open */
	runningstat= 0xFF;							/* no status yet */
	cnxdata= datastart;
	cnxpatch= editstart;
	cnxend= end;
	cnxstackx= cnxloopx= 0;
	cnxpnum_i= cnxnpats= 0;

	/* reset CNX variables */
	cnxvars[VAR_DLN]= (long)dataend - (long)datastart  ;
	cnxvars[VAR_ELN]= (long)editend - (long)editstart  ;
	cnxvars[VAR_ERR]= 0;
	cnxvars[VAR_PTR]= 0;							/* index into data buffer */

	/* recv/tran:  midi activity indicator */
	cnxflicker=0;
	if ((seg==cnxRECV)||(seg==cnxTRAN))
	{
		cnxflicker=1;
		menuprompt(prompt);
	}
	/* recv/tran/send:  swap in context */
	if ((seg==cnxRECV)||(seg==cnxTRAN)||(seg==cnxSEND))
	{
		set_context(1);
	}
	/* recv:  disable mouse at ikbd */
	cnxkillmouse=0;
	if (seg==cnxRECV)
	{
		cnxkillmouse=1;
		mouse_enable(0);
	}
	/* save tables */
	if (seg!=cnxCMMN)
	{
		copy_words(tablestart,savestart,NTABLES);
		copy_words(tableleng,saveleng,NTABLES);
		savetotal= tabletotal;
		copy_bytes(cnxtables,savetables,(long)tabletotal);
	}

	/* clear keyboard buffer so that keyboard break can be used */
	*keyb_head= *keyb_tail;

	/* thread through cnx code, exec each command */
	for (ptr=start; ptr<end; ptr=nextcnx)
	{
		/* next command (unless changed in command handler) */
		nextcnx= ptr + (ptr[1]&0xFF);
		exec_1cnx(ptr);
		if (cnxvars[VAR_ERR]) break;
	}

	/* close window if it's still open */
	ge_closewind(&dummy);

	/* reset loops */
	set_loops(start,end,0);

	/* restore tables (if changed) */
	if ( (seg!=cnxCMMN) && (tabletotal!=savetotal) )
	{
		copy_words(savestart,tablestart,NTABLES);
		copy_words(saveleng,tableleng,NTABLES);
		tabletotal= savetotal;
		copy_bytes(savetables,cnxtables,(long)tabletotal);
	}
	/* get rid of midi activity indicator */
	if ((seg==cnxRECV)||(seg==cnxTRAN))
	{
		menuprompt(0L);
	}
	/* re-enable mouse at ikbd */
	if (seg==cnxRECV)
	{
		mouse_enable(1);
	}
	/* recv/tran/send:  swap out context */
	if ((seg==cnxRECV)||(seg==cnxTRAN)||(seg==cnxSEND))
	{
		set_context(0);
	}

#endif
}	/* end exec_cnx() */

#if CNXFLAG

exec_1cnx(ptr)
register char *ptr;
{
	register long templong;
	int cmd;

	cmd= ptr[0];
	if (cmd>=NCNXCMDS)			/* if unknown command: abort or skip it */
		cnxvars[VAR_ERR]= cnx_alert(1,BADCNXCMD)==1 ;
	else
	{
		templong= cnxfuncs[cmd];
		asm {
			move.l	ptr,-(a7)
			move.l	templong,a0
			jsr		(a0)
			addq.w	#4,a7
		}
	}
	if (cnxvars[VAR_PTR]>cnxvars[VAR_DLN])
	{
		cnx_alert(1,BADVARPTR);
		cnxvars[VAR_PTR]= cnxvars[VAR_DLN];
		cnxvars[VAR_ERR]=1;
	}
}	/* end exec_1cnx() */

set_context(flag)
int flag; /* 1= set, 0= restore */
{
	static int save_speed,save_filter,save_thru,save_rport,save_tport;
	int temp;

	if (flag)
	{
		/* save/disable thru */
		save_thru= midithru;
		midithru= 0;
		if (save_thru) thru_nts_off();
		reset_midi();

		/* initialize patch bay */
		send_pmidi(cnx_context.initstring);

		save_rport= midi_rport;
		save_tport= midi_tport;
		save_speed= midi_speed;
		save_filter= midi_filter;

		/* swap in context */
		cnxvars[VAR_CHN]= cnx_context.midichan;
		midi_rport= cnx_context.in_port;
		midi_tport= cnx_context.out_port;
		midi_speed= cnx_context.speed;
		midi_filter= cnx_context.filter;
	}
	else
	{
		/* swap out context */
		temp= cnxvars[VAR_CHN];
		cnx_context.midichan= ((temp>=0)&&(temp<=15)) ? temp : -1;
		cnx_context.in_port= midi_rport;
		cnx_context.out_port= midi_tport;
		cnx_context.speed= midi_speed;
		cnx_context.filter= midi_filter;

		midi_rport= save_rport;
		midi_tport= save_tport;
		midi_speed= save_speed;
		midi_filter= save_filter;

		/* deinitialize patch bay */
		send_pmidi(cnx_context.exitstring);

		/* restore thru */
		midithru= save_thru;
		reset_midi();
	}
}

/* CNX command handlers .....................................................*/

ge_nop(ptr)
char *ptr;
{
	;	/* do nothing */
}	/* end ge_nop() */

ge_neg(ptr)
register char *ptr;
{
	register long val;

	asm {
		move.l	ptr,a0
		adda.w	#4,a0
		jsr		val_of_cv
		move.l	d0,val			; val.l = constvar
	}
	cnxvars[ ptr[2]&0xFF ]= -val;
}	/* end ge_neg() */

ge_not(ptr)
register char *ptr;
{
	cnxvars[ ptr[2]&0xFF ]= !cnxvars[ ptr[3]&0xFF ] ;
}	/* end ge_not() */

ge_invert(ptr)
register char *ptr;
{
	cnxvars[ ptr[2]&0xFF ] = cnxvars[ ptr[3]&0xFF ] ^ 0xffffffffL ;
}	/* end ge_invert() */

ge_speed(ptr)
register char *ptr;
{
	unsigned int speed;

	speed= ptr[2]&0xFF;
	midi_speed= speedtable[speed/51];
}	/* end ge_speed() */

ge_filter(ptr)
register char *ptr;
{
	register int new;

	new= ptr[2]&0xFF;			/* filter mask */
	if (ptr[3])
		midi_filter |= new;
	else
		midi_filter &= ~new;
	
}	/* end ge_filter() */

ge_dtod(ptr)
char *ptr;
{
	ge_copy(ptr,cnxvars[VAR_DLN],BADPEEKD,cnxdata,
					cnxvars[VAR_DLN],BADPOKED,cnxdata);
}	/* end ge_dtod() */

ge_dtop(ptr)
char *ptr;
{
	ge_copy(ptr,cnxvars[VAR_DLN],BADPEEKD,cnxdata,
					cnxvars[VAR_ELN],BADPOKEP,cnxpatch);
}	/* end ge_dtop() */

ge_ptod(ptr)
char *ptr;
{
	ge_copy(ptr,cnxvars[VAR_ELN],BADPEEKP,cnxpatch,
					cnxvars[VAR_DLN],BADPOKED,cnxdata);
}	/* end ge_ptod() */

ge_ptop(ptr)
char *ptr;
{
	ge_copy(ptr,cnxvars[VAR_ELN],BADPEEKP,cnxpatch,
					cnxvars[VAR_ELN],BADPOKEP,cnxpatch);
}	/* end ge_ptop() */

ge_copy(ptr,from_len,badpeek,from_start,
				to_len,badpoke,to_start)
register char *ptr;
long from_len;
char *badpeek;
long from_start;
long to_len;
char *badpoke;
long to_start;
{
	long to_off,from_off,to_end,from_end;
	register long val,n;
	int size;

	switch (ptr[2])				/* # bytes per element */
	{
		case 'B': size=1;	break;
		case 'W': size=2; break;
		case 'L': size=4;
	}

	asm {								/* offset to start of source */
		move.l	ptr,a0
		addq.w	#4,a0
		jsr		val_of_cv
		move.l	d0,from_off(a6)
	}
	from_off *= size;
	if ( (from_off+size-1) > from_len )
	{
		cnxvars[VAR_ERR]= cnx_alert(1,badpeek)==1 ;
		return;
	}

	asm {								/* offset to start of destination */
		move.l	ptr,a0
		adda.w	#10,a0
		jsr		val_of_cv
		move.l	d0,to_off(a6)

		move.l	ptr,a0			/* how many elements to be copied */
		adda.w	#16,a0
		jsr		val_of_cv
		move.l	d0,n
	}
	to_off *= size;
	if ( (to_off+size*n-1) > to_len )
	{
		cnxvars[VAR_ERR]= cnx_alert(1,badpoke)==1 ;
		return;
	}

	from_start += from_off;
	to_start += to_off;
	from_end= from_start + size*n ;
	to_end= to_start + size*n;

	if ( (to_start>from_start) && (to_start<from_end) )	/* overlap */
	{
		switch (size)
		{
			case 1:	rcopy_bytes(from_end,to_end,n); break;
			case 2:	rcopy_words(from_end,to_end,n); break;
			case 4:	rcopy_longs(from_end,to_end,n);
		}
	}
	else
	{
		switch (size)
		{
			case 1:	copy_bytes(from_start,to_start,n); break;
			case 2:	copy_words(from_start,to_start,n); break;
			case 4:	copy_longs(from_start,to_start,n);
		}
	}
}	/* end ge_copy() */

ge_event(ptr)
register char *ptr;
{
	;	/* no run-time errors !!! */
}	/* end ge_event() */

ge_getport(ptr)
register char *ptr;
{
	;	/* run-time errors? !!! */
}	/* end ge_getport() */

ge_assign(ptr)
register char *ptr;
{
	register long val;

	asm {
		move.l	ptr,a0
		adda.w	#4,a0
		jsr		val_of_cv
		move.l	d0,val			; val.l = constvar1
		move.b	3(ptr),d2
		blt		no_cv1
		move.l	ptr,a0
		adda.w	#10,a0
		jsr		val_of_cv
		move.l	d0,d1				; d1.l = constvar2
		move.l	val,d0
		jsr		oper_d0d1		; d0.l = d0.l oper(d2) d1.l
		move.l	d0,val
	no_cv1:							; val = value to be assigned
	}
	if (divbyzero)
	{
		divbyzero=0;
		val=0L;
		cnxvars[VAR_ERR]= cnx_alert(1,BADDIVZERO)==1 ;
	}
	cnxvars[ ptr[2]&0xFF ]=val;

}	/* end ge_assign() */

ge_logic(ptr)
register char *ptr;
{
	register long val1,val2;

	val1= cnxvars[ ptr[3]&0xFF ];
	val2= cnxvars[ ptr[4]&0xFF ];
	switch (ptr[5])
	{
		case 0:	/* and */
		val1= val1 && val2;
		break;

		case 1:	/* or */
		val1= val1 || val2;
		break;
		
		case 2:	/* xor */
		val1= !!( val1 ^ val2 );
	}
	cnxvars[ ptr[2]&0xFF ]= val1;

}	/* end ge_logic() */

ge_rel(ptr)
register char *ptr;
{
	register long val1,val2;

	val1= cnxvars[ ptr[3]&0xFF ];
	asm {
		move.l	ptr,a0
		addq.w	#4,a0
		jsr		val_of_cv
		move.l	d0,val2
	}
	switch (ptr[10])
	{
		case 0:	/* eq */
		asm {
			cmp.l	val2,val1
			seq	val1
		}
		break;
		
		case 1:	/* ne */
		asm {
			cmp.l	val2,val1
			sne	val1
		}
		break;
		
		case 2:	/* lt */
		asm {
			cmp.l	val2,val1
			sne	d0
			sls	val1
			and.b	d0,val1
		}
		break;
		
		case 3:	/* gt */
		asm {
			cmp.l	val2,val1
			shi	val1
		}
		break;
		
		case 4:	/* le */
		asm {
			cmp.l	val2,val1
			sls	val1
		}
		break;
		
		case 5:	/* ge */
		asm {
			cmp.l	val2,val1
			seq	d0
			shi	val1
			or.b	d0,val1
		}
	}
	cnxvars[ ptr[2]&0xFF ]= val1&1;
}	/* end ge_rel() */

ge_goto(ptr)
register char *ptr;
{
	register char *label;
	unsigned int var;

	if (key_abort()) return;

	label= cnxlabel[ ptr[3]&0xFF ];
	if (!label)
		cnxvars[VAR_ERR]= cnx_alert(1,BADLABEL)==1 ;
	else
	{
		var= ptr[2]&0xFF;
		if ( (var==VAR_DUM) || cnxvars[var] ) nextcnx= label;
	}
}	/* end ge_goto() */

ge_gosub(ptr)
register char *ptr;
{
	register char *label;
	unsigned int var;

	label= cnxlabel[ ptr[3]&0xFF ];
	if (!label)
		cnxvars[VAR_ERR]= cnx_alert(1,BADLABEL)==1 ;
	else
	{
		var= ptr[2]&0xFF;
		if ( (var==VAR_DUM) || cnxvars[var] )
		{
			if (cnxstackx==MAXGOSUB)
				cnxvars[VAR_ERR]= cnx_alert(1,BADSTACKO)==1 ;
			else
			{
				cnxstack[cnxstackx++]= nextcnx;
				nextcnx= label;
			}
		}
	}
}	/* end ge_gosub() */

ge_return(ptr)
char *ptr;
{
	if (!cnxstackx)
		cnxvars[VAR_ERR]= cnx_alert(1,BADSTACKU)==1 ;
	else
		nextcnx= cnxstack[--cnxstackx];
}	/* end ge_return() */

ge_recvdata(ptr)
register char *ptr;
{
	register long nflick,nflickcnt,nbytes,nactual;
	long termbyte,nterm,i,hz200;
	int error,what_to_do;
	unsigned int midibyte;
	int flickphase=0;

	asm {
		move.l	ptr,a0
		addq.w	#4,a0
		jsr		val_of_cv
		move.l	d0,nbytes

		move.l	ptr,a0
		adda.w	#10,a0
		jsr		val_of_cv
		andi.l	#0xFF,d0
		move.l	d0,termbyte(a6)

		move.l	ptr,a0
		adda.w	#16,a0
		jsr		val_of_cv
		move.l	d0,nterm(a6)
	}

	if (midiovfl) /* set in interrupt */
	{
		cnx_alert(1,BADOVFL);
		cnxvars[VAR_ERR]=1;
		return;
	}

	error=0;												/* no error yet */
	what_to_do=2;
	nactual= 0L;										/* # bytes received */
	nflickcnt= nflick= max(8L,(nbytes>>7));	/* interval between flickers */
	i= cnxvars[VAR_PTR];								/* index into data buffer */
	hz200= *(long*)(HZ200);							/* start time-out counter */

	while ( (termbyte!=0xFF) || ( (hz200+20) > *(long*)(HZ200) ) )
	{
		if (error=key_break()) break;
		midibyte= get_midi();
		if (midibyte!=0xFF)						/* if byte available */
		{
			hz200= *(long*)(HZ200);				/* restart time-out counter */
			if (cnxflicker)
			{
				if (recv_head == recv_tail) nflickcnt=1;
				if ( !(--nflickcnt) )
				{
					xorchar(FLICKERX0,1);
					flickphase ^= 1;
					nflickcnt=nflick;
				}
			}
			cnxdata[i++]= midibyte;
			if ( (++nactual)==nbytes) break;
			if (midibyte==termbyte)
				if ( (--nterm) <= 0 ) break;
			if (i>=cnxvars[VAR_DLN]) { error=2; break; }
		}
	}
	if (flickphase) xorchar(FLICKERX0,1);

	if (error)
	{
		if (error==1)	/* key was typed */
		{
			what_to_do= cnxloopx ? cnx_alert(1,CHEKSTOP3) :
											 cnx_alert(1,CHEKSTOP2) ;
			cnxdata[i++]= END_OF_DATA;
		}
		if (error==2)	/* data buffer overflowed */
		{
			what_to_do= cnxloopx ? cnx_alert(1,CHEKOVFL3) :
											 cnx_alert(1,CHEKOVFL2) ;
		}
	}	/* end if error */

	cnxvars[VAR_PTR]=i;			/* update data buffer index */
	cnxvars[ ptr[2]&0xFF ]= nactual;	/* # bytes received */

	switch (what_to_do)
	{
		case 1:				/* stop */
		cnxvars[VAR_ERR]=1;
		break;

		case 2:				/* continue */
		break;

		case 3:				/* exit loop */
		cnxloopx--;
		nextcnx= loopstruct.end[cnxloopx];
	}

}	/* end ge_recvdata() */

ge_trandata(ptr)
register char *ptr;
{
	long nbytes,termbyte,nterm,nactual,i;
	int error,what_to_do=2;
	unsigned int midibyte;
	char midistr;
	int flickphase=0;

	asm {
		move.l	ptr,a0
		addq.w	#4,a0
		jsr		val_of_cv
		move.l	d0,nbytes(a6)

		move.l	ptr,a0
		adda.w	#10,a0
		jsr		val_of_cv
		andi.l	#0xFF,d0
		move.l	d0,termbyte(a6)

		move.l	ptr,a0
		adda.w	#16,a0
		jsr		val_of_cv
		move.l	d0,nterm(a6)
	}

	error=0;								/* no error yet */
	nactual= 0L;						/* # bytes transmitted */
	i= cnxvars[VAR_PTR];				/* index into data buffer */

	while (1)
	{
		if (error=key_break()) break;
		midibyte= cnxdata[i++];
		if (midibyte==(END_OF_DATA&0x00FF)) { error=2; break; }
		midistr=midibyte;
		send_midi(&midistr,1);
		if (cnxflicker)
		{
			xorchar(FLICKERX1,1);
			flickphase ^= 1;
		}
		nactual++;
		if (nactual==nbytes) break;
		if (midibyte==termbyte)
			if ( (--nterm) <= 0 ) break;
		if (i>=cnxvars[VAR_DLN]) { error=2; break; }
	}
	if (flickphase) xorchar(FLICKERX1,1);

	if (error==1)	/* key was typed */
	{
		what_to_do= cnxloopx ? cnx_alert(1,CHEKSTOP3) :
										 cnx_alert(1,CHEKSTOP2) ;
	}
	if (error==2)	/* data buffer underflowed */
	{
		what_to_do= cnxloopx ? cnx_alert(1,CHEKUNFL3) :
										 cnx_alert(1,CHEKUNFL2) ;
	}

	cnxvars[VAR_PTR]= i;					/* update data buffer index */
	cnxvars[ ptr[2]&0xFF ]= nactual;	/* # bytes transmitted */

	switch (what_to_do)
	{
		case 1:				/* stop */
		cnxvars[VAR_ERR]=1;
		break;

		case 2:				/* continue */
		break;

		case 3:				/* exit loop */
		cnxloopx--;
		nextcnx= loopstruct.end[cnxloopx];
	}

}	/* end ge_trandata() */

ge_peekdata(ptr)
char *ptr;
{
	ge_peek(ptr,cnxvars[VAR_DLN],BADPEEKD,cnxdata);
}	/* end ge_peekdata() */

ge_peekpatch(ptr)
char *ptr;
{
	ge_peek(ptr,cnxvars[VAR_ELN],BADPEEKP,cnxpatch);
}	/* end ge_peekpatch() */

ge_peek(ptr,len,badpeek,start)
register char *ptr;
long len;
char *badpeek,*start;
{
	register long offset,val;
	int size;

	asm {
		move.l	ptr,a0
		addq.w	#4,a0
		jsr		val_of_cv
		move.l	d0,offset
	}
	switch (ptr[3])
	{
		case   0:	/* PeekTable does this */
		case 'B': size=1;	break;
		case 'W': size=2; break;
		case 'L': size=4;
	}
	offset *= size;
	if ( (offset+size) > len )
		cnxvars[VAR_ERR]= cnx_alert(1,badpeek)==1 ;
	else
	{
		switch (size)
		{
			case 1: val= start[offset] & 0x000000ffL; 			break;
			case 2: val= *(int*)(start+offset) & 0x0000ffffL;	break;
			case 4: val= *(long*)(start+offset);
		}
		cnxvars[ptr[2]&0xFF]= val;
	}
}	/* end ge_peek() */

ge_pokedata(ptr)
char *ptr;
{
	ge_poke(ptr,cnxvars[VAR_DLN],BADPOKED,cnxdata);
}	/* end ge_pokedata() */

ge_pokepatch(ptr)
char *ptr;
{
	ge_poke(ptr,cnxvars[VAR_ELN],BADPOKEP,cnxpatch);
}	/* end ge_pokepatch() */

ge_poke(ptr,len,badpoke,start)
register char *ptr;
long len;
char *badpoke,*start;
{
	register long offset,val;
	int size;

	asm {
		move.l	ptr,a0
		addq.w	#4,a0
		jsr		val_of_cv
		move.l	d0,offset

		move.l	ptr,a0
		adda.w	#10,a0
		jsr		val_of_cv
		move.l	d0,val
	}
	switch (ptr[2])
	{
		case 'B': size=1; break;
		case 'W': size=2; break;
		case 'L': size=4;
	}
	offset *= size;
	if ( (offset+size-1) > len )
		cnxvars[VAR_ERR]= cnx_alert(1,badpoke)==1 ;
	else
	{
		if ( (size==1) && (val&0xffffff00L) ) size= -1;
		if ( (size==2) && (val&0xffff0000L) ) size= -1;
		if (size<0)
			cnxvars[VAR_ERR]= cnx_alert(1,BADPOKESIZ)==1 ;		
		else
		{
			switch (size)
			{
				case 1: start[offset]= val;				break;
				case 2: *(int*)(start+offset)= val;		break;
				case 4: *(long*)(start+offset)= val;
			}
		}
	}
}	/* end ge_poke() */

ge_receive(ptr)
register char *ptr;
{
	long nbytes,nactual;
	char *str_ptr,*expptr,*gotptr;
	unsigned int got_str[16];
	int error,what_to_do;
	unsigned int midibyte,verifybyte;
	register int i;
	int flickphase=0;

	nbytes= ptr[3];		/* max # bytes to receive */
	str_ptr= ptr+4;		/* verify string */
	error=0;					/* no error yet */
	nactual= 0L;			/* # bytes received */

	if (midiovfl) /* set in interrupt */
	{
		cnx_alert(1,BADOVFL);
		cnxvars[VAR_ERR]=1;
		return;
	}

	while (1)
	{
		if (error=key_break()) break;
		midibyte= get_midi();
		if (midibyte!=0xFF)
		{
			if (cnxflicker)
			{
				xorchar(FLICKERX0,1);
				flickphase ^= 1;
			}
			got_str[nactual]= midibyte;
			verifybyte= str_ptr[nactual++];
			if ((verifybyte!=0xFF)&&(midibyte!=verifybyte)) { error=2; break; }
			if (nactual==nbytes) break;
		}
	}

	if (flickphase) xorchar(FLICKERX0,1);

	what_to_do=VERYCONT;	/* no error = continue */
	if (error==1)	/* key was typed */
	{
		what_to_do= cnxloopx ? cnx_alert(1,CHEKSTOP3) :
										 cnx_alert(1,CHEKSTOP2) ;
		if (what_to_do==1) what_to_do= VERYSTOP;
		if (what_to_do==2) what_to_do= VERYCONT;
		if (what_to_do==3) what_to_do= VERYEXIT;
	}
	if (error==2)	/* verify failed */
	{
		expptr= veryaddr[VERYEXP].ob_spec;
		gotptr= veryaddr[VERYGOT].ob_spec;
		expptr[0]= gotptr[0]= 0;
		for (i=0; i<nactual; i++)
		{
			verifybyte= str_ptr[i];
			strcat(expptr,hextext[verifybyte]); strcat(expptr," ");
			strcat(gotptr,hextext[got_str[i]]); strcat(gotptr," ");
		}
		if (cnxloopx)
			veryaddr[VERYEXIT].ob_flags &= ~HIDETREE;
		else
			veryaddr[VERYEXIT].ob_flags |= HIDETREE;
		if (cnxkillmouse) mouse_enable(1);
		what_to_do= do_dial(veryaddr,-1);
		if (cnxkillmouse) mouse_enable(0);
		reset_midi();
	}

	cnxvars[ ptr[2]&0xFF ]= nactual;	/* # bytes received */

	switch (what_to_do)
	{
		case VERYSTOP:			/* stop */
		cnxvars[VAR_ERR]=1;
		break;

		case VERYCONT:			/* continue */
		break;

		case VERYEXIT:			/* exit loop */
		cnxloopx--;
		nextcnx= loopstruct.end[cnxloopx];
		break;

		case VERYRTRY:			/* retry */
		nextcnx=ptr;
	}

}	/* end ge_receive() */

ge_transmit(ptr)
register char *ptr;
{
	long nbytes,nactual;
	int error,what_to_do=2;
	int flickphase=0;
	char *str_ptr;

	nbytes= ptr[3];		/* # bytes to transmit */
	str_ptr= ptr+4;		/* bytes to transmit */
	error=0;					/* no error yet */
	nactual= 0L;			/* # bytes transmitted */

	while (1)
	{
		if (error=key_break()) break;
		send_midi(str_ptr,1);
		str_ptr++;
		if (cnxflicker)
		{
			xorchar(FLICKERX1,1);
			flickphase ^= 1;
		}
		nactual++;
		if (nactual==nbytes) break;
	}

	if (flickphase) xorchar(FLICKERX1,1);

	if (error==1)	/* key was typed */
	{
		what_to_do= cnxloopx ? cnx_alert(1,CHEKSTOP3) :
										 cnx_alert(1,CHEKSTOP2) ;
	}

	cnxvars[ ptr[2]&0xFF ]= nactual;	/* # bytes transmitted */

	switch (what_to_do)
	{
		case 1:				/* stop */
		cnxvars[VAR_ERR]=1;
		break;

		case 2:				/* continue */
		break;

		case 3:				/* exit loop */
		cnxloopx--;
		nextcnx= loopstruct.end[cnxloopx];
	}

}	/* end ge_transmit() */

ge_getkey(ptr)
register char *ptr;
{
	int key;

	/* enable mouse, wait til buttons both up, clear keyboard buffer */
	HIDEMOUSE;
	if (cnxkillmouse) mouse_enable(1);
	waitmouse();
	*keyb_head= *keyb_tail;

	/* wait for key press or button click */
	key=0;
	while (!key)
	{
		if (*keyb_head != *keyb_tail)
		{
			key= Crawcin()&0xffL;
			if (!key) key= 0x1B;		/* non-ascii = esc */
		}
		else
		{
			key= (*Mstate)&3;
			if (key==1) key=0x0D;	/* L-click = return */
			if (key==2) key=0x1B;	/* R-click = esc */
		}
	}
	cnxvars[ ptr[2]&0xFF ]= key;
	waitmouse();
	if (cnxkillmouse) mouse_enable(0);
	SHOWMOUSE;
	reset_midi();	/* midi buffer not serviced during user-input */
}	/* end ge_getkey() */

ge_openwind(ptr)
char *ptr;
{
	register int i,j;
	register long *fromptr,*toptr;

	if (cnxopenwind) return;	/* window already open */

	HIDEMOUSE;
	fromptr= (long*)(scrbase+SCRLENG/4);
	toptr=	(long*)(cnxscrsave);
	j= 20*(3-rez);
	fromptr += (j/4);
	j/=2;
	for (i= 200/(3-rez); i>0; i--,fromptr+=j)
	{
		asm { move.w j,-(a7) }
		for (; j>0; j--) *toptr++ = *fromptr++;
		asm { move.w (a7)+,j }
	}
	cnxopenwind=1;
	cnxhomex= 160/charw + 1;		/* column # */
	cnxhomey= 50*rez + 1;			/* pixel # */
	ge_clrwind(&dummy);
	SHOWMOUSE;

}	/* end ge_openwind() */

ge_closewind(ptr)
char *ptr;
{
	register int i,j;
	register long *fromptr,*toptr;

	if (!cnxopenwind) return;	/* window already closed */

	HIDEMOUSE;
	toptr= (long*)(scrbase+SCRLENG/4);
	fromptr= (long*)(cnxscrsave);
	j= 20*(3-rez);
	toptr += (j/4);
	j/=2;
	for (i= 200/(3-rez); i>0; i--,toptr+=j)
	{
		asm { move.w j,-(a7) }
		for (; j>0; j--) *toptr++ = *fromptr++;
		asm { move.w (a7)+,j }
	}
	SHOWMOUSE;
	cnxopenwind=0;

}	/* end ge_closewind() */

ge_print(ptr)
register char *ptr;
{
	register int x,y;

	if (!cnxopenwind) return;	/* window not open */
	asm {
		move.l	ptr,a0
		addq.w	#2,a0
		jsr		val_of_cv
		move.l	d0,y

		move.l	ptr,a0
		addq.w	#8,a0
		jsr		val_of_cv
		move.l	d0,x
	}
	if ((x<0)||(x>MAXCURX))
	{
		cnxvars[VAR_ERR]= cnx_alert(1,BADCURSX)==1 ;
		return;
	}
	if ((y<0)||(y>MAXCURY))
	{
		cnxvars[VAR_ERR]= cnx_alert(1,BADCURSY)==1 ;
		return;
	}
	cnx_text(ptr+14,x,y);

}	/* end ge_print() */

ge_prntvar(ptr)
register char *ptr;
{
	long val;
	unsigned int byte[4];
	register int x,y;
	char buf[48];

	if (!cnxopenwind) return;	/* window not open */
	val= cnxvars[ ptr[2]&0xFF ];		/* value to be printed */
	for (x=0; x<4; x++) byte[3-x]= (val>>(8*x))&0xFF;	/* bytes in the long */
	switch (ptr[3])
	{
		case 'D':					/* decimal */
		ltoa(val&0x7FFFFFFF,buf,-1);
		break;

		case 'B':					/* binary */
		buf[0]= '%';
		y=1;
		for (x=0; x<4; x++)
		{
			if (byte[x]||(x==3))
			{
				btoa(byte[x],&buf[y]);
				y+=8;
			}
		}
		buf[y]=0;
		break;

		case 'A':					/* ascii */
		for (x=y=0; x<4; x++) if (byte[x]) buf[y++]=byte[x];
		buf[y]=0;
		break;

		case 'P':					/* patch */
		if (!itop((int)(val)&0xFF,cnxpnumfmt,buf)) strcpy(buf,UNDEFPFMT);
		break;

		default:						/* hex */
		buf[0]='$';
		buf[1]=0;
		for (x=0; x<4; x++) strcat(buf,hextext[byte[x]]);
	}

	asm {
		move.l	ptr,a0
		addq.w	#4,a0
		jsr		val_of_cv
		move.l	d0,y

		move.l	ptr,a0
		adda.w	#10,a0
		jsr		val_of_cv
		move.l	d0,x
	}
	if ((x<0)||(x>MAXCURX))
	{
		cnxvars[VAR_ERR]= cnx_alert(1,BADCURSX)==1 ;
		return;
	}
	if ((y<0)||(y>MAXCURY))
	{
		cnxvars[VAR_ERR]= cnx_alert(1,BADCURSY)==1 ;
		return;
	}
	cnx_text(buf,x,y);

}	/* end ge_prntvar() */

ge_clrwind(ptr)
register char *ptr;
{
	register long *lptr;
	register int i,j;
	int xy[10];

	if (!cnxopenwind) return;	/* window not open */

	HIDEMOUSE;
	lptr= (long*)(scrbase+SCRLENG/4);
	j= 20*(3-rez);
	lptr += (j/4);
	j/=2;
	for (i= 200/(3-rez); i>0; i--,lptr+=j)
	{
		asm { move.w j,-(a7) }
		for (; j>0; j--) *lptr++ = 0L;
		asm { move.w (a7)+,j }
	}
	/* cosmetic border around it */
	vs_clip(gl_hand,0,0L);	/* no clipping */
	xy[8]= xy[6]= xy[0]= 160;
	xy[9]= xy[3]= xy[1]= 50*rez;
	xy[4]= xy[2]= 160 + 320 - 1;
	xy[7]= xy[5]= 150*rez - 2;
	v_pline(gl_hand,5,xy);

	SHOWMOUSE;

}	/* end ge_clrwind() */

ge_clrline(ptr)
register char *ptr;
{
	register int y;
	char buf[80];

	if (!cnxopenwind) return;	/* window not open */
	asm {
		move.l	ptr,a0
		addq.w	#2,a0
		jsr		val_of_cv
		move.l	d0,y
	}
	if ((y<0)||(y>MAXCURY))
	{
		cnxvars[VAR_ERR]= cnx_alert(1,BADCURSY)==1 ;
		return;
	}
	set_bytes(buf,79L,' ');
	buf[79]=0;
	cnx_text(buf,0,y);	/* gets clipped at right edge */

}	/* end ge_clrline() */

ge_input(ptr)
char *ptr;
{
	get_x(ptr,999,ptr+22,0);
}	/* end ge_input() */

ge_getpatch(ptr)
char *ptr;
{
	/* input in current patch numbering format !!! (PACHPROMPT must change) */
	/* requires valid cnxpnumfmt during all exec_cnx() calls !!! */

	get_x(ptr,127,PACHPROMPT,1);
}	/* end ge_getpatch() */

ge_getchan(ptr)
char *ptr;
{
	get_x(ptr,15,CHANPROMPT,1);
}	/* end ge_getchan() */

get_x(ptr,max_val,prompt,offset)
register char *ptr;
int max_val;
char *prompt;
int offset;
{
	register int x,y,def;
	int waswindopen;

	asm {
		move.l	ptr,a0
		addq.w	#4,a0
		jsr		val_of_cv
		move.l	d0,y

		move.l	ptr,a0
		adda.w	#10,a0
		jsr		val_of_cv
		move.l	d0,x

		move.l	ptr,a0
		adda.w	#16,a0
		jsr		val_of_cv
		move.l	d0,def
	}

	waswindopen=cnxopenwind;
	if (!waswindopen) ge_openwind();

	if ( (x<0) || (x>MAXCURX) )
		cnxvars[VAR_ERR]= cnx_alert(1,BADCURSX)==1 ;
	if ( (y<0) || (y>MAXCURY) )
		cnxvars[VAR_ERR]= cnx_alert(1,BADCURSY)==1 ;

	if (!cnxvars[VAR_ERR])
	{
		def= get_val(prompt,x,y,def+offset,offset,max_val+offset);
		if (def<0)	/* input aborted */
			cnxvars[VAR_ERR]=1;
		else
			cnxvars[ ptr[2]&0xFF ]= def-offset;
	}

	if (!waswindopen) ge_closewind();

}	/* end get_x() */

/* returns value or -1 for cancel */

get_val(prompt,x,y,def_val,min_val,max_val)
char *prompt;
int x,y,def_val,min_val,max_val;
{
	register int ndigs,val,key,scan;
	char ch_buf[6];
	int done,first_time,mstate,val_x;
	long longkey;
	char buf[80];

	/* weird default value? */
	def_val= max(def_val,min_val);
	def_val= min(def_val,max_val);

	/* clear lines before prompting */
	set_bytes(buf,79L,' ');
	buf[79]=0;
	cnx_text(buf,0,y);
	cnx_text(buf,0,y+1);
	cnx_text(buf,0,y+2);

	/* don't get input if prompt is completely clipped */
	if (!cnx_text(prompt,x,y)) return -1;
   cnx_text(UNDOPROMPT,x,y+1);
   cnx_text(UNDOPRMPT2,x,y+2);
	val_x= x + strlen(prompt) + 1;

	if (cnxkillmouse) mouse_enable(1);
   HIDEMOUSE;
	waitmouse();

	first_time=1;
	val= def_val;
	val= max(val,min_val);
	val= min(val,max_val);
	ndigs= ndigits( (long)max_val );

	done=0;
	scan=0;
   while (!done)
   {
		itoa(val,ch_buf,ndigs);
		cnx_text(ch_buf,val_x,y);

		do
		{
			scan= -1;
			if ( *keyb_head != *keyb_tail )
			{
		      longkey= Crawcin();
				key= longkey&0xffL;
				scan= longkey>>16;
			}
			else
				if ( mstate= getmouse(&dummy,&dummy) )
					scan= mstate==1 ? SCAN_CR : SCAN_UNDO ;
		}
		while (scan<0);
		if (mstate) waitmouse();

		switch (scan)
		{
			case SCAN_CR:
			case SCAN_ENTER:
			if ((val<min_val)||(val>max_val))
				Cconout(7);
			else
				done=1;
			break;

			case SCAN_ESC:
			val= def_val;
			first_time=1;
			break;

			case SCAN_UNDO:
			done= -1;
			break;

			default:
			key -= '0';
   	   if ( (key>=0) && (key<=9) )
			{
      		key= first_time ? key : 10*val + key ;
				if (key<=max_val)
				{
					first_time=0;
					val=key;
				}
				else
					Cconout(7);
			}
			else
				Cconout(7);
		}	/* end switch (scan) */
   } /* end while !done */

   SHOWMOUSE;
	if (cnxkillmouse) mouse_enable(0);
	reset_midi();	/* midi buffer not serviced during user-input */

   return done<0 ? -1 : val ;

} /* end get_val() */

/* x and y converted to actual screen coords, string clipped */
/* returns 0= output completely clipped, 1= at least partly displayed */

cnx_text(str,x,y)
register char *str;	/* null term'd */
int x,y;					/* cnx window coords (col,row) */
{
	char buf[80];	/* oversized */
	register int i;

	if ((x<0)||(x>MAXCURX)) return 0;	/* x completely clipped */
	if ((y<0)||(y>MAXCURY)) return 0;	/* y completely clipped */
	strcpy(buf,str);
	buf[MAXCURX+1-x]=0;					/* clipped at right edge */
	gr_text(buf,cnxhomex+x,cnxhomey+charh*y);
	return 1;
}	/* end cnx_text() */

ge_bell(ptr)
char *ptr;
{
	Cconout(7);
}	/* end ge_bell() */

ge_patchnum(ptr)
register char *ptr;
{
	int npats,off;
	long bname;

	if (cnxpnum_i>=MAXNBANKS)
		cnxvars[VAR_ERR]= cnx_alert(1,BADNPNUMS)==1 ;
	else
	{
		bname= *(long*)(ptr+2);
		npats= ptr[6]&0xFF;
		off= ptr[7];
		if ((npats+cnxnpats)>MAXNPATS)
			cnxvars[VAR_ERR]= cnx_alert(1,BADNPATS)==1 ;
		else
		{
			cnxpnumfmt.npatches[cnxpnum_i]= npats;
			cnxpnumfmt.bankname[cnxpnum_i]= bname;
			cnxpnumfmt.offset[cnxpnum_i++]= off;
			cnxnpats += npats;
		}
	}

}	/* end ge_patchnum() */

ge_time(ptr)
register char *ptr;
{
	register long n;

	asm {
		move.l	ptr,a0
		addq.w	#2,a0
		jsr		val_of_cv
		move.l	d0,n
	}
	wait(5L*n);
}	/* end ge_time() */

ge_setport(ptr)
register char *ptr;
{
	;	/* no run-time errors !!! */
}	/* end ge_setport() */

ge_stop(ptr)
char *ptr;
{
	nextcnx= cnxend;
}	/* end ge_stop() */

ge_asm(ptr)
register char *ptr;
{
	; /* no run-time errors !!! */
}	/* end ge_asm() */

ge_label(ptr)
char *ptr;
{
	;	/* do nothing */
}	/* end ge_label() */

ge_buildtab(ptr)
register char *ptr;
{
	register int which,n;

	which= ptr[2]-1;	/* which table (0-15) */
	n= ptr[3];			/* string length (1-16) */

	/* check for table overflow */
	if ( (n+tabletotal) > TABLELENG )
		cnxvars[VAR_ERR]= cnx_alert(1,BADTABLENG)==1 ;
	else
	{
		insert_bytes((long)(n),ptr+4,
			cnxtables+tablestart[which]+tableleng[which],cnxtables+tabletotal);
		tabletotal += n;
		tableleng[which] += n;
		for (which++; which<NTABLES; which++) tablestart[which] += n;
	}
}	/* end ge_buildtab() */

ge_peektable(ptr)
register char *ptr;
{
	register int which;

	/* which table? */
	asm {
		move.l	ptr,a0
		adda.w	#10,a0
		jsr		val_of_cv
		move.w	d0,which
	}
	/* error if table # bad */
	if ((which<1)||(which>NTABLES))
	{
		cnxvars[VAR_ERR]= cnx_alert(1,BADTABLNUM)==1 ;
		return;
	}
	which--;
	/* error if table is clear */
	if (!tableleng[which])
	{
		cnxvars[VAR_ERR]= cnx_alert(1,BADTABLECLR)==1 ;
		return;
	}
	ge_peek(ptr,(long)tableleng[which],BADPEEKT,cnxtables+tablestart[which]);
}	/* end ge_peektable() */

ge_tranvar(ptr)
register char *ptr;
{
	char midibyte;

	midibyte= cnxvars[ ptr[2]&0xFF ];
	send_midi(&midibyte,1);
	if (cnxflicker)
	{
		xorchar(FLICKERX1,1);
		xorchar(FLICKERX1,1);
	}
}	/* end ge_tranvar() */

ge_comment(ptr)
char *ptr;
{
	;	/* do nothing */
}	/* end ge_comment() */

ge_recvany(ptr)
register char *ptr;
{
	int error,what_to_do;
	long nactual,nbytes;
	unsigned int midibyte;
	int flickphase=0;

	asm {
		move.l	ptr,a0
		addq.w	#4,a0
		jsr		val_of_cv
		move.l	d0,nbytes(a6)
	}
	error=0;
	nactual= 0L;

	if (midiovfl) /* set in interrupt */
	{
		cnx_alert(1,BADOVFL);
		cnxvars[VAR_ERR]=1;
		return;
	}

	while (1)
	{
		if (error=key_break()) break;
		midibyte= get_midi();
		if (midibyte!=0xFF)
		{
			if (cnxflicker)
			{
				xorchar(FLICKERX0,1);
				flickphase ^= 1;
			}
			nactual++;
			if (nactual==nbytes) break;
		}
	}

	if (flickphase) xorchar(FLICKERX0,1);

	if (error==1)	/* key was typed */
	{
		what_to_do= cnxloopx ? cnx_alert(1,CHEKSTOP3) :
										 cnx_alert(1,CHEKSTOP2) ;
	}
	else
		what_to_do= 2;		/* no error: continue */

	cnxvars[ ptr[2]&0xFF ]= nactual;	/* # bytes received */
	switch (what_to_do)
	{
		case 1:				/* stop */
		cnxvars[VAR_ERR]=1;
		break;

		case 2:				/* continue */
		break;

		case 3:				/* exit loop */
		cnxloopx--;
		nextcnx= loopstruct.end[cnxloopx];
	}

}	/* end ge_recvany() */

ge_loop(ptr)
register char *ptr;
{
	long initctr;

	/* check for loop overflow */
	if (cnxloopx==MAXLOOP)
	{
		cnx_alert(1,BADLOOPO);		
		cnxvars[VAR_ERR]=1;
		return;
	}

	/* init counter */
	asm {
		move.l	ptr,a0
		addq.w	#2,a0
		jsr		val_of_cv
		move.l	d0,initctr(a6)
	}

	loopstruct.start[cnxloopx]= nextcnx;
	loopstruct.end[cnxloopx]= *(char**)(ptr+8);
	loopstruct.initctr[cnxloopx]= initctr;
	loopstruct.ctr[cnxloopx++]= 0;

}	/* end ge_loop() */

ge_endloop(ptr)
char *ptr;
{
	int i;
	long initctr,ctr;
	char *start;

	if (key_abort()) return;

	/* check for loop underflow */
	if (!(i=cnxloopx))
	{
		cnx_alert(1,BADLOOPU);
		cnxvars[VAR_ERR]=1;
		return;
	}

	/* get info from loopstruct */
	i--;
	start= loopstruct.start[i];
	initctr= loopstruct.initctr[i];
	ctr= loopstruct.ctr[i];

	/* if infinite loop or count less than init count, branch back */
	ctr++;
	if ( !initctr || (ctr<initctr) )
	{
		loopstruct.ctr[i]= ctr;
		nextcnx= start;
		return;
	}

	/* else exit loop and continue at command after EndLoop */
	cnxloopx--;
}	/* end ge_endloop() */

ge_exitloop(ptr)
register char *ptr;
{
	unsigned int var;

	if (!cnxloopx)
		cnxvars[VAR_ERR]= cnx_alert(1,BADEXITLP)==1 ;
	else
	{
		var= ptr[2]&0xFF;
		if ( (var==VAR_DUM) || cnxvars[var] )
		{
			cnxloopx--;
			nextcnx= loopstruct.end[cnxloopx];
		}
	}
}	/* end ge_exitloop() */

ge_execute(ptr)
char *ptr;
{
	char *routine;
	register long n;
	register char *cdrptr,*foundptr;
	long ret_val,recleng;
	int callback();
	long tables[NTABLES];
	FILEHEADER *fileheader;
	RECHEADER *recheader;

	if (!heap[cdrmem].nbytes)
	{
		cnxvars[VAR_ERR]= cnx_alert(1,BADEXECUTE)==1 ;
		return;
	}

	routine= ptr+3;	/* --> null-term'd routine name */
	cdrptr= (char*)(heap[cdrmem].start) + sizeof(*fileheader);
	for (foundptr= (char*)(0L); !foundptr; )
	{
		recheader= (RECHEADER*)(cdrptr);
		/* CDR file contains only CDR records */
		if ( recheader->type != idCDR) break;
		/* length of routine */
		recleng= recheader->length;
		cdrptr += sizeof(*recheader);
		/* length of routine name (including null term) */
		n= strlen(cdrptr)+1;
		if (n&1) n++;
		if (!strcmp(cdrptr,routine)) foundptr= cdrptr+n;
		cdrptr= cdrptr + recleng;
	}

	/* routine not found */
	if (!foundptr)
	{
		cnxvars[VAR_ERR]= cnx_alert(1,BADEXECUTE)==1 ;
		return;
	}

	/* build array of tables */
	for (n=0; n<NTABLES; n++)
		tables[n]= (long)cnxtables + tablestart[n];
	asm {
		lea		tables(a6),a1
		movem.l	d4-d7/a2-a6,-(a7)
		move.l	foundptr,a0
		lea		cnxvars(a4),a6
		lea		cnxfuncs(a4),a5
		move.l	cnxdata(a4),a3
		move.l	cnxpatch(a4),a2
		lea		callback(PC),a4
		jsr		(a0)
		movem.l	(a7)+,d4-d7/a2-a6
		move.l	d0,ret_val(a6)
	}
	cnxvars[ ptr[2]&0xFF ]= ret_val;

}	/* end ge_execute() */

callback(ptr)		/* can be called from cdr routine */
char *ptr;
{
	asm {
		lea	saveA4(PC),a4
		move.l	(a4),a4
	}
	exec_1cnx(ptr);
}	/* end callback() */

/* get value of a constvar ..................................................*/

extern long val_of_cv();
asm {		/* called with a0 --> constvar */
val_of_cv:
	move.b	5(a0),d0
	cmpi.b	#VAR_DUM,d0
	beq		v_of_const
	andi.w	#0xFF,d0
	lsl.w		#2,d0	
	lea		cnxvars(a4),a0
	adda.w	d0,a0
v_of_const:
	move.l	(a0),d0
	rts
}	/* end val_of_cv() */

/* d0.l = d0.l oper(d2.b) d1.l ..............................................*/

extern long oper_d0d1();
asm {
oper_d0d1:
	cmpi.b	#0,d2
	bne		oper_1
	add.l		d1,d0
	rts
oper_1:
	cmpi.b	#1,d2
	bne		oper_2
	sub.l		d1,d0
	rts
oper_2:
	cmpi.b	#2,d2
	bne		oper_3
	mulu		d1,d0
	rts
oper_3:
	cmpi.b	#3,d2
	bne		oper_4
	tst.w		d1
	beq		div_by_0
	divu		d1,d0
	andi.l	#0xFFFF,d0	; no remainder
	rts
oper_4:
	cmpi.b	#4,d2
	bne		oper_5
	divu		d1,d0
	lsr.l		#8,d0
	lsr.l		#8,d0			; remainder
	rts
oper_5:
	cmpi.b	#5,d2
	bne		oper_6
	or.l		d1,d0
	rts
oper_6:
	cmpi.b	#6,d2
	bne		oper_7
	and.l		d1,d0
	rts
oper_7:
	cmpi.b	#7,d2
	bne		oper_8
	eor.l		d1,d0
	rts
oper_8:
	cmpi.b	#8,d2
	bne		oper_9
	andi.l	#0x1F,d1
	lsr.l		d1,d0
	rts
oper_9:
	andi.l	#0x1F,d1
	lsl.l		d1,d0
	rts
div_by_0:
	st			divbyzero(a4)
	rts
}	/* end oper_d0d1() */

/* alert box with mouse enable/disable and reset midi .......................*/
/* returns same thing form_alert() would */

cnx_alert(i,str)
int i;
char *str;
{
	int savehide;

	if (cnxkillmouse) mouse_enable(1);
	savehide= *(int*)(Abase-598);
	while (*(int*)(Abase-598)) { SHOWMOUSE; }
	i= form_alert(i,str);
	while (*(int*)(Abase-598)<savehide) { HIDEMOUSE; }
	if (cnxkillmouse) mouse_enable(0);
	reset_midi();
	return i;
}	/* end cnx_alert() */

/* build cnx command handler jump table .....................................*/
/* note: this has to be after all the cnx command handlers */

extern init_funcs();
asm {
init_funcs:
	lea cnxfuncs(a4),a0
	lea ge_nop(PC),a1				move.l a1,(a0)+
	lea ge_invert(PC),a1			move.l a1,(a0)+
	lea ge_neg(PC),a1				move.l a1,(a0)+
	lea ge_not(PC),a1				move.l a1,(a0)+
	lea ge_assign(PC),a1			move.l a1,(a0)+
	lea ge_logic(PC),a1			move.l a1,(a0)+
	lea ge_rel(PC),a1				move.l a1,(a0)+
	lea ge_goto(PC),a1			move.l a1,(a0)+
	lea ge_gosub(PC),a1			move.l a1,(a0)+
	lea ge_exitloop(PC),a1		move.l a1,(a0)+
	lea ge_return(PC),a1			move.l a1,(a0)+
	lea ge_speed(PC),a1			move.l a1,(a0)+
	lea ge_filter(PC),a1			move.l a1,(a0)+
	lea ge_setport(PC),a1		move.l a1,(a0)+
	lea ge_recvdata(PC),a1		move.l a1,(a0)+
	lea ge_trandata(PC),a1		move.l a1,(a0)+
	lea ge_peekdata(PC),a1		move.l a1,(a0)+
	lea ge_pokedata(PC),a1		move.l a1,(a0)+
	lea ge_receive(PC),a1		move.l a1,(a0)+
	lea ge_transmit(PC),a1		move.l a1,(a0)+
	lea ge_getkey(PC),a1			move.l a1,(a0)+
	lea ge_openwind(PC),a1		move.l a1,(a0)+
	lea ge_closewind(PC),a1		move.l a1,(a0)+
	lea ge_clrwind(PC),a1		move.l a1,(a0)+
	lea ge_print(PC),a1			move.l a1,(a0)+
	lea ge_prntvar(PC),a1		move.l a1,(a0)+
	lea ge_clrline(PC),a1		move.l a1,(a0)+
	lea ge_input(PC),a1			move.l a1,(a0)+
	lea ge_getpatch(PC),a1		move.l a1,(a0)+
	lea ge_getchan(PC),a1		move.l a1,(a0)+
	lea ge_bell(PC),a1			move.l a1,(a0)+
	lea ge_getport(PC),a1		move.l a1,(a0)+
	lea ge_endloop(PC),a1		move.l a1,(a0)+
	lea ge_pokepatch(PC),a1		move.l a1,(a0)+
	lea ge_peekpatch(PC),a1		move.l a1,(a0)+
	lea ge_patchnum(PC),a1		move.l a1,(a0)+
	lea ge_time(PC),a1			move.l a1,(a0)+
	lea ge_stop(PC),a1			move.l a1,(a0)+
	lea ge_asm(PC),a1				move.l a1,(a0)+
	lea ge_label(PC),a1			move.l a1,(a0)+
	lea ge_event(PC),a1			move.l a1,(a0)+
	lea ge_tranvar(PC),a1		move.l a1,(a0)+
	lea ge_comment(PC),a1		move.l a1,(a0)+
	lea ge_recvany(PC),a1		move.l a1,(a0)+
	lea ge_loop(PC),a1			move.l a1,(a0)+
	lea ge_dtod(PC),a1			move.l a1,(a0)+
	lea ge_dtop(PC),a1			move.l a1,(a0)+
	lea ge_ptod(PC),a1			move.l a1,(a0)+
	lea ge_ptop(PC),a1			move.l a1,(a0)+
	lea ge_buildtab(PC),a1		move.l a1,(a0)+
	lea ge_peektable(PC),a1		move.l a1,(a0)+
	lea ge_execute(PC),a1		move.l a1,(a0)+
	rts
}	/* end init_funcs() */

/* (dis)connect loops and endloops ..........................................*/
/* returns 1= error, 0= ok */

set_loops(start,end,flag)
char *start,*end;
int flag;	/* 1= connect, 0= disconnect */
{
	register char *ptr;
	int cmd,error=0;

	for (ptr=start; !error&&(ptr<end); )
	{
		cmd= ptr[0];										/* byte 0 is command */
		if (cmd==GE_LOOP) error= set_loop(ptr,end,flag);
		ptr += (ptr[1]&0xFF);							/* byte 1 is length */
	}
	return error;
}	/* end set_loops() */

/* returns 1= error, 0= ok */
set_loop(start,end,flag)
char *start,*end;
int flag;
{
	register char *ptr;
	int level=0;
	int error=1;
	int cmd;

	for (ptr=start+(start[1]&0xFF); ptr<end; )
	{
		cmd= ptr[0];
		ptr += (ptr[1]&0xFF);
		if (cmd==GE_LOOP) level++;
		if (cmd==GE_ENDLOOP)
		{
			if (!level)
			{
				error=0;
				break;
			}
			level--;
		}
	}
	if (!error) *(long*)(start+8)= flag ? (long)(ptr) : 0L ;
	return error;
}	/* end set_loop() */

/* abort on key .............................................................*/
/* returns 1= abort */

key_abort()
{
	register int abort;

	abort= key_break();
	if (abort) abort = cnx_alert(1,CHEKSTOP2)==1 ;
	cnxvars[VAR_ERR] |= abort;
	return abort;
}	/* end key_abort() */

/* returns 1= special break key typed, else 0 ...............................*/

key_break()
{
	return *keyb_head != *keyb_tail ? (Crawcin()&0xffL)==ASCIBREAK : 0 ;
}	/* end key_break() */

#endif

/* EOF */
