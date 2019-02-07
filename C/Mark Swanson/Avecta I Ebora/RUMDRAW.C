extern int rumdraw(pan)
char *pan;

{
extern char zline[16][8][7],rumdata[][157],crumobj[][9],triglist[];
extern char specbuf[40],invnpc[][20],invtrig[],curmon[][60],*rummsg[];
extern int vxy[],lxy[],mode,handle,crum,objnum,bitmap[][65],storbuf[][130];
extern long int addr;
extern int outside;
int top,i,j,k,xold,yold,x,y,x1,y1,x2,y2,stepx,stepy,open;
char *c,*z,*r =  rumdata[crum];
for(i=0;i<13;i++) {
   c = crumobj[i+1];
   for(j=0;j<9;j++) 
     *(c+j) = *(r+31+9*i+j);
   }
for(i=14;i<19;i++) {
   c = crumobj[i];
   for(j=0;j<9;*(c+(j++)) = 0);
   }
for(i=0;i<16;i++) {
   for(j=0;j<8;j++)
      for(k=0;k<7;zline[i][j][k++] = 0);
   }
objnum = 0;
for(i=0;i<25;triglist[i++] = 0);
for(i=1;i<14;i++) {
   c = crumobj[i];
   if(*c != 0) {
     objnum++;
     if(*(c+2) != 0) {
        triglist[0]++;
        triglist[i] = *(c+2);
        }
     }
   }
for(i=0;i<4;i++) {
  c = curmon[i];
  if(*(c+45) > 40 && *(c+45) < 81)
     invtrap(*(c+45));
  if(*(c+46) > 40 && *(c+46) < 81)
     invtrap(*(c+46));
  c = invnpc[i];
  if(*c == 0)
     continue;
  for(j=1;j<14;j++) {
    if(*(c+j) == 0)
      continue;
    invtrap(*(c+j));
    }
  }
xold = rumdata[crum][0]%16;
yold = rumdata[crum][0]/16;
x1 = xold;
y1 = yold;
i = 1;
do {
   x2 = (rumdata[crum][i])%16;
   y2 = (rumdata[crum][i])/16;
   stepx = x2-x1;
   stepy = y2-y1;
   stepx = (stepx != 0 ? stepx/abs(stepx) : 0);
   stepy = (stepy != 0 ? stepy/abs(stepy) : 0);
   while( x1 != x2 || y1 != y2 )  {
      zline[x1][y1][0] = 2;
      x1 += stepx;
      y1 += stepy;
      }
   x1 = x2;
   y1 = y2;
   i++;
   } while((x2 != xold || y2 != yold) && i <= 16);
top = -1;
for(j=0;j<8;j++) {
  open = 0;
  for(i=0;i<16;i++) {
     z = zline[i][j];
     if(top == -1 && *z != 0)
          top = j;
     if(i > 0 && zline[i-1][j][0] == 2 && *z != 2) {
       open = !open;
       k = 0;
       while (j-k > 0) {
          if(j == 0)
             break;
          if(k > 0 && zline[i][j-k][0] != 2)
             break;
          else
             k++;
          } 
       if(k == 1) { 
         if(zline[i][j-1][0] != 2)
           open = zline[i][j-1][0];
         else
           open = 1;
         }           
       else {
         if(j == k && zline[i][j-k][0] == 2)
           open = 1;
         else
           open = !zline[i][j-k][0];
         }
       }
     if(j == top || j == 7)
        open = 0;
     if(*z != 2)
        *z = open;
     }      
  }
rumclear();
if(*(r+30)) {
  for(k=0;k<2;k++) {
    setfill(k);
    for(j=0;j<8;j++) {
       for(i=0;i<16;i++) {
          if(zline[i][j][0] == 2-k && (!outside || k != 0) ) 
             fillsq(i,j);
          }
       }
    }
  }
else {
 setfill(2);
 for(j=0;j<8;j++) {
    for(i=0;i<16;i++)
       fillsq(i,j);
    }
 }
vsf_interior(handle,1);
vsf_style(handle,0);
vsf_color(handle,0);
v_bar(handle,vxy);
v_bar(handle,lxy);
for(i=1;i<14;i++) {
  c = crumobj[i];
  if(*c != 0) {
    if(*(c+8)){
      if(*(r+30)) 
         blt(bitmap[*c],(*(c+6))*16,(*(c+7))*16,addr);
      zline[*(c+6)][*(c+7)][1] = i;
      }
    else
      zline[*(c+6)][*(c+7)][3] = i;
    }
  }
for(i=148;i<153;i++) {
  if(*(r+i) == 0)
     continue;
  j = 1;
  while(j < 157 && (rumdata[0][j] != *(r+i) || rumdata[0][j+2] != crum)) {
     j += 3;
     }
  if(j >= 157) {
     *(r+i) = 0;
     continue;
     }
  c = crumobj[i-134];
  *(c+6) = x = rumdata[0][j+1]%16;
  *(c+7) = y = rumdata[0][j+1]/16;
  if(x > 15 || y > 7)
    continue;
  *c = *(r+i);
  zline[x][y][1] = i-134;
  invtrap(*c);
  *(c+2) = *(c+3) = 0;
  *(c+1) = 1;
  *(c+4) = *c;
  *(c+5) = -1;
  *(c+8) = 1;
  if(rumdata[crum][30])
    drawsq(x,y);
  }
if(specbuf[35] != 0) {
  x = specbuf[36]%16;
  y = specbuf[36]/16;
  for(i = x-1;i < x+2; i++) {
    for(j = y-1; j < y+2; j++) {
       z = zline[i][j];
       if(*z == 1) {
          *(z+5) += 1;
          *(z+6) = 1;
          drawsq(i,j);
          }
       }
     }
   }
for(i=1;i<12;i++) {
  c = curmon[i];
  if(*c == 1 && *(c+30) == crum) {
    x1 = *(c+24);
    y1 = *(c+25);
    j = xmon(*(c+30),*(c+4),x1,y1);
    if(*(c+4) == 110)
       *(c+4) = 116 + rnd(3);
    if(*(c+36) == 0) {
      if(zline[x1][y1][2] != 0) {
        *c = 0;
        continue;
        }
      }
    if( *(pan+i-1) == 1 )  {
      x1 = rnd(13);
      y1 = rnd(7);
      z = zline[x1][y1];
      k = 0;
      while( k < 100 && ( *z != 1 || *(z+1) != 0 || *(z+2) != 0)) {
         x1 = rnd(13);
         y1 = rnd(7);
         z = zline[x1][y1];
         k++;
         }
      if(k == 100) {
        *c = 0;
        continue;
        }
      *(c+24) = x1;
      *(c+25) = y1;
      *(c+36) = 0;
      }                     
    *(c+15) = 8;
    *(c+16) = 1;
    *(c+39) = i;
    *(c+18) = 0;
    zline[x1][y1][2] = i;
    drawman(i,*(c+24),*(c+25));
    if(i > 3 && *(c+31) < 4)
      mode = 1; 
    }
  }
return(1);
}


