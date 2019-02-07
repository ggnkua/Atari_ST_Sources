extern int sgetxy(x,y,type,top1,bot,ret)
int *x,*y,type,top1,bot,*ret;

{
int oldline = -1,newline=0,newx,newy,oldx = -1,oldy=0,i,j,k,status=1;
int light,keybd = 0,keystk = 0,mflag=0,rflag=0,tflag= 0,inrflag,intflag;
extern long int addr;
extern char *posture[],rumdata[][157],*verblist[],curmon[][60],zline[16][8][7];
extern int mode,handle,toggle(),crum,winker;
char *z,*c;
char *string,letter;
if(winker != 0)
  c = curmon[winker-1];
light = rumdata[crum][30];
while( (int)gemdos(0xb) != 0) {
     gemdos(0x8);
     }
do {
   vq_mouse(handle,&status,x,y);
   } while(status != 0);
if(top1 == 3 && bot == 15)
  keybd = 13;
if(top1 ==  8 && bot == 11)
  keybd = 4;
xbios(37);
raton();
do {
   if((int)gemdos(0xb) == -1) {
      keystk = 1;
      letter = gemdos(0x8);
      }
   if(keybd != 0 && keystk) {
     keystk = 0;
     for(i=0;i<keybd;i++) {
        if(keybd == 13)
          string = verblist[i];
        else
          string = posture[i];
        if( letter == ' ' || *string == letter || *string == (letter-32) ) {
            rausmaus();
            top(1);
            clrinp();
            if(rflag) {
              xbios(37);
              zline[oldx][oldy][4] = 0;
              for(j=0;j<2;j++) 
                 for(k=0;k<2;toggle(2*oldx+j,2*oldy+(k++),0,addr));
              if(mflag>0 && mode) {
                 toggle(32,mflag,7,addr);
                 mflag = 0;
                 }
              }
            if(keybd == 13) {
              if(letter == ' ')
                 *ret = 16;
              else
                 *ret = i+3;
              }
            else {
              if(letter == ' ')
                *ret = 12;
              else
                *ret = 8 + i;
              }
            return(1);  
            }
         }
     }
   vq_mouse(handle,&status,x,y);  /* sample mouse state */
   newx = (*x)/16;
   newy = (*y)/16;
   newline = (*y)/8;
   if(newx < 16 && newy < 8)
        inrflag = 1;
   else
        inrflag = 0;
   if(type == 0 && (newx > 15 || newy > 7) ) {
      if(rflag) { 
         xbios(37);
         for(j=0;j<2;j++) 
             for(k=0;k<2;toggle(2*oldx+j,2*oldy+(k++),0,addr));
         zline[oldx][oldy][4] = 0;
         if(mflag>0 && mode) {
             toggle(32,mflag,7,addr);
             mflag = 0;
             }
         rflag = 0;
         }
      oldx = newx;
      continue;
      }
   if(type == 1) {
      if(newx < 16 && newy < 8)
        inrflag = 1;
      else
        inrflag = 0;
      if(newx > 15 && newline >= top1 && newline <= bot)
        intflag = 1;
      else
        intflag = 0;
      if(tflag && !intflag) {
        xbios(37);
        rausmaus();
        tflag = 0;
        toggle(32,oldline,7,addr);
        raton();
        }
      if(rflag && !inrflag) {
         xbios(37);
         for(j=0;j<2;j++) 
             for(k=0;k<2;toggle(2*oldx+j,2*oldy+(k++),0,addr));
         zline[oldx][oldy][4] = 0;
         if(mflag > 0 && mode) {
            toggle(32,mflag,7,addr);
            mflag = 0;
            }
         rflag = 0;
         }
      if(!intflag)
         oldline = newline;
      if(!inrflag) {  
        if(!intflag)
          oldx = newx;
        oldy = newy;
        }
      if(!intflag && !inrflag) 
         continue;
      }
   if(type == 2 && (newx < 16 || newline < top1 || newline > bot ) ) {
      if(tflag) {
        tflag = 0;
        xbios(37);
        rausmaus();
        toggle(32,oldline,7,addr);
        raton();
        } 
      oldline = newline;
      oldx = newx;
      continue;
      }
   if(type == 0 || (type == 1 && inrflag) ) {
     z = zline[newx][newy];
     if(tflag) {
        tflag = 0;
        xbios(37);
        rausmaus();
        toggle(32,oldline,7,addr);
        raton();
        } 
     if(newx < 16 && newy < 8 && (*z == 1 || (*z == 2 && *(z+1) != 0 ) ) ) {
        if(newx != oldx || newy != oldy) {
           xbios(37);
           if(tflag) {
            tflag = 0;
            toggle(32,oldline,7,addr);
            } 
           rausmaus();
           if(oldx != -1 && rflag) {
             xbios(37);
             for(j=0;j<2;j++) 
                for(k=0;k<2;toggle(2*oldx+j,2*oldy+(k++),0,addr));
             zline[oldx][oldy][4] = 0;
             if(mflag > 0 && mode) {
                toggle(32,mflag,7,addr);
                mflag = 0;
                }
             rflag = 0;
             }
           if(*(z+5) > 0 || light || (*(z+2) > 0 && *(z+2) < 4) || 
               (winker > 0 && *(c+24) == newx && *(c+25) == newy) ) {
             xbios(37);
             for(j=0;j<2;j++) 
                 for(k=0;k<2;toggle(2*newx+j,2*newy+(k++),0,addr));
             *(z+4) = 1;
             rflag = 1;
             }
           oldx = newx;
           oldy = newy;
           if( mflag == 0 && mode && *(z+2) > 3 && (*(z+5) > 0 || light) 
               && curmon[*(z+2)][31] < 4 ) {
             mflag = curmon[*(z+2)][33];
             xbios(37);
             toggle(32,mflag,7,addr);             
             }
           raton();
           }
        }
     else {
        if(rflag) {
          rausmaus();
          xbios(37);
          for(j=0;j<2;j++) 
             for(k=0;k<2;toggle(2*oldx+j,2*oldy+(k++),0,addr));
          zline[oldx][oldy][4] = 0;
          if(mflag > 0 && mode) {
              toggle(32,mflag,7,addr);
              mflag = 0;
              }
          raton();
          rflag = 0;
          }
        oldx = newx;
        oldy = newy;
        }
     }
   if(type == 2 || (type == 1 && intflag)) {
      if(rflag) {
          rausmaus();
          xbios(37);
          for(j=0;j<2;j++) 
             for(k=0;k<2;toggle(2*oldx+j,2*oldy+(k++),0,addr));
          zline[oldx][oldy][4] = 0;
          if(mflag > 0 && mode) {
              toggle(32,mflag,7,addr);
              mflag = 0;
              }
          raton();
          rflag = 0;
          oldx = newx;
          oldy = newy;
          }
     if(newx > 15 && newline >= top1 && newline <= bot) {
        if(newline != oldline || oldx < 16) {
           xbios(37);
           rausmaus();
           if(oldline != -1 && tflag && oldx > 15) 
             toggle(32,oldline,7,addr);
           toggle(32,newline,7,addr);
           tflag = 1;
           oldline = newline;
           oldx = newx;
           raton();
           }
        }
     else {
        if(tflag) {
           xbios(37);
           rausmaus();
           toggle(32,oldline,7,addr);
           tflag = 0;
           raton();
           }
        oldline = newline;
        oldx = newx;
        oldy = newy;
        }
     }
   if(status != 0 && (rflag || tflag || 
     (inrflag && winker > 0 && lom(winker-1,oldx,oldy)) ) ) {
     rausmaus();
     xbios(37);
     if(rflag) {
       zline[oldx][oldy][4] = 0;
       for(j=0;j<2;j++) 
          for(k=0;k<2;toggle(2*oldx+j,2*oldy+(k++),0,addr));
       }
     if(tflag) 
       toggle(32,oldline,7,addr);
     if(mflag > 0 && mode) 
       toggle(32,mflag,7,addr);
     *x = oldx;
     *y = oldy;
     if(tflag)
       *ret = oldline;
     else
       *ret = 0;
     return(1);
     }
   } while (1);
}


