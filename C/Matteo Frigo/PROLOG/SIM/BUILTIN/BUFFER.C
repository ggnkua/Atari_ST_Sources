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
/* buffer.c */

#include "builtin.h"

/*
#define DEBUG_ALLOC
#define EXAMINE_BUFFCODE
#define DEBUG_SUBSTRING
#define DEBUG_CONLENGTH
*/

#define BACKWARDS 0      /* Direction parameter = 0 means backwards, */
                         /* != 0 means forwards */

#define GET_E_LENGTH(ptr)  ( GET_LENGTH(ptr) < LONGBUFF ?  \
                             (LONG)GET_LENGTH(ptr) :       \
			     *(LONG_PTR)(GET_NAME(ptr)-4))

extern LONG_PTR insert();

static BYTE perm = PERM;
static BYTE temp = TEMP;

/* create a buffer psc_entry on the heap.  Len = 4 */

LONG makenullbuff()
{
    LONG        addr;
    PSC_REC_PTR psc_ptr;

    addr  = (LONG)hreg;
    psc_ptr = (PSC_REC_PTR)(hreg + 1);
    *hreg = (LONG)psc_ptr;            /* point to psc record being created */
    hreg += 3;                        /* no ep and no hash link */
    GET_ETYPE(psc_ptr)  = T_BUFF;
    GET_ARITY(psc_ptr)  = 0;
    GET_LENGTH(psc_ptr) = 0;
    GET_NAME(psc_ptr)   = (CHAR_PTR)hreg;
    return addr;
}


b_ALLOC_BUFF()
{
   /* reg1 = size (input)
    * reg2 = Buffer (output)
    * reg3 = 0 => perm, 1 => heap, 2 => subbuff (input)
    * reg4 = Super-Buffer if there is one (input)
    * reg5 = Retcode (output)
    * (long lengths (>= 65535) are kept in 4 bytes immediately preceeding name)
    */

   register LONG     op1, op3, op4;
   register LONG_PTR top;
   PSC_REC_PTR       psc_ptr, sub_psc_ptr;
   LONG              addr, rc, size, len, disp;
   LONG_PTR          loc, stack_top, heap_top;

   extern LONG       alloc_perm();

   /* reg1 should be bound to a number; reg2 is free */
   op1  = reg[1];  DEREF(op1);  size = INTVAL(op1);
   op3  = reg[3];  DEREF(op3);
   rc = 0;

#ifdef DEBUG_ALLOC
   printf("b_ALLOC_BUFF: ");
#endif

   switch (INTVAL(op3)) {

      case 0:                                /* perm */
         addr = alloc_perm(size);            /* addr = ptr to struct node */
					     /*        for buffer         */
#ifdef DEBUG_ALLOC
         printf("case 0 : perm\n");
         printf("            : size = %d   addr = %08x\n", size, addr);
#endif
         if (!unify(reg[2], (addr | CS_TAG)))
            {FAIL0;}
         break;

      case 1:                                /* heap */
#ifdef DEBUG_ALLOC
         printf("case 1 : heap\n");
         printf("            : hreg = %08x size = %d  shift = %x\n", 
                hreg, size, (size + 3) >> 2);
#endif
	 /* check for heap overflow */
	 stack_top = (breg < ereg) ? breg : ereg - ENV_SIZE(cpreg);
	 heap_top  = hreg + 5 + ((size + 3) >> 2);
	 if (stack_top < heap_top) {
	    /* garbage_collection("b_ALLOC_BUFF"); */
	    if (stack_top < heap_top)    /* still too full */
	       quit("Heap overflow\n");
	 }
         addr = makenullbuff();
         psc_ptr = GET_STR_PSC(addr);
#ifdef DEBUG_ALLOC
         printf("            : addr = %08x   psc_ptr = %08x\n\n",
		addr, psc_ptr);
#endif
         if (size < LONGBUFF)
 	   GET_LENGTH(psc_ptr) = size;
         else {
            GET_LENGTH(psc_ptr) = LONGBUFF;
            *hreg++ = size;
            GET_NAME(psc_ptr) = (CHAR_PTR)hreg;
         }
         hreg += (size + 3) >> 2;
	 /* add a trailing CS-tagged pointer (end_buf) for GC */
	 *hreg++ = (LONG)psc_ptr | CS_TAG;
         *(LONG_PTR)GET_NAME(psc_ptr) = 4;   /* displacement of next free */
					     /*   (for subbuffers)        */
#ifdef DEBUG_ALLOC
         printf("            : hreg = %08x \n", hreg);
         printf("            : addr = %08x  =>  %08x\n", addr, *(LONG_PTR)addr);
         printf("            : psc_ptr  = %08x\n", psc_ptr);
         printf("            : etype = %d  arity = %d  len = %d\n",
                GET_ETYPE(psc_ptr), GET_ARITY(psc_ptr), GET_LENGTH(psc_ptr));
         printf("            : nameptr = %08x\n", GET_NAME(psc_ptr));
         printf("            : ep      = %08x\n", GET_EP(psc_ptr));
#endif
         if (!unify(reg[2], (addr | CS_TAG)))
            {FAIL0;}
         break;

      case 2:                                /* subbuffer */
#ifdef DEBUG_ALLOC
         printf("case 2 : subbuffer\n");
#endif
         op4 = reg[4];  DEREF(op4);          /* super buffer */
         psc_ptr = GET_STR_PSC(op4);
         len = GET_E_LENGTH(psc_ptr);
         disp = *(LONG_PTR)GET_NAME(psc_ptr);
         loc = (LONG_PTR)(GET_NAME(psc_ptr) + disp);

         if (disp + 12 + size > len)         /* not enough room in super buf */
            rc = 1;                          /*   return error code */
         else {
            addr = (LONG)loc;
            sub_psc_ptr = (PSC_REC_PTR)(loc + 1);
            *loc = (LONG)sub_psc_ptr;
            loc += 3;                        /* no ep, no hash link */
            GET_ETYPE(sub_psc_ptr) = T_BUFF;
            GET_ARITY(sub_psc_ptr) = 0;
            if (size < LONGBUFF)
               GET_LENGTH(sub_psc_ptr) = size;
            else {
               GET_LENGTH(sub_psc_ptr) = LONGBUFF;
               *loc++ = size;
            }
            GET_NAME(sub_psc_ptr) = (CHAR_PTR)loc;
            loc += (size + 3) >> 2;
            *(LONG_PTR)GET_NAME(sub_psc_ptr) = 4;   /* displacement of next free */
            disp = (LONG)((CHAR_PTR)loc - GET_NAME(psc_ptr));
            *(LONG_PTR)GET_NAME(psc_ptr) = disp;
            if (!unify(reg[2], (addr | CS_TAG)))
               {FAIL0;}
         }
         break;
   }
   if (!unify(reg[5], MAKEINT(rc)))
      {FAIL0;}
}

