/************************************************/
/*						*/
/* 	 Display-Acc fÅr Dumps auf DeskJet 	*/
/*	      	     in Turbo C 		*/
/* 		Sevo Stille 4.12.90		*/
/*	     					*/
/************************************************/

/* includes */
#include <aes.h>
#include <tos.h>

/* defines */
#define PRINTER 3

/* Funktionen */
void doalert(void);
 
/*Variablen:*/
int appl_id;
int menu_id;
int msg_buf[8];
extern int _app;
char display_on[]="&s0CY";
char display_off[]="Z";

/****************************************/
/*	Initialisierung  als ACC 	*/
/*	und Hauptschleife		*/
/****************************************/

int main(void)
{
	appl_id = appl_init();		/* ohne Erfolgskontrolle! */
	if(_app == 0)
	{
		menu_id = menu_register(appl_id,"  DeskJet Display  ");

		if (menu_id == -1)			/* dann halt nicht */
		{
			form_error(2);
			return -1;
		} 
	}   

	while (_app==0)			/* wenns als ACC lÑuft	*/
	{				/* die endlose Event-Schleife	*/
		evnt_mesag(msg_buf);
					
		if ((msg_buf[0]==AC_OPEN)&&(msg_buf[4]==menu_id))
		{
			doalert();
		}
	}   
	doalert();			/* sonst nur einmal	*/ 
	appl_exit();			/* und adieu		*/
	return 0;
} 

/************************************************/
/* 	Alertbox darstellen und auswerten	*/
/************************************************/

void doalert(void)
{
 switch (form_alert(2,"[0][|   Set Display Mode    |    for HP DeskJet     | ][ ON | OFF ]")) 
	{
	case 1: 			
		if (Cprnos()) Fwrite(PRINTER,7,display_on);break;	/* Cprnos nÅtzt beim DeskJet allerdings nur wenig	*/
	case 2: 
		if (Cprnos())Fwrite(PRINTER,2,display_off);break;
	 }       	
}	 

