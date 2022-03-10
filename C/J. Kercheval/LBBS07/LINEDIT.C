/* linedit.c - Line-oriented text editor 
 * by Vincent "TMS" Archer
 * adapted for the LazyBBS project by Franck Arnaud
 *	settings:	LINED_UNIX	define to enable original unix version parts
 *				LINED_ALONE	define to make a stand alone version
 *				LINED_ECHO  define to echo chars to console
 *				LINED_IDIOTPROOF define to quit after MAX_IDIOTPROOF
 *							blanklines
 *				LINED_CLEAN clear buffer so that next call ok
 */
 
/*#define LINED_ALONE*/
#define LINED_IDIOTPROOF
#define LINED_CLEAN

#define MAX_IDIOTPROOF 2 /* number of blanklines to quit */

#ifdef LINED_UNIX
#include <sys/termios.h>
#endif
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include "linedit.h"

#ifndef LINED_ALONE
#include "bbs.h"
#include "miscio.h"
#else
#define out_char putchar
#endif

#ifdef LINED_UNIX
struct termios oldmode, newmode;
#ifndef LINED_ECHO /* unix implies echo */
#define LINED_ECHO
#endif
#endif

char *filename;
char buffer[1024];

#ifdef LINED_UNIX
int Lines, Columns;
#else
#define Lines 23
#define Columns 78
#endif

A_line *first_line, *last_line;
int nb_lines;

#ifdef LINED_ALONE
int getkey(void )
{
	char c;
	while (read(0, &c, 1) != 1) 
		;
	return (int) c;
}
#endif

yes()
{
	int c;

	while (1) {
		fflush(stdout);
		c=getkey();
		if(c<0)
			return 0;
			
		switch (c) {
		    case '\r':
		    case '\n':
		    case 'Y':
		    case 'y':
			return(1);
		    case 'N':
		    case 'n':
			return(0);
		}
	}
}


void listbuffer(dsp)
int dsp;
{
A_line *line;
int l,n;

	l = 1;
	n = Lines-2-dsp;
	for (line = first_line; line; line = line->next) {
		out_printf("%3d|%s\n", l++, line->text);
		if (!n--) {
			out_printf("More [Yes/No]?");
			if (!yes()) {
				out_char('\n');
				return;
			}
			out_printf("\r              \r");
			n = Lines-2;
		}
	}
}


A_line *whichline(no)
int no;
{
A_line *line;

	for (line = first_line; line; line = line->next)
		if (--no <= 0)
			break;
	return(line);
}


int geti(min, max, deflt)
int min, max, deflt;
{
int c;
int i, val;

	i = 0;
	val = 0;
	while (1) {
		fflush(stdout);
		c=getkey();
		
		if (c == '\r' || c == '\n') {
			if (!i)
				val = deflt;
			else
				if (val < min || val > max)
					return deflt;
			out_char('\n');
			return val;
		}
		if (c == '\b' && i) {
#ifdef LINED_ECHO
			out_printf("\b \b");
#else
			out_printf(" \b");
#endif
			i--;
			val = val/10;
			continue;
		}
		if (c < '0' || c > '9' || i > 3)
			continue;
		if (c == '0' && val == 0)
			continue;
		
#ifdef LINED_ECHO
		out_char(c);
#endif

		i++;
		val = val*10 + (c-'0');
	}
}

void deleteline(line)
A_line *line;
{
	if (!line)
		return;
	if (line->prev) {
		if (line->cr_at_end)
			line->prev->cr_at_end = 1;
		line->prev->next = line->next;
		if (line->next) {
			line->next->prev = line->prev;
			line->next->cr_before = line->prev->cr_at_end;
		} else
			last_line = line->prev;
	} else {
		first_line = line->next;
		if (line->next) {
			line->next->prev = 0;
			line->next->cr_before = 1;
		} else
			last_line = NULL;
	}
	free(line->text);
	free(line);
	nb_lines--;
}


A_line *insertline(text, before)
char *text;
A_line *before;
{
A_line *line2;

	if (!(line2 = (A_line *)malloc(sizeof(A_line)) )) {
		out_printf("Out of memory!\n");
		return(0);
	}
	if (!(line2->text = strdup(text))) {
		free(line2);
		out_printf("Out of memory!\n");
		return(0);
	}
	line2->cr_at_end = 0;
	line2->next = before;
	if (before) {
		before->cr_before = 0;
		line2->prev = before->prev;
		if (line2->prev) {
			line2->cr_before = line2->prev->cr_at_end;
			line2->prev->next = line2;
		} else {
			line2->cr_before = 1;
			first_line = line2;
		}
		before->prev = line2;
	} else {
		line2->prev = last_line;
		if (last_line) {
			line2->cr_before = line2->prev->cr_at_end;
			last_line->next = line2;
		} else
			first_line = line2;
		last_line = line2;
	}
	nb_lines++;
	return(line2);
}


