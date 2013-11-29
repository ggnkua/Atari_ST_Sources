#include "extern.h"

#define cabs(a) ((a<0) ? -a : a)

static frq_max;

/* -------------------------
	 | Remove bad frequences |
	 ------------------------- */
void kill_bads(long *p_data, long *o_data, int len)
{
int i, l = len / 2, c;
int l_merk, c_merk;
long cmp;

c_merk = 0;
l_merk = 0;
c = 0;
for (i = 1; i < l; i++)
	{
	if (p_data[i] * 100L / maxp <= 1L)
		c++;
	else
		{
		if (c > c_merk)
			{
			c_merk = c;
			l_merk = i - c;
			}
		c = 0;
		}
	}

if (c > c_merk)
	{
	c_merk = c;
	l_merk = i - c;
	}

if (l_merk > l - (l_merk + c_merk))
	{
	for(i = l_merk; i < l; i++)
		{
		o_data[i] = 0;
		p_data[i] = 0;
		o_data[len - i] = 0;
		}

/*	for (i = l_merk + c_merk - 1; i > 0 && p_data[i] * 100L / maxp > 1500L; i--)
		{
		o_data[i] = 0;
		p_data[i] = 0;
		o_data[len - i] = 0;
		}*/
	}

cmp = maxp * 450L / 3000L; 			/* 450 = 0.15 * 3000 */
for (i = 1; i < l - 2; i++)
	if (p_data[i] > cmp)
		if (p_data[i - 1] * 100L / p_data[i] < 15L
				&& 	p_data[i + 1] * 100L / p_data[i] < 15L)
			{
			p_data[i] = 0;
			o_data[i] = 0;
			o_data[l - i] = 0;
			}
}

/* ------------------
	 | Analyse maxima |
	 ------------------ */
void analyse_maxsmp(void)
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
int i, l;
long p;

l = len / 2;
for (i = 1; i < l; i++)
	if ((p = p_data[i]) != 0L)
		{
		p_data[i] = (p_data[i] + p_data[i + 1]) / 2;
	
		o_data[i] = (o_data[i] * p_data[i]) / p;
		o_data[len - i] = (o_data[len - i] * p_data[i]) / p;
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

