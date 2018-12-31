/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"
#include "chars.h"
#include "fp.h"
#include "jctype.h"
#include "disp.h"
#include "extend.h"
#include "fmt.h"

#ifdef MAC
# include  "mac.h"
#endif

private void
	doformat proto((File *, const char *, va_list)),
	outld proto((long, int)),
	pad proto((DAPchar, int));

char	mesgbuf[MESG_SIZE];

/* Formatting codes supported:
 *
 * %%: => '%'
 * %O, %D, %X: long => octal, decimal, or hex
 * %lo, %ld, %lx: long => octal, decimal, or hex
 * %o, %d, %x: int => octal, decimal, or hex
 * %c: char => character
 * %s: char* => string
 *
 * %b: buffer pointer => buffer's name
 * %f: void => current command's name
 * %n: int => int == 1? "" : "s"
 * %p: char => visible rep
 */

#ifdef ZTCDOS
/* ZTCDOS only accepts va_list in a prototype */
void
format(char *buf, size_t len, const char *fmt, va_list ap)
#else
void
format(buf, len, fmt, ap)
char	*buf;
size_t	len;
const char	*fmt;
va_list	ap;
#endif
{
	File	strbuf;

	strbuf.f_ptr = strbuf.f_base = buf;
	strbuf.f_fd = -1;		/* Not legit for files */
	strbuf.f_bufsize = strbuf.f_cnt = len;
	strbuf.f_flags = F_STRING;

	doformat(&strbuf, fmt, ap);
	f_putc('\0', &strbuf);	/* f_putc will place this, even if overflow */
}

/* pretty-print character c into buffer cp (up to PPWIDTH bytes) */

void
PPchar(c, cp)
ZXchar	c;
char	*cp;
{
	if (jisprint(c)) {
		cp[0] = c;
		cp[1] = '\0';
	} else if (c < DEL) {
		strcpy(cp, "^?");
		cp[1] = c +'@';
	} else if (c == DEL) {
		strcpy(cp, "^?");
	} else {
		cp[0] = '\\';
		cp[1] = '0'+(c >> 6);
		cp[2] = '0'+((c >> 3) & 07);
		cp[3] = '0'+(c & 07);
		cp[4] = '\0';
	}
}

private struct fmt_state {
	int	precision,
		width;
	bool	leftadj;
	char	padc;
	File	*iop;
} current_fmt;

private void
putld(d, base)
long	d;
int	base;
{
	int	len = 1;
	long	tmpd = d;

	if (current_fmt.width == 0 && current_fmt.precision) {
		current_fmt.width = current_fmt.precision;
		current_fmt.padc = '0';
	}
	while ((tmpd = (tmpd / base)) != 0)
		len += 1;
	if (d < 0)
		len += 1;
	if (!current_fmt.leftadj)
		pad(current_fmt.padc, current_fmt.width - len);
	if (d < 0) {
		f_putc('-', current_fmt.iop);
		d = -d;
	}
	outld(d, base);
	if (current_fmt.leftadj)
		pad(current_fmt.padc, current_fmt.width - len);
}

private void
outld(d, base)
long	d;
int	base;
{
	register long	n;
	static const char	chars[] = {'0', '1', '2', '3', '4', '5', '6',
				    '7', '8', '9', 'a', 'b', 'c', 'd',
				    'e', 'f'};

	if ((n = (d / base)) != 0)
		outld(n, base);
	f_putc((int) (chars[(int) (d % base)]), current_fmt.iop);
}

private void
fmt_puts(str)
char	*str;
{
	int	len;
	register char	*cp;

	if (str == NULL)
		str = "(null)";
	len = strlen(str);
	if (current_fmt.precision == 0 || len < current_fmt.precision)
		current_fmt.precision = len;
	else
		len = current_fmt.precision;
	cp = str;
	if (!current_fmt.leftadj)
		pad(' ', current_fmt.width - len);
	while (--current_fmt.precision >= 0)
		f_putc(*cp++, current_fmt.iop);
	if (current_fmt.leftadj)
		pad(' ', current_fmt.width - len);
}

private void
pad(c, amount)
register char	c;
register int	amount;
{
	while (--amount >= 0)
		f_putc(c, current_fmt.iop);
}

