/*
// make block & mask
*/

/*
// maak de blocken uit de PI1 plaatjes
// maak masks van voorgrond objecten
// maak same tabel van de masks
// maak block lookuptabel (duo_block_table) 128 bytes voor
// duo_block_table staat de animatie lookup table (ani_table).
*/

/*
// structuur van de pi1 plaatjes:
// twee plaatjes: origblk0.pi1 en origblk1.pi1
// ieder plaatje bevat 8 rijen blokken
// een rij blokken bestaat uit 16 lijnen data en dan 8 lijnen bagger
// een data lijn bevat data voor 8 blokken
// eerst 4 woorden blok data
// dan 4 woorden mask data
*/

/*
// de output mask data bestaat uit
// byte mask_same[]
//   dit is een arry van 128 bytes die de offset van een 
//   bepaalde mask in de mask data array geeft
// byte masks_0[]
//   bevat de masks op shift level 0
//   van onder naar boven 16 lijnen
//   met op iedere lijn 1 word links data en 1 word rechts data
//   op shift level 0 is links data leeg en bevat rechts data de 
//   gehele mask
// byte masks_1[]
//   bevat de masks op shift level 1, 4 pixels
// byte masks_2[]
//   bevat de masks op shift level 2, 8 pixels
// byte masks_3[]
//   bevat de masks op shift level 3, 12 pixels
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "..\hland.h"

unsigned int maskdata[2048]; /* niet geshift */
unsigned int blokdata[8192];
byte same[128];
byte same2[128];
unsigned int buf[100000UL];
byte array[128L*128L*2L+2L];

#include "map_data.c"

/****************************************************************/


/* -1 */
byte munt_ani[]=
{
  0x78,
  0x79,
  0x7a,
  0x7b,
  0x7b,
  0x7a,
  0x79,
  0x78,
  0x78,
  0x79,
  0x7a,
  0x7b,
  0x7b,
  0x7a,
  0x79,
  0x78,
};

/* -2 */
char fles_ani[]=
{
  0x70,
  0x71,
  0x72,
  0x71,
  0x70,
  0x77,
  0x76,
  0x77,
  0x70,
  0x71,
  0x72,
  0x71,
  0x70,
  0x77,
  0x76,
  0x77,
};

/* -3 */
char punt_ani[]=
{
  0x1e,
  0x26,
  0x27,
  0x28,
  0x29,
  0x2a,
  0x2b,
  0x2c,
  0x3b,
  0x2c,
  0x2b,
  0x2a,
  0x29,
  0x28,
  0x27,
  0x26,
};

char* ani_select[]=
{
  punt_ani,
  fles_ani,
  munt_ani,
};

void do_ani(signed char last, signed char new)
{
  int i;
  for(i=0; i<ANI_LEN; i++)
  {
    signed char a;
    signed char b;
    int index;
    if(last<0)
    {
      a=same2[ani_select[ANIMATED_OBJECTS+last][i]];
    }
    else
    {
      a=same2[last];
    }
    if(new<0)
    {
      b=same2[ani_select[ANIMATED_OBJECTS+new][i]];
    }
    else
    {
      b=same2[new];
    }
    index=a;
    index<<=7;
    index+=b;
    buf[index]=1;
  }
}

void do_add(signed char new, signed char last)
{
  if((new<0) || (last<0))
  {
    do_ani(last, new);
  }
  else
  {
    int index=same2[last];
    index<<=7;
    index+=same2[new];
    buf[index]=1;
  }
}

