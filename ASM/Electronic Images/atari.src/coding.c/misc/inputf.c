/* inputf.c   functions for prompting user input     jlc 10-87 */
/* version 1.0 */ 

#include <conio.h>		/* compiler library module headers */
#include <stdio.h>
#include <stdlib.h>

#include "standard.h"			/* header files */

	
getfloat(lineno,string,value,min,max)	/* get floating point no. from user */
float *value, min, max;
char *string;
int lineno;
{
    static char input[20], minbuf[20], maxbuf[20], message[80];
    float tempval;

    while (kbhit()) getch();		/* clear any stray keypress */
	
    while (1){
	writword(BWC,string,0,lineno);
	fgets(input,19,stdin);
	if (input[0] == '\n' || input[0] == '\0' || input[0] == ESC)
	    return(0);
	tempval = atof(input);
    
	if (tempval > max || tempval < min){
	    gcvt(min,3,minbuf);
	    gcvt(max,3,maxbuf);
	    strcpy(message,"Value must be between ");
	    strcat(message,minbuf);
	    strcat(message," and ");
	    strcat(message,maxbuf);
	    writerr(message);
	}
	else{
	    *value = tempval;
	    return(1);
	}
    }
}


getint(lineno,string,value,min,max)	/* get integer value from user */
int *value, min, max, lineno;
char *string;
{
    static char input[20], minbuf[20], maxbuf[20], message[80];
    
    int tempval;

    while (kbhit()) getch();		/* clear any stray keypress */
	
    while (1){
	writword(BWC,string,0,lineno);
	fgets(input,19,stdin);
	if (input[0] == '\n' || input[0] == '\0' || input[0] == ESC)
	    return(0);
	tempval = atoi(input);
    
	if (tempval > max || tempval < min){
	    itoa(min,minbuf,10);
	    itoa(max,maxbuf,10);
	    strcpy(message,"Value must be between ");
	    strcat(message,minbuf);
	    strcat(message," and ");
	    strcat(message,maxbuf);
	    writerr(message);
	}
	else{
	    *value = tempval;
	    return(1);
	}
    }
}


clearline(lineno)			/* blank out a line */
int lineno;
{
    csrplot(0,lineno);
    writbw(' ',80);
}

