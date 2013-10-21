#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include <define.h>
#include <string.h>
#include <linea.h>

#include "vdi_font.h"

int vdi_handle;
int contrl[12];
int intin[50];
int intout[20];
int ptsin[20];
int ptsout[20];
int work_in[11];
int work_out[57];

int bx, by; 											/* Position der Editorbox */
int hs, ws; 											/* Gr”že eines Editpunktes */

OBJECT *font_back, *menu_adr; 		/* Pointer auf Objektb„ume */
int fx, fy, fw, fh; 							/* Koordinaten des Hintergrundes */

/* Tabelle mit den Indizes der Font-Zeilen */
int fl_tab[16] = {FL1, FL2, FL3, FL4, FL5, FL6, FL7, FL8,
									FL9, FLA, FLB, FLC, FLD, FLE, FLF, FLG};

/* Indizes der Menpunkte, welche auch ber Tasten erreichbar sind */
#define KEY_NUM 22

int m_entry[KEY_NUM] = {F_OK, LOADFONT, SAVEFONT, C_CLEAR,
				      				  C_COPY, C_UP, C_DWN,
								 				C_LFT, C_RGT, C_HFLIP, C_VFLIP, FE_ABOUT,
								 				C_PASTE, F_UNDO, F_SHOW, NEW_FONT,
								 				AS_INTEL, AS_MOTOR, HLF_HIGH, DOP_HIGH,
								 				HLF_WDTH, DOP_WDTH};

/* Kodes der Tasten zu obigen Menpunkten */
char m_keys[KEY_NUM] = {'Q', 'L', 'S', 'D',
												'C', 0xC8, 0xD0,
												0xCB, 0xCD,	'H', 'V', 'I',
												'P', 0xE1, 0xE2, 'N',
												'6', '8',	'(', ')',
												'/', '*'};

unsigned char akt_char = 'A'; 	/* Aktuelles Zeichen */

/* Fontspeicher */
long fontmem[96][256][3];							/* Fontspeicher */
int p_width[256];

int c_off[257];
fontform show_head = {68, 22, 
											"Look",
											0, 255, 
											13, 11, 8, 2, 2,
											96, 96, 1, 7, 2, 1, 0x5555, 0x5555,
											0, 0, 1, 1, 0L, c_off,
											fontmem, 3072, 16, 0L};

unsigned long s_buf[96][3]; 				/* Arbeitsbereich */
int s_pwidth; 											/* Breite des Zeichen im Arbeitsb. */

unsigned long c_buf[96][3]; 				/* Kopierbereich */
int c_pwidth; 											/* Breite des Zeichen im Kopierb. */
short c_flg = FALSE;								/* Zeichen im Puffer */

char fnt_path[65];											/* Fontpfad */
char fnt_file[14] = "SYSTEM.FNT"; 			/* Fontfile */

int mousex, mousey; 								/* mousex, mousey */
int clicks;
int key;														/* Gedrckte Taste */
int f_row = 0;
int f_col = 0;									
int f8086 = TRUE;

