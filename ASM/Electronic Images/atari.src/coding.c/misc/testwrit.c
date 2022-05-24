/* testwrit.c   test operation of writscrn.c functions */

#include <stdio.h>		/* compiler library module headers */

#include "standard.h"		/* header files for patchlib.c */
#include "chain.h"
#include "writscrn.h"

struct selement ajuno1[13] = {
    {4,  5,  "DRIVE",   12,  1,  0,  0,  0 },  
    {4,  6,  "LIBRARY",  0,  2,  1,  1,  1 },  
    {4,  7,  "SELECT",   1,  3,  2,  2,  2 },  
    {4,  8,  "EDIT",     2,  4,  3,  3,  3 },  
    {4,  9,  "NAME",     3,  5,  4,  4,  4 },  
    {4,  10, "SAVE",     4,  6,  5,  5,  5 },  
    {4,  11, "UPLOAD",   5,  7,  6,  6,  6 },  
    {4,  12, "DOWNLOAD", 6,  8,  7,  7,  7 },  
    {4,  13, "PRINT",    7,  9,  8,  8,  8 },  
    {4,  14, "CLEAR",    8,  10, 9,  9,  9 },  
    {4,  15, "MOVE",     9,  11, 10, 10, 10 },  
    {4,  16, "IMPORT",  10,  12, 11, 11, 11 },  
    {4,  18, "QUIT",    11,  0,  12, 12, 12 }
};



main(){
    int pick;
    struct strchain *screen;
    
    screen = inpchain("ajuno1.scr",81);  	/* load screen image */
    
    clearsc();					/* clear screen */
    dispchain(screen);	  			/* display screen image */
    
    writerr("Use arrow keys to move cursor, return key to select.");
    
    pick = movescrn(ajuno1,0,12);		/* allow cursor movement */
    
    clearsc();
    home();
    printf("movescrn returned a value of %d",pick);
    
    exit();
}

