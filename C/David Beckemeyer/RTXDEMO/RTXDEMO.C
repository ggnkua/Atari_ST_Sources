/************************************************************************/
/* 									*/
/*         RRRRRRRRR       TTTTTTTTTTTTTTT      XXX     XXX		*/
/*         RRR     RRR           TTT             XXX   XXX		*/
/*         RRR     RRR           TTT              XXX XXX 		*/
/*         RRRRRRRRR             TTT                XXX			*/
/*         RRR    RRR            TTT              XXX XXX 		*/
/*         RRR     RRR           TTT             XXX   XXX		*/
/*         RRR     RRR           TTT            XXX     XXX		*/
/* 									*/
/*	MICRO RTX  -  Atari ST Multitasking Operating System Kernel	*/
/* 									*/
/*	(c) Copyright 1986 by David Beckemeyer				*/
/* 									*/
/* 									*/
/*	This short demonstaration program demonstates some of the	*/
/*	multitasking capabilities of the Atari ST computer.		*/
/* 									*/
/*	This is a sample of a MICRO RTX multitasking application.	*/
/*	As you can see, MICRO RTX applications can be as simple as you	*/
/*	want.  The standard GEMDOS functions operate as usual, with	*/
/*	automatic multitasking.						*/
/*									*/
/*	This MICRO RTX application is a simple "shell" that shows	*/
/*	how to use the kernel to get automatic multitasking.		*/
/*									*/
/*	When run, the shell will prompt with a "*".  It accepts the	*/
/*	following one letter commands:					*/
/*									*/
/*		e - execute a program file				*/
/*		h - create background CPU hog				*/
/*		l - list a file on the screen				*/
/*		m - spool a file to the modem (RS-232)			*/
/*		p - spool a file to the printer				*/
/*		s - show processes					*/
/*		x - exit demo program					*/
/*									*/
/*	The e, l, m, and p commands prompt for a file name.  In each	*/
/*	case the complete path of the file (including the extension)	*/
/*	must be given.							*/
/*									*/
/*	The e command will attept to execute the given program file.	*/
/*	This must not be a GEM program with this demo because the	*/
/*	mouse and screen are not set up for GEM.  			*/
/*									*/
/*	The l, m, and p commands cannot be used concurrently.		*/
/*	This is because the demo uses the Unix style standard I/O	*/
/*	library for opening the files (from GEMLIB) and since this	*/
/*	code from DRI is not reentrant, the sharing of the GEMLIB	*/
/*	code doesn't work. This could be fixed by either re-writing	*/
/*	the standard I/O routines, or by using the GEMDOS style		*/
/*	calls (from osbind.h) Fopen, Fread, etc.  We are working on	*/
/*	our improved version of the Unix standard I/O library.		*/
/*									*/
/*	Keep in mind that standard "fopen", "fclose" calls work		*/
/*	normally for progams that always used them.  The problem	*/
/*	only comes about when you are actually sharing the data		*/
/*	& code segments, like this demo does.  The sub-processes	*/
/*	created here all share one copy of code from "GEMLIB" made	*/
/*	at link time.  When individual programs are run as a		*/
/*	single process, they each have their own copy of GEMLIB		*/
/*	so everything works fine.  Got it?				*/
/*									*/
/*	The h command just soaks up CPU time to demonstrate the		*/
/*	fantastic CPU horsepower of the ST.				*/
/*									*/
/*	With this MICRO RTX demo, you can run up to three background	*/
/*	processes.  This is a configuration limitation only.  You	*/
/*	can configure MICRO RTX for however many processes you want.	*/
/*									*/
/************************************************************************/

#include <stdio.h>
#include <osbind.h>

char filename[64];

main()
{
	char buf[80];
	char *p;
	int i, delta;
	char c;
	int modem(), hog(), print();

	rtx_install();
 	delta = p_priority(0L, 0) - 100;
 	p_priority(0L, -delta);
	printf("MICRO RTX - Atari ST Multitasking Operating System Kernel\n");
	printf("(c) Copyright 1986 - David Beckemeyer\n\n");
	printf("This program is Free!  It is a simple application program\n");
	printf("that uses the MICRO RTX multitasking kernel to demonstrate\n");
	printf("a few of the multitasking capabilities of the ST.\n\n");
	printf("It may be freely distributed, provided all the introductory\n");
	printf("messages remain intact.   MICRO RTX is available from:\n\n");
	printf("\tBeckemeyer Development Tools\n");
	printf("\t592 Jean Street #304\n");
	printf("\tOakland, CA 94610\n");
	printf("\t(415) 658-5318\n\n");

	do {
		getline(buf, "* ");
		switch (buf[0]) {
		case 'e':
			getline(buf, "Exec file: ");
			Pexec(0, buf, "", "");
			break;
		case 'm':
			getline(filename, "File: ");
			p_create(100, 20, modem, 0, 0L);
			break;
		case 'h':
			p_create(100, 20, hog, 0, 0L);
			break;
		case 'p':
			getline(filename, "File: ");
			p_create(100, 20, print, 0, 0L);
			break;
		case 's':
			printf("Processes:\n----------\n\n");
			showpall();
			break;
		case 'l':
			getline(buf, "File: ");
			list(buf);
			break;
		case '\0':
		case 'x':
			break;
		case '?':
			printf("e - exec a program (foreground)\n");
			printf("h - create background CPU hog\n");
			printf("l - dump file to screen (foreground)\n");
			printf("m - spool file to RS-232\n");
			printf("p - spool file to printer\n");
			printf("s - show processes\n");
			printf("x - exit\n");
			break;
		default:
			printf("Unknown command - ? lists commands\n");
			break;
		}
	} while (buf[0] != 'x');
	rtx_remove();
	printf("\nBye Byte\n");
}



modem()
{
	char c;
	FILE *fd;

	if ((fd = fopen(filename, "r")) != 0) {
		while ((c = fgetc(fd)) != EOF) {
			Cauxout(c);
			if (c == '\n')
				Cauxout('\015');
		}
		fclose(fd);
	}
}


list(file)
char *file;
{
	char c;
	FILE *fd;

	if ((fd = fopen(file, "r")) != 0) {
		while ((c = fgetc(fd)) != EOF) {
			putchar(c);
		}
		fclose(fd);
	}
	else
		printf("%s does not exist\n", file);
}






hog()
{
	for (;;)
		;
}


print()
{
	char c;
	FILE *fd;

	if ((fd = fopen(filename, "r")) != 0) {
		while ((c = fgetc(fd)) != EOF) {
			Cprnout(c);
			if (c == '\n')
				Cprnout('\015');
		}
		fclose(fd);
	}
}



getline(buf, p)
char *buf;
char *p;
{
	Cconws(p);
	buf[0] = 78;
	Cconrs(buf);
	buf[2+buf[1]] = '\0';
	putchar('\n');
	strcpy(buf, buf+2);
}
