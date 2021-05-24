#ifndef __KEYS_H
#define __KEYS_H

#if !defined(__AES__)
#include "xaes.h"
#endif

/* Addition to K_ALT, K_CTL, K_LSHIFT, K_RSHIFT */
#define K_SCAN      0x0010

#define ASCIICODE(key) (key & 0xFF)
#define SCANCODE(key)  (key >>8)

#define ALT(key)   ((K_ALT << 8) | key)
#define CTRL(key)  ((K_CTRL << 8) | key)
#define LSHIFT(key)((K_LSHIFT << 8) | key)
#define RSHIFT(key)((K_RSHIFT << 8) | key)

#define ASCII(key) ASCIICODE(key)
#define SCAN(key)  ((K_SCAN << 8) | SCANCODE(key))

/* Values in parenthesis are come from french keyboard (scan code|ascii code) */
/* Function keys */
#define F1          SCAN(0x3B00)
#define F2          SCAN(0x3C00)
#define F3          SCAN(0x3D00)
#define F4          SCAN(0x3E00)
#define F5          SCAN(0x3F00)
#define F6          SCAN(0x4000)
#define F7          SCAN(0x4100)
#define F8          SCAN(0x4200)
#define F9          SCAN(0x4300)
#define F10         SCAN(0x4400)
#define LSF1        LSHIFT(SCAN(0x5400))
#define LSF2        LSHIFT(SCAN(0x5500))
#define LSF3        LSHIFT(SCAN(0x5600))
#define LSF4        LSHIFT(SCAN(0x5700))
#define LSF5        LSHIFT(SCAN(0x5800))
#define LSF6        LSHIFT(SCAN(0x5900))
#define LSF7        LSHIFT(SCAN(0x5A00))
#define LSF8        LSHIFT(SCAN(0x5B00))
#define LSF9        LSHIFT(SCAN(0x5C00))
#define LSF10       LSHIFT(SCAN(0x5D00))
#define RSF1        RSHIFT(SCAN(0x5400))
#define RSF2        RSHIFT(SCAN(0x5500))
#define RSF3        RSHIFT(SCAN(0x5600))
#define RSF4        RSHIFT(SCAN(0x5700))
#define RSF5        RSHIFT(SCAN(0x5800))
#define RSF6        RSHIFT(SCAN(0x5900))
#define RSF7        RSHIFT(SCAN(0x5A00))
#define RSF8        RSHIFT(SCAN(0x5B00))
#define RSF9        RSHIFT(SCAN(0x5C00))
#define RSF10       RSHIFT(SCAN(0x5D00))

/* Cursor keys */
#define CURSOR_UP   SCAN(0x4800)
#define CURSOR_LSUP LSHIFT(SCAN(0x4838))
#define CURSOR_RSUP RSHIFT(SCAN(0x4838))
#define CURSOR_PUP  SCAN(0x4900)
#define CURSOR_DN   SCAN(0x5000)
#define CURSOR_LSDN LSHIFT(SCAN(0x5032))
#define CURSOR_RSDN RSHIFT(SCAN(0x5032))
#define CURSOR_PDN  SCAN(0x5100)
#define CURSOR_LT   SCAN(0x4B00)
#define CURSOR_LSLT LSHIFT(SCAN(0x4B34))
#define CURSOR_RSLT RSHIFT(SCAN(0x4B34))
#define CURSOR_RT   SCAN(0x4D00)
#define CURSOR_LSRT LSHIFT(SCAN(0x4D36))
#define CURSOR_RSRT RSHIFT(SCAN(0x4D36))


#define KBD_CTRL_A  CTRL(ASCII(0x1001))
#define KBD_CTRL_B  CTRL(ASCII(0x3002))
#define KBD_CTRL_C  CTRL(ASCII(0x2E03))
#define KBD_CTRL_D  CTRL(ASCII(0x2004))
#define KBD_CTRL_E  CTRL(ASCII(0x1205))
#define KBD_CTRL_F  CTRL(ASCII(0x2106))
#define KBD_CTRL_G  CTRL(ASCII(0x2207))
#define KBD_CTRL_H  CTRL(ASCII(0x2308))
#define KBD_CTRL_I  CTRL(ASCII(0x1709))
#define KBD_CTRL_J  CTRL(ASCII(0x240A))
#define KBD_CTRL_K  CTRL(ASCII(0x250B))
#define KBD_CTRL_L  CTRL(ASCII(0x260C))
#define KBD_CTRL_M  CTRL(ASCII(0x270D))
#define KBD_CTRL_N  CTRL(ASCII(0x310E))
#define KBD_CTRL_O  CTRL(ASCII(0x180F))
#define KBD_CTRL_P  CTRL(ASCII(0x1910))
#define KBD_CTRL_Q  CTRL(ASCII(0x1E11))
#define KBD_CTRL_R  CTRL(ASCII(0x1312))
#define KBD_CTRL_S  CTRL(ASCII(0x1F13))
#define KBD_CTRL_T  CTRL(ASCII(0x1414))
#define KBD_CTRL_U  CTRL(ASCII(0x1615))
#define KBD_CTRL_V  CTRL(ASCII(0x2F16))
#define KBD_CTRL_W  CTRL(ASCII(0x2C17))
#define KBD_CTRL_X  CTRL(ASCII(0x2D18))
#define KBD_CTRL_Y  CTRL(ASCII(0x1519))
#define KBD_CTRL_Z  CTRL(ASCII(0x111A))

/* ASCII code is meaningless here are these keys depends on language */
#define KBD_CTRL_0  CTRL(SCAN(0x0B85))
#define KBD_CTRL_1  CTRL(SCAN(0x0206))
#define KBD_CTRL_2  CTRL(SCAN(0x0382))
#define KBD_CTRL_3  CTRL(SCAN(0x0402))
#define KBD_CTRL_4  CTRL(SCAN(0x0507))
#define KBD_CTRL_5  CTRL(SCAN(0x0608))
#define KBD_CTRL_6  CTRL(SCAN(0x070D))
#define KBD_CTRL_7  CTRL(SCAN(0x088A))
#define KBD_CTRL_8  CTRL(SCAN(0x091F))
#define KBD_CTRL_9  CTRL(SCAN(0x0A87))


/* Misc */
#define KBD_SPACE   ASCII(0x3920)

#define KBD_LESS    ASCII(0x603C)

#define KBD_BACKSPACE ASCII(0x0E08)
#define KBD_ESCAPE    ASCII(0x011B)
#define KBD_TAB       ASCII(0x0F09)
#define KBD_DELETE    ASCII(0x537F)
#define KBD_LSDELETE  LSHIFT(ASCII(0x537F))
#define KBD_RSDELETE  RSHIFT(ASCII(0x537F))
#define KBD_UNDO      SCAN(0x6100)

#define KBD_RETURN    ASCII(0x1C0D)

/* Numeric Pad */
#define KBD_NP0     ASCII(0x7030)   /* PN 0 */
#define KBD_NP1     ASCII(0x6D31)   /* PN 1 */
#define KBD_NP2     ASCII(0x6E32)   /* PN 2 */
#define KBD_NP3     ASCII(0x6F33)   /* PN 3 */
#define KBD_NP4     ASCII(0x6A34)   /* PN 4 */
#define KBD_NPPLUS  ASCII(0x4E2B)   /* Pn + */
#define KBD_NPMINUS ASCII(0x4A2D)   /* Pn - */
#define KBD_NPTIMES ASCII(0x662A)   /* PN * */
#define KBD_NPDIV   ASCII(0x652F)   /* PN / */


#endif