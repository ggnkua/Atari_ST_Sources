/****************** (c) Trevor Blight 2002 ****************************
*
*
* This file is part of ttf-gdos.
*
* ttf-gdos is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*
********************************************
*
*
*  this file implements a simple monitor program for the true type interpreter
*
******************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <unixlib.h>
#include <ctype.h>

#include "ttf.h"
#include "interp.h"
#include "ibug.h"

extern INSTRUCTION *ins_ptr;

static char prev_ch;
static INSTRUCTION *go_adr;
static char go_adr_str[8];
static BOOL go_flag;
INSTRUCTION *prg_start;
char *prg_str;

static const char *iname[] =
{  "SVTCA[y]",          /* 00 */
   "SVTCA[x]",          /* 01 */
   "SPVTCA[y]",         /* 02 */
   "SPVTCA[x]",         /* 03 */
   "SFVTCA[y]",         /* 04 */
   "SFVTCA[x]",         /* 05 */
   "SPVTL[paralell]",   /* 06 */
   "SPVTL[perpendicular]", /* 07 */
   "SFVTL[paralell]",   /* 08 */
   "SFVTL[perpendicular]", /* 09 */
   "SPVFS[]",           /* 0a */
   "SFVFS[]",           /* 0b */
   "GPV[]",             /* 0c */
   "GFV[]",             /* 0d */
   "SFVTPV[]",          /* 0e */
   "ISECT[]",           /* 0f */
   "SRP0[]",            /* 10 */
   "SRP1[]",            /* 11 */
   "SRP2[]",            /* 12 */
   "SZP0[]",            /* 13 */
   "SZP1[]",            /* 14 */
   "SZP2[]",            /* 15 */
   "SZPS[]",            /* 16 */
   "SLOOP[]",           /* 17 */
   "RTG[]",             /* 18 */
   "RTHG[]",            /* 19 */
   "SMD[]",             /* 1a */
   "ELSE[]",            /* 1b */
   "JMPR[]",            /* 1c */
   "SCVTCI[]",          /* 1d */
   "SSWCI[]",           /* 1e */
   "SSW[]",             /* 1f */
   "DUP[]",             /* 20 */
   "POP[]",             /* 21 */
   "CLEAR[]",           /* 22 */
   "SWAP[]",            /* 23 */
   "DEPTH[]",           /* 24 */
   "CINDEX[]",          /* 25 */
   "MINDEX[]",          /* 26 */
   "ALIGNPTS[]",        /* 27 */
   "",                  /* 28 */
   "UTP[]",             /* 29 */
   "LOOPCALL[]",        /* 2a */
   "CALL[]",            /* 2b */
   "FDEF[]",            /* 2c */
   "ENDF[]",            /* 2d */
   "MDAP[no round]",    /* 2e */
   "MDAP[round]",       /* 2f */
   "IUP[y]",            /* 30 */
   "IUP[x]",            /* 31 */
   "SHP[rp2, zp1]",     /* 32 */
   "SHP[rp1,zp0]",      /* 33 */
   "SHC[rp2, zp1]",     /* 34 */
   "SHC[rp1,zp0]",      /* 35 */
   "SHZ[rp2, zp1]",     /* 36 */
   "SHC[rp1,zp0]",      /* 37 */
   "SHPIX[]",           /* 38 */
   "IP[]",              /* 39 */
   "MSIRP[no set ref]", /* 3a */
   "MSIRP[set ref]",    /* 3b */
   "ALIGNRP[]",         /* 3c */
   "RTDG[]",            /* 3d */
   "MIAP[no round]",    /* 3e */
   "MIAP[round]",       /* 3f */
   "NPUSHB[]",          /* 40 */
   "NPUSHW[]",          /* 41 */
   "WS[]",              /* 42 */
   "RS[]",              /* 43 */
   "WCVTP[]",           /* 44 */
   "RCVT[]",            /* 45 */
   "GC[current]",       /* 46 */
   "GC[original]",      /* 47 */
   "SCFS[]",            /* 48 */
   "MD[grid]",          /* 49 */
   "MD[original]",      /* 4a */
   "MPPEM[]",           /* 4b */
   "MPS[]",             /* 4c */
   "FLIPON[]",          /* 4d */
   "FLIPOFF[]",         /* 4e */
   "DEBUG[]",           /* 4f */
   "LT[]",              /* 50 */
   "LTEQ[]",            /* 51 */
   "GT[]",              /* 52 */
   "GTEQ[]",            /* 53 */
   "EQ[]",              /* 54 */
   "NEQ[]",             /* 55 */
   "ODD[]",             /* 56 */
   "EVEN[]",            /* 57 */
   "IF[]",              /* 58 */
   "EIF[]",             /* 59 */
   "AND[]",             /* 5a */
   "OR[]",              /* 5b */
   "NOT[]",             /* 5c */
   "DELTAP1[]",         /* 5d */
   "SDB[]",             /* 5e */
   "SDS[]",             /* 5f */
   "ADD[]",             /* 60 */
   "SUB[]",             /* 61 */
   "DIV[]",             /* 62 */
   "MUL[]",             /* 63 */
   "ABS[]",             /* 64 */
   "NEG[]",             /* 65 */
   "FLOOR[]",           /* 66 */
   "CEILING[]",         /* 67 */
   "ROUND[grey]",       /* 68 */
   "ROUND[black]",      /* 69 */
   "ROUND[white]",      /* 6a */
   "NROUND[11]",        /* 6b */
   "NROUND[grey]",      /* 6c */
   "NROUND[black]",     /* 6d */
   "NROUND[white]",     /* 6e */
   "NROUND[11]",        /* 6f */
   "WCVTF[]",           /* 70 */
   "DELTAP2[]",         /* 71 */
   "DELTAP3[]",         /* 72 */
   "DELTAC1[]",         /* 73 */
   "DELTAC2[]",         /* 74 */
   "DELTAC3[]",         /* 75 */
   "SROUND[]",          /* 76 */
   "S45ROUND[]",        /* 77 */
   "JROT[]",            /* 78 */
   "JROF[]",            /* 79 */
   "ROFF[]",            /* 7a */
   "",                  /* 7b */
   "RUTG[]",            /* 7c */
   "RDTG[]",            /* 7d */
   "SANGW[]<<old",      /* 7e */
   "AA[]<<<old",        /* 7f */
   "FLIPPT[]",          /* 80 */
   "FLIPRGON[]",        /* 81 */
   "FLIPRGOFF[]",       /* 82 */
   "",                  /* 83 */
   "",                  /* 84 */
   "SCANCTRL[]",        /* 85 */
   "SDPVTL[parallel]",  /* 86 */
   "SDPVTL[perpendicular]", /* 87 */
   "GETINFO[]",         /* 88 */
   "IDEF[]",            /* 89 */
   "ROLL[]",            /* 8a */
   "MAX[]",             /* 8b */
   "MIN[]",             /* 8c */
   "SCANTYPE[]",        /* 8d */
   "INSTCTRL[]",        /* 8e */
   "",                  /* 8f */
   "",                  /* 90 */
   "",                  /* 91 */
   "",                  /* 92 */
   "",                  /* 93 */
   "",                  /* 94 */
   "",                  /* 95 */
   "",                  /* 96 */
   "",                  /* 97 */
   "",                  /* 98 */
   "",                  /* 99 */
   "",                  /* 9a */
   "",                  /* 9b */
   "",                  /* 9c */
   "",                  /* 9d */
   "",                  /* 9e */
   "",                  /* 9f */
   "",                  /* a0 */
   "",                  /* a1 */
   "",                  /* a2 */
   "",                  /* a3 */
   "",                  /* a4 */
   "",                  /* a5 */
   "",                  /* a6 */
   "",                  /* a7 */
   "",                  /* a8 */
   "",                  /* a9 */
   "",                  /* aa */
   "",                  /* ab */
   "",                  /* ac */
   "",                  /* ad */
   "",                  /* ae */
   "",                  /* af */
   "PUSHB[1]",          /* b0 */
   "PUSHB[2]",          /* b1 */
   "PUSHB[3]",          /* b2 */
   "PUSHB[4]",          /* b3 */
   "PUSHB[5]",          /* b4 */
   "PUSHB[6]",          /* b5 */
   "PUSHB[7]",          /* b6 */
   "PUSHB[8]",          /* b7 */
   "PUSHW[1]",          /* b8 */
   "PUSHW[2]",          /* b9 */
   "PUSHW[3]",          /* ba */
   "PUSHW[4]",          /* bb */
   "PUSHW[5]",          /* bc */
   "PUSHW[6]",          /* bd */
   "PUSHW[7]",          /* be */
   "PUSHW[8]",          /* bf */
   "MDRP[00000]",       /* c0 */
   "MDRP[00001]",       /* c1 */
   "MDRP[00010]",       /* c2 */
   "MDRP[00011]",       /* c3 */
   "MDRP[00100]",       /* c4 */
   "MDRP[00101]",       /* c5 */
   "MDRP[00110]",       /* c6 */
   "MDRP[00111]",       /* c7 */
   "MDRP[01000]",       /* c8 */
   "MDRP[01001]",       /* c9 */
   "MDRP[01010]",       /* ca */
   "MDRP[01011]",       /* cb */
   "MDRP[01100]",       /* cc */
   "MDRP[01101]",       /* cd */
   "MDRP[01110]",       /* ce */
   "MDRP[01111]",       /* cf */
   "MDRP[10000]",       /* d0 */
   "MDRP[10001]",       /* d1 */
   "MDRP[10010]",       /* d2 */
   "MDRP[10011]",       /* d3 */
   "MDRP[10100]",       /* d4 */
   "MDRP[10101]",       /* d5 */
   "MDRP[10110]",       /* d6 */
   "MDRP[10111]",       /* d7 */
   "MDRP[11000]",       /* d8 */
   "MDRP[11001]",       /* d9 */
   "MDRP[11010]",       /* da */
   "MDRP[11011]",       /* db */
   "MDRP[11100]",       /* dc */
   "MDRP[11101]",       /* dd */
   "MDRP[11110]",       /* de */
   "MDRP[11111]",       /* df */
   "MIRP[00000]",       /* e0 */
   "MIRP[00001]",       /* e1 */
   "MIRP[00010]",       /* e2 */
   "MIRP[00011]",       /* e3 */
   "MIRP[00100]",       /* e4 */
   "MIRP[00101]",       /* e5 */
   "MIRP[00110]",       /* e6 */
   "MIRP[00111]",       /* e7 */
   "MIRP[01000]",       /* e8 */
   "MIRP[01001]",       /* e9 */
   "MIRP[01010]",       /* ea */
   "MIRP[01011]",       /* eb */
   "MIRP[01100]",       /* ec */
   "MIRP[01101]",       /* ed */
   "MIRP[01110]",       /* ee */
   "MIRP[01111]",       /* ef */
   "MIRP[10000]",       /* f0 */
   "MIRP[10001]",       /* f1 */
   "MIRP[10010]",       /* f2 */
   "MIRP[10011]",       /* f3 */
   "MIRP[10100]",       /* f4 */
   "MIRP[10101]",       /* f5 */
   "MIRP[10110]",       /* f6 */
   "MIRP[10111]",       /* f7 */
   "MIRP[11000]",       /* f8 */
   "MIRP[11001]",       /* f9 */
   "MIRP[11010]",       /* fa */
   "MIRP[11011]",       /* fb */
   "MIRP[11100]",       /* fc */
   "MIRP[11101]",       /* fd */
   "MIRP[11110]",       /* fe */
   "MIRP[11111]",       /* ff */
}; /* iname[] */