/* ------------ */
/* | Fontedit | */
/* ------------ */
main()
{
register int which; 										/* Ausgel”ste Aktion */
register int i; 												/* Schleifenindex */
int msg[8]; 														/* Message-Buffer */
int dummy;															/* fr unwichtige Werte */

appl_init();
open_vwork();

fnt_path[0] = Dgetdrv() + 'A';					/* Aktuellen Pfad ermitteln*/
fnt_path[1] = ':';
Dgetpath(fnt_path + 2, 0);
strcat(fnt_path, "\\*.FNT");

rsrc_load("VDI_FONT.RSC");							/* RSC laden */

graf_mouse(ARROW, 0L);									/* Mauspfeil */

set_workarea(); 												/* Hintergrund anlegen */
count_defined();
set_marker(); 													/* Marker positionieren */
restore_char(); 												/* Erstes Zeichen holen */
show_ccharacter();

do
	{
	which = evnt_multi(MU_BUTTON|MU_KEYBD|MU_MESAG,
										 2, 1, 1,
										 0, 0, 0, 0, 0,
										 0, 0, 0, 0, 0,
										 msg,
										 0, 0,
										 &mousex, &mousey, &dummy,
										 &dummy, &key, &clicks);


	switch(which)
		{
		case MU_KEYBD:											/* Tastendruck ? */
			if ((char)key >= 'a' && (char)key <= 'z')
				key &= 0xDF;
				
			if (!(char)key) 									/* Kontrolltaste ?*/
				{
				key >>= 8;
				key |= 0x80;
				}

			for (i = 0; i < KEY_NUM; i++)					/* Passenden Meneintrag suchen */
				if (m_keys[i] == (char)key)
					{
					which = MU_MESAG;
					msg[0] = MN_SELECTED;
					msg[4] = m_entry[i];
					menu_action(msg); 						/* Meneintrag ausfhren */
					break;
					}
			break;

		case MU_MESAG:
			if (msg[0] == MN_SELECTED)				/* Meneintrag ? */
				{
				menu_action(msg);
				menu_tnormal(menu_adr, msg[3], TRUE);
				}
			break;

		case MU_BUTTON:
			button_click(); 									/* Mausklick */
			break;
		}

	}while(which != MU_MESAG || msg[0] != MN_SELECTED || msg[4] != F_OK);

cls_vwork();
appl_exit();
}

/* ------------------------ */
/* | Button wurde benutzt | */
/* ------------------------ */
button_click()
{
register int object;

/*		'TOP LINE': oberste Begrenzung aller Zeichen.						*/
/* 'ASCENT LINE': oberste Zeile aller Grožbuchstaben					 */
/*	 'HALF LINE': oberste Zeile aller Kleinbuchstaben 				 */
/*	 'BASE LINE': unterste Zeile aller Zeichen ohne Unterl„nge */
/*'DESCENT LINE': unterste Zeile aller Zeichen mit Unterl„ngen */
/* 'BOTTOM LINE': unterste Begrenzung aller Zeichen.					 */

object = objc_find(font_back, ROOT, MAX_DEPTH, mousex, mousey);
switch(object)
	{
	case TOP:
	case ASCENT:
	case HALF:
	case BASE:
	case BOTTOM:
	case DESCENT:
	 	if (clicks == 1 && object != TOP)
			move_line(object);
		else
			switch(object)
				{
			  case TOP:
					form_alert(1, "[1]['TOP LINE':| |oberste Begrenzung aller |Zeichen.][ OK ]");
					break;

			  case ASCENT:
					form_alert(1, "[1]['ASCENT LINE':| |oberste Zeile aller |Grožbuchstaben.][ OK ]");
					break;

				case HALF:
					form_alert(1, "[1]['HALF LINE':| |oberste Zeile aller |Kleinbuchstaben.][ OK ]");
					break;

				case BASE:
					form_alert(1, "[1]['BASE LINE':| |unterste Zeile aller |Zeichen ohne Unterl„nge][ OK ]");
					break;

				case BOTTOM:
					form_alert(1, "[1]['BOTTOM LINE':| |unterste Begrenzung |aller Zeichen.][ OK ]");
					break;

				case DESCENT:
					form_alert(1, "[1]['DESCENT LINE':| |unterste Zeile aller |Zeichen mit Unterl„ngen.][ OK ]");
					break;
				}

		break;

	case F_BKG: 												/* Editierfeld */
		draw_fpoint();
		break;

	case SCL_RGT: 											/* Skala rechts */
		scale_right();
		break;

	case SCL_LFT: 											/* Skala links */
		scale_left();
		break;

	case ROOT:													/* Hintergrund */
		break;

	case FONTNAME:											/* Fontname */
		edit_name();
		break;

	case UP:														/* Editorzeile hoch */
		edit_up();
		break;					

	case DOWN:													/* Editorzeile runter */
		edit_dwn();		
		break;

	case LEFT:													/* Editorspalte links */
		edit_lft();
		break;
		
	case RIGHT:													/* Editorspalte rechts */
		edit_rgt();
		break;
				
	default:														/* FONTLINE */
		new_character();
		break;
	}
}

