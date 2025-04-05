/***************************************/
/* General-Purpose Ray-Tracing Program */
/*           by Tom Hudson             */
/*   Copyright 1987 Antic Publishing   */
/*   START, The ST Quarterly #4        */
/*   Markt & Technik Happy-Computer    */
/***************************************/

#include <osbind.h>

/* Set maximum object array size */

#define MAXOBS 20

/* GEM binding stuff    */

int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];

/* My working variables */

int gr_1,gr_2,gr_3,gr_4;
int handle,l_intin[11],l_out[57];
long oldsphys,inch;
int oldpal[16],oldrez,clip[4];
int dumrez,mypal[16],genresult;
int lastobj,boucnt;
int parmhand,fresult,fbutton;
char defpath[64],workpath[80],filename[20],filepath[80];

static float rayx,rayy,rayz,xi,yi,zi,px,py,pz,midx,midy,midz,bigstep;
static int tfx,tfy,tfz,grid;

/* Object work arrays           */

static int sizes[MAXOBS],xs[MAXOBS],ys[MAXOBS],zs[MAXOBS];
static float rsqr[MAXOBS];
static float minx[MAXOBS],miny[MAXOBS],minz[MAXOBS];
static float maxx[MAXOBS],maxy[MAXOBS],maxz[MAXOBS];

/* Wall/floor bitmap buffers    */

static char leftbuf[32000],rightbuf[32000],frontbuf[32000],backbuf[32000];
static char botbuf[51200];

static int reflects,infinity,numobs,lumdrop[16][10],pcount,ceiling[2];
static int viewXYZ[3];

/* Various filenames            */

static char lfile[30],rfile[30],bfile[30],ffile[30],outfile[30];
static char workstr[80];

/* Form_alert strings           */

static char cantopen[] =
"[1][ | Can't open that file! | ][SORRY]";

