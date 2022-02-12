/* men - menu system for MINIX		Author: Andy Tanenbaum */

/* This is a simple menu system for MINIX.  By creating a .menu file and
 * putting men at the end of a users .profile, when the user logs in, a
 * menu appears.  The user can select items from the menu by typing short
 * commands.  The .menu file consists of lines, one per menu entry.
 * Each line has three parts, separated by semicolons.  The first is the
 * string to be typed to invoke the menu item.  The second is text to
 * appear on the screen.  The third is the command sequence to execute
 * when the item is selected.  The command sequence may need parameters,
 * so this program allows prompting for them.  At the place where a
 * parameter must be filled in, the menu writer should put %<prompt>%
 * where <prompt> tells the user what to fill in.  Many commands produce
 * some sort of output for the user to inspect (e.g. ls).  To allow this
 * output to remain on the screen until the user has read it, the special
 * action: # may be used.  This is a macro for: 
 *
 *	echo "Hit RETURN to menu"; read ret
 *
 * Here is an example of the .menu file:
 *
 * ca:Calendar:cal %month% %year%;echo "Hit RETURN to continue";read ret
 * cp:Copy file:cp %source file% %destination file%
 * da:Date:date;sleep 3
 * du:Disk Usage:du %directory name%;echo "Hit RETURN to continue";read ret
 * e:ELLE:elle %file name%
 * f:Tell fortune:fortune;echo "Hit RETURN to continue";read ret
 * g:Grep:grep %pattern% %file(s)%;echo "Hit RETURN to continue";read ret
 * k:Kermit:kermit 
 * ls:List directory (short):ls -C;echo "Hit RETURN to continue";read ret
 * ll:List directory (long):ls -l;echo "Hit RETURN to continue";read ret
 * mi:Mined:mined %file name%
 * mk:Make file system:mkfs %special% %size or prototype name%
 * mor:Examine file:more %file name%
 * mou:Mount floppy:/etc/mount /dev/fd0 %directory to mount on%
 * mv:Rename a file:mv %old name% %new name%
 * p:Print current dir name:pwd;echo Hit RETURN to continue";read ret
 * rec:Recover lost file:recover %file name%
 * rm:Remove file:rm %file name(s)%
 * v:vi:/bin/vi
 * +:RPN calculator:ic
 * q:Exit menu system:exit
 * !:Temporary escape to shell:/bin/sh
 * 
 */

#include <sys/types.h>
#include <fcntl.h>
#include <termios.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>

#define MAX_ITEMS 44		/* max items in all the visible menus */
#define EXEC_BUF_SIZE 1024	/* max chars in an executable command */
#define MAX_FILE_SIZE 5000	/* # bytes in the .menu file */
#define PROMPT_SIZE 256		/* size of the prompt buffer */
#define DEFAULT_FILE ".menu"	/* default file where menu is found */
#define ENTRIES_PER_COL 11	/* each menu is limited to this many entries */
#define LINE_SIZE 80		/* input buffer size */
#define SCREEN_WIDTH 80		/* # columns in the screen */
#define LINES 23		/* lines on the screen */
#define SCREEN_SIZE (LINES * (SCREEN_WIDTH + 1))

/* These items define the characters used for building frames around menus. */
#define ULCORNER 201
#define MIDDLE   205
#define URCORNER 187
#define LLCORNER 200
#define LRCORNER 188
#define SINGLE   179
#define DOUBLE   186
#define LMIDT    204
#define RMIDT    185
#define DOWN     209
#define UP       207
#define CROSS    216

struct item {
  char *code;			/* pointer to code symbol for invocation */
  char *desc;			/* pointer to text describing menu item */
  char *exec;			/* pointer to commands to execute */
} item[MAX_ITEMS];

