/* man - display and manage manual pages	Author: Dick van Veen */

/* Options:
 *	man <ar-dir>? <ar-name>? <man-page>+
 *		display <man-page> from <ar-name> in <ar-dir>.
 *	man <ar-dir>? <ar-name>?
 *		display contents of <ar-name> in <ar-dir>,
 *		by using the <cursor-keys> and <return> a page is choosen.
 *
 * <ar-dir>	is a directory name starting with a '/'.
 *		the default directory is '/usr/man'.
 *
 * <ar-name>	is a digit, when no digit is used, chapter 1 searched.
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <ctype.h>
#include <termcap.h>
#include <stdio.h>

#ifndef INDEX_H
#define INDEX_H

#define MAN_DELIM	'#'
#define NAME_SIZE	12	/* for size in index file */
#define NAME_WIDTH	15	/* for on screen projection */
#define AR_NAME_SIZE	64	/* for file names */
#define AR_DIR		"/usr/man"
#define AR_NAME		"/man"
#define AR_INDEX	"/._man"

struct INDEX {
  long page_pos;		/* position in index file */
  char page_name[NAME_SIZE];	/* name of manual page */
};

extern char ar_name[AR_NAME_SIZE];	/* name of man archive file */
extern char ar_index[AR_NAME_SIZE];	/* name of index file */
extern struct INDEX *index_buf;	/* contains indices */
extern int max_index_nr;	/* number of indices in index_buf */

/* Should be a prototype */
extern void read_index();
#endif
#ifndef DISPLAY_H
#define DISPLAY_H

#define MAX_X		(CO/NAME_WIDTH)	/* define width of screen */
#define MAX_Y		(LI)	/* define hight of screen */

#define STOP		256	/* codes returned by get_token */
#define READY		257
#define	CURSLEFT	258
#define CURSRIGHT	259
#define CURSUP      	260
#define CURSDOWN	261
#define CURSHOME	262
#define CURSEND		263
#define CURSPAGEUP	264
#define CURSPAGEDOWN	265
#define CURSMIDDLE	266

extern int term_dialog;		/* do we have a terminal ? */
extern int term_clear;		/* do we clear at exit ? */
extern int top_y, cur_x, cur_y;	/* current position on the screen */
extern char *CL, *CM, *DL, *SO, *SE;	/* for termcap */
extern int CO, LI;		/* for termcap */

#define	GOTOXY(x, y)		fputs(tgoto(CM, (x), (y)), stdout)
#define reverse(on)		fputs((on)?SO:SE, stdout)
#define clrscr()		fputs(CL, stdout)

/* Should be prototypes */
extern void display();
extern int gettoken();
extern void set_cursor();
extern void term_init();
extern void term_exit();
#endif

/* Arguments for do_wait() */
#define	WAIT1		"press <return> to go back to menu"
#define WAIT2		"press <return> for "
#define WAIT3		"press <return> for more ..."

#define DO_REVERSE	0x01	/* modes for do_wait() */
#define DO_DELETE	0x02

extern char *malloc();
extern char *getenv();

/* Forward declaration: */
extern void Exit();
static void man();
static void _man();
static void choose();
static int do_choose();
static int do_wait();

main(argc, argv)
int argc;
char **argv;
{
  FILE *man_fd;

  argv++;
  argc--;
  if (*argv != NULL && **argv == '/') {
	(void) strcpy(ar_name, *argv);	/* get archive directory */
	(void) strcpy(ar_index, *argv);	/* get index directory */
	argv++;
	argc--;
  } else {
	(void) strcpy(ar_name, AR_DIR);	/* use default directory */
	(void) strcpy(ar_index, AR_DIR);
  }

  (void) strcat(ar_name, AR_NAME);	/* get archive name */
  (void) strcat(ar_index, AR_INDEX);	/* get index name */

  if (*argv != NULL && isdigit(**argv)) {
	(void) strcat(ar_name, *argv);	/* get archive name */
	(void) strcat(ar_index, *argv);
	argv++;
	argc--;
  } else {
	(void) strcat(ar_name, "1");	/* default archive */
	(void) strcat(ar_index, "1");
  }
  man_fd = fopen(ar_name, "r");	/* open man archive */
  if (man_fd == NULL) {
	fprintf(stderr, "can't open %s\n", ar_name);
	Exit(1);
  }
  read_index();
  term_dialog = isatty(0) && isatty(1);
  term_init();
  if (*argv == NULL)
	choose(man_fd);
  else
	man(man_fd, argv);
  Exit(0);
}

