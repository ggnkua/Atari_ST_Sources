#include "extern.h"

#include "mt_dats.h"

static int most, k_byte1, k_byte2, k_byte3, ci, offset;

/* ------------------------ */
/* | Bin„rl„nge ermitteln | */
/* ------------------------ */
bin_len(word)
register int word;
{
register unsigned int a, b;

a = 16;
b = 0x8000;

while (b > (long)word && b > 1)
  {
  b >>= 1;
  a--;
  }
  
return(a);   
}

/* ---------------- */
/* | Daten packen | */
/* ---------------- */
long bitting(mem1, mem2, len1)
register unsigned char *mem1, *mem2;
register long len1;
{
register int i;
int byt_map[256][2];
long len2;

clear_bytes(byt_map);
count_bytes(mem1, len1, byt_map);
sort_bytes(byt_map);

*(mem2++) = ci;
for (i = 0; i <= ci; i++)
	*(mem2++) = byt_map[i][1];

len2 = pack_b(mem1, mem2, byt_map, len1);

return(len2 + ci + 2);
}

/* ----------------------------- */
/* | Nach Algorithmus B packen | */
/* ----------------------------- */
pack_b(mem1, mem2, byt_map, len1)
register unsigned char *mem1, *mem2;
int (*byt_map)[2];
long len1;
{
register long i, l;
long akt_bit, len2;

akt_bit = 0;
l = len1;
for (i = 0; i < l; i++)
  set_bits(mem2, &akt_bit, dt[byt_map[mem1[i]][0]]);

set_bits(mem2, &akt_bit, 0x7F);
len2 = akt_bit >> 3;

return(len2);
}

/* ------------------ */
/* | Bits einsetzen | */
/* ------------------ */
set_bits(mem2, akt_bit, wert)
register unsigned char *mem2;
long *akt_bit;
unsigned int wert;
{
register int len;
register long a, ins, p;

len = bin_len(wert);
wert <<= 2;
len += 2;

ins = (0xFFFFL >> (16 - len));
p = *akt_bit >> 3;
a = (((long)mem2[p]) << 16) + (((long)mem2[p + 1]) << 8) + ((long)mem2[p + 2]);;

ins <<= (24 - len) - (*akt_bit - (p << 3));
ins = ~ins;
a &= ins;

ins = wert;
ins <<= (24 - len) - (*akt_bit - (p << 3));
a |= ins;

mem2[p] = a >> 16;
mem2[p + 1] = a >> 8;
mem2[p + 2] = a;

*akt_bit += len;
}

/* ------------------------------------------------------------------- */
/* |                         Pack-Routinen                           | */
/* -------------------------------------------------------------------
/* ---------------- */
/* | Daten packen | */
/* ---------------- */
long packing(mem1, mem2, len1)
register unsigned char *mem1, *mem2;
register long len1;
{
int anz1, anz2;
register int i;
long len2;
int byt_map[256][2];

clear_bytes(byt_map);
count_bytes(mem1, len1, byt_map);
sort_bytes(byt_map);

*(mem2++) = most = byt_map[0][1];
*(mem2++) = k_byte1 = byt_map[255][1];
*(mem2++) = k_byte2 = byt_map[254][1];
*(mem2++) = k_byte3 = byt_map[253][1];

pack_a(mem1, mem2, &len2, len1);

return(len2 + 4);
}

/* ----------------------------------- */
/* | Daten nach Algorithmus A packen | */
/* ----------------------------------- */
pack_a(mem1, mem2, len2, len1)
register unsigned char *mem1, *mem2;
register long len1;
long *len2;
{
register long b, p_ind;
register int anz;

p_ind = 0;
b = 0;
while (p_ind < len1)
  {
  if (*(mem1 + p_ind) == most && *(mem1 + p_ind + 1) == most && *(mem1 + p_ind + 2) == most)
    {
    anz = count_same(mem1, p_ind, len1);
    mem2[b++] = k_byte1;
    mem2[b++] = anz;
    
    p_ind += anz + 1;
    }
  else
    {
    anz = count_same(mem1, p_ind, len1);
    if (anz > 2)
      {
      mem2[b++] = k_byte2;
      mem2[b++] = anz;
      mem2[b++] = *(mem1 + p_ind);
      
      p_ind += anz + 1;
      }
    else
      {
      anz = count_folge(mem1, p_ind, len1);
      if (anz > 3)
        {
        mem2[b++] = k_byte3;
        mem2[b++] = anz - 1;
        mem2[b++] = offset;

        p_ind += anz;
        }
      else
        {
        if (*(mem1 + p_ind) == k_byte1 || *(mem1 + p_ind) == k_byte2 || *(mem1 + p_ind) == k_byte3)
          {
          mem2[b++] = k_byte2;
          mem2[b++] = 0;
          mem2[b++] = *(mem1 + p_ind);
          }
        else
          mem2[b++] = *(mem1 + p_ind);
  
        p_ind++;
        }
      }
    }
  }

*len2 = b;
}

