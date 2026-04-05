#include <stdarg.h>
#include <stdio.h>
#include <mint/arch/nf_ops.h>
#include <mint/mintbind.h>
#include <sys/types.h>
#include <mint/osbind.h>
#include <errno.h>

struct msgbuf {
	char *buf;
	size_t bufsize;
	size_t used;
};

#define EMULATE_DEBUGPRINTF 0

#if EMULATE_DEBUGPRINTF

/*** ---------------------------------------------------------------------- ***/

static long debugprintf_putchar(int c, struct msgbuf *msg)
{
	if (msg->used < msg->bufsize)
	{
		msg->buf[msg->used++] = c;
	}
	return 1;
}

/*** ---------------------------------------------------------------------- ***/

static long debugprintf_putc(struct msgbuf *msg, int c, int width)
{
	long put;
	
	put = debugprintf_putchar(c, msg);
	while (--width > 0)
	{
		put += debugprintf_putchar(' ', msg);
	}
	
	return put;
}

/*** ---------------------------------------------------------------------- ***/

static long debugprintf_putl(struct msgbuf *msg, unsigned long u, int base, int width, int fill_char, int upper)
{
	char obuf[32];
	char *t = obuf;
	long put = 0;
	
	do {
		*t = "0123456789abcdef"[u % base];
		if (upper && *t >= 'a' && *t <= 'f')
			*t = *t - 'a' + 'A';
		t++;
		u /= base;
		width--;
	} while (u > 0);
	
	while (width-- > 0)
	{
		put += debugprintf_putchar(fill_char, msg);
	}
	
	while (t != obuf)
	{
		put += debugprintf_putchar(*--t, msg);
	}
	
	return put;
}

/*** ---------------------------------------------------------------------- ***/

static long debugprintf_puts(struct msgbuf *msg, const char *s, int width)
{
	long put = 0;
	
	if (s == NULL)
		s = "(null)";
	
	while (*s)
	{
		put += debugprintf_putchar(*s++, msg);
		width--;
	}
	
	while (width-- > 0)
	{
		put += debugprintf_putchar(' ', msg);
	}
	
	return put;
}

/*** ---------------------------------------------------------------------- ***/

# define TIMESTEN(x)	((((x) << 2) + (x)) << 1)

static long debugprintf(struct msgbuf *msg, const char *fmt, va_list args)
{
	char c;
	char fill_char;
	long len = 0;
	int width;
	int long_flag;
	
	char *s_arg;
	int   i_arg;
	long  l_arg;

	while ((c = *fmt++) != 0)
	{
		if (c != '%')
		{
			len += debugprintf_putc(msg, c, 1);
			continue;
		}
		
		c = *fmt++;
		width = 0;
		long_flag = 0;
		fill_char = ' ';
		
		if (c == '0')
		{
			fill_char = '0';
			c = *fmt++;
		}
		
		while (c >= '0' && c <= '9')
		{
			width = TIMESTEN(width) + (c - '0');
			c = *fmt++;
		}
		
		if (c == 'l' || c == 'L')
		{
			long_flag = 1;
			c = *fmt++;
		}
		
		if (!c)
			break;
		
		switch (c)
		{
		case '%':
			len += debugprintf_putc(msg, c, width);
			break;
		case 'c':
			i_arg = (int)va_arg(args, int32_t);
			len += debugprintf_putc(msg, i_arg, width);
			break;
		case 's':
			s_arg = (char *)(va_arg(args, int32_t));
			len += debugprintf_puts(msg, s_arg, width);
			break;
		case 'i':
		case 'd':
			if (long_flag)
				l_arg = (long)va_arg(args, int32_t);
			else
				l_arg = (int)va_arg(args, int32_t);
			if (l_arg < 0)
			{
				len += debugprintf_putc(msg, '-', 1);
				width--;
				l_arg = -l_arg;
			}
			len += debugprintf_putl(msg, l_arg, 10, width, fill_char, FALSE);
			break;
		case 'o':
			if (long_flag)
				l_arg = (long)va_arg(args, int32_t);
			else
				l_arg = (unsigned int)va_arg(args, int32_t);
			len += debugprintf_putl(msg, l_arg, 8, width, fill_char, FALSE);
			break;
		case 'x':
		case 'X':
			if (long_flag)
				l_arg = (long)va_arg(args, int32_t);
			else
				l_arg = (unsigned int)va_arg(args, int32_t);
			len += debugprintf_putl(msg, l_arg, 16, width, fill_char, c == 'X');
			break;
		case 'b':
			if (long_flag)
				l_arg = (long)va_arg(args, int32_t);
			else
				l_arg = (unsigned int)va_arg(args, int32_t);
			len += debugprintf_putl(msg, l_arg, 2, width, fill_char, FALSE);
			break;
		case 'u':
			if (long_flag)
				l_arg = (long)va_arg(args, int32_t);
			else
				l_arg = (unsigned int)va_arg(args, int32_t);
			len += debugprintf_putl(msg, l_arg, 10, width, fill_char, FALSE);
			break;
		case 'p':
			l_arg = (long)va_arg(args, int32_t);
			while (width > 10)
			{
				len += debugprintf_putchar(' ', msg);
				width--;
			}
			len += debugprintf_puts(msg, "0x", 0);
			len += debugprintf_putl(msg, l_arg, 16, 8, '0', FALSE);
			break;
		}
	}
	
	return len;
}

#endif

/*** ---------------------------------------------------------------------- ***/

int nf_debugvprintf(const char *format, va_list args)
{
	struct nf_ops *ops;
	long nfid_stderr;
	int ret;
	
	if ((ops = nf_init()) == NULL ||
		(nfid_stderr = NF_GET_ID(ops, NF_ID_STDERR)) == 0)
	{
		errno = -32;
		return -1;
	}	
#if EMULATE_DEBUGPRINTF
	{
		struct msgbuf msg;
		char buf[2048];
		
		msg.buf = buf;
		msg.bufsize = sizeof(buf);
		msg.used = 0;
		ret = (int)debugprintf(&msg, format, args);
		if (ret >= (int)sizeof(buf))
			ret = (int)sizeof(buf) - 1;
		buf[ret] = '\0';
		ret = (int)ops->call(nfid_stderr | 0, (uint32_t)virt_to_phys(buf));
	}
#else
	{
#if defined(_PUREC_SOURCE) || !defined(HAVE_VASPRINTF)
		char buf[2048];
		
#ifdef HAVE_VSNPRINTF
		ret = vsnprintf(buf, sizeof(buf), format, args);
#else
		ret = vsprintf(buf, format, args);
#endif
		ret = (int)ops->call(nfid_stderr | 0, (__uint32_t)virt_to_phys(buf));
#else
		char *buf = NULL;
		
		ret = vasprintf(&buf, format, args);
		if (buf)
		{
			ret = (int)ops->call(nfid_stderr | 0, (__uint32_t)virt_to_phys(buf));
			free(buf);
		}
#endif
	}
#endif

	return ret;
}

/*** ---------------------------------------------------------------------- ***/

int nf_debugprintf(const char *format, ...)
{
	int ret;
	va_list args;
	
	va_start(args, format);
	ret = nf_debugvprintf(format, args);
	va_end(args);
	return ret;
}
