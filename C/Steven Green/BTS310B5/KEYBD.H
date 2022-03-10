#ifndef H_KEYBD
#define H_KEYBD
/*--------------------------------------------------------------------------*/
/*                                                                          */
/*                                                                          */
/*      ------------         Bit-Bucket Software, Co.                       */
/*      \ 10001101 /         Writers and Distributors of                    */
/*       \ 011110 /          Freely Available<tm> Software.                 */
/*        \ 1011 /                                                          */
/*         ------                                                           */
/*                                                                          */
/*  (C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*                                                                          */
/*                                                                          */
/*           Keyboard Scan Code definitions used in BinkleyTerm             */
/*                                                                          */
/*                                                                          */
/*    For complete  details  of the licensing restrictions, please refer    */
/*    to the License  agreement,  which  is published in its entirety in    */
/*    the MAKEFILE and BT.C, and also contained in the file LICENSE.240.    */
/*                                                                          */
/*    USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE    */
/*    BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF    */
/*    THIS  AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,  OR IF YOU DO    */
/*    NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET    */
/*    SOFTWARE CO.  AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT    */
/*    SHOULD YOU  PROCEED TO USE THIS FILE  WITHOUT HAVING  ACCEPTED THE    */
/*    TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER    */
/*    AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.      */
/*                                                                          */
/*                                                                          */
/* You can contact Bit Bucket Software Co. at any one of the following      */
/* addresses:                                                               */
/*                                                                          */
/* Bit Bucket Software Co.        FidoNet  1:104/501, 1:132/491, 1:141/491  */
/* P.O. Box 460398                AlterNet 7:491/0                          */
/* Aurora, CO 80046               BBS-Net  86:2030/1                        */
/*                                Internet f491.n132.z1.fidonet.org         */
/*                                                                          */
/* Please feel free to contact us at any time to share your comments about  */
/* our software and/or licensing policies.                                  */
/*                                                                          */
/*--------------------------------------------------------------------------*/

#if defined(ATARIST)

#define N_SHELLS 10		/* On PC F10 was used for help */

/* most of these will be the same as the PC */

#define ALT_OFFSET  0x800
#define CTRL_OFFSET 0x900

#define ALT(c)	(ALT_OFFSET+c)
#define ALTA	ALT('a')
#define ALTB	ALT('b')
#define ALTC	ALT('c')
#define ALTD	ALT('d')
#define ALTE	ALT('e')
#define ALTF	ALT('f')
#define ALTG	ALT('g')
#define ALTH	ALT('h')
#define ALTI	ALT('i')
#define ALTJ	ALT('j')
#define ALTK	ALT('k')
#define ALTL	ALT('l')
#define ALTM	ALT('m')
#define ALTN	ALT('n')
#define ALTO	ALT('o')
#define ALTP	ALT('p')
#define ALTQ	ALT('q')
#define ALTR	ALT('r')
#define ALTS	ALT('s')
#define ALTT	ALT('t')
#define ALTU	ALT('u')
#define ALTV	ALT('v')
#define ALTW	ALT('w')
#define ALTX	ALT('x')
#define ALTY	ALT('y')
#define ALTZ	ALT('z')

#define ALT1	ALT('1')
#define ALT2	ALT('2')
#define ALT3	ALT('3')
#define ALT4	ALT('4')
#define ALT5	ALT('5')
#define ALT6	ALT('6')
#define ALT7	ALT('7')
#define ALT8	ALT('8')
#define ALT9	ALT('9')
#define ALT0	ALT('0')

#define CTRL(c) (CTRL_OFFSET+(c&0x1f))
#define CTRLC  	CTRL('C')
#define CTRLF  	CTRL('F')
#define CTRLM  	CTRL('M')
#define CTRLQ	CTRL('Q')

#define PGUP	0x4900	/* 02480038 */	/* Shift Up arrow */
#define PGDN	0x5100	/* 02500032 */	/* Shift Down */

#define ALTF1	0x6800	/* 083B0000 */
#define ALTF2	0x6900	/* 083C0000 */
#define ALTF3	0x6a00	/* 083D0000 */
#define ALTF4	0x6b00	/* 083E0000 */
#define ALTF5	0x6c00	/* 083F0000 */
#define ALTF6	0x6d00	/* 08400000 */
#define ALTF7	0x6e00	/* 08410000 */
#define ALTF8   0x6f00	/* 08420000 */
#define ALTF9	0x7000	/* 08430000 */
#define ALTF10	0x7100	/* 08440000 */

