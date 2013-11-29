#include "extern.h"

static char last_note;
static int tab[17] = {-128, -64, -32, -16, -8, -4, -2, -1,
											0,	 1, 	2,	 4,  8, 16, 32, 64, 128};

static int init_d1[] = {1,1,2,3,6,12,24,47,65,48,24,12,
											 6,3,1,1,1,1,2,3,6,12,24,47,65,
											 48,24,12,6,3,1,1,0};

static int init_d2[] = {129, 64, 32, 16, 8, 4, 2, 1, 1, 
											 1, 2, 4, 8, 16, 32, 64, 128, 0};
											 
static char dist_field[512];

static OBJECT *pck_info;
static char pck_len[17];
static char pck_done[17];
static char pck_rate[17];
static int pck_hndl;

/* --------------
	 | Init field |
	 -------------- */
void init_field(void)
{
char *point = dist_field;
int idx, i, j, *set_tab;

if (!sub_tab)
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
	new = c1 + tab[t];
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
	zw = zw_note + tab[best_id];

	if (sgn(zw) != sgn(in_d[i]) && (abs(in_d[i]) > 31 || abs(zw) > 31))
		{
 		best_id = srch_best(0, 1, zw_note, in_d[i]);
		zw = zw_note + tab[best_id];
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

			zw = zw_note + tab[best_id];

			if (sgn(zw) != sgn(in_d[i]) && (abs(in_d[i]) > 31 || abs(zw) > 31))
				{
		  	best_id = srch_best((t & mask) / mask, 2, zw_note, in_d[i]);
				zw = zw_note + tab[best_id];
				}

			if (best_id == 8)
				if (in_d[i] != zw)
					{
					best_id = 10;
					zw = zw_note + tab[10];
					}
					
			diff_tab[i] = best_id;
			difference[i] = abs((int)in_d[i] - (int)zw);

			last_t = ~t;
			}
		else
			best_id = diff_tab[i];

		zw_note = zw_note + tab[best_id];

		mask >>= 1;
		if (difference[i] > diff_total)
			diff_total = difference[i];
			
		diff_sum += difference[i];
		}

	zw = zw_note + tab[t];
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
		zw = zw_note + tab[best_id];

		if (sgn(zw) != sgn(in_d[i]) && (abs(in_d[i]) > 31 || abs(zw) > 31))
			{
  		best_id = srch_best(0, 1, zw_note, in_d[i]);
			zw = (char)(zw_note + tab[best_id]);
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

/* -------------------------
	 | Slider initialisation |
	 ------------------------- */
void set_pcksld(long akt, long all, long size)
{
ltoa(akt, pck_done, 10);
strcat(pck_done, " Bytes");

itoa((int)(size * 100L / akt), pck_rate, 10);
strcat(pck_rate, " %");

pck_info[PCK_SLD].ob_width = (int)(pck_info[PSLD_BKG].ob_width * akt / all);

wind_get(pck_hndl, WF_WORKXYWH, &red_x, &red_y, &red_w, &red_h);
dialog_window(pck_hndl, pck_info, RDW_DIA, PCK_SLD);

redraw_obj(pck_info, PCK_DLEN);
redraw_obj(pck_info, PCK_RATE);

dialog_window(pck_hndl, pck_info, ACT_DIA, -1);
}

/* ----------------
   | Packe Sample |
   ---------------- */
void kompakt(int flg)
{
int i;
long pos, len, pos1;
char *in_d;
char *out_d, *omem;

rsrc_gaddr(R_TREE, PCK_INFO, &pck_info);

pck_info[PCK_SLEN].ob_spec.free_string = pck_len;
pck_info[PCK_DLEN].ob_spec.free_string = pck_done;
pck_info[PCK_RATE].ob_spec.free_string = pck_rate;
pck_info[PCK_SLD].ob_width = 0;

ltoa(total, pck_len, 10);
strcat(pck_len, " Bytes");
strcpy(pck_done, "0 Bytes");
pck_rate[0] = 0;

pck_hndl = dialog_window(0, pck_info, OPN_DIA, 0);
dialog_window(pck_hndl, pck_info, ACT_DIA, -1);

len = total;
omem = (char *)malloc((len + 6L) * 3 / 2);

if (pck_filt)
	do_filter(o_bytes, len);

if (!bitp_pck)
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
	pos1 = 500;
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

	if (pos > pos1)
		{
		set_pcksld(pos, len, out_d - omem);
		pos1 += 500;
		}
	}
set_pcksld(pos, len, out_d - omem);

if (bit4_pck)
	if (out_d - omem > len / 2)
		{
	  last_note = o_bytes[0];
		in_d = o_bytes + 1;
	  omem[0] = o_bytes[0];
		omem[1] = 1;
		out_d = omem + 2;
		pos = 0;
		pos1 = 500;

		while(pos < len)
			{
			if (len - pos < 4)
				for (i =	(int)(len - pos); i < 4; i++)
					in_d[i] = in_d[i - 1] / 2;

			pack2(in_d, out_d);
			in_d += 4;
			out_d += 2;
			pos += 4L;

			if (pos > pos1)
				{
				set_pcksld(pos, len, out_d - omem);
				pos1 += 500;
				}
			}
		}
set_pcksld(pos, len, out_d - omem);

dialog_window(pck_hndl, pck_info, CLS_DIA, 0);

if (flg)
	{
	if (select_sample())
		save_file(fname, omem, out_d - omem);
	}
else
	{
	total = out_d - omem;
	memcpy(o_bytes, omem, total);
	}
	
free(omem);
}
