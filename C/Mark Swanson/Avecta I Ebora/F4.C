extern int i4(pc)
int pc;
{
extern char curmon[][60];
char *c = curmon[pc];
int x,y;
*(c+22) = *(c+24);
*(c+23) = *(c+25);
*(c+15) = 4;
*(c+16) = (*(c+11) > 0 ? *(c+11) : 1);
nextxy(*(c+24),*(c+25),*(c+26),*(c+27),*(c+24),*(c+25),&x,&y);
if(x - *(c+24) != 0 && y - *(c+25) != 0)
  *(c+16) += (*(c+16))/2;
*(c+28) = x;
*(c+29) = y;
*(c+7) = *(c+8) = *(c+9) = 0;
return(1);
}

extern int o4(pc)
int pc;
{
extern char *name[],pname[],crumobj[][9],curmon[][60],zline[16][8][7];
extern long int addr;
extern char rumdata[][157];
extern int outside,crum,off(),vbl(),bitmap[][65],storbuf[][130];
char *c = curmon[pc],*z,id,*d,*w;
int flag,xroll,yroll,i,xnow = *(c+24),ynow = *(c+25),x = *(c+28),y = *(c+29);
int j,light = rumdata[crum][30];
z = zline[x][y];
id = crumobj[*(z+1)][0];
w = (pc == 0 ? &pname[0] : name[curmon[pc][3]]);
if(*z != 1 || (id < 41 && id >0)  || *(z+2) != 0) {
  i = curmon[*(z+2)][3];
  if(pc < 4 && *(z+2) != 0 && pc != *(z+2)) {
     if(*(z+2) > 3 && i != 10) 
        prnt("-> The %s blocks %s!",name[i],w);
     else
        prnt("-> %s blocks %s!",name[i],w);
     }
  return(1);
  }
if(pc > 0 && *(z+2) == 0 && x == curmon[0][24] && y == curmon[0][25])
  return(1);
if(pc == 0) {
   if(*(c+18) != 4)
      prnt("-> %s moves...",&pname[0]);
   *(c+18) = 4;
   }
xroll = 2*(x - xnow)/(1 + outside);
yroll = 2*(y - ynow)/(1 + outside);
z = zline[xnow][ynow];
xbios(37);
xbios(38,off);
x = 16*xnow;
y = 16*ynow;
if(!light && *(z+5) == 0)
   flag = 1;
else
   flag = 0;
if(!light && zline[*(c+28)][*(c+29)][5] == 0) { 
  if(pc < 4)  {
    drawsq(*(c+28),*(c+29));
    }
  else {
     *(z+2) = 0;
     if(*(z+5) > 0)
        drawsq(xnow,ynow);
     *(c+24) = *(c+28);
     *(c+25) = *(c+29);
     zline[*(c+24)][*(c+25)][2] = pc;
     return(1);
     }
  }
for(i=1;i<9 + 8*outside;i++) {
    x += xroll;
    y += yroll;
    if(outside) {
       for(j=0;j<2;j++)
           xbios(37);
       }
    xbios(37);
    if(i > 1 || pc < 4 || !flag)
      storsc(storbuf[pc],x-xroll,y-yroll,1,addr); /* restores the screen */
    storsc(storbuf[pc],x,y,0,addr);
    blt(bitmap[*(c+4)],x,y,addr);
    }
*(c+34) = 0;
*(c+35) = 0;
*(c+24) = *(c+28);
*(c+25) = *(c+29);
*(z+2) = 0;        /* reset the zline array to reflect move */
zline[*(c+24)][*(c+25)][2] = pc;
if(pc < 4)
  setlite(pc,*(c+24) -xnow,*(c+25) -ynow);
if(!light && *(z+5) == 0) {
  setfill(2);
  fillsq(xnow,ynow);
  }
if(*(z+6))
  blt(bitmap[132],16*xnow,16*ynow,addr);
xbios(37);
xbios(38,vbl);
if(*(c+28) == *(c+26) && *(c+29) == *(c+27)) {
   return(1); /* since the move is complete */
   }
nextxy(*(c+22),*(c+23),*(c+26),*(c+27),*(c+24),*(c+25),&x,&y);
*(c+16) = (*(c+11) > 0 ? *(c+11) : 1);
if(x - *(c+24) != 0 && y - *(c+25) != 0)
   *(c+16) += (*(c+16))/2;
*(c+28) = x;
*(c+29) = y;
return(0);  /* the move is not complete otherwise */
}
