/****************************************************************/
/*                                                              */
/*   Keytbl.h  Header File fuer keyboard-scan umsetzung         */
/*                                                              */
/****************************************************************/

/* Key-Descriptoren */

#define   KEY_N     0x100     /*Normal Key, Keine spezielle Verarbeitung*/
#define   KEY_F     0x200     /*Function Key (F1-F10) */
#define   KEY_P     0x400     /*VT100 Keypad */
#define   KEY_C     0x800     /* Cursor Keys */
#define   KEY_S     0x1000    /* Special Keys */

/* Funktions-Tasten */

#define   K_F1      1
#define   K_F2      2
#define   K_F3      3
#define   K_F4      4
#define   K_F5      5
#define   K_F6      6
#define   K_F7      7
#define   K_F8      8
#define   K_F9      9
#define   K_F10     10        /* F-Keys shifted */
#define   K_SF1     11
#define   K_SF2     12
#define   K_SF3     13
#define   K_SF4     14
#define   K_SF5     15
#define   K_SF6     16
#define   K_SF7     17
#define   K_SF8     18
#define   K_SF9     19
#define   K_SF10    20

/* Keypad Tasten */
#define   K_P0      1
#define   K_PDOT    2
#define   K_PENT    3
#define   K_P1      4
#define   K_P2      5
#define   K_P3      6
#define   K_P4      8
#define   K_P5      9
#define   K_P6      10
#define   K_PADD    11
#define   K_P7      12
#define   K_P8      13
#define   K_P9      14
#define   K_PMIN    15
#define   K_PPF1    16
#define   K_PPF2    17
#define   K_PPF3    18
#define   K_PPF4    19

/* Cursor Tasten */

#define   K_CUP     1
#define   K_DOWN    2
#define   K_LEFT    3
#define   K_RIGHT   4

/*  Spezielle Tasten */

#define   K_HELP    1
#define   K_UNDO    2
#define   K_INSERT  3
#define   K_HOME    4
#define   K_CLR     5