void Exit(code)
int code;
{
  term_exit();			/* return terminal to old status */
  exit(code);
}

static void man(man_fd, man_pages)
FILE *man_fd;
char **man_pages;
{				/* copy all requested manual pages to
			 * standard output */
  int ch;

  while (1) {
	_man(man_fd, *man_pages);
	man_pages++;
	if (*man_pages == NULL) break;
	if (term_dialog) {	/* wait before starting next page */
		fputs(WAIT2, stdout);
		if (do_wait(*man_pages, 0)) break;
		fputc('\n', stdout);
	}
  }
}

static void _man(man_fd, man_page)
FILE *man_fd;
char *man_page;
{				/* copy the manual page to standard output */
  int index_nr, ch, line_nr = -1;

  /* Search entries for man_page */
  for (index_nr = 0; index_nr < max_index_nr; index_nr++) {
	if (strncmp(man_page, index_buf[index_nr].page_name,
		    NAME_SIZE) == 0)
		break;
  }
  if (index_nr == max_index_nr) {
	fprintf(stderr, "manual page for %s not available\n", man_page);
	return;
  }
  if (fseek(man_fd, index_buf[index_nr].page_pos, 0) == -1) {
	fprintf(stderr, "can't seek in manaul archive\n");
	Exit(1);
  }
  while ((ch = fgetc(man_fd)) != '\n') {	/* skip names on first line */
	if (ch == EOF) break;
  }
  ch = fgetc(man_fd);		/* display manual page */
  while (ch != EOF) {
	fputc(ch, stdout);
	if (ch == '\n') {
		ch = fgetc(man_fd);
		if (ch == MAN_DELIM) break;
		if (term_dialog) {	/* wait after page full */
			line_nr++;
			if (line_nr != LI - 2) continue;
			if (do_wait(WAIT3, DO_REVERSE | DO_DELETE)) break;
			line_nr = 0;
		}
	} else
		ch = fgetc(man_fd);
  }
}

static void choose(man_fd)
FILE *man_fd;
{				/* driver one time chosing a page on the
			 * screen */
  int ch, index, max_x, max_y;

  if (!term_dialog) {
	fprintf(stderr, "sorry, no terminal\n");
	Exit(1);
  }
  term_clear = 1;
  max_y = (max_index_nr - 1) / MAX_X;	/* determine screen sizes */
  max_x = max_index_nr % MAX_X;
  if (max_x == 0) max_x = MAX_X;
  while (1) {
	index = do_choose(max_x, max_y);
	if (index == STOP) break;
	clrscr();
	_man(man_fd, index_buf[index].page_name, 1);
	(void) do_wait(WAIT1, DO_REVERSE);
  };
}

static int do_choose(max_x, max_y)
int max_x, max_y;
{				/* implements the cursor movement on screen,
			 * returns entry number */
  int token;

  display(1);
  set_cursor(1);
  while (1) {
	fflush(stdout);
	token = gettoken();
	if (token == READY || token == STOP) break;
	set_cursor(0);
	switch (token) {
	    case CURSLEFT:
		if (cur_x > 0) cur_x--;
		break;
	    case CURSRIGHT:
		if (cur_x < MAX_X - 1) cur_x++;
		break;
	    case CURSUP:
		if (cur_y > top_y)
			cur_y--;
		else if (top_y > 0) {
			cur_y--;
			top_y--;
		}
		break;
	    case CURSDOWN:
		if (cur_y < (top_y + MAX_Y - 1)) {
			cur_y++;
			if (cur_y > max_y) cur_y = max_y;
		} else if ((top_y + MAX_Y - 1) < max_y) {
			top_y++;
			cur_y++;
		}
		break;
	    case CURSPAGEUP:
		top_y -= MAX_Y;
		if (top_y < 0) {
			top_y = 0;
		}
		cur_y = top_y;
		cur_x = 0;
		break;
	    case CURSPAGEDOWN:
		top_y += MAX_Y;
		if ((top_y + MAX_Y - 1) >= max_y) {
			top_y = max_y - (MAX_Y - 1);
			if (top_y < 0) top_y = 0;
		}
		cur_y = top_y;
		cur_x = 0;
		break;
	    case CURSHOME:
		top_y = 0;
		cur_y = 0;
		cur_x = 0;
		break;
	    case CURSEND:
		top_y = max_y - (MAX_Y - 1);
		if (top_y < 0) top_y = 0;
		cur_y = max_y;
		cur_x = 0;
		break;
	    case CURSMIDDLE:
		clrscr();	/* redraw screen */
		break;
	}
	if (cur_y == max_y && cur_x >= max_x) cur_x = max_x - 1;
	display(token == CURSMIDDLE);
	set_cursor(1);
  }
  if (token == STOP)
	return(STOP);
  else
	return(cur_x + cur_y * MAX_X);
}

