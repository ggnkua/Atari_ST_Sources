double f_zero = 0.0;
double f_ten = 10.0;
double f_tenth = 0.1;
double f_e10 = 1e10;
double f_em10 = 1e-10;

lclr(lp, n)
long *lp;
{
	while (n--)
		*lp++ = 0;
}

lcpy(top, frp, n)
long *frp, *top;
{
	while (n--)
		*top++ = *frp++;
}
