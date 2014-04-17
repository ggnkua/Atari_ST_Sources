/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                          Copyright 1990 Tom Bajoras

	module CNXTOKEN : CNX utilities and tokenizer/detokenizer

	findcnxseg, print_cnx
	detoken_seg, _detoken_seg,	detoken_line, detoken_cv, detoken_var
	token_seg, token_line

******************************************************************************/

overlay "cnx"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */

/* local globals ............................................................*/

/* dedicated CNX variable names -- don't ever use last one (dummy) */
char *cnxdedvar[NVARS-100]= {
	"PAT","CHN","PTR","   ","NMO","NML","EBL","ERR","   ","   ",
	"   ","   ","   ","   ","   ","   ","   ","   ","   ","   ",
	"   ","   ","   ","   ","   ","   ","   ","   ","   ","   ",
	"   ","   ","   ","   ","   ","   ","   ","   ","   ","   ",
	"   ","   ","   ","   ","   ","   ","   ","   ","   ","   ",
	"   ","   ","   ","   ","   ","   ","   ","   ","   ","   ",
	"   ","   ","   ","   ","   ","   ","   ","   ","   ","   ",
	"   ","   ","   ","   ","   ","   ","   ","   ","   ","   ",
	"   ","   ","   ","   ","   ","   ","   ","   ","   ","   ",
	"   ","   ","   ","   ","   ","   ","   ","   ","   ","   ",
	"DLN","ELN","LPO","LPV","   ","   ","   ","   ","   ","   ",
	"   ","   ","   ","   ","   ","   ","   ","   ","   ","   ",
	"   ","   ","   ","   ","   ","   ","   ","   ","   ","   ",
	"   ","   ","   ","   ","   ","   ","   ","   ","   ","   ",
	"   ","   ","   ","   ","   ","   ","   ","   ","   ","   ",
	"   ","   ","   ","   ","   ","   "
};
char *cnxcmds[NCNXCMDS]= {	/* cnx command names (blank ones not displayed) */
	"NOP","Invert","NEG","NOT"," "," "," ","GoTo",
	"GoSub","ExitLoop","Return","SetSpeed","SetFilter","SetPorts",
	"ReceiveData","TransmitData","PeekData","PokeData","Receive",
	"Transmit","GetKey","OpenWindow","CloseWindow","ClearWindow",
	"Print","PrintVar","ClearLine","InputVar","InputPatch",
	"InputChannel","Bell","Format","EndLoop","PokeEdit","PeekEdit",
	"FormatBank","Wait","Stop","ASM"," ","WaitEvent","TransmitVar",
	" ","ReceiveAny","Loop","CopyDtoD","CopyDtoE","CopyEtoD",
	"CopyEtoE","BuildTable","PeekTable","Execute"
};
char *cnxCmds[NCNXCMDS]= {	/* cnx command names uppercase */
	"NOP","INVERT","NEG","NOT"," "," "," ","GOTO",
	"GOSUB","EXITLOOP","RETURN","SETSPEED","SETFILTER","SETPORTS",
	"RECEIVEDATA","TRANSMITDATA","PEEKDATA","POKEDATA","RECEIVE",
	"TRANSMIT","GETKEY","OPENWINDOW","CLOSEWINDOW","CLEARWINDOW",
	"PRINT","PRINTVAR","CLEARLINE","INPUTVAR","INPUTPATCH",
	"INPUTCHANNEL","BELL","FORMAT","ENDLOOP","POKEEDIT","PEEKEDIT",
	"FORMATBANK","WAIT","STOP","ASM"," ","WAITEVENT","TRANSMITVAR",
	" ","RECEIVEANY","LOOP","COPYDTOD","COPYDTOE","COPYETOD",
	"COPYETOE","BUILDTABLE","PEEKTABLE","EXECUTE"
};
char cnx_lvar[NCNXCMDS]= {	/* whether command has an lvar */
	0,1,1,1,1,1,1,0,0,0,
	0,0,0,0,1,1,1,0,1,1,
	1,0,0,0,0,0,0,1,1,1,
	0,0,0,0,1,0,0,0,0,0,
	0,0,0,1,0,0,0,0,0,0,
	1,1
};
char cnxkeyword[NCNXCMDS]= {	/* 0= no keyword, 1= keyword, 2= "if"+keyword */
	1,1,1,1,0,0,0,2,2,2,
	1,1,1,1,1,1,1,1,1,1,
	1,1,1,1,1,1,1,1,1,1,
	1,1,1,1,1,1,1,1,1,0,
	1,1,0,1,1,1,1,1,1,1,
	1,1
};
char *operstr[10]= {				/* math operations */
	"+","-","*","/","%","|","&","^",">>","<<" } ;
char *logicstr[3]= {				/* logic operations */
	"AND","OR","XOR" };
char *relstr[6]=	 {				/* relational operations */
	"EQ","NE","LT","GT","LE","GE" };
char dquotestr[2]= { DQUOTE, 0 };

/* find start and end of a given cnx seg ....................................*/
/* returns 1= found it, 0= didn't find it */

findcnxseg(which,seg,start_out,end_out)
int which,seg;
long *start_out,*end_out;
{
#if CNXFLAG
	long start,end;

	start= heap[cnxmem].start;
	end= start + cnxoffset[which+1];
	start += cnxoffset[which];

	return _findcnxseg(seg,start,end,start_out,end_out);
#endif
}	/* end findcnxseg() */

_findcnxseg(seg,start,end,start_out,end_out)
int seg;
long start,end;
long *start_out,*end_out;
{
#if CNXFLAG
	register long *lptr;
	int result;

	/* find start and end of this segment */
	result=0;
	while ( !result && (start<end) )
	{
		lptr= (long*)(start);
		start += (8+lptr[1]);		/* start of next segment */
		result= (lptr[0]==seg);
	}
	if (result)
	{
		*end_out= start;
		*start_out= (long)(lptr)+8;
	}
	return result;
#endif
}	/* end _findcnxseg() */

/* print cnx slot ...........................................................*/

print_cnx(name,start,end)
char *name;				/* config name (not null term'd) */
long start,end;		/* --> cnx slot, --> 1st byte past cnx slot */
{
#if CNXFLAG
	register int temp,seg,i;
	char *segstart,*segend;
	char buf[CNXTOKENW];
	int loopdepth,cmd;
	static long segtype[NSEGTYPES]= {
		cnxINIT, cnxRECV, cnxTRAN, cnxDTOE,
		cnxETOD, cnxSEND, cnxGETP, cnxPUTP,
		cnxVLDT, cnxCMMN
	};

	waitmouse();
	temp=1;
	while ( !(temp=Cprnos()) )
		if (form_alert(1,BADPRINT)!=1) break;
	if (!temp) return;
	cprnwsrow=0;	/* reset pagination */

	/* config name */
	strcpy(buf,"-------- ");
	copy_bytes(name,buf+9,(long)(NCHPERCNX));
	buf[9+NCHPERCNX]=0;
	strcat(buf," --------");
	Cprnws(buf,0);

	menuprompt(NOWPRINTMSG);
	graf_mouse(BEE_MOUSE);
	for (i=0; i<NSEGTYPES; i++)
	{
		seg= segtype[i];
		if (_findcnxseg(seg,start,end,&segstart,&segend))
		{
			Cprnws("",1);
			Cprnws("",1);
			strcpy(buf,"      <<< ");
			strcat(buf,cnxsegname[seg]);
			strcat(buf," >>> ");
			Cprnws(buf,1);
			Cprnws("",1);
			loopdepth=0;
			while (segstart<segend)
			{
				/* mouse button aborts */
				if (getmouse(&dummy,&dummy)) goto endprint;
				cmd= segstart[0];
				if (cmd==GE_ENDLOOP) loopdepth= max(0,loopdepth-1);
				detoken_line(segstart,buf,loopdepth);
				/* chop off spaces at end of line */
				for (temp=CNXTOKENW-1; temp>0; temp--)
					if (buf[temp]==' ')
						buf[temp]=0;
					else
						break;
				temp= buf[80]; buf[80]=0;
				Cprnws(buf,1);
				if (temp)
				{
					buf[80]=temp;
					Cprnws(&buf[80],1);
				}
				if (cmd==GE_LOOP) loopdepth++;
				segstart += (segstart[1]&0xFF);			/* thread to next token */
			}
			if (cprnwsrow)
			{
				Cprnout(0x0C);	/* form feed after each segment */
				cprnwsrow=0;
			}
		}	/* end if seg found */
	}	/* end loop through all segs */

endprint:
	waitmouse();
	graf_mouse(ARROWMOUSE);
	menuprompt(0L);

#endif
}	/* end print_cnx() */

