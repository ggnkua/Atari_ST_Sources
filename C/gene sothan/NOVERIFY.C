/*  TOS NO VERIFY  */
/*    11/24/85     */
/*  By gene sothan */
/*  							   */
/*  use TOS extender in file name  */
/*  							   */

#include <stdio.h>
#define REV_VID "\033p" /* FROM PATS VT52.H FILE  */
#define NOR_VID "\033q" /* FROM PATS VT52.H FILE  */
#define CLR_SCRN "\033E" /* FROM PATS VT52.H FILE  */
#define CUR_OFF "\033f" /* FROM PATS VT52.H FILE  */
#define CUR_ON "\033e" /* FROM PATS VT52.H FILE  */
#define NAME "A:TOS.IMG" /* easy to change  drive # for debugging */
#define getc() necin()  /* from my stdio.h file -- no echo to screen */

int handle,w;
char c;

main()
{
	prog_inf(); 		 /* what this program is !! */
	unprotect();
	mod_tos();
	protect();
	say_goodbye();
	leave();			 /* reset cursor & clear screen for control C */
}

prog_inf()
{
	handle=0;
	puts(CLR_SCRN);
	puts(CUR_OFF);
	printf("This program will modify the file TOS.IMG so that when booted\n");
	printf("TOS will do all disk writes with NO VERIFY.\n");
	printf("It only changes the file TOS.IMG,not memory. You will have to\n");
	printf("reboot with the new TOS.IMG file on your system disk.\n");
	printf("To see which TOS has been booted, click on 'DESKTOP INFO' and\n");
	printf("above TOS it will say 'NO VERIFY' if it is this TOS.\n");

	while(handle<1)
	{
		printf("\n\nPlease insert TOS disk in drive ");
		printf("%sA%s and hit any key !! ",REV_VID,NOR_VID);
		printf("<%s control C to exit %s>\7\n\n",REV_VID,NOR_VID);
		c=getc();if(c==3) leave();
		handle=open(NAME,"R");

			if(handle==-1)
				printf("%25s%s NO disk in drive ?? %s\7\n",
				"",REV_VID,NOR_VID);
			if(handle==-33)
				printf("%25s%s TOS.IMG NOT FOUND !! %s\n",
				"",REV_VID,NOR_VID);
	}

	close(handle);

}

say_goodbye()
{
	printf("%s%18s%s TOS has been modified -- PRESS ANY KEY %s\7\n",
	CLR_SCRN,"",REV_VID,NOR_VID);
	getc();
}

unprotect()
{
	handle=-1;
	while(handle<0)
	{
		handle=attrib(NAME,1,0);

		if(handle==-1)
		{
			 printf("\n%16s%s Error trying to unprotect ","",REV_VID);
			 printf("TOS.IMG %s\n",NOR_VID);
			 printf("%8s%s Please check disk write protect ","",REV_VID);
			 printf("tab and enable !! %s\n",NOR_VID);
			 printf("%8s%s PRESS ANY KEY TO TRY AGAIN !! ","",REV_VID);
			 printf("<CONTROL C to exit> %s\7\n",NOR_VID);

			 c=getc();if(c==3) leave();
		}
	}
}

protect()
{
	handle=attrib(NAME,1,1);
}

leave()
{
	puts(CLR_SCRN);
	puts(CUR_ON);
	exit();
}

mod_tos()
{
	handle=open(NAME,2);
	seek(0x2D0,handle,0); /* from start of file */
	w=fgetc(handle);
		if(w!=0x50 && w!=0x51)
		{
			close(handle);
			printf("\n%12s%s WRONG VERSION OF TOS -- PRESS ANY KEY !! %s\7\n\n",
			"",REV_VID,NOR_VID);
			getchar();
			leave();
		}
	seek(-1,handle,1);     /* backup 1 byte */
	fputc(0x51,handle);    /* NO VERIFY */

	seek(0x17bc2,handle,1);  /* SO I KNOW WHICH TOS IT IS - DESKTOP INFO */
	fputs("* verify  off *",handle);

	close(handle);
}
