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
/* loader.c */

#include "sim.h"
#include "inst.h"
#include "aux.h"

#define GET_DATA(x,y)  (y*sizeof(*x) - fread(x,sizeof(char),y*sizeof(*x),fp))
#define PUT_DATA(x,y)  (fwrite(x, sizeof(char), y*sizeof(*x), fp)/sizeof(*x))
	/* GET_DATA and PUT_DATA are defined in this way to avoid byte
	   ordering problems when words are written out -- this way we
	   write things out,  and read them in,  a byte at a time.	*/
#define ST_PTRPTRPSC(i_addr) \
   *(LONG_PTR *)i_addr = reloc_table[*(LONG_PTR)i_addr];

#define ST_PTRPSC(i_addr)    \
   *(LONG_PTR)i_addr = *reloc_table[*(LONG_PTR)i_addr];

static WORD_PTR inst_addr;
static LONG_PTR hptr;
static LONG_PTR reloc_table[500];
static LONG_PTR last_text;

WORD   eof_flag;
LONG   psc_bytes, text_bytes, index_bytes, magic;

int    (*load_routine[20])();

static FILE *fp;
static BYTE perm = PERM;

extern LONG_PTR reloc_addr();        /* actually it is defined below */

/****************************************************************************/
/*                                                                          */
/* fix_bb4: fixes the byte-backwards problem.  It is passed a pointer to a  */
/* sequence of 4 bytes read in from a file as bytes.  It then converts      */
/* those bytes to represent a number.  This code works for any machine, and */
/* makes the byte-code machine independent.                                 */
/*                                                                          */
/****************************************************************************/
fix_bb4(lptr)
BYTE_PTR lptr;
{
   LONG_PTR numptr = (LONG_PTR)lptr;

   *numptr = (((((*lptr << 8) | *(lptr+1)) << 8) | *(lptr+2)) << 8) | *(lptr+3);
}

/****************************************************************************/
/*                                                                          */
/* fix_bb2: fixes the byte-backwards problem.  It is passed a pointer to a  */
/* sequence of 2 bytes read in from a file as bytes.  It then converts      */
/* those bytes to represent a number.  This code works for any machine, and */
/* makes the byte-code machine independent.                                 */
/*                                                                          */
/****************************************************************************/
fix_bb2(lptr)
BYTE_PTR lptr;
{
   WORD_PTR numptr = (WORD_PTR)lptr;

   *numptr = (*lptr << 8) | *(lptr+1);
}

/****************************************************************************/
/*                                                                          */
/*    Load the file into permanent space, starting from "curr_fence".       */
/* Data segment first (mixed psc entries and name strings), then text       */
/* segment, ended with a virtual instruction "endfile <pointer>" where the  */
/* pointer is a pointer to the next text segment (of another byte code      */
/* file).                                                                   */
/*                                                                          */
/****************************************************************************/
loader(file)
CHAR_PTR file;
{
   CHAR_PTR restore;
   WORD     err_msg;

   fp = fopen(file, "r");
   if (fp == NULL)
      return 10;
   if (hitrace)
      printf("\n     ...... loading file %s\n", file);

   while ((eof_flag = GET_DATA(&magic, 1)) == 0) {
      if (eof_flag = GET_DATA(&psc_bytes, 1))
	 return 1;
      if (eof_flag = GET_DATA(&text_bytes, 1))
	 return 1;
      if (eof_flag = GET_DATA(&index_bytes, 1))
	 return 1;

      err_msg = load_syms();

      if (err_msg != 0) {
         printf("error %d loading file %s: bad symbol table\n", err_msg, file);
         exit(1);  /* eventually upper level routines will determine */
      } else {
         restore = curr_fence;
         err_msg = load_text();
         if (err_msg != 0) {
            printf("error %d loading file %s: bad text segment\n", err_msg, file);
            curr_fence = restore;
            exit(1);  /* eventually upper level routines will determine */
         } else {
            err_msg = load_index();
            if (err_msg != 0) {
               printf("error %d in (index) loading file %s: bad index segment\n", err_msg, file);
               curr_fence = restore;
               exit(1);  /*eventually upper level routines will determine */
            } else {
               if (eof_flag = GET_DATA(inst_addr, 4))
                  return eof_flag;
               fix_bb2(inst_addr);
               if (*inst_addr != endfile)
                   *inst_addr = endfile;
               inst_addr += 2;              /* skip opcode and pad */
               *(LONG_PTR)inst_addr = 0;    /* force 0 address (LONG) */
               last_text  = (LONG_PTR)inst_addr;
               inst_addr += 2;
               curr_fence = (CHAR_PTR)inst_addr;
               if (curr_fence >= max_fence)
                  quit("Program area overflow\n");
            }
         }
      }
   }
   fclose(fp);
   return 0;
}  /* end of loader */

