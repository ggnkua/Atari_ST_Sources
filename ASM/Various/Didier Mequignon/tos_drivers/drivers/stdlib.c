/*
 * File:        stdlib.c
 * Purpose:     Functions normally found in a standard C lib.
 *
 * Notes:       This supports ASCII only!!!
 */

#define FALSE       (0)
#define TRUE        (1)
#define NULL        (0)

/****************************************************************/
#if 1
static int isspace(int c)
{
  switch(c)
  {
    case ' ':
    case '\f':
    case '\n':
    case '\r':
    case '\t':
    case '\v':
    return TRUE;
  }
  return FALSE;
}
#else
int isspace(int ch)
{
    if ((ch == ' ') || (ch == '\t'))    /* \n ??? */
        return TRUE;
    else
        return FALSE;
}
#endif

/****************************************************************/
int isalnum(int ch)
{
    /* ASCII only */
    if (((ch >= '0') && (ch <= '9')) ||
        ((ch >= 'A') && (ch <= 'Z')) ||
        ((ch >= 'a') && (ch <= 'z')))
        return TRUE;
    else
        return FALSE;
}

/****************************************************************/
int isdigit(int ch)
{
    /* ASCII only */
    if ((ch >= '0') && (ch <= '9'))
        return TRUE;
    else
        return FALSE;
}

/****************************************************************/
int isupper(int ch)
{
    /* ASCII only */
    if ((ch >= 'A') && (ch <= 'Z'))
        return TRUE;
    else
        return FALSE;
}

/****************************************************************/
int strcasecmp(const char *s1, const char *s2)
{
    char    c1, c2;
    int     result = 0;

    while (result == 0)
    {
        c1 = *s1++;
        c2 = *s2++;
        if ((c1 >= 'a') && (c1 <= 'z'))
            c1 = (char)(c1 - ' ');
        if ((c2 >= 'a') && (c2 <= 'z'))
            c2 = (char)(c2 - ' ');
        if ((result = (c1 - c2)) != 0)
            break;
        if ((c1 == 0) || (c2 == 0))
            break;
    }
    return result;
}


/****************************************************************/
int strncasecmp(const char *s1, const char *s2, int n)
{
    char    c1, c2;
    int     k = 0;
    int     result = 0;

    while ( k++ < n )
    {
        c1 = *s1++;
        c2 = *s2++;
        if ((c1 >= 'a') && (c1 <= 'z'))
            c1 = (char)(c1 - ' ');
        if ((c2 >= 'a') && (c2 <= 'z'))
            c2 = (char)(c2 - ' ');
        if ((result = (c1 - c2)) != 0)
            break;
        if ((c1 == 0) || (c2 == 0))
            break;
    }
    return result;
}

/****************************************************************/
unsigned long strtoul(char *str, char **ptr, int base)
{
    unsigned long rvalue;
    int c, err, neg;
    char *endp;
    char *startp;

    rvalue = 0;  err = 0;  neg = 0;

    /* Check for invalid arguments */
    if ((str == NULL) || (base < 0) || (base == 1) || (base > 36))
    {
        if (ptr != NULL)
        {
            *ptr = str;
        }
        return 0;
    }

    /* Skip leading white spaces */
    for (startp = str; isspace(*startp); ++startp)
        ;

    /* Check for notations */
    switch (startp[0])
    {
        case '0':
            if ((startp[1] == 'x') || (startp[1] == 'X'))
            {
                if ((base == 0) || (base == 16))
                {
                    base = 16;
                    startp = &startp[2];
                }
            }
            break;
        case '-':
            neg = 1;
            startp = &startp[1];
            break;
        default:
            break;
    }

    if (base == 0)
        base = 10;

    /* Check for invalid chars in str */
    for ( endp = startp; (c = *endp) != '\0'; ++endp)
    {
        /* Check for 0..9,Aa-Zz */
        if (!isalnum(c))
        {
            err = 1;
            break;
        }

        /* Convert char to num in 0..36 */
        if (isdigit(c))
        {
            c = c - '0';
        }
        else
        {
            if (isupper(c))
            {
                c = c - 'A' + 10;
            }
            else
            {
                c = c - 'a' + 10;
            }
        }

        /* check c against base */
        if (c >= base)
        {
            err = 1;
            break;
        }

        if (neg)
        {
            rvalue = (rvalue * base) - c;
        }
        else
        {
            rvalue = (rvalue * base) + c;
        }
    }

    /* Upon exit, endp points to the character at which valid info */
    /* STOPS.  No chars including and beyond endp are used.        */

    if (ptr != NULL)
        *ptr = endp;

    if (err)
    {
        if (ptr != NULL)
            *ptr = str;
        
        return 0;
    }
    else
    {
        return rvalue;
    }
}

