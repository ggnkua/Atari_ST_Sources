/****************************************************************************/
/* I5() initializes a DRAG/Eat function.  Clicking in the room gives a     */
/* move function.  The character can drop something from the inventory      */
/* while holding something else but he gets a significant time penalty.     */
/****************************************************************************/

extern int i5(pc)
int pc;
{
extern char weight[],invnpc[][20],curmon[][60],*name[],pname[];
extern char zline[16][8][7],crumobj[][9];
extern int outside,winker,handle,mode;
extern long int addr;
int self = 0,i,j = 0,k,ret,time;
int object,top=0,bot=0,type,x,y,oldy;
char *c = curmon[pc],*z,scratch[18],*w = (pc == 0 ? pname : name[*(c+3)]);
if(outside)
  return(0);
if(invnpc[pc][0] == 0 ) {
  type = 0;
  }
else {
  top = 3;
  bot = 2 + listinv(pc,scratch);
  type = 1;
  }
if(type == 0)
  header(w);
else {
  header("Eat");
  prhand(pc);
  }
if(!type)
  domsg(7);
winker = pc+1;
sgetxy(&x,&y,type,top,bot,&ret);
if(!type)
  undomsg();
winker = 0;
clrinp();
if((type == 1 && ret == 0) || type == 0) { /* this is a drag option */
  if(x == *(c+24) && y == *(c+25)) { /* going for an eat in hand */
    if(*(c+45) == 0 && (*(c+46) == 0 || *(c+46) == 81)) {
       error(27);
       return(0);
       }
    if(*(c+45) != 0 && *(c+46) != 0 && *(c+46) != 81) 
       self = error(31);
    else 
       self = (*(c+45) == 0 ? 2 : 1 );
    *(c+8) = *(c+44+self);
    *(c+10) = 1;
    *(c+15) = 5;
    *(c+16) = 4;
    return(1);
    }  /* now continue with drag */
  if((object = zline[x][y][1]) == 0) {
    error(23);
    return(0);
    } 
  if(crumobj[object][1] < 0) {
    error(24);
    return(0);
    }
  if(!adjac(pc,x,y)) {
    error(5);
    return(0);
    }
  if(*(c+45) > 0 && *(c+46) > 0) {
   error(29);
   return(0);
   }
  *(c+7) = *(c+8) = *(c+10) = 0;
  *(c+9) = object;
  header(w);
  domsg(1);
  winker = pc+1;
  sgetxy(&x,&y,0,0,0,&ret);
  undomsg();
  winker = 0;
  if(!lom(pc,x,y)) {
    error(1);
    return(0);
    }
  *(c+5) = x;
  *(c+6) = y;
  *(c+15) = 5;
  if(object > 0 && crumobj[object][0] < 41)
    time = 3*(*(c+50) - weight[crumobj[object][0]]);
  else
    time = 5;
  time = (time < 1 ? 4 : time);
  time = (time > 20 ? 20 : time); 
  *(c+16) = time;
  *(c+34) = 0;
  return(1);
  }
else {
  *(c+8) = scratch[ret];
  *(c+10) = 1;
  *(c+15) = 5;
  *(c+16) = 6;
  }
return(1);
}

/*****************************************************************************/
/* This is DRag/eat  out function.                                           */
/*****************************************************************************/