main()
{
register int ix,jx,kx,lx;

appl_init();

handle=graf_handle(&gr_1,&gr_2,&gr_3,&gr_4);

/* Get disk information         */

defpath[0] = Dgetdrv() + 'A';
defpath[1] = ':';
Dgetpath(&defpath[2], 0);
strcpy(workpath,defpath);
strcat(workpath,"\\");

/* open workstation */

for(ix=0; ix<10; ix++)
 l_intin[ix] = 1;
l_intin[10] = 2;
v_opnvwk(l_intin, &handle, l_out);

/* Get old display information  */

for(ix=0; ix<16; ix++)
 oldpal[ix] = Setcolor(ix,-1);
oldsphys=Physbase();
oldrez=Getrez();

/* Init my plot routine         */

pinit(oldsphys);

/* Get the parameter file       */

file_try:
strcat(workpath,"*.CTL");
filename[0]=0;

fresult=fsel_input(workpath,filename,&fbutton);

trunname(workpath);
if(fresult>0 && fbutton==1)
 {
 strcpy(filepath,workpath);
 strcat(filepath,filename);

 parmhand=Fopen(filepath,0);
 if(parmhand >= 0)
  {

/* Get max reflect count        */

  if(getparm()<0)
   goto bail_2;
  reflects=ascint(workstr);
  if(reflects<1 || reflects>10)
   {
   sprint("Bad MAX REFLECT value!");
   goto bail_out;
   }

/* Get color of infinity        */

  if(getparm()<0)
   goto bail_2;
  infinity=ascint(workstr);
  if(infinity<0 || infinity>15)
   {
   sprint("Bad > MAX value!");
   goto bail_out;
   }

/* Get luminance drop table     */

  for(ix=0; ix<16; ++ix)
   {
   if(getparm()<0)
    goto bail_2;
   if(iaparse(workstr,lumdrop[ix],20,&pcount)<0 || pcount!=reflects)
    {
    baddim();
    goto bail_out;
    }
   for(jx=0; jx<reflects; ++jx)
    {
    if(lumdrop[ix][jx]<0 || lumdrop[ix][jx]>15)
     {
     baddim();
     goto bail_out;
     }
    }
   }

/* Get ceiling colors           */

  if(getparm()<0)
   goto bail_2;
  if(iaparse(workstr,ceiling,2,&pcount)<0 || pcount!=2)
   {
   badceil();
   goto bail_out;
   }
  if(ceiling[0]<0 || ceiling[0]>15 || ceiling[1]<0 || ceiling[1]>15)
   {
   badceil();
   goto bail_out;
   }
  }
 else
  {
  form_alert(1,cantopen);
  goto file_try;
  }
 }
else
 goto bail_out;

v_hide_c(handle);

/* Grab frame data from parameter file! */
/* This is the main program loop, which */
/* Generates all the requested frames.  */

gen_loop:

/* Set initial big-step trace increment */

bigstep=10.0;

/* Get XYZ position of observer */

if(getparm()<0)
 goto bail_2;
if(iaparse(workstr,viewXYZ,3,&pcount)<0 || pcount!=3)
 {
 badXYZ();
 goto bail_out;
 }
if(viewXYZ[2]>=0)
 {
 badXYZ();
 goto bail_out;
 }

/* Get number of objects        */

if(getparm()<0)
 goto bail_2;
numobs=ascint(workstr);
if(numobs<0 || numobs>20)
 {
 sprint("Bad object count value!");
 goto bail_out;
 }

/* Get sizes of the objects     */

if(getparm()<0)
 goto bail_2;
if(numobs)
 {
 if(iaparse(workstr,sizes,20,&pcount)<0 || pcount!=numobs)
  {
  badsize();
  goto bail_out;
  }

 for(ix=0; ix<pcount; ++ix)
  {
  if(sizes[ix]<1 || sizes[ix]>99)               /* Verify sphere sizes     */
   {
   badsize();
   goto bail_out;
   }
  rsqr[ix]=(float)(sizes[ix]*sizes[ix]);        /* Get Radius Squared!     */
  if(sizes[ix]<30)                              /* Find biggest step value */
   bigstep=(float)sizes[ix]/3.0;
  }
 }

/* Get X coordinates of the objects */

if(getparm()<0)
 goto bail_2;
if(numobs)
 {
 if(iaparse(workstr,xs,20,&pcount)<0 || pcount!=numobs)
  {
  badloc();
  goto bail_out;
  }
 for(ix=0; ix<numobs; ++ix)
  {
  minx[ix]=(float)(xs[ix]-sizes[ix]);
  maxx[ix]=(float)(xs[ix]+sizes[ix]);
  if(minx[ix]<1 || maxx[ix]>318)
   {
   badloc();
   goto bail_out;
   }
  }
 }

/* Get Y coordinates of the objects */

if(getparm()<0)
 goto bail_2;
if(numobs)
 {
 if(iaparse(workstr,ys,20,&pcount)<0 || pcount!=numobs)
  {
  badloc();
  goto bail_out;
  }
 for(ix=0; ix<numobs; ++ix)
  {
  miny[ix]=(float)(ys[ix]-sizes[ix]);
  maxy[ix]=(float)(ys[ix]+sizes[ix]);
  if(miny[ix]<1 || maxy[ix]>198)
   {
   badloc();
   goto bail_out;
   }
  }
 }

/* Get Z coordinates of the objects */

if(getparm()<0)
 goto bail_2;
if(numobs)
 {
 if(iaparse(workstr,zs,20,&pcount)<0 || pcount!=numobs)
  {
  badloc();
  goto bail_out;
  }
 for(ix=0; ix<numobs; ++ix)
  {
  minz[ix]=(float)(zs[ix]-sizes[ix]);
  maxz[ix]=(float)(zs[ix]+sizes[ix]);
  if(minz[ix]<1 || maxz[ix]>318)
   {
   badloc();
   goto bail_out;
   }
  }
 }

/* Get left wall bitmap filename        */

if(getparm()<0)
 goto bail_2;
strcpy(lfile,workstr);

/* Get right wall bitmap filename       */

if(getparm()<0)
 goto bail_out;
strcpy(rfile,workstr);

/* Get back wall bitmap filename        */

if(getparm()<0)
 goto bail_2;
strcpy(bfile,workstr);

/* Get front wall bitmap filename       */

if(getparm()<0)
 goto bail_2;
strcpy(ffile,workstr);

/* Get output bitmap filename           */

if(getparm()<0)
 goto bail_2;
strcpy(outfile,workstr);

/* Load the wall bitmaps!               */

if(loadmap(leftbuf,lfile)<0)
 goto bail_2;
if(loadmap(rightbuf,rfile)<0)
 goto bail_2;
if(loadmap(backbuf,bfile)<0)
 goto bail_2;
if(loadmap(frontbuf,ffile)<0)
 goto bail_2;

/* Switch to raytrace colors!           */

Setpallete(mypal);

/* Plot sphere shadows                  */

Setscreen(oldsphys,oldsphys,0); /* Clear screen */

clr_RAM(botbuf,51200L);         /* Clear floor  */

clip[0]=clip[1]=0;              /* Set clip     */
clip[2]=320;
clip[3]=200;
vs_clip(handle,1,clip);

/* Now plot shadows in 2 passes (need 320X320 image) */

for(jx=200; jx>=0; jx-=200)
 {
 vswr_mode(handle,1);
 vsf_color(handle,2);
 for(ix=0; ix<numobs; ++ix)
  {
  v_ellpie(handle,xs[ix],zs[ix]-jx,
           sizes[ix],sizes[ix],0,3600);
  }

/* Move shadows to appropriate location */
/* on the floor buffer bitmap!          */

 if(jx==200)
  {
  movedat(oldsphys,botbuf+32000L,19200L);
  clr_RAM(oldsphys,32000L);
  }
 else
  movedat(oldsphys,botbuf,32000L);
 }

/* Clear work screen again              */

Setscreen(oldsphys,oldsphys,0);

/* Now make checkered floor pattern */

vsf_color(handle,3);
for(kx=0; kx<4; ++kx)
 {
 for(lx=0; lx<8; ++lx)
  {
  if((kx+lx) & 1)
   {
   clip[0]=lx*40;
   clip[1]=kx*50;
   clip[2]=lx*40+39;
   clip[3]=kx*50+49;
   vr_recfl(handle,clip);
   }
  }
 }

/* Now overlap the checkers onto the shadows */

or_sc(oldsphys,botbuf,32000L);
or_sc(oldsphys,botbuf+32000L,19200L);

/* Clear screen for new ray tracing!    */

Setscreen(oldsphys,oldsphys,0);

/* Generate the frame!                  */

genresult=genframe();
if(genresult == -2)
 goto quit_it;
else
if(genresult>0)
 {
 if(saveframe()<0)
  goto bail_2;
 }
goto gen_loop;

/* close workstation */

bail_out:
sprint(workstr);

bail_2:
sprint("Press any key");
Crawcin();

quit_it:
Fclose(parmhand);

/* Return to old resolution & colors */

Setscreen(oldsphys,oldsphys,oldrez);
Setpallete(oldpal);

v_hide_c(handle);
v_show_c(handle,0);
v_clsvwk(handle);

appl_exit();
}

