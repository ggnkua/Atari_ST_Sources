/**********************************************/
/*																						*/
/*	Clicker.C								fÅr Clicker.ACC		*/
/*																						*/
/*	Simuliert einen Mausklick beim Wechsel		*/
/*	in ein anderes Fenster										*/
/*																						*/
/*	V1.0		 2. 7.91		Laser C								*/
/*	V1.1		22. 8.91		Pure C								*/
/*	V1.2		 5. 1.92		ST Computer						*/
/*																						*/
/*	Written by Ulrich Mast 										*/
/*																						*/
/**********************************************/
#include		<tos.h>
#include		<aes.h>
/**********************************************/
#define 		FALSE					0
#define 		TRUE					1

#define 		WAIT_LOOP			500
#define 		WAIT_CLOSE		4000

#define			TOP_WINDOW
#undef			SEND_MESSAGE
#undef			ASM_CLICK
/**********************************************/
void				click_main(void);
void				do_click(int);
void				asm_init(void);
long				asm_click(void);
/**********************************************/
int 				ap_id;

char *alert[] =
{
"[1][ | Auto Window Clicker | written 1992 by Uli ][Off|On]",
"[3][ | Auto Window Clicker | is an Accessory! ][Quit]"
};
/**********************************************/
void
main()
{
	EVENT	event;
	int 	active=TRUE;
	
	ap_id=appl_init();
	
	if(!_app)
	{
		menu_register(ap_id,"  Clicker ");
		
#ifdef ASM_CLICK

		asm_init();

#endif
		
		while(TRUE)
		{
			event.ev_mflags=MU_MESAG|MU_TIMER;
			event.ev_mtlocount=WAIT_LOOP;
			event.ev_mthicount=0;
			
			EvntMulti(&event);
			
			if(event.ev_mwich & MU_MESAG)
			{
				if(event.ev_mmgpbuf[0]==AC_OPEN)
					if(form_alert(active?2:1,alert[0])==2)
						active=TRUE;
					else
						active=FALSE;
				
				if(event.ev_mmgpbuf[0]==AC_CLOSE)
					evnt_timer(WAIT_CLOSE,0);
			}
			if(event.ev_mwich & MU_TIMER)
				if(active)
					click_main();
		}
	}
	form_alert(1,alert[1]);
	appl_exit();
}
/**********************************************/
void
click_main()
{
	int 	wind,top;
	int 	d;
	int 	x,y;
	
	wind_get(0,WF_TOP,&top,&d,&d,&d);
	if(top>0)
	{
		evnt_button(1,0,2,&x,&y,&d,&d);
		wind=wind_find(x,y);
		if(wind>0)
			if(wind!=top)
				do_click(wind);
	}
}
/**********************************************/
void
do_click(int wind)
{

#ifdef TOP_WINDOW

	wind_set(wind,WF_TOP,0,0,0,0);
														/* Fenster aktiv	*/
#endif

#ifdef SEND_MESSAGE

	int 	msg[8];
	
	msg[0]=WM_TOPPED;				/* Message					*/
	msg[1]=ap_id;						/* Unsere ID				*/
	msg[2]=0;								/* keine öberlÑnge	*/
	msg[3]=wind;						/* Fenster ID				*/	
	msg[4]=0;
	msg[5]=0;
	msg[6]=0;
	msg[7]=0;
	
	appl_write(0,16,msg);				/* -> APP 0			*/

#endif

#ifdef ASM_CLICK

	Supexec(asm_click);

#endif

}
/**********************************************/
