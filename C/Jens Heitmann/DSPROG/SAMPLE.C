#include "extern.h"

static ACTIVATOR setvol_a[] = {{VOL_OK, okay_but},
															 {VOL_CNC, cancel_but}};

static DIALOG setvol_dia = {SET_VOL, "Lautst„rke ver„ndern", 0, 2, NULL, setvol_a, 1, VOL_VAL, -1, ""};

static DIALOG statis_dia = {SGL_STAT, "Sample-Statistik", 0, 0, NULL, NULL, 0, 0, CLK2_IC, "Statistik"};

static long max;
static long follow;
static char *adr;
static char *fadr;
static long fcnt;
static int sample_id;
static int last_prc;

static MULTI stat_m = {multi_statistik, NULL};

/* ----------------------------
   | Search top sample window |
   ---------------------------- */
int search_topsw(void)
{
int w_handle;
int zw;

wind_get(0, WF_TOP, &w_handle);
if (w_handle)	
	{
	zw = search_sw(w_handle);
	if (zw > -1)	
		{
		last_sample = zw;
		return zw;
		}
	else
		if (samples && last_sample > -1)
		 if (samples[last_sample])
		 	 return last_sample;
	}
else
	if (samples && last_sample > -1)
	 if (samples[last_sample])
	 	 return last_sample;
	 	 
return -1;
}

/* ------------------------
   | Search sample window |
   ------------------------ */
int search_sw(int w_handle)
{
int i;

for (i = 0; i < max_samples; i++)
	if (samples[i])
		if (samples[i]->w_handle == w_handle)
			return i;
	
return -1;
}

/* -------------------------
   | Close sample window ? |
   ------------------------- */
int sample_close(int w_handle)
{
int i, ni;
char *nm;

i = search_sw(w_handle);

if (i > -1)
	{
	ni = search_freeicon();

	if (last_sample == i)
		last_sample = -1;
			
	if (ni > 0)
		{
		samples[i]->w_handle = -ni;
		if (strchr(samples[i]->smp_name, '\\'))
			nm = strrchr(samples[i]->smp_name, '\\') + 1;
		else
			nm = samples[i]->smp_name;
			
		new_icon(icon_no[ni - 1], nm, NOT_IC, -1, -1);
		return 1;
		}
	}
return 0;
}

/* -------------------------
   | Delete Sample by icon |
   ------------------------- */
void sample_delete(int i_handle)
{
int i;

i = search_sw(i_handle);

if (i > -1)
	{
	if (last_sample == i)
		last_sample = -1;

	akt_samples--;
	free(samples[i]);
	samples[i] = NULL;
			
	if (!akt_samples)
		{
		free(samples);
		max_samples = 0;
		}
		
	delete_icon(icon_no[(-i_handle) - 1]);
	}
}

/* ------------------
   | Sample Re-Open |
   ------------------ */
void sample_reopen(int i_handle)
{
int i;

i = search_sw(i_handle);

if (i > -1)
	{
	open_sample(i, samples[i]->len);
	delete_icon(icon_no[(-i_handle) - 1]);
	}
}

/* ------------------------
	 | Redraw sample window |
	 ------------------------ */
void sample_redraw(int wind_id, int rx, int ry, int rw, int rh)
{
int xy[4];
int s, j, y, i;
long teiler, pos;
int smp_x, smp_y, smp_w, smp_h;
char *o_bytes;

i = search_sw(wind_id);
			
if (i != -1)
	{
	o_bytes = samples[i]->data;
	wind_get(samples[i]->w_handle, WF_WORKXYWH, &smp_x, &smp_y, &smp_w, &smp_h);

	teiler = samples[i]->len / smp_w;
	if (!teiler)
		teiler = 1;
	
	s = first_rect(samples[i]->w_handle, rx, ry, rw, rh, 1);
	while(s)
		{
		xy[0] = smp_x;
		xy[3] = xy[1] = y = smp_y + (smp_h >> 1);
		xy[2] = smp_x + smp_w - 1;
		v_pline(vdi_handle, 2, xy);

		for (j = 0, pos = 0L; j < smp_w && j < samples[i]->len; j++)
			{
			xy[2] = smp_x + j;
			xy[3] = y + o_bytes[pos] * (smp_h / 2) / 133;
			pos += teiler;
			v_pline(vdi_handle, 2, xy);
			xy[0] = xy[2];
			xy[1] = xy[3];
			}
		s = next_rect(samples[i]->w_handle, 1);
		}
	}
}

/* ------------------------
   | ST <-> STE - Convert |
   ------------------------ */
void sample_convert(void)
{
int i;

i = search_topsw();
if (i != -1)
	{
	st_convert(samples[i]->data, samples[i]->len);
	force_wredraw(samples[i]->w_handle);
	}
}

