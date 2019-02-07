/*:*************************************************************************/
/*                                                                         */
/*  IFF file write.  Written by Tom Hudson      Rev. 7/15/86               */
/*                                                                         */
/*  START magazine, Fall 1986.      Copyright 1986 by Antic Publishing     */
/*                                                                         */
/*  To promote the IFF standard, this program is freeware. NOT to be sold. */
/*                                                                         */
/***************************************************************************/
#include <osbind.h>;

/* IFF writer global variables */

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
int mousex,mousey,bstate,newx,newy,boxx,boxy,box[10],boxtime;
int scrnmfdb[10],workmfdb[10],oldpal[16],picpal[16],blit[8];
char pathin[80],filename[20],workname[80],*workarea;
long slog,sphys,formaddr=0;

/* File pathnames */

static char bpaths[3][7] =
{
"\\*.BL1","\\*.BL2","\\*.BL3"
};
static char ppaths[3][7] =
{
"\\*.PI1","\\*.PI2","\\*.PI3"
};

/* Miscellaneous form_alert strings */

static char badwrite[] =
"[3][ |    Error writing file!   | ][SORRY]";
static char noRAM[] =
"[1][ | Insufficient RAM for block! | ][SORRY]";
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

/* Set up a temporary work buffer */

formaddr=Malloc(32000L);
if(formaddr==0)
 {
 form_alert(1,noRAM);
 goto bail_out;
 }
workarea=(char *)formaddr;

/* Build screen's MFDB */

scrnmfdb[0]=(int)(sphys >> 16);
scrnmfdb[1]=(int)(sphys & 0x0000ffffL);
if(rez==0)
 {
 scrnmfdb[2]=320;
 scrnmfdb[3]=200;
 scrnmfdb[4]=20;
 scrnmfdb[6]=4;
 }
else
if(rez==1)
 {
 scrnmfdb[2]=640;
 scrnmfdb[3]=200;
 scrnmfdb[4]=40;
 scrnmfdb[6]=2;
 }
else
 {
 scrnmfdb[2]=640;
 scrnmfdb[3]=400;
 scrnmfdb[4]=40;
 scrnmfdb[6]=1;
 }
scrnmfdb[5]=scrnmfdb[7]=scrnmfdb[8]=scrnmfdb[9]=0;

/* Get the DEGAS picture file to load */

file_try:
pathin[0]=Dgetdrv()+'A';
pathin[1]=':';
Dgetpath(&pathin[2],0);
strcat(pathin,ppaths[rez]);
filename[0]=0;
fs_ireturn=fsel_input(pathin,filename,&fs_iexbutton);
if(fs_iexbutton==1 && fs_ireturn>0 && filename[0]!=0)
 {

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
  v_hide_c(handle);
  Fread(fhand,2L,&dummy);
  Fread(fhand,32L,picpal);
  Fread(fhand,32000L,sphys);
  Setpallete(picpal);
  Fclose(fhand);
  v_show_c(handle,0);
  }
 else
  {
  form_alert(1,cantopen);
  goto file_try;
  }
 }
else
 {
 goto bail_out;
 }

/* Cursor back to arrow */

graf_mouse(0,&dummy);

/* wait for mouse button action */

menu_bar(&dummy,0);

button_loop:
bstate=0;
while(bstate==0)
 vq_mouse(handle,&bstate,&boxx,&boxy);
if(bstate==2)
 goto skip_grab;

/* Let user draw a box for block to save */

vswr_mode(handle,3);
vsl_color(handle,1);
boxtime=0;
mousex=boxx;
mousey=boxy;
newx=newy= -1;
while(bstate==1)
 {
 if(mousex!=newx || mousey!=newy)
  {
  if(boxtime>0)         /* Erase old box position */
   {
   v_hide_c(handle);
   v_pline(handle,5,box);
   v_show_c(handle,0);
   }
  boxtime=1;
  box[0]=box[6]=box[8]=boxx;
  box[1]=box[3]=box[9]=boxy;
  box[2]=box[4]=mousex;
  box[5]=box[7]=mousey;
  newx=mousex;
  newy=mousey;
  v_hide_c(handle);
  v_pline(handle,5,box);
  v_show_c(handle,0);
  }
 vq_mouse(handle,&bstate,&mousex,&mousey);
 if(mousex<boxx)
  mousex=boxx;
 if(mousey<boxy)
  mousey=boxy;
 }
v_hide_c(handle);
v_pline(handle,5,box);
v_show_c(handle,0);
vswr_mode(handle,1);

/* Set up bitblt parameters */

blit[0]=boxx;
blit[1]=boxy;
blit[2]=mousex;
blit[3]=mousey;

blit[4]=blit[5]=0;
blit[6]=blit[2]-boxx;
blit[7]=blit[3]-boxy;

/* Set up work buffer's MFDB */

workmfdb[0]=(int)(workarea >> 16);
workmfdb[1]=(int)(workarea & 0x0000ffffL);
workmfdb[2]=blit[6]+1;
workmfdb[3]=blit[7]+1;
workmfdb[4]=(workmfdb[2] + 15) >> 4;
workmfdb[5]=workmfdb[7]=workmfdb[8]=workmfdb[9]=0;
workmfdb[6]=scrnmfdb[6];

/* copy defined box to workarea */

vro_cpyfm(handle,3,blit,scrnmfdb,workmfdb);

/* Time to get block filename */

pathin[0]=Dgetdrv()+'A';
pathin[1]=':';
Dgetpath(&pathin[2],0);
strcat(pathin,bpaths[rez]);
filename[0]=0;
fs_ireturn=fsel_input(pathin,filename,&fs_iexbutton);
if(fs_iexbutton==1 && fs_ireturn>0 && filename[0]!=0)
 {

/* Build the working filename from pathname & filename parts */

 strcop(workname,pathin);
 trunname(workname);
 strcat(workname,filename);

/* Change cursor to bee and try to open the file */

 graf_mouse(2,&dummy);
 fhand=Fcreate(workname,0);
 if(fhand>=0)
  {

/* File's open, now write the IFF block file! */

  if(iff_wrt(fhand,workmfdb,picpal,rez)<0)
   {
   form_alert(1,badwrite);
   }
  Fclose(fhand);
  }
 else
  {
  form_alert(1,cantopen);
  }
 graf_mouse(0,&dummy);
 }
  
/* Free up allocated memory */

skip_grab:
if(formaddr != 0L)
 Mfree(formaddr);

/* Close virtual workstation */

bail_out:
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