/****************************************************************/
int strlen(const char *str)
{
    char *s = (char *)str;
    int len = 0;

    if (s == NULL)
        return 0;

    while (*s++ != '\0')
        ++len;

    return len;
}

/****************************************************************/
char *strcat(char *dest, const char *src)
{
    char *dp;
    char *sp = (char *)src;

    if ((dest != NULL) && (src != NULL))
    {
        dp = &dest[strlen(dest)];

        while (*sp != '\0')
        {
            *dp++ = *sp++;
        }
        *dp = '\0';
    }
    return dest;
}

/****************************************************************/
char *strncat(char *dest, const char *src, int n)
{
    char *dp;
    char *sp = (char *)src;

    if ((dest != NULL) && (src != NULL) && (n > 0))
    {
        dp = &dest[strlen(dest)];

        while ((*sp != '\0') && (n-- > 0))
        {
            *dp++ = *sp++;
        }
        *dp = '\0';
    }
    return dest;
}

/****************************************************************/
char *strcpy(char *dest, const char *src)
{
    char *dp = (char *)dest;
    char *sp = (char *)src;

    if ((dest != NULL) && (src != NULL))
    {
        while (*sp != '\0')
        {
            *dp++ = *sp++;
        }
        *dp = '\0';
    }
    return dest;
}

/****************************************************************/
char * strncpy(char *dest, const char *src, int n)
{
    char *dp = (char *)dest;
    char *sp = (char *)src;

    if ((dest != NULL) && (src != NULL) && (n > 0))
    {
        while ((*sp != '\0') && (n-- > 0))
        {
            *dp++ = *sp++;
        }
        *dp = '\0';
    }
    return dest;
}

/****************************************************************/
int strcmp(const char *s1, const char *s2)
{
    /* No checks for NULL */
    char *s1p = (char *)s1;
    char *s2p = (char *)s2;

    while (*s2p != '\0')
    {
        if (*s1p != *s2p)
            break;

        ++s1p;
        ++s2p;
    }
    return (*s1p - *s2p);
}

/****************************************************************/
int strncmp(const char *s1, const char *s2, int n)
{
    /* No checks for NULL */
    char *s1p = (char *)s1;
    char *s2p = (char *)s2;

    if (n <= 0)
        return 0;

    while (*s2p != '\0')
    {
        if (*s1p != *s2p)
            break;

        if (--n == 0)
            break;

        ++s1p;
        ++s2p;
    }
    return (*s1p - *s2p);
}

#if 0
/****************************************************************/
void *memcpy(void *dest, const void *src, unsigned n)
{
    int longs, bytes;
    unsigned long *dpl = (unsigned long *)dest;
    unsigned long *spl = (unsigned long *)src;
    unsigned char  *dpb, *spb;

    if ((dest != NULL) && (src != NULL) && (n > 0))
    {
        bytes = (n & 0x3);
        longs = (n - bytes) >> 2;
    
        while (longs--)
            *dpl++ = *spl++;
        
        dpb = (unsigned char *)dpl;
        spb = (unsigned char *)spl;
        
        while (bytes--)
            *dpb++ = *spb++;
    }
    return dest;
}

/****************************************************************/
void *memset(void *s, int c, unsigned n)
{
    /* Not optimized, but very portable */
    unsigned char *sp = (unsigned char *)s;

    if ((s != NULL) && (n > 0))
    {
        while (n--)
        {
            *sp++ = (unsigned char)c;
        }
    }
    return s;
}
#endif

/****************************************************************/
static long check_base(char ch, long base)
{
  if(isdigit(ch) && (ch < '0' + base))
    return(ch - '0');
  if((ch >= 'a') && (ch <= 'z'))
    ch -= ('a' - 'A');
  if((ch >= 'A') && (ch < 'A' + base - 10))
    return(ch - 'A' + 10);
  return(-1);
}

/****************************************************************/
long atol(const char *text)
{
	long n;
	int minus, base, ch;
	while(isspace(*text))
		text++;
	minus = 0;   
	if(*text == '-')
	{
		minus = 1;
		text++;
	}
	base = 10;
	if(*text == '$')
	{
		base = 16;
		text++;
	}
	else if(*text == '%')
	{
		base = 2;
		text++;
	}
	n = 0;
	while((ch = check_base(*text++, base)) >= 0)
		n = n * base + ch;
	if(minus)
		n = -n;
	return(n);
}

