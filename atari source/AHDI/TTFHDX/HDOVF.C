#include	<osbind.h>
#include	"define.h"
#include	"lrwabs.h"


long		total, bsize, ostack, start, btime, tleft,
		tsect, hdsiz, rate, time, timesup;
unsigned int	pdev, scnt;
char		*rbuf, show[10], key;


main(argc, argv)
int	argc;
char	*argv[];
{
	register long	clk_in, clk_out, *hz200v;
	register int	ret;

	Cconout(ESC); Cconout('H');	/* home cursor */

	/*
	 * printfs are buffered, put \n at end to flush it 
	 * or call fflush(stdout) after the printfs
	 */
	if (argc <= 1) {		/* defaults */
		pdev = 9;		/* unit 9  (SCSI unit 1) */
		timesup = 60000L;	/* 5 minutes (in hz200 ticks) */
		printf("\nHit ESC or test will run for 5 minute(s)\n\r\n"); 
	} else {
		pdev = atoi(argv[1]);
		timesup = (long)atoi(argv[2]) * 12000L;
		printf("\nHit ESC or test will run for %s minute(s)\n\r\n", 
			argv[2]);
	}

	bsize = Malloc(-1L);
	rbuf = (char *)Malloc(bsize);
	scnt = bsize >> 9;
	total = tsect = start = 0L;
	
	ostack = Super(NULL);
	hz200v = (long *)0x4ba;
	
	if (pdev < 8)
		printf("Timing ACSI unit %d\n\r", pdev);
	else if (pdev < 16)
		printf("Timing SCSI unit %d\n\r", pdev-8);
	else
		printf("Timing IDE unit %d\n\r", pdev-16);

	printf("Number of sectors per read: %d\n\r", scnt);

	pdev += 2;

	/* find hard disk size */
	if (Rwabs(PHYSREAD, rbuf, 1, 0, pdev) != 0) {
		printf("\n\rRead error\!\n\r");
		goto end;
	}
	hdsiz = *(long *)(rbuf + 0x1c2);

	btime = *hz200v;
	while (1) {
    		/* Check for keyboard input */
    		if ((key = chkeybd()) == ESC) {
			goto end;
    		}

		if (start + (long)scnt >= hdsiz) {
			start = 0L;
		}

		ltoa(start, show);
		printf("Starting sector #: %s          \n\r", show);
		clk_in = *hz200v;
		ret = Lrwabs(PHYSREAD, rbuf, scnt, start, pdev);
		clk_out = *hz200v;

		if (ret != 0) {
			printf("\n\rRead Error\!");
			goto end;
		} else {
			time = clk_out - clk_in;
			total += time;
			tsect += scnt;
			start += scnt;
			ltoa(time, show);
			printf("Time taken (in 200Hz ticks): %s      \n\r", 
				show);
		}

		
		if ((tleft = timesup - (*hz200v-btime)) <= 0) {
			printf("Time's up\!                          \n\r");
			goto end;
		}
		tleft /= 200L;
		ltoa(tleft, show);
		printf("Time left (in sec): %s          \n\r", show);
		Cconout(ESC); Cconout('A');
		Cconout(ESC); Cconout('A');
		Cconout(ESC); Cconout('A');
	}
end:
	ltoa(tsect, show);
	printf("\n\n\nTotal # of sectors read: %s\n\r", show);
	rate = (tsect << 9) / (total/200);
	ltoa(rate, show);
	printf("Rate (in bytes/sec): %s\n\r", show);
	Super(ostack);
	Mfree(rbuf);
	while(!Cconis())
		;
}


ltoa(inword, numbuf)			
unsigned long inword;
char numbuf[];
{	
    unsigned long temp1, value;
    register int i, j;
    char tmpbuf[10];
    register char *ascbuf;
	
    ascbuf = numbuf;
    i = 0;

    if (!inword)			/* if the value is non zero  */
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



atoi(ptr)
char *ptr;
{
    register int n;

    for (n = 0; (*ptr >= '0' && *ptr <= '9'); ptr++)
	n = (10 * n) + *ptr - '0'; 

    return (n);
}



/*
 *  Check if any key is input from the keyboard.
 *	Key code looking for:
 *		Escape - to stop the procedure
 *		Any other or no key - no effect.
 *	Return:
 *		NOKEY - if no key is input, or key input is not
 *			what we are looking for.
 *		or ESC
 */
char
chkeybd()
{
    char key;		/* key being input */
 
    if (Cconis()) {		/* 2: CONSOLE */
    	if((key = (char)Cconin()) != ESC)
    	    key = NOKEY;
    } else {
    	key = NOKEY;
    }
    return key;
}

