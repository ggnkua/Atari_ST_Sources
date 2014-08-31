/*****************************************************************************
*   "Gif-Lib" - Yet another gif library.				     *
*									     *
* Written by:  Gershon Elber				Ver 0.1, Jun. 1989   *
******************************************************************************
* Program to dump the hercules graphic screen into a GIF file		     *
******************************************************************************
* History:								     *
* 26 Jun 89 - Version 1.0 by Gershon Elber.				     *
*****************************************************************************/

#include <graphics.h>
#include "gif_lib.h"

#define DEFAULT_NAME	"hercules.gif"

/******************************************************************************
* Simple - isnt it?							      *
******************************************************************************/
void main(int argc, char **argv)
{
    if (argc == 2)
	DumpScreen2Gif(argv[1], HERCMONO, HERCMONOHI, 0, 0);
    else
	DumpScreen2Gif(DEFAULT_NAME, HERCMONO, HERCMONOHI, 0, 0);
}