static int do_wait(message, mode)
char *message;
int mode;
{				/* print message and waits for a newline,
			 * only on terminal dialog */
  int ch;

  if (!term_dialog) return(0);
  if (mode & DO_REVERSE) reverse(1);
  fputs(message, stdout);
  if (mode & DO_REVERSE) reverse(0);
  fflush(stdout);
  do {
	ch = getchar();
  } while (ch != EOF && ch != 'q' && ch != 'Q' && ch != '\n');

  if ((mode & DO_DELETE) && DL) fprintf(stdout, "%s\r", DL);
  if (ch == '\n') return (0);	/* normal end */
  return(1);			/* abnormal end */
}

/* Index.c:	a file to handle the index file */
/*
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <ctype.h>
#include "index.h"
*/

#define MAN_FGETC(ch, man_fd)	{ch=fgetc(man_fd);man_pos++;}
#define INDEX_SIZE()	(max_index_nr * sizeof(struct INDEX))

char ar_name[AR_NAME_SIZE];	/* name of man archive file */
char ar_index[AR_NAME_SIZE];	/* name of index file */

struct INDEX *index_buf;	/* contains indices */
struct INDEX index_record;	/* one index for build_index(); */
int max_index_nr = 0;		/* number of indices in index_buf */
static long man_pos;		/* position in manual file */

/* Forward declarations: */
static void _read_index();
static void build_index();
static int find_name();
static int find_delim();

static int index_cmp(index1, index2)
struct INDEX *index1, *index2;
{				/* used in qsort to sort the indexes read */
  int tmp;
  tmp = strncmp(index1->page_name, index2->page_name, NAME_SIZE);
  if (tmp == 0) tmp = index1 - index2;
  return(tmp);
}

extern void read_index()
{				/* read index file, if necessary creat a new
			 * one */
  int index_fd, build = 1;	/* assume to build a new index */
  struct stat name_stat, index_stat;

  stat(ar_name, &name_stat);
  if (stat(ar_index, &index_stat) == 0) {
	if (name_stat.st_mtime < index_stat.st_mtime)
		build = 0;	/* index OK */
  }
  if (build) build_index(ar_name, ar_index);

  index_fd = open(ar_index, O_RDONLY);	/* read the index */
  stat(ar_index, &index_stat);
  _read_index(index_fd, (int) index_stat.st_size);
  close(index_fd);

  if (build) {			/* write new index out to index file */
	qsort(index_buf, max_index_nr, sizeof(struct INDEX), index_cmp);
	index_fd = creat(ar_index, 0600);
	if (index_fd == -1) {
		fprintf(stderr, "can't create index\n");
		return;		/* not fatal for now */
	}
	if (write(index_fd, index_buf, INDEX_SIZE()) != INDEX_SIZE()) {
		fprintf(stderr, "write error on index file\n");
		unlink(ar_index);	/* don't leave partial index */
		return;		/* not fatal for now */
	}
	close(index_fd);
  }
}

static void _read_index(index_fd, index_size)
int index_fd;
int index_size;
{				/* allocate index buffer and read index */
  index_buf = (struct INDEX *) malloc(index_size);
  if (index_buf == NULL) {
	fprintf(stderr, "can't allocate index buffer\n");
	Exit(1);
  }
  if (read(index_fd, index_buf, index_size) != index_size) {
	fprintf(stderr, "can't read index file\n");
	Exit(1);
  }
  max_index_nr = index_size / sizeof(struct INDEX);
}

static void build_index(ar_name, ar_index)
char *ar_name, *ar_index;
{
  /* Create new index by reading manual file and recording start points
   * to new entries. thes entries are writen to index file, which is
   * later read, sorten and writen out again. use stdio buffering to
   * speed up this process. */
  FILE *man_fd, *index_fd;
  int ch;

  fprintf(stderr, "please wait, rebuilding index\n");
  man_fd = fopen(ar_name, "r");
  if (man_fd == NULL) {
	fprintf(stderr, "can't open %s\n", ar_name);
	Exit(1);
  }
  index_fd = fopen(ar_index, "w");
  if (index_fd == NULL) {
	fprintf(stderr, "can't create index file\n");
	Exit(1);
  }
  man_pos = 0L;			/* initialize page pointer */
  MAN_FGETC(ch, man_fd);
  if (ch != MAN_DELIM) ch = find_delim(man_fd, ch);

  while (ch != EOF) {
	index_record.page_pos = man_pos;
	ch = find_name(man_fd, index_fd);
	ch = find_delim(man_fd, ch);
  }
  fclose(man_fd);
  fclose(index_fd);
}

