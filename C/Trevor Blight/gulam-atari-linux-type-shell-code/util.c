/*
	util.c of Gulam -- simple utility routines

	Copyright (c) 1987 pm@Case
*/

/* 890111 kbad	Made aborting things a LOT easier by checking inside "eachline"
*/

#include "gu.h"

#ifdef STANC
# define P_(s) s
#else
# define P_(s) ()
#endif
local uchar *escapedchar P_((uchar *p, int *ip));
#undef P_

uchar	hex[17]		= "0123456789abcdef";
uchar	CRLF[]		= "\r\n";
uchar	ES[]		= {'\0', '\0'};	/* two zero-bytes; empty string	*/


panic(s)
register char *s;
{
	gputs("fatal situation in Gulam:"); gputs(s);
	ggetchar();
	exit(-1);	
}

/* Bitwise-OR the 256-char long array a to v for the chars in s.  */

charor(a, s, v)
register uchar	*a, *s;
register uint	v;
{	register int	i;

	while (i = (int) (*s++)) a[i] |= (uchar) v;
}

/* Set the 256-char long array a to all v (which is either 0 or 1) for
the chars in s; the rest to 1-v.  */

charset(a, s, v)
register uchar	*a, *s;
register uint	v;
{	register uchar	*p, u;
	register int	i;

	u = (uchar) (v? 0 : 1);	/* more robust than 1 - v	*/
	for (p=a+256; p > a; ) *--p = u;
	while (i = (int) *s++) a[i] = (uchar) v;
}

#ifndef MWC

/* Copy n bytes from s to d; these are either disjoint areas, or d is < s.
*/
cpymem(d, s, n)
register uchar	*d, *s;
register int	n;
{
#ifndef MGMX
	if (d && s) 
		while (n--) *d++ = *s++;
	else	panic("cpymem");
#else
	if (d && s) 
	asm {	tst	n
		ble	ret
		subq	#1, n
	lp:	move.b	(s)+, (d)+
		dbf	n, lp
	ret:
	}
	else	panic("cpymem");
#endif
}
#endif	MWC


/* Growing arrays: #elements increases, can't predict the max, and
want to use as little space as possible.  */

#if 00
typedef	struct	GA
{	int	ne;		/* #elements in the array		*/
	int	na;		/* #elements allocated			*/
	int	sz;		/* size (in bytes) of an element	*/
	int	ni;		/* size of increment			*/
	uchar	el[0];		/* elements themselves			*/
}	GA;
#endif


	GA *
initga(z, i)
register int	z, i;
{	register GA	*a;

	if (z <= 0 || i <= 0) return NULL;
	if (a = (GA *) gmalloc(((uint)sizeof(GA)) + i*z))
		{a->sz = z; a->ne = 0; a->na = a->ni = i;};
	return a;
}

	GA *
addelga(ga, e)
register GA	*ga;
register uchar	*e;
{	register GA	*a;
	register int	n, z;

	if (ga && e)
	{	z = ga->sz;
		if (ga->ne == ga->na)
		{	n = (ga->na) * z + ((uint)sizeof(GA));
			if (a = (GA *) gmalloc(n + (ga->ni) * z))
			{	cpymem(a, ga, n);  gfree(ga);
				ga = a; ga->na += ga->ni;
			} else	return ga;
		}
		cpymem(ga->el + (ga->ne)*z, e, z);
		ga->ne ++;
	}
	return ga;
}

/******    WS related functions.
ws->ns == #stringlets;
ws->ps == pt to the beginning of the block of mem that contains these;
ws->nc == length of this block;
ws->sz == allocated size of mem for such use.
Stringlets are numbered 0 to ws->ns - 1.
*/

	WS *
initws()
{	register WS	*ws;

	if (ws = (WS *) gmalloc(((uint)sizeof(WS))))
	{	if (ws->ps = gmalloc(Iwssz))
		{	ws->sz = Iwssz;
			ws->nc = ws->ns = 0;
			ws->ps[0] = ws->ps[1] = '\000';
		} else { gfree(ws); ws = NULL;}
	}
	return ws;
}

freews(ws)
register WS	*ws;
{
	if (ws) {gfree(ws->ps); gfree(ws);}
}

#if 00	/* unused */

	WS *
dupws(ws)
register WS	*ws;
{	register WS	*w2;

	if (ws == NULL) return NULL;
	w2 = (WS *) gmalloc(((uint)sizeof(WS)));
	if (w2)
	{	if (w2->ps = gmalloc(ws->nc))
		{	w2->sz = w2->nc = ws->nc; w2->ns = ws->ns;
			cpymem(w2->ps, ws->ps, ws->nc);
		} else	{gfree(w2); w2 = NULL;}
	}
	return w2;
}
#endif

	int
