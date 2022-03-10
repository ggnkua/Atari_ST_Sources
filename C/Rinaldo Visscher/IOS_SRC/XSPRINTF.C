/*********************************************************************

					IOS - special routines
					
	Program : IOSmail
    Source  : free
	Author  : Rinaldo Visscher
	Date    : 1991
**********************************************************************/


#include	<stdio.h>
#include	<stdarg.h>
#include	<string.h>
#include	<ctype.h>
#include	<tos.h>
#include	<ext.h>
#include	"portab.h"

#define		LP		*(ULONG *)
#define		IP		(ULONG)*(UWORD *)
#define		STTC	1

MLOCAL BYTE *mon[12] = {	"Jan", "Feb", "Mar", "Apr", "May", "Jun",
							"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"},

			*prtstr[2];		/* Must be array: Time/Date!	*/
MLOCAL WORD	prtcnt = -1;	/* points to current buffer		*/


VOID CDECL doprint(BYTE *fmt, BYTE *arg);


MLOCAL VOID conv(ULONG getal, BYTE *p, WORD base, WORD unsign)
{
	/*
	**	Local function of doprint
	*/
	
	BYTE	buf[10],
			*t = &buf[9],
			sign = getal & 0x80000000L && !unsign,
			ch;
	
	*t = EOS;
	
	if (sign) getal = -getal;
    
    do
    {
		ch = getal % base;
		*--t = (ch < 10) ? ch+'0' : ch-10+'A';
		getal /= base;
	}
	
	while (getal);
	if (sign) *--t='-';
	strcpy(p, t);
}

MLOCAL VOID putSTR(BYTE c)
{
	*prtstr[prtcnt]++ = c;
}

MLOCAL VOID CDECL iprint(BYTE *fmt, ...)
{
	va_list args;
	va_start(args, fmt);
	
	doprint(fmt, (BYTE *)args);
}

MLOCAL VOID CDECL doprint(BYTE *fmt, BYTE *arg)
{
	REG WORD	width, precision, uselong;
	REG BYTE	*p, *pos, left, dot, pad;
	BYTE		buf[128];
	struct date	d;
	struct time t;
	
	getdate(&d);
	gettime(&t);
	
	p = fmt-1L;
	
	while (*++p)
	{
		if (*p == '%')
		{
			p++;
			uselong = width = precision = 0;
			pad = ' ';
			
			if (*p == '%')
			{
				putSTR('%');
				continue;
			}
			
			left = *p == '-';
			if (left) p++;
			if (*p == '0') pad = '0';
			while (isdigit(*p)) width = width * 10 + *p++ - '0';
			dot = *p == '.';
			
			if (dot)
			{
				p++;
				while (isdigit(*p)) precision = precision * 10 + *p++ - '0';
			}
			
			uselong = *p == 'l';
			if (uselong) p++;
			
			switch (*p)
			{
				case 'D':	uselong++;
				case 'd':	conv(uselong ? *(LONG *)arg : (LONG)*(WORD *)arg, buf, 10, 0);
							arg += uselong ? sizeof(LONG) : sizeof(WORD);
							break;
				case 'U':	uselong++;
				case 'u':	conv(uselong ? LP arg : IP arg, buf, 10, 1);
							arg += uselong ? sizeof(LONG) : sizeof(WORD);
							break;
				case 'X':	uselong++;
				case 'x':	conv(uselong ? LP arg : IP arg, buf, 0x10, 1);
							arg += uselong ? sizeof(LONG) : sizeof(WORD);
							break;
				case 'O':	uselong++;
				case 'o':	conv(uselong ? LP arg : IP arg, buf, 8, 1);
							arg += uselong ? sizeof(LONG) : sizeof(WORD);
							break;
				case 'Z':	uselong++;
				case 'z':	conv(uselong ? LP arg : IP arg, buf, 36, 1);
							arg += uselong ? sizeof(LONG) : sizeof(WORD);
							break;
				case 'c':	*buf = *(WORD *)arg; buf[1] = EOS;
							arg += sizeof(WORD);	/* Char on stack == WORD */
							break;
				case 's':	strncpy(buf, *(BYTE **)arg, 127);
							buf[127] = EOS;
							arg += sizeof(BYTE *);
							if (dot) buf[precision] = EOS;
							break;
			}
			
			width -= (int)strlen(buf);
			if (!left) while (width-->0) putSTR(pad);	/* left padding	*/
			pos = buf;
			while (*pos) putSTR(*pos++);	/* buffer	*/
			if (left)
				while (width-- > 0) putSTR(pad);	/* right padding */
			continue;
		}
	
	if (*p == '$')
		switch (*++p)
		{
			case '$':	putSTR('$'); break;
			case 't':	iprint("%02d:%02d:%02d", t.ti_hour, t.ti_min, t.ti_sec); break;
			case 'd':	iprint("%02d-%02d-%02d", d.da_day, d.da_mon, d.da_year-1900); break;
			case 'D':	iprint("%02d", d.da_day); break;
			case 'm':	iprint("%03s", mon[d.da_mon-1]); break;
		}
	else putSTR(*p);
	}
}

VOID CDECL xsprintf(BYTE *buf, BYTE *fmt, ...)
{
	va_list	args;
	va_start(args, fmt);
	
	prtstr[++prtcnt] = buf;
	doprint(fmt, (BYTE *)args);
	*prtstr[prtcnt--] = EOS;		/* add string terminator	*/
}
