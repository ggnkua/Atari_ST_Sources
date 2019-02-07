/*:*************************************************************************/
/*                                                                         */
/*  IFF routines.   Written by Tom Hudson      Rev. 7/15/86                */
/*                                                                         */
/*  START magazine, Fall 1986.      Copyright 1986 by Antic Publishing     */
/*                                                                         */
/*  To promote the IFF standard, this program is freeware. NOT to be sold. */
/*                                                                         */
/***************************************************************************/

#include <osbind.h>;

#define cmpNone 0       /* No compression                       */
#define cmpByteRun1 1   /* Run-length encoding compression      */

/*************************************************/
/* My IFF read/write routine error codes         */
/*************************************************/

#define NotForm -1      /* File is not a FORM type              */
#define NoHead  -2      /* File does not have a BMHD header     */
#define NoData  -3      /* File has no image data               */
#define Incomplete -4   /* Incomplete image data                */

/*************************************************/
/*               GLOBAL DATA AREA                */
/*************************************************/

int Syspal[16];         /* ST hardware palette array            */
int Gempal[16][3];      /* GEM palette data array               */
int xparent;            /* transparent color index              */

/*************************************************/
/*               MODULE DATA AREA                */
/*************************************************/

static long FORM = 0x464f524d;          /* "FORM" */
static long BODY = 0x424f4459;          /* "BODY" */
static long BMHD = 0x424d4844;          /* "BMHD" */
static long CMAP = 0x434d4150;          /* "CMAP" */
static long ILBM = 0x494c424d;          /* "ILBM" */

static long form_size,BMHD_size;
struct BMHD_data
 {
 int w,h;                       /* width & height of block      */
 int x,y;                       /* X & Y coord within block     */
 char nPlanes;                  /* number of bit planes         */
 char masking;                  /* masking (ignored)            */
 char compression;              /* compression flag             */
 char padding;                  /* unused filler byte           */
 int transcolor;                /* transparent color number     */
 char xAspect,yAspect;          /* pixel aspect ratios          */
 int pageWidth,pageHeight;      /* width & height of page       */
 };
struct BMHD_data bmhd;

struct Chunk
 {
 long chk_ID;                   /* 4-character chunk ID         */
 long chk_size;                 /* chunk size in bytes          */
 };
struct Chunk chk;

/*************************************************/
/* Read an IFF identifier and size into memory   */
/*                                               */
/* Format:                                       */
/* iff_id(fhand)                                 */
/*                                               */
/* Where:                                        */
/* fhand = handle of file opened for input       */
/*                                               */
/* Returns:                                      */
/* 0  = OK (no error)                            */
/* -1 = Read error has occurred                  */
/*                                               */
/*************************************************/

iff_id(fhand)
int fhand;
{
if(Fread(fhand,8L,&chk)==8L)
 return(0);
return(-1);
}

/*************************************************/
/* Read an IFF color map into memory and change  */
/* it into a form we can use.                    */
/*                                               */
/* Format:                                       */
/* proc_CMAP(fhand)                              */
/*                                               */
/* Where:                                        */
/* fhand = handle of file opened for input       */
/*                                               */
/* Returns:                                      */
/* 0  = OK (no error)                            */
/* -1 = Error has occurred                       */
/*                                               */
/* Alters:                                       */
/* Syspal array contains system format palette   */
/* Gempal array contains GEM palette data        */
/*                                               */
/*************************************************/

proc_CMAP(fhand)
int fhand;
{
register int pal_ix,pal_odd;
static char R_G_B[3];

/* GEM palette entry offsets */

static int paloff[16]=
 {
 0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,1
 };

pal_odd=chk.chk_size & 1;
pal_ix=0;
while(chk.chk_size>0L && pal_ix<16)
 {
 if(Fread(fhand,3L,R_G_B)<3L)
  return(-1);
 Syspal[pal_ix]=(((int)R_G_B[0] << 3) & 0x0700) |
                (((int)R_G_B[1] >> 1) & 0x0070) |
                (((int)R_G_B[2] >> 5) & 0x0007);
 Gempal[paloff[pal_ix]][0]=(((int)R_G_B[0] >> 5) & 7) * 142;
 Gempal[paloff[pal_ix]][1]=(((int)R_G_B[1] >> 5) & 7) * 142;
 Gempal[paloff[pal_ix++]][2]=(((int)R_G_B[2] >> 5) & 7) * 142;
 chk.chk_size-=3;
 }
Fseek((long)(chk.chk_size+pal_odd),fhand,1);
return(0);
}