b_BUFF_CODE()
{
   /* b_BUFF_CODE inserts a word into, or extracts a word from, a buffer.
    * It is VERY low-level and implementation dependent. It is used to
    * generate byte-code into a buffer, and retrieve a word from a buffer.
    * On entry, reg1 is bound to a buffer, reg2 is the offset in the buffer,
    * reg3 contains a number indicating what internal word to generate,
    * reg4 contains a term from which the word to insert in the buffer is
    * extracted, or a variable that is bound to the word extracted from
    * the buffer
    */

   PSC_REC_PTR       psc_ptr, io_psc_ptr;
   register LONG     op1, op4;
   register LONG_PTR top;
   FILE              *fdes;
   WORD              disc, i, arity;
   LONG              disp;
   CHAR              s[100];
   LONG              tempvar, temp1, temp2;

   op4 = reg[1];  DEREF(op4);
   if (!ISCONSTR(op4)) {
      errmsg(11);
      FAIL0;
      return;
   }
   psc_ptr = GET_STR_PSC(op4);
   op4 = reg[2];  DEREF(op4);  disp = INTVAL(op4);
   op4 = reg[3];  DEREF(op4);  disc = INTVAL(op4);
   op4 = reg[4];  DEREF(op4);

   switch (disc) {
      case  0: /* ppsc: constant/structure, UNTAGGED psc_ptr to buff */
               /* make permanent if could be dangling pointer        */
               if ((LONG)GET_NAME(psc_ptr) < (LONG)GET_STR_PSC(op4)) {
                  io_psc_ptr = GET_STR_PSC(op4);
                  op4 = (LONG)insert(GET_NAME(io_psc_ptr),
				     GET_LENGTH(io_psc_ptr),
                                     GET_ARITY(io_psc_ptr), &perm) | CS_TAG;
               }
               *(LONG_PTR)(GET_NAME(psc_ptr) + disp) = (LONG)GET_STR_PSC(op4);
               break;
      case  1: /* pppsc: con/str, UNTAGGED ptr to psc_ptr to buff */
               /* make permanent if could be dangling pointer        */
               if ((LONG)GET_NAME(psc_ptr) < (LONG)UNTAGGED(op4)) {
                  io_psc_ptr = GET_STR_PSC(op4);
                  op4 = (LONG)insert(GET_NAME(io_psc_ptr),
				     GET_LENGTH(io_psc_ptr),
                                     GET_ARITY(io_psc_ptr), &perm);
               }
               *(LONG_PTR)(GET_NAME(psc_ptr) + disp) = UNTAGGED(op4);
               break;
      case  2: /* pn: number, UNTAGGED LONG value to buff */
               *(LONG_PTR)(GET_NAME(psc_ptr) + disp) = INTVAL(op4);
               break;
      case  3: /* ps: number, UNTAGGED short value to buff */
               *(WORD_PTR)(GET_NAME(psc_ptr) + disp) = INTVAL(op4);
               break;
      case  4: /* ga: return address of location in buffer, as tagged num */
               if (!unify(op4, MAKEINT(GET_NAME(psc_ptr) + disp)))
                  {FAIL0;}
               break;
      case  5: /* gn: return word at location in buffer, as tagged num */
               if (!unify(op4, MAKEADD(*(LONG_PTR)(GET_NAME(psc_ptr) + disp))))
                  {FAIL0;}
               break;
      case  6: /* gs: return short at location in buffer, as tagged num */
               if (!unify(op4, MAKEINT(*(WORD_PTR)(GET_NAME(psc_ptr)+disp)))) {
                  FAIL0;
               }
               break;
      case  7: /* gepb: return buff that 1st arg pred ep points to       */
               /* assumes ep points to 2nd word in buff, first is ptr to */
               /*   its own psc_ptr                                      */
               if (!unify(op4, *(LONG_PTR)(GET_EP(psc_ptr) - 1)))
                  {FAIL0;}
               break;
      case  8: /* gpb: return buff that word at disp-buff points to */
               if (!unify(op4,
                          *(LONG_PTR)(*(LONG_PTR)(GET_NAME(psc_ptr)+disp)-4)))
                  {FAIL0;}
               break;
      case  9: /* pep: set ep of term to point to 4th byte in buff */
               GET_EP(psc_ptr) = (LONG_PTR)(GET_NAME(GET_STR_PSC(op4)) + 4);
               GET_ETYPE(psc_ptr) = T_DYNA;
               /* and set 1st word of buff to point to buff psc_ptr */
               /* *(LONG_PTR)GET_NAME(GET_STR_PSC(op4)) = op4; */
               break;
      case 10: /* pbr: set word p points to 4th byte in buff */
               *(CHAR_PTR *)(GET_NAME(psc_ptr) + disp) = 
		     GET_NAME(GET_STR_PSC(op4)) + 4;
               /* and set 1st word of buff to point to buff psc_ptr */
               /* *(LONG_PTR)GET_NAME(GET_STR_PSC(op4)) = op4; */
               break;
      case 11: /* rep: reset ep of first arg to undefined */
               if (IS_PRED(psc_ptr) || IS_DYNA(psc_ptr)) {
                  GET_EP(psc_ptr) = 0;
                  GET_ETYPE(psc_ptr) = T_ORDI;
               }
               break;
      case 12: /* fv: free variable to buff, for use with getival instr */
               temp1 = (LONG)(GET_NAME(psc_ptr) + disp);
               if (ISVAR(temp1))
                  FOLLOW(temp1) = temp1;
               else {
                  curr_fence = (CHAR_PTR)(((LONG)curr_fence + 3) & 0xfffffffc);
                  FOLLOW(temp1) = (LONG)curr_fence;
                  FOLLOW(curr_fence) = (LONG)curr_fence;
                  curr_fence += 4;
		  if (curr_fence >= max_fence)
		     quit("Program area overflow\n");
               }
               break;
      case 13: /* execb: branch into buffer,  using 4th arg as call */
               pcreg = (WORD_PTR)(GET_NAME(psc_ptr) + disp);
               arity = GET_ARITY(GET_STR_PSC(op4));
               UNTAG(op4);
               for (i = 1; i <= arity; i++)
                  reg[i] = FOLLOW((LONG_PTR)op4 + i);
               break;
      case 14: /* ptv: number or const, tagged word value to buff */
               /* make permanent if could be dangling pointer     */
               if (ISCONSTR(op4) && (LONG)GET_NAME(psc_ptr) <
		   (LONG)UNTAGGED(op4)) {
                  io_psc_ptr = GET_STR_PSC(op4);
                  op4 = (LONG)insert(GET_NAME(io_psc_ptr),
				     GET_LENGTH(io_psc_ptr),
                                     GET_ARITY(io_psc_ptr), &perm) | CS_TAG;
               }
               *(LONG_PTR)(GET_NAME(psc_ptr) + disp) = op4;
               break;
      case 15: /* ptp: put str-tagged pointer to second location */
               *(LONG_PTR)(GET_NAME(psc_ptr) + disp) =
                     (LONG)((LONG)(GET_NAME(psc_ptr) + INTVAL(op4)) | CS_TAG);
               break;
      case 16: /* ptl: put list-tagged pointer to second location */
               *(LONG_PTR)(GET_NAME(psc_ptr) + disp) =
                     (LONG)((LONG)(GET_NAME(psc_ptr) + INTVAL(op4)) | LIST_TAG);
               break;
      case 17: /* pvar: put variable into buffer */
               tempvar = (LONG)(GET_NAME(psc_ptr) + disp);
               FOLLOW(tempvar) = tempvar;
               if (op4 >= (LONG)GET_NAME(psc_ptr) &&
                   op4 <= (LONG)(GET_NAME(psc_ptr) + GET_E_LENGTH(psc_ptr)))
                  /* already points into the buffer */
                  FOLLOW(op4) = tempvar;        /* point word to it */
               else {
                  FOLLOW(op4) = tempvar;
                  PUSHTRAIL(op4);               /* and trail! */
               }
               break;
      case 18: /* ubv: unify value with buffer */
               if (!unify(GET_NAME(psc_ptr) + disp, op4))
                  {FAIL0;}
               break;
      case 19: /* cep: copy ep of last arg to ep of first */
               io_psc_ptr = GET_STR_PSC(op4);
               if (!IS_BUFF(psc_ptr)) {
                  GET_EP(psc_ptr) = GET_EP(io_psc_ptr);
                  GET_ETYPE(psc_ptr) = GET_ETYPE(io_psc_ptr);
               }
               break;
      case 20: /* pepb: copy ep of last arg to loc in buff */
               io_psc_ptr = GET_STR_PSC(op4);
               FOLLOW(GET_NAME(psc_ptr) + disp) = (LONG)GET_EP(io_psc_ptr);
               break;
      case 21: /*gnb: return next buffer along the hash chain */
               op1 = *(LONG_PTR)(GET_NAME(psc_ptr) + disp);
               op1 = *(LONG_PTR)(op1 + 12) - 12;
               if (!unify(op4, *(LONG_PTR)op1))
                  {FAIL0;}
               break;
      case 22: /*dis: disassemble buffer for debugging assert         */
               /*op1: buffer; op2: 0 for "w" 1 for "a"; op4: filename */
               io_psc_ptr = GET_STR_PSC(op4);
               temp1 = (LONG)pcreg;
               temp2 = num_line;
               num_line = 1;
               namestring(io_psc_ptr, s);
               if (disp == 0)
                  fdes = fopen(s, "w");
               else
                  fdes = fopen(s, "a");
               fprintf(fdes,
  "\n /* New Buffer Below: pscptr, arity, length, nameptr, backptr *\/\n\n");
               fprintf(fdes, "%x, %d, %d, %x, %x \n",
		       psc_ptr, GET_ARITY(psc_ptr), GET_LENGTH(psc_ptr),
		       GET_NAME(psc_ptr), GET_EP(psc_ptr));
               pcreg = (WORD_PTR)(GET_NAME(psc_ptr) + 4);
               while (pcreg <
		      (WORD_PTR)(GET_NAME(psc_ptr) + GET_LENGTH(psc_ptr)))
                  print_inst(fdes, pcreg);
               fflush(fdes);
               fclose(fdes);
               pcreg = (WORD_PTR)temp1;
               num_line = temp2;
               break;
      case 23: /* ps: short number, UNTAGGED word value to buff */
               *(WORD_PTR)(GET_NAME(psc_ptr) + disp) = INTVAL(op4);
               break;
      case 24: /* gs: return short number at location in buffer,  */
               /* as tagged num                                   */
               if (!unify(op4, MAKEINT(*(WORD_PTR)(GET_NAME(psc_ptr) + disp))))
                  {FAIL0;}
               break;
      case 25: /* bb: build a buffer for a pointer in a buffer, 0 len  */
               temp1 = makenullbuff();
               io_psc_ptr = GET_STR_PSC(temp1);
               GET_NAME(io_psc_ptr) = *(CHAR_PTR *)(GET_NAME(psc_ptr) + disp);
               if (!unify(op4, (temp1 | CS_TAG)))
                  {FAIL0;}
               break;
      case 26: /* pba: put buffer address into buffer */
               io_psc_ptr = GET_STR_PSC(op4);
               FOLLOW(GET_NAME(psc_ptr) + disp) = (LONG)(GET_NAME(io_psc_ptr));
               break;
      case 27: /* pf: put float (in WAM format, word) into buffer */
               *(LONG_PTR)(GET_NAME(psc_ptr) + disp) = op4;
               break;
      case 28: /* gppsc: get ptr to psc_table entry */
	       if (!unify(op4, *(LONG_PTR)(GET_NAME(psc_ptr) + disp) | CS_TAG))
                  {FAIL0;}
               break;
      case 29: /* gf: get float (in WAM format, word) from buffer */
               if (!unify(op4, *(LONG_PTR)(GET_NAME(psc_ptr) + disp)))
                  {FAIL0;}
	       break;
      case 30: /* pb: number, UNTAGGED byte value to buff */
               *(BYTE_PTR)(GET_NAME(psc_ptr) + disp) = INTVAL(op4);
               break;
      case 31: /* gb: return byte at location in buffer, as tagged num */
               if (!unify(op4, MAKEINT(*(BYTE_PTR)(GET_NAME(psc_ptr) + disp))))
                  {FAIL0;}
               break;
      case 32: /* similar to Case 2, but using ADDVAL.  -- Ultrix */
               *(LONG_PTR)(GET_NAME(psc_ptr) + disp) = ADDVAL(op4);
               break;
      case 33: /* similar to Case 4, but using MAKEADD. -- Ultrix */
               if (!unify(op4, MAKEADD(GET_NAME(psc_ptr) + disp)))
                  {FAIL0;}
               break;
   }
}

