/* libraries used */

#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <graphics.h>


#define SYSRESET  0xFF		/* reset command for the Roland MPU-401 */
#define START_PLAY 0x0A
#define STOP_PLAY  0x05
#define BUFSIZE   1000		/* how big to make data buffer */
#define STARTREC  0x22
#define STOPREC   0x11
#define YES       0x79
#define NO        0x6E
#define	CLEAR_PCOUNT	0xB8	/* clears all play counters */
#define	REQ_TRK(n)	(0xF0 | ((n) & 0x07))
#define	CLEAR_PMAP		0xB9	/* clears all channel reference tables */
#define	SET_TEMPO	0xE0	/* set tempo */
#define	BEND_ON	0x87	/* enable continuous controller msgs */
#define	ACK		0xFE	/* MPU's acknowledement of a command */
#define	ACT_TRACK	0xEC	/* set active tracks bitmap */


/* function prototypes */
void putdata(int);
int getdata(void);
void sendcmd(int);
void Quit(void);
void Help(void);
void Save(void);
void Load(void);
void Edit(void);
void Output(void);
void Input(void);
void initalise(void);
void stop(void);
void initalise2(void);
void readinput(void);
void stop(void);
void draw_screen_lines(void);
void place_note_data(void);
void highlight(int, int, int);
void unhighlight(int, int, int);
void init_mpu401(void);

/* global variables */

char opt;
char responce;
int now,count;

struct midi_event
	{
	int	data_cnt;
	int data[4];
	struct midi_event *next;
	};

char currentsong[100][4];

struct midi_event *eventalloc(void);
struct midi_event *store(struct midi_event *,int,int,int,int,int);
struct midi_event *record(void);
void play(struct midi_event *);




/* main program */

