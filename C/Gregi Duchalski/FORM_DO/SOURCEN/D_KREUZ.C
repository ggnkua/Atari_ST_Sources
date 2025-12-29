 /***************************************************************
 *  Userdefined Objects in GFA-BASIC 3.x                        *
 *  (c)8/92 Gregi Duchalski                                     *
 *																*
 *  last change 03.08.92                                        *
 *      														*
 *  ANKREUZ-BUTTON zeichnen                                     *
 ***************************************************************/

#include <portab.h>
#include <aes.h>
#include <vdi.h>

WORD cdecl dcrbutton(PARMBLK *parmblk)
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

	WORD 	xy[4],xy_clip[4],v_handle,x,y,bw,bh;
	USRBLK	*usrblk;
		
	usrblk=(USRBLK*) parmblk->pb_parm; 
	
	v_handle=usrblk->u_handle; /* Bildschirmhandle */
	bw=usrblk->u_wchar;		   /* Zeichenbreite    */
	bh=usrblk->u_hchar;        /* Zeichenh”he      */

  
/* Clipping setzen */

	xy_clip[0]=parmblk->pb_xc;
	xy_clip[1]=parmblk->pb_yc;
	xy_clip[2]=parmblk->pb_xc+parmblk->pb_wc-1;
	xy_clip[3]=parmblk->pb_yc+parmblk->pb_hc-1;

	vs_clip(v_handle,1,xy_clip);

/* Rahmen zeichnen */

	xy[0]=parmblk->pb_x+2;
	xy[1]=parmblk->pb_y;
	xy[2]=xy[0]+bw*2-2;
	xy[3]=xy[1]+bh-2;
  
	vsf_color(v_handle,1);				  /* Fllfarbe         */
	vsl_color(v_handle,1);                /* Linienfarbe 	   */
	vsf_interior(v_handle,FIS_HOLLOW);    /* Fllmuster setzen */
	vsf_perimeter(v_handle,1);            /* Umrandung ein     */
  
	v_bar(v_handle,xy);
  
/* Selektiert, also mit Kreuz versehen */

	if (parmblk->pb_currstate & SELECTED)
	{
		v_pline(v_handle,2,xy);
		x=xy[0];
		xy[0]=xy[2];
		xy[2]=x;
		v_pline(v_handle,2,xy);
	}
	
	
/* Text ausgeben */
	
	x=parmblk->pb_x+2+bw*3;
    y=xy[1]+bh-(bh/8)-1;
    
	v_gtext(v_handle,x,y,usrblk->u_text);
	
/* Wenn es einen unterstr. Buchst. gibt... */
	
	if (usrblk->u_pos!=0)
	{
		xy[0]=x+(usrblk->u_pos-1)*bw;
		xy[1]=++xy[3]; 
		xy[2]=xy[0]+bw-1;
		
		v_pline(v_handle,2,xy);
	}
	
/* Clipping aus */
	
	vs_clip(v_handle,0,xy_clip);
  
	return (parmblk->pb_currstate & ~SELECTED);
}

