/***************************************************************

        bwb_tbl.c       Command Table
                        for Bywater BASIC Interpreter

                        Copyright (c) 1992, Ted A. Campbell

                        Bywater Software
                        P. O. Box 4023
                        Duke Station
                        Durham, NC  27706

                        email: tcamp@acpub.duke.edu

        Copyright and Permissions Information:

        All U.S. and international copyrights are claimed by the
        author. The author grants permission to use this code
        and software based on it under the following conditions:
        (a) in general, the code and software based upon it may be
        used by individuals and by non-profit organizations; (b) it
        may also be utilized by governmental agencies in any country,
        with the exception of military agencies; (c) the code and/or
        software based upon it may not be sold for a profit without
        an explicit and specific permission from the author, except
        that a minimal fee may be charged for media on which it is
        copied, and for copying and handling; (d) the code must be
        distributed in the form in which it has been released by the
        author; and (e) the code and software based upon it may not
        be used for illegal activities.

***************************************************************/

#include <stdio.h>
#include <stdlib.h>

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
      { "VARS",         bwb_vars,        2 },
      { "CMDS",         bwb_cmds,        2 },
      { "FNCS",         bwb_fncs,        2 },
      #endif

      #if DIRECTORY_CMDS
      { "CHDIR",        bwb_chdir,       2 },
      { "MKDIR",        bwb_mkdir,       2 },
      { "RMDIR",        bwb_rmdir,       2 },
      #endif

      { "SYSTEM",       bwb_system,      2 },
      { "REM",          bwb_rem,         2 },
      { "LET",          bwb_let,         2 },
      { "LIST",         bwb_list,        2 },
      { "LOAD",         bwb_load,        2 },
      { "MERGE",        bwb_merge,       2 },
      { "CHAIN",        bwb_chain,       2 },
      { "COMMON",       bwb_common,      2 },
      { "RUN",          bwb_run,         2 },
      { "PRINT",        bwb_print,       2 },
      { "SAVE",         bwb_save,        2 },
      { "INPUT",        bwb_input,       2 },
      { "GOTO",         bwb_goto,        2 },
      { "GOSUB",        bwb_gosub,       2 },
      { "RETURN",       bwb_return,      2 },
      { "ERROR",        bwb_lerror,      2 },
      { "ON",           bwb_on,          2 },
      { "IF",           bwb_if,          2 },
      { "WHILE",        bwb_while,       2 },
      { "WEND",         bwb_wend,        2 },
      { "WRITE",        bwb_write,       2 },
      { "WIDTH",        bwb_width,       2 },
      { "TRON",         bwb_tron,        2 },
      { "TROFF",        bwb_troff,       2 },
      { "END",          bwb_xend,        2 },
      { "NEW",          bwb_new,         2 },
      { "DELETE",       bwb_delete,      2 },
      { "FOR",          bwb_for,         2 },
      { "NEXT",         bwb_next,        2 },
      { "RANDOMIZE",    bwb_randomize,   2 },
      { "STOP",         bwb_stop,        2 },
      { "DATA",         bwb_data,        2 },
      { "READ",         bwb_read,        2 },
      { "RESTORE",      bwb_restore,     2 },
      { "DIM",          bwb_dim,         2 },
      { "OPTION",       bwb_option,      2 },
      { "OPEN",         bwb_open,        2 },
      { "CLOSE",        bwb_close,       2 },
      { "GET",          bwb_get,         2 },
      { "PUT",          bwb_put,         2 },
      { "KILL",         bwb_kill,        2 },
      { "NAME",         bwb_name,        2 },
      { "LSET",         bwb_lset,        2 },
      { "RSET",         bwb_rset,        2 },
      { "FIELD",        bwb_field,       2 },
      { "LINE",         bwb_line,        2 },
      { "DEFDBL",       bwb_ddbl,        2 },
      { "DEFINT",       bwb_dint,        2 },
      { "DEFSNG",       bwb_dsng,        2 },
      { "DEFSTR",       bwb_dstr,        2 },
      { "DEF",          bwb_deffn,       2 },
      { "CLEAR",        bwb_clear,       2 },
      { "ERASE",        bwb_erase,       2 },
      { "ENVIRON",      bwb_environ,     2 },
      { "SWAP",         bwb_swap,        2 }
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
char err_od[] =         ERR_OD;
char err_overflow[] =   ERR_OVERFLOW;
char err_nf[] =         ERR_NF;
char err_uf[] =         ERR_UF;
char err_dbz[] =        ERR_DBZ;
char err_redim[] =      ERR_REDIM;
char err_obdim[] =      ERR_OBDIM;
char err_uc[] = 	ERR_UC;

/* error table */

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
   err_uc 
   };

