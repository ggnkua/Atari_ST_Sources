
#define MAXEC	40

static char *f_buf;
static int f_upper;

static char ec_buf[MAXEC+10];
static int ec_sign, ec_exp;

fp_print(x, fmtc, prec, ptmp)
float x;
char *ptmp;
{
	f_buf = ptmp;
	f_upper = 0;

	switch (fmtc) {
	case 'E':
		f_upper = 1;
	case 'e':
		e_print(x, prec);
		break;
	case 'F':
	case 'f':
		f_print(x, prec);
		break;
	case 'G':
		f_upper = 1;
	case 'g':
		g_print(x, prec);
		break;
	}
}

static
e_print(x, prec)
float x;
{
	int nsig;
	register char *p;

	if (prec < 0)
		nsig = 7;
	else
		nsig = prec+1;

	ec_pr(x, nsig, 0);

	p = f_buf;
	if (ec_sign)
		*p++ = '-';
	*p++ = ec_buf[0];
	*p++ = '.';
	if (nsig > 1)
		strcpy(p, &ec_buf[1]);
	p += strlen(p);
	*p++ = f_upper ? 'E' : 'e';
	ec_exp--;
	if (ec_exp < 0) {
		*p++ = '-';
		ec_exp = -ec_exp;
	}
	if (ec_exp < 10)
		*p++ = '0';
	sprintf(p, "%d", ec_exp);
}

static
f_print(x, prec)
float x;
{
	int nsig, nz, i;
	register char *p;

	if (prec < 0)
		nsig = 6;
	else
		nsig = prec;

	ec_pr(x, -nsig, 0);

	p = f_buf;
	if (ec_sign)
		*p++ = '-';
	if (ec_exp < 1) {
		*p++ = '0';
	} else {
		strncpy(p, ec_buf, ec_exp);
		p += ec_exp;
	}
	if (prec != 0 || nsig)
		*p++ = '.';
	if (nsig == 0) {
		*p = 0;
		return;
	}

	if (ec_exp < 0) {
		nz = -ec_exp;
		if (nz > nsig)
			nz = nsig;
		for (i=0; i<nz; i++)
			*p++ = '0';
		nsig -= nz;
		if (nsig > 0) {
			strncpy(p, ec_buf, nsig);
			p += nsig;
		}
		*p = 0;
	} else {
		strcpy(p, &ec_buf[ec_exp]);
	}
}

static
g_print(x, nsig)
float x;
{
	int prec;

	if (nsig < 0)
		nsig = 6;
	if (nsig < 1)
		nsig = 1;

	ec_pr(x, 1, 1);

	if (ec_exp < -3 || ec_exp > nsig)
		e_print(x, nsig-1);
	else {
		prec = nsig - ec_exp;
		f_print(x, prec);
	}
}

/*
 * given x, ndig
 *	if ndig is > 0, indicates number of significant digits
 *	else -ndig is number of digits we want to the right of dec. pt.
 * return the following:
 *	appropriate number of digits of significance in ec_buf
 *	ec_sign true if x was negative
 *	ec_exp indicates the decimal point relative to leftmost digit
 */
static
ec_pr(x, ndig, trunc)
float x;
{
	int isneg;
	int nhave;
	long part;
	int exp, newexp;
	float rem;
	char tbuf[20];

	/* ndig must be >= 1 and <= MAXEC */
	if (x < 0.0) {
		isneg = 1;
		x = -x;
	} else
		isneg = 0;

	/* get some digits */
	somedig(x, &part, &rem, &exp);

	sprintf(ec_buf, "%ld", part);
	nhave = strlen(ec_buf);
	exp = nhave + exp;

	if (ndig <= 0) {
		ndig = -ndig;
		ndig += exp;
	}

	if (ndig < 1)
		ndig = 1;
	else if (ndig > MAXEC)
		ndig = MAXEC;

	/* get some more digits */
	while (nhave < ndig+1 && nhave < MAXEC) {
		if (rem == 0.0) {
			while (nhave < ndig+1)
				ec_buf[nhave++] = '0';
			ec_buf[nhave] = 0;
			break;
		}

		x = rem;
		somedig(x, &part, &rem, &newexp);

		sprintf(tbuf, "%ld", part);
		newexp = strlen(tbuf) + newexp;
		while (newexp++)
			ec_buf[nhave++] = '0';
		strcpy(&ec_buf[nhave], tbuf);
		nhave = strlen(ec_buf);
	}

	fround(ndig, trunc);
	ec_sign = isneg;
	ec_exp = exp;
}

static
fround(n, trunc)
{
	char *p;

	p = &ec_buf[n];
	if (*p >= '5' && !trunc) {
		p--;
		while (p >= ec_buf) {
			*p += 1;
			if (*p < '9')
				goto done;
			*p = '0';
			p--;
		}
		ec_buf[0] = '1';
	}
done:
	ec_buf[n] = 0;
}

static
somedig(x, lp, remp, expp)
float x;
long *lp;
float *remp;
int *expp;
{
	int bexp, dexp;
	long ipart;
	float rem;

	bexp = fgetexp(x);
	dexp = 0;

	while (bexp > 31) {
		x *= 1E-3;
		dexp += 3;
		bexp = fgetexp(x);
	}
	while (bexp < 10) {
		x *= 1E3;
		dexp -= 3;
		if (dexp < -24) {
			ipart = 0;
			dexp = 0;
			rem = 0.0;
			goto iszero;
		}
		bexp = fgetexp(x);
	}
	fsplit(x, &ipart, &rem);
iszero:
	*lp = ipart;
	*remp = rem;
	*expp = dexp;
}

static
fgetexp(x)
float x;
{
	char *p;
	int i;

	p = (char *)&x;
	i = p[3] & 0x7f;
	i -= 0x40;
	return i;
}

static
fsplit(x, vp, rp)
float x, *rp;
long *vp;
{
	long ival;
	float rem;
	int bexp, neg;

	ival = *(long *)&x;
	neg = ival & 0x80;
	ival &= ~0xff;

	bexp = fgetexp(x);

	if (bexp < 1) {
		ival = 0;
		rem = x;
	} else {
		ival = (unsigned long)ival >> (32-bexp);
		if (neg)
			ival = -ival;
		rem = x - (float)ival;
	}

	*vp = ival;
	*rp = rem;	
}