/* end main */

/****************************************************/
/* This routine simply calls the ray tracer routine */
/* for each pixel on the screen.  trace() does all  */
/* the hard work.                                   */
/*                                                  */
/* If the UNDO key is pressed, the program quits.   */
/* If the HELP key is pressed, the frame being      */
/* drawn aborts and the program goes to the next    */
/* frame (if any).                                  */
/****************************************************/

genframe()
{
register int ix,iy;

for(ix=0; ix<320; ++ix)
 {
 for(iy=199; iy>=0; --iy)
  {
  boucnt=0;
  myplot(ix,199-iy,lumdrop[trace(ix,iy)][boucnt]);
  }
 if(Cconis())
  {
  inch=Crawcin();
  if(inch==0x00610000)  /* Undo completely */
   return(-2);
  else
  if(inch==0x00620000)  /* Skip this frame */
   return(-1);
  }
 }
return(1);
}

/********************************************************/
/* The nitty-gritty routine!  This baby figures out the */
/* initial ray's direction based on the viewpoint and   */
/* screen pixel.  It then follows the ray until it hits */
/* a wall or bounces the maximum number of times.       */
/********************************************************/

trace(x,y)
int x,y;
{
register int ix;

/* Calculate ray vector increment values */

xi=(float)(x-viewXYZ[0])/(-viewXYZ[2]);
yi=(float)(y-viewXYZ[1])/(-viewXYZ[2]);
zi=1.0;

/* Go to big step value */

bigincs();

/* Get ray's starting location in float variables */

rayx=(float)x;
rayy=(float)y;
rayz=0.01;

/* Didn't hit anything yet!  Reset LASTOBJ.       */

lastobj=99;

/* Follow ray around room, call inbox() if we go  */
/* inside a sphere's bounding box!                */
/*                                                */
/* This routine returns the color of the pixel    */
/* hit by the ray.                                */

while(rayx>0.0 && rayx<320.0 && rayy>0.0 && rayy<200.0 &&
      rayz>0.0 && rayz<320.0)
 {
 px=rayx;       /* Save previous ray location   */
 py=rayy;
 pz=rayz;

 rayx+=xi;      /* Move the ray                 */
 rayy+=yi;
 rayz+=zi;

/* Check to see if we're in a bounding box */

 for(ix=0; ix<numobs; ++ix)
  {
  if(ix!=lastobj &&
     rayx>=minx[ix] && rayx<=maxx[ix] && 
     rayy>=miny[ix] && rayy<=maxy[ix] &&
     rayz>=minz[ix] && rayz<=maxz[ix])

/* Ray is inside a bounding box! */

   {
   if(inbox()<0)
    return(infinity);
   break;
   }
  }
 }

/* We're now outside of the room!                                   */
/* Binary search 8 times to get intersection w/wall, floor, ceiling */

for(ix=0; ix<8; ++ix)
 {
 midx=(px+rayx)/2.0;
 midy=(py+rayy)/2.0;
 midz=(pz+rayz)/2.0;
 if(midx>320.0 || midx<0.0 || midy>200.0 || midy<0.0 ||
    midz>320.0 || midz<0.0)
  {
  rayx=midx;
  rayy=midy;
  rayz=midz;
  }
 else
  {
  px=midx;
  py=midy;
  pz=midz;
  }
 }

/* Now we have collision point, turn into integer */

tfx=(int)(midx+0.5);
tfy=199-(int)(midy+0.5);
tfz=(int)(midz+0.5);

/* Now adjust value so it's within bitmap size limits */

if(tfx<0)
 tfx=0;
else
if(tfx>319)
 tfx=319;

if(tfy<0)
 tfy=0;
else
if(tfy>199)
 tfy=199;

if(tfz<0)
 tfz=0;
else
if(tfz>319)
 tfz=319;

/* tfx, tfy & tfz now contain the bitmap exit position */

if(tfx==319)                            /* on right wall */
 return(get0(rightbuf,319-tfz,tfy));

if(tfx==0)                              /* on left wall */
 return(get0(leftbuf,tfz,tfy));

if(tfy==199)                            /* on floor     */
 return(get0(botbuf,tfx,tfz));

if(tfy==0)                              /* on ceiling   */
 {
 grid=(tfx/40+tfz/40) & 1;
 if(grid)
  return(ceiling[0]);
 return(ceiling[1]);
 }

if(tfz==0)                              /* on front wall */
 return(get0(frontbuf,319-tfx,tfy));

return(get0(backbuf,tfx,tfy));          /* on back wall */
}

