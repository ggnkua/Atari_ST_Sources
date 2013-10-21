#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include <define.h>
#include <string.h>
#include <linea.h>

#include "vdi_font.h"

extern int vdi_handle;
extern int contrl[12];
extern int intin[50];
extern int ptsin[20];

extern OBJECT *menu_adr, *font_back;
extern fontform show_head;
extern int p_width[256];
extern int fx, fy, fw, fh; 							/* Koordinaten des Hintergrundes */
extern int c_off[257];
extern unsigned char akt_char;

long a;
int skew[] = {0x0000, 0x8000, 0x1084, 0x2222, 0x2492, 0xa94a, 0x5555,
							0x54b5, 0x5b4d, 0x5ddd, 0x6f7b, 0x77f7, 0x7f7f, 0xffff};

int show_c[] = {C_1, C_2, C_3, C_4, C_5, C_6, C_7, C_8, C_9, C_A, C_B};

/* ----------------- */
/* | Font anzeigen | */
/* ----------------- */
show_font()
{
int off, key, w, h, ww, wh, dummy;
register int i, hg, eo;
OBJECT *show_form;
int sx, sy, sw, sh, c_xy[4], eff = NORMAL, f_sld;
int sk = 0;

menu_bar(menu_adr, FALSE);
store_char();

inst_font(&show_head);
vsf_interior(vdi_handle, 0);

for (i = 0; i < 14 && show_head.skewmask != skew[i]; i++);
if (i < 14)
	sk = i;
else
	sk = 6;
	
rsrc_gaddr(ROOT, SHW_FLD, &show_form);

form_center(show_form, &sx, &sy, &sw, &sh);
strcpy(show_form[SHW_NAM].ob_spec, font_back[FONTNAME].ob_spec);
strcpy(show_form[SHW_DEF].ob_spec, font_back[CHAR_DEF].ob_spec);

show_form[BOLD].ob_state &= ~SELECTED;
show_form[ITALIC].ob_state &= ~SELECTED;
show_form[LIGHT].ob_state &= ~SELECTED;
show_form[OUTL].ob_state &= ~SELECTED;
show_form[UNDERL].ob_state &= ~SELECTED;

show_form[KR_UP].ob_state |= DISABLED;
show_form[KR_DWN].ob_state |= DISABLED;
show_form[UL_UP].ob_state |= DISABLED;
show_form[UL_DWN].ob_state |= DISABLED;

hg = show_head.top * 2;
make_rasc((long)hg, 100L, ((TEDINFO *)show_form[SHW_TG].ob_spec)->te_ptext);

off = akt_char;
set_aktshw(&f_sld, off, show_form);

make_rasc((long)show_head.formheight, 10L, show_form[SHW_HGHT].ob_spec);

objc_draw(show_form, ROOT, MAX_DEPTH, sx, sy, sw, sh);

objc_offset(show_form, SHW_WIND, &c_xy[0], &c_xy[1]);
c_xy[2] = c_xy[0] + show_form[SHW_WIND].ob_width - 1;
c_xy[3] = c_xy[1] + show_form[SHW_WIND].ob_height - 1;

do
	{
	make_fontscreen(off, hg, c_xy, eff);

	eo = form_do(show_form, 0) & 0x7FFF;

	if (!(show_form[eo].ob_state & DISABLED))
		switch(eo)
			{
			case BOLD:
				if (show_form[BOLD].ob_state & SELECTED)
					eff |= 1;
				else
					eff &= ~1;
				break;
	
			case LIGHT:
				if (show_form[LIGHT].ob_state & SELECTED)
					eff |= 2;
				else
					eff &= ~2;
				break;
	
			case ITALIC:
				if (show_form[ITALIC].ob_state & SELECTED)
					{
					eff |= 4;
					show_form[KR_UP].ob_state &= ~DISABLED;
					show_form[KR_DWN].ob_state &= ~DISABLED;
					}
				else
					{
					eff &= ~4;
					show_form[KR_UP].ob_state |= DISABLED;
					show_form[KR_DWN].ob_state |= DISABLED;
					}
				objc_draw(show_form, SHW_PARA, MAX_DEPTH, sx, sy, sw, sh);
				break;
	
			case UNDERL:
				if (show_form[UNDERL].ob_state & SELECTED)
					{
					eff |= 8;
					show_form[UL_UP].ob_state &= ~DISABLED;
					show_form[UL_DWN].ob_state &= ~DISABLED;
					}
				else
					{
					eff &= ~8;
					show_form[UL_UP].ob_state |= DISABLED;
					show_form[UL_DWN].ob_state |= DISABLED;
					}
				objc_draw(show_form, SHW_PARA, MAX_DEPTH, sx, sy, sw, sh);
				break;
	
			case OUTL:
				if (show_form[OUTL].ob_state & SELECTED)
					eff |= 16;
				else
					eff &= ~16;
				break;
	
			case TG_UP:
				if (hg < show_head.top * 2)
					do
						{
						hg++;
						}while(hg == show_head.top);
				make_rasc((long)hg, 100L, ((TEDINFO *)show_form[SHW_TG].ob_spec)->te_ptext);
				objc_draw(show_form, SHW_TG, MAX_DEPTH, sx, sy, sw, sh);
				break;
	
			case TG_DWN:
				if (hg > 3)
					do
						{
						hg--;
						}while(hg == show_head.top);
				make_rasc((long)hg, 100L, ((TEDINFO *)show_form[SHW_TG].ob_spec)->te_ptext);
				objc_draw(show_form, SHW_TG, MAX_DEPTH, sx, sy, sw, sh);
				break;
	
			case UL_DWN:
				if (show_head.underlinemask < 10)
					show_head.underlinemask++;
				break;
				
			case UL_UP:
				if (show_head.underlinemask > 0)
					show_head.underlinemask--;
				break;
	
			case KR_DWN:
				if (sk < 13)
					show_head.skewmask = skew[++sk];
				break;
				
			case KR_UP:
				if (sk > 0)
					show_head.skewmask = skew[--sk];
				break;
	
			case SHW_UP:
				if (off > 0)
					off--;
				set_aktshw(&f_sld, off, show_form);
				objc_draw(show_form, SHW_CBKG, MAX_DEPTH, sx, sy, sw, sh);
				objc_draw(show_form, SHW_INFO, MAX_DEPTH, sx, sy, sw, sh);
				break;
	
			case SHW_DWN:
				if (off < 255)
					off++;
				set_aktshw(&f_sld, off, show_form);
				objc_draw(show_form, SHW_CBKG, MAX_DEPTH, sx, sy, sw, sh);
				objc_draw(show_form, SHW_INFO, MAX_DEPTH, sx, sy, sw, sh);
				break;
				
			default:
				show_form[eo].ob_state &= ~SELECTED;
			}
				
	}while(eo != SHW_END);

deinst_font();

menu_bar(menu_adr, TRUE);
objc_change(font_back, MARKER, 0, fx, fy, fw, fh, NORMAL, TRUE);
form_dial(FMD_FINISH, 0, 0, 0, 0, sx, sy, sw, sh);

show_character();
show_ccharacter();
draw_edit();
objc_change(font_back, MARKER, 0, fx, fy, fw, fh, SELECTED, TRUE);
}

