extern int i11(pc)
int pc;
{
extern int outside,winker;
extern char zline[16][8][7],*name[],pname[],curmon[][60];
char *c = curmon[pc],*w = (pc == 0 ? pname : name[*(c+3)]);
int tar,x,y,ret;
if(outside)
  return(0);
if(*(c+45) != 45 || *(c+44) == 0) {
  error(30);
  return(0);
  }
if(*(c+46) != 0) {
  error(22);
  return(0);
  }
domsg(3);
header(w);
winker = pc+1;
sgetxy(&x,&y,0,0,0,&ret);
winker = 0;
undomsg();
tar = zline[x][y][2];
if(pc < 4 && tar < 4) {
  error(8);
  return(0);
  }  
if(!los(pc,x,y)) {
  error(3);
  return(0);
  }
*(c+7) = tar;
if(pc > 0)
  *(c+39) = tar;
*(c+8) = *(c+9) = 0;
*(c+15) = 11;
*(c+16) = 2 + *(c+11);
return(1);
}

extern int o11(pc)
int pc;
{
extern char zline[16][8][7],*name[],pname[],curmon[][60];
extern int crum;
char *c = curmon[pc],*t,*w = (pc == 0 ? pname : name[*(c+3)]),*wt;
int x,y,miss,tar,dir,i,j,k = 0,off();
tar = (pc == 0 ? *(c+7) : *(c+39) );
t = curmon[tar];
wt = (tar == 0 ? pname : name[*(t+3)]);
*(c+7) = (pc > 0 ? *(c+39) : *(c+7) );
if(*(t+30) != crum || !los(pc,*(t+24),*(t+25))) {
  prnt("-> The %s is out of %s's sight!",wt,w);
  return(1);
  }
if(rnd(100) < 10*(*(t+11)) + 5*(*(c+50) - 10) ) { 
  miss = 0;
  i = 0;
  j = 0;
  }
else {
  miss = 1;
  do {
    k++;
    i = rnd(2);
    i = (2*i - 1);
    j = rnd(2);
    j = 2*j - 1;
    } while(k < 10 && zline[*(t+24) + i][*(t+25) + j][0] == 0);
  }
nextxy(*(c+24),*(c+25),*(t+24)+i,*(t+25)+j,*(c+24),*(c+25),&x,&y);
switch(y - *(c+25)) {
   case 1:
      switch(x - *(c+24)) {
         case 1:
            dir = 3;
            break;
          case 0:
            dir = 4;
            break;
          case -1:
            dir = 5;
          }
        break;
   case 0:
      switch(x - *(c+24)) {
        case 1:
           dir = 2;
           break;
        case 0:
           dir = 8;
           break;
        case -1:
           dir = 6;
        }
      break;
   case -1:
      switch(x - *(c+24)) {
         case 1:
            dir = 1;
            break;
         case 0:
            dir = 0;
            break;
         case -1:
            dir = 7;
         }
      break;
   }
dir /= 2;
xbios(37);
xbios(38,off);
fireball(*(c+24),*(c+25),*(t+24)+i,*(t+25)+j,3+dir);
explode(*(t+24)+i,*(t+25)+j,3+dir);
if(!miss && (*(c+43) || (tar > 3 && !*(t+46)) || tar < 3) ) {
   prnt("-> %s's arrow hits the %s!",w,wt);
   miss = 5 + rnd(*(c+50));
   damage(tar,miss);
   return(1);
   }
prnt("-> %s's arrow misses the %s!",w,wt);
return(1);
}
