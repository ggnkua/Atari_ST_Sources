/******************************************************************************/
/* I2() initializes the use of magic.                                         */
/******************************************************************************/

#include "osbind.h"

extern int i2(pc)
int pc;
{
extern char spelinfo[][3],crumobj[][9],zline[16][8][7],*spell[],curmon[][60];
extern int outside,handle,mode,vbl(),off(),winker;
extern char invnpc[][20],pname[],*name[];
int i,j,k,numb,x,y,status,ret;
char *z,*c = curmon[pc],scratch[3],*w = (pc == 0 ? pname : name[*(c+3)]);
if(outside)
  return(0);
if(*(c+14) <= 0) {
  error(13);
  return(0);
  }
top(1);
clrinp();
do {
    vq_mouse(handle,&status,&x,&y);
   } while (status != 0);
xbios(37);
xbios(38,off);
undorep();
for(i=0;i<25;i++) {
  textsix(1,258,1 + 8*i,strlen(spell[i]),spell[i]);
  sprintf(scratch,"%d",1 + (i/5));
  if(i != 24)
    textsix(1,314,1+8*i,1,scratch);
  }
xbios(37);
xbios(38,vbl);
sgetxy(&x,&y,2,0,24,&numb);
top(1);
xbios(37);
clrinp();
xbios(37);
undorep();
if(mode)
  dorep();
if(numb == 24)
  return(0);
numb++;
if((numb-1)/5 > (*(c+51) + 1)/2) {
   error(28);
   return(0);
   }
if( 1 + (numb-1)/5 > *(c+14)) {
 error(13);
 return(0);
 }
if((i = spelinfo[numb-1][1]) > 0) {
  domsg(i);
  header(w);
  winker = pc + 1;
  sgetxy(&x,&y,0,0,0,&ret);
  undomsg();
  winker = 0;
  if(!los(pc,x,y)) {
    error(3);
    return(0);
    }
  z = zline[x][y];
  j = spelinfo[numb-1][0];
  if(j == 1 && *(z+2) == 0 ) {
    error(8);
    return(0);
    }
  if(j == 2 && *(z+1) == 0) {
    error(23);
    return(0);
    }
  if(j == 3 && ( *(z+2) == 0 && (x != *(c+24) || y != *(c+25)) ) ) {
    error(8);
    return(0);
    }
  *(c+9) =  *(z+1);
  *(c+8) = 0;
  *(c+7) = *(z+2);
  *(c+5) = x;
  *(c+6) = y;
  }
if(numb == 24) {
      k = 0;
      if(*(c+45) == 80 || *(c+46) == 80)
        k = 1;
      for(j=1;j<invnpc[pc][0];j++) {
         if(invnpc[pc][j] == 80) {
            k = 1;
            break;
            }
         }
      if(k == 0) {
         prnt("-> %s does not have a seekshard to trigger the teleport spell!",
               w);
         return(0);
         }
      }
if(numb == 13) { /* asshole wants to blink */
  domsg(1);
  header(w);
  winker = pc + 1;
  sgetxy(&x,&y,0,0,0,&ret);
  winker = 0;
  undomsg();
  if(!los(pc,x,y) || zline[x][y][0] != 1) {
    error(3);
    return(0);
    }
  if(zline[x][y][1] != 0 && crumobj[zline[x][y][1]][0] < 41) {
    error(1);
    return(0);
    }
  *(c+26) = x;
  *(c+27) = y;
  }
*(c+10) = numb;
*(c+15) = 2;
*(c+16) = spelinfo[numb-1][2];
*(c+14) -= 1 + (numb-1)/5;
return(1);
}  

