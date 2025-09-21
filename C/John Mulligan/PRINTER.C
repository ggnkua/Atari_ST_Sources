#include <string.h>      
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include <stdio.h>
#include "printer.h"

 int retn;   /* return value for form_do calls */
 int menu_id;
 int event;
 int ret;

extern int	gl_apid;
int	gl_hchar;
int	gl_wchar;
int	gl_wbox;
int	gl_hbox;	/* system sizes */
int msgbuff[8];	/* event message buffer */

int 	phys_handle;	/* physical workstation handle */
int 	handle;		/* virtual workstation handle */

int	xdesk,ydesk,hdesk,wdesk;
int	xold,yold,hold,wold;
int	xwork,ywork,hwork,wwork;	/* desktop and work areas */

int	msgbuf[8];	/* event message buffer */
int	keycode;	/* keycode returned by event-keyboard */
int	mx,my;		/* mouse x and y pos. */
int	butdown;	/* button state tested for, UP/DOWN */

int	contrl[12];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];	/* storage wasted for idiotic bindings */

int work_in[11];	/* Input to GSX parameter array */
int work_out[57];	/* Output from GSX parameter array */
int pxyarray[10];	/* input point array */
int test;           /* result from char output to printer */
#define TRUE 1
#define FALSE 0

/****************************************************************/
/* open virtual workstation					*/
/****************************************************************/
open_vwork()
{
int i;
	for(i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	handle=phys_handle;
	v_opnvwk(work_in,&handle,work_out);
}

main()
{
	OBJECT *printer_dialog;			      /* pointer to midi tree       */
	char string1[40], string2[40];       /* storage for ted_info struct */
	int base, i,  count, place, cnt;  /* variable for base conversion */
	char **ptr, output, *str;
              int     x;
	  
	appl_init();
	phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
	open_vwork();
	menu_id = menu_register(gl_apid,"  Printer_Out");     /* I.D. for .ACC */
    base = 10;
    
    
/* load resource file */ 
  
	if (!rsrc_load("PRINTER.RSC")) {
		form_alert(1, "[0][Cannot find PRINTER.RSC file...][OK]"); }

 
while (TRUE)  { 					  /* forever loop for evnt_multi */
		event = evnt_multi(MU_MESAG,
			1,1,butdown,
			0,0,0,0,0,
			0,0,0,0,0,
			msgbuf,0,0,&mx,&my,&ret,&ret,&keycode,&ret);
			
       

       if (msgbuf[0] == AC_OPEN)  {	
       	  if (msgbuf[4] == menu_id)
 {      	 								/* start message handle */
	rsrc_gaddr(0, PRINTER, &printer_dialog);
	((TEDINFO *)printer_dialog[TEXT].ob_spec)->te_ptext = string1;
	((TEDINFO *)printer_dialog[TEXT].ob_spec)->te_txtlen = 40;
	do_dialog(printer_dialog);
	if(retn == B1)						            /* send ? (Ok button)      */
   	      {     cnt = 1;
	          count = 0;
              place = 0;
	           base = 10;
	           test = TRUE;
	       while(test==TRUE) {    
	                     switch(string1[count]) {
	          
	            case ',' :  str=&string1[place];
	                        output = (char) strtol(str,ptr,base);
	                        if(!Cprnout(output)) {
	                           form_alert(1, "[0][Device not responding.|Check connections...][OK]"); 
	                           test=FALSE;          }
	                        count++;
	                        place=count;
	                        break;
	                        
	            case '\0' : if(count==0) break;
	                        str=&string1[place];
	                        output = (char) strtol(str,ptr,base);
	                        if(!Cprnout(output)) {
	                           form_alert(1, "[0][Device not responding.|Check connections...][OK]"); 
	                           test=FALSE;          }
	                 }
            	if (string1[count]=='\0')  
	                         break; 
	            count++;  
	                     }
	                       
 
	  } 
	}         			            
   }     
 }
}
do_dialog(printer_dialog)
OBJECT *printer_dialog ;
{
	int cx, cy, cw, ch ;
    graf_mouse(M_OFF,0x0L);
	form_center(printer_dialog, &cx, &cy, &cw, &ch);
	form_dial(FMD_START, 0,0,0,0, cx, cy, cw, ch);
	objc_draw(printer_dialog, 0, 10, cx, cy, cw, ch);
    graf_mouse(M_ON,0x0L);
	retn=form_do(printer_dialog, 0);
	form_dial(FMD_FINISH, 0,0,0,0,cx, cy, cw, ch);
	objc_change(printer_dialog,retn,0,cx,cy,cw,ch,0,0);
}
 
 
 
 
 
 
