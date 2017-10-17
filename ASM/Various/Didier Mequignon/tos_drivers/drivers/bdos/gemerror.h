/*
 * gemerror.h - standard error numbers for GEMDOS
 *
 * Copyright (c) 2001 Lineo, Inc.
 *
 * Authors:
 *  xxx <xxx@xxx>
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */

#ifndef _MINT_ERRNO_H

/* BIOS level errors */

#define E_OK      0L    /* OK, no error                 0x00            */
#define ERR      -1L    /* basic, fundamental error     0xffffffff      */
#define EDRVNR   -2L    /* drive not ready              0xfffffffe      */
#define EUNCMD   -3L    /* unknown command              0xfffffffd      */
#define E_CRC    -4L    /* CRC error                    0xfffffffc      */
#define EBADRQ   -5L    /* bad request                  0xfffffffb      */
#define E_SEEK   -6L    /* seek error                   0xfffffffa      */
#define EMEDIA   -7L    /* unknown media                0xfffffff9      */
#define ESECNF   -8L    /* sector not found             0xfffffff8      */
#define EPAPER   -9L    /* no paper                     0xfffffff7      */
#define EWRITF  -10L    /* write fault                  0xfffffff6      */
#define EREADF  -11L    /* read fault                   0xfffffff5      */
#define EGENRL  -12L    /* general error                0xfffffff4      */
#define EWRPRO  -13L    /* write protect                0xfffffff3      */
#define E_CHNG  -14L    /* media change                 0xfffffff2      */
#define EUNDEV  -15L    /* unknown device               0xfffffff1      */
#define EBADSF  -16L    /* bad sectors on format        0xfffffff0      */
#define EOTHER  -17L    /* insert other disk            0xffffffef      */

/* BDOS level errors */

#define EINVFN  -32L    /* invalid function number       1   0xffffffe0 */
#define EFILNF  -33L    /* file not found                2   0xffffffdf */
#define EPTHNF  -34L    /* path not found                3   0xffffffde */
#define ENHNDL  -35L    /* too many open files           4   0xffffffdd */
#define EACCDN  -36L    /* access denied                 5   0xffffffdc */
#define EIHNDL  -37L    /* invalid handle                6   0xffffffdb */

#define ENSMEM  -39L    /* insufficient memory           8   0xffffffd9 */
#define EIMBA   -40L    /* invalid memory block address  9   0xffffffd8 */

#define EDRIVE  -46L    /* invalid drive was specified  15   0xffffffd2 */

#define ENMFIL  -49L    /* no more files                18   0xffffffcf */

/* our own inventions */

#define ERANGE  -64L    /* range error                  0xffffffc0      */
#define EINTRN  -65L    /* internal error               0xffffffbf      */
#define EPLFMT  -66L    /* invalid program load format  0xffffffbe      */
#define EGSBF   -67L    /* setblock fail: growth restr. 0xffffffbd      */

#endif