extern int lom(pc,x,y)
int x,y,pc;
{
extern int crum;
extern char rumdata[][157],zline[16][8][7],curmon[][60],crumobj[14][9];
int x2,y2,h,i,j,q;
long register k,l,m,n,p;
char *z,z1,*c0 = curmon[pc];
x2 = *(c0+24); /* fetch the x-coordinate of the PC */
y2 = *(c0+25); /* fetch the y-coordinate of the PC */
i = (x2-x);            /* find difference between target and PC */
j = (y2-y);            
k = abs(i);   /* take absolute value of i and j */
l = abs(j);
if(k < 2 && l < 2)  /* always adjacent will make it through */
  return(1);
if(!zline[x][y][5] && !rumdata[crum][30] && pc < 4) /* the square is dark */
  return(0);
if (i != 0)
   i = ( i/k ); /* i is +1 if x2>x and i is -1 if x2<x, else = 0 */
if (j != 0)
   j = ( j/l );  /* j is +1 if y2>y and j is -1 if y2<y, else = 0  */
m = k;      /* m is the temporary value of x separation,called roll variable */
n = l;      /* n is the temporary value of y separation, called roll variable */
q = 0;
while ( (x != x2) || (y != y2) ) {
   if (q == 1) {
      z = zline[x][y];
      z1 = crumobj[*(z+1)][0];
      if(*(z+1) != 0 ) {
         if(z1 < 41 && z1 > 1)
           return(0);
         }
      if (*(z+2) != 0 || *z == 0 || ( *z == 2 && z1 == 0))
         return(0);    
      q = 0;  /* all this is stored in zline array  for each room     */
      }
   --m;         /* decrement each roll variable */
   --n;
   if (m<0) {   /* if x separation variable is 0 then roll y */
      y += j;
      q = 1;    /* alert system to check if los is blocked   */
      m = k;
      }
   if (n<0) {   /* same for y separation variable            */
      x += i;
      q = 1;
      n = l;
      }
   }
return(1);  /* if it makes it all the way through then los is open */         
}

