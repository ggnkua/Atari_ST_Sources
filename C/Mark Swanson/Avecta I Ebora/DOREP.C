
extern int dorep()
{
extern int handle,vbl(),off(),mode,crum;
extern char *mod[],*name[],curmon[][60],rumdata[][157];
int i,j,k,pxy[10],x=256,y=127,w=62,h=72;
char *c,scratch[13];
pxy[0]=256;
pxy[1]=127;
pxy[2]=319;
pxy[3]=127;
pxy[4]=319;
pxy[5]=199;
pxy[6]=256;
pxy[7]=199;
pxy[8]=256;
pxy[9]=127;
k = 0;
undorep();
for(i=4;i<12;i++) {
  c = curmon[i];
  if(*c == 1 && *(c+30) == crum && *(c+31) < 4)
    k = 1;
  }
if(k == 0) {
  mode = 0;
  return(1);
  }
mode = 1;
xbios(37);
xbios(38,off);
form_dial(1,0,0,0,0,x,y,w,h);
v_pline(handle,5,pxy);
v_rvon(handle);
vs_curaddress(handle,17,33);
printf("        ");
v_rvoff(handle);
textsix(1,259,129,10,"Opponents ");
j = 17;
for(k=4;k<12;k++) {
  c = curmon[k];
  if(*c != 0 && *(c+30) == crum && *(c+31) < 4) {
    sprintf(scratch,"%s",name[*(c+3)]);
    textsix(1,259,1 + 8*j,strlen(scratch),scratch);
    *(c+33) = j;
    i = (*(c+1) * 4)/(*(c+2));
    if(*(c+36) == 1)
       i = 5;
    if(*(c+38)) 
       i = 6;
    textsix(1,313,1 + 8*j,1,mod[i]);
    j++;
    }
  }
xbios(37);
xbios(38,vbl);
}

extern int undorep()
{
extern int handle;
int i;
xbios(37);
for(i=16;i<26;i++) {
  vs_curaddress(handle,i,33);
  v_eeol(handle);
  }
}
