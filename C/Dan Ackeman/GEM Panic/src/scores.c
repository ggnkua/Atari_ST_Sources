/* scores.c (c) Dan Ackerman 1997         
 * baldrick@columbus.rr.com
 *
 * routines for saving and loading high score files
 */
 
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"

SCORE_ENTRY scores[10] =
{ 
	"Mr. Humphries", 5000L,
	"Mr. Grace Jr.", 4000L,
	"Mr. Lucas", 3500L,
	"Cpt. Peacock", 3000L,
	"Mr. Rumbold", 2500L,
	"Mr. Granger", 2000L,
	"Mrs. Slocumb", 1500L,
	"Mr. Harmon", 1000L,
	"Ms. Brahms", 750L,
	"Mr. Tebbs", 500L
} ; /* This is our highscore list */

/* read_highscore()
 *
 * loads the highscore list into memory
 * and loads the values into our highscore
 * dialog
 */
 
long
read_highscore(void)
{
	int formdo_ret;
	int i;
	FILE *fp;	
	char tempstr[30];

reopen_score:

	fp = fopen(score_file, "r");

	if (fp != (FILE *)NULL) 
	{
		for (i = 0; i < 10; i++)
		{
			/* This is just to clear out the name */
			strcpy(scores[i].name,"              \0\0");

			fgets(tempstr, 16,  fp);

			if(tempstr[strlen(tempstr)-1]=='\n')
				tempstr[strlen(tempstr)-1]=0;
			if(tempstr[strlen(tempstr)-1]=='\r')
				tempstr[strlen(tempstr)-1]=0;

			strcpy(scores[i].name,tempstr);

			fgets(tempstr, 10,  fp);
			scores[i].score = atol(tempstr);
		}

		fclose(fp);

		/* Init RSC form for High Score */

		for (i = 0; i < 10; i++)
		{
			sprintf(tempstr,"%2d %-14s  %6ld",i+1,scores[i].name,
				scores[i].score);

			set_tedinfo(scorelist_dial,SCORE1 + i,tempstr);
		}
	}
	else
	{
		/*we need to tell them the file doesn't exist*/

		formdo_ret = form_alert(1,alert_noscore);

		if (formdo_ret == 1)
		{
			/* we will have to create one now*/
			if ( write_score() == 0 )
				form_alert(1,alert_cantcreate);
			else
				goto reopen_score;					
		}
		else
		     form_alert(1,alert_cantfind);
	}
	
	return 1;
}

/* write_score()
 *
 * This will write out the highscore file
 *	This routine could probably use some 
 *	error checking
 */

long
write_score(void)
{
	FILE *fd;
	int i;

	fd = fopen(score_file,"w");
	if (fd==NULL)  return 0;

	for (i = 0; i < 10; i++)
	{
		fprintf(fd,"%s\n",scores[i].name);
		fprintf(fd,"%ld\n",scores[i].score);
	}

	fclose(fd);

	return 1;
}

/* get_high_name()
 *
 * ugly modal dialog to get name for highscore list
 * adds it to the file
 */
 
void
get_high_name(int x)
{
	int xchoice;
	GRECT dial;
	static char tempstr[14]="";

	set_tedinfo(highscore_dial, D_ENTERNAME, tempstr);

	form_center(highscore_dial,ELTR(dial));
	form_dial(FMD_START,0,0,10,10,ELTS(dial));
	objc_draw(highscore_dial,0,3,ELTS(dial));
	xchoice = (form_do(highscore_dial, 0) & 0x7fff);
	form_dial(FMD_FINISH,0,0,10,10,ELTS(dial));

	highscore_dial[xchoice].ob_state &= ~SELECTED;

	get_tedinfo(highscore_dial,D_ENTERNAME,tempstr);

	strcpy(scores[x].name,tempstr);
	scores[x].score = score;	/* MAR -- .score is now long  */

	write_score();
	read_highscore();
	high_score();
}

/* high_score()
 *
 * put up high score list window
 * could be replaced with a handle_win call
 * I'm not sure why I didn't do that... 
 */
 
void
high_score(void)
{
	if (win[SCORE_WIN].handle == NO_WINDOW)
	{
		do_scorelist();
		return;
	}

	if (win[SCORE_WIN].status == 3) /* iconified */
	{
		un_iconify(SCORE_WIN, (GRECT *)&win[SCORE_WIN].current);
		wind_set(win[SCORE_WIN].handle, WF_TOP, win[SCORE_WIN].handle,0,0,0);
	}
	else if (win[SCORE_WIN].status == 1) /* normal */
		wind_set(win[SCORE_WIN].handle, WF_TOP, win[SCORE_WIN].handle,0,0,0);
	else
		do_scorelist();

	return;
}