int nitems;			/* number of items in item table */
char file_buf[MAX_FILE_SIZE+2];	/* buffer for holding .menu file */
char screen[SCREEN_SIZE];	/* screen buffer image */
char backspace = '\b';		/* backspace */
char newline = '\n';		/* newline */
char separator = ':';		/* menu items are separated by this char */
char prompt = '%';		/* separator for prompts in commands */
char ret = '#';			/* generates special message */
char *clr_str = "\033[H\033[0J";	/* ANSI for clear the screen */
char *ret_str = "echo '\n\nPlease hit RETURN to go back to the menu';read ret";

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(void read_file, (int argc, char *argv []));
_PROTOTYPE(void build_item_table, (void));
_PROTOTYPE(void legality_check, (void));
_PROTOTYPE(void build_display, (void));
_PROTOTYPE(void init_screen, (void));
_PROTOTYPE(void build_col, (struct item *ip, int count, int offset, int wid1, int wid2));
_PROTOTYPE(void draw, (void));
_PROTOTYPE(void barfill, (char *s, int lt, int mid, int rt, int wid1, int wid2));
_PROTOTYPE(void execute, (void));
_PROTOTYPE(void expand, (char *menu, char *exec));
_PROTOTYPE(void clr_screen, (void));
_PROTOTYPE(void syntax_err, (char *s));
_PROTOTYPE(void code_err, (struct item *ip, struct item *jp));

int main(argc, argv)
int argc;
char *argv[];
{

  read_file(argc, argv);	/* read in the menu file */
  build_item_table();		/* extract info from menu file */
  legality_check();		/* check for duplicates etc. */
  build_display();

  /* Display the menu and get a command to execute. */
  while (1) {
	draw();
	execute();
  }
  return(0);
}

void read_file(argc, argv)
int argc;
char *argv[];
{
/* Read the menu file into screen. */

  char *file_name;
  int fd, n;

  if (argc > 2) {
	fprintf(stderr, "Usage: men [file]\n");
	exit(1);
  }

  file_name = (argc == 2 ? argv[1] : DEFAULT_FILE);
  fd = open(file_name, O_RDONLY);
  if (fd < 0) {
	fprintf(stderr, "Cannot open %s\n", file_name);
	exit(1);
  }

  n = read(fd, file_buf, MAX_FILE_SIZE);
  if (n == MAX_FILE_SIZE) {
	fprintf(stderr, "%s is too large\n", file_name);
	exit(1);
  }

  file_buf[n+1] = '\n';
  file_buf[n+2] = '\0';
}

void build_item_table()
{
/* Examine the menu file line by line and build struct item. */

  char *p;
  struct item *ip;

  p = file_buf;
  ip = &item[0];
  nitems = 0;

  while (*p != 0) {
	/* Check for too many items. */
	if (nitems > MAX_ITEMS) {
		fprintf(stderr, "Too many items in the menu (%d)\n", nitems);
		exit(1);
	}

	ip->code = p;		/* p points to the code for this item */

	/* Search line for first separator.  It's absence is an error. */
	while (*p != separator && *p != '\n') p++;
	if (*p == '\n') syntax_err(ip->code);
	*p++ = '\0';

	/* Search line for second separator.  It's absence is also an error. */
	ip->desc = p;		/* p points to the description for this item */
	while (*p != separator && *p != '\n') p++;
	if (*p == '\n') syntax_err(ip->code);
	*p++ = '\0';
	
	/* Search line for line feed.  It cannot be absent (one was added). */
	ip->exec = p;
	while (*p != '\n') p++;
	*p++ = '\0';

	/* Move on to next item. */
	ip++;
	nitems++;
  }
}

void legality_check()
{
/* It is forbidden to repeat a code in the menu.  It is also forbidden to
 * have one code be the prefix of another code, i.e., you can't have a
 * code 'a' and a code 'am' because carriage returns are not used.  As soon
 * as you type 'a', the first item will be executed.
 */

  size_t n1, n2;
  int prompt_count;
  char *p;
  struct item *ip, *jp;

  for (ip = &item[0]; ip < &item[nitems]; ip++) {
	for (jp = ip + 1; jp < &item[nitems]; jp++) {
		if (strcmp(ip->code, jp->code) == 0) code_err(ip, jp);
		n1 = strlen(ip->code);
		n2 = strlen(jp->code);
		if (strncmp(ip->code, jp->code, n1) == 0) code_err(ip, jp);
		if (strncmp(ip->code, jp->code, n2) == 0) code_err(ip, jp);
	}

	/* If the exec part uses %, they better be balanced. */
	prompt_count = 0;
	p = ip->exec;
	while (*p != '\0') {
		if (*p == prompt) prompt_count++;
		p++;
	}

	/* Check to see that it is even. */
	if (prompt_count & 01) {
		fprintf(stderr,"Unbalanced %% ... %% in: %s\n",ip->exec);
		exit(1);
	}
  }
  	
}
	

