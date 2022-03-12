/*
   Atari Mouse interface by Anthony Jacques <jacquesa@cs.man.ac.uk>

   You are allowed to use any parts of this code in another program, as
   long as you give credits to the authors in the documentation and in
   the program itself.  Read the file README.1ST for more information.

   This program comes with absolutely no warranty.

   ATRMOUSE.C - Atari Mouse driver routines.
*/

/* the includes */
#include "deu.h"

/* the global data */
Bool UseMouse;			/* is there a mouse driver? */


/*
** initialize the mouse driver
*/
void CheckMouseDriver()
{
   UseMouse = TRUE; /* Theres always a mouse */
}



/*
** show the pointer
*/

void ShowMousePointer()
{
}



/*
** hide the pointer
*/
void HideMousePointer()
{
}



/*
** read pointer coordinates
*/

void GetMouseCoords(short *x, short *y, short *buttons)
{
}



/*
** change pointer coordinates
*/

void SetMouseCoords( short x, short y)
{
}



/*
** set horizontal and vertical limits (constrain pointer in a box)
*/

void SetMouseLimits( short x0, short y0, short x1, short y1)
{
}



/*
** reset horizontal and vertical limits
*/

void ResetMouseLimits()
{
}


/*
** mouse callback function - for a kludge to fix a problem with
** Cirrus graphics cards in PC deu...
*/
void MouseCallBackFunction()
{
}

/* end of file */