b_TRIMBUFF()
{
   /* reg1 : new length (if <0 scan for 0x00)
    * reg2 : buffer
    * reg3 : 0 => perm, 1 => temp, 2 => temp in superbuff (r4)
    * reg4 : superbuff to trim (if 2)
    */

   register LONG     op1, op2, op3;
   register LONG_PTR top;
   PSC_REC_PTR       psc_ptr, sb_psc_ptr;
   LONG              len;
   LONG_PTR          new_end;

   op3 = reg[3];  DEREF(op3);  op3 = INTVAL(op3);
   op2 = reg[2];  DEREF(op2);  psc_ptr = GET_STR_PSC(op2);
   op1 = reg[1];  DEREF(op1);  len = INTVAL(op1);

#ifdef DEBUG_ALLOC
   printf("b_TRIMBUFF: op1 = %08x  op = %08x  op3 = %08x\n", op1, op2, op3);
   printf("          : ptr = %08x  len = %08x\n", psc_ptr, len);
   printf("          : type = %d  arity = %d  len = %d\n", 
          GET_ETYPE(psc_ptr), GET_ARITY(psc_ptr), GET_LENGTH(psc_ptr));
   printf("          : name = %08x  %s\n",
	  GET_NAME(psc_ptr), GET_NAME(psc_ptr));
   printf("          : ep   = %08x\n", GET_EP(psc_ptr));
#endif

   if (len < 0) {
      if (GET_NAME(psc_ptr)) {
         len = strlen(GET_NAME(psc_ptr));
#ifdef DEBUG_ALLOC
         printf(" len < 0  : newlen = %d\n", len);
#endif
      } else {
#ifdef DEBUG_ALLOC
         printf(" len < 0  : failing  (FAIL0)\n");
#endif
         FAIL0;
      }
   }
   else if (op3 == 0) {                      /* perm */
      if (curr_fence == GET_NAME(psc_ptr) + GET_LENGTH(psc_ptr))
         curr_fence = GET_NAME(psc_ptr) + len;
   }
   else if (op3 == 1) {                      /* heap */
      new_end = (LONG_PTR)GET_NAME(psc_ptr) + ((len + 3) >> 2);
      *new_end = (LONG)psc_ptr | CS_TAG;     /* move up end_buf pointer*/
      if (hreg == (LONG_PTR)psc_ptr + BUFF_SIZE(psc_ptr) - 1)
         hreg = new_end + 1;
   }
   else {                                    /* in superbuffer */
      op2 = reg[4];  DEREF(op2);  sb_psc_ptr = GET_STR_PSC(op2);
      if ((LONG)GET_NAME(sb_psc_ptr) + *(LONG_PTR)GET_NAME(sb_psc_ptr) ==
          (LONG)GET_NAME(psc_ptr) + GET_E_LENGTH(psc_ptr))
         *(LONG_PTR)GET_NAME(sb_psc_ptr) =   /* new displacement */
             UNTAGGED((LONG)GET_NAME(psc_ptr) + len -
	     (LONG)GET_NAME(sb_psc_ptr) + 3);
   }
   if (GET_LENGTH(psc_ptr) < LONGBUFF)
      GET_LENGTH(psc_ptr) = len;
   else
      *(LONG_PTR)(GET_NAME(psc_ptr) - 4) = len;
}


