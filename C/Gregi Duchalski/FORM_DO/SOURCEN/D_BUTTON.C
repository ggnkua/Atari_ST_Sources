/****************************************************************
*  Userdefined Objects in GFA-BASIC 3.x							*
*  (c)8/92 Gregi Duchalski										*
*																*
*  last change 03.08.92											*
*      															*
*  BUTTONS/STRINGS zeichnen							(Tabweite 4)*
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

	WORD 	xy[8],xy_clip[4],v_handle,width,x,y,bw,bh;
	USRBLK	*usrblk;
		
	usrblk=(USRBLK*) parmblk->pb_parm; 
	
	v_handle=usrblk->u_handle; /* Bildschirmhandle */
	bw=usrblk->u_wchar;		   /* Zeichenbreite    */
	bh=usrblk->u_hchar;        /* Zeichenh”he      */

/* Clipping setzen */
	
	xy_clip[0]=parmblk->pb_xc;
	xy_clip[1]=parmblk->pb_yc;
	xy_clip[2]=xy_clip[0]+parmblk->pb_wc-1;
	xy_clip[3]=xy_clip[1]+parmblk->pb_hc-1;

	vs_clip(v_handle,1,xy_clip);
	
/* Rahmen-Koordinaten setzen... */
	
	xy[0]=parmblk->pb_x;
	xy[1]=parmblk->pb_y;
	xy[2]=xy[0]+parmblk->pb_w-1;
	xy[3]=parmblk->pb_y+parmblk->pb_h-1;
	
/* Rahmendicke bei... */
	
	if (OB_FLAGS(parmblk->pb_tree,parmblk->pb_obj) & SELECTABLE)
		width=1;	    /* ...Button */
	
	else             
		width=0;        /* ...String */

	if (OB_FLAGS(parmblk->pb_tree,parmblk->pb_obj) & EXIT)
		width++;        /* ...EXIT-Button */
	
	if (OB_FLAGS(parmblk->pb_tree,parmblk->pb_obj) & DEFAULT)
		width++;		/* ...DEFAULT-Button */

/* Wenn's einen Rahmen gibt, zeichnen... */
	
	if (width>0)
	{
		vswr_mode(v_handle,MD_REPLACE);		/* Schreibmodus  */
		vsf_perimeter(v_handle,1);			/* Umrandung ein */
		vsf_interior(v_handle,FIS_HOLLOW);  /* Flltyp       */
		vsf_color(v_handle,1);              /* Fllfarbe     */
		
		xy[0]-=width;
		xy[1]-=(width+1);
		xy[2]+=width;
		xy[3]+=(width+1);
		
		for (x=width;x>0;x--)
		{
			v_bar(v_handle,xy);
			xy[0]++;
			xy[1]++;
			xy[2]--;
			xy[3]--;
		}

	}

/* Objekt selektieren */
	
	if (parmblk->pb_currstate & SELECTED)
	{
		vswr_mode(v_handle,MD_XOR);
		vsf_perimeter(v_handle,0);
     	vsf_interior(v_handle,FIS_SOLID);
		v_bar(v_handle,xy);
	} 

/* Text ausgeben */
	
	x=(WORD) (xy[0]+xy[2]-(bw*strlen(usrblk->u_text)))/2+1;
    y=xy[1]+bh-(bh/8); 
    
	vst_alignment(v_handle,0,0,&bh,&bh); 	/* Ausrichtung Basislinie */
	vst_effects(v_handle,0);				/* Kein Attribut 		  */
	v_gtext(v_handle,x,y,usrblk->u_text);
	
/* Wenn es einen unterstr. Buchst. gibt... */
	
	if (usrblk->u_pos!=0)
	{
		xy[0]=x+(usrblk->u_pos-1)*bw;
		xy[1]=xy[3]-1; 
		xy[2]=xy[0]+bw-2;
		xy[3]=xy[1];
		
		v_pline(v_handle,2,xy);
	}
	
	
/* Clipping aus, Schreibmodus zurck */
	
	vswr_mode(v_handle,MD_REPLACE);
	vs_clip(v_handle,0,xy_clip);
	
	return (parmblk->pb_currstate); 
}