extern int los(pc,x,y)
int x,y,pc;
{
extern int crum;
extern char rumdata[][157],zline[16][8][7],curmon[][60],crumobj[14][9];
int x2,y2,h,i,j,q;
long register k,l,m,n,p;
char *z,z1,*c0 = curmon[pc];
x2 = *(c0+24); /* fetch the x-coordinate of the PC */
y2 = *(c0+25); /* fetch the y-coordinate of the PC */
i = (x2-x);            /* find difference between target and PC */
j = (y2-y);            
k = abs(i);   /* take absolute value of i and j */
l = abs(j);
if(k < 2 && l < 2)  /* always adjacent will make it through */
  return(1);
if(!zline[x][y][5] && !rumdata[crum][30] && pc < 4) /* the square is dark */
  return(0);
if (i != 0)
   i = ( i/k ); /* i is +1 if x2>x and i is -1 if x2<x, else = 0 */
if (j != 0)
   j = ( j/l );  /* j is +1 if y2>y and j is -1 if y2<y, else = 0  */
m = k;      /* m is the temporary value of x separation,called roll variable */
n = l;      /* n is the temporary value of y separation, called roll variable */
q = 0;
while ( (x != x2) || (y != y2) ) {
   if(q == 1) {
      z = zline[x][y];
      z1 = crumobj[*(z+1)][0];
      if(*z != 1 || ( *(z+1) != 0 && z1 == 1) )
         return(0);    
      q = 0;  /* all this is stored in zline array  for each room     */
      }
   --m;         /* decrement each roll variable */
   --n;
   if (m<0) {   /* if x separation variable is 0 then roll y */
      y += j;
      q = 1;    /* alert system to check if los is blocked   */
      m = k;
      }
   if (n<0) {   /* same for y separation variable            */
      x += i;
      q = 1;
      n = l;
      }
   }
return(1);  /* if it makes it all the way through then los is open */         
}

