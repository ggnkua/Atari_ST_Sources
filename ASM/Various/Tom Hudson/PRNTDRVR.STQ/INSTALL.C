
/********************************************/
/*    DEGAS(TM) Printer Driver Installer    */
/*          Written by Tom Hudson           */
/*      Copyright 1986, ANTIC Publishing    */
/*         Freeware, not to be sold         */
/*                                          */
/*    Installs a DEGAS printer driver as    */
/*    the default screen dump routine.      */
/*    ---> NOTE: Link with INSTALL.S <---   */
/********************************************/

#include <osbind.h>

#define HORIZONTAL 0
#define VERTICAL 8

extern scrdump();       /* The printer driver code */

extern int gl_apid;     /* ID of our accessory     */

int contrl[13];         /* Idiotic bindings        */
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];

int fresult,fbutton,mexit,prtmode;
long bcount;

char menuname[] = "  Printer Driver";   /* Name in desk menu   */

/*********************************************/
/*   Our miscellaneous form_alert strings    */
/*********************************************/

char intro[] =
   "[1][DEGAS\277 Printer Installer|by Tom Hudson| |\275 1986 ANTIC Publishing|Version 1.0][Horizontal| Vertical ]";

char instOK[] =
   "[1][Printer driver installed][ OK ]";

char cantopen[] =
   "[3][ |Can't open driver file!| ][ Sorry ]";

char notpd[] =
   "[3][ |That is not a printer driver!| ][ Sorry ]";

/*********************************************/
/*       Start of desk accessory code        */
/*********************************************/

main()
{
register int i,j,handle;
int  menuID1,mgbuf[8];
char defpath[64],workpath[80],filename[20];

/*********************************************/
/* Initialize the desk accessory application */
/*********************************************/

appl_init();

/*********************************************/
/* Install our accessory name in menu bar    */
/*********************************************/

menuID1 = menu_register(gl_apid, menuname);

/*********************************************/
/* Loop forever looking for startup call     */
/*********************************************/

for (;;)
 {
 evnt_mesag(mgbuf);   /* Wait on a message event   */

/*********************************************/
/*           We are being called!            */
/*********************************************/

 if (mgbuf[0] == 40  && mgbuf[4] == menuID1) 
  {
  for (;;)
   {

/*********************************************/
/*      Display configuration alert box      */
/*  prtmode sets either normal (horizontal)  */
/*  or Alternate (vertical) modes.           */
/*********************************************/

   mexit=form_alert(2,intro);
   if(mexit == 1)
    prtmode=HORIZONTAL;
   else
    prtmode=VERTICAL;

/*********************************************/
/*    Build pathname with *.PRT extension    */
/*********************************************/

   defpath[0] = Dgetdrv() + 'A';
   defpath[1] = ':';
   Dgetpath(&defpath[2], 0);
   strcpy(workpath,defpath);
   strcat(workpath,"*.PRT");
   filename[0]=0;

/*********************************************/
/* Use file selector to get the driver file  */
/*********************************************/

   fresult=fsel_input(workpath,filename,&fbutton);

/*********************************************/
/*     If file was selected, grab info!      */
/*********************************************/

   if(fresult>0 && fbutton==1)
    {
    trunname(workpath);
    strcat(workpath,filename);

/*********************************************/
/*  Attempt to load the printer driver file  */
/*********************************************/

    handle = Fopen(workpath,0);
    if (handle >= 0)
     {
     bcount=Fread(handle,2000L,&scrdump);
     Fclose(handle);

/*********************************************/
/*  A driver file must be 2000 bytes long!   */
/*********************************************/

     if(bcount!=2000L)
      {
      form_alert(1,notpd);
      break;
      }

/*********************************************/
/*   Install the driver, everything's GO!    */
/*********************************************/

     install();
     form_alert(1,instOK);
     break;
     }
    else

/*********************************************/
/*         Can't open the file, pal!         */
/*********************************************/

     {
     form_alert(1,cantopen);
     break;
     }
    }
   else
    {
    break;
    }
   }
  }
 }
}

/*********************************************/
/*    General-utility string concatenator    */
/*********************************************/

strcat(to,from)
char *to,*from;
{
while (*to) ++to;
while (*to++ = *from++);
}

/*********************************************/
/*       General-purpose string copier       */
/*********************************************/

strcpy(to,from)
char *to,*from;
{
while (*to++ = *from++);
}

/*********************************************/
/*    General-purpose string length test     */
/*********************************************/

strlen(string)
char *string;
{
register int ix;

for (ix=0; *string++; ++ix);
return ix;
}

/*********************************************/
/*       Strip off *.PRT from pathname       */
/*********************************************/

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

/*********************************************/
/* Our code which replaces the system dumper */
/*********************************************/

dumpctrl()
{
int ix,rez,result;
static int palette[16];
static char *screen,workarea[1280];

/*********************************************/
/*  Grab screen resolution and base address  */
/*********************************************/

rez=Getrez();
screen=Physbase();

/*********************************************/
/*       Grab the system color palette       */
/*********************************************/

for(ix=0; ix<16; ++ix)
 palette[ix]=Setcolor(ix,-1);

/*********************************************/
/*    Force monochrome palette to 000/777    */
/*********************************************/

if(rez==2)
 {
 if(palette[0] & 0x0001)
  {
  palette[0]=0x0777;
  palette[1]=0x0000;
  }
 else
  {
  palette[0]=0x0000;
  palette[1]=0x0777;
  }
 }

/*********************************************/
/*    Force alternate key mode to prtmode    */
/*********************************************/

Getshift(prtmode);

/*********************************************/
/*  Initialize screen dumper code & printer  */
/*********************************************/

result=scrdump(0,rez,screen,palette,workarea);

/*********************************************/
/* Dump the screen if initialization was OK  */
/*********************************************/

if(result)
 scrdump(1,rez,screen,palette,workarea);

/*********************************************/
/*    Return Alternate key mode to normal    */
/*********************************************/

Getshift(0);
}

/*********************************************/
/*              End of program!              */
/*********************************************/