/* --------------------------- */
/* | Line-Markierung bewegen | */
/* --------------------------- */
move_line(obj)
int obj;
{
int end_pos, np;

end_pos = graf_slidebox(font_back, LINE_BKG, obj, 1);

end_pos >>= 5;
np = end_pos + f_row;

switch(obj)
	{
	case BASE:
		show_head.half += np - show_head.top;
		show_head.ascent += np - show_head.top;
		show_head.descent += show_head.top - np;
		show_head.bottom += show_head.top - np;
		show_head.top = np;
		break;

	case ASCENT:
		show_head.ascent = show_head.top - np;
		break;

	case HALF:
		show_head.half = show_head.top - np;
		break;

	case BOTTOM:
		show_head.bottom = np - show_head.top;
		show_head.formheight = show_head.bottom + show_head.top + 1;
		break;

	case DESCENT:
		show_head.descent = np - show_head.top;
		break;
	}

set_linemarker();
}

/* ------------------------ */
/* | Menuentry angeklickt | */
/* ------------------------ */
menu_action(msg)
int *msg;
{
register int i;

switch(msg[4])
	{
	case F_OK:													/* Programmende */
		break;

	case NEW_FONT:
		for (i = 0; i < 96; i++)
			bzero(fontmem[i], 256 * 12);

		for (i = 0; i < 256; p_width[i++] = 0);
		
		count_defined();
		restore_char();
		break;

	case LOADFONT:											/* Font laden */
		do_load();
		break;

	case SAVEFONT:											/* Font speichern */
		do_save();
		break;

	case C_CLEAR: 											/* Zeichen l”schen */
		for (i = 0; i < 96; i++)
			bzero(fontmem[i][akt_char], 12);

		p_width[akt_char] = 0;
		restore_char();
		break;

	case F_UNDO:												/* Zeichen rcksetzen */
		restore_char();
		break;

	case C_COPY:												/* Zeichen kopieren */
		bcopy(s_buf, c_buf, sizeof(s_buf));
		c_pwidth = s_pwidth;
		c_flg = TRUE;
		show_ccharacter();
		break;

	case FE_ABOUT:											/* Info */
		info();
		break;

	case C_UP:													/* Eine Zeile hoch */
		one_up();
		break;

	case C_DWN: 												/* Eine Zeile runter */
		one_dwn();
		break;

	case C_LFT: 												/* Eine Spalte links */
		one_lft();
		break;

	case C_RGT: 												/* Eine Spalte rechts */
		one_rgt();
		break;

	case C_HFLIP: 											/* Horizontal spiegeln */
		h_flip();
		break;

	case C_VFLIP: 											/* Vertikal spiegeln */
		v_flip();
		break;

	case C_PASTE: 											/* Zeichen einkleben */
		bcopy(c_buf, s_buf, sizeof(c_buf));
		s_pwidth = c_pwidth;
		set_scale();
		show_character();
		draw_edit();
		break;

	case F_SHOW:												/* Font anzeigen */
		show_font();
		break;

	case AS_INTEL:											/* Intel an */
		f8086 = TRUE;
		set_fformat();
		break;

	case AS_MOTOR:											/* 68000 an */
		f8086 = FALSE;
		set_fformat();
		break;
		
	case HLF_HIGH:											/* halbe H”he */
		half_height();
		break;

	case DOP_HIGH:											/* doppelte H”he */
		double_height();
		break;

	case HLF_WDTH:											/* halbe Breite */
		half_width();
		break;

	case DOP_WDTH:											/* doppelte Breite */
		double_width();
		break;
	}
}