/*****************************************************************************/
/* NEXTXY(XLO,YLO,XHI,YHI,XNOW,YNOW,&XNEXT,&YNEXT) is a dandy call to find   */
/* the next coordinates along the line joining the coordinates (xlo,ylo) to  */
/* (xhi,yhi) given that the character or whatever is currently at the (xnext,*/
/* ynext) coordinates.  It passes the coordinate of the                      */
/* square which the PC is going to move to into the addresses &XNEXT,&YNEXT. */
/* In addition, it returns the direction of the move.  The code for that is  */
/* 0=North,1=Northeast,2=East,3=Southeast,4=South,5=Southwest,6=West,7=North-*/
/* west,8=Samesquare.                                              12/12/85  */
/*****************************************************************************/

extern int nextxy(xlo,ylo,xhi,yhi,xnow,ynow,xnext,ynext)
int xlo,ylo,xhi,yhi,xnow,ynow,*xnext,*ynext;
{
int i,j,k=1,rollx,rolly,signx=0,signy=0;
i = xhi - xlo;
j = yhi - ylo;
rollx = abs(i);
rolly = abs(j);
if (i != 0)
   signx = i/rollx;
if (j != 0)
   signy = j/rolly;
do {
   if(line(xlo,ylo,xhi,yhi,xnow+signx,ynow+signy)) {
       *xnext = xnow + signx;
       *ynext = ynow + signy;
       k = 0;
       break;
       }
   if(line(xlo,ylo,xhi,yhi,xnow+signx,ynow)) {
       *xnext = xnow + signx;
       *ynext = ynow;
       signy = 0;
       k = 0;
       break;
       }
   *xnext = xnow;
   *ynext = ynow + signy;
   k = 0;    
   } while (k == 1);
}


extern int line(xlo,ylo,xhi,yhi,xnow,ynow)
int xlo,ylo,xhi,yhi,xnow,ynow;
{
int i,j,q;
register k,l,m,n,p,r;
i = (xhi-xlo);            /* find difference between two coordinates */
j = (yhi-ylo);            
if((xnow == xlo && ynow == ylo) || (xnow == xhi && ynow == yhi) ) 
     return(1);
k = abs(i);   /* take absolute value of i and j */
l = abs(j);
if (i != 0)
   i = ( i/k ); /* i is +1 if xhi>xlo and i is -1 if xhi<xlo, else = 0 */
if (j != 0)
   j = ( j/l );  /* j is +1 if yhi>ylo and j is -1 if yhi<ylo, else = 0  */
m = k;      /* m is the temporary value of x separation,called roll variable */
n = l;      /* n is the temporary value of y separation, called roll variable */
q = 0;
while ( (xlo != xhi) || (ylo != yhi) ) {
   if (q == 1) {
      if(xnow == xlo && ynow == ylo)
         return(1); /* then it's along the line */
      q = 0;  
      }
   --m;         /* decrement each roll variable */
   --n;
   if (m<0) {   /* if x separation variable is 0 then roll y */
      ylo += j;
      q = 1;    /* alert system to check if los is blocked   */
      m = k;
      }
   if (n<0) {   /* same for y separation variable            */
      xlo += i;
      q = 1;
      n = l;
      }
   }
return(0);  /* if it makes it all the way through then it's NOT in line */     
}

extern int rnd(max)
int max;
{
if(max == 0 || max == 1)
  return(0);
return(rand()%max);
}

extern int adjac(pc,x,y)
int pc,x,y;
{
extern char curmon[][60];
int xnow,ynow;
xnow = curmon[pc][24];
ynow = curmon[pc][25];
x = abs(xnow-x);
y = abs(ynow-y);
if(x <= 1 && y <= 1)
  return(1);
else
  return(0);
}	

/*****************************************************************************/
/* If flag is set this function moves the object randomly to a square around */
/* x,y.  If flag is zero then it moves the object to x,y.                    */
/*****************************************************************************/

