#include "extern.h"

#define cabs(a) ((a<0) ? -a : a)

static frq_max;

/* -------------------------
	 | Remove bad frequences |
	 ------------------------- */
void kill_bads(long *p_data, long *o_data, int len)
{
int i, l = len / 2, c;
int l_merk, c_merk, l_pct;
long cmp, l_maxp;

if (!maxp)
	return;
	
if (flt_ovsm)
	l >>= 1;

l_maxp = 0L;
for (i = l/2; i < l; i++)
	if (p_data[i] <= maxp / 2)
		if (p_data[i] > l_maxp)
			l_maxp = p_data[i];

if (!l_maxp)
	return;
	
c_merk = 0;
l_merk = 0;
c = 0;
l_pct = (int)(p_data[0] * 20L / l_maxp);
for (i = l/2; i < l; i++)
	{
	if (p_data[i] * 20L / l_maxp == l_pct)
		c++;
	else
		{
		if (c > c_merk)
			{
			c_merk = c;
			l_merk = i - c;
			}
		c = 0;
		l_pct = (int)(p_data[i] * 20L / l_maxp);
		}
	}

if (c > c_merk)
	{
	c_merk = c;
	l_merk = i - c;
	}

if (l_merk > l - (l_merk + c_merk) && c_merk > l/6)
	{
	for(i = l_merk; i < l; i++)
		{
		o_data[i] = 0;
		p_data[i] = 0;
		o_data[len - i] = 0;
		}
	}

cmp = maxp * 450L / 3000L; 			/* 450 = 0.15 * 3000 */
for (i = 1; i < l - 2; i++)
	if (p_data[i] > cmp)
		if (p_data[i - 1] * 100L / p_data[i] < 15L
				&& 	p_data[i + 1] * 100L / p_data[i] < 15L)
			{
			p_data[i] = 0;
			o_data[i] = 0;
			o_data[len - i] = 0;
			}
}

/* ------------------
	 | Analyse maxima |
	 ------------------ */
void analyse_maxsmp(char *o_bytes, long total)
{
long i;
char c;

frq_max = 0;
for (i = 0; i < total; i++)
	{
	c = cabs(o_bytes[i]);
	frq_max = (c > frq_max) ? c : frq_max;
	}
}

/* -----------------------
	 | Frequenzen absenken |
	 ----------------------- */
void frq_sink(long *p_data, long *o_data, int len)
{
int i;

if (frq_max > 100)
	{
	for (i = 0; i < len / 2; i++)
		{
		p_data[i] = p_data[i] * 100 / frq_max;
		o_data[i] = o_data[i] * 100 / frq_max;
		o_data[len - i] = o_data[len - i] * 100 / frq_max;
		}
	}
}

/* ----------------------
	 | flatten frequences |
	 ---------------------- */
void flatten(long *p_data, long *o_data, int len)
{
int l;

l = len / 8;
while(l > -1)
	{
	p_data[l] = 0L;
	o_data[l] = 0L;
	o_data[len - l] = 0L;
	l--;
	}
}

/* ------------------------------
	 | Reduce half of frequencies |
	 ------------------------------ */
void reduce_freq(long *p_data, long *o_data, int len)
{
int i, l;

l = len / 2;
for (i = l / 2 + 1; i < l; i++)
	{
	p_data[i] = 0;
	o_data[i] = 0;
	o_data[len - i] = 0;
	}
}