/* de-tokenize a segment ....................................................*/
/* returns # of tokens (>=0) */

detoken_seg(which,seg,max_n,ptr)
int which;					/* which cnx to detokenize (0 - (NCNX-1) ) */
int seg;						/* which seg to detokenize, cnxXXXX */
int max_n;					/* max # of tokens to detokenize, 0 means
                           count tokens but don't detokenize */
register char *ptr;		/* where to put result */
{
#if CNXFLAG
	long start,end;

	/* start and end of this config */
	if (!findcnxseg(which,seg,&start,&end)) return 0;

	return _detoken_seg(max_n,start,ptr,end-start);
#endif
}	/* end detoken_seg() */

_detoken_seg(max_n,start,toptr,length)
int max_n;					/* max # of tokens to detokenize (can be 0) */
char *start;				/* seg to detokenize */
register char *toptr;	/* where to put result */
long length;				/* # bytes in segment to be detokenized */
{
#if CNXFLAG
	register int i,count;
	register char *ptr;
	int cmd,loopdepth;
	char *end;

	/* end of this segment */
	end= start+length;

	/* count tokens */
	for (ptr=start,count=0; ptr<end;)
	{
		ptr += (ptr[1]&0xFF);
		count++;
	}

	/* detokenize the tokens */
	loopdepth=0;
	for (ptr=start,i=0; ptr<end; toptr+=CNXTOKENW)
	{
		if ( (max_n>=0) && (i==max_n) ) break;
		cmd= ptr[0];
		if (cmd==GE_ENDLOOP) loopdepth= max(0,loopdepth-1);
		detoken_line(ptr,toptr,loopdepth);
		i++;
		if (cmd==GE_LOOP) loopdepth++;
		ptr += (ptr[1]&0xFF);
	}

	return count;
#endif
}	/* end _detoken_seg() */

/* de-tokenize a token ......................................................*/
/* watch out for result longer than CNXTOKENW !!! */

detoken_line(fromptr,toptr,indent)
register char *fromptr;	/* start of token */
char *toptr;				/* where to put result */
int indent;					/* # levels nested */
{
#if CNXFLAG
	unsigned int cmd,lvar,leng;
	register int i,j;
	char tempbuf[CNXTOKENW],tempbuf2[CNXTOKENW];

	cmd= fromptr[0];						/* byte 0 = command # (always) */
	leng= (fromptr[1]&0xFF);			/* byte 1 = command length (always) */
	lvar= fromptr[2];						/* byte 2 = lvar (if there is an lvar) */

	if (cmd>=NCNXCMDS)	/* turn unknown command into a comment */
	{
		strcpy(toptr,UNKNOWNCMD);
		return;
	}

	/* start building source line */
	toptr[0]=0;

	/* indent inside loop, except comments */
	if (cmd!=GE_COMMENT) for (i=0; i<indent; i++) strcat(toptr,"  ");

	/* build left part of line */
	if (cnx_lvar[cmd]&&(lvar!=VAR_DUM))
	{
		detoken_var(fromptr+2,tempbuf);
		strcat(toptr,tempbuf);
		strcat(toptr,"= ");
	}

	/* build keyword part of line */
	i= cnxkeyword[cmd];
	if ( (i==2) && (lvar!=VAR_DUM) )
	{
		strcat(toptr,IF_MSG);
		detoken_var(fromptr+2,tempbuf);
		strcat(toptr,tempbuf);
	}
	if (i)
	{
		strcat(toptr,cnxcmds[cmd]);
		strcat(toptr," ");
	}

	/* build rest of line */
	tempbuf[0]=0; /* default: no more line */

	switch (cmd)
	{
		case GE_INVERT:
		case GE_NOT:
		detoken_var(fromptr+3,tempbuf);
		break;

		case GE_TRANVAR:
		detoken_var(fromptr+2,tempbuf);
		break;

		case GE_LOOP:
		case GE_CLRLINE:
		case GE_TIME:
		detoken_cv(fromptr+2,tempbuf);
		break;

		case GE_NEG:
		case GE_RECVANY:
		detoken_cv(fromptr+4,tempbuf);
		break;

		case GE_GOTO:
		case GE_GOSUB:
		case GE_LABEL:
		tempbuf[0]='L';
		itoa(fromptr[3],tempbuf+1,2);
		break;

		case GE_DTOD:
		case GE_DTOP:
		case GE_PTOD:
		case GE_PTOP:
		detoken_cv(fromptr+4,tempbuf);
		detoken_cv(fromptr+10,tempbuf2);
		strcat(tempbuf,tempbuf2);
		detoken_cv(fromptr+16,tempbuf2);
		strcat(tempbuf,tempbuf2);
		tempbuf2[0]=fromptr[2];
		tempbuf2[1]=0;
		strcat(tempbuf,tempbuf2);
		break;

		case GE_ASSIGN:
		detoken_cv(fromptr+4,tempbuf);
		i= fromptr[3]&0xFF;
		if (i!=255)
		{
			strcat(tempbuf,operstr[i]);
			strcat(tempbuf," ");
			detoken_cv(fromptr+10,tempbuf2);
			strcat(tempbuf,tempbuf2);
		}
		break;

		case GE_LOGIC:
		detoken_var(fromptr+3,tempbuf);
		strcat(tempbuf,logicstr[fromptr[5]]);
		strcat(tempbuf," ");
		detoken_var(fromptr+4,tempbuf2);
		strcat(tempbuf,tempbuf2);
		break;

		case GE_REL:
		detoken_var(fromptr+3,tempbuf);
		strcat(tempbuf,relstr[fromptr[10]]);
		strcat(tempbuf," ");
		detoken_cv(fromptr+4,tempbuf2);
		strcat(tempbuf,tempbuf2);
		break;

		case GE_RECVDATA:
		case GE_TRANDATA:
		case GE_GETPATCH:
		case GE_GETCHAN:
		detoken_cv(fromptr+4,tempbuf);
		detoken_cv(fromptr+10,tempbuf2);
		strcat(tempbuf,tempbuf2);
		detoken_cv(fromptr+16,tempbuf2);
		strcat(tempbuf,tempbuf2);
		break;

		case GE_RECEIVE:
		case GE_TRANSMIT:
		detoken_hex(fromptr[3],fromptr+4,tempbuf);
		break;

		case GE_BUILDTAB:
		itoa(fromptr[2],tempbuf,-1);
		strcat(tempbuf," ");
		detoken_dec(fromptr[3],fromptr+4,tempbuf2);
		strcat(tempbuf,tempbuf2);
		break;

		case GE_PEEKDATA:
		case GE_PEEKPATCH:
		detoken_cv(fromptr+4,tempbuf);
		tempbuf2[0]= fromptr[3];
		tempbuf2[1]= 0;
		strcat(tempbuf,tempbuf2);
		break;

		case GE_PEEKTABLE:
		detoken_cv(fromptr+10,tempbuf);
		detoken_cv(fromptr+4,tempbuf2);
		strcat(tempbuf,tempbuf2);
		break;

		case GE_POKEDATA:
		case GE_POKEPATCH:
		detoken_cv(fromptr+4,tempbuf);
		detoken_cv(fromptr+10,tempbuf2);
		strcat(tempbuf,tempbuf2);
		tempbuf2[0]= fromptr[2];
		tempbuf2[1]= 0;
		strcat(tempbuf,tempbuf2);
		break;

		case GE_SPEED:
		itoa(fromptr[2]&0xFF,tempbuf,-1);
		break;

		case GE_SETPORT:
		detoken_cv(fromptr+2,tempbuf);
		detoken_cv(fromptr+8,tempbuf2);
		strcat(tempbuf,tempbuf2);
		break;

		case GE_PRINT:
		detoken_cv(fromptr+2,tempbuf);
		detoken_cv(fromptr+8,tempbuf2);
		strcat(tempbuf,tempbuf2);
		strcat(tempbuf,dquotestr);
		strcat(tempbuf,fromptr+14);
		strcat(tempbuf,dquotestr);
		break;

		case GE_PRNTVAR:
		detoken_var(fromptr+2,tempbuf);
		tempbuf2[0]=fromptr[3];
		tempbuf2[1]=' ';
		tempbuf2[2]=0;
		strcat(tempbuf,tempbuf2);
		detoken_cv(fromptr+4,tempbuf2);
		strcat(tempbuf,tempbuf2);
		detoken_cv(fromptr+10,tempbuf2);
		strcat(tempbuf,tempbuf2);
		break;

		case GE_INPUT:
		detoken_cv(fromptr+4,tempbuf);
		detoken_cv(fromptr+10,tempbuf2);
		strcat(tempbuf,tempbuf2);
		detoken_cv(fromptr+16,tempbuf2);
		strcat(tempbuf,tempbuf2);
		tempbuf2[0]=fromptr[3];
		tempbuf2[1]=' ';
		tempbuf2[2]=0;
		strcat(tempbuf,tempbuf2);
		strcat(tempbuf,dquotestr);
		strcat(tempbuf,fromptr+22);
		strcat(tempbuf,dquotestr);
		break;

		case GE_PATCHNUM:
		j=0;
		tempbuf2[j++]=QUOTE;
		for (i=2; i<=5; i++)
			if (fromptr[i]) tempbuf2[j++]= fromptr[i];
		tempbuf2[j++]=QUOTE;
		tempbuf2[j]=0;
		strcat(tempbuf,tempbuf2);
		tempbuf2[0]=' ';
		itoa(fromptr[6]&0xFF,tempbuf2+1,-1);
		strcat(tempbuf,tempbuf2);
		tempbuf2[0]=' ';
		itoa(fromptr[7]&0xFF,&tempbuf2[1],-1);
		strcat(tempbuf,tempbuf2);
		break;

		case GE_FILTER:
		j=0;
		tempbuf2[j++]=QUOTE;
		i= fromptr[2];	/* filter mask */
		if (i&1) tempbuf2[j++]='R';
		if (i&2) tempbuf2[j++]='C';
		if (i&4) tempbuf2[j++]='P';
		if (i&8) tempbuf2[j++]='N';
		tempbuf2[j++]=QUOTE;
		tempbuf2[j++]=0;
		strcat(tempbuf,tempbuf2);
		tempbuf2[0]=' ';
		tempbuf2[1]= fromptr[3] ? '1' : '0' ;
		tempbuf2[2]=0;
		strcat(tempbuf,tempbuf2);
		break;

		case GE_EXECUTE:
		strcat(tempbuf,dquotestr);
		strcat(tempbuf,fromptr+3);
		strcat(tempbuf,dquotestr);
		break;

		case GE_ASM:
		case GE_EVENT:
		case GE_GETPORT:
		/* !!! */
		break;

		case GE_COMMENT:
		strcpy(tempbuf,";");
		strcat(tempbuf,fromptr+2);

	}	/* end switch (cmd) */

	/* append rest of line to start of line */
	strcat(toptr,tempbuf);

	/* source lines are space-padded out to end, no nulls */
	pad_str((int)CNXTOKENW-1,toptr,' ');
	toptr[CNXTOKENW-1]=' ';

#endif
}	/* end detoken_line() */

