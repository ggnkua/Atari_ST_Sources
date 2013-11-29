#include "extern.h"

static int most, k_byte1, k_byte2, k_byte3;
extern int dt[];

/* --------------------------- */
/* | B-Algorithmus entpacken | */
/* --------------------------- */
long un_bit_it(unsigned char *mem1, unsigned char *mem2, long len, int *ubyt_map)
{
register long anz;
register int ind, i;
long akt_bit;

akt_bit = 0;
anz = 0;
while((ind = get_bits(mem1, &akt_bit, len)) != -1)
  {
  for (i = 0; i < 256; i++)
    if (dt[i] == ind)
      {
      mem2[anz++] = ubyt_map[i];
      break;
      }

  akt_bit += bin_len(ind) + 2;
  }

return(anz);
}

/* ------------------ */
/* | Bits entpacken | */
/* ------------------ */
long un_bit(mem1, mem2, in_len)
register unsigned char *mem1, *mem2;
register long in_len;
{
register int ci, i;
int ubyt_map[256];

ci = *(mem1++);
for (i = 0; i <= ci; ubyt_map[i++] = *(mem1++));

return(un_bit_it(mem1, mem2, in_len - ci - 1, ubyt_map));
}

/* -------------- */
/* | Bits holen | */
/* -------------- */
get_bits(mem1, akt_bit, max)
register unsigned char *mem1;
long *akt_bit;
long max;
{
register int m, b, word = 0;
register long ab2;
int p;

ab2 = *akt_bit;
do
  {
  if ((ab2 >> 3) >= max)
    return(-1);
    
  p = ab2 >> 3;
  b = mem1[p];
  m = ab2++ - (p << 3);

  b >>= 7 - m;
  b &= 1;
  
  word <<= 1;
  word |= b;
  }while((word & 0x7) != 1 || ab2 < *akt_bit + 2);
  
word >>= 3; 
return(word);
}


/* --------------------------- */
/* | Gleiche Worte entpacken | */
/* --------------------------- */
long same_words(mem1, mem2, ab, len1)
register unsigned char *mem1, *mem2;
long ab;
long len1;
{
register int i, b, w1, w2;

b = mem2[ab + 1];
w1 = mem2[ab + 2];
w2 = mem2[ab + 3];

for (i = 0; i <= b; i++)
  {
  *(mem1 + len1++) = w1;
  *(mem1 + len1++) = w2;
  }

return(len1);
}

/* ----------------------------- */
/* | H„ufigstes Byte entpacken | */
/* ----------------------------- */
long same_most(mem1, mem2, ab, len1)
register unsigned char *mem2, *mem1;
long ab;
long len1;
{
register int i, b;

b = mem2[ab + 1];
for (i = 0; i <= b; i++)
  *(mem1 + len1++) = most;

return(len1);  
}

/* -------------------------- */
/* | Wiederholung entpacken | */
/* -------------------------- */
long same(mem1, mem2, ab, len1)
register unsigned char *mem2, *mem1;
long ab;
long len1;
{
register int i, b, y;

b = mem2[ab + 1];
y = mem2[ab + 2];
for (i = 0; i <= b; i++)
  *(mem1 + len1++) = y;

return(len1);
}

/* ------------------- */
/* | Folge entpacken | */
/* ------------------- */
long do_folge(mem1, mem2, ab, len1)
register unsigned char *mem1, *mem2;
long ab, len1;
{
register int i, b;
long ab2;

ab2 = len1 - mem2[ab + 2];
b = mem2[ab + 1];

for (i = 0; i <= b; i++)
  *(mem1 + len1++) = *(mem1 + ab2++);
 
return(len1); 
}

/* --------------------------- */
/* | Algorithmus A entpacken | */
/* --------------------------- */
long unpack_a(mem2, mem1, anz)
register unsigned char *mem2, *mem1;
register long anz;
{
register long i;
register long len1 = 0;

i = 0;
while (i < anz)
  if (mem2[i] == k_byte1)
    {
    len1 = same_most(mem1, mem2, i, len1);
    i += 2;
    }
  else
    if (mem2[i] == k_byte2)
      {
      len1 = same(mem1, mem2, i, len1);
      i += 3;
      }
    else
      if (mem2[i] == k_byte3)
        {
        len1 = do_folge(mem1, mem2, i, len1);

        i += 3;
        }
      else
        *(mem1 + len1++) = mem2[i++];

return(len1);
}

/* ------------- */
/* | Entpacken | */
/* ------------- */
long unpack(mem1, mem2, in_len)
register unsigned char *mem1, *mem2;
long in_len;
{
most = *(mem1++);
k_byte1 = *(mem1++);
k_byte2 = *(mem1++);
k_byte3 = *(mem1++);

return(unpack_a(mem1, mem2, in_len - 4));
}

/* ----------------------- */
/* | Lese gepackte Datei | */
/* ----------------------- */
long read_pack(out, f_handle)
char  *out;
int		f_handle;
{
char	*in, *out2;
long	in_len, out_len, data_len, all_len, read_dat;

in = (char *)Malloc(15000L);
out2 = (char *)Malloc(15000L);

Fread(f_handle, 4L, &all_len);
read_dat = 0;
while(all_len > 0 && Fread(f_handle, 4L, &in_len))
	{
	Fread(f_handle, in_len, in);

	out_len = un_bit(in, out2, in_len);
	out_len = unpack(out2, out, out_len);

	out += out_len;
	all_len -= out_len;
	read_dat += out_len;
	}

Mfree(in);
Mfree(out2);
return(read_dat);
}
