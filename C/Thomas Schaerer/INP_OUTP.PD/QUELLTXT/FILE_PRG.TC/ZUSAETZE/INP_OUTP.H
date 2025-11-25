/* INP_OUTP.H  Include-File zu INP_OUTP.C      */
 
#include <stdio.h> 
#include <stdlib.h>   
#include <math.h>   /* wegen 'pow10'           */ 
#include <ext.h>                /* wegen 'putch', 'getch'  */ 
#include <tos.h>                /* wegen 'gemdos','Cconis' */ 
#include <string.h> 
#include <aes.h>    /* wegen 'evnt_keybd()'    */ 
 
#define  FALSE    0 
#define  TRUE    -1 
#define  MUE    230     /* Mikro - Zeichen              */ 
#define  F1      59     /* Funktionstaste F1            */ 
#define  CH_MAX  80     /* Max. Zeichen Eingabe         */
#define  BACKSP   8 
#define  TAB      9 
#define  CR      13 
#define  ESC     27 
#define  STREND   0 /* Stringende                                                       */
#define  backspace  Cconout(8) 
#define  space      Cconout(32) 
#define  blank    backspace;  space;  backspace 
#define  bell     Cconout(7) 
#define  cl_eol       putch(ESC);   putch('K') 
#define  cls()        putch(ESC);   putch('E') 
#define  revrs_curs() putch(ESC);   putch('p') 
#define  norm_curs()  putch(ESC);   putch('q') 
#define  ena_curs()   putch(ESC);   putch('e') 
#define  dis_curs()   putch(ESC);   putch('f') 
 
/* -------- ENDE ------- */
