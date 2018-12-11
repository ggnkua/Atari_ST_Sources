#ifndef __KEYS
#define __KEYS

#if !defined(__AES__)
#include <xaes.h>
#endif

/* Function keys */
#define F1          0x3B00
#define F2          0x3C00
#define F3          0x3D00
#define F4          0x3E00
#define F5          0x3F00
#define F6          0x4000
#define F7          0x4100
#define F8          0x4200
#define F9          0x4300
#define F10         0x4400
#define SF1         0x5400
#define SF2         0x5500
#define SF3         0x5600
#define SF4         0x5700
#define SF5         0x5800
#define SF6         0x5900
#define SF7         0x5A00
#define SF8         0x5B00
#define SF9         0x5C00
#define SF10        0x5D00

/* Cursor keys */
#define CURSOR_UP   0x4800
#define CURSOR_SUP  0x4838
#define CURSOR_PUP  0x4900
#define CURSOR_DN   0x5000
#define CURSOR_SDN  0x5032
#define CURSOR_PDN  0x5100
#define CURSOR_LT   0x4B00
#define CURSOR_SLT  0x4B34
#define CURSOR_RT   0x4D00
#define CURSOR_SRT  0x4D36

/* Typical menu shortcuts */
#define CTRL(x)    ((K_CTRL << 8) | ((x) & 0x00FF))
/* Following scancodes come from Mint, only ASCII code makes sense, use CTRL macro to normalize */
#define KBD_CTRL_A  CTRL(0x1001)
#define KBD_CTRL_B  CTRL(0x3002)
#define KBD_CTRL_C  CTRL(0x2E03)
#define KBD_CTRL_D  CTRL(0x2004)
#define KBD_CTRL_E  CTRL(0x1205)
#define KBD_CTRL_F  CTRL(0x2106)
#define KBD_CTRL_G  CTRL(0x2207)
#define KBD_CTRL_H  CTRL(0x2308)
#define KBD_CTRL_I  CTRL(0x1709)
#define KBD_CTRL_J  CTRL(0x240A)
#define KBD_CTRL_K  CTRL(0x250B)
#define KBD_CTRL_L  CTRL(0x260C)
#define KBD_CTRL_M  CTRL(0x270D)
#define KBD_CTRL_N  CTRL(0x310E)
#define KBD_CTRL_O  CTRL(0x180F)
#define KBD_CTRL_P  CTRL(0x1910)
#define KBD_CTRL_Q  CTRL(0x1E11)
#define KBD_CTRL_R  CTRL(0x1312)
#define KBD_CTRL_S  CTRL(0x1F13)
#define KBD_CTRL_T  CTRL(0x1414)
#define KBD_CTRL_U  CTRL(0x1615)
#define KBD_CTRL_V  CTRL(0x2F16)
#define KBD_CTRL_W  CTRL(0x2C17)
#define KBD_CTRL_X  CTRL(0x2D18)
#define KBD_CTRL_Y  CTRL(0x1519)
#define KBD_CTRL_Z  CTRL(0x111A)

/* Misc */
#define KBD_SPACE   0x3920

#define KBD_LESS    0x603C

#define KBD_BACKSPACE 0x0E08
#define KBD_ESCAPE    0x011B
#define KBD_TAB       0x0F09
#define KBD_DELETE    0x537F
#define KBD_SDELETE   0x537E /* Hoping this code does not map another key ! */
#define KBD_UNDO      0x6100

/* Numeric Pad */
#define KBD_NP0     0x7030    /* PN 0 */
#define KBD_NP1     0x6D31    /* PN 1 */
#define KBD_NP2     0x6E32    /* PN 2 */
#define KBD_NP3     0x6F33    /* PN 3 */
#define KBD_NP4     0x6A34    /* PN 4 */
#define KBD_NPPLUS  0x4E2B    /* Pn + */
#define KBD_NPMINUS 0x4A2D    /* Pn - */
#define KBD_NPTIMES 0x662A    /* PN * */
#define KBD_NPDIV   0x652F    /* PN / */


#endif