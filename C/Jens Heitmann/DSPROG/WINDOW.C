#include "extern.h"

static int red_x, red_y, red_w, red_h;

#define max(a, b) ((a > b) ? a : b)
#define min(a, b) ((a < b) ? a : b)

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
int first_rect(int wind_id, int r_x, int r_y, int r_w, int r_h, int typ)
{
int x, y, w, h;

red_x = r_x;
red_y = r_y;
red_w = r_w;
red_h = r_h;

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

/* -------------------------------
   | Force a total window redraw |
   ------------------------------- */
void force_wredraw(int w_handle)
{
int r_x, r_y, r_w, r_h;

if (w_handle < 0)
	return;
	
wind_get(w_handle, WF_FIRSTXYWH, &r_x, &r_y, &r_w, &r_h);
while(r_w && r_h)
	{
	form_dial(FMD_FINISH, 0, 0, 0, 0, r_x, r_y, r_w, r_h);
	wind_get(w_handle, WF_NEXTXYWH, &r_x, &r_y, &r_w, &r_h);
	}
}
