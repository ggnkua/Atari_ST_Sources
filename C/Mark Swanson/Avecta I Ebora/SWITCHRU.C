extern int switchrum()
{
extern int fromout,outside,winroom,dungeon,crum,mode,pursuit[3];
extern int off(),vbl(),bitmap[][65],storbuf[][130];
extern char zline[16][8][7],*rummsg[],rumdata[][157],crumobj[][9],curmon[][60];
extern char *msg[],specbuf[40];
extern long int addr;
int d,i,j,x,y,xn,yn,oldrum;
char *c,*p = curmon[0],*r = rumdata[crum],pan[12];
if(crum != *(p+30) && crum != -1 && !outside) {
  for(i=0;i<13;i++) {
    c = crumobj[i+1];
    for(j=0;j<9;j++) 
       *(r+31+9*i+j) = *(c+j);
    }
  for(i=0;i<3;pursuit[i++] = 0);
  pursuit[0] = 10;
  for(i=1;i<12;i++) {
    c = curmon[i];
    *(c+35) = 0;
    if(*c == 1 && *(c+30) == crum  && (i < 4 || *(c+38) == 0) && 
       (i < 4 || *(c+39) < 4) && *(c+58) != 16 &&
       *(c+31) < 4 && (dungeon != 2 || *(c+58) == 17) &&
       (i < 4 || (*(c+36) == 0 && *(c+13) > rnd(100)) ) ) {
      pursuit[2] = crum;
      xn = *(c+24);
      yn = *(c+25);
      d = dist(x,y,0,xn,yn,0);
      pursuit[0] = (pursuit[0] > d ? d : pursuit[0]);
      pursuit[1]++;
      } 
    }
  }
if(*(p+30) == 127) {
  stormon();
  pursuit[0] = pursuit[1] = pursuit[2] = 0;
  return(2);
  }
if(fromout == 1 && *(p+30) != crum) {
  *(p+4) = 125;
  outside = 1;
  fromout = 0;
  }
if(fromout == 2)
  fromout = 1;
*(p+15) = 8;
*(p+16) = 1;
x = *(p+24);
y = *(p+25);
*(p+35) = 0;
mode = 0;
for(i=0;i<12;pan[i++] = 0);
for(i=4;i<12;i++) {
 if(curmon[i][30] != crum && (curmon[i][36] == 1 || curmon[i][31] == 6) )
        pan[i-1] = 1;
 }
if(crum != *(p+30) && crum != -1) {
   specbuf[35] = specbuf[36] = 0;
   stormon();
   }
if(pursuit[0] > 1)
  pursuit[0] /= 2;
if(pursuit[1] == 0)
  pursuit[0] = 0;
oldrum = crum;
crum = *(p+30);
if(crum == 70) 
  return(1);
rumdraw(pan);
i = 0;
if(oldrum != crum) {
  for(i=1;i<14;i++) {
      c = crumobj[i];
      if(*(c+3) == oldrum) {
        *(p+24) = x = *(c+6);
        *(p+25) = y = *(c+7);
        if(*(c+8) == 0) { /* must reveal hidden door */
          *(c+8) = 1;
          xbios(37); 
          blt(bitmap[*c],16*x,16*y,addr);
          zline[x][y][1] = i;
          }
        break;
        }
      }
   }
if(oldrum == crum || i == 14) { /* got into the room through a trap */
  x = *(p+24);
  y = *(p+25);
  if(i == 14)
    pursuit[0] = pursuit[1] = pursuit[2] = 0;
  }
drawman(0,x,y);
if(oldrum == crum) {
  for(i=1;i<12;i++) { 
     if(pan[i-1] == 1)
         curmon[i][36] = 1;
     }
  }
getmon(crum);
if(mode)
  dorep();
if(!outside) {
  if(fromout != 0)
     prnt(msg[crum]);
  else
     prnt(rummsg[crum + 80*(dungeon-1)]);  
  trigtrol(0);
  }
if(rumdata[crum][30]) {
   i = 0;
   for(j=0;j<4;j++) {
     c = curmon[j];
     if(*(c+41) > 0) { 
       i = 1;
       *(c+42) += 1;
       *(c+41) = 0;
       *(c+46) = 0;
       }
     }
   if(i)
     prnt("-> The lit torch is snuffed and put away.");
   }
return(0);
}

extern int stormon()
{
extern char monbuf[],zline[16][8][7],rumdata[][157],curmon[][60];
extern int crum;
char *r = monbuf,*c;
int i,j = 1;
for(i=4;i<12;i++) {
   c = curmon[i];
   if(*c == 0 || *(c+30) != crum)
     continue;
   while( *(r+j) != 0 && j < 320) {
      j += 4;
      }
   if(j >= 320)
      break;
   if(*(c+4) > 115 && *(c+4) < 119)
      *(c+4) = 110;
   *(r+j) = *(c+4);
   *(r+j+1) = crum;
   *(r+j+2) = *(c+1);
   *(r+j+3) = 16*( *(c+25) ) + *(c+24);
   }
}

extern int getmon(room)
int room;
{
extern char monbuf[],zline[16][8][7],curmon[][60],permon[][23],rumdata[][157];
extern int mode,bitmap[][65],storbuf[][130];
extern long int addr;
char *r = monbuf,*c,*p;
int i,j,k,type,count=0,x,y;
for(i=1;i<320;i += 4) {
  if(*(r+i+1) == room) {
    for(j=1;j<26;j++) {
      if(permon[j][4] == *(r+i))
         break;
      }
    if(j == 26)
      continue;
    type = j;
    p = permon[type];
    x = ( *(r+i+3) )%16;
    y = ( *(r+i+3) )/16;
    if( zline[x][y][2] != 0 || (x == curmon[0][24] && y == curmon[0][25]))
       continue;
    for(j=4;j<12;j++) {
      c = curmon[j];
      if(*c == 0 || *(c+30) != room) {
         for(k=0;k<60;*(c+(k++)) = 0);
         for(k=0;k<15;k++)
             *(c+k) = *(p+k);
         *(c+50) = *(p+15);
         *(c+45) = *(p+16);
         *(c+41) = *(p+17);
         *(c+42) = *(p+18);
         *(c+43) = *(p+19);
         *(c+31) = *(p+20);
         *(c+44) = *(p+21);
         *(c+46) = *(c+37) = *(p+22);
         *(c+58) = type;
         *(c+51) = (*(c+14))/3;
         if(*(c+51) > 20)
           *(c+54) = 1;
         *(c+24) = x;
         *(c+25) = y;
         *(c+30) = room;
         *(c+39) = j;
         *(c+1) = *(r+i+2);
         *(c+15) = 8;
         *(c+16) = 1;
         zline[x][y][2] = j;
         count++;
         if(*(r+i) == 110)
            *(c+4) = 116 + rnd(3);
         if(*(c+31) < 4)
            mode = 1;
         drawman(j,x,y);
         *(r+i) = *(r+i+1) = *(r+i+2) = *(r+i+3) = 0;
         break;
         }
      }
    } 
  }
return(count);
}