/* -------------------------------- */
/* | Aktuellen Character anzeigen | */
/* -------------------------------- */
set_aktshw(f_sld, off, form)
int *f_sld, off;
OBJECT *form;
{
register int i;

*f_sld = off - 5;
if (*f_sld < 0)
	*f_sld = 0;
	
if (*f_sld > 245)
	*f_sld = 245;
	
for (i = 0; i < 11; i++)
	{
	*((TEDINFO *)form[show_c[i]].ob_spec)->te_ptext = *f_sld + i;

	if (*f_sld + i == off)
		form[show_c[i]].ob_state |= SELECTED;
	else
		form[show_c[i]].ob_state &= ~SELECTED;

	if (!p_width[*f_sld + i])
		form[show_c[i]].ob_state |= DISABLED;
	else
		form[show_c[i]].ob_state &= ~DISABLED;
	}

*form[CH_INFO].ob_spec = off;
make_rasc((long)off, 100L, form[SHW_DEZ].ob_spec);
make_rasc((long)p_width[off], 10L, form[SHW_WDTH].ob_spec);

*form[SHW_HEX].ob_spec = (off >> 4) + '0' + (((off >> 4) > 9) ? 7 : 0);
*(form[SHW_HEX].ob_spec + 1) = (off & 0xF) + '0' + (((off & 0xF) > 9) ? 7 : 0);
}

/* ------------------ */
/* | 128 darstellen | */
/* ------------------ */
make_fontscreen(offset, hg, c_xy, eff)
int offset, hg, *c_xy, eff;
{
int dummy;

vswr_mode(vdi_handle, 1);
vr_recfl(vdi_handle, c_xy);

vswr_mode(vdi_handle, 2);
vst_effects(vdi_handle, NORMAL);
vst_height(vdi_handle, 4, &dummy, &dummy, &dummy, &dummy);
vst_alignment(vdi_handle, 1, 5, &dummy, &dummy);

draw_font(10, offset, TRUE, c_xy);

vst_effects(vdi_handle, eff);
vst_font(vdi_handle, show_head.fontid);
vst_height(vdi_handle, hg, &dummy, &dummy, &dummy, &dummy);

draw_font((c_xy[2] - c_xy[0]) / 2, offset, FALSE, c_xy);

vst_font(vdi_handle, 1);
}

/* ----------------- */
/* | Font ausgeben | */
/* ----------------- */
draw_font(ad, offset, flg, c_xy)
register int ad, offset, flg, *c_xy;
{
if (p_width[offset] || flg)
	{
	c_off[offset] = 96 * offset;
	c_off[offset + 1] = 96 * offset + p_width[offset] + 1;
		
	cv_gtext(vdi_handle, c_xy[0] + ad, c_xy[1] + 2, offset);
	}
}

/* --------------------- */
/* | Font installieren | */
/* --------------------- */
inst_font(f_header)
long f_header;
{
a = (long)Malloc(20000L);

contrl[0] = 119;
contrl[1] = 0;
contrl[2] = 0;
contrl[3] = 1;
contrl[4] = 1;
contrl[6] = vdi_handle;

contrl[7] = a >> 16;
contrl[8] = a;
contrl[9] = 5000;
contrl[10] = f_header >> 16;
contrl[11] = f_header;

vdi();
}

/* ----------------------- */
/* | Font deinstallieren | */
/* ----------------------- */
deinst_font()
{
vst_unload_fonts(vdi_handle);
Mfree(a);
}

/* -------------------------------------- */
/* | v_gtext fehlerfrei fÅr ein Zeichen | */
/* -------------------------------------- */
cv_gtext(vdi_handle, x, y, chr)
int vdi_handle, x, y;
register unsigned char chr;
{
extern int *pblock[];

contrl[0] = 8;
contrl[1] = 1;
contrl[2] = 0;
contrl[4] = 0;
contrl[6] = vdi_handle;

ptsin[0] = x;
ptsin[1] = y;

intin[0] = chr;

contrl[3] = 1;

pblock[1] = intin;
pblock[2] = ptsin;

vdi();
}
