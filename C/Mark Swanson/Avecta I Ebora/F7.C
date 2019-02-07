/******************************************************************************/
/* I7() is a  call to initialize a TAKE/DROP.      It must be adjacent and    */
/* takeable, which means its type must be greater than 40.                    */
/******************************************************************************/

extern int i7(pc)
int pc;
{
extern char invnpc[][20],crumobj[14][9],zline[16][8][7],curmon[][60];
extern int outside,mode,winker;
extern char pname[],*name[];
char *z,*c = curmon[pc],scratch[15],*w = (pc == 0 ? pname : name[*(c+3)]);
int object,x,y,j,k,l,self,num=0,bot=0,top1=3,type,ret=0;
if(outside)
  return(0);
if(invnpc[pc][0] == 0 && *(c+45) == 0 && (*(c+46) == 0 || *(c+46) == 81) )
  type = 0;
else {
  bot = 2+listinv(pc,scratch);
  type = 1;
  }
if(type == 0)
  domsg(2);
if(!type) 
   header(w);
else {
  header("Drop");
  prhand(pc);
  }
winker = pc+1;
sgetxy(&x,&y,type,top1,bot,&ret);
if(type == 0)
  undomsg();
winker = 0;
top(1);
clrinp();
self = ( x == *(c+24) && y == *(c+25) ? 1 : 0);
if(ret == 0 && !self) {
  if( (object = zline[x][y][1]) == 0) {
    error(6);
    return(0);
    }
  if(crumobj[object][1] != 1 || crumobj[object][0] < 41 ) {
    error(6);
    return(0);
    }
  if(!adjac(pc,x,y)) {
    error(5);
    return(0);
    }
  if(invnpc[pc][0] == 13) {
    error(7);
    return(0);
    }
  }
*(c+7) = *(c+8) = *(c+9) = 0;      
if(ret == 0 && !self) {
  *(c+9) = zline[x][y][1];
  *(c+10) = 0;
  *(c+15) = 7;  
  *(c+16) = 6;
  return(1);
  }
else { /* this is a drop out of inventory */
  if(self) {
    if(*(c+45) == 0 && (*(c+46) == 0 || *(c+46) == 81)) {
       error(27);
       return(0);
       }
    if(*(c+45) > 0 && *(c+46) > 0 && *(c+46) != 81) 
       l = error(31);
    else
       l = ( *(c+46) == 0 || *(c+46) == 81 ? 1 : 2);
    ret = l;
    }
  header(w);
  domsg(4);
  winker = pc + 1;
  sgetxy(&x,&y,0,0,0,&k);
  winker = 0;
  undomsg();
  if(!adjac(pc,x,y)) {
    error(11);
    return(0);
    } 
  z = zline[x][y];
  if( *z == 0 || ( (k = *(z+1) ) != 0 && crumobj[k][5] < 0) )  {
    error(12);
    return(0);
    }
  *(c+8) = scratch[ret];
  *(c+7) = *(c+9) = 0;      
  if(k != 0)
     *(c+9) = k;
  *(c+5) = x;
  *(c+6) = y;
  *(c+10) = 1;
  *(c+15) = 7;
  *(c+16) = 2;
  if(*(c+8) != *(c+45))
    *(c+16) += 4;
  return(1);
  }
}

/****************************************************************************/
/* TAKE/DROP output function.                                               */
/****************************************************************************/

