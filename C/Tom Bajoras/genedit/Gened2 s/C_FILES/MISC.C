/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	module: MISC

	set_longs, set_words, set_bytes
	copy_longs, copy_words, copy_bytes
	rcopy_longs, rcopy_words, rcopy_bytes
	comp_bytes, insert_bytes

	max_word

	hexvalue, itoa, ltoa, btoa, atoi, atoii, atol, bytes_for, ndigits
	bin2ascii

	pad_str, swap_char, make_tone, Cprnws

	iSine, iCosine

	val_to_val, ival_to_val
	checksum, malloc256, crc16
	find_const, wait

******************************************************************************/

overlay "misc"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */

/* fill an array of longs ...................................................*/

extern set_longs();
asm {
set_longs:	/* 4(a7).l --> array, 8(a7).l= # of longs, 12(a7).l = value */
	movea.l	4(a7),a0
	move.l	8(a7),d0
	ble		endsl
	move.l	12(a7),d1
loopsl:
	move.l	d1,(a0)+
	subq.l	#1,d0
	bgt		loopsl
endsl:
	rts
}  /* end set_longs() */

/* fill an array of words ...................................................*/

extern set_words();
asm {
set_words:	/* 4(a7).l --> array, 8(a7).l = # of words, 12(a7).w = value */
	movea.l	4(a7),a0
	move.l	8(a7),d0
	ble		endsw
	move.w	12(a7),d1
loopsw:
	move.w	d1,(a0)+
	subq.l	#1,d0
	bgt		loopsw
endsw:
	rts
}  /* end set_words() */

/* fill an array of bytes ...................................................*/

extern set_bytes();
asm {
set_bytes:	/* 4(a7).l --> array, 8(a7).l = # of bytes, 12(a7).w = value */
	movea.l	4(a7),a0
	move.l	8(a7),d0
	ble		endsb
	move.w	12(a7),d1
loopsb:
	move.b	d1,(a0)+
	subq.l	#1,d0
	bgt		loopsb
endsb:
	rts
}  /* end set_bytes() */

/* copy an array of longs ...................................................*/

extern copy_longs();
asm {
copy_longs:	/* 4(a7).l --> from, 8(a7).l --> to, 12(a7).l = # of longs */
	movea.l	4(a7),a0
	movea.l	8(a7),a1
	move.l	12(a7),d0
	ble		endcl
loopcl:
	move.l	(a0)+,(a1)+
	subq.l	#1,d0
	bgt		loopcl
endcl:
	rts
}  /* end copy_longs() */

/* copy an array of words ...................................................*/

extern copy_words();
asm {
copy_words:	/* 4(a7).l --> from, 8(a7).l --> to, 12(a7).l = # of words */
	movea.l	4(a7),a0
	movea.l	8(a7),a1
	move.l	12(a7),d0
	ble		endcw
loopcw:
	move.w	(a0)+,(a1)+
	subq.l	#1,d0
	bgt		loopcw
endcw:
	rts
}  /* end copy_words() */

/* copy an array of bytes ...................................................*/

extern copy_bytes();
asm {
copy_bytes:	/* 4(a7).l --> from, 8(a7).l --> to, 12(a7).l = # of bytes */
	movea.l	4(a7),a0
	movea.l	8(a7),a1
	move.l	12(a7),d0
	ble		endcb

	btst		#0,d0			; if everything's even, copy_words instead
	bne		loopcb
	move.l	a0,d1
	btst		#0,d1
	bne		loopcb
	move.l	a1,d1
	btst		#0,d1
	bne		loopcb
	asr.l		#1,d0
	bra		loopcw

loopcb:
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bgt		loopcb
endcb:
	rts
}  /* end copy_bytes() */

/* reverse-copy an array of longs ...........................................*/
/* use throughout !!! */

extern rcopy_longs();
asm {
rcopy_longs:
/* 4(a7).l --> first byte past end of source
	8(a7).l --> first byte past end of destination
  12(a7).l = # of longs
*/
	movea.l	4(a7),a0
	movea.l	8(a7),a1
	move.l	12(a7),d0
	ble		endclr
loopclr:
	move.l	-(a0),-(a1)
	subq.l	#1,d0
	bgt		loopclr
endclr:
	rts
}  /* end rcopy_longs() */

/* reverse-copy an array of words ...........................................*/
/* use throughout !!! */

