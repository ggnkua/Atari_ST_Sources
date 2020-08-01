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
#include "inst.h"
#include "sim.h"

/* these are macros to use lpcreg as the instruction pointer and to
   parse instruction operands into oprnd1, 2, and 3
*/
#define PARSE_P    lpcreg++;
#define PARSE_PSS  lpcreg++;  oprnd1 = *lpcreg++;  oprnd2 = *lpcreg++;
#define PARSE_PC   lpcreg++;  oprnd1 = *(LONG_PTR)lpcreg;  lpcreg += 2;
#define PARSE_PL   lpcreg++;  oprnd1 = *(LONG_PTR)lpcreg;  lpcreg += 2;
#define PARSE_PW   lpcreg++;  oprnd1 = *(LONG_PTR)lpcreg;  lpcreg += 2;
#define PARSE_PA   lpcreg++;  oprnd1 = *(LONG_PTR)lpcreg;  lpcreg += 2;
#define PARSE_PWW  lpcreg++;  oprnd1 = *(LONG_PTR)lpcreg;  lpcreg += 2; \
                              oprnd2 = *(LONG_PTR)lpcreg;  lpcreg += 2;

#define PARSE_S    oprnd1 = *lpcreg++;
#define PARSE_SSS  oprnd1 = *lpcreg++; oprnd2 = *lpcreg++; \
                                       oprnd3 = *lpcreg++;
#define PARSE_SC   oprnd1 = *lpcreg++; oprnd2 = *(LONG_PTR)lpcreg; lpcreg += 2;
#define PARSE_SL   oprnd1 = *lpcreg++; oprnd2 = *(LONG_PTR)lpcreg; lpcreg += 2;
#define PARSE_SW   oprnd1 = *lpcreg++; oprnd2 = *(LONG_PTR)lpcreg; lpcreg += 2;
#define PARSE_SA   oprnd1 = *lpcreg++; oprnd2 = *(LONG_PTR)lpcreg; lpcreg += 2;
#define PARSE_SAA  oprnd1 = *lpcreg++; oprnd2 = *(LONG_PTR)lpcreg; lpcreg += 2;\
                                       oprnd3 = *(LONG_PTR)lpcreg; lpcreg += 2;
#define PARSE_BBW  oprnd1 = *(BYTE_PTR)lpcreg++; \
		   oprnd2 = *(BYTE_PTR)lpcreg++; \
		   oprnd3 = *(LONG_PTR)lpcreg;  lpcreg += 2;
#define PARSE_BBA  oprnd1 = *(BYTE_PTR)lpcreg++; \
		   oprnd2 = *(BYTE_PTR)lpcreg++; \
		   oprnd3 = *(LONG_PTR)lpcreg;  lpcreg += 2;

extern int (*p_routine[])();   /* array of functions */

#define PRINTOP1(tp)  fprintf(fd, "\t %x",(tp)oprnd1);  fflush(stdout)
#define PRINTOP2(tp)  fprintf(fd, "\t %x",(tp)oprnd2);  fflush(stdout)
#define PRINTOP3(tp)  fprintf(fd, "\t %x",(tp)oprnd3);  fflush(stdout)

print_inst(fd, inst_ptr)
FILE     *fd;
WORD_PTR inst_ptr;
{
   WORD_PTR lpcreg; /* local pc register for macros to use */
   WORD     opcode;
   LONG     i;

   lpcreg = inst_ptr;
   if (num_line)
      fprintf(fd, "%x\t", lpcreg);
   opcode = *lpcreg++;

   fprintf(fd, xxopcode[opcode].name);

   switch (xxopcode[opcode].type) {
      case E  : break;
      case P  : PARSE_P;
                if (opcode == noop)
		   lpcreg += oprnd1;
                break;
      case PSS: PARSE_PSS;
                PRINTOP1(WORD);
                PRINTOP2(WORD);
                break;
      case PC : PARSE_PW;
                PRINTOP1(LONG);
                break;
      case PL : PARSE_PL;
                PRINTOP1(LONG);
                break;
      case PW : PARSE_PW;
                PRINTOP1(LONG);
                break;
      case PA : PARSE_PA;
                PRINTOP1(LONG);
                break;
      case S  : PARSE_S;
                PRINTOP1(WORD);
                if (opcode == hash) {
                   fprintf(fd, "\n");
                   for (i = 0; i < oprnd1; i++) {
                      if (num_line)
			 fprintf(fd, "%x\t", lpcreg);
                      fprintf(fd, "\t %x\n", *(WORD_PTR)lpcreg);
                      lpcreg++;
                   }
                }
                break;
      case SSS: PARSE_SSS;
                PRINTOP1(WORD);
                PRINTOP2(WORD);
                PRINTOP3(WORD);
                break;
      case SC : PARSE_SW;
                PRINTOP1(WORD);
                PRINTOP2(LONG);
                break;
      case SL : PARSE_SL;
                PRINTOP1(WORD);
                PRINTOP2(LONG);
                break;
      case SW : PARSE_SW;
                PRINTOP1(WORD);
                PRINTOP2(LONG);
                break;
      case SA : PARSE_SA;
                PRINTOP1(WORD);
                PRINTOP2(LONG);
                break;
      case SAA: PARSE_SAA;
                PRINTOP1(WORD);
                PRINTOP2(LONG);
                PRINTOP3(LONG);
                if (opcode == switchonbound) {
                   fprintf(fd, "\n");
                   if (num_line)
		      fprintf(fd, "%x\t", lpcreg);
                   opcode = *lpcreg++;
                   fprintf(fd, xxopcode[opcode].name);
                   PARSE_PA;
                   PRINTOP1(WORD); fprintf(fd, "\n");
                   for (i = 0; i < oprnd3; i++) {
                      if (num_line)
			 fprintf(fd, "%x\t", lpcreg);
                      fprintf(fd, "\t %x\n", *lpcreg);
                      lpcreg++;
                   }
                }
                break;
      case BBW: PARSE_BBW;
	        PRINTOP1(BYTE);
	        PRINTOP2(BYTE);
	        PRINTOP3(LONG);
                break;
      case BBA: PARSE_BBW;
		PRINTOP1(BYTE);
		PRINTOP2(BYTE);
		PRINTOP3(LONG);
		break;
   }  /* end switch */

   pcreg = (WORD_PTR)lpcreg;

   fprintf(fd, "\n");

}  /* end of print_inst */