/*************************************************/
/* Read a compressed IFF BODY scan line and      */
/* place it into the memory form designated by   */
/* user.                                         */
/*                                               */
/* Format:                                       */
/* decompress(fhand,mfdb,use,row,plane,RAMptr)   */
/*                                               */
/* Where:                                        */
/* fhand = handle of file opened for input       */
/* mfdb  = standard GEM MFDB for bit block       */
/* use   = 1 to use data, 0 to ignore            */
/* row   = word row to read                      */
/* plane = plane to read                         */
/* RAMptr= pointer to form buffer                */
/*                                               */
/*************************************************/

decompress(fhand,mfdb,use,row,plane,RAMptr)
int fhand,mfdb[16],use;
unsigned row,plane;
char RAMptr[];
{
register int ix;
register unsigned offset,offinc;
static int dccount,dcptr,ffbytes;
static char decombuf[160],comp_flg,comp_byte;

dccount=(((bmhd.w+15)>>4)<<1);

dcptr=0;
while(dccount)
 {
 if(Fread(fhand,1L,&comp_flg)<1)
  return(-1);
 if(comp_flg>=0)
  {
  comp_flg++;
  dccount-=comp_flg;
  if(Fread(fhand,(long)comp_flg,&decombuf[dcptr])<(long)comp_flg)
   return(-1);
  dcptr+=comp_flg;
  }
 else
 if(comp_flg != -128)
  {
  comp_flg= -comp_flg+1;
  dccount-=comp_flg;
  if(Fread(fhand,1L,&comp_byte)<1L)
   return(-1);
  for(ix=0; ix<comp_flg; ++ix)
   decombuf[dcptr++]=comp_byte;
  }
 }
if(use)
 toraster(mfdb,row,plane,decombuf,RAMptr);
return(0);
}

/*************************************************/
/* Read an uncompressed IFF BODY scan line into  */
/* designated memory.                            */
/*                                               */
/* Format:                                       */
/* rawread(fhand,mfdb,use,row,plane,RAMptr)      */
/*                                               */
/* Where:                                        */
/* fhand = handle of file opened for input       */
/* mfdb  = standard GEM MFDB for bit block       */
/* use   = 1 to use data, 0 to ignore            */
/* row   = word row to read                      */
/* plane = plane to read                         */
/* RAMptr= pointer to form buffer                */
/*                                               */
/*************************************************/

rawread(fhand,mfdb,use,row,plane,RAMptr)
int fhand,mfdb[16],use;
unsigned row,plane;
char RAMptr[];
{
int dccount;
static char decombuf[160];

dccount=(((bmhd.w+15)>>4)<<1);

if(Fread(fhand,(long)dccount,decombuf)<(long)dccount)
 return(-1);
if(use)
 toraster(mfdb,row,plane,decombuf,RAMptr);
return(0);
}

/*************************************************/
/* Write a scan line to the IFF-format file (no  */
/* compression)                                  */
/*                                               */
/* Format:                                       */
/* rawwrite(fhand,mfdb,row,plane,RAMptr)         */
/*                                               */
/* Where:                                        */
/* fhand = handle of file opened for output      */
/* mfdb  = standard GEM MFDB for bit block       */
/* row   = row to write                          */
/* plane = plane to write                        */
/* RAMptr= pointer to form buffer                */
/*                                               */
/*************************************************/

rawwrite(fhand,mfdb,row,plane,RAMptr)
int fhand,mfdb[];
unsigned row,plane;
char RAMptr[];
{
long dccount;
static char decombuf[160];

dccount=(long)(((bmhd.w+15)>>4)<<1);

fmraster(mfdb,row,plane,decombuf,RAMptr);
if(Fwrite(fhand,dccount,decombuf)<dccount)
 return(-1);
form_size+=dccount;
return(0);
}

