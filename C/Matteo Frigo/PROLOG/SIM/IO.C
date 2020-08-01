/************************************************************************
*									*
* The SB-Prolog System							*
* Copyright SUNY at Stony Brook, 1986; University of Arizona, 1987	*
*									*
************************************************************************/

/*-----------------------------------------------------------------
SB-Prolog is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the SB-Prolog General Public
License for full details.

Everyone is granted permission to copy, modify and redistribute
SB-Prolog, but only under the conditions described in the
SB-Prolog General Public License.   A copy of this license is
supposed to have been given to you along with SB-Prolog so you
can know your rights and responsibilities.  It should be in a
file named COPYING.  Among other things, the copyright notice
and this notice must be preserved on all copies. 
------------------------------------------------------------------ */
/* io.c */

#include "sim.h"
#include "aux.h"

extern double floatval();

/* write_tnum() writes a tagged number out to stream F */

write_tnum(N, F)
LONG N;
FILE *F;
{
    double fv;

    switch((int)(N & 0x7)) {
	case INT_TAG:
	    fprintf(F, "%d", INTVAL(N));
	    break;
	case FLOAT_TAG:
	    fv = floatval(N);
	    fprintf(F, "%g", fv);
	    if ((int)fv == fv) fprintf(F, ".0");
	    break;
	default: fprintf(stderr, "illegal argument to write_tnum: %x\n", N);
    }
}

writepname(file, name_ptr, length)
FILE     *file;
CHAR_PTR name_ptr;
WORD     length;
{
   WORD i, slen;
   CHAR ch;

   for (i = 1; i <= length; ++i) {
	ch = *name_ptr++;
	putc(((ch < ' ' && ch != '\n' && ch != '\t') ? ' ' : ch), file);
	/* nonprintables to blanks */
   }
   /* fflush(file); */
}

writeqname(file, name_ptr, length)
FILE     *file;
CHAR_PTR name_ptr;
WORD     length;
{
   WORD i, need_to_quote;
   CHAR ch;

   ch = *name_ptr;
   if (ch >= 'a' && ch <= 'z')
      need_to_quote = 0;
   else need_to_quote = 1;
   if (!need_to_quote) {
      i = 1;
      while (i < length) {
	 ch = *(name_ptr+i);
	 if (!((ch >= '0' && ch <= '9') ||
	       (ch >= 'A' && ch <= 'Z') ||
	       (ch == '_') ||
	       (ch >= 'a' && ch <= 'z'))) {
            need_to_quote = 1;    /* quote if name contains spl chars */
            break;
	 }
	 else i++;
      }
   }
   if (need_to_quote)
      fprintf(file, "'");
   for (i = 1; i <= length; ++i) {
      if (need_to_quote && *name_ptr == '\'')
	 fprintf(file, "'");
       /* putc(*name_ptr++, file); */
       putc(((*name_ptr < ' ' && *name_ptr != '\n' && *name_ptr != '\t') ?
             ' ' : *name_ptr), file);
       name_ptr++;
   }
   if (need_to_quote)
      fprintf(file, "'");
   /* fflush(file); */
}

printterm(term, car)
LONG term;
BYTE car;
{
   WORD              i, arity;
   PSC_REC_PTR       psc_ptr;
   register LONG_PTR top;

ptd: 
   switch (TAG(term)) {
      case FREE:
	 NDEREF(term, ptd);
	 printf("_%x", UNTAGGED(term));
	 return;
      case CS:
         psc_ptr = GET_STR_PSC(term);
	 if (IS_BUFF(psc_ptr))               /* buffer */
            printf("Buffer_%x", GET_NAME(psc_ptr));
	 else writepname(stdout, GET_NAME(psc_ptr), GET_LENGTH(psc_ptr));
	 arity = GET_ARITY(psc_ptr);
	 if (arity == 0)                     /* constant */
	    return;
	                                     /* structure */
	 printf("(");
	 UNTAG(term);
	 for (i = 1; i <= arity; i++) {
            printterm(term += 4, CAR);
            if (i < arity)                   /* not at end of struct */
	       printf(",");
	 }
	 printf(")");
         /* fflush(stdout); */
         return;
      case NUM:
	 write_tnum(term, stdout);
	 return;
      case LIST:
	 UNTAG(term);
	 if (car)
	    printf("[");
	 printterm(FOLLOW(term), CAR);
	 term = FOLLOW(term + 4);
ldp:     switch (TAG(term)) {
            case FREE:
	       NDEREF(term, ldp);
	       break;
            case LIST:
	       printf(",");
	       printterm(term, CDR);
	       return;
            case CS:
	       if (ISNIL(term)) {    /* term is the 'nil' constant */
	          printf("]");
                  /* fflush(stdout); */
                  return;
	       }
	       break;
	    case NUM:
	       break;
	 }
	 /* vertical bar case */
         printf("|");
	 printterm(term, CAR);
	 printf("]");
	 /* fflush(stdout); */
	 return;
   }
}