extern int o7(pc)
int pc;
{
extern char invnpc[][20];
extern char *obj[],curmon[][60],crumobj[14][9],zline[16][8][7],pname[];
extern char rumdata[][157],trigval[][6],*name[],invtrig[],triglist[];
extern int crum,bitmap[][65],storbuf[][130];
extern long int addr;
char *z,*c = curmon[pc],*t,*w,*w1 = (pc == 0 ? pname : name[*(c+3)]);
int i,k,l,inv = *(c+8),r = *(c+9),x = *(c+5),y = *(c+6),j = *(c+10),id;
*(c+18) = 7;
if(j > 0)
  r = 0;
if(!handman(pc,inv,r,j))
  return(1);
if(j > 0 && (k = zline[x][y][1]) == 0 && slotnum() == 0) {
  prnt("-> Supernatural forces prevent %s from dropping the %s!",w1,
       obj[*(c+8)]);
  return(1);
  }
if(j > 0 && k != 0) {
  prnt("-> %s puts the %s in the %s.",w1,obj[*(c+8)],obj[crumobj[k][0]]);
  crumobj[k][5] = 1;
  takeout(pc,*(c+8));
  if(*(c+45) == *(c+8))
    *(c+45) = 0;
  else {
    if(*(c+46) != 81 && *(c+45) != 0 && *(c+46) == *(c+8))
      *(c+46) = 0;
    }
  putinto(k,*(c+8));  
  }
if(j > 0 && k == 0) {
  *(c+9) = 0;
  i = rumslot();
  prnt("-> %s puts the %s down.",w1,obj[*(c+8)]);
  z = crumobj[i];
  if(i > 13) { 
     storobj(*(c+8),x,y);
     rumdata[crum][134+i] = *(c+8);
     }
  takeout(pc,*(c+8));
  if(*(c+45) == *(c+8))
      *(c+45) = 0;
  if(*(c+46) == *(c+8))
      *(c+46) = 0;
  if(pc < 4 && *(c+32) == *(c+8)) {
      *(c+32) = 0;
      for(j=1;j<14;j++) {
         if(invnpc[pc][j] < 46 && invnpc[pc][j] > 40) {
            *(c+32) = invnpc[pc][j];
            break;
            }
         }
      }
  *z = *(c+8);
  *(z+1) = 1;
  *(z+6) = x;
  *(z+7) = y;
  *(z+4) = *(c+8);
  *(z+5) = -1;
  *(z+8) = 1;
  *(z+2) = *(z+3) = 0;
  zline[x][y][1] = i;
  if(zline[x][y][5] > 0 || rumdata[crum][30])
    drawsq(x,y);
   }
if(j > 0) {
  for(k=0;k<40;k++) {
    if(*(c+8) == 0)
       break;
    if(invtrig[k] == *(c+8)) {
      for(l=1;l<14;l++) {
         if(triglist[l] == *(c+8) ) {
            t = trigval[triglist[l]];
            if( ( *t & 16) && *(t+3) == 7)
              trapres(pc,*(t+5),*(c+24),*(c+25));
            triglist[l] = 0;
            triglist[0]--;
            break;
            }
         }
      }
    }
  }
if(j > 0 && *(c+8) == 80) {
   *(c+52) = *(c+30);
   *(c+53) = x + 16*y;
   prnt("-> The seeking shard imprints the room!");
   }
if(j == 0) {
  x = crumobj[*(c+9)][6];
  y = crumobj[*(c+9)][7];
  if(!adjac(pc,x,y))
    return(1);
  id = zline[x][y][1];
  k = crumobj[id][0];
  if(k < 41)
    return(1);
  l = (*(c+45) == 0 ? 0 : 1);
  *(c+45+l) = k;
  invtrap(k);
  w = obj[k];
  prnt("-> %s takes the %s into hand.",w1,w); 
  for(j=0;j<9;j++) 
    crumobj[id][j] = 0;
  if(id > 13) {
    xobj(crumobj[id][0],crum);
    rumdata[crum][134+id] = 0;
    }
  zline[x][y][1] = 0;
  *(c+5) = x;
  *(c+6) = y;
  *(c+8) = k;
  if(k < 46 && k > 40 && *(c+32) == 0)
    *(c+32) = k;
  attack(pc,x,y);
  if(rumdata[crum][30] || zline[x][y][5] > 0)
    drawsq(x,y);
  }
return(1);
}

