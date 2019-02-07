#include "osbind.h"

extern int load()

{
extern int fillpic[][65],bitmap[][65];
extern char fname[],savname[],rumdata[][157];
extern char putbuf[],trigval[][6],specbuf[];
long int offset = 0,count = 26000;
int fhandle,mode = 0;
fhandle = Fopen(fname,mode);
if(fhandle < 0)
  return(0);
Fread(fhandle,count,bitmap[0]);
Fclose(fhandle);
fhandle = Fopen("FILL.DAT\0",0);
if(fhandle < 0)
   return(0);
Fread(fhandle,(long)5200,fillpic);
Fclose(fhandle);
fhandle = Fopen(savname,mode);
if(fhandle < 0)
  return(0);
Fread(fhandle,count = 12560,rumdata);
Fread(fhandle,(long)320,putbuf);
Fread(fhandle,(long)480,trigval);
Fread(fhandle,(long)40,specbuf);
Fclose(fhandle);
return(1);
}