b_SUBSTRING()
{
   /* reg1 = direction (1 = forwards for read,  0 = backwards for write)
    * reg2 = numbytes
    * reg3 = Internal constant
    * reg4 = Initial location in the input buffer
    * reg5 = Input Buffer  (must be a valid constant)
    * reg6 = Final location in the input buffer after reading from or
    *        writing into the buffer
    *
    * Forwards: If the internal constant parameter is free upon entry, it
    *           takes the first numbytes of the input buffer and creates
    *           an internal constant.  Reg 6 gets bound to the location
    *           in the input buffer directly FOLLOWing the constant. If the
    *           constant parameter is already bound, it is checked against
    *           the one in the buffer to see if they unify.  The numbytes
    *           parameter must unify with the length of the constant.
    *
    * Backwards: Binds numbytes(if not bound) to the length of the internal
    *            constant. Copies the internal constant into the Input Buffer,
    *            and returns in reg 6 an index into the input buffer which
    *            directly FOLLOWs the constant.
    */

   CHAR_PTR    Bnameptr, Cnameptr;   /* Buffer Nameptr, Constant Nameptr */
   PSC_REC_PTR psc_ptr;              /* pointer to psc rec of buffer */
   LONG        addr;                 /* Holds result from insert */
   LONG        offset;               /* Offset into buffer  */
   LONG        numbytes;             /* Numbytes in buffer for constant */
   LONG        i;                    /* Counter */
   LONG        op1, op2, op3, op4, op5;
   register    LONG_PTR top;

   op1 = reg[1];  DEREF(op1);          /* direction */
   op2 = reg[2];                       /* length */
   op3 = reg[3];  DEREF(op3);          /* constant substring */
   op4 = reg[4];  DEREF(op4);          /* offset */
   op5 = reg[5];  DEREF(op5);          /* constant, long string */

   /* check the direction param for error */

   if (!ISINTEGER(op1)) {
      errmsg(0);
      FAIL0;
      return;
   }

   /* check input buffer - ?valid constant */

   if (!ISATOM(op5)) {
      errmsg(8);
      FAIL0;
      return;
   }
   psc_ptr = GET_STR_PSC(op5);

   /* check that offset is valid */

   if (!ISINTEGER(op4)) {
      errmsg(2);
      FAIL0;
      return;
   }
   offset = INTVAL(op4);
   if (GET_LENGTH(psc_ptr) < offset || offset < 0) {
      errmsg(3);
      FAIL0;
      return;
   }

   /* get length of substring */

   if (ISATOM(op3) && !unify(op2, MAKEINT(GET_LENGTH(GET_STR_PSC(op3))))) {
      FAIL0;
      return;
   }
   DEREF(op2);
   if (!ISINTEGER(op2)) {
      errmsg(4);
      FAIL0;
      return;
   }
   numbytes = INTVAL(op2);

   /* check no buffer overflow */

   if (numbytes < 0 || (offset + numbytes) > GET_LENGTH(psc_ptr)) {
      errmsg(3);
      FAIL0;
      return;
   }

   if (INTVAL(op1) != BACKWARDS) {
      /* find the constant, or insert a new one */
      temp = TEMP;
      addr = (LONG)insert(GET_NAME(psc_ptr) + offset, numbytes, 0, &temp);
      if (!unify(op3, addr | CS_TAG)) {
         FAIL0;
         return;
      }
   } else {                              /* going backwards */
      Bnameptr = GET_NAME(psc_ptr);
      if (!ISATOM(op3)) {
         errmsg(5);
	 FAIL0;
         return;
      }
      Cnameptr = GET_NAME(GET_STR_PSC(op3));
      for (i = 0; i < numbytes; i++)    /* copy into buffer */
         Bnameptr[i+offset] = Cnameptr[i];

#ifdef DEBUG_SUBSTRING
      printf("b_SUBSTRING: (1)dir = %d   (2)bytes = %d   (4)ofs = %d\n",
             INTVAL(op1), INTVAL(op2), INTVAL(op4));
      printf("           : const = %08x\n", GET_STR_PSC(op3));
      printf("           :    type = %d  arity = %d  len = %d\n",
             GET_ETYPE(GET_STR_PSC(op3)), GET_ARITY(GET_STR_PSC(op3)),
             GET_LENGTH(GET_STR_PSC(op3)));
      printf("           :    name = %08x : %s\n",  
             GET_NAME(GET_STR_PSC(op3)), GET_NAME(GET_STR_PSC(op3)));
      printf("           : buff  = %08x\n", GET_STR_PSC(op5));
      printf("           :    type = %d  arity = %d  len = %d\n",
             GET_ETYPE(GET_STR_PSC(op5)), GET_ARITY(GET_STR_PSC(op5)),
             GET_LENGTH(GET_STR_PSC(op5)));
      printf("           :    name = %08x : %s\n",  
             GET_NAME(GET_STR_PSC(op5)), GET_NAME(GET_STR_PSC(op5)));
      printf("           : Cname = %s\n", Cnameptr);
      printf("           : Bname = %s\n", Bnameptr);
#endif
   }

   /* check or set out location */

   if (!unify(reg[6], MAKEINT(offset + numbytes)))
      {FAIL0;}
}


