/******************************************************************************/
/* ROB/LISTEN is function 10.  This attempts to open locked objects, and is   */
/* highly dependent on thieving abilities.  It only works with room objects   */
/* and therefore parses intent from the nature of the object.  If it is locked*/
/* the object is assumed to be jimmied.                                       */
/******************************************************************************/

extern int i10(pc)
int pc;
{
extern int outside,winker;
extern char crumobj[][9],curmon[][60],zline[16][8][7],pname[],*name[];
int obj,x,y,ret;
char *c = curmon[pc],*w = (pc == 0 ? pname : name[*(c+3)]);
if(outside)
  return(0);
if(*(c+45) > 0 && *(c+46) > 0) {
   error(29);
   return(0);
   }
header(w);
winker = pc + 1;
domsg(2);
sgetxy(&x,&y,0,0,0,&ret);
undomsg();
winker = 0;
clrinp();
obj = zline[x][y][1];
if(obj == 0 || (crumobj[obj][5] != -2 && crumobj[obj][3] < 1) ) {
  error(25);
  return(0);
  }
if(!adjac(pc,x,y)) {
  error(11);
  return(0);
  }
*(c+7) = *(c+8) = *(c+9) = 0;
*(c+5) = x;
*(c+6) = y;
*(c+9) = obj;
*(c+15) = 10;
*(c+16) = 6;
*(c+34) = 0;
return(1);
}

extern int o10(pc)
int pc;
{
extern char curmon[][60],zline[16][8][7],*name[],*obj[],pname[];
extern char crumobj[][9],rumdata[][157],permon[][23];
int x,y,object,flag=0;
char *c = curmon[pc],*o,*r,*w = (pc == 0 ? pname : name[*(c+3)]);
x = *(c+5);
y = *(c+6);
object = *(c+9);
o = crumobj[object];
r = rumdata[*(o+3)];
if(object != zline[x][y][1])
  return(1);
if( rnd(100) < *(c+37) && *(o+5) == -2) {
    if(*(o+3) == 0)
      *(o+5) = 1;
    else {
      if(*(o+2) == 0)
        *(o+5) = -1;
      else
        return(1);
      }
    prnt("-> %s unlocks the %s!",w,obj[*o]);
    flag = 1;
    }
if(*(o+3) != 0 && *(r+22) != 0 && rnd(100) < *(r+26) && rnd(100) < *(c+37)) {
    flag = 1; 
    prnt("-> %s hears one or more %ss through the %s!",w,
         name[permon[*(r+22)][3]],obj[*o]);
    }
if(flag == 0 && *(c+18) != 10) {
  prnt("-> %s has no success with the %s!",w,obj[*o]);
  }
*(c+18) = 10;
return(1);
}
