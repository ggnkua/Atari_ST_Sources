#include "extern.h"

static char last_note;

/* Init data for distance table */
static int init_d1[] = {1,1,2,3,6,12,24,47,65,48,24,12,
											 6,3,1,1,1,1,2,3,6,12,24,47,65,
											 48,24,12,6,3,1,1,0};
static int init_d2[] = {129, 64, 32, 16, 8, 4, 2, 1, 1, 
											 1, 2, 4, 8, 16, 32, 64, 128, 0};
											 
static char dist_field[512];

/* --------------
	 | Init field |
	 -------------- */
void init_field(void)
{
char *point = dist_field;
int idx, i, j, *set_tab;

if (!pck_alter)
	{
	idx = 8;
	set_tab = init_d1;
	}
else
	{
	idx = 0;
	set_tab = init_d2;
	}
	
j = 0;
while(set_tab[j])
	{
	for (i = set_tab[j++]; i > 0; i--)
		*(point++) = idx;
		
	idx++;
	idx &= 0xF;
	}
}

/* ----------------
	 | SGN-function |
	 ---------------- */
int sgn(char val)
{
if (!val)
	return 0;

if (val > 0)
	return 1;

return -1;
}

/* ----------------------------------------
	 | Filter to optimize packing algorithm |
	 ---------------------------------------- */
void do_filter(char *mem, long len)
{
long c;
int s0, s1, s2;

s0 = sgn(mem[0]);
s1 = sgn(mem[1]);

for (c = 0; c < len - 2; c++)
	{
	s2 = sgn(mem[c + 2]);

	if (mem[c] * s0 > 31 && mem[c + 2] * s2 > 31 && mem[c + 1] * s1 > 31)
		if (s0 == s2
				&& s0 && s1
				&& s1 != s0)
			{
			mem[c + 1] = (mem[c] + mem[c + 2]) / 2;
			s1 = s0;
			}

	s0 = s1;
	s1 = s2;
	}
}

/* ------------------------
   | Search best distance |
   ------------------------ */
int srch_best(int start, int step, char c1, char c2)
{
int best_diff = 289, id;
int t, dist;
char new;

dist = (int)c2 - (int)c1;
id = dist_field[256 + dist];
for (t = start; t < 16; t += step)
	{
	new = c1 + pck_tab[t];
	dist = abs((int)new - (int)c2);
	if (dist < best_diff)
		{
		id = t;
		best_diff = dist;
		}
	}
	
return id;
}

/* --------------------------------------------
	 | Packing algorythmn (taken from TOS 9/92) |
	 -------------------------------------------- */
void pack2(char *in_d, char *out_d)
{
int diff_tab[4];
char zw_note, zw;
int i, s, best_id;

zw_note = last_note;
for (i = 0; i < 4; i++)
	{
	s = (int)in_d[i] - (int)zw_note;
	best_id = dist_field[256 + s];
	zw = zw_note + pck_tab[best_id];

	if (sgn(zw) != sgn(in_d[i]) && (abs(in_d[i]) > 31 || abs(zw) > 31))
		{
 		best_id = srch_best(0, 1, zw_note, in_d[i]);
		zw = zw_note + pck_tab[best_id];
		}

	diff_tab[i] = best_id;
	zw_note = zw;
	}

out_d[0] = (diff_tab[0] << 4) | diff_tab[1];
out_d[1] = (diff_tab[2] << 4) | diff_tab[3];
last_note = zw_note;
}

/* --------------------------------------------------------
	 | Packing algorythmn (taken from TOS 9/92 and modified |
	 | for higher performance by J. Heitmann) 							|
	 -------------------------------------------------------- */