extern rcopy_words();
asm {
rcopy_words:
/* 4(a7).l --> first byte past end of source
	8(a7).l --> first byte past end of destination
  12(a7).l = # of words
*/
	movea.l	4(a7),a0
	movea.l	8(a7),a1
	move.l	12(a7),d0
	ble		endcwr
loopcwr:
	move.w	-(a0),-(a1)
	subq.l	#1,d0
	bgt		loopcwr
endcwr:
	rts
}  /* end rcopy_words() */

/* reverse-copy an array of bytes ...........................................*/
/* use throughout !!! */

extern rcopy_bytes();
asm {
rcopy_bytes:
/* 4(a7).l --> first byte past end of source
	8(a7).l --> first byte past end of destination
  12(a7).l = # of bytes
*/
	movea.l	4(a7),a0
	movea.l	8(a7),a1
	move.l	12(a7),d0
	ble		endcbr
loopcbr:
	move.b	-(a0),-(a1)
	subq.l	#1,d0
	bgt		loopcbr
endcbr:
	rts
}  /* end rcopy_bytes() */

/* compare an array of bytes ................................................*/
/* returns 0 if the two arrays are same, else returns non-0 */

extern comp_bytes();
asm {
comp_bytes:	/* 4(a7) --> array1, 8(a7) --> array2, 12(a7).l = # of bytes */
	moveq		#0,d0
	movea.l	4(a7),a0
	movea.l	8(a7),a1
	move.l	12(a7),d1
	ble		comp_exit		; "comparing" <=0 bytes -- return "the same"
	moveq		#1,d0
loopcmpb:
	cmpm.b	(a0)+,(a1)+
	bne		comp_exit
	subq.l	#1,d1
	bgt		loopcmpb
	moveq		#0,d0
comp_exit:
	rts
}  /* end comp_bytes() */

/* insert a block of bytes into middle of another block of bytes ............*/
/* warning: buffer grows, make sure there's room for it to grow into before
	calling this */
/* use throughout !!! (write another one called delete_bytes?) */

insert_bytes(nbytes,bytes,start,end)
long nbytes;		/* how many bytes to be inserted */
char *bytes;		/* the bytes to be inserted (0L means no insert) */
char *start;		/* where they are to be inserted */
char *end;			/* 1st byte past buffer, before the bytes are inserted */
{
	register char *ptr;

	for (ptr=end-1; ptr>=start; ptr--)
		*(ptr+nbytes) = *ptr;							/* open hole */
	if (bytes) copy_bytes(bytes,start,nbytes);	/* put bytes into hole */

}	/* end insert_bytes() */

/* maximum int in an array ..................................................*/
/* returns index */

max_word(n,val)
register int n,*val;
{
	register int max_n,maxval= -32768;

	for (--n; (n>=0); n--)
	{
		if (val[n]>=maxval)
		{
			maxval=val[n];
			max_n=n;
		}
	}
	return max_n;
}	/* end max_word() */

/* convert character to nibble ..............................................*/
/* returns 0-15, -1 error */

hexvalue(ch)
register unsigned int ch;
{
	if ( (ch>='0') && (ch<='9') ) return ch-'0';
	if ( (ch>='A') && (ch<='F') ) return ch-'A'+10;
	if ( (ch>='a') && (ch<='f') ) return ch-'a'+10;
	return -1;
}	/* end hexvalue() */

/* encode int into ascii ....................................................*/

itoa(val,s,n)
int val;			/* value to be encoded */
char *s;			/* buffer to be encoded into */
int n;			/* # of decimal digits (<1 for no leading 0's) */
{
	ltoa( (long)(val) , s , n );
}  /* end itoa() */

/* encode long into ascii ...................................................*/

ltoa(val,s,n)
long val;		/* value to be encoded */
char *s;			/* buffer to be encoded into */
int n;			/* # of decimal digits (<1 for no leading 0's) */
{
	long div;
	static long power10[12]= {
		1L,10L,100L,1000L,10000L,100000L,1000000L,10000000L,
		100000000L,1000000000L,10000000000L,100000000000L
	};

	if (val<0L)
	{
		*s++ = '-';
		val = -val;
	}
	if (n<=0) n=ndigits(val);	/* figure out how many digits */
	if (n==1)
	{
		s[0]= '0'+val;      s[1]= 0;
	}
	else
	{
		div= power10[n-1];
		s[0]= '0' + val/div;   
		ltoa(val%div,&s[1],n-1);
	}
}  /* end ltoa() */