/*************************************************************************
*                                                                        *
* Load_syms is a function which loads a symbol table given in a byte     *
* code file into an appropriate format in the pcs table.  As part of     *
* its function it resolves entry points for byte code intructions (call  *
* to relloc_addr), and maintains a tableau so that instructions          *
* with indices into the pcs table may have those indices resloved before *
* loading them in the intruction array (byte code program space).  The   *
* intructions are loaded by a separate function.                         *
* The function returns a short integer which is an error code.  Relevant *
* error codes are listed below.                                          *
*                                                                        *
*      1: in load_syms: incomplete or missing psc count                  *
*      2: in load_syms: incomplete or missing ep in record dec           *
*      3: in load_syms: incomplete or missing arity in record dec        *
*      4: in load_syms: incomplete or missing length in record dec       *
*      5: in load_syms: incomplete or missing name in record dec         *
*      8: can not open file                                              *
*                                                                        *
*************************************************************************/
load_syms()
{
   CHAR     name[256];
   LONG     ep_offset;
   LONG     i = 0, j, count = 0;
   BYTE     temp_len;
   BYTE     temp_arity;
   LONG_PTR insert();

   fix_bb4(&psc_bytes);       /* caller read psc_bytes, we just fix it */

   while (count < psc_bytes && eof_flag == 0) {
      if (eof_flag = GET_DATA(&ep_offset, 1))
	 return 2;
      fix_bb4(&ep_offset);
      if (eof_flag = GET_DATA(&temp_arity, 1))
	 return 3;
      if (eof_flag = GET_DATA(&temp_len, 1))
	 return 4;
      if (eof_flag = GET_DATA(name, temp_len))
	 return 5;
      reloc_table[i] = insert(name, temp_len, temp_arity, &perm);
      set_temp_ep(*reloc_table[i], ep_offset);
      count += temp_len + 6;
      i++;
   }

   for (j = 0; j < i; j++)
      set_real_ep(*reloc_table[j], curr_fence);
   pspace_used = ((LONG)curr_fence - (LONG)(pspace)) / 4;
   return 0;
}  /* end of load_syms */

/************************************************************************
*                                                                       *
* Load_text loads the byte code instruction from a byte code file to    *
* the byte code program space.  References to indices to the pcs table  *
* are resolved with the use of the macro st_index.  New index relies    *
* on the symbol table array which is assigned values by load_syms.      *
* The routine assumes the current length (8/18/84) of byte code         *
* intructions when reading from the byte code file.                     *
* The function returns a short integer which is a error code.  Relevant *
* error codes are listed below.                                         *
*                                                                       *
*      6: in load_text: byte code Operands are non-existent             *
*      7: in load_text: Illegal instruction from PIL file               *
*      8: can not open file                                             *
*                                                                       *
************************************************************************/
load_text()
{
   WORD current_opcode = 0;
   LONG count = 0;
   WORD opval;

   /* set text segments chain */
   if (inst_begin == 0) 
      inst_begin = (WORD_PTR)curr_fence;
   else 
      *last_text = (LONG)curr_fence;

   inst_addr = (WORD_PTR)curr_fence;

   fix_bb4(&text_bytes);

   while (count < text_bytes &&
	  (eof_flag = GET_DATA(&current_opcode, 1)) == 0) {
      fix_bb2(&current_opcode);

      *inst_addr++ = current_opcode;

      if (current_opcode >= 100) {
         switch (current_opcode - 100) {
            case 0 : opval = 0x05;  break;
            case 1 : opval = 0x08;  break;
            case 2 : opval = 0x11;  break;
            case 3 : opval = 0x46;  break;
            case 4 : opval = 0x05;  break;
            case 5 : opval = 0x27;  break;
            case 6 : opval = 0x27;  break;
            case 7 : opval = 0x03;  break;
            case 8 : opval = 0x07;  break;
         }
         (*load_routine[xxopcode[opval].type])();
         count += xxopcode[opval].size;
      } else {
         (*load_routine[xxopcode[current_opcode].type])();
         count += xxopcode[current_opcode].size;
      }
  }

  if (count != text_bytes)   
     return 9;               /* missing instructions */
   return 0;
}  /* end of load_text */


