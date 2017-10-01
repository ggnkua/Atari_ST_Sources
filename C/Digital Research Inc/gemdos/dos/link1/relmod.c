/* relmod.c
	Convert CP/M-68K format relocatable command file to GEMDOS format.
*/


char c1 = { 1 } ;
int infil,outfil;
gem_rel()
{
	long off,last,n;
	int i,rel;
	char c;


	if ((infil = openb(argv[1],0)) == -1)
	{
		printf("Unable to open %s.", argv[1]);
		exit(1);
	}


	for (off = last = 0; read(infil,&rel,2) == 2; off += 2)
	{
		rel &= 7;
		if (rel == 5)
		{
			read(infil,&rel,2);
			rel = (rel - 1) & 7;
			if (rel < 3)
			{
				if (!last)
					write(outfil,&off,4);
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

	if (!off)
		write(outfil,&off,4);		/* nothing needed relocation */

	c = 0;					/* terminate relocation info */
	write(outfil,&c,1);

	close(outfil);
	close(infil);
}