/* ----------------------------- */
/* | Arbeitsbereich einrichten | */
/* ----------------------------- */
set_workarea()
{
rsrc_gaddr(ROOT, FONTEDIT, &font_back);
rsrc_gaddr(ROOT, FE_MENU, &menu_adr);

init_form();
load_sysfont(fnt_file);

wind_get(0, WF_WORKXYWH, &fx, &fy, &fw, &fh);
font_back[0].ob_x = fx;
font_back[0].ob_y = fy;
font_back[0].ob_width = fw;
font_back[0].ob_height = fh;

hs = font_back[F_BKG].ob_height >> 5;
ws = font_back[F_BKG].ob_width >> 5;

font_back[TOP].ob_height = hs;
font_back[ASCENT].ob_height = hs;
font_back[HALF].ob_height = hs;
font_back[BASE].ob_height = hs;
font_back[BOTTOM].ob_height = hs;
font_back[DESCENT].ob_height = hs;

wind_set(0, WF_NEWDESK, font_back, 0, 0);
form_dial(FMD_FINISH, 0, 0, 0, 0, fx, fy, fw, fh);

objc_offset(font_back, F_BKG, &bx, &by);

menu_bar(menu_adr, TRUE);
}

/* ---------------------------- */
/* | Virtuelle Arbeitsstation | */
/* ---------------------------- */
open_vwork()
{
register int i;

for(i = 0; i < 10; work_in[i++] = 1);
work_in[10] = 2;

v_opnvwk(work_in, &vdi_handle, work_out);
}

/* ---------------------------- */
/* | Arbeitsstation schliežen | */
/* ---------------------------- */
cls_vwork()
{
v_clsvwk(vdi_handle);
}

/* -------------------- */
/* | Checkmark setzen | */
/* -------------------- */
set_fformat()
{
if (f8086)
	{
	menu_icheck(menu_adr, AS_INTEL, TRUE);
	menu_icheck(menu_adr, AS_MOTOR, FALSE);
	}
else
	{
	menu_icheck(menu_adr, AS_INTEL, FALSE);
	menu_icheck(menu_adr, AS_MOTOR, TRUE);
	}
}

/* ------------ */
/* | Maus aus | */
/* ------------ */
hide_mouse()
{
v_hide_c(vdi_handle);
}

/* ------------ */
/* | Maus an | */
/* ------------ */
show_mouse()
{
v_show_c(vdi_handle, 1);
}

/* ------------------ */
/* | Initialisieren | */
/* ------------------ */
init_form()
{
register int i, j;

*(font_back[FL8].ob_spec + 31) = 0x7F;
*(font_back[FL9].ob_spec + 1) = 0;
*(font_back[FLG].ob_spec + 31) = 0x7F;
font_back[MARKER].ob_state |= SELECTED;

for (i = 8; i < 16; i++)
	for (j = 1; j < 32; j += 2)
		*(font_back[fl_tab[i]].ob_spec + j) += 0x80;

for (i = 0; i < 96; i++)
	bzero(fontmem[i], 12 * 256);

for (i = 0; i < 256; p_width[i++] = 0);

strcpy(font_back[FONTNAME].ob_spec, "GEM-Proportional-Font");
}

/* ------------------------ */
/* | Marker positionieren | */
/* ------------------------ */
set_marker()
{
objc_change(font_back, MARKER, 0, fx, fy, fw, fh, NORMAL, TRUE);

font_back[MARKER].ob_x = (((akt_char % 16) << 1) + 1) * font_back[MARKER].ob_width;
font_back[MARKER].ob_y = (akt_char >> 4) * font_back[MARKER].ob_height;

objc_change(font_back, MARKER, 0, fx, fy, fw, fh, SELECTED, TRUE);
}

/* ------------------------------ */
/* | Neuer Buchstabe angeklickt | */
/* ------------------------------ */
new_character()
{
int mousex, mousey, mousek, dummy;
int ox, oy, x, y;

graf_mkstate(&mousex, &mousey, &mousek, &dummy);
objc_offset(font_back, C_BKG, &ox, &oy);

x = mousex - ox;
x /= font_back[MARKER].ob_width;
x--;
x /= 2;

y = mousey - oy;
y /= font_back[MARKER].ob_height;

if (x >= 0 && y >= 0 && (y << 4) + x != akt_char)
	{
	store_char();
	akt_char = (y << 4) + x;
	set_marker();
	restore_char();
	}

do
	{
	graf_mkstate(&mousex, &mousey, &mousek, &dummy);
	}while(mousek);
}

