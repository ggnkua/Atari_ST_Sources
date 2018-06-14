// compile with:
// g++ -O3 nrv2b.cpp -o nrv2b
// i586-mingw32msvc-g++ -O3 nrv2b.cpp -o nrv2b-cygwin.exe
// m68k-atari-mint-g++ -O3 nrv2b.cpp -o nrv2b-atari-mint.ttp

#define stricmp strcasecmp

// freenrv2[b,d,e] compression algo

//#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>
//#include <io.h>
//#pragma hdrstop

//extern "C" int __cdecl unpack_nrv2b(BYTE*, BYTE*);
//extern "C" int __cdecl unpack_nrv2d(BYTE*, BYTE*);
//extern "C" int __cdecl unpack_nrv2e(BYTE*, BYTE*);

//#pragma optimize("g",on)


#define bbPutBit(x)                             \
{                                               \
  if (t_bitcount == 8)                         \
  {                                             \
    t_bitset   = (BYTE*)t_outptr;              \
    t_outptr += 1;                              \
    *t_bitset  = 0;                             \
    t_bitcount = 0;                             \
  }                                             \
  *t_bitset = ((*t_bitset) << 1) | ((x)&1);     \
  t_bitcount++;                                 \
}

#define code_prefix_ss11(a)                     \
{                                               \
    DWORD i = a;                                \
    if (i >= 2)                                 \
    {                                           \
        DWORD t = 4;                            \
        i += 2;                                 \
        do {                                    \
            t <<= 1;                            \
        } while (i >= t);                       \
        t >>= 1;                                \
        do {                                    \
            t >>= 1;                            \
            bbPutBit((i & t) ? 1 : 0);          \
            bbPutBit(0);                        \
        } while (t > 2);                        \
    }                                           \
    bbPutBit(i & 1);                            \
    bbPutBit(1);                                \
}

#define code_prefix_ss12(a)                     \
{                                               \
    DWORD i = a;                                \
    if (i >= 2)                                 \
    {                                           \
        DWORD t = 2;                            \
        do {                                    \
            i -= t;                             \
            t <<= 2;                            \
        } while (i >= t);                       \
        do {                                    \
            t >>= 1;                            \
            bbPutBit((i & t) ? 1 : 0);          \
            bbPutBit(0);                        \
            t >>= 1;                            \
            bbPutBit((i & t) ? 1 : 0);          \
        } while (t > 2);                        \
    }                                           \
    bbPutBit(i & 1);                            \
    bbPutBit(1);                                \
}






// start of pack_nrv2b

//typedef unsigned long DWORD;
//typedef unsigned char BYTE;
//typedef unsigned short WORD;

#include <stdint.h>
typedef uint32_t DWORD;
typedef uint8_t  BYTE;
typedef uint16_t WORD;

#include <string.h>
#include <stdlib.h>
#define my_malloc   malloc
#define my_free     free
#define stricmp     strcasecmp
#define PSIZE       sizeof(int *)

