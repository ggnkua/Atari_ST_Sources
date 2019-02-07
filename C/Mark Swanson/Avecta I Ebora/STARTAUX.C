#include "osbind.h"



extern int domsg(i)
int i;
{
extern int handle,vbl(),off();
extern char *com[];
int x = 256,y = 8,w = 64,h = 40;
int pxy[10];
char scratch[10];
top(2);
pxy[0] = 256;
pxy[1] = 8;
pxy[2] = 319;
pxy[3] = 8;
pxy[4] = 319;
pxy[5] = 48;
pxy[6] = 256;
pxy[7] = 48;
pxy[8] = 256;
pxy[9] = 8;
xbios(37);
xbios(38,off);
form_dial(0,0,0,0,0,x,y,w,h);
form_dial(1,0,0,0,0,x,y,w,h);
v_pline(handle,5,pxy);
textsix(1,259,17,7,"  Point");
textsix(1,259,25,8,"  at the");
sprintf(scratch,"%s",com[i]);
textsix(1,259,33,strlen(scratch),scratch);
xbios(37);
xbios(38,vbl);
}


extern int undomsg()
{
extern int handle,vbl(),off(),i;
int x = 255,y = 0,w = 64,h = 40;
xbios(37);
xbios(38,off);
form_dial(2,0,0,0,0,x,y,w,h);
top(1);
clrinp();
xbios(37);
xbios(38,vbl);
}

extern int init(flag)
int flag;
{
extern int hold,usedline,col,dungeon,outside,row,handle,crum,pursuit[3];
extern char pname[],curmon[][60],invnpc[][20];
int i,j;
char str[15],*c,val[3];
vs_curaddress(handle,1,1);
v_eeos(handle);
row=17;
if(flag == 1) {
  texwin();
  return(1);
  }
dungeon = 2;
outside = 0;
for(i=4;i<12;i++) {
  c = curmon[i];
  for(j=0;j<60;j++)
    *(c+j) = 0;
  }
for(i=0;i<3;pursuit[i++] = 0);  
c = curmon[0];
crum = -1;
*c = 1;
*(c+46) = *(c+45) = 
   *(c+31) = *(c+32) = *(c+33) = *(c+34) = *(c+35) = *(c+1) = 0;
*(c+59) = 2;
*(c+42) = 20;
*(c+41) = 0;
*(c+32) = 2;
*(c+33) = 4;
*(c+4) = 81;
for(j=0;j<4;j++) {
  for(i=0;i<20;i++) 
     invnpc[j][i] = 0;
  }
invnpc[0][0] = 1;
invnpc[0][2] = 42;
*(c+44) = 50;
*(c+47) = 0;
*(c+49) = 50;
if(flag == 2) {
  *(c+14) = 6*(*(c+51));
  texwin();
  return(1);
  }
val[0] = 10;
val[1] = 3;
val[2] = 1;
*(c+37) = 5 + 20*val[2];
*(c+50) = 3 + 2*val[1];
*(c+14) = 6*val[0];
*(c+51) = val[0];
*(c+2) = 50;
*(c+11) = 4;
texwin();
usedline = hold = 0;
return(0);
}

extern int ruminit()
{
extern int oldpal[];
extern char rumdata[][157],curmon[][60];
int i;
char *c = curmon[1];
for(i=0;i<660;*(c+(i++)) = 0);
if(!loadnew()) {
   raton();
   Setpallete(oldpal);
   xbios(37);
   form_alert(1,"[1][There are data files missing!][OK]");
   rausmaus();
   return(1);
   }
return(0);
}

extern int error(i)
int i;
{
extern char *errmsg[];
extern int vbl(),off();
xbios(37);
xbios(38,off);
raton();
i = form_alert(1,errmsg[i]);
rausmaus();
xbios(37);
xbios(38,vbl);
return(i);
}


int savpal()
{
extern int oldpal[];
int *j;
int i;
j = 16745024;
for(i=0;i<16;i++)
  oldpal[i] = *(j+i);
}

extern int console()
{
extern char curmon[][60],specbuf[];
extern int crum,dungeon,new,police,handle,newpal[];
int i;
char *c = curmon[0];
for(i=1;i<17;i++) {
  vs_curaddress(handle,i,1);
  v_eeol(handle);
  }
for(i=17;i<26;i++) {
  vs_curaddress(handle,i,31);
  v_eeol(handle);
  }
for(i=17;i<26;i++) {
  vs_curaddress(handle,i,1);
  printf(" ");
  }
vsf_interior(handle,1);
vsf_color(handle,2);
v_contourfill(handle,300,10,-1);
raton();
if(dungeon == 2 && police) {
  form_alert(1,"[1][\
The blond man murmurs |\
   `Unworthy soul!    |\
   No resurrection!   |\
 You violate the law!'][Death!]");
  return(0);
  }
new = 0;
loadnew();
new = 1;
*(c+30) = 29;
form_alert(1,"[1][\
 The blond man murmurs  |\
 `Resurrection again... |\
 My strength fails me...|\
Such a great distance...|\
  So little time.' ]\
[ Once more ]");
specbuf[28] = 1;
rausmaus();
Setpallete(newpal);
xbios(37);
init(2);
return(3);
}

