extern int texwin()
{
extern int handle,bitmap[][65];
extern long int addr;
int i,j,k;
for(i=16;i<25;i+=2) {
 blt(bitmap[131],16*15,8*i,addr);
 blt(bitmap[199],0,8*i,addr);
 }
blt(bitmap[129],0,128,addr);
blt(bitmap[129],0,186,addr);
blt(bitmap[130],16*15-2,128,addr);
blt(bitmap[130],16*15-2,186,addr);
v_rvon(handle);
for(i=17;i<26;i++) {
  vs_curaddress(handle,i,3);
  printf("                            ");       
  }
v_rvoff(handle);
}

