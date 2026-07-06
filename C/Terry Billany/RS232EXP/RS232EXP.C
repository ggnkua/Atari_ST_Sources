/*
	HEADER:		CUG236;
	TITLE:		RS232 Diagnostic Helper (Kila86);
	DATE:		05/17/1987;
	DESCRIPTION:	"Helps diagnose problems with the RS232 serial port.";
	VERSION:	1.1;
	KEYWORDS:	Serial port, RS-232;
	FILENAME:	RS232EXP.C;
	SEE-ALSO:	RS232EXP.DOC;
	COMPILERS:	vanilla;
	AUTHORS:	J. Kilar, W. C. Colley III;

	minor fixes for Sozobon C on Atari ST by Terry Billany 
*/

/*  Portability Note:  This program was originally written for the DeSmet C
    compiler.  That compiler supplies a number of quirky functions that
    operate the screen on the IBM PC.  This program uses two of them:

	void scr_rowcol(r,c)		Set the cursor to row r (1-24),
	int r, c;			column c (1-80).

	void scr_clr()			Clear the screen.

    Users on other systems will have to use equivalents from their C compilers'
    libraries or write equivalents.

    The Eco-C88 compiler has equivalent routines (that require ANSI.SYS to be
    installed) as follows:

void clrscr(), scr_pos();
#define scr_rowcol(r,c)		scr_pos((r)-1,(c)-1)
#define scr_clr			clrscr

    Folks using serial terminals (like my Z-19) can write routines like these:

void scr_rowcol(r,c)
int r, c;
{
    fprintf(stderr,"\033Y%c%c",r + (' '-1),c + (' '-1));
}

void scr_clr()
{
    fprintf(stderr,"\033Y  \033E");
}

    You can also work directly into the ANSI.SYS driver or work into an ANSI
    serial terminal like this:

void scr_rowcol(r,c)
int r, c;
{
    fprintf(stderr,"\033[%d;%dH",r,c);
}

void scr_clr()
{
    fprintf(stderr,"\033[2J");
}

*/
#include <stdio.h>

/*  Portability Note:  A few compilers don't know the additional type
    void.  If yours is one of these, uncomment the following #define.	*/

/* #define	void		int					*/

int baudrate(), bothpc(), bothterm(), chkcable(), databits(), dcedte();
int decterm(), deviceoff(), fullcable(), parity(), pc(), pcmale();
int pcmodem(), pcport(), pcprint(), pcterm(), resp(), respny(), term();
void blank(), clear(), devincomp(), heading(), nullmodem(), wait();

void scr_rowcol(r,c)
int r, c;
{
    fprintf(stderr,"\033Y%c%c",r + (' '-1),c + (' '-1));
}

void scr_clr()
{
    fprintf(stderr,"\033E");
}

void main()
{
    while (1) {
	heading();			/* display heading */
	if (deviceoff()) break;		/* check that devices are on */
	if (chkcable()) break;		/* check cable connected */
	if (baudrate()) break;		/* check baud rate */
	if (parity()) break;		/* parity */
	if (databits()) break;		/* check data bits */
	if (pc()) {			/* handle PC involved case */
	    if (pcmale()) break;	/* on serial not parallel port? */
	    if (pcport()) break;	/* COM1 or COM2 */
	    if (bothpc()) break;	/* two PCs case */
	    if (pcterm()) break;	/* PC to a terminal case */
	    if (pcmodem()) break;	/* PC to a modem case */
	    if (pcprint()) break;	/* PC to a printer */
	    if (fullcable()) break;	/* try full straight thru cable */
	    devincomp();  break;
	}
	else if (term()) {		/* no PC, terminal case */
	    if (pcmodem()) break;
	    if (decterm()) break;	/* DEC terminal */
	    if (bothterm()) break;	/* both terminals */
	    if (fullcable()) break;	/* try 25 lead straight thru cable */
	    if (dcedte()) break;
	    devincomp();  break;
	}
	else {
	    if (dcedte()) break;
	    devincomp();  break;
	}
    }
    blank();  blank();
    printf("Glad I could be of service to you.\n");
}

