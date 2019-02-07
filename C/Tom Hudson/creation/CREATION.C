/*******************************/
/*         Creation!           */
/* Fractal Landscape Generator */
/*       by Tom Hudson         */
/*                             */
/*  (C) 1988 Antic Publishing  */
/*******************************/

#include <portab.h>
#include <osbind.h>
#include <obdefs.h>
#include <creation.h>

extern float sqrt();

/************************/
/* GEM's working arrays */
/************************/

int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];

/*********************/
/* Working variables */
/*********************/

char mainpath[64],workname[80],justpath[64];
char picpath[64],picfile[13],path3D[64],file3D[13];
char datpath[64],datfile[13];
int dum,handle,l_intin[11],l_out[57];
int gr_1,gr_2,gr_3,gr_4;
int got_rsrc,done=0,mcflg=0,header=0;
int button,kstate,kreturn,breturn;
int oldrez,oldpal[16];
int event,mgbuf[8],mousex,mousey;
int formx,formy,formw,formh,exitix;
int wrand,startx,starty,endx,endy,gridsize;
long menuaddr,progaddr,prog2addr,partaddr,topbuf,perbuf,mapbuf=0L,freeRAM;
long oldsc;

int masks[9] =
{
0,255,127,63,31,15,7,3,1
};

int subfac[9] =
{
0,127,63,31,15,7,3,1,0
};

int palette[16] =
{
0x0000,0x0444,0x0222,0x0007,0x0040,0x0340,0x0450,0x0560,
0x0770,0x0760,0x0741,0x0622,0x0633,0x0644,0x0655,0x0777
};

/*****************************/
/*   Miscellaneous buffers   */
/*****************************/

static int table[257][257],tab2[160][160],ln[4],xbuf[470],*mapdata,*map[470];
static char filename[20],ascnum[6];
static int toppic[16128],perpic[16128];

/*******************************/
/* Map data file header record */
/*******************************/

struct header
 {
 char USGS[144];
 long low_x;
 long low_y;
 long hi_y;
 int num_y;
 int num_x;
 int interval;
 int UTMzone;
 int low_z;
 int hi_z;
 };
struct header hdr;

/*****************************************/
/*   Miscellaneous form_alert strings    */
/*****************************************/

static char bad_rez[]=
"[1][Run in low resolution!][ SORRY ]";
static char no_rsrc[]=
"[1][Can't find resource file!][ SORRY ]";
static char quit_sure[]=
"[1][Are you sure you want to quit?][ OK |Cancel]";
static char about_it[]=
"[1][Creation! by Tom Hudson|(C) 1988 Antic Publishing][ OK ]";
static char bad_file[]=
"[1][Invalid file!][ Sorry ]";
static char cant_create[]=
"[1][Can't create that file!][ Sorry ]";
static char no_ext[]=
"[1][Need .PI1 or .NEO extension!][ Sorry ]";
static char write_err[]=
"[1][Write error on file!][ Sorry ]";
static char cant_open[]=
"[1][Can't open that file!][ Sorry ]";
static char no_RAM[]=
"[1][No RAM available!][ Sorry ]";

/***************************/
/* Dummy file read routine */
/***************************/

long dumread(fhand,length)
int fhand;
long length;
{
char dumbuf[100];
long dumtot,getsize,gotsize;

dumtot=0L;

dum_loop:
if(length<100L)
 getsize=length;
else
 getsize=100L;
gotsize=Fread(fhand,getsize,dumbuf);
if(gotsize<0)
 return(gotsize);
dumtot+=gotsize;
length-=gotsize;
if(gotsize<getsize || length==0L)
 return(dumtot);
goto dum_loop;
}

/*****************************/
/* Main program starts here! */
/*****************************/

