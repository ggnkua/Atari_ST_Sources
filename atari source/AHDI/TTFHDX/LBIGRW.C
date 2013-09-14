#include	<osbind.h>
#include	"define.h"

main(argc, argv)
int	argc;
char	*argv[];
{
	long		total, bsize, ostack, i;
	register long	start, stop, *hz200v, amtrd;
	unsigned int	fhandle/*, rate*/, j;
	char		fname[128], *rbuf, show[10];


	if (argc <= 1) {
		strcpy(fname, "N:\\BIGFILE");
	} else {
		strcpy(fname, argv[1]);
	}
	if ((fhandle = Fopen(fname, 0)) < 0) {
		printf("\n\rCannot open %s\!", fname);
		return;
	}

	bsize = Malloc(-1L);
	rbuf = (char *)Malloc(bsize);
	total = i = 0L;
	ostack = Super(NULL);
	hz200v = (long *)0x4ba;
	for (j = 0; j < 6; j++) {
timit:
		start = *hz200v;
		amtrd = Fread(fhandle, bsize, rbuf);
		stop = *hz200v;
		if (amtrd < 0) {
			printf("\n\rRead Error\!");
			goto end;
		} else if (amtrd > 0) {
			i += amtrd;
			total += (stop - start);
			goto timit;
		} else /* if (amtrd == 0) */ {
			strcpy(show, "          ");
			ltoa(total, show);
			printf("\n\r\r # 200hz ticks: %s\n\r", show);
			strcpy(show, "          ");
			ltoa(i, show);
			printf("\n\r # bytes read: %s\n\r", show);
			Fseek(0L, fhandle, 0);	/* back to beginning of file */
			total = i = 0L;
		}
	}
end:
	Super(ostack);
	Fclose(fhandle);
	while(!Bconstat(2))
		;
}


ltoa(inword, numbuf)			
long inword;
char numbuf[];
{	
    long temp1, value;
    register int i, j;
    char tmpbuf[10];
    register char *ascbuf;
	
    ascbuf = numbuf;
    i = 0;				/* if the value is non zero  */

    if (!inword)	
	*ascbuf++ = '0';
    else {
	value = inword;
	while(value) {
	    temp1 = value % 10;		/*  find the remainder	*/
	    temp1 += 0x0030;		/*  convert to ASCII	*/
	    tmpbuf[i++] = temp1;	/*  buffer is reverse	*/
	    value = value / 10;
	}

	for (j = i-1; j >= 0; j--) 	/* reverse it back	*/
	    *ascbuf++ = tmpbuf[j];
    }

    *ascbuf = 0;			/* end of string mark	*/
    return;
}



