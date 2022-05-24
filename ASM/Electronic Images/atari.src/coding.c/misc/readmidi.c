/* readmidi.c   simple MIDI data input and output via the  mpu-401 */

#include <stdio.h>		/* library function header files */
#include <conio.h>
#include <ctype.h>

#define UART	 0x3F		/* MPU-401 command to UART mode */
#define SYSRESET 0xFF		/* reset command for MPU-401 */
#define BUFSIZE  1000		/* how big to make data buffer */
#define ESC	 27		/* ASCII code for ESC char */

void putcmd(int);
int getdata(void);
void putdata(int);
int xtoi(char *, int *);
int hextran(char);

void main()
{
	char str[4];
	int i, j, k, n, *m;
	static int mdata[BUFSIZE];	/* store midi data here */
	m = &j;

	printf("\n   **** READMIDI - MIDI Data Input And Output ****");
	printf("\n\n\nThis program sends and receives MIDI data.");
	printf("\nAll data is displayed in hexadecimal (base 16).");
	printf("\n\nTo enter MIDI data, first hit the space bar. Then");
	printf("\nenter MIDI commands by typing in two hex digits.");
	printf("\n\nExit this program by hitting the ESC key.\n\n");

	putcmd(UART);		/* put MPU-401 in UART mode */

    while (1){
	j = 0;
	while ((i = getdata()) != -1){	/* read in MIDI data until none left */
	    mdata[j++] = i;
	    if (j > BUFSIZE - 1){
		printf("\n*** MIDI data overflowed buffer ***");
		break;
	    }
	}
	if (j){
	    for (k = 0; k < j; k++){	/* print all there is in one shot */
		if (mdata[k] >= 0x80)
		    printf("\n");
		if (mdata[k] != 0xFE)	/* screen active sensing bytes out */
		    printf(" %02x",mdata[k]);
	    }
	}
	
	if (kbhit()){		/* if key pressed, prompt for MIDI data */
	    n = getch();
	    if (n == ESC)	/* quit if ESC key pressed */
		break;
	    printf("\nInput two hex digits, then <ret>. ->");
	    gets(str);
		n = xtoi(str, m);
	    if (n > 0 && n < 3)
		putdata(*m);	/* send data to MIDI out of MPU401 */
	    else
		printf("\nUse only two 0-9,A-F digits. ESC to exit.");
	}
	}
    putcmd(SYSRESET);
}


xtoi(str, nbr)	/* converts hex string to int, returns number of */ 
char *str;	/* valid hex chars read (4 max) */
int *nbr;
{
    int n, i;
    *nbr = i = 0;
    do{
	if ((n = hextran(str[i])) < 0)
	    break;
	else
	    *nbr = (*nbr * 16) + n;	
    }while (++i < 4);
    return(i);
}



hextran(hex)	/* convert 1 hex char to decimal */
char hex;
{
    hex = toupper(hex);
    if (hex >= '0' && hex <= '9')
	return(hex - '0');
    else if (hex >= 'A' && hex <= 'F')
	return(hex - 'A' + 10);
    else
	return(-1);		/* no match with hex chars */
}

