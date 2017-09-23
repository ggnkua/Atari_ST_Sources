#include "extern.h"

/* ---------------------- */
/* | Gem-Image einlesen | */
/* ---------------------- */
get_img()
{
unsigned char first;
register int lines;

fread(header, 2, 8, img_f);

putx = 0;
rep = 1;
lines = header[7];
l_wdth = ((header[6] + 15) & ~15) >> 3;

pic_sub += lines * l_wdth + 4;

img_mem = mem = (unsigned char *)mtext_mem + mtext_mlen - pic_sub;
if ((int)mem == 4 || !(char)mem)
	{
	mem -= 2;
	img_mem = mem;
	pic_sub += 2;
	}

*(mem++) = header[6] >> 8;
*(mem++) = header[6];
*(mem++) = lines >> 8;
*(mem++) = lines;

while(lines && fread(&first, 1, 1, img_f))
	{
	if (!first)
		first_zero();
	else
		if (first == (unsigned char)0x80)
			n_bytes();
		else
			solid_run(first);

	if (putx >= ((header[6] + 7) >> 3))
		{
		putx = 0;
		mem += l_wdth * rep;
		lines -= rep;
		rep = 1;
		}
	}
}

/* ------------------------- */
/* | Erstes Kennbyte ist 0 | */
/* ------------------------- */
first_zero()
{
unsigned char second;

fread(&second, 1, 1, img_f);
if (!second)
	v_rep();
else
	pattern(second);
}

/* ------------------- */
/* | Vertikal Repeat | */
/* ------------------- */
v_rep()
{
fread(&rep, 2, 1, img_f);
rep &= 0xFF;
}

/* --------------- */
/* | Pattern Run | */
/* --------------- */
pattern(anz)
unsigned char anz;
{
unsigned char p_bytes[20];
register int i;
register unsigned char *pb_adr;

pb_adr = p_bytes;
fread(pb_adr, 1, header[3], img_f);
for (i = anz; i > 0; i--)
	add_imgbyt(pb_adr, header[3]);
}

/* ----------- */
/* | N-Bytes | */
/* ----------- */
n_bytes()
{
unsigned char anz, byte;
register int i;
char bytes[128];

fread(&anz, 1, 1, img_f);
fread(bytes, 1, anz, img_f);
add_imgbyt(bytes, (int)anz);
}

/* ------------- */
/* | Solid Run | */
/* ------------- */
solid_run(sol)
register char sol;
{
register int i;
register int *msk_a;
int msk;

msk = sol;
msk_a = &msk;
for (i = sol & 0x7F; i > 0; i--)
	add_imgbyt(msk_a, 1);
}

/* ------------------- */
/* | Bytes schreiben | */
/* ------------------- */
add_imgbyt(b_adr, b_anz)
register unsigned char *b_adr;
register int b_anz;
{
register int i, l, ind;
register unsigned char *mem_r;

mem_r = mem;
for (l = rep - 1, ind = putx; l >= 0; l--, ind += l_wdth)
	for (i = 0; i < b_anz; i++)
		mem_r[ind + i] = b_adr[i];

putx += b_anz;
}