/* de-tokenize a constvar ...................................................*/

detoken_cv(cvptr,toptr)
CONSTVAR *cvptr;	/* constvar to be detokenized */
char *toptr;		/* where to put result */
{
#if CNXFLAG
	int j;
	long templong,div;
	unsigned int var,i,fmt;
	static char *digit[10]= { "0","1","2","3","4","5","6","7","8","9"};
	int leadzero=1;
	CONSTVAR cv;

	cv= *cvptr;
	templong= cv.const;
	fmt= cv.format;
	var= cv.var;

	if (var==VAR_DUM)	/* constant */
	{
		switch (fmt)
		{
			case 'H':		/* hex */
			toptr[0]='$'; toptr[1]=0;
			for (j=3; j>=0; j--)
			{
				i= (templong>>(8*j)) & 0xFF;
				if (i) leadzero=0;
				if (!leadzero || !j)		/* no leading 0's */
					strcat(toptr,hextext[i]);
			}
			break;

			case 'D':		/* decimal */
			toptr[0]=0;
			for (div=1000000000L; div>=1L; div/=10L)
			{
				i= templong/div;
				if (i) leadzero=0;
				if (!leadzero || (div==1L))		/* no leading 0's */
					strcat(toptr,digit[i]);
				templong-= (i*div);
			}
			break;

			case 'A':		/* ascii */
			j=1;
			toptr[0]=QUOTE;
			for (div=24; div>=0; div-=8)
			{
				i= (templong>>div)&0xFF;
				if (i) toptr[j++]=i;
			}
			toptr[j++]=QUOTE;
			toptr[j]=0;
			break;

			case 'B':
			toptr[0]= '%';
			j=1;
			for (div=24; div>=0; div-=8)
			{
				i= (templong>>div)&0xFF;
				if (i||!div)
				{
					btoa(i,&toptr[j]);
					j+=8;
				}
			}
			toptr[j]=0;

		}	/* end switch (fmt) */
		strcat(toptr," ");	/* space character after each constant field */
	}
	else				/* variable */
		detoken_var((long)(&var)+1,toptr);	/* includes ' ' at end */

#endif
}	/* end detoken_cv() */

/* de-tokenize a string of hex bytes ........................................*/

detoken_hex(n,fromptr,toptr)
int n;			/* # bytes in string */
char *fromptr;	/* bytes */
char *toptr;	/* where to put result */
{
#if CNXFLAG
	unsigned int val;
	char buf[8];

	toptr[0]=0;
	for (; n>0; n--)
	{
		val= *fromptr++;
		buf[0]='$';
		buf[1]=0;
		strcat(buf,hextext[val]);
		strcat(buf," ");
		strcat(toptr,buf);
	}
#endif
}	/* end detoken_hex() */

/* de-tokenize a decimal string .............................................*/

detoken_dec(n,fromptr,toptr)
int n;			/* # bytes in string */
char *fromptr;	/* bytes */
char *toptr;	/* where to put result */
{
#if CNXFLAG
	unsigned int val;
	char buf[8];

	toptr[0]=0;
	for (; n>0; n--)
	{
		val= *fromptr++;
		if (val>99)
			itoa(val,buf,3);
		else
			itoa(val,buf,2);
		strcat(buf," ");
		strcat(toptr,buf);
	}
#endif
}	/* end detoken_dec() */

/* de-tokenize a variable ...................................................*/

detoken_var(varptr,toptr)
char *varptr;
char *toptr;			/* where to put result */
{
#if CNXFLAG
	unsigned int var;

	var= *varptr;
	if (var<100)	/* general purpose variable */
	{
		toptr[0]='V';
		itoa(var,toptr+1,2);
	}
	else			/* dedicated variable (but not dummy) */
		if (var!=VAR_DUM) strcpy(toptr,cnxdedvar[var-100]);

	strcat(toptr," ");	/* space character after each variable field */
#endif
}	/* end detoken_var() */

