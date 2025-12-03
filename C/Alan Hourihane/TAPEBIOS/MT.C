/* MT.TTP, Magnetic Tape functions for TapeBIOS 	*/
/* This program is part of the TapeBIOS ditribution	*/
/* Written by Alan Hourihane 1992			*/
/* Needs TapeBIOS driver loaded				*/

#include <stdio.h>
#include "tapebind.h"

extern void exit();
extern void Erase_Tape();
extern void Retension();
extern int Request_Sense();
extern int strcmp();
extern void bzero();
extern long get_cookie();

int
main(argc, argv) 
int argc; char *argv[];
{
	if(argc != 2) { 
		printf("Magnetic Tape (MT) Utility. Copyright 1992, A. Hourihane.\r\n");
		printf("Usage: %s { rewind | load | unload | erase | retension }\r\n", argv[0]); 
		exit(1); 
	}

	if(!get_cookie("TAPE")) {
		printf("TapeBIOS is not installed.\r\n");
		exit(1);
	}
	
	if (!(strcmp(argv[1], "rewind")))
		(void) Trewind();
	else if(!(strcmp(argv[1], "retension")))
		(void)Retension();
	else if(!(strcmp(argv[1], "erase")))
		(void)Erase_Tape();
	else if(!(strcmp(argv[1], "load")))
		(void)Tload(0L);
	else if(!(strcmp(argv[1], "unload")))
		(void)Tunload(0L);
	
	return(0);
}

int
Ready_Tape()
{
	int stat = 0, x = 0;

	for(x = 10; x > 0 && stat; x--) {
		stat = Tready();
		if(stat == 2) {
			stat = Request_Sense();
			printf("Tape Drive returned error code: %d\r\n",stat);
			return(stat);
		}
	}
	return(0);
}

void
Retension()
{
	int stat = 0;

	if(Ready_Tape() == 0) {
		stat = Tload(1L);
		if (stat == 2) {
			stat = Request_Sense();
			printf("Tape Drive returned error code: %d\r\n",stat);
		}
		stat = Tunload(0L);
		if (stat == 2) {
			stat = Request_Sense();
			printf("Tape Drive returned error code: %d\r\n",stat);
		}
	}
}

void
Erase_Tape()
{
	int stat = 0;
	
	if(Ready_Tape() == 0) {
		stat = Terase();	
			if(stat) {
				if(stat == 2) {
				stat = Request_Sense();
				printf("Tape Drive returned error code: %d\r\n",stat);
				}
			}
	}
}
