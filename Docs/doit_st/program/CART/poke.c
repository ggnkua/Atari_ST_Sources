/*
 * poke.c	Poke data into address on cart port.
 *
 * 		compile: cc poke.c cart.s
 */
 
#include <stdio.h>

#define ROM3_BASE  0xFB0000L
#define ROM4_BASE  0xFA0000L

/*
 * writecart16(addr, data)	in cart.s
 *	unsigned addr;  0..65535
 *	int	 data;
 *
 * -- Writes 16 bit data to ROM4 space on cart port.
 * -- Address supplied is referred to ROM4_BASE. Data is written there.
 *
 *	eg.  writecart16(0xC000, 0xFFFF), will write
 *	     16 bit word 0xFFFF to location ROM4_BASE + 0xC000.
 *	eg.  writecart16(0xC001, 0xFFFF) will bomb because addr is odd.
 */

extern int writecart16();

main(argc, argv)
int argc;
char **argv;
{
   char s[10];
   unsigned addr;
   unsigned data;
   register unsigned i;
 

	if ( (argc != 2) && (argc != 3) && (argc != 4) ) {
		printf("\tUsage: poke [r|w] [addr] <[data]>.\n");
		printf("\t[addr] and [data] are to be 16 bit decimal numbers.\n");
		exit(0);
	}
	

	if (argv[1][0] == 'w') {
		addr = atoi(argv[2]);
		data = atoi(argv[3]);
		printf("Writing 0x%4x to 0xFa0000+0x%4x\n", data, addr);
		for (i=0L; ; ++i) {
			writecart16(addr, data);
			if (i%10000L == 0) {
				i = 0L;
				printf("*");
				fflush(stdout);
			}
		}
		exit(0);
	}
	
	else if (argv[1][0] == 'r') {
		addr = atoi(argv[2]);
		printf("0xFA0000 + %x contains %x.\n",
			addr, * (int *) (ROM4_BASE + addr) );
			
		exit(0);
	}
	
		
	else {
		printf("Unknown command '%c'. Must be 'r' or 'w'.\n",
			argv[1][0]);
			
		exit(-1);
	}
		
}


