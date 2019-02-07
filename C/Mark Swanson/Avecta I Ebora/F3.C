/******************************************************************************/
/* I3(NPC) initializes an EXAMINE action.  It simply determines if the charac */
/* can see the object.                                                        */
/******************************************************************************/

extern int i3(pc)
int pc;
{
extern char invnpc[][20],curmon[][60],zline[16][8][7],pname[],*name[];
extern int winker,handle;
int i,bot=0,top1=0,type,x,y,ret;
char *c = curmon[pc],z1,z2,scratch[15];
char *w = (pc == 0 ? pname : name[*(c+3)]);
if(invnpc[pc][0] == 0 && *(c+45) == 0 && (*(c+46) == 0 || *(c+46) == 81) ) 
  type = 0;
else {
  top(1);
  clrinp();
  bot = 2 + listinv(pc,scratch);
  type = 1;
  top1 = 3;
  }
if(type == 0) {
  header(w);
  domsg(6);
  }
else
  header("Examine");
winker = pc+1;
sgetxy(&x,&y,type,top1,bot,&ret);
if(!type)
  undomsg();
winker = 0;
top(2);
clrinp();
if(ret == 0) {
z1 = zline[x][y][1];
z2 = zline[x][y][2];
if(!los(pc,x,y)) {
  error(3);
  return(0);
  }
if(z2 == 0 && z1 != 0 && !adjac(pc,x,y)) {
  error(11);
  return(0);
  }
if(z1 != 0 && z2 != 0 ) {
  error(12);
  return(0);
  }
if(!z1 && !z2 && (*(c+24) != x || *(c+25) != y)) {
  error(4);
  return(0);
  } 
if(*(c+24) == x && *(c+25) == y  && !*(c+45) && (!*(c+46) || *(c+46) == 81)) {
  error(4);
  return(0);
  }
*(c+7) = *(c+8) = *(c+9) = 0;
*(c+10) = (!z1 ? 2 : 1);
*(c+7) = z2;
*(c+9) = z1;
if(*(c+24) == x && *(c+25) == y) {
  *(c+10) = 3;
  *(c+8) = (*(c+45) == 0 ? *(c+46) : *(c+45) );
  if(*(c+45) != 0 && *(c+46) != 0 && *(c+46) != 81) {
    i = error(31);
    *(c+8) = *(c+44+i);
    }
  *(c+7) = *(c+9) = 0;
  }
}
else {
  *(c+10) = 3;
  *(c+8) = scratch[ret];
  }
*(c+15) = 3;
*(c+16) = 6;
*(c+34) = 0;
return(1);
}

/*****************************************************************************/
/* O3(pc) is a call to output an EXAMINE function.                           */
/*****************************************************************************/

extern int o3(pc)
int pc;
{
extern char curmon[][60],crumobj[14][9],zline[16][8][7],pname[],*name[];
extern char rumdata[][157],*obj[],*msg[],*monmsg[];
extern int mode,crum,dungeon,outside,fromout;
char *c = curmon[pc],*t,*w,*w1,scratch[10];
int flag,i,type,x= *(c+24),y= *(c+25),object,mess;
type = *(c+10);
w1 = (pc == 0 ? &pname[0] : name[*(c+3)]);
if( (type == 3 && (object = *(c+8)) > 40) || 
    (!outside && type == 1 && (object = *(c+9)) > 40) ) {
        if(type == 3 && *(c+8) != *(c+45) && *(c+8) != *(c+46)) {
          if(!handman(pc,*(c+8),0,1))
                return(1);
          if(*(c+46) == 0)
              *(c+46) = *(c+8);
          else
              *(c+45) = *(c+8);
          takeout(pc,*(c+8));
          object = *(c+8);
          prnt("-> %s takes out the %s to examine.",w1,obj[object]);
          }
        prnt("-> %s examines the %s.",w1,obj[object]);
        if(!rumdata[crum][30] && !zline[x][y][5]) {
           prnt("-> It is too dark for %s to see anything!",w1);
           return(1);
           }
        prnt(msg[object]);
        return(1);
        }
if(type == 2) 
   object = *(c+7);
if(type == 2 && !los(object,*(c+24),*(c+25))) {
  prnt("-> The object which %s was examining has moved out of sight.",
       w1);
  return(1);
  }
if(type == 1)
  object = *(c+9);
t = (type == 1 ? crumobj[object] : curmon[object] );
if(type == 2) {
  w = name[*(t+3)];
  }
else {
  w = obj[*t];
  if(*(t+4) > 0 && *t < 41) {
     mess = *(t+4) + (1-outside)*80*dungeon;
     if(fromout > 0)
        mess -= 80;
     }
  if(*(t+4) > 0 && *t > 40)
     mess = *(t+4);
  if(*(t+4) == 0)
     mess = 0;
  }
if(!outside && !fromout && (type != 2 || *(c+7) ))
  prnt("-> %s examines the %s.",w1,w);
if(type == 2 ) {
  if(*(t+39) != pc) {
     if(*(t+39) == 0)
       w1 = pname;
     if(*(t+39) > 0 && *(t+39) < 4)
       w1 = name[curmon[*(t+39)][3]];
     if((*(t+39) > 3 || *(t+38) == 1) && *(t+31) < 3) {
       if(mode)
         sprintf(scratch,"%s","its enemy");
       else {
         if(*(t+38))           
           sprintf(scratch,"%s","a friend");
         }
       w1 = scratch;
       }
     }
  prnt(monmsg[*(t+3)],w1);
  return(1);
  }
flag = 0;
if(type == 1 && mess == 0 && *(t+5) == -1 && *(t+3) == 0 && ( *(t+2) == 0 ||
   rnd(100) > *(c+37) ) ) { 
  prnt("-> %s notices nothing unusual.",w1);
  return(1);
  }
if(!outside && type == 1 && *(t+2) != 0 && *(c+37) > rnd(100)) {
  flag = 1; 
  prnt("-> %s senses something strange about the %s.",w1,w);
  }
if(mess != 0) {
  prnt(msg[mess]);
  return(1);
  }
if(!outside && type == 1 && mess == 0 && *(t+3) != 0) {
  flag = 1;
  prnt("-> %s notices an exit through the %s.",
       w1,w);
  }
if(type == 1 && *(t+5) == -2) {
  flag = 1;
  prnt("-> %s notices the %s is locked.",w1,w);
  }
if((type == 1 || mess == 0) && !flag) 
  prnt("-> %s notices nothing unusual.",w1);
*(c+18) = 3;
return(1);
}

