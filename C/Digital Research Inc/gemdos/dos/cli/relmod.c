/* relmod.c
	Convert CP/M-68K format relocatable command file to GEMDOS format.

	Originally written by Jason S. Loveman

	Modified by Steven C. Cavender

		3 Jul 85	Added check of argument count.
				Added check of source file open.
				Added check of destination file create.
				Added check of no items needing relocation.
*/

#define BUFSIZ 8000

char buf[BUFSIZ];
char c1 = { 1 } ;
int infil,outfil;
long lrandw();

main(argc,argv)
int argc;
char *argv[];
{
    	long len[4], off2;
	register long off,last,n;
	register int i;
    	int rel;
	char c;

	if (argc != 3)
	{
		printf("Usage is:  relmod CP/M_file GEMDOS_file");
		exit(1);
	}

	if ((infil = openb(argv[1],0)) == -1)
	{
		printf("Unable to open %s.", argv[1]);
		exit(1);
	}

	if ((outfil = creatb(argv[2],1)) == -1)
	{
		printf("Unable to create %s.", argv[2]);
		exit(1);
	}

	randw(2L);				/* 601a */

	for (i = 0; i < 4; i++)
		len[i] = lrandw();

	randw(10L);				/* junk */
	randw(len[0] + len[1] + len[3]);	/* now pointing at reloc info */

	/* scan for relocatable items */

	for (off = last = 0; read(infil,&rel,2) == 2; off += 2)
	{
    		i = rel;
		i &= 7;
		if (i == 5)
		{
			read(infil,&rel,2);
    			i = rel;
			i = (i - 1) & 7;
			if (i < 3)
			{
				if (!last){
    					off2 = off;
					write(outfil,&off2,4);
    				}
				else
				{
					n = off - last;
					while (n > 254)
					{
						n -= 254;
						write(outfil,&c1,1);
					}
					c = n;
					write(outfil,&c,1);
				}
				last = off;
			}
			off += 2;
		}
	}

	if (!off){
    		off2 = off;
		write(outfil,&off2,4);		/* nothing needed relocation */
    	}
	c = 0;					/* terminate relocation info */
	write(outfil,&c,1);

	close(outfil);
	close(infil);
}

randw(n)
long n;
{
	for (; n > BUFSIZ; n -= BUFSIZ) randw((long) BUFSIZ);
	read(infil,buf,(int) n);
	write(outfil,buf, (int) n);
}
	
long lrandw()
{
	long n;
	read(infil,&n,4);
	write(outfil,&n,4);
	return(n);
}
