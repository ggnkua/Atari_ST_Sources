/***************************************************************

	bwb_tbl.c       Command, Function, Operator, 
			and Error-Message Tables
                        for Bywater BASIC Interpreter

                        Copyright (c) 1993, Ted A. Campbell
                        Bywater Software

                        email: tcamp@delphi.com

        Copyright and Permissions Information:

        All U.S. and international rights are claimed by the author,
        Ted A. Campbell.

	This software is released under the terms of the GNU General
	Public License (GPL), which is distributed with this software
	in the file "COPYING".  The GPL specifies the terms under
	which users may copy and use the software in this distribution.

	A separate license is available for commercial distribution,
	for information on which you should contact the author.

***************************************************************/

/*---------------------------------------------------------------*/
/* NOTE: Modifications marked "JBV" were made by Jon B. Volkoff, */
/* 11/1995 (eidetics@cerf.net).                                  */
/*---------------------------------------------------------------*/

#include <stdio.h>

#include "bwbasic.h"
#include "bwb_mes.h"

int err_line = 0;			/* line in which error occurred */
int err_number = 0;			/* number of last error */

/***************************************************************

        Command Table for Bywater BASIC

***************************************************************/

struct bwb_command bwb_cmdtable[ COMMANDS ] =
   {

#if PERMANENT_DEBUG
      { CMD_VARS,         bwb_vars },
      { CMD_CMDS,         bwb_cmds },
      { CMD_FNCS,         bwb_fncs },
#endif

#if UNIX_CMDS
      { CMD_CHDIR,        bwb_chdir },
      { CMD_MKDIR,        bwb_mkdir },
      { CMD_RMDIR,        bwb_rmdir },
      { CMD_KILL,         bwb_kill },
      { CMD_ENVIRON,      bwb_environ },
#endif

#if INTERACTIVE
      { CMD_LIST,         bwb_list },
      { CMD_LOAD,         bwb_load },
      { CMD_RUN,          bwb_run },
      { CMD_SAVE,         bwb_save },
      { CMD_DELETE,       bwb_delete },
      { CMD_NEW,          bwb_new },
      { CMD_QUIT,         bwb_system },
      { CMD_SYSTEM,       bwb_system },
#endif

#if MS_CMDS
      { CMD_DEFDBL,       bwb_ddbl },
      { CMD_DEFINT,       bwb_dint },
      { CMD_DEFSNG,       bwb_dsng },
      { CMD_DEFSTR,       bwb_dstr },
      { CMD_MID,          bwb_mid }, /* Added this extension (JBV) */
#if IMP_CMDCLS
      { CMD_CLS,          bwb_cls },
#endif
#if IMP_CMDCOLOR
      { CMD_COLOR,        bwb_color },
#endif
#if IMP_CMDLOC
      { CMD_LOCATE,       bwb_locate },
#endif
#endif

#if STRUCT_CMDS
      { CMD_CALL,         bwb_call },
      { CMD_SUB,          bwb_sub },
      { CMD_FUNCTION,     bwb_function },
      { CMD_LABEL,        bwb_null },
      { CMD_ELSE,         bwb_else },
      { CMD_ELSEIF,       bwb_elseif },
      { CMD_SELECT,       bwb_select },
      { CMD_CASE,         bwb_case },
      { CMD_LOOP,         bwb_loop },
      { CMD_EXIT,         bwb_exit },
#endif

#if COMMON_CMDS
      { CMD_MERGE,        bwb_merge },
      { CMD_CHAIN,        bwb_chain },
      { CMD_COMMON,       bwb_common },
      { CMD_ERROR,        bwb_lerror },
      { CMD_WIDTH,        bwb_width },
      { CMD_TRON,         bwb_tron },
      { CMD_TROFF,        bwb_troff },
      { CMD_FILES,        bwb_files },
      { CMD_EDIT,         bwb_edit },
      { CMD_ERASE,        bwb_erase },
      { CMD_SWAP,         bwb_swap },
      { CMD_NAME,         bwb_name },
      { CMD_CLEAR,        bwb_clear },
      { CMD_WHILE,        bwb_while },
      { CMD_WEND,         bwb_wend },
      { CMD_WRITE,        bwb_write },
      { CMD_OPEN,         bwb_open },
      { CMD_CLOSE,        bwb_close },
      { CMD_GET,          bwb_get },
      { CMD_PUT,          bwb_put },
      { CMD_LSET,         bwb_lset },
      { CMD_RSET,         bwb_rset },
      { CMD_FIELD,        bwb_field },
      { CMD_LINE,         bwb_line },
      { CMD_RENUM,        bwb_renum }, /* Added this extension (JBV) */
#endif

      /* The remainder are the core functions defined for ANSI Minimal BASIC */

      { CMD_DATA,         bwb_data },
      { CMD_DEF,          bwb_def },
      { CMD_DIM,          bwb_dim },
      { CMD_END,          bwb_xend },
      { CMD_FOR,          bwb_for },
      { CMD_DO,           bwb_do },  /* not really core but needed in two different places */
      { CMD_GO,		  bwb_go },
      { CMD_GOSUB,        bwb_gosub },
      { CMD_GOTO,         bwb_goto },
      { CMD_IF,           bwb_if },
      { CMD_INPUT,        bwb_input },
      { CMD_LET,          bwb_let },
      { CMD_NEXT,         bwb_next },
      { CMD_ON,           bwb_on },
      { CMD_OPTION,       bwb_option },
      { CMD_PRINT,        bwb_print },
      { CMD_RANDOMIZE,    bwb_randomize },
      { CMD_READ,         bwb_read },
      { CMD_REM,          bwb_rem },
      { CMD_RESTORE,      bwb_restore },
      { CMD_RETURN,       bwb_return },
      { CMD_STOP,         bwb_stop }
   };

