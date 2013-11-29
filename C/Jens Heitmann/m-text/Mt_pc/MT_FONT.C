#include "extern.h"

/* ------------------ */
/* | Font ausw„hlen | */
/* ------------------ */
void set_font(void)
{
register int eo, i, font_nr, font_height;
int tst_x, tst_y, xy[4], dummy;
int minADE, maxADE, distance[5], effects[3], maxw;
char font_names[4][34];

set_eline();

font_nr = akt_font;
font_height = akt_fheight;

rsrc_gaddr(ROOT, SET_FONT, &form_adr);

for (i = 0; i < 4; i++)
	form_adr[FONT_1B + i].ob_spec.tedinfo->te_ptext = font_names[i];

form_adr[FONT_S].ob_state &= ~SELECTED;
for (i = 0; i < 4; i++)
	{
	form_adr[FONT_1B + i].ob_state &= ~SELECTED;
	if (tfont_names[akt_id][i][0])
		{
		strcpy(font_names[i], tfont_names[akt_id][i]);
		form_adr[FONT_1B + i].ob_state &= ~DISABLED;
		}
	else
		{
		strcpy(font_names[i], "-- Unbelegt --");
		form_adr[FONT_1B + i].ob_state |= DISABLED;
		}
	}
form_adr[FONT_S + font_nr - 1].ob_state |= SELECTED;

form_draw();

objc_offset(form_adr, TST_FLD, &tst_x, &tst_y);

xy[0] = tst_x;
xy[1] = tst_y;
xy[2] = xy[0] + form_adr[TST_FLD].ob_width - 2;
xy[3] = xy[1] + form_adr[TST_FLD].ob_height - 2;
vs_clip(vdi_handle, TRUE, xy);
vswr_mode(vdi_handle, 1);

vst_effects(vdi_handle, NORMAL);
vst_alignment(vdi_handle, 0, 5, &dummy, &dummy);

do
	{
	show_testtext(tst_x, tst_y, font_nr, font_height);
	vqt_fontinfo(vdi_handle, &minADE, &maxADE, distance, &maxw, effects);

	if (distance[4] < font_height)
		font_height = distance[4];
 
	eo = form_do(form_adr, 0);
	switch(eo & 0x7FFF)
		{
		case FONT_S:
		case FONT_1B:
		case FONT_2B:
		case FONT_3B:
		case FONT_4B:
			if ((form_adr[eo & 0x7FFF].ob_state & DISABLED) || ((eo & 0x8000) && (eo & 0x7FFF) != FONT_S))
				{
				eo &= 0x7FFF;
	
				if (load_font(eo - FONT_S + 1))
					{
					font_nr = eo - FONT_S + 1;

					vqt_name(vdi_handle, 2, tfont_names[akt_id][eo - FONT_1B]);
					strcpy(font_names[eo - FONT_1B], tfont_names[akt_id][eo - FONT_1B]);

					form_adr[eo].ob_state &= ~DISABLED;
					for (i = 0; i < 5; i++)
						form_adr[FONT_S + i].ob_state &= ~SELECTED;

					form_adr[eo].ob_state |= SELECTED;
					strcpy(txt_fonts[akt_id][font_nr - 2], rindex(font_path, '\\') + 1);
					}

				objc_draw(form_adr, ROOT, MAX_DEPTH, fx, fy, fw, fh);
				}
			else
				font_nr = eo - FONT_S + 1;
			break;

		case GRT_UP:
			if (font_height > distance[4] - distance[2])
				font_height--;
			break;

		case GRT_DWN:
			font_height++;
			break;
		}

	eo &= 0x7FFF;
	}while(eo != FONT_OK && eo != FONT_CNC);

form_adr[eo & 0x7FFF].ob_state &= ~SELECTED;
f_dial(FMD_SHRINK);
f_dial(FMD_FINISH);

get_eline();

if (eo == FONT_OK)
	{
	set_fontd(font_nr, font_height);
	akt_font = font_nr;
	akt_fheight = font_height;
	}

vst_alignment(vdi_handle, 0, 3, &dummy, &dummy);
}

/* ----------------------- */
/* | Teststring ausgeben | */
/* ----------------------- */
void show_testtext(int xpos, int ypos, int font_nr, int font_hg)
{
int dummy, height;

vst_font(vdi_handle, font_nr);
vst_height(vdi_handle, font_hg, &dummy, &dummy, &dummy, &height);
v_gtext(vdi_handle, xpos, ypos + height, "                ");
v_gtext(vdi_handle, xpos, ypos,   			 "Testtext        ");
}

