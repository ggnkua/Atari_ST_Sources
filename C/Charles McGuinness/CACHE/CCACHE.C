/************************************************************************/
/*									*/
/*	ccache....							*/
/*									*/
/*	LRU Buffer implementation system				*/
/*									*/
/*	This module, which holds the guts of the cachine program,	*/
/*	maintains a number of buffers (see "BUFFERS") which hold the	*/
/*	"BUFFERS" most recently accessed (read or written) sectors	*/
/*	from the disk. Associated with each buffer is an age, which	*/
/*	gets incremented each time any buffer is accessed.  The age	*/
/*	of a buffer is reset to 0 when that specific buffer is used,	*/
/*	so the buffer with the oldest age is the Least Recently Used.	*/
/*	The LRU buffer is recycled for a new sector if we need a place	*/
/*	to save a buffer.						*/
/*									*/
/*	The size of the buffer depends entirely upon one's needs.	*/
/*	A small buffer, say 32 elements, will probably suffice to	*/
/*	show some speed up.  A large buffer, perhaps around 256		*/
/*	elements (128k of buffer) will achieve many of the same		*/
/*	benefits that a ram disk will, without the volatility (as	*/
/*	we always perform writes immediately (write through cache)).	*/
/*									*/
/*	This program is compiled under Lattice C, using the -n -t	*/
/*	options, and linked with the fast linker from Personal Pascal.	*/
/*									*/
/*	Program Copyright 1987, Charles McGuinness.  Reproduction	*/
/*	in any form beyond the CompuServe Information Service is	*/
/*	prohibited.							*/
/*									*/
/************************************************************************/

/*	#define	FAT

	If FAT is defined, then only the first BUFFERS/2 sectors of
	each diskette will be cached, causing the FAT and directories
	to be always in memory....
*/


#define	BUFFERS	256			/* Let's go for the 128k Size!	*/

unsigned char	drive[BUFFERS];		/* Why didn't I use a struct???	*/
unsigned short	recs[BUFFERS];
unsigned short	age[BUFFERS];

short		bufs[BUFFERS][256];


unsigned short	xrwflag,
		xnumber,
		xrecno,
		xdev,
		xchar;
	
char *	xbuffer;


int lru_startup()
{
	init_cache();		/* Clear out the cache...	*/
	return(BUFFERS * 512);	/* How much data space we need	*/
}

int myrwabs()
{
	int	i,
		bnum;
	

	if ((!xrecno) || (! xbuffer)) {
		init_cache();
		return(rwabs());
	}
	
	if (xrwflag & 1) {
		i = rwabs();	/* Write them all out ...		*/
		if (i != 0) {
			init_cache();	/* All bets off now!		*/
			return(i);
		}
		
		for (i = 0;i < xnumber;i++) {
			write_sect();
			xbuffer += 512;
			xrecno++;
			}
		return(0);
		}

	for (;xnumber;xnumber--) {
		bnum = in_cache(xrecno);
		if (bnum != -1) {
			movmem(bufs[bnum],xbuffer,512);
			xbuffer += 512;
			xrecno++;
			}
		else {
			i = rwabs();
			if (i != 0) {
				init_cache();	/* All bets off now!	*/
				return(i);
			}
			for (i=0;i<xnumber;i++) {
				save_sect();
				xrecno++;
				xbuffer += 512;
				}
			return(0);
			}
		}
	return(0);
}


int dchange()
{
	int	i;

	init_cache();

	if ((! xbuffer) || (! xrecno))
		return(rwabs());
	
	i = rwabs();		/* Do the whole shebang...	*/
	if (i != 0)
		return(i);
	
	if (xrwflag & 1) {
		for (i = 0;i < xnumber;i++) {
			write_sect();
			xbuffer += 512;
			xrecno++;
			}
		return(0);
		}

	for (i=0;i<xnumber;i++) {
		save_sect();
		xrecno++;
		xbuffer += 512;
		}
	return(0);
}

init_cache()
{
	int	i;
	for (i=0;i<BUFFERS;i++)
		drive[i] = 0xff;
		
}

write_sect()
{
	int	i;

	for (i=0;i<BUFFERS;i++)
		if ((drive[i] == xdev) && (recs[i] == xrecno)) {
			movmem(xbuffer,bufs[i],512);
			age[i] = 0;
			return(0);
			}
			
	i = find_free();	/* Get a free buffer slot		*/
	movmem(xbuffer,bufs[i],512);
	drive[i] = xdev;
	recs[i]  = xrecno;
	age[i] = 0;
	update_age();

	return(0);

}

save_sect()
{
	int	i;

#ifdef	FAT
	if (xrecno > (BUFFERS >> 1))
		return;
#endif

	for (i=0;i<BUFFERS;i++)
		if ((drive[i] == xdev) && (recs[i] == xrecno)) {
			movmem(xbuffer,bufs[i],512);
			age[i] = 0;
			update_age();
			return;
		}
		
		
	i = find_free();	/* Get a free buffer slot		*/
	movmem(xbuffer,bufs[i],512);
	drive[i] = xdev;
	recs[i]  = xrecno;
	age[i]	 = 0;
	update_age();

	return(0);
}

in_cache(x)
{
	int	i;
	
	for (i=0; i<BUFFERS; i++)
		if ((drive[i] == xdev) && (recs[i] == x))
			return(i);
		
	return(-1);
}

find_free()
{
	int	i, oldest,oldage;
	
	oldage	=0;

	for (i=0;i<BUFFERS;i++) {
		if (drive[i] == 0xff)
			return(i);
		if (age[i] >= oldage) {
			oldage = age[i];
			oldest = i;
		}
	}
	
	return(oldest);
}

update_age()
{
	int	i;
	
	for (i=0;i<BUFFERS;i++)
		if (age[i] < 4096)
			age[i]++;
}
