/***************************************************************************/
/* TIMETROL() checks the pc's for the expiration of temporary events.      */
/***************************************************************************/

extern int timetrol()
{
extern int crum;
extern char specbuf[40],zline[16][8][7],rumdata[][157];
extern char *wordmod[],pname[],*name[],curmon[][60];
char *c,*w,*z;
int i,j,x,y;
for(i=0;i<12;i++) {
    c = curmon[i];
    if(*c == 0)
       continue;
    if(i < 4 && *(c+41) > 0 && *(c+30) == crum) { 
       *(c+41) -= 1; /* checks for burn out of torches */
       if(*(c+41) < 3) {
          if(i == 0)
             w = &pname[0];
          else
             w = name[*(c+3)];
          prnt("-> %s's torch flickers...",w);
          litetrol(*(c+24),*(c+25),0);
          litetrol(*(c+24),*(c+25),1);
          if(*(c+41) == 0) {
            prnt("-> ... and goes out!");
            if(rumdata[crum][30] == 0)
              litetrol(*(c+24),*(c+25),0);
            }
          }
       }
    if(*(c+47) > 0 && *(c+30) == crum) { /* poisoning depends on constitution */
       *(c+47) += 1;
       if( (*(c+47))%10 == 0) {
          if(i == 0)
             w = &pname[0];
          else
             w = name[*(c+3)];
          j = (4*(*(c+47)))/(*(c+2));
          if(j > 0) {
            if(i < 4 || *(c+58) == 16)
              prnt("-> %s's level of poisoning is %s!",w,wordmod[j]);
            else
              prnt("-> The %s's level of poisoning is %s!",w,wordmod[j]);
            if(*(c+47) >= *(c+2)) {
               *(c+1) = *(c+2);
               damage(i,1 + *(c+12));
               return(-1);
               }
            }
          }
       }          
    if( *(c+21) > 0) { /* checks for expiration of spells */
       *(c+21) -= 1;
       if( *(c+21) == 0) {
          *(c + *(c+19) ) = *(c+20);
          if(i == 0)
             w = &pname[0];
          else
             w = name[*(c+3)];
          if(i < 4)
             prnt("-> %s's spell has expired!",w);
          else
             prnt("-> The spell on the %s has worn off!",w);
          }
        }
     if(zline[*(c+24)][*(c+25)][6] > 0 && *(c+30) == crum && *(c+46) == 0)
       damage(i,20 + rnd(10));
     }
  if(specbuf[35] != 0) {
     specbuf[35]--;
     if(specbuf[35] == 0) {
       prnt("-> The Wallfire spell has expired!");
       x = specbuf[36]%16;
       y = specbuf[36]/16;
       for(i=x-1;i<=x+1;i++) {
          for(j=y-1;j<=y+1;j++) {
             z = zline[i][j];
             if( *z != 1)
                 continue;
             *(z+6) = 0;
             if(*(z+5) > 0)
               *(z+5) -= 1;
             if(*(z+5) > 0 || rumdata[crum][30])
                drawsq(i,j);
             else {
                setfill(2);
                fillsq(i,j);
                }
             }
          }
       }
     }
return(1);
}

