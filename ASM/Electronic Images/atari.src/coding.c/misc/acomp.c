/*   Guazzo Coding Implementation  -  Compression version 0.0.0

 
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

/* 
     This code uses a one-byte finite state predictor to drive an arithmetic
     coder for data compression.  It should give compression nearly identical
     to one-byte huffman coding.

     Find a better predictor, and you'll have a better compressor!

     It handles end-of-file properly, which requires more than 5 minutes
     thought.
*/



#include <stdio.h>
main(){
int max = 0x1000000,
    min = 0,
    mid,
    index,
    c, 
    i,
    bytes = 0,
    obytes = 3;
int bit;
int one[256], zero[256];
for (i=0;i<256;i++) {
   one[i] = 1;
   zero[i] = 1;
   }

for(;;){
   c = getchar();
   if (c == EOF) {
      min = max-1;
      fprintf(stderr,"compress done bytes in %d bytes out %d ratio %f\n",
                      bytes,obytes, (float)obytes/bytes);
      break;
   } 
   bytes++;
   for (i=0;i<8;i++){
      bit = (c << i) & 0x80;
      index = (1<<i) - 1 + (c >> (8-i));
      mid = min + ((max-min-1)*((float)zero[index]) / (one[index]+zero[index]));
      if (mid == min) mid++;
      if (mid == (max-1)){ /* should never happen, but with floating pt? */
         mid--;
      }
      if (bit) { 
         min = mid;
         one[index]++;
         }
      else {
         max = mid;
         zero[index]++;
         }
      while ((max-min) < 256) {
         max--;
         putchar(min >> 16);
         obytes++;
         min = (min << 8) & 0xffff00;
         max = ((max << 8) & 0xffff00) ;
         if (min >= max) max = 0x1000000;
         }
      }
   }
putchar(min>>16);
putchar((min>>8) & 0xff);
putchar(min & 0x00ff);
}
