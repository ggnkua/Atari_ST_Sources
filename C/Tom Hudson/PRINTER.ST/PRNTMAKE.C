/**********************************/
/*    DEGAS printer driver maker  */
/*          by Tom Hudson	  */
/*       For START Magazine	  */
/* Copyright 1986 Antic Publishing */
/**********************************/

#include <portab.h>
#include <obdefs.h>
#include <osbind.h>
#include <prntmake.h>
#include <prntmake.rsh>

/*******************************************************************/
/* Define the dumper and the various dumper skeleton insert points */
/*******************************************************************/

extern dumper();

extern int lshift;
extern int rshift;

extern int HEADPINS[];
extern int HEADSIZE[];
extern int VSOFF[];
extern int VSSIZE[];
extern int HVXO[];
extern int HVXE[];
extern int HVYO[];
extern int HVYE[];
extern int MVYO[];
extern int MVYE[];
extern int LVXO[];
extern int LVXE[];
extern int HSOFF[];
extern int HSSIZE[];
extern int HHXO[];
extern int HHXE[];
extern int HHYO[];
extern int HHYE[];
extern int MHXO[];
extern int MHXE[];
extern int LHYO[];
extern int LHYE[];
extern int INITOFF[];
extern int INITSIZ[];
extern int SCALE1[];
extern int SCALE2[];
extern int HMINIT[];
extern int SHIFT[];
extern int ENDOFF[];
extern int ENDSIZ[];
extern int CLEANOFF[];
extern int CLEANSIZ[];
extern char STRINGS[];

/********************************/
/* GEM binding global variables */
/********************************/

int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];

int gr_1,gr_2,gr_3,gr_4;
long abaddr,vaddr,haddr,chkaddr,msaddr,inaddr;
int dum;
int formx,formy,formw,formh;
int exitix,l_intin[11],l_out[57];
int handle,fresult,fbutton,fhandle;
char defpath[64],workpath[80],filename[20],filepath[80];
int pin1,vw640,vh400,hw400,hh640;
int pcount,scale;
char npins[3]="8";
char pscale[2]="1";
char istring[73],vertstrt[73],horstrt[73],endoline[73],cleanlin[73];
char initbuf[40],vertbuf[40],horbuf[40],endbuf[40],cleanbuf[40];
int ibsize,vbsize,hbsize,ebsize,cbsize;

static int workrez,worksc[16000],workpal[16],iobuf[16000],workarea[640];

/************************************/
/* Miscellaneous form_alert strings */
/************************************/

char newwarn[] =
"[1][ | WARNING: This operation will| clear the driver data! | ]\
[NEW DRIVER|Cancel]";

char badfile[] =
"[1][ | Bad picture file! | ][SORRY]";

char badrez[] =
"[1][ | Run this program in medium | or high resolution!| ][SORRY]";

char cantopen[] =
"[1][ | Can't open that file! | ][SORRY]";

char badwrite[] =
"[1][ |    Write error on file!| Driver not written.  Please |\
 try another disk.| ][SORRY]";

char toomany[] =
"[1][ | Please enter 1-24 pins! | ][Try again]";

char badscale[] =
"[1][ | Please enter scaling factor! | ][Try again]";

char badis[] =
"[1][ | Invalid init string! | ][Try again]";

char quitchk[] =
"[3][ | Are you sure you want to | quit? | ][Quit|Cancel]";

char badss[] =
"[1][ | Invalid start string! | ][Try again]";

char bades[] =
"[1][ | Invalid line-end string! | ][Try again]";

char badcs[] =
"[1][ | Invalid clean-up string! | ][Try again]";

char ready[] =
"[3][Ready to test!  Click on OK|alone for horizontal dump, or|\
press Alternate and click on|OK for vertical dump.][  OK  |Cancel]";

char another[] =
"[3][ |     Driver written!     |  More drivers to make?  | ][YES|NO]";

char initfail[] =
"[3][ |  Driver init failure!  | Ready printer & retry. | ][Retry|Cancel]";