/****************************************************************/
#ifndef MCF5445X /* MCF5445X has no FPU */
float atof(const char *text)
{
	long n;
	float nf;
	int minus, base, ch;
	while(isspace(*text))
		text++;
	minus = 0;   
	if(*text == '-')
	{
		minus = 1;
		text++;
	}
	base = 10;
	if(*text == '$')
	{
		base = 16;
		text++;
	}
	else if(*text == '%')
	{
		base = 2;
		text++;
	}
	n = 0;
	while((ch = check_base(*text++, base)) >= 0)
		n = n * base + ch;
	nf = (float)n;
	if(text[-1] == '.')
	{
		n = base;
		while((ch = check_base(*text++, base)) >= 0)
		{
			nf += (float)ch/(float)n;
			n *= base;
		}
	}	
	if(minus)
		nf = -nf;
	return(nf);
}
#endif /* MCF5445X */

/****************************************************************/
void ltoa(char *buf, long n, unsigned long base)
{
	unsigned long un;
	char *tmp, ch;
	un = n;
	if((base == 10) && (n < 0))
	{
		*buf++ = '-';
		un = -n;
	}
	tmp = buf;
	do
	{
		ch = un % base;
		un = un / base;
		if(ch <= 9)
			ch += '0';
		else
			ch += 'a' - 10;
		*tmp++ = ch;
	}
	while(un);
	*tmp = '\0';
	while(tmp > buf)
	{
		ch = *buf;
		*buf++ = *--tmp;
		*tmp = ch;
	}
}

/****************************************************************/
#ifndef MCF5445X /* MCF5445X has no FPU */
typedef union
{ 
	long	L; 
	float	F; 
}	LF_t; 

void ftoa(float f, int max, char *buf) 
{ 
	long mantissa, int_part, frac_part; 
	short exp2; 
	LF_t x; 
	x.F = f; 
	if(x.L == 0) 
	{ 
		*buf++ = '0'; 
		*buf++ = '\0';
		return; 
	} 
	exp2 = (unsigned char)(x.L >> 23) - 127; 
	mantissa = (x.L & 0xFFFFFF) | 0x800000; 
	frac_part = 0; 
	int_part = 0; 
	if((exp2 >= 31) || (exp2 < -23))
	{ 
		*buf++ = 'n'; 
		*buf++ = 'a'; 
		*buf++ = 'n'; 
		*buf++ = '\0';
		return;
	} 
	else if(exp2 >= 23) 
		int_part = mantissa << (exp2 - 23); 
	else if(exp2 >= 0) 
	{ 
		int_part = mantissa >> (23 - exp2); 
		frac_part = (mantissa << (exp2 + 1)) & 0xFFFFFF; 
	} 
	else
		frac_part = (mantissa & 0xFFFFFF) >> -(exp2 + 1); 
	if(x.L < 0) 
		*buf++ = '-'; 
	if(int_part == 0) 
		*buf++ = '0'; 
	else 
	{ 
		ltoa(buf, int_part, 10); 
		while(*buf) 
			buf++; 
	} 
	if((frac_part != 0) && (max != 0)) 
	{ 
		char m; 
		*buf++ = '.'; 
		for(m = 0; m < max; m++) 
		{ 
			frac_part = (frac_part << 3) + (frac_part << 1); 
			*buf++ = (frac_part >> 24) + '0'; 
			frac_part &= 0xFFFFFF; 
		} 
		for(--buf; buf[0] == '0' && buf[-1] != '.'; --buf); 
			++buf; 
	} 
	*buf = '\0'; 
} 
#endif /* MCF5445X */

/****************************************************************/
char *strchr(const char *s, int c)
{
  while(*s && (*s != (char)c))
    s++;
  return(*s ? (char *)s : NULL);
}

/****************************************************************/
int memcmp(const void *s1, const void *s2, long size)
{
  char *src1, *src2;
  src1 = (char *)s1;
  src2 = (char *)s2;
  while(--size >= 0)
  {
    if(*src1++ != *src2++)
      return(src1[-1] < src2[-1] ? -1 : 1);
  }
  return(0);
}

/****************************************************************/
static int str_cmp(const char* s1, const char *s2)
{
  while(*s1 && *s2)
  { 
    if(*s1++ != *s2++)
    return(s1[-1] < s2[-1] ? -1 : 1);
  }
  return(0);
}

/****************************************************************/
char *strstr(const char *s1, const char *s2)
{
  char *p = (char *)s1;
  while((p != NULL) && *p)
  {
    p = strchr(p, *s2);
    if(p != NULL)
    {
      if((str_cmp(p, s2) == 0) && (strlen(p) >= strlen(s2)))
        return(p);
      p++;
    }
  }
  return(NULL);
}

