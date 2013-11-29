#include "extern.h"

/* --------------------------------------------
	 | Packing algorythmn (taken from TOS 9/92) |
	 -------------------------------------------- */
long unpack4(char *in_d, char *out_d, long cnt)
{
unsigned char byte;
long len;

*out_d = *in_d;
in_d += 2;
cnt -= 2L;
len = 1L;
while(cnt)
	{
	byte = *(in_d++);
	*out_d = *(out_d++) + pck_tab[byte >> 4];
	*out_d = *(out_d++) + pck_tab[byte & 0xF];
	cnt--;
	len += 2L;
	}
return len;
}

/* --------------------------------------------------------
	 | Packing algorythmn (taken from TOS 9/92 and modified |
	 | for higher performance by J. Heitmann) 							|
	 -------------------------------------------------------- */
long unpack4p(char *in_d, char *out_d, long cnt)
{
char add;
unsigned char byte;
long len;

*out_d = *in_d;
in_d += 2;
cnt -= 2L;
len = 1L;
while(cnt)
	{
	byte = *(in_d++);
	*out_d = *(out_d++) + pck_tab[byte >> 4];
	*out_d = *(out_d++) + pck_tab[byte & 0xF];
	add = ((byte & 0x10) >> 1) | ((byte & 1) << 2);

	byte = *(in_d++);
	*out_d = *(out_d++) + pck_tab[byte >> 4];
	len += 3L;

	if (byte & 0xF)
		{
		*out_d = *(out_d++) + pck_tab[byte & 0xF];
		add |= ((byte & 0x10) >> 3) | (byte & 1);
		*out_d = *(out_d++) + pck_tab[add];
		len += 2L;
		}
	else
		{
		*(++out_d) = *(in_d++);
		len++;
		cnt--;
		}

	cnt -= 2L;
	}
return len;
}

/* -------------------
   | Unkompakt sound |
   ------------------- */
char *unkompakt(long *len, char *o_bytes)
{
char *omem;
long total = *len;

omem = (char *)malloc(total * 5 / 2 + sizeof(SOUND));
if (!omem)
	{
	error("Speicher voll!", "\0", 0xA);
	return 0L;
	}

if (o_bytes[1 + sizeof(SOUND)])
	total = unpack4(o_bytes + sizeof(SOUND), omem + sizeof(SOUND), total);
else
	total = unpack4p(o_bytes + sizeof(SOUND), omem + sizeof(SOUND), total);

free(o_bytes);

omem = realloc(omem, total + sizeof(SOUND));
*len = total;
return omem;
}
