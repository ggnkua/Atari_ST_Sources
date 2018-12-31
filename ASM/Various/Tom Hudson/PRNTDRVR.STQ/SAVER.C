
/*******************************************/
/*      DEGAS(TM) Printer Driver Saver     */
/*          Written by Tom Hudson          */
/*     Copyright 1986, ANTIC Publishing    */
/*         Freeware, not to be sold        */
/*                                         */
/*  Link with DEGAS printer driver object  */
/*  file and execute, specifying the name  */
/*  of the printer driver file (be sure    */
/*  to use a .PRT extension for the file!  */
/*******************************************/

#include <osbind.h>

extern dumper();        /* The printer driver code                          */
                        /* Be sure to use the label _dumper in your printer */
                        /* driver before the first instruction!             */

int contrl[13];         /* Standard GEM bindings        */
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];

/*********************************************/
/*   Our miscellaneous form_alert strings    */
/*********************************************/

char saveOK[] =
   "[1][ |Printer driver written!| ][ OK ]";

char cantopen[] =
   "[3][ |Can't open driver file!| ][ Sorry ]";

char wrterr[] =
   "[3][ |Error writing file!| ][ Sorry ]";

/*****************************************/
/*       Start of file write code        */
/*****************************************/

main()
{
int handle,fresult,fbutton;
long bcount;
char defpath[64],workpath[80],filename[20];

/*********************************************/
/* Initialize the application                */
/*********************************************/

appl_init();

/*********************************************/
/* Build a pathname with a .PRT extension    */
/*********************************************/

defpath[0] = Dgetdrv() + 'A';
defpath[1] = ':';
Dgetpath(&defpath[2], 0);
strcpy(workpath,defpath);
strcat(workpath,"\\*.PRT");
filename[0]=0;

/*********************************************/
/* Use file selector to get the driver name  */
/*********************************************/

fresult=fsel_input(workpath,filename,&fbutton);

/*********************************************/
/* If filename was entered, write the file!  */
/*********************************************/

if(fresult>0 && fbutton==1)
 {
 trunname(workpath);
 strcat(workpath,filename);

/*********************************************/
/*  Attempt to save the printer driver file  */
/*********************************************/

 handle = Fcreate(workpath,0);
 if (handle >= 0)
  {
  bcount=Fwrite(handle,2000L,&dumper);
  Fclose(handle);
  if(bcount<2000L)
   form_alert(1,wrterr);
  else
   form_alert(1,saveOK);
  }
 else
  {
  form_alert(1,cantopen);
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
/*              End of program!              */
/*********************************************/

