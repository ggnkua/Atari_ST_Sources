/* test401.c   input and output testing for the  mpu-401 */


#include <stdio.h>
#include <conio.h>
#include <ctype.h>

#include "standard.h"


main()
{
    char str[4], c;
    int i, j, n, *m, status;
    static int k;
    m = &k;
    
    printf("\nHit 'c' to enter a command, ESC to exit.  All data in hex.");
	
    while (1){
	if ((i = getdata()) != -1){
	    printf("\n->%x",i);
	    while ((i = getdata()) != -1)
		printf(" %x",i);
	}
	if (kbhit()){
	    c = getch();
	    if (c == '\n' || c == ESC)
		exit();
	    printf("\nEnter two hex digits->");
	    gets(str);
	    n = xtoi(str, m);
		
	    if (toupper(c) == 'D'){
		if (n > 0){
		    j = putdata(*m);
		    printf("\nputdata returned %x",j);
		}
		else
		    printf("\nNot valid hex input (00 - FF)");
	    }
	    else if (toupper(c) == 'C'){
		if (n > 0){
		    j = putcmd(*m);
		    printf("\nputcmd returned %x",j);
		}
		else
		    printf("\nNot valid hex input (00 - FF)");
	    }
	}
    }
}




xtoi(str, nbr)	/* converts hex string to int, returns number of */ 
char *str;	/* valid hex chars read (4 max) */
int *nbr;
{
    int n, i;
    *nbr = i = 0;
    do{
	if ((n = hextran(str[i])) < 0)
	    break;
	else
	    *nbr = (*nbr * 16) + n;	
    }while (++i < 4);
    return(i);
}



hextran(hex)	/* convert 1 hex char to decimal */
char hex;
{
    hex = toupper(hex);    
    if (hex >= '0' && hex <= '9')
	return(hex - '0');
    else if (hex >= 'A' && hex <= 'F')
	return(hex - 'A' + 10);
    else
	return(-1);	/* no match with hex chars */
}

