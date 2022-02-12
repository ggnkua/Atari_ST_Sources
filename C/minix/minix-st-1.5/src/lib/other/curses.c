#include <lib.h>
#include <curses.h>
#include <termcap.h>
/************************************************************************
 *									*
 *			 Tiny pseudo "curses" package			*
 *									*
 *		v1.0	870117	DBW - D. Wecker, initial hack		*
 *		v1.1    881003  W. Toomey, hacked to get it to use	*
 *				Termcap, and to not foul input.		*
 *				Borrowed a bit of code from Alistair	*
 *				Crooks' `show.c' posted on 870730.	*
 *									*
 ************************************************************************/

/* #include <sys/ioctl.h>	- the ioctl calls seem to stop input */
#include <sgtty.h>
#include <stdlib.h>
#include <stdio.h>

struct sgttyb old_tty, new_tty;

extern char *tgetstr();		/* termcap getstring capability */
extern char *tgoto();		/* termcap goto (x, y) */

#define ROWS	24
#define COLS	80
#define NORMAL	0x00
#define BOLD	0x80

char termcap[1024];		/* termcap buffer */
char tc[100];			/* area to hold string capabilities */
char *ttytype;			/* terminal type from env */
char *arp;			/* pointer for use in tgetstr */
char *cp;			/* character pointer */

char *cl;			/* clear screen capability */
char *cm;			/* cursor motion capability */
char *so;			/* start standout capability */
char *se;			/* end standout capability */

char nscrn[ROWS][COLS], cscrn[ROWS][COLS], row, col, mode;
char str[256];

/*
 *	fatal - report error and die. Never returns
 */
void fatal(s)
char *s;
{
  (void) fprintf(stderr, "curses: %s\n", s);
  exit(1);
}


/*
 *	outc - call putchar, necessary because putchar is a macro.
 */
void outc(c)
int c;
{
  putchar(c);
}


void move(y, x)
int y, x;
{
  row = y;
  col = x;
}

void clrtoeol()
{
  int i;

  for (i = col; i < COLS; i++) nscrn[row][i] = ' ' | mode;
}

void printw(fmt, a1, a2, a3, a4, a5)
char *fmt, *a1, *a2, *a3, *a4, *a5;
{
  int i, j, k;

  sprintf(str, fmt, a1, a2, a3, a4, a5);
  j = 0;
  k = row;
  for (i = col; i < COLS && k < ROWS && str[j] != '\000'; i++)
	if (str[j] != '\n')
		nscrn[k][i] = str[j++] | mode;
	else {
		i = 0;
		j++;
		k++;
	}
  col = i;
  row = k;
}

void clrtobot()
{
  int i, j;

  clrtoeol();
  for (i = row + 1; i < ROWS; i++) for (j = 0; j < COLS; j++)
		nscrn[i][j] = ' ' | mode;
}

void standout()
{
  mode = BOLD;
}

void standend()
{
  mode = NORMAL;
}

void addstr(s)
char *s;
{
  printw("%s", s, "", "", "", "");
}

void initscr()
{
  int i, j;
/*
    ioctl(0,TIOCGETP,&old_tty);			I don't have a clue
    ioctl(0,TIOCGETP,&new_tty);			why these are used,
    new_tty.sg_flags |= RAW;			but I've commented them
    new_tty.sg_flags &= ~ECHO;			out to get stdin working.
    ioctl(0,TIOCSETP,&new_tty);
*/
  if ((ttytype = getenv("TERM")) == (char *)NULL)
	fatal("No terminal type set in environment");

  if (tgetent(termcap, ttytype) != 1) fatal("No termcap entry for terminal");
  arp = tc;
  cl = tgetstr("cl", &arp);
  so = tgetstr("so", &arp);
  se = tgetstr("se", &arp);
  cm = tgetstr("cm", &arp);

  row = 0;
  col = 0;
  mode = NORMAL;
  for (i = 0; i < ROWS; i++) for (j = 0; j < COLS; j++)
		nscrn[i][j] = cscrn[i][j] = ' ';
  tputs(cl, 1, outc);
}

void clear()
{
  row = 0;
  col = 0;
  clrtobot();
}

char inch()
{
  return(nscrn[row][col] & 0x7F);
}

void touchwin()
{
  int i, j;

  for (i = 0; i < ROWS; i++) for (j = 0; j < COLS; j++)
		cscrn[i][j] = ' ';
  tputs(cl, 1, outc);
}

void refresh()
{
  int i, j, mode;

  mode = NORMAL;
  for (i = 0; i < ROWS; i++) {
	for (j = 0; j < COLS; j++) {
		if (nscrn[i][j] != cscrn[i][j]) {
			cp = tgoto(cm, j + 1, i + 1);
			tputs(cp, 1, outc);
			while (nscrn[i][j] != cscrn[i][j]) {
				if (mode == NORMAL && (nscrn[i][j] & BOLD) == BOLD) {
					tputs(so, 1, outc);
					mode = BOLD;
				} else if (mode == BOLD && (nscrn[i][j] & BOLD) == NORMAL) {
					tputs(se, 1, outc);
					mode = NORMAL;
				}
				cscrn[i][j] = nscrn[i][j];
				fputc(nscrn[i][j] & 0x7F, stdout);
				j++;
			}
		}
	}
  }
  cp = tgoto(cm, col + 1, row + 1);
  tputs(cp, 1, outc);
  if (mode) tputs(se, 1, outc);
  fflush(stdout);
}

void endwin()
{
  move(ROWS - 1, 0);
  refresh();
/*
    ioctl(0,TIOCSETP,&old_tty);
 */
}