/* heading - displays header for program */
void heading()
{
    clear();
    printf("RS-232 MINI EXPERT SYSTEM.\n");
    printf("Version 1.1   by   Joe Kilar\n");
    blank();
    printf("This program will help you solve RS-232 serial communications ");
    printf("problems.\n");
    printf("Examples are connecting PCs to serial printers, modems, or");
    printf(" terminals.\n");
    blank();
    printf("If you're not sure about an answer you may try skipping it by\n");
    printf("answering no to whether the devices are communicating.  ");
    printf("Jot down\n");
    printf("the question in case further aids don't result in success.\n");
    wait();
    return;
}


int deviceoff()
{
    clear();
    printf("Check that power to both devices is on.  If power is not \n");
    printf("on, turn it on. \n");
    return respny();
}


int chkcable()
{
    clear();
    printf("Check that the serial cable is firmly connected to both ");
    printf("devices.\nIf not, ensure a good connection. \n");
    return respny();
}

int baudrate()
{
    clear();
    printf("Check that the baud rates selected or required for both devices");
    printf("\nare the same.   Baud rate reflects the speed at which data is");
    printf("\ncommunicated.  Typical baud rates are 300,1200,2400,9600, and ");
    printf("19.2K\n");
    blank();
    printf("Some devices have auto-baud.  They lock onto the baud rate of\n");
    printf("the other device sending successive RETURNs (sometimes SPACEs). ");
    printf("At times\nnoise ");
    printf("may make it lock onto the wrong baud rate.  Try turning it\n");
    printf("off and then back on to reset it.\n");
    blank();
    printf("Ensure that the baud rates are identical and/or reset any\n");
    printf("device using auto-baud.\n");
    return respny();
}

int parity()
{
    clear();
    printf("Check that the parity's selected or required for both devices\n");
    printf("are the same.   Parity has to do with an extra bit sent that can");
    printf("\nhelp detect transmission errors.  It is usually set to even, ");
    printf("odd\nor none.\n");
    blank();
    printf("Ensure that the parity's are identical.\n");
    return respny();
}

int databits()
{
    clear();
    printf("Check that each device is set for the same number of data bits.");
    printf("\nUsual values are  7  or  8.\n");
    blank();
    printf("Ensure that the data bits selected are identical. \n");
    return respny();
}

int pc()
{
    clear();
    printf("Is one or both devices an IBM or compatible PC? \n");
    return resp("No", "Yes");
}

int pcmale()
{
    clear();
    printf("Check that the cable is connected to the PC's serial and\n");
    printf("not parallel port.\n");
    printf("The serial port has male pins protruding from it, the parallel\n");
    printf("port is female. \n");
    blank();
    printf("Make sure the cable is connected to the serial port.\n");
    return respny();
}

int pcport()
{
    clear();
    printf("If you have more than one serial port or have a PCjr, make sure");
    printf("\nyou are connected to the correct serial port.\n");
    blank();
    printf("The port that comes on an XT, usually closest to the side with\n");
    printf("the power switch, is COM1.  The serial port on back of a PCjr\n");
    printf("may look like COM1 or COM2 depending on the way the software\n");
    printf("accesses it.  Try switching to the other port if you\n");
    printf("are in doubt.\n");
    blank();
    printf("Double check which port is used, switch the cable, or tell the\n");
    printf("program to use the other if there is another or you have a PCjr.");
    printf("\n");
    return respny();
}

int bothpc()
{
    int r;

    clear();
    printf("Are both devices IBM or compatible PCs?\n");
    if (r = resp("No","Yes")) nullmodem();
    return r;
}

int pcterm()
{
    int r;

    clear();
    printf("Is the other device a terminal?\n");
    if (r = resp("No","Yes")) nullmodem();
    return r;
}

int pcmodem()
{
    int r;

    clear();
    printf("Is the other device a modem?\n");
    if (r = resp("No","Yes")) (void)fullcable();
    return r;
}

