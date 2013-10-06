
/***************************************************************************

    XPRINT.C

    - integer only printf routines, print() and sprint()
    - based on code in the Megamax C library

    created 12/26/88

    updated 12/29/88 15:30

***************************************************************************/

#include <osbind.h>


long quotient, remainder;

_ldiv(divisor, dividend)
long   dividend, divisor;
{
    int    negate;

    asm {
           movem.l D0-D3, -(A7)
           move.l  divisor(A6), D2
      ok:
           move.l  dividend(A6), D1
           clr.w   negate(A6)
           tst.l   D1
           bge     skip1
           addq.w  #3, negate(A6)
           neg.l   D1
      skip1:   tst.l   D2
           bge     skip2
           addq.w  #1, negate(A6)
           neg.l   D2
      skip2:
           moveq   #1, D3
      rotate:  cmp.l   D1, D2
           bcc     endrot
           asl.l   #1, D2
           asl.l   #1, D3
           bra     rotate
      endrot:
           clr.l   D0
      dodiv:   cmp.l   D1, D2
           bhi     nosub
           or.l    D3, D0
           sub.l   D2, D1
      nosub:
           lsr.l   #1, D2
           lsr.l   #1, D3
           bcc     dodiv
           cmpi.w  #3, negate(A6)
           blt     posrem
           neg.l   D1
      posrem:  lsr.w   negate(A6)
           bcc     dontneg
           neg.l   D0
      dontneg:
           move.l  D0,divisor(A6)
           move.l  D0,quotient
           move.l  D1,dividend(A6)
           move.l  D1,remainder
           movem.l (A7)+, D0-D3
    }
}

#ifdef UNUSED
_uldiv(divisor, dividend)
long   dividend, divisor;
{
    asm {
           movem.l D0-D3, -(A7)
           move.l  divisor(A6), D2
           bne     ok
           divu    #0, D0   ;divide by zero error
           clr.l   D0       ;for debugging lets return something
           clr.l   D1
           bra     dontneg
      ok:
           move.l  dividend(A6), D1
           clr.l   D0
           moveq   #1, D3
      rotate:  cmp.l   D1, D2
           bcc     dodiv
           asl.l   #1, D2
           bcc     keepgoing
           roxr.l  #1, D2
           bra     dodiv
      keepgoing:
           asl.l   #1, D3
           bra     rotate

      dodiv:   cmp.l   D1, D2
           bhi     nosub
           or.l    D3, D0
           sub.l   D2, D1
      nosub:
           lsr.l   #1, D2
           lsr.l   #1, D3
           bcc     dodiv
      dontneg:
           move.l  D0, divisor(A6)
           move.l  D1, dividend(A6)
           movem.l (A7)+, D0-D3
    }
}
#endif

static nconv(type, size, s, val)
int type;
int size; /* 1=long, 0=int */
register char **s;
register long val;
    {
    int stack[40];
    register int sp = 0;
    register int base;

    switch ((int)type)
        {
    default:
    case 'd':
        base = 10;
        break;

    case 'u':
        base = 10;
        break;

    case 'o':
        base = 8;
        break;

    case 'x':
        base = 16;
        }

    if (val < 0)
        {
        if (type == 'd')
            {
            *(*s)++ = '-';
            val = -val;
            }
        else if (!size)
            val &= 0x0000ffffL;
        }

    do
        {
        stack[sp++] = base == 8 ? val&7 : base == 16 ? val&15 :
            val % base;
        val = base == 8 ? val>>3&0x1fffffff : base == 16 ? val>>4&0xfffffff :
            quotient;
        } while (val);

    while (sp)
        *(*s)++ = stack[--sp] >= 10 ? stack[sp]-10+'A' : stack[sp]+'0';
    }


static int _digits(ppch)
register char **ppch;
    {
    register char *pch = *ppch;
    register int result = 0;

    while (*pch >= '0' && *pch <= '9')
        {
        result = result*10 + *pch++ - '0';
        }

    *ppch = pch;
    return result;
    }


static int _sprint(s, args)
register char *s;
register char *args;
    {
    char *stemp;        /* we cant take address of s */
    register char *format;
    char *starts, *field, *str, *temp, pad;
    register int convchar;
    int left, minimum, prec, longitem;
    register int i;
    register char ch;

    starts = s;     /* save start ptr so length can be easily computed */
    format = *(char **)args;
    args += sizeof format;
    while (*format)
        {
        while ((ch = *format) && (ch != '%'))
            {
            if (ch == '\n')     /* convert LF to CRLF */
                *s++ = '\r';
            *s++ = *format++;
            }

        if (ch == '%')
            {
            format++;
            left = 0;
            prec = 256;
            longitem = 0;
            pad = ' ';

            if (*format == '-')
                {
                left = 1;
                format++;
                }

            if (*format == '0')
                {
                pad = '0';
                format++;
                }

            temp = format;
            minimum = _digits(&temp);
            format = temp;

            if (*format == '.')
                {
                format++;
                temp = format;
                prec = _digits(&temp);
                format = temp;
                }

            if (*format == 'l')
                {
                longitem = 1;
                format++;
                }

            if (*format)
                convchar = *format++;

            field = s;    /* start of field */

            if (convchar == 'd' || convchar == 'o' ||
                convchar == 'x' || convchar == 'u')
                {
                stemp = s;
                nconv(convchar, longitem, &stemp,
                    (long)(longitem ? *(long *)args : (long)*(int *)args));
                s = stemp;
                args += longitem ? sizeof(long) : sizeof(int);
                }

            else if (convchar == 'c')
                {
                *s++ = *(args+1);
                args += sizeof(int);
                }

            else if (convchar == 's')
                {
                str = *(char **)args;
                args += sizeof str;
                for (i=prec; i && *str; i--)
                    *s++ = *str++;
                }
            else
                *s++ = convchar;    /* something like %% */

            if (s-field < minimum)    /* must justify field */
                {
                if (left)
                    {
                    for (i = minimum-(s-field); i; i--)
                        *s++ = pad;
                    }
                else
                    {
                    temp = str = field + (minimum - 1);

                    for (i = s-field; i; i--)
                        *str-- = *(field+(i-1));

                    while (field <= str)
                        *field++ = pad;

                    s = temp+1;
                    }
                }
            }
        }
    *s = 0;    /* terminate with a null */
    return s - starts;
    }


int print(args)
int args;
    {
    char rgch[512];

    _sprint(rgch, &args);
    Cconws(rgch);
    }


int sprint(s, args)
char *s;
int args;
    {
    _sprint(s, &args);
    }