load_index()
{
   LONG     psc_offset, clause_no, temp_len;
   LONG     count = 0;
   LONG_PTR psc;
   WORD_PTR gen_index();

   fix_bb4(&index_bytes);

   while (count < index_bytes && eof_flag == 0) {
      if (eof_flag = GET_DATA(&psc_offset, 1))
	 return 10;
      fix_bb4(&psc_offset);
      psc = (LONG_PTR)*reloc_table[psc_offset];
      if (eof_flag = GET_DATA(&clause_no, 1))
	 return 1;
      fix_bb4(&clause_no);
      if (eof_flag = get_index_tab(clause_no, &temp_len))
	 return eof_flag;
      inst_addr = gen_index(clause_no, psc);
      count += (8 + temp_len);
   }
   return 0;
}


get_index_tab(clause_no, lenptr)
LONG     clause_no;
LONG_PTR lenptr;
{
   LONG     hashval, size, j;
   LONG     count = 0;
   BYTE     type;
   LONG     val;
   LONG_PTR label, reloc_addr();

   hptr = hreg;
   size = hsize(clause_no);
   for (j = 0; j < size; j++) {
      indextab[j].l = 0;
      indextab[j].link = (LONG_PTR)(&(indextab[j].link));
   }
   for (j = 0; j < clause_no; j++) {
      if (eof_flag = GET_DATA(&type, 1))
	 return 11;
      switch (type) {
        case 'i': if (eof_flag = GET_DATA(&val, 1))
		     return 12;
                  fix_bb4(&val);
		  count += 9;
                  break;
        case 'l': /* val = UNTAGGED(list_str); */
	          val = *(LONG_PTR)UNTAGGED(list_str);
                  count += 5;
                  break;
        case 'n': /* val = UNTAGGED(nil_sym); */
                  val = *(LONG_PTR)UNTAGGED(nil_sym);
                  count += 5;
                  break;
        case 's': if (eof_flag = GET_DATA(&val, 1))
		     return 12;
                  fix_bb4(&val);
		  count += 9;
                  /* val = (WORD)reloc_table[val]; */
                  val = *reloc_table[val];
                  break;
        case 'c': if (eof_flag = GET_DATA(&val, 1))
		     return 12;
                  fix_bb4(&val);
		  count += 9;
                  /* val = (WORD)reloc_table[val]; */
                  val = *reloc_table[val];
                  break;
      }
      if (eof_flag = GET_DATA(&label, 1))
	 return 13;
      fix_bb4(&label);
      label = reloc_addr((LONG)label);
      hashval = IHASH(val, size);
      inserth(label, &indextab[hashval]);
   }

   *lenptr = count;
   return 0;
}  /* end of get_index_tab */


WORD_PTR gen_index(clause_no, psc_ptr)
LONG        clause_no;
PSC_REC_PTR psc_ptr;
{
   WORD_PTR ep1, ep2;
   LONG     j, size;
   LONG_PTR temp;

   size = hsize(clause_no);
   ep1  = inst_addr;
   *ep1++ = hash;             /* opcode 'hash' */
   *ep1++ = size;
   ep2 = inst_addr + 2 + 2 * size;
   temp = GET_EP(psc_ptr) + 1;             /* here the hash table size is */
   *temp++ = (LONG)(inst_addr + 2);        /* computed and inserted into  */
   *temp = size;                           /* sob instructions            */
   for (j = 0; j < size; j++) {
      if (indextab[j].l == 0) {
         *(LONG_PTR)ep1 = (LONG)trap_vector[0];
	 ep1 += 2;
      } else  if (indextab[j].l == 1) {
         *(LONG_PTR)ep1 = (LONG)*(indextab[j].link);
	 ep1 += 2;
      } else {
         /* otherwise create try/retry/trust instruction */
         *(LONG_PTR)ep1 = (LONG)ep2;
	 ep1 += 2;
         temp = (LONG_PTR)(indextab[j].link);
         GEN_TRY(try, GET_ARITY(psc_ptr), *temp++, ep2);
         while (*temp != (LONG)temp) {
            temp = (LONG_PTR)*temp;
            GEN_TRY(retry, GET_ARITY(psc_ptr), *temp++, ep2);
         }
         *(ep2 - 4) = trust;
      }
   }
   return ep2;
}


