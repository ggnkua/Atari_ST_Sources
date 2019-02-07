extern int animate()
{
extern int outside,crum,grflist[],prev,time,handle,bitmap[][65],storbuf[][130];
extern long int addr;
extern char specbuf[],rumdata[][157],curmon[][60],zline[16][8][7];
int m,n,j;
int x,y;
char *c,*z;
time++;
if(!grflist[0])
   return(1);
if(specbuf[35] > 0 && time%3 == 0) {
   x = specbuf[36]%16;
   y = specbuf[36]/16;
   x += rnd(3) - 1;
   y += rnd(3) - 1;
   z = zline[x][y];
   if((m = *(z+6)) != 0) 
      blt(bitmap[130 + 2*m + rnd(2)],16*x,16*y,addr);
   }
if(time > (60-20*outside)/grflist[0]) {
   prev++;
   prev = (prev > grflist[0] ? 1 : prev);
   j = grflist[prev];
   c = curmon[j];
   if(*c == 0 || *(c+30) != crum)
     return(1);
   time = 0;
   x = *(c+24);
   y = *(c+25);
   z = zline[x][y];
   if(!*(z+5) && !rumdata[crum][30] && j > 3)
     return(1);
   *(c+17) = ( *(c+17) == 1 ? 0 : 1);
   rausmaus();
   storsc(storbuf[j],16*x,16*y,1,addr);
   blt(bitmap[*(c+4) + 66*(*(c+17))],x*16,y*16,addr);
   if(*(c+35) > 0) {
      blt(bitmap[128],16*x,16*y,addr);
      *(c+35) -= 1;
      } 
   if( (m = *(z+6)) != 0)
     blt(bitmap[130 + 2*m],16*x,16*y,addr);
   if(*(z+4) == 1) {
      for(m=0;m<2;m++)
        for(n=0;n<2;toggle(2*x+m,2*y+(n++),0,addr));
     }
   raton();
   }
return(1);
}

