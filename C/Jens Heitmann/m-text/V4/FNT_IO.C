#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include <define.h>
#include <string.h>
#include <linea.h>

#include "vdi_font.h"

extern int vdi_handle;
extern OBJECT *font_back; 							/* Pointer auf Objektb„ume */
extern int fx, fy, fw, fh; 							/* Koordinaten des Hintergrundes */
extern int s_pwidth; 										/* Breite des Zeichen im Arbeitsb. */
extern long fontmem[96][256][3];				/* Fontspeicher */
extern int p_width[256];
extern int s_pwidth; 										/* Breite des Zeichen im Arbeitsb. */
extern unsigned long s_buf[96][3]; 			/* Arbeitsbereich */
extern unsigned char akt_char; 					/* Aktuelles Zeichen */
extern fontform show_head;
extern int f8086;

extern char fnt_path[65];								/* Fontpfad */
extern char fnt_file[14];					 			/* Fontfile */

/* -------------- */
/* | Font laden | */
/* -------------- */
do_load()
{
char full_path[80];
register int f_button, i;

objc_change(font_back, MARKER, 0, fx, fy, fw, fh, NORMAL, TRUE);
f_button = fsel(fnt_path, fnt_file, full_path);
if (f_button)
	{
	load_sysfont(full_path);

	for (i = 0; i < 96; i++)
		bcopy(fontmem[i][akt_char], s_buf[i], 12);

	s_pwidth = p_width[akt_char];
	count_defined();
	}

objc_draw(font_back, NAM_BKG, MAX_DEPTH, fx, fy, fw, fh);
objc_change(font_back, MARKER, 0, fx, fy, fw, fh, SELECTED, TRUE);

show_character();
show_ccharacter();
set_scale();
draw_edit();
}

/* -------------------- */
/* | Systemfont laden | */
/* -------------------- */
load_sysfont(file)
char *file;
{
register int f_handle, i;
char *f_mem;

f_handle = Fopen(file, 0);
if (f_handle > 0)
	{
	f_mem = (char *)Malloc(100000L);
	Fread(f_handle, 100000L, f_mem);
	Fclose(f_handle);

	for (i = 0; i < 96; i++)
		bzero(fontmem[i], 12 * 256);

	for (i = 0; i < 256; p_width[i++] = 0);

	if (!strcmp(f_mem, "eset0001") || !strcmp(f_mem, "ps090001"))
		unpack_sig(f_mem);
	else
		unpack_sys(f_mem);

	Mfree(f_mem);
	}
}

/* ------------------ */
/* | Font entpacken | */
/* ------------------ */
unpack_sys(f_mem)
long f_mem;
{
fontform *f_header;
int *c_offset, rows;
unsigned char *f_data;
register int i, j, w, c;

if (!(*((char *)f_mem + 67) & 4))
	{
	turn_fheader(f_mem);
	f8086 = TRUE;
	}
else
	f8086 = FALSE;

set_fformat();

f_header = (fontform *)f_mem;
c_offset = (int *)(f_mem + (long)f_header[0].chartable);
f_data = (unsigned char *)(f_mem + (long)f_header[0].fonttable);

if (!(*((char *)f_mem + 67) & 4))
	turn_datas(c_offset, f_header[0].highascii - f_header[0].lowascii + 1);

strcpy(font_back[FONTNAME].ob_spec, f_header[0].fontname);

rows = f_header[0].formheight;
for (i = f_header[0].lowascii; i <= f_header[0].highascii; i++)
	{
	c = c_offset[i - f_header[0].lowascii];
	w = p_width[i] = c_offset[i - f_header[0].lowascii + 1] - c;
	if (w > 96 || w < 0)
		{
		w = 96;
		p_width[i] = 96;
		}

	if (((w + c - 1) >> 3) > f_header[0].formwidth)
		w = (f_header[0].formwidth << 3) - c + 1;

	for (j = 0; j < rows; j++)
		get_bits(f_data + (long)f_header[0].formwidth * j, fontmem[j][i], w, c);

	if (p_width[i] == 1)
		{
		for (j = 0; j < rows && !fontmem[j][i][0] && !fontmem[j][i][1] && !fontmem[j][i][2]; j++);

		if (j == rows)
			p_width[i] = 0;
		}
	}

bcopy(f_header, &show_head, 36);
bcopy((long)f_header + 0x28, ((long)&show_head) + 0x28, 26);
show_head.formheight = f_header[0].formheight;
}

/* ---------------------- */
/* | 8086-Font in 68000 | */
/* ---------------------- */
turn_fheader(f_mem)
char *f_mem;
{
register int i;

turn_int(f_mem);
turn_int(f_mem + 2);

for (i = 0x24; i < 0x58; i += 2)
	turn_int(f_mem + i);

turn_long(f_mem + 0x44);
turn_long(f_mem + 0x48);
turn_long(f_mem + 0x4C);
}

/* ----------------------- */
/* | 8086-Daten in 68000 | */
/* ----------------------- */
turn_datas(d_adr, anz)
int *d_adr, anz;
{
register int i;

for (i = 0; i < anz; i++)
	turn_int(d_adr + i);
}

/* ---------------------- */
/* | Vertausche 2 Bytes | */
/* ---------------------- */
turn_int(pos)
unsigned char *pos;
{
unsigned char z;

z = pos[0];
pos[0] = pos[1];
pos[1] = z;
}

/* ---------------------- */
/* | Vertausche 2 Worte | */
/* ---------------------- */
turn_long(pos)
unsigned int *pos;
{
unsigned int z;

z = pos[0];
pos[0] = pos[1];
pos[1] = z;
}

