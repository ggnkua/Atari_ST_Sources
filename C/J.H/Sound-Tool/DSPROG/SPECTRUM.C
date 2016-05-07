#include "extern.h"

static DIALOG flt_display = {FLT_SHW, "", 0, 0, NULL, NULL, 0, 0, CLK2_IC, "Filter"};

static int blk_len;
static long smp_area[MAX_BLK];						/* Original Sample */
static long work_buf[MAX_BLK];						/* Arbeitsbuffer */
static long pow_dat[MAX_BLK / 2];					/* Power Spektrum */
static long l;
static char *p;
static long *z0, *z1, *zt;					/* Wechseln: Buffer, Daten */
static int i, s_level;
static int j;
static int s_w;
static long slid_cnt, slid_poi;

static MULTI flt_m = {flt_task, NULL};
static int level, n, b, richtung;
static int (*flt_dsp)[2] = (int (*)[])NULL;
static USERBLK flt_usrobj = {power_draw, 0L};

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

/* -------------------------------
	 | Main part of filter routine |
	 ------------------------------- */
void filter(void)
{
long l_b, tl, bt;

s_w = search_topsw();
if (s_w == -1)
	return;

new_dialog2(&flt_display, samples[s_w]->w_handle);
if (!flt_display.w_handle)
  return;

flt_display.tree[FLT_SLD].ob_width = 0;
flt_display.tree[POW_DISP].ob_type = G_USERDEF;
flt_display.tree[POW_DISP].ob_spec.userblk = &flt_usrobj;

start_slider(&flt_m);

l_b = l = samples[s_w]->len;
p = samples[s_w]->data;

if (flt_pitch)
	analyse_maxsmp(p, l);

slid_poi = slid_cnt = 0;
tl = MAX_BLK;
bt = 13;
while(bt >= 2 && l_b >= 4L)
	{
	while (tl > l_b)
		{
		tl >>= 1;
		bt--;
		}
	slid_cnt += 6 + 6 + (bt - 2) * 2;
	l_b -= tl;
	}
slid_cnt++;	
level = 0;
flt_active = s_w;
}

/* ---------------------
   | Cancel Filtertask |
   --------------------- */
void close_flttask(void)
{
int wh = flt_display.w_handle;

if (flt_dsp)
	free(flt_dsp);
	
flt_dsp = NULL;
flt_active = -1;

if (wh)	
	{
	dialog_delete(wh);
	if (wh > 0)
		{
		wind_close(wh);
		wind_delete(wh);
		}
	}

if (samples)
	force_wredraw(samples[s_w]->w_handle);
}

/* ---------------------------
   | Set new slider position |
   --------------------------- */
void new_slidlevel(void)
{
int new;

if (flt_display.w_handle < 0)
	return;

new = (int)(flt_display.tree[FLT_SLDB].ob_width * (long)++slid_poi / slid_cnt);
if (new != flt_display.tree[FLT_SLD].ob_width)
	{
	flt_display.tree[FLT_SLD].ob_width = new;
	force_oredraw(flt_display.w_handle, FLT_SLD);
	}
}

/* --------------------------------
   | Power-Object drawing routine |
   -------------------------------- */
int cdecl power_draw(PARMBLK *paras)
{
int i;
int xy[4], c_xy[4];

c_xy[0] = paras->pb_xc;
c_xy[1] = paras->pb_yc;
c_xy[2] = paras->pb_xc + paras->pb_wc - 1;
c_xy[3] = paras->pb_yc + paras->pb_hc - 1;

if (c_xy[2] || c_xy[3])
	vs_clip(vdi_handle, 1, c_xy);

xy[0] = paras->pb_x + 2;
xy[1] = paras->pb_y + 3;
xy[2] = paras->pb_x + paras->pb_w - 4;
xy[3] = paras->pb_y + paras->pb_h - 4;
vsf_interior(vdi_handle, 2);
vsf_style(vdi_handle, 4);
vr_recfl(vdi_handle, xy);

if (flt_dsp)
	{
	xy[0] = xy[2] = paras->pb_x + paras->pb_w - 2;

	for (i = paras->pb_w - 8 - 1; i >= 0; i--)
		{
		xy[1] = paras->pb_y + 6;
		xy[3] = paras->pb_y + 6 + flt_dsp[i][0];
		vsl_color(vdi_handle, 0);
		v_pline(vdi_handle, 2, xy);
	
		xy[1] = paras->pb_y + paras->pb_h - 2;
		xy[3] = paras->pb_y + 6 + flt_dsp[i][1];
		vsl_color(vdi_handle, 1);
		v_pline(vdi_handle, 2, xy);
	
		xy[2] = --xy[0];
		}
	}

if (c_xy[2] || c_xy[3])
	vs_clip(vdi_handle, 0, c_xy);

return 0;
}

