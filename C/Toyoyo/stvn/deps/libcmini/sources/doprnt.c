/*
 * doprnt.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <stdarg.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <ctype.h>
#include "lib.h"

/*
 * Lexical definitions.
 *
 * All lexical space is allocated dynamically.
 * The eighth/sixteenth bit of characters is used to prevent recognition,
 * and eventually stripped.
 */
#define UNLIMITED                 -1
#define PRINTF_BUFFER_SIZE        128

#define DEFAULT_DIGITS_REMAINDER  6
#define MAX_DIGITS_REMAINDER      10
#define MULTI_REMAINDER           10e9


#ifndef ONLY_INTEGER_IO
static int normalize_float(double* valptr, int round_to, int eformat);
#endif /* ONLY_INTEGER_IO */


#ifndef TRUE
#   define TRUE   1
#   define FALSE  0
#endif


#define ISDIGIT(c)  ((c) >= '0' && (c) <= '9')
#define ISUPPER(c)  ((c) >= 'A' && (c) <= 'Z')
#define ISLOWER(c)  ((c) >= 'a' && (c) <= 'z')


int
doprnt(int (*addchar)(int, void*), void* stream, const char* sfmt, va_list ap)
{
    enum { INT_VAL, LONG_VAL, LONG_LONG_VAL };

    int  fmt;
    char pad           = ' ';
    int  flush_left    = FALSE;
    int  field_width   = 0;
    int  precision     = UNLIMITED;
    int  hash          = FALSE;
    char space_or_sign = '\0';
    int  do_long       = INT_VAL;
    int  negative      = FALSE;
    int  attributes    = 0;
    int  count         = 0;

    register const char* f;

    for (f = sfmt; *f != '\0'; ++f) {
        if (*f != '%') {
            /* then just out the char */
            count += addchar(attributes | (unsigned char)*f, stream);
        } else {
            char  buf[PRINTF_BUFFER_SIZE];
            char* bufptr;

        #ifndef ONLY_INTEGER_IO
            double floatval;
        #endif /* ONLY_INTEGER_IO */

            long          longval;
            unsigned long ulongval;

        #ifdef STDIO_WITH_LONG_LONG
            long long          longlongval;
            unsigned long long ulonglongval;
        #endif /* STDIO_WITH_LONG_LONG */

            int flag_found;

            ++f; /* skip the % */

            do {
                flag_found = TRUE;

                switch (*f) {
                    case '-':
                        /* minus: flush left */
                        flush_left = TRUE;
                        break;

                    case '+':
                        /* plus: numbers always with sign */
                        space_or_sign = '+';
                        break;

                    case ' ':
                        /* space: numbers without sign start with space */
                        space_or_sign = ' ';
                        break;

                    case '0':
                        /* padding with 0 rather than blank */
                        pad = '0';
                        break;

                    case '#':
                        /* alternate form */
                        hash = TRUE;
                        break;

                    default:
                        flag_found = FALSE;
                        break;

                }

                if (flag_found) {
                    ++f;
                }
            } while (flag_found);

            if (*f == '*') {
                /* field width */
                field_width = va_arg(ap, int);

                if (field_width < 0) {
                    flush_left  = TRUE;
                    field_width = -field_width;
                }

                ++f;
            } else {
                while (ISDIGIT(*f)) {
                    /* skip the digits */
                    field_width = field_width * 10 + *f++ - '0';
                }
            }

            if (*f == '.') {
                /* precision */
                ++f;

                if (*f == '*') {
                    precision = va_arg(ap, int);
                    ++f;
                } else if (ISDIGIT(*f)) {
                    precision = atoi(f);

                    while (ISDIGIT(*f)) {
                        /* skip the digits */
                        ++f;
                    }
                }
            }

            if (*f == 'l') {
                /* long format */
                ++do_long;
                ++f;

                if (*f == 'l') {
                    /* long long format */
                    ++do_long;
                    ++f;
                }
            }

            fmt = (unsigned char)*f;

            if (fmt != 'S' && fmt != 'Q' && fmt != 'X' && fmt != 'E' && fmt != 'G' && ISUPPER(fmt)) {
                do_long = LONG_VAL;
                fmt    |= 0x20 /* tolower */;
            }

            bufptr = buf;

            switch (fmt) {
                /* do the format */
                case 'i':
                case 'd':
                    switch (do_long) {
                        case INT_VAL:
                            longval = (long)va_arg(ap, int);
                            break;

#ifdef STDIO_WITH_LONG_LONG

                        case LONG_LONG_VAL:
                            longlongval = va_arg(ap, long long);

                            if (longlongval > LONG_MAX || longlongval < LONG_MIN) {
                                /* use 64 bit arithmetic only if needed */

                                if (longlongval < 0) {
                                    negative    = TRUE;
                                    longlongval = -longlongval;
                                }

                                do {
                                    *bufptr++    = (longlongval % 10) + '0';
                                    longlongval /= 10;
                                } while (longlongval > 0);

                                longval = 0;
                            } else {
                                longval = longlongval;
                            }

                            break;

#endif /* STDIO_WITH_LONG_LONG */

                        case LONG_VAL:
                        default:
                            longval = va_arg(ap, long);
                            break;

                    }

                    if (bufptr == buf) {
                        /** we have to use unsigned, because a signed value of 0x80000000
                         *  represents a decimal value of -2147483648 which cannot be
                         *  stored as a positive value of 2137483648 into a signed variable
                         */

                        unsigned long ulongval;

                        if (longval < 0) {
                            negative = TRUE;
                            ulongval = -longval;
                        } else {
                            ulongval = longval;
                        }

                        do {
                            *bufptr++ = (ulongval % 10) + '0';
                            ulongval  /= 10;
                        } while (ulongval > 0);
                    }

                    {
                        int num_zeros;
                        int num_blanks;
                        int sign_extra;

                        if (precision > 0) {
                            num_zeros  = precision;
                            num_blanks = field_width - num_zeros;
                            sign_extra = TRUE;
                            pad        = ' ';

                            if (num_blanks < 0) {
                                num_blanks = 0;
                            }
                        } else {
                            if (pad == '0') {
                                num_zeros  = field_width;
                                num_blanks = 0;
                            } else {
                                num_zeros  = 0;
                                num_blanks = field_width;
                            }

                            sign_extra = FALSE;
                        }

                        field_width = num_zeros + num_blanks;
                        num_zeros  -= (int)(bufptr - buf);

                        if (num_zeros > 0) {
                            pad = '0';
                        }

                        if ((flush_left && precision <= 0) || num_zeros <= 0) {
                            if (negative) {
                                *bufptr++ = '-';
                                negative = FALSE;
                            } else if (space_or_sign != '\0') {
                                *bufptr++ = space_or_sign;
                            }
                        } else {
                            char* signptr;

                            while (num_zeros > 0) {
                                *bufptr++ = pad;

                                if (--num_zeros == 0) {
                                    pad = ' ';
                                }
                            }

                            signptr = sign_extra ? bufptr : (bufptr - 1);

                            if (negative) {
                                *signptr++ = '-';
                                negative = FALSE;
                            } else if (space_or_sign != '\0') {
                                *signptr++ = space_or_sign;
                            }

                            if (sign_extra) {
                                bufptr = signptr;
                            }
                        }

                        field_width -= (int)(bufptr - buf);

                        if (!flush_left) {
                            while (field_width-- > 0) {
                                count += addchar(attributes | (unsigned char)pad, stream);
                            }
                        }

                        for (--bufptr; bufptr >= buf; --bufptr) {
                            count += addchar(attributes | (unsigned char)*bufptr, stream);
                        }

                        if (flush_left) {
                            while (field_width-- > 0) {
                                count += addchar(attributes | ' ', stream);
                            }
                        }
                    }

                    break;

                case 'f':
                case 'e':
                case 'E':
                case 'g':
                case 'G':

#ifdef ONLY_INTEGER_IO

                    {
                        static const char *p = ")taolf(";

                        do {
                            *bufptr++ = *p++;
                        } while (*p != '\0');

                        pad = ' ';

                        (void)va_arg(ap, double);

#else

                    /* this is actually more than stupid, but does work for now */
                    floatval = va_arg(ap, double); /* beware: va_arg() extends float to double! */

                    if (floatval < 0) {
                        negative = TRUE;
                        floatval = -floatval;
                    }

                    {
                        char   tmpbuf[PRINTF_BUFFER_SIZE];
                        char*  tmpbufptr;
                        int    exponent;
                        int    use_exp_format = FALSE;
                        double floatvalbak = floatval;

                        if (precision == UNLIMITED) {
                            precision = DEFAULT_DIGITS_REMAINDER;
                        } else if (precision > MAX_DIGITS_REMAINDER) {
                            precision = MAX_DIGITS_REMAINDER;
                        }

                        exponent = normalize_float(&floatval, precision, (fmt | 0x20 /* tolower */) == 'e');

                        switch (tolower(fmt)) {
                            case 'e':
                                use_exp_format = TRUE;
                                break;

                            case 'g':
                                if (exponent < -4 || exponent >= precision) {
                                    use_exp_format = TRUE;
                                    floatval       = floatvalbak;
                                    exponent       = normalize_float(&floatval, precision, 1);
                                }

                                break;

                            default:
                                break;

                        }

                        tmpbufptr = tmpbuf;

                        if (use_exp_format) {
                            int digit = (int)(floatval * 10.0);
                            int count_nonzero;

                            if (digit == 10) {
                                digit     = 1;
                                floatval /= 10.0;
                                ++exponent;
                            }

                            *tmpbufptr = digit + '0';

                            if (*tmpbufptr++ == '0') {
                                count_nonzero = 0;
                            } else {
                                count_nonzero = 1;
                            }

                            floatval = floatval * 10.0 - (double)digit;
                            --exponent;

                            if (precision > 0 || hash) {
                                register int i;

                                *tmpbufptr++ = '.';

                                for (i = 0; i < precision; ++i) {
                                    int digit = (int)(floatval * 10.0);

                                    if (digit == 10) {
                                        digit     = 1;
                                        floatval /= 10.0;
                                        ++exponent;
                                    }

                                    *tmpbufptr = digit + '0';

                                    if (*tmpbufptr++ != '0') {
                                        ++count_nonzero;
                                    }

                                    floatval = floatval * 10.0 - (double)digit;
                                }
                            }

                            *tmpbufptr++ = ISLOWER(fmt) ? 'e' : 'E';

                            if (exponent < 0 && count_nonzero > 0) {
                                *tmpbufptr++ = '-';
                                exponent     = -exponent;
                            } else {
                                *tmpbufptr++ = '+';

                                if (exponent < 0) {
                                    exponent = 0;
                                }
                            }

                            if (exponent < 10) {
                                *tmpbufptr++ = '0';
                            }

                            do {
                                *tmpbufptr++ = '0' + (exponent % 10);
                                exponent    /= 10;
                            } while (exponent > 0);
                        } else {
                            int places = 0;

                            while (exponent > 0) {
                                int digit = (int)(floatval * 10.0);

                                if (digit == 10) {
                                    digit     = 1;
                                    floatval /= 10.0;
                                    ++exponent;
                                }

                                *tmpbufptr++ = digit + '0';
                                floatval     = floatval * 10.0 - (double)digit;

                                --exponent;
                                ++places;
                            }

                            if (places == 0) {
                                *tmpbufptr++ = '0';
                            }

                            if (hash || precision > 0) {
                                *tmpbufptr++ = '.';
                                places       = 0;

                                while (exponent < 0 && places < precision) {
                                    *tmpbufptr++ = '0';
                                    ++exponent;
                                    ++places;
                                }

                                while (places < precision) {
                                    int digit = (int)(floatval * 10.0);

                                    if (digit == 10) {
                                        digit     = 1;
                                        floatval /= 10.0;
                                        ++exponent;
                                    }

                                    *tmpbufptr++ = digit + '0';
                                    floatval     = floatval * 10.0 - (double)digit;
                                    ++places;
                                }
                            }
                        }

                        while (tmpbufptr > tmpbuf) {
                            *bufptr++ = *--tmpbufptr;
                        }

                        if (flush_left || pad != '0') {
                            if (negative) {
                                *bufptr++ = '-';
                            } else if (space_or_sign != '\0') {
                                *bufptr++ = space_or_sign;
                            }
                        }

#endif /* ONLY_INTEGER_IO */

                        field_width -= (int)(bufptr - buf);

                        if (!flush_left) {
                            if (negative && pad == '0') {
                                count += addchar(attributes | '-', stream);
                                --field_width;
                            }

                            while (field_width-- > 0) {
                                count += addchar(attributes | (unsigned char)pad, stream);
                            }
                        }

                        for (--bufptr; bufptr >= buf; --bufptr) {
                            count += addchar(attributes | (unsigned char)*bufptr, stream);
                        }

                        if (flush_left) {
                            while (field_width-- > 0) {
                                count += addchar(attributes | ' ', stream);
                            }
                        }
                    }

                    break;

                case 'p':
                    do_long = LONG_VAL;
                    hash    = TRUE;
                    fmt     = 'x';
                    /* no break */

                case 'o':
                case 'x':
                case 'X':
                case 'u':
                    {
                        const char* numbers = "0123456789abcdef";
                        const char* prefix = NULL;
                        int len_prefix = 0;

                        switch (do_long) {
                            case INT_VAL:
                                ulongval = (unsigned long)va_arg(ap, unsigned int);
                                break;

#ifdef STDIO_WITH_LONG_LONG

                            case LONG_LONG_VAL:
                                ulonglongval = va_arg(ap, unsigned long long);

                                if(ulonglongval > ULONG_MAX) {
                                    /* use 64 bit arithmetic only if needed */
                                    unsigned long long base;

                                    switch (fmt) {
                                        case 'u':
                                        default:
                                            base = 10;
                                            break;

                                        case 'o':
                                            base = 010;
                                            break;

                                        case 'X':
                                            numbers = "0123456789ABCDEF";

                                        case 'x':
                                            base = 0x10;
                                            break;

                                    }

                                    if (ulonglongval == 0) {
                                        /* no prefix if value is 0 */
                                        hash = FALSE;
                                    }

                                    do {
                                        *bufptr++     = numbers[ulonglongval % base];
                                        ulonglongval /= base;
                                    } while (ulonglongval > 0);
                                } else {
                                    ulongval = (unsigned long)ulonglongval;
                                }

                                break;

#endif /* STDIO_WITH_LONG_LONG */

                            case LONG_VAL:
                            default:
                                ulongval = va_arg(ap, unsigned long);
                                break;

                        }

                        if (bufptr == buf) {
                            unsigned long base;

                            switch (fmt) {
                                case 'u':
                                default:
                                    base = 10;
                                    break;

                                case 'o':
                                    base = 010;
                                    break;

                                case 'X':
                                    numbers = "0123456789ABCDEF";

                                case 'x':
                                    base = 0x10;
                                    break;

                            }

                            if (ulongval == 0) {
                                /* no prefix if value is 0 */
                                hash = FALSE;
                            }

                            do {
                                *bufptr++ = numbers[ulongval % base];
                                ulongval /= base;
                            } while (ulongval > 0);
                        }

                        if(hash) {
                            switch (fmt) {
                                case 'X':
                                case 'x':
                                    prefix = "x0";
                                    *(char*)prefix = fmt;
                                    len_prefix = 2;
                                    break;

                                case 'o':
                                    prefix = "0";
                                    len_prefix = 1;
                                    break;

                                default:
                                    break;

                            }
                        }

                        {
                            int num_zeros;
                            int num_blanks;

                            if (precision > 0) {
                                num_zeros  = precision;
                                num_blanks = field_width - num_zeros;
                                pad        = ' ';

                                if (num_blanks < 0) {
                                    num_blanks = 0;
                                }
                            } else {
                                if (pad == '0' && !flush_left) {
                                    num_zeros  = field_width;
                                    num_blanks = 0;
                                } else {
                                    num_zeros  = 0;
                                    num_blanks = field_width;
                                }
                            }

                            field_width = num_zeros + num_blanks;
                            num_zeros  -= (int)(bufptr - buf);

                            if (prefix != NULL && (fmt == 'o' || pad == '0')) {
                                if (num_zeros > 0) {
                                    num_zeros -= len_prefix;

                                    if (num_blanks > 0) {
                                        ++num_blanks;
                                    }
                                }
                            }

                            if (num_zeros > 0) {
                                pad = '0';

                                while (num_zeros-- > 0) {
                                    *bufptr++ = pad;

                                    if (num_zeros == 0) {
                                        pad = ' ';

                                        if (prefix != NULL) {
                                            do {
                                                *bufptr++ = *prefix++;
                                            } while (*prefix != '\0');
                                        }
                                    }
                                }
                            } else if (prefix != NULL) {
                                do {
                                    *bufptr++ = *prefix++;
                                } while (*prefix != '\0');
                            }

                            field_width -= (int)(bufptr - buf);

                            if (!flush_left) {
                                while (field_width-- > 0) {
                                    count += addchar(attributes | (unsigned char)pad, stream);
                                }
                            }

                            for (--bufptr; bufptr >= buf; --bufptr) {
                                count += addchar(attributes | (unsigned char)*bufptr, stream);
                            }

                            if (flush_left) {
                                while (field_width-- > 0) {
                                    count += addchar(attributes | ' ', stream);
                                }
                            }
                        }
                    }

                    break;

                case 'c':
                    {
                        int ch = va_arg(ap, int);

                        if (ch != '\0') {
                            --field_width;
                        }

                        if (!flush_left) {
                            while (field_width-- > 0) {
                                count += addchar(attributes | (unsigned char)pad, stream);
                            }
                        }

                        count += addchar(attributes | ch, stream);

                        if (flush_left) {
                            while (field_width-- > 0) {
                                count += addchar(attributes | ' ', stream);
                            }
                        }
                    }

                    break;

                case 'S':
                case 's':
                    {
                        register int i;

                        bufptr = va_arg(ap, char*);

                        if (bufptr == NULL) {
                            bufptr = "(nil)";
                        }

                        field_width -= (int)strlen(bufptr);

                        if (!flush_left) {
                            while (field_width-- > 0) {
                                count += addchar(attributes | (unsigned char)pad, stream);
                            }
                        }

                        for (i = 0; *bufptr != '\0' && (precision == UNLIMITED || i < precision); ++i) {
                            count += addchar(attributes | (unsigned char)*bufptr++, stream);
                        }

                        if (flush_left) {
                            while (field_width-- > 0) {
                                count += addchar(attributes | ' ', stream);
                            }
                        }
                    }

                    break;

                case '%':
                    count += addchar(attributes | '%', stream);
                    break;

                default:
                    break;

            }

            flush_left    = FALSE;
            field_width   = 0;
            precision     = UNLIMITED;
            hash          = FALSE;
            do_long       = INT_VAL;
            space_or_sign = '\0';
            negative      = FALSE;
            pad           = ' ';
        }
    }

    return count;
}


#ifndef ONLY_INTEGER_IO

int
normalize_float(double* valptr, int round_to, int eformat)
{
    double round;
    double floatval = *valptr;
    int    exponent = 0;

    for (round = 0.5; round_to > 0; --round_to) {
        round *= 0.1;
    }

    if (eformat) {
        round *= 0.1;
    }

    while (floatval >= 1.0) {
        floatval *= 0.1;

        if (!eformat) {
            round *= 0.1;
        }

        ++exponent;
    }

    if (floatval > 0.0) {
        while (floatval < 0.1) {
            floatval *= 10.0;

            if (!eformat) {
                round *= 10.0;
            }

            --exponent;
        }
    }

    *valptr = floatval + round;

    return exponent;
}

#endif /* ONLY_INTEGER_IO */
