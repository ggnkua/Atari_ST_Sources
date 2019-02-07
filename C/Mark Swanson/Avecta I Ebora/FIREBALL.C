
   
extern int fireball(xs,ys,xd,yd,type)
int xs,ys,xd,yd,type;

{
extern long int addr;
extern int bitmap[][65],firebuff[120];
int i,j,k,l,m,n,q,r,s,t;
i = 8*(xd - xs);
j = 8*(yd - ys);
k = abs(i);
l = abs(j);
if(i != 0)
  i /= k;
if(j != 0)
  j /= l;
i *= 2;
j *= 2;
m = k;
n = l;
q = r = s = 0;
xs *= 16;
xd *= 16;
ys *= 16;
yd *= 16;
xbios(37);
storsc(firebuff,xs,ys,0,addr);
while( (xs/16 != xd/16) || (ys/16 != yd/16) ) {
  if(q == 1) {
    xbios(37);
    storsc(firebuff,xs-s,ys-r,1,addr);
    storsc(firebuff,xs,ys,0,addr);
    blt(bitmap[132 + 2*type + rnd(2)],xs,ys,addr);
    q = r = s = 0;
    }
  --m;
  --n;
  if(m < 0) {
    ys += j;
    q = 1;
    m = k;
    r = j;
    }
  if(n < 0) {
    q = 1;
    xs += i;
    n = l;
    s = i;
    }
  }
xbios(37);
storsc(firebuff,xs-s,ys-r,1,addr);
}
