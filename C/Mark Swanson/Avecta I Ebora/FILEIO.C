#include "osbind.h"

extern int fileio(flow)
int flow;
{
extern char putbuf[],monbuf[],crumobj[][9],curmon[][60],rumdata[][157];
extern int police,lev,new,bitmap[][65],outside,dungeon,handle,crum,pursuit[3];
extern int fromout;
extern char trigval[][6],invnpc[][20],path[],filename[],pname[],specbuf[];
extern char invtrig[];
int i,j,button,filehandle;
long int *length;
char check,*c,*r = rumdata[crum],dta[44];
vs_curaddress(handle,1,1);
v_eeos(handle);
raton();
fsel_input(path,filename,&button);
rausmaus();
vs_curaddress(handle,1,1);
v_eeos(handle);
init(1);
if(button == 0) {
   return(-2);
   }
filehandle = Fopen(filename,0);
if(flow == 2 && filehandle < 0) {
  return(-1);
  }
if(flow == 2) {
  Fsetdta(dta);
  Fsfirst(filename,0);
  length = &dta[26];
  if(*length != 14546) {
    return(-1);
    }
  }
if(flow == 1 && filehandle < 0)
  filehandle = Fcreate(filename,0);
if(filehandle < 0) {
  return(-1);
  }
if(flow == 1) {
  specbuf[26] = outside;
  specbuf[27] = curmon[0][59];
  specbuf[28] = lev;
  specbuf[29] = new;
  specbuf[34] = police;
  specbuf[37] = fromout;
  for(i=0;i<13;i++) {
    c = crumobj[i+1];
    for(j=0;j<9;j++)
      *(r+31+9*i+j) = *(c+j);
    }
  if(Fwrite(filehandle,(long)12560,rumdata) < 12560 || 
     Fwrite(filehandle,(long)320,putbuf) < 320 ||
     Fwrite(filehandle,(long)480,trigval) < 480 ||
     Fwrite(filehandle,(long)40,specbuf) < 40 ||
     Fwrite(filehandle,(long)720,curmon) < 720 ||
     Fwrite(filehandle,(long)6,pursuit) < 6  ||
     Fwrite(filehandle,(long)20,pname) < 20 ||
     Fwrite(filehandle,(long)80,invnpc) < 80 ||
     Fwrite(filehandle,(long)320,monbuf) < 320 ) {
    Fclose(filehandle);
    return(-1);
    }
  else {
    Fclose(filehandle);
    }
  }
if(flow == 2) {
  Fseek((long)13387,filehandle,0);
  Fread(filehandle,(long)1,&check);
  if(curmon[0][59] != check && dungeon != 2) {
     Fclose(filehandle);
     return(0);
     }
  else
    Fseek((long)0,filehandle,0);
  if(Fread(filehandle,(long)12560,rumdata) < 12560 || 
     Fread(filehandle,(long)320,putbuf) < 320 ||
     Fread(filehandle,(long)480,trigval) < 480 ||
     Fread(filehandle,(long)40,specbuf) < 40 ||
     Fread(filehandle,(long)720,curmon) < 720 ||
     Fread(filehandle,(long)6,pursuit) < 6  ||
     Fread(filehandle,(long)20,pname) < 20 ||
     Fread(filehandle,(long)80,invnpc) < 80 ||
     Fread(filehandle,(long)320,monbuf) < 320 ) {
     Fclose(filehandle);
     return(-1);
     }
  else {
     lev = specbuf[28] = 1;
     dungeon = specbuf[27];
     fromout = specbuf[37];
     police = specbuf[34];
     outside = specbuf[26];
     crum = curmon[0][30];
     for(i=0;i<20;i++)
         invtrig[i] = specbuf[i+1];
     Fclose(filehandle);
     if(outside || fromout) {
           specbuf[32] = 1;
           filehandle = Fopen("FILL.DAT\0",0);
           if(filehandle < 0)
              return(0);
           Fseek((long)5330,filehandle,0);
           Fread(filehandle,(long)3900,bitmap[21]);
           Fclose(filehandle);
           }
     else {
           filehandle = Fopen("GRAFX.DAT\0",0);
           if(filehandle < 0)
              return(0);
           Fread(filehandle,(long)9230,bitmap[0]);
           Fclose(filehandle);
          }            
     }
  }
return(1);
}
  