main()
{
register int ix;

/* Save old screen info */

for(ix=0; ix<16; ++ix)
 oldpal[ix]=Setcolor(ix,-1);
oldsc=Physbase();

/* Set up drive paths */

mainpath[0]=Dgetdrv()+'A';
mainpath[1]=':';
Dgetpath(&mainpath[2],0);

strcpy(picpath,mainpath);
strcat(picpath,"\\*.PI1");
strcpy(path3D,mainpath);
strcat(path3D,"\\*.3D");
strcpy(datpath,mainpath);
strcat(datpath,"\\*.*");
strcpy(picfile,"");
strcpy(file3D,"");
strcpy(datfile,"");

/* Set up pic buffer pointers */

topbuf=(((long)toppic+511L)/512L)*512L;
perbuf=(((long)perpic+511L)/512L)*512L;

/* Open workstation */

appl_init();

handle=graf_handle(&gr_1,&gr_2,&gr_3,&gr_4);

for(ix=0; ix<10; ++ix)
 l_intin[ix] = 1;
l_intin[10] = 2;
v_opnvwk(l_intin, &handle, l_out);
graf_mouse(0,&dum);

if(Getrez()!=0)
 {
 form_alert(1,bad_rez);
 goto rsrc_bail;
 }

/* Get resource file */

got_rsrc=rsrc_load("creation.rsc");
if(!got_rsrc)
 {
 form_alert(1,no_rsrc);
 goto rsrc_bail;
 }

rsrc_gaddr(0,MENUBAR,&menuaddr);
rsrc_gaddr(0,PROGRESS,&progaddr);
rsrc_gaddr(0,REALPROG,&prog2addr);
rsrc_gaddr(0,MAPPART,&partaddr);

/* Allocate a bunch of RAM for map data */

freeRAM=Malloc(-1L)-8000L;
if(freeRAM<0)
 {
 form_alert(1,no_RAM);
 goto RAM_abort;
 }
mapbuf=Malloc(freeRAM);
mapdata=(int *)mapbuf;

/* Init menu bar items */

menu_ienable(menuaddr,SAVE3D,0);
menu_ienable(menuaddr,SAVETOP,0);
menu_ienable(menuaddr,SAVEPSPC,0);
menu_ienable(menuaddr,TOP,0);
menu_ienable(menuaddr,PERSPEC,0);
menu_ienable(menuaddr,USEDATA,0);

/* Draw menu bar */

menu_bar(menuaddr,1);

/* Now wait for the GEM messages! */

while(!done)
 {
 my_update(2);
 event=evnt_multi(0x0010,2,1,1, 0,0,0,0,0, 0,0,0,0,0, mgbuf, 0,0,
		  &mousex,&mousey,&button,&kstate,&kreturn,&breturn);
 my_update(3);

/* Message event */

 if(event & 0x0010)
  {
  if(mgbuf[0]==10)
   {
   do_menu();
   menu_tnormal(menuaddr,mgbuf[3],1);
   }
  }
 }
 
/* All done! */

menu_bar(menuaddr,0);
Mfree(mapbuf);

RAM_abort:
rsrc_free();

my_update(2);

rsrc_bail:
v_clsvwk(handle);
appl_exit();
}

/*****************************************/
/* Various string manipulation functions */
/*****************************************/

strcat(to,from)
char *to,*from;
{
while (*to) ++to;
while (*to++ = *from++);
}

strcpy(to,from)
char *to,*from;
{
while (*to++ = *from++);
}

strlen(string)
char *string;
{
register int ix;

for (ix=0; *string++; ++ix);
return ix;
}

/***************************/
/* Chop wildcard from path */
/***************************/

trunname(string)
char *string;
{
register int ix;

for(ix=strlen(string); ix>=0; --ix)
 {
 if(string[ix] == 92)  /* is it /? */
  break;
 }
string[ix+1]=0;
}

/****************************/
/* Get a filespec from user */
/****************************/

