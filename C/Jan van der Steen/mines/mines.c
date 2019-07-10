/* #[include:		*/

#include <vdi.h>
#include <aes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <osbind.h>

#include "stdc.h"
#include "mines.h"

/* #]include:		*/ 
/* #[defines:		*/

#define EMPTY	0
#define GRAY	1
#define BOMB	2
#define OK	3
#define MAN	4
#define PATH	5

#define	DEFBOMBS	60

/* #]defines:		*/ 
/* #[global:		*/

#include "shapes.h"

int	mine [SIZE][SIZE];
int	yours[SIZE][SIZE];
int	vdi_handle;
int	orgcolor;
int	gl_apid;
int	newgame   = 0;
int	exitflag  = 0;
int	userbombs = DEFBOMBS;	/* user's choice		*/
int	curi, curj;
int	lasthow;

/* #]global:		*/ 

/* #[alert:		*/

int alert(special, line1, line2, line3, line4, line5, but1, but2, but3, defbut)
/*
 * General interactive message
 *
 * special	: kind of alert (0=none, 1=!, 2=?, 3=stop for AtariST)
 * line[1-5]	: message lines
 * but[1-3]	: tekst for answer buttons
 * defbut	: number of default button (0 for none)
 *
 * alert() returns the number of the selected button
 *
 * PS.	Because of a bug in Turbo-C all character pointers have either
 *	the form " ", or "". An argument 0 will cause an address error.
 *	Because of this bug we test on *line instead of the more usual
 *	value of line...
 */
int special;
char *line1, *line2, *line3, *line4, *line5;
char *but1, *but2, *but3;
int defbut;
{
    char msg[200];
    char l1[200], l2[200], l3[200], l4[200], l5[200];
    char b1[25], b2[25], b3[25];

    if (*line1) sprintf(l1, "%s"  , line1); else l1[0] = 0;
    if (*line2) sprintf(l2, " |%s", line2); else l2[0] = 0;
    if (*line3) sprintf(l3, " |%s", line3); else l3[0] = 0;
    if (*line4) sprintf(l4, " |%s", line4); else l4[0] = 0;
    if (*line5) sprintf(l5, " |%s", line5); else l5[0] = 0;
    if (*but1 ) sprintf(b1, "%s"  ,  but1); else b1[0] = 0;
    if (*but2 ) sprintf(b2, " | %s",  but2); else b2[0] = 0;
    if (*but3 ) sprintf(b3, " | %s",  but3); else b3[0] = 0;
    sprintf(msg,"[%d][%s%s%s%s%s][ %s%s%s ]",
		special, l1, l2, l3, l4, l5, b1, b2, b3);
    return form_alert(defbut, msg);
}

/* #]alert:		*/ 
/* #[mouse_on():	*/

void
mouse_on()
{
    v_show_c(vdi_handle, 1);
}

/* #]mouse_on():	*/ 
/* #[mouse_off():	*/

void
mouse_off()
{
    v_hide_c(vdi_handle);
}

/* #]mouse_off():	*/ 
/* #[RezWarning:	*/

void
RezWarning()
{
    (void) alert(3,	" ",
			" Sorry...,",
			" ",
			" Mines will only run",
			"  in high resolution ",
			"Exit", "", "", 1);
}

/* #]RezWarning:	*/ 

/* #[glob_init:		*/

void
glob_init()
{
    int		i;
    int		work_in [11];
    int		work_out[57];
    int		wchar, hchar, wbox, hbox;

    /*
     * Empty input buffer
     */
	while (Cconis()) Cconin();

    /*
     * Check resolution
     */
	if ( Getrez() != 2 ) { RezWarning(); my_exit(0); }

    /*
     * Save the screen color and set it to white
     */
	orgcolor = Setcolor(0, 0xffff);
	Setcolor(0, 0xfff); Setcolor(1, 0);

    /*
     * Initialise the ROM libraries and tell it about this application
     */
	if ((gl_apid = appl_init()) == -1) my_exit(1);


    graf_mouse(HOURGLASS, 0x0L);

    /*
     * Open the physical work station
     */
	vdi_handle = work_in[0] = graf_handle(&wchar, &hchar, &wbox, &hbox);

    /*
     * Initialise: Line type and color, Text style and color, ...,
     * and the coordinate system we will use.
     */
	for (i=1 ; i<10 ; i++) work_in[i] = 1; work_in[10] = 2;

    /*
     * Open virtual workstation
     */
	v_opnvwk(work_in, &vdi_handle, work_out);
	if (vdi_handle == 0) my_exit(2);

    /*
     * Clear workstation
     */
	mouse_off(); v_clrwk(vdi_handle); mouse_on();

    /*
     * Load resources
     */
 	fix_objects();

    graf_mouse(ARROW, 0x0L);
}
/* #]glob_init:		*/ 
/* #[my_init:		*/