main()
{
register int ix;

/**********************************/
/* Initialize the GEM application */
/**********************************/

appl_init();
handle=graf_handle(&gr_1,&gr_2,&gr_3,&gr_4);

defpath[0] = Dgetdrv() + 'A';
defpath[1] = ':';
Dgetpath(&defpath[2], 0);
strcpy(workpath,defpath);
strcat(workpath,"\\");

/***********************/
/* Set up dialog trees */
/***********************/

abaddr = &rs_object[rs_trindex[ABOUTIT]];
vaddr = &rs_object[rs_trindex[VERTSET]];
haddr = &rs_object[rs_trindex[HORIZSET]];
chkaddr = &rs_object[rs_trindex[CHECKIT]];
msaddr = &rs_object[rs_trindex[MISCSET]];
inaddr = &rs_object[rs_trindex[INITSTR]];

/***********************************************************/
/* Calculate all the positions of the objects in our trees */
/***********************************************************/

for(ix=0; ix<NUM_OBS; ++ix)
 {
 if(rs_object[ix].ob_type==G_STRING ||
    rs_object[ix].ob_type==G_BUTTON)
  rs_object[ix].ob_spec=rs_strings[(int)rs_object[ix].ob_spec];
 else
 if(rs_object[ix].ob_type==G_FTEXT)
  rs_object[ix].ob_spec= &rs_tedinfo[(int)rs_object[ix].ob_spec];
 rs_object[ix].ob_x*=gr_1;
 rs_object[ix].ob_y*=gr_2;
 rs_object[ix].ob_width*=gr_1;
 rs_object[ix].ob_height*=gr_2;
 }

for(ix=0; ix<NUM_TI; ++ix)
 {
 rs_tedinfo[ix].te_ptext=rs_strings[(int)rs_tedinfo[ix].te_ptext];
 rs_tedinfo[ix].te_ptmplt=rs_strings[(int)rs_tedinfo[ix].te_ptmplt];
 rs_tedinfo[ix].te_pvalid=rs_strings[(int)rs_tedinfo[ix].te_pvalid];
 }

/********************/
/* open workstation */
/********************/

for (ix=0; ix<10; ix++)
  l_intin[ix] = 1;
l_intin[10] = 2;
v_opnvwk(l_intin, &handle, l_out);

graf_mouse(0,&dum);

/********************************/
/* Verify the screen resolution */
/********************************/

if(Getrez()==0)
 {
 form_alert(1,badrez);
 goto bail_out;
 }

/***************************/
/* Show the "about" dialog */
/***************************/

form_center(abaddr,&formx,&formy,&formw,&formh);
form_dial(0,0,0,0,0,formx,formy,formw,formh);
objc_draw(abaddr,0,3,formx,formy,formw,formh);
exitix=form_do(abaddr,0) & 0x7fff;
srcoff(abaddr,exitix,1);
form_dial(3,0,0,0,0,formx,formy,formw,formh);
if(exitix==ABOUTCAN)
 goto bail_out;

/********************************************************/
/* Initialize driver settings to start-up configuration */
/********************************************************/

new_driver:
pin1=0;			/* top pin = 1 */
strcpy(npins,"8");	/* 8 pins      */
strcpy(pscale,"1");	/* scale=1     */
istring[0]=0;

vw640=1;		/* 960 pixels  */
vh400=1;		/* 600 pixels  */
vertstrt[0]=0;		/* null string */

hw400=1;		/* 600 pixels  */
hh640=1;		/* 960 pixels  */
horstrt[0]=0;		/* null string */

endoline[0]=0;		/* null string */
cleanlin[0]=0;		/* null string */

/*************************/
/* re-edit reentry point */
/*************************/

re_edit:
copdtxt(inaddr,NPINS,npins);
copdtxt(inaddr,PSCALE,pscale);
copdtxt(inaddr,ISTRING,istring);
srcon(inaddr,PIN1+pin1,0);

form_center(inaddr,&formx,&formy,&formw,&formh);
form_dial(0,0,0,0,0,formx,formy,formw,formh);
objc_draw(inaddr,0,3,formx,formy,formw,formh);
exitix=form_do(inaddr,NPINS) & 0x7fff;
srcoff(inaddr,exitix,1);
form_dial(3,0,0,0,0,formx,formy,formw,formh);

if(exitix==INITCAN)
 {
 if(form_alert(1,quitchk)==1)
  goto bail_out;
 goto re_edit;
 }

pin1=radio(inaddr,PIN1,2);		/* pin1=0:top=1, pin1=1:top=128	*/
radreset(inaddr,PIN1,2,0);
getdtxt(inaddr,NPINS,npins);		/* npins  = 1-24		*/
getdtxt(inaddr,PSCALE,pscale);		/* pscale = 1-9			*/
getdtxt(inaddr,ISTRING,istring);	/* istring = un-parsed string	*/

pcount=ascint(npins);
if(pcount<1 || pcount>24)
 {
 form_alert(1,toomany);
 goto re_edit;
 }
scale=ascint(pscale);
if(scale<=0)
 {
 form_alert(1,badscale);
 goto re_edit;
 }
if(nparse(istring,initbuf,&ibsize)<0)
 {
 form_alert(1,badis);
 goto re_edit;
 }

get_vert:
copdtxt(vaddr,VERTSTRT,vertstrt);
srcon(vaddr,VW640+vw640,0);
srcon(vaddr,VH400+vh400,0);

form_center(vaddr,&formx,&formy,&formw,&formh);
form_dial(0,0,0,0,0,formx,formy,formw,formh);
objc_draw(vaddr,0,3,formx,formy,formw,formh);
exitix=form_do(vaddr,VERTSTRT) & 0x7fff;
srcoff(vaddr,exitix,1);
form_dial(3,0,0,0,0,formx,formy,formw,formh);

if(exitix==VERTCAN)
 {
 if(form_alert(1,quitchk)==1)
  goto bail_out;
 goto get_vert;
 }

vw640=radio(vaddr,VW640,12);		/* vw640=vertical width (0-11)	*/
vh400=radio(vaddr,VH400,12);		/* vh400=vertical height (0-11)	*/
radreset(vaddr,VW640,12,0);
radreset(vaddr,VH400,12,0);
getdtxt(vaddr,VERTSTRT,vertstrt);	/* vertstrt=raw vert start string */

if(nparse(vertstrt,vertbuf,&vbsize)<0)
 {
 form_alert(1,badss);
 goto get_vert;
 }

get_hor:
copdtxt(haddr,HORSTRT,horstrt);
srcon(haddr,HW400+hw400,0);
srcon(haddr,HH640+hh640,0);

form_center(haddr,&formx,&formy,&formw,&formh);
form_dial(0,0,0,0,0,formx,formy,formw,formh);
objc_draw(haddr,0,3,formx,formy,formw,formh);
exitix=form_do(haddr,HORSTRT) & 0x7fff;
srcoff(haddr,exitix,1);
form_dial(3,0,0,0,0,formx,formy,formw,formh);

if(exitix==HORIZCAN)
 {
 if(form_alert(1,quitchk)==1)
  goto bail_out;
 goto get_hor;
 }

hw400=radio(haddr,HW400,12);		/* hw400=horiz. width (0-11)	*/
hh640=radio(haddr,HH640,12);		/* hh640=horiz. height (0-11)	*/
radreset(haddr,HW400,12,0);
radreset(haddr,HH640,12,0);
getdtxt(haddr,HORSTRT,horstrt);		/* horstrt=raw horiz. start string */

if(nparse(horstrt,horbuf,&hbsize)<0)
 {
 form_alert(1,badss);
 goto get_hor;
 }

get_misc:
copdtxt(msaddr,ENDOLINE,endoline);
copdtxt(msaddr,CLEANLIN,cleanlin);

form_center(msaddr,&formx,&formy,&formw,&formh);
form_dial(0,0,0,0,0,formx,formy,formw,formh);
objc_draw(msaddr,0,3,formx,formy,formw,formh);
exitix=form_do(msaddr,ENDOLINE) & 0x7fff;
srcoff(msaddr,exitix,1);
form_dial(3,0,0,0,0,formx,formy,formw,formh);

if(exitix==MISCCAN)
 {
 if(form_alert(1,quitchk)==1)
  goto bail_out;
 goto get_misc;
 }

getdtxt(msaddr,ENDOLINE,endoline);	/* endoline=raw line-end string */
getdtxt(msaddr,CLEANLIN,cleanlin);	/* cleanlin=raw clean-up string */

if(nparse(endoline,endbuf,&ebsize)<0)
 {
 form_alert(1,bades);
 goto get_misc;
 }
if(cleanlin[0]==0)
 {
 cbsize=0;
 }
else
 {
 if(nparse(cleanlin,cleanbuf,&cbsize)<0)
  {
  form_alert(1,badcs);
  goto get_misc;
  }
 }

get_check:
form_center(chkaddr,&formx,&formy,&formw,&formh);
form_dial(0,0,0,0,0,formx,formy,formw,formh);
objc_draw(chkaddr,0,3,formx,formy,formw,formh);
exitix=form_do(chkaddr,0) & 0x7fff;
srcoff(chkaddr,exitix,1);
form_dial(3,0,0,0,0,formx,formy,formw,formh);

/************************************/
/* Plug codes into dumper skeleton! */
/************************************/

inst_codes();

switch(exitix)
 {
 case LOWTEST:
  dumptest(0);
  break;
 case MEDTEST:
  dumptest(1);
  break;
 case HITEST:
  dumptest(2);
  break;
 case REEDIT:
  goto re_edit;
  break;
 case NEWDRV:
  if(form_alert(1,newwarn)==1)
   goto new_driver;
  break;
 case SAVEIT:
  save_drv();
  break;
 default:
  if(form_alert(1,quitchk)==1)
   goto bail_out;
  break;
 }
goto get_check;

/*****************************/
/* Close virtual workstation */
/*****************************/

bail_out:
v_clsvwk(handle);

/********************/
/* And say bye-bye! */
/********************/

appl_exit();
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

/***************************************/
/* Place a string into a string object */
/* 				       */
/* format:			       */
/* copdstr(tree,object,string)	       */
/*				       */
/* tree:   LONG address of tree	       */
/* object: WORD index of string object */
/* string: string to place into the    */
/*         string object	       */
/***************************************/

copdstr(dumarray,dumix,txtad)
long *dumarray[][6];
char *txtad;
int dumix;
{
unsigned ix;
char *acttext;

acttext=(char *)dumarray[dumix][3];
strcpy(acttext,txtad);
}

/***************************************/
/* Place a string into a text object   */
/* 				       */
/* format:			       */
/* copdstr(tree,object,string)	       */
/*				       */
/* tree:   LONG address of tree	       */
/* object: WORD index of text object   */
/* string: string to place into the    */
/*         text object		       */
/***************************************/

copdtxt(dumarray,dumix,txtad)
long *dumarray[][6];
char *txtad;
int dumix;
{
unsigned ix;
char *acttext;
long *loc;

loc=dumarray[dumix][3];
acttext= *loc;
strcpy(acttext,txtad);
}

/***************************************/
/* Get a string from a text object     */
/* 				       */
/* format:			       */
/* copdstr(tree,object,string)	       */
/*				       */
/* tree:   LONG address of tree	       */
/* object: WORD index of text object   */
/* string: string to recieve the text  */
/*         object's string	       */
/***************************************/

getdtxt(dumarray,dumix,txtad)
long *dumarray[][6];
char *txtad;
int dumix;
{
unsigned ix;
char *acttext;
long *loc;

loc=dumarray[dumix][3];
acttext= *loc;
strcpy(txtad,acttext);
}

/****************************************/
/* Convert an ascii value to an integer */
/*					*/
/* Returns a WORD value containing the  */
/* positive integer value of a string.  */
/* Returns -1 if string is non-numeric  */
/* or > 32767.				*/
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

/****************************************/
/* Deselect an object			*/
/*					*/
/* format:				*/
/* srcoff(tree,object,draw)		*/
/*					*/
/* tree:   Address of object tree	*/
/* object: Index of object to change	*/
/* draw:   0: don't redraw object	*/
/*         <>0: redraw object		*/
/****************************************/

srcoff(formad,index,draw)
long formad;
int index,draw;
{
objc_change(formad,index,0,formx,formy,formw,formh,0,draw);
}

/****************************************/
/* Select an object			*/
/*					*/
/* format:				*/
/* srcon(tree,object,draw)		*/
/*					*/
/* tree:   Address of object tree	*/
/* object: Index of object to change	*/
/* draw:   0: don't redraw object	*/
/*         <>0: redraw object		*/
/****************************************/

srcon(formad,index,draw)
long formad;
int index,draw;
{
objc_change(formad,index,0,formx,formy,formw,formh,1,draw);
}

/****************************************/
/* Reset a group of radio buttons	*/
/*					*/
/* format:				*/
/* radreset(tree,object,count,draw)	*/
/*					*/
/* tree:   Address of object tree	*/
/* object: Starting radio button index	*/
/* count:  Number of buttons in group	*/
/* draw:   0: don't redraw buttons	*/
/*         <>0: redraw buttons		*/
/****************************************/

radreset(tree,fradio,radcnt,draw)
long tree;
int fradio,radcnt,draw;
{
register unsigned ix;
for(ix=0; ix<radcnt; ++ix)
 srcoff(tree,fradio+ix,draw);
}

/****************************************/
/* Find enabled radio button		*/
/*					*/
/* format:				*/
/* radio(tree,object,count)		*/
/*					*/
/* tree:   Address of object tree	*/
/* object: Radio button index		*/
/* count:  Number of buttons in group	*/
/*					*/
/* Returns button # (0-count) as WORD	*/
/* Returns -1 if none enabled		*/
/****************************************/

radio(tree,fradio,radcnt)
long tree;
int fradio,radcnt;
{
register unsigned ix;
int butnum;

butnum= -1;
for(ix=0; ix<radcnt; ++ix)
 {
 if((itmstate(tree,fradio+ix) & 1))
  butnum=ix;
 }
return(butnum);
}

/****************************************/
/* Return object state			*/
/*					*/
/* format:				*/
/* itmstate(tree,object)		*/
/*					*/
/* tree:   Address of object tree	*/
/* object: Index of object to change	*/
/*					*/
/* returns object state as WORD		*/
/****************************************/

itmstate(dumarray,dumix)
int dumarray[][12];
int dumix;
{
return(dumarray[dumix][5]);
}

/****************************************/
/* Plug printer driver codes into the	*/
/* printer driver assembly skeleton	*/
/****************************************/

inst_codes()
{
register int ix,sx;
long imask;

/*******************************/
/* Odd & even repeat constants */
/*******************************/

static int hodds[12] =
{
1,1,2,2,3,3,4,4,5,5,6,6
};
static int hevens[12] =
{
1,2,2,3,3,4,4,5,5,6,6,7
};

static int lodds[12] =
{
2,3,4,5,6,7,8,9,10,11,12,13
};
static int levens[12] =
{
2,3,4,5,6,7,8,9,10,11,12,13
};

HEADPINS[1]=pcount;			/* Store # of pins		*/

HEADSIZE[1]=(pcount-1)/8+1;		/* Store # of bytes for head	*/

SCALE1[1]=SCALE2[1]=scale;		/* Store pattern scaling factor	*/

if(pin1==0)	/* 1 bit on top */
 {
 imask=0x00000001L << (24-pcount);	/* Set head mask initial position */
 HMINIT[1]=(int)(imask>>16);		/* Install head mask in driver	  */
 HMINIT[2]=(int)(imask & 0x0000ffffL);
 SHIFT[0]=lshift;			/* We need a left shift opcode	  */
 }
else		/* 128 bit on top */
 {
 HMINIT[1]=0x8000;			/* Head mask always $80000000	  */
 HMINIT[2]=0x0000;
 SHIFT[0]=rshift;			/* We need a right shift opcode   */
 }

sx=0;				/* Zero string offset index		*/

INITOFF[1]=0;			/* Init string offset = 0		*/
INITSIZ[1]=ibsize;		/* Set init string length		*/

for(ix=0; ix<ibsize; ++ix)	/* Copy init strin into STRINGS area	*/
 STRINGS[sx++]=initbuf[ix];

VSOFF[1]=sx;			/* Set vertical start string offset	*/
VSSIZE[1]=vbsize;		/* Set vertical start string length	*/

for(ix=0; ix<vbsize; ++ix)	/* Copy vert start string to STRINGS	*/
 STRINGS[sx++]=vertbuf[ix];

HSOFF[1]=sx;			/* Set horizontal start string offset	*/
HSSIZE[1]=hbsize;		/* Set horizontal start string length	*/

for(ix=0; ix<hbsize; ++ix)	/* Copy horiz. start string to STRINGS	*/
 STRINGS[sx++]=horbuf[ix];

ENDOFF[1]=sx;			/* Set end-of-line string offset	*/
ENDSIZ[1]=ebsize;		/* Set end-of-line string length	*/

for(ix=0; ix<ebsize; ++ix)	/* Copy end-of-line string to STRINGS	*/
 STRINGS[sx++]=endbuf[ix];

CLEANOFF[1]=sx;			/* Set clean-up string offset		*/
CLEANSIZ[1]=cbsize;		/* Set clean-up string length		*/

for(ix=0; ix<cbsize; ++ix)	/* Copy clean-up string to STRINGS	*/
 STRINGS[sx++]=cleanbuf[ix];

HVXO[1]=hodds[vw640];		/* Plug in all the vertical repeats	*/
HVXE[1]=hevens[vw640];
HVYO[1]=hodds[vh400];
HVYE[1]=hevens[vh400];
MVYO[1]=lodds[vh400];
MVYE[1]=levens[vh400];
LVXO[1]=lodds[vw640];
LVXE[1]=levens[vw640];

HHXO[1]=hodds[hw400];		/* Plug in all the horizontal repeats	*/
HHXE[1]=hevens[hw400];
HHYO[1]=hodds[hh640];
HHYE[1]=hevens[hh640];
MHXO[1]=lodds[hw400];
MHXE[1]=levens[hw400];
LHYO[1]=lodds[hh640];
LHYE[1]=levens[hh640];
}

/********************************************/
/* Grab a DEGAS picture and try to dump it! */
/********************************************/

dumptest(rez)
int rez;
{
register int ix;
static char rezstr[]="*.P?n";

rezstr[4]=rez+'1';
strcat(workpath,rezstr);
filename[0]=0;

fresult=fsel_input(workpath,filename,&fbutton);

trunname(workpath);
if(fresult>0 && fbutton==1)
 {
 strcpy(filepath,workpath);
 strcat(filepath,filename);

 fhandle=Fopen(filepath,0);
 if(fhandle >= 0)
  {
  Fread(fhandle,2L,&workrez);			/* Get resolution WORD	*/
  Fread(fhandle,32L,workpal);			/* Get color palette	*/
  if(get_pic(fhandle,workrez,iobuf,worksc)<0)	/* Get the image 	*/
   {
   form_alert(1,badfile);
   return;
   }

  try_dump:
  if(form_alert(0,ready)==2)			/* Display ready dialog	*/
   return;
  if(dumper(0,workrez & 3,worksc,workpal,workarea)<0)	/* Init dumper	*/
   {
   if(form_alert(1,initfail)==1)
    goto try_dump;
   return;
   }
  dumper(1,workrez & 3,worksc,workpal,workarea);	/* Dump it!	*/
  }
 else
  {
  form_alert(1,cantopen);
  }
 }
}

/******************************/
/* Save driver to a .PRT file */
/******************************/

save_drv()
{
strcat(workpath,"*.PRT");
filename[0]=0;

fresult=fsel_input(workpath,filename,&fbutton);

trunname(workpath);
if(fresult>0 && fbutton==1)
 {
 strcpy(filepath,workpath);
 strcat(filepath,filename);

 fhandle=Fcreate(filepath,0);
 if(fhandle >= 0)
  {
  if(Fwrite(fhandle,2000L,&dumper)!=2000L)	/* Write dumper file	*/
   form_alert(1,badwrite);
  Fclose(fhandle);   
  }
 else
  {
  form_alert(1,cantopen);
  }
 }
}

/********************************************************/
/* Parse an ascii numeric string into an output string	*/
/*							*/
/* format:						*/
/* nparse(instring,outstring,count)			*/
/*							*/
/* instring:  string of numbers separated by commas	*/
/* outstring: string to receive parsed string		*/
/* count:     pointer to WORD to receive string length 	*/
/*							*/
/* returns -1 (error) or 1 (no error)			*/
/********************************************************/

nparse(istring,ostring,ocount)
char istring[],ostring[];
int *ocount;
{
register int ix,ox,value,flag;
static char pstr;

if(istring[0]==0)
 {
 return(-1);
 }

ox=value=flag=0;
pstr=0;
for(ix=0; ix<strlen(istring); ++ix)
 {
 if(istring[ix]==' ')
  goto next_ix;
 else
 if(istring[ix]==',')
  {
  if(pstr==',')
   return(-1);
  ostring[ox++]=(char)value;
  value=flag=0;
  }
 else
 if(istring[ix]>='0' && istring[ix]<='9')
  {
  flag=1;
  value=value*10+(int)(istring[ix]-'0');
  if(value>255 || value<0)
   return(-1);
  }
 else
  return(-1);

 next_ix:
 pstr=istring[ix];
 }

if(flag)
 ostring[ox++]=(char)value;

if(ox==0)
 return(-1);

*ocount=ox;
return(1);
}
