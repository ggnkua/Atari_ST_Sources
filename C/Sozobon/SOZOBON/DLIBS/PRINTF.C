#include <stdio.h>
#include <ctype.h>

_printf(op, put, fmt, args)
	char *op;
	unsigned int (*put)();
	register unsigned char *fmt;
	register unsigned int *args;
	{
	register int i, cnt = 0, ljustf, lval;
	int preci, dpoint, width;
	char pad, sign, radix;
	register char *ptmp;
	char tmp[64], *ltoa(), *ultoa();
#if FLOATS
	double fx;
#endif

	while(*fmt)
		{
		if(*fmt == '%')
			{
			ljustf = FALSE;	/* left justify flag */
			sign = '\0';	/* sign char & status */
			pad = ' ';	/* justification padding char */
			width = -1;	/* min field width */
			dpoint = FALSE;	/* found decimal point */
			preci = -1;	/* max data width */
			radix = 10;	/* number base */
			ptmp = tmp;	/* pointer to area to print */
			lval = FALSE;	/* long value flaged */
fmtnxt:
			i = 0;
			while (isdigit(*++fmt))
				{
				i = (i * 10) + (*fmt - '0');
				if (dpoint)
					preci = i;
				else if (!i && (pad == ' '))
					{
					pad = '0';
					goto fmtnxt;
					}
				else
					width = i;
				}

			switch(*fmt)
				{
				case '\0':	/* early EOS */
					--fmt;
					goto charout;

				case '-':	/* left justification */
					ljustf = TRUE;
					goto fmtnxt;

				case ' ':
				case '+':	/* leading sign flag */
					sign = *fmt;
					goto fmtnxt;

				case '*':	/* parameter width value */
					i = *args++;
					if (dpoint)
						preci = i;
					else
						width = i;
					goto fmtnxt;

				case '.':	/* secondary width field */
					dpoint = TRUE;
					goto fmtnxt;

				case 'l':	/* long data */
					lval = TRUE;
					goto fmtnxt;

				case 'd':	/* Signed decimal */
				case 'i':
					ltoa((long)((lval)
						?(*((long *) args))
						:(*((int  *) args))),
					      ptmp, 10);
					if(lval)
						args = ((unsigned int *)
							(((long *) args) + 1));
					else
						args = ((unsigned int *)
							(((int *) args) + 1));
					goto printit;

				case 'b':	/* Unsigned binary */
					radix = 2;
					goto usproc;

				case 'o':	/* Unsigned octal */
					radix = 8;
					goto usproc;

				case 'p':	/* Pointer */
					lval = TRUE;
					pad = '0';
					width = 6;
					preci = 8;
					/* fall thru */

				case 'x':	/* Unsigned hexadecimal */
				case 'X':
					radix = 16;
					/* fall thru */

				case 'u':	/* Unsigned decimal */
usproc:
					ultoa((unsigned long)((lval)
						?(*((unsigned long *) args))
						: *args++ ),
					      ptmp, radix);
					if(lval)
						args = ((unsigned int *)
						(((unsigned long *) args) + 1));
					if (*fmt == 'x')
						strlwr(ptmp, ptmp);
					goto printit;

#if FLOATS
				case 'e':	/* float */
				case 'f':
				case 'g':
				case 'E':
				case 'G':
					fx = *((double *) args);
					args=(unsigned int *)
						 (((double *) args)+1);

					fp_print(fx, *fmt, preci, ptmp);
					preci = -1;
					goto printit;
#endif

				case 'c':	/* Character */
					ptmp[0] = *args++;
					ptmp[1] = '\0';
					goto nopad;

				case 's':	/* String */
					ptmp = *((char **) args);
					args = ((unsigned int *)
						(((char **) args) + 1));
nopad:
					sign = '\0';
					pad  = ' ';
printit:
					cnt += _prtfld(op, put, ptmp, ljustf,
						       sign, pad, width, preci);
					break;

				default:	/* unknown character */
					goto charout;
				}
			}
		else
			{
charout:
			(*put)(*fmt, op);		/* normal char out */
			++cnt;
			}
		++fmt;
		}
	return(cnt);
	}
