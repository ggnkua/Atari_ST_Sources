/****************************************************************************/
/* ACTMON(TYPE,NUMBER,X,Y) activates the number of type monsters around and */
/* including the position x,y.                                              */
/****************************************************************************/

extern int actmon(type,nm,x,y)
int type,nm,x,y;
{
extern char zline[16][8][7],crumobj[][9],curmon[][60],permon[][23];
extern int mode,crum,bitmap[][65],storbuf[][130];
extern long int addr;
char *z,*c,*p;
int adder,i,j=0,k,l;
if(type < 0) {
  type = abs(type);
  c = curmon[type];
  for(i=0;i<60;i++)
      *(c+i) = 0;
  p = permon[type+7];
  for(i=0;i<15;i++)
      *(c+i) = *(p+i);
  *(c+50) = *(p+15);
  *(c+42) = 10;
  *(c+32) = *(c+45) = *(p+16);
  *(c+46) = *(p+17);
  *(c+37) = *(p+18);
  *(c+51) = *(p+19);
  *(c+24) = x;
  *(c+25) = y;
  *(c+15) = 8;
  *(c+16) = 1;
  *(c+30) = crum;
  *(c+39) = i;
  zline[x][y][2] = type;
  drawman(type,x,y);
  return(1);
  }
p = permon[type];
for(i=4;i<12;i++) {
  c = curmon[i];
  adder = 0;
  if(*c == 0 || *(c+30) != crum) {
    z = zline[x][y];
    if(*z == 1 && (*(z+1) == 0 || crumobj[*(z+1)][0] > 40) && *(z+2) == 0 && 
       (curmon[0][24] != x || curmon[0][25] != y) ) { 
       zline[x][y][2] = i;   /* then square is available */
       *(c+24) = x;
       *(c+25) = y;
       adder = 1;
       }
    else { /* must root for adjacent square to dump monster into */
       k = -2;
       l = -1;
       do {
           k++;
           if(k == 2) {
              k = -2;
              l++;
              }
           z = zline[x+k][y+l];
           if(k == -2 || *z != 1 || *(z+2) != 0 || (curmon[0][24] == (x+k) && 
                  curmon[0][25] == (y+l)) || 
                  (*(z+1) > 0 && crumobj[*(z+1)][0] < 41) ) 
               continue;  /* if it doesn't continue then square available */
           else {
               *(z+2) = i;
               *(c+24) = x+k;
               *(c+25) = y+l;
               adder = 1;
               break;
               }
           } while ( l != 1 || k != 1); 
       }    
    }
  if(adder == 0)
    continue;
  j++;
  for(k=0;k<60;k++) { 
       if(k == 24 || k == 25)
         continue;
       *(c+k) = 0;
       }
  for(k=0;k<15;k++)
       *(c+k) = *(p+k);
  *(c+50) = *(p+15);   /* physical strength */
  *(c+45) = *(p+16);   /* poison mode */
  *(c+41) = *(p+17);   /* base chance #1 attack */
  *(c+42) = *(p+18);   /* base chance #2 */
  *(c+43) = *(p+19);   /* base chance #3 */
  *(c+31) = *(p+20);   /* intell routine */
  *(c+44) = *(p+21);   /* bane */
  *(c+46) = *(c+54) = *(p+22);  /* magic mode, can be hit by magic? */
  *(c+58) = type;  /* record type of monster */
  *(c+51) = (*(c+14))/3;  /* magic level is one-third of spelunits */
  if(*(c+51) > 20)
    *(c+54) = 1;  /* then he is immune to magic as in p+22 */
  *(c+15) = 8;  /* installed with a wait */
  *(c+16) = 1;
  *(c+30) = crum;
  *(c+39) = i;
  if(type == 18)
     *(c+4) = 116 + rnd(3);
  drawman(i,*(c+24),*(c+25));
  *(c+26) = curmon[0][24];
  *(c+27) = curmon[0][25];
  if(j == nm )
    break;
  }
if(j>0 && *(c+31) < 4) {
  mode = 1;
  dorep();
  }
else
  mode = 0;
if(nm == 1) {
  if(i > 0)
    return(i);
  else
    return(-1);
  }
return(j);
}
       