/* ------------------ */
/* | Zeichen merken | */
/* ------------------ */
store_char()
{
register int i;

for (i = 0; i < 96; i++)
	bcopy(s_buf[i], fontmem[i][akt_char], 12);

p_width[akt_char] = s_pwidth;

count_defined();
}

/* ----------------- */
/* | Zeichen holen | */
/* ----------------- */
restore_char()
{
register int i;

for (i = 0; i < 96; i++)
	bcopy(fontmem[i][akt_char], s_buf[i], 12);
s_pwidth = p_width[akt_char];

set_scale();
show_character();
draw_edit();
}

/* ---------------- */
/* | Setze Marker | */
/* ---------------- */
set_linemarker()
{
register int y, y1;

if (show_head.ascent < 0)
	show_head.ascent = 2;

if (show_head.half < 0)
	show_head.half = 1;
		
if (show_head.bottom < 0)
	show_head.bottom = 2;
	
if (show_head.descent < 0)
	show_head.descent = 2;

if (show_head.bottom != show_head.formheight)
	show_head.bottom = show_head.formheight - show_head.top - 1;

if (!show_head.top)	
	{
	show_head.top = show_head.bottom - 2;
	show_head.bottom = 2;
	}
	
while (show_head.top > 95)
		{
		show_head.top --;
		show_head.ascent--;
		show_head.half--;
		show_head.bottom++;
		show_head.descent++;
		}

while (show_head.top + show_head.bottom > 95)
		show_head.bottom --;

while (show_head.top + show_head.descent > 95)
		show_head.descent --;

while (show_head.top - show_head.ascent < 0)
		show_head.ascent ++;
		
while (show_head.top - show_head.half < 0)
		show_head.half ++;
		
y = show_head.top - f_row;
if (y < 0 || y > 31)
	font_back[BASE].ob_flags |= HIDETREE;
else
	{
	font_back[BASE].ob_flags &= ~HIDETREE;
	font_back[BASE].ob_y = y * hs;
	}

y1 = y - show_head.ascent;
if (y1 < 0 || y1 > 31)
	font_back[ASCENT].ob_flags |= HIDETREE;
else
	{
	font_back[ASCENT].ob_flags &= ~HIDETREE;
	font_back[ASCENT].ob_y = y1 * hs;
	}

y1 = y + show_head.descent;
if (y1 < 0 || y1 > 31)
	font_back[DESCENT].ob_flags |= HIDETREE;
else
	{
	font_back[DESCENT].ob_flags &= ~HIDETREE;
	font_back[DESCENT].ob_y = y1 * hs;
	}

y1 = y - show_head.half;
if (y1 < 0 || y1 > 31)
	font_back[HALF].ob_flags |= HIDETREE;
else
	{
	font_back[HALF].ob_flags &= ~HIDETREE;
	font_back[HALF].ob_y = y1 * hs;
	}

y1 = y + show_head.bottom;
if (y1 < 0 || y1 > 31)
	font_back[BOTTOM].ob_flags |= HIDETREE;
else
	{
	font_back[BOTTOM].ob_flags &= ~HIDETREE;
	font_back[BOTTOM].ob_y = y1 * hs;
	}

if (f_row > 0)
	font_back[TOP].ob_flags |= HIDETREE;
else
	{
	font_back[TOP].ob_flags &= ~HIDETREE;
	font_back[TOP].ob_y = f_row * hs;
	}

if (show_head.descent == show_head.bottom)
	((TEDINFO *)font_back[BOTTOM].ob_spec)->te_ptext = "Bt/D";
else
	((TEDINFO *)font_back[BOTTOM].ob_spec)->te_ptext = "Bt";

objc_draw(font_back, LINE_BKG, MAX_DEPTH, fx, fy, fw, fh);
}

