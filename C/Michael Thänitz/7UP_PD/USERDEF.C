/* benutzerdefinierte AES Objekte */
/*****************************************************************************
*
*											  7UP
*									  Modul: USERDEF.C
*                             (c) by mt '90
*
*****************************************************************************/

#define RSC_CREATE 1

#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>

#include "windows.h"
#include "7up.h"

#include "language.h"
#include "toolbar.h"

#define DESK		0

#define DRBUTTON	 0x0001					 /* user defined objects */
#define DCHECKBOX  0x0002
#define DALTBUTTON 0x0003
#define DULINE	    0x0004
#define DEAR		 0x0005
#define DCIRCLE	 0x0006
#define DDLINE	    0x0007
#define DSELFONT   0x0008
#define D3DBOX     0x0009
#define DHEADER	 0x0020
#define DFONT	    0x0080
#define DTABBAR    0x00FF

#define FLAGS9  	 0x0200
#define FLAGS10 	 0x0400
#define FLAGS14    0x4000
#define FLAGS15    0x8000


int threedee; /* lange šberschriftenunterstreichung */
int dialbgcolor=WHITE;
int actbutcolor=WHITE;

#if MSDOS
EXTERN PARMBLK	*fardr_start	 _((VOID));
EXTERN VOID		fardr_end		 _((WORD state));
#endif

extern int userhandle;
extern int boxh,boxw,norm_point,small_point;
extern int xdesk,ydesk,wdesk,hdesk;

extern OBJECT *userimg;

#if MSDOS
LOCAL WORD		 draw_checkbox	_((VOID));
LOCAL WORD		 draw_radio		_((VOID));
LOCAL WORD		 draw_font		_((VOID));
LOCAL WORD		 draw_uline		_((VOID));
LOCAL WORD		 draw_dline		_((VOID));
LOCAL WORD		 draw_selfont	_((VOID));
LOCAL WORD		 draw_3Dbox		_((VOID));
LOCAL WORD		 draw_tabbar	_((VOID));
#else
LOCAL WORD CDECL draw_checkbox	_((FAR PARMBLK *pb));
LOCAL WORD CDECL draw_radio	 _((FAR PARMBLK *pb));
LOCAL WORD CDECL draw_font		 _((FAR PARMBLK *pb));
LOCAL WORD CDECL draw_uline		_((FAR PARMBLK *pb));
LOCAL WORD CDECL draw_dline		_((FAR PARMBLK *pb));
LOCAL WORD CDECL draw_selfont		_((FAR PARMBLK *pb));
LOCAL WORD CDECL draw_3Dbox		_((FAR PARMBLK *pb));
LOCAL WORD CDECL draw_tabbar		_((FAR PARMBLK *pb));
#endif

LOCAL  USERBLK	  font_blk;		 /* used for 7UP fonts */
LOCAL  USERBLK	  ear_blk;
LOCAL  USERBLK	  circle_blk;
LOCAL  USERBLK	  dline_blk;
LOCAL  USERBLK	  selfont_blk;
LOCAL  USERBLK	  threeDbox_blk;

LOCAL VOID set_clip   (WORD handle, WORD x, WORD y, WORD w, WORD h);
LOCAL VOID reset_clip (WORD handle, WORD x, WORD y, WORD w, WORD h);

/*********************************************************************/

LOCAL void vdi_fix (FDB *pfd, void *theaddr, int wb, int h)
{
  pfd->mp  = theaddr;
  pfd->fwp = wb << 3;
  pfd->fh  = h;
  pfd->fww = wb >> 1;
  pfd->np  = 1;
} /* vdi_fix */

LOCAL void vdi_trans (int *saddr, int swb, int *daddr, int dwb, int h)
{
  MFDB src, dst;

  vdi_fix (&src, saddr, swb, h);
  src.ff = TRUE;

  vdi_fix (&dst, daddr, dwb, h);
  dst.ff = FALSE;

  vr_trnfm (userhandle, &src, &dst);
} /* vdi_trans */

LOCAL void trans_gimage (OBJECT *tree, int obj)
{
  ICONBLK *piconblk;
  BITBLK  *pbitblk;
  int	    *taddr;
  int	    wb, hl, type;

  type = (tree [obj].ob_type & 0xFF);
  if (type == G_ICON)
  {
	 piconblk = (ICONBLK *)tree [obj].ob_spec;
	 taddr	 = piconblk->ib_pmask;
	 wb		 = piconblk->ib_wicon;
	 wb		 = wb >> 3;
	 hl		 = piconblk->ib_hicon;
	 vdi_trans (taddr, wb, taddr, wb, hl);
	 taddr = piconblk->ib_pdata;
  } /* if */
  else
  {
	 pbitblk = (BITBLK *)tree [obj].ob_spec;
	 taddr	= pbitblk->bi_pdata;
	 wb		= pbitblk->bi_wb;
	 hl		= pbitblk->bi_hl;
  } /* else */
  vdi_trans (taddr, wb, taddr, wb, hl);
} /* trans_gimage */

/*****************************************************************************/
LOCAL VOID set_clip (handle, x, y, w, h)
WORD handle, x, y, w, h;

{
  WORD pxy [4];

  pxy [0] = x;
  pxy [1] = y;
  pxy [2] = x + w - 1;
  pxy [3] = y + h - 1;

  vs_clip (handle, TRUE, pxy);
} /* set_clip */

LOCAL VOID reset_clip (handle, x, y, w, h)
WORD handle, x, y, w, h;

{
  WORD pxy [4];

  pxy [0] = x;
  pxy [1] = y;
  pxy [2] = x + w - 1;
  pxy [3] = y + h - 1;

  vs_clip (handle, FALSE, pxy);
} /* set_clip */

/*****************************************************************************/
/* Zeichnet tastaturbedienbare Exitbuttons															 */
/*****************************************************************************/

#define odd(i) ((i)&1)

