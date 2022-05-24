
#include <stdio.h>
#include <conio.h>
#include <ctype.h>

#define SYSRESET 0xFF		/* reset command for the Roland MPU-401 */
#define BUFSIZE  1000		/* how big to make data buffer */
#define STARTREC 0x22
#define STOPREC  0x11
#define YES      0x79
#define NO       0x6E

struct midi_data
	{
	int time;
	int on_off;
	int pitch;
	int velocity;
	}note_data;

char currentsong[100][4];

void initialise(void);
void readinput(void);
void stop(void);

void main()
{
char responce;
int now,count;

	clrscr();
	printf("WARNING!\n");
	printf("Current song will be lost\n");
	printf("Continue? Y/N");
	while(responce != YES && responce != NO)
	{
		responce = getch();
		if(responce == YES);
		{
			initalise();
			clrscr();
			printf("Play any note to begin");
			while(note_data.on_off == 0 && !kbhit())
			{
				readinput();
			}
			now = 0;
			clrscr();
			printf("Press any key to finish");
			while(!kbhit())
			{
				count = 0;
				while(count <= 3 && note_data.time == now)
				{
					currentsong[now][count] = note_data.pitch;
					readinput();
					count ++;
				}
				now ++;
			}
			stop();
		}
	}
}

initalise()
{
	putcmd(SYSRESET);       /* put the Roland MPU-401 in INTELLEGENT mode */
	putcmd(STARTREC);       /* starts reciving data*/
}

void readinput()
{
int i,j,k,l;
static int mdata[10];

    while (1)
    {
	j = 0;
	while ((i = getdata()) != -1)
	{
		/* reads in MIDI data until none left */
		mdata[j++] = i;
		if (j > BUFSIZE - 1)
		{
			printf("\n*** MIDI data overflowed buffer ***");
			break;
		}
	}
	while( k <= j)
	{
		for (l = 0; l < 4; l++)
		{
			note_data.time = mdata[k];
			k++;
			note_data.on_off = mdata[k];
			k++;
			note_data.pitch = mdata[k];
			k++;
			note_data.velocity = mdata[k];
			k++;
			printf("number%d  time%02x  note%02x \n",l,note_data.time,note_data.pitch);
		}
	}
	}
}

void stop()
{
	putcmd(STOPREC);	/* stops reciving data */
	putcmd(SYSRESET);	/* resets roland MPU - 401 */
}