findstr(q, p)
register WSPS	q;
register uchar	*p;
{	register int	n;

	if (p && q)
	{	for (n = 0; *q; q += strlen(q) + 1)
		{	if (strcmp(p, q) == 0) return n;
			n++;
	}	}
	return -1;
}

/* Return ptr to n-th stringlet from p.  Stringlets are numbered 0 to
ws->ns - 1.  */

	uchar	*
nthstr(p, n)
register WSPS	p;
register int	n;
{
	if ((n < 0) || (p == NULL)) return ES;
	for (n++; --n && *p; ) p += strlen(p) + 1;
	return p;
}

/* Cat the stringlets in p, starting from the m-th, with ' ' as
separator,and return the result.  (Just replace all but the last '\0'
with ' '.) */

	uchar *
catall(ws, m)
register WS	*ws;
register int	m;
{	register uchar	*p, *q;
	register int	n;

	if (ws == NULL || 0 > m || m >= (n = ws->ns)) return ES;
	q = p = nthstr(ws->ps, m);	/* m < n */
	while (++m < n)
	{	p += strlen(p);
		*p++ = ' ';
	}
	return q;
}

/* Append to ws->ps the string p, and then one more '\0' if i == 1.
The value of i is either 1, or 0.  */

strwcat(ws, p, i)
register WS	*ws;
register uchar	*p;
register int	i;
{	register int	n;
	register uchar	*q;

	if (p==NULL || ws==NULL) return; if (i) i = 1;
	n = strlen(p) + ws->nc;
	if (ws->sz <= n+i)
	{	if (q = gmalloc(n + Iwssz))
		{	cpymem(q, ws->ps, ws->nc); gfree(ws->ps);
			ws->ps = q;
			ws->sz = n + Iwssz;
		}else	return;
	}
	if (q = ws->ps)
	{	strcpy(q+ws->nc, p); q[n+i] = '\000';
		ws->nc = n+i;
		if (i) ws->ns ++;
	}
}

/* Columnize the 'string' r.  If ns >= 0, r is in argv[] format, ns ==
#stringlets in r, cw == length of longest stringlet in r.  If ns < 0,
these values are to be computed by this routine, and r is in WSPS
format; we don't set cw initially to 0 because this permits the caller
to set it at a minimum.  pf is a ptr to a function that computes
one-char based on its argument string; this char can be '\0'.  */

	uchar *
pscolumnize(r, ns, cw)
uchar	*r;
int	ns, cw;
{	register uchar	*p, *q, *qq, **aa;
	register int	i, m, n, nc, nr;	/* #col per line, #rows */
	extern   int	screenwidth;

	if (r == NULL) return NULL;
	if (ns < 0)
	{	ns = 0; aa = NULL;	/* compute cw */
		for (p=r; *p; p += n+1)
		{	n = strlen(p);
			if (n > cw) cw = n;
			ns ++;
		}
		cw ++;	/* at least one blank as a separator */
	} else  aa = (uchar **) r;

	nc = (screenwidth-2)/cw;	if (nc <= 0) nc = 1;
	nr = (ns + nc -1)/nc;

	/* allocates more than nec, but	this is ok; we free this soon	*/
	q = qq = gmalloc(1+ns*(cw+2));
	if (q)
	{	for (n=0; n < nr; n++)
		{	for (m=0; m < nc; m++)
			{	i = m*nr + n;  if (i >= ns) break;
 				p = (aa? aa[i] : nthstr(r, i));
				for (i=0; *q++ = *p++;) i++;
				q[-1] = ' ';
				if (m < nc-1)
					while (++i < cw) *q++ = ' ';
			}
			*q++ = '\r'; *q++ = '\n';
		}
		*q = '\000';
	}
	return qq;
}

/* Make a new ws which has the stringletes of WSPS q each prefixed with p
*/
	WS *
prefixws(p, q)
register uchar	*p;
register WSPS	q;
{
	register WS	*w;

	w = initws();
	if (w && q)
	{	while (*q)
		{	strwcat(w, p, 0);  strwcat(w, q, 1);
			q += strlen(q) + 1;
	}	}
	return w;
}

/* Append stringlets m..  upwards of v to u */

appendws(u, v, m)
register WS	*u, *v;
register int	m;
{	register int	n;
	register uchar	*p;

	if (u == NULL || v == NULL) return;
	n = v->ns; p = v->ps;  if (m < 0 || n < m || p == NULL) return;
	p = nthstr(p, m);
	while (m++ < n)
	{	strwcat(u, p, 1);
		p += strlen(p) + 1;
	}
}