/************************************************************************/
/* Ray is inside one or more bounding boxes.  Test for hit on sphere.   */
/*                                                                      */
/* If a sphere is hit, bounce the ray in the appropriate direction      */
/* and continue tracing.  If hay has bounced maximum number of times,   */
/* return -1 to indicate the infinity color should be used.             */
/************************************************************************/

inbox()
{
register int ix,jx;
static int inbox[MAXOBS],insphere[MAXOBS],boxtot,sphtot,sphnum;
static float testx,testy,testz,nx,ny,nz,vpx,vpy,vpz,dot;

/* Reduce trace speed down to 1 unit per increment */
/* (Avoids missed sphere edges)                    */

xi /= bigstep;
yi /= bigstep;
zi /= bigstep;

/* Stay in this loop until you are no longer in a  */
/* bounding box!                                   */

boxloop:
sphtot=boxtot=0;
for(ix=0; ix<numobs; ++ix)
 {
 insphere[ix]=inbox[ix]=0;
 if(rayx>=minx[ix] && rayx<=maxx[ix] &&         /* See if in box        */
    rayy>=miny[ix] && rayy<=maxy[ix] &&
    rayz>=minz[ix] && rayz<=maxz[ix])
  {
  inbox[ix]=1;
  boxtot++;
  if(inside(rayx,rayy,rayz,ix))                 /* See if in sphere     */
   {
   insphere[ix]=1;
   sphtot++;
   sphnum=ix;
   }
  }
 }

/* Return if not in a bounding box anymore */

if(boxtot==0)
 {
 bigincs();             /* return to fast tracing       */
 return(1);
 }

/* If inside sphere(s), locate closest surface & bounce it */

if(sphtot>0)
 {

/* Limit bounces, then force color if at limit */

 if(boucnt>=(reflects-1))
  return(-1);

/* Do a binary search for the sphere surface */

 for(jx=0; jx<8; ++jx)
  {
  testx=(px+rayx)/2.0;
  testy=(py+rayy)/2.0;
  testz=(pz+rayz)/2.0;

/* Reset sphere hit tally                   */

  sphtot=0;

  for(ix=0; ix<numobs; ++ix)
   {
   if(inbox[ix])
    {
    if(inside(testx,testy,testz,ix))
     {
     insphere[ix]=1;
     sphtot++;
     sphnum=ix;
     }
    }
   }

/* Adjust binary search range   */

  if(sphtot==0)
   {
   px=testx;
   py=testy;
   pz=testz;
   }
  else
   {
   rayx=testx;
   rayy=testy;
   rayz=testz;
   }
  }

/* Now we have the number of the intersected sphere and point on surface! */
/* Calculate reflected vector of new ray and continue the quest           */

 lastobj=sphnum;
 boucnt++;

 nx=rayx-(float)xs[sphnum];
 ny=rayy-(float)ys[sphnum];
 nz=rayz-(float)zs[sphnum];

 dot=nx*xi+ny*yi+nz*zi;

 if(dot<0)
  dot= -dot;

 vpx=xi/dot;
 vpy=yi/dot;
 vpz=zi/dot;

 xi=vpx+2*nx;
 yi=vpy+2*ny;
 zi=vpz+2*nz;

/* Now we have the new ray vector!    */
/* Go back to big step value & return */

 bigincs(); 
 }
else    /* Not inside sphere, just keep tracing! */
 {
 rayx+=xi;
 rayy+=yi;
 rayz+=zi;
 goto boxloop;
 }

return(1);
}