inserth(label, bucket)
LONG_PTR label;
struct   hrec *bucket;
{
   LONG_PTR temp;

   bucket->l++;
   temp = (LONG_PTR)&(bucket->link);
   if (bucket->l > 1) {
      temp = (LONG_PTR)*temp;
      while ((LONG_PTR)*temp != temp)
         temp = (LONG_PTR)*(++temp);
   }
   *temp = (LONG)hptr;
   *hptr++ = (LONG)label;
   *hptr++ = *temp + 4;     /* *hptr++ = (LONG)hptr; */
}


hsize(numentry)
LONG numentry;
{
   LONG i, j, temp;

   temp = numentry + 1;

hashsod:
   j = temp / 2 + 1;
   for (i = 2; i <= j; i++) {
      if (i != temp && (temp % i) == 0) {
         temp++;
         goto hashsod;
      }
   }
   return temp;
}

/************************************************************************
*                                                                       *
* Reloc_addr calculates the entry point of the code using the entry     *
* point stored in the byte code file as an offset, and the stack        *
* pointer curr_fence as the relative address.  Note trap vectors are    *
* are indicated with a - 1, in the byte code file.                      *
*                                                                       *
************************************************************************/
LONG_PTR reloc_addr(offset)
LONG offset;
{
   if (offset >= 0)
      return (LONG_PTR)((LONG)curr_fence + offset);
   else if (-(offset+1) <= MAXTRAPS)
      return trap_vector[-(offset+1)];
   else
      return (LONG_PTR)((LONG)curr_fence + offset);
}


l_E()
{
}

l_P()      /* pad only, no operands */
{
   if (GET_DATA(inst_addr, 1))
      quit("incomplete instruction\n");
   inst_addr++;
}

l_PSS()    /* pad; operand 1 = 2 bytes; operand 2 = 2 bytes */
{
   if (GET_DATA(inst_addr, 3))
      quit("incomplete instruction\n");
   else {
      inst_addr++;
      fix_bb2(inst_addr);
      inst_addr++;
      fix_bb2(inst_addr);
      inst_addr++;
   }
}

l_PC()     /* pad; operand 1 = 4 bytes */
{
   if (GET_DATA(inst_addr, 3))
      quit("incomplete instruction\n");
   else {
      inst_addr++;
      fix_bb4(inst_addr);
      ST_PTRPTRPSC(inst_addr);
      inst_addr += 2;
   }
}

l_PL()     /* pad; operand 1 = 4 bytes (number) */
{
   if (GET_DATA(inst_addr, 3))
      quit("incomplete instruction\n"); 
   else {
      inst_addr++;
      fix_bb4(inst_addr);
      inst_addr += 2;
   }
}

l_PW()     /* operand 1 = 4 bytes (index) */
{
   if (GET_DATA(inst_addr, 3))
      quit("incomplete instruction\n"); 
   else {
      inst_addr++;
      fix_bb4(inst_addr);
      ST_PTRPSC(inst_addr);
      inst_addr += 2;
   }
}

l_PA()     /* operand 1 = 4 bytes (address) */
{
   if (GET_DATA(inst_addr, 3))
      quit("incomplete instruction\n"); 
   else {
      inst_addr++;
      fix_bb4(inst_addr);
      *(LONG_PTR)inst_addr = (LONG)reloc_addr(*(LONG_PTR)inst_addr);
      inst_addr += 2;
   }
}

l_PWW()
{
}

l_S()      /* operand 1 = 2 bytes */
{
   if (GET_DATA(inst_addr, 1))
      quit("incomplete instruction\n");
   else {
      fix_bb2(inst_addr);
      inst_addr++;
   }
}

l_SSS()    /* operands 1, 2 & 3 = 2 bytes */
{
   if (GET_DATA(inst_addr, 3))
      quit("incomplete instruction\n");
   else {
      fix_bb2(inst_addr);
      inst_addr++;
      fix_bb2(inst_addr);
      inst_addr++;
      fix_bb2(inst_addr);
      inst_addr++;
   }
}

l_SC()     /* operand 1 = 2 bytes (index); operand 2 = 4 bytes */
{
   if (GET_DATA(inst_addr, 3))
      quit("incomplete instruction\n"); 
   else {
      fix_bb2(inst_addr);
      inst_addr++;
      fix_bb4(inst_addr);
      ST_PTRPTRPSC(inst_addr);
      inst_addr += 2;
   }
}