getfile(path,file)
char *path,*file;
{
fsel_input(path,file,&button);
if(button==0)
 return(-1);
if(file[0]==0)
 return(0);
strcpy(workname,path);
trunname(workname);
strcpy(justpath,workname);
strcat(workname,file);
return(1);
}

/***********************************/
/* Handle the menu bar interaction */
/***********************************/

do_menu()
{
switch(mgbuf[4])
 {
 case ABOUTIT:
  form_alert(1,about_it);
  break;
 case LOADDATA:
  load_data();
  break;
 case SAVETOP:
  save_pic(topbuf,palette);
  break;
 case SAVEPSPC:
  save_pic(perbuf,palette);
  break;
 case SAVE3D:
  save_3D();
  break;
 case QUIT:
  if(form_alert(1,quit_sure)==1)
   done=1;
  break;
 case USEDATA:
  gen_real();
  break;
 case FRACTAL:
  gen_fractal();
  break;
 case TOP:
  gen_top();
  break;
 case PERSPEC:
  gen_perspec();
  break;
 }
}

/************************/
/* Set up a dialog form */
/************************/

fm_set(address)
long address;
{
form_center(address,&formx,&formy,&formw,&formh);
form_dial(0,0,0,0,0,formx,formy,formw,formh);
}

/*****************/
/* Remove a form */
/*****************/

fm_unset()
{
form_dial(3,0,0,0,0,formx,formy,formw,formh);
}

/**************************************************/
/* Get item's X,Y,W & H adjusted to screen coords */
/**************************************************/

getxywh(dumarray,dumix,dumx,dumy,dumw,dumh)
int dumarray[][12];
int dumix,*dumx,*dumy,*dumw,*dumh;
{
objc_offset(dumarray,dumix,dumx,dumy);
*dumw=dumarray[dumix][10];
*dumh=dumarray[dumix][11];
}

/******************************/
/* Select an item in a dialog */
/******************************/

srcon(formad,index,draw)
long formad;
int index,draw;
{
objc_change(formad,index,0,formx,formy,formw,formh,1,draw);
}

/********************************/
/* Deselect an item in a dialog */
/********************************/

srcoff(formad,index,draw)
long formad;
int index,draw;
{
objc_change(formad,index,0,formx,formy,formw,formh,0,draw);
}

/*********************************************/
/* Wait for mouse button to return to normal */
/*********************************************/

mbup()
{
evnt_button(1,3,0,&dum,&dum,&dum,&dum);
}

/***********************/
/* My wind_update code */
/***********************/

my_update(myut)
int myut;
{
if(myut==2)
 {
 if(mcflg)
  {
  mcflg=0;
  wind_update(2);
  }
 }
else
if(myut==3)
 {
 if(mcflg==0)
  {
  mcflg=1;
  wind_update(3);
  }
 }
}

/************************************/
/* Save a picture, given its bitmap */
/* and palette buffer addresses     */
/************************************/

save_pic(picbuf,palbuf)
long picbuf,palbuf;
{
register int format,fhand;
char savefile[64];
int fn_len,e0,e1,e2,e3;

if(getfile(picpath,picfile)>0)
 {
 fn_len=strlen(picfile);
 e0=fn_len-4;
 e1=fn_len-3;
 e2=fn_len-2;
 e3=fn_len-1;

 if(picfile[e0]!='.')		/* Must have extension */
  {
  form_alert(1,no_ext);
  return;
  }

 if(picfile[e1]=='P' && picfile[e2]=='I' && picfile[e3]=='1')
  format=0;
 else
 if(picfile[e1]=='N' && picfile[e2]=='E' && picfile[e3]=='O')
  format=1;
 else
  {
  form_alert(1,no_ext);
  return;
  }

 strcpy(savefile,justpath);
 strcat(savefile,picfile);
 fhand=Fcreate(savefile,0);
 if(fhand>=0)
  {
  switch(format)
   {
   case 0:
    pi1_save(fhand,picbuf,palbuf);
    break;
   case 1:
    neo_save(fhand,picbuf,palbuf);
    break;
   }
  }
 else
  form_alert(1,cant_create);
 }
}

