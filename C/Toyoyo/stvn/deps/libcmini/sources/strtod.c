/*
 * strtod.c --
 *
 *  Source code for the "strtod" library procedure.
 *
 * Copyright (c) 1988-1993 The Regents of the University of California.
 * Copyright (c) 1994 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * RCS: @(#) $Id: strtod.c,v 1.1.1.3 2002/04/05 16:12:51 jevans Exp $
 */

/*
 * Content of "license.terms" as of Jul 24, 2019:
 *
 * This software is copyrighted by the Regents of the University of
 * California, Sun Microsystems, Inc., Scriptics Corporation, ActiveState
 * Corporation and other parties.  The following terms apply to all files
 * associated with the software unless explicitly disclaimed in
 * individual files.
 *
 * The authors hereby grant permission to use, copy, modify, distribute,
 * and license this software and its documentation for any purpose, provided
 * that existing copyright notices are retained in all copies and that this
 * notice is included verbatim in any distributions. No written agreement,
 * license, or royalty fee is required for any of the authorized uses.
 * Modifications to this software may be copyrighted by their authors
 * and need not follow the licensing terms described here, provided that
 * the new terms are clearly indicated on the first page of each file where
 * they apply.
 *
 * IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
 * FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
 * ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
 * DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
 * IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
 * NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
 * MODIFICATIONS.
 *
 * GOVERNMENT USE: If you are acquiring this software on behalf of the
 * U.S. government, the Government shall have only "Restricted Rights"
 * in the software and related documentation as defined in the Federal
 * Acquisition Regulations (FARs) in Clause 52.227.19 (c) (2).  If you
 * are acquiring the software on behalf of the Department of Defense, the
 * software shall be classified as "Commercial Computer Software" and the
 * Government shall have only "Restricted Rights" as defined in Clause
 * 252.227-7013 (c) (1) of DFARs.  Notwithstanding the foregoing, the
 * authors grant the U.S. Government and others acting in its behalf
 * permission to use and distribute the software in accordance with the
 * terms specified in this license.
 *
 * http://ftp.nmr.mgh.harvard.edu/pub/dist/freesurfer/tutorial_packages/OSX/fsl_501/extras/src/tcl/license.terms
 * http://ftp.nmr.mgh.harvard.edu/pub/dist/freesurfer/tutorial_packages/OSX/fsl_501/extras/src/tcl/compat/strtod.c
 */

#include <errno.h>
#include <stdlib.h>


#ifndef TRUE
# define TRUE   1
# define FALSE  0
#endif


#define ISSPACE(c)  ((c) == ' ' || (c) == '\t')
#define ISDIGIT(c)  ((c) >= '0' && (c) <= '9')


#ifndef FLOAT
# define FLOAT   double
# define STRTOF  strtod
#endif /* !defined FLOAT */

static int maxExponent = 511;   /* Largest possible base 10 exponent.  Any
								 * exponent larger than this will already
								 * produce underflow or overflow, so there's
								 * no need to worry about additional digits.
								 */

static FLOAT powersOf10[] = /* Table giving binary powers of 10.  Entry */
{							/* is 10^2^i.  Used to convert decimal      */
	1.0e1,					/* exponents into floating-point numbers.   */
    1.0e2,
    1.0e4,
	1.0e8,
	1.0e16,
	1.0e32,
	1.0e64,
	1.0e128,
	1.0e256
};


/*
 *----------------------------------------------------------------------
 *
 * strtod --
 *
 *  This procedure converts a floating-point number from an ASCII
 *  decimal representation to internal double-precision format.
 *
 * Results:
 *  The return value is the double-precision floating-point
 *  representation of the characters in string.  If endPtr isn't
 *  NULL, then *endPtr is filled in with the address of the
 *  next character after the last one that was part of the
 *  floating-point number.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */

FLOAT
STRTOF(const char* string, char** endPtr)
{
    int sign, expSign = FALSE;
    FLOAT fraction, dblExp, *d;
    register const char *p;
    register int c;
    int exp = 0;        /* Exponent read from "EX" field. */
    int fracExp = 0;        /* Exponent that derives from the fractional
                 * part.  Under normal circumstatnces, it is
                 * the negative of the number of digits in F.
                 * However, if I is very long, the last digits
                 * of I get dropped (otherwise a long I with a
                 * large negative exponent could cause an
                 * unnecessary overflow on I alone).  In this
                 * case, fracExp is incremented one for each
                 * dropped digit. */
    int mantSize;       /* Number of digits in mantissa. */
    int decPt;          /* Number of mantissa digits BEFORE decimal
                 * point. */
    const char *pExp;       /* Temporarily holds location of exponent
                 * in string. */

    /*
     * Strip off leading blanks and check for a sign.
     */

    p = string;
    while (ISSPACE((unsigned char)*p)) {
    p += 1;
    }
    if (*p == '-') {
    sign = TRUE;
    p += 1;
    } else {
    if (*p == '+') {
        p += 1;
    }
    sign = FALSE;
    }

    /*
     * Count the number of digits in the mantissa (including the decimal
     * point), and also locate the decimal point.
     */

    decPt = -1;
    for (mantSize = 0; ; mantSize += 1)
    {
    c = *p;
    if (!ISDIGIT(c)) {
        if ((c != '.') || (decPt >= 0)) {
        break;
        }
        decPt = mantSize;
    }
    p += 1;
    }

    /*
     * Now suck up the digits in the mantissa.  Use two integers to
     * collect 9 digits each (this is faster than using floating-point).
     * If the mantissa has more than 18 digits, ignore the extras, since
     * they can't affect the value anyway.
     */

    pExp  = p;
    p -= mantSize;
    if (decPt < 0) {
    decPt = mantSize;
    } else {
    mantSize -= 1;          /* One of the digits was the point. */
    }
    if (mantSize > 18) {
    fracExp = decPt - 18;
    mantSize = 18;
    } else {
    fracExp = decPt - mantSize;
    }
    if (mantSize == 0) {
    fraction = 0.0;
    p = string;
    goto done;
    } else {
    long frac1, frac2;
    frac1 = 0;
    for ( ; mantSize > 9; mantSize -= 1)
    {
        c = *p;
        p += 1;
        if (c == '.') {
        c = *p;
        p += 1;
        }
        frac1 = 10*frac1 + (c - '0');
    }
    frac2 = 0;
    for (; mantSize > 0; mantSize -= 1)
    {
        c = *p;
        p += 1;
        if (c == '.') {
        c = *p;
        p += 1;
        }
        frac2 = 10*frac2 + (c - '0');
    }
    fraction = (1.0e9 * frac1) + frac2;
    }

    /*
     * Skim off the exponent.
     */

    p = pExp;
    if ((*p == 'E') || (*p == 'e')) {
    p += 1;
    if (*p == '-') {
        expSign = TRUE;
        p += 1;
    } else {
        if (*p == '+') {
        p += 1;
        }
        expSign = FALSE;
    }
    if (!ISDIGIT((unsigned char)*p)) {
        p = pExp;
        goto done;
    }
    while (ISDIGIT((unsigned char)*p)) {
        exp = exp * 10 + (*p - '0');
        p += 1;
    }
    }
    if (expSign) {
    exp = fracExp - exp;
    } else {
    exp = fracExp + exp;
    }

    /*
     * Generate a floating-point number that represents the exponent.
     * Do this by processing the exponent one bit at a time to combine
     * many powers of 2 of 10. Then combine the exponent with the
     * fraction.
     */

    if (exp < 0) {
    expSign = TRUE;
    exp = -exp;
    } else {
    expSign = FALSE;
    }
    if (exp > maxExponent) {
    exp = maxExponent;
    errno = ERANGE;
    }
    dblExp = 1.0;
    for (d = powersOf10; exp != 0; exp >>= 1, d += 1) {
    if (exp & 01) {
        dblExp *= *d;
    }
    }
    if (expSign) {
    fraction /= dblExp;
    } else {
    fraction *= dblExp;
    }

done:
    if (endPtr != NULL) {
    *endPtr = (char *) p;
    }

    if (sign) {
    return -fraction;
    }
    return fraction;
}