ifold(line)
char *line;
{
int l, m, c, cr_at_end;
char *s;
A_line *ll;

	l = strlen(line);
	if (line[l-1] == '\n') {
		line[--l] = 0;
		cr_at_end = 1;
	} else
		cr_at_end = 0;
	m = Columns-5;
	while (l > m) {
		c = line[m];
		line[m] = 0;
		if (s = strrchr(line, ' ')) {
			*s++ = '\0';
			line[m] = c;
			if (!insertline(line, (A_line *)0))
				return(-1);
			line = s;
		} else {
			if (!insertline(line, (A_line *)0))
				return(-1);
			line += m;
			line[0] = c;
		}
		l = strlen(line);
	}
	if (!(ll = insertline(line, (A_line *)0)))
		return (-1);
	ll->cr_at_end = 1;
	return(0);
}


void insertbefore(no)
int no;
{
int c;
A_line *line, *line2;
int l, f, brok;
char *s;
#ifdef LINED_IDIOTPROOF
int count_idiot=0;
#endif

	if (no == 0) {
		no = nb_lines+1;
		line = 0;
	} else if (!(line = whichline(no)))
		return;
	buffer[0] = 0;
	while (nb_lines < 999) {
		out_printf("%3d|%s", no, buffer);
		l = strlen(buffer);
		f = Columns-5-l;
		brok = 1;
		while (brok) {
			fflush(stdout);
		
			c=getkey();

			if (c == '\b' && l) {
#ifdef LINED_ECHO
				out_printf("\b \b");
#else
				out_printf(" \b");
#endif
				buffer[--l] = 0;
				f++;
				continue;
			}
			if (c == '\r' || c == '\n') {
				out_char('\n');
				if (buffer[0] == '.' && !buffer[1])
					return;
#ifdef LINED_IDIOTPROOF
				if(!buffer[0])
				{
					if(count_idiot++>=MAX_IDIOTPROOF)
						return;
				}
				else
					count_idiot=0;
#endif
				if (!(line2 = insertline(buffer, line)))
					return;
				line2->cr_at_end = 1;
				if (line)
					line->cr_before = 1;
				no++;
				buffer[0] = 0;
				l = 0;
				f = Columns-5;
				break;
			}
			if (c < ' ')
				continue;
			if (!f) {
				if (s = strrchr(buffer, ' ')) {
					*s++ = '\0';
					for (l = 0; l < strlen(s); l++)
						out_printf("\b \b");
/* don't (fixme, " \b" ???) */
					if (!(line2 = insertline(buffer, line)))
						return;
					strcpy(buffer, s);
				} else {
					if (!(line2 = insertline(buffer, line)))
						return;
					buffer[0] = 0;
				}
				no++;
				l = strlen(buffer);
				f = Columns-5-l;
				out_char('\n');
				brok = 0;
			} 
#ifdef LINED_ECHO
			else
				out_char(c);
#endif
			buffer[l++] = c;
			buffer[l] = 0;
			f--;
		}
	}
}


