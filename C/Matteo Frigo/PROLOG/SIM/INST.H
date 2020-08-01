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
/* inst.h */

/* Instruction operand types  */

#define  E       0
#define  P       1
#define  PSS     2
#define  PC      3
#define  PL      4
#define  PW      5
#define  PA      6
#define  PWW     7

#define  S       8
#define  SSS     9
#define  SC     10
#define  SL     11
#define  SW     12
#define  SA     13
#define  SAA    14
#define  BBW    15
#define  BBA    16

/* Instruction lengths  */

#define  P_LEN         4     /* opcode + pad */
#define  PSS_LEN       8     /* opcode + pad + short + short */
#define  PC_LEN        8     /* opcode + pad + long */
#define  PL_LEN        8     /* opcode + pad + long */
#define  PW_LEN        8     /* opcode + pad + long */
#define  PA_LEN        8     /* opcode + pad + long */
#define  PWW_LEN      12     /* opcode + pad + long + long */

#define  S_LEN         4     /* opcode + short */
#define  SSS_LEN       8     /* opcode + short + short + short */
#define  SC_LEN        8     /* opcode + short + long */
#define  SL_LEN        8     /* opcode + short + long */
#define  SW_LEN        8     /* opcode + short + long */
#define  SA_LEN        8     /* opcode + short + long */
#define  SAA_LEN      12     /* opcode + short + long + long */
#define  BBW_LEN       8     /* opcode + byte + byte + long */
#define  BBA_LEN       8     /* opcode + byte + byte + long */

struct opcode_info {
   char  *name;
   int    num;
   int    type;
   int    size;
};
extern  struct opcode_info  xxopcode[];

/**************************************************************************/
/*    The set of instructions.                                            */
/*                                                                        */
/*    These are used as labels in "main.c"                                */
/**************************************************************************/

/* Basic term instructions */

#define    getpvar                  0
#define    getpval                  1
#define    getstrv                  2
#define    gettval                  3
#define    getcon                   4
#define    getnil                   5
#define    getstr                   6
#define    getlist                  7
#define    unipvar                  8
#define    unipval                  9
#define    unitvar                 10
#define    unitval                 11
#define    unicon                  12
#define    uninil                  13
#define    getnumcon               14
#define    putnumcon               15
#define    putpvar                 16
#define    putpval                 17
#define    puttvar                 18
#define    putstrv                 19
#define    putcon                  20
#define    putnil                  21
#define    putstr                  22
#define    putlist                 23
#define    bldpvar                 24
#define    bldpval                 25
#define    bldtvar                 26
#define    bldtval                 27
#define    bldcon                  28
#define    bldnil                  29
#define    uninumcon               30
#define    bldnumcon               31
#define    getfloatcon             32
#define    putfloatcon             33
#define    unifloatcon             34
#define    bldfloatcon             35
#define    test_unifiable          36

#define    getlist_k               37
#define    getlist_k_tvar_tvar     38
#define    getlist_tvar_tvar       39
#define    getcomma                40
#define    getcomma_tvar_tvar      41

/* Non-determinism instructions */

#define    trymeelse               42
#define    retrymeelse             43
#define    trustmeelsefail         44
#define    try                     45
#define    retry                   46
#define    trust                   47
#define    getpbreg                48
#define    gettbreg                49
#define    putpbreg                50
#define    puttbreg                51

/* Indexing instructions */

#define    switchonterm            52
#define    arg                     53
#define    arg0                    54
#define    switchonbound           55
#define    switchonlist            56

/* tag instructions */

#define    get_tag                 57

/* Numeric instructions */

#define    movreg                  58
#define    negate                  59
#define    and                     60
#define    or                      61
#define    lshiftl                 62
#define    lshiftr                 63
#define    addreg                  64
#define    subreg                  65
#define    mulreg                  66
#define    divreg                  67
#define    idivreg                 68

/* Unsafe term instructions  */

#define    putdval                 69
#define    putuval                 70

/* Procedure instructions */

#define    call                    71
#define    allocate                72
#define    deallocate              73
#define    proceed                 74
#define    execute                 75
#define    calld                   76

/* Branching instructions */

#define    jump                    77
#define    jumpz                   78
#define    jumpnz                  79
#define    jumplt                  80
#define    jumple                  81
#define    jumpgt                  82
#define    jumpge                  83

/* Miscellaneous instructions */

#define    fail                    84
#define    noop                    85
#define    halt                    86
#define    builtin                 87
#define    endfile                 88

#define    hash                    89
#define    getival                 90
#define    jumptbreg               91
#define    unexec                  92
#define    unexeci                 93
#define    executev                94

/* virtual instruction, used for disassembler to link different segs */

extern int Switchonbound();
extern int Builtin();
