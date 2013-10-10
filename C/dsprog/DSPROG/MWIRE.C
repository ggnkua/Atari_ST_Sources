#include "extern.h"

extern DIALOG setmw_dia;

#define MWIRE 0xFFFF8922L
#define MWDATA 0
#define MWMASK 1

static int mw_cmd[] = {0x4C0, 0x540, 0x500, 0x480, 0x440};
static int mw_base[] = {-80, -40, -40, -12, -12};
static int mw_sldd[] = {40, 20, 20, 12, 12};
static int mw_sbkg[] = {MV_SBKG, LV_SBKG, RV_SBKG, TR_SBKG, BA_SBKG};
static int mw_sld[] = {MVOL_SLD, LVOL_SLD, RVOL_SLD, TRB_SLD, BASS_SLD};

/* -------------------
   | Set main volume |
   ------------------- */
int mvol_scale(void)
{
mw_move(0);
return 0;
}

/* -------------------
   | Set main volume |
   ------------------- */
int lvol_scale(void)
{
mw_move(1);
return 0;
}

/* -------------------
   | Set main volume |
   ------------------- */
int rvol_scale(void)
{
mw_move(2);
return 0;
}

/* -------------------
   | Set main volume |
   ------------------- */
int treb_scale(void)
{
mw_move(3);
return 0;
}

/* -------------------
   | Set main volume |
   ------------------- */
int bass_scale(void)
{
mw_move(4);
return 0;
}

/* --------------------------
   | Move Micro-wire slider |
   -------------------------- */
void mw_move(int inx)
{
int obj_y, obj_y2, obj_x;
int mx, my, mk, ks;
int obj_h;
int red, dummy;

objc_offset(setmw_dia.tree, mw_sld[inx], &dummy, &obj_y);
obj_h = setmw_dia.tree[mw_sld[inx]].ob_height;

graf_mkstate(&mx, &my, &mk, &ks);
mk = 1;
do
	{
	if (mk == 1 && my < obj_y || my >= obj_y + obj_h)
		{
		red = 0;
		
		if (my > obj_y && mw_data[inx])
			{
			mw_data[inx]--;
			red = 1;
			}
			
		if (my < obj_y && mw_data[inx] < mw_sldd[inx])
			{
			mw_data[inx]++;
			red = 1;
			}
			
		if (red)
			{
			set_mwsld(inx);
			objc_offset(setmw_dia.tree, mw_sld[inx], &obj_x, &obj_y2);
			
			if (obj_y2 < obj_y)
				dialog_redraw(setmw_dia.w_handle, ROOT,
												obj_x, 
												obj_y2, 
												setmw_dia.tree[mw_sld[inx]].ob_width + 4,
												setmw_dia.tree[mw_sld[inx]].ob_height + 4
												+ obj_y - obj_y2);
			else
				dialog_redraw(setmw_dia.w_handle, ROOT,
												obj_x, 
												obj_y, 
												setmw_dia.tree[mw_sld[inx]].ob_width + 4,
												setmw_dia.tree[mw_sld[inx]].ob_height + 4
												+ obj_y2 - obj_y);
			obj_y = obj_y2;
			}
		}
	graf_mkstate(&mx, &my, &mk, &ks);
	}while(mk == 1);
}

/* -------------------------------
   | Initialize Microwire dialog |
   ------------------------------- */
void init_mwdia(void)
{
int i;

rsrc_gaddr(R_TREE, SET_MW, &setmw_dia.tree);
for (i = 0; i < 5; i++)
	set_mwsld(i);
}

/* ------------------------
   | Set microwire-slider |
   ------------------------ */
void set_mwsld(int inx)
{
int slen;
char *a;

slen = setmw_dia.tree[mw_sbkg[inx]].ob_height 
			 - setmw_dia.tree[mw_sld[inx]].ob_height;
setmw_dia.tree[mw_sld[inx]].ob_y = slen - mw_data[inx] * slen / mw_sldd[inx]
											 + setmw_dia.tree[mw_sbkg[inx]].ob_y;

slen = mw_base[inx] + mw_data[inx] * 2;
a = setmw_dia.tree[mw_sld[inx]].ob_spec.tedinfo->te_ptmplt;
if (slen <= 0)
	itoa(slen, a, 10);
else
	{
	a[0] = '+';
	itoa(slen, a + 1, 10);
	}
}

/* ------------------------
   | Send it to Microwire |
   ------------------------ */
void send_mwire(void)
{
int *mw_reg = (int *)MWIRE;
int i;
long old_stack;

old_stack = Super(0L);

mw_reg[MWMASK] = 0x7FF;
for (i = 0; i < 5; i++)
	{
	delay(50);
	mw_reg[MWDATA] = mw_cmd[i] | mw_data[i];
	}
delay(50);
mw_reg[MWDATA] = 0x401;
delay(50);

Super((void *)old_stack);
}