/* ------------------------- */
/* | Gleiche Folgen z„hlen | */
/* ------------------------- */
count_folge(mem1, ab, len1)
register unsigned char *mem1;
register long ab, len1;
{
register int anz = 0, i;
register long ab2;

for (i = 4; i < 21 && *(mem1 + ab) != *(mem1 + ab - i - 1); i++);
if (i == 21)
	return(0);

offset = 0;
for (i = ((i > 9) ? (i >> 1) - 1 : i - 1); i < 10 && ab + i + 1 < len1; i++)
  {
  ab2 = ab - i - 1;

  while(*(mem1 + ab2) != *(mem1 + ab) && ab2 > ab - ((i + 1) << 1) && ab2 > 0)
    ab2--;

	if (ab2 < 0)
		break;

  if (ab2 >= 0 && *(mem1 + ab2) == *(mem1 + ab))
    offset = ab - ab2;
  }

if (offset)
  {
  ab2 = ab - offset;
  for (anz = 0; anz < 256 && ab + anz < len1 && *(mem1 + ab2 + anz) == *(mem1 + ab + anz); anz++);

  while(*(mem1 + ab + anz - 1) == *(mem1 + ab + anz - 2) && anz > 0)
    anz -= 2;
  }
      
return(anz);
}

/* ------------------------ */
/* | Gleiche Bytes z„hlen | */
/* ------------------------ */
count_same(mem1, ab, len1)
register unsigned char *mem1;
register long ab, len1;
{
register int byte, anz;

byte = *(mem1 + ab++);
anz = 0;

while(ab < len1 && anz < 255)
  {
  if (*(mem1 + ab++) != byte)
    break;
    
  anz++;
  }
  
return(anz);
}

/* ------------------------ */
/* | Gleiche Worte z„hlen | */
/* ------------------------ */
count_words(mem1, ab, len1)
register unsigned char *mem1;
register long ab, len1;
{
register int byte1, byte2, anz;

byte1 = *(mem1 + ab++);
byte2 = *(mem1 + ab++);

anz = 0;

while(ab < len1 && anz < 255)
  {
  if (*(mem1 + ab) != byte1 || *(mem1 + ab + 1) != byte2)
    break;
  
  ab += 2;  
  anz++;
  }
  
return(anz);
}

/* ------------------------ */
/* | Byte-Tabelle l”schen | */
/* ------------------------ */
clear_bytes(byt_map)
register int (*byt_map)[2];
{
register int i;

for (i = 0; i < 256; i++)
  {
  byt_map[i][0] = 0;
  byt_map[i][1] = i;
  }
}

/* ---------------- */
/* | Bytes z„hlen | */
/* ---------------- */
count_bytes(adr, num, byt_map)
register unsigned char *adr;
register long num;
register int (*byt_map)[2];
{
register long i;

i = 0;
while (i < num)
  byt_map[*(adr + i++)][0]++;
}

/* ------------------- */
/* | Bytes sortieren | */
/* ------------------- */
sort_bytes(byt_map)
register int (*byt_map)[2];
{
register int i, j, k, z;

for (k = 128; k > 0; k /= 2)
  for (i = k; i < 256; i++)
    for (j = i - k; j >= 0 && byt_map[j][0] < byt_map[j + k][0]; j -= k)
      {
      z = byt_map[j][0];
      byt_map[j][0] = byt_map[j + k][0];
      byt_map[j + k][0] = z;

      z = byt_map[j][1];
      byt_map[j][1] = byt_map[j + k][1];
      byt_map[j + k][1] = z;
      }

for (ci = 0; ci < 256 && byt_map[ci][0] != 0; ci++);
ci--;

for (i = 0; i < 256; i++)
  byt_map[byt_map[i][1]][0] = i;
}


/* 	Benutzer-Schnittstelle	*/
/* 	======================	*/

/* -------------------- */
/* | Schreibe gepackt | */
/* -------------------- */
write_pack(in, in_len, f_handle)
unsigned char *in;
long in_len;
int f_handle;
{
register char	*out, *out2;
long	data_len;
register int i;

out = (char *)Malloc(15000L);
out2 = (char *)Malloc(15000L);

Fwrite(f_handle, 4L, &in_len);

while (in_len > 10000)
	{
	data_len = packing(in, out, in_len);
	data_len = bitting(out, out2, data_len);

	Fwrite(f_handle, 4L, &data_len),
	Fwrite(f_handle, data_len, out2);

	in += 10000;
	in_len -= 10000;
	}

if (in_len > 0)
	{
	data_len = packing(in, out, in_len);
	data_len = bitting(out, out2, data_len);

	Fwrite(f_handle, 4L, &data_len),
	Fwrite(f_handle, data_len, out2);
	}

Mfree(out);
Mfree(out2);
}