/* ----------------------------	*/
/* | Loadfont-Auswahl & laden | */
/* ---------------------------- */
int load_font(int font_nr)
{
register int f_handle;
register long len;
register fontform *fnt_mem, *search;

if (fsel(font_path, ".FNT"))
	return(load_font_in(font_path, font_nr));
}

/* --------------	*/
/* | Font laden | */
/* -------------- */
int load_font_in(char *font_path, int font_nr)
{
register int f_handle;
register long len;
register fontform *fnt_mem, *search;

f_handle = Fopen(font_path, 0);	
if (f_handle > 0)
	{
	len = Fseek(0L, f_handle, 2);
	Fseek(0L, f_handle, 0);

	pic_sub += len + 4;
	if (pic_sub & 1)
		{
		pic_sub--;
		*(long *)(mtext_mem + mtext_mlen - pic_sub) = len + 1;
		}
	else
		*(long *)(mtext_mem + mtext_mlen - pic_sub) = len;

	fnt_mem = (fontform *)(mtext_mem + mtext_mlen - pic_sub + 4);

	Fread(f_handle, len, fnt_mem);
	Fclose(f_handle);

	if ((long)fnt_point[akt_id] > 0)
		vst_unload_fonts(vdi_handle, 1);

	if ((long)fnt_point[akt_id] > 0)
		fnt_mem[0].next = fnt_point[akt_id];
	else
		fnt_mem[0].next = 0;

	fnt_point[akt_id] = fnt_mem;

	fnt_mem[0].id = 99;
	fnt_mem[0].ch_ofst = (int *)((long)fnt_mem[0].ch_ofst + (long)fnt_mem);
	fnt_mem[0].fnt_dta  = (int *)((long)fnt_mem[0].fnt_dta + (long)fnt_mem);

	remove_font(font_nr);

	fnt_mem = fnt_point[akt_id];
	fnt_mem[0].id = font_nr;

	inst_font();

	return(1);
	}

return(0);
}

/* --------------------- */
/* | Font installieren | */
/* --------------------- */
void inst_font(void)
{
VDIPB vdipb;

_VDIParBlk.contrl[0]	 = 119;
_VDIParBlk.contrl[1]  = 0;
_VDIParBlk.contrl[2]  = 0;
_VDIParBlk.contrl[3]  = 1;
_VDIParBlk.contrl[4]  = 1;
_VDIParBlk.contrl[6]  = vdi_handle;
_VDIParBlk.contrl[7]	 = scrtchp >> 16;
_VDIParBlk.contrl[8]	 = scrtchp;
_VDIParBlk.contrl[9]	 = 0xCC << 1;
_VDIParBlk.contrl[10] = (long)fnt_point[akt_id] >> 16;
_VDIParBlk.contrl[11] = (int)fnt_point[akt_id];
_VDIParBlk.intin[0] 	 = 1;

vdipb.contrl = _VDIParBlk.contrl;
vdipb.intin = _VDIParBlk.intin;
vdipb.ptsin = _VDIParBlk.ptsin;
vdipb.intout = _VDIParBlk.intout;
vdipb.ptsout = _VDIParBlk.ptsout;

vdi(&vdipb);
}

/* ------------------------- */
/* | Druckerfont ausw„hlen | */
/* ------------------------- */
void set_pfont(void )
{
register int eo;

rsrc_gaddr(ROOT, PRT_FONT, &form_adr);

eo = dialog(0);
}

/* ---------------- */
/* | Font l”schen | */
/* ---------------- */
void remove_font(int font_nr)
{
register long len;
register unsigned char *fnt_adr;
fontform *fnt;
long *fnt_p;

fnt = fnt_point[akt_id];
fnt_p = (long *)&fnt_point[akt_id];

while(fnt > 0 && fnt[0].id != font_nr)
	{
	fnt_p = (long *)&fnt[0].next;
	fnt = fnt[0].next;
	}

if (fnt <= 0)
	return;

fnt_p[0] = (long)fnt[0].next;

len = *(long *)((long)fnt - 4) + 4;
fnt_adr = (unsigned char *)fnt - 4;

remove_one(fnt_adr, len);
}

/* ------------------- */
/* | Fonts entfernen | */
/* ------------------- */
void remove_allf(int id)
{
register int i;

for (i = 2; i < 5; remove_font(i++));
}