void do_array(void)
{ /* maak duoblock lookup tabel */
  signed char* map=game_map;
  signed char last=0;
  long i;
  for(i=0; i<128*128; i++)
  {
    buf[i]=0;
  }
  for(i=0; i<54000L; i++)
  {
    signed char new=*map++;
    do_add(new, last);
    switch(new)
    { /* handle removable objecten */
    case -2: /* flesje */
      do_add(0x0f, last);
      if(last<0)
      {
        if(last==-1)
        {
          do_add(0x0f, 0x0e);
        }
        else
        {
          do_add(0x0f, 0x0f);
        }
      }
      break;
    case -1: /* muntje */
      do_add(0x0e, last);
      if(last<0)
      {
        if(last==-1)
        {
          do_add(0x0e, 0x0e);
        }
        else
        {
          do_add(0x0e, 0x0f);
        }
      }
      break;
    case 0x6c: /* kaarten */
    case 0x6d:
    case 0x6e:
    case 0x6f:
      do_add(0x10, last);
      break;
    case 0x46: /* teleport */
    case 0x47:
    case 0x48:
    case 0x49:
    case 0x4a:
    case 0x4b:
    case 0x60:
    case 0x61:
    case 0x62:
      switch(last)
      {
      case 0x46:
      case 0x47:
      case 0x48:
      case 0x49:
      case 0x4a:
      case 0x4b:
      case 0x60:
      case 0x61:
      case 0x62:
        do_add(0x0e, 0x0e);
      break;
      default:
        do_add(0x0e, last);
      }
    break;
    default:
      (void)0;
    }
    switch(last)
    { /* handle removable objecten */
    case -2: /* flesje */
      do_add(new, 0x0f);
      break;
    case -1: /* muntje */
      do_add(new, 0x0e);
      break;
    case 0x6c: /* kaarten */
    case 0x6d:
    case 0x6e:
    case 0x6f:
      do_add(new, 0x10);
      break;
    case 0x46: /* teleport */
    case 0x47:
    case 0x48:
    case 0x49:
    case 0x4a:
    case 0x4b:
    case 0x60:
    case 0x61:
    case 0x62:
      switch(last)
      {
      case 0x46:
      case 0x47:
      case 0x48:
      case 0x49:
      case 0x4a:
      case 0x4b:
      case 0x60:
      case 0x61:
      case 0x62:
        do_add(0x0e, 0x0e);
      break;
      default:
        do_add(new, 0x0e);
      }
    break;
    default:
      (void)0;
    }
    last=new;
  }
}

void do_block(void)
{
  long i;
  long count=0;
  do_array();
  memset(array, 0, sizeof(array));
  for(i=0; i<128; i++)
  {
    int j;
    for(j=0; j<128; j++)
    {
      if(buf[i*128+j]!=0)
      {
        count++;
        *(long*)(array+i*256+j*2)|=count<<7;
      }
    }
  }
  for(i=0; i<128; i++)
  {
    int j;
    for(j=0; j<128; j++)
    {
      if(buf[i*128+j]==0)
      {
        int index;
        index=same2[i];
        index<<=7;
        index+=same2[j];
        if((buf[index]!=0) && (i<=0x7b) && (j<=0x7b)
           && (i!= 0x73) && (i!= 0x74) && (i!= 0x75) 
           && (j!= 0x73) && (j!= 0x74) && (j!= 0x75)) /* geen dubbele animaties */
        {
          long data;
          data=*(long*)(array+index*2);
          data=data&(0xffffL<<7);
          *(long*)(array+i*256+j*2)|=data;
        }
      }
    }
  }
  printf("Totaal aantal doublocks = %li.\n", count);
}

/****************************************************************/

void make_it(void)
{ /* lees de pi1 data */
  FILE *f;
  int i;
  unsigned int *p;
  unsigned int *q;
  unsigned int *r;
  f=fopen("origblk0.pi1","rb");
  if(f==NULL)
  {
    printf("origblk0.pi1 error!\n");
    exit(-1);
  }
  fread(buf, 32768UL, 1, f);
  fclose(f);
  p=buf+17;
  q=blokdata;
  r=maskdata;
  for(i=0;i<8;i++)
  { /* rijen */
    int j;
    for(j=0;j<8;j++)
    { /* blokken */
      int k;
      for(k=0;k<16;k++)
      { /* lijnen */
        unsigned int mask;
        *q++=p[(i*24+k)*80+j*8+0];
        *q++=p[(i*24+k)*80+j*8+1];
        *q++=p[(i*24+k)*80+j*8+2];
        *q++=p[(i*24+k)*80+j*8+3];
        mask=p[(i*24+k)*80+j*8+4];
        mask|=p[(i*24+k)*80+j*8+5];
        mask|=p[(i*24+k)*80+j*8+6];
        mask|=p[(i*24+k)*80+j*8+7];
        *r++=mask;
      }
    }
  }
  f=fopen("origblk1.pi1","rb");
  if(f==NULL)
  {
    printf("origblk1.pi1 error!\n");
    exit(-1);
  }
  fread(buf, 32768UL, 1, f);
  fclose(f);
  p=buf+17;
  for(i=0;i<8;i++)
  { /* rijen */
    int j;
    for(j=0;j<8;j++)
    { /* blokken */
      int k;
      for(k=0;k<16;k++)
      { /* lijnen */
        unsigned int mask;
        *q++=p[(i*24+k)*80+j*8+0];
        *q++=p[(i*24+k)*80+j*8+1];
        *q++=p[(i*24+k)*80+j*8+2];
        *q++=p[(i*24+k)*80+j*8+3];
        mask=p[(i*24+k)*80+j*8+4];
        mask|=p[(i*24+k)*80+j*8+5];
        mask|=p[(i*24+k)*80+j*8+6];
        mask|=p[(i*24+k)*80+j*8+7];
        *r++=mask;
      }
    }
  }
}

