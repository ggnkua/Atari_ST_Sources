#include	"defs.h"
#include	"comp.h"
#include	"table.h"
#include	"cnvrt.h"

extern	int	unit_type;
extern	double	modf();

/*
	Function to convert unsigned integer to decimal ascii string
	Divisor div specifies how many digits to convert.
*/
utoa(buf,val,div)
char	 *buf;
unsigned val, div;
{
	unsigned t;
	while (div) {
		while ((t = val / div) > 9)
			val -= div * 10;
		*buf++ = (char)t + '0';
		val %= div; div /= 10;
	}
	*buf = 0;
}

/*
	Convert Point (ln) & 1/2 Point (rn) to 1/8 Point values.
	Used for Point Size and Set Size. Valid rn digits are 0 & 5.
*/
unsigned pt12(ln,rn)
unsigned ln, rn;
{
	rn = rn == 5 ? 4:0;
	return((ln * 8) + rn);
}

/*
	Getting Maximum X, Y and Line Space values
*/
getmax(maxx,maxy,maxls)
unsigned *maxx, *maxy, *maxls;
{
	int	ptype;

	ptype = get_pgtype();
	if (setp.omod < 4) {			/* All Typesetters	*/
		*maxx	= (!setp.omod) ? 14688:15120;
		*maxy	= 16128;
		*maxls	= 15996;
	}
	else
	if (setp.omod == 4) {			/* EP308 only		*/
		*maxx	= epxmax[ptype];
	*maxls = *maxy	= epymax[ptype];
	}
	else {					/* Laser only		*/
		*maxx	= pvxmax[ptype];
	*maxls = *maxy	= pvymax[ptype];
	}
	if (*maxls > 15996)
		*maxls	= 15996;		/* 999.3 points max	*/
}

/*
	Conversion of machine unit integer n to Point.1/2 Point string "t".
	Used for Point/Set Size fields.
*/
mu_pt12(n,t)
unsigned n;
char	*t;
{
	utoa(t,n / 8,100);
	*(t += 3) = '.';  
	*(++t) = (n % 8) ? '5':'0';
	*(++t) = 0;  
}

/*
	Conversion of machine unit long integer "n" to Hor. left/right
	values string "t".
	Used for Horizontal measure fields.
*/
mu_hlrv(val,t)
unsigned val;
char	 *t;
{
	double		n, ldiv, rmul, intg;
	unsigned	ln, rn, ldig, rdig;

	n	= (double)val;
	ldiv	= (rmul = (double)hlq[unit_type]) * hrq[unit_type];
	n	/= ldiv;
	n	= modf(n,&intg);
	ln	= (unsigned)intg;
	if (n > 0.0) {
		n	*= rmul;
		n	= modf(n,&intg);
		rn	= (unsigned)intg;
		if (n >= 0.5)
			++rn;
		if (rn >= hlq[unit_type])
		{ rn = 0; ++ln; }
	}
	else	rn = 0;
	if (unit_type == 2)			/* for metric	*/
		ldig = 100, rdig = 1;		/* show XXX.X	*/
	else	ldig = 10,  rdig = 10;		/* show XX.XX	*/
	setdspf(t,ln,rn,ldig,rdig);
}

/*
	Conversion of machine unit long n to Vert. left/right values
	string "t".
	Used for Vertical measure fields.
*/
mu_vlrv(val,t)
unsigned val;
char	*t;
{
	double		n, ldiv, rmul, intg;
	unsigned	ln, rn, ldig, rdig;

	n	= (double)val;
	ldiv	= (rmul = (double)vlq[unit_type]) * vrq[unit_type];
	n	/= ldiv;
	n	= modf(n,&intg);
	ln	= (unsigned)intg;
	if (n > 0.0) {
		n	*= rmul;
		n	= modf(n,&intg);
		rn	= (unsigned)intg;
		if (n >= 0.5)
			++rn;
		if (rn >= vlq[unit_type])
		{ rn = 0; ++ln; }
	}
	else	rn = 0;
	if (unit_type == 0)			/* for inches	*/
		ldig = 10,	rdig = 10;	/* show XX.XX	*/
	else	ldig = 100,	rdig = 1;	/* show XXX.X	*/
	setdspf(t,ln,rn,ldig,rdig);
}