/* tokenize a segment ......................................................*/
/* returns bad token #, -1 for all tokens ok */

token_seg(fromptr,toptr,nlines,flag,leng)
register char *fromptr;	/* --> source lines to be tokenized */
register char *toptr;	/* --> where to put result (invalid if !flag) */
int nlines;		/* how many lines to tokenize */
int flag;		/* 1= tokenize, 0= parse only */
					/* toptr= 0L instead of flag=0 !!! */
long *leng;		/* resulting # bytes in all tokens (even) */
{
#if CNXFLAG
	register int i,n;
	register long result=0L;
	unsigned int lastcmd;

	for (i=0; i<nlines; i++,fromptr+=CNXTOKENW)
	{
		n= token_line(fromptr,toptr,flag,&lastcmd);
		if (!n) break;		/* bad line: won't tokenize */
		result += n;
		toptr += n;
	}
	if (i==nlines) i= -1;		/* no bad tokens */
	*leng= result;
	return i;
#endif
}	/* end token_seg() */

/* tokenize a line .........................................................*/
/* returns 0= error, non-0 = # bytes in resulting token */

token_line(fromptr,toptr,flag,cmd_out)
register char *fromptr;		/* --> line of source code to be tokenized */
					/* source is CNXTOKENW chars, space-padded on right */
char *toptr;					/* --> where to put result */
int flag;						/* 1= tokenize, 0= parse only */
									/* toptr= 0L instead of flag=0 !!! */
int *cmd_out;
{
#if CNXFLAG
	char *tempbuf[CNXTOKENW];
	char **fieldstart,**fieldend;
	char fieldtype[CNXTOKENW/2];
	long fieldval[CNXTOKENW/2];
	char frombuf[CNXTOKENW];
	long field_val();
	int nfields,ch,cmd;
	register int i,temp;
	register char *ptr;
	int result=0;

	copy_bytes(fromptr,frombuf,CNXTOKENW);
	fromptr=frombuf;

	/* divide tempbuf into two arrays */
	fieldstart=	&tempbuf[0];
	fieldend=	&tempbuf[CNXTOKENW/2];

	/* find first non-space */
	for (i=0; i<CNXTOKENW; i++) if (fromptr[i]!=' ') break;
	/* if line is all spaces, turn it into a comment */
	if (i==CNXTOKENW) fromptr[i=0]=';';

	/* treat comment as special case */
	if (fromptr[i]==';')
	{
		if (i==(CNXTOKENW-1))	/* turn null comment into single-space comment */
		{
			fromptr[i-1]=';';
			fromptr[i]=' ';
			i--;
		}
		result= token_comment(fromptr+i+1,fromptr+CNXTOKENW-1,toptr,flag);
		*cmd_out= GE_COMMENT;
		return result;
	}

	/* find all fields */
	nfields= find_fields(fromptr,fieldstart,fieldend);
	if (nfields<0) return 0;
	cmd= -1;		/* initialize search for command keyword */

	for (i=0; i<nfields; i++)
	{
		/* convert all non-literal fields to all-upper case */
		temp=0;
		for (ptr=fieldstart[i]; ptr<=fieldend[i]; ptr++,temp++)
		{
			ch= *ptr;
			if (!temp)
				if ((ch==QUOTE)||(ch==DQUOTE)) break;	/* literal field */
			if ((ch>='a')&&(ch<='z')) *ptr= ch-'a'+'A';
		}

		/* determine type of each field */
		temp= field_type(fieldstart[i],fieldend[i]);
		if (temp<0) return 0;	/* un-type-able field */
		if ( (temp>=FT_CMD0) && (cmd<0) ) cmd= temp-FT_CMD0;	/* keyword */
		fieldtype[i]=temp;

		/* value of each field */
		fieldval[i]= field_val(fieldtype[i],fieldstart[i],fieldend[i]);
	}	/* end for all fields */

	/* two kinds of tokenize: with/without keyword */
	result= cmd<0 ? token_key0(nfields,fieldtype,fieldval,tempbuf) :
						 token_key1(cmd,nfields,fieldtype,fieldval,tempbuf) ;
	*cmd_out= *(char*)(tempbuf);	/* command */
	if (result&&flag) copy_bytes(tempbuf,toptr,(long)(result));

	return result;
#endif
}	/* end token_line() */

/* tokenize a comment .......................................................*/
/* returns 0= error, non-0 = # bytes in resulting token */

token_comment(start,end,toptr,flag)
register char *start;	/* --> first char in comment */
register char *end;		/* --> last char in comment */
char *toptr;	/* where to put result */
int flag;		/* 0= compute length but don't tokenize, 1= tokenize also */
					/* toptr= 0L instead of flag=0 !!! */
{
#if CNXFLAG
	register int result;
	register int i;
	int ch;

	while ( (end>start) && (*end==' ') ) end--;
	result= (long)(end) - (long)(start) + 1;	/* length of string */
	toptr += 2;											/* skip command and length */
	for (i=0; i<result; i++)						/* copy string into token */
	{
		ch= *start++;
		if (flag) toptr[i]=ch;
	}
	if (ch)												/* null term'd */
	{
		if (flag) toptr[i++]=0;
		result++;
	}
	if (result&1)										/* even # bytes */
	{
		if (flag) toptr[i++]=0;
		result++;
	}
	result += 2;										/* include command and length */
	if (flag)
	{
		toptr[-2]= GE_COMMENT;						/* command */
		toptr[-1]= result;							/* length */
	}
	return result;
#endif
}	/* end token_comment() */

/* return # fields ..........................................................*/
/* returns -1 = error (unclosed token) */

find_fields(fromptr,fieldstart,fieldend)
register char *fromptr;	/* line of source code ([CNXTOKENW-1] always ' ') */
char *fieldstart[];
char *fieldend[];
{
#if CNXFLAG
	register int i,n,ch,phase;

	for (i=phase=n=0; i<CNXTOKENW; i++,fromptr++)
	{
		ch= *fromptr;
		switch (phase)
		{
			case 0:				/* between tokens */
			if (ch!=' ')
			{
				fieldstart[n]= fieldend[n]= fromptr;
				phase=ch;
				if ((phase!=DQUOTE)&&(phase!=QUOTE)) phase=1;
			}
			break;

			case 1:				/* inside non-literal token */
			if (ch==' ')
			{
				n++;
				phase=0;
			}
			else
				fieldend[n]=fromptr;
			break;

			case DQUOTE:			/* inside literal token */
			case QUOTE:
			fieldend[n]=fromptr;
			if (ch==phase)
			{
				n++;
				phase=0;
			}
		}
	} /* end loop through all characters in line */
	if (phase) n= -1;	/* unclosed token */
	return n;
#endif
}	/* end find_fields() */

/* classify a field .........................................................*/
/* returns -1 = unknown type, >=0 = a type */