int pcprint()
{
    int r;

    clear();
    printf("Is the other device a printer?\n");
    if (r = resp("No","Yes")) {
	clear();
	blank();
	printf("Make sure the printer is an RS-232 device and not a ");
	printf("Centronics\nparallel device.  If it is Centronics, you need ");
	printf("to attach it\nto the parallel port of the PC.\n");
	wait();
    }
    return r;
}

int fullcable()
{
    clear();  blank();
    printf("Try a straight thru cable that uses all 25 pins.  Make sure the");
    printf("\ncable is not a null modem cable.\n");
    return respny();
}

void nullmodem()
{
    clear();
    printf("You need a null modem cable.  You can purchase one from a\n");
    printf("computer store.  You can also make one yourself by wiring\n");
    printf("up a cable as shown below.\n");
    blank();
    printf("     2 ------------------------------------------------ 3\n");
    printf("     3 ------------------------------------------------ 2\n");
    printf("     4 ------------------------------------------------ 5\n");
    printf("     5 ------------------------------------------------ 4\n");
    printf("     6 ------------------------------------------------ 20\n");
    printf("     7 ------------------------------------------------ 7\n");
    printf("    20 ------------------------------------------------ 6\n");
    blank();
    printf("If the null modem cable doesn't work, see someone in Digital\n");
    printf("Electronics for help.\n");
    wait();
    return;
}

int term()
{
    clear();
    printf("Is one or both devices a terminal?\n");
    return resp("No","Yes");
}

int decterm()
{
    clear();
    printf("If the terminal is a DEC model such as VT100 or VT220\n");
    printf("and other device is not a DEC computer or modem to a DEC\n");
    printf("computer (e.g. VAX), turn off the XON/XOFF feature.\n");
    return respny();
}

int bothterm()
{
    int r;

    clear();
    printf("Are both devices terminals?\n");
    if (r = resp("No","Yes")) nullmodem();
    return r;
}

int dcedte()
{
    clear();
    printf("RS-232 devices fall into two classes - DTE (Data Terminal ");
    printf("Equip.)\nand DCE (Data Communications Equip.).  Try a full 25 ");
    printf("pin straight\nthrough cable if one device is DTE and the other ");
    printf("DCE.  If both\ndevices are DTEs or DCEs, you need a null modem ");
    printf("cable. The device\nmanual may indicate the device's type.\n");
    blank();
    printf("Devices that are usually DTEs: terminals and IBM compatible PCs.");
    printf("\nDevices that are usually DCEs: modems, ports to minicomputers,");
    printf("\n   printers, VME bus serial ports, and devices designed to ");
    printf("talk\n   with terminals such as serial ports on micro ");
    printf("development\n   systems.\n");
    blank();
    printf("Does it seem that you need a null modem cable as the devices are");
    printf("\nboth DTEs or DCEs?\n");
    if (resp("No","Yes")) nullmodem();
    clear();
    return respny();
}

void devincomp()
{
    clear();
    printf("The devices are probably not supplying all the signals required");
    printf("\nby the other.  See someone in Digital Electronics for help.\n");
    wait();
    return;
}


int respny()
{
    blank();
    printf("    Are the devices communicating properly now?\n");
    return resp("No","Yes");
}


int resp(zero,one)
char *zero,*one;
{
    char buf[256], *gets();

    blank();  blank();
    printf("            0  - %s \n",zero);
    blank();
    printf("            1 -  %s \n",one);

    do {
	scr_rowcol(22,10);
	printf("Enter either 0 or 1, then hit <return>: ");
    } while (*gets(buf) != '0' && *buf != '1');
    return *buf == '1';
}

void wait()
{
    char buf[256], *gets();

    scr_rowcol(22,10);
    printf("Hit <return> to continue.....");
    (void)gets(buf);
    return;
}


void clear()
{
    scr_clr();	scr_rowcol(1,1);
    return;
}

void blank()
{
    printf("\n");
    return;
}


