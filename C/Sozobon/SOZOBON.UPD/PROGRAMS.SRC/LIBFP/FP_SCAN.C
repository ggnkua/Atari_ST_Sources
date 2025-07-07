double
fp_scan(neg, eneg, ipart, fpart, epart, flen)
long ipart, fpart, epart;
{
	double val, fmul, fexp;

	val = ipart;

	fmul = 1.0;
	while (flen--)
		fmul *= .1;
	val += fmul*(double)fpart;

	if (epart) {
		fmul = 1.0;
		if (eneg)
			fexp = 1e-10;
		else
			fexp = 1e10;
		while (epart >= 10) {
			fmul *= fexp;
			epart -= 10;
		}
		if (eneg)
			fexp = 1e-1;
		else
			fexp = 1e1;
		while (epart--)
			fmul *= fexp;
		val *= fmul;
	}

	if (neg)
		val = -val;

	return val;
}
