/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                          Copyright 1990 Tom Bajoras

	module CNFTOCNX : convert GenPatch CNF to GenEdit CNX

	convertcnf

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

	/* local globals */
int ge_nfields;				/* arguments for ge_line() */
char ge_fieldtype[32];
long ge_fieldval[32];
char ge_buf[128];

/* translate CNF code into CNX code .........................................*/
/* returns # bytes in result, -1L for error */

long convertcnf(from_ptr,nptr,to_ptr,nfrom,flag)
register char *from_ptr;	/* start of CNF code */
char *nptr;						/* --> byte used for GP_BYTEINCR command */
register char *to_ptr;		/* where to put resulting CNX code */
int nfrom;		/* # bytes of CNF code */
int flag;		/* non-0 put result in to_ptr, 0: compute length of result */
					/* use to_ptr=0L instead of flag=0 !!! */
{
#if CNXFLAG
	register long ltemp;
	register int itemp;
	register int i;						/* index into cnf buffer */
	register long result;				/* returned value */
	char chanprompt;						/* whether we've prompted for a channel */
	char *top_ptr,*end_ptr;				/* insert points for tokens */
	int error;								/* error flag */
	unsigned int gp_cmd;					/* GP command to be converted */
	int loopflag;							/* whether we're inside a loop */
	static char *cnxerror[2]= { BADINSTR, BADNVARS };
	int j;
	int count11;							/* how many GP_BYTEINPUT commands */

	/* init variables */
	top_ptr= end_ptr= to_ptr;
	count11= chanprompt= loopflag= result= 0;

	/* loop for all GP commands, or until error */
	for (i=error=0; !error && (i<nfrom) ; )
	{
		switch ( gp_cmd=from_ptr[i++] )	/* next GP command */
		{
			case GP_BYTEINPUT:				/* send patch # (default N) */
			count11++;							/* count how many byte w/ input */
			itemp= from_ptr[i++]&0xFF;		/* N */
			/*** PAT = InputPatch 0 0 N ***/
			ltemp= gp_inputpat(VAR_PAT,itemp);
			result += ltemp;
			if (flag)
			{
				if ( (count11==1) && !loopflag )
				{
					insert_bytes(ltemp,ge_buf,top_ptr,end_ptr);
					top_ptr += ltemp;
				}
				else
					copy_bytes(ge_buf,end_ptr,ltemp);
				end_ptr += ltemp;
			}
			/*** TransmitVar PAT ***/
			ltemp= gp_transvar(VAR_PAT);
			result += ltemp;
			if (flag)
			{
				copy_bytes(ge_buf,end_ptr,ltemp);
				end_ptr += ltemp;
			}
			break;	/* end case GP_BYTEINPUT */

			case GP_BYTEINCR:					/* send N + loop counter */
			itemp= from_ptr[i++]&0xFF;		/* N */
			if (nptr[0]&0x80)
			{
				/*** V01 = InputPatch 0 0 N ***/
				ltemp= gp_inputpat(1,itemp);
			}
			else
			{
				/*** V01 = N ***/
				ge_nfields= 3;
				ge_fieldtype[0]= FT_VAR;	ge_fieldval[0]= 1;
				ge_fieldtype[1]= FT_EQUAL;
				ge_fieldtype[2]= FT_HEX;	ge_fieldval[2]= itemp;			
				ltemp= ge_line(-1);
			}
			result += ltemp;
			if (flag)
			{
				insert_bytes(ltemp,ge_buf,top_ptr,end_ptr);
				top_ptr += ltemp; end_ptr += ltemp;
			}
			/*** PAT = V01 [ + nptr[0]&$7F ] ***/
			if (nptr[0]&0x7F)
				ltemp= gp_math(VAR_PAT,1,0,nptr[0]&0x7F,FT_HEX);
			else
				ltemp= gp_assign(VAR_PAT,1);
			result += ltemp;
			if (flag)
			{
				copy_bytes(ge_buf,end_ptr,ltemp);
				end_ptr += ltemp;
			}
			/*** PAT = PAT & $7F ***/
			ltemp= gp_math(VAR_PAT,VAR_PAT,6,0x7F,FT_HEX);
			result += ltemp;
			if (flag)
			{
				copy_bytes(ge_buf,end_ptr,ltemp);
				end_ptr += ltemp;
			}
			/*** TransmitVar PAT ***/
			ltemp= gp_transvar(VAR_PAT);
			result += ltemp;
			if (flag)
			{
				copy_bytes(ge_buf,end_ptr,ltemp);
				end_ptr += ltemp;
			}
			/*** V01 = V01 + 1 ***/
			ltemp= gp_math(1,1,0,1,FT_DEC);
			result += ltemp;
			if (flag)
			{
				copy_bytes(ge_buf,end_ptr,ltemp);
				end_ptr += ltemp;
			}
			break;	/* end case GP_BYTEINCR */

			case GP_SENDCHAN:					/* send N or'd with channel */
			itemp= from_ptr[i++] & 0xf0;	/* N, ignore low nibble default chan */
			if (!chanprompt)					/* prompt for channel only once */
			{
				/*** CHN = InputChannel 0 0 CHN ***/
				ge_nfields= 6;
				ge_fieldtype[0]= FT_VAR;					ge_fieldval[0]= VAR_CHN;
				ge_fieldtype[1]= FT_EQUAL;
				ge_fieldtype[2]= FT_CMD0+GE_GETCHAN;	ge_fieldval[2]= GE_GETCHAN;
				ge_fieldtype[3]= FT_DEC;					ge_fieldval[3]= 0;
				ge_fieldtype[4]= FT_DEC;					ge_fieldval[4]= 0;
				ge_fieldtype[5]= FT_VAR;					ge_fieldval[5]= VAR_CHN;
				result += (ltemp=ge_line(GE_GETCHAN)) ;
				if (flag)
				{
					insert_bytes(ltemp,ge_buf,top_ptr,end_ptr);
					top_ptr += ltemp;		end_ptr += ltemp;
				}
				chanprompt=1;
			}
			/*** V00 = CHN [ | N ] ***/
			if (itemp)
				ltemp= gp_math(0,VAR_CHN,5,itemp,FT_HEX);
			else
				ltemp= gp_assign(0,VAR_CHN);
			result += ltemp;
			if (flag)
			{
				copy_bytes(ge_buf,end_ptr,ltemp);
				end_ptr += ltemp;
			}
			/*** TransmitVar V00 ***/
			ltemp= gp_transvar(0);
			result += ltemp;
			if (flag)
			{
				copy_bytes(ge_buf,end_ptr,ltemp);
				end_ptr += ltemp;
			}
			break;	/* end case GP_SENDCHAN */

			case GP_SENDDATA:				/* send data */
			case GP_RECVDATA:				/* receive data */
			ltemp= *(long*)(&from_ptr[i-1]) & 0x00ffffffL; i+=3;	/* # bytes */
			itemp= gp_cmd==GP_SENDDATA ? GE_TRANDATA : GE_RECVDATA ;
			/*** TransmitData[ReceiveData] N $F7 1 ***/
			ge_nfields= 4;
			ge_fieldtype[0]= FT_CMD0+itemp;	ge_fieldval[0]= itemp;
			ge_fieldtype[1]= FT_DEC;			ge_fieldval[1]= ltemp;
			ge_fieldtype[2]= FT_HEX;			ge_fieldval[2]= 0xF7;
			ge_fieldtype[3]= FT_DEC;			ge_fieldval[3]= 1;
			result += (ltemp=ge_line(itemp)) ;
			if (flag)
			{
				copy_bytes(ge_buf,end_ptr,ltemp);
				end_ptr += ltemp;
			}
			break;	/* end case GP_SENDDATA or GP_RECVDATA */

			case GP_RECVANY:						/* receive N non-real-time bytes */
			ltemp= from_ptr[i++]&0xFF;			/* N */
			/*** ReceiveAny N ***/
			ge_nfields= 2;
			ge_fieldtype[0]= FT_CMD0+GE_RECVANY;	ge_fieldval[0]= GE_RECVANY;
			ge_fieldtype[1]= FT_DEC;					ge_fieldval[1]= ltemp;
			result += (ltemp=ge_line(GE_RECVANY)) ;
			if (flag)
			{
				copy_bytes(ge_buf,end_ptr,ltemp);
				end_ptr += ltemp;
			}
			break;	/* end case GP_RECVANY */

			case GP_WAIT:				/* wait N/100 seconds */
			itemp= from_ptr[i++]&0xFF;
			ltemp= max(1,itemp/5);	/* 1/20 units */
			/*** Wait N ***/
			ge_nfields= 2;
			ge_fieldtype[0]= FT_CMD0+GE_TIME;	ge_fieldval[0]= GE_TIME;
			ge_fieldtype[1]= FT_DEC;				ge_fieldval[1]= ltemp;
			result += (ltemp=ge_line(GE_TIME)) ;
			if (flag)
			{
				copy_bytes(ge_buf,end_ptr,ltemp);
				end_ptr += ltemp;
			}
			break;	/* end case GP_WAIT */

			case GP_LOOP:					/* loop N times (0=infinity) */
			loopflag= 1;
			ltemp= from_ptr[i++]&0xFF;	/* N */
			/*** Loop N ***/
			ge_nfields= 2;
			ge_fieldtype[0]= FT_CMD0+GE_LOOP;	ge_fieldval[0]= GE_LOOP;
			ge_fieldtype[1]= FT_DEC;				ge_fieldval[1]= ltemp;
			result += (ltemp=ge_line(GE_LOOP)) ;
			if (flag)
			{
				copy_bytes(ge_buf,end_ptr,ltemp);
				end_ptr += ltemp;
			}
			break;	/* end case GP_LOOP */

			case GP_ENDLOOP:				/* end loop */
			i++;								/* unused byte after command byte */
			loopflag= 0;
			/*** EndLoop ***/
			ge_nfields= 1;
			ge_fieldtype[0]= FT_CMD0+GE_ENDLOOP;	ge_fieldval[0]= GE_ENDLOOP;
			result += (ltemp=ge_line(GE_ENDLOOP)) ;
			if (flag)
			{
				copy_bytes(ge_buf,end_ptr,ltemp);
				end_ptr += ltemp;
			}
			break;	/* end case GP_ENDLOOP */

			default:								/* send/receive sentence */
			ltemp = 1 + (gp_cmd&0x0f);		/* # bytes */
			gp_cmd &= 0xf0;					/* get rid of # bytes */
			error= (gp_cmd!=GP_SENDSENT) && (gp_cmd!=GP_RECVSENT) ;
			if (error) break;					/* bad GP instruction */
			j=i;									/* index to start of string in cnf */
			i+=ltemp; if (i&1) i++;			/* cnf sentence always even length */
			itemp= gp_cmd==GP_SENDSENT ? GE_TRANSMIT : GE_RECEIVE ;
			/*** Transmit[Receive] b1 b2 b3 b4 ... bN ***/
			ge_nfields= 1+ltemp;
			ge_fieldtype[0]= FT_CMD0+itemp;	ge_fieldval[0]= itemp;
			asm { move.w i,-(a7) }
			for (i=1; i<=ltemp; i++)
			{
				ge_fieldtype[i]= FT_HEX;
				ge_fieldval[i]= from_ptr[j++]&0xFF;
			}
			asm { move.w (a7)+,i }
			result += (ltemp=ge_line(itemp)) ;
			if (flag)
			{
				copy_bytes(ge_buf,end_ptr,ltemp);
				end_ptr += ltemp;
			}

		}	/* end switch (GP command) */
	}	/* end for all CNF bytes */

	/* if error: message and abort */
	if (error)
	{
		form_alert(1,cnxerror[error-1]);
		return -1L;
	}

	/* CNX must be multiple of 4 bytes */
	if (result%4)
	{
		result += 2;
		if (flag)
		{
			*end_ptr++ = GE_NOP;
			*end_ptr++ = 2;
		}
	}

	return result;
#else
	return -1L;
#endif
}	/* end convertcnf() */