INSTRUCTION *ilist(  INSTRUCTION *lip )
{
register INSTRUCTION instruction_code = *lip++;
   if( *iname[instruction_code] ) {
      printf( "%s.%d: %s\t", prg_str, (int)(lip - 1 - prg_start), iname[instruction_code] );
   }
   else {
      printf( "--- no func ---, code = %d", instruction_code );
   } /* if */
   if( instruction_code == 0x40 ) {	/* pushn bytes */
   int n = *lip++;	/* nr bytes */
      printf( " (%d)", n );
      while( n-- > 0) {
	 printf( " %d", *lip++ );
      } /* while */
   }
   else if( instruction_code == 0x41 ) {	/* pushn words */
   int n = *lip++;	/* nr words */
      printf( " (%d)", n );
      while( n-- > 0) {
      int16 w;
         w = *lip++;
	 w = w*256 + *lip++;
	 printf( " %d", w );
      } /* while */
   }
   else if( (instruction_code&0xf8) == 0xb0 ) {	/* push bytes */
   int n = instruction_code&7;	/* nr bytes */
      while( n-- >= 0) {
	 printf( " %d", *lip++ );
      } /* while */
   }
   else if( (instruction_code&0xf8) == 0xb8 ) {	/* pushn words */
   int n = instruction_code&7;	/* nr words */
      while( n-- >= 0) {
      uint16 w;
         w = *lip++;
	 w = w*256 + *lip++;
	 printf( " %d", w );
      } /* while */
   } /* if */
   return lip;
} /* ilist() */