/*************************************************/
/* Convert the decompressed raw screen data to   */
/* the ST's device-specific interleaved format.  */
/*                                               */
/* Format:                                       */
/* toraster(mfdb,row,plane,decombuf,RAMptr)      */
/*                                               */
/* Where:                                        */
/* mfdb  = standard GEM MFDB for bit block       */
/* row   = row to write                          */
/* plane = plane to write                        */
/* decombuf = form data buffer                   */
/* RAMptr= pointer to form buffer                */
/*                                               */
/*************************************************/

toraster(mfdb,row,plane,decombuf,RAMptr)
int mfdb[10];
unsigned row,plane;
char decombuf[],RAMptr[];
{
static unsigned ix,ffbytes,offset,offinc;

ffbytes=mfdb[4]*2;
offinc=mfdb[6]*2;
offset=row*ffbytes*(unsigned)mfdb[6]+plane*2;
for(ix=0; ix<ffbytes; offset+=offinc)
 {
 RAMptr[offset]=decombuf[ix++];
 RAMptr[offset+1]=decombuf[ix++];
 }
}

/*************************************************/
/* Convert a scan line from the ST's interleaved */
/* form to a block of raw data in the temporary  */
/* buffer.                                       */
/*                                               */
/* Format:                                       */
/* fmraster(mfdb,row,plane,decombuf,RAMptr)      */
/*                                               */
/* Where:                                        */
/* mfdb  = standard GEM MFDB for bit block       */
/* row   = word row to convert                   */
/* plane = plane to convert                      */
/* decombuf = temporary data buffer              */
/* RAMptr= pointer to form buffer                */
/*                                               */
/*************************************************/

fmraster(mfdb,row,plane,decombuf,RAMptr)
int mfdb[10];
unsigned row,plane;
char decombuf[],RAMptr[];
{
static unsigned ix,ffbytes,offset,offinc;

ffbytes=mfdb[4]*2;
offinc=mfdb[6]*2;
offset=row*ffbytes*(unsigned)mfdb[6]+plane*2;
for(ix=0; ix<ffbytes; offset+=offinc)
 {
 decombuf[ix++]=RAMptr[offset];
 decombuf[ix++]=RAMptr[offset+1];
 }
}

/*************************************************/
/* Do a phase 1 IFF file read.                   */
/*                                               */
/* Format:                                       */
/* iff_rd1(fhand,mfdb)                           */
/*                                               */
/* Where:                                        */
/* fhand = handle of file opened for input       */
/* mfdb  = standard GEM MFDB for bit block       */
/*                                               */
/* Returns:                                      */
/* 0  = OK (no error)                            */
/* <0 = IFF read error code                      */
/*                                               */
/*************************************************/

int iff_rd1(fhand,mfdb)
int fhand,mfdb[10];
{
static char rgb_buf[3];

if(iff_id(fhand)<0)
 return(NoData);
if(chk.chk_ID!=FORM)
 return(NotForm);
Fseek(4L,fhand,1);              /* Skip ILBM block */

/* Now look for BMHD */

BMHD_loop:
if(iff_id(fhand)<0)
 return(NoHead);
if(chk.chk_ID!=BMHD)
 {
 Fseek(chk.chk_size,fhand,1);
 goto BMHD_loop;
 }

if(Fread(fhand,20L,&bmhd)<20L)
 return(Incomplete);
xparent=bmhd.transcolor;
if(xparent>15)
 xparent=0;

CMAP_BODY:
if(iff_id(fhand)<0)
 return(NoHead);
if(chk.chk_ID==CMAP)
 {
 if(proc_CMAP(fhand)<0)
  return(Incomplete);
 goto CMAP_BODY;
 }
else
if(chk.chk_ID!=BODY)
 {
 Fseek(chk.chk_size,fhand,1);
 goto CMAP_BODY;
 }

/* Got BODY Header, process into MFDB data */

mfdb[5]=mfdb[7]=mfdb[8]=mfdb[9]=0;
mfdb[2]=bmhd.w;
mfdb[3]=bmhd.h;
mfdb[4]=(mfdb[2]+15)/16;
mfdb[6]=bmhd.nPlanes;

/* Return to caller */

return(0);
}

/*************************************************/
/* Do phase 2 IFF file read.                     */
/*                                               */
/* Format:                                       */
/* iff_rd2(fhand,mfdb)                           */
/*                                               */
/* Where:                                        */
/* fhand = handle of file opened for input       */
/* mfdb  = standard GEM MFDB for bit block       */
/*                                               */
/* Returns:                                      */
/* 0  = OK (no error)                            */
/* <0 = IFF read error code                      */
/*                                               */
/*************************************************/

