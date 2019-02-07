

extern int i1(pc)
int pc;
{
extern int outside,combat;
extern char curmon[][60],zline[16][8][7];
char *c = curmon[pc],*t = curmon[*(c+39)];
int x = *(t+24),y = *(t+25);
if(outside)
  return(0);
combat = 0;
if(!adjac(pc,x,y)) {
  error(9);
  return(0);
  }
if(pc < 4 && (*(c+45) > 45 || *(c+45) < 41) ) {
  error(20);
  return(0);
  }
if(pc == 0 && *(c+45) == 45 && *(c+46) != 0) {
  error(22);
  return(0);
  }
if(pc < 4 && pc > 0)
  *(c+7) = *(c+39);
*(c+15) = 1;
*(c+16) = *(c+11);
*(c+9) = 0;
return(1);
}

extern int o1(pc) 
int pc;
{
extern char curmon[][60],zline[16][8][7];
extern char wepmatx[4][4],weapon[][3],pname[],*name[];
extern int row,col,crum;
char *a = curmon[pc],*t = curmon[*(a+39)],*w;
int bonus = 0,base,roll,dam,armor,wepchanz,i;
if(*t == 0 || *(t+30) != crum)
  return(1);
if(!adjac(pc,*(t+24),*(t+25))) {
  return(1);
  }
attack(pc,*(t+24),*(t+25));
if(pc < 4 && *(t+46) && !*(a+43)) {
  *(a+34) = -1;
  return(1);
  }
if(pc < 4) 
   wepchanz = weapon[*(a+45) - 40][0] + 20*(*(a+43));
if(pc < 4 && *(a+51) > 5)
   wepchanz /= *(a+51) - 4;
else
   wepchanz = *(a + 40 + *(a+40) );
if(*(t+39) == pc)
   wepchanz += wepmatx[*(a+40)][*(t+40)];
else
   wepchanz += 40;   /* big bonus for blind side shots */         
roll = rnd(100);
base = wepchanz + 3*( *(a+50) - 10 + *(a+11) - *(t+11) );   
if(pc < 4) 
  dam = weapon[*(a+45) - 40][1];
else
  dam = *(a + 3 + 2*(*(a+40)) );
if(pc > 3)
  dam = 1 + rnd(dam);
else
  dam += rnd(dam/2);
if(pc < 4 && *(t+31) > 3) {
  base += 200;
  dam += 10;
  }
if(pc < 4)
  *(a+8) = *(a+45);
if(base > roll && dam > 0) {
     if(pc > 3 && *(a+40) == *(a+45) && *(t+47) == 0) {
        w = ( *(a+39) == 0 ? pname : name[curmon[*(a+39)][3]]);
        if(*(a+39) < 4)
          prnt("-> %s is envenomed!",w);
        else
          prnt("-> The %s is envenomed!",w);
        *(t+47) = 1;
        }
     if(pc < 4)
        *(a+34) = 1;
     return(damage(*(a+39),dam));
     }
else {
  if(pc < 4)
    *(a+34) = -1;
  }   
return(1);
}