void main(void)
{
	struct midi_event *track_data;

	init_mpu401();
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
		case '1' : track_data=record();
			break;
		case '2' : play(track_data);
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



struct midi_event *record()	/* record a track, stop on any keypress */
{
    int first, second, third, fourth, mstatus;
	struct midi_event *firstnode;
	struct midi_event *nextnode;

	mstatus = 0;
	firstnode = eventalloc();	/* start memory allocation with first node */
	nextnode = firstnode;
	while (kbhit()) getch();	/* clear any stray keypress */
	sendcmd(STARTREC);
	printf("attempting to record");
	getch();

	while (1){
	first = get401();
	printf("\nfirst: %d", first);
	if (first == -1){		/* a keypress */
		while (kbhit()) getch();
		sendcmd(STOPREC);
		first = get401();
	}
	if (first <= 0xEF){		/* timing byte */
		second = get401();
		if (second <= 0x7F){		/* MIDI data, running status assumed */
		third = get401();
		nextnode = store(nextnode,4,first,mstatus,second,third);
		}
		else if (second <= 0xBF){	/* MIDI message, note on/off */
		mstatus = second;	/* after touch or control change */
		third = get401();
		fourth = get401();
		nextnode = store(nextnode,4,first,second,third,fourth);
		}
	    else if (second <= 0xDF){	/* prog change or chan after touch */
		mstatus = second;
		third = get401();
		nextnode = store(nextnode,3,first,second,third,0);
		}
		else if (second <= 0xEF){	/* pitch wheel */
		mstatus = second;
		third = get401();
		fourth = get401();
		nextnode = store(nextnode,4,first,second,third,fourth);
		}
		else if (second == 0xF9){	/* measure end */
		nextnode = store(nextnode,2,first,second,0,0);
		}
		else if (second == 0xFC){	/* data end for track */
		nextnode = store(nextnode,2,first,second,0,0);
		return(firstnode);	/* only one track recording, so done */
		}
		else{
		printf("\nUnrecognized data %x %x",first,second);
		}
	}
	else if (first <= 0xF7)		/* track data requests */
		printf("\nTrack data was requested (%x)",first);
	else if (first == 0xF8)		/* time out */
		nextnode = store(nextnode,1,first,0,0,0);
	else if (first == 0xF9)		/* conductor request */
		printf("\nGot a conductor data request.");
	else if (first == 0xFC)		/* all end */
		return(firstnode);
	else if (first == 0xFD)		/* mpu send clock signal */
		printf("\nGot a clock out signal (%x)",first);
	else if (first == 0xFE){		/* ignore acknoledge */
	}
	else{
		cputs("Record stopped.");
		return(firstnode);
	}

	if (nextnode == NULL){
		cputs("Could not allocate more memory (full?), record stopped.");
		sendcmd(STOPREC);
		get401();
		return(firstnode);
	}
	}
}


struct midi_event *eventalloc()		/* returns pointer to memory area */
{					/* sized for one event. */
	return((struct midi_event *)malloc(sizeof(struct midi_event)));
}



struct midi_event *store(struct midi_event *node,int nbytes,int b1,
							int b2,int b3,int b4)
{
	node->next = eventalloc();
	(node->next)->next = NULL;	/* null pointer in next node to mark end */
	node->data_cnt = nbytes;
	node->data[0] = b1;
	node->data[1] = b2;
	node->data[2] = b3;
	node->data[3] = b4;
	return(node->next);
}



void play(struct midi_event *events)		/* play tracks */
{
	int i, cmd, trk, firstcmd;
	firstcmd = 1;

	sendcmd(ACT_TRACK);
	putdata(1);			/* activate track one only */




	while (kbhit()) getch();		/* clear any stray keypress */

	sendcmd(CLEAR_PCOUNT);		/* clear play counters */
	sendcmd(START_PLAY);
	printf("\nSent Commands");

	while (1){
	cmd = get401();			/* get next mpu-401 request */
	printf("\ncommand: %2X",cmd);
	if (cmd == -1)
		break;			/* quit on keypress */
	if (cmd >= REQ_TRK(0) && cmd <= REQ_TRK(7)){		/* track req */
		firstcmd = 0;
 //		trk = cmd - REQ_TRK(1);				/* track number */
		for (i = 0; i < events->data_cnt; i++){
		putdata(events->data[i]);		/* send data bytes */
		}
		if (events->next == NULL)
		break;
		else
		events = events->next;	/* move track counter */
								/* forward one event */
	}
	else if (cmd == 0xFC){
		if (firstcmd)		/* don't quit if received at start */
		firstcmd = 0;
		else
		break;
	}
	}
	sendcmd(STOP_PLAY);
	sendcmd(CLEAR_PMAP);
	printf("\nFinished playing");
}



void clear(struct midi_event *event)			/* clear a track from memory */

{
	struct midi_event *nextevent;

	do{
	nextevent = event->next;
	free(event);
	event = nextevent;
	}while (event != NULL);
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



void initalise()
{
	sendcmd(SYSRESET);       /* put the Roland MPU-401 in INTELLEGENT mode */
	sendcmd(START_PLAY);       /* starts reciving data*/
}

void initalise2()
{
	sendcmd(SYSRESET);       /* put the Roland MPU-401 in INTELLEGENT mode */
	sendcmd(STARTREC);       /* starts reciving data*/
}

void stop()
{
	sendcmd(STOP_PLAY);	/* stops reciving data */
	sendcmd(SYSRESET);	/* resets roland MPU - 401 */
}
 

 
void stop2()
{
	sendcmd(STOPREC);	/* stops reciving data */
	sendcmd(SYSRESET);	/* resets roland MPU - 401 */
}



void init_mpu401()
{
	putcmd(SYSRESET);			/* clear MPU-401 */
	sendcmd(BEND_ON);			/* allow pitch bend data to pass */
	sendcmd(SET_TEMPO);			/* set tempo to default value */
	putdata(120/2);
//	sendcmd(METRO_MEAS); 		/* set meter to default value */
 //	putdata(4);
}

/***
int get401()
{
	int i;

	while (1){
	i = getdata();
	if (kbhit()) return(-1);
	if (i != -1) return(i);
	}

}

void sendcmd(int n)	/* send a command, check for ACK, if not save MPU data
		/* until it stops sending
{
	int ans;

	ans = putcmd(n);
	if (ans == ACK)
	return;
	while(ans!= -1 && ans != ACK)
		ans=getdata();

}
****/


int cmdbuf[BUFSIZE];		/* global buffer for pending MPU commands */

int cmdbufp = 0;		/* next free position in cmdbuf */

getnext()	/* get a possibly pushed back command from MPU or cmdbuf */
{
	return((cmdbufp > 0) ? cmdbuf[--cmdbufp] : getdata());
}


void ungetnext(int n)	/* push a command back on input */
{
	if (cmdbufp > BUFSIZE)
	printf("\nungetnext ran out of buffer space.");
	else
	cmdbuf[cmdbufp++] = n;
}
get401()		/* get next byte from mpu401 (or pending buffer) */
{			/* try forever, stop on keypress */
	int i;
    
    while (1){
	i = getnext();
	if (kbhit()) return(-1);
	if (i != -1) return(i);
    }
}



void sendcmd(int n)	/* send a command, check for ACK, if not save MPU data */
{
    int ans;

    ans = putcmd(n);
    if (ans == ACK)
	return;
    else if (ans != -1){
	ungetnext(ans);		/* put pending data on stack */
	while (1){		/* check for more incoming data */
	    ans = getdata();
	    if (ans == ACK || ans == -1)
		return;
	    else
		ungetnext(ans);
	}
    }
}