int iff_rd2(fhand,mfdb)
int fhand,mfdb[16];
{
register int ix,useit,bytect;
register unsigned row,plane;
register char *RAMptr;

RAMptr=(char *)(((long)mfdb[0]<<16) | (((long)mfdb[1]) & 0x0000ffffL));
bytect=mfdb[3]*mfdb[4]*mfdb[6]*2;

/* Clear memory form to zeroes     */

for(ix=0; ix<bytect; RAMptr[ix++]=0);

/* Read memory form data from file */

for(row=0; row<mfdb[3]; row++)
 {
 for(plane=0; plane<bmhd.nPlanes; plane++)
  {
  if(plane<mfdb[6])
   useit=1;
  else
   useit=0;
  if(bmhd.compression==cmpByteRun1)
   {
   if(decompress(fhand,mfdb,useit,row,plane,RAMptr)<0)
    return(Incomplete);
   }
  else
  if(bmhd.compression==cmpNone)
   {
   if(rawread(fhand,mfdb,useit,row,plane,RAMptr)<0)
    return(Incomplete);
   }
  else
   return(Incomplete);
  }
 }
return(0);
}

/*************************************************/
/* Write a bit block to disk in an IFF file.     */
/*                                               */
/* Format:                                       */
/* iff_wrt(fhand,mfdb,palette,picrez)            */
/*                                               */
/* Where:                                        */
/* fhand = handle of file opened for output      */
/* mfdb  = standard GEM MFDB for bit block       */
/* palette = ST color palette array              */
/* picrez = resolution flag (0, 1 or 2)          */
/*                                               */
/* Returns:                                      */
/* 0  = OK (no error)                            */
/* -1 = write error                              */
/*                                               */
/*************************************************/

iff_wrt(fhand,mfdb,palette,picrez)
int fhand,mfdb[],palette[],picrez;
{
unsigned row,plane;
register int ix;
long bodysize,bloksize,RAMptr;
static long headsize=20;
static int xaspect[3] = {10,5,10};
static int colregs[3] = {16,4,2};
static char rgb_buf[3];

form_size=0;
Fwrite(fhand,4L,&FORM);
Fwrite(fhand,4L,&form_size);    /* dummy value */
Fwrite(fhand,4L,&ILBM);
Fwrite(fhand,4L,&BMHD);
Fwrite(fhand,4L,&headsize);

bmhd.w=bmhd.pageWidth=mfdb[2];
bmhd.h=bmhd.pageHeight=mfdb[3];
bmhd.x=bmhd.y=bmhd.masking=bmhd.padding=bmhd.transcolor=0;
bmhd.nPlanes=mfdb[6];
bmhd.compression=cmpNone;
bmhd.xAspect=xaspect[picrez];
bmhd.yAspect=11;

if(Fwrite(fhand,20L,&bmhd)<20L)
 return(-1);

Fwrite(fhand,4L,&CMAP);
bloksize=(long)(colregs[picrez]*3);
Fwrite(fhand,4L,&bloksize);
form_size=40L;                  /* current file length */
for(ix=0; ix<colregs[picrez]; ++ix)
 {
 rgb_buf[0]=(palette[ix] >> 3) & 0x00e0;
 rgb_buf[1]=(palette[ix] << 1) & 0x00e0;
 rgb_buf[2]=(palette[ix] << 5) & 0x00e0;
 Fwrite(fhand,3L,rgb_buf);
 form_size+=3L;
 }

Fwrite(fhand,4L,&BODY);
bodysize=((mfdb[2]+15)/16)*2*mfdb[6]*mfdb[3];
Fwrite(fhand,4L,&bodysize);
form_size+=8L;

RAMptr=(char *)(((long)mfdb[0]<<16) | (((long)mfdb[1]) & 0x0000ffffL));
for(row=0; row<mfdb[3]; ++row)
 {
 for(plane=0; plane<mfdb[6]; ++plane)
  {
  if(rawwrite(fhand,mfdb,row,plane,RAMptr)<0L)
   return(-1);
  }
 }
Fseek(4L,fhand,0);
Fwrite(fhand,4L,&form_size);
return(0);
}