field_type(start,end)
char *start,*end;		/* --> 1st and last chars in field */
{
#if CNXFLAG
	int ch0,chn,ch;
	register int leng,i;
	char nulltermd[CNXTOKENW];

	leng= (long)(end) - (long)(start) + 1 ;	/* how many chars in field */
	ch0= *start;										/* 1st and last chars */
	chn= *end;
	/* convert to null-term'd string */
	for (i=0; i<leng; i++) nulltermd[i]=start[i];
	nulltermd[i]=0;

	/* equal sign */
	if ( (leng==1) && (ch0=='=') ) return FT_EQUAL;

	/* literal string */
	if ( (leng>=2) && (ch0==DQUOTE) && (chn==DQUOTE) ) return FT_STRING;

	/* asci constant */
	if ( (leng>=2) && (leng<=6) && (ch0==QUOTE) && (chn==QUOTE) )
		return FT_ASCII;

	/* binary constant */
	if ( (leng>=2) && (leng<=33) && (ch0=='%') )
	{
		for (i=1; i<leng; i++)
		{
			ch= start[i];
			if ( (ch!='0') && (ch!='1') ) break;
		}
		if (i==leng) return FT_BIN;
	}

	/* hex constant */
	if ( (leng>=2) && (leng<=9) && (ch0=='$') )
	{
		for (i=1; i<leng; i++)
		{
			ch= start[i];
			if ( ((ch<'0')||(ch>'9')) && ((ch<'A')||(ch>'F')) ) break;
		}
		if (i==leng) return FT_HEX;
	}

	/* dec constant */
	if (leng<=9)
	{
		for (i=0; i<leng; i++)
		{
			ch= start[i];
			if ( (ch<'0') || (ch>'9') ) break;
		}
		if (i==leng) return FT_DEC;
	}

	/* variable name */
	if ( (leng==3) && (ch0=='V') )
	{
		for (i=1; i<leng; i++)
		{
			ch= start[i];
			if ( (ch<'0') || (ch>'9') ) break;
		}
		if (i==leng) return FT_VAR;
	}
	for (i=0; i<(NVARS-100); i++)
		if (!strcmp(nulltermd,cnxdedvar[i])) return 5;

	/* label name */
	if ( (leng==3) && (ch0=='L') )
	{
		for (i=1; i<leng; i++)
		{
			ch= start[i];
			if ( (ch<'0') || (ch>'9') ) break;
		}
		if (i==leng) return FT_LABEL;
	}

	/* single letter */
	if ( (leng==1) && (ch0>='A') && (ch0<='Z') ) return FT_LETTER;

	/* math operator */
	for (i=0; i<10; i++)
		if (!strcmp(nulltermd,operstr[i])) return FT_MATH;

	/* logic operator */
	for (i=0; i<3; i++)
		if (!strcmp(nulltermd,logicstr[i])) return FT_LOGIC;

	/* relational operator */
	for (i=0; i<6; i++)
		if (!strcmp(nulltermd,relstr[i])) return FT_REL;

	/* "IF" */
	if ( (leng==2) && (ch0=='I') && (chn=='F') ) return FT_IF;

	/* keyword */
	for (i=0; i<NCNXCMDS; i++)
		if (!strcmp(nulltermd,cnxCmds[i])) return FT_CMD0+i;

	/* bad type */
	return -1;
#endif
}	/* end field_type() */

/* "value" of field .........................................................*/
/* returns "value" of field */

long field_val(type,start,end)
int type;		/* FT_xxxx */
char *start;	/* --> first char in field */
char *end;		/* --> last char in field */
{
#if CNXFLAG
	long result=0L;
	register int leng,i,ch;
	char nulltermd[CNXTOKENW];

	leng= (long)(end) - (long)(start) + 1 ;
	/* convert to null-term'd string */
	for (i=0; i<leng; i++) nulltermd[i]=start[i];
	nulltermd[i]=0;

	switch (type)
	{
		case FT_IF:
		case FT_EQUAL:			break;	/* value undef'd */

		case FT_STRING:					/* pointer to string DQUOTE-term'd */
		result= (long)(start+1);
		break;

		case FT_ASCII:						/* ascii constant, right justified */
		leng-=2; start++;	/* don't include quotes in value */
		for (i=0; i<leng; i++)
			result= (result<<8)|(*start++) ;
		break;

		case FT_BIN:
		leng--; start++;	/* don't include '%' in value */
		for (i=0; i<leng; i++)
		{
			ch= *start++;
			ch= ch=='1';
			result= (2L*result) + ch;
		}
		break;

		case FT_HEX:						/* hex constant, right justified */
		leng--; start++;	/* don't include '$' in value */
		for (i=0; i<leng; i++)
		{
			ch= *start++;
			if ((ch>='0')&&(ch<='9')) ch -= '0';
			if ((ch>='A')&&(ch<='F')) ch = 10 + ch - 'A' ;
			result= (16L*result) + ch;
		}
		break;

		case FT_DEC:						/* dec constant, right justified */
		for (i=0; i<leng; i++)
			result= (10L*result) + (*start++) - '0' ;
		break;

		case FT_VAR:						/* variable # */
		if (start[0]=='V')
			result= 10*(start[1]-'0') + start[2] - '0' ;
		else
		{
			for (result=0; result<(NVARS-100); result++)
				if (!strcmp(nulltermd,cnxdedvar[result])) break;
			result += 100;
		}
		break;

		case FT_LABEL:						/* label # */
		result= 10*(start[1]-'0') + start[2] - '0' ;
		break;

		case FT_LETTER:					/* ascii */
		result= start[0];
		break;

		case FT_MATH:						/* which math operator */
		for (result=0; result<10; result++)
			if (!strcmp(nulltermd,operstr[result])) break;
		break;

		case FT_LOGIC:						/* which logic operator */
		for (result=0; result<3; result++)
			if (!strcmp(nulltermd,logicstr[result])) break;
		break;

		case FT_REL:						/* which relational operator */
		for (result=0; result<6; result++)
			if (!strcmp(nulltermd,relstr[result])) break;
		break;

		default:		result= type-FT_CMD0;	/* command # */
	}
	return result;
#endif
}	/* end field_val() */

/* tokenize without keyword .................................................*/
/* returns # bytes in token, 0= error */

token_key0(nfields,fieldtype,fieldval,toptr)
int nfields;
char fieldtype[];
long fieldval[];
char *toptr;
{
#if CNXFLAG
	int result=0;
	int cmd,temp;
	int f2iscv,f2isvar,f4iscv,f4isvar;

	toptr += 2;	/* past command and length */

	/* label */
	if ((nfields==1)&&(fieldtype[0]==FT_LABEL))
	{
		toptr[0]= 0;
		toptr[1]= fieldval[0];
		result=4;
		cmd= GE_LABEL;
	}

	/* ASSIGN, LOGIC, and REL all start "var = ", var not write-only */
	if ( (nfields>=3)&&(fieldtype[0]==FT_VAR)&&(fieldtype[1]==FT_EQUAL)&&
		  (fieldval[0]<200)
		)
	{
		temp= fieldtype[2];
		f2iscv= iscvtype(temp);
		f2isvar= temp==FT_VAR;
		temp= fieldtype[4];
		f4iscv= iscvtype(temp);
		f4isvar= temp==FT_VAR;

		/* simple assignment: var = constvar */
		if ( (nfields==3) && f2iscv )
		{
			toptr[0]= fieldval[0];	/* lvar */
			toptr[1]= -1;				/* no math operation */
			token_cv(fieldtype[2],fieldval[2],toptr+2);
			set_bytes(toptr+8,6L,0);	/* no second constvar */
			result=16;
			cmd= GE_ASSIGN;
		}

		/* complex assignment: var = constvar oper constvar */
		if ( (nfields==5) && f2iscv && f4iscv && (fieldtype[3]==FT_MATH) )
		{
			toptr[0]= fieldval[0];	/* lvar */
			toptr[1]= fieldval[3];	/* math operation */
			token_cv(fieldtype[2],fieldval[2],toptr+2);
			token_cv(fieldtype[4],fieldval[4],toptr+8);
			result=16;
			cmd= GE_ASSIGN;
		}

		/* logic: var = var logic var */
		if ( (nfields==5) && f2isvar && f4isvar && (fieldtype[3]==FT_LOGIC) )
		{
			toptr[0]=fieldval[0];	/* lvar */
			toptr[1]=fieldval[2];	/* var2 */
			toptr[2]=fieldval[4];	/* var3 */
			toptr[3]=fieldval[3];	/* logic operation */
			result=6;
			cmd= GE_LOGIC;
		}

		/* rel: var = var rel constvar */
		if ( (nfields==5) && f2isvar && f4iscv && (fieldtype[3]==FT_REL) )
		{
			toptr[0]=fieldval[0];	/* lvar */
			toptr[1]=fieldval[2];	/* var2 */
			token_cv(fieldtype[4],fieldval[4],toptr+2);	/* constvar */
			toptr[8]=fieldval[3];	/* relational operation */
			toptr[9]=0;
			result=12;
			cmd= GE_REL;
		}

	}	/* end if "var = " */

	/* insert command # and length */
	if (result)
	{
		toptr[-2]=cmd;
		toptr[-1]=result;
	}
	return result;

#endif
}	/* end token_key0() */

