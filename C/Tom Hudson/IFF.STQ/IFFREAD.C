/*:*************************************************************************/
/*                                                                         */
/*  IFF file read.  Written by Tom Hudson      Rev. 7/15/86                */
/*                                                                         */
/*  START magazine, Fall 1986.      Copyright 1986 by Antic Publishing     */
/*                                                                         */
/*  To promote the IFF standard, this program is freeware. NOT to be sold. */
/*                                                                         */
/***************************************************************************/

#include <osbind.h>;

/* IFF reader global variables */

extern int xparent;             /* transparent color index      */
extern int Syspal[];            /* System format palette array  */
extern int Gempal[][3];         /* GEM format palette stuff     */

/* GEM binding global variables */

int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];

main()
{
register int ix;
int dummy,l_intin[11],l_out[57];
int handle,fhand,rez,fs_ireturn,fs_iexbutton;
int formtype;
int scrnmfdb[10],workmfdb[10],oldpal[16],blit[8];
char pathin[80],filename[20],workname[80];
long slog,sphys,formsize,formaddr=0;

/* Miscellaneous form_alert strings */

static char whichfm[] =
"[3][ |     Read block into:     | ][Screen| Form ]";
static char noRAM[] =
"[1][ | Insufficient RAM for block! | ][SORRY]";
static char badIFF[] =
"[1][ |   Bad block file format!   | ][SORRY]";
static char cantopen[] =
"[1][ |   Can't open file!   | ][SORRY]";

/* Initialize the GEM application */

appl_init();

/* open workstation */

for (ix=0; ix<10; ix++)
  l_intin[ix] = 1;
l_intin[10] = 2;
v_opnvwk(l_intin, &handle, l_out);

/* capture old screen location */

slog = Logbase();
sphys = Physbase();
rez = Getrez();

/* capture old screen color palette */

for (ix=0; ix<16; ix++)
 oldpal[ix] = Setcolor(ix,-1);

/* Build screen's MFDB */

scrnmfdb[0]=(int)(sphys >> 16);
scrnmfdb[1]=(int)(sphys & 0x0000ffffL);
if(rez==0)
 {
 scrnmfdb[2]=320;
 scrnmfdb[3]=200;
 scrnmfdb[4]=20;        /* 320 / 16     */
 scrnmfdb[6]=4;         /* 4 bit planes */
 }
else
if(rez==1)
 {
 scrnmfdb[2]=640;
 scrnmfdb[3]=200;
 scrnmfdb[4]=40;        /* 640 / 16     */
 scrnmfdb[6]=2;         /* 2 bit planes */
 }
else
 {
 scrnmfdb[2]=640;
 scrnmfdb[3]=400;
 scrnmfdb[4]=40;        /* 640 / 16     */
 scrnmfdb[6]=1;         /* 1 bit plane  */
 }
scrnmfdb[5]=scrnmfdb[7]=scrnmfdb[8]=scrnmfdb[9]=0;

/* Get the block file to load */

pathin[0]=Dgetdrv()+'A';
pathin[1]=':';
Dgetpath(&pathin[2],0);
strcat(pathin,"\\*.BL*");
filename[0]=0;
fs_ireturn=fsel_input(pathin,filename,&fs_iexbutton);
if(fs_iexbutton==1 && fs_ireturn>0 && filename[0]!=0)
 {

/* Ask user where to load it (1=screen, 2=allocated block) */

 formtype=form_alert(1,whichfm);

/* Build the working filename from pathname & filename parts */

 strcop(workname,pathin);
 trunname(workname);
 strcat(workname,filename);

/* Change cursor to bee and try to open the file */

 graf_mouse(2,&dummy);
 fhand=Fopen(workname,0);

/* Do the file read if the file was opened successfully */

 if(fhand>=0)
  {

/* Phase 1 IFF read */

  if(iff_rd1(fhand,workmfdb)<0)
   goto bad_IFF;

/* Don't allow a form larger than the ST screen!                  */

  if(workmfdb[2]>scrnmfdb[2])
   {
   workmfdb[2]=scrnmfdb[2];
   workmfdb[4]=scrnmfdb[4];
   }
  if(workmfdb[3]>scrnmfdb[3])
   workmfdb[3]=scrnmfdb[3];

/* Make sure it gets converted to the proper number of bitplanes! */

  workmfdb[6]=scrnmfdb[6];

/* Complete setup of working MFDB */

  if(formtype==1)
   {
   workmfdb[0]=scrnmfdb[0];
   workmfdb[1]=scrnmfdb[1];
   workmfdb[4]=scrnmfdb[4];
   }
  else
   {
   formsize=(long)(workmfdb[3]*workmfdb[4]*workmfdb[6]*2);
   formaddr=Malloc(formsize);
   if(formaddr==0)
    {
    form_alert(1,noRAM);
    goto br_exit;
    }
   else
    {
    workmfdb[0]=(int)(formaddr >> 16);
    workmfdb[1]=(int)(formaddr & 0x0000ffffL);
    }
   }

/* Read in the rest of the bit block! */

  v_hide_c(handle);
  graf_mouse(0,&dummy);
  if(iff_rd2(fhand,workmfdb)<0)
   {
   v_show_c(handle,0);

   bad_IFF:
   form_alert(1,badIFF);
   }
  else
   {

/* Set colors to those contained in block... */

   Setpallete(Syspal);

/* ...OR use GEM to do it (same result) */

   for(ix=0; ix<16; ++ix)
    vs_color(handle,ix,Gempal[ix]);
   
/* now blit block to screen if it was read into a separate area */

   if(formtype==2)
    {

/* source coordinates */

    blit[0]=blit[1]=0;
    blit[2]=workmfdb[2]-1;
    blit[3]=workmfdb[3]-1;

/* destination coordinates */

    blit[4]=scrnmfdb[2]/2-workmfdb[2]/2;
    blit[5]=scrnmfdb[3]/2-workmfdb[3]/2;
    blit[6]=blit[4]+workmfdb[2]-1;
    blit[7]=blit[5]+workmfdb[3]-1;

/* Blit the bit block to the screen! */

    vro_cpyfm(handle,3,blit,workmfdb,scrnmfdb);
    }
   v_show_c(handle,0);
   }

/* Don't forget to close the file! */

  br_exit:
  Fclose(fhand);
  }
 else
  {
  form_alert(1,cantopen);
  }
 }

/* wait for any key */

evnt_keybd();

/* Free up allocated memory */

if(formaddr != 0L)
 Mfree(formaddr);

/* Close virtual workstation */

v_clsvwk(handle);

/* Restore original palette       */
/* I wish everyone would do this! */

Setpallete(oldpal);

/* And say bye-bye! */

appl_exit();
}

/* Copy a string */

strcop(to,from)
char *from;
char *to;
{
while (*to++ = *from++);
}

/* Concatenate string onto the end of another */

strcat(to, from)
char *to,*from;
{
while (*to) ++to;
while (*to++ = *from++);
}

/* Strip off wildcard from path string */

trunname(string)
char *string;
{
register int ix;

for(ix=strlen(string); ix>=0; --ix)
 {
 if(string[ix] == 92)  /* is it \? */
  break;
 }
string[ix+1]=0;
}

/* Return the length of a string */

strlen(string)
char *string;
{
register int  ix;

for (ix=0; *string++; ++ix);
return ix;
}