extern int o5(pc)
int pc;
{
extern char eats[],*obj[],pname[],zline[16][8][7],curmon[][60],crumobj[14][9];
extern char invnpc[][20],rumdata[][157],weight[],*name[],triglist[],invtrig[];
char *z,*c = curmon[pc],*w,*w1 = (pc == 0 ? &pname[0] : name[*(c+3)]);
extern int storbuf[][130],bitmap[][65],crum;
extern long int addr;
int flag = 1,x1,y1,x2,y2,i = 1,l,j = *(c+10),x = *(c+5),y = *(c+6),k;
if(!handman(pc,*(c+8),*(c+9),!j))
  return(1);
if(j == 1) {
  w = obj[*(c+8)];
  if(eats[*(c+8) - 40] == 0) {
    prnt("-> %s attempts to consume the %s, but such a thing is clearly \
impossible!  It is apparent that %s is becoming a little strange.",w1,w,w1);
    *(c+8) = 0;
    return(1);
    }
  else {
    prnt("-> %s swallows the %s!",w1,w);
    if(*(c+8) != *(c+45) && *(c+8) != *(c+46))
      takeout(pc,*(c+8));
    if(*(c+8) == *(c+45)) {
       *(c+45) = 0;
       return(1);
       }
    if(*(c+8) == *(c+46))
       *(c+46) = 0;
    return(1);
    }
  }        
if(j == 0) {
  j = *(c+9);
  x = crumobj[j][6];
  y = crumobj[j][7];
  if(!adjac(pc,x,y))
    return(1);
  k = crumobj[j][0];
  if(k < 41 && weight[k] < 0) {
     prnt("-> %s attempts to drag the %s, but that is impossible!",w1,obj[k]);
     return(1);
     }
  if(k < 41 && *(c+50) + rnd(3) < weight[k]) {
    flag = 1; 
    prnt("-> %s is unable to budge the %s.",w1,obj[k]);
    }
  else {  
    if(*(c+24) == *(c+5) && *(c+25) == *(c+6))
       return(1);
    nextxy(*(c+24),*(c+25),*(c+5),*(c+6),*(c+24),*(c+25),&x1,&y1);
    x2 = x + x1 - *(c+24);
    y2 = y + y1 - *(c+25);
    z = zline[x2][y2];
    if(*z != 1 || *(z+1) != 0 || (*(z+2) > 0 && *(z+2) != pc) ||
       (curmon[0][24] == x2 && curmon[0][25] == y2 && pc != 0) ) {
      flag = 1;
      prnt("-> The %s which %s is moving is blocked!",obj[crumobj[j][0]],w1);
      }
    else {
      *(c+26) = *(c+5);
      *(c+27) = *(c+6);
      flag = 1;  
      if(i4(pc)) {
        flag = o4(pc);
        *(c+9) = j;
        move(j,0,x2,y2);
        }
      *(c+15) = 5;
      if(!flag) {
        if(k < 41)
           *(c+16) += 4 - *(c+50) + weight[k];
        *(c+16) = (*(c+16) < 0 ? 1 : *(c+16));
        }
      }
    }
  }
return(flag);
}


extern int header(string)
char *string;
{
extern int handle;
int i = strlen(string);
v_rvon(handle);
vs_curaddress(handle,1,33);
printf("        ");
v_rvoff(handle);
vsf_interior(handle,0);
vsf_style(handle,0);
vsf_color(handle,0);
i = (11 - i)/2;
textsix(1,260 + 6*i,1,strlen(string),string);
}

extern int prhand(pc)
int pc;
{
extern int handle;
extern char curmon[][60],*obj[];
char scratch[12],*c = curmon[pc];
int i;
v_rvon(handle);
for(i=2;i<=3;i++) {
  vs_curaddress(handle,i,33);
  printf("        ");
  }
v_rvoff(handle);
for(i=0;i<2;i++) {
  if(*(c+45+i) != 0)
    sprintf(scratch,"%s",obj[*(c+45+i)]);
  else
    sprintf(scratch,"%s","Empty");
  textsix(1,260,9+8*i,strlen(scratch),scratch);
  }
return(1);
}

extern int handman(pc,inv,rum,flag)
int pc,inv,rum,flag;
{
extern char crumobj[][9],*obj[],curmon[][60],pname[],*name[];
char *c = curmon[pc],*w1 = (pc == 0 ? pname : name[*(c+3)]);
int l;	
if(rum != 0 || (flag == 1 && inv != *(c+45) && inv != *(c+46)) ) {
  if(*(c+45) > 0 && *(c+46) > 0) {
      l = (*(c+46) != 81 ? 1 : 0);
      if(putaway(pc,*(c+45+l)) == 0 && pc != 3) {
         error(7);
         return(0);
         }
      if(inv != 0 && pc != 3)
         prnt("-> %s puts away the %s in order to handle the %s.",
           w1,obj[*(c+45+l)],obj[inv]);
      if(rum != 0 && pc != 3)
         prnt("-> %s puts away the %s to free a hand.",w1,obj[*(c+45+l)]);
      *(c+45+l) = 0;
      }
  }
return(1);
}