/* ---------------------------- */
/* | Zeichen im Feld anzeigen | */
/* ---------------------------- */
show_character()
{
draw_character(s_buf, 380);
}

/* ------------------------- */
/* | Kopierpuffer anzeigen | */
/* ------------------------- */
show_ccharacter()
{
draw_character(c_buf, 520);
}

/* -------------------- */
/* | Zeichen ausgeben | */
/* -------------------- */
draw_character(buf, pos)
long buf;
int pos;
{
MFDB src, des;
int xy[8];

src.fd_addr = buf;
src.fd_w = 96;
src.fd_h = 96;
src.fd_wdwidth = 6;
src.fd_stand = 1;
src.fd_nplanes = 1;

des.fd_addr = 0L;
des.fd_stand = 1;

xy[0] = 0;
xy[1] = 0;
xy[2] = 95;
xy[3] = 95;

xy[4] = pos;
xy[5] = 2;
xy[6] = xy[4] + 95;
xy[7] = 97;

hide_mouse();
vro_cpyfm(vdi_handle, 3, xy, &src, &des);

vsf_interior(vdi_handle, 0);
vswr_mode(vdi_handle, 2);
xy[4]--;
xy[5]--;
xy[6]++;
xy[7]++;
v_bar(vdi_handle, &xy[4]);
vswr_mode(vdi_handle, 1);

show_mouse();
}

/* ------------------------- */
/* | Zeichenbreite kleiner | */
/* ------------------------- */
scale_left()
{
if (s_pwidth)
	{
	s_pwidth--;
	set_scale();
	}
}

/* ------------------------ */
/* | Zeichenbreite gr”žer | */
/* ------------------------ */
scale_right()
{
if (s_pwidth < 96)
	{
	s_pwidth++;
	set_scale();
	}
}

/* ----------------- */
/* | Breite zeigen | */
/* ----------------- */
set_scale()
{
register int x;

x = s_pwidth + 1 - f_col;

if (x >= 1 && x <= 33)
	{
	font_back[SCL_LFT].ob_width = font_back[SCL].ob_width * x - (font_back[SCL].ob_width >> 1);

	font_back[SCL].ob_x = font_back[SCL_LFT].ob_x + font_back[SCL_LFT].ob_width;

	font_back[SCL_RGT].ob_x = font_back[SCL].ob_x + font_back[SCL].ob_width;
	font_back[SCL_RGT].ob_width = font_back[SCL_BKG].ob_width - font_back[SCL_RGT].ob_x;

	font_back[SCL].ob_flags &= ~HIDETREE;
	font_back[SCL_RGT].ob_flags &= ~HIDETREE;
	font_back[SCL_LFT].ob_flags &= ~HIDETREE;
	}
else
	if (x < 1)
		{
		font_back[SCL_RGT].ob_width = font_back[SCL_BKG].ob_width;
		font_back[SCL_RGT].ob_x = 0;

		font_back[SCL].ob_flags |= HIDETREE;
		font_back[SCL_LFT].ob_flags |= HIDETREE;
		}
	else
		{
		font_back[SCL_LFT].ob_width = font_back[SCL_BKG].ob_width;
		
		font_back[SCL].ob_flags |= HIDETREE;
		font_back[SCL_RGT].ob_flags |= HIDETREE;
		}

objc_draw(font_back, SCL_BKG, MAX_DEPTH, fx, fy, fw, fh);
}

/* -------------- */
/* | Bits holen | */
/* -------------- */
get_bits(f_data, lg, bits, pos)
register unsigned char *f_data;
register int *lg;
int bits;
unsigned int pos;
{
register unsigned long w1, msk;
register unsigned int p;

while(bits > 0)
	{
	p = pos >> 3;
	w1 = (long)f_data[p] << 16;
	w1 |= (long)f_data[p + 1] << 8;
	w1 |= (long)f_data[p + 2];

	p = pos % 8;

	w1 <<= p;
	w1 >>= 8;

	msk = 0xFFFFL;
	if (bits < 17)
		msk <<= (16 - bits);

	w1 &= msk;

	*lg++ = w1;
	pos += 16;
	bits -= 16;
	}
}

