/* ----------------------------------------------------------------------- */
/* J-Source Version 6.2 - COPYRIGHT 1992 Iverson Software Inc.             */
/* 33 Major Street, Toronto, Ontario, Canada, M5S 2K9, (416) 925 6096      */
/*                                                                         */
/* J-Source is provided "as is" without warranty of any kind.              */
/*                                                                         */
/* J-Source Version 6.2 license agreement:  You may use, copy, and         */
/* modify the source.  You have a non-exclusive, royalty-free right        */
/* to redistribute source and executable files.                            */
/* ----------------------------------------------------------------------- */
/*                                                                         */
/* SYS_ and friends                                                        */


#ifndef SYS

#define SYS_AMIGA               1L              /* DICE                    */
#define SYS_ARCHIMEDES          2L
#define SYS_ATARIST             4L              /* GCC                     */
#define SYS_ATT3B1              8L              /* System V C              */
#define SYS_DEC5500             16L             /* GCC                     */
#define SYS_IBMRS6000           32L
#define SYS_MACINTOSH           64L             /* Think C                 */
#define SYS_MIPS                128L            /* GCC                     */
#define SYS_NEXT                256L            /* GCC                     */
#define SYS_OS2                 512L
#define SYS_PC                  1024L           /* Turbo C                 */
#define SYS_PCWIN               2048L           /* Watcom C 386            */
#define SYS_PC386               4096L           /* Watcom C 386            */
#define SYS_SGI                 8192L           /* GCC                     */
#define SYS_SUN3                16384L          /* GCC                     */
#define SYS_SUN4                32768L          /* GCC                     */
#define SYS_VAX                 65536L          /* GCC                     */
#define SYS_386IX               131072L         /* Interactive C           */

#define SYS_ANSILIB             (SYS_AMIGA + SYS_ARCHIMEDES + \
                                 SYS_IBMRS6000 + SYS_MACINTOSH + \
                                 SYS_PC + SYS_PCWIN + SYS_PC386)
#define SYS_SESM                (SYS_ARCHIMEDES + SYS_MACINTOSH + \
                                 SYS_PC + SYS_PCWIN + SYS_PC386)
#define SYS_UNIX                (SYS_ATT3B1 + SYS_DEC5500 + SYS_IBMRS6000 + \
                                 SYS_MIPS + SYS_NEXT + SYS_SGI + SYS_SUN3 + \
                                 SYS_SUN4 + SYS_VAX + SYS_386IX)
#define SYS_LILENDIAN           (SYS_ARCHIMEDES + SYS_DEC5500 + SYS_OS2 + \
                                 SYS_PC + SYS_PCWIN + SYS_PC386 + SYS_386IX)

#define SYS                     SYS_ATARIST
#define LINKJ                   0
#define SYS_DOUBLE              0
#define SYS_GETTOD              0
#define SYS_MACUNIV             0    /* MAC 12-byte universal floating pt. */
#define SYS_MAC6888X            0    /* MAC 12-byte 6888x     floating pt. */

#endif