static int find_name(man_fd, index_fd)
FILE *man_fd, *index_fd;
{				/* write an index record for all names this
			 * entry is known by. these names are on the
			 * first line following the MAN_DELIM,
			 * separated by comma's. */
  int ch, name_size;

  MAN_FGETC(ch, man_fd);
  while (ch != EOF && ch != '\n') {
	name_size = 0;
	while (ch != '\n' && (isspace(ch) || ch == ','))
		MAN_FGETC(ch, man_fd);	/* read leading spaces */
	if (ch == '\n') break;

	while (!isspace(ch) && ch != ',' && ch != '\n' && ch != EOF) {
		if (ch == EOF) break;	/* read manual name */
		if (name_size < NAME_SIZE)
			index_record.page_name[name_size++] = ch;
		MAN_FGETC(ch, man_fd);
	}
	while (name_size < NAME_SIZE)	/* fill name out */
		index_record.page_name[name_size++] = '\0';

	if (index_record.page_name[0] == '\0')
		continue;	/* no manual name */

	if (fwrite(&index_record, sizeof(struct INDEX), 1, index_fd) != 1) {
		fprintf(stderr, "write error on index file\n");
		unlink(ar_index);	/* don't leave partial index */
		Exit(1);
	}
  }
  return(ch);
}

static int find_delim(man_fd, ch)
FILE *man_fd;
int ch;
{				/* find start of next manual page. this is
			 * the line on which the MAN_DELIM is the
			 * first character on that line. */
  while (ch != EOF) {
	if (ch == '\n') {	/* check for end manual page */
		MAN_FGETC(ch, man_fd);
		if (ch == MAN_DELIM) break;
	} else
		MAN_FGETC(ch, man_fd);
  }
  return(ch);
}

/* Display.c:	a file to handle the display */

#include <sgtty.h>
#include <signal.h>
/*
#include <stdio.h>
#include "index.h"
#include "display.h"
*/

int term_dialog = 0;		/* to determine if we have a terminal */
int term_clear = 0;		/* do we have to clear the terminal at exit */
int top_y = 0;			/* position of top line on screen (absolute) */
int cur_y = 0;			/* y-position on screen (absolute) */
int cur_x = 0;			/* x-position on screen (absolute) */

char *AL = "";			/* string to insert a line */
char *DL = "";			/* string to delete a line */
char *CL = "";			/* string for clearing the screen */
char *CM = "";			/* string for cursor goto code */
char *SE = "";			/* string to enter standout mode */
char *SO = "";			/* string to end standout mode */
int CO = 0;			/* number of columns on screen */
int LI = 0;			/* number of lines on screen */

static struct sgttyb termmode;	/* contains startup sgtty struct */
static int term_used = 0;	/* set when terminal is initialised */

extern char *tgetstr();

/* Forward declarations */
static void disp_all();
static void scr_down();
static void scr_up();
static void disp_fill();
static void disp_elem();
static void get_termcap();

void term_init()
{				/* initialize terminal and termcap functions */
  struct sgttyb argp;
  static int init_done = 0;
  extern void Exit();

  if (init_done || !term_dialog) return;
  get_termcap();
  setbuf(stdout, malloc(BUFSIZ));
  signal(SIGHUP, Exit);		/* we got to restore the term mode */
  signal(SIGINT, Exit);
  signal(SIGQUIT, Exit);
  signal(SIGTERM, Exit);
  ioctl(fileno(stdout), TIOCGETP, &termmode);
  argp = termmode;
  argp.sg_flags |= CBREAK;
  argp.sg_flags &= ~ECHO;
  ioctl(fileno(stdout), TIOCSETP, &argp);
  init_done = 1;
  term_used = 1;
}

void term_exit()
{
  if (term_used) ioctl(fileno(stdout), TIOCSETP, &termmode);
  if (term_used && term_clear) clrscr();
}

