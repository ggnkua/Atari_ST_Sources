#include "extern.h"

#define MWIRE 0xFFFF8922L
#define MWDATA 0
#define MWMASK 1

static int mw_cmd[] = {0x4C0, 0x540, 0x500, 0x480, 0x440};
static int mw_base[] = {-80, -40, -40, -12, -12};
static int mw_data[] = {40, 20, 20, 6, 6};
static int mw_sldd[] = {40, 20, 20, 12, 12};
static int mw_sbkg[] = {MV_SBKG, LV_SBKG, RV_SBKG, TR_SBKG, BA_SBKG};
static int mw_sld[] = {MVOL_SLD, LVOL_SLD, RVOL_SLD, TRB_SLD, BASS_SLD};

/* ------------------------
   | Send it to Microwire |
   ------------------------ */
void send_mwire(void)
{
int *mw_reg = (int *)MWIRE;
int i;
long old_stack;

old_stack=Super(0L);

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

/* --------------------------
   | Move Micro-wire slider |
   -------------------------- */
void mw_move(OBJECT *tree, int hndl, int inx)
{
int x, y, red;
int mx, my, mk, ks;

objc_offset(tree, mw_sld[inx], &x, &y);
red_x = x;
red_y = y;
red_w = tree[mw_sld[inx]].ob_width;
red_h = tree[mw_sld[inx]].ob_height;

do
	{
	graf_mkstate(&mx, &my, &mk, &ks);
	if (mk == 1 && my < y || my >= y + red_h)
		{
		red = 0;
		
		if (my > y && mw_data[inx])
			{
			mw_data[inx]--;
			red = 1;
			}
			
		if (my < y && mw_data[inx] < mw_sldd[inx])
			{
			mw_data[inx]++;
			red = 1;
			}
			
		if (red)
			{
			set_mwsld(tree, inx);
			red_w = tree[mw_sld[inx]].ob_width;
			red_h = tree[mw_sld[inx]].ob_height;

			dialog_window(hndl, tree, RDW_DIA, ROOT);

			objc_offset(tree, mw_sld[inx], &x, &y);
			red_y = y;
			dialog_window(hndl, tree, RDW_DIA, mw_sld[inx]);
			}
		}
	}while(mk == 1);
}

/* ------------------------
   | Set microwire-slider |
   ------------------------ */
void set_mwsld(OBJECT *tree, int inx)
{
int slen;
char *a;

slen = tree[mw_sbkg[inx]].ob_height - tree[mw_sld[inx]].ob_height;
tree[mw_sld[inx]].ob_y = slen - mw_data[inx] * slen / mw_sldd[inx]
											 + tree[mw_sbkg[inx]].ob_y;

slen = mw_base[inx] + mw_data[inx] * 2;
a = tree[mw_sld[inx]].ob_spec.tedinfo->te_ptext;
if (slen <= 0)
	itoa(slen, a, 10);
else
	{
	a[0] = '+';
	itoa(slen, a + 1, 10);
	}
}

/* -----------------------
	 | Select playing rate |
	 ----------------------- */
void set_mwire(void)
{
OBJECT *mw_sel;
int hndl, ret;
int i;

rsrc_gaddr(R_TREE, MIC_WIRE, &mw_sel);

for (i = 0; i < 5; i++)
	set_mwsld(mw_sel, i);

hndl = dialog_window(0, mw_sel, OPN_DIA, 0);
do
	{
	ret = dialog_window(hndl, mw_sel, ACT_DIA, 0);

	for (i = 0; i < 5; i++)
		if (ret == mw_sld[i] || ret == mw_sbkg[i])
			{
			mw_move(mw_sel, hndl, i);
			break;
			}

	if (i == 5)
		if (ret == MW_PLAY)
			{
			send_mwire();
			play(o_bytes, total);

		  objc_offset(mw_sel, MW_PLAY, &red_x, &red_y);
		  red_w = mw_sel[MW_PLAY].ob_width;
	  	red_h = mw_sel[MW_PLAY].ob_height;
			dialog_window(hndl, mw_sel, RDW_DIA, MW_PLAY);
			}
		  		
	}while(ret != MW_OKAY);
	
send_mwire();
dialog_window(hndl, mw_sel, CLS_DIA, 0);
}

