#include "extern.h"

static int samp_wind;
static char smp_name[13] = "No sample";
static int max_x, max_y, max_w, max_h;
static int smp_x, smp_y, smp_w, smp_h;
int red_x, red_y, red_w, red_h;

#define max(a, b) ((a > b) ? a : b)
#define min(a, b) ((a < b) ? a : b)

/* ------------------
	 | Oeffne Fenster |
	 ------------------ */
int open_window(int kind, int w_x, int w_y, int w_w, int w_h, char *t)
{
int w_handle;

wind_get(0, WF_WORKXYWH, &max_x, &max_y, &max_w, &max_h);

w_handle = wind_create(kind, max_x, max_y, max_w, max_h);
wind_set(w_handle, WF_NAME, t);
wind_open(w_handle, w_x, w_y, w_w, w_h);

return w_handle;
}

/* ---------------
	 | Sample name |
	 --------------- */
void sample_name(char *nam_p)
{
strcpy(smp_name, nam_p);
wind_set(samp_wind, WF_NAME, smp_name);
}

/* -----------------
	 | Sample window |
	 ----------------- */
void sample_window(void)
{
wind_get(0, WF_WORKXYWH, &max_x, &max_y, &max_w, &max_h);
samp_wind = open_window(MOVER|NAME, max_x, max_y, max_w, max_h >> 1, smp_name);
wind_get(samp_wind, WF_WORKXYWH, &smp_x, &smp_y, &smp_w, &smp_h);
}

/* ----------------------------------
	 | Get overlaps of two rectangles |
	 ---------------------------------- */
int rect_intersect(int x1, int y1, int w1, int h1,
									 int x2, int y2, int w2, int h2,
									 int *rx, int *ry, int *rw, int *rh)
{
*rx = max(x1, x2);
*ry = max(y1, y2);
*rw = min(x1 + w1, x2 + w2) - *rx;
*rh = min(y1 + h1, y2 + h2) - *ry;

return (*rw > 0) && (*rh > 0);
}

/* -------------------
	 | First rectangle |
	 ------------------- */
int first_rect(int wind_id, int typ)
{
int x, y, w, h;

wind_get(wind_id, WF_FIRSTXYWH, &x, &y, &w, &h);
while (w && h)
	{
 	if (rect_intersect(red_x, red_y, red_w, red_h, x, y, w, h, &r_xy[0], &r_xy[1], &r_xy[2], &r_xy[3]))
		{
		wind_update(BEG_UPDATE);
		if (typ)
			{
			r_xy[2] += r_xy[0] - 1;
			r_xy[3] += r_xy[1] - 1;

			v_hide_c(vdi_handle);
			vs_clip(vdi_handle, 1, r_xy);
			vsf_interior(vdi_handle, 0);
			vr_recfl(vdi_handle, r_xy);

			r_xy[2] -= r_xy[0] - 1;
			r_xy[3] -= r_xy[1] - 1;
			}

		return 1;
		}
	wind_get(wind_id, WF_NEXTXYWH, &x, &y, &w, &h);
	}
return 0;
}

/* ------------------
	 | Next rectangle |
	 ------------------ */
int next_rect(int wind_id, int typ)
{
int x, y, w, h;

do
	{
	wind_get(wind_id, WF_NEXTXYWH, &x, &y, &w, &h);
	if (w && h)
		{
	 	if (rect_intersect(red_x, red_y, red_w, red_h, x, y, w, h, &r_xy[0], &r_xy[1], &r_xy[2], &r_xy[3]))
			{
			if (typ)
				{
				r_xy[2] += r_xy[0] - 1;
				r_xy[3] += r_xy[1] - 1;

				vs_clip(vdi_handle, 1, r_xy);
				vsf_interior(vdi_handle, 0);
				vr_recfl(vdi_handle, r_xy);

				r_xy[2] -= r_xy[0] - 1;
				r_xy[3] -= r_xy[1] - 1;
				}
			return 1;
			}
		}
	}while(w && h);
	
v_show_c(vdi_handle, 1);
wind_update(END_UPDATE);
return 0;
}

/* ------------------------
	 | Redraw sample window |
	 ------------------------ */
void sample_redraw(int wind_id)
{
int xy[4];
int s, j, y;
int cx, cy, cw, ch;
long teiler, pos;

if (wind_id == -1)
	{
	wind_get(samp_wind, WF_CURRXYWH, &cx, &cy, &cw, &ch);
	form_dial(FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch);
	return;
	}
	
if (wind_id == samp_wind)
	{
	wind_get(samp_wind, WF_WORKXYWH, &smp_x, &smp_y, &smp_w, &smp_h);

	teiler = total / smp_w;
	if (!teiler)
		teiler = 1;
	
	s = first_rect(samp_wind, 1);
	while(s)
		{
		xy[0] = smp_x;
		xy[3] = xy[1] = y = smp_y + (smp_h >> 1);
		xy[2] = smp_x + smp_w - 1;
		v_pline(vdi_handle, 2, xy);

		for (j = 0, pos = 0L; j < smp_w && j < total; j++)
			{
			xy[2] = smp_x + j;
			xy[3] = y + o_bytes[pos] * (smp_h / 2) / 133;
			pos += teiler;
			v_pline(vdi_handle, 2, xy);
			xy[0] = xy[2];
			xy[1] = xy[3];
			}
		s = next_rect(samp_wind, 1);
		}
	}
}