void pack(char *in_d, char *out_d)
{
int diff_tab[4], difference[4];
char zw_note, zw;
int i, s, best_id, t, mask, diff_total, last_t;
int new_diff = 257, copy_tab[4], copy_last, diff_sum, new_sum = 5 * 257;

last_t = 15;
for (t = 0; t < 16; t++)
	{
	zw_note = last_note;

	diff_total = 0;
	diff_sum = 0;
	for (i = 0, mask = 8; i < 4; i++)
		{
		if ((t & mask) != (last_t & mask))
			{
			s = (int)in_d[i] - (int)zw_note;
			best_id = dist_field[256 + s];

			if ((t & mask) / mask != (best_id & 1))
		  	best_id = srch_best((t & mask) / mask, 2, zw_note, in_d[i]);

			zw = zw_note + pck_tab[best_id];

			if (sgn(zw) != sgn(in_d[i]) && (abs(in_d[i]) > 31 || abs(zw) > 31))
				{
		  	best_id = srch_best((t & mask) / mask, 2, zw_note, in_d[i]);
				zw = zw_note + pck_tab[best_id];
				}

			if (best_id == 8)
				if (in_d[i] != zw)
					{
					best_id = 10;
					zw = zw_note + pck_tab[10];
					}
					
			diff_tab[i] = best_id;
			difference[i] = abs((int)in_d[i] - (int)zw);

			last_t = ~t;
			}
		else
			best_id = diff_tab[i];

		zw_note = zw_note + pck_tab[best_id];

		mask >>= 1;
		if (difference[i] > diff_total)
			diff_total = difference[i];
			
		diff_sum += difference[i];
		}

	zw = zw_note + pck_tab[t];
	s = (int)in_d[4] - (int)zw;
	s = abs(s);
	if (s > diff_total)
		diff_total = s;

  diff_sum += s;
	if (diff_total < new_diff || diff_sum < new_sum)
		{
		new_diff = diff_total;
		new_sum = diff_sum;
		
		for (i = 0; i < 4; i++)
			copy_tab[i] = diff_tab[i];

		copy_last = zw;
		}

	last_t = t;
	}

if (new_diff > korr_val)
	{
	zw_note = last_note;
	diff_total = 0;
	
	for (i = 0; i < 3; i++)
		{
		s = (int)in_d[i] - (int)zw_note;
		best_id = dist_field[256 + s];
		zw = zw_note + pck_tab[best_id];

		if (sgn(zw) != sgn(in_d[i]) && (abs(in_d[i]) > 31 || abs(zw) > 31))
			{
  		best_id = srch_best(0, 1, zw_note, in_d[i]);
			zw = (char)(zw_note + pck_tab[best_id]);
			}

		s = abs((int)in_d[i] - (int)zw);
		if (s > diff_total)
			diff_total = s;
			
		diff_tab[i] = best_id;
		zw_note = zw;
		}
		
	if (diff_total < new_diff)
		{
		for (i = 0; i < 3; i++)
			copy_tab[i] = diff_tab[i];
		copy_tab[3] = 0;
		}
	}

out_d[0] = (copy_tab[0] << 4) | copy_tab[1];
out_d[1] = (copy_tab[2] << 4) | copy_tab[3];
last_note = copy_last;
}

/* ----------------
   | Packe Sample |
   ---------------- */
void kompakt(int flg)
{
int i;
long pos, len, total;
char *in_d, *o_bytes;
char *out_d, *omem;
char fname[MAXPATH];

i = search_topsw();
if (i == -1)
	return;

len = samples[i]->len;
o_bytes = samples[i]->data;

omem = (char *)malloc((len + 6L) * 3 / 2);

if (pck_filt)
	do_filter(o_bytes, len);

init_field();
if (!pck_4plus)
	{
	pos = len;
	out_d = omem + len;
	}
else
	{
	last_note = o_bytes[0];
	omem[0] = o_bytes[0];
	omem[1] = 0;
	in_d = o_bytes + 1;
	out_d = omem + 2;
	pos = 0;
	}
len--;

while(pos < len)
	{
 	if (len - pos < 5)
	 for (i =  (int)(len - pos); i < 5; i++)
		 in_d[i] = in_d[i - 1] / 2;

	pack(in_d, out_d);
	if ((out_d[1] & 0xF))
		{
		in_d += 5;
		out_d += 2;
		pos += 5L;
		}
	else
		{
		in_d += 3;
		out_d += 2;
		last_note = *(out_d++) = *(in_d++);
		pos += 4L;
		}
	}

if (pck_4bit)
	if (out_d - omem > len / 2)
		{
	  last_note = o_bytes[0];
		in_d = o_bytes + 1;
	  omem[0] = o_bytes[0];
		omem[1] = 1;
		out_d = omem + 2;
		pos = 0;

		while(pos < len)
			{
			if (len - pos < 4)
				for (i =	(int)(len - pos); i < 4; i++)
					in_d[i] = in_d[i - 1] / 2;

			pack2(in_d, out_d);
			in_d += 4;
			out_d += 2;
			pos += 4L;
			}
		}

if (flg)
	{
	if (select_sample(fname, "Gepacktes Sample speichern", pck_extension))
		save_out_sample(fname, omem, out_d - omem);
	}
else
	{
	samples[i]->len = total = out_d - omem;
	memcpy(o_bytes, omem, total);
	}
	
free(omem);
}
