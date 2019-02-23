/*
	this routine dumps the R1200C image memory to the screen
	buffer array 'scr_buf', switches bank in the R1200C, then
	reloads the image back.
*/
#include "stdio.h"
/*
	define R1200C commands
*/
#define DUMP_RAW 0xBD
#define BANK_INC 0x03
#define LOAD_RAW 0xFD

unsigned char scr_buf[200000];	/* the screen buffer */
main()
{
unsigned char red, green, blue, get1200();
register unsigned char *bp;
register long i;

	flush1200();	/* clear the interface */
	printf("\nany key to dump screen to buffer");
	bp = scr_buf;
	getchar();	/* wait for the user's signal */
	printf("\ndumping");

	put1200(DUMP_RAW);	/* ask R120C for the current image in R,G,B */

	for (i=0l; i<10l; i++) {	/* show the first 10 pixels */
		*bp++ = (red = get1200());	/* red */
		*bp++ = (green = get1200());	/* green */
		*bp++ = (blue = get1200());	/* blue */
		printf("\nr = %d, g = %d, b = %d", red, green, blue);
	}
	for (i=10l; i<61440l; i++) {
		*bp++ = get1200();	/* red */
		*bp++ = get1200();	/* green */
		*bp++ = get1200();	/* blue */
	}

	put1200(BANK_INC);	/* go to the next bank in the R1200C */

	printf("\nany key to re-load screen");
	bp = scr_buf;
	getchar();		/* wait til user is ready to watch */
	printf("\nloading");

	put1200(LOAD_RAW);	/* ask R1200C to receive the R,G,B image */
	for (i=0l; i<61440l; i++) {
		put1200(*bp++);	/* red */
		put1200(*bp++);	/* green */
		put1200(*bp++);	/* blue */
	}
	printf("\ndone");
}

/*
	define addresses of the ports on the interface
*/
static unsigned char *r1200in = 0xFA0001; /* input data read from here */
static unsigned char *r1200st = 0xFA0000; /* I/O status read from here */
static unsigned char *r1200ou = 0xFB0000; /* data xx written when read from
					     (here + (xx<2)) */
static unsigned char *r1200oc = 0xFB0001; /* output strobe cleared if read */
/*
	define the status bits on the interface
*/
#define INREADY 0x40
#define OUTREADY 0x80

flush1200()	/* routine to clear the interface */
{
register unsigned char c;
	c = *r1200in;	/* clear the input register and status */
	c = *r1200oc;	/* clear the output strobe */
	return;
}


put1200(c)	/* routine to send data to the output port */
char c;
{
register unsigned char *cp, cc;
register int ii;

	ii = c * 2;			/* product bigger than byte */
	cp = r1200ou + (ii & 0x1FE);	/* calculate address */
	while (*r1200st & OUTREADY);	/* wait til ready */
	cc = *cp;			/* write the byte */
	return;
}


unsigned char get1200()	/* routine to receive data from the input port */
{
	while (!(*r1200st & INREADY));	/* wait for data available */
	return *r1200in;		/* get the byte and return it */
}
