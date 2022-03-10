/* KEYCODES.H  C-language include file for GEM */
/* Defines codes obtained from GEM evnt_multi() and evnt_keybd() routines */
/* Prepared by Tyson Gill and GT Software ( T.GILL7 on GEnie ) */
/* Please report any corrections or additions to the author. */
/* This file is public domain and may be freely used and distributed. */


/* named keys with combinations */
#define KEY_BACKSPACE 0x0E08        /* Backspace */
#define KEY_CLR 0x4737              /* Clr (also SHIFT_HOME) */
#define KEY_DELETE 0x537F           /* Delete  */
#define SHIFT_DELETE 0x532E
#define KEY_ENTER 0x720D            /* Enter */
#define KEY_ESCAPE 0x011B           /* Esc */
#define KEY_HELP 0x6100             /* Help */
#define KEY_HOME 0x4700             /* Home */
#define SHIFT_HOME 0x4737           /* also KEY_CLR */
#define CNTRL_HOME 0x7700
#define KEY_INSERT 0x5200           /* Insert */
#define SHIFT_INSERT 0x5230
#define KEY_RETURN 0x1C0D           /* Return */
#define CNTRL_RETURN 0x1C0A
#define KEY_TAB 0x0F09              /* Tab */
#define KEY_UNDO 0x6200             /* Undo */

/* cursor keys */
#define KEY_LARROW 0x4B00
#define KEY_RARROW 0x4D00
#define KEY_UARROW 0x4800
#define KEY_DARROW 0x5000
#define SHIFT_LARROW 0x4B34
#define CNTRL_LARROW 0x7300
#define SHIFT_RARROW 0x4D36
#define CNTRL_RARROW 0x7400
#define SHIFT_UARROW 0x4838
#define SHIFT_DARROW 0x5032
/* Note that there are no defined Control-Up or Control-Down codes */

/* non-alpha keys with combinations */
#define KEY_ACCENT 0x2960           /* ` (below tilde) */
#define KEY_AMPERSAND 0x0826        /* & */
#define KEY_APOSTROPHE 0x2827       /* ' (below quotation mark) */
#define KEY_ASTERISK 0x092A         /* * */
#define KEY_AT 0x0340               /* @ */
#define KEY_CARET 0x075E            /* ^ */
#define KEY_COLON 0x273A            /* : */
#define KEY_COMMA 0x332C            /* , */
#define KEY_DOLLAR 0x0524           /* $ */
#define KEY_EQUALS 0x0D3D           /* = */
#define ALT_EQUALS 0x8300
#define KEY_EXCLAMATION 0x0221      /* ! */
#define KEY_MINUS 0x0C2D            /* - */
#define ALT_MINUS 0x8200
#define CNTRL_MINUS 0x0C1F
#define KEY_PERCENT 0x0625          /* % */
#define KEY_PERIOD 0x342E           /* . */
#define KEY_PLUS 0x0D2B             /* + */
#define KEY_POUNDS 0x0423           /* # */
#define KEY_QUESTION 0x353F         /* ? */
#define KEY_QUOTATION 0x2822        /* " */
#define KEY_SEMICOLON 0x273B        /* ; */
#define KEY_SPACE 0x3920            /*   */
#define KEY_TILDE 0x297E            /* ~ */
#define KEY_ULINE 0x0C5F            /* _ */
#define KEY_VLINE 0x2B7C            /* | */

/* Brackets with combinations */
#define KEY_L_ANGLE 0x333C          /* < */
#define KEY_R_ANGLE 0x343E          /* > */
#define KEY_L_BRACKET 0x1A7B        /* { */
#define KEY_R_BRACKET 0x1B7D        /* } */
#define KEY_L_PAREN 0x0A28          /* ( */
#define KEY_R_PAREN 0x0B29          /* ) */
#define KEY_SLASH 0x352F            /* / */
#define KEY_BACKSLASH 0x2B5C        /* \ */
#define CNTRL_BACKSLASH 0x2B1C
#define KEY_L_SQUARE 0x1A5B         /* [ */
#define CNTRL_L_SQUARE 0x1A1B
#define KEY_R_SQUARE 0x1B5D         /* ] */
#define CNTRL_R_SQUARE 0x1B1D

/* Number keys */
#define KEY_0 0x0B30
#define KEY_1 0x0231
#define KEY_2 0x0332
#define KEY_3 0x0433
#define KEY_4 0x0534
#define KEY_5 0x0635
#define KEY_6 0x0736
#define KEY_7 0x0837
#define KEY_8 0x0938
#define KEY_9 0x0A39

/* Numeric keypad */
#define KEYPAD_MINUS 0x4A2B
#define KEYPAD_PLUS 0x4E2B

