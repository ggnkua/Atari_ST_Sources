/**************************************************************************/
/*                                                                        */
/*  NAME:         libterm.inc                                             */
/*                                                                        */
/*  DATUM:        21.04.89                                                */
/*                                                                        */
/*  BESCHREIBUNG: Include-Datei fuer libterm.a.                           */
/*                                                                        */
/**************************************************************************/

#ifndef LIBTERMINC
#define LIBTERMINC

#include <portab.h>

extern WORD  tgetent();
extern WORD  tgetnum();
extern WORD  tgetflag();
extern BYTE *tgetstr();
extern BYTE *tgoto();
extern WORD  tputs();
extern VOID  t_beep();
extern VOID  t_cleol();
extern VOID  t_cleos();
extern VOID  t_cls();
extern VOID  t_curson();
extern VOID  t_cursoff();
extern VOID  t_chome();
extern VOID  t_cleft();
extern VOID  t_cright();
extern VOID  t_cdown();
extern VOID  t_cup();
extern BOOL  t_cursstat();
extern VOID  t_cblink();
extern VOID  t_csteady();
extern VOID  t_exit();
extern WORD  t_getc();
extern VOID  t_goxy();
extern WORD  t_init();
extern VOID  t_rawon();
extern VOID  t_rawoff();
extern WORD  t_setatt();
extern VOID  t_hline();
extern VOID  t_vline();
extern VOID  t_box();

/* Bildschirm - Attribute */

#define ATTRIB  0xFF00

#define NRM     0x0000
#define DIM     0x0400
#define INV     0x0800
#define BLK     0x1000
#define UND     0x2000
#define ALT     0x4000
#define GRA     0x8000

#define t_invon()  t_setatt (INV)
#define t_invoff() t_setatt (NRM)
#define t_settw(d) (t_tw = d)

/* Globale  Variablen */

#ifdef GLOBALTERM
extern
#endif GLOBALTERM
 BOOL t_dofflush;

/* Termcap - Strings */

#ifdef GLOBALTERM
extern
#endif GLOBALTERM
 BYTE *t_ae, *t_al, *t_as, *t_cd, *t_ce, *t_CF, *t_cl, 
      *t_cm, *t_CO, *t_dc, *t_dl, *t_G1, *t_G2, *t_G3,
      *t_G4, *t_GC, *t_GD, *t_GE, *t_GH, *t_GL, *t_GR, *t_GS,
      *t_GU, *t_GV, *t_ic, *t_ir, *t_is, *t_mb, *t_md, *t_me,
      *t_mh, *t_mr, *t_se, *t_so, *t_ue, *t_up, *t_us,
      *t_do, *t_ho, *t_nd, *t_le;

/* Termcap - Numbers */

#ifdef GLOBALTERM
extern
#endif GLOBALTERM
 WORD t_li, t_co, t_tw;

/* interne Definitionen fuer termcap - Funktionen */

#define CAPABLEN  2
#define ISSPACE(c)   ((c) == ' ' || (c) == '\t' || (c) == '\r' || (c) == '\n')
#define ISDIGIT(x)   ((x) >= '0' && (x) <= '9')

/* Termcap - Keys */

#define t_Al 0x0100
#define t_c0 0x0101
#define t_c1 0x0102
#define t_c2 0x0103
#define t_c3 0x0104
#define t_c4 0x0105
#define t_c5 0x0106
#define t_c6 0x0107
#define t_c7 0x0108
#define t_c8 0x0109
#define t_c9 0x010A
#define t_cA 0x010B
#define t_cB 0x010C
#define t_cC 0x010D
#define t_cD 0x010E
#define t_cE 0x010F
#define t_cF 0x0110
#define t_DC 0x0111
#define t_Dl 0x0112
#define t_EN 0x0113
#define t_HP 0x0114
#define t_k0 0x0115
#define t_k1 0x0116
#define t_k2 0x0117
#define t_k3 0x0118
#define t_k4 0x0119
#define t_k5 0x011A
#define t_k6 0x011B
#define t_k7 0x011C
#define t_k8 0x011D
#define t_k9 0x011E
#define t_kA 0x011F
#define t_kB 0x0120
#define t_kC 0x0121
#define t_kD 0x0122
#define t_kE 0x0123
#define t_kF 0x0124
#define t_kd 0x0125
#define t_kh 0x0126
#define t_kI 0x0127
#define t_kl 0x0128
#define t_kL 0x0129
#define t_kN 0x012A
#define t_kP 0x012B
#define t_kr 0x012C
#define t_ku 0x012D

#endif LIBTERMINC

