/* #[include:		*/

#include <aes.h>
#include <vdi.h>
#include <stdlib.h>
#include <string.h>

#include "stdc.h"
#include "mines.h"

/* #]include:		*/ 
/* #[globals:		*/

static int xstart, ystart, width, height;
extern int exitflag;
extern int userbombs;

/* #]globals:		*/ 
/* #[rsc_stuff:		*/

#define NUM_OBS 9

static char p_to_null[1] = "";

static TEDINFO rs_tedinfo[] = {
    {
	"___",
	"Number of mines: ___",
	"999",
	3,   6,   0, 4480,   0,  -2,   4,  21
    },{
	"  Welcome to Mines  ",
	"____________________",
	"XXXXXXXXXXXXXXXXXXXX",
	3,   6,   2, 4480,   0,  -2,  21,  21
    },{
	"(FOR UNCHICHAN)",
	p_to_null,
	p_to_null,
	5,   6,   0, 4480,   0,  -2,  16,   1
    }
};

static OBJECT rs_object[] = {
  /* Tree #0*/
  { -1,  1,  8, 0x0014, 0x0000, 0x0030,    0x00021121L,  1,  1,  28,   18},
  {  7,  2,  4, 0x0014, 0x0000, 0x0020,    0x00fe1141L,  2,  1,  24,   12},
  {  3, -1, -1, 0x001d, 0x0008, 0x0030, &rs_tedinfo[0],  2,  8,  20,    1},
  {  4, -1, -1, 0x001d, 0x0000, 0x0030, &rs_tedinfo[1],  2, 10,  20,    1},
  {  1,  5,  6, 0x0014, 0x0000, 0x0020,    0x00fe1101L,  2,  1,  20, 2051},
  {  6, -1, -1, 0x001c, 0x0000, 0x0000,  " MINES ",  4,  1,  11,    1},
  {  4, -1, -1, 0x0015, 0x0000, 0x0000, &rs_tedinfo[2],  4,  2, 523,    1},
  {  8, -1, -1, 0x001a, 0x0007, 0x0020,         "PLAY",  2, 15,   9,    2},
  {  0, -1, -1, 0x001a, 0x0025, 0x0020,         "EXIT", 18, 15,   8,    2}
};

static OBJECT *tree = &rs_object[0];

/* #[fix_objects:	*/

void
fix_objects()
{
    register int i;

    for(i=0; i<NUM_OBS; i++) rsrc_obfix(rs_object, i);
}
/* #]fix_objects:	*/ 
/* #]rsc_stuff:		*/

/* #[ObjPosition:	*/

void
ObjPosition()
{
    width  = tree->ob_width;
    height = tree->ob_height;

    tree->ob_x = xstart = (OFFX - width)/2;
    tree->ob_y = ystart = (400 - height)/2;
}

/* #]ObjPosition:	*/ 
/* #[ObjPut:		*/

void
ObjPut(object)
int object;
{
    form_dial(0, xstart, ystart, width, height, xstart, ystart, width, height);
    objc_draw(tree, object, 5, xstart, ystart, width, height);
}

/* #]ObjPut:		*/ 
/* #[ObjGet:		*/

void
ObjGet()
{
    form_dial(2, 320, 200, 0, 0, xstart, ystart, width, height);
    form_dial(3, xstart, ystart, width, height, xstart, ystart, width, height);
}

/* #]ObjGet:		*/ 
/* #[SetText:		*/

void
SetText(object, s)
int	object;		/* child which contains TEDINFO	*/
char	*s;		/* address of our string	*/
{
#define MSGLEN	21
#define BOMBLEN	 4

    (void) strcpy((tree+object)->ob_spec.tedinfo->te_ptext, s);
    (tree+object)->ob_spec.tedinfo->te_txtlen =
    	(object == MESSAGE) ? MSGLEN : BOMBLEN;

    objc_draw(tree, object, 1, xstart, ystart, width, height);
}

/* #]SetText:		*/ 
/* #[GetText:		*/

void
GetText(object, s)
int	object;		/* child which contains TEDINFO	*/
char	*s;
{
    (void) strcpy(s, (tree+object)->ob_spec.tedinfo->te_ptext);
}

/* #]GetText:		*/ 
/* #[Button:		*/

Button(index)
int	index;
{
    long l = (long) tree;

return ((*((int *)(l + (index)*sizeof(OBJECT)+10)) & (int) SELECTED) != 0);
}

/* #]Button:		*/ 
/* #[Settings:		*/

void
Settings()
{
    int choice;
    static char bombstr[4];

    objc_change(tree, PLAY, 0, xstart, ystart, width, height, NORMAL, 1);

    choice = form_do(tree, MINES);
    switch (choice) {
	case QUIT :	exitflag++;
			return;
	case PLAY :	GetText(BOMBS, bombstr);
			userbombs = atoi(bombstr);
			break;
    }
}

/* #]Settings:		*/ 
