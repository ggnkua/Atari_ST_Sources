/************************************************************************/
/*               STEreo SAMPLE SEQUENCING SYSTEM V1.10beta              */
/*                       written by PHAZE Shift                         */
/*                                                                      */
/*                         C-Source Code ONLY                           */
/*            must be linked with assembled machine code file           */
/*                        ½ Ian Hancock 19/11/92                        */
/************************************************************************/

/***************************** INCLUDE FILES ****************************/
#include	<osbind.h>
#include	<stddef.h>
#include	<errno.h>
#include 	<stdio.h>
#include 	<stdlib.h>
#include 	<string.h>
#include	<dos.h>
#include 	<aes.h>
#include 	<vdi.h>
#include 	"seqmed.h"
/************************* FUNCTION PROTOTYPES **************************/
char *Sample_load(char wholename[80]);
void handle_dialog(OBJECT *dlog);
void initialise(void);
void deinitialise(void);
void waiting(int time);
int direct(int lineno);
void Sample_save(char wholename[80], int sam);
void loaddat(OBJECT *dlog,int a,int b,short x,short y,short w,short h,char nom[30],short mode,int sam);
void Sequence_save(char wholename[80],short mode);
void Sequence_load(char wholename[80],short mode);
void set_button(OBJECT *tree,int parent,int button);
int playing(int lineno);
void recording(void);
void Sample_list(int lineno2);
void cls(void);
void seq_display(int lineno);
void editing(int lineno);
int get_end(void);
/***************************** FILE STRUCTURES **************************/
struct file {			/* Audio Visual Research 1st 30 bytes of header*/
	char	ident[4];
	char	name[8];
	short stereo;
	short resolution;
	short sign;
	short loop;
	short midi;
	int speed;
	int length;
} avr;
struct seq {			/* my sequence file header */
	char	ident[19];	/* id code */
	char	samples;		/* no of samples used */
	unsigned int slength;	/* length of sequence file */
	unsigned int size[18];	/* length of each sample */
} amazinge;
/**************************** GLOBAL VARIABLES **************************/
char *sam_start[19];	/* array of pointers to samples in memory */
int space = 32000;	/* memory allocated for sequence in bytes */
long error;		/* return val from proggy, or negative (error) */
char count = -1;	/* number of samples in memory minus 1 */
unsigned short int *sequence, *buffer;	/* pointers to the sequence and */
								/* buffer area */