/*
	Routine to setup display string in the format of ldig.rdig
*/
static	setdspf(t,ln,rn,ldig,rdig)
char	*t;
int	ln, rn, ldig, rdig;
{
	char	r[4];

	utoa(t,ln,ldig);
	utoa(r,rn,rdig);
	strcat(t,".");
	strcat(t,r);
}

/*
	Routine to calculate character width from relative width
*/
unsigned cwfrw(rw,k)
unsigned char	rw, k;
{
	unsigned long	temp;
	int		temp1;

	temp	= k ? (long)smsz:(long)cp.ssiz;
	temp	*= (long)rw;
	temp1	= (int)(temp / 24L);
	if ((temp % 24L) >= 12L) ++temp1;
	return(temp1);
}

/*
	Routine to get from font width table font data
*/
unsigned char getfd(ofs,fp)
unsigned	ofs, fp;
{
	return(*(pftpt+ofs+(fp * 2)));
}

/*
	Function to calculate the character width of argument flash position
	If any Character Compensation is ON, substract it from width.
	Returns -1 if character has no width.
*/
unsigned cwffp(fp)
unsigned char	fp;
{
	unsigned	cw;
	unsigned char	rw;

	if ((rw = getfd(49,fp)) == 0xff)
		cw = -1;
	else {
		cw = cwfrw(rw,0);
		if (cp.mcomp) {
		  if (cw > cmpval)
			cw -= cmpval;
		  else	cw = 0;
		  cmpval = cp.mcomp;
		}
		if (cp.acomp) {
		  if (cw > avcval)
			cw -= avcval;
		  else	cw = 0;
		  avcval = acmp;
		}
	}
	return(cw);
}

/*
	Routine to get flash position from text character
*/
unsigned char getfp(c)
unsigned char	c;
{
	unsigned	i;
	unsigned char	fp;

	if (c == TSP)	fp = 119;
	else
	if (c == NSP)	fp = 120;
	else
	if (c == MSP)	fp = 121;
	else
	if ((fp = ptsfpos[c]) == 0xfe)
	for (i = 0;i < 303;i += 3)
		if (mcsdbl[i] == c)
		{ fp = mcsdbl[i+2]; break; }
	return(!fp || fp > 121 ? 0xff:fp);
}

/*
	Function to calculate the character width from text character
	Returns -1 if character undefined (no flash position).
*/
unsigned cwidth(c)
unsigned char	c;
{
	return((c = getfp(c)) == 0xff ? -1:cwffp(c));
}

/*
	Function to calculate the automatic variable character
	compensation value.
	i  --	0	Loosest
		1	Medium
		2	Tight
	sz --	Set size value
*/
aucomp(i,sz)
unsigned char	i;
unsigned	sz;
{
	int	temp, temp1, temp2;

	if (!avcc[i].var) return(0);
	temp2 = sz >> 3;
	if (!(temp2 -= avcc[i].zpt) ||
	    !(temp1 = 72 - avcc[i].zpt))
		return(0);
	temp2 *= avcc[i].var;
	temp  = temp2 / temp1;
	if (temp <= 0)
		return(0);
	temp2 %= temp1;
	if (temp2 >= (temp1 / 2)) ++temp;
	return(temp * 2);
}

/*
	Routine to get/load the AVCC value depending on
	the current font, auto comp. mode and set size.
*/
ldacmp()
{
	if (cp.acomp)
		acmp = aucomp(cp.acomp - 1,cp.ssiz);
	else	acmp = 0;
}

/*
	Routine to get from font width table AVCC data
	of current font.
*/
loadavcc()
{
	unsigned	i;
	unsigned char	*ptr, *bptr;

	ptr	= pftpt + 35;			/* point to avcc flag	*/
	bptr	= pftpt + 36;			/* point to kern flag	*/
	kpptr	= pftpt + 779;			/* point to kern data	*/
	txkn	= (*(bptr) & 0x0e);		/* check any kerning	*/
	if (*(bptr) & 0x08)			/* kern pairs present ?	*/
		kpval = get_argument(pftpt + 777);	/* ok get count	*/
	else	kpval = 0;
	if (!(*ptr & 0x01)) {			/* no Avcc clear vars	*/
	  for (i = 0;i < 4;++i)
		avcc[i].zpt = avcc[i].var = 0;
	}
	else {					/* else load them...	*/
	  ptr += 2;
	  for (i = 0;i < 4;++i) {
		avcc[i].zpt = *(ptr++);
		avcc[i].var = *(ptr++);
	  }
	}
}

