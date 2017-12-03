/*
	tcvmode.c
	
	data to be linked with F30START.O
	defines true color 320x240 video mode
*/

#include <tos.h>

/* new tos.h defines
#define VERTFLAG          0x0100
#define STMODES           0x0080
#define OVERSCAN          0x0040
#define PAL               0x0020
#define VGA_FALCON        0x0010
#define TV                0x0000

#define COL80             0x08
#define COL40             0x00

#define BPS16             4
#define BPS8              3
#define BPS4              2
#define BPS2              1
#define BPS1              0
*/

int vmodes[]=
{	0,                                      /* sm124, pas de mode */
	TV | COL40 | BPS16,                     /* rgb */
	VGA_FALCON | COL40 | BPS16 | VERTFLAG,  /* vga */
	TV | COL40 | BPS16                      /* tv  */
};