/* Shift the stringlets left by losing the (m-1)-th one.  */

shiftws(ws, m)
register WS	*ws;
register int	m;
{	register uchar	*q;
	register int	n, k;

	if (ws==NULL || m > ws->ns || m <= 0) return;
	q = nthstr(ws->ps, m-1); n = strlen(q) + 1;
	k = ws->nc - (int)(q - ws->ps);
	cpymem(q, q+n, k);
	ws->ns --;
	ws->nc -= n;
}

#ifdef DEBUG

/* Show the wsps p */

showwsps(p)
register WSPS	p;
{	register uchar	*q;

	if (p == NULL) {outstr("showwsps arg is NULL"); return;}
	q = pscolumnize(p, -1, 0);
	if (q) {outstr(q); gfree(q);}
}
#endif

static	uchar	bschar[256] =
{	'\000', '\001', '\002', '\003', '\004', '\005', '\006', '\007', 
	'\010', '\011', '\012', '\013', '\014', '\015', '\016', '\017', 
	'\020', '\021', '\022', '\023', '\024', '\025', '\026', '\027', 
	'\030', '\031', '\032', '\033', '\034', '\035', '\036', '\037', 
	'\040', '\041', '\042', '\043', '\044', '\045', '\046', '\047', 
	'\050', '\051', '\052', '\053', '\054', '\055', '\056', '\057', 
	'\060', '\061', '\062', '\063', '\064', '\065', '\066', '\067', 
	'\070', '\071', '\072', '\073', '\074', '\075', '\076', '\077', 
	'\100', '\101', '\b'  , '\103', '\104', '\033', '\014', '\107', 
	'\110', '\111', '\112', '\113', '\114', '\115', '\n'  , '\117', 
	'\120', '\121', '\r'  , '\123', '\t'  , '\125', '\v'  , '\127', 
	'\130', '\131', '\132', '\133', '\134', '\135', '\136', '\137', 
	'\140', '\141', '\b',   '\143', '\144', '\145', '\146', '\147', 
	'\150', '\151', '\152', '\153', '\154', '\155', '\n'  , '\157', 
	'\160', '\161', '\r'  , '\163', '\t'  , '\165', '\v'  , '\167', 
	'\170', '\171', '\172', '\173', '\174', '\175', '\176', '\177', 
	'\200', '\201', '\202', '\203', '\204', '\205', '\206', '\207', 
	'\210', '\211', '\212', '\213', '\214', '\215', '\216', '\217', 
	'\220', '\221', '\222', '\223', '\224', '\225', '\226', '\227', 
	'\230', '\231', '\232', '\233', '\234', '\235', '\236', '\237', 
	'\240', '\241', '\242', '\243', '\244', '\245', '\246', '\247', 
	'\250', '\251', '\252', '\253', '\254', '\255', '\256', '\257', 
	'\260', '\261', '\262', '\263', '\264', '\265', '\266', '\267', 
	'\270', '\271', '\272', '\273', '\274', '\275', '\276', '\277', 
	'\300', '\301', '\302', '\303', '\304', '\305', '\306', '\307', 
	'\310', '\311', '\312', '\313', '\314', '\315', '\316', '\317', 
	'\320', '\321', '\322', '\323', '\324', '\325', '\326', '\327', 
	'\330', '\331', '\332', '\333', '\334', '\335', '\336', '\337', 
	'\340', '\341', '\342', '\343', '\344', '\345', '\346', '\347', 
	'\350', '\351', '\352', '\353', '\354', '\355', '\356', '\357', 
	'\360', '\361', '\362', '\363', '\364', '\365', '\366', '\367', 
	'\370', '\371', '\372', '\373', '\374', '\375', '\376', '\377'
};
	static uchar *
escapedchar(p, ip)
register uchar	*p;
register int	*ip;
{	register int	ic, n;

	ic = p[1];
	if ('0' <= ic && ic <= '9')
	{	for (ic = 0, n = 3; n; n--)
			if ('0' <= *++p && *p <= '9')
					ic = ic*8 + (*p - '0');
	} else
		if (ic) {ic = bschar[ic &0xff]; p++;}
	*ip = ic;
	return p;
}

/* If the string p begins with either ' or " remove them, and convert
^Q-quoted-chars that it has, if any.  The unquoted string is stored
beginning at q.  Often called with q == p; however, if q points to the
middle of p, the src string will be clobbered -- obviously.  Return
ptr to new eos.  */

	uchar *
