#include "extern.h"

/* ---------------------
	 | Make oversampling |
	 --------------------- */
void do_oversam(void)
{
if (ovsm_typ == 3)
	oversamp3();
else
	oversamp2();

total >>= 1;
o_bytes = realloc(o_bytes, total + 6L);
}

/* ----------------------------------
	 | Make oversampling with 3 Bytes |
	 ---------------------------------- */
void oversamp3(void)
{
long i;
char *s, *d;
int z1, z3;

d = s = (char *)o_bytes;
d++;
z1 = (int)*(s++);

for (i = 0; i < total; i++)
	{
	z3 = (int)s[1];

	*(d++) = (unsigned char)((z1 + (int)s[0] + z3) / 3);
	s += 2;
	z1 = z3;
	}
}

/* ----------------------------------
	 | Make oversampling with 2 Bytes |
	 ---------------------------------- */
void oversamp2(void)
{
long i;
char *s, *d;

d = s = (char *)o_bytes;

for (i = 0; i < total; i++)
	*(d++) = (unsigned char)( ((int)*(s++) + (int)*(s++)) >> 1);
}

