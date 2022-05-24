
#include <stdio.h>		/* library function header files */
#include <conio.h>
#include <ctype.h>

#define UART	 0x3F		/* MPU-401 command to UART mode */
#define SYSRESET 0xFF		/* reset command for MPU-401 */
#define BUFSIZE  1000		/* how big to make data buffer */
#define ESC	 27		/* ASCII code for ESC char */

int	 getdata(void);
int      putdata(int);
void 	 putcmd(int);

main()
{
    int currentsong[500][2];
	int i, j, k, slow, count;

    putcmd(UART);		/* put MPU-401 in UART mode */

	j = 0;
	count=0;


	while ((i = getdata()) != -1 || j<=498)
	{	/* read in MIDI data until none left */
		count++;
		for(slow = 0; slow < 1000; slow++);
		if (i != -1)
		{
		currentsong[j++][1]=count;
		currentsong[j][2]=i;
		}

	printf("\n %d    %d",j,count);
	putdata(j);
	}
	{
	    for (k = 0; k < 498; k++)
		    {
			printf("\npos %d ->",k);
			printf(" %02x",currentsong[k][1]);
			printf(" %02x",currentsong[k][2]);
		    }

	 }


    putcmd(SYSRESET);
    return 1;
}
