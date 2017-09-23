#include "extern.h"

/* --------------------- */
/* | IFF-File einlesen | */
/* --------------------- */
get_iff()
{
long chunk, c_len;
char two_byt[2];
register int lines, l_wdth;

fseek(img_f, 20L, 0);
fread(&bmhd, sizeof(bmhd), 1, img_f);

lines = bmhd.height;
l_wdth = (bmhd.width + 7) >> 3;
if (l_wdth & 1)
	l_wdth++;

pic_sub += lines * l_wdth + 4;

img_mem = mem = (unsigned char *)mtext_mem + mtext_mlen - pic_sub;
if ((int)mem == 4 || !(char)mem)
	{
	mem -= 2;
	img_mem = mem;
	pic_sub += 2;
	}

*(mem++) = bmhd.width >> 8;
*(mem++) = bmhd.width;
*(mem++) = bmhd.height >> 8;
*(mem++) = bmhd.height;

putx = 0;
fread(&chunk, 4, 1, img_f);
while(chunk != 'BODY')
	{
	fread(&c_len, 4, 1, img_f);
	fseek(img_f, c_len, 1);

	fread(&chunk, 4, 1, img_f);
	}

fseek(img_f, 4L, 1);
if (bmhd.compress)
	while(lines && fread(two_byt, 1, 2, img_f))
		{
		if (two_byt[0] < 0)
			packed(two_byt);
		else
			normal(two_byt);			

		if (putx >= ((bmhd.width + 7) >> 3))
			{
			if (ftell(img_f) & 1)
				fseek(img_f, 1L, 1);

			putx = 0;
			mem += l_wdth;
			lines--;
			}
		}
else
	while(lines && fread(mem, 1, 2, img_f))
		{
		mem += l_wdth;
		lines--;
		}
}

/* ------------------ */
/* | Gepackte Bytes | */
/* ------------------ */
packed(two)
register char *two;
{
register int i;

for (i = two[0]; i <= 0; i++)
	add_iffbyt(two + 1, 1);
}

/* ------------- */
/* | Bytezeile | */
/* ------------- */
normal(two)
register char *two;
{
char line[128];

add_iffbyt(two + 1, 1);
if (two[0] > 0)
	{
	fread(line, 1, (int)two[0], img_f);
	add_iffbyt(line, (int)two[0]);
	}
}

/* ------------------- */
/* | Bytes schreiben | */
/* ------------------- */
add_iffbyt(b_adr, b_anz)
register unsigned char *b_adr;
register int b_anz;
{
register int i, px;
register unsigned char *mem_r;

px = putx;
mem_r = mem;
for (i = 0; i < b_anz; i++)
	mem_r[px++] = b_adr[i];

putx = px;
}
