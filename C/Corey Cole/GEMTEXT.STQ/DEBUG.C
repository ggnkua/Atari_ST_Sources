/****************************************************************/
/* debug.c -- Debugging routines for GEM applications           */
/*          by Corey Cole, Visionary Systems, ppn 76224,66      */
/* Credit appreciated if you use this.                          */
/* Copyright 1986 ANTIC Publishing                              */
/****************************************************************/

#include "portab.h"                             /* portability macros   */
#include "machine.h"                            /* machine depndnt conv */
#include "obdefs.h"                             /* object definitions   */
#include "gembind.h"                            /* gem binding structs  */

#define  DEBUGOFF       4
#define  DEBUGPART      28
#define  DEBUGLINES     5
#define  DEBUGLEN       (DEBUGPART * DEBUGLINES)

char    big_buf[DEBUGLEN + 2];          /*  General debug buffer        */
static char  debugger[] = "[1][1234567890123456789012345678|\
1234567890123456789012345678|1234567890123456789012345678|\
1234567890123456789012345678|1234567890123456789012345678][ Continue ]";

debug(dbstring)         /*  Print a debug message       */
        char    *dbstring;
{
        int     len, ctr;
        char    *foo, *foo2;

        len = LSTRLEN(dbstring);
        if (len > DEBUGLEN)  len = DEBUGLEN;

        foo = (char *) debugger + DEBUGOFF;
        for (ctr = 0; ctr < DEBUGLEN; ctr += DEBUGPART) {
                if (len > DEBUGPART)
                        LBCOPY(ADDR(foo), ADDR(dbstring), DEBUGPART);
                else {
                        for (foo2 = foo; foo2 < foo + DEBUGPART; ++foo2)
                                *foo2 = ' ';

                        if (len > 0)
                                LBCOPY(ADDR(foo), ADDR(dbstring), len);
                }

                if (ctr != DEBUGLEN - DEBUGPART)
                        foo[DEBUGPART] = '|';

                foo      += DEBUGPART + 1;
                dbstring += DEBUGPART;
                len      -= DEBUGPART;
        }

        form_alert(1, debugger);
}

/*
 *  xprintf -- Simplified version of "sprintf" -- allows up to 9 numeric
 *      arguments, always prints them in hex.  Only formatting codes
 *      allowed are "%x" (hexadecimal word), "%d" (decimal word), and
 *      "%%" (literal '%').  Any other letter following a '%' is treated
 *      as though it were an 'x'.  Other characters are passed through
 *      unchanged (feel free to add other capabilities as you need them).
 */
char *
xprintf(sformat, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
        char    *sformat;
        int     arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9;
{
        int     argptr[9], argindex;
        char    *foobuf;

        argindex  = 0;
        argptr[0] = arg1;
        argptr[1] = arg2;
        argptr[2] = arg3;
        argptr[3] = arg4;
        argptr[4] = arg5;
        argptr[5] = arg6;
        argptr[6] = arg7;
        argptr[7] = arg8;
        argptr[8] = arg9;

        for (foobuf = big_buf; *sformat != '\0'; ++sformat) {
            if (*sformat != '%')  *foobuf++ = *sformat;
            else {
                if (*++sformat == '%')  *foobuf++ = *sformat;
                else  if ((*sformat | 0x20) == 'd') {
                    foobuf += decnum(foobuf, argptr[argindex++]);
                }
                else {
                    foobuf += hexnum(foobuf, argptr[argindex++]);
                }
            }
        }
        *foobuf = '\0';         /*  Append NULL terminator to string    */
        return (big_buf);
}

int
decnum(tostr, val)              /*  Places ASCII equiv of dec val in tostr  */
        char    *tostr;
        int     val;
{
        int     digits, num;
        char    decchar(), *ptr;

        digits = 5;
        if (val < 1000)
                digits = 3;

        for (ptr = tostr + digits - 1; ptr >= tostr; --ptr) {

            if (val == 0) {
                if (ptr == (tostr + digits - 1))
                        *ptr = '0';
                else    *ptr = ' ';     /*  Leading space       */
            }
            else {
                num  = val % 10;
                val /= 10;
                *ptr = '0' + num;
            }
        }

        return (digits);
}

int
hexnum(tostr, val)              /*  Places ASCII equiv of hex val in tostr  */
        char    *tostr;
        int     val;
{
        int     digits;
        char    hexchar(), *ptr;

        digits = 4;
        for (ptr = tostr + digits - 1; ptr >= tostr; --ptr) {
                *ptr = hexchar(val);            /*  Bottom four bits    */
                val  = val >> 4;                /*  Next four bits      */
        }
        return (digits);
}

char
hexchar(val)                    /*  Returns ASCII equiv of hex digit, or '-' */
        int     val;
{
        char    charcode;

        val &= 0xF;
        if (val >= 16)  charcode = '-';
        else  if (val >= 10)  charcode = val - 10 + 'A';
        else  charcode = val + '0';
        return (charcode);
}

#if MC68K
/* Note that LBCOPY and LWCOPY don't really return BYTE and WORD values.
   They are declared this way to match the EXTERN declarations from
   MACHINE.H, thus avoiding annoying compilation errors. */
BYTE LBCOPY(dest, src, len) /*  Copy "len" bytes from *src into *dest  */
        char            *dest;
        register char   *src;
        register int    len;
{
        register char   *p = dest;

        if (dest == src)
                return;
        else  if (dest < src) {         /*  Copying backwards           */
                for ( ; len > 0; --len)
                        *p++ = *src++;
        }
        else {         /*  Forward copy, so start at end and work back  */
                src += len;
                p   += len;
                for ( ; len > 0; --len)
                *--p = *--src;
        }
}

WORD LWCOPY(dest, src, len)  /*  Copy "len" bytes from *src into *dest  */
        int             *dest;
        register int    *src;
        register int    len;
{
        register int    *p = dest;

        if (dest == src)
                return;
        else  if (dest < src) {         /*  Copying backwards           */
                for ( ; len > 0; --len)
                        *p++ = *src++;
        }
        else {         /*  Forward copy, so start at end and work back  */
                src += len;
                p   += len;
                for ( ; len > 0; --len)
                *--p = *--src;
        }
}

WORD LSTRLEN(s)              /*  String length       */
        char    *s;
{
        register  char  *p = s;

        while (*p)
                ++p;
        return ((int) (p - s));
}

#endif