l_SL()     /* operand 1 = 2 bytes (number); operand 2 = 4 bytes (reg) */
{
   if (GET_DATA(inst_addr, 3))
      quit("incomplete instruction\n");
   else {
      fix_bb2(inst_addr);
      inst_addr++;
      fix_bb4(inst_addr);
      inst_addr += 2;
   }
}

l_SW()     /* operand 1 = 2 bytes (index); operand 2 = 4 bytes */
{
   if (GET_DATA(inst_addr, 3))
      quit("incomplete instruction\n");
   else {
      fix_bb2(inst_addr);
      inst_addr++;
      fix_bb4(inst_addr);
      ST_PTRPSC(inst_addr);
      inst_addr += 2;
   }
}

l_SA()     /* operand 1 = 2 bytes (reg); operand 2 = 4 bytes (address) */
{
   if (GET_DATA(inst_addr, 3))
      quit("incomplete instruction\n"); 
   else {
      fix_bb2(inst_addr);
      inst_addr++;
      fix_bb4(inst_addr);
      *(LONG_PTR *)inst_addr = (LONG_PTR)reloc_addr(*(LONG_PTR)inst_addr);
      inst_addr += 2;
   }
}

l_SAA()    /* operand 1 = 2 bytes (reg); operands 2 & 3 = 4 bytes (addr) */ 
{
   if (GET_DATA(inst_addr, 5))
      quit("incomplete instruction\n"); 
   else {
      fix_bb2(inst_addr);
      inst_addr++;
      fix_bb4(inst_addr);
      *(LONG_PTR)inst_addr = (LONG)reloc_addr(*(LONG_PTR)inst_addr);
      inst_addr += 2;
      fix_bb4(inst_addr);
      *(LONG_PTR)inst_addr = (LONG)reloc_addr(*(LONG_PTR)inst_addr);
      inst_addr += 2;
   }
}

l_BBW()     /* operands 1 & 2 = 1 byte; operand 3 = 4 bytes */
{
   if (GET_DATA(inst_addr, 3))
      quit("incomplete instruction\n");
   else {
      inst_addr++;
      fix_bb4(inst_addr);
      ST_PTRPSC(inst_addr);
      inst_addr += 2;
   }
}

l_BBA()     /* operands 1 & 2 = 1 byte; operand 3 = 4 bytes (address) */
{
   if (GET_DATA(inst_addr, 3))
      quit("incomplete instruction\n"); 
   else {
      inst_addr++;
      fix_bb4(inst_addr);
      *(LONG_PTR *)inst_addr = (LONG_PTR)reloc_addr(*(LONG_PTR)inst_addr);
      inst_addr += 2;
   }
}

init_load_routine()
{
   load_routine[ E   ] = l_E;
   load_routine[ P   ] = l_P;
   load_routine[ PSS ] = l_PSS;
   load_routine[ PC  ] = l_PC;
   load_routine[ PL  ] = l_PL;
   load_routine[ PW  ] = l_PW;
   load_routine[ PA  ] = l_PA;
   load_routine[ PWW ] = l_PWW;

   load_routine[ S   ] = l_S;
   load_routine[ SSS ] = l_SSS;
   load_routine[ SC  ] = l_SC;
   load_routine[ SL  ] = l_SL;
   load_routine[ SW  ] = l_SW;
   load_routine[ SA  ] = l_SA;
   load_routine[ SAA ] = l_SAA;
   load_routine[ BBW ] = l_BBW;
   load_routine[ BBA ] = l_BBA;
}

dyn_loader(psc_ptr)
PSC_REC_PTR psc_ptr;
{
   extern   CHAR_PTR getenv();
   CHAR     s[256], s1[256], s3[256];
   CHAR_PTR s2;
   WORD     i, returnval;

   namestring(psc_ptr, s1);
   if (*s1 == '/') 
      return loader(s1);
   else if (*s1 == '.') 
      return loader(s1);
   else {
      /* printf("using dynamic loader! %s\n", s1); */
      s2 = getenv("SIMPATH");
      while (1) {
         while (*s2 == ':' || *s2 == ' ')
	    s2++;
         i = 0;
         if (*s2 == '\0')    /* file not found */
            return 1;
         while (*s2 && *s2 != ' ' && *s2 != ':') 
            s[i++] = *s2++;
         s[i++] = '/';
         s[i] = '\0';
         scat(s, s1, s3);
         returnval = loader(s3);

         if (returnval == 0)
            return 0;
      }
   }
}