b_SUBNUMBER()
{
   /* reg1 = direction (forwards for read,  backward for write)
    * reg2 = number of bytes storing the length
    * reg3 = numeric constant
    * reg4 = Initial location in buffer
    * reg5 = Input Buffer
    * reg6 = Final location in buffer
    *
    * Forward case: Takes numbytes out of Input Buffer, converts
    *               it to a number.  (starting from initial loc in buffer)
    *               Binds reg 6 to location in the buffer FOLLOWing the
    *               string representation of the number.
    *
    * Backward case: Takes a numeric constant, stores its name in the
    *                Input buffer and binds reg6 to the location in the
    *                buffer FOLLOWing the string representation of number
    */

   CHAR_PTR    Bnameptr;          /* Buffer nameptr */
   PSC_REC_PTR psc_ptr;           /* pointer to psc rec of buffer */
   LONG        num;               /* Number from subnumber op */
   LONG        numbytes;          /* Number of bytes */
   LONG        xtra;              /* Number of leading zeros */
   LONG        i;                 /* Counter */
   LONG        offset;            /* Offset into buffer */
   CHAR        s[10];             /* String representation of number */
   LONG        op1, op2, op3, op4, op5;
   register    LONG_PTR top;

   op1 = reg[1];  DEREF(op1);     /* direction */
   op2 = reg[2];  DEREF(op2);     /* length */
   op3 = reg[3];  DEREF(op3);     /* numeric constant,  substring */
   op4 = reg[4];  DEREF(op4);     /* offset */
   op5 = reg[5];  DEREF(op5);     /* buffer constant, long string */

   /* check the direction param for error */

   if (!ISINTEGER(op1)) {
      errmsg(0);
      FAIL0;
      return;
   }

   /* check input buffer - ?valid constant */

   if (!ISATOM(op5)) {
      errmsg(8);
      FAIL0;
      return;
   }
   psc_ptr = GET_STR_PSC(op5);

   /* check that offset is valid */

   if (!ISINTEGER(op4)) {
      errmsg(2);
      FAIL0;
      return;
   }
   offset = INTVAL(op4);
   if (GET_LENGTH(psc_ptr) < offset || offset < 0) {
      errmsg(3);
      FAIL0;
      return;
   }
   if (!ISINTEGER(op2)) {       /* Number of bytes which is the length */
      errmsg(6);                /* of the string representation of the */
      FAIL0;                    /* number MUST be specified in both    */
      return;                   /* the forward and backward case.      */
   }
   numbytes = INTVAL(op2);    /* get the length of const into numbytes  */

   /* check no buffer overflow */

   if (numbytes < 0 || (offset + numbytes) > GET_LENGTH(psc_ptr)) {
      errmsg(3);
      FAIL0;
      return;
   }

  if (INTVAL(op1) != BACKWARDS) {
     /* get numeric equivalent out */
      num = getnum(numbytes, GET_NAME(psc_ptr) + offset);
      if (!unify(op3, MAKEINT(num))) {     /* unify reg3 with number */
         FAIL0;
         return;
      }
   }
   else {                              /* going backwards */
      if (!ISINTEGER(op3)) {
         errmsg(6);                    /* no number to be written */
         FAIL0;
         return;
      }
      num = INTVAL(op3);               /* get number to be written */
      Bnameptr = GET_NAME(psc_ptr);    /* get buffer name pointer */
      itoa(num, s);                    /* make s string representing num */
      xtra = numbytes - strlen(s);     /* number of leading zeros */
      if (xtra < 0) {                  /* number too large */
         errmsg(10);
         FAIL0;
         return;
      }
      for (i = 0; i < xtra; i++)       /* put leading zeros in if any */
         Bnameptr[i+offset] = '0';
      for (i = xtra; i < strlen(s) + xtra; i++)   /* put character rep of */
         Bnameptr[i+offset] = s[(i-xtra)];        /*   number into buffer */
   }

   /* check or set out location */

   if (!unify(reg[6], MAKEINT(offset+numbytes)))
      {FAIL0;}
}


