extern int explode(x,y,type)
int x,y,type;
{
extern int firebuff[],bitmap[][65],vbl(),off();
extern long int addr;
int i,j;
x *= 16;
y *= 16;
xbios(37);
xbios(38,off);
storsc(firebuff,x,y,0,addr);
for(i=1;i<10;i++) {
   xbios(37);
   blt(bitmap[132 + 2*type + (i%2)],x,y,addr);
   for(j=0;j<4000;j++);
   xbios(37);
   storsc(firebuff,x,y,1,addr);
   }
xbios(38,vbl);
return(1);
}