void display(force)
int force;
{				/* do scrolling by determining direction of
			 * scrolling */
  static int prev_y = 0;
  int diff;

  diff = prev_y - top_y;	/* determine direction */
  if (diff < 0) {
	diff = -diff;
	if (diff >= MAX_Y)
		disp_all();	/* distance to large */
	else
		scr_up(diff);
  } else if (diff == 0) {	/* no scrolling */
	if (force) disp_all();	/* redraw screen */
  } else if (diff >= MAX_Y) {
	disp_all();		/* distance to large */
  } else
	scr_down(diff);
  prev_y = top_y;		/* remember old top */
}

int gettoken()
{				/* read character from keyboard and decode
			 * cursor keys */
  int ch;

  do {
	ch = fgetc(stdin);
	if (ch == '\033') {	/* decode the cursor keys */
		ch = fgetc(stdin);
		if (ch != '[') continue;
		ch = fgetc(stdin);
		switch (ch & 0377) {
		    case 'H':	ch = CURSHOME;	break;
		    case 'A':	ch = CURSUP;	break;
		    case 'V':	ch = CURSPAGEUP;	break;
		    case 'D':	ch = CURSLEFT;	break;
		    case 'G':	ch = CURSMIDDLE;	break;
		    case 'C':	ch = CURSRIGHT;	break;
		    case 'Y':	ch = CURSEND;	break;
		    case 'B':	ch = CURSDOWN;	break;
		    case 'U':	ch = CURSPAGEDOWN;	break;
		    default:	ch = READY;	break;
		}
		if (ch != READY) return(ch);
	} else if (ch == EOF || ch == 'q' || ch == 'Q')
		return(STOP);
  } while (ch != '\n');
  return(READY);
}

void set_cursor(on)
int on;
{				/* put highlighted menu item on screen */
  if (on) reverse(1);
  disp_elem(cur_x, cur_y - top_y);
  if (on) reverse(0);
}

static void scr_up(count)
int count;
{				/* do actual moving of screen object for
			 * scrolling up */
  int i;

  GOTOXY(0, 0);
  for (i = count; i > 0; i--) fputs(DL, stdout);
  disp_fill(MAX_Y - count, MAX_Y - 1);
}

static void scr_down(count)
int count;
{				/* do actual moving of screen object for
			 * scrolling down */
  int i;

  for (i = count; i > 0; i--) {
	GOTOXY(0, MAX_Y - 1);
	fputs(DL, stdout);
	GOTOXY(0, 0);
	fputs(AL, stdout);
  }
  disp_fill(0, count - 1);
}

static void disp_all()
{				/* redraw complete screen */
  clrscr();
  disp_fill(0, MAX_Y - 1);
}

static void disp_fill(first_y, last_y)
int first_y, last_y;
{				/* fill in cleared space for scrolling with
			 * new items */
  int x, y;

  for (y = first_y; y <= last_y; y++) for (x = 0; x < MAX_X; x++)
		disp_elem(x, y);
}

static void disp_elem(x, y)
int x, y;
{				/* put one menu item on correct place on
			 * screen */
  register int i, index;

  index = (top_y + y) * MAX_X + x;
  if (index >= max_index_nr) {
	return;			/* for simplicity this check is made here */
  }
  GOTOXY(x * NAME_WIDTH, y);
  for (i = 0; i < NAME_SIZE; i++) {
	register int ch = index_buf[index].page_name[i];

	if (ch != '\0')
		putc(ch, stdout);
	else
		putc(' ', stdout);	/* fill name out */
  }
}

static void get_termcap()
{				/* initialize all needed termcap entries,
			 * assumes all entries are available. */
  static char entries[100];
  char term_buf[1024];
  char *loc = entries;
  static int init_done = 0;

  if (init_done) return;
  init_done = 1;
  /* Read terminal capabilities */
  if (tgetent(term_buf, getenv("TERM")) <= 0) {
	fprintf(stderr, "Unknown terminal\n");
	Exit(-1);
  }
  CO = tgetnum("co");
  LI = tgetnum("li");
  AL = tgetstr("al", &loc);
  CL = tgetstr("cl", &loc);
  CM = tgetstr("cm", &loc);
  DL = tgetstr("dl", &loc);
  SE = tgetstr("se", &loc);
  SO = tgetstr("so", &loc);

  if (CO < NAME_WIDTH || LI < 1) {
	fprintf(stderr, "sorry, co or li not sufficient in termcap\n");
	Exit(-1);
  }
  if (AL == 0 || CL == 0 || CM == 0 || DL == 0 || SE == 0 || SO == 0) {
	fprintf(stderr,
		"sorry, al, cl, cm, dl, se or so not in termcap\n");
	Exit(-1);
  }
}
