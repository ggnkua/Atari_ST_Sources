/****************************************************************************/
/* INVENT() is a call to update the inventory of the hero.  It updates the  */
/* status as well as which possessions are in the person's inventory.       */
/****************************************************************************/

extern int status(pc)
{
extern int off(),vbl(),handle;
extern char invnpc[][20],curmon[][60],*wepname[],*name[],*statword[],*obj[];
extern char pname[];
int i,j,ret,flag;
char scratch[3],*w,*c = curmon[pc];
long int point;
if(pc > 3)
 return(1);
xbios(37);
xbios(38,off);
clrinp();
v_rvon(handle);
for(i=0;i<7;i++) {
   vs_curaddress(handle,2*i+1,33);
   printf("        ");
   textsix(1,260,1 + 16*i,strlen(statword[i]),statword[i]);
   }
if(pc == 0)
   w = &pname[0];
else
   w = name[*(c+3)];
vs_curaddress(handle,1,33);
texsix(1,260,9,strlen(w),w);
sprintf(scratch,"%d",*(c+2) - *(c+1));
textsix(1,284,25,2,scratch);
if(*(c+47)>0)
  sprintf(scratch,"%c",'P');
else
  sprintf(scratch,"%c",'G');
textsix(1,312,25,1,scratch);
sprintf(scratch,"%d",*(c+14));
textsix(1,284,41,2,scratch);
textsix(1,260,57,strlen(wepname[*(c+32)]),wepname[*(c+32)]);
for(i=0;i<2;i++)
  textsix(1,260,73+16*i,strlen(obj[*(c+45+i)]),obj[*(c+45+i)]);
sgetxy(&i,&i,2,14,18,&ret);
ret -= 13;
xbios(37);
xbios(38,vbl);
switch(ret) {
   case 1:
       i = *(c+33);
       *(c+33) = *(c+32);
       *(c+32) = i;
       pass(pc);
       flag = 0;
       break;
   case 2:
       putaway(pc,*(c+45));
       *(c+45) = invent(pc);
       pass(pc);
       flag = 0;
       break;
   case 3:
       if(*(c+41) > 0)
          litetrol(*(c+24),*(c+25),0);
       else
          putaway(pc,*(c+46));
       if(invnpc[pc][0] == 0)
          return(1);
       if(*(c+41) > 64)
          *(c+42) += 1;
       *(c+46) = invent(pc);
       pass(pc);
       flag = 0;
       break;
   case 4:
       invent(pc);
       flag = 1;
       break;
   default:
       flag = 1;
       break;
   }
return(flag);
}     


extern int invent(pc)
int pc;
{
extern int handle,vbl(),off(),mode;
extern char invnpc[][20],*obj[];
int j,top = 1,i,ret,bot;
char scratch[16];
clrinp();
bot = listinv(pc,scratch);
sgetxy(&i,&i,2,top,bot,&ret);
clrinp();
return(scratch[ret]);
}

extern int listinv(pc,scratch)
int pc;
char *scratch;
{
extern int handle,vbl(),off();
extern char curmon[][60],invnpc[][20],*obj[];
int j,bot=1;
char word[3],*o = invnpc[pc];
xbios(37);
xbios(38,off);
header("INVENTORY");
for(j=1;j<14;j++) {
  if(*(o+j) != 0) {
     textsix(1,260,1+bot*8,strlen(obj[*(o+j)]),obj[*(o+j)]);
     *(scratch+bot) = *(o+j);
     bot++;
     }
  }
textsix(1,260,1+8*(bot+1),7,"Torches");
sprintf(word,"%d",curmon[pc][42]);
textsix(1,308,1+8*(bot+1),strlen(word),word);
xbios(37);
xbios(38,vbl);
return(bot);
}