/***************************************************/
/* Save the picture in DEGAS' uncompressed format. */
/***************************************************/

pi1_save(fhand,buffer,pal)
int fhand;
long buffer,pal;
{
static int rezword=0;

Fwrite(fhand,2L,&rezword);
Fwrite(fhand,32L,pal);
if(Fwrite(fhand,32000L,buffer)!=32000L)
 form_alert(1,write_err);
Fclose(fhand);
}

/***********************************/
/* Save a NeoChrome format picture */
/***********************************/

neo_save(fhand,buffer,pal)
int fhand;
long buffer,pal;
{
register int ix;
static int rezword=0;

Fwrite(fhand,2L,&rezword);
Fwrite(fhand,2L,&rezword);
Fwrite(fhand,32L,pal);
for(ix=0; ix<46; ++ix)
 Fwrite(fhand,2L,&rezword);
if(Fwrite(fhand,32000L,buffer)!=32000L)
 form_alert(1,write_err);
Fclose(fhand);
}

/**********************************/
/* Save the map data as a 3D file */
/**********************************/

save_3D()
{
register int fhand,rez;
char savefile[64];
static char maprez[]=
"[3][ What map resolution? ][ 80X80 | 40X40 | 20X20 ]";

rez=form_alert(1,maprez);
if(getfile(path3D,file3D)>0)
 {
 strcpy(savefile,justpath);
 strcat(savefile,file3D);
 fhand=Fcreate(savefile,0);
 if(fhand>=0)
  {
  graf_mouse(2,0L);
  write_3D(fhand,rez);
  graf_mouse(0,0L);
  }
 else
  form_alert(1,cant_create);
 }
}

write_3D(fhand,rez)
int fhand,rez;
{
register int ix,iy,jx,kx;
int worknum,gsize,gstep,xystep,vsize,vtcount,fccount;
static float px[6400],py[6400],pz[6400];
static float wpx,wpy,wpz;

switch(rez)
 {
 case 1:	/* 80X80 */
  gsize=80;
  gstep=2;
  xystep=1;
  vsize=25600;
  vtcount=6400;
  fccount=12482;
  break;
 case 2:	/* 40X40 */
  gsize=40;
  gstep=4;
  xystep=2;
  vsize=6400;
  vtcount=1600;
  fccount=3042;
  break;
 case 3:	/* 20X20 */
  gsize=20;
  gstep=8;
  xystep=4;
  vsize=1600;
  vtcount=400;
  fccount=722;
  break;
 }

/* File header */

worknum=0x3d3d;
Fwrite(fhand,2L,&worknum);

/* # of objects */

worknum=1;
Fwrite(fhand,2L,&worknum);

/* Light sources */

worknum=1;
Fwrite(fhand,2L,&worknum);
worknum=0;
Fwrite(fhand,2L,&worknum);
Fwrite(fhand,2L,&worknum);

worknum=7;
Fwrite(fhand,2L,&worknum);
worknum=4;
Fwrite(fhand,2L,&worknum);
worknum=3;
Fwrite(fhand,2L,&worknum);

worknum=0;
Fwrite(fhand,2L,&worknum);
worknum=1;
Fwrite(fhand,2L,&worknum);
worknum=2;
Fwrite(fhand,2L,&worknum);

worknum=0;
Fwrite(fhand,2L,&worknum);
worknum=1;
Fwrite(fhand,2L,&worknum);
worknum=2;
Fwrite(fhand,2L,&worknum);

worknum=2;
Fwrite(fhand,2L,&worknum);
worknum=1;
Fwrite(fhand,2L,&worknum);
worknum=0;
Fwrite(fhand,2L,&worknum);

/* Object name */

Fwrite(fhand,9L,"CONTOUR ");

/* Build vertex arrays */

for(ix=0,jx=0,wpx= -40; ix<160; ix+=gstep,wpx+=xystep)
 {
 for(iy=0,wpy=40; iy<160; iy+=gstep,wpy-=xystep)
  {
  px[jx]=wpx;
  py[jx]=wpy;
  pz[jx++]=(float)tab2[ix][iy];
  }
 }

/* Vertex count */

Fwrite(fhand,2L,&vtcount);

/* Write vertices */

Fwrite(fhand,(long)vsize,px);
Fwrite(fhand,(long)vsize,py);
if(Fwrite(fhand,(long)vsize,pz)!=(long)vsize)
 goto failure;

/* Face count */

Fwrite(fhand,2L,&fccount);

/* Write faces */

for(ix=0; ix<(gsize-1); ++ix)
 {
 jx=ix*gsize;
 for(iy=0; iy<(gsize-1); ++iy,++jx)
  {
  worknum=jx;
  Fwrite(fhand,2L,&worknum);
  worknum=jx+1;
  Fwrite(fhand,2L,&worknum);
  worknum=jx+gsize+1;
  Fwrite(fhand,2L,&worknum);
  if((pz[jx]+pz[jx+gsize+1]+pz[jx+1])==0)
   worknum=0x060e;
  else
   worknum=0x0607;
  Fwrite(fhand,2L,&worknum);

  worknum=jx;
  Fwrite(fhand,2L,&worknum);
  worknum=jx+gsize+1;
  Fwrite(fhand,2L,&worknum);
  worknum=jx+gsize;
  Fwrite(fhand,2L,&worknum);
  if((pz[jx]+pz[jx+gsize+1]+pz[jx+gsize])==0)
   worknum=0x030e;
  else
   worknum=0x0307;
  if(Fwrite(fhand,2L,&worknum)!=2L)
   goto failure;
  }
 }
Fclose(fhand);
return;

failure:
Fclose(fhand);
form_alert(1,write_err);
}