/***********************************/
/* see if ray is inside the sphere */
/*                                 */
/* inside(x,y,z,index)             */
/* x,y,z are float coordinates     */
/* index is WORD index of sphere   */
/*                                 */
/* Returns: 0=not inside, 1=inside */
/***********************************/

inside(xval,yval,zval,index)
float xval,yval,zval;
int index;
{
register float dltx,dlty,dltz;

dltx=xval-(float)xs[index];
dlty=yval-(float)ys[index];
dltz=zval-(float)zs[index];
if(((dltx*dltx+dlty*dlty+dltz*dltz)-rsqr[index])<0.0)
 return(1);
return(0);
}

/************************************************/
/* Return to an increment of 10 units per step. */
/* (Scales largest increment value to 10 units) */
/************************************************/

bigincs()
{
register float axi,ayi,azi,mfac;
static float axs,ays,azs;

axi=xi;
ayi=yi;
azi=zi;
axs=ays=azs=1;

if(axi<0)
 {
 axi= -axi;
 axs= -1;
 }
if(ayi<0)
 {
 ayi= -ayi;
 ays= -1;
 }
if(azi<0)
 {
 azi= -azi;
 azs= -1;
 }

if(axi>=ayi && axi>=azi)
 mfac=bigstep/axi;
else
if(ayi>=axi && ayi>=azi)
 mfac=bigstep/ayi;
else
 mfac=bigstep/azi;

xi=axi*mfac*axs;
yi=ayi*mfac*ays;
zi=azi*mfac*azs;
}

