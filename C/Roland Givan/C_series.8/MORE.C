/* 'More' by Roland Givan, (c)1990.
   Written in SOZOBON C for the ATARI ST.
   Designed for use with the Gulam shell.

   This version of 'more' accepts the following commands:

   <SPACE>	Move onto next screen.
   <RETURN>	Move onto next line.
   n,N		Move onto next file (if any).
   q,Q		Quit.
*/

#include <stdio.h>
#include <osbind.h>	/* Need this for Crawcin(). */
#include <ctype.h>

#define SCREENWIDTH 80
#define SCREENHEIGHT 25
#define INVERSE "\033p"
#define NORMAL "\033q"
#define BLANK_LINE "\033l"	/* Note last character is ell not one! */
#define RETURN '\015'		/* Defined as a character constant to satisfy
				   "switch()" */
#define BELL "\007"		/* The "BELL" character/sound. */
#define MAX_LINE 255		/* The maximun length of line it can handle. */

int more();
int get_line();
char get_valid_command();
long length_of_file();


main(argc,argv)
/* Extracts the files off the command line and passes them one by one to
more(). */

int argc;	/* Holds number of items on the command line. */
char **argv;	/* Holds a pointer to an array of pointers to items. */
{
	int ret;
	if (argc<2){	/* Must be at least two items on the command line. */
		fprintf(stderr,"usage: more <file 1> .. <file n>\n");
		exit(1);	/* Exit 'more' with error. */
	}
	argc--;	/* Step past program name. */
	argv++; /*	"	"	   */
	while ((argc--) && (ret)){	/* While, not out of files or quitted */
		ret=more(*argv++);	/* Call "more()" and get return value */
	}
	exit(0);	/* Exit 'more' with no error */
}

int more(file)
/* Opens and displays the file named in the parameter "file". */
char *file;
{
	int ret,quit,nextfile,row,per;
	long total,length;
	char i;
	FILE *fp;
	char line[MAX_LINE];

	if ((fp=fopen(file,"r"))==NULL){	/* Try to open file. */
		fprintf(stderr,"Unable to open %s\n.",file);
		return(FALSE);
	}
	row=0;
	per=0;
	total=0;
	ret=quit=nextfile=FALSE;
	i='\0';
	length=length_of_file(fp);
	ret=get_line(line,fp);
	while ((ret) && (!quit) && (!nextfile)){
		if (strlen(line)<=SCREENWIDTH){
			row++;	/* Add 1 to row count. */
		}else{
			row+=2;	/* Add 2 to row count if line length over 80. */
		}
		fprintf(stdout,"%s",line);	/* Print out line to stdout. */
		total+=strlen(line);
		if (row>=SCREENHEIGHT-1){
			per=((total*100)/length); /* Calculate percentage. */
			fprintf(stdout,INVERSE);
			fprintf(stdout,"--More--( %s,%d%% )",file,per);
			fprintf(stdout,NORMAL);
			i=get_valid_command();
			fprintf(stdout,BLANK_LINE);
			switch (i){
			case ' ':	/* Go onto next screen. */
				row=0;
				break;
			case RETURN:	/* Go onto next line. */
				row=SCREENHEIGHT-2;
				break;
			case 'q':	/* Quit	'more'. */
				quit=TRUE;
				break;
			case 'n':	/* Go onto next file. */
				nextfile=TRUE;
				break;
			}
		}
		ret=get_line(line,fp);	/* Get next line from file. */
	}
	fclose(fp);	/* Close file */
	if (quit){
		return(FALSE);	/* Quitted. */
	}else{
		if (!nextfile){
			fprintf(stdout,INVERSE);
			fprintf(stdout,"--EOF---( %s,100%% )",file);
			fprintf(stdout,NORMAL);
			i=get_valid_command();
			fprintf(stdout,BLANK_LINE);
			if (i != 'q'){
				return(TRUE);
			}else{
				return(FALSE);	/* Quitted. */
			}
		}else{
			return(TRUE);
		}
	}
}

int get_line(line,fp)
char *line;
FILE *fp;
{
	char *ptr;
	ptr=fgets(line,MAX_LINE,fp);
	if (ptr!=(char *)(0)){	/* If got a line successfully. */
		return(TRUE);
	}else{
		return(FALSE);
	}
}

char get_valid_command()
/* gets a valid command from the keyboard and returns its lower case value.
   Valid commands are ' ',q,Q,n,N,<RETURN>.				   */
{
	int okay,i;
	char c;
	okay=FALSE;
	while (!okay){
		i=Crawcin(); /* get a char direct from console (no echo) */
		c=(char)(tolower(i));	/* Convert i into a lower case char. */
		switch(c){
		case ' ':
		case RETURN:
		case 'q':
		case 'n':
			okay=TRUE;
			break;
		default:
			fprintf(stdout,BELL);	/* beep at the user! */
			break;
		}
	}
	return(c);
}

long length_of_file(fp)
/* Returns the length of the file in bytes */
FILE *fp;
{
	int length=0;
	while (fgetc(fp)!=EOF){	/* While have sucessfully got a character.. */
		length++;	/* ... add 1 to the length count. */
	}
	rewind(fp);	/* move file pointer back to start of file */
	return(length);
}
