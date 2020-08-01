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
/* dispatch.c */

#include "inst.h"

struct opcode_info xxopcode[] = {
{ "getpvar",              getpvar,              PSS,   PSS_LEN },
{ "getpval",              getpval,              PSS,   PSS_LEN },
{ "getstrv",              getstrv,              SW,    SW_LEN  },
{ "gettval",              gettval,              PSS,   PSS_LEN },
{ "getcon",               getcon,               SC,    SC_LEN  },
{ "getnil",               getnil,               S,     S_LEN   },
{ "getstr",               getstr,               SW,    SW_LEN  },
{ "getlist",              getlist,              S,     S_LEN   },
{ "unipvar",              unipvar,              S,     S_LEN   },
{ "unipval",              unipval,              S,     S_LEN   },
{ "unitvar",              unitvar,              S,     S_LEN   },
{ "unitval",              unitval,              S,     S_LEN   },
{ "unicon",               unicon,               PC,    PC_LEN  },
{ "uninil",               uninil,               P,     P_LEN   },
{ "getnumcon",            getnumcon,            SL,    SL_LEN  },
{ "putnumcon",            putnumcon,            SL,    SL_LEN  },
{ "putpvar",              putpvar,              PSS,   PSS_LEN },
{ "putpval",              putpval,              PSS,   PSS_LEN },
{ "puttvar",              puttvar,              PSS,   PSS_LEN },
{ "putstrv",              putstrv,              SW,    SW_LEN  },
{ "putcon",               putcon,               SC,    SC_LEN  },
{ "putnil",               putnil,               S,     S_LEN   },
{ "putstr",               putstr,               SW,    SW_LEN  },
{ "putlist",              putlist,              S,     S_LEN   },
{ "bldpvar",              bldpvar,              S,     S_LEN   },
{ "bldpval",              bldpval,              S,     S_LEN   },
{ "bldtvar",              bldtvar,              S,     S_LEN   },
{ "bldtval",              bldtval,              S,     S_LEN   },
{ "bldcon",               bldcon,               PC,    PC_LEN  },
{ "bldnil",               bldnil,               P,     P_LEN   },
{ "uninumcon",            uninumcon,            PL,    PL_LEN  },
{ "bldnumcon",            bldnumcon,            PL,    PL_LEN  },
{ "getfloatcon",          getfloatcon,          SL,    SL_LEN  },
{ "putfloatcon",          putfloatcon,          SL,    SL_LEN  },
{ "unifloatcon",          unifloatcon,          PL,    PL_LEN  },
{ "bldfloatcon",          bldfloatcon,          PL,    PL_LEN  },
{ "test_unifiable",       test_unifiable,       SSS,   SSS_LEN },
{ "getlist_k",            getlist_k,            S,     S_LEN   },
{ "getlist_k_tvar_tvar",  getlist_k_tvar_tvar,  SSS,   SSS_LEN },
{ "getlist_tvar_tvar",    getlist_tvar_tvar,    SSS,   SSS_LEN },
{ "getcomma",             getcomma,             S,     S_LEN   },
{ "getcomma_tvar_tvar",   getcomma_tvar_tvar,   SSS,   SSS_LEN },
{ "trymeelse",            trymeelse,            SA,    SA_LEN  },
{ "retrymeelse",          retrymeelse,          SA,    SA_LEN  },
{ "trustmeelsefail",      trustmeelsefail,      S,     S_LEN   },
{ "try",                  try,                  SA,    SA_LEN  },
{ "retry",                retry,                SA,    SA_LEN  },
{ "trust",                trust,                SA,    SA_LEN  },
{ "getpbreg",             getpbreg,             S,     S_LEN   },
{ "gettbreg",             gettbreg,             S,     S_LEN   },
{ "putpbreg",             putpbreg,             S,     S_LEN   },
{ "puttbreg",             puttbreg,             S,     S_LEN   },
{ "switchonterm",         switchonterm,         SAA,   SAA_LEN },
{ "arg",                  arg,                  SSS,   SSS_LEN },
{ "arg0",                 arg0,                 SSS,   SSS_LEN },
{ "switchonbound",        switchonbound,        SAA,   SAA_LEN },
{ "switchonlist",         switchonlist,         SAA,   SAA_LEN },
{ "get_tag",              get_tag,              PSS,   PSS_LEN },
{ "movreg",               movreg,               PSS,   PSS_LEN },
{ "negate",               negate,               S,     S_LEN   },
{ "and",                  and,                  PSS,   PSS_LEN },
{ "or",                   or,                   PSS,   PSS_LEN },
{ "lshiftl",              lshiftl,              PSS,   PSS_LEN },
{ "lshiftr",              lshiftr,              PSS,   PSS_LEN },
{ "addreg",               addreg,               PSS,   PSS_LEN },
{ "subreg",               subreg,               PSS,   PSS_LEN },
{ "mulreg",               mulreg,               PSS,   PSS_LEN },
{ "divreg",               divreg,               PSS,   PSS_LEN },
{ "idivreg",              idivreg,              PSS,   PSS_LEN },
{ "putdval",              putdval,              PSS,   PSS_LEN },
{ "putuval",              putuval,              PSS,   PSS_LEN },
{ "call",                 call,                 BBW,   BBW_LEN },
{ "allocate",             allocate,             S,     S_LEN   },
{ "deallocate",           deallocate,           P,     P_LEN   },
{ "proceed",              proceed,              P,     P_LEN   },
{ "execute",              execute,              PW,    PW_LEN  },
{ "calld",                calld,                BBA,   BBA_LEN },
{ "jump",                 jump,                 PA,    PA_LEN  },
{ "jumpz",                jumpz,                SA,    SA_LEN  },
{ "jumpnz",               jumpnz,               SA,    SA_LEN  },
{ "jumplt",               jumplt,               SA,    SA_LEN  },
{ "jumple",               jumple,               SA,    SA_LEN  },
{ "jumpgt",               jumpgt,               SA,    SA_LEN  },
{ "jumpge",               jumpge,               SA,    SA_LEN  },
{ "fail",                 fail,                 P,     P_LEN   },
{ "noop",                 noop,                 P,     P_LEN   },
{ "halt",                 halt,                 P,     P_LEN   },
{ "builtin",              builtin,              S,     S_LEN   },
{ "endfile",              endfile,              PA,    PA_LEN  },
{ "hash",                 hash,                 S,     S_LEN   },
{ "getival",              getival,              SW,    SW_LEN  },
{ "jumptbreg",            jumptbreg,            SA,    SA_LEN  },
{ "unexec",               unexec,               PWW,   PWW_LEN },
{ "unexeci",              unexeci,              PWW,   PWW_LEN },
{ "executev",             executev,             PW,    PW_LEN  }
};
