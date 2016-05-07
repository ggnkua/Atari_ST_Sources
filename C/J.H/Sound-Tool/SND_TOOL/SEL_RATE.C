#include "extern.h"

static int cmp_tab[] = {KH625, KH125, KH25, KH50, MAN_SPD};
static int outp_tab[] = {OP_PSG, OP_DMA, OP_DSP};
static int korr_tab[] = {KORR_8, KORR_16, KORR_32, KORR_64, KORR_OFF};
static int korr_cmp[] = {7, 15, 31, 63, 256};

/* -----------------------
	 | Select playing rate |
	 ----------------------- */
void select_rate(void)
{
OBJECT *rate_sel;
int i, ret, turn = 0;
int hndl;

rsrc_gaddr(R_TREE, PLY_SPD, &rate_sel);
hndl = dialog_window(0, rate_sel, OPN_DIA, 0);

do
	{
	if (ovsm_ply)
		rate_sel[OV_SEL].ob_state |= CHECKED;
	else
		rate_sel[OV_SEL].ob_state &= ~CHECKED;
	
	for (i = 0; i < 5; i++)
		rate_sel[cmp_tab[i]].ob_state &= ~SELECTED;
	rate_sel[cmp_tab[play_spd]].ob_state |= SELECTED;

	if (ovsm_ply && play_mode == PSG && cpu_type < 68030L)
		{
		rate_sel[T_25].ob_state |= DISABLED;
		rate_sel[KH25].ob_state |= DISABLED;
		}
	else
		{
		rate_sel[T_25].ob_state &= ~DISABLED;
		rate_sel[KH25].ob_state &= ~DISABLED;
		}

	if (play_mode == PSG)
		{
		rate_sel[T_50].ob_state |= DISABLED;
		rate_sel[KH50].ob_state |= DISABLED;
		rate_sel[MAN_SPD].ob_state &= ~DISABLED;
		rate_sel[SPD_VAL].ob_state &= ~DISABLED;
		}
	else
		{
		if (ovsm_ply)
			{
			rate_sel[T_50].ob_state |= DISABLED;
			rate_sel[KH50].ob_state |= DISABLED;
			}
		else
			{
			rate_sel[T_50].ob_state &= ~DISABLED;
			rate_sel[KH50].ob_state &= ~DISABLED;
			}
		rate_sel[MAN_SPD].ob_state |= DISABLED;
		rate_sel[SPD_VAL].ob_state |= DISABLED;
		}

	if (turn)
		dialog_window(hndl, rate_sel, RDW_DIA, ROOT);
	
	ret = dialog_window(hndl, rate_sel, ACT_DIA, 0);

	for (i = 0; i < 5; i++)
		if (rate_sel[cmp_tab[i]].ob_state & SELECTED)
			{
			play_spd = i;
			if (i == 4)
				spd_table[4] = atol(rate_sel[SPD_VAL].ob_spec.tedinfo->te_ptext);
			break;
			}
	
	if (ret == OV_SEL)
		ovsm_ply ^= 1;

	turn = 1;
	}while(ret == OV_SEL);

dialog_window(hndl, rate_sel, CLS_DIA, 0);
}

/* -----------------
	 | Select output |
	 ----------------- */
void select_output(void)
{
OBJECT *outp_sel;
int i;

rsrc_gaddr(R_TREE, AUSG_SEL, &outp_sel);

dialog(outp_sel);

for (i = 0; i < 3; i++)
	if (outp_sel[outp_tab[i]].ob_state & SELECTED)
		{
		play_mode = i;
		break;
		}
}

/* ---------------------------
	 | Select correction value |
	 --------------------------- */
void select_cval(void)
{
OBJECT *korr_sel;
int i;

rsrc_gaddr(R_TREE, KORR_SEL, &korr_sel);

for (i = 0; i < 5; i++)
	if (korr_cmp[i] != korr_val)
		korr_sel[korr_tab[i]].ob_state &= ~SELECTED;
	else
		korr_sel[korr_tab[i]].ob_state |= SELECTED;

dialog(korr_sel);

for (i = 0; i < 5; i++)
	if (korr_sel[korr_tab[i]].ob_state & SELECTED)
		{
		korr_val = korr_cmp[i];
		break;
		}
}

/* ---------------------------
	 | Select correction value |
	 --------------------------- */
int ask_sndtype(void)
{
OBJECT *type_sel;
int akt_sel;
long zw = total;

total = 0;
rsrc_gaddr(R_TREE, ASK_LOAD, &type_sel);

type_sel[STE_SND].ob_state &= ~SELECTED;
type_sel[ST_SND].ob_state &= ~SELECTED;
type_sel[PK_SND].ob_state &= ~SELECTED;

akt_sel = dialog(type_sel);

total = zw;
return akt_sel;
}

/* -------------
	 | Give Info |
	 ------------- */
void do_info(void)
{
OBJECT *info_fm;

rsrc_gaddr(R_TREE, SND_INFO, &info_fm);
if (dialog(info_fm) == DO_STAT)
	check_sample();
}