/* -----------------------
   | Draw power spectrum |
   ----------------------- */
void draw_power(long *pow_dat, int n, int grey)
{
int i,sc;
int w, h, j;
int zofa;					/* Zoomfaktor */
long mx;
int flt_len;

flt_len = n/2;
w = flt_display.tree[POW_DISP].ob_width - 8;
h = flt_display.tree[POW_DISP].ob_height - 8;

/*if (1)
	{
	while(flt_len > 1 && pow_dat[flt_len - 1] * h / maxp == 0L)
		flt_len--;
	}*/
zofa = flt_len / w;

if (!zofa) 
	{
	zofa=1;						/* Zoomfaktor: >=1 */
	flt_len = w;
	}
	
if ((flt_len - 1) / zofa > w)
	zofa++;

if (!flt_dsp)
	{
	flt_dsp = (int (*)[])malloc(w * sizeof(int) * 2);
	for (i = 0; i < w; flt_dsp[i++][1] = h)
		flt_dsp[i][0] = h;
	}

if (maxp)
	{
	for(i = 0, sc = 0; i < flt_len; i += zofa)
		{
		for (j = 0, mx = 0L; j < zofa && i + j < flt_len; j++)
		  if (pow_dat[i + j] > mx) 
	  	  mx = pow_dat[i + j];
	    
		flt_dsp[sc++][grey] = h - (int)(mx * h / maxp);	/* Y-Koordinate (gerundet) */
		}
	}
else
	for (i = 0; i < w; flt_dsp[i++][1] = h)
		flt_dsp[i][0] = h;
}

/* ---------------
   | Filter task |
   --------------- */
int flt_task(void)
{
if (!samples)
	{
	close_flttask();
	return 1;
	}
	
if (!flt_display.w_handle || !samples[s_w]->w_handle)
	{
	close_flttask();
	return 1;
	}

if (!s_level)
	new_slidlevel();

switch(level)
	{
	case 0:				 								/* Blockberechnung */
		if(l)
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
			if (b < 2)
				{
				close_flttask();
				return 1;
				}
								
			level = 1;
			richtung = 0;
			
			to_calcd(p, n);				/* Umwandeln nach Fliesskomma */
			init_dfht(b);
			return 0;
			}
		close_flttask();
		return 1;
		
	case 1:		
		bit_reverse(smp_area);								/* Daten permutieren */
		level = 2;
		break;
		
	case 2:
		if (b & 1)
			{																		/* Ende: Daten in pdaten[] */
			stage_1(smp_area, smp_area);				/* Ungerade: stage_1: Inplace */
			z0 = work_buf;
			z1 = smp_area;
			}
		else
			{
			stage_1(smp_area, work_buf);	/* Gerade: stage_1: Transport */
			z1 = work_buf;
			z0 = smp_area;
			}
		level = 3;
		break;
		
	case 3:
		stage_2(z1, z0);								/* Sonst: Abwechseln! */
		level = 4;
		i = 3;
		s_level = 0;
		break;
		
	case 4:
		if (i <= b)
			{
			if (!stage_x(z0, z1, i, s_level))
				{
				zt = z0;
				z0 = z1;
				z1 = zt;
				s_level = 0;
				i++;
				}
			else
				s_level = 1;
			}
		if (i > b)
			level = 5;
		break;
		
	case 5:
		if (!richtung)
			{
			for(j = 0; j < n; smp_area[j++] >>= b);
			level = 6;
			}
		else
			level = 8;
		break;
				
	case 6:
		maxp = power(smp_area, pow_dat);						/* Maximum finden */
		draw_power(pow_dat, n, 0);
		level = 7;
		break;
		
	case 7:
		if (flt_ovsm)
			reduce_freq(pow_dat, smp_area, blk_len);

		if (flt_bad)
			kill_bads(pow_dat, smp_area, blk_len);

		if (flt_pitch)
			frq_sink(pow_dat, smp_area, blk_len);

		if (flt_slice)
			flatten(pow_dat, smp_area, blk_len);
			
		draw_power(pow_dat, n, 1);
		force_oredraw(flt_display.w_handle, POW_DISP);
		richtung = 1;
		level = 1;
		break;
		
	case 8:
		to_chars(p, n);
		p += n;
		l -= n;
		level = 0;
		break;
	}
return 0;
}