unquote(q, p)
register uchar	*p, *q;
{	register uchar	c, sdq;
	int	i;

	if (p && q)
	{	if ((sdq = *p) && (sdq == '"' || sdq == '\''))
		{  while (c = *++p)
		   {	if (c == sdq) break;
			if (c == '\021') {p = escapedchar(p, &i); c = i;}
			*q++ = c;
		   }
		   *q = '\000';  /** if (c!=sdq) emsg = "unmatched quote"; **/
		}else
		{	i = strlen(p);
			if (p != q) cpymem(q, p, i+1);
			q += i;
	}	}
	return q;
}

	uchar *
str3cat(p, q, r)	/* return the catenation p|q|r	*/
uchar *p, *q, *r;
{
	register uchar *a, *b;
	uchar *s;

	s = a = ((p && q && r)
		? gmalloc(((uint)(strlen(p) + strlen(q) + strlen(r) + 1)))
		: NULL		);
	if (s)
	{	b = p; while (*a++ = *b++); a--;
		b = q; while (*a++ = *b++); a--;
		b = r; while (*a++ = *b++);
	}
	return s;
}

/* Return ptr to the leftmost occurrence of q in p.  Return NULL if no
match.  */

	uchar *
strsub(p, q)
register uchar   *p, *q;
{	register int	n;

	if (p && q)
	{	for (n = strlen(q); p = index(p, *q); p++)
			if (strncmp(p, q, ((size_t)n)) == 0) break;
	} else p = NULL;
	return p;
}

/*
 * for gcc dont use the lib strdup() as it calls malloc with size_t
 */
#if 0
	uchar *
strdup(p)
register uchar *	p;
{
	register uchar *q;
	
	q = (p ? gmalloc(((uint)strlen(p)) + 1) : NULL);
	if (q) strcpy(q, p);
	return(q);
}
#else
	char *
strdup(p)
register const char *	p;
{
	register char *q;
	
	q = (p ? gmalloc(((uint)strlen(p)) + 1) : NULL);
	if (q) strcpy(q, p);
	return(q);
}
#endif

#ifndef __GNUC__

/* Find length of initial segment of s1 consisting entirely of
characters not from s2.  By Henry Spencer */

strcspn(s1, s2)
uchar *s1;
uchar *s2;
{
	register uchar *scan1;
	register uchar *scan2;
	register int count;

	count = 0;
	for (scan1 = s1; *scan1 != '\0'; scan1++)
	{	for (scan2 = s2; *scan2 != '\0';)	/* ++ moved down. */
			if (*scan1 == *scan2++)
				return(count);
		count++;
	}
	return(count);
}

	uchar *
rindex(p, c)			/* MWC 2.0 has a bug; try: rindex("", c) */
register uchar	*p, c;
{	register uchar	*q;

	for (q = p + strlen(p) - 1; q >= p; q--)
		if (*q == c) return q;
	return NULL;
}
#endif

/* Change case: i == 0 => to lower; i != 0 => upper */

	uchar *
chcase(p, i)
register uchar *	p;
int	i;
{
	register uchar	*q, c;
	register int	lb, ub, d;
	
	if (q = p)
	{	if (i)  {lb = 'a'; ub = 'z'; d = 'a' - 'A';}
		else	{lb = 'A'; ub = 'Z'; d = 'A' - 'a';}
		while (c = *p)
		{	if (lb <= c && c <= ub) c -= d;
			*p++ = c;
	}	}
	return q;
}

atoi(p)
register uchar *p;
{
	return (int) atoir(p, 10);
}

/* Convert string p of digits given in radix r into a long integer */

	long
atoir(p, r)
register uchar	*p;
register int	r;
{	register long	x, d;
	register uchar	c, sign;

	x = 0L;	if (p == NULL) return;
	if (*p == '-') {sign = '-'; p++;} else sign = '+';
	while (c = *p++)
	{	d = r;
		if (r == 16)
		{	if ('A' <= c && c <= 'F') d = (long)(c + 10 - 'A');
			if ('a' <= c && c <= 'f') d = (long)(c + 10 - 'a');
		}
		if ('0' <= c && c <= '9') d = (long) (c - '0');
		if (d >= r) break;
		x = x*r + d;
	}
	if (sign == '-') x = - x;
	return x;
}

/* Convert the given long (32-bit) integer into a digit string in
radix r.  The radix r is one of 2, 8, 10, or 16.  Return a ptr to the
static string.  */

	uchar *
itoar(i, r)
register long	i;
register int	r;
{
	static uchar s[33];
	register uchar	*p, c;

	p = &s[32];
	*p-- = '\000';
	c = '+';
	if (i < 0) { c = '-'; i = -i; }
	do {
		*p-- = hex[i % r];
		i /= r;
	} while (i > 0);
	if (c == '-') *p = c;
	else p++;
	return p;
}

	uchar *
