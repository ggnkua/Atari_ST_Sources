extern int damage(pc,level)
int pc,level;
{
extern char rumdata[][157],pname[],*name[],curmon[][60],zline[16][8][7];
extern int mode,combat,handle,crum,vbl(),off(),bitmap[][65],storbuf[][130];
extern int police,dungeon;
extern long int addr;
extern char *mod[],crumobj[][9],invnpc[][20],*wordmod[],specbuf[];
char *c = curmon[pc],scratch[4],*z,*z1,*w = (pc == 0 ? pname : name[*(c+3)]);
int newpolice = 1,flag,old,light,i,j,k,l,hp = *(c+2),x = *(c+24),y = *(c+25);
if(police)
  newpolice = 0;
if(*(c+30) != crum)
  return(1);
light = rumdata[crum][30];
level -= *(c+12);
level = (level < 1 ? 0 : level );
old = *(c+1);
*(c+1) += level;
*(c+1) = ( *(c+1) > *(c+2) ? *(c+2) : *(c+1) );
if(pc > 3 && *(c+31) < 4 && mode) {
   i = (*(c+1) * 4)/(*(c+2));
   if(i > 3) {
      *c = 0;
      i = 4;
      }
   if(*(c+36) == 1 && *(c+1) < *(c+2))
     i = 5;
   if(*(c+38) && *c == 1)
     i = 6;
   xbios(37);
   textsix(0,313,1+8*(*(c+33)),1," ");
   textsix(1,313,1+8*(*(c+33)),1,mod[i]);
   }
if(level == 0)
  return(1);
if(pc > 3 && (*(c+31) > 3  || (*(c+38) && curmon[0][39] == pc)) && crum != 31) {
  if(*(c+31) > 3 && *(c+52) == 0) {
     *(c+52) = 1;
     prnt("-> The %s shrieks in pain and fear!",w);
     }
  if(curmon[0][39] == pc || (curmon[0][15] == 2 && curmon[0][7] == pc) ) {
    *(c+38) = 0;
    dorep();
    }
  if(dungeon == 2 && *(c+31) > 3 && crum != 31 && !*(c+38) ) {
     police = 1;
     }
   if(dungeon == 2 && *(c+31) > 3 && specbuf[35] != 0)
      police = 1;
   }
*(c+35) = 2;
xbios(37);
xbios(38,off);
if(pc < 4 || light || zline[x][y][5] > 0)
   blt(bitmap[128],16*x,16*y,addr);
if(pc > 3 && mode) {
  for(i=0;i<8;i++) {
    xbios(37); 
    toggle(32,*(c+33),7,addr);
    }
  }
xbios(37);
xbios(38,vbl);
if(*(c+1) >= *(c+2) || level > *(c+2)) {
  *(c+1) = *(c+2);
  *c = 0;
  zline[x][y][2] = 0;
  if(pc > 0) {
    if(pc > 3 && *(c+58) != 16)
       prnt("-> The %s has been slain!",w);
    if(newpolice && police) {
       prnt("-> And an evil deed it was!  %s will pay for this heinous crime!",
              pname);
       }
    if(pc > 3 && *(c+58) == 16)
       prnt("->  MELKTHROP IS SLAIN!!!");
    if(pc < 4) {
       j = rumslot();
       z = crumobj[j];
       prnt("-> %s IS DEAD!",w);
       if(*(c+41) > 0)
          litetrol(x,y,0);
       i = zline[x][y][1];
       if(i != 0 && crumobj[i][3] != 0) {
          storsc(storbuf[pc],16*x,16*y,1,addr);
          do {
             i = 1 - rnd(3);
             k = 1 - rnd(3);
             x = *(c+24) + i;
             y = *(c+25) + k;
             z1 = zline[x][y];
             l = *(z1+1);
             } while ( x < 0 || x > 15 || y < 0 || y > 7 ||  
                      (crumobj[l][0] < 41 && crumobj[l][3] != 0) || *z1 != 1);
          *(c+24) = x;
          *(c+25) = y;
          storsc(storbuf[pc],16*x,16*y,0,addr);
          if(l != 0 && crumobj[l][0] > 40)
             putaway(pc,crumobj[l][0]);
          } 
       zline[x][y][1] = j;
       if(*(c+45) != 0)
          putaway(pc,*(c+45));
       if(*(c+46) != 0 && *(c+41) == 0)
          putaway(pc,*(c+46));
       if(j > 13) {
          rumdata[crum][134+j] = 41-pc;
          storobj(41-pc,x,y);
          }
       *z = *(z+4) = 41-pc;
       *(z+1) = *(z+8) = 1;
       *(z+7) = *(c+25);
       *(z+6) = *(c+24);
       if(invnpc[pc][0] > 0) {
         for(i=1;i<=13;i++) {
            if(invnpc[pc][i] != 0) {
              putinto(j,invnpc[pc][i]);
              invnpc[pc][i] = 0;
              }
            }
         invnpc[pc][0] = 0;
         *(z+5) = 1;
         }       
       else
         *(z+5) = 0;
       *(z+2) = *(z+3) = 0;
       }
    if(light || zline[x][y][5] > 0)
       drawsq(x,y);
    for(i=0;i<60;*(c+(i++)) = 0);
    return(1);
    }
  else {
    undorep();
    prnt("   -- ! %s IS PASSING OUT ! --",w);
    stormon();
    combat = 0;
    return(-1);
    }
  }
if( pc < 4 && (old*4)/(*(c+2)) < (i = (*(c+1)*4)/(*(c+2))) ) 
  prnt("-> %s's damage is now %s!",w,wordmod[i]);
return(1);
}