/* ------------------ */
/* | Font speichern | */
/* ------------------ */
do_save()
{
char full_path[80];
register int f_button;

objc_change(font_back, MARKER, 0, fx, fy, fw, fh, NORMAL, TRUE);

f_button = fsel(fnt_path, fnt_file, full_path);
strcat(full_path, ".FNT");

if (f_button)
	{
	store_char();
	create_system(full_path);
	}

objc_change(font_back, MARKER, 0, fx, fy, fw, fh, SELECTED, TRUE);
show_character();
show_ccharacter();
draw_edit();
}

/* ----------------------- */
/* | Systemfont erzeugen | */
/* ----------------------- */
long mk_sys(sys_font)
long sys_font;
{
fontform *f_header;
int *c_offset;
unsigned char *f_data;
long f_len = sizeof(fontform);
register int i, j, c, max_pw;

f_header = (fontform *)sys_font;
c_offset = (int *)(sys_font + sizeof(fontform));

f_header[0].fontid = 68;
f_header[0].fontsize = 20;
strcpy(f_header[0].fontname, font_back[FONTNAME].ob_spec);

for (i = 0; i < '?' && !p_width[i]; i++);
f_header[0].lowascii = i;

for (j = 255; j > i && !p_width[j]; j--);
f_header[0].highascii = j;

f_header[0].top = show_head.top;
f_header[0].ascent = show_head.ascent;
f_header[0].half = show_head.half;
f_header[0].descent = show_head.descent;
f_header[0].bottom = show_head.bottom;
f_header[0].kern = 2;
f_header[0].rightoffset = 14;
f_header[0].boldmask = 1;
f_header[0].underlinemask = 1;
f_header[0].litemask = 0x5555;
f_header[0].skewmask = 0x5555;
f_header[0].flags.system = 0;
f_header[0].flags.horiz = 0;
f_header[0].flags.swapbytes = 1;
f_header[0].flags.monospace = 0;
f_header[0].horztable = 0;
f_header[0].chartable = (int *)sizeof(fontform);
f_header[0].fonttable = (int *)(sizeof(fontform) + ((f_header[0].highascii - f_header[0].lowascii + 2) << 1));
f_header[0].formheight = show_head.formheight;
f_header[0].nextfont = 0;

f_data = (unsigned char *)(sys_font + (long)f_header[0].fonttable);
bzero(f_data, sizeof(s_buf) << 8);

c = 0;
max_pw = 1;
for (i = f_header[0].lowascii; i <= f_header[0].highascii; i++)
	{
	if (p_width[i])
		c += p_width[i];
	else
		c++;

	if (p_width[i] > max_pw)
		max_pw = p_width[i];
	}

f_header[0].largechar = max_pw - 2;
f_header[0].largeboxchar = max_pw;

f_header[0].formwidth = ((c + 15) >> 4) << 1;
f_len += ((f_header[0].highascii - f_header[0].lowascii + 2) << 1) + (long)f_header[0].formheight * f_header[0].formwidth;

c_offset[0] = 0;
c = 0;
for (i = f_header[0].lowascii; i <= f_header[0].highascii; i++)
	{
	for (j = 0; j < f_header[0].formheight; j++)
		if (p_width[i])
			{
			if (p_width[i] > 32)
				{
				set_bits(f_data + ((long)f_header[0].formwidth) * j, fontmem[j][i][0], 32, c);

				if (p_width[i] > 64)
					{
					set_bits(f_data + ((long)f_header[0].formwidth) * j, fontmem[j][i][1], 32, c + 32);
					set_bits(f_data + ((long)f_header[0].formwidth) * j, fontmem[j][i][2], p_width[i] - 64, c + 64);
					}
				else
					set_bits(f_data + ((long)f_header[0].formwidth) * j, fontmem[j][i][1], p_width[i] - 32, c + 32);
				}
			else
				set_bits(f_data + ((long)f_header[0].formwidth) * j, fontmem[j][i][0], p_width[i], c);
			}
		else
			set_bits(f_data + ((long)f_header[0].formwidth) * j, 0L, 1, c);

	if (p_width[i])
		c += p_width[i];
	else
		c++;

	c_offset[i + 1 - f_header[0].lowascii] = c;
	}

if (f8086)
	{
	turn_fheader(f_header);
	turn_datas(c_offset, f_header[0].highascii - f_header[0].lowascii + 1);
	}

return(f_len);
}

/* ------------------------ */
/* | Systemfont speichern | */
/* ------------------------ */
create_system(full_path)
char *full_path;
{
register int f_handle;
register long f_length;
register char *f_mem;

f_handle = Fcreate(full_path, 0);
if (f_handle > 0)
	{
	f_mem = (char *)Malloc(160000L);

	f_length = mk_sys(f_mem);

	Fwrite(f_handle, f_length, f_mem);
	Fclose(f_handle);

	Mfree(f_mem);
	}
}

/* -------------- */
/* | Fileselect | */
/* -------------- */
fsel(path, file, pathfile)
char *path, *file, *pathfile;
{
register int st;
int but;

st = fsel_input(path, file, &but);

if (st > 0)
	{
	strcpy(pathfile, path);
	strcpy(rindex(pathfile, '\\') + 1, file);
	}
else
	but = st;

return(but);
}

/* ------------------------- */
/* | Signum-Font entpacken | */
/* ------------------------- */
unpack_sig(f_mem)
char *f_mem;
{
register int i, h;

f_mem += 656;

for (i = 0; i < 128; i++)
	{
	p_width[i] = *(f_mem++);
	h = *(f_mem++);
	if (h)
		for(; h >= 0; h--)
			fontmem[h][i][0] = (((long)*(f_mem++)) << 24) + (((long)*(f_mem++)) << 16);
	}
}
