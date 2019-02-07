extern int i6(pc)
int pc;
{
extern int outside;
extern char curmon[][60];
char *c = curmon[pc];
if(outside)
  return(0);
*(c+16) = 6;
*(c+15) = 6;
*(c+7) = *(c+8) = *(c+9) = 0;      
return(1);
}

extern int o6(pc)
int pc;
{
extern char *name[],crumobj[14][9],zline[16][8][7],curmon[][60],pname[],*obj[];
extern char rumdata[][157],putbuf[];
extern int crum,mode,bitmap[][65];
extern long int addr;
char *c  = curmon[pc],*z,*o,*w = ( pc == 0 ? &pname[0] : name[*(c+3)]);
char *r = putbuf;
int x = *(c+24), y = *(c+25);
int i,j,k,l,m = 0,num = 0,flag;
*(c+7) = *(c+8) = *(c+9) = 0;
if(pc == 0 && *(c+18) != 6) {
   prnt("-> %s searches nearby...",w);
   }
for(i = -1;i < 2; i++) {
  for(j = -1; j < 2; j++) {
    z = zline[x+i][y+j];
    if( x+i < 0 || x+i > 15 || y+j < 0 || y+j > 7 || *z == 0 || (x+i == *(c+24)
         && y+j == *(c+25)) )
       continue;
    if( *(z+1) != 0 && crumobj[*(z+1)][5] > 0 ) {
      o = crumobj[*(z+1)];
      flag = 0;
      while(m < 320) {
       if(*(r+m+3) != crum || *(r+m+2) != *(z+1)) {
          m += 4;
          continue;
          }
       flag++;          
       k = *(r+m+1);
       if(pc != 3 || *(c+38) == 1)
         prnt("-> %s discovers a %s in the %s!",w,obj[k],obj[*o]);
       *(c+18) = 0;
       num++;
       if( pc == 3 || ( (pc != 3 || *(c+38) == 1) && error(16) == 1) ) {
         flag--;
         if(!handman(pc,0,k,0)) 
            return(1);
          l = (*(c+45) == 0 ? 0 : 1);
          *(c+45+l) = k;
          invtrap(k);
          remove(*(z+1),k);
          *(c+15) = 7;
          *(c+8) = k;
          *(c+10) = 0;
          prnt("-> %s breaks off the search to take the %s.",w,obj[k]);
          return(1);
          }
       m += 4;
       }
      if(flag == 0)
         crumobj[*(z+1)][5] = 0;
      }
    if(*(z+1) != 0 && crumobj[*(z+1)][5] == -2 && *(c+18) != 6) 
       prnt("-> %s notices the %s is locked!",w,obj[crumobj[*(z+1)][0]]);
    for(k=1;k<17;k++) {
        o = crumobj[k];
        if(*o != 0 && *(c+37) > rnd(100) && *(o+8) == 0 && 
           *(o+6) == x+i && *(o+7) == y+j ) {
          *(o+8) = 1;
          prnt("-> %s discovers a hidden %s!",w,obj[*o]);
          *(c+18) = 0;
          if(rumdata[crum][30] || zline[x+i][y+j][5] > 0)
             blt(bitmap[*o],16*(x+i),16*(y+j),addr);
          *(z+1) = k;
          if(*(o+3) != 0)
           *z = 2;
          num++;
          }
        }
    }
  }          
if(num == 0 && *(c+18) != 6 && (pc != 3 || *(c+38) == 1) ) {
  prnt("-> %s discovers nothing.",w);
  *(c+18) = 6;
  }
return(1);
}

