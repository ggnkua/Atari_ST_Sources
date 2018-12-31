/*
 * qroff: a very quick and dirty text formatter, for stadel documentation.
 */
/*
 * commands supported:
 * $include <filename>		- include a file
 * $section <level> <title>	- produce a section title
 * $raw				- introduce raw code
 * $cooked			- reenable the formatter
 * $left <left-margin>		- set left margin
 * $right <right-margin>	- set right margin
 * $indent <paragraph-indent>	- set paragraph indent
 * $skip <lines)		- skip some lines
 * $par				- force paragraph break
 */
#include <stdio.h>
#include <ctype.h>
#include <stdarg.h>

#define	YES	1
#define	NO	0
#define	MAXWORD	160

int left_margin=4;			/* left page margin */
int right_margin=70;			/* right page margin */
int width=66;				/* page width (rm-lm) */
int para_indent=4;			/* indent of first line of paragraph */
char noformat=NO;			/* raw text output */
int newpara=YES;			/* starting a new paragraph? */

char formatted[MAXWORD];		/* where text is processed to */
int  fp=0;				/* index into the above */
char inputted[MAXWORD];			/* latest line of text coming in */
int  ip=0;				/* index into the above. */

#define	SECTIONS	10
int  sections[SECTIONS];

#define	MAXFSTACK	20

struct filestack {
    char name[80];
    int  line;
} stack[MAXFSTACK];
int fsp = (-1);


/*
 * qroff main
 */
main(argc, argv)
char **argv;
{
    register i;

    iformat();				/* initialize things */
    fformat(NO, "style.qfm");
    if (argc < 2)
	sformat(stdin);
    else for (i=1; i<argc; i++)
	fformat(YES, argv[i]);
    fsync();
    exit(0);
}


/*
 ************************************************
 *	iformat() - initialize the formatter	*
 ************************************************
 */
iformat()
{
    register i;

    for (i=0;i<SECTIONS; i++)
	sections[i] = 0;
}


/*
 ************************************************************************
 *	fformat() - format a file.  If whine is true, complain about	*
 *	files that can't be read.					*
 ************************************************************************
 */
 fformat(whine, file)
 char *file;
 {
     FILE *fopen(), *thing;

    if (fsp >= MAXFSTACK-1)
	message("stack overflow trying to read %s", file);
    else if (thing=fopen(file, "r")) {
	fsp++;
	strcpy(stack[fsp].name, file);
	stack[fsp].line = 0;
	sformat(thing);
	fclose(thing);
	fsp--;
    }
    else if (whine)
	message("cannot read %s", file);
}


/*
 ****************************************************************
 *	sformat() - take a stream and format it to stdout	*
 ****************************************************************
 */
sformat(text)
FILE *text;
{
    char thisword[MAXWORD];
    char pc;
    register idx, j, k;

    while (fgets(inputted, MAXWORD, text)) {
	stack[fsp].line++;
	if (!process())
	    if (noformat)
		fputs(inputted, stdout);
	    else if (isblank()) {
		fsync();
		putchar('\n');
	    }
	    else {
		for (idx=0; inputted[idx]; ) {
		    while (inputted[idx] && isspace(inputted[idx]))
			idx++;
		    j = idx;
		    while (inputted[idx] && !isspace(inputted[idx]))
			idx++;
		    if (newpara) {
			newpara=NO;
			for (k=0; k<para_indent; k++)
			    thisword[k] = ' ';
		    }
		    else k = 0;
		    while (j<idx)
			thisword[k++] = inputted[j++];
		    thisword[k] = 0;
		    if (fp > 0)
			if (fp + strlen(thisword) >= width) {
			    /*
			     * if this word will make the screen wrap, kick out a
			     * newline first.
			     */
			    outline();
			}
			else {
			    pc = fp ? formatted[fp-1] : 254;
			    if (pc != ' ')
				formatted[fp++] = ' ';
			    if (strchr(".;:?!", pc))
				formatted[fp++] = ' ';
			}
		    /*
		     * put the word and update curcol.  If the word was
		     * longer than WIDTH, we dump it straight and hope
		     * that the tty will wrap.
		     */
		    for (k=0; thisword[k]; )
			formatted[fp++] = thisword[k++];
		}
	    }
    }
}



/*
 ************************************************
 *	outline() - dump out a formatted line	*
 ************************************************
 */
outline()
{
    register j;

    if (fp > 0) {
	formatted[fp] = 0;
	for (j=0; j<left_margin; j++)
	    putchar(' ');
	printf("%s\n", formatted);
	fp = 0;
    }
}


/*
 ************************************************************************
 *	fsync() - if there is stuff waiting to be output, force it	*
 *	out and reset the output buffer to start of line.		*
 ************************************************************************
 */
fsync()
{
    outline();
    newpara=YES;
}


/*
 ************************************************************************
 *	isblank() - is this line blank (for paragraphing things)	*
 ************************************************************************
 */
