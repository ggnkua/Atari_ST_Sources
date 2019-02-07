
extern int i9(pc)
int pc;
{
extern int outside,winker;
extern char pname[],*name[],zline[16][8][7],crumobj[][9],curmon[][60];
char *c = curmon[pc],*z,*w = (pc == 0 ? pname : name[*(c+3)]);
int i,j,x,y,ret,quit = 0;
if(pc > 0 && pc < 4 && curmon[0][15] != 9) {
  prnt("-> %s says 'I cannot abandon you!  I will stay with you!'",w);
  return(0);
  }
if(pc > 0) {
  *(c+15) = 8;
  *(c+16) = curmon[0][16] + 1;
  return(1);
  }
if(outside) {
  x = *(c+24);
  y = *(c+25);
  for(i= -1;i < 2 ;i++) {
     if(quit)
        break;
     for(j = -1; j < 2;j++) {
        if(quit)
          break;
        if(zline[x+i][y+j][0] == 2 && i*j == 0 && (i != 0 || j != 0)) { 
           if(i == -1 ) {
              *(c+24) = 5;
              *(c+30) -= 1;
              prnt("-> %s goes west...",w);
              quit = 1;
              }
           if(i == 1) {
              *(c+24) = 1; 
              *(c+30) += 1;
              prnt("-> %s goes east...",w);
              quit = 1;
              }
           if(j == -1) {
              *(c+25) = 5;
              *(c+30) -= 5;
              prnt("-> %s goes north...",w);
              quit = 1;
              }
           if(j == 1) {
              *(c+25) = 1;
              *(c+30) += 5;
              prnt("-> %s goes south...",w);
              quit = 1;
              }
           if(quit) {
             clrinp();
             *(c+15) = 8;
             *(c+16) = 1;
             return(1);
             }
           }
         }
      }
    }
if(outside && !quit) {
   error(15);
   return(0);
   }
domsg(5);
header(w);
winker = pc+1;
sgetxy(&x,&y,0,0,0,&ret);
winker = 0;
undomsg();
clrinp();
if(!adjac(0,x,y)) {
  error(11);
  return(0);
  }
z = zline[x][y];
if(crumobj[*(z+1)][3] == 0) {
  error(15);
  return(0);
  }
*(c+7) = *(c+8) = 0;      
*(c+9) = *(z+1);
*(c+10) = crumobj[*(z+1)][3];
*(c+15) = 9;
*(c+16) = 6;
return(1);
}

extern int o9(pc)
int pc;
{
extern int crum,mode,storbuf[][130];
extern char rumdata[][157],pname[],curmon[][60],crumobj[][9],zline[16][8][7];
extern char monbuf[];
extern long int addr;
char *c = curmon[pc];
int i,x = *(c+24), y = *(c+25);
char *z = zline[x][y];
if(pc == 0 && crumobj[*(c+9)][5] == -2) {
    prnt("-> %s finds the exit is locked!",pname);
    *(c+30) = crum;
    return(1);
    }
*(z+2) = 0;
if(*(z+5) > 0 || rumdata[*(c+30)][30]) {
  xbios(37);
  storsc(storbuf[pc],16*x,16*y,1,addr);
  }
*(c+30) = *(c+10);
if(pc != 0) {
   z = zline[*(c+26)][*(c+27)];
   *(c+30) = crumobj[*(z+1)][3];
   if(mode)
      dorep();
   return(-1);
   }
if(pc == 0) {
  *(c+34) = 0;
  if(mode)
    prnt("-> %s flees!",&pname[0]);
  *(c+18) = 8;
  }
return(-1);
}

