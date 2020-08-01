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
/* dis.c */

#include "sim.h"
#include "inst.h"
#include "aux.h"

#define DEBUG_DIS

static FILE *filedes;

dis()
{
#ifdef  DEBUG_DIS
   filedes = stdout;
#else
   filedes = fopen("dump.pil", "w");
#endif

   dis_data();
   dis_text();
   fflush(filedes);
   fclose(filedes);
}

dis_data()
{
   PSC_REC_PTR psc_ptr;
   LONG_PTR    chain_ptr;
   WORD        i;

   fprintf(filedes, "\n/* data below: name, arity, type, and entry *\/\n\n");

   for (i = 0; i < BUCKET_CHAIN; ++i) {
      chain_ptr = (LONG_PTR)&hash_table[i][PERM];
      while (!ISFREE(chain_ptr)) {
         chain_ptr = (LONG_PTR)FOLLOW(chain_ptr);
         psc_ptr = (PSC_REC_PTR)FOLLOW(chain_ptr);
         fprintf(filedes, "%x: ", psc_ptr);
         writepname(filedes, GET_NAME(psc_ptr), GET_LENGTH(psc_ptr));
         fprintf(filedes, "/%d,\t", GET_ARITY(psc_ptr));
         switch (GET_ETYPE(psc_ptr)) {
            case T_ORDI: fprintf(filedes, "ORDI");  break;
            case T_DYNA: fprintf(filedes, "DYNA");  break;
            case T_PRED: fprintf(filedes, "PRED");  break;
            case T_BUFF: fprintf(filedes, "BUFF");  break;
         }
         fprintf(filedes, ",  %x\n", GET_EP(psc_ptr));
         chain_ptr++;
      }
   }
   fprintf(filedes, "\n");
}

dis_text()
{
   fprintf(filedes, "\n/*  text below  *\/\n");
   pcreg = inst_begin;
   do {
      fprintf(filedes, "\nNew segment below \n\n");
      while (*pcreg != endfile)
         print_inst(filedes, pcreg);
      pcreg += 2;
   } while (pcreg = (*(WORD_PTR *)pcreg));   /* repeat for all text segment */
}