void build_display()
{
/* The display is constructed in screen and written out in one blow. */

  int wid1, wid2, wid3, cols, k, offset, left, count;
  struct item *ip;

  /* Determine how wide the columns must be. */
  wid1 = 0;			/* code string column width */
  wid2 = 0;			/* description column width */
  for (ip = &item[0]; ip < &item[nitems]; ip++) {
	if (strlen(ip->code) > wid1) wid1 = strlen(ip->code);
	if (strlen(ip->desc) > wid2) wid2 = strlen(ip->desc);
  }

  /* Is there enough room on the screen? */
  wid3 = wid1 + wid2 + 9;	/* allow for spaces around strings, etc. */
  cols = (nitems + ENTRIES_PER_COL - 1)/ENTRIES_PER_COL;
  if (cols * wid3 > SCREEN_WIDTH) {
	fprintf(stderr, "Menus are too wide to fit %d of them on the screen\n",
								cols);
	exit(1);
  }

  /* There may be several menus next to each other.  Build them separately. */
  k = 0;
  offset = 0;			/* which column to display the menu in */
  left = nitems;		/* how many items left to display */
  init_screen();

  while (left > 0) {
	count = (left < ENTRIES_PER_COL ? left : ENTRIES_PER_COL);
	build_col(&item[k], count, offset, wid1, wid2);
	left -= count;
	k += count;
	offset += wid1 + wid2 + 9;
  }
}

void init_screen()
{
/* Clear the screen buffer */

  char *p;

  for (p = &screen[0]; p < &screen[SCREEN_SIZE]; p++) *p = ' ';
  for (p = &screen[SCREEN_WIDTH]; p < &screen[SCREEN_SIZE]; p +=SCREEN_WIDTH+1)
	*p = '\n';
}

void build_col(ip, count, offset, wid1, wid2)
struct item *ip;		/* pointer into item table */
int count;			/* number of items to display */
int offset;			/* column offset for this menu */
int wid1;			/* width of code string */
int wid2;			/* width of description screen */
{
/* Build one vertical menu in screen. */

  int k;
  char *s, *base;

  /* Build top of menu. */
  s = &screen[offset];
  barfill(s, ULCORNER, DOWN, URCORNER, wid1, wid2);
  base = s += SCREEN_WIDTH + 1;

  for (k = 0; k < count; k++) {
	/* Iterate on each line to be entered. */
	s = base;
	*s++ = DOUBLE;
	*s++ = ' ';
	strcpy(s, ip->code);
	s = base + wid1 + 3;
	*s = SINGLE;

	strcpy(base + wid1 + 5, ip->desc);
	s = base + wid1 + wid2 + 6;
	*s = DOUBLE;

	/* Draw the line under the entry.  Last one is different. */
	s = base + SCREEN_WIDTH + 1;
	if (k != count -1) {
		barfill(s, LMIDT, CROSS, RMIDT, wid1, wid2);
	} else {
		barfill(s, LLCORNER, UP, LRCORNER, wid1, wid2);
	}
	base += 2 * SCREEN_WIDTH + 2;
	ip++;
  }
}

void draw()
{
/* Draw the menu on the screen. */
  char *p;

  for (p = &screen[0]; p < &screen[SCREEN_SIZE]; p++)
	if (*p == '\0') *p = ' ';

  write(1, "\n", 1);
  write(1, screen, SCREEN_SIZE);
}


