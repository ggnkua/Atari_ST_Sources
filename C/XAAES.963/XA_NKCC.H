/*******************************************************************************
*
*  Project name : NORMALIZED KEY CODE CONVERTER (NKCC)
*  Module name  : Global definitions
*  Symbol prefix: nkc
*
*  Author       : Harald Siegmund (HS)
*  Co-Authors   : - Henk Robbers (Reductions for use in XaAES)
*  Write access : HS
*
*/

/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef __NKCC
#define __NKCC

   /* flags for NKCC initialization */

#define NKI_BUTHND   0x00000001UL   /* install button event handler */
#define NKI_BHTOS    0x00000002UL   /* additional flag: only if TOS has */
                                    /*  mouse click bug */
#define NKI_NO200HZ  0x00000004UL   /* don't install 200 Hz clock interrupt */
                                    /*  (this flag is ignored if the button */
                                    /*  event handler is being activated) */

   /* flag combinations for compatibility with old versions of NKCC */

#define BE_ON        NKI_BUTHND
#define BE_OFF       0
#define BE_TOS       (NKI_BUTHND | NKI_BHTOS)


   /* flags for special key code handling */

#define NKS_ALTNUM   0x00000001UL   /* Alt + numeric pad -> ASCII */
#define NKS_CTRL     0x00000002UL   /* Control key emulation */
                                    /* deadkey management: */
#define NKS_D_CIRCUM 0x00010000UL   /* ^  accent circumflex */
#define NKS_D_TILDE  0x00020000UL   /* ~  accent tilde */
#define NKS_D_AGUI   0x00040000UL   /* '  accent agui */
#define NKS_D_GRAVE  0x00080000UL   /* `  accent grave */
#define NKS_D_UMLAUT 0x00100000UL   /* ¹  umlaut */
#define NKS_D_QUOTE  0x00200000UL   /* "  quote, synonym for umlaut */
#define NKS_D_SMOERE 0x00400000UL   /* ø  smoerebroed */
#define NKS_D_CEDIL  0x00800000UL   /* ,  cedil */
#define NKS_D_SLASH  0x01000000UL   /* /  slash, for scandinavian characters */
#define NKS_DEADKEY  0xffff0000UL   /* all deadkeys */

   /* NKCC key code flags */

#define NKF_FUNC     0x8000         /* function          */
#define NKF_RESVD    0x4000         /* resvd, ignore it! */
#define NKF_NUM      0x2000         /* numeric pad       */
#define NKF_CAPS     0x1000         /* CapsLock          */
#define NKF_ALT      0x0800         /* Alternate         */
#define NKF_CTRL     0x0400         /* Control           */
#define NKF_SHIFT    0x0300         /* any Shift key     */
#define NKF_LSH      0x0200         /* left Shift key    */
#define NKF_RSH      0x0100         /* right Shift key   */

#define NKF_IGNUM    NKF_RESVD      /* special flag for nkc_cmp() */

   /* special key codes for keys performing a function */

#define NK_INVALID   0x00           /* invalid key code  */
#define NK_UP        0x01           /* cursor up         */
#define NK_DOWN      0x02           /* cursor down       */
#define NK_RIGHT     0x03           /* cursor right      */
#define NK_LEFT      0x04           /* cursor left       */
#define NK_RVD05     0x05           /* reserved!         */
#define NK_RVD06     0x06           /* reserved!         */
#define NK_RVD07     0x07           /* reserved!         */
#define NK_BS        0x08           /* Backspace         */
#define NK_TAB       0x09           /* Tab               */
#define NK_ENTER     0x0a           /* Enter             */
#define NK_INS       0x0b           /* Insert            */
#define NK_CLRHOME   0x0c           /* Clr/Home          */
#define NK_HOME      0x0c           /* Clr/Home          */
#define NK_RET       0x0d           /* Return            */
#define NK_HELP      0x0e           /* Help              */
#define NK_UNDO      0x0f           /* Undo              */
#define NK_F1        0x10           /* function key #1   */
#define NK_F2        0x11           /* function key #2   */
#define NK_F3        0x12           /* function key #3   */
#define NK_F4        0x13           /* function key #4   */
#define NK_F5        0x14           /* function key #5   */
#define NK_F6        0x15           /* function key #6   */
#define NK_F7        0x16           /* function key #7   */
#define NK_F8        0x17           /* function key #8   */
#define NK_F9        0x18           /* function key #9   */
#define NK_F10       0x19           /* function key #10  */
#define NK_RVD1A     0x1a           /* reserved!         */
#define NK_ESC       0x1b           /* Esc               */
#define NK_RVD1C     0x1c           /* reserved!         */
#define NK_RVD1D     0x1d           /* reserved!         */
#define NK_RVD1E     0x1e           /* reserved!         */
#define NK_DEL       0x1f           /* Delete            */

                                    /* terminator for key code tables */
#define NK_TERM      ((int)(NKF_FUNC | NK_INVALID))

   /* ASCII codes less than 32 */

#define NUL          0x00           /* Null */
#define SOH          0x01           /* Start Of Header */
#define STX          0x02           /* Start Of Text */
#define ETX          0x03           /* End Of Text */
#define EOT          0x04           /* End Of Transmission */
#define ENQ          0x05           /* Enquiry */
#define ACK          0x06           /* positive Acknowledgement */
#define BEL          0x07           /* Bell */
#define BS           0x08           /* BackSpace */
#define HT           0x09           /* Horizontal Tab */
#define LF           0x0a           /* Line Feed */
#define VT           0x0b           /* Vertical Tab */
#define FF           0x0c           /* Form Feed */
#define CR           0x0d           /* Carriage Return */
#define SO           0x0e           /* Shift Out */
#define SI           0x0f           /* Shift In */
#define DLE          0x10           /* Data Link Escape */
#define DC1          0x11           /* Device Control 1 */
#define XON          0x11           /* same as DC1 */
#define DC2          0x12           /* Device Control 2 */
#define DC3          0x13           /* Device Control 3 */
#define XOFF         0x13           /* same as DC3 */
#define DC4          0x14           /* Device Control 4 */
#define NAK          0x15           /* Negative Acknowledgement */
#define SYN          0x16           /* Synchronize */
#define ETB          0x17           /* End of Transmission Block */
#define CAN          0x18           /* Cancel */
#define EM           0x19           /* End of Medium */
#define SUB          0x1a           /* Substitute */
#define ESC          0x1b           /* Escape */
#define FS           0x1c           /* Form Separator */
#define GS           0x1d           /* Group Separator */
#define RS           0x1e           /* Record Separator */
#define US           0x1f           /* Unit Separator */

   /* XBRA vector link/unlink modes */

#define NKXM_NUM     0              /* by vector number */
#define NKXM_ADR     1              /* by vector address */

   /* additional flag in event mask */

#define MU_XTIMER    0x100

int normkey(short aesstate, short aescode);

   /* install NKCC */
void *nkc_init(void);

   /* deinstall NKCC */
int nkc_exit(void);


   /* convert key code in TOS format to normalized format */
int nkc_tconv(long toskey);


#endif      /* #ifndef __NKCC */
