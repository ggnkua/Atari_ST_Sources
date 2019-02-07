/*****************************************************************************/
/* It's torch time!!                                                         */
/*****************************************************************************/

extern int i12(pc)
int pc;
{
extern int outside;
extern char curmon[][60];
char *c = curmon[pc];
if(outside)
  return(0);
if(*(c+41) > 60) 
  *(c+10) = 0;
if(*(c+41) <= 60) {
   if(*(c+42) == 0) {
     error(27);
     return(0);
     }
   *(c+10) = 1;
   }
*(c+7) = *(c+8) = *(c+9) = 0;
*(c+15) = 12;
*(c+16) = 6;
return(1);
}

extern int o12(pc)
int pc;
{
extern char curmon[][60],pname[],*name[];
char *c = curmon[pc],*w = (pc == 0 ? pname : name[*(c+3)]);
if(*(c+10) == 0) {
  *(c+41) = 0;
  *(c+42) += 1;
  *(c+46) = 0;
  litetrol(*(c+24),*(c+25),0);
  prnt("-> %s puts out and stores the torch.",w);
  return(1);
  }
*(c+42) -= 1;
prnt("-> %s lights a torch.",w);
if(*(c+41) > 0) {
  *(c+41) = 100;
  *(c+42) -= 1;
  return(1);
  }
else {
  if(*(c+46) != 81 && *(c+46) != 0) {
     if(!putaway(pc,*(c+46))) {
         error(7);
         return(1);
         }
      }
  *(c+46) = 81;
  *(c+41) = 100;
  litetrol(*(c+24),*(c+25),1);
  }
return(1);
}