void
my_init()
{
    long ticks = 349L;
    int  dummy;

    srand((int) (time(&ticks) % 37));	/* see: Turbo-C rand() */
    ObjPosition();
    ObjPut(MINES);
    /*
     * Draw a board
     */
    drawboard();
    /*
     * As small as possible
     */
    vst_height(vdi_handle, 4, &dummy, &dummy, &dummy, &dummy);
    /*
     * Left and topline alignment
     */
    vst_alignment(vdi_handle, 0, 2, &dummy, &dummy);
}

/* #]my_init:		*/ 
/* #[game_init:		*/

void
game_init()
{
    char tmp[4];

    sprintf(tmp, "%3d", userbombs);
    SetText(BOMBS, tmp);
    /*
     * get playing conditions
     */
    do {
	Settings();
    } while (userbombs > (SIZE*SIZE -5));

    /*
     * Create board
     */
    if (!exitflag) newboard();
}

/* #]game_init:		*/ 
/* #[my_exit:		*/

void
my_exit(error)
/*
 *	Clean up depending on error
 */
int error;
{
    switch (error) {
	case 4:	ObjGet();			/* not enough memory	  */
	case 3:	appl_exit();			/* couldn't open rsc file */
	case 2:	v_clsvwk(vdi_handle);		/* couldn't open device   */
		graf_mouse(ARROW, 0x0L);
	case 1:	Setcolor(0, orgcolor);		/* no application handle  */
       default:	exit(0);
    }
}

/* #]my_exit:		*/ 
/* #[main:		*/

void
main()
{
    int	mx, my, mbut, mstate;

    glob_init();
    my_init();
    game_init();
    while (!exitflag) { /* play! */
	vq_mouse(vdi_handle, &mbut, &mx, &my);
	vq_key_s(vdi_handle, &mstate);
	/*
	 * graf_mkstate(&mx, &my, &mbut, &mstate);
	 */

	check(mx, my, mbut, mstate);
	if (mbut) do {
	    vq_mouse(vdi_handle, &mbut, &mx, &my);
	    /*
	     * graf_mkstate(&mx, &my, &mbut, &mstate);
	     */
	} while (mbut);
	if (newgame) game_init();
    }
    my_exit(4);
}

/* #]main:		*/ 

/* #[Message:		*/

void
Message(s)
char	*s;
{
    char msg[200];

    sprintf(msg, "[1][ %s ][ OK ]", s);
    form_alert(1, msg);
}

/* #]Message:		*/
/* #[message:		*/

void
message(s)
char *s;
{
    SetText(MESSAGE, s);
}

/* #]message:		*/ 
/* #[howmany:		*/

void
howmany(i, j)
int i, j;
{
    int ii;
    int jj;
    char tmp[80];

    lasthow = 0;
    for (ii=-1; ii<=1; ii++)
    for (jj=-1; jj<=1; jj++) {
	int iii = i+ii;
	int jjj = j+jj;

	if (!onboard(&iii, &jjj) || (iii==0 && jjj==0)) continue;
	if (mine[iii][jjj] == BOMB) lasthow++;
    }
    if (lasthow == 1)
	sprintf(tmp, "%d mine near to you  ", lasthow);
    else
	sprintf(tmp, "%d mines near to you ", lasthow);
    SetText(MESSAGE, tmp);
}

/* #]howmany:		*/ 
/* #[Howmany:		*/

int
Howmany(i, j)
int i, j;
{
    int ii;
    int jj;
    int tot = 0;

    for (ii=-1; ii<=1; ii++)
    for (jj=-1; jj<=1; jj++) {
	int iii = i+ii;
	int jjj = j+jj;

	if (!onboard(&iii, &jjj) || (iii==0 && jjj==0)) continue;
	if (yours[iii][jjj] == PATH) tot++;
    }
    return tot;
}

/* #]Howmany:		*/ 
/* #[onboard:		*/