#define PF1		0x3b00	/* 003B0000 */
#define PF2		0x3c00	/* 003C0000 */
#define PF3		0x3d00	/* 003D0000 */
#define PF4		0x3e00	/* 003E0000 */
#define PF5		0x3f00	/* 003F0000 */
#define PF6		0x4000	/* 00400000 */
#define PF7		0x4100	/* 00410000 */
#define PF8		0x4200	/* 00420000 */
#define PF9		0x4300	/* 00430000 */
#define PF10	0x4400	/* 00440000 */

#define UPAR	0x4800	/* 00480000 */
#define LFAR	0x4b00	/* 004B0000 */
#define RTAR	0x4d00	/* 004D0000 */
#define DNAR	0x5000	/* 00500000 */
#define HOME   	0x4700	/* 00470000 */
#define END    	0x4f00	/* 02470037 */

#define SHF1	0x5400	/* 02540000 */
#define SHF2	0x5500	/* 02550000 */
#define SHF3	0x5600	/* 02560000 */
#define SHF4	0x5700	/* 02570000 */
#define SHF5	0x5800	/* 02580000 */
#define SHF6	0x5900	/* 02590000 */
#define SHF7	0x5a00	/* 025A0000 */
#define SHF8	0x5b00	/* 025B0000 */
#define SHF9	0x5c00	/* 025C0000 */
#define SHF10	0x5d00	/* 025D0000 */

#define HELP	0x6200	/* 00620000 */
#define UNDO	0x6100	/* 00610000 */
#define INSERT	0x5200	/* 00520000 */


#else	/* Generic PC */

#define N_SHELLS 9		/* On PC F10 is used for help */


#define ALTA	0x1e00
#define ALTB	0x3000
#define ALTC	0x2e00
#define ALTD	0x2000
#define ALTE	0x1200
#define ALTF	0x2100
#define ALTG	0x2200
#define ALTH	0x2300
#define ALTI	0x1700
#define ALTJ	0x2400
#define ALTK	0x2500
#define ALTL	0x2600
#define ALTM	0x3200
#define ALTN	0x3100
#define ALTO	0x1800
#define ALTP	0x1900
#define ALTQ	0x1000
#define ALTR	0x1300
#define ALTS	0x1f00
#define ALTT	0x1400
#define ALTU	0x1600
#define ALTV	0x2f00
#define ALTW	0x1100
#define ALTX	0x2d00
#define ALTY	0x1500
#define ALTZ	0x2600

#define CTRLC  	0x2e03

#define ALT1	0x7800
#define ALT2	0x7900
#define ALT3	0x7a00
#define ALT4	0x7b00
#define ALT5	0x7c00
#define ALT6	0x7d00
#define ALT7	0x7e00
#define ALT8	0x7f00
#define ALT9	0x8000
#define ALT0	0x8100

#define PGUP	0x4900
#define PGDN	0x5100

#define ALTF1	0x6800
#define ALTF2	0x6900
#define ALTF3	0x6a00
#define ALTF4	0x6b00
#define ALTF5	0x6c00
#define ALTF6	0x6d00
#define ALTF7	0x6e00
#define ALTF8  	0x6f00
#define ALTF9	0x7000
#define ALTF10	0x7100

#define PF1		0x3b00
#define PF2		0x3c00
#define PF3		0x3d00
#define PF4		0x3e00
#define PF5		0x3f00
#define PF6		0x4000
#define PF7		0x4100
#define PF8		0x4200
#define PF9		0x4300
#define PF10	0x4400

#define UPAR	0x4800
#define LFAR	0x4b00
#define RTAR	0x4d00
#define DNAR	0x5000
#define HOME   	0x4700
#define END    	0x4f00

#define SHF1	0x5400
#define SHF2	0x5500
#define SHF3	0x5600
#define SHF4	0x5700
#define SHF5	0x5800
#define SHF6	0x5900
#define SHF7	0x5a00
#define SHF8	0x5b00
#define SHF9	0x5c00
#define SHF10	0x5d00

#endif

#endif	/* H_KEYBD */
