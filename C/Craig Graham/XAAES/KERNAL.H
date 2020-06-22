/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

/*
	Kernal Message Handler
*/

#ifndef _KERNAL_H_
#define _KERNAL_H_
#include "K_DEFS.H"
#include "XA_DEFS.H"

void kernal(void);
void setup_k_function_table(void);

typedef unsigned long (*AESroutine)(short clnt_pid,AESPB*);		/* All AES command handers are of this type */

typedef struct {		/* Kernal command packet structure */
	short pid;			/* client pid */
	unsigned short cmd;	/* command code */
	AESPB *pb;			/* pointer to AES parameter block */
} K_CMD_PACKET;

typedef struct {
	short mx;
	short my;
	short state;
	short clicks;
} MOUSE_DATA;

#endif
