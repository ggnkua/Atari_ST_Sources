/*****************************************************************************
 *
 * Module : PRINTER.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 04.04.94
 *
 *
 * Description: This module defines the printer dialog box.
 *
 * History:
 * 04.04.94: Parameter loadfile replaced by loadinf in load_prncfg
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __PRINTER__
#define __PRINTER__

/****** DEFINES **************************************************************/

#define PROP_ON         0       /* control codes */
#define PROP_OFF        1
#define SUPER_ON        6
#define SUPER_OFF       7
#define SUB_ON          8
#define SUB_OFF         9
#define ITALIC_ON      10
#define ITALIC_OFF     11
#define BOLD_ON        12
#define BOLD_OFF       13
#define UNDER_ON       14
#define UNDER_OFF      15
#define PRINTER_ON     16
#define PRINTER_OFF    17
#define PICA_ON        30
#define PICA_OFF       31
#define ELITE_ON       32
#define ELITE_OFF      33
#define NLQ_ON         34
#define NLQ_OFF        35
#define CONDENSED_ON   36
#define CONDENSED_OFF  37
#define EXPANDED_ON    38
#define EXPANDED_OFF   39
#define LINE6_ON       40
#define LINE6_OFF      41
#define LINE8_ON       42
#define LINE8_OFF      43
#define MAX_CTRL       44

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

GLOBAL PRNCFG prncfg;

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_printer _((VOID));
GLOBAL BOOLEAN term_printer _((VOID));

GLOBAL BOOLEAN open_printer _((WORD icon));
GLOBAL BOOLEAN info_printer _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_printer _((WINDOWP window, WORD icon));

GLOBAL BOOLEAN open_queue   _((WORD icon));

GLOBAL BOOLEAN prn_ready    _((WORD port));
GLOBAL BOOLEAN prn_check    _((WORD port));
GLOBAL BOOLEAN prn_occupied _((VOID));
GLOBAL BOOLEAN str_to_prn   _((BYTE *s, FILE *file, BOOLEAN to_printer));
GLOBAL BOOLEAN code_to_prn  _((PRNCFG *prncfg, FILE *file, BOOLEAN to_printer, BOOLEAN start));
GLOBAL FILE    *fopen_prn   _((BYTE *filename));
GLOBAL VOID    fclose_prn   _((VOID));
GLOBAL VOID    spool_file   _((BYTE *filename, WORD port, BOOLEAN binary, BOOLEAN tmp, LONG events_ps, LONG bytes_pe));
GLOBAL VOID    print_buffer _((BYTE *buffer, LONG size));
GLOBAL VOID    check_spool  _((VOID));
GLOBAL VOID    get_ctrlcode _((WORD ctrl_code, BYTE *code));

GLOBAL VOID    get_prncfg   _((PRNCFG *prncfg));
GLOBAL VOID    set_prncfg   _((PRNCFG *prncfg));
GLOBAL VOID    get_prname   _((PRNCFG *prncfg, BYTE *prname));
GLOBAL BOOLEAN load_prncfg  _((BYTE *loadinf, BYTE *loadname, PRNCFG *cfg, BOOLEAN updt_dialog));
GLOBAL BOOLEAN save_prncfg  _((FILE *savefile, BYTE *savename, PRNCFG *cfg));
GLOBAL BOOLEAN load_driver  _((BYTE *filename));

#endif /* __PRINTER__ */

