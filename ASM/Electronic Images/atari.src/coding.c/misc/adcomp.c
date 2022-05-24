/*   Guazzo Coding Implementation  -  Expansion  version 0.0.0
 
 
     Copyright Feb. 1993
 
     Gordon V. Cormack  Feb. 1993
     University of Waterloo
     cormack@uwaterloo.ca
 
 
     All rights reserved.
 
     This code and the algorithms herein are the property of Gordon V. Cormack.
 
     Neither the code nor any algorithm herein may be included in any software,
     device, or process which is sold, exchanged for profit, or for which a
     licence or royalty fee is charged.
 
     Permission is granted to use this code for educational, research, or
     commercial purposes, provided this notice is included, and provided this
     code is not used as described in the above paragraph.
 
*/
 
#include <stdio.h>

main(){
long max = 0x1000000;
long    min = 0;
long    mid;
long    val;
register int index;
register int i;
register int bit;
register char c;
int one[256], zero[256];
for (i=0;i<256;i++){
   one[i] = 1;
   zero[i] = 1;
   }

val = ((long) getchar())<<16;
val += ((long) getchar())<<8;
val += ((long) getchar());
while(1) {
   c = 0;
   if (val == (max-1)) {
      fprintf(stderr,"expand done\n");
      break;
   }
   for (i=0;i<8;i++){
      index = (1<<i) - 1 + c;
      mid = min + ((max-min-1)*((float)zero[index]) /(zero[index]+one[index]));
      if (mid == min) mid++;
      if (mid == (max-1)){  /* should never happen */
         mid--;
      }
      if (val >= mid) {
         bit = 1;
         min = mid;
         one[index]++;
         }
      else {
         bit = 0;
         max = mid;
         zero[index]++;
         }
      c = c + c + bit;
      while ((max-min) < 256) {
         max--;
         val = (val << 8) & 0xffff00 | (getchar()& 0xff);
         min = (min << 8) & 0xffff00;
         max = ((max << 8) & 0xffff00) ;
         if (min >= max) max = 0x1000000;
         }
      }
   putchar(c);
   }
}