b_SUBDELIM()
{
   /* reg1 = direction       (forwards for read,  backwards for write )
    * reg2 = delimiter
    * reg3 = internal constant
    * reg4 = Initial location in buffer
    * reg5 = Input buffer
    * reg6 = Final location in buffer
    *
    * Forwards: Takes the characters preceeding the delimiter
    *           in the input buffer, and creates an internal
    *           constant with that name.  Binds reg[6] to the
    *           location in the buffer FOLLOWing the delimiter.
    *
    *  Backwards: Puts the internal constant into the buffer,
    *            appends the delimiter to it, binds reg[6] to
    *            the final location in the input buffer
    */

   LONG        addr;                  /* Holds result from insert */
   CHAR_PTR    Bnameptr;              /* Buffer Nameptr */
   CHAR_PTR    Cnameptr;              /* Constant Nameptr */
   CHAR_PTR    Dnameptr;              /* Delimiter Nameptr */
   PSC_REC_PTR psc_ptr, con_psc_ptr;  /* pointers to psc recs */
   LONG        offset;                /* Offset into buffer */
   LONG        Blen;                  /* Buffer length */
   LONG        Clen;                  /* Constant length */
   LONG        i;                     /* Counter */
   LONG        op1, op2, op3, op4, op5;
   register    LONG_PTR top;

   op1 = reg[1];  DEREF(op1);       /* direction */
   op2 = reg[2];  DEREF(op2);       /* delimiter */
   op3 = reg[3];  DEREF(op3);       /* constant,  substring */
   op4 = reg[4];  DEREF(op4);       /* offset */
   op5 = reg[5];  DEREF(op5);       /* buffer constant, long string */

   /* check the direction param for error */

   if (!ISINTEGER(op1)) {
      errmsg(0);
      FAIL0;
      return;
   }

   /* check input buffer - ?valid constant */

   if (!ISATOM(op5)) {
      errmsg(8);
      FAIL0;
      return;
   }
   psc_ptr = GET_STR_PSC(op5);

   /* check that offset is valid */

   if (!ISINTEGER(op4)) {
      errmsg(2);
      FAIL0;
      return;
   }
   offset = INTVAL(op4);
   if (GET_LENGTH(psc_ptr) < offset || offset < 0) {
      errmsg(3);
      FAIL0;
      return;
   }

   if (!ISATOM(op2)) {                     /* delimiter must be given */
      errmsg(7);
      FAIL0;
      return;
   }

   Bnameptr = GET_NAME(psc_ptr);           /* get nameptr for Buffer */
   Dnameptr = GET_NAME(GET_STR_PSC(op2));  /* get nameptr for delimiter */
   if (INTVAL(op1) != BACKWARDS) {
      Blen = GET_LENGTH(psc_ptr);          /* length of Buffer */
      Clen = 0;                            /* get the length of the constant */
      while (Bnameptr[offset+Clen] != Dnameptr[0] && offset + Clen < Blen)
         Clen++;
      if (offset + Clen >= Blen) {
         FAIL0;
         return;
      }
      /* create constant of length Clen */
      temp = TEMP;
      addr = (LONG)insert(Bnameptr + offset, Clen, 0, &temp);
      /* unify this with reg3 */
      if (!(unify(op3, addr | CS_TAG))) {
         FAIL0;
         return;
      }
   }
   else {                                    /* going backwards */
      if (ISATOM(op3)) {       /* make sure there is a constant to write out */
         con_psc_ptr  = GET_STR_PSC(op3);
         Cnameptr = GET_NAME(con_psc_ptr);   /* get cnst nameptr */
         Clen     = GET_LENGTH(con_psc_ptr); /* get length of constant */
         for (i = 0; i < Clen; i++)          /* copy constant into buffer */
            Bnameptr[offset+i] = Cnameptr[i];
         /* copy delimiter into buffer */
         Bnameptr[offset + Clen] = Dnameptr[0];
      }
      else {                                 /* no constant to be written out */
         errmsg(5);
	 FAIL0;
         return;
      }
   }

   /* validate or bind outloc */

   if (!unify(reg[6], MAKEINT(offset+Clen+1)))
      {FAIL0;}
}