/*********************************/
/* Generate a map from real data */
/*********************************/

gen_real()
{
register int ix,iy,ox,oy;
int exitix,lastx,lasty;
int pstrtx,pstrty,pendx,pendy,wsx,wsy,wex,wey,ulx,uly;
int box[10],xlimit,ylimit,limit,deltax,partx,party,partw,parth,partr,partb;
float sample,frac;

pstrtx=startx;
pstrty=starty;
pendx=endx;
pendy=endy;

vsl_udsty(handle,0x5555);
vsl_type(handle,7);
vsl_color(handle,1);
vswr_mode(handle,3);

/* Do the real map dialog */

fm_set(partaddr);
objc_draw(partaddr,0,2,formx,formy,formw,formh);

getxywh(partaddr,PARTBOX,&partx,&party,&partw,&parth);
partr=partx+partw;
partb=party+parth;

part_loop:
exitix=form_do(partaddr,0) & 0x7fff;
switch(exitix)
 {
 case PART:
  wsx=pstrtx;
  wsy=pstrty;
  wex=pendx;
  wey=pendy;
  break;
 case FULL:
  wsx=startx;
  wsy=starty;
  wex=endx;
  wey=endy;
  break;
 case PARTBOX:
  graf_mkstate(&ulx,&uly,&button,&dum);

  if(ulx<partx || ulx>=partr || uly<party || uly>=partb)
   break;

  objc_draw(partaddr,PARTBOX,0,0,0,320,200);

  xlimit=partr-ulx;
  ylimit=partb-uly;
  if(xlimit>ylimit)
   limit=ylimit;
  else
   limit=xlimit;

  box[0]=box[6]=box[8]=ulx;
  box[2]=box[4]=ulx+1;
  box[1]=box[3]=box[9]=uly;
  box[5]=box[7]=uly+1;

  v_pline(handle,5,box);

  lastx=lasty= -9999;
  while(button==1)
   {
   graf_mkstate(&mousex,&mousey,&button,&dum);
   
   if(mousex==lastx && mousey==lasty)
    goto skip;
   if(mousex<=ulx || mousey<=uly)
    goto skip;

   lastx=mousex;
   lasty=mousey;

   deltax=mousex-ulx;
   if(deltax<limit)
    {
    v_hide_c(handle);
    v_pline(handle,5,box);
    box[2]=box[4]=mousex;
    box[5]=box[7]=uly+deltax;
    v_pline(handle,5,box);
    v_show_c(handle,0);
    }

   skip:
   }

  frac=(float)(ulx-partx)/partw;
  pstrtx=(int)(frac*(float)(endx-startx))+startx;
  frac=(float)(box[4]-partx)/partw;
  pendx=(int)(frac*(float)(endx-startx))+startx;
  frac=(float)(uly-party)/parth;
  pstrty=(int)(frac*(float)(endy-starty))+starty;
  frac=(float)(box[5]-party)/parth;
  pendy=(int)(frac*(float)(endy-starty))+starty;

  goto part_loop;
  break;
 }
fm_unset();
srcoff(partaddr,exitix,0);

vswr_mode(handle,1);

menu_ienable(menuaddr,TOP,1);
menu_ienable(menuaddr,PERSPEC,1);
menu_ienable(menuaddr,SAVETOP,0);
menu_ienable(menuaddr,SAVEPSPC,0);
menu_ienable(menuaddr,SAVE3D,1);

fm_set(prog2addr);
objc_draw(prog2addr,0,2,formx,formy,formw,formh);

graf_mouse(2,0L);

/* Sample main map array down into work array */

srcon(prog2addr,SAMPLING,1);
srcoff(prog2addr,SAMPLING,0);

sample=(float)(wex-wsx)/256.0;

for(ix=0; ix<256; ++ix)
 {
 ox=(int)((float)ix*sample)+wsx;
 for(iy=0; iy<256; ++iy)
  {
  oy=(int)((float)iy*sample)+wsy;
  table[ix][iy]=map[ox][oy];
  }
 }

/* Final processing step */

srcon(prog2addr,REALFINL,1);
srcoff(prog2addr,REALFINL,0);

fin_proc();

fm_unset();
graf_mouse(0,0L);
}