extern int congratulate()
{
extern int handle,off();
extern char pname[];
int i,rgb[3];
xbios(37);
xbios(38,off);
vs_curaddress(handle,1,1);
v_eeos(handle);
vs_curaddress(handle,5,1);
printf("\n%s appears in the peaceful",&pname[0]);
printf("\ncountryside around the abbey's entrance."); 
printf("\nBirds sing again, the sun shines, and");
printf("\nthe air seems so clean and fresh.");
printf("\nIt's as if the whole world is ");
printf("\ncelebrating %s's great...",pname);
printf("\n");
printf("\n[More...]");
Bconin(2);
vs_curaddress(handle,1,1);
v_eeos(handle);
rgb[0] = rgb[1] = rgb[2] = 0;
vs_color(handle,0,rgb);
xbios(37);
prntbig("VICTORY OVER",4,1);
prntbig(" MELKTHROP!",4,5);
do {
      rgb[0] = Random();
      rgb[1] = Random();
      rgb[2] = Random();
      rgb[0] %= 1000;
      rgb[1] %= 1000;
      rgb[2] %= 1000;  
      vs_color(handle,2,rgb);
      i = Bconstat(2);
      } while(i == 0);
xbios(37);
}


extern int loadnew()
{
extern int lev,police,new;
extern int crum,bitmap[][65],fillpic[][65],winroom,dismax,dungeon;
extern char rumdata[][157],putbuf[],monbuf[],trigval[][6],specbuf[];
extern char selllist[][4],invtrig[],curmon[][60],*savname[];
char *c = curmon[0];
int fhandle,i,j,old,d1=0,d2=0,d3=0,flag = 0;
old = dungeon;
if(new == 0) {
  if(specbuf[32])
    flag = 1;
  police = 0;
  *(c+55) = 53;
  *(c+56) = 3;
  *(c+57) = 3;
  *(c+59) = 2;
  for(i=0;i<4;selllist[i++][3] = 0);
  for(i=1;i<320;i += 4) {
    if(old == 2 && !flag && lev > 0 && monbuf[i] == 112)
      continue;
    for(j=0;j<4;monbuf[i + (j++)] = 0);
    }
  specbuf[31] = specbuf[32] = specbuf[33] = 0;
  specbuf[27] = 2;
  if(flag)
     lev = 1;
  else
     lev = 0;
  }
else
  lev = 1;
if(dungeon != 0 && new != 0) {
  specbuf[30+dungeon] = 1;  /* gotta set the dirty flag on that dungeon */
  fhandle = Fopen(savname[dungeon + 3*specbuf[30 + dungeon]],0);
  if(fhandle < 0) 
     fhandle = Fcreate(savname[dungeon+3*specbuf[30+dungeon]],0);
  if(fhandle < 0)
     return(0);
  if(Fwrite(fhandle,(long)12560,rumdata) < 12560 ||
     Fwrite(fhandle,(long)320,putbuf) < 320 ||
     Fwrite(fhandle,(long)480,trigval) < 480 ||
     Fwrite(fhandle,(long)40,specbuf) < 40 ||
     Fwrite(fhandle,(long)320,monbuf) < 320) {
         Fclose(fhandle);
         return(0);
     }
  Fclose(fhandle);
  }
dungeon = *(c+59);
fhandle = Fopen("GRAFX.DAT\0",0);
if(fhandle < 0)
    return(0);
Fread(fhandle,(long)26000,bitmap[0]);
Fclose(fhandle);
fhandle = Fopen("FILL.DAT\0",0);
if(fhandle < 0)
    return(0);
Fread(fhandle,(long)5330,fillpic);
if(dungeon == 0) {
  *(c+4) = 125;
  if(*(c+47) > 0 && *(c+14) > 0)
    *(c+47) = 0;
  *(c+41) = 0;
  Fseek((long)5330,fhandle,0);
  Fread(fhandle,(long)5200,bitmap[21]);
  }
else
  *(c+4) = 81;
Fclose(fhandle);
if(dungeon != 0)
  fhandle = Fopen(savname[dungeon + 3*specbuf[30 + dungeon]],0);
else
  fhandle = Fopen(savname[0],0);
if(fhandle < 0)
    return(0);
d1 = specbuf[31];
d2 = specbuf[32];
d3 = specbuf[33];
Fread(fhandle,(long)12560,rumdata); 
Fread(fhandle,(long)320,putbuf);
Fread(fhandle,(long)480,trigval);
Fread(fhandle,(long)40,specbuf);
if(dungeon != 0 && specbuf[30 + dungeon])
  Fread(fhandle,(long)320,monbuf);
else {
   if(new || dungeon == 0)
     for(i=0;i<320;monbuf[i++] = 0);
   }
if(flag) { /* got killed outside of kilkaney */
   monbuf[1] = 112;
   monbuf[2] = 30;
   monbuf[4] = 38;
   }
Fclose(fhandle);
dismax = specbuf[21];
*(c+24) = specbuf[22];
*(c+25) = specbuf[23];
winroom = specbuf[24];
*(c+30) = specbuf[25];
police = specbuf[34];
specbuf[31] = d1;
specbuf[32] = d2;
specbuf[33] = d3;
if(old != 0 && new == 1)
  specbuf[30+old] = 1;  /* inform this dungeon the old one is dirty */
if(new == 0 && lev != 0 ) {
  *(c+24) = 6;
  *(c+25) = 3;
  lev = specbuf[28] = 1;
  }
for(i=1;i<4;i++) {
  if(curmon[i][0] == 1) 
    curmon[i][30] = -2;
  }
for(i=4;i<12;i++) {
  c = curmon[i];
  for(j=0;j<60;j++)
    *(c+j) = 0;
  }
for(i=0;i<20;i++)
  invtrig[i] = specbuf[i+1];
crum = -1;
return(1);
}  
