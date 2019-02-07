#include "osbind.h"

extern int title()
{
extern int handle,newpal[];
int i,j,k,rgb[3];
vs_curaddress(handle,1,1);
v_eeos(handle);
rgb[0] = rgb[1] = rgb[2] = 0;
vs_color(handle,0,rgb);
xbios(37);
prntbig(" AVECTA I",4,1);
prntbig(" -EBORA-",4,5);
vst_color(handle,2);
v_justified(handle,60,140,"Copyright Mark Swanson",16,0,0);
v_justified(handle,6,180,"Select option: (Q)uit,(N)ew,(R)estore",31,0,0);
do {
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
   i = Bconin(2);
   i = (i < 97 ? i+32 : i);
   } while (i != 114 && i != 110 && i != 113);
vs_curaddress(handle,1,1);
v_eeos(handle);
Setpallete(newpal);
i = ( i>110 ? 2*(i-113) : 1); 
return(i);
}

int prntbig(s,x,y)
char s[];
int x,y;
{
extern int textbig(),handle;
int i=0;
x = 16*x;
y = 16*y;
while(s[i] != '\0') {
  textbig(s[i],x,y);
  x += 16;
  i++;
  if(x >= 310) {
    x = 0;
    y += 6;
    }
  }
}

