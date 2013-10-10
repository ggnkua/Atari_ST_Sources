#include <stdio.h>
#include <ctype.h>

static nconv(type, size, s, val)
int type;
int size; /* 1=long, 0=int */
register char **s;
long val;
{
    int stack[20], sp = 0;
    register int base;

    switch ((int)type) {
	case 'd': base = 10; break;
	case 'u': base = 10; break;
	case 'o': base = 8; break;
	case 'x': base = 16; }

    if (val < 0)
	if (type == 'd') {
	    *(*s)++ = '-';
	    val = -val; }
	else if (!size)
	    val &= 0xffffL;

    do {
	stack[sp++] = base == 8 ? val&7 : base == 16 ? val&15 :
	    val % base;
	val = base == 8 ? val>>3&0x1fffffff : base == 16 ? val>>4&0xfffffff :
	    val / base;
    } while (val);

    while (sp)
	*(*s)++ = stack[--sp] >= 10 ? stack[sp]-10+'A' : stack[sp]+'0';
}

static fconv(type, prec, s, val)
int type;
int prec;    /* precision */
register char **s;
double val;
{
    register int i,j;
    extern int _maxprec;

    struct {
	short sgn;    /* subrange : 0..1 */
	int exp;
	char sig[30];
    } decimal;

    if (prec == 256) prec = 6;	  /* defaults to six digits */
    decimal.sgn = val < 0;
    fconvert(&val, decimal.sig, &decimal.exp, prec+1);

    if (decimal.sgn)
	*(*s)++ = '-';
    if (decimal.sig[0] == '0' && !decimal.sig[1])
	*(*s)++ = decimal.sig[0];
    else {
	if (type == 'f') {
	    i = decimal.exp + prec + 1;
	    i = i>_maxprec ? _maxprec : i;
	    fconvert(&val, decimal.sig, &decimal.exp, i < 0 ? 1 : i);

	    j = 0;
	    while (i && decimal.exp >= 0) {
		*(*s)++ = decimal.sig[j++];
		i--;
		decimal.exp--;
	    }
	    while (decimal.exp >= 0) {
		*(*s)++ = '0';
		decimal.exp--;
	    }
	    if (prec)
		*(*s)++ = '.';
	    while (prec && decimal.exp < -1) {
		*(*s)++ = '0';
		decimal.exp++;
		prec--;
	    }
	    while (prec--) {
		*(*s)++ = i>0 ? decimal.sig[j++] : '0';
		i--;
	    }
	}
	else {
	    *(*s)++ = decimal.sig[0];
	    if (prec)
		*(*s)++ = '.';
	    i = 1;
	    while (prec--)
		*(*s)++ = decimal.sig[i++];
	    *(*s)++ = 'E';
	    sprintf(*s, "%d", decimal.exp);
	    *s += strlen(*s);
	}
    }
}

int _digits(s)
char **s;
{
    int result = 0;

    while (**s >= '0' && **s <= '9') {
	result = result*10 + **s-'0';
	(*s)++; }

    return result;
}

/*VARARGS1*/
int _sprintf(s, args)
char *s;
register char *args;
{
    register char *format;
    char *starts, *field, *str, *temp, pad;
    register int convchar;
    int left, minimum, prec, longitem;
    register int i;

    starts = s; /* save start ptr so length can be easily computed */
    format = *(char **)args; args += sizeof format;
    while (*format) {
	while (*format && *format != '%')
	    *s++ = *format++;
	if (*format == '%') {
	    format++;
	    left = 0; prec = 256; longitem = 0; pad = ' ';
	    if (*format == '-') {
		left = 1; format++; }
	    if (*format == '0') {
		pad = '0'; format++; }
	    temp = format; minimum = _digits(&temp); format = temp;
	    if (*format == '.') {
		format++;
		temp = format; prec = _digits(&temp); format = temp;}
	    if (*format == 'l') {
		longitem = 1; format++; }

	    if (*format) convchar = *format++;
	    field = s;	  /* start of field */
	    if (convchar == 'd' || convchar == 'o' || convchar == 'x' || convchar == 'u') {
		nconv(convchar, longitem, &s, (long)(longitem ? *(long *)args :
		    (long)*(int *)args));
		args += longitem ? sizeof(long) : sizeof(int); }
	    else if (convchar == 'c') {
		*s++ = *(args+1); args += sizeof(int); }
	    else if (convchar == 's') {
		str = *(char **)args; args += sizeof str;
		for (i=prec; i && *str; i--)
		    *s++ = *str++; }
	    else if (convchar == 'e' || convchar == 'f' || convchar == 'g') {
		fconv(convchar, prec, &s, *(double *)args);
		args += sizeof(double); }
	    else
		*s++ = convchar;    /* something like %% */

	    if (s-field < minimum)    /* must justify field */
		if (left)
		    for (i = minimum-(s-field); i; i--)
			*s++ = pad;
		else {
		    temp = str = field + (minimum - 1);
		    for (i = s-field; i; i--)
			*str-- = *(field+(i-1));
		    while (field <= str)
			*field++ = pad;
		    s = temp+1; } } }
    *s = 0;    /* terminate with a null */
    return s - starts;
}

/*VARARGS1*/
int _fprintf(stream, args)
long stream;
int *args;
{
    char s[256];
    int len;

    len = _sprintf(s, args);
    fputs(s, stream);
    len;
}

/*VARARGS*/
int printf(args)
int args;
{
    _fprintf(stdout, &args);
}

/*VARARGS1*/
int fprintf(stream, args)
long stream;
int args;
{
    _fprintf(stream, &args);
}

/*VARARGS1*/
int sprintf(s, args)
char *s;
int args;
{
    _sprintf(s, &args);
}