short vdi;	/* Virtual Device Number */
char pathname[70] = "A:\*.*";		/* File path */
char key[] = "()/*7894561230.E";
/********************************* PROGRAM ******************************/
int main(void)
{
OBJECT *dlog;

	initialise();
	
	rsrc_gaddr(R_TREE,SEQ,&dlog);		/* get address of form in dlog */
	handle_dialog(dlog);			/* main loop */
	
	deinitialise();
	return EXIT_SUCCESS;
}
/****************** SET UP GEM - LOAD RSC. ALLOCATE MEMORY **************/
void initialise(void)
{
short work_in[11]={1,1,1,1,1,1,1,1,1,1,2};
short work_out[57];
short junk;
short screenx,screeny,screenw,screenh;
	
	if (appl_init())	/* open aes application */
		exit(EXIT_FAILURE);
	vdi = graf_handle(&junk, &junk, &junk, &junk);	/* get temp. vdi no */
	v_opnvwk(work_in, &vdi, work_out);	/* update vdi id number */
	if (!vdi)
		exit(EXIT_FAILURE);		/* vdi failure */
		
	if (Getrez() == 2)
	{
		if (!rsrc_load("seqhigh.RSC"))	/* load resource file */
		{
			form_alert(1,"[3][RESOURCE FILE ERROR][ QUIT ]");
			exit(EXIT_FAILURE);
		}
	}
	else if (Getrez() == 0)
	{
		form_alert(1,"[3][SORRY MEDIUM | OR HIGH RES. ONLY][ QUIT ]");
		exit(EXIT_FAILURE);
	}
	else
	{
		if (!rsrc_load("seqmed.RSC"))	/* load resource file */
		{
			form_alert(1,"[3][RESOURCE FILE ERROR][ QUIT ]");
			exit(EXIT_FAILURE);
		}
	}
	wind_get(DESK,WF_WORKXYWH,&screenx,&screeny,&screenw,&screenh);
		/* get screen size co-ords */
	graf_mouse(ARROW,NULL);	/* put mouse on screen */

	if ((sequence = malloc(space)) == NULL)	/* sample bank memory */
	{
		form_alert(1,"[3][ OUT OF MEMORY ERROR | CANNOT INSTALL !][ CANCEL ]");
		exit(EXIT_FAILURE);
	}
	if ((buffer = malloc(32000)) == NULL)	/* sample bank memory */
	{
		form_alert(1,"[3][ OUT OF MEMORY ERROR | CANNOT INSTALL !][ CANCEL ]");
		exit(EXIT_FAILURE);
	}
	/*  allocate space bytes for sequence and buffer */
	*(sequence+3) = 0xffff;	/* put end of sequence flag in sequence */
	count = -1;	/* no samples in memory */
	Click(0);		/* MC- turn off keyclick + bell */
}
/*********************** SHUT DOWN - CLOSE WORK BASE ********************/
void deinitialise(void)
{
	rsrc_free();		/* free up resource file */
	v_clsvwk(vdi);		/* close work station */
	appl_exit();		/* close aes application */
	Click(7);			/* MC- restore keyclick and bell */
}
/***************************** MAIN SUB-ROUTINE *************************/
void handle_dialog(OBJECT *dlog)
{
	char ok;			/* response from keyboard */
	short x,y,w,h;		/* screen co-ords */
	char *path;		/* pointer to pathname (file path) */
	int but, cnt;		/* but = what button pressed */
	int lineno = 0;	/* line position in sequence */
	int lineno2 = 0;	/* line position in sample list */
	int radio = DMSAM;	/* set list mode to sample list */
	int an_error;		/* set to 1 or 2 if a record error occurs */
	
	path = &pathname[0];		/* set pointer to start of pathname */
	set_button(dlog,DMODE,radio);	/* set radio button to highlight sample */
	
	form_center(dlog,&x,&y,&w,&h);	/* get centre form on screen co-ords */
	form_dial(FMD_START,0,0,0,0,x,y,w,h);	/* grow from 0,0,0,0 */
	form_dial(FMD_GROW,x+w/2,y+h/2,0,0,x,y,w,h); /* do grow */
	objc_draw(dlog,ROOT,MAX_DEPTH,x,y,w,h);		/* draw form */
	but = DRECORD;		/* but initialised (so it won't exit */
	while (but != DBYE)	/* if not clicked on exit */
	{
		set_button(dlog,DMODE,radio);		/* highlight right radio but */
		while (Crawio(0x00ff) != 0);

		but = form_do(dlog, 0);		/* let user interact */
		vs_curaddress(vdi, 10, 15);	/* set cursor to top of box */
		STOP();	/* MC clears sound chip incase exit */
		switch (but)	/* what button was pressed */
		{
			case DTEST:	/* test mode */
				printf("***** TEST ***** NON-SAMPLE KEY TO STOP   ");
				TEST(&sam_start[0], count);	/* MC */
				STOP();	/* MC */
				break;
			
			case DPLAY:	/* play mode */
				printf("***** PLAY *****                          ");
				lineno = playing(lineno);   /* MC - return current line */
				if (lineno < 0)	/* occasionally = -1; CORRECTION */
					lineno = 0;
				break;

			case DRECORD:	/* recording mode */
				if (*(sequence+3) == 0xffff)	/* if seq. is empty */
					ok = 1;
				else		/* else ask if you want to wipe */
				{
					ok = form_alert(1,"[3][ CLEAR CURRENT MIX !][ YES | NO ]");
				}
				if (ok == 1)
				{
					vs_curaddress(vdi, 10, 15);	/* set cursor */
					printf("***** RECORD ***** NON-SAMPLE KEY STOPS   ");
					recording();	/* C sets up record and calls MC */
					lineno = 0;	/* reset line position to start of seq. */
				}
				break;

			case DODUB:	/* dubbing mode */
				/* if not an empty seq. and not on start line pos */
				if (*(sequence+3) != 0xffff && lineno != 0)
				{
					ok = form_alert(1,"[2][ WIPE FROM CURRENT TO END !][ YES | NO ]");
					if (ok == 1)
					{
						vs_curaddress(vdi, 10, 15);
						printf("***** DUBBING ***** NON-SAMPLE KEY STOPS  ");
						if (an_error = RECORD(&sam_start[0],count,sequence+lineno,space-(lineno*2),0))	/* MC */
						{
							vs_curaddress(vdi, 10, 15);
							if (an_error == 2)
								form_alert(1,"[3][ OUT OF MEMORY IN SEQUENCE FILE ! | ADVISE SAVING YOUR SEQUENCE | AND RESTART ! ][ OK ]");
							else
								form_alert(1,"[3][ OUT OF TIME | 65535 UNITS ONLY !!! ][ SORRY ]");							
						}
						STOP();	/* MC */
						lineno = 0;	/* reset line pos to start */
					}
				}
				break;
				
			case DMIX:	/* mixing mode */
				printf("***** MIXING ***** NON-SAMPLE KEY STOPS  ");
				editing(lineno);	/* C - calls MC */
				break;
				
			case DDIRECT:	/* direct editing of seq. */
				Click(6);
				if (radio == DMSEQ)		/* if in seq. list mode */
					lineno = direct(lineno);
				Click(0);
				break;
				
			case DUP:		/* up cursor */
				if (radio == DMSEQ && lineno-2 >= 0) /* if in seq mode and can go up */
					lineno -= 2;
				else if (radio == DMSAM && lineno2-1 >= 0) /* if in sam mode and can go up */
					lineno2--;
				break;
			
			case DDOWN:	/* down cursor */
				if (radio == DMSEQ && lineno+2 <= get_end())
					lineno += 2;
				else if (radio == DMSAM && lineno2+1 <= count)
					lineno2++;
				break;
			
			case DFUP:	/* jump 7 lines up cursor */
				if (radio == DMSEQ && lineno-14 >= 0)
					lineno -= 14;
				else if (radio == DMSEQ)
					lineno = 0;
				else if (radio == DMSAM && lineno2-7 >= 0)
					lineno2 -= 7;
				else if (radio == DMSAM)
					lineno2 = 0;
				break;
				
			case DFDOWN:	/* jump 7 lines down cursor */
				if (radio == DMSEQ && lineno+14 <= get_end())
					lineno += 14;
				else if (radio == DMSEQ)
					lineno = get_end();
				else if (radio == DMSAM && lineno2+7 <= count)
					lineno2 += 7;
				else if (radio == DMSAM && count >= 0)
					lineno2 = count;
				break;
				
			case DTOP:	/* scroll to top cursor */
				if (radio == DMSEQ)
					lineno = 0;
				else
					lineno2 = 0;
				break;
				
			case DBOTTOM:	/* scroll to bottom cursor */
				if (radio == DMSEQ)
					lineno = get_end();
				else if (count >= 0)
					lineno2 = count;
				break;
				
			case DLSAM:	/* load a sample file */
				strmfe(path,path,"AVR");	/* add AVR extension to path */
				if (count < 15)
					loaddat(dlog,ROOT,MAX_DEPTH,x,y,w,h,"LOAD SAMPLE",0,0);
				break;

			case DDEL:
				if (count > 0 && *(sequence+3) == 0xffff)
				{
					ok = form_alert(1,"[3][ DELETE A DISK FILE | OR THE CURRENT SAMPLE | IN MEMORY !][ SAMPLE | FILE | CANCEL ]");
					if (ok == 1)
					{
						free(sam_start[lineno2]);
						while (lineno2 < 17)
							sam_start[lineno2] = sam_start[++lineno2];
						count--;
						lineno2 = 0;
					}
					else if (ok == 2)
					{
						strmfe(path,path,"*");
						loaddat(dlog,ROOT,MAX_DEPTH,x,y,w,h,"DELETE A FILE",6,0);
					}
				}
				else
				{
					strmfe(path,path,"*");
					loaddat(dlog,ROOT,MAX_DEPTH,x,y,w,h,"DELETE A FILE",6,0);
				}
				break;
			
			case DHEAD:
				strmfe(path,path,"*");
				loaddat(dlog,ROOT,MAX_DEPTH,x,y,w,h,"HEAD A FILE",7,0);
				break;
			
			
			case DSSAM:	/* save a sample file */
				if (count >= 0)
				{
					strmfe(path,path,"AVR");
					loaddat(dlog,ROOT,MAX_DEPTH,x,y,w,h,"SAVE SAMPLE",5,lineno2);
				}
				break;
			
			case DMSEQ:	/* set to sequence list mode */
				radio = DMSEQ;	/* make radio button change next loop */
				but = DCLS;	/* make it redraw the list box */
				break;
				
			case DMSAM:	/* set to sample mode */
				but = DCLS;	/* as above */
				radio = DMSAM;
				break;
				
			case DSSEQ:	/* save a sequence */
				if (count >= 0 && *(sequence+3) != 0xffff)
				{
					lineno = lineno2 = 0; /* reset line pos */
					objc_draw(dlog, DCLS, 1,x,y,w,h);	/* clear list box */
					ok = form_alert(1,"[2][ SAVE FILE !][ ALL | MIX | CANCEL ]");
					if (ok == 1)
					{
						strmfe(path,path,"SEQ");	/* set path extension */
						loaddat(dlog,ROOT,MAX_DEPTH,x,y,w,h,"SAVE MIX AND SAMPLES",1,0);
					}
					else if (ok == 2)
					{
						strmfe(path,path,"MIX");
						loaddat(dlog,ROOT,MAX_DEPTH,x,y,w,h,"SAVE MIX ONLY",2,0);
					}
				}
				else
				{
					form_alert(1,"[1][ YOU CAN'T SAVE A SEQUENCE | WITHOUT A MIX !][ CANCEL ]");
				}
				break;
			
			case DLSEQ:	/* load a sequence */
				lineno = lineno2 = 0;
				objc_draw(dlog, DCLS, 1,x,y,w,h);
				ok = form_alert(1,"[2][ LOAD FILE !][ ALL | MIX | CANCEL ]");
				if (ok == 1)
				{
					strmfe(path,path,"SEQ");
					loaddat(dlog,ROOT,MAX_DEPTH,x,y,w,h,"LOAD MIX AND SAMPLES",3,0);
				}
				else if (ok == 2)
				{
					strmfe(path,path,"MIX");
					loaddat(dlog,ROOT,MAX_DEPTH,x,y,w,h,"LOAD MIX ONLY",4,0);
				}
				break;

			case DAC:		/* all clear */
				ok = form_alert(2,"[2][ CLEAR EVERYTHING !][ YES | NO ]");
				if (ok == 1)
				{
					for (cnt=0; cnt <= count; cnt++)
						free(sam_start[cnt]);
					count = -1;
					*(sequence+3) = 0xffff;
					lineno = lineno2 = 0;
				}
				break;
				
			case DCLRMIX:	/* clear the mix */
				ok = form_alert(1,"[2][ CLEAR MIX - ONLY !][ YES | NO ]");
				if (ok == 1)
				{
					*(sequence+3) = 0xffff;
					lineno = 0;
				}
				break;
				
			case DPANIC:	/* maybe help mode */
form_alert(1,"[1][   WRITTEN BY I.D.HANCOCK | USING HISOFT'S LATTICE C V5 |------------------------------|'look for the ridiculous in |everything and you'll find it'][ SMILE ! BE HAPPY ! ]");
				break;
				
			case DBYE: /* do you wana leave */
				ok = form_alert(1,"[3][ LEAVING ME !! | |  GOODBYE !][ NOPE | YES ]");
				if (ok == 1)
				{
					dlog[but].ob_state&=~SELECTED;	/* de-select exit button */
					objc_draw(dlog, but, 1,x,y,w,h);	/* redraw button (object)*/
					but = DPANIC;
				}
				break;
				
			break;		
		}
		dlog[but].ob_state&=~SELECTED;	/* de-select exit button */
		objc_draw(dlog, but, 1,x,y,w,h);	/* redraw button (object)*/

		if (radio == DMSAM)			/* update active list */
			Sample_list(lineno2);
		else
			seq_display(lineno);

	}	/* loop, or exit */
	form_dial(FMD_SHRINK,x+w/2,y+h/2,0,0,x,y,w,h);	/* close form */
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
	dlog[but].ob_state&=~SELECTED;	/* de-select exit button */
}
/************************** SORT OUT RADIO BUTTONS **********************/
void set_button(OBJECT *tree,int parent,int button)
{
	int b;
	
	for (b=tree[parent].ob_head; b!=parent; b=tree[b].ob_next)
		if (b==button)
			tree[b].ob_state|=SELECTED;
		else
			tree[b].ob_state&=~SELECTED;
}
/************************* DIRECT EDIT ROUTINE **************************/
int direct(int lineno)
{
unsigned short int *contents;
char ok = '½';	/* keyboard input */
int difference;	/* amount to shuffle other items by (+ or -) */

	contents = sequence;	/* point contents to start of sequence */
	contents += lineno;		/* add line pos. to contents */
						/* note lineno = 2*line displace on screen */
	difference = *contents;	/* set difference to current time */
	
	if (lineno != get_end() && lineno != 0)	/* if not at start or end item */
	{
		vs_curaddress(vdi, 11, 15);
		printf("'+' INCREASE DELAY. '-' DECREASE DELAY.   ");
		vs_curaddress(vdi, 12, 15);
		printf("SPACE - CHANGE TIME WITH SHUFFLE          ");
		vs_curaddress(vdi, 13, 15);
		printf("N - CHANGE TIME WITHOUT SHUFFLE.          ");
		vs_curaddress(vdi, 14, 15);
		printf("X - DELETE WITHOUT SHUFFLE.               ");
		vs_curaddress(vdi, 15, 15);
		printf("D - DELETE WITH SHUFFLE.                  ");
		vs_curaddress(vdi, 16, 15);
		printf("Q - CANCEL.                               ");

		while ((ok = Bconin(2)) == '+' || ok == '-')
		{
			vs_curaddress(vdi, 10, 15);

			if (ok == '+' && *contents + 1 < *(contents+2))
				*contents += 1;	/* increase time if within bounds */
			if (ok == '-' && *contents - 1 > *(contents-2))
				*contents -= 1;	/* decrease as above */
		
			printf("%4d =  %5d    -    %2d                 ", (lineno/2), *contents, *(contents+3));
		}
	}
	else if (lineno != 0)	/* if not at start */
	{
		vs_curaddress(vdi, 11, 15);
		printf("'+' INCREASE DELAY. '-' DECREASE DELAY.   ");
		vs_curaddress(vdi, 12, 15);
		printf("N - CHANGE TIME WITHOUT SHUFFLE.          ");
		vs_curaddress(vdi, 13, 15);
		printf("X - DELETE WITHOUT SHUFFLE.               ");
		vs_curaddress(vdi, 14, 15);
		printf("Q - CANCEL.                               ");
		vs_curaddress(vdi, 15, 15);
		printf("                                          ");
		vs_curaddress(vdi, 16, 15);
		printf("                                          ");
		
		while ((ok = Bconin(2)) == '+' || ok == '-')
		{
			vs_curaddress(vdi, 10, 15);

			if (ok == '+' && *contents + 1 < 0xffff)
				*contents += 1;	/* increase time if within bounds */
			if (ok == '-' && *contents - 1 > *(contents-2))
				*contents -= 1;	/* decrease as above */
		
			printf("%4d =  %5d    -    %2d                 ", (lineno/2), *contents, *(contents+3));
		}
		if (ok != 'n' && ok != 'N' && ok != 'x' && ok != 'X')
			ok = 'q';
	}
	else if (lineno == 0 && *(sequence+3) != 0xffff)	/* if its the start item */
	{
		vs_curaddress(vdi, 11, 15);
		printf("D - DELETE WITH SHUFFLE.                  ");
		vs_curaddress(vdi, 12, 15);
		printf("Q - CANCEL.                               ");
		vs_curaddress(vdi, 13, 15);
		printf("                                          ");
		vs_curaddress(vdi, 14, 15);
		printf("                                          ");
		vs_curaddress(vdi, 15, 15);
		printf("                                          ");
		vs_curaddress(vdi, 16, 15);
		printf("                                          ");

		ok = Bconin(2);
		if (ok != 'D' && ok != 'd')
			ok = '½';
	}
/**********  do alteration or not !! **********/	
	if (ok == ' ')
	{
		difference = *contents - difference; /* calc difference */
		contents += 2;	/* inc. to next time in sequence */
		while (*contents != 0xffff)	/* until end flag */
		{
			*contents += difference;	/* add difference to item (shuffle) */
			contents += 2;	/* inc. to next time */
		}
	}
	else if (ok == 'N' || ok == 'n')
	{}
	else if (ok == 'D' || ok == 'd')
	{
		DELETE(sequence+lineno);	/* MC routine */
		contents = sequence+lineno;	/* set up and shuffle */
		difference -= *contents;
		while (*contents != 0xffff)
		{
			*contents += difference;
			contents += 2;
		}
	}
	else if (ok == 'X' || ok == 'x')
	{
		DELETE(sequence+lineno);	/* MC */
		if (lineno != 0)
			lineno -= 2;
	}
	else if (ok != '½')
		*contents = difference;	/* restore old time value */
	
	return (lineno);
}
/************************* DISPLAY SEQUENCE INFO ************************/
void seq_display(int lineno)
{
unsigned short int *contents;
int line = 0;	/* on screen cursor positioning displacement */

	vs_curaddress(vdi, 10, 15);
			
	contents = sequence;	/* pointer to start of sequence */
	contents += 3;			/* point to second time */
	contents += lineno;		/* add displacement */
	while (*contents != 0xffff && line < 7)	/* until seq. end or 7 lines printed */
	{
		vs_curaddress(vdi, 10+line, 15);
		printf("%4d =  %5d    -    %2d                 ", (lineno/2)+line, *(contents-3), *contents);
		contents += 2;		/* inc. by 1 item */
		line++;			/* inc. by one screen line */
	}
	if (line != 7)		/* if all lines not used, blank rest */
	{
		while (line < 7)
		{
			vs_curaddress(vdi, 10+line, 15);
			printf("                                          ");
			line++;
		}
	}
}
/******* GET END DISPLACEMENT (address) FROM START OF SEQUENCE **********/
int get_end(void)
{
int contents = 3;

	while (*(sequence+contents) != 0xffff)	/* loop till end flag */
		contents += 2;	/* inc. by one item */
	if (contents == 3)	/* if == 3 then no seq. */
		return (0);
	return (contents-5); /* -3 for initial, -2 for flag pos */
}
/************************* FILE SELECTOR ROUTINE ************************/
void loaddat(OBJECT *dlog,int a,int b,short x,short y,short w,short h,char nom[30],short mode,int sam)
{
char wholename[80];
char filename[13] = "";	/* blank off filename bit */
char *aname, thename[9];
char *memory;
char ok;
long size;
int quit = 0;
short ok_clicked;
char *n, *p, *strrchr();
struct file *xp;
struct DISKINFO info;
FILE*fp;
long int start;

	aname = &thename[0];
	xp = &avr;
	n = &nom[0];	/* title for item selector */

	vs_curaddress(vdi, 10, 15);
     if (fsel_exinput(pathname, filename, &ok_clicked, n) && ok_clicked)
     {
		objc_draw(dlog,a,b,x,y,w,h);	/* re-draw form */
          
          graf_mouse(HOURGLASS, NULL);
          strcpy(wholename, pathname);
          if (p = strrchr(wholename, '\\'))
          {
               strcpy(p+1, filename);
			switch (mode)
			{
				case 0:
					if (count < 17)
					{
						sam_start[++count] = Sample_load(wholename);
						if (*sam_start[count] == NULL)
						count--;
					}
					else
					{
						form_alert(1,"[1][ TOO MANY SAMPLES ! | MAXIMUM 16 ONLY !][ OK ]");
					}
     				break;
     				
     			case 1:
     				Sequence_save(wholename,0);
     				break;
     				
     			case 2:
     				Sequence_save(wholename,1);
     				break;
     				
     			case 3:
     				Sequence_load(wholename,0);
     				break;
     				
     			case 4:
     				Sequence_load(wholename,1);
     				break;

				case 5:
					Sample_save(wholename, sam);
					break;
     				
     			case 6:	/* delete file */
     				printf("** DELETE  %.12s (Y/N) **",filename);
     				ok = Bconin(2);
     				if (ok == 'y' || ok == 'Y')
     				{
     					if (remove(wholename) != 0)
							form_alert(1,"[3][ CAN'T DELETE FILE ! ][ CANCEL ]");
					}
					break;
					
				case 7:	/* head a sample with avr format */
					vs_curaddress(vdi, 10, 15);
					
					xp = &avr;
					
					if (fp = fopen(wholename, "rb"))	/* open seq file READ only */
					{
						if (fseek(fp,0L,SEEK_END) !=0)
							form_alert(1,"[3][ FILE NOT VALID !][ CANCEL ]");
						start = ftell(fp);
						rewind(fp);
						if ((memory = calloc(start+130,1)) == NULL) /* sample bank memory */
						{
							form_alert(1,"[3][ RAN OUT OF MEMORY ERROR !!!][ CANCEL ]");
							return;
						}
						fread(xp,1,4,fp);
						rewind(fp);
						if (strncmp("2BIT",avr.ident,4) == 0)
						{	
							printf("***** AN AVR SAMPLE FILE !! *****");
								waiting(800);
							fread(memory,1,start,fp);
							start -= 128;
						}
						else
						{
							memory += 128;
							fread(memory,1,start,fp);
							memory -= 128;
						}
						fclose(fp);
					}
					else
					{
						form_alert(1,"[3][ NO FILE SORRY !][ CANCEL ]");
						graf_mouse(ARROW, NULL);
						return;
					}
					/* file fine */

					vs_curaddress(vdi, 10, 15);
							
					printf("*Creates an 8-BIT AVR STANDARD Header.*");
					vs_curaddress(vdi, 12, 15);
					printf("NOTE: This is the sample name -"); 
					vs_curaddress(vdi, 13, 15);
					printf("        NOT the FILENAME !!!!");
					vs_curaddress(vdi, 14, 15);
					printf("NAME: (MAX 8 CHARS, NO SPACES) ->");
					Click(7); /* key clk on */
					ok = 0;
					while (ok == 0)
					{
						while (ok <= 7 && (aname[ok] = Crawcin()) != 13 )
						{
							if (aname[ok] < '0' || aname[ok] > 'z')
								putchar('\7');
							else
							{
								putchar(aname[ok]);
								ok++;
							}
						}
					}
					if (ok < 7)
						aname[ok] = 0;
					Click(0); /* key clk off */

					strncpy(avr.ident, "2BIT",4);
					p = &avr.name[0];
					memset(p,0,26);
					strncpy(p, aname, 8);
							
					ok = form_alert(1,"[2][ SAMPLE TYPE ][ MONO | STEREO ]");

					if (ok == 2)
						avr.stereo = 0xffff;
					
					ok = form_alert(1,"[2][ SAMPLE TYPE ][ SIGNED | UNSIGNED ]");
	
					if (ok == 1)
						avr.sign = 0xffff;
								
					ok = form_alert(1,"[2][ SAMPLE PLAY MODE ][ ONCE | LOOPED ]");
					if (ok == 2)
						avr.loop = 0xffff;
					avr.midi = 0xffff;
					avr.resolution = 0x0008;
								
					ok = form_alert(2,"[2][ PLAYBACK FREQUENCY | IN Khz ][ 6 | 12 | OTHER ]");
					if (ok == 3)
					{
						ok = form_alert(1,"[2][ PLAYBACK FREQUENCY | IN Khz ][ 25 | 50 ]");
						ok += 2;
					}
					if (ok == 4)
						avr.speed = 0xff00c800;
					else if (ok == 2)
						avr.speed = 0xff0030fa;
					else if (ok == 3)
						avr.speed = 0xff006400;
					else
						avr.speed = 0xff00187d;
					avr.length = start;
					memset(memory,0,128);
					memcpy(memory, xp, 30);
					
					ok = form_alert(1,"[2][ SAVE CHANGES IN THE |  SELECTED FILE ? | NOTE: This overwrites | the existing file. ][ YES | NO ]");
	
					if (ok == 2)
						quit = 1;

					objc_draw(dlog,DCLS,1,x,y,w,h);	/* re-draw form */
					if (getdfs(wholename[0]-0x40,&info) == 0)
						size = (long)info.free*info.spc*info.bps;
					while (size < start+150 && quit == 0)
					{
ok = form_alert(2,"[3][ NOT ENOUGH SPACE FREE | ON THE DISK. | INSERT ANOTHER DISK ?][ YES | NO ]");
						if (ok == 2)
							quit = 1;
						else
							if (getdfs(wholename[0]-0x40,&info) == 0)
								size = (long)info.free*info.spc*info.bps;
					}
					while (quit == 0)
					{
						if (fp = fopen(wholename, "wb"))
						{
							if (fwrite(memory,1,start+128,fp) != start+128)
							{
								form_alert(1,"[3][ DISK FULL | FILE NOT SAVED !][ CANCEL ]");
								fclose(fp);
								if (remove(wholename) != 0)
								{
									form_alert(1,"[3][ CAN'T DELETE FILE ! ][ CANCEL ]");
								}
								quit = 1;
							}
							else
							{
								quit = 1;
								fclose(fp);
							}
						}
						else
						{
							ok = form_alert(1,"[3][ DISK WRITE PROTECTED ! ][ RETRY | CANCEL ]");
							if (ok == 2)
								quit = 1;
						}
					}
					free(memory);
					break;
					
     			break;
     		}
          }
          graf_mouse(ARROW, NULL);
     }
     else
		objc_draw(dlog,a,b,x,y,w,h);	/* re-draw form */
}
/************************** SAVE A SAMPLE FROM MEMORY ******************/
void Sample_save(char wholename[80], int sam)
{
FILE*fp;
struct file *p;

	p = &avr;	/* pointer to avr structure */

	memcpy (p, sam_start[sam], 30);	/* put header in avr struc */
	vs_curaddress(vdi, 10, 15);

	if (fp = fopen(wholename, "wb"))	/* write file */
	{
		if (fwrite(sam_start[sam], 1,(128+avr.length), fp) == 128+avr.length)
			fclose(fp);						/* close it */
		else
		{
			form_alert(1,"[3][ DISK FULL | FILE NOT SAVED ][ CANCEL ]");
			fclose(fp);
			if (remove(wholename) != 0)
			{
				form_alert(1,"[3][ CAN'T DELETE FILE ! ][ CANCEL ]");
			}
		}
	}
	else
		form_alert(1,"[3][ DISK WRITE PROTECTED !][ CANCEL ]");
}
/************** SAVE SEQUENCE OR ALL DEPENDING ON MODE ******************/
void Sequence_save(char wholename[80], short mode)
{
FILE*fp;
char *pointer;
int cnt = 0;
int fault = 0;
struct file *p;
struct seq *mp;	/* 96 byte header */

	mp = &amazinge;
	p = &avr;
	errno = 0;	/* reset file error flag */
	
	if (fp = fopen(wholename, "wb"))	/* open seq file write only */
	{
		pointer = &amazinge.ident[0];
		if (mode == 0)
			strcpy(pointer, "PHAZESHIFT_SEQUENCE");
		else
			strcpy(pointer, "PHAZESHIFT_MIX_ONLY");
			
		amazinge.slength = get_end()+10;
		amazinge.samples = count;
		
		if (mode == 0)
		{
			while (cnt <= count)
			{	
				memcpy (p, sam_start[cnt], 30);
				amazinge.size[cnt++] = ((avr.length+128)/2)*2;
			}
			while (cnt <= 17)
				amazinge.size[cnt++] = 0;
			
			if (fwrite(mp, 1, 96, fp) != 96)
				fault = 1;
			if (!fault)
			{
				cnt = 0;
				while (cnt <= count)
				{
					pointer = sam_start[cnt];
					if (fwrite(pointer, 1, amazinge.size[cnt], fp) != amazinge.size[cnt])
						fault = 1;
					cnt++;
				}
			}
		}
		else
		{
			if (fwrite(mp, 1, 24, fp) != 24)
				fault = 1;
		}
		if (fwrite(sequence, 2, amazinge.slength, fp) != amazinge.slength)
			fault = 1;
		
		if (fclose(fp) != 0)
			fault = 1;
	}
	else
		fault = 1;
	if (fault == 1)
	{
		if (errno == ENOSPC)
		{
			form_alert(1,"[3][ DISK FULL | FILE NOT SAVED ][ CANCEL ]");
			if (remove(wholename) != 0)
			{
				form_alert(1,"[3][ CAN'T DELETE FILE ! ][ CANCEL ]");
			}
		}
		else
			form_alert(1,"[3][ DISK WRITE PROTECTED !][ CANCEL ]");
	}
}
/************** LOAD SEQUENCE OR ALL DEPENDING ON MODE ******************/
void Sequence_load(char wholename[80], short mode)
{
FILE*fp;
char *pointer, *memory;
int cnt = 0;
int sam_len;
struct seq *mp;	/* 96 byte header */

	mp = &amazinge;
	errno = 0;	/* reset file error flag */
	
	if (fp = fopen(wholename, "rb"))	/* open seq file read only */
	{
		pointer = &amazinge.ident[0];
		if (mode == 0)
		{
			fread(mp, 1, 96, fp);	/* read it in */
			
			if (!(strncmp("PHAZESHIFT_SEQUENCE",pointer,19)))
			{
				/* valid file format */
				for (cnt=0; cnt <= count; cnt++)
					free(sam_start[cnt]);
				count = amazinge.samples;
				cnt = 0;
				while (cnt <= count)
				{	
					sam_len = amazinge.size[cnt];
					if ((memory = malloc(sam_len)) == NULL) /* sample bank memory */
					{
						form_alert(1,"[3][ RAN OUT OF MEMORY ERROR !!!][ CANCEL ]");
						count = cnt-1;
						fclose(fp);
					}
					else
					{
					fread(memory, 1, (amazinge.size[cnt]), fp); /* read it in */
					sam_start[cnt++] = memory;
					}
				}
				fread(sequence, 2, (amazinge.slength), fp);
			}
			else
			{
				form_alert(1,"[1][ NOT A VALID | MIX & SAMPLE FILE | ERROR !!! ][ CANCEL ]");
			}
		}
		else
		{
			fread(mp, 1, 24, fp);
			if (!(strncmp("PHAZESHIFT_MIX_ONLY",pointer,19)))
			{
				if (count >= amazinge.samples)
					fread(sequence, 2, (amazinge.slength), fp);
				else
				{
					form_alert(1,"[1][ NOT ENOUGH SAMPLES | IN MEMORY !!!][ CANCEL ]");
				}
			}
			else
			{
				form_alert(1,"[1][ NOT A VALID | MIX ONLY FILE | ERROR !!! ][ CANCEL ]");
			}
		}
		fclose(fp);
	}
	else
	{
		form_alert(1,"[1][ FILE DOES NOT EXIST ! ][ CANCEL ]");
	}
}
/******************** LIST SAMPLES THAT ARE LOADED **********************/
void Sample_list(int lineno2)
{
int cnt;
int line = 0;
struct file *p;

	p = &avr;
	cnt = lineno2;

	while (cnt <= count && line < 7)
	{	
		memcpy (p, sam_start[cnt], 30);
		vs_curaddress(vdi, 10+line, 15);
		printf("%8.8s.", &avr.name[0]);
		printf(" - %2d: %c", cnt, key[cnt]);
		if (avr.stereo == 0)
			printf(" MONO  ");
		else
			printf(" STEreo");
		if (avr.loop == 0)
			printf(" ONCE");
		else
			printf(" LOOP");
		avr.speed &= 0xffffff; 
		printf(" %d Hz  ", avr.speed);
		cnt++;
		line++;
	}
	if (line != 7)
	{
		while (line < 7)
		{
			vs_curaddress(vdi, 10+line, 15);
			printf("                                         ");
			line++;
		}
	}
}
/******************** LOAD A SAMPLE TO MEMORY BANK **********************/
char *Sample_load(char wholename[80])
{
FILE*fp;
char A;
char *pointer, *memory;
int sam_len;
struct file *p;

	memory = &A;
	*memory = 10;
	p = &avr;
	errno = 0;	/* reset file error flag */

	if (fp = fopen(wholename, "rb"))	/* open sound file */
	{
		fread(p, 1, 30, fp);	/* read it in */
		fclose(fp);						/* close it */
	}
	else
	{
		form_alert(1,"[1][ FILE DOES NOT EXIST ! ][ CANCEL ]");
		*memory = NULL;
		return (memory);
	}
/* header loaded now test it as a 2-bit sytems file */
	
	pointer = avr.ident;
	if (strncmp("2BIT",pointer,4) != 0)
	{	
		form_alert(1,"[1][ NOT AN AVR SAMPLE FILE ! ][ CANCEL ]");
		*memory = NULL;
		return(memory);
	}
	sam_len = avr.length;	
	if ((memory = malloc(sam_len+128)) == NULL)	/* sample bank memory */
	{
		form_alert(1,"[3][ RAN OUT OF MEMORY ERROR !!!][ CANCEL ]");

		memory = &A;
		*memory = NULL;
		return(memory);	/* NOT enough memory SORRY */
	}
	fp = fopen(wholename, "rb");	/* open sound file */
	if (fread(memory, 1, (sam_len+128), fp) != sam_len+128)	/* read it in */
	{
		form_alert(1,"[1][ FILE TOO SMALL | ACCORDING TO HEADER ! ][ CANCEL ]");
		free(memory);
		memory = &A;
		*memory = NULL;
	}
	fclose(fp);						/* close it */
	if (avr.sign == 0x0000 && *memory != NULL)
	{
		SIGN_IT(memory);
		avr.sign = 0xffff;
	}
	
	return(memory);
}
/********************** SIMPLE DELAY ROUTINE ****************************/
void waiting(int time)
{
int wt;
	time *= 500;
	for (wt=0; wt < time; wt++)
		wt = wt;
}
/******************* SET UP AND CALL MC RECORD ROUTINE ******************/
void recording(void) 
{
unsigned short int *contents;
int an_error;
int difference;
	contents = sequence;

	if (an_error = RECORD(&sam_start[0],count,sequence,space,1))
	{
		if (an_error == 2)
			form_alert(1,"[3][ OUT OF MEMORY | IN SEQUENCE FILE ! | ADVISE SAVING SEQUENCE | AND RESTART ! ][ OK ]");
		else
			form_alert(1,"[3][ OUT OF TIME | 65535 UNITS ONLY !!! ][ SORRY ]");
	}
	STOP();
	difference = *contents - 1;
	while (*contents != 0xffff)
	{
		*contents -= difference;
		contents += 2;
	}
}
/******************* SET UP AND CALL MC PLAY ROUTINE ********************/
int playing(int lineno)
{
int finish = 1;

	if (*(sequence+3) == 0xffff)
		return (lineno);
	PLAY(&sam_start[0],sequence+lineno,space,&finish);
	vs_curaddress(vdi, 10, 32);
	printf("ANY KEY TO STOP !");
	while (Crawio(0x00ff) != 0);
	while (finish != 0 && Crawio(0x00ff) == 0)
	{}
	Vbl_Remove();
	if (finish != 0)
	{
		STOP();
		return (((finish-2)*2)+lineno);
	}
	return (0);
}
/******************* SET UP AND CALL MC EDIT ROUTINE ********************/
void editing(int lineno)
{
char ok;
int an_error;

	if (*(sequence+3) != 0xffff)
	{
		if (an_error = EDIT(&sam_start[0],count,sequence+lineno,32000,buffer))
		{
			if (an_error == 2)
				form_alert(1,"[3][ OUT OF MEMORY | IN MIX MERGE BUFFER !!! | 8000 KEY PRESSES MAX ! ][ MUPPET ]");
			else
				form_alert(1,"[3][ OUT OF TIME | 65535 UNITS ONLY !!! ][ SORRY ]");
		}
		STOP();
		ok = form_alert(1,"[2][ DO YOU WANT TO KEEP | CHANGES ? ][ YES | NO ]");
		if (ok == 1)
		{
			if (MERGE_BUFFER(sequence,space,buffer))
			{
				form_alert(1,"[3][ OUT OF MEMORY IN SEQ FILE | NOT ALL MIXING MERGED ! | ADVISE SAVING SEQUENCE | AND RESTARTING !! ][ OK ]");
			}
			vs_curaddress(vdi, 11, 15);
			printf("..DONE                                ");
		}
	}
}
/******************************** EOF ***********************************/