extern int o2(pc)
int pc;
{
extern char spelinfo[][3],zline[16][8][7],curmon[][60],crumobj[][9],triglist[];
extern char *name[],*spell[],pname[],rumdata[][157];
extern char *obj[],invnpc[][20],specbuf[40],putbuf[],junk[];
extern int crum,handle,mode,bitmap[][65],vbl(),off(),dismax,storbuf[][130];
extern int pursuit[];
extern long int addr;
char *z,*p,*c = curmon[pc],*t,*w,*wt;
int k,m,flag=0,dam,j,trap,num,target,type,i,x,y;
w = (pc == 0 ? pname :  name[*(c+3)]);
if(pc > 3) {
   if(*(c+58) != 16) {
     sprintf(junk,"%s","The ");
     sprintf(&junk[4],"%s",w);
     w = junk;
     }
   num = *(c+10);
   target = *(c+39);
   t = curmon[*(c+39)];
   if(!los(pc,*(t+24),*(t+25)))
       flag = 1; 
   wt = ( *(c+39) == 0 ? pname : name[*(t+3)]);
   }
if(pc < 4) {
   flag = 0;
   num = *(c+10);
   if(spelinfo[num-1][0] != 2) {
     target = *(c+7);   
     t = curmon[target];
     if( !*t || *(t+30) != crum || !los(pc,*(t+24),*(t+25)) ) 
         flag = 1;
     wt = (target == 0 ? pname : name[*(t+3)]);
     } 
   else {
     target = *(c+9);
     t = crumobj[target];
     wt = obj[*t];
     if(*t == 0) 
       flag = 1;
     }
   }
if(spelinfo[num-1][0] == 0)
  flag = 0;
if(flag) {
       prnt("-> %s's %s Spell has no target!",w,spell[num - 1]);
       return(1);
       }
if(num != 13)
  prnt("-> %s casts the %s Spell!",w,spell[num-1]);
flash();
switch (num) {
   case 1:  /* cure light wounds but not poison */
      *(t+1) -= 5 + curmon[pc][51] + rnd(20);
      if(*(t+1) < 0)
        *(t+1) = 0;     
      break;
   case 2: /* heavy duty search */
      num = *(c+37);
      *(c+37) = 120;
      o6(pc);
      *(c+37) = num;
      break;
   case 3:  /* the infamous freeze spell */
      if(savthrow(target,*(c+51)))
         break;
      if(*(t+16) == 0) {
        prnt("-> The spell fails!");
        break;
        }
     losespel(target);
     *(t+16) = 50 + 5*(*(c+51));
     *(t+19) = 0;
     *(t+20) = 1;
     *(t+21) = (*(t+16))/5;
     break;
   case 4:  /* the unvenom spell */
     *(t+47) = 0;
     break;
   case 5:  /* vorpal blade */
     if(target > 3)
       break;
     losespel(target);
     *(t+20) = *(t+43);
     *(t+43) = 1;
     *(t+19) = 43;
     *(t+21) = 20 + 2*(*(c+51));
     break;
   case 6:  /* speed spell */
     losespel(target);
     *(t+20) = *(t+11);
     *(t+11) = 1;
     *(t+19) = 11;
     *(t+21) = 20 + 2*(*(c+51));
     break;
   case 7:  /* armor spell */
     losespel(target);
     *(t+20) = *(t+12);
     *(t+12) += *(c+51);
     *(t+19) = 12;
     *(t+21) = 20 + 2*(*(c+51));
     break;
   case 8: /* disarm trap */
      trap = *(t+2);
      if(trap > dismax || trap == 0)
        return(1);
      *(t+2) = 0;
      untrap(target);
      break;
   case 9: /*  bolt */
   case 12: /* fireball */
   case 16: /* prism */
      if(num == 9) {
         dam = 10;
         j = 1;
         }
      if(num == 12) {
         dam = 20;
         j = 0;
         }
      if(num == 16) {
         dam = 40;
         j = 2;
         }
      if(!los(pc,*(t+24),*(t+25))) {
         prnt("-> But the target is out of sight!");
         return(1);
         }
      xbios(37);
      xbios(38,off);
      fireball(*(c+24),*(c+25),*(t+24),*(t+25),j);
      explode( *(t+24), *(t+25) ,j);
      if(savthrow(target,*(c+51)))
         break;
      damage(target, dam + rnd(10));
      break;
   case 10: /* thief spell */
      num = *(c+37);
      *(c+37) = 120;
      o10(pc);
      *(c+37) = num;
      break;
   case 11:  /* fear spell */
      if(savthrow(target,*(c+51)))
         break;
      losespel(target);
      *(t+20) = *(t+36);
      *(t+36) = 1;
      *(t+19) = 36;
      *(t+21) = 40 + 2*(*(c+51));
      damage(target,0);
      break;
   case 13:  /* blink spell */
      if(zline[*(c+26)][*(c+27)][2] != 0) {
        prnt("-> %s's blink spell fails!",w);
        break;
        }
      x = *(t+24);
      y = *(t+25);
      *(t+35) = 0;
      prnt("-> %s blinks out of reality for an instant!",wt);
      explode(x,y,0);
      xbios(37);
      storsc(storbuf[target],16*x,16*y,1,addr);
      zline[x][y][2] = 0;
      *(t+24) = *(c+26);
      *(t+25) = *(c+27);
      zline[*(t+24)][*(t+25)][2] = target;
      if(target < 4 && *(t+41) > 0)
         setlite(target,*(t+24) - x,*(t+25) - y); 
      x = *(c+26);
      y = *(c+27);
      if(zline[*(t+24)][*(t+25)][5] > 0 || rumdata[crum][30]) {
        explode(x,y,0);
        drawsq(x,y);
        }
      *(t+15) = 8;
      break;
   case 14: /* reveal */
      for(i=1;i<19;i++) {
          c = crumobj[i];
          if(*(c+8) == 0) {
             *(c+8) = 1;
             zline[*(c+6)][*(c+7)][1] = i;
             if(rumdata[crum][30] || zline[*(c+6)][*(c+7)][5] > 0)
                blt(bitmap[*c],16*(*(c+6)),16*(*(c+7)),addr);
              }       
          }
      break;
    case 15: /* heal, you sumbitch */
      *(t+1) = 0;
      *(t+47) = 0;
      break;
    case 17: /* block head */
      flag = 0;
      for(i=0;i<4;i++) {
        if(curmon[i][0] && curmon[i][30] == pursuit[2]) {
           prnt("-> %s holds the %s spell to wait for friends!",w,spell[num-1]);
           flag = 1;
           break;
           }
        }
      if(flag) {
        *(t+16) = 6;
        return(0);
        }
      if(pursuit[2] == *(t+3))
         pursuit[0] = pursuit[1] = pursuit[2] = 0;
      break;
    case 18: /* charm old scratch */
      if(savthrow(target,*(c+51)))
         break;
      losespel(target);
      *(t+38) = 1;
      *(t+20) = 0;
      *(t+19) = 38;
      *(t+21) = 20 + 2*(*(c+51));
      dorep();
      break;
    case 19: /* firewall */
      if(specbuf[35] != 0) {
        prnt("-> The existing wall of fire prevents a second spell!");
        break;
        }
      specbuf[35] = *(c+51)/3;
      specbuf[36] = *(c+5) + 16*(*(c+6));
      for(i= -1;i < 2 ;i++) {
          for(j= -1;j < 2;j++) {
            z = zline[*(c+5) + i][*(c+6) +j];
            if(*z == 1) {
               *(z+6) = 1;
               *(z+5) += 1;
               drawsq(*(c+5) + i, *(c+6) + j);
               }
             }
          }
      break;
    case 20:  /* destroy an object */
      if(*(t+2) > dismax || *(t+3) > 0 || *t == 1) {
        prnt("-> The spell inexplicably fails!");
        break;
        }
      explode(*(t+6),*(t+7),0);
      destroy(1,target);
      break;
    case 21: /* summon some kinda monsters */
      j = 1 + rnd(7);
      i = 1 + rnd(6);
      if(pc < 4) {
        x = *(c+5);
        y = *(c+6);
        }
      else {
        x = *(t+24);
        y = *(t+25);
        }
      actmon(j,i,x,y);
      for(i=4;i<12;i++) {
        if(curmon[i][58] == j)
          curmon[i][38] = 1;
        }
      dorep();
      break;
    case 22: /* death */
      if(savthrow(target,*(c+51)))
         break;  
      *t = 0;
      damage(target,1 + *(t+2) + *(t+12));
      break;
    case 23: /* bringin back the dead */
      if(*t < 38 || *t > 40) {
        prnt("-> The life spell does not work on %ss!",wt);
        break;
        }
      k = 41 - *t;
      for(i=0;i<14;invnpc[k][i++] = 0);
      if(target > 13)
        xobj(*t,crum);
      p = putbuf;
      m = 0;
      while(m < 320) {
        if(*(p+m+3) != crum || *(p+m+2) != target) {
          m += 4;
          continue;
          }
        putaway(k, *(p+m+1));
        *(p+m) = *(p+m+1) = *(p+m+2) = *(p+m+3) = 0;
        }
      x = *(t+6);
      y = *(t+7);
      destroy(1,target);
      explode(x,y,0);
      actmon(-k,1,x,y);         
      prnt("-> Eirik shakes his head and mutters `Crom, my eyes spin! But \
I still live! I do not wish to know the ensorcelment used to do this.'");
      break;
   case 24:  /* time to teleport */
      if( (k = *(c+52)) == 0) {
        prnt("-> The teleport invocator cannot find the inline mana thread!");
        break;
        }
      crum = -1;
      x = (*(c+53))%16;
      y = (*(c+53))/16;
      for(j= 0;j<4;j++) {
        c = curmon[j];
        if(*c == 1) {
          *(c+24) = x + j/2 - (j%2);
          *(c+25) = y - (j+1)/2 + ((j+1)%2);
          *(c+30) = k;
          }
        }
   }
return(1);
}