DWORD pack_nrv2b( BYTE* inptr,
                  DWORD ilen,
                  BYTE* outptr/*,
                  void* (__cdecl*my_malloc)(unsigned int),
                  void (__cdecl*my_free)(void*) */)
{
  BYTE*  t_outptr;
  BYTE*  t_bitset;
  DWORD  t_bitcount;


  DWORD* ss11_len = (DWORD*)my_malloc((ilen+1)*4);
  for(DWORD q=0; q<=ilen; q++)
  {
    DWORD i = q;
    /*int*/ DWORD r = 0;
    if (i >= 2)
    {
      DWORD t = 4;
      i += 2;
      do {
          t <<= 1;
      } while (i >= t);
      t >>= 1;
      do {
          t >>= 1;
          r += 2;
      } while (t > 2);
    }
    ss11_len[q] = r+2;
  }

  DWORD sz = (ilen+1) << 2;
  BYTE* mem1 = (BYTE*)my_malloc(sz*6);
  memset(mem1, 0x00, sz*6);
  DWORD*c_off = (DWORD*)(mem1);
  DWORD*c_len = (DWORD*)(mem1+sz);
  DWORD*c_pak = (DWORD*)(mem1+sz*2);
  DWORD*c_lmo = (DWORD*)(mem1+sz*3);
  DWORD*c_prv = (DWORD*)(mem1+sz*4);
  DWORD*c_nxt = (DWORD*)(mem1+sz*5);

  BYTE* mem2 = (BYTE*)my_malloc(65536*4* /* 3 */ 2);
  memset(mem2, 0x00, 65536*4* /* 3 */ 2);
  DWORD*c_hash_max = (DWORD*)(mem2);
  DWORD*c_hash_cnt = (DWORD*)(mem2+65536*4*1);

  BYTE* mem2ptr = (BYTE*)my_malloc(65536*4*PSIZE);
  memset(mem2ptr, 0x00, 65536*4*PSIZE);
  DWORD**c_hash_ptr = (DWORD**)(mem2ptr);

/*  int i;  */
  DWORD i;
  for(i=0; i<ilen-1; i++)
  {
    DWORD w = *(WORD*)&inptr[i];
    if (c_hash_cnt[w] == c_hash_max[w])
    {
      if (c_hash_max[w] == 0)
        c_hash_max[w] = 1024;
      else
        c_hash_max[w] <<= 1;
      DWORD* newptr = (DWORD*)my_malloc(c_hash_max[w] << 2);
      if (c_hash_ptr[w] != NULL)
      {
        memcpy(newptr, c_hash_ptr[w], c_hash_cnt[w] << 2);
        my_free(c_hash_ptr[w]);
      }
      c_hash_ptr[w] = newptr;
    }
    c_hash_ptr[w][c_hash_cnt[w]++] = i;
  }

  c_lmo[0] = 1;

  // xxxxxxxxx

  for(i=0; i<ilen; i++)
  {

#define FOLLOW(src,dst,bitpaklen,lmo,off,len)                                 \
        {                                                                     \
          /*int*/ DWORD n = c_pak[src] + (bitpaklen);                                   \
          if ( (c_pak[dst] == 0) ||                                           \
               (  c_pak[dst] > n )  )                                         \
          {                                                                   \
            c_pak[dst] = n;                                                   \
            c_lmo[dst] = lmo;                                                 \
            c_off[dst] = off;                                                 \
            c_len[dst] = len;                                                 \
            c_prv[dst] = src;                                                 \
          }                                                                   \
        }

    FOLLOW(i,i+1,9,c_lmo[i],0,0)

    if (i < ilen-1)
    {
      WORD w = *(WORD*)&inptr[i];
      DWORD cnt = c_hash_cnt[w];
      for(/*int*/ DWORD c=0; c<cnt; c++)
      {
        /*int*/ DWORD z = c_hash_ptr[w][c];
        if (z >= i) break;
        DWORD t_off = i - z;
        DWORD t_len = 1;
        while((i+t_len<ilen)&&(inptr[i+t_len] == inptr[z+t_len]))
        {
          t_len++;

        if ((t_len > 2) || ((t_len == 2) && (t_off <= 0xd00)))
        {

          /*int*/ DWORD l;
          if (t_off == c_lmo[i])
            l = 5;
          else
          {
            l = 11 + ss11_len[1 + ((t_off - 1) >> 8)];
          }
          /*int*/ DWORD t = t_len - 1 - (t_off > 0xd00);
          if (t >= 4)
            l += ss11_len[t-4];

          if (l < (t_len << 3))
            FOLLOW(i,i+t_len,l,t_off, t_off,t_len)
        }
        }

      }
    }

  }

  // yyyyyyyy

  DWORD x = ilen;
  for(;;)
  {
    DWORD y = c_prv[x];
    c_nxt[y] = x;
    x = y;
    if (x == 0) break;
  }

  t_outptr   = outptr;

  t_bitset   = (BYTE*)t_outptr;
  t_outptr   += 1;
  *t_bitset  = 0;
  t_bitcount = 0;

  DWORD last_m_off = 1;

  x = 0;
  while(1)
  {
    DWORD y = c_nxt[x];
    if (y == 0) break;

    DWORD m_off = c_off[y];
    DWORD m_len = c_len[y];

    if (m_len == 0)
    {
      bbPutBit(1);
      *t_outptr++ = *inptr++;
      ilen--;
    }
    else
    {
      inptr += m_len;
      ilen  -= m_len;

      //
      bbPutBit(0);
      if (m_off == last_m_off)
      {
          bbPutBit(0);
          bbPutBit(1);
      }
      else
      {
          code_prefix_ss11(1 + ((m_off - 1) >> 8));
          *t_outptr++ = m_off - 1;
      }
      m_len = m_len - 1 - (m_off > 0xd00);
      if (m_len >= 4)
      {
          bbPutBit(0);
          bbPutBit(0);
          code_prefix_ss11(m_len - 4);
      }
      else
      {
          bbPutBit(m_len > 1);
          bbPutBit((unsigned)m_len & 1);
      }
      last_m_off = m_off;
      //

    }

    x = y;
  }

  bbPutBit(0);
  code_prefix_ss11(0x1000000);
  *t_outptr++ = 0xff;

  while(t_bitcount != 8)
    bbPutBit(0);

  for(i=0; i<65536; i++)
    if (c_hash_ptr[i])
      my_free(c_hash_ptr[i]);
  my_free(mem1);
  my_free(mem2);

  my_free(ss11_len);

  return t_outptr - outptr;

} // end of pack_nrv2b









