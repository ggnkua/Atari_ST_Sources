/****************************************************************
*  Userdefined Objects in GFA-BASIC 3.x							*
*  (c)8/92 Gregi Duchalski										*
*																*
*  last change 04.08.92											*
*      															*
*  UNTERSTR. TEXT zeichnen							(Tabweite 4)*
****************************************************************/

#include <portab.h>
#include <aes.h>
#include <vdi.h>
#include <string.h>

WORD cdecl button(PARMBLK *parmblk)
{
/* Diese Struktur wird im BASIC angelegt... */
	
	typedef struct
	{
		WORD	u_handle;  /* Bildschirmhandle V~H 		*/
		BYTE	*u_text;   /* Adresse des Textes     	*/
		BYTE	u_wchar;   /* Breite eines Zeichens		*/
		BYTE	u_hchar;   /* H”he eines Zeichens		*/
		WORD	u_pos;     /* Pos. d. unterstr. Buchst.	*/
	}USRBLK;

	WORD 	xy_clip[4],v_handle,x,y;
	USRBLK	*usrblk;
		
	usrblk=(USRBLK*) parmblk->pb_parm; 
	
	v_handle=usrblk->u_handle; /* Bildschirmhandle */

/* Clipping setzen */
	
	xy_clip[0]=parmblk->pb_xc;
	xy_clip[1]=parmblk->pb_yc;
	xy_clip[2]=xy_clip[0]+parmblk->pb_wc-1;
	xy_clip[3]=xy_clip[1]+parmblk->pb_hc-1;

	vs_clip(v_handle,1,xy_clip);
	
/* Text ausgeben */
	
	x=parmblk->pb_x;
    y=parmblk->pb_y+usrblk->u_hchar-(usrblk->u_hchar/8)-1; 
    
	vst_effects(v_handle,8);        /* Unterstr. ein */
	v_gtext(v_handle,x,y,usrblk->u_text);
	vst_effects(v_handle,0);		/* Unterstr. aus */
	
/* Clipping aus, Schreibmodus zurck */
	
	vs_clip(v_handle,0,xy_clip);
	
	return (parmblk->pb_currstate); 
}