/************************************************/
/* Load a wall's bitmap buffer                  */
/*                                              */
/* loadmap(buffer,file)                         */
/* buffer is pointer to a 32000-byte buffer     */
/* file is pointer to filename string (w/path)  */
/*                                              */
/* Returns 1=OK  -1=ERROR                       */
/************************************************/

loadmap(buffer,file)
char buffer[],file[];
{
int fhand,bcount;

bcount=0;
fhand=Fopen(file,0);
if(fhand>=0)
 {
 Fread(fhand,2L,&dumrez);
 Fread(fhand,32L,mypal);
 bcount=Fread(fhand,32000L,buffer);
 Fclose(fhand);
 }
if(bcount<32000)
 {
 sprint("Can't load file:");
 sprint(file);
 return(-1);
 }
return(1);
}

/*************************************/
/* Save a generated ray-traced frame */
/* to the file indicated by outfile. */
/*                                   */
/* Returns: 1=OK  -1=ERROR           */
/*************************************/

saveframe()
{
int fhand,bcount;
static int newrez=0;

bcount=0;
fhand=Fcreate(outfile,0);
if(fhand>=0)
 {
 Fwrite(fhand,2L,&newrez);
 Fwrite(fhand,32L,mypal);
 bcount=Fwrite(fhand,32000L,oldsphys);
 Fclose(fhand);
 }
if(bcount<32000)
 {
 sprint("Can't save frame!");
 return(-1);
 }
return(1);
}

/********************************************************/
/* Parse an ascii numeric string into an INT array      */
/*                                                      */
/* format:                                              */
/* iaparse(instring,outarray,olimit,count)              */
/*                                                      */
/* instring:  string of numbers separated by commas     */
/* outarray:  array to receive parsed values            */
/* olimit:    max size of output array                  */
/* count:     pointer to WORD to receive value count    */
/*                                                      */
/* returns -1 (error) or 1 (no error)                   */
/********************************************************/

iaparse(istring,oarray,olimit,ocount)
char istring[];
int oarray[],olimit,*ocount;
{
register int ix,ox,flag;
long value;
int posneg;
static char pstr;

if(istring[0]==0)
 return(-1);

ox=flag=0;
pstr=0;
value=0L;
posneg=1;
for(ix=0; ix<strlen(istring); ++ix)
 {
 switch(istring[ix])
  {
  case ' ':
   goto next_ix;
   break;
  case ',':
   if(pstr==',' || pstr==0 || ox==olimit)
    return(-1);
   oarray[ox++]=(int)value*posneg;
   posneg=1;
   value=flag=0;
   break;
  case '-':
   if(pstr!=0 && pstr!=',')
    return(-1);
   posneg= -1;
   break;
  case '0':
  case '1':
  case '2':
  case '3':
  case '4':
  case '5':
  case '6':
  case '7':
  case '8':
  case '9':
   flag=1;
   value=value*10L+(long)(istring[ix]-'0');
   if(value>32767L || value<0L)
    return(-1);
   break;
  default:
   return(-1);
   break;
  }
  
 next_ix:
 pstr=istring[ix];
 }

if(flag)
 {
 if(ox>=olimit)
  return(-1);
 oarray[ox++]=(int)value*posneg;
 }

if(ox==0)
 return(-1);

*ocount=ox;
return(1);
}