//int __start_nrv2b() { return 1; }
//#include "0_nrv2b.cpp"
//int __end_nrv2b() { return 2; }

//int __start_nrv2d() { return 3; }
//#include "0_nrv2d.cpp"
//int __end_nrv2d() { return 4; }

//int __start_nrv2e() { return 5; }
//#include "0_nrv2e.cpp"
//int __end_nrv2e() { return 6; }

int main(int argc, char* argv[])
{
/*
  if (argc == 2)
  if (!stricmp(argv[1],"--gimmeyourbrain"))
  {
    printf("nrv2b: code size = %d\n", (int)&__end_nrv2b - (int)&__start_nrv2b);
    printf("nrv2d: code size = %d\n", (int)&__end_nrv2d - (int)&__start_nrv2d);
    printf("nrv2e: code size = %d\n", (int)&__end_nrv2e - (int)&__start_nrv2e);
    FILE*f0=fopen("pack_nrv2b.bin","wb");
    fwrite((char*)&__start_nrv2b + 16, 1,(int)&__end_nrv2b - (int)&__start_nrv2b - 16, f0);
    fclose(f0);
    FILE*f1=fopen("pack_nrv2d.bin","wb");
    fwrite((char*)&__start_nrv2d + 16, 1,(int)&__end_nrv2d - (int)&__start_nrv2d - 16, f1);
    fclose(f1);
    FILE*f2=fopen("pack_nrv2e.bin","wb");
    fwrite((char*)&__start_nrv2e + 16, 1,(int)&__end_nrv2e - (int)&__start_nrv2e - 16, f2);
    fclose(f2);
    exit(0);
  }
*/
  /*if (argc!=4) */ if (argc!=3)
  {
//    printf("syntax: pack --nrv2b|--nrv2d|--nrv2e infile outfile\n", argv[0]);
    printf("syntax: %s infile outfile\n", argv[0]);
    exit(0);
  }

  FILE*f1=fopen(argv[1],"rb");
if (NULL == f1) {
    printf("Unable to open %s for reading\n", argv[1]);
    exit(-1);
}
//  int ilen = filelength(fileno(f1));
fseek(f1, 0, SEEK_END); // seek to end of file
int ilen = ftell(f1); // get current file pointer
fseek(f1, 0, SEEK_SET); // seek back to beginning of file

  BYTE* ibuf = new BYTE[ ilen ];
  fread(ibuf,1,ilen,f1);
  fclose(f1);

  BYTE* obuf = new BYTE[ ilen+(ilen>>3)+1024 ];
  BYTE* xbuf = new BYTE[ ilen+1024 ];
  /* DWORD olen=0, xlen=0; */
  int olen=0;

//  DWORD t0 = GetTickCount();

  /*if (!stricmp(argv[1],"--nrv2b"))*/ olen = pack_nrv2b(ibuf,ilen,obuf/*,&malloc,&free*/);
//  if (!stricmp(argv[1],"--nrv2d")) olen = pack_nrv2d(ibuf,ilen,obuf/*,&malloc,&free*/);
//  if (!stricmp(argv[1],"--nrv2e")) olen = pack_nrv2e(ibuf,ilen,obuf/*,&malloc,&free*/);

//  DWORD t1 = GetTickCount();
  printf("packed: %d --> %d\n", ilen, olen);
//  printf("time: %d ms\n",t1-t0);

//  if (!stricmp(argv[1],"--nrv2b")) xlen = unpack_nrv2b(obuf,xbuf);
//  if (!stricmp(argv[1],"--nrv2d")) xlen = unpack_nrv2d(obuf,xbuf);
//  if (!stricmp(argv[1],"--nrv2e")) xlen = unpack_nrv2e(obuf,xbuf);
//  printf("unpacked: %d --> %d\n", olen,xlen);

  fflush(stdout);
//  assert(ilen==(int)xlen);
//  assert(memcmp(ibuf,xbuf,xlen)==0);
//  printf("verify OK\n");

  FILE*f2=fopen(argv[2],"wb");
if (NULL == f2) {
    printf("Unable to open %s for writing\n", argv[2]);
    exit(-1);
}
  fwrite(obuf,1,olen,f2);
  fclose(f2);

  delete ibuf;
  delete obuf;
  delete xbuf;

} // main


