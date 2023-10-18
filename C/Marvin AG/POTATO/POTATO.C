#include <aes.h>
#include <string.h>
#include "potato.h"

#define POTATO	"  Potato      V1.1"

extern void       mrsrc_load(char *rsc);                      
extern char       rsc_datei[];
extern void cdecl rom_adr(int x);
extern int 	  romsel;
extern int	  _app;

void potato(void)
/***************/
{
int     which,pre1,pre2,fo_x,fo_y,fo_w,fo_h;
OBJECT  *tree_addr;

rsrc_gaddr(0, ROMPORT, &tree_addr);			/* pre1select */
switch(romsel)			
   {case 0:  tree_addr[pre2=RROM0].ob_state = 
   		     tree_addr[pre1=ROM0].ob_state = SELECTED;break;
    case 1:  tree_addr[pre2=RROM1].ob_state = 
             tree_addr[pre1=ROM1].ob_state = SELECTED;break;
    case 2:  tree_addr[pre2=RROM2].ob_state = 
             tree_addr[pre1=ROM2].ob_state = SELECTED;break;
    default: tree_addr[pre2=RROM3].ob_state = 
             tree_addr[pre1=ROM3].ob_state = SELECTED;}

form_center(tree_addr,&fo_x,&fo_y,&fo_w,&fo_h);		/* Dialog zentrieren */
form_dial(FMD_START,0,0,1,1,fo_x,fo_y,fo_w,fo_h);	/* retten	     */
objc_draw(tree_addr,0,8,fo_x,fo_y,fo_w,fo_h);		/* zeichnen          */
which = form_do(tree_addr, -1) & 0xff;			/* editieren 	     */
objc_change(tree_addr, which, 0, fo_x,fo_y,fo_w,fo_h, NORMAL,1); /* deselect */
objc_change(tree_addr, pre1 , 0, fo_x,fo_y,fo_w,fo_h, NORMAL,1);
objc_change(tree_addr, pre2 , 0, fo_x,fo_y,fo_w,fo_h, NORMAL,1);
form_dial(FMD_FINISH,0,0,1,1,fo_x,fo_y,fo_w,fo_h);	/* redraw	     */

  switch(which)						/* Auswahl 	     */
    {case RROM0:
     case ROM0:	rom_adr(0);break;
     case RROM1:
     case ROM1:	rom_adr(1);break;
	     case RROM2:
     case ROM2:	rom_adr(2);break;
     case RROM3:
     case ROM3:	rom_adr(3);break;
    }
}

void romname(void)
/****************/
{
OBJECT  *tree_addr;
int	i,j,k;

rsrc_gaddr(0,ROMPORT,&tree_addr);	/* Module auslesen 	*/
for(i=0;i<4;i++)			/* 4 Module testen	*/
 {rom_adr(i);				/* Anw„hlen		*/
  if(*(long*)0xfa0000 == 0xABCDEF42)	/* Magic testen		*/
    {
    switch(i)
      {case 0: k = ROM0;break;
       case 1: k = ROM1;break;
       case 2: k = ROM2;break;
       case 3: k = ROM3;break;}
    strncpy(tree_addr[k].ob_spec.free_string,(char*)0xfa0018,8); /* Name */
    for(j=0;j<8;j++)			/* Extension suchen und l”schen  */
      if(*(tree_addr[k].ob_spec.free_string+j)=='.')
         *(tree_addr[k].ob_spec.free_string+j)=0;
    }
 }
}


void  main(void )
/**************/
{
int	ap_id,msg[16];

if ((ap_id = appl_init()) < 0)return;	/* Appl. Handle holen 	*/
if (!_app) menu_register(ap_id,POTATO); /* Meneintrag 		*/
mrsrc_load(rsc_datei);			/* Resource		*/

romname();				/* Modulnamen lesen 	*/

if(_app)
   potato();				/* Bei Programmaufruf   */
else 
   for(;;){				/* Endlosschleife  	*/
      evnt_mesag(msg);			/* Auf Aufruf warten    */
      if(msg[0] == AC_OPEN)potato();	/* Menaufruf		*/
   }

appl_exit();
}

