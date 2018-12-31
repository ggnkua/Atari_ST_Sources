/*********************************************
	file: events.h
	utility: header file of events.c
	date: 14 dec 96
	author: C. Moreau
	modifications:
	comments: 
*********************************************/

#ifndef _EVENTS_H
#define _EVENTS_H

/*********************************************
	includes
*********************************************/

/*********************************************
	defines
*********************************************/
#ifndef TRUE
#define TRUE		1
#define FALSE		0
#endif 

/*********************************************
	types definitions
*********************************************/

/*********************************************
	globals variables declarations
*********************************************/
extern int objet;
extern int message[8];			/* AES message array */

/*********************************************
	globals functions declarations
*********************************************/
extern void TaskMaster(void);

#endif