/***************************************************************

        Predefined Function Table for Bywater BASIC

***************************************************************/

struct bwb_function bwb_prefuncs[ FUNCTIONS ] =
   {

#if INTENSIVE_DEBUG
   { "TEST",    NUMBER,         2,   fnc_test,       (struct bwb_function *) NULL, 0    },
#endif


#if MS_FUNCS			/* Functions unique to Microsoft GWBASIC (tm) */
   { "ASC",     NUMBER,         1,   fnc_asc,        (struct bwb_function *) NULL, 0    },
   { "MKD$",    STRING,         1,   fnc_mkd,        (struct bwb_function *) NULL, 0    },
   { "MKI$",    STRING,         1,   fnc_mki,        (struct bwb_function *) NULL, 0    },
   { "MKS$",    STRING,         1,   fnc_mks,        (struct bwb_function *) NULL, 0    },
   { "CVD",     NUMBER,         1,   fnc_cvd,        (struct bwb_function *) NULL, 0    },
   { "CVS",     NUMBER,         1,   fnc_cvs,        (struct bwb_function *) NULL, 0    },
   { "CVI",     NUMBER,         1,   fnc_cvi,        (struct bwb_function *) NULL, 0    },
   { "CINT",    NUMBER,         1,   fnc_cint,       (struct bwb_function *) NULL, 0    },
   { "CSNG",    NUMBER,         1,   fnc_csng,       (struct bwb_function *) NULL, 0    },
   { "ENVIRON$",STRING,         1,   fnc_environ,    (struct bwb_function *) NULL, 0    },
   { "ERR",     NUMBER,         0,   fnc_err,        (struct bwb_function *) NULL, 0    },
   { "ERL",     NUMBER,         0,   fnc_erl,        (struct bwb_function *) NULL, 0    },
   { "LOC",     NUMBER,         1,   fnc_loc,        (struct bwb_function *) NULL, 0    },
   { "LOF",     NUMBER,         1,   fnc_lof,        (struct bwb_function *) NULL, 0    },
   { "EOF",     NUMBER,         1,   fnc_eof,        (struct bwb_function *) NULL, 0    },
   { "INSTR",   NUMBER,         1,   fnc_instr,      (struct bwb_function *) NULL, 0    },
   { "SPC",     STRING,		1,   fnc_spc,        (struct bwb_function *) NULL, 0    },
   { "SPACE$",  STRING,		1,   fnc_space,      (struct bwb_function *) NULL, 0    },
   { "STRING$", STRING,		1,   fnc_string,     (struct bwb_function *) NULL, 0    },
   { "MID$",    STRING,		3,   fnc_mid,        (struct bwb_function *) NULL, 0    },
   { "LEFT$",   STRING,		2,   fnc_left,       (struct bwb_function *) NULL, 0    },
   { "RIGHT$",  STRING,		2,   fnc_right,      (struct bwb_function *) NULL, 0    },
   { "TIMER",   NUMBER,         0,   fnc_timer,      (struct bwb_function *) NULL, 0    },
   { "HEX$",    STRING,         1,   fnc_hex,        (struct bwb_function *) NULL, 0    },
   { "OCT$",    STRING,         1,   fnc_oct,        (struct bwb_function *) NULL, 0    },
#if IMP_FNCINKEY == 1
   { "INKEY$",  STRING,         1,   fnc_inkey,      (struct bwb_function *) NULL, 0    },
#endif
#endif

#if COMMON_FUNCS			/* Functions common to GWBASIC and ANSI Full BASIC */
   { "CHR$",    NUMBER,         0,   fnc_chr,        (struct bwb_function *) NULL, 0    },
   { "LEN",     NUMBER,         1,   fnc_len,        (struct bwb_function *) NULL, 0    },
   { "POS",     NUMBER,         0,   fnc_pos,        (struct bwb_function *) NULL, 0    },
   { "VAL",     NUMBER,         1,   fnc_val,        (struct bwb_function *) NULL, 0    },
   { "STR$",    STRING,         1,   fnc_str,        (struct bwb_function *) NULL, 0    },
   { "DATE$",   STRING,         0,   fnc_date,       (struct bwb_function *) NULL, 0    },
   { "TIME$",   STRING,         0,   fnc_time,       (struct bwb_function *) NULL, 0    },
#endif

#if ANSI_FUNCS			/* Functions required for ANSI Full BASIC */
#endif

   /* The remainder are core functions defined for ANSI Minimal BASIC */

#if COMPRESS_FUNCS
   { "ABS",     NUMBER,         1,   fnc_core,        (struct bwb_function *) NULL, F_ABS    },
   { "ATN",     NUMBER,         1,   fnc_core,        (struct bwb_function *) NULL, F_ATN    },
   { "COS",     NUMBER,         1,   fnc_core,        (struct bwb_function *) NULL, F_COS    },
   { "EXP",     NUMBER,         1,   fnc_core,        (struct bwb_function *) NULL, F_EXP    },
   { "INT",     NUMBER,         1,   fnc_core,        (struct bwb_function *) NULL, F_INT    },
   { "LOG",     NUMBER,         1,   fnc_core,        (struct bwb_function *) NULL, F_LOG    },
   { "RND",     NUMBER,         0,   fnc_core,        (struct bwb_function *) NULL, F_RND    },
   { "SGN",     NUMBER,         1,   fnc_core,        (struct bwb_function *) NULL, F_SGN    },
   { "SIN",     NUMBER,         1,   fnc_core,        (struct bwb_function *) NULL, F_SIN    },
   { "SQR",     NUMBER,         1,   fnc_core,        (struct bwb_function *) NULL, F_SQR    },
   { "TAN",     NUMBER,         1,   fnc_core,        (struct bwb_function *) NULL, F_TAN    },
   { "ACOS",    NUMBER,         1,  fnc_core, 			(struct bwb_function *) NULL, F_ACOS    },
   { "ASIN",    NUMBER,         1,  fnc_core, 			(struct bwb_function *) NULL, F_ASIN    },
#else
   { "ABS",     NUMBER,         1,   fnc_abs,        (struct bwb_function *) NULL, 0    },
   { "ATN",     NUMBER,         1,   fnc_atn,        (struct bwb_function *) NULL, 0    },
   { "COS",     NUMBER,         1,   fnc_cos,        (struct bwb_function *) NULL, 0    },
   { "ACOS",    NUMBER,         1,  fnc_acos, 			(struct bwb_function *) NULL, 0    },
   { "ASIN",    NUMBER,         1,  fnc_asin, 			(struct bwb_function *) NULL, 0    },
   { "EXP",     NUMBER,         1,   fnc_exp,        (struct bwb_function *) NULL, 0    },
   { "INT",     NUMBER,         1,   fnc_int,        (struct bwb_function *) NULL, 0    },
   { "LOG",     NUMBER,         1,   fnc_log,        (struct bwb_function *) NULL, 0    },
   { "RND",     NUMBER,         0,   fnc_rnd,        (struct bwb_function *) NULL, 0    },
   { "SGN",     NUMBER,         1,   fnc_sgn,        (struct bwb_function *) NULL, 0    },
   { "SIN",     NUMBER,         1,   fnc_sin,        (struct bwb_function *) NULL, 0    },
   { "SQR",     NUMBER,         1,   fnc_sqr,        (struct bwb_function *) NULL, 0    },
   { "TAN",     NUMBER,         1,   fnc_tan,        (struct bwb_function *) NULL, 0    },
#endif
   { "TAB",     STRING,         1,   fnc_tab,        (struct bwb_function *) NULL, 0    }
   };