/*************************************************/
/* Get a parameter line from the parameter file. */
/* Ignores comment lines (starting with ;)       */
/* Returns: 1=OK  -1=ERROR (EOF, etc.)           */
/*************************************************/

getparm()
{
int getstat;

do
 {
 getstat=getaline(parmhand,workstr,80);
 if(getstat == -1)
  {
  sprint("Line too long:");
  workstr[50]=0;
  sprint(workstr);
  return(-1);
  }
 else
 if(getstat== -2)
  {
  sprint("End of file reached");
  return(-1);
  }
 }
 while(workstr[0]==';');

return(1);
}

/****************************************/
/* Get a LF-terminated line from a file */
/* Puts line in target string as a null */
/* terminated string.                   */
/*                                      */
/* getaline(fhand,string,size)          */
/* fhand = WORD file handle             */
/* string = pointer to target string    */
/* size = WORD length of string         */
/*                                      */
/* Returns: 1=OK -1=LONG STRING -2=EOF  */
/****************************************/

getaline(fhand,string,linesize)
int fhand,linesize;
char string[];
{
register int ix;
char inch;

ix=0;
do
 {
 if(Fread(fhand,1L,&inch)!=1L)
  return(-2);
 switch(inch)
  {
  case 10:
  case 13:
   break;
  default:
   if(ix>=linesize)
    return(-1);
   string[ix++]=inch;
   break;
  }
 }
 while(inch!=10);

string[ix]=0;
return(1);
}

/*****************/
/* Copy a string */
/*****************/

strcpy(to,from)
char *from;
char *to;
{
while (*to++ = *from++);
}

/**********************************************/
/* Concatenate string onto the end of another */
/**********************************************/

strcat(to, from)
char *to,*from;
{
while (*to) ++to;
while (*to++ = *from++);
}

/***************************************/
/* Strip off wildcard from path string */
/***************************************/

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

/*********************************/
/* Return the length of a string */
/*********************************/

strlen(string)
char *string;
{
register int  ix;

for (ix=0; *string++; ++ix);
return ix;
}

/****************************************/
/* Convert an ascii value to an integer */
/*                                      */
/* Returns a WORD value containing the  */
/* positive integer value of a string.  */
/* Returns -1 if string is non-numeric  */
/* or > 32767.                          */
/****************************************/

ascint(string)
char string[];
{
register int ix;
long temp;

temp=0L;
for(ix=0; ix<5; ++ix)
 {
 if(string[ix]==0)
  break;
 if(string[ix]<'0' || string[0]>'9')
  return(-1);
 temp=temp*10L+(long)(string[ix]-'0');
 }
if(temp>32767)
 return(-1);
return((int)temp);
}

/******************************************/
/* Print null-terminated string to screen */
/******************************************/

sprint(string)
char string[];
{
Cconws(string);
Cconout(13);
Cconout(10);
}

/******************************************/
/* Miscellaneous error message prints     */
/******************************************/

baddim()
{
sprint("Bad dimming index:");
}

badceil()
{
sprint("Bad ceiling values:");
}

badXYZ()
{
sprint("Bad viewpoint values:");
}

badsize()
{
sprint("Bad size values:");
}

badloc()
{
sprint("Bad location values:");
}