int cmp(unsigned int* src, unsigned int* dst, int wc)
{ /* compare; 0= zelfde, 1 niet zelfde */
  do
  {
    if(*src++!=*dst++)
    {
      return 1;
    }
  }
  while(--wc>0);
  return 0;
}

int cmpa(unsigned int* src, unsigned int* dst, int cnt, int wc)
{ /* compare; <cnt = zelfde, cnt niet zelfde */
  int i;
  for(i=0;i<cnt;i++)
  {
    if(cmp(src, dst+i*wc, wc)==0)
    {
      return i;
    }
  }
  return i;
}

int find_same(unsigned int* data, int wc)
{
  int i;
  int count=0;
  same[0]=count++;
  for(i=1;i<128;i++)
  {
    int res=cmpa(data+wc*i, data, i, wc);
    same2[i]=res;
    if(res==i)
    { /* nieuwe same gevonden */
      same[i]=count++;
      #if 0
      printf("nieuw same %x = %x\n", i, same[i]);
      #endif
    }
    else
    {
      same[i]=same[res];
      #if 0
      printf("same %x = %x\n", i, res);
      #endif
    }
  }
  printf("uniek = %i\n", count);
  return count;
}

void doit(FILE* outf, void* data, char* naam, long len)
{
  long i;
  int w=128;
  byte *p=(byte *)data;
  printf("Doing: %s\n", naam);
  fprintf(outf, "\nexport %s\nDATA\nEVEN\n", naam);
  fprintf(outf, "%s: \n", naam, len);
  for(i=0; i<len; i++)
  {
    if(w>=16)
    {
      fprintf(outf,"\ndc.b ");
      w=0;
    }
    fprintf(outf, "%i,", p[i]);
    w++;
  }
  fprintf(outf, "\n");
}

void make_masks(int shift_level)
{
  unsigned int* p=buf;
  int count=0;
  int i;
  shift_level*=4;
  for(i=0;i<128;i++)
  {
    if(same[i]==count)
    { /* uniek blok gevonden */
      unsigned long data;
      int j;
      for(j=0;j<16;j++)
      {
        data=(unsigned long)(~maskdata[i*16+15-j]);
        data<<=shift_level;
        *p++=(unsigned int)((data>>16)& 0xFFFF);
        *p++=(unsigned int)(data & 0xFFFF);
      }
      count++;
    }
  }
}

int update_array[2000];

void update_duo_ani(int ani_count)
{
  int i;
  byte *buffer=(byte*)buf;
  for(i=0; i<128; i++)
  {
    int j;
    for(j=0; j<128; j++)
    {
      long data=0;
      long tmp=0;
      int index;
      switch(i)
      {
      case 0x78:
        index=munt_ani[ani_count];
        break;
      case 0x70:
        index=fles_ani[ani_count];
        break;
      case 0x1e:
        index=punt_ani[ani_count];
        break;
      default:
        index=i;
      }
      index<<=7;
      switch(j)
      {
      case 0x78:
        index+=munt_ani[ani_count];
        break;
      case 0x70:
        index+=fles_ani[ani_count];
        break;
      case 0x1e:
        index+=punt_ani[ani_count];
        break;
      default:
        index+=j;
      }
      index*=2;
      data=*(long*)(array+index);
      data&=0x7fff80UL;
      tmp=*(long*)(buffer+i*256+j*2);
      tmp&=~0x7fff80UL;
      tmp|=data;
      *(long*)(buffer+i*256+j*2)=tmp;
    }
  }
}