/* TransmitVar var */
gp_transvar(var)
int var;
{
	ge_nfields= 2;
	ge_fieldtype[0]= FT_CMD0+GE_TRANVAR;	ge_fieldval[0]= GE_TRANVAR;
	ge_fieldtype[1]= FT_VAR;					ge_fieldval[1]= var;
	return ge_line(GE_TRANVAR);
}
/* lvar = InputPatch 0 0 n */
gp_inputpat(lvar,n)
int lvar,n;
{
	ge_nfields= 6;
	ge_fieldtype[0]= FT_VAR;					ge_fieldval[0]= lvar;
	ge_fieldtype[1]= FT_EQUAL;
	ge_fieldtype[2]= FT_CMD0+GE_GETPATCH;	ge_fieldval[2]= GE_GETPATCH;
	ge_fieldtype[3]= FT_DEC;					ge_fieldval[3]= 0;
	ge_fieldtype[4]= FT_DEC;					ge_fieldval[4]= 0;
	ge_fieldtype[5]= FT_DEC;					ge_fieldval[5]= n;
	return ge_line(GE_GETPATCH);
}
/* lvar = var op n */
gp_math(lvar,var,op,n,fmt)
int lvar,var,op,n,fmt;
{
	ge_nfields= 5;
	ge_fieldtype[0]= FT_VAR;			ge_fieldval[0]= lvar;
	ge_fieldtype[1]= FT_EQUAL;
	ge_fieldtype[2]= FT_VAR;			ge_fieldval[2]= var;
	ge_fieldtype[3]= FT_MATH;			ge_fieldval[3]= op;
	ge_fieldtype[4]= fmt;				ge_fieldval[4]= n;
	return ge_line(-1);
}
/* lvar = var */
gp_assign(lvar,var)
int lvar,var;
{
	ge_nfields= 3;
	ge_fieldtype[0]= FT_VAR;	ge_fieldval[0]= lvar;
	ge_fieldtype[1]= FT_EQUAL;
	ge_fieldtype[2]= FT_VAR;	ge_fieldval[2]= var;
	return ge_line(-1);
}

/* tokenize a converted line of CNX code ....................................*/
/* returns # of bytes in token, -1 for error (shouldn't happen) */

ge_line(cmd)
int cmd;	/* -1 for no keyword */
{
	return cmd>=0 ? 
		token_key1(cmd,ge_nfields,ge_fieldtype,ge_fieldval,ge_buf)
	:
		token_key0(ge_nfields,ge_fieldtype,ge_fieldval,ge_buf)
	;
}	/* pretty cool function, huh? */

/* EOF */