/* tokenize with keyword ....................................................*/
/* returns # bytes in token, 0= error */

token_key1(cmd,nfields,fieldtype,fieldval,toptr)
int cmd;				/* command # for keyword found somewhere in fields */
int nfields;		/* how many fields (>0) */
char fieldtype[];	/* type of each field */
long fieldval[];	/* value of each field */
char *toptr;		/* where to put result */
{
#if CNXFLAG
	int result=0;
	char *strptr;
	register int i,temp;

	toptr += 2;		/* skip command and length */

	switch (cmd)
	{
		case GE_RETURN:
		case GE_OPENWIND:
		case GE_CLOSEWIND:
		case GE_CLRWIND:
		case GE_BELL:
		case GE_ENDLOOP:
		case GE_STOP:
		case GE_NOP:
		if (nfields==1) result=2;
		break;

		case GE_GETKEY:					/* var = keyword */
		if (nfields==1)	/* optional dummy lvar was omitted */
			nfields= add_dummy(nfields,fieldtype,fieldval);
		if (nfields==3)
		{
			if (lvarsequence(nfields,fieldtype,fieldval))
			{
				toptr[0]= fieldval[0];	/* var */
				toptr[1]= 0;
				result=4;
			}
		}
		break;

		case GE_RECVDATA:					/* var = keyword cv1 cv2 cv3 */
		case GE_TRANDATA:
		if (nfields==4)	/* optional dummy lvar omitted */
			nfields= add_dummy(nfields,fieldtype,fieldval);
		case GE_GETPATCH:
		case GE_GETCHAN:
		if (nfields==6)
		{
			if (lvarsequence(nfields,fieldtype,fieldval))
			{
				if (typesequence(cmd,nfields,fieldtype,fieldval))
				{
					toptr[0]= fieldval[0];	/* var */
					toptr[1]= 0;
					token_cv(fieldtype[3],fieldval[3],toptr+2);
					token_cv(fieldtype[4],fieldval[4],toptr+8);
					token_cv(fieldtype[5],fieldval[5],toptr+14);
					result=22;
				}
			}
		}
		break;

		case GE_PRINT:
		if (typesequence(cmd,nfields,fieldtype,fieldval))
		{
			token_cv(fieldtype[1],fieldval[1],toptr);
			token_cv(fieldtype[2],fieldval[2],toptr+6);
			result=12;		/* length without command and length */
			strptr= (char*)(fieldval[3]);
			while ( (i= *strptr++) != DQUOTE )	/* string is DQUOTE-term'd */
				toptr[result++]= i;
			toptr[result++]=0;						/* string gets null term'd */
			if (result&1) toptr[result++]=0;		/* string must be even length */
			result+=2;									/* length of command and length */
		}
		break;

		case GE_LOOP:
		if (typesequence(cmd,nfields,fieldtype,fieldval))
		{
			token_cv(fieldtype[1],fieldval[1],toptr);
			*(long*)(toptr+6)= 0L;	/* built-in endloop xref */
			result=12;
		}
		break;

		case GE_TIME:
		case GE_CLRLINE:
		if (typesequence(cmd,nfields,fieldtype,fieldval))
		{
			token_cv(fieldtype[1],fieldval[1],toptr);
			result=8;
		}
		break;

		case GE_RECEIVE:
		case GE_TRANSMIT:
		if (fieldtype[0]==FT_CMD0+cmd)	/* optional dummy lvar omitted */
			nfields= add_dummy(nfields,fieldtype,fieldval);
		if ((nfields>=4)&&(nfields<=19))	/* "lvar = keyword" + 1-16 bytes */
		{
			if (lvarsequence(nfields,fieldtype,fieldval))
			{
				for (i=3; i<nfields; i++)		/* hex bytes follow keyword */
					if (fieldtype[i]!=FT_HEX) break;
				if (i==nfields)
				{
					toptr[0]= fieldval[0];	/* lvar */
					toptr[1]= nfields-3;		/* # of bytes */
					result=2;					/* length without command and length */
					for (i=3; i<nfields; i++)
						toptr[result++]= fieldval[i];
					if (result&1) toptr[result++]=0;	/* even length */
					result+=2;					/* length includes command and length */
				}
			}
		}
		break;

		case GE_BUILDTAB:
		if ((nfields>=3)&&(nfields<=18))	/* keyword + T + 1-16 bytes */
		{
			if ((fieldtype[0]==FT_CMD0+cmd)&&(fieldtype[1]==FT_DEC))
			{
				i= fieldval[1];			/* table # must be 1-16 */
				if ((i>=1)&&(i<=16))
				{
					toptr[0]= i;
					toptr[1]= nfields-2;				/* # of bytes */
					for (i=2; i<nfields; i++)		/* bytes follow table # */
					{
						if (!iscontype(fieldtype[i])) break;
  						if (fieldval[i]>0xFF) break;		/* must fit in a byte */
					}
					if (i==nfields)
					{
						result=2;
						for (i=2; i<nfields; i++)
							toptr[result++]= fieldval[i];
						if (result&1) toptr[result++]=0;	/* even length */
						result+=2;
					}
				}
			}
		}
		break;

		case GE_NEG:
		case GE_RECVANY:
		if (fieldtype[0]==FT_CMD0+cmd)	/* optional dummy lvar omitted */
			nfields= add_dummy(nfields,fieldtype,fieldval);
		if (typesequence(cmd,nfields,fieldtype,fieldval))
		{	/* lvar for NEG can't be dummy */
			if ((cmd!=GE_NEG)||(fieldval[0]!=VAR_DUM))
			{
				toptr[0]= fieldval[0];	/* lvar */
				toptr[1]= 0;
				token_cv(fieldtype[3],fieldval[3],toptr+2);
				result=10;
			}
		}
		break;

		case GE_INVERT:
		case GE_NOT:
		if (typesequence(cmd,nfields,fieldtype,fieldval))
		{
			toptr[0]= fieldval[0];
			toptr[1]= fieldval[3];
			result=4;
		}
		break;

		case GE_TRANVAR:
		if (typesequence(cmd,nfields,fieldtype,fieldval))
		{
			toptr[0]= fieldval[1];	/* var */
			toptr[1]= 0;
			result=4;
		}
		break;

		case GE_PRNTVAR:
		if (typesequence(cmd,nfields,fieldtype,fieldval))
		{
			i= fieldval[2];
			if (isfmttype(i))
			{
				toptr[0]= fieldval[1];	/* var to be printed */
				toptr[1]= i;				/* fmt */
				token_cv(fieldtype[3],fieldval[3],toptr+2);
				token_cv(fieldtype[4],fieldval[4],toptr+8);
				result=16;
			}
		}
		break;

		case GE_GOTO:
		case GE_GOSUB:
		if (nfields==2)	/* unconditional branch */
		{
			if ( (fieldtype[0]==FT_CMD0+cmd) && (fieldtype[1]==FT_LABEL) )
			{
				toptr[0]= VAR_DUM;
				toptr[1]= fieldval[1];
				result=4;
			}
		}
		if (nfields==4)	/* conditional branch */
		{
			if ( (fieldtype[0]==FT_IF) && (fieldtype[1]==FT_VAR) && 
				(fieldtype[2]==FT_CMD0+cmd) && (fieldtype[3]==FT_LABEL) )
			{
				toptr[0]= fieldval[1];
				toptr[1]= fieldval[3];
				result=4;
			}
		}
		break;

		case GE_EXITLOOP:
		if (nfields==1)	/* unconditional branch */
		{
			toptr[0]= VAR_DUM;
			result=4;
		}
		if (nfields==3)	/* conditional branch */
		{
			if ( (fieldtype[0]==FT_IF) && (fieldtype[1]==FT_VAR) && 
				(fieldtype[2]==FT_CMD0+cmd) )
			{
				toptr[0]= fieldval[1];
				result=4;
			}
		}
		break;

		case GE_SPEED:
		if (typesequence(cmd,nfields,fieldtype,fieldval))
		{
			toptr[0]=fieldval[1];
			toptr[1]=0;
			result=4;
		}
		break;

		case GE_SETPORT:
		if (typesequence(cmd,nfields,fieldtype,fieldval))
		{
			token_cv(fieldtype[1],fieldval[1],toptr  );
			token_cv(fieldtype[2],fieldval[2],toptr+6);
			result=14;
		}
		break;

		case GE_PEEKDATA:
		case GE_PEEKPATCH:
		if (typesequence(cmd,nfields,fieldtype,fieldval))
		{
			i=fieldval[4];	/* size */
			if (issizetype(i))
			{
				toptr[0]= fieldval[0];	/* lvar */
				toptr[1]= i;
				token_cv(fieldtype[3],fieldval[3],toptr+2);
				result=10;
			}
		}
		break;

		case GE_PEEKTABLE:
		if (typesequence(cmd,nfields,fieldtype,fieldval))
		{
			toptr[0]= fieldval[0];	/* lvar */
			toptr[1]='B';				/* size always byte */
			token_cv(fieldtype[3],fieldval[3],toptr+8);
			token_cv(fieldtype[4],fieldval[4],toptr+2);
			result=16;
		}
		break;

		case GE_POKEDATA:
		case GE_POKEPATCH:
		if (typesequence(cmd,nfields,fieldtype,fieldval))
		{		
			i=fieldval[3];	/* size */
			if (issizetype(i))
			{
				toptr[0]=i;
				toptr[1]=0;
				token_cv(fieldtype[1],fieldval[1],toptr+2);
				token_cv(fieldtype[2],fieldval[2],toptr+8);
				result=16;
			}
		}
		break;

		case GE_DTOD:
		case GE_DTOP:
		case GE_PTOD:
		case GE_PTOP:
		if (typesequence(cmd,nfields,fieldtype,fieldval))
		{
			i=fieldval[4];	/* size */
			if (issizetype(i))
			{
				toptr[0]=i;
				toptr[1]=0;
				token_cv(fieldtype[1],fieldval[1],toptr+2   );
				token_cv(fieldtype[2],fieldval[2],toptr+8);
				token_cv(fieldtype[3],fieldval[3],toptr+14);
				result=22;
			}
		}
		break;

		case GE_PATCHNUM:
		if (typesequence(cmd,nfields,fieldtype,fieldval))
		{
			if ((fieldval[2]>0)&&(fieldval[2]<=255))		/* # patches */
			{
				if ((fieldval[3]>=0)&&(fieldval[3]<=255))	/* offset */
				{
					*(long*)(toptr)=fieldval[1];				/* bank name */
					toptr[4]=fieldval[2];
					toptr[5]=fieldval[3];
					result=8;
				}
			}
		}
		break;

		case GE_FILTER:
		if (typesequence(cmd,nfields,fieldtype,fieldval))
		{
			if ((fieldval[2]==0)||(fieldval[2]==1))	/* on or off */
			{
				toptr[1]=fieldval[2];
				toptr[0]=0;	/* start building the mask */
				for (i=24; i>=0; i-=8)
				{
					temp= (fieldval[1]>>i)&0xFF;
					if (!temp) continue;
					result= -1;
					if ((temp=='R')||(temp=='r')) result=1;
					if ((temp=='C')||(temp=='c')) result=2;
					if ((temp=='P')||(temp=='p')) result=4;
					if ((temp=='N')||(temp=='n')) result=8;
					if (result<0) break;	/* weird character */
					if (toptr[0]&result) break;	/* duplicate */
					toptr[0] |= result;
				}
				result= i<0 ? 4 : 0 ;	/* ok? */
			}
		}
		break;

		case GE_EXECUTE:
		if (nfields==2)	/* optional dummy lvar was omitted */
			nfields= add_dummy(nfields,fieldtype,fieldval);
		if (lvarsequence(nfields,fieldtype,fieldval))
		{
			if (typesequence(cmd,nfields,fieldtype,fieldval))
			{
				toptr[0]= fieldval[0];	/* lvar */
				strptr= (char*)(fieldval[3]);
				result= 1;		/* length without command and length */
				while ( (i= *strptr++) != DQUOTE )	/* string is DQUOTE-term'd */
					toptr[result++]= i;
				toptr[result++]=0;						/* string null term'd */
				if (result&1) toptr[result++]=0;		/* string even length */
				result+=2;									/* command and length */
			}
		}
		break;

		case GE_INPUT:
		if (nfields==8)
		{
			if (typesequence(cmd,nfields,fieldtype,fieldval))
			{
				i= fieldval[6];
				if (isfmttype(i))
				{
					toptr[0]= fieldval[0];	/* var */
					toptr[1]= i;				/* fmt */
					token_cv(fieldtype[3],fieldval[3],toptr+2);
					token_cv(fieldtype[4],fieldval[4],toptr+8);
					token_cv(fieldtype[5],fieldval[5],toptr+14);
					result=20;		/* length without command and length */
					strptr= (char*)(fieldval[7]);
					while ( (i= *strptr++) != DQUOTE )	/* DQUOTE-term'd */
						toptr[result++]= i;
					toptr[result++]=0;			/* string gets null term'd */
					if (result&1) toptr[result++]=0;		/* string even length */
					result+=2;						/* length of command and length */
				}
			}
		}
		break;

		case GE_GETPORT:
		case GE_ASM:
		case GE_EVENT:
		/* !!! */

	}	/* end switch (cmd) */

	/* insert command # and length */
	if (result)
	{
		toptr[-2]= cmd;
		toptr[-1]= result;
	}
	return result;

#endif
}	/* end token_key1() */

