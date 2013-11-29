#include "extern.h"

/* ---------------------
	 | Make oversampling |
	 --------------------- */
void do_oversam(void)
{
int i;

i = search_topsw();
if (i == -1)
	return;

switch (ovsm_typ)
	{
	case 2:
		overshift(samples[i]->data, samples[i]->len);
		break;

	case 1:
		oversamp3(samples[i]->data, samples[i]->len);
		break;

	case 0:
		oversamp2(samples[i]->data, samples[i]->len);
		break;
	}

samples[i]->len >>= 1;
samples[i] = realloc(samples[i], sizeof(SOUND) + samples[i]->len + 6L);
samples[i]->data = (char *)samples[i] + sizeof(SOUND);

strcpy(samples[i]->smp_info, " L„nge: ");
ltoa(samples[i]->len, samples[i]->smp_info + 8, 10);
wind_set(samples[i]->w_handle, WF_NAME, samples[i]->smp_name);
wind_set(samples[i]->w_handle, WF_INFO, samples[i]->smp_info);

force_wredraw(samples[i]->w_handle);
}

/* ----------------------------------
	 | Make oversampling with 3 Bytes |
	 ---------------------------------- */
void oversamp3(char *o_bytes, long total)
{
long i;
char *s, *d;
int z1, z3;

d = s = (char *)o_bytes;
d++;
z1 = (int)*(s++);

total >>= 1;
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
void oversamp2(char *o_bytes, long total)
{
long i;
char *s, *d;

d = s = (char *)o_bytes;

total >>= 1;
for (i = 0; i < total; i++)
	*(d++) = (unsigned char)( ((int)*(s++) + (int)*(s++)) >> 1);
}

/* ----------------------------------
	 | Make oversampling with 2 Bytes |
	 ---------------------------------- */
void overshift(char *o_bytes, long total)
{
long i;
char *s, *d;

d = s = (char *)o_bytes;

total >>= 1;
for (i = 0; i < total; i++, s += 2)
	*(d++) = *s;
}