/* Upper case letters */
#define KEY_A 0x1E41
#define KEY_B 0x3042
#define KEY_C 0x2E43
#define KEY_D 0x2044
#define KEY_E 0x1245
#define KEY_F 0x2146
#define KEY_G 0x2247
#define KEY_H 0x2348
#define KEY_I 0x1749
#define KEY_J 0x244A
#define KEY_K 0x254B
#define KEY_L 0x264C
#define KEY_M 0x324D
#define KEY_N 0x314E
#define KEY_O 0x184F
#define KEY_P 0x1950
#define KEY_Q 0x1051
#define KEY_R 0x1352
#define KEY_S 0x1F53
#define KEY_T 0x1454
#define KEY_U 0x1655
#define KEY_V 0x2F56
#define KEY_W 0x1157
#define KEY_X 0x2D58
#define KEY_Y 0x1559
#define KEY_Z 0x2C5A

/* Lower case letters */
#define KEY_a 0x1E61
#define KEY_b 0x3062
#define KEY_c 0x2E63
#define KEY_d 0x2064
#define KEY_e 0x1265
#define KEY_f 0x2166
#define KEY_g 0x2267
#define KEY_h 0x2368
#define KEY_i 0x1769
#define KEY_j 0x246A
#define KEY_k 0x256B
#define KEY_l 0x266C
#define KEY_m 0x326D
#define KEY_n 0x316E
#define KEY_o 0x186F
#define KEY_p 0x1970
#define KEY_q 0x1071
#define KEY_r 0x1372
#define KEY_s 0x1F73
#define KEY_t 0x1474
#define KEY_u 0x1675
#define KEY_v 0x2F76
#define KEY_w 0x1177
#define KEY_x 0x2D78
#define KEY_y 0x1579
#define KEY_z 0x2C7A

/* Control combinations */
#define CNTRL_2 0x0300
#define CNTRL_6 0x071E
#define CNTRL_A 0x1E01
#define CNTRL_B 0x3002
#define CNTRL_C 0x2E03
#define CNTRL_D 0x2004
#define CNTRL_E 0x1205
#define CNTRL_F 0x2106
#define CNTRL_G 0x2207
#define CNTRL_H 0x2308
#define CNTRL_I 0x1709
#define CNTRL_J 0x240A
#define CNTRL_K 0x250B
#define CNTRL_L 0x260C
#define CNTRL_M 0x320D
#define CNTRL_N 0x310E
#define CNTRL_O 0x180F
#define CNTRL_P 0x1910
#define CNTRL_Q 0x1011
#define CNTRL_R 0x1312
#define CNTRL_S 0x1F13
#define CNTRL_T 0x1414
#define CNTRL_U 0x1615
#define CNTRL_V 0x2F16
#define CNTRL_W 0x1117
#define CNTRL_X 0x2D18
#define CNTRL_Y 0x1519
#define CNTRL_Z 0x2C1A

/* Alternate combinations */
#define ALT_0 0x8100
#define ALT_1 0x7800
#define ALT_2 0x7900
#define ALT_3 0x7A00
#define ALT_4 0x7B00
#define ALT_5 0x7C00
#define ALT_6 0x7D00
#define ALT_7 0x7E00
#define ALT_8 0x7F00
#define ALT_9 0x8000
#define ALT_A 0x1E00
#define ALT_B 0x3000
#define ALT_C 0x2E00
#define ALT_D 0x2000
#define ALT_E 0x1200
#define ALT_F 0x2100
#define ALT_G 0x2200
#define ALT_H 0x2300
#define ALT_I 0x1700
#define ALT_J 0x2400
#define ALT_K 0x2500
#define ALT_L 0x2600
#define ALT_M 0x3200
#define ALT_N 0x3100
#define ALT_O 0x1800
#define ALT_P 0x1900
#define ALT_Q 0x1000
#define ALT_R 0x1300
#define ALT_S 0x1F00
#define ALT_T 0x1400
#define ALT_U 0x1600
#define ALT_V 0x2F00
#define ALT_W 0x1100
#define ALT_X 0x2D00
#define ALT_Y 0x1500
#define ALT_Z 0x2C00

/* Function keys */
#define FKEY_1 0x3B00
#define FKEY_2 0x3C00
#define FKEY_3 0x3D00
#define FKEY_4 0x3E00
#define FKEY_5 0x3F00
#define FKEY_6 0x4000
#define FKEY_7 0x4100
#define FKEY_8 0x4200
#define FKEY_9 0x4300
#define FKEY_10 0x4400
#define SHIFT_F1 0x5400
#define SHIFT_F2 0x5500
#define SHIFT_F3 0x5600
#define SHIFT_F4 0x5700
#define SHIFT_F5 0x5800
#define SHIFT_F6 0x5900
#define SHIFT_F7 0x5A00
#define SHIFT_F8 0x5B00
#define SHIFT_F9 0x5C00
#define SHIFT_F10 0x5D00