/***************************************************************

	Operator Table for Bywater BASIC

***************************************************************/

struct bwb_op exp_ops[ N_OPERATORS ] =
   {
   { "NOT",     OP_NOT,         2  },   /* multiple-character operators */
   { "AND",     OP_AND,         13 },   /* should be tested first because */
   { "OR",      OP_OR,          14 },   /* e.g. a ">=" would be matched */
   { "XOR",     OP_XOR,         15 },   /* as "=" if the single-character */
   { "IMP",     OP_IMPLIES,     16 },   /* operator came first */
   { "EQV",     OP_EQUIV,       17 },
   { "MOD",     OP_MODULUS,     5  },
   { "<>",      OP_NOTEQUAL,    8  },
   { "<=",      OP_LTEQ,        11 },
   { "=<",      OP_LTEQ,        11 },   /* allow either form */
   { ">=",      OP_GTEQ,        12 },
   { "=>",      OP_GTEQ,        12 },   /* allow either form */
   { "<",       OP_LESSTHAN,    9  },
   { ">",       OP_GREATERTHAN, 10 },
   { "^",       OP_EXPONENT,    0  },
   { "*",       OP_MULTIPLY,    3  },
   { "/",       OP_DIVIDE,      3  },
   { "\\",      OP_INTDIVISION, 4  },
   { "+",       OP_ADD,         6  },
   { "-",       OP_SUBTRACT,    6  },
   { "=",       OP_EQUALS,      7  },
   { "=",       OP_ASSIGN,      18 },   /* don't worry: OP_EQUALS will be converted to OP_ASSIGN if necessary */
   { ";",       OP_STRJOIN,     19 },
   { ",",       OP_STRTAB,      20 },
   { "-",       OP_NEGATION,    1  }    /* Right below exponentiation (JBV) */
   };