/* -----------------
   | Change volume |
   ----------------- */
void change_volume(void)
{
int i, vol;

i = search_topsw();
if (i != -1)
	{
	if (exclusiv_dialog(&setvol_dia) == 1)
		{
		vol = atoi(setvol_dia.tree[VOL_VAL].ob_spec.tedinfo->te_ptext);
		vol_calc(samples[i]->data, samples[i]->len, vol);
		force_wredraw(samples[i]->w_handle);
		}
	}
}

/* -------------------
   | Samplestatistik |
   ------------------- */
void sample_statistik(void)
{
int j;

j = search_topsw();
if (j == -1)
	return;
	
rsrc_gaddr(R_TREE, SGL_STAT, &statis_dia.tree);

strcpy(statis_dia.tree[STATNAME].ob_spec.tedinfo->te_ptmplt + 1,
		   (strchr(samples[j]->smp_name, '\\') 
		   	? strrchr(samples[j]->smp_name, '\\') + 1 
		   	: samples[j]->smp_name));
			   	
ltoa(samples[j]->len, 
		 statis_dia.tree[STATLEN].ob_spec.tedinfo->te_ptmplt + 1,
		 10);

strcpy(statis_dia.tree[STATMAXI].ob_spec.tedinfo->te_ptmplt + 1,
			 "??????");
strcpy(statis_dia.tree[STATFOLL].ob_spec.tedinfo->te_ptmplt + 1,
			 "??????");

new_dialog(&statis_dia);

statis_dia.tree[STAT_PRC].ob_spec.tedinfo->te_ptmplt[0] = 0;

max = 0L;
follow = 0L;
adr = fadr = samples[j]->data;
adr += samples[j]->len;
sample_id = j;
fcnt = 0;
last_prc = -1;

start_slider(&stat_m);
statis_active = 1;
statis_dia.icon_no = CLK2_IC;
}

/* -------------------------
   | Set percent statistik |
   ------------------------- */
void set_statpercent(void)
{
int prc;

prc = (int)((fadr - samples[sample_id]->data) * 100L / samples[sample_id]->len);

if (abs(prc - last_prc) > 2)
	{
	ltoa(prc,
		 statis_dia.tree[STAT_PRC].ob_spec.tedinfo->te_ptmplt,
		 10);
	strcat(statis_dia.tree[STAT_PRC].ob_spec.tedinfo->te_ptmplt, "%");
	force_oredraw(statis_dia.w_handle, STAT_PRC);
	last_prc = prc;
	}
}

/* -----------------------
   | Multitask Statistik |
   ----------------------- */
int multi_statistik(void)
{
char c;
long clm;

clm = clock();
while (fadr < adr && statis_dia.w_handle && samples[sample_id]->w_handle)
	{
	if (!fcnt)
		while (fadr < adr && statis_dia.w_handle && samples[sample_id]->w_handle)
			{
			if (*fadr == -128 || *fadr == 127)
				break;	
		
			fadr++;
			if (!((long)fadr & 255L))
				if (clock() - clm > CLK_TCK/3)
					{
					set_statpercent();
					return 0;
					}
			}

	if (fadr < adr && statis_dia.w_handle && samples[sample_id]->w_handle)
		{
		c = *(fadr++);
		
		while(fadr < adr && statis_dia.w_handle && samples[sample_id]->w_handle)
			{
			if (*fadr != c)
 				break;	

			fcnt++;					
			if (!((long)fadr & 255L))
				if (clock() - clm > CLK_TCK/3)
					{
					set_statpercent();
					return 0;
					}				
			fadr++;
			}
			
		max += fcnt;
		if (fcnt > follow)
			follow = fcnt;
			
		fcnt = 0L;
		}
		
	if (!((long)fadr & 255L))
		if (clock() - clm > CLK_TCK/3)
			{
			set_statpercent();
			return 0;
			}
	}
		
if (statis_dia.w_handle && samples[sample_id]->w_handle)
	{
	ltoa(max, 
			 statis_dia.tree[STATMAXI].ob_spec.tedinfo->te_ptmplt + 1,
			 10);
	ltoa(follow, 
			 statis_dia.tree[STATFOLL].ob_spec.tedinfo->te_ptmplt + 1,
			 10);
			 
	statis_dia.tree[STAT_PRC].ob_spec.tedinfo->te_ptmplt[0] = 0;

	force_oredraw(statis_dia.w_handle, STATMAXI);
	force_oredraw(statis_dia.w_handle, STATFOLL);
	force_oredraw(statis_dia.w_handle, STAT_PRC);
	}

statis_dia.icon_no = -1;
statis_active = 0;	
return 1;
}