extern int move(obj,flag,x,y)
int obj,flag,x,y;
{
extern char zline[16][8][7],crumobj[][9],curmon[][60],rumdata[][157];
extern int crum,bitmap[][65];
extern long int addr;
char *c = crumobj[obj],*z;
int done,i,j,light = rumdata[crum][30];
if(flag) {
  done = 0;
  for(i = -1;i <= 1;i++) {
     for(j = -1;j <= 1;j++) {
        if(i == 0 && j == 0)
            continue;
        z = zline[x+i][y+j];
        if(*z == 1 && *(z+1) == 0 && *(z+2) == 0 &&
            (curmon[0][24] != x+i || curmon[0][25] != y+j) ) {
          if(obj > 13)
            xobj(*c,crum);
          zline[x][y][1] = 0;
          if(light || zline[x][y][5] > 0)
            drawsq(x,y);
          *(z+1) = obj;
          *(c+6) = x+i;
          *(c+7) = y+j;
          if(obj > 13)
            storobj(*c,x+i,y+j);
          if(light || *(z+5) > 0)
             drawsq(x+i,y+j);
          done = 1;
          break;
          }
        }
     if(done)
        break;
     }
  }
if(!flag) {
    zline[*(c+6)][*(c+7)][1] = 0;
    if(light || zline[*(c+6)][*(c+7)][5] > 0)
      drawsq(*(c+6),*(c+7));
    *(c+6) = x;
    *(c+7) = y;
    zline[x][y][1] = obj;
    if(light || zline[x][y][5] > 0)
      drawsq(x,y);
    if(obj > 13) {
       xobj(*c,crum);
       storobj(*c,x,y);
       }
    done = 1;
    }
return(done);
}

extern int putinto(rumobj,thing)
int rumobj,thing;
{
extern char putbuf[];
extern int crum;
int i = 0;
while(putbuf[i] != 0 && i < 320) {
  i += 4;
  }
if(i >= 320)
  return(0);
putbuf[i] = 1;
putbuf[i+1] = thing;
putbuf[i+2] = rumobj;
putbuf[i+3] = crum;
return(1);
}

extern int putaway(pc,thing)
int pc,thing;
{
extern char curmon[][60],invnpc[][20];
char *i = invnpc[pc];
int j = 1;
if(thing == 0)
  return(1);
if(*i > 9 || thing == 81)
  return(0);
while(*(i+j) != 0 && j < 11) {
  j++;
  }
if(j == 11)
  return(0);
if(thing < 46 && thing > 40)
  curmon[pc][32] = 0;
*(i+j) = thing;
*i += 1;
return(1);
}

extern int takeout(pc,thing)
int pc,thing;
{
extern char invnpc[][20];
char *i = invnpc[pc];
int j = 1;
if(thing == 0)
  return(0);
while(*(i+j) != thing && j < 11) {
  j++;
  }
if(j == 11)
  return(0);
*i -= 1;
*(i+j) = 0;
return(1);
}

extern int remove(rumobj,thing)
int rumobj,thing;
{
extern int crum;
extern char putbuf[];
int i = 0;
while((putbuf[i+3] != crum || putbuf[i+2] != rumobj || putbuf[i+1] != thing) &&
       i < 320) {
    i += 4;
    }
if(i >= 320)
  return(0);
putbuf[i] = putbuf[i+1] = putbuf[i+2] = putbuf[i+3] = 0;
return(1);
} 

extern int storobj(thing,x,y)
int thing,x,y;
{
extern char rumdata[][157];
extern int crum;
int i=1;
char *r = rumdata[0];
while(*(r+i) != 0 && i <157) {
  i += 3;
  }
if(i >= 157)
  return(0);
*(r+i) = thing;
*(r+i+1) = 16*y + x;
*(r+i+2) = crum;
return(1);
}

extern int xobj(thing,room)
int thing,room;
{
extern char rumdata[][157];
int i = 1;
char *r = rumdata[0];
while( ( *(r+i) != thing || *(r+i+2) != room) && i < 157) {
  i += 3;
  }
if(i >= 157)
  return(0);
*(r+i) = *(r+i+1) = *(r+i+2) = 0;
return(1);
}

/****************************************************************************/
/* INVENT() is a call to update the inventory of the hero.  It updates the  */
/* status as well as which possessions are in the person's inventory.       */
/****************************************************************************/