/* Error messages used more than once */

char err_openfile[] =   ERR_OPENFILE;
char err_getmem[] =     ERR_GETMEM;
char err_noln[] =       ERR_NOLN;
char err_nofn[] =       ERR_NOFN;
char err_lnnotfound[] = ERR_LNNOTFOUND;
char err_incomplete[] = ERR_INCOMPLETE;
char err_valoorange[] = ERR_VALOORANGE;
char err_syntax[] =     ERR_SYNTAX;
char err_devnum[] =     ERR_DEVNUM;
char err_dev[] =        ERR_DEV;
char err_opsys[] =	ERR_OPSYS;
char err_argstr[] = 	ERR_ARGSTR;
char err_defchar[] = 	ERR_DEFCHAR;
char err_mismatch[] =	ERR_MISMATCH;
char err_dimnotarray[] =ERR_DIMNOTARRAY;
char err_retnogosub[] = ERR_RETNOGOSUB;
char err_od[] =         ERR_OD;
char err_overflow[] =   ERR_OVERFLOW;
char err_nf[] =         ERR_NF;
char err_uf[] =         ERR_UF;
char err_dbz[] =        ERR_DBZ;
char err_redim[] =      ERR_REDIM;
char err_obdim[] =      ERR_OBDIM;
char err_uc[] = 	ERR_UC;
char err_noprogfile[] = ERR_NOPROGFILE;

/***************************************************************

	Error Message Table for Bywater BASIC

***************************************************************/

char *err_table[ N_ERRORS ] =
   {
   err_openfile,
   err_getmem,
   err_noln,
   err_nofn,
   err_lnnotfound,
   err_incomplete,
   err_valoorange,
   err_syntax,
   err_devnum,
   err_dev,
   err_opsys,
   err_argstr,
   err_defchar,
   err_mismatch,
   err_dimnotarray,
   err_od,
   err_overflow,
   err_nf,
   err_uf,
   err_dbz,
   err_redim,
   err_obdim,
   err_uc,
   err_noprogfile
   };