b_CONLENGTH()
{
   /* reg 1 is an internal constant or a number
    * reg 2 is the length of the constant or number
    */

   LONG     op1;
   register LONG_PTR top;
   LONG     len;

   op1 = reg[1];  DEREF(op1);

   if (ISATOM(op1)) {
#ifdef  DEBUG_CONLENGTH
      printf("b_CONLENGTH : ptr = %08x\n", GET_STR_PSC(op1));
      printf("            :   type = %d  arity = %d  len = %d\n", 
             GET_ETYPE(GET_STR_PSC(op1)), GET_ARITY(GET_STR_PSC(op1)),
             GET_LENGTH(GET_STR_PSC(op1)));
      printf("            :   name = %08x   %s\n",
             GET_NAME(GET_STR_PSC(op1)), GET_NAME(GET_STR_PSC(op1)));
#endif

      len = GET_E_LENGTH(GET_STR_PSC(op1));
   }
   else if (ISINTEGER(op1))
      len = numlength(INTVAL(op1));
   else if (ISFLOAT(op1)) {
      printf("conlength: FLOAT case not implemented\n");
      len = 0;
   }
   else {
      errmsg(9);
      FAIL0;
      return;
   }

   if (!unify(MAKEINT(len), reg[2]))
      {FAIL0;}
}

/*****************************************************************************/
/* Routine name: errmsg                                                      */
/* Input Parameter: errnum  type: short integer                              */
/* Purpose:  To output a relevant message when an error occurs.              */
/*****************************************************************************/
errmsg(errnum)
WORD errnum;
{
   switch (errnum) {
      case  0: printf("Error: Direction parameter must must be a 0 or 1.\n");
      case  1: printf("Error: Delimiter not found in buffer.\n");
      case  2: printf("Error: Index into buffer is not an integer.\n");
      case  3: printf("Error: Index into buffer is out of range.\n");
      case  4: printf(
      "Error: Constant and length params are both free or bound improperly.\n");
      case  5: printf("Error: Nothing to write out in sub* backwards.\n");
      case  6: printf("Error: Length must be bound in subnumber operation.\n");
      case  7: printf(
      "Error: Delimiter must be bound in subdelim operation.\n");
      case  8: printf("Error: Input buffer is free or bound improperly.\n");
      case  9: printf("Error: Improper argument to Conlength.\n");
      case 10: printf("Error: Number too large for field in Subnumber.\n");
      case 11: printf("Error: Illegal arg to buff_code.\n");
   }
}
