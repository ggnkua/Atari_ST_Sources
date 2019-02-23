/*************************************************/
/*  DEGAS normal/compressed file read routines   */
/*                by Tom Hudson                  */
/*************************************************/

#include <osbind.h>;

/******************************/
/* Global data for DEGAS read */
/******************************/

int anileft[4],aniright[4],anidir[4],anispd[4];

/*************************************************/
/*               MODULE DATA AREA                */
/*************************************************/

struct BMHD_data
 {
 int w,h;			/* width & height of block	*/
 int x,y;			/* X & Y coord within block	*/
 char nPlanes;			/* number of bit planes		*/
 char masking;			/* masking (ignored)		*/
 char compression;		/* compression flag		*/
 char padding;			/* unused filler byte		*/
 int transcolor;		/* transparent color number	*/
 char xAspect,yAspect;		/* pixel aspect ratios		*/
 int pageWidth,pageHeight;	/* width & height of page	*/
 };
struct BMHD_data bmhd;

static char *Mptr;
static long remain;

/*************************************************/
/* Memory read subroutine to speed decompression */
/*************************************************/

long Mread(count,address)
long count;
char *address;
{
if(count>remain)
 count=remain;
if(count>0)
 {
 movem(Mptr,address,count);
 remain-=count;
 Mptr+=count;
 }
return(count);
}

/*************************************************/
/* Convert the decompressed raw screen data to   */
/* the ST's device-specific interleaved format.  */
/*						 */
/* Format:					 */
/* toraster(mfdb,row,plane,decombuf,RAMptr)	 */
/*						 */
/* Where:					 */
/* mfdb  = standard GEM MFDB for bit block	 */
/* row   = row to write				 */
/* plane = plane to write			 */
/* decombuf = form data buffer			 */
/* RAMptr= pointer to form buffer		 */
/*						 */
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

/**********************************************************/
/*  Get a DEGAS picture (normal or compressed)		  */
/*							  */
/*  get_pic(whand,picrez,iobuf,picbuf)			  */
/*							  */
/*  where:						  */
/*  whand  = WORD handle of file opened for input	  */
/*	     resolution & palette already read		  */
/*  picrez = resolution	WORD from file			  */
/*  iobuf  = pointer to scratch buffer 32000 bytes long	  */
/*  picbuf = pointer to picture data buffer (32000 bytes) */
/*							  */
/*  Returns:						  */
/*  -1 = error						  */
/*  1  = success					  */
/*							  */
/*  Example:						  */
/*  							  */
/*  int fhand,rezflag,palette[16];			  */
/*  static char iobuf[32000],picbuf[32000];		  */
/*  							  */
/*  fhand=Fopen(filename,0);				  */
/*  Fread(fhand,2L,&rezflag);				  */
/*  Fread(fhand,32L,palette);				  */
/*  get_pic(fhand,rezflag,iobuf,picbuf);		  */
/*							  */
/*  (picbuf now has picture data, and the animation	  */
/*  variables are stored in the variables anileft[],	  */
/*  aniright[], anidir[] and anispd[] (if used).  In	  */
/*  addition, the file has been automatically closed.)	  */
/*							  */
/**********************************************************/

get_pic(whand,picrez,iobuf,picbuf)
int whand,picrez;
long iobuf,picbuf;
{
register int ix,jx;

remain=Fread(whand,32000L,iobuf);
Mptr=iobuf;
Fclose(whand);
if(picrez==0 || picrez==1 || picrez==2)
 Mread(32000L,picbuf);
else
if(picrez==0x8000 || picrez==0x8001 || picrez==0x8002)
 {
 if(Decomp(picbuf,picrez & 3)<0)
  return(-1);		/* Bad decompress! */
 }
else
 return(-1);		/* Bad resolution flag */

for(ix=0; ix<4; ++ix)
 anidir[ix]=1;		/* shut down animation */

Mread(8L,anileft);
Mread(8L,aniright);
Mread(8L,anidir);
Mread(8L,anispd);

for(ix=0; ix<4; ++ix)
 {
 if((anileft[ix]<0) || (anileft[ix]>15) ||
    (aniright[ix]<0) || (aniright[ix]>15) ||
    (anidir[ix]<0) || (anidir[ix]>2) ||
    (anispd[ix]<0) || (anispd[ix]>128))
  {
  for(jx=0; jx<4; ++jx)
   {
   anileft[jx]=0;
   aniright[jx]=0;
   anidir[jx]=1;
   anispd[jx]=0;
   }
  break;
  }
 }
return(1);
}

/***************************/
/* Main decompression rtn  */
/***************************/

Decomp(screen,rez)
long screen;
int rez;
{
register int row,plane;
static int plct[3]={4,2,1};
static int rwd[3]={320,640,640};
static int rht[3]={200,200,400};
static int rbp[3]={20,40,40};
static int tmpmfdb[10];

tmpmfdb[0]=(int)(screen >> 16);
tmpmfdb[1]=(int)(screen & 0x0000ffffL);
tmpmfdb[2]=rwd[rez];
tmpmfdb[3]=rht[rez];
tmpmfdb[4]=rbp[rez];
tmpmfdb[6]=plct[rez];

bmhd.w=tmpmfdb[2];
for(row=0; row<tmpmfdb[3]; ++row)
 {
 for(plane=0; plane<tmpmfdb[6]; ++plane)
  {
  if(decom2(tmpmfdb,row,plane,screen)<0)
   return(-1);			/* Error! */
  }
 }
return(1);			/* All's well that ends well */
}

/***************************/
/* Decompression processor */
/***************************/

decom2(mfdb,row,plane,RAMptr)
int mfdb[10];
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
 if(Mread(1L,&comp_flg)<1)
  return(-1);
 if(comp_flg>=0)
  {
  comp_flg++;
  dccount-=comp_flg;
  if(Mread((long)comp_flg,&decombuf[dcptr])<(long)comp_flg)
   return(-1);
  dcptr+=comp_flg;
  }
 else
 if(comp_flg != -128)
  {
  comp_flg= -comp_flg+1;
  dccount-=comp_flg;
  if(Mread(1L,&comp_byte)<0)
   return(-1);
  for(ix=0; ix<comp_flg; ++ix)
   decombuf[dcptr++]=comp_byte;
  }
 }
toraster(mfdb,row,plane,decombuf,RAMptr);
return(1);
}