#ifdef ZTCDOS
/* ZTCDOS only accepts va_list in a prototype */
private void
doformat(register File *sp, register const char *fmt, va_list ap)
#else
private void
doformat(sp, fmt, ap)
register File	*sp;
register const char	*fmt;
va_list	ap;
#endif
{
	register char	c;
	struct fmt_state	prev_fmt;

	prev_fmt = current_fmt;
	current_fmt.iop = sp;

	while ((c = *fmt++) != '\0') {
		if (c != '%') {
			f_putc(c, current_fmt.iop);
			continue;
		}

		current_fmt.padc = ' ';
		current_fmt.precision = current_fmt.width = 0;
		current_fmt.leftadj = NO;
		c = *fmt++;
		if (c == '-') {
			current_fmt.leftadj = YES;
			c = *fmt++;
		}
		if (c == '0') {
			current_fmt.padc = '0';
			c = *fmt++;
		}
		while (c >= '0' && c <= '9') {
			current_fmt.width = current_fmt.width * 10 + (c - '0');
			c = *fmt++;
		}
		if (c == '*') {
			current_fmt.width = va_arg(ap, int);
			c = *fmt++;
		}
		if (c == '.') {
			c = *fmt++;
			while (c >= '0' && c <= '9') {
				current_fmt.precision = current_fmt.precision * 10 + (c - '0');
				c = *fmt++;
			}
			if (c == '*') {
				current_fmt.precision = va_arg(ap, int);
				c = *fmt++;
			}
		}
	reswitch:
		/* At this point, fmt points at one past the format letter. */
		switch (c) {
		case '%':
			f_putc('%', current_fmt.iop);
			break;

		case 'O':
		case 'D':
		case 'X':
			putld(va_arg(ap, long), (c == 'O') ? 8 :
						(c == 'D') ? 10 : 16);
			break;

		case 'b':
		    {
			Buffer	*b = va_arg(ap, Buffer *);

			fmt_puts(b->b_name);
			break;
		    }

		case 'c':
			f_putc(va_arg(ap, DAPchar), current_fmt.iop);
			break;

		case 'o':
		case 'd':
		case 'x':
			putld((long) va_arg(ap, int), (c == 'o') ? 8 :
						(c == 'd') ? 10 : 16);
			break;

		case 'f':	/* current command name gets inserted here! */
			fmt_puts(LastCmd->Name);
			break;

		case 'l':
			c = CharUpcase(*++fmt);
			goto reswitch;

		case 'n':
			if (va_arg(ap, int) != 1)
				fmt_puts("s");
			break;

		case 'p':
		    {
			ZXchar	cc = ZXC(va_arg(ap, DAPchar));

			if (cc == ESC) {
				fmt_puts("ESC");
			} else {
				char	cbuf[PPWIDTH];

				PPchar(cc, cbuf);
				fmt_puts(cbuf);
			}
		    }
			break;

		case 's':
			fmt_puts(va_arg(ap, char *));
			break;

		default:
			complain("Unknown format directive: \"%%%c\"", c);
		}
	}
	current_fmt = prev_fmt;
}

#ifdef STDARGS
char *
sprint(const char *fmt, ...)
#else
/*VARARGS1*/ char *
sprint(fmt, va_alist)
	const char	*fmt;
	va_dcl
#endif
{
	va_list	ap;
	static char	line[LBSIZE];

	va_init(ap, fmt);
	format(line, sizeof line, fmt, ap);
	va_end(ap);
	return line;
}

#ifdef STDARGS
void
writef(const char *fmt, ...)
#else
/*VARARGS1*/ void
writef(fmt, va_alist)
	const char	*fmt;
	va_dcl
#endif
{
	va_list	ap;

	va_init(ap, fmt);
#ifdef NO_JSTDOUT
	/* Can't use sprint because caller might have
	 * passed the result of sprint as an arg.
	 */
	{
		char	line[100];

		format(line, sizeof(line), fmt, ap);
		putstr(line);
	}
#else /* !NO_JSTDOUT */
	doformat(jstdout, fmt, ap);
#endif /* !NO_JSTDOUT */
	va_end(ap);
}

#ifdef STDARGS
void
fwritef(File *fp, const char *fmt, ...)
#else
/*VARARGS2*/ void
fwritef(fp, fmt, va_alist)
	File	*fp;
	const char	*fmt;
	va_dcl
#endif
{
	va_list	ap;

	va_init(ap, fmt);
	doformat(fp, fmt, ap);
	va_end(ap);
}

#ifdef STDARGS
void
swritef(char *str, size_t size, const char *fmt, ...)
#else
/*VARARGS3*/ void
swritef(str, size, fmt, va_alist)
	char	*str;
	size_t	size;
	const char	*fmt;
	va_dcl
#endif
{
	va_list	ap;

	va_init(ap, fmt);
	format(str, size, fmt, ap);
	va_end(ap);
}

/* send a message (supressed if input pending) */

#ifdef STDARGS
void
s_mess(const char *fmt, ...)
#else
/*VARARGS1*/ void
s_mess(fmt, va_alist)
	const char	*fmt;
	va_dcl
#endif
{
	va_list	ap;

	if (InJoverc)
		return;
	va_init(ap, fmt);
	format(mesgbuf, sizeof mesgbuf, fmt, ap);
	va_end(ap);
	message(mesgbuf);
}

/* force a message: display it now no matter what.
 * If you wish it to stick, set stickymsg on after calling f_mess.
 */

#ifdef STDARGS
void
f_mess(const char *fmt, ...)
#else
/*VARARGS1*/ void
f_mess(fmt, va_alist)
	const char	*fmt;
	va_dcl
#endif
{
	va_list	ap;

	va_init(ap, fmt);
	format(mesgbuf, sizeof mesgbuf, fmt, ap);
	va_end(ap);
	DrawMesg(NO);
	stickymsg = NO;
	UpdMesg = YES;	/* still needs updating (for convenience) */
}

#ifdef STDARGS
void
add_mess(const char *fmt, ...)
#else
/*VARARGS1*/ void
add_mess(fmt, va_alist)
	const char	*fmt;
	va_dcl
#endif
{
	int	mesg_len = strlen(mesgbuf);
	va_list	ap;

	if (InJoverc)
		return;
	va_init(ap, fmt);
	format(&mesgbuf[mesg_len], (sizeof mesgbuf) - mesg_len, fmt, ap);
	va_end(ap);
	message(mesgbuf);
}
