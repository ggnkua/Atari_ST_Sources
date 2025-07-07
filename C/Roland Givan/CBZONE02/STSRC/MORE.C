/* 'More' by Roland Givan, (c)1990,1991,1992,1993
   This file is a cut down version of the above
   for the purposes of implementing a 'pager' in CBZONE
   This file is entirly Public Domain and you may use it
   as you wish (as long as I am credited as the original
   author)
*/

#include "c_includ.h"
#ifndef LATTICE
#include <stat.h>
#else
#include <sys/types.h>
#include <sys/stat.h>
#endif
#include <ctype.h>


/* VT52 escape code. Should really use TERMCAP! */

#define INVERSE		"\033p"
#define NORM		"\033q"
#define BLANK_LINE	"\033l"	/* Note last character is ell not one! */
#define RETURN		'\015'	/* Defined as a character constant to satisfy
				   "switch()" */
#define HOME		"\033H"
#define MAX_LINE	255	/* The maximun length of line it can handle. */

#define SAME		0


int	more();
int	get_line();
char	get_valid_command();
extern void sound(char *);

extern char ping[];

int screenwidth	= 80;
int screenheight = 25;


int more(char *file)
/* Opens and displays the file named in the parameter "file". */
{
	int ret,quit,row,per;
	long total,length;
	char i;
	FILE *fp;
	char line[MAX_LINE];
	struct stat stbuf;

	set_front();
	fprintf(stdout,HOME);
	if ((fp=fopen(file,"r"))==NULL){	/* Try to open file. */
		fprintf(stderr,"Unable to open %s\n",file);
		clearentirescreen();
		set_back();
		return(1);
	}
	stat(file, &stbuf);
	length=stbuf.st_size;
	row=per=total=0;
	ret=quit=False;
	i='\0';
	ret=get_line(line,fp);
	while ((ret) && (!quit)){
		/* calculate additional rows */
		row += 1+((strlen(line))/screenwidth);
		fprintf(stdout,"%s",line);	/* Print out line to stdout. */
		total+=strlen(line);
		if (row>=screenheight-1){
			per=((total*100)/length); /* Calculate % */
			fprintf(stdout,"%s- Press <SPACE>,<RETURN> or Q -( %s,%d%% )%s",
				INVERSE,file,per, NORM);
			fflush(stdout); /* Fix for GCC 1.40. RMG 15/01/92 */
			i=get_valid_command();
			fprintf(stdout,BLANK_LINE);
			switch (i){
			case ' ':		/* Go onto next screen. */
				row=0;
				break;
			case RETURN:		/* Go onto next line. */
				row=screenheight-2;
				break;
			case 'q':		/* Quit	'more'. */
				quit=True;
				break;
			}
		}
		ret=get_line(line,fp);		/* Get next line from file. */
	}
	fclose(fp);	/* Close filne */
	if (!quit){
		fprintf(stdout,"%s- Press <RETURN> -( %s,100%% )%s",
			INVERSE,file, NORM);
		fflush(stdout); /* Fix for GCC 1.40. RMG 21/04/92 */
		i=get_valid_command();
		fprintf(stdout,BLANK_LINE);
	}
	clearentirescreen();
	set_back();
	return(0);
}

int get_line(char *line, FILE *fp)
{
	char *ptr;

	ptr=fgets(line,MAX_LINE,fp);
	if (ptr!=(char *)(0)){	/* If got a line successfully. */
		return(True);
	}else{
		return(False);
	}
}

char get_valid_command(void)
/* gets a valid command from the keyboard and returns its lower case value.
   Valid commands are ' ',q,Q,<RETURN>.				   */
{
	int okay;
	char c;
	okay=False;
	while (!okay){
		c=(char)Crawcin(); /* get a char direct from console (no echo) */
		if(isupper(c)){
			c=(char)(tolower(c));	/* Convert i into a lower case char. */
		} 
		switch(c){
			case ' ':
			case RETURN:
       			case 'q':
				okay=True;
				break;
			default:
				sound(ping);	/* beep at the user! */
				break;
		}
	}
	return(c);
}


