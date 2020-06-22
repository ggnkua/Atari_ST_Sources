
/********************************************************************
* SE_TEST:  This program demonstrates the SE-protocol with Everest.
*
* 1) Start EVEREST
* 2) Start SE_TEST
*
* This program ignores memory protection. You have to allocate the
* memory for the SE-protocol as public.
********************************************************************/


#include <stddef.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include <ext.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#include "seproto.h"
#include "vaproto.h"
#include "se_test.h"

typedef enum {true=1,false=0} boolean;
#define TRUE true
#define FALSE false

OBJECT *menu;

char *app_name="SE_TEST ";   /* Memory protection ignored!! */
int ap_id; /* Own ID */
int ev_id; /* Everest ID */


void wait_for_everest(void) {
int send[16];
	do {
		ev_id=appl_find("EVEREST ");
	}while(ev_id<0);
	
	send[0]=SE_INIT;
	send[1]=ap_id;
	send[2]=0;
	send[3]=_SEINIT|_SEQUIT|_SEACK|
	        _SETERMINATE|_SECLOSE|_SEOPEN|
	        _SEERRFILE|_SEERROR;
	        /* SE_TEST is able to send these messages */
	send[4]=0;
	send[5]=_ESQUIT|_ESOK|_ESACK|_ESMAKE|_ESCOMPILE;
	        /* SE_TEST is able to understand these messages */
	send[6]=SEPROTOVERSION;
	appl_write(ev_id,16,send);
}

ERRINFO errormessage={
	"EVEREST.DOC",
	"This planet has - or rather had - a problem, which was this: most "
  "of the people on it were unhappy for pretty much of the time. "
  "Many solutions were suggested for this problem, but most of these "
  "were largely concerned with the movements of small green pieces "
  "of paper, which is odd because on the whole it wasn't the small "
  "green pieces of paper that were unhappy.",
  0,
  1565,
  53
};


boolean do_menu(int titel, int eintr) {
int send[16];
boolean ready=false;
	if (titel==FILE) {
		switch(eintr) {
			case OPEN:
				send[0]=SE_OPEN;
				send[1]=ap_id;
				send[2]=0;
				*((char **)(send+3))="EVEREST.DOC"; /* Memory protection ignored!! */
				appl_write(ev_id,16,send);
				break;
			case CLOSE:
				send[0]=SE_CLOSE;
				send[1]=ap_id;
				send[2]=0;
				appl_write(ev_id,16,send);
				break;
			case EDQUIT:
				send[0]=SE_TERMINATE;
				send[1]=ap_id;
				send[2]=0;
				appl_write(ev_id,16,send);
				break;
			case ERROR:
				send[0]=SE_ERROR;
				send[1]=ap_id;
				send[2]=0;
				*((ERRINFO **)(send+3))=&errormessage;  /* Memory protection ignored!! */
				appl_write(ev_id,16,send);
				break;
			case ERRFILE:
				send[0]=SE_ERRFILE;
				send[1]=ap_id;
				send[2]=0;
				*((char **)(send+3))=".\\SE_TEST\\ERROR.TXT"; /* Memory protection ignored!! */
				*((char **)(send+5))=".\\SE_TEST\\SE_TEST.C"; /* Memory protection ignored!! */
				appl_write(ev_id,16,send);
				break;
			case QUIT:
				ready=true;
				break;
		}
	}
	return ready;
}

boolean do_keybd(int taststat, int tastcode) {
boolean ready=false;
	switch(tastcode & 0x00ff) {
		case 'Q'-'@':
			ready=do_menu(FILE,QUIT);
			break;
		case 'O'-'@':
			ready=do_menu(FILE,OPEN);
			break;
		case 'E'-'@':
			ready=do_menu(FILE,ERRFILE);
			break;
		case 'M'-'@':
			ready=do_menu(FILE,ERROR);
			break;
		case 'S'-'@':
			ready=do_menu(FILE,CLOSE);
			break;
		case 'X'-'@':
			ready=do_menu(FILE,EDQUIT);
			break;
	}
	return ready;
}

boolean do_messag(int *messag) {
int send[16];
boolean ready=false;
char alstr[800];
	switch(messag[0]) {
		case MN_SELECTED:
			ready=do_menu(messag[3],messag[4]);
			menu_tnormal(menu,messag[3],1);
			break;
		case ES_OK:
			break;
		case ES_ACK:
			break;
		case ES_QUIT:
			evnt_timer(2000,0);
			wait_for_everest();
			break;
		case ES_MAKE:
			form_alert(1,"[1][SE_TEST: |Message received: |ES_MAKE.][  OK  ]");
			break;
		case ES_COMPILE:
			form_alert(1,"[1][SE_TEST: |Message received: |ES_COMPILE.][ Continue ]");
			strcpy(alstr,"[0][SE_TEST: |Compile file: |");
			strcat(alstr,*(char **)(messag+3));
			strcat(alstr,"][  OK  ]");
			form_alert(1,alstr);
			break;
		case AV_PROTOKOLL:
			send[0]=VA_PROTOSTATUS;
			send[1]=ap_id;
			send[2]=0;
			send[3]=1;
			send[4]=send[5]=0;
			*((char * *)(send+6)) = app_name;
			appl_write(messag[1],16,send);
			break;
		case AV_SENDKEY:
			ready=do_keybd(messag[3],messag[4]);
			break;
		
	}
	return ready;
}


int main(void) {
int error=0,d;
boolean ready=false;
int messag[16],send[16];
int ms;
int taststat,tastcode;
	ap_id=appl_init();
	if (ap_id>0) {
		if (rsrc_load("SE_TEST.RSC")!=0) {
			rsrc_gaddr(R_TREE,MENU,&menu);
			menu_bar(menu,1);
			wait_for_everest();
			do {
				ms=evnt_multi( MU_KEYBD|MU_MESAG, 0,0,0,0,0,0,0,
				                  0,0,0,0,0,0,
				                  messag,0,0, &d,&d,&d,&taststat,&tastcode,&d);
				if (ms & MU_KEYBD) {
					ready=do_keybd(taststat,tastcode);
				}
				if (ms & MU_MESAG) {
					ready=do_messag(messag);
				}
			}while(!ready);
			rsrc_free();
		}else
			error=-1;
		send[0]=SE_QUIT;
		send[1]=ap_id;
		send[2]=0;
		appl_write(ev_id,16,send);
		appl_exit();
	}else
		error=-1;
	return error;
}
