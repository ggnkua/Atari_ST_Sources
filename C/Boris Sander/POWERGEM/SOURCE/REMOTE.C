/* ---------------------------------------------------------------------- */
/* Accessory zum Senden einer Nachricht                                   */
/* ---------------------------------------------------------------------- */
#include <aes.h>
#include <stdio.h>
#include "remote.h"

#define OWNMSG 0x500   /* Neuer Nachrichtentyp */

/* ---------------------------------------------------------------------- */
/* Prototypen                                                             */
/* ---------------------------------------------------------------------- */
void main(void);
void send_message(void);
void event_loop(void);

/* ---------------------------------------------------------------------- */
/* Globale Variablen                                                      */
/* ---------------------------------------------------------------------- */
int    ap_id, 
       menu_id,
       partner_id;                       
int    show_flag = 0;
OBJECT *box;


/* ---------------------------------------------------------------------- */
/* Ereignisschleife                                                       */
/* ---------------------------------------------------------------------- */
static void event_loop(void)
{
   int msgbuff[8];

   for(;;)
   {
       evnt_mesag(msgbuff);
	   
	   if ((msgbuff[0] & AC_OPEN) && (msgbuff[4] == menu_id))
      	   send_message();
   }       
}	


/* ---------------------------------------------------------------------- */
/* Initialisation                                                         */
/* ---------------------------------------------------------------------- */
void main(void)
{
   ap_id = appl_init();
   if(ap_id != -1)
   {
       menu_id = menu_register(ap_id, "  PowerGEM Sender" );
	   rsrc_load("REMOTE.RSC");
	   rsrc_gaddr(0, SETMSG, &box);
	   event_loop();
   }
}


/* ---------------------------------------------------------------------- */
/* Dialog darstellen und Nachricht verschicken                            */
/* ---------------------------------------------------------------------- */
void send_message(void)
{
	int x,y,w,h, exit;
	int msgbuff[8] = {0,0,0,0,0,0,0,0}; /* Message-Pipe */
	char message[37];                   /* Nachrichten-Buffer */
	
	partner_id = appl_find("DEMO    "); /* AES-ID des Demo-Programms */
	if (partner_id < 0)                 /* nicht aktiv -> Abbruch */
	{
		form_alert(1,"[3][PowerGEM-Demo nicht aktiv!][ Abbruch ]");
		return;
	}

	box[NACHRICH].ob_spec.tedinfo->te_ptext = message; /* G_TEXT setzen */
	box[NACHRICH].ob_spec.tedinfo->te_txtlen = 37;

	/* Dialogbox aufbauen ---------------- */
	wind_update(BEG_UPDATE);     
	form_center(box, &x, &y, &w, &h);
	form_dial(FMD_START, x,y,w,h, x,y,w,h);
	objc_draw(box, 0, 8, x,y,w,h);

	exit = form_do(box, NACHRICH);
	
	box[exit].ob_state &= ~SELECTED;
	form_dial(FMD_FINISH, x,y,w,h, x,y,w,h);
	wind_update(END_UPDATE);

	if (exit & SEND)  
	{	
		msgbuff[0] = OWNMSG;  /* Message-Pipe init. */
		msgbuff[1] = ap_id;
		msgbuff[2] = 37;

		appl_write(partner_id, 16, msgbuff); /* Neuer MSG-Typ senden */ 
		appl_write(partner_id, 37, message); /* Nachricht an DEMO schicken*/
	}
}
		