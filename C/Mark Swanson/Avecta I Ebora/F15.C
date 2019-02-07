extern int i15(pc)
int pc;
{
extern int outside,winker;
extern char zline[16][8][7],curmon[][60],pname[];
int x,y,ret,tar;
char *c = curmon[pc];
if(outside)
  return(0);
if(pc > 0)
  return(0);
clrinp();
domsg(3);
header(pname);
winker = pc+1;
sgetxy(&x,&y,0,0,0,&ret);
undomsg();
winker = 0;
tar = zline[x][y][2];
if(tar == 0 || tar > 3) {
   error(8);
   return(0);
   }
if(!los(pc,x,y)) {
   error(3);
   return(0);
   }
*(c+7) = tar;
*(c+15) = 15;
*(c+16) = 1;
return(1);
}

extern int o15(pc)
int pc;
{
extern char curmon[][60],pname[],*name[];
int act;
char *c = curmon[curmon[pc][7]];
curmon[pc][8] = curmon[pc][9] = 0;
if(*(c+38)) {
   *(c+38) = 0;
   prnt("-> %s allows %s to make decisions!",pname,name[*(c+3)]);
   return(1);
   }
prnt("-> %s issues orders to %s!",pname,name[*(c+3)]);
if(*(c+16) != 0) {
  *(c+15) = 8;
  *(c+16) = 1;
  }
*(c+38) = 1;
return(1);
}
