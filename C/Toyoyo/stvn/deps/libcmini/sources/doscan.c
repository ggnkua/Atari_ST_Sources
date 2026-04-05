/*
 * doscan.c
 *
 *  Created on: 26.07.2017
 *      Author: og
 */

#include <stdarg.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <ctype.h>
#include "lib.h"


#define UNLIMITED          -1
#define SCANF_BUFFER_SIZE  512


#ifndef TRUE
#   define TRUE   1
#   define FALSE  0
#endif


#define ISDIGIT(c)   ((c) >= '0' && (c) <= '9')
#define ISXDIGIT(c)  (ISDIGIT(c) || ((c) >= 'A' && (c) <= 'F') || ((c) >= 'a' && (c) <= 'f'))


int
doscan(int (*getchar_func)(void*), int (*ungetchar_func)(int, void*), void* stream, const char* sfmt, va_list ap)
{
    int  suppress       = FALSE;
    int  maxlen         = 0;
    int  do_long        = 0;
    int  do_short       = 0;
    int  do_long_double = FALSE;
    int  num            = 0;
    int  num_chars      = 0;
    char ch             = '\0';
    char keepch         = '\0';
    int  error          = FALSE;

    register const char* f;

    for (f = sfmt ; *f != '\0' && ch != EOF && !error; ++f) {
        if (isspace(*f)) {
            /* skip whitespace characters */
            if (keepch != '\0' && !isspace(keepch)) {
                /* buffered character is not a whitespace -> skip */
                continue;
            }

            keepch = '\0';

            do {
                ch = getchar_func(stream);
                ++num_chars;
            } while (ch != EOF && isspace(ch));

            if (ch == EOF) {
                /* end of stream */
                break;
            } else {
                /* move char to buffer */
                keepch = ch;
            }
        } else if (*f != '%') {
            /* then just get the char */
            if (keepch != '\0') {
                ch     = keepch;
                keepch = '\0';
            } else {
                ch = getchar_func(stream);
                ++num_chars;
            }

            if (ch == EOF || ch != *f) {
                error = TRUE;
            }
        } else {
            /* skip the % */
            ++f;

            if (*f == '%') {
                /* read literal % */
                if (keepch != '\0') {
                    ch     = keepch;
                    keepch = '\0';
                } else {
                    ch = getchar_func(stream);
                    ++num_chars;
                }

                if (ch == EOF || ch != *f) {
                    error = TRUE;
                }
            } else if (*f != '\0') {
                char fmt;

                if (*f == '*') {
                    /* asterisk: suppress */
                    suppress = TRUE;
                    ++f;
                }

                if (ISDIGIT(*f)) {
                    maxlen = atoi(f);

                    while (ISDIGIT(*f)) {
                        ++f; /* skip the digits */
                    }
                }

                switch (*f) {
                    case 'l':
                        /* long format */
                        ++do_long;
                        ++f;

                        if (*f == 'l') {
                            ++do_long;
                            ++f;
                        }

                        break;

                    case 'h':
                        /* short format */
                        ++do_short;
                        ++f;

                        if (*f == 'h') {
                            ++do_short;
                            ++f;
                        }

                        break;

                    case 'L':
                        /* long double format */
                        do_long_double = TRUE;
                        ++f;
                        break;

                    default:
                        break;

                }

                if (maxlen == 0) {
                    maxlen = UNLIMITED;
                }

                fmt = *f;

                if (fmt == 'A' || fmt == 'E' || fmt == 'F' || fmt == 'G' || fmt == 'X') {
                    fmt |= 0x20; /* tolower */
                }

                switch (fmt) { /* do the format */
                    case 'n':
                        if (!suppress) {
                            int* int_ptr = va_arg(ap, int*);

                            *int_ptr = num_chars;

                            if (keepch != '\0') {
                                --*int_ptr;
                            }

                            ++num;
                        }

                        break;

                    case 'i':
                    case 'd':
                    case 'u':
                    case 'o':
                    case 'x':
                    case 'p':
                        {
                            char buf[SCANF_BUFFER_SIZE];
                            int  bufsize;
                            int  negative    = FALSE;
                            int  is_unsigned = FALSE;
                            int  base;

                            switch (fmt) {
                                case 'i':
                                    base = 0;
                                    break;

                                case 'u':
                                    base = 10;
                                    is_unsigned = TRUE;
                                    break;

                                case 'o':
                                    base = 010;
                                    is_unsigned = TRUE;
                                    break;

                                case 'x':
                                case 'p':
                                    base = 0x10;
                                    is_unsigned = TRUE;
                                    break;

                                case 'd':
                                default:
                                    base = 10;
                                    break;

                            }

                            if (keepch != '\0') {
                                ch     = keepch;
                                keepch = '\0';
                            } else {
                                ch = getchar_func(stream);
                                ++num_chars;
                            }

                            while (isspace(ch)) {
                                ch = getchar_func(stream);
                                ++num_chars;
                            }

                            buf[0]  = '\0';
                            bufsize = 0;

                            if (ch == '-') {
                                negative = TRUE;

                                if (bufsize < SCANF_BUFFER_SIZE - 1) {
                                    buf[bufsize++] = ch;
                                }

                                ch = getchar_func(stream);
                                ++num_chars;

                                if (maxlen != UNLIMITED) {
                                    --maxlen;
                                }
                            }

                            if (maxlen == 0 || (negative && is_unsigned)) {
                                error = TRUE;
                            } else {
                                int any_digit = FALSE;
                                int pos       = 0;

                                while (bufsize < SCANF_BUFFER_SIZE - 1 && maxlen != 0) {
                                    --maxlen;

                                    if ((base == 0 || base == 010 || base == 0x10) && pos == 0 && ch == '0') {
                                        if (base == 0) {
                                            base = 010;
                                        }
                                    } else if (!any_digit && (base == 010 || base == 0x10) && pos == 1 && (ch | 0x20 /* tolower */) == 'x') {
                                        base = 0x10;
                                    } else if (base == 0x10 && !ISXDIGIT(ch)) {
                                        break;
                                    } else if (base == 010 && (ch < '0' || ch > '7')) {
                                        break;
                                    } else if (base == 10 && !ISDIGIT(ch)) {
                                        break;
                                    } else {
                                        any_digit = TRUE;

                                        buf[bufsize++] = ch;
                                    }

                                    ch = getchar_func(stream);
                                    ++num_chars;
                                    ++pos;
                                }

                                if (any_digit) {
                                    buf[bufsize] = '\0';
                                } else {
                                    error = TRUE;
                                }
                            }

                            if (!error) {
                                if (!suppress) {
                                    if (fmt == 'p') {
                                        /* pointer */
                                        void** void_ptr = va_arg(ap, void**);
                                        *void_ptr = (void*)strtoul(buf, NULL, base);
                                    } else if (do_long == 0 && do_short == 0) {
                                        if (is_unsigned) {
                                            unsigned int* uint_ptr = va_arg(ap, unsigned int*);
                                            *uint_ptr = (unsigned int)strtoul(buf, NULL, base);
                                        } else {
                                            int* int_ptr = va_arg(ap, int*);
                                            *int_ptr = (int)strtol(buf, NULL, base);
                                        }
                                    } else if (do_long > 0) {
                                        switch (do_long) {

#if defined(STDIO_WITH_LONG_LONG) && (__STDC_VERSION__ >= 199901L)

                                            case 2:
                                                if (is_unsigned) {
                                                    unsigned long long* ulong_long_ptr = va_arg(ap, unsigned long long*);
                                                    *ulong_long_ptr = strtoull(buf, NULL, base);
                                                } else {
                                                    long long* long_long_ptr = va_arg(ap, long long*);
                                                    *long_long_ptr = strtoll(buf, NULL, base);
                                                }

                                                break;

#endif

                                            case 1:
                                            default:
                                                if (is_unsigned) {
                                                    unsigned long* ulong_ptr = va_arg(ap, unsigned long*);
                                                    *ulong_ptr = strtoul(buf, NULL, base);
                                                } else {
                                                    long* long_ptr = va_arg(ap, long*);
                                                    *long_ptr = strtol(buf, NULL, base);
                                                }

                                                break;

                                        }
                                    } else if (do_short > 0) {
                                        switch (do_short) {
                                            case 2:
                                                if (is_unsigned) {
                                                    unsigned char* uchar_ptr = va_arg(ap, unsigned char*);
                                                    *uchar_ptr = (unsigned char)strtoul(buf, NULL, base);
                                                } else {
                                                    char* char_ptr = va_arg(ap, char*);
                                                    *char_ptr = (char)strtol(buf, NULL, base);
                                                }

                                                break;

                                            case 1:
                                            default:
                                                if (is_unsigned) {
                                                    unsigned short int* ushort_ptr = va_arg(ap, unsigned short int*);
                                                    *ushort_ptr = (unsigned short int)strtoul(buf, NULL, base);
                                                } else {
                                                    short int* short_ptr = va_arg(ap, short int*);
                                                    *short_ptr = (short int)strtol(buf, NULL, base);
                                                }

                                                break;

                                        }
                                    }

                                    ++num;
                                }

                                if (ch != EOF) {
                                    keepch = ch;
                                }
                            }
                        }

                        break;

                    case 'c':
                        if (keepch != '\0') {
                            ch     = keepch;
                            keepch = '\0';
                        } else {
                            ch = getchar_func(stream);
                            ++num_chars;
                        }

                        if (ch != EOF) {
                            char* char_ptr = suppress ? NULL : va_arg(ap, char*);

                            if (maxlen == UNLIMITED) {
                                maxlen = 1;
                            }

                            do {
                                if (char_ptr != NULL) {
                                    *char_ptr++ = ch;
                                }

                                if (maxlen > 0) {
                                    --maxlen;
                                }

                                if (maxlen != 0) {
                                    ch = getchar_func(stream);
                                    ++num_chars;
                                }
                            } while (ch != EOF && maxlen != 0);

                            if (!suppress) {
                                ++num;
                            }
                        } else {
                            error = TRUE;
                        }

                        break;

                    case 's':
                        {
                            char* dest = suppress ? NULL : va_arg(ap, char*);

                            if (keepch != '\0') {
                                ch     = keepch;
                                keepch = '\0';
                            } else {
                                ch = getchar_func(stream);
                                ++num_chars;
                            }

                            if (ch != EOF) {
                                do {
                                    if (dest != NULL) {
                                        *dest++ = ch;
                                    }

                                    if (maxlen > 0) {
                                        --maxlen;
                                    }

                                    if (maxlen != 0) {
                                        ch = getchar_func(stream);
                                        ++num_chars;
                                    }
                                } while (ch != EOF && maxlen != 0 && !isspace(ch));

                                if (dest != NULL) {
                                    *dest = '\0';
                                    ++num;
                                }
                            } else {
                                error = TRUE;
                            }
                        }

                        break;

                    case 'e':
                    case 'f':
                    case 'g':
                        {
                            char buf[SCANF_BUFFER_SIZE];
                            int  bufsize;
                            int  any_digit = FALSE;
                            int  decimal   = FALSE;
                            int  is_e      = FALSE;

                            if (keepch != '\0') {
                                ch     = keepch;
                                keepch = '\0';
                            } else {
                                ch = getchar_func(stream);
                                ++num_chars;
                            }

                            while (isspace(ch)) {
                                ch = getchar_func(stream);
                                ++num_chars;
                            }

                            buf[0] = '\0';
                            bufsize = 0;

                            while (bufsize < SCANF_BUFFER_SIZE - 1 && maxlen != 0) {
                                --maxlen;

                                if (bufsize == 0) {
                                    if (ch == '.') {
                                        decimal = TRUE;
                                    } else if (ch != '+' && ch != '-' && !ISDIGIT(ch)) {
                                        break;
                                    }
                                } else if (is_e) {
                                    if (ch == '+' || ch == '-') {
                                        if ((buf[bufsize] |= 0x20 /* tolower */) != 'e') {
                                            break;
                                        }
                                    } else if (!ISDIGIT(ch)) {
                                        break;
                                    }
                                } else if ((ch |= 0x20 /* tolower */) == 'e') {
                                    if (is_e) {
                                        break;
                                    } else {
                                        is_e = TRUE;
                                    }
                                } else if (ISDIGIT(ch)) {
                                    any_digit = TRUE;
                                } else if (ch == '.') {
                                    if (decimal) {
                                        break;
                                    } else {
                                        decimal = TRUE;
                                    }
                                } else {
                                    break;
                                }

                                buf[bufsize++] = ch;
                                ch             = getchar_func(stream);
                                ++num_chars;
                            }

                            if (is_e && (buf[bufsize] == '+' || buf[bufsize] == '-' || (buf[bufsize] | 0x20 /* tolower */) == 'e')) {
                                error = TRUE;
                            } else if (any_digit) {
                                buf[bufsize] = '\0';

                                if (!suppress) {
                                    if (do_long_double) {
                                        long double* long_double_ptr = va_arg(ap, long double*);

#if !defined(ONLY_INTEGER_IO) && (__STDC_VERSION__ >= 199901L)

                                        *long_double_ptr = strtold(buf, NULL);
#else
                                        *long_double_ptr = 0.0;
#endif /* ONLY_INTEGER_IO && __STDC_VERSION */

                                    } else if (do_long) {
                                        double* double_ptr = va_arg(ap, double*);

#ifndef ONLY_INTEGER_IO
                                        *double_ptr = strtod(buf, NULL);
#else
                                        *double_ptr = 0.0;
#endif /* ONLY_INTEGER_IO */

                                    } else {
                                        float* float_ptr = va_arg(ap, float*);

#ifndef ONLY_INTEGER_IO
                                        *float_ptr = (float)strtod(buf, NULL);
#else
                                        *float_ptr = 0.0;
#endif /* ONLY_INTEGER_IO */

                                    }

                                    ++num;
                                }

                                if (ch != EOF) {
                                    keepch = ch;
                                }
                            } else {
                                error = TRUE;
                            }
                        }

                        break;

                    case '[':
                        {
                            char  format[SCANF_BUFFER_SIZE];
                            int   formatsize;
                            int   reverse = FALSE;
                            char* dest    = suppress ? NULL : va_arg(ap, char*);

                            format[0] = '\0';
                            formatsize = 0;

                            if (*++f == '^') {
                                reverse = TRUE;
                                ++f;
                            }

                            if (*f == ']') {
                                format[0] = *f++;
                                ++formatsize;
                            }

                            while (*f != '\0' && *f != ']') {
                                if (formatsize < SCANF_BUFFER_SIZE - 1) {
                                    format[formatsize++] = *f;
                                }

                                ++f;
                            }

                            if (*f == '\0') {
                                error = TRUE;
                            } else {
                                format[formatsize] = '\0';
                                ++f;

                                if (keepch != '\0') {
                                    ch     = keepch;
                                    keepch = '\0';
                                } else {
                                    ch = getchar_func(stream);
                                    ++num_chars;
                                }

                                while (ch != EOF) {
                                    const char* match = strchr(format, ch);

                                    if (reverse) {
                                        if (match != NULL) {
                                            break;
                                        }
                                    } else {
                                        if (match == NULL) {
                                            break;
                                        }
                                    }

                                    if (dest != NULL) {
                                        *dest++ = ch;
                                    }

                                    ch = getchar_func(stream);
                                    ++num_chars;
                                }

                                if (!suppress) {
                                    *dest = '\0';
                                }

                                if (ch != EOF) {
                                    keepch = ch;
                                }
                            }
                        }
                        break;

                    default:
                        break;
                }

                maxlen         = 0;
                do_long        = 0;
                do_short       = 0;
                do_long_double = FALSE;
                suppress       = FALSE;
            }
        }
    }

    if (keepch != '\0' && ungetchar_func != NULL) {
        /* put last char back to stream */
        ungetchar_func(keepch, stream);
    }

    if (ch == EOF && num == 0) {
        num = EOF;
    }

    return num;
}
