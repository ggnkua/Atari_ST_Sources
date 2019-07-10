/* test small bitblit functions */

#include <stdio.h>
#include "bitmap.h"

extern int bit_debug;

#define message(x) \
	if(bit_debug){printf("%s\n",x);fflush(stdout);}

#define SIZE		32				/* basic size */

int bit_debug = 0;

main(argc,argv)
char **argv;
   {
   register BITMAP *screen;
   BITMAP *src,*dst;
   int wait=1;
	int size;
	int x0;
   register int i,j,x;

   if (argc>1) 
		size = atoi(argv[1]);
	else
		size=SIZE;
   bit_debug = getenv("DEBUG");

   screen = bit_open("/dev/bwtwo0");

   /* make src and dst */

   src = bit_alloc(size,size,0);
   dst = bit_alloc(size,size,0);
   
   message("Make src and dst");

   mem_rop(src,0,0,size/2,size,BIT_CLR,0,0,0);
   mem_rop(src,size/2,0,size/2,size,BIT_SET,0,0,0);

   mem_rop(dst,0,0,size,size/2,BIT_CLR,0,0,0);
   mem_rop(dst,0,size/2,size,size/2,BIT_SET,0,0,0);

   /* test 16 bitmem_rop functions */

   message("16 borders");
   for(i=0;i<16;i++) {
		x0 = i*(size+10);
      mem_rop(screen,10+x0%900,100+(size+10)*(x0/900),size,size,BIT_SET,0,0,0);
		if (wait) sleep(1);
		}
   message("16 dst patterns");
   for(i=0;i<16;i++) {
		x0 = i*(size+10);
      mem_rop(screen,12+x0%900,102+(size+10)*(x0/900),size-4,size-4,BIT_SRC,dst,2,2);
		if (wait) sleep(1);
		}
   message("16 bit-blt functions");
   for(i=0;i<16;i++) {
		x0 = i*(size+10);
      mem_rop(screen,12+x0%900,102+(size+10)*(x0/900),size-4,size-4,i,src,2,2);
      if (wait) sleep(1);
      }
   }