extern int flash()
{
extern int handle,off(),vbl(),newpal[];
int i,j,funk[3];
xbios(37);
xbios(38,off);
for(i=0;i<30;i++) {
  for(j=2;j<15;j++) {
    funk[0] = rnd(1000);
    funk[1] = rnd(1000);
    funk[2] = rnd(1000);
    vs_color(handle,j,funk);
    }
  xbios(37);
  }
Setpallete(newpal);
xbios(37);
xbios(38,vbl);
}

losespel(pc)
int pc;
{
extern char pname[],*name[],curmon[][60],*rummsg[],*msg[];
char *c = curmon[pc],*w = (pc == 0 ? pname : name[*(c+3)]);
char *n = (pc < 4 ? rummsg[0] : msg[0]);
if( *(c+21) != 0) {
       prnt("-> The original spell on %s%s was lost!",n,w);  
       *(c + *(c+19)) = *(c+20);
       *(c+21) = 0;
       }
}

extern int savthrow(npc,mag)
int npc,mag;
{
extern char curmon[][60],*name[],pname[];
char *c = curmon[npc],*w = (npc == 0 ? pname : name[*(c+3)]);
if(rnd(100) < (*(c+51) - mag)*8 || *(c+54) > 0) {
  if(npc < 4 || curmon[npc][3] == 10)
    prnt("-> %s resists the spell!",w);
  else
    prnt("-> The %s resists the spell!",w);
  return(1);
  }
return(0);
}
