/******************************/
/* DEGAS Elite Test Accessory */
/*       by Tom Hudson        */
/*    for START Magazine      */
/******************************/

#include <osbind.h>

/**********************/
/* EXTERNALS	      */
/**********************/

extern int gl_apid;

/**********************/
/* GLOBAL VARIABLES   */
/**********************/

int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];

char no_DEGAS[] = 
"[1][ |DEGAS Elite is not resident!| ][ Sorry ]";

/* Test color palette -- loaded into Elite */

int colors[16]=
{
0x0000,0x0100,0x0200,0x0300,0x0400,0x0500,0x0600,0x0700,
0x0000,0x0001,0x0002,0x0003,0x0004,0x0005,0x0006,0x0007
};

int DE_id,menu_id;
int mgin[8],mgout[8];
int forever=1,slots,dum,event;
long *screens;

/**************************************************************/
/* Init accessory, store accessory title in system's menu bar */
/* then wait for a message using evnt_mesag().  When we get   */
/* an open (message type 40), we ask DEGAS Elite for various  */
/* information, then do our thing.  If DEGAS Elite is not     */
/* running, the accessory goes to sleep until called again    */
/* by waiting for another evnt_mesag.                         */
/**************************************************************/

main()
{
appl_init();

menu_id=menu_register(gl_apid,"  Elite-comm");
 
while(forever)
 {
 evnt_mesag(mgin);
 if(mgin[0]==40 && mgin[4]==menu_id)
  {
  DE_id=appl_find("DEGELITE");
  if(DE_id<0)
   form_alert(1,no_DEGAS);
  else
   {

/* Make sure Elite's REALLY there */

   mgout[0]=0xDE00;
   mgout[1]=gl_apid;
   mgout[2]=0;
   appl_write(DE_id,16,mgout);

   is_there:
   event=evnt_multi(0x0030,
		    -1,-1,-1,
		    0,0,0,0,0,
		    0,0,0,0,0,
		    mgin,
		    2000,0,	/* 2000 ms */
		    &dum,&dum,&dum,&dum,&dum,&dum);

/* If timer event, DEGAS Elite isn't there, otherwise, look for reply msg */

   if(event & 0x0020)
    form_alert(1,no_DEGAS);	/* Timer timed out -- no Elite! */
   else
    {
    if(mgin[0]==0xDE80)
     do_test();		/* Got reply -- Elite's there! */
    else
     goto is_there;	/* Keep waiting until timer event happens */
    }
   }
  }
 }
}

do_test()
{
register int ix;

/* Print out DEGAS Elite ID */

lprint("Elite ID:");
prt_i(DE_id);

/******************** screen addresses ********************/

lprint("Requesting Screen Addresses");
mgout[0]=0xDE00;
mgout[1]=gl_apid;
mgout[2]=0;
appl_write(DE_id,16,mgout);

/* Wait for reply message */

do
 {
 evnt_mesag(mgin);
 }
 while(mgin[0] != 0xDE80);

/* Print out results */

screens=(long *)(((long)mgin[3]<<16) | (((long)mgin[4]) & 0x0000ffffL));
slots=mgin[5];

lprint("Got Screen Pointers:");
lprint("# of slots:");
prt_i(slots);

lprint("Screens:");
for(ix=0; ix<slots; ++ix)
 {
 if(screens[ix]==0L)
  lprint("* UNUSED *");
 else
  prt_l(screens[ix]);  
 }

/****************** Screen buffer number ******************/

lprint("Requesting Screen Number");
mgout[0]=0xDE01;
mgout[1]=gl_apid;
mgout[2]=0;
appl_write(DE_id,16,mgout);

/* Wait for reply message */

do
 {
 evnt_mesag(mgin);
 }
 while(mgin[0] != 0xDE81);

/* Print out results */

lprint("Got Screen Number:");
prt_i(mgin[3]);

/****************** Get block parameters ******************/

lprint("Requesting Block Parameters");
mgout[0]=0xDE02;
mgout[1]=gl_apid;
mgout[2]=0;
appl_write(DE_id,16,mgout);

/* Wait for reply message */

do
 {
 evnt_mesag(mgin);
 }
 while(mgin[0] != 0xDE82);

/* Print out results */

lprint("Got Block Parameters:");
lprint("Screen index:");
prt_i(mgin[3]);
lprint("X coord:");
prt_i(mgin[4]);
lprint("Y coord:");
prt_i(mgin[5]);
lprint("Width:");
prt_i(mgin[6]);
lprint("Height:");
prt_i(mgin[7]);

/****************** Set block parameters ******************/

lprint("Altering Block Parameters");
mgout[0]=0xDE03;
mgout[1]=gl_apid;
mgout[2]=0;
mgout[3]=70;	/* Set width to 70 pixels */
mgout[4]=90;	/* Set height to 90 pixels */
appl_write(DE_id,16,mgout);

/* No reply! */

/******************** Set color palette *******************/

lprint("Altering Colors");
mgout[0]=0xDE04;
mgout[1]=gl_apid;
mgout[2]=32;	/* NOTE: Extra bytes in msg! */
mgout[3]=1;	/* Use palette for picture   */
appl_write(DE_id,16,mgout);	/* Write part 1 */
appl_write(DE_id,32,colors);	/* Write part 2 */

/* No reply! */
}

/****************************************************************/
/* This routine converts a LONG variable into a string.  Custom */
/* written for this accessory, it works with numbers up to      */
/* 9,999,999.  Pass the long value and the string which is to   */
/* receive the ASCII value.                                     */
/****************************************************************/

longasc(value,string)
long value;
char *string;
{
long divfac,subfac;
char *index,digit;

index=string;
for(divfac=1000000L; divfac>0; ++index,divfac/=10L)
 {
 digit=value/divfac;
 value=value-digit*divfac;
 *index=digit+48;
 }
}

/***************************/
/* Print string to printer */
/***************************/

lprint(string)
char *string;
{
int ix,retries;
static char prn_off[] =
"[3][Your printer is not ready to|receive data.  Ready the|printer before\
 retrying.][Retry|Cancel]";

retries=0;

retry_it:
for(retries=0; retries<27000; ++retries)
 {
 if(Bcostat(0)!=0)
  goto do_lpt;
 }
if(form_alert(1,prn_off)!=1)
 return;
else
 goto retry_it;

do_lpt:
while(*string)
 {
 ix= *string++;
 Bconout(0,ix);
 }
Bconout(0,13);
Bconout(0,10);
}

/***************************************/
/* Simple integer-to-ascii converter   */
/*				       */
/* Parameters:			       */
/* num: integer value to convert       */
/* string: target string	       */
/* count: number of digits to show     */
/* negch: ascii value of negative sign */
/* posch: ascii value of positive sign */
/***************************************/

iset(num,string,count,negch,posch)
int num,count,negch,posch;
char *string;
{
int divfac,dct,ix,jx,kx;

if(num<0)
 {
 num = -num;
 string[0]=negch;
 }
else
 string[0]=posch;

for(ix=0,jx=4,kx=1,divfac=10000; ix<5; ++ix,--jx,divfac=divfac/10)
 {
 dct=num/divfac;
 if(jx<count)
  string[kx++]=48+dct;
 num=num-dct*divfac;
 }
string[kx++]=0;
}

/********************************/
/* Simple integer print routine */
/********************************/

prt_i(value)
int value;
{
static char string[] = "99999";

iset(value,string,5,45,32);
lprint(string);
}

/*****************************/
/* Simple long print routine */
/*****************************/

prt_l(value)
long value;
{
static char string[] = "9999999   ";

longasc(value,string);
lprint(string);
}