void make_ani_tables(FILE* f)
{
  long i;
  int count=0;
  int last=-1;
  long tikken=0;
  for(i=0; i<128; i++)
  {
    long j;
    for(j=0; j<128; j++)
    {
      if((j>0x7b) || (i>0x7b))
      {
        long tmp=*(long*)(array+i*256+j*2);
        tmp&=0x7fff80UL;
        if(tmp!=0)
        {
          printf("?? Data op i=%li, j=%li\n", i, j);
        }
      }
      if((j==0x78)  || (j==0x70)  || (j==0x1e)  || 
         (i==0x78)  || (i==0x70)  || (i==0x1e))
      {
        long tmp=*(long*)(array+i*256+j*2);
        tmp&=0x7fff80UL;
        if(tmp!=0)
        {
          int current=(int)(i*256+j*2);
          if(current!=last)
          {
            update_array[count]=current;
            count++;
          }
          current+=2;
          update_array[count]=current;
          last=current;
          count++;
        }
      }
    }
  }
  update_array[count]=-1;
  fprintf(f, "export ani_duo_blocks\nTEXT\n; D0 = game animatie counter x4\n"
             "; A3 = duo_block table\n; A5 = return adres\n"
             "fixes:\ndc.l fixa, fixb, fixc, fixd, fixe, fixf, fixg, fixh\n"
             "dc.l fixi, fixj, fixk, fixl, fixm, fixn, fixo, fixp\nani_duo_blocks:\n"
             "     move.l fixes(pc,d0.w),a4\n");
  for(i=0; i<count; i++)
  {
    int current=update_array[i];
    if(update_array[i+1]==current+2)
    { /* long output */
      tikken+=24;
      fprintf(f, "     move.l (a4)+,%i(a3)\n", current);
      i++;
    }
    else
    {
      fprintf(f, "     move.w (a4)+,%i(a3)\n", current);
      tikken+=16;
    }
  }
  fprintf(f, "     jmp (a5)\n");
  printf("Aantal gebruikte tikken = %li voor het fixen van %i duoblocks.\n", tikken, count);
  for(i=0; i<ANI_LEN; i++)
  {
    int j;
    char naam[10];
    byte *buffer=(byte*)buf;
    memcpy(buffer, array, sizeof(array));
    update_duo_ani((int)i);
    for(j=0; j<count; j++)
    {
      *(word*)(buffer+0x10000UL+j*2)=*(word*)(buffer+update_array[j]);
    }
    sprintf(naam, "fix%c", (int)(i+'a'));
    doit(f, buffer+0x10000L, naam, count*2);
  }
}



int main(void)
{
  FILE*f;
  long uniek;
  { /* re fix map */
    long i;
    signed char *p=game_map;
    for(i=0; i<54000L; i++)
    {
      switch(p[i])
      {
      case 0x1e:
        p[i]=-3;
        break;
      case 0x70:
        p[i]=-2;
        break;
      case 0x78:
        p[i]=-1;
        break;
      default:
        (void) 0;
      }
    }
  }   
  if((f=fopen("blokdata.s","w"))==NULL)
  {
    printf("blokdata file open error!\n");
    return -1;
  }
  fprintf(f,";\n"
            "; file generated by: " __FILE__ "\n"
            ";/\n\n"
         );
  make_it();
  
  printf("Doing mask data...\n");
  uniek=find_same(maskdata, 16);
  doit(f, same, "mask_same", 128);
  make_masks(0);
  doit(f, buf, "masks_0", uniek*16*4);
  make_masks(1);
  doit(f, buf, "masks_1", uniek*16*4);
  make_masks(2);
  doit(f, buf, "masks_2", uniek*16*4);
  make_masks(3);
  doit(f, buf, "masks_3", uniek*16*4);

  printf("Doing block data...\n");
  uniek=find_same(blokdata, 4*16);
  doit(f, blokdata, "blocks", 128*16*8);
  do_block();
  fprintf(f, "\nEXPORT ani_table\nani_table:\n");
  {
    int i;
    for(i=0; i<8; i++)
    {
      int j;
      fprintf(f, "dc.b ");
      for(j=0; j<16; j++)
      {
        fprintf(f, "%i, ", i*16+j);
      }
      fprintf(f, "\n");
    }
  }
  doit(f, array, "duo_block_table", 128L*128L*2L+2L);
  {
    make_ani_tables(f);
  }
  fclose(f);
  return 0;
}