/*********************************/
/* Generate a map using fractals */
/*********************************/

gen_fractal()
{
register int ix,ix2,iy,iy2;
int phase,step,step2;
static int c256=256;

menu_ienable(menuaddr,TOP,1);
menu_ienable(menuaddr,PERSPEC,1);
menu_ienable(menuaddr,SAVETOP,0);
menu_ienable(menuaddr,SAVEPSPC,0);
menu_ienable(menuaddr,SAVE3D,1);

graf_mouse(2,0L);

/* Show progress dialog */

fm_set(progaddr);
objc_draw(progaddr,0,2,formx,formy,formw,formh);

/* Init map to null values */

for(ix=0; ix<257; ++ix)
 {
 for(iy=0; iy<257; ++iy)
  table[ix][iy] = -5000;
 }

/* Define random corners for map */

table[0][0]=((int)Random() & 0x01ff) - 255;
table[0][c256]=((int)Random() & 0x01ff) - 255;
table[c256][0]=((int)Random() & 0x01ff) - 255;
table[c256][c256]=((int)Random() & 0x01ff) - 255;

/* Now do a fractal interpolation */

for(phase=1,step=128,step2=256; phase<9; ++phase,step/=2,step2/=2)
 {
 srcon(progaddr,PHASE1+phase-1,1);
 srcoff(progaddr,PHASE1+phase-1,0);

 for(iy=0; iy<257; iy+=step2)
  {
  for(ix=0; ix<257; ix+=step)
   {
   if(table[ix][iy] == -5000)
    {
    wrand=(Random() & masks[phase])-subfac[phase];
    table[ix][iy]=(table[ix-step][iy]+table[ix+step][iy])/2+wrand;
    }
   }
  }
 for(ix=0; ix<257; ix+=step)
  {
  for(iy=0; iy<257; iy+=step)
   {
   if(table[ix][iy] == -5000)
    {
    wrand=(Random() & masks[phase])-subfac[phase];
    table[ix][iy]=(table[ix][iy-step]+table[ix][iy+step])/2+wrand;
    }
   }
  }
 } 

/* Add offset for sea level adjust */

for(ix=0; ix<257; ++ix)
 {
 for(iy=0; iy<257; ++iy)
  table[ix][iy] += 144;
 }

/* Final processing step */

srcon(progaddr,FINAL,1);
srcoff(progaddr,FINAL,0);
fin_proc();

fm_unset();
graf_mouse(0,0L);
}

