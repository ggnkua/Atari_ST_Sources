#include "extern.h"

static int blk_len;
static int flt_hndl, stg_jump, akt_stage;
static OBJECT *flt_info;
static char smp_len[20], smp_done[20], calc_time[20];

/* ---------------------------------------------------
	 | tsmp_area(): Sample nach Pseudo-float umrechnen |
	 --------------------------------------------------- */
void to_calcd(char *o_bytes, int len)
{
int i;

for (i = 0; i < len; i++)
	smp_area[i] = (o_bytes[i] + 1L) * 3000L;
}

/* --------------------------------------------
	 | to_uchars(): Sample nach uchar umrechnen |
	 -------------------------------------------- */
void to_chars(char *o_bytes, int len)
{
int i, v;

for (i = 0; i < len; i++)
	{
	v = (int)((smp_area[i] + 382500L) / 3000L);  /* 382500 = 127.5 * 3000 */
	if (v < 0)
		v = 0;
	else
		if (v > 255)
			v = 255;											/* begrenzen */

	o_bytes[i] = v - 128;
	}
}

/* -------------------------
	 | Slider initialisation |
	 ------------------------- */
void init_stage(int all_stages)
{
flt_info[FLT_SLD].ob_width = 0;
akt_stage = 0;
stg_jump = all_stages;
dialog_window(flt_hndl, flt_info, ACT_DIA, -1);

wind_get(flt_hndl, WF_WORKXYWH, &red_x, &red_y, &red_w, &red_h);
dialog_window(flt_hndl, flt_info, RDW_DIA, SLD_BKG);
}

/* -------------------------
	 | Slider initialisation |
	 ------------------------- */
void set_stage(void)
{
akt_stage++;
flt_info[FLT_SLD].ob_width = flt_info[SLD_BKG].ob_width * akt_stage / stg_jump;
dialog_window(flt_hndl, flt_info, ACT_DIA, -1);

wind_get(flt_hndl, WF_WORKXYWH, &red_x, &red_y, &red_w, &red_h);
dialog_window(flt_hndl, flt_info, RDW_DIA, FLT_SLD);
}

/* -------------------------------
	 | Main part of filter routine |
	 ------------------------------- */
void filter(void)
{
long l;
int n, b;
char *p;
clock_t start;

rsrc_gaddr(R_TREE, FLT_INFO, &flt_info);

flt_info[SMP_BYTS].ob_spec.free_string = smp_len;
flt_info[FLT_BYTS].ob_spec.free_string = smp_done;
flt_info[CALCTM].ob_spec.free_string = calc_time;
flt_info[FLT_SLD].ob_width = 0;

ltoa(total, smp_len, 10);
strcat(smp_len, " Bytes");

strcpy(smp_done, "0 Bytes");
calc_time[0] = 0;

flt_hndl = dialog_window(0, flt_info, OPN_DIA, 0);

start = clock();

if (sink_frq)
	analyse_maxsmp();

l = total;
p = o_bytes;
while(l)
	{
	if (l >= MAX_BLK)
		{
		n = MAX_BLK;
		b = MAX_BITS;
		}
	else
		{
		n = (int)l;
		b = 0;
		while((1 << b) < n)
			b++;

		if ((1 << b) > n)
			b--;
		n = 1 << b;
		}

	blk_len = n;
	if (b > 2)
		{
		init_stage((b + 3) * 2);

		to_calcd(p, n);															/* Umwandeln nach Fliesskomma */

		dfht(smp_area, b, 0, 1);										/* DFHT-Analyse */

		maxp = power(smp_area, pow_dat);						/* Maximum finden */
/*		draw_power(0);*/

		if (ovsm_prep)
			{
			reduce_freq(pow_dat, smp_area, blk_len);
			blk_len >>= 1;
			}

		if (badf_kill)
			kill_bads(pow_dat, smp_area, blk_len);

		if (sink_frq)
			frq_sink(pow_dat, smp_area, blk_len);

		if (flat_frq)
			flatten(pow_dat, smp_area, blk_len);

		dfht(smp_area, b, 1, 1);					/* Ruecktransformation */

		to_chars(p, n);

		p += n;
		l -= n;

		ltoa(total - l, smp_done, 10);
		strcat(smp_done, " Bytes");

		ltoa((total - l) * CLK_TCK / (clock() - start), calc_time, 10);
		strcat(calc_time, " Byte/s");
		dialog_window(flt_hndl, flt_info, RDW_DIA, ROOT);
		}
	else
		l = 0;
	}

dialog_window(flt_hndl, flt_info, CLS_DIA, 0);
}