void barfill(s, lt, mid, rt, wid1, wid2)
char *s;			/* where to start */
int lt;				/* symbol to use on left */
int mid;			/* symbol to use in middle */
int rt;				/* symbol to use on right */
int wid1;			/* col1 width */
int wid2;			/* col2 width */
{
/* Draw a bar of symbols. */

  int i;

  *s++ = lt;
  for (i = 0; i < wid1 + 2; i++) *s++ = MIDDLE;
  *s++ = mid;
  for (i = 0; i < wid2 + 2; i++) *s++ = MIDDLE;
  *s++ = rt;
}

  
void execute()
{
/* Get input and execute a command. */

  struct termios save, argp;
  struct item *ip;
  char c[LINE_SIZE], exec_buf[EXEC_BUF_SIZE], *cp;

  /* Put terminal in cbreak mode. */
  tcgetattr(fileno(stdin), &save);
  argp = save;
  argp.c_lflag |= ICANON;

  /* Read in characters */
  cp = &c[0];
  while (1) {
	tcsetattr(fileno(stdin), TCSANOW, &argp);
	read(fileno(stdin), cp, 1);
	tcsetattr(fileno(stdin), TCSANOW, &save);
	if (*cp == newline) {
		cp = &c[0]; /* restart */
		continue;
	}
	if (*cp == backspace && cp > c) {
		cp--;
		write(1, " \b", 2);
		continue;
	}	
	*(cp+1) = 0;

	/* Search for a match. */
	for (ip = &item[0]; ip < &item[nitems]; ip++) {
		if (strcmp(c, ip->code) == 0) {
			/* Hit found. */
			if (strcmp(ip->exec, "exit") == 0) {
				clr_screen();
				exit(0);
			}
			expand(ip->exec, exec_buf);
			clr_screen();
			system(exec_buf);
			return;
		}
	}
	cp++;
  }
}


void expand(menu, exec)
char *menu;			/* pointer to exec part of menu item */
char *exec;			/* pointer to exec buffer */
{
/* The exec part of the menu item may have parameters, delimited by %...%
 * with a prompt in between.  The command is copied to the exec buffer,
 * and the parameters prompted for and filled in.  The final executable
 * command is passed by in exec.
 */

  register char *mp, *ep;
  int n;
  char prompt_buf[PROMPT_SIZE], *pb;

  mp = menu;
  ep = exec;
  *ep = 0;

  /* Loop need here.  One iteration per parameter prompted for. */
  while (1) {
	while (*mp != '\0' && *mp != prompt && *mp != ret) *ep++ = *mp++;
	if (*mp == '\0') {
		*ep = '\0';
		return;
	}

	/* '#' is a macro for calling "echo xxx;read ret". */
	if (*mp == ret) {
		pb = ret_str;
		while (*pb != '\0') *ep++ = *pb++;
		mp++;
		continue;
	}

	/* Start of parameter prompt. Copy it to prompt_buf. */
	mp++;
	pb = &prompt_buf[0];
	while (*mp != prompt) *pb++ = *mp++;
	*pb = '\0';
	mp++;
	*ep = '\0';

	/* Prompt the user for the parameter. */
	clr_screen();

	printf("Please enter:\n\n\t%s\n\nThen hit RETURN\n\n%s",
							prompt_buf, exec);
	fflush(stdout);

	/* Get the reply. */
	n = read(0, prompt_buf, PROMPT_SIZE);
	prompt_buf[n-1] = '\0';
	pb = &prompt_buf[0];
	while (*pb != '\0') *ep++ = *pb++;
  }		
}


void clr_screen()
{
  /* Could use Termcap, but this is simpler and probably faster. */
  write(1, clr_str, strlen(clr_str));
}

void syntax_err(s)
char *s;
{
  fprintf(stderr, "Syntax error in menu file in line:\n%s\n",s);
  exit(1);
}

void code_err(ip, jp)
struct item *ip, *jp;
{
  fprintf(stderr, "The following lines have strings that conflict:\n");
  fprintf(stderr, "%s;%s;%s\n",ip->code,ip->desc,ip->exec);
  fprintf(stderr, "%s;%s;%s\n",jp->code,jp->desc,jp->exec);
  exit(1);
}