/**********************************/
/* Scale map to 160X160 grids for */
/* display and 3D file generation */
/**********************************/

fin_proc()
{
register int ix,iy,ox,oy;
float sample;

sample=1.6;

for(ix=0; ix<160; ++ix)
 {
 ox=(int)((float)ix*sample);
 for(iy=0; iy<160; ++iy)
  {
  oy=(int)((float)iy*sample);
  if(table[ox][oy]<0)
   table[ox][oy]=0;

  tab2[ix][iy]=table[ox][oy]/12;
  table[ix][iy]=table[ox][oy]/24+3;
  
  if(table[ix][iy]==3 && tab2[ix][iy]>0)
   table[ix][iy]=4;
  if(table[ix][iy]>15)
   table[ix][iy]=15;
  }
 }
}

/***********************************/
/* Generate & display map top view */
/***********************************/

gen_top()
{
register int ix,ix2,iy,iy2;

v_hide_c(handle);
Setscreen(topbuf,topbuf,0);
Setpallete(palette);

pinit(topbuf);

for(ix=0,ix2=80; ix<160; ++ix,++ix2)
 {
 for(iy=0,iy2=20; iy<160; ++iy,++iy2)
  myplot(ix2,iy2,table[ix][iy]);
 }

evnt_button(1,1,1,&dum,&dum,&dum,&dum);
mbup();

Setscreen(oldsc,oldsc,-1);
Setpallete(oldpal);
v_show_c(handle,0);

menu_ienable(menuaddr,SAVETOP,1);
}

/***************************************/
/* Generate & display perspective view */
/***************************************/

gen_perspec()
{
register int ix,ix2,iy,iy2;

v_hide_c(handle);
Setscreen(perbuf,perbuf,0);
Setpallete(palette);

pinit(perbuf);

/* Draw surface */

for(iy=0; iy<160; ++iy)
 {
 for(ix=0,ix2=ix+iy; ix<160; ++ix)
  {
  myplot(ix2++,iy+30-tab2[ix][iy],table[ix][iy]);
  }
 }

/* Draw block sides */

vsl_color(handle,3);
vsl_type(handle,1);
for(iy=0,iy2=40; iy<160; ++iy)
 {
 ln[0]=ln[2]=iy; ln[1]=iy2++; ln[3]=ln[1]-9-tab2[0][iy];
 v_pline(handle,2,ln);
 }
vsl_color(handle,2);
for(ix=0,ix2=160; ix<160; ++ix)
 {
 ln[0]=ln[2]=ix2++; ln[1]=199; ln[3]=190-tab2[ix][159];
 v_pline(handle,2,ln);
 }

evnt_button(1,1,1,&dum,&dum,&dum,&dum);
mbup();

Setscreen(oldsc,oldsc,-1);
Setpallete(oldpal);
v_show_c(handle,0);

menu_ienable(menuaddr,SAVEPSPC,1);
}

/*****************************/
/* Load a PES/USGS data file */
/*****************************/