extern int status(pc)
{
extern int winker,off(),vbl(),handle;
extern char invnpc[][20],curmon[][60],*wepname[],*name[],*statword[],*obj[];
extern char pname[];
int i,j,ret,flag = 0;
char scratch[3],*c = curmon[pc],*w = (pc == 0 ? pname : name[*(c+3)]);
long int point;
if(pc > 3)
 return(1);
xbios(37);
xbios(38,off);
top(1);
clrinp();
header(w);
for(i=0;i<2;i++)
  textsix(1,260,9+8*i,strlen(statword[i]),statword[i]);
v_rvon(handle);
for(i=2;i<5;i++) {
   vs_curaddress(handle,2*i,33);
   printf("        ");
   textsix(1,260,16*i-7,strlen(statword[i]),statword[i]);
   }
textsix(1,260,33,strlen(obj[*(c+45)]),obj[*(c+45)]);
textsix(1,260,49,strlen(obj[*(c+46)]),obj[*(c+46)]);
sprintf(scratch,"%d",*(c+2) - *(c+1));
textsix(1,300,9,2,scratch);
if(*(c+47)>0)
  sprintf(scratch,"%c",'P');
else
  sprintf(scratch,"%c",'G');
textsix(1,314,9,1,scratch);
sprintf(scratch,"%d",*(c+14));
textsix(1,300,17,strlen(scratch),scratch);
v_rvoff(handle);
for(i=5;i<9;i++)
   textsix(1,260,25+8*i,strlen(statword[i]),statword[i]);
xbios(37);
xbios(38,vbl);
sgetxy(&i,&j,2,8,11,&ret);
top(1);
clrinp();
ret -= 7;
switch(ret) {
   case 1:
   case 2:
       if(ret == 2) {
         if(*(c+41) > 0) {
            *(c+46) = 0;
            litetrol(*(c+24),*(c+25),0);
            } 
         if(*(c+41) > 64) 
            *(c+42) += 1;
         if(*(c+41) > 0)
            *(c+41) = 0;
         }
       j = invent(pc);
       if(j == 0) {
         if(!putaway(pc,*(c+44+ret))) {
            error(7);
            break;
            }
         *(c+44+ret) = 0;
         break;
         } 
       if(*(c+44+ret) != 0 ) { 
          if(!putaway(pc,*(c+44+ret))) {
             error(7);
             break;
             }
          }
       takeout(pc,j);
       *(c+44+ret) = j;
       if(*(c+45) < 46 && *(c+45) > 40)
           *(c+32) = *(c+45);
       break;
   case 3:
       invent(pc);
       flag = 1;
       break;
   default:
       flag = 1;
       break;
   }
top(1);
clrinp();
dotop(pc);
return(flag);
}     


extern int invent(pc)
int pc;
{
extern int handle,vbl(),off(),mode;
extern char invnpc[][20],*obj[];
int j,top = 3,i,ret,bot;
char scratch[16];
bot = 2+listinv(pc,scratch);
sgetxy(&i,&j,2,top,bot+1,&ret);
if(ret == bot+1)
  return(0);
return(scratch[ret]);
}

extern int listinv(pc,scratch)
int pc;
char *scratch;
{
extern int handle,vbl(),off();
extern char curmon[][60],invnpc[][20],*obj[],*wepname[];
int j,bot=0;
char word[3],*o = invnpc[pc],*c = curmon[pc];
xbios(37);
xbios(38,off);
vs_curaddress(handle,1,33);
v_rvon(handle);
printf("        ");
v_rvoff(handle);
textsix(1,260,1,9,"INVENTORY");
prhand(pc);
*(scratch+1) = *(c+45);
*(scratch+2) = *(c+46);
for(j=1;j<14;j++) {
  if(*(o+j) != 0) {
     bot++;
     textsix(1,260,17+bot*8,strlen(obj[*(o+j)]),obj[*(o+j)]);
     *(scratch+bot+2) = *(o+j);
     }
  }
textsix(1,260,25+bot*8,9,"No Choice");
textsix(1,260,33+8*bot,7,"Torches");
sprintf(word,"%d",*(c+42));
textsix(1,308,33+8*bot,strlen(word),word);
textsix(1,260,41 + 8*bot,4,"Gold");
sprintf(word,"%d",*(c+49));
textsix(1,308,41 + 8*bot,strlen(word),word);
xbios(37);
xbios(38,vbl);
invnpc[pc][0] = bot;
return(bot);
}

extern int top(line)
int line;
{
extern int handle;
int i;
for(i=2;i>=line;i--) {
  vs_curaddress(handle,i,33);
  v_eeol(handle);
  }
}