/* how many digits needed to encode a non-negative long .....................*/
/* returns # digits (>=1) */

ndigits(val)
register long val;
{
	register int n=1;

	/* do this algorithmically? !!! */
	if (val>9L) n++;
	if (val>99L) n++;
	if (val>999L) n++;
	if (val>9999L) n++;
	if (val>99999L) n++;
	if (val>999999L) n++;
	if (val>9999999L) n++;
	if (val>99999999L) n++;
	if (val>999999999L) n++;
	if (val>9999999999L) n++;
	return n;
}	/* end ndigits() */

/* encode binary byte into ascii ............................................*/

btoa(i,str)
register int i;					/* 0-255 */
register char *str;	/* must be at least 9 chars */
{
	asm {
		moveq		#7,d0
	btoaloop:
		lsl.b		#1,i
		bcs		btoa_1
		moveq		#'0',d1
		bra		btoa_x
	btoa_1:
		moveq		#'1',d1
	btoa_x:
		move.b	d1,(str)+
		dbf		d0,btoaloop
		move.b	#0,(str)
	}	/* end asm */
}	/* end btoa() */

/* convert ascii to signed int ..............................................*/
/* use throughout instead of atoi !!! */

atoii(ptr,error)
char *ptr;		/* make sure this is big enough */
int *error;
{
	long val;
	int sign=1;
	long atol();

	if (ptr[0]=='-')
	{
		sign= -1;
		ptr++;
	}
	if (ptr[0]=='+')
	{
		sign= 1;
		ptr++;
	}
	val= atol(ptr);
	*error= sign==1 ? (val>0x7fffL) : (val>0x8000L) ;
	val *= sign;
	return (int)val;
}	/* end atoii() */

/* convert ascii to non-negative int ........................................*/
/* returns 0-0x7FFFF, -1 = error */

atoi(str)
register char *str;	/* --> non-negative int encoded as decimal ascii */
{
	register long result;
	long atol();

	result= atol(str);
	if (result>0x7fffL) result= -1L;
	return (int)result;
}	/* end atoi() */

/* convert ascii string to long .............................................*/
/* returns -1L if str is not an encoded long */

long atol(str)
register char *str;	/* --> non-negative long encoded as decimal ascii */
{
	register long result;
	register int ch;

	for (result=0L; result>=0L; )
	{
		ch= *str++;
		if (!ch) break;
		if ((ch>='0')&&(ch<='9'))
			result= 10*result + ch - '0';
		else
			result= -1L;
	}
	return result;
}	/* end atol() */

/* encode patch number ......................................................*/
/* returns 0= can't convert, 1= converted ok */
/* build-in code to use 7 spaces for can't convert, space pad on right !!! */

itop(j,pnumfmt,linebuf)
register int j;					/* patch # 0-(MAXNPATS-1) */
PNUMFMT pnumfmt;
register char *linebuf;			/* 4 + 3 + 1(null) */
{
	register int i,bank,npats;
	char linebuf2[4];

	for (i=bank=0; i<MAXNBANKS; i++)
	{
		npats= pnumfmt.npatches[i];
		if (!npats) return 0;
		bank += npats;
		if (j<bank) { bank=i; break; }
	}
	if (i==MAXNBANKS) return 0;

	copy_bytes(&(pnumfmt.bankname[bank]),linebuf,4L);
	for (i=0; i<4; i++) if (!linebuf[i]) linebuf[i]=' ';
	linebuf[4]=0;

	/* append patch number only if more than one patch in this bank */
	if (pnumfmt.npatches[bank]>1)
	{
		for (i=0; i<bank; i++) j -= pnumfmt.npatches[i];
		j += ( pnumfmt.offset[bank] & 0xFF ) ;
		itoa(j,linebuf2,-1);
		/* no #s greater than 999, so that linebuf won't overflow */
		linebuf2[3]=0;
		strcat(linebuf,linebuf2);
	}

	return 1;
}	/* end itop() */

/* returns 1, 2, 3, or 4 ....................................................*/