char rdch( void )
{
char c;
   fflush( stdout );
   read( 0, &c, 1 );
   return c;
} /* rdch() */

/*** match strings, s2 may contain wildcard chars ***/
static BOOL
match( register const char *s1, register const char *s2 )
{
BOOL result = TRUE;
   while( TRUE ) {
      if( *s2 == '\0' ) {
	 result = (*s1=='\0');
	 break;
      }
      else if( *s2 == '*' ) {
      const char *ss = s1;
         while( TRUE ) {
	    if( match(ss, s2+1) ) {
	       result = TRUE;
	       break;
	    } /* if */
	    if( *ss == '\0' ) {
	       result = FALSE;
	       break;
	    } /* if */
	    ss++;
	 } /* while */
	 break;
      }
      else if( (toupper(*s1) != toupper(*s2)) && (*s2 != '?') ) {
	 result = FALSE;
	 break;
      } /* if */
      s1++; s2++;
   } /* while */
   return result;
} /* match() */

void ibug( void )
{
char ch;
static int  i0;
int    i1;
int depth;
int32 *sp;
char s[32];
char s0[32];
char s1[32];
BOOL loop_flag = FALSE;
static INSTRUCTION *ip0;
INSTRUCTION   *ip1;
static char brk_ins[12];

   ip1 = ilist( ins_ptr );
   if( ((*go_adr_str == '\0') || (strcmp(go_adr_str, prg_str) == 0))
    && ((ip1 > go_adr) && (ins_ptr <= go_adr)) ) {
      printf( "reached go address\n" );
      go_flag = FALSE;
   } /* if */
   if( match( iname[*ins_ptr], brk_ins ) ) {
      printf( "reached break instruction %s at adr %d\n",
             iname[*ins_ptr], (int)(ins_ptr - prg_start) );
      go_flag = FALSE;
   } /* if */

  if( go_flag ) return;

   while( !loop_flag ) {
      ch = rdch(); putchar( '\b' );
      switch( ch ) {
      case '?':
	 printf( "\ng adr\t go til address\n"
	         "$\tshow stack elements\n"
		 "?\thelp\n"
		 "b instruction\tbreak \n"
		 "l [start][,end]\tlist from start..end\n"
		 "space\tstep\n" );
	 break;
      case 'b':
         printf( "\nb " );
	 fgets( brk_ins, sizeof(brk_ins), stdin );
	 break;
      case '$':
	 depth = stack_ptr - stack_Base;
	 printf( "\n$ stack[%d]: ", depth );
	 sp = stack_ptr - 1;
	 i1 = depth>10 ? 10 : depth;
	 while( i1>0 ) {
	    printf( " -> %ld", *sp );
	    sp--; i1--;
	 } /* for */
	 printf( "\n" );
	 break;
      case 'l':
	 printf( "\nl " ); fflush( stdout );
	 fgets( s, sizeof(s), stdin );
	 switch( sscanf( s, "%d, %d", &i0, &i1 ) ) {
	 default:
	    if( prev_ch != 'l' ) {
	       ip0 = ins_ptr;
	    } /* if */
	    ip1 = ip0+10;
	    break;
	 case 1:
	    ip0 = prg_start+i0;
	    ip1 = ip0+10;
	    break;
	 case 2:
	    ip0 = prg_start+i0;
	    ip1 = prg_start+i1;
	 } /* switch */
	 while( ip0<=ip1 ) {
	    ip0 = ilist( ip0 );
	    printf( "\n ");
	 } /* for */
	 break; /* case 'l' */
      case 'g':
	 printf( "\ng " ); fflush( stdout );
	 fgets( s, sizeof(s), stdin );
	 switch( sscanf( s, "%s.%d", s0, s1 ) ) {
	 case 1: 
	    go_adr = prg_start + atoi( s0 );
	    *go_adr_str = '\0';
	    break;
	 case 2:
	    go_adr = prg_start + atoi( s1 );
	    strcpy( go_adr_str, s0);
	    break;
	 } /* switch */
	 go_flag = TRUE;
	 loop_flag = TRUE;
	 break;
      default:
	 loop_flag = TRUE;
      } /* switch */
      prev_ch = ch;
   } /* while */

} /* ibug() */


void nofunc( void )
{
uint8 n = ins_ptr[-1];
   printf( "\afunction %s (%02x) not implemented\n",
                            iname[n], (int)n );
   rdch();
} /* nofunc() */

void reset_ibug( void )
{
   go_flag = FALSE;
   prev_ch = '\0';
} /* reset_bug() */

/****************** end of ibug.c *********************/

