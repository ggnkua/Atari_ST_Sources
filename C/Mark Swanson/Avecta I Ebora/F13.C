extern int i13(pc)
int pc;
{
extern int outside,winker;
extern char curmon[][60],zline[16][8][7],pname[],*name[];
char *c = curmon[pc],*w = (pc == 0 ? pname : name[*(c+3)]);
int x,y,ret,tar;
if(outside)
  return(0);
if(*(c+45) == 0) {
   error(27);
   return(0);
   }
domsg(3);
header(w);
winker = pc + 1;
sgetxy(&x,&y,0,0,0,&ret);
undomsg();
winker = 0;
tar = zline[x][y][2];
if(!los(pc,x,y)) {
  error(3);
  return(0);
  }
if( (tar == 0 && (curmon[0][24] != x || curmon[0][25] != y)) || tar > 3) {
  error(8);
  return(0);
  }
*(c+7) = tar;
*(c+8) = *(c+9) = 0;
*(c+15) = 13;
*(c+16) = *(c+11);
return(1);
}

extern int o13(pc)
int pc;
{
extern int crum;
extern char rumdata[][157],curmon[][60],zline[16][8][7],pname[],*obj[],*name[];
extern char crumobj[][9];
char *c = curmon[pc],*t,*wt,*z,*w = (pc == 0 ? pname : name[*(c+3)]);
int tar = *(c+7),x,y,d,miss,i,j,k;
t = curmon[tar];
x = *(t+24);
y = *(t+25);
d = dist(*(c+24),*(c+25),0,x,y,0);
wt = (tar == 0 ? pname : name[*(t+3)]);
if(!los(pc,x,y)) {
   prnt("-> %s cannot see %s to give the %s!",w,wt,obj[*(c+45)]);
   return(1);
   }
if(!adjac(pc,x,y)) { /* gotta throw the damned thing */
  miss = 0;
  if(rnd(100) > 5*(*(c+50)) - 5*d )
    miss = 1;
  i = j = k = 0;
  if(miss || zline[x][y][1] != 0) {
     do {
        k++;
        i = 2 - rnd(5);
        j = 2 - rnd(5);
        } while(k < 20 && (zline[x+i][y+j][1] != 0 || zline[x+i][y+j][0] != 1));
      }
   if(k == 20) {
     prnt("-> %s cannot spot a place to which to throw the %s!",w,obj[*(c+45)]);
     return(1);
     }    
   prnt("-> %s throws the %s to %s!",w,obj[*(c+45)],wt);
   k = rumslot();
   z = crumobj[k];
   if(k > 13) { 
     storobj(*(c+45),x+i,y+j);
     rumdata[crum][134+k] = *(c+45);
     }
   *z = *(c+45);
   *(z+1) = 1;
   *(z+6) = x+i;
   *(z+7) = y+j;
   *(z+4) = *(c+45);
   *(z+5) = -1;
   *(z+8) = 1;
   *(z+2) = *(z+3) = 0;
   *(c+45) = 0;
   zline[x+i][y+j][1] = k;
   if(rumdata[crum][30] || zline[x+i][y+j][5] > 0)
      drawsq(x+i,y+j);
   return(1);
   }
prnt("-> %s gives the %s to %s.",w,obj[*(c+45)],wt);
if(*(t+45) != 0)
  putaway(tar,*(t+45));
*(c+8) = *(c+45);
*(t+45) = *(c+45);
if(*(t+45) == 45) {
  *(t+44) = *(c+44);
  *(c+44) = 0;
  }
if(*(t+32) == 0 && *(t+45) < 46 && *(t+45) > 40 )
  *(t+32) = *(t+45);
*(c+45) = 0;
return(1);
}
