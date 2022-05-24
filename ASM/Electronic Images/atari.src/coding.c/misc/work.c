/* libraries used */

#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <graphics.h>

#define UART	 0x3F		/* MPU-401 command to UART mode */
#define ESC	 27		/* ASCII code for ESC char */
#define SYSRESET  0xFF		/* reset command for the Roland MPU-401 */
#define STARTPLAY 0x0A
#define STOPPLAY  0x05
#define BUFSIZE   1000		/* how big to make data buffer */
#define STARTREC  0x22
#define STOPREC   0x11
#define YES       0x79
#define NO        0x6E

/* function prototypes */
void putdata(int);
int getdata(void);
void putcmd(int);
void Quit(void);
void Help(void);
void Save(void);
void Load(void);
void Edit(void);
void Output(void);
void Input(void);
/*void initalise(void);
void stop(void);
void initalise2(void);
void readinput(void);
void stop(void);
void draw_screen_lines(void);
void place_note_data(void);
void highlight(int, int, int);
void unhighlight(int, int, int);*/


/* global variables */

char opt;
char responce;
int now,count;

struct midi_data
	{
	int time;
	int on_off;
	int pitch;
	int velocity;
	}note_data;

int currentsong[500][2];
/* main program */

void main(void)
{
 do {
	clrscr();
	printf("\n\n\n\n\n                               Main Menu");
	printf("\n                               ---------");
	printf("\n\n\n                 1....Inport data from MIDI");
	printf("\n\n                 2....Export data to MIDI");
	printf("\n\n                 3....Edit/Create data");
	printf("\n\n                 4....Load data from disk");
	printf("\n\n                 5....Save data to disk");
	printf("\n\n                 6....Help");
	printf("\n\n                 7....Quit");
	opt = getch();
	switch (opt) {
		case '1' : Input();
			break;
		case '2' : Output();
			break;
	    /*	case '3' : Edit();
			break;*/
		case '4' : Load();
			break;
		case '5' : Save();
			break;
		case '6' : Help();
			break;
		case '7' : Quit();
			break; }
} while (opt != '7');
}

/* procedures */

void Quit(void)
{
 char yn;
 clrscr();
 printf("Are you sure you wish to quit? (y/n)");
 yn = getch();
 if (yn == 'n')
	{opt = '0';}
 else if (yn == 'y')
	{}
 else
	{Quit();}
}

void Help(void)
{
char choice;
do {
	clrscr();
	printf("\n\n\n\n\n                               Help Menu");
	printf("\n                               ---------");
	printf("\n\n\n                   1....Importing data from MIDI");
	printf("\n\n                   2....Exporting data to MIDI");
	printf("\n\n                   3....Editing/Creating data");
	printf("\n\n                   4....Loading data from a disk");
	printf("\n\n                   5....Saving data to a disk");
	printf("\n\n                   6....Main Menu");
	choice = getch();
	switch (choice) {
		case '1' : clrscr();
			   printf("\n\n\n     Importing Data From The MIDI");
			   printf("\n\n explan");
			   getch();
			break;
		case '2' : clrscr();
			   printf("\n\n\n     Exporting Data To The MIDI");
			   printf("\n\n explan");
			   getch();
			break;
		case '3' : clrscr();
			   printf("\n\n\n     Editing/Creating Data");
			   printf("\n\n explan");
			   getch();
			break;
		case '4' : clrscr();
			   printf("\n\n\n     Loading Data From Disk");
			   printf("\n\n explan");
			   getch();
			break;
		case '5' : clrscr();
			   printf("\n\n\n     Saving Data To Disk");
			   printf("\n\n explan");
			   getch();
			break;
		case '6' :
			break;}
} while (choice != '6');
}


void Load(void)
{

FILE *fp;
int x,y;
char *filename;

	printf ("Please Enter Filename : ");
	scanf ("%s",filename);
	fp = fopen(filename,"r");
	if(fp == NULL)
	{
		printf("File does not exist\n");
		getch();
		clrscr();
	}
	else
	{
		x=0;
		for (y=0; y==3; y++)
		{
			fscanf (fp,"%c",currentsong[x][y]);
		}
		while (currentsong[x][y] != EOF)
		{
			x++;
			for (y=0; y==3; y++)
			{
			fscanf (fp,"%c",currentsong[x][y]);
			}
		fclose(fp);
		}
	}
}

void Save(void)
{

FILE *fp;
int x,y;
char *filename;

	printf ("Please Enter Filename : ");
	scanf ("%s",filename);
	fp=fopen(filename,"w");
	x=0;
	for (y=0; y==3; y++)
	{
		fprintf (fp,"%c",currentsong[x][y]);
	}
	while (x <= 10)
	{
		x++;
		for (y=0; y==3; y++)
		{
		fprintf (fp,"%c",currentsong[x][y]);
		}
	fclose(fp);
	}
}


void Input(void)
{

	int i, j, k, n, slow, count;

	putcmd(UART);		/* put MPU-401 in UART mode */

	j = 0;
	count=0;
	clrscr();
	printf("WARNING!\n");
	printf("Current song will be lost\n");
	printf("Continue? Y/N");
	while(responce != YES && responce != NO)
	{
		responce = getch();
		if(responce == YES);
		{
			clrscr();
			while(!kbhit)
			{
				printf("recording\n");
				while ((i = getdata()) != -1 || j<=498)
				{	/* read in MIDI data until none left */
				count++;
				gotoxy(5,5);
				printf("clock : %d",count);
				for(slow = 0; slow < 1000; slow++);
				if (i != -1)
				{
					currentsong[j++][1]=count;
					currentsong[j][2]=i;
				}
				}
			}
		}
	}
}

void Output(void)
{
	int now,count,speed,x;
	now = 0; /* variable represents clock */
	count = 0; /* variable represents when to play */
	clrscr();
	x = 1000;
		while (currentsong[count][1] !=0)
		{
		for(speed=0;speed<x;speed++);
		now++;
		if (currentsong[count][1] == now)
			/* write data to output port */
			{
				putdata(currentsong[count][2]);
			}
			count++;
		}
}

/*
void initalise()
{
	putcmd(UART);
	putcmd(STARTPLAY);       /* starts reciving data*/
/*}

void initalise2()
{
	putcmd(UART);
	putcmd(STARTREC);       /* starts reciving data*/
/*}

void stop()
{
	putcmd(STOPPLAY);	/* stops reciving data */
  /*	putcmd(UART);
}



void stop2()
{
	putcmd(STOPREC);	/* stops reciving data */
    /*	putcmd(UART);
}*/