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

#define PARSE_OP1(y) oprnd1=(WORD)*(y *)pcreg; pcreg =(WORD_PTR)((y)pcreg + 1)
#define PARSE_OP2(y) oprnd2=(WORD)*(y *)pcreg; pcreg =(WORD_PTR)((y)pcreg + 1)
#define PARSE_OP3(y) oprnd3=(WORD)*(y *)pcreg; pcreg =(WORD_PTR)((y)pcreg + 1)

int (*p_routine[20])();

p_E()
{
}

p_P()
{
}

p_PSS()
{
   PARSE_OP1(WORD);
   PARSE_OP2(WORD);
}

p_PC()
{
   PARSE_OP1(LONG);
}

p_PL()
{
   PARSE_OP1(LONG);
}

p_PW()
{
   PARSE_OP1(LONG);
}

p_PA()
{
   PARSE_OP1(WORD_PTR);
}

p_PWW()
{
}

p_S()
{
   PARSE_OP1(WORD);
}

p_SSS()
{
   PARSE_OP1(WORD);
   PARSE_OP2(WORD);
   PARSE_OP3(WORD);
}

p_SC()
{
   PARSE_OP1(WORD);
   PARSE_OP2(LONG);
}

p_SL()
{
   PARSE_OP1(WORD);
   PARSE_OP2(LONG);
}

p_SW()
{
   PARSE_OP1(WORD);
   PARSE_OP2(LONG);
}

p_SA()
{
   PARSE_OP1(WORD);
   PARSE_OP2(WORD_PTR);
}

p_SAA()
{
   PARSE_OP1(WORD);
   PARSE_OP2(WORD_PTR);
   PARSE_OP2(WORD_PTR);
}

p_BBW()
{
   PARSE_OP1(BYTE);
   PARSE_OP2(BYTE);
   PARSE_OP3(LONG);
}

p_BBA()
{
   PARSE_OP1(BYTE);
   PARSE_OP2(BYTE);
   PARSE_OP3(WORD_PTR);
}

init_parse_routine()
{
   p_routine[ E ]   = p_E;
   p_routine[ P ]   = p_P;
   p_routine[ PSS ] = p_PSS;
   p_routine[ PC ]  = p_PC;
   p_routine[ PL ]  = p_PL;
   p_routine[ PW ]  = p_PW;
   p_routine[ PA ]  = p_PA;
   p_routine[ PWW ] = p_PWW;

   p_routine[ S ]   = p_S;
   p_routine[ SSS ] = p_SSS;
   p_routine[ SC ]  = p_SC;
   p_routine[ SL ]  = p_SL;
   p_routine[ SW ]  = p_SW;
   p_routine[ SA ]  = p_SA;
   p_routine[ SAA ] = p_SAA;
   p_routine[ BBW ] = p_BBW;
   p_routine[ BBA ] = p_BBA;
}