bytes_for(sign,val)
int sign;
long val;
{
	int n=1;

	if (sign)
	{
		if ( (val>0x7fL) || (val<(-0x80L)) ) n++;
		if ( (val>0x7fffL) || (val<(-0x8000L)) ) n++;
		if ( (val>0x7fffffL) || (val<(-0x800000L)) ) n++;
	}
	else
	{
		if (val>0xffL) n++;
		if (val>0xffffL) n++;
		if (val>0xffffffL) n++;
	}
	return n;
}	/* end bytes_for() */

/* encode binary array into ascii array .....................................*/
/* returns # bytes in ascii array */
/* use this throughout !!! */
long bin2ascii(bin_ptr,asc_ptr,bin_leng,crlf,spacing)
register char *bin_ptr;	/* --> source */
register char *asc_ptr;	/* --> destination (must be big enough!) */
register long bin_leng;	/* # bytes in source */
int crlf;		/* whether to append 0x0D,0x0A after each 80 characters
						in destination */
int spacing;	/* whether to append ' ' after each 2 characters in
						destination */
{
	register long asc_leng= 0L;
	register int lineleng;

	for (lineleng=0; bin_leng>0; bin_leng--)
	{
		strcpy(asc_ptr,hextext[ (*bin_ptr++)&0xFF ]);
		asc_ptr+=2;
		asc_leng+=2;
		lineleng+=2;
		if (spacing)
		{
			*asc_ptr++ = ' ';
			asc_leng++;
			lineleng++;
		}
		if (lineleng>=78)
		{
			if (crlf)
			{
				*asc_ptr++ = 0x0D;
				*asc_ptr++ = 0x0A;
				asc_leng+=2;
			}
			lineleng=0;
		}
	}
	return asc_leng;
}	/* end bin2ascii() */

/* pad a string on right ....................................................*/

pad_str(n,str,padchar)
int n;					/* byte offset to new null at end of string */
register char *str;	/* pointer to a null-term'd string */
int padchar;			/* character to pad with */
{
	register int i;
	
	for (i=0; str[i]!=0; i++) ;
	for ( ; i<n; i++) str[i]=padchar;
	str[n]=0;
}	/* end pad_str() */

/* replace a character in a string .........................................*/

swap_char(str,oldchar,newchar)
register char *str;	/* null-term'd */
int oldchar,newchar;
{
	register int i;

	for (i=0; str[i]>0; i++)
		if (str[i]==oldchar) str[i]=newchar;
}	/* end swap_char() */

/* play a tone on internal sound ...........................................*/

make_tone()
{
	static char sound_data[30]= {
	0,0x80,1,1,2,0x81,3,1,4,0x82,5,1,6,0,7,0xf8,8,16,
	9,16,10,16,11,0,12,0x30,13,9,0xff,0
	};

	if (tone_disabled) return;
	Dosound(sound_data);
}	/* end make_tone() */

/* wait N/100 seconds .......................................................*/

wait(n)
register long n;
{
	for (; n>0L; n--)
	{
		asm {
        moveq	#2,d1				; wait .01 (2/200) seconds
        add.l	0x4BAL,d1		; 200 hz timer
		wait_01:
        cmp.l	0x4BAL,d1
        bne		wait_01
		}
	}
}

/* print null-term'd string .................................................*/

Cprnws(str,lfcr)
register char *str;	/* null-term'd string */
int lfcr;				/* whether to line-feed/return after it */
{
	register int ch;

	while (ch=*str++) Cprnout(ch);
	Cprnout(0x0D);
	if (lfcr)
	{
		Cprnout(0x0A);
		cprnwsrow++;
		if (cprnwsrow>54)	/* 6-line top and bottom margins */
		{
			Cprnout(0x0C);
			cprnwsrow=0;
		}
	}

}	/* end Cprnws() */

/* returns (int)(32000*sin(angle)) ..........................................*/

iSine(angle)
int angle;			/* angle in degrees */
{
	static int sinetable[46]= {
       0, 1117, 2232, 3345, 4454,
	 5557, 6653, 7742, 8820, 9889,
   10945,11987,13016,14028,15023,
   16000,16957,17894,18809,19701,
   20569,21412,22229,23019,23781,
   24513,25216,25889,26529,27138,
   27713,28254,28761,29233,29670,
   30070,30434,30760,31049,31301,
   31514,31689,31825,31922,31981,
	32000
	};

	while (angle<0) angle+=360;
	angle %= 360;

	if (angle<= 90) return sinetable[angle/2];
	if (angle<=180) return sinetable[(180-angle)/2];
	if (angle<=270) return -sinetable[(angle-180)/2];
	return -sinetable[(360-angle)/2];
}	/* end iSine() */