/* add "DUM = " to beginning of command */
/* returns new # fields */

add_dummy(nfields,fieldtype,fieldval)
int nfields;					/* how many fields (>0) */
register char *fieldtype;	/* type of each field */
register long *fieldval;	/* value of each field */
{
#if CNXFLAG
	register int i;

	for (i=nfields-1; i>=0; i--)
	{
		fieldtype[i+2]= fieldtype[i];
		fieldval[i+2]= fieldval[i];
	}
	fieldtype[0]= FT_VAR;
	fieldval[0]= VAR_DUM;
	fieldtype[1]= FT_EQUAL;
	return nfields+2;
#endif
}	/* end add_dummy() */

#if CNXFLAG

/* check for "Vxx = keyword" at beginning of command */
/* returns 1= yes, 0= no */

lvarsequence(nfields,fieldtype,fieldval)
int nfields;		/* how many fields (>0) */
char fieldtype[];	/* type of each field */
long fieldval[];	/* value of each field */
{
	int result=0;

	if (nfields>2)
		if (fieldtype[0]==FT_VAR)
			if ( (fieldval[0]<200L) || (fieldval[0]==VAR_DUM) )	/* read/write */
				if (fieldtype[1]==FT_EQUAL)
					if (fieldtype[2]>=FT_CMD0)
						result=1;
	return result;
}	/* end lvarsequence() */

/* check for correct type sequence for a given command ......................*/
/* returns 1= ok, 0= bad */