/* ------------------ */
/* | Bits einsetzen | */
/* ------------------ */
set_bits(f_data, lg, bits, pos)
register unsigned char *f_data;
register unsigned long lg;
int bits, pos;
{
register unsigned int w, bit;
register unsigned long msk;
int p, shr;

p = pos >> 3;
shr = pos % 8;
w = f_data[p];

bit = 0x80 >> shr;
msk = 0x80000000;
while(bits)
	{
	w &= ~bit;

	if (lg & msk)
		w |= bit;
		
	msk >>= 1;
	bit >>= 1;
	bits--;
	if (!bit)
		{
		f_data[p++] = w;
		bit = 0x80;
		w = f_data[p];
		}
	}
	
f_data[p] = w;
}

/* ------------------- */
/* | Fonteditor-Info | */
/* ------------------- */
info()
{
OBJECT *info;
int ix, iy, iw, ih, eo;

rsrc_gaddr(ROOT, FE_INFO, &info);

form_dial(FMD_START, 0, 0, 0, 0, ix, iy, iw, ih);

form_center(info, &ix, &iy, &iw, &ih);
objc_draw(info, ROOT, MAX_DEPTH, ix, iy, iw, ih);
eo = form_do(info, 0) & 0x7FFF;

info[eo].ob_state &= ~SELECTED;

objc_change(font_back, MARKER, 0, ix, iy, iw, ih, NORMAL, TRUE);
form_dial(FMD_FINISH, 0, 0, 0, 0, ix, iy, iw, ih);
show_character();
show_ccharacter();
draw_edit();
objc_change(font_back, MARKER, 0, ix, iy, iw, ih, SELECTED, TRUE);
}

/* ---------------------- */
/* | Fontname editieren | */
/* ---------------------- */
edit_name()
{
OBJECT *edit;
int eo;

rsrc_gaddr(ROOT, ED_FNAME, &edit);

strcpy(((TEDINFO *)edit[ED_FN].ob_spec)->te_ptext, font_back[FONTNAME].ob_spec);
edit[ROOT].ob_x = fx;
edit[ROOT].ob_y = fy;

eo = form_do(edit, ED_FN) & 0x7FFF;
objc_change(edit, eo, 0, fx, fy, fw, fh, NORMAL, TRUE);

bzero(font_back[FONTNAME].ob_spec, 32);
strcpy(font_back[FONTNAME].ob_spec, ((TEDINFO *)edit[ED_FN].ob_spec)->te_ptext);
}

/* ----------------------------- */
/* | Definierte Zeichen z„hlen | */
/* ----------------------------- */
count_defined()
{
register int i, cnt;

for (i = 0, cnt = 0; i < 256; i++)
	if (p_width[i])
		cnt++;

make_rasc((long)cnt, 100L, font_back[CHAR_DEF].ob_spec);
objc_draw(font_back, DEF_BKG, MAX_DEPTH, fx, fy, fw, fh);
}

/* ---------------------- */
/* | Erzeugt ASCII-Zahl | */
/* ---------------------- */
make_asc(zahl, teiler, adr)
register long zahl, teiler;
register char *adr;
{
register int i = 0;

while (teiler > 0)
	{
	adr[i]=(char)(zahl / teiler) + 48;
	i++;
	zahl -= (zahl / teiler) * teiler;
	teiler /= 10;
	}
}

/* ------------------------------------ */
/* | Erzeuge rechtsbndige ASCII-Zahl | */
/* ------------------------------------ */
make_rasc(zahl_r, teiler_r, adr_r)
register long zahl_r, teiler_r;
register char *adr_r;
{
make_asc(zahl_r, teiler_r, adr_r);

while(adr_r[0] == (char)48 && adr_r[1] >= (char)0x30 && adr_r[1] <= (char)0x39)
	{
	adr_r[0] = (char)0x20;
	adr_r ++;
	}
}