itoa(i)
register long	i;
{
	return itoar(i, 10);
}

/* A small class of printf like format items is handled.  Assumes that
the stack grows down (see ap += ...  in the argument scan loop).
(Should merge mlwrite() of display.c with this.) */

	uchar *
sprintp(fmt, arg)
uchar *fmt;
long arg;
{
	register int c, r;
	register uchar *ap, *p;
	static	uchar ms[1024];

	ap = (uchar *) &arg;	p = ms;
	while (c = *fmt++)
	{  if (c != '%') {*p++ = c; continue;}
           c = *fmt++;	r = 0;
           switch (c)
           {  case 'x': r += 6;
              case 'd': r += 2;
              case 'o': r += 8;
		strcpy(p, itoar((long)(*(int *)ap), r)); p += strlen(p);
		ap += ((uint)sizeof(int));
		break;
              case 'X': r += 6;
              case 'D': r += 2;
              case 'O': r += 8;
		strcpy(p, itoar(*((long *)ap), r)); p += strlen(p);
		ap += ((uint)sizeof(long));
		break;
              case 's':
                    strcpy(p, *(uchar **)ap); p += strlen(p);
                    ap += ((uint)sizeof(uchar *));
                    break;
	      case 'c':
		*p++ = (uchar) (*(int *)ap);
		ap += ((uint)sizeof(int));
		break;
              default: *p++ = c;
            }
        }
	*p = '\000';
	return ms;
}

stackoverflown(n)
register int	n;
{	int		dummy;
	extern long	_stksize;

#if 0
/* this section removed because it doesn't work on */
/* TT with two disjoint memory spaces. */
	if ((long) &dummy < _stksize + (long) n)
	{	emsg = "run-time stack is about to overflow";
		return -1;
	}
#endif
	return 0;
}

/* Read the already Fopen'd file fd into a large buffer, and invoke
the given function on each line of the file.  */


eachline(fd, fn)
int	fd;
int	(*fn)();		/* fn(ptr to bgn of line, len of line) */
{
	register uchar   *q, *r, *be, *bb, *p;
	register long	sz, n;
        register int	i;
	long		asz;

	valu = 0L; emsg = NULL; asz = 19*1024+2;
	bb = maxalloc(&asz); if (bb == NULL) {valu = -39; return;}
	sz = asz - 2;	/* leave 1 byte for '\n' sentinel; make it even 19k */
	for( q = r = bb;
	     !valu && (n = gfread(fd, r, (long) (bb - r + sz))) > 0;
	     q = bb)
	{	be = r + n; be[0] = '\n';  /* sentinels */
		while( !(valu = useraborted()?-1:0) )
		{	for (r = q; *r != '\n';) r++;
			if  (r == be) break;			  /* <== */
			/* between q and r is a whole line */
			if (r[-1] == '\r') {*--r = '\000'; i = 2;}
			else
			{	*r = '\000'; i = 1;
				if (p = index(q, '\r'))
				{	*r = '\n'; r = p; *r = '\000'; 
			}	}
			(*fn)(q, (int)(r - q));
			q = r + i;
		}
		if( !valu ) {
			if (be-q >= sz)
			{	emsg = sprintp(
				"a line with >= %D chars has been split", sz);
				(*fn)(q, (int)(be - q));
				q = be;
			}
			/* move leftover part of ln to bgn of buf */
			for (r=bb; q < be;) *r++ = *q++;
		}
	}
	if (n < 0) {emsg = "File read error"; valu = n;}
	if (n == 0 && bb != r)
	{	emsg = "The last line ended without \\n";
		*r   = '\000';
		(*fn)(q, (int)(r - q));
	}
	gfclose(fd);  maxfree(bb);
}

/* Text contains 0 or more lines.  Invoke the given function on each
line.  */

streachline(text, fn, ap)
	uchar	*text, *ap;
	int	(*fn)();	/* fn(arbitrary ptr ap, ptr to line) */
{
	register uchar	*p, *q, *et, cr;
	register int	d;

	if (text == NULL) return;
	et = text + strlen(text);	*et = '\n';	/* sentinel */
	for (p=text; (p < et) && (q = index(p, '\n')); p = q+1)
	{
		d = usertyped();
		if (d == CTRLS) ggetchar(); /* xon/xoff */
		else if (d == CTRLC) break;

		*q = '\000'; cr = q[-1];  if (cr == '\r') q[-1] = '\000';
		(*fn)(ap, p);
		q[-1] = cr; *q = '\n';	/* restore the line */
	}
	*et = '\000';
}

/* -eof- */