/* returns (int)(32000*cos(angle)) ..........................................*/

iCosine(angle)
int angle;			/* angle in degrees */
{
	return iSine(angle+90);
}	/* end iCosine() */

/* scale value to another range .............................................*/
/* returns scaled value */
/* change name to val_to_val, use throughout !!! */

ival_to_val(val1,low1,high1,low2,high2)
int val1,low1,high1;
register int low2,high2;
{
	register long num,den;

	if (low1==high1)
	{
		num= low2;
		den= 1;
	}
	else
	{
		num= (val1-high1)*(long)low2 - (val1-low1)*(long)high2;
		den= (low1-high1);
	}
	/* watch out for 32-bit overflow! */
	if (
		( num < (0x7fffffffL/1000) ) &&
		( num > (0x7fffffffL/(-1000)) )
		)
	{
		num= (1000*num)/den;
		num= (num/1000) + ((num%1000)>=500) ;
	}
	else
		num /= den ;

	/* clip num to [low2,high2] (which might be a reversed range) */
	if (low2>high2)
	{
		asm { exg low2,high2 }
	}
	if (num<low2 ) num=low2;
	if (num>high2) num=high2;
	
	return (int)num;

}	/* end ival_to_val() */

/* scale value to another range .............................................*/
/* returns scaled value */
/* change name to lval_to_val, use throughout !!! */

long val_to_val(val1,low1,high1,low2,high2)
long val1,low1,high1;
long low2,high2;
{
	return
		low1==high1 ? low2 :
		(((val1-high1)*low2) - ((val1-low1)*high2))/(low1-high1) ;
}	/* end val_to_val() */

/* simple 16-bit checksum ...................................................*/

extern checksum();
asm {
checksum:	/* 4(a7) --> start, 8(a7) --> end */
	move.l	4(a7),d0			; --> start
	andi.l	#0xFFFFFFFE,d0	; must be on word boundary
	move.l	d0,a0
	move.l	8(a7),d1			; --> end
	clr.w		d0					; init sum
	sub.l		a0,d1				; # bytes to be checksummed
	ble		end_sum
csumlp:
	add.w		(a0)+,d0
	subq.l	#2,d1
	bgt		csumlp
end_sum:
	rts
}	/* end checksum() */

/* 16-bit CRC ...............................................................*/

extern crc16();
asm {
crc16:	/* 4(a7) --> start, 8(a7) --> end */
	move.l	4(a7),d0			; --> start
	andi.l	#0xFFFFFFFE,d0	; must be on word boundary
	move.l	d0,a0
	move.l	8(a7),d1			; --> end
	clr.w		d0					; init crc
	sub.l		a0,d1				; # bytes to be crc'd
	lsr.w		#1,d1				; # words to be crc'd
	subq.w	#1,d1				; prepare for dbf
	ble		end_crc
crclp:
	move.w	(a0)+,d2
	moveq		#7,d3
crclp2:
	lsl.b		#1,d2
	roxl.w	#1,d0
	bcc		crcskip
	eori.w	#0x8005,d0
crcskip:
	dbf		d3,crclp2
	dbf		d1,crclp
end_crc:
	rts

}	/* end crc16() */

/* allocate buffer on 256-byte boundary .....................................*/

long malloc256(nbytes)
long nbytes;
{
	register long templong;

	if ( templong = Malloc(nbytes+256L) )
	{
		templong+=256L;
		templong&=0xffffff00L;
	}
	return templong;
}	/* end long malloc256() */

/* find constant in a list of named constants ...............................*/
/* returns pointer to found constant, 0L if not found */

long find_const(name,ptr,leng)
register char *name;	/* --> name to be searched for (8 characters) */
register long ptr;	/* --> constant list to be searched */
long leng;				/* length of constant list (bytes) */
{
	register long endptr;

	endptr= ptr+leng;
	while (ptr<endptr)
	{
		if (!comp_bytes(ptr,name,8L)) break;
		ptr += (8 + 2 + ((NAMEDCONST*)(ptr))->length);
	}
	return ptr==endptr ? 0L : ptr ;
}	/* end find_const() */

/* EOF */