isblank()
{
    register i;

    for (i=0; inputted[i] && isspace(inputted[i]); i++)
	;
    return inputted[i] ? NO : YES;
}


/*
 ************************************************
 *	process() - a command in the text	*
 ************************************************
 */
process()
{
    char cmd[MAXWORD], argument[MAXWORD];
    int count;
    int temp;
    char plus = NO;
    register i;
    int shp;

    if (inputted[0] == '$') {
	count = sscanf(inputted, "%s %s", cmd, argument);
	if (stricmp(cmd, "$include") == 0) {
	    if (count == 2)
		fformat(YES, argument);
	    else
		message("$include syntax");
	}
	else if (stricmp(cmd, "$left") == 0) {
	    if (count != 2)
		message("$left syntax");
	    else {
		plus = (argument[0] == '+');
		temp = atoi(plus ? (&argument[1]) : argument);
		if (temp < 0 && left_margin + temp < 0)
		    message("left margin would be negative");
		else if ((plus && left_margin + temp >= right_margin)
					     || (temp > right_margin))
		    message("left margin would be greater than right margin");
		else {
		    if (plus || temp < 0)
			left_margin += temp;
		    else
			left_margin = temp;
		    width = right_margin-left_margin;
		}
	    }
	}
	else if (stricmp(cmd, "$right") == 0) {
	    if (count != 2)
		message("$right syntax");
	    else {
		plus = (argument[0] == '+');
		temp = atoi(plus ? (&argument[1]) : argument);
		if ((temp < 0 && right_margin + temp < left_margin)
			    || (!plus && right_margin < left_margin))
		    message("right margin would be less than left margin");
		else if ((plus && right_margin+temp > MAXWORD)
					    || temp > MAXWORD)
		    message("right margin exceeds %d", MAXWORD);
		else {
		    if (plus || temp < 0)
			right_margin += temp;
		    else
			right_margin = temp;
		    width = right_margin-left_margin;
		}
	    }
	}
	else if (stricmp(cmd, "$indent") == 0) {
	    if (count != 2)
		message("$indent syntax");
	    else {
		temp = atoi(argument);
		if (temp+left_margin > right_margin)
		    message("para indent exceeds right margin");
		else if (temp+left_margin < 0)
		    message("para indent is less than zero");
		else
		    para_indent = temp;
	    }
	}
	else if (stricmp(cmd, "$raw") == 0) {
	    fsync();
	    noformat = YES;
	}
	else if (stricmp(cmd, "$cooked") == 0)
	    noformat = NO;
	else if (stricmp(cmd, "$section") == 0) {
	    for (i=0; inputted[i] && !isspace(inputted[i]); i++)
		;
	    while (inputted[i] && isspace(inputted[i]))
		i++;
	    while (inputted[i] && !isspace(inputted[i]))
		i++;
	    while (inputted[i] && isspace(inputted[i]))
		i++;
	    if (count < 2 || !inputted[i])
		message("$section syntax");
	    else {
		temp = atoi(argument);
		if (temp < 0 || temp > 9)
		    message("$section level must be 0 to 9");
		else {
		    fsync();
		    shp = i;
		    sections[temp]++;
		    for (i=1+temp; i<10; i++)
			sections[i] = 0;
		    for (i=0; i<=temp; i++)
			printf("%s%d", (i==0)?"":".", sections[i]);
		    printf(") %s", &inputted[shp]);
		}
	    }
	}
	else if (stricmp(cmd, "$center") == 0) {
	    for (i=0; inputted[i] && !isspace(inputted[i]); i++)
		;
	    while (inputted[i] && isspace(inputted[i]))
		i++;
	    if (inputted[i]) {
		fsync();
		temp = (width-strlen(&inputted[i]))/2;
		temp += left_margin;
		while (temp-- > 0)
		    putchar(' ');
		fputs(&inputted[i], stdout);
	    }
	    else
		message("$center syntax");
	}
	else if (stricmp(cmd, "$par") == 0) {
	    fsync();
	}
	else if (stricmp(cmd, "$skip") == 0) {
	    if (count != 2)
		message("$skip syntax");
	    else {
		fsync();
		temp = atoi(argument);
		while (temp-- > 0)
		    putchar('\n');
	    }
	}
	else if (strcmp(cmd, "$") != 0)
	    message("%s not recognised", cmd);
	return YES;
    }
    return NO;
}


/*
 ************************************************
 *	message() - print an error message	*
 ************************************************
 */
message(format, args)
char *format;
{
    va_list arg_ptr;

    va_start(arg_ptr, format);

    fprintf(stderr, "qroff: ");
    if (fsp >= 0)
	fprintf(stderr, "(%s) line %d: ", stack[fsp].name, stack[fsp].line);
    vfprintf(stderr, format, arg_ptr);
    putc('\n', stderr);
}
