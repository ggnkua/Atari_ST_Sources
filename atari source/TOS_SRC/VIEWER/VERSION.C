#include <string.h>

char *
version(void)
{
static char v[12];
	if (!v[0])
	{
				/* Mmm DD YYYY HH:MM:SS */
		char *dt = __DATE__ " " __TIME__;
		char *m = "???JanFebMarAprMayJunJulAugSepOctNovDec";
		int mn;
		for (mn = 12*3;
			 mn && (m[mn] != dt[0] || m[mn+1] != dt[1] || m[mn+2] != dt[2]);
			 mn -= 3)
		;
		mn /= 3;
		v[0] = dt[9];
		v[1] = dt[10];
		v[2] = '0'+mn/10;
		v[3] = '0'+mn%10;
		v[4] = dt[4] | 0x10;
		v[5] = dt[5];
		v[6] = '-';
		v[7] = dt[12];
		v[8] = dt[13];
		v[9] = dt[15];
		v[10] = dt[16];
	}
	return v;
}

char *
menuname(void)
{
static char name[81];
	if (!name[0])
		strcat(strcpy(name, "  Viewer "), version());
	return name;
}