int
onboard(i, j)
int *i, *j;
{
    if (*i>100) {
	/* assume screen coordinates so adjust them */
	*i -= OFFX; *i = *i / PIXELS;
	*j -= OFFY; *j = *j / PIXELS;
    }
    if (*i>=0 && *i<SIZE && *j>=0 && *j<SIZE)
	return 1;
    else
	return 0;
}

/* #]onboard:		*/ 
/* #[reachable:		*/

reachable(i, j)
/*
 * Is (i, j) reachable with normal moves?
 */
int i, j;
{
    int ii;
    int jj;

    for (ii=-1; ii<=1; ii++)
    for (jj=-1; jj<=1; jj++) {
	int iii = i+ii;
	int jjj = j+jj;

	if (!onboard(&iii, &jjj)) continue;
	if (yours[iii][jjj] == GRAY || yours[iii][jjj] == MAN) return 1;
    }
    return 0;
}

/* #]reachable:		*/ 
/* #[check:		*/

void
check(i, j, but, state)
int i, j, but, state;
{
    if (state & K_LSHIFT && state & K_RSHIFT) {
	/*
	 * quit request
	 */
	showpos();
	return;
    }
    if (state & K_LSHIFT || state & K_RSHIFT) return;

    if (!onboard(&i, &j)) return;

    if (but && state == K_ALT) {
	/*
	 * User indication: BOMB, OK, or EMPTY
	 */
	if (but == 1) {
	    /*
	     * OK request
	     */
	    if (yours[i][j] == EMPTY ||
		yours[i][j] ==  BOMB ||
		yours[i][j] ==  PATH  ) putshape(i, j, OK);
	    else if (yours[i][j] == OK) putshape(i, j, EMPTY);
	}
	if (but == 2) {
	    /*
	     * BOMB request
	     */
	    if (yours[i][j] == EMPTY ||
		yours[i][j] ==    OK ||
		yours[i][j] ==  PATH  ) putshape(i, j, BOMB);
	    else if (yours[i][j] == BOMB) putshape(i, j, EMPTY);
	}
	return;
    }

    if (but != 1 || !reachable(i, j)) return;

    /*
     * Test if move is legal
     */
    if (mine[i][j] == BOMB && yours[i][j] != BOMB) {
	putflash(i, j);
	message("You just exploded");
	showpos();
	return;
    }
    switch (yours[i][j]) {
	case BOMB:
	    /*
	     * You don't want to step on your own mines, do you?
	     */
	     return;
	case EMPTY:
	case OK:
	case GRAY:
	case PATH:
		putshape(curi, curj, GRAY);
		puthow();	/* how many in last square */
		curi = i;
		curj = j;
		putshape(curi, curj, MAN);
		howmany(curi, curj);
		break;
	case MAN:
		break;
    }
    /*
     * Test end of game
     */
    if (curi == SIZE-1 && curj == SIZE-1) {
	Message(" | | You made it!");
	showpos();
	return;
    }
}

/* #]check:		*/ 
/* #[puthow:		*/

void
puthow()
{
    char number[2];

    mouse_off();

    sprintf(number, "%d", lasthow);
    vswr_mode(vdi_handle, MD_REPLACE);
    v_gtext(vdi_handle, OFFX+(curi*PIXELS)+4, OFFY+(curj*PIXELS)+4, number);

    mouse_on();
}
/* #]puthow:		*/ 
/* #[putshape:		*/

void
putshape(i, j, which)
int i, j, which;
{
    static int rect[8] = {               0,   0,  23,  23,   0,   0,   0,  0 };
    static MFDB screen = { (void *) 0,   0,   0,   0,   0,   0,   0,   0,  0 };
    static MFDB shapep = { (void *) 1,  32,  24,   2,   1,   1,   0,   0,  0 };

    rect[4] = OFFX + i*PIXELS;
    rect[5] = OFFY + j*PIXELS;
    rect[6] = rect[4] + PIXELS-1;
    rect[7] = rect[5] + PIXELS-1;

    shapep.fd_addr = shape[which];
    yours[i][j] = which;

    mouse_off();
    vro_cpyfm(vdi_handle, 3, rect, &shapep, &screen);
    mouse_on();
}
/* #]putshape:		*/ 
/* #[permute:		*/

