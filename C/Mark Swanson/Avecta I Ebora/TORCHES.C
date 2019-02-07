
extern int setlite(pc,dx,dy)
int pc,dx,dy;
{
extern int crum,vbl(),off();
extern char rumdata[][157],curmon[][60];
char *c = curmon[pc];
int x,y;
if(rumdata[crum][30])
  return(1);
x = *(c+24);
y = *(c+25);
xbios(37);
xbios(38,off);
drawsq(x,y);
if(*(c+41) == 0) {
   drawsq(x-dx,y-dy);
   return(0);
   }
litetrol(x,y,1);
litetrol(x-dx,y-dy,0);
xbios(37);
xbios(38,vbl);
}

extern int litetrol(x,y,s)
int x,y,s;
{
extern int crum;
extern char curmon[][60],rumdata[][157],zline[16][8][7];
int i,j,k,a,flag,l;
char *c;
if(rumdata[crum][30]) /* if room is naturally lit */
  return(1);          /* don't sweat torches  */
for(i = -2;i <= 2;i++) { /* do that funny shaped pattern around square */
    switch (abs(i)) {
       case 2:
         j = 0;
         break;
       case 1:
         j = 1;
         break;
       default:
         j = 2;
       }
    for(k = -j;k <= j;k++) {
       if(x+i>15 || x+i<0 || y+k>7 || y+k<0 || zline[x+i][y+k][0] == 0)
         continue; /* if off display surface or square is void */
       a = zline[x+i][y+k][5]; /* fetch torch overlay number */
       switch(s) { /* s=0 ->  turn lights out, s=1 -> turn 'em on */
          case 0: /* turn out the lights, the party's over */
            if(a > 1) /* decrement torch overlays */
              a--;
            else  /* there is zero torch overlays */
              a = 0;
            zline[x+i][y+k][5] = a; /*set zline*/
            if(a > 0) /* another torch is carrying the lighting in the square */
              continue;
            flag = 0; /* shut down flag */
            for(l=0;l<=3;l++) { /* don't shut down square if 1-4 charac there */
                c = curmon[l];
                if(*c != 0 && *(c+30) == crum 
                   && *(c+24) == x+i && *(c+25) == y+k) {
                  flag = 1;
                  break;
                  }
                } 
            if(!flag) { /* shut down square */
               setfill(2); /* blank it */
               fillsq(x+i,y+k); /* paint it black */
               }
             break;
          case 1: /* turn on the lights, the party's started */
             flag = 0; /* is the square a blit? */
             if(a == 0) /* then the square was black to begin with */
               flag = 1; /* so set up blit flag */
             a++; /* increment the torch overlay number */
             zline[x+i][y+k][5] = a;/*set zline*/
             if(flag)   /* blit flag is set so blit it, buster! */
               drawsq(x+i,y+k);
             break;                  
          }
       }
    }   
}

extern int drawsq(x,y)
int x,y;
{
extern int bitmap[][65],storbuf[][130];
extern char zline[16][8][7],crumobj[][9],curmon[][60];
extern long int addr;
char *z = zline[x][y],*c;
int i,pc;
if(*z == 1)
  i = 1;
if(*z == 2)
  i = 0;
if(*z == 0)
  i = 2;
setfill(i);
fillsq(x,y);
if(i == 2)
  return(1);
pc = *(z+2);
if(!pc)
   pc = (curmon[0][24] == x && curmon[0][25] == y ? 0 : -1);
x *= 16;
y *= 16;
if(*(z+1) != 0 && crumobj[*(z+1)][8] == 1)
  blt(bitmap[crumobj[*(z+1)][0]],x,y,addr);
if(pc >= 0) { 
  c = curmon[pc];
  *c = 0;
  xbios(37);
  *c = 1;
  storsc(storbuf[pc],x,y,0,addr);
  blt(bitmap[*(c+4)],x,y,addr);
  }
if(*(z+6) != 0)
  blt(bitmap[130 + 2*(*(z+6))],x,y,addr);
}

drawman(pc,x,y)
int pc,x,y;
{
extern int crum;
extern char zline[16][8][7],curmon[][60],rumdata[][157];
char *c = curmon[pc];
if(pc < 4 && *(c+41) > 0) 
  litetrol(x,y,1);
if(zline[x][y][5] > 0 || rumdata[crum][30] || pc < 4) 
  drawsq(x,y);
}