typesequence(cmd,nfields,fieldtype,fieldval)
int cmd;
int nfields;
char fieldtype[];
long fieldval[];
{
	static int Nfields[NCNXCMDS]= {		/* -1 for variable (don't call this) */
 1, 4, 4, 4,-1, 5, 5,-1,-1,-1,
 1, 2, 3, 3, 6, 6, 5, 4,-1,-1,
 3, 1, 1, 1, 4, 5, 2, 8, 6, 6,
 1, 5, 1, 4, 5, 4, 2, 1,-1, 1,
 3, 2,-1, 4, 2, 5, 5, 5, 5,-1,
 5, 4
};
	static char Ftypes[NCNXCMDS][8]= {		/* -1 for constvar */
FT_CMD0, 0, 0, 0, 0, 0, 0, 0,								/* nop */
FT_VAR, FT_EQUAL, FT_CMD0, FT_VAR, 0, 0, 0, 0,		/* invert */
FT_VAR, FT_EQUAL, FT_CMD0, -1, 0, 0, 0, 0,			/* neg */
FT_VAR, FT_EQUAL, FT_CMD0, FT_VAR, 0, 0, 0, 0,		/* not */
0,0,0,0,0,0,0,0,		/* assign */
FT_VAR, FT_EQUAL, FT_VAR, FT_LOGIC, FT_VAR, 0,0,0,	/* logic */
FT_VAR, FT_EQUAL, FT_VAR, FT_CMD0, -1, 0,0,0,		/* rel */
0,0,0,0,0,0,0,0,		/* if...goto */
0,0,0,0,0,0,0,0,		/* if...gosub */
0,0,0,0,0,0,0,0,		/* if...exitloop */
FT_CMD0,0,0,0,0,0,0,0,										/* return */
FT_CMD0,FT_DEC,0,0,0,0,0,0,								/* setspeed */
FT_CMD0,FT_ASCII,FT_DEC,0,0,0,0,0,						/* setfilter */
FT_CMD0,-1,-1,0,0,0,0,0,									/* setports */
FT_VAR,FT_EQUAL,FT_CMD0,-1,-1,-1,0,0,					/* receivedata */
FT_VAR,FT_EQUAL,FT_CMD0,-1,-1,-1,0,0,					/* transmitdata */
FT_VAR,FT_EQUAL,FT_CMD0,-1,FT_LETTER,0,0,0,			/* peekdata */
FT_CMD0,-1,-1,FT_LETTER,0,0,0,0,							/* pokedata */
0,0,0,0,0,0,0,0,		/* receive */
0,0,0,0,0,0,0,0,		/* transmit */
FT_VAR,FT_EQUAL,FT_CMD0,0,0,0,0,0,						/* getkey */
FT_CMD0,0,0,0,0,0,0,0,										/* openwindow */
FT_CMD0,0,0,0,0,0,0,0,										/* closewindow */
FT_CMD0,0,0,0,0,0,0,0,										/* clearwindow */
FT_CMD0,-1,-1,FT_STRING,0,0,0,0,							/* print */
FT_CMD0,FT_VAR,FT_LETTER,-1,-1,0,0,0,					/* printvar */
FT_CMD0,-1,0,0,0,0,0,0,										/* clearline */
FT_VAR,FT_EQUAL,FT_CMD0,-1,-1,-1,FT_LETTER,FT_STRING,	/* inputvar */
FT_VAR,FT_EQUAL,FT_CMD0,-1,-1,-1,0,0,					/* inputpatch */
FT_VAR,FT_EQUAL,FT_CMD0,-1,-1,-1,0,0,					/* inputchannel */
FT_CMD0,0,0,0,0,0,0,0,										/* bell */
FT_CMD0,FT_DEC,FT_DEC,FT_DEC,FT_DEC,0,0,0,			/* format */
FT_CMD0,0,0,0,0,0,0,0,										/* endloop */
FT_CMD0,-1,-1,FT_LETTER,0,0,0,0,							/* pokepatch */
FT_VAR,FT_EQUAL,FT_CMD0,-1,FT_LETTER,0,0,0,			/* peekpatch */
FT_CMD0,FT_ASCII,FT_DEC,FT_DEC,0,0,0,0,				/* patchnumfmt */
FT_CMD0,-1,0,0,0,0,0,0,										/* wait */
FT_CMD0,0,0,0,0,0,0,0,										/* stop */
0,0,0,0,0,0,0,0,		/* asm */
FT_LABEL,0,0,0,0,0,0,0,										/* label */
FT_CMD0,FT_DEC,FT_HEX,0,0,0,0,0,							/* waitevent */
FT_CMD0,FT_VAR,0,0,0,0,0,0,								/* transmitvar */
0,0,0,0,0,0,0,0,		/* comment */
FT_VAR,FT_EQUAL,FT_CMD0,-1,0,0,0,0,						/* receiveany */
FT_CMD0,-1,0,0,0,0,0,0,										/* loop */
FT_CMD0,-1,-1,-1,FT_LETTER,0,0,0,						/* copydtod */
FT_CMD0,-1,-1,-1,FT_LETTER,0,0,0,						/* copydtop */
FT_CMD0,-1,-1,-1,FT_LETTER,0,0,0,						/* copyptod */
FT_CMD0,-1,-1,-1,FT_LETTER,0,0,0,						/* copyptop */
0,0,0,0,0,0,0,0,		/* buildtable */
FT_VAR,FT_EQUAL,FT_CMD0,-1,-1,0,0,0,					/* peektable */
FT_VAR,FT_EQUAL,FT_CMD0,FT_STRING,0,0,0,0				/* execute */
};
	register int i,correct,test;

	if (nfields!=Nfields[cmd]) return 0;	/* wrong # fields */

	/* can't have "write-only var =" */
	if ((fieldtype[0]==FT_VAR)&&(fieldtype[1]==FT_EQUAL)&&
		 (fieldval[0]>=200)&&(fieldval[0]!=VAR_DUM)) return 0;
	
	for (i=0; i<nfields; i++)					/* check field types */
	{
		correct= Ftypes[cmd][i];
		if (correct==FT_CMD0) correct += cmd;
		test= fieldtype[i];
		test= correct<0 ? iscvtype(test) : (test==correct) ;
		if (!test) break;
	}
	return i==nfields;
}	/* end typesequence() */

/* build a constvar .........................................................*/

token_cv(fieldtype,fieldval,toptr)
int fieldtype;		/* FT_VAR, FT_HEX, FT_DEC, FT_ASCII, FT_BIN */
long fieldval;		/* var # or constant value */
CONSTVAR *toptr;	/* where to put result */
{
	if (fieldtype==FT_VAR)
	{
		toptr->const= 0L;
		toptr->format= 'D';
		toptr->var= fieldval;
	}
	else
	{
		toptr->const= fieldval;
		switch (fieldtype)
		{
			case FT_HEX: 	toptr->format= 'H'; break;
			case FT_DEC: 	toptr->format= 'D'; break;
			case FT_ASCII: toptr->format= 'A'; break;
			case FT_BIN:	toptr->format= 'B';
		}
		toptr->var= VAR_DUM;
	}
}	/* end token_cv() */

/* is a fieldtype one of cv types? */
/* returns 1= yes, 0= no */

iscvtype(temp)
register int temp;
{
	return (temp==FT_VAR) || iscontype(temp) ;
}	/* end iscvtype() */

/* is a fieldtype one of constant types? */
/* returns 1= yes, 0= no */

iscontype(temp)
register int temp;
{
	return (temp==FT_HEX)||(temp==FT_DEC)||(temp==FT_ASCII)||(temp==FT_BIN) ;
}	/* end iscontype() */

/* is a fieldtype one of size types? */
/* returns 1= yes, 0= no */

issizetype(i)
register int i;
{
	return (i=='B') || (i=='W') || (i=='L') ;
}	/* end issizetype() */

isfmttype(i)
register int i;
{
	return (i=='D') || (i=='H') || (i=='B') || (i=='A') || (i=='P') ;
}	/* end isfmttype() */

#endif

/* EOF */
