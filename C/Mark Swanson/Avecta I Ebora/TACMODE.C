			
/*****************************************************************************/
/* TACMODE runs the tactical mode of the game, and continues until the hero  */
/* is victorious or leaves the room, or everyone is dead.  It returns the    */
/* following code: 0 = no one in the room (so hero is gone and maybe dead),  */
/* 1 = hero is sole possessor of room, -1 = monsters in sole possession of   */
/* room, -2 = hero has called an interrupt to play.                          */
/*****************************************************************************/

#include "osbind.h"

extern int tacmode()
{
extern char zline[16][8][7],rumdata[][157],*msg[],curmon[][60],crumobj[14][9];
extern char permon[][23];
extern int mode,crum,pursuit[3],bitmap[][65],(*inverb[])(),(*outverb[])();
extern int monster,police,outside,dungeon,fromout,combat,handle,storbuf[][130];
extern long int addr;
int flag,i,j,k,l,m,n,p,timer=0,x,y;
int actlist[13];
extern int grflist[];
char *c,*o;
do {
   for(i=0;i<13;i++)
      grflist[i] = actlist[i] = 0;
   if(curmon[0][0] == 0)
     return(-1);
   if( curmon[0][30] != crum)
     return(0);
   if(timer % 5 == 0) {
     timetrol();
     if(pursuit[0] != 0) {
       pursuit[0]--;
       flag = 0;
       if(pursuit[0] == 0 && (mode == 0 || pursuit[1] != 0) ) {
         for(i=1;i<12;i++) {
            c = curmon[i];
            if(*c == 0 || *(c+30) != pursuit[2] || flag > 0 || *(c+31) > 3)
              continue;
            for(j=0;j<14;j++) {
              o = crumobj[j];
              if(*o == 0 || flag > 0)
                 continue;
              if(*(o+3) == pursuit[2]) {
                 x = *(o+6);
                 y = *(o+7);
                 if(zline[x][y][2] != 0 || (curmon[0][24] == x &&
                                            curmon[0][25] == y ) ) {
                    pursuit[0] += 2;
                    flag = 2;
                    break;
                    }
                 zline[x][y][2] = i; 
                 xmon(*(c+30),*(c+4),*(c+24),*(c+25));
                 *(c+24) = x;
                 *(c+25) = y;
                 *(c+16) = 1;
                 *(c+15) = 8;
                 *(c+26) = curmon[0][24];
                 *(c+27) = curmon[0][25];
                 *(c+30) = crum;
                 drawman(i,x,y);
                 dorep();
                 if(i > 3 && *(c+31) < 4)
                   mode = 1;
                 flag = 1;
                 pursuit[1]--;
                 if(pursuit[1] > 0) 
                   pursuit[0] += 2;
                 else
                   pursuit[0] = pursuit[1] = pursuit[2] = 0;
                 } 
              }
            }
         if(i == 12 && flag == 0)
            for(i=0;i<3;pursuit[i++] = 0);
         }
       }
     if(police && rnd(100) < 15) {
       for(i=1;i<17;i++) {
          o = crumobj[i];
          if(*(o+3) != 0)
             break;
           }
       if(i < 17 && actmon(17,4,*(o+6),*(o+7)) > 0) {
          prnt("-> The guards are pursuing!");
          mode = 1;
          }
       }
     o = rumdata[crum];
     if(mode == 0 && rnd(100) < *(o+26)) {
       actmon(*(o+22),*(o+23),*(o+24),*(o+25));
       if(*(o+29) != 0)
         prnt(msg[*(o+29) + 80*dungeon]);
       if(mode && permon[*(o+22)][20] < 4 && (dungeon != 2 || crum != 31))
          prnt("      ***  A MELEE BEGINS!  ***");
       *(o+26) = *(o+27);
       }
     }
   monster = 0;
   for(i=0;i<12;i++) {
       c = curmon[i];
       if( *c == 1 && *(c+30) ==  crum) {
          if(i > 3 && *(c+31) < 4) {
             monster++;
             if(*(c+38) == 0)
               monster++;
             }
          grflist[0]++;
          grflist[grflist[0]] = i;
          *(c+16) -= 1;
          if(*(c+16) == 0) {
            actlist[0] += 1;
            actlist[actlist[0]] = i;
            }
          }
       }
   if(mode == 1 && monster < 2 && curmon[0][0] == 1 && curmon[0][30] == crum) { 
        mode = 0;
        undorep();
        }
   if(monster > 1 && curmon[0][0] == 1 && curmon[0][30] == crum) {
        mode = 1;
        }
   timer++;
   if(actlist[0] == 0 || !curmon[0][0] )
      continue;
   for(i=1;i<=actlist[0];i++) {
      n = actlist[i];
      c = curmon[n];
      if(*c && *(c+30) == crum)
        j = (*outverb[*(c+15)])(n);      
      if( (n == 0 || (n == 1 && *(c+38))) && j == 0 && (p=Bconstat(2)) != 0) {
        p = Bconin(2);
        if(p == 32) {
          *(c+16) = 0;
          j = 1;
          }
        }
      if(*(c+15) != 8 || !outside)
        trigtrol(n);
      if(curmon[0][0] == 0)
         return(-1);
      if(curmon[0][30] != crum)
         return(0);
      if(j == -1 && n == 0)
        return(0);
      if( n > 3 || (n < 4 && n > 0 && *(c+38) == 0))
           intell(n);
      else {
        if(*(c+16) == 0) {
           do {
              l = 1;
              if(j == 1) {
                 k = input(n); 
                 if(k == 1 && !combat) {
                    l = 0;
                    continue;
                    }
                 if(k == -1) {
                    if((k=error(17)) > 1) {
                       if(k == 2)
                          return(-2);
                       if(k == 3 && !outside && !fromout) {
                          k = error(19);
                          if(k == 1)
                            l = 0;
                          if(k == 2)
                            return(-4);
                          if(k == 3)
                            return(-5);
                          }
                       else
                          l = 0;
                       }
                    else 
                       l = 0;
                    }
                 if(l == 1)
                    l = (*inverb[k])(n);
                 if(l == -1)
                    return(-1);
                 }
              } while(l == 0);        
           }
         }
      }
   } while(1);   
}

extern int xmon(room,bit,x,y)
int room,bit,x,y;
{
extern char monbuf[];
char *r = monbuf;
int j,i = 1;
if(bit < 119 && bit > 115)
  bit = 110;
while(( *(r+i) != bit || *(r+i+1) != room || (*(r+i+3))%16 != x || 
      (*(r+i+3))/16 != y ) && i < 320) {
  i += 4;
  }
if(i >= 320)
  return(0);
for(j = i; j < i+4 ; j++)
  *(r+j) = 0;
return(1);
}