#if MSDOS
LOCAL WORD draw_altbutton ()
{
  PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_altbutton (PARMBLK *pb)
{
#endif

  WORD	 ob_x, ob_y, ob_width, ob_height;
  BOOLEAN selected, changed;
  WORD	 pxy [10];
  int	    i,cx,cy,cw,ch,ret,l_width;
  char	 *cp,string[32];

  ob_x		= pb->pb_x+2;
  ob_y		= pb->pb_y+2;
  ob_width  = pb->pb_w-4;
  ob_height = pb->pb_h-4;

  selected  = pb->pb_currstate & SELECTED;
  changed	= (pb->pb_currstate ^ pb->pb_prevstate) & SELECTED;

  vsl_type (userhandle, SOLID);
  vsl_ends (userhandle, SQUARED, SQUARED);
  vsl_width (userhandle, l_width=1);
  vsl_color (userhandle, BLACK);
  vsf_interior(userhandle,FIS_SOLID); /* Fllung */
  vst_alignment(userhandle,0,5,&ret,&ret); /* Ausrichtung */
  vswr_mode (userhandle, MD_REPLACE);

  if(pb->pb_tree[pb->pb_obj].ob_flags & EXIT)
  {
	  l_width=2;
  }
  if(pb->pb_tree[pb->pb_obj].ob_flags & DEFAULT)
  {
	  l_width=3;
  }

  set_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

  strcpy(string,(char *)((TEDINFO *)pb->pb_parm)->te_ptext);
  if((cp=strchr(string,'_'))!=NULL)
	  strcpy(cp,&cp[1]);

  if(threedee && !strcmp(KHILFE,string)) /* Hilfeknopf ein Pixel breit */
  	  l_width=1;
  	
  if (! changed) /* it was an objc_draw, so draw button */
  {
	 for(i=0; i<l_width; i++)
	 {
		 pxy [0] = ob_x -i;
		 pxy [1] = ob_y -i;
		 pxy [2] = ob_x + ob_width  - 1 +i;
		 pxy [3] = pxy [1];
		 pxy [4] = pxy [2];
		 pxy [5] = ob_y + ob_height - 1 +i;
		 pxy [6] = pxy [0];
		 pxy [7] = pxy [5];
		 pxy [8] = pxy [0];
		 pxy [9] = pxy [1];
		 v_pline (userhandle, 5, pxy);
	 }
	 pxy[0]=ob_x+1;
	 pxy[1]=ob_y+1;
	 pxy[2]=ob_x+ob_width-2;
	 pxy[3]=ob_y+ob_height-2;
	 if(selected)
	 {
		vsf_color(userhandle,BLACK);		  /* farbe  */
		vst_color(userhandle,WHITE);		  /* farbe  */
	 }
	 else
	 {
	 	if(threedee) /*3D*/
			vsf_color(userhandle,actbutcolor);		  /* farbe  */
		else
			vsf_color(userhandle,WHITE);		  /* farbe  */
		vst_color(userhandle,BLACK);		  /* farbe  */
	 }
	 vr_recfl(userhandle,pxy);	  /* weižes rechteck in workspace */

    vst_color (userhandle, BLACK);
	 vswr_mode (userhandle, MD_TRANS); /*3D (XOR) */

	 if(((TEDINFO *)pb->pb_parm)->te_font==IBM)
	 {
		 vst_point(userhandle,norm_point,&ret,&ret,&cw,&ch);
		 cx=pb->pb_x+(pb->pb_w-strlen(string)*cw)/2;
		 cy=pb->pb_y+(pb->pb_h-ch)/2-1;
		 if(boxh<=8)
		 	cy++;
		 if(threedee) /* 3D-Look */
		 {
	       if(selected)
	       {
	       	cx++;
	       	cy++;
	       }
       }
		 if(threedee) /* 3D-Look */
			 v_gtext(userhandle,cx,cy,string);
		 else
			 v_gtext(userhandle,cx,cy+1,string); /* ein Pixel tiefer */
		 if(cp)
		 {
			 pxy[0]=cx + (cp-string)*cw;
			 pxy[1]=cy + ch - 1;
			 pxy[2]=cx + (cp-string+1L)*cw - 1;
			 pxy[3]=cy + ch - 1;
			 vsl_color (userhandle, BLACK);
			 if(boxh<=8)
			 {
				 pxy[1]++;
				 pxy[3]++;
			 }
			 if(!threedee) /* kein 3D-Look */
			 {
				 pxy[1]++;
				 pxy[3]++;
			 }
			 v_pline(userhandle,2,pxy);
		 }
	 }
	 else
	 {
		 vst_height(userhandle,small_point,&ret,&ret,&cw,&ch);
		 cx=pb->pb_x+(3*cw);
		 cy=pb->pb_y+((boxh>8)?SMALL:SMALL/2-1)-1;
		 if(threedee) /* 3D-Look */
		 {
	       if(selected)
	       {
	       	cx++;
	       	cy++;
	       }
       }
		 v_gtext(userhandle,cx,cy,string);
		 if(cp)
		 {
			 pxy[0]=cx + (cp-string)*cw;
			 pxy[1]=cy + ch - 4;
			 pxy[2]=cx + (cp-string+1L)*cw - 1;
			 pxy[3]=cy + ch - 4;
			 vsl_color (userhandle, BLACK);
			 v_pline(userhandle,2,pxy);
		 }
	 }
	 vswr_mode (userhandle, MD_REPLACE);
	 if(threedee) /* 3D-Look */
	 {
		 vsl_color (userhandle, WHITE);/* oben, links weiž */
		 pxy[0]=ob_x+2-1;
		 pxy[1]=ob_y+ob_height-2-1;
		 pxy[2]=ob_x+2-1;
		 pxy[3]=ob_y+2-1;
		 pxy[4]=ob_x+ob_width-2-1;
		 pxy[5]=ob_y+2-1;
		 v_pline (userhandle, 3, pxy); 

		 vsl_color (userhandle, LBLACK); 
		 pxy[0]=ob_x+2;
		 pxy[1]=ob_y+ob_height-2;
		 pxy[2]=ob_x+ob_width-2;
		 pxy[3]=ob_y+ob_height-2;
		 pxy[4]=ob_x+ob_width-2;
		 pxy[5]=ob_y+2;
		 v_pline (userhandle, 3, pxy);/* unten, rechts schwarz */
	 }
  }
  else
  {
	 if(!threedee) /* kein 3D-Look */
	 {
		 pxy[0]=ob_x+1;
		 pxy[1]=ob_y+1;
		 pxy[2]=ob_x+ob_width-2;
		 pxy[3]=ob_y+ob_height-2;
		 if(selected)
		 {
			vsf_color(userhandle,BLACK);		  /* farbe  */
		 }
		 else
		 {
			vsf_color(userhandle,WHITE);		  /* farbe  */
		 }
		 vswr_mode(userhandle, MD_XOR);
		 vr_recfl(userhandle,pxy);	  /* weižes rechteck in workspace */
	 }
	 else
	 {
		 pxy[0]=ob_x+1;
		 pxy[1]=ob_y+1;
		 pxy[2]=ob_x+ob_width-2;
		 pxy[3]=ob_y+ob_height-2;
		 vsf_color(userhandle,actbutcolor);		  /* farbe  */
		 vst_color(userhandle,BLACK);		  /* farbe  */
  		 vswr_mode (userhandle, MD_REPLACE); 
		 vr_recfl(userhandle,pxy);	  /* weižes rechteck in workspace */
	
  		 vswr_mode (userhandle, MD_TRANS); 

		 if(((TEDINFO *)pb->pb_parm)->te_font==IBM)
		 {
			 vst_point(userhandle,norm_point,&ret,&ret,&cw,&ch);
			 cx=pb->pb_x+(pb->pb_w-strlen(string)*cw)/2;
			 cy=pb->pb_y+(pb->pb_h-ch)/2-1;
			 if(boxh<=8)
			 	cy++;
	       if(selected)
	       {
	       	cx++;
	       	cy++;
	       }
			 v_gtext(userhandle,cx,cy,string);
			 if(cp)
			 {
				 pxy[0]=cx + (cp-string)*cw;
				 pxy[1]=cy + ch - 1;
				 pxy[2]=cx + (cp-string+1L)*cw - 1;
				 pxy[3]=cy + ch - 1;
				 vsl_color (userhandle, BLACK);
				 if(boxh<=8)
				 {
					 pxy[1]++;
					 pxy[3]++;
				 }
				 v_pline(userhandle,2,pxy);
			 }
		 }
		 else
		 {
		 	 vst_height(userhandle,small_point,&ret,&ret,&cw,&ch);
			 cx=pb->pb_x+(3*cw);
			 cy=pb->pb_y+((boxh>8)?SMALL:SMALL/2-1)-1;
	       if(selected)
	       {
	       	cx++;
	       	cy++;
	       }
			 v_gtext(userhandle,cx,cy,string);
			 if(cp)
			 {
				 pxy[0]=cx + (cp-string)*cw;
				 pxy[1]=cy + ch - 4;
				 pxy[2]=cx + (cp-string+1L)*cw - 1;
				 pxy[3]=cy + ch - 4;
				 vsl_color (userhandle, BLACK);
				 v_pline(userhandle,2,pxy);
			 }
		 }
		 vswr_mode (userhandle, MD_REPLACE);
		 if(selected)
		 {
			 vsl_color (userhandle, BLACK);/* oben, links schwarz */
			 pxy[0]=ob_x+2-1;
			 pxy[1]=ob_y+ob_height-2-1;
			 pxy[2]=ob_x+2-1;
			 pxy[3]=ob_y+2-1;
			 pxy[4]=ob_x+ob_width-2-1;
			 pxy[5]=ob_y+2-1;
			 v_pline (userhandle, 3, pxy); 

			 vsl_color (userhandle, WHITE);
			 pxy[0]=ob_x+2;
			 pxy[1]=ob_y+ob_height-2;
			 pxy[2]=ob_x+ob_width-2;
			 pxy[3]=ob_y+ob_height-2;
			 pxy[4]=ob_x+ob_width-2;
			 pxy[5]=ob_y+2;
			 v_pline (userhandle, 3, pxy);/* unten, rechts weiž */ 
		 }
		 else
		 {
			 vsl_color (userhandle, WHITE);/* oben, links weiž */
			 pxy[0]=ob_x+2-1;
			 pxy[1]=ob_y+ob_height-2-1;
			 pxy[2]=ob_x+2-1;
			 pxy[3]=ob_y+2-1;
			 pxy[4]=ob_x+ob_width-2-1;
			 pxy[5]=ob_y+2-1;
			 v_pline (userhandle, 3, pxy); 

			 vsl_color (userhandle, LBLACK); /* dunkelgrau */
			 pxy[0]=ob_x+2;
			 pxy[1]=ob_y+ob_height-2;
			 pxy[2]=ob_x+ob_width-2;
			 pxy[3]=ob_y+ob_height-2;
			 pxy[4]=ob_x+ob_width-2;
			 pxy[5]=ob_y+2;
			 v_pline (userhandle, 3, pxy);/* unten, rechts dunkelgrau */
		 }
	 }
  }

  reset_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

#if MSDOS
  fardr_end (pb->pb_currstate & ~ SELECTED);
#endif

  return (pb->pb_currstate & ~ SELECTED);
} /* draw_altbutton */

/*****************************************************************************/
/* Zeichnet ankreuzbare Buttons															 */
/*****************************************************************************/
#if MSDOS
LOCAL WORD draw_checkbox ()
{
  PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_checkbox (PARMBLK *pb)
{
#endif

  WORD	 ob_x, ob_y, ob_width, ob_height;
  BOOLEAN disabled, selected, changed;
  WORD	 pxy [12];
  int	    cw,ch,ret,viele_Farben;
  char	 *cp,string[32];

  ob_x		= pb->pb_x+1;
  ob_y		= pb->pb_y+1;
  ob_width  = pb->pb_h-2; /* nicht pb_w!!! */  /* 3 */
  ob_height = pb->pb_h-2;                      /* 3 */
  selected  = pb->pb_currstate & SELECTED;
  disabled  = pb->pb_currstate & DISABLED;
  changed	= (pb->pb_currstate ^ pb->pb_prevstate) & SELECTED;
  viele_Farben = mindestens_16_Farben();

  set_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

  vsf_perimeter(userhandle,TRUE);
  vsl_type (userhandle, SOLID);
  vsl_ends (userhandle, SQUARED, SQUARED);
  vsl_width (userhandle, 1);
  vsl_color (userhandle, BLACK);

  if(threedee && disabled && viele_Farben)
     vst_color (userhandle, WHITE);
  else  
     vst_color (userhandle, BLACK);

  vsm_type(userhandle,PM_DOT);
  vswr_mode (userhandle, MD_TRANS);

  if (! changed) /* it was an objc_draw, so draw box */
  {
	 pxy [0] = ob_x;
	 pxy [1] = ob_y + ob_height - 1;
	 pxy [2] = ob_x;
	 pxy [3] = ob_y;
	 pxy [4] = ob_x + ob_width - 1;
	 pxy [5] = ob_y;
	 v_pline (userhandle, 3, pxy);

    if(threedee && viele_Farben)
	    vsl_color (userhandle, WHITE);
	 pxy [ 6] = ob_x + ob_width - 1;
	 pxy [ 7] = ob_y + 1;
	 pxy [ 8] = ob_x + ob_width - 1;
	 pxy [ 9] = ob_y + ob_height - 1;
	 pxy [10] = ob_x + 1;
	 pxy [11] = ob_y + ob_height - 1;
	 v_pline (userhandle, 3, &pxy[ 6]);

    vsl_color (userhandle, BLACK);

	 strcpy(string,(char *)((TEDINFO *)pb->pb_parm)->te_ptext);
	 if((cp=strchr(string,'_'))!=NULL)
		 strcpy(cp,&cp[1]);
	 vst_alignment(userhandle,0,5,&ret,&ret); /* Ausrichtung */

	 if(((TEDINFO *)pb->pb_parm)->te_font==IBM)
	 {
		 vst_point(userhandle,norm_point,&ret,&ret,&cw,&ch);
		 if(boxh>8)
		 {
			 v_gtext(userhandle,pb->pb_x+(3*cw),pb->pb_y-1,string);
		 }
		 else
		 {
			 v_gtext(userhandle,pb->pb_x+(3*cw),pb->pb_y,string);
		 }
		 if(cp)
		 {
			 pxy[0]=pb->pb_x + (cp-string)*cw+(3*cw);
			 pxy[1]=pb->pb_y + pb->pb_h - 2;
			 pxy[2]=pb->pb_x + (cp-string+1L)*cw+(3*cw) - 1;
			 pxy[3]=pb->pb_y + pb->pb_h - 2;
		    if(threedee && disabled && viele_Farben)
	   		vsl_color (userhandle, WHITE);
	   	 else
			 	vsl_color (userhandle, BLACK);
			 if(boxh<=8)
			 {
				 pxy[1]++;
				 pxy[3]++;
			 }
			 v_pline(userhandle,2,pxy);
		 }
	 }
	 else
	 {
		 vst_height(userhandle,small_point,&ret,&ret,&cw,&ch);
		 v_gtext(userhandle,pb->pb_x+(3*cw),pb->pb_y+((boxh>8)?SMALL:SMALL/2-1),string);
		 if(cp)
		 {
			 pxy[0]=pb->pb_x + (cp-string)*cw+(3*cw);
			 pxy[1]=pb->pb_y + pb->pb_h - 4;
			 pxy[2]=pb->pb_x + (cp-string+1L)*cw+(3*cw) - 1;
			 pxy[3]=pb->pb_y + pb->pb_h - 4;
		    if(threedee && disabled && viele_Farben)
	   		vsl_color (userhandle, WHITE);
	   	 else
				vsl_color (userhandle, BLACK);
			 if(boxh<=8)
			 {
				 pxy[1]+=3;
				 pxy[3]+=3;
			 }
			 v_pline(userhandle,2,pxy);
		 }
	 }
  }

  if (!selected && !disabled) /* it was an objc_change */
	 vsl_color (userhandle, dialbgcolor);

  if (selected) /* it was an objc_change */
	 vsl_color (userhandle, BLACK);

  if (disabled) /* it was an objc_change */
	 vsl_color (userhandle, dialbgcolor);

  pxy [0] = ob_x + 1;
  pxy [1] = ob_y + 1;
  pxy [2] = ob_x + ob_width - 2;
  pxy [3] = ob_y + ob_height - 2;
  v_pline (userhandle, 2, pxy);

  pxy [0] = ob_x + ob_width - 2;
  pxy [1] = ob_y + 1;
  pxy [2] = ob_x + 1;
  pxy [3] = ob_y + ob_height - 2;
  v_pline (userhandle, 2, pxy);

  reset_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

#if MSDOS
  fardr_end (pb->pb_currstate & ~ SELECTED);
#endif
  if (threedee && viele_Farben)
	  return (pb->pb_currstate & ~ (SELECTED|DISABLED));
  else
	  return (pb->pb_currstate & ~ SELECTED);
} /* draw_checkbox */

/*****************************************************************************/
/* Zeichnet runde Radiobuttons															  */
/*****************************************************************************/
#if MSDOS
LOCAL WORD draw_radio ()
{
  PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_radio (PARMBLK *pb)
{
#endif

  WORD	 ob_x, ob_y, ob_height;
  BOOLEAN disabled,selected,changed;
  MFDB	 s, d;
  BITBLK  *bitblk;
  WORD	 robj; /* radio button object number */
  WORD	 pxy [8];
  WORD	 index [2];
  int	    cw,ch,ret,viele_Farben;
  char	 *cp,string[32];

  ob_x		= pb->pb_x;
  ob_y		= pb->pb_y;
  ob_height = pb->pb_h;
  disabled  = pb->pb_currstate & DISABLED;
  selected  = pb->pb_currstate & SELECTED;
  changed	= (pb->pb_currstate ^ pb->pb_prevstate) & SELECTED;
  viele_Farben = mindestens_16_Farben();

  if(threedee && disabled && viele_Farben)
     vst_color (userhandle, WHITE);
  else  
     vst_color (userhandle, BLACK);

  set_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

  if (selected) /* it was an objc_change */
  {
	  switch(norm_point)
	  {
	     case 9:
	        robj=RBLSEL;
	        break;
	     case 10:
	        if(threedee)
		        robj=RBHSEL3D;
		     else
		        robj=RBHSEL;
	        break;
	     case 20:
	        robj=RBBSEL;
	        break;
	     default:
	        if(threedee)
		        robj=RBHSEL3D;
		     else
		        robj=RBHSEL;
	        break;
	  }
  }
  else
  {
	  switch(norm_point)
	  {
	     case 9:
	        robj=RBLNORM;
	        break;
	     case 10:
	        if(threedee)
		        robj=RBHNORM3D;
		     else
		        robj=RBHNORM;
	        break;
	     case 20:
	        robj=RBBNORM;
	        break;
	     default:
	        if(threedee)
		        robj=RBHNORM3D;
		     else
		        robj=RBHNORM;
	        break;
	  }
  }
  
  if(threedee)
  {
	  bitblk = (BITBLK *)userimg [RBHBG3D].ob_spec;
	
	  d.mp  = NULL; /* screen */
	  s.mp  = (VOID *)bitblk->bi_pdata;
	  s.fwp = bitblk->bi_wb << 3;
	  s.fh  = bitblk->bi_hl;
	  s.fww = s.fwp/16;
	  s.ff  = FALSE;
	  s.np  = 1;
	
	  pxy [0] = 0;
	  pxy [1] = 0;
	  pxy [2] = s.fwp - 1;
	  pxy [3] = s.fh - 1;
	  pxy [4] = ob_x + 1 + (ob_height-bitblk->bi_wb*8)/2-1;/* nicht ob_width! */
	  if(boxh<=8)
		 pxy [4]+=ob_height/2-1;
	  pxy [5] = ob_y + 1 + (ob_height-bitblk->bi_hl)/2-1;
	  pxy [6] = ob_x + pxy [2];
	  pxy [7] = ob_y + pxy [3];
	
	  index [0] = WHITE;
	  index [1] = dialbgcolor;
	  vrt_cpyfm (userhandle, MD_REPLACE, pxy, &s, &d, index);	 /* copy it */
  }
  
  bitblk = (BITBLK *)userimg [robj].ob_spec;

  d.mp  = NULL; /* screen */
  s.mp  = (VOID *)bitblk->bi_pdata;
  s.fwp = bitblk->bi_wb << 3;
  s.fh  = bitblk->bi_hl;
  s.fww = s.fwp/16;
  s.ff  = FALSE;
  s.np  = 1;

  pxy [0] = 0;
  pxy [1] = 0;
  pxy [2] = s.fwp - 1;
  pxy [3] = s.fh - 1;
  pxy [4] = ob_x + 1 + (ob_height-bitblk->bi_wb*8)/2-1;/* nicht ob_width! */
  if(boxh<=8)
	 pxy [4]+=ob_height/2-1;
  pxy [5] = ob_y + 1 + (ob_height-bitblk->bi_hl)/2-1;
  pxy [6] = ob_x + pxy [2];
  pxy [7] = ob_y + pxy [3];

  index [0] = BLACK;
  index [1] = dialbgcolor;

  vrt_cpyfm (userhandle, threedee?MD_TRANS:MD_REPLACE, pxy, &s, &d, index);	 /* copy it */

  vswr_mode (userhandle, MD_TRANS);

  if(!changed)
  {
	 strcpy(string,(char *)((TEDINFO *)pb->pb_parm)->te_ptext);
	 if((cp=strchr(string,'_'))!=NULL)
		 strcpy(cp,&cp[1]);
	 vst_alignment(userhandle,0,5,&ret,&ret); /* Ausrichtung */

	 if(((TEDINFO *)pb->pb_parm)->te_font==IBM)
	 {
		 vst_point(userhandle,norm_point,&ret,&ret,&cw,&ch);
		 if(boxh>8)
		 {
			 v_gtext(userhandle,pb->pb_x+(3*cw),pb->pb_y-1,string);
		 }
		 else
		 {
			 v_gtext(userhandle,pb->pb_x+(3*cw),pb->pb_y,string);
		 }
		 if(cp)
		 {
			 pxy[0]=pb->pb_x + (cp-string)*cw+(3*cw);
			 pxy[1]=pb->pb_y + pb->pb_h - 2;
			 pxy[2]=pb->pb_x + (cp-string+1L)*cw+(3*cw) - 1;
			 pxy[3]=pb->pb_y + pb->pb_h - 2;
		    if(threedee && disabled && viele_Farben)
	   		vsl_color (userhandle, WHITE);
	   	 else
				vsl_color (userhandle, BLACK);
			 if(boxh<=8)
			 {
				 pxy[1]++;
				 pxy[3]++;
			 }
			 v_pline(userhandle,2,pxy);
		 }
	 }
	 else
	 {
		 vst_height(userhandle,small_point,&ret,&ret,&cw,&ch);
		 v_gtext(userhandle,pb->pb_x+(3*cw),pb->pb_y+((boxh>8)?SMALL:SMALL/2-1),string);
		 if(cp)
		 {
			 pxy[0]=pb->pb_x + (cp-string)*cw+(3*cw);
			 pxy[1]=pb->pb_y + pb->pb_h - 4;
			 pxy[2]=pb->pb_x + (cp-string+1L)*cw+(3*cw) - 1;
			 pxy[3]=pb->pb_y + pb->pb_h - 4;
		    if(threedee && disabled && viele_Farben)
	   		vsl_color (userhandle, WHITE);
	   	 else
				vsl_color (userhandle, BLACK);
			 if(boxh<=8)
			 {
				 pxy[1]+=3;
				 pxy[3]+=3;
			 }
			 v_pline(userhandle,2,pxy);
		 }
	 }
  }

  reset_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

#if MSDOS
  fardr_end (pb->pb_currstate & ~ SELECTED);
#endif
  if(threedee && viele_Farben)
     return (pb->pb_currstate & ~ (SELECTED|DISABLED));
  else
     return (pb->pb_currstate & ~ SELECTED);
} /* draw_radio */
/*
/*****************************************************************************/
/* Zeichnet runde Radiobuttons mit VDI	            NICHT BENUTZT!!!		     */
/*****************************************************************************/
#if MSDOS
LOCAL WORD draw_radio ()
{
  PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_radio (PARMBLK *pb)
{
#endif

  WORD	 ob_x, ob_y, ob_height;
  BOOLEAN selected,changed;
  int	    cw,ch,ret,pxy[4];
  char	 *cp,string[32];

  ob_x		= pb->pb_x;
  ob_y		= pb->pb_y;
  ob_height = pb->pb_h;
  selected  = pb->pb_currstate & SELECTED;
  changed	= (pb->pb_currstate ^ pb->pb_prevstate) & SELECTED;

  set_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

  vst_color (userhandle, BLACK);
  vswr_mode (userhandle, MD_TRANS);
  vsf_color(userhandle,BLACK);
  vsf_interior(userhandle,FIS_HOLLOW);
  v_ellipse(userhandle,ob_x+ob_height/2-1,ob_y+ob_height/2-1,
                       ob_height/2-1,   ob_height/2-1);
  if(selected)
  {
	  vsf_interior(userhandle,FIS_SOLID);
	  v_ellipse(userhandle,ob_x+ob_height/2-1,ob_y+ob_height/2-1,
	                       ob_height/4,   ob_height/4);
  }

  if(!changed)
  {
	 strcpy(string,(char *)((TEDINFO *)pb->pb_parm)->te_ptext);
	 if((cp=strchr(string,'_'))!=NULL)
		 strcpy(cp,&cp[1]);
	 vst_alignment(userhandle,0,5,&ret,&ret); /* Ausrichtung */

	 if(((TEDINFO *)pb->pb_parm)->te_font==IBM)
	 {
		 vst_point(userhandle,norm_point,&ret,&ret,&cw,&ch);
		 if(boxh>8)
		 {
			 v_gtext(userhandle,pb->pb_x+(3*cw),pb->pb_y-1,string);
		 }
		 else
		 {
			 v_gtext(userhandle,pb->pb_x+(3*cw),pb->pb_y,string);
		 }
		 if(cp)
		 {
			 pxy[0]=pb->pb_x + (cp-string)*cw+(3*cw);
			 pxy[1]=pb->pb_y + pb->pb_h - 2;
			 pxy[2]=pb->pb_x + (cp-string+1L)*cw+(3*cw) - 1;
			 pxy[3]=pb->pb_y + pb->pb_h - 2;
			 vsl_color (userhandle, BLACK);
			 if(boxh<=8)
			 {
				 pxy[1]++;
				 pxy[3]++;
			 }
			 v_pline(userhandle,2,pxy);
		 }
	 }
	 else
	 {
		 vst_height(userhandle,small_point,&ret,&ret,&cw,&ch);
		 v_gtext(userhandle,pb->pb_x+(3*cw),pb->pb_y+((boxh>8)?SMALL:SMALL/2-1),string);
		 if(cp)
		 {
			 pxy[0]=pb->pb_x + (cp-string)*cw+(3*cw);
			 pxy[1]=pb->pb_y + pb->pb_h - 4;
			 pxy[2]=pb->pb_x + (cp-string+1L)*cw+(3*cw) - 1;
			 pxy[3]=pb->pb_y + pb->pb_h - 4;
			 vsl_color (userhandle, BLACK);
			 if(boxh<=8)
			 {
				 pxy[1]+=3;
				 pxy[3]+=3;
			 }
			 v_pline(userhandle,2,pxy);
		 }
	 }
  }

  reset_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

#if MSDOS
  fardr_end (pb->pb_currstate & ~ SELECTED);
#endif

  return (pb->pb_currstate & ~ SELECTED);
} /* draw_radio */
*/
/*****************************************************************************/
/* Zeichnet Buttons mit Kreis																*/
/*****************************************************************************/
#if MSDOS
LOCAL WORD draw_circle ()
{
	PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_circle (PARMBLK *pb)
{
#endif

  WORD	 ob_x, ob_y, ob_width, ob_height, cobj;
  BOOLEAN changed;
  MFDB	 s, d;
  BITBLK  *bitblk;
  WORD	 pxy [10];
  WORD	 index [2];
  GRECT	r;

  ob_x		= pb->pb_x;
  ob_y		= pb->pb_y;
  ob_width  = pb->pb_w;
  ob_height = pb->pb_h;
  changed	= (pb->pb_currstate ^ pb->pb_prevstate) & SELECTED;

  set_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

  if (! changed) /* it was an objc_draw, so draw box */
  {
	 vsf_interior(userhandle,FIS_SOLID);
	 vsf_perimeter (userhandle, TRUE);
    vswr_mode (userhandle, MD_TRANS);

	 pxy [0] = ob_x+2;
	 pxy [1] = ob_y+2;
	 pxy [2] = ob_x+2 + ob_width - 1;
	 pxy [3] = ob_y+2 + ob_height - 1;
	 vsf_color (userhandle, BLACK);
	 v_bar (userhandle, pxy);

	 pxy [0] = ob_x;
	 pxy [1] = ob_y;
	 pxy [2] = ob_x + ob_width  - 1;
	 pxy [3] = ob_y + ob_height - 1;
	 vsf_color (userhandle, WHITE);
	 v_bar (userhandle, pxy);

	 vsl_type (userhandle, SOLID);
	 vsl_ends (userhandle, SQUARED, SQUARED);
	 vsl_width (userhandle, 1);
	 vsl_color (userhandle, BLACK);
/*
    vswr_mode (userhandle, MD_REPLACE);
*/
	 pxy [0] = ob_x;
	 pxy [1] = ob_y;
	 pxy [2] = ob_x + ob_width - 1;
	 pxy [3] = ob_y;
	 pxy [4] = pxy [2];
	 pxy [5] = ob_y + ob_height - 1;
	 pxy [6] = ob_x;
	 pxy [7] = pxy [5];
	 pxy [8] = ob_x;
	 pxy [9] = ob_y;
	 v_pline (userhandle, 5, pxy);

  } /* if */
  switch(norm_point)
  {
     case 9:
        cobj=CIRCLEL;
        break;
     case 10:
     		if(pb->pb_currstate & DISABLED)
        		cobj=CIRCLEHDIS;
       	else
        		cobj=CIRCLEH;
        break;
     case 20:
        cobj=CIRCLEB;
        break;
     default:
     		if(pb->pb_currstate & DISABLED)
        		cobj=CIRCLEHDIS;
       	else
        		cobj=CIRCLEH;
        break;
  }
  bitblk = (BITBLK *)userimg [cobj].ob_spec;

  d.mp  = NULL; /* screen */
  s.mp  = (VOID *)bitblk->bi_pdata;
  s.fwp = bitblk->bi_wb << 3;
  s.fh  = bitblk->bi_hl;
  s.fww = s.fwp/16;
  s.ff  = FALSE;
  s.np  = 1;

  pxy [0] = 0;
  pxy [1] = 0;
  pxy [2] = s.fwp - 1;
  pxy [3] = s.fh - 1;
  pxy [4] = ob_x + 1 + (ob_width-bitblk->bi_wb*8)/2-1;
  pxy [5] = ob_y + 1 + (ob_height-bitblk->bi_hl)/2-1;
  pxy [6] = ob_x + pxy [2];
  pxy [7] = ob_y + pxy [3];

  index [0] = BLACK;
  index [1] = WHITE;

  vrt_cpyfm (userhandle, MD_TRANS, pxy, &s, &d, index);	 /* copy it */

  reset_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

#if MSDOS
  fardr_end ((pb->pb_currstate & ~ SELECTED) & ~ DISABLED);
#endif

  return ((pb->pb_currstate & ~ SELECTED) & ~ DISABLED);
} /* draw_circel */

/*****************************************************************************/
/* Zeichnet aktuellen Font																	*/
/*****************************************************************************/
#if MSDOS
LOCAL WORD draw_font ()
{
	PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_font (PARMBLK *pb)
{
#endif
	int ret;
	BOOLEAN selected, changed;
	WORD	 pxyarray[4];
	char string[]="X";
	static int w=0;

	extern WINDOW *twp;

	selected  = pb->pb_currstate & SELECTED;
	changed	= (pb->pb_currstate ^ pb->pb_prevstate) & SELECTED;

   set_clip (twp->vdihandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

	if(!changed) /* ordinary objc_draw */
	{
		vswr_mode(twp->vdihandle,MD_TRANS);
		if(pb->pb_obj==FCHAR)
			if(vst_point(twp->vdihandle,5,&ret,&ret,&w,&ret)!=5)
			{
				if(boxh>8)
					vst_point(twp->vdihandle,norm_point,&ret,&ret,&w,&ret);
				else
					vst_point(twp->vdihandle,5,&ret,&ret,&w,&ret);
			}
		*string=pb->pb_obj-FCHAR;
		v_gtext(twp->vdihandle,pb->pb_x+w,pb->pb_y,string);
	}
	else		  /* objc_change */
	{
      pxyarray[0]=pb->pb_x;
      pxyarray[1]=pb->pb_y;
      pxyarray[2]=pb->pb_x+pb->pb_w-1;
      pxyarray[3]=pb->pb_y+pb->pb_h-1;
		vswr_mode(twp->vdihandle,MD_XOR);
		if(selected)
		{
			vsf_color(twp->vdihandle,BLACK);
			vst_color(twp->vdihandle,WHITE);
			vr_recfl(twp->vdihandle,pxyarray);		/* markieren */
		}
		else
		{
			vsf_color(twp->vdihandle,WHITE);
			vst_color(twp->vdihandle,BLACK);
			vr_recfl(twp->vdihandle,pxyarray);		/* markieren */
		}
	}

   reset_clip (twp->vdihandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

 #if MSDOS
	fardr_end (pb->pb_currstate & ~ SELECTED);
 #endif

	return (pb->pb_currstate & ~ SELECTED);

} /* draw_font */
/*****************************************************************************/
/* Zeichnet šberschriftenunterstreichung												 */
/*****************************************************************************/
#if MSDOS
LOCAL WORD draw_uline ()
{
	PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_uline (PARMBLK *pb)
{
#endif
	int x, cw, ch, width, ret, pxy[4], pxyarray[4];

   set_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

	vst_color (userhandle, BLACK);
	vswr_mode (userhandle, MD_TRANS);
	vst_alignment(userhandle,0,5,&ret,&ret); /* Ausrichtung */
	vst_point(userhandle,norm_point,&ret,&ret,&cw,&ch);
	switch(((TEDINFO *)pb->pb_parm)->te_just)
	{
		case TE_LEFT:
			x=pb->pb_x;
			break;
		case TE_RIGHT:
			x=pb->pb_x+pb->pb_w-strlen((char *)((TEDINFO *)pb->pb_parm)->te_ptext)*cw;
			break;
		case TE_CNTR:
			x=pb->pb_x+(pb->pb_w-strlen((char *)((TEDINFO *)pb->pb_parm)->te_ptext)*cw)/2;
			break;
	}

	v_gtext(userhandle,x,pb->pb_y,(char *)((TEDINFO *)pb->pb_parm)->te_ptext);
	width=pb->pb_w+2;

	pxy[0]=pb->pb_x - 1;
	pxy[1]=pb->pb_y + pb->pb_h;
	pxy[2]=pb->pb_x - 1 + width - 1;
	pxy[3]=pxy[1];
	vswr_mode (userhandle, MD_REPLACE);
	vsl_color (userhandle, BLACK);
	v_pline(userhandle,2,pxy);
	pxy[1]++;
	pxy[3]++;
	vsl_color (userhandle, WHITE);
	v_pline(userhandle,2,pxy);

   reset_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

 #if MSDOS
	fardr_end (pb->pb_currstate);
 #endif
	return (pb->pb_currstate);

} /* draw_uline */
/*****************************************************************************/
/* Zeichnet Eselsohren																		*/
/*****************************************************************************/
#if MSDOS
LOCAL WORD draw_ear ()
{
	PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_ear (PARMBLK *pb)
{
#endif
	int pxy[8], pxyarray[4];

   set_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

	vswr_mode (userhandle, MD_REPLACE);
	vsl_color (userhandle, BLACK);
	vsf_color(userhandle, dialbgcolor);
	vsf_perimeter(userhandle, TRUE);
	vsf_style(userhandle, 1);
	vsf_interior(userhandle, FIS_SOLID);

	pxy[0]=pb->pb_x;
	pxy[1]=pb->pb_y;
	pxy[2]=pb->pb_x + pb->pb_w - 1;
	pxy[3]=pb->pb_y + pb->pb_h - 1;
	pxy[4]=pb->pb_x;
	pxy[5]=pb->pb_y + pb->pb_h - 1;
	pxy[6]=pb->pb_x;
	pxy[7]=pb->pb_y;
	v_fillarea(userhandle,4,pxy);
	v_pline(userhandle,4,pxy);

	pxy[0]=pb->pb_x+3;
	pxy[1]=pb->pb_y+3;
	pxy[2]=pb->pb_x+3;
	pxy[3]=pb->pb_y + pb->pb_h - 1 - 3;
	pxy[4]=pb->pb_x + pb->pb_w - 1 - 3;
	pxy[5]=pb->pb_y + pb->pb_h - 1 - 3;
	v_pline(userhandle,3,pxy);

   reset_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

 #if MSDOS
	fardr_end (pb->pb_currstate);
 #endif
	return (pb->pb_currstate);

} /* draw_ear */
#if MSDOS
/*****************************************************************************/
/* Zeichnet disablete Trennlinien														  */
/*****************************************************************************/
#if MSDOS
LOCAL WORD draw_dline ()
{
	PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_dline (PARMBLK *pb)
{
#endif
	int xy[16];

	xy[ 4]=pb->pb_x;
	xy[ 5]=pb->pb_y+(pb->pb_h-1)/2;
	xy[ 6]=pb->pb_x+pb->pb_w-1;
	xy[ 7]=xy[5];
	xy[ 8]=xy[6];
	xy[ 9]=xy[7]+1;
	xy[10]=xy[4];
	xy[11]=xy[5]+1;
	xy[12]=xy[4];
	xy[13]=xy[5];

	vswr_mode(userhandle,MD_REPLACE);
	vsl_type (userhandle, SOLID);
	vsl_ends (userhandle, SQUARED, SQUARED);
	vsl_width (userhandle, 1);
	vsl_color (userhandle, BLACK);
	v_pline(userhandle,5,&xy[4]);

 #if MSDOS
	fardr_end (pb->pb_currstate);
 #endif
	return (pb->pb_currstate);
}
#endif
/*****************************************************************************/
/* Zeichnet 3Dbox																		  		  */
/*****************************************************************************/
#if MSDOS
LOCAL WORD draw_3Dbox ()
{
	PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_3Dbox (PARMBLK *pb)
{
#endif
	int pxy[12];
	int ob_x,ob_y,ob_width,ob_height;
	
	ob_x      = pb->pb_x;
	ob_y      = pb->pb_y;
	ob_width  = pb->pb_w;
	ob_height = pb->pb_h;
	
   set_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

	vswr_mode(userhandle,MD_REPLACE);
	vsl_type (userhandle, SOLID);
	vsl_ends (userhandle, SQUARED, SQUARED);
	vsl_width (userhandle, 1);
	vsl_color (userhandle, BLACK);
   vsf_interior(userhandle,FIS_SOLID); /* Fllung */

	pxy [0] = ob_x;
	pxy [1] = ob_y;
	pxy [2] = ob_x + ob_width - 1;
	pxy [3] = ob_y;
	pxy [4] = pxy [2];
	pxy [5] = ob_y + ob_height - 1;
	pxy [6] = ob_x;
	pxy [7] = pxy [5];
	pxy [8] = ob_x;
	pxy [9] = ob_y;
	v_pline (userhandle, 5, pxy);

	pxy[0]=ob_x+1;
	pxy[1]=ob_y+1;
	pxy[2]=ob_x+ob_width-3;
	pxy[3]=ob_y+ob_height-3;
	if(threedee) /*3D*/
		vsf_color(userhandle,dialbgcolor);		  /* farbe  */
	else
		vsf_color(userhandle,WHITE);		  /* farbe  */
	vr_recfl(userhandle,pxy);	  /* weižes rechteck in workspace */

	if(threedee)
	{
		vsl_color (userhandle, WHITE);
		pxy [0] = ob_x + 1;
		pxy [1] = ob_y + ob_height - 2;
		pxy [2] = ob_x + 1;
		pxy [3] = ob_y + 1;
		pxy [4] = ob_x + ob_width - 2;
		pxy [5] = ob_y + 1;
		v_pline (userhandle, 3, pxy);

		vsl_color (userhandle, BLACK);
		pxy [0] = ob_x + ob_width - 2;
		pxy [1] = ob_y + 2;
		pxy [2] = ob_x + ob_width - 2;
		pxy [3] = ob_y + ob_height - 2;
		pxy [4] = ob_x + 2;
		pxy [5] = ob_y + ob_height - 2;
		v_pline (userhandle, 3, pxy);

		vsl_color (userhandle, WHITE);
		pxy [0] = ob_x + ob_width - 1;
		pxy [1] = ob_y + 1;
		pxy [2] = ob_x + ob_width - 1;
		pxy [3] = ob_y + ob_height - 1;
		pxy [4] = ob_x + 1;
		pxy [5] = ob_y + ob_height - 1;
		v_pline (userhandle, 3, pxy);

	}
   reset_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

 #if MSDOS
	fardr_end (pb->pb_currstate);
 #endif
	return (pb->pb_currstate);
}
/*
#if MSDOS
LOCAL WORD draw_3Dbox ()
{
	PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_3Dbox (PARMBLK *pb)
{
#endif
	int pxy[12];
	int ob_x,ob_y,ob_width,ob_height;
	
	ob_x      = pb->pb_x;
	ob_y      = pb->pb_y;
	ob_width  = pb->pb_w;
	ob_height = pb->pb_h;
	
   set_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

	vswr_mode(userhandle,MD_REPLACE);
	vsl_type (userhandle, SOLID);
	vsl_ends (userhandle, SQUARED, SQUARED);
	vsl_width (userhandle, 1);
	vsl_color (userhandle, BLACK);
   vsf_interior(userhandle,FIS_SOLID); /* Fllung */

	pxy [0] = ob_x;
	pxy [1] = ob_y;
	pxy [2] = ob_x + ob_width - 1;
	pxy [3] = ob_y;
	pxy [4] = pxy [2];
	pxy [5] = ob_y + ob_height - 1;
	pxy [6] = ob_x;
	pxy [7] = pxy [5];
	pxy [8] = ob_x;
	pxy [9] = ob_y;
	v_pline (userhandle, 5, pxy);

	pxy[0]=ob_x+1;
	pxy[1]=ob_y+1;
	pxy[2]=ob_x+ob_width-3;
	pxy[3]=ob_y+ob_height-3;
	if(threedee) /*3D*/
		vsf_color(userhandle,dialbgcolor);		  /* farbe  */
	else
		vsf_color(userhandle,WHITE);		  /* farbe  */
	vr_recfl(userhandle,pxy);	  /* weižes rechteck in workspace */

	if(threedee)
	{
		vsl_color (userhandle, WHITE);
		pxy [0] = ob_x + ob_width - 2;
		pxy [1] = ob_y + 1;
		pxy [2] = ob_x + ob_width - 2;
		pxy [3] = ob_y + ob_height - 2;
		pxy [4] = ob_x + 1;
		pxy [5] = ob_y + ob_height - 2;
		v_pline (userhandle, 3, pxy);

		vsl_color (userhandle, LBLACK);
		pxy [0] = ob_x + 1;
		pxy [1] = ob_y + ob_height - 2;
		pxy [2] = ob_x + 1;
		pxy [3] = ob_y + 1;
		pxy [4] = ob_x + ob_width - 2;
		pxy [5] = ob_y + 1;
		v_pline (userhandle, 3, pxy);
	}
   reset_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

 #if MSDOS
	fardr_end (pb->pb_currstate);
 #endif
	return (pb->pb_currstate);
}
*/
/*
#if MSDOS
LOCAL WORD draw_3Dbox ()
{
	PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_3Dbox (PARMBLK *pb)
{
#endif
	int pxy[12];
	int ob_x,ob_y,ob_width,ob_height,viele_Farben;
	
	ob_x      = pb->pb_x;
	ob_y      = pb->pb_y;
	ob_width  = pb->pb_w;
	ob_height = pb->pb_h;
	
   set_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

	vswr_mode(userhandle,MD_REPLACE);
	vsl_type (userhandle, SOLID);
	vsl_ends (userhandle, SQUARED, SQUARED);
	vsl_width (userhandle, 1);
	vsl_color (userhandle, BLACK);
   vsf_interior(userhandle,FIS_SOLID); /* Fllung */
   viele_Farben = mindestens_16_Farben();

   pxy [0] = ob_x;
	pxy [1] = ob_y + ob_height - 1;
	pxy [2] = ob_x;
	pxy [3] = ob_y;
	pxy [4] = ob_x + ob_width - 1;
	pxy [5] = ob_y;
	v_pline (userhandle, 3, pxy);

   if(threedee && viele_Farben)
		vsl_color (userhandle, WHITE);

	pxy [0] = ob_x + ob_width - 1;
	pxy [1] = ob_y + 1;
	pxy [2] = pxy [0];
	pxy [3] = ob_y + ob_height - 1;
	pxy [4] = ob_x + 1;
	pxy [5] = pxy [3];
	v_pline (userhandle, 3, pxy);

	pxy[0]=ob_x+1;
	pxy[1]=ob_y+1;
	pxy[2]=ob_x+ob_width-3;
	pxy[3]=ob_y+ob_height-3;
	if(threedee && viele_Farben) /*3D*/
		vsf_color(userhandle,dialbgcolor);		  /* farbe  */
	else
		vsf_color(userhandle,WHITE);		  /* farbe  */
	vr_recfl(userhandle,pxy);	  /* weižes rechteck in workspace */

   reset_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

 #if MSDOS
	fardr_end (pb->pb_currstate);
 #endif
	return (pb->pb_currstate);
}
*/
/*****************************************************************************/
/* Zeichnet selektierten Font in der Fontbox						   				  */
/*****************************************************************************/
#if MSDOS
LOCAL WORD draw_selfont ()
{
	PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_selfont (PARMBLK *pb)
{
#endif
   int obx,oby,h,ret;
   int pxyarray[14];

	extern WINDOW *twp;
   extern int tid,tsize,tattr;

   pxyarray[10]=pb->pb_x;
   pxyarray[11]=pb->pb_y;
   pxyarray[12]=pb->pb_w;
   pxyarray[13]=pb->pb_h;

   if(rc_intersect(&pb->pb_xc,&pxyarray[10]))
   {
      set_clip (twp->vdihandle,pxyarray[10],pxyarray[11],pxyarray[12],pxyarray[13]);

      draw_3Dbox(pb);
      
      vst_font(twp->vdihandle,tid);
	   if(tattr && (vq_vgdos()==0x5F46534D)) /* Vektor-GDOS */
	      vst_arbpt(twp->vdihandle,tsize,&ret,&ret,&ret,&h);
   	else
   	   vst_point(twp->vdihandle,tsize,&ret,&ret,&ret,&h);
      oby =  pb->pb_y;
      oby += (pb->pb_h - h)/2;
      vswr_mode(twp->vdihandle, MD_TRANS);
      v_gtext(twp->vdihandle,pb->pb_x+1,oby,"The quick brown fox jumps over the lazy dog.");
      vst_font(twp->vdihandle,twp->fontid);
      vst_point(twp->vdihandle,twp->fontsize,&ret,&ret,&ret,&ret);
      vswr_mode(twp->vdihandle, MD_REPLACE); /* zurckstellen */

      reset_clip (twp->vdihandle,pxyarray[10],pxyarray[11],pxyarray[12],pxyarray[13]);
   }
 #if MSDOS
	fardr_end (pb->pb_currstate);
 #endif
	return (pb->pb_currstate);
}

#if MSDOS
LOCAL WORD draw_tabbar ()
{
	PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_tabbar (PARMBLK *pb)
{
#endif
	int i, ret, viele_Farben;
	char *cp;
	int attrib[10], pxy [4];
	
	extern WINDOW *twp;
	
	set_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

	vqt_attributes(userhandle,attrib);
	vst_font(userhandle,twp->fontid);
	vst_point(userhandle,twp->fontsize,&ret,&ret,&ret,&ret);
	vst_alignment(userhandle,0,5,&ret,&ret); /* Zellenoberkante */
	vst_color(userhandle,BLACK);
	
	vsl_type (userhandle, SOLID);
	vsl_ends (userhandle, SQUARED, SQUARED);
	vsl_width (userhandle, 1);
	vsl_color (userhandle, BLACK);
	vsf_interior(userhandle,FIS_SOLID); /* Fllung */
   viele_Farben = mindestens_16_Farben();
	
	pxy[0]=pb->pb_x;
	pxy[1]=pb->pb_y;
	pxy[2]=pb->pb_x+pb->pb_w-1;
	pxy[3]=pb->pb_y+pb->pb_h-1;

	if(threedee && viele_Farben) /*3D*/
		vsf_color(userhandle,dialbgcolor);		  /* farbe  */
	else
		vsf_color(userhandle,WHITE);		  /* farbe  */
	vswr_mode(userhandle,MD_REPLACE);
	vr_recfl(userhandle,pxy);	  /* rechteck in workspace */
	
	pxy[0]=pb->pb_x-twp->wscroll/2;      /* Trennlinie ziehen */
	pxy[1]=pb->pb_y-1;
	pxy[2]=pb->pb_x+pb->pb_w-1;
	pxy[3]=pb->pb_y-1;
/*
	vsl_color (userhandle, WHITE);
*/
	v_pline(userhandle,2,pxy);
/*
	pxy[1]++;
	pxy[3]++;
	vsl_color (userhandle, BLACK);
	v_pline(userhandle,2,pxy);
*/
	vswr_mode (userhandle, /*MD_REPLACE*/MD_TRANS); 
	cp=(char *)((TEDINFO *)pb->pb_parm)->te_ptext;
	if(cp[twp->umbruch-2] != ']')
	{
		for(i=1;i<STRING_LENGTH;i++)
			if(cp[i]==']')
			{
				if( ! (i%twp->tab))
					cp[i] = TABSIGN; /*Htchen im Zeichensatz*/
				else
					cp[i] = '.';
				break;
			}
		cp[twp->umbruch-2] = ']';
	}
	v_gtext(userhandle,pb->pb_x,pb->pb_y+(pb->pb_h-twp->hscroll)/2,&cp[twp->wfirst/twp->wscroll]);
	vst_font(userhandle,attrib[0]);
	vst_height(userhandle,attrib[7],&ret,&ret,&ret,&ret);
	
	reset_clip (userhandle, pb->pb_xc,pb->pb_yc,pb->pb_wc,pb->pb_hc);

 #if MSDOS
	fardr_end (pb->pb_currstate);
 #endif
	return (pb->pb_currstate);
}

/*****************************************************************************/
#define MAXUSERBLK (219+3+1) /* 3 Buttons in form_alert() + 1 Reserve */

static int userdefobjs=0;

USERBLK rs_userblk[MAXUSERBLK+1];

void tabbar_fix(WINDOW *wp)
{
	if(wp && wp->toolbar)
	{
		rs_userblk[userdefobjs].ub_code = draw_tabbar;
		rs_userblk[userdefobjs].ub_parm = wp->tabbar->ob_spec;
		wp->tabbar->ob_type = G_USERDEF;
		wp->tabbar->ob_spec = (LONG)&rs_userblk[userdefobjs++];
/*
printf("\33H%003d ",userdefobjs);
*/
	}
}

void form_fix(OBJECT *tree, BOOLEAN is_dialog)
{
  WORD	 obj;
  OBJECT  *ob;
  ICONBLK *ib;
  TEDINFO *ti;
  UWORD	type, xtype;
#if GEM & (GEM2 | GEM3 | XGEM)
  BYTE	 *s;
#endif

  if (tree != NULL)
  {
#if GEM & (GEM2 | GEM3 | XGEM)
	 if (is_dialog)
	 {
		tree->ob_state&=~SHADOWED; /* Atari-like */
		tree->ob_state|=OUTLINED;
	 } /* if */
#endif

	 obj = 0;

	 do
	 {
		ob = &tree [++obj];
		type  = ob->ob_type & 0xFF;
		xtype = ob->ob_type >> 8;

#if MSDOS
		if ((type == G_STRING) && (ob->ob_state & DISABLED))
		{
		  for (s = (BYTE *)ob->ob_spec; *s; s++)
			 if (*s == 0x13)
			 {
				 *s = '-';
				 xtype=DDLINE;
			 }
		}
#endif
		if (threedee && (ob->ob_flags & EDITABLE) && mindestens_16_Farben())
		{  /* vertiefte Eingabefelder */
/*
			ob->ob_y-=2;
			ob->ob_height+=4;
*/
			ob->ob_y--;
			ob->ob_height+=2;
			ob->ob_type  =G_FBOXTEXT;
			ob->ob_state|=SELECTED;
			ob->ob_flags|=FLAGS9;
			ob->ob_flags|=FLAGS10;
			ti = (TEDINFO *)ob->ob_spec;

			ti->te_thickness=0;

			ti->te_just=TE_CNTR;
			ti->te_color=0x11F0;
		}

		if (type == G_ICON)
		{
		  ib = (ICONBLK *)ob->ob_spec;
		  ob->ob_height = ib->ib_ytext + ib->ib_htext; /* Objekth”he = Iconh”he */
		  trans_gimage (tree, obj);		  /* Icons an Bildschirm anpassen */
		} /* if */

		if (type == G_IMAGE)
		{
		  trans_gimage (tree, obj);		  /* Bit Images an Bildschirm anpassen */
		} /* if */

		switch (xtype)
		{
		  case DCHECKBOX  :
			  rs_userblk[userdefobjs].ub_code	  = draw_checkbox;
			  rs_userblk[userdefobjs].ub_parm	  = ob->ob_spec;
			  ob->ob_type	  = G_USERDEF;
			  ob->ob_spec	  = (LONG)&rs_userblk[userdefobjs++];
			  break;
		  case DRBUTTON	:
			  rs_userblk[userdefobjs].ub_code	  = draw_radio;
			  rs_userblk[userdefobjs].ub_parm	  = ob->ob_spec;
			  ob->ob_type	  = G_USERDEF;
			  ob->ob_spec	  = (LONG)&rs_userblk[userdefobjs++];
			  break;
		  case DALTBUTTON :
			  rs_userblk[userdefobjs].ub_code	  = draw_altbutton;
			  rs_userblk[userdefobjs].ub_parm	  = ob->ob_spec;
			  ob->ob_type	  		= G_USERDEF;
			  ob->ob_spec	  		= (LONG)&rs_userblk[userdefobjs++];
           ob->ob_x      	  -= 4;
           ob->ob_y      	  -= 5; /* 4 */
           ob->ob_width  	  += 8;
           ob->ob_height 	  += 10; /* 8 */
           ob->ob_flags      |= FLAGS14; /* wg. '*' im Dialog */
			  if(!threedee)
			  {
	           ob->ob_y++;
   	        ob->ob_height-=2;
			  }
			  break;
		  case DULINE	  :
			  rs_userblk[userdefobjs].ub_code	  = draw_uline;
			  rs_userblk[userdefobjs].ub_parm	  = ob->ob_spec;
			  ob->ob_type	  		 = G_USERDEF;
			  ob->ob_spec	  		 = (LONG)&rs_userblk[userdefobjs++];
			  break;
		  case DHEADER	   :
		  	  ob->ob_y			 	-= boxh / 2;
			  break;
		  case DFONT		:
			  font_blk.ub_code  	 = draw_font;
			  font_blk.ub_parm  	 = ob->ob_spec;
			  ob->ob_type		  	 = G_USERDEF;
			  ob->ob_spec		  	 = (LONG)&font_blk;
			  break;
		  case DEAR		 :
			  ear_blk.ub_code	    = draw_ear;
			  ear_blk.ub_parm	  	 = ob->ob_spec;
			  ob->ob_x			 	-= 3;
			  ob->ob_y			 	-= 3;
			  ob->ob_width			 = ob->ob_height;
if(boxh<=8)
	ob->ob_width=2*ob->ob_height;
			  ob->ob_width		 	+= 6;
			  ob->ob_height	 	+= 6;
			  ob->ob_type		  	 = G_USERDEF;
			  ob->ob_state		 	&= ~OUTLINED;
			  ob->ob_flags		 	|= TOUCHEXIT;
			  ob->ob_flags		 	&= ~SELECTABLE;
			  ob->ob_flags		 	&= ~EXIT;
			  ob->ob_spec		  	 = (LONG)&ear_blk;
			  break;
		  case DCIRCLE	 :
			  circle_blk.ub_code  = draw_circle;
			  circle_blk.ub_parm  = ob->ob_spec;
			  ob->ob_x				-= 1;
			  ob->ob_y			 	-= 1;
			  ob->ob_width		 	+= 2;
			  ob->ob_height	 	+= 2;
			  ob->ob_type		    = G_USERDEF;
			  ob->ob_flags		   |= TOUCHEXIT;
			  ob->ob_spec		    = (LONG)&circle_blk;
			  break;
		  case DDLINE	  :
#if GEMDOS
			  ob->ob_type		   &= 0x00FF;
#else
			  dline_blk.ub_code   = draw_dline;
			  dline_blk.ub_parm   = ob->ob_spec;
			  ob->ob_type		    = G_USERDEF;
			  ob->ob_spec		    = (LONG)&dline_blk;
#endif
			  break;
		  case DSELFONT	:
			  selfont_blk.ub_code = draw_selfont;
			  selfont_blk.ub_parm = ob->ob_spec;
			  ob->ob_type		    = G_USERDEF;
			  ob->ob_spec		    = (LONG)&selfont_blk;
           ob->ob_x   		   -= 1;
           ob->ob_y    		   -= 1;
           ob->ob_width  		+= 2;
           ob->ob_height 		+= 2;
			  break;
		  case D3DBOX     :
			  threeDbox_blk.ub_code   = draw_3Dbox;
			  threeDbox_blk.ub_parm   = ob->ob_spec;
			  ob->ob_type		    = G_USERDEF;
			  ob->ob_spec		    = (LONG)&threeDbox_blk;
           ob->ob_x   		   -= 1;
           ob->ob_y    		   -= 1;
           ob->ob_width  		+= 2;
           ob->ob_height 		+= 2;
           ob->ob_flags       |= FLAGS15; /* wg. draw_altbutton() */
		     break;
		} /* switch */
/*
printf("\33H%003d ",userdefobjs);
*/
		if(userdefobjs>MAXUSERBLK)
		{
			Bconout(2,7);
			Cconws("\rNot enough memory to support USERDEFs!\r\nPress any key to abort...");
			while(!kbhit())
				;
			_exit(-1);
		}
	 } while (! (ob->ob_flags & LASTOB));
  } /* if */
} /* fix_objs */