int menu_loop()
{
FILE *f;
int c;
int nook;
A_line *line;
int i,j;


	while (1) {
		out_printf("\
[A]bort edition, [D]elete line(s), [I]nsert text, [L]ist, [R]eplace line(s)\n\
[S]save & exit, your choice: ");
		nook = 1;
		while (nook) {
			fflush(stdout);
			c=getkey();
#ifndef LINED_ECHO
			out_printf("\b");
#endif
			
			switch (c) {
			    case 'a':
			    case 'A':
				out_printf("Abort\nConfirm abort [Yes/No]?");
				if (yes()) {
					out_char('\n');
#ifdef LINED_CLEAN
					for (line = first_line; line; line = line->next)
						free(line->text);
						
					first_line=0;
					last_line=0;
					nb_lines=0;
#endif
					return 0;
				}
				out_char('\n');
				nook = 0;
				break;
			    case 'D':
			    case 'd':
				if (!nb_lines)
					break;
				nook = 0;
				out_printf("Delete\nFrom line[%s%d, none]:",
					nb_lines==1 ? "" : "1-", nb_lines);
				i = geti(0, nb_lines, 0);
				if (!i)
					break;
				if (i < nb_lines) {
					out_printf("  To line[%d-%d, %d]:", i, nb_lines, i);
					j = geti(i, nb_lines, i);
				} else
					j = i;
				j -= i;
				while (j-- >= 0)
					deleteline(whichline(i));
				break;
			    case 'I':
			    case 'i':
				nook = 0;
				out_printf("Insert\n");
				if (!nb_lines)
					i = 0;
				else {
					out_printf("Before line [%s%d, at end]:",
						nb_lines==1 ? "" : "1-", nb_lines);
					i = geti(1, nb_lines, 0);
				}
				out_printf("    End insertion with a dot ('.') on an otherwise empty line.\n\
   +");
				for (j=5; j<Columns; j++)
					out_char('-');
				out_char('\n');
				insertbefore(i);
				break;
			    case 'L':
			    case 'l':
				out_printf("List\n");
				listbuffer(0);
				nook = 0;
				break;
                            case 'R':
                            case 'r':
                                if (!nb_lines)
                                        break;
                                nook = 0;
                                out_printf("Replace\nFrom line[%s%d, none]:",
                                        nb_lines==1 ? "" : "1-", nb_lines);
                                i = geti(0, nb_lines, 0);
                                if (!i)
                                        break;
                                if (i < nb_lines) {
                                        out_printf("  To line[%d-%d, %d]:", i, nb_lines, i);
                                        j = geti(i, nb_lines, i);
                                } else
                                        j = i;
                                j -= i;
                                while (j-- >= 0)
                                        deleteline(whichline(i));
				if (!whichline(i))
					i = -1;
                                out_printf("    End insertion with a dot ('.') on an otherwise empty line.\n\
   +");
                                for (j=5; j<Columns; j++)
                                        out_char('-');
                                out_char('\n');
                                insertbefore(i);
                                break;
			    case 'S':
			    case 's':
				out_printf("Save\n");
				if (!(f = fopen(filename, "w"))) {
					perror("text");
					nook = 0;
					break;
				}
				for (line = first_line; line; line = line->next)
				{
					fprintf(f, "%s\n", line->text);
#ifdef LINED_CLEAN
					free(line->text);
#endif
				}
				fclose(f);
#ifdef LINED_CLEAN
				first_line=0;
				last_line=0;
				nb_lines=0;
#endif
				return 1;
			}
		}
		out_char('\n');
	}
	return 0;
}


#ifdef LINED_ALONE
main(argc, argv)
int argc;
char *argv[];
{
char *arg;
FILE *f;
#ifdef LINED_UNIX
char *s, *getenv();
#endif
int i;

	argc--;
	argv++;
	while (argc--) {
		arg = *argv++;
		if (*arg == '+')
			continue;
		if (*arg == '-')
			continue;
		filename = arg;
	}
#else /* ! stand_alone */
int edit_file(char *arg)
{
	FILE *f;
	int i;
	filename=arg;
#endif

	if (!filename) {
		fprintf(stderr,"edit: file name missing\n");
		exit(1);
	}
#ifdef LINED_UNIX /* terminal initialisation */
	ioctl(0, TCGETS, &oldmode);
	memcpy(&newmode, &oldmode, sizeof(newmode));
	newmode.c_iflag |= IGNBRK|IGNPAR|ISTRIP|ICRNL;
	newmode.c_lflag &= ~(ISIG|ICANON|ECHO|ECHOE|ECHONL);
	newmode.c_cc[VMIN] = 1;
	newmode.c_cc[VTIME] = 0;
	ioctl(0, TCSETS, &newmode);
#endif

/*
 * Read the file
 */
#ifdef LINED_UNIX
	s = getenv("TERM");
	if (s && tgetent(buffer, s) == 1) {
		Lines = tgetnum("li");
		Columns = tgetnum("co");
	} else 
	{
		Lines = 23;
		Columns = 80;
	}
#endif
	
	if (f = fopen(filename, "r")) {
		while (fgets(buffer, sizeof(buffer), f) != (char *)0)
			ifold(buffer);
		fclose(f);
	}
/*
 * Enter the editor session
 */
	out_char('\n');
	out_printf("    Please compose your message. End insertion with a single dot on a line.\n");
	out_printf("    Any dot at the beginning of a line will be stripped, so put TWO dots\n");
	out_printf("    when you want one. In other words, type '.' on first column to exit.\n");
	out_printf("   +");
	for (i=6; i<Columns; i++)
		out_char('-');
	out_char('+');
	out_char('\n');

	if (first_line)
		listbuffer(4);
	else
		insertbefore(0);

#ifdef LINED_ALONE
	menu_loop();
#else
	if(menu_loop())
		return BBSOK;
	return BBSFAIL;
#endif
#ifdef LINED_UNIX
	ioctl(0, TCSETS, &oldmode);
#endif
#ifdef LINED_ALONE
	return 0;
#endif
}