/*
	Routine to get from font width table sector Kerning data
	of character c.
*/
getkerval(c,ker)
unsigned char	c, ker;
{
	unsigned char	*ptr;
	unsigned	idx, i;

	kern[ker].ch = c;
	idx = 289 + (unsigned)c * 4;
	ptr = pftpt + idx;
	for (i = 0;i < 4;++i) {
		kern[ker].rval[i] = *ptr & 0x0f;
		kern[ker].lval[i] = *ptr++ >> 4;
	}
}

/*
	Routine to compute the actual sector Kerning value
	of the character pair in the KERN structure.
*/
cmpknval()
{
	unsigned char	min=127, *ptr;
	unsigned	i, found;

	for (i = 0;i < 4;++i) {
	  kern[0].rval[i] += kern[1].lval[i];
	  if (min > kern[0].rval[i])
		min = kern[0].rval[i];
	}
	if (kpval) {
	  ptr = kpptr;
	  found = i = 0;
	  while (i < kpval && !found) {
	    if (kern[0].ch == *ptr &&
		kern[1].ch == *(ptr+1)) {
		found = 1;
		min += *(ptr+2);;
	    }
	    ptr += 3; ++i;
	  }
	}
	if (min) {
	  if (min > 127) {
		min = ~min + 1;
		return(0 - cwfrw(min,0));
	  }
	  else	return(cwfrw(min,0));
	}
	else	return(0);
}



/*
	Conversion of machine unit long integer "n" to Hor. left/right
	values string "t".
	Used for Horizontal measure fields.
*/
imu_hlrv(val,t)
int 	val;
char	*t;
{
	double	n, ldiv, rmul, intg;
	int	ln, rn, ldig, rdig;
	int	flag;

	flag = 0;
	if(val < 0)
	{
	    val = -val;
	    flag = 1;
	}

	n	= (double)val;
	ldiv	= (rmul = (double)hlq[unit_type]) * hrq[unit_type];
	n	/= ldiv;
	n	= modf(n,&intg);
	ln	= intg;
	if (n > 0.0) {
		n	*= rmul;
		n	= modf(n,&intg);
		rn	= intg;
		if (n >= 0.5)
			++rn;
		if (rn >= hlq[unit_type])
		{ rn = 0; ++ln; }
	}
	else	rn = 0;
	if (unit_type == 2)			/* for metric	*/
		ldig = 100, rdig = 1;		/* show XXX.X	*/
	else	ldig = 10,  rdig = 10;		/* show XX.XX	*/
	isetdspf(t,ln,rn,ldig,rdig,flag);
}

/*
	Conversion of machine unit long n to Vert. left/right values
	string "t".
	Used for Vertical measure fields.
*/
imu_vlrv(val,t)
int	 val;
char	 *t;
{
	double	n, ldiv, rmul, intg;
	int	ln, rn, ldig, rdig;
	int	flag;

	flag = 0;
	if(val < 0)
	{
	    val = -val;
	    flag = 1;
	}

	n	= (double)val;
	ldiv	= (rmul = (double)vlq[unit_type]) * vrq[unit_type];
	n	/= ldiv;
	n	= modf(n,&intg);
	ln	= intg;
	if (n > 0.0) {
		n	*= rmul;
		n	= modf(n,&intg);
		rn	= intg;
		if (n >= 0.5)
			++rn;
		if (rn >= vlq[unit_type])
		{ rn = 0; ++ln; }
	}
	else	rn = 0;
	if (unit_type == 0)			/* for inches	*/
		ldig = 10,	rdig = 10;	/* show XX.XX	*/
	else	ldig = 100,	rdig = 1;	/* show XXX.X	*/
	isetdspf(t,ln,rn,ldig,rdig,flag);
}



static	isetdspf(t,ln,rn,ldig,rdig,flag)
char	*t;
int	ln, rn, ldig, rdig;
int	flag;
{
	char	r[4];
	char *b;

	b = t;
	if(flag)
	     strcpy(b++,"-");
	utoa(b,ln,ldig);
	utoa(r,rn,rdig);
	strcat(t,".");
	strcat(t,r);
}
