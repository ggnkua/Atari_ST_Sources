/* test random bitblit functions (S. A. Uhler) */

#include <stdio.h>
#include "bitmap.h"

#define message(x) \
	if(bit_debug){printf("%s\n",x);fflush(stdout);}

#define FRACTION		850				/* maximum blit size (parts/1000)*/

int bit_debug = 0;

main(argc,argv)
char **argv;
   {
   register BITMAP *screen;
   register int x,y,w,h,op,xs,ys;
	int maxx, maxy;
	int min,max;
	int count;

   bit_debug = getenv("DEBUG");

   screen = bit_open("/dev/bwtwo0");
	
	if (argc < 3) {
		printf("usage: %s min_size max_size count\n",*argv);
		exit(1);
		}

	min = atoi(argv[1]);
	max = atoi(argv[2]);
	count = atoi(argv[3]);

	if (min >= max)
		max = min +1;
	maxx = max-min;
	maxy = max-min;

	while (count-- > 0) {
		op = random()&15;
		w = min + random()%maxx;
		h = min + random()%maxy;
		x = random()%(BIT_WIDE(screen)-w);
		y = random()%(BIT_HIGH(screen)-h);
		xs = random()%(BIT_WIDE(screen)-w);
		ys= random()%(BIT_HIGH(screen)-h);
      mem_rop(screen,x,y,w,h,op,screen,xs,ys);
      }
   }