load_data()
{
register int ix,iy;
char datafile[64];
int fhand,maxgrid,*mapptr;
int tnull,bnull,lnull,rnull,nullflag;
float zscale;

if(getfile(datpath,datfile)>0)
 {
 strcpy(datafile,justpath);
 strcat(datafile,datfile);
 fhand=Fopen(datafile,0);
 if(fhand<0)
  {
  form_alert(1,cant_open);
  return;
  }

/* Read the file's header record */

 graf_mouse(2,&dum);
 if(Fread(fhand,168L,&hdr)!=168L)
  {
  bad_data:
  graf_mouse(0,&dum);
  form_alert(1,bad_file);
  Fclose(fhand);
  return;
  }

/* Dummy-read rest of header record */

 if(dumread(fhand,772L)!=772L)
  goto bad_data;

/* Flop INTEL-format values */

 flop_l(&hdr.low_x);
 flop_l(&hdr.low_y);
 flop_l(&hdr.hi_y);
 flop_i(&hdr.num_y);
 flop_i(&hdr.num_x);
 flop_i(&hdr.interval);
 flop_i(&hdr.UTMzone);
 flop_i(&hdr.low_z);
 flop_i(&hdr.hi_z);

/* Find scale factor for grid Z values */

 zscale=300.0/(float)hdr.hi_z;

/* Find maximum grid size for our memory */

 maxgrid=(int)sqrt((float)(freeRAM/2));
 if(maxgrid>470)
  maxgrid=470;

 if(hdr.num_y>maxgrid)
  hdr.num_y=maxgrid;
 if(hdr.num_x>maxgrid)
  hdr.num_x=maxgrid;

/* Now insure that data grid is square */

 if(hdr.num_y<hdr.num_x)
  gridsize=hdr.num_y;
 else
  gridsize=hdr.num_x;

/* Init map pointer array */

 for(ix=0,mapptr=mapdata; ix<gridsize; ++ix,mapptr+=(long)gridsize)
  map[ix]=mapptr;

/* Now read in the map data */

 for(iy=0; iy<gridsize; ++iy)
  {
  if(Fread(fhand,940L,xbuf)<940L)
   goto bad_data;
  for(ix=0; ix<gridsize; ++ix)
   {
   flop_i(&xbuf[ix]);
   if(xbuf[ix] == -999)
    map[ix][iy] = -999;
   else
    map[ix][iy]=(int)((float)xbuf[ix]*zscale);
   }
  }
 Fclose(fhand);
 menu_ienable(menuaddr,USEDATA,1);
 }

startx=starty=0;
endx=endy=gridsize;

/* Fix edges if there is null data */

edge_fix:
tnull=bnull=lnull=rnull=nullflag=0;
for(ix=startx; ix<endx; ++ix)
 {
 if(map[ix][starty]== -999)
  tnull=nullflag=1;
 if(map[ix][endy-1]== -999)
  bnull=nullflag=1;
 }
for(ix=starty; ix<endy; ++ix)
 {
 if(map[startx][ix]== -999)
  lnull=nullflag=1;
 if(map[endx-1][ix]== -999)
  rnull=nullflag=1;
 }
if(tnull)
 starty++;
if(bnull)
 endy--;
if(lnull)
 startx++;
if(rnull)
 endx--;
if(nullflag)
 goto edge_fix;

graf_mouse(0,&dum);
}

/*************************************/
/* Reverse order of LONG INTEL value */
/*************************************/

flop_l(laddr)
char *laddr;
{
register char temp;

temp= *laddr;
*laddr=laddr[3];
laddr[3]=temp;
temp=laddr[1];
laddr[1]=laddr[2];
laddr[2]=temp;
}

/************************************/
/* Reverse order of INT INTEL value */
/************************************/

flop_i(iaddr)
char *iaddr;
{
register char temp;

temp= *iaddr;
*iaddr=iaddr[1];
iaddr[1]=temp;
}