long
permute()
/*
 * Generate a random order of 8 digits and return it packed in a long
 */
{
    int  place, number = 8;
    int  perm[8] = {0};
    long ran = 0;

    do {
	/*
	 * Fill perm random with 1, 2,..., 8
	 */
	place = rand() & 0x07;
	if (!perm[place]) perm[place] = number--;
    } while (number);

    /*
     * Fill the long with the order
     */
    for (place=0; place<8; place++) {
	ran <<= 3;
	ran  |= (perm[place]-1);
    }
    return ran;
}

/* #]permute:		*/ 
/* #[makepath:		*/

makepath(i, j)
/*
 * Make a path from (i, j) to (SIZE-1, SIZE-1).
 * This will ensure that the target square can always be reached.
 */
{
    int ii = i, jj = j, k;
    long ran;

    if (i == SIZE-1 && j == SIZE-1) return 1;
    /*
     * Generate a random order for (0, 1, ..., 7)
     */
    ran = permute();

    /*
     * Now try each neighbour
     */
    for (k=0; k<8; k++) {
	switch ((int) (ran & 0x07)) {
	    /*
	     * We bias sligthly towards the lower right corner
	     * by changing case 7 (i--; j--) to i++; j++.
	     */
	    case 0: i++;	break;
	    case 1: j++;	break;
	    case 2: i--;	break;
	    case 3: j--;	break;
	    case 4: i++; j++;	break;
	    case 5: i++; j--;	break;
	    case 6: i--; j++;	break;
	    case 7: i++; j++;	break;
	}
	ran >>= 3;

	if (
		/*
		 * Are we on the board?
		 */
		onboard(&i, &j)	&&
		/*
		 * Have we been here before?
		 */
		!yours[i][j]	&&
		/*
		 * Do we have more than 1 neighbour. This will ensure
		 * a thin path and hence more space for the bombs.
		 */
		Howmany(i, j) < 2) {

	    yours[i][j] = PATH;
	    if (makepath(i, j)) return 1;
	    else yours[i][j] = 0;
	}
	i = ii; j = jj;
    }
    return 0;
}

/* #]makepath:		*/ 
/* #[drawboard:		*/

void
drawboard()
/*
 * Draw a field
 */
{
    int i, j;

    for (i=0; i<SIZE; i++)
    for (j=0; j<SIZE; j++) {
	mine [i][j] =
	yours[i][j] = 0;
	putshape(i, j, EMPTY);
    }
}

/* #]drawboard:		*/ 
/* #[newboard:		*/

void
newboard()
{
    int	i, j;
    int	ran;
    int free  = 0;
    int bombs = userbombs;

    mouse_off();
    newgame = 0;

    for (i=0; i<SIZE; i++)
    for (j=0; j<SIZE; j++) {
	mine [i][j] =
	yours[i][j] = 0;
	putshape(i, j, EMPTY);
    }

    /*
     * Design path from (0, 0) to lower right corner
     */
    message("Creating a path...");
    (void) makepath(0, 0);

    /*
     * Put start squares and finish square
     */
    putshape(0, 0, GRAY);
    putshape(1, 0, GRAY);
    putshape(0, 1, GRAY);
    putshape(1, 1, GRAY);
    putshape(SIZE-1, SIZE-1, OK);

    /*
     * Check if there is any place left for the mines
     */
    for (i=0; i<SIZE; i++)
    for (j=0; j<SIZE; j++) if (!yours[i][j]) free++;

    if (free < bombs) {
	message("Can't place bombs!");
	showpos();
	mouse_on();
	return;
    }

    /*
     * Place the bombs
     */
    message("Placing the bombs...");
    while (bombs) {
	ran = rand();
	/*
	 *  11111111 1111 1111
	 *	     ^^^^ ^^^^
	 *		i    j
	 */
	i = ran & 0x0f; ran >>= 4;
	j = ran & 0x0f;
	if (!mine[i][j] && !yours[i][j]) {
	    mine[i][j] = BOMB;
	    bombs--;
	}
    }

    curi = curj = 0;
    putshape(curi, curj, MAN);
    howmany (curi, curj);
    mouse_on();
}

/* #]newboard:		*/ 
/* #[showpos:		*/

void
showpos()
{
    int i, j;

    mouse_off();
    for (i=0; i<SIZE; i++)
    for (j=0; j<SIZE; j++) {
	if ( mine[i][j] == BOMB) putshape(i, j,  BOMB);
	else
	if (yours[i][j] == BOMB) putshape(i, j, EMPTY);
	if (yours[i][j] == PATH) putshape(i, j,  PATH);
    }
    newgame = 1;
    mouse_on();
}

/* #]showpos:		*/ 