extern int rumclear()
{
extern int handle;
int i;
for(i=1;i<17;i++) {
  vs_curaddress(handle,i,1);
  v_eeol(handle);
  }
undorep();
}


extern int abs(x)
int x;
{
return( x = (x < 0 ? -x : x) );
}

int click()
{
extern int handle;
int status,x,y;
do {
    vq_mouse(handle,&status,&x,&y);
   } while(status == 0);
do{
    vq_mouse(handle,&status,&x,&y);
  } while(status != 0);
}  

extern int fillsq(x,y)
int x,y;
{
extern int handle;
extern char rumdata[][157];
int pxy[4];
pxy[0] = 16*x;
pxy[1] = 16*y;
pxy[2] = pxy[0] + 15;
pxy[3] = pxy[1] + 15;
vr_recfl(handle,pxy);
return(1);
}

extern int setfill(k)
int k;
{
extern char rumdata[][157];
extern int fillpic[][65],crudbuf[],handle,crum;
char *r = rumdata[crum];
if(k == 2) {
  vsf_interior(handle,1);
  vsf_color(handle,0);
  return(1);
  }
vsf_color(handle,*(r+18+3*k)); 
if( *(r+16+3*k) > 0) {
  vsf_interior(handle,*(r+16+3*k));
  vsf_style(handle,*(r+17+3*k));
  }
else {
  trans(fillpic[*(r+17+3*k)],crudbuf);
  vsf_udpat(handle,crudbuf,4);
  vsf_interior(handle,4);
  }
}

extern int trans(bit,stor)
int *bit,*stor;
{
int i,j;
for(i=0;i<4;i++) {
  for(j=0;j<16;j++) 
     *(stor+j+16*i) = *(bit+4*j+i);
  }
}


