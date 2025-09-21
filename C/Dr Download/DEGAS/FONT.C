/* DRDFNT.C: convert 8-bit Atari fonts to DEGAS format
 *
 * link gems,DRDFNT,osbind,gemlib
 *
 * Dr.Download BBS  614-587-3774
 */

#include <osbind.h>

#define HI_RES	   2
#define MED_RES    1
#define LO_RES     0
#define PATHLEN    64

#define CLR_SCREEN "\033E"
#define INV_VIDEO  "\033p"
#define NOR_VIDEO  "\033q"
#define W_ON_B     "\033b0\033c3"   /* 0 white  1 red  2 green  3 black */
#define B_ON_W	   "\033b3\033c0"
#define CR         "\r\n"
#define WAIT       { }
						
char buf[2050],path[67];
 
main()
{
	do {
		setup();
		do {
			Cconws("\r\nEnter pathname for 8-bit font: ");
			enter_path();
		} while (read_path());
		setup();  
		do {
			Cconws("\r\nEnter pathname for DEGAS font: ");
			enter_path();
		} while (write_path());
		setup();
		Cconws("\r\nConvert another font? [y/n]: ");
	} while (yesno());
	goodbye();
}

/* SETUP: configure screen
 */
int setup()
{
	if (Getrez() == HI_RES) 
		Cconws(W_ON_B);
	else 
		Cconws(B_ON_W);
	Cconws(CLR_SCREEN);
	Cconws(INV_VIDEO);
	Cconws(" DRDFNT.PRG: convert 8-bit fonts to DEGAS format \n");
	Cconws(NOR_VIDEO);
	Cursconf(1,0);	   /* cursor: 0 hide  1 show  2 blink  3 no blink */
	Cursconf(3,0);
	return(0);
}

/* ENTER_PATH: configure path from keyboard entry
 */
int enter_path()
{
	char *p = path;
	
	path[0] = PATHLEN;
	Cconrs(path);
	Cconws(CR);
	if (path[3] == ':') 
		while (*p++ = *(p+2));
	else {
		path[0] = (Dgetdrv()+65);
		path[1] = ':'; 
	}
	return(0);
}

/* READ_PATH: open 8-bit font file; copy each byte twice into the buffer
 */
int read_path()
{
	int handle;
	char *b = buf;

	if ((handle = Fopen(path,0)) < 0) {
		Cconws("file open error...");
		Cconws(CR);
		return(1);
		}
	else {
		while (Fread(handle,(long)1,b)) {
			*(b+1) = *b; 
			b+=2;
		}
		Fclose(handle);
		shuffle();
		buf[2048] = 0;
		buf[2049] = 1;  	/* enable half-sizes */
	}
	return(0);
}

/* SHUFFLE: put letters in ASCII order
 */
int shuffle()
{
	char *row1 = buf,
	     *row2 = buf + 512,
	     *row3 = buf + 1024;
	int i;

	for (i = 0; i < 512; i++) {
		buf[2050] = *(row3+i);
	 	*(row3+i) = *(row2+i);
		*(row2+i) = *(row1+i);
		*(row1+i) = buf[2050];
	}
	return(0);
} 

/* WRITE_PATH: create DEGAS font file; write buffer
 */
int write_path()
{
	long handle,len = 2050;

	handle = Fcreate(path,(short)0);
	if (handle >= 0) {	
		Fwrite((short)handle,len,&buf);
		Fclose((short)handle);
	}
	return(0);
}

/* YESNO: branch on keyboard entry
 */
int yesno()
{
	int reply;

	reply = Bconin(2);
	if ((reply == 89) || (reply == 121))
		return(1);
	else
		return(0);
}

/* GOODBYE: clean up & leave
 */
int goodbye()
{
	Cconws(CLR_SCREEN);
	Cconws(INV_VIDEO);
	Cconws(" Dr.Download BBS  614-587-3774 ");
	Cconws(NOR_VIDEO);
	Cconws("\r\n\nPress a key to leave: ");
	wait_key();
	Cconws(CR);
	exit(0);
}

/* WAIT_KEY: wait for keyboard entry
 */
int wait_key()
{
	while (!Bconstat(2)) WAIT;
	Bconin(2);
	return(0);
}
