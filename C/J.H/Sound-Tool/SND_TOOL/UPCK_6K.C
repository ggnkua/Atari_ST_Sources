#include "extern.h"

static int tab[16] = {-128, -64, -32, -16, -8, -4, -2, -1,
											0,	 1, 	2,	 4,  8, 16, 32, 64};

/*static OBJECT *pck_info;
static char pck_len[17];
static char pck_done[17];
static int pck_hndl;*/

/* --------------------------------------------
	 | Packing algorythmn (taken from TOS 9/92) |
	 -------------------------------------------- */
long unpack4(char *in_d, char *out_d)
{
char zw_note;
unsigned char byte;
long len, cnt;

*(out_d++) = zw_note = *in_d;
in_d += 2;
cnt = total - 2;
len = 1;
while(cnt)
	{
	byte = *(in_d++);
	*(out_d++) = zw_note += tab[byte >> 4];
	*(out_d++) = zw_note += tab[byte & 0xF];
	cnt--;
	len += 2;
	}
return len;
}

/* --------------------------------------------------------
	 | Packing algorythmn (taken from TOS 9/92 and modified |
	 | for higher performance by J. Heitmann) 							|
	 -------------------------------------------------------- */
long unpack4p(char *in_d, char *out_d)
{
char zw_note, add;
unsigned char byte;
long len, cnt;

*(out_d++) = zw_note = *in_d;
in_d += 2;
cnt = total - 2;
len = 1;
while(cnt)
	{
	byte = *(in_d++);
	*(out_d++) = zw_note += tab[byte >> 4];
	*(out_d++) = zw_note += tab[byte & 0xF];
	add = ((byte & 0x10) >> 1) | ((byte & 1) << 2);

	byte = *(in_d++);
	*(out_d++) = zw_note += tab[byte >> 4];
	len += 3;

	if (byte & 0xF)
		{
		*(out_d++) = zw_note += tab[byte & 0xF];
		add |= ((byte & 0x10) >> 3) | (byte & 1);
		*(out_d++) = zw_note += tab[add];
		len += 2;
		}
	else
		{
		*(out_d++) = zw_note = *(in_d++);
		len++;
		cnt--;
		}

	cnt -= 2;
	}
return len;
}

void unkompakt(void)
{
char *omem;

omem = (char *)malloc(total * 5 / 2);
if (!omem)
	{
	error("Speicher voll!", "\0", 0xA);
	total = 0L;
	return;
	}

if (o_bytes[1])
	total = unpack4(o_bytes, omem);
else
	total = unpack4p(o_bytes, omem);

free(o_bytes);

omem = realloc(omem, total);
o_bytes = omem;
}
