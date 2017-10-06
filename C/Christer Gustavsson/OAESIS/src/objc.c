/****************************************************************************

 Module
  objc.c
  
 Description
  Resource object routines in oAESis.
  
 Author(s)
 	cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)
 	
 Revision history
 
  951229 cg
   Added standard header.
   get_cliprect() renamed to Objc_area_needed().

  960324 cg
   Changed behaviour of objc_find() so that the object that is last drawn
   is found instead of the first suitable. Why doesn't programs like
   Thing just hide the text lines it doesn't use? Bloody annoying!
 
  960405 cg
   Changed Objc_do_draw into a non recursive function. This way less stack
   is needed => (hopefully) fewer crashes.

  960414 cg
   Fixes for INDIRECT ob_spec mode made.
   
  960421 cg
   If the first character of pe_text is '@' draw_text will change it into
   '\0' before drawing modes G_FTEXT and G_FBOXTEXT.
   
  960515 cg
   Added objc_delete(). Papyrus didn't like oAESis' objc_draw() and hung.
   Now papyrus works better :-).
   
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <mintbind.h>
#include <stdio.h>

#include "appl.h"
#include "debug.h"
#include "gemdefs.h"
#include "global.h"
#include "misc.h"
#include "objc.h"
#include "types.h"
#include "vdi.h"

/****************************************************************************
 * Macros                                                                   *
 ****************************************************************************/

#define	SWRM_TRANS		0
#define	SWRM_REPLACE	1
#define	SWRM_INVTRANS	4

#define FLD3DANY 0x0600

/****************************************************************************
 * Typedefs of module global interest                                       *
 ****************************************************************************/

typedef struct tiext {
	unsigned	framecol    : 4;
	unsigned	textcol     : 4;
	unsigned	textmode    : 1;
	unsigned	fillpattern : 3;
	unsigned	interiorcol : 4;
}TIEXT;

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

static WORD num_planes;

static WORD	textyoffs = 8;

static struct {
	WORD br;        /* Colour used for bottom right 3d edge */
	WORD tl;        /* Colour used for top left 3d edge */
	WORD border;    /* Colour used for edging */
	WORD highlight; /* Colour used for highlighting */
	
	WORD colour_ind; /* Default indicator colour */
	WORD move_ind;   /* Indicates whether indicator text should be moved */
	WORD alter_ind;  /* Indicates whether indicator colour should be changed */
	
	WORD colour_act; /* Default activator colour */
	WORD move_act;   /* Indicates whether activator text should be moved */
	WORD alter_act;  /* Indicates whether activator colour should be changed */
	
	WORD colour_bkg; /* Default background colour */
}ocolours = {
	LBLACK,
	WHITE,
	BLACK,
	BLUE,
	
	LWHITE, 1, 1,
	
	LWHITE, 1, 0,
	
	LWHITE
};

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/

static WORD	invertcolor(WORD color) {
	switch(color) {
		case	BLACK:
			return	WHITE;
		case	WHITE:
			return	BLACK;
		case	BLUE:
			return	LYELLOW;
		case	LYELLOW:
			return	BLUE;
		case	RED:
			return	LCYAN;
		case	LCYAN:
			return	RED;
		case	GREEN:
			return	LMAGENTA;
		case	LMAGENTA:
			return	GREEN;
		case	CYAN:
			return	LRED;
		case	LRED:
			return	CYAN;
		case	YELLOW:
			return	LBLUE;
		case	LBLUE:
			return	YELLOW;
		case	MAGENTA:
			return	LGREEN;
		case	LGREEN:
			return	MAGENTA;
		case	LWHITE:
			return	LBLACK;
		case	LBLACK:
			return	LWHITE;
		default:
			return	BLACK;
	};
}

static void	setfilltype(WORD vid,WORD fill) {
	switch(fill) {
		case 0	:
			Vdi_vsf_interior(vid,0);
			break;
		case 7	:
			Vdi_vsf_interior(vid,1);
			break;
		default	:
			Vdi_vsf_interior(vid,2);
			Vdi_vsf_style(vid,fill);
			break;
	}
}

static void	settxtalign(WORD vid,WORD alignment) {
	Vdi_vst_alignment(vid,alignment,3,&alignment,&alignment);
}

static void	set_write_mode(WORD vid,WORD mode) {
	switch(mode) {
		case	SWRM_TRANS		:	/*transparent*/
			Vdi_vswr_mode(vid,MD_TRANS);
			break;
			
		case	SWRM_REPLACE	:	/*replace*/
			Vdi_vswr_mode(vid,MD_REPLACE);
			break;
			
		case	SWRM_INVTRANS	:	/*0x0004*/
			Vdi_vswr_mode(vid,MD_ERASE);
			break;
	};
}

static void	settextsize(WORD vid,WORD size) {
	switch(size) {
	case	3:	/*large*/
		Vdi_vst_font( vid, globals.fnt_regul_id);
		Vdi_vst_point(vid,globals.fnt_regul_sz,&size,&size,&size,&size);
					
		textyoffs = globals.clheight >> 1;
		break;
	
	case	5:	/*small*/
		Vdi_vst_font( vid, globals.fnt_small_id);
		Vdi_vst_point(vid,globals.fnt_small_sz,&size,&size,&size,&size);
		
		textyoffs = globals.csheight >> 1;	
	};
}

static void	drawtext(WORD vid,BYTE *text,RECT *size,WORD alignment,WORD color
	,WORD textsize,WORD writemode,WORD state) {
	WORD x;
	WORD y;
	WORD txteff = 0;
	
	settextsize(vid,textsize);

	y = size->y + (size->height >> 1) + textyoffs - 1;

	switch(alignment) {
		case	0	:	/*left*/
			x = size->x;
			settxtalign(vid,0);
			break;
		case	1	:	/*right*/
			x = size->x + size->width - 1;
			settxtalign(vid,2);
			break;
		case	2	:	/*center*/
			x = size->x + (size->width >> 1);
			settxtalign(vid,1);
			break;
	};
	
	if(state & DISABLED) {
		txteff |= LIGHT;
	};
	
	Vdi_vst_effects(vid,txteff);
	
	if(state & SELECTED) {
		set_write_mode(vid,writemode);
		
		Vdi_vst_color(vid,invertcolor(color));
		Vdi_v_gtext(vid,x,y,text);
		
		if(writemode == SWRM_REPLACE)
		{
			set_write_mode(vid,SWRM_INVTRANS);
			Vdi_vst_color(vid,BLACK);
			Vdi_v_gtext(vid,x,y,text);
		};
	}
	else {
		set_write_mode(vid,writemode);
		Vdi_vst_color(vid,color);
		Vdi_v_gtext(vid,x,y,text);
	};
}

static void	draw_text(WORD vid,OBJECT *ob,WORD par_x,WORD par_y,WORD is_top) {
	WORD txteff = 0;
	WORD type = ob->ob_type & 0xff;
	BYTE ctext[100];
	BYTE *text = NULL;
	WORD temp;
	WORD tx,ty;
	WORD tcolour = BLACK,bcolour = WHITE;
	WORD bfill = 0;
	WORD writemode = SWRM_TRANS;
	WORD draw3d = ob->ob_flags & FLD3DANY;
	WORD invertcolour = 0;
	U_OB_SPEC ob_spec;
	
	if(ob->ob_flags & INDIRECT) {
		ob_spec = *ob->ob_spec.indirect;
	}
	else {
		ob_spec = ob->ob_spec;
	};

	/* find the text string to draw */
	
	switch(type) {
	case G_FTEXT:
	case G_FBOXTEXT:
		{
			BYTE *ptmplt = ob_spec.tedinfo->te_ptmplt;
			BYTE *ptext = ob_spec.tedinfo->te_ptext;
			BYTE *pctext = ctext;
					
			if(*ptext == '@') {
				*ptext = '\0';
			}
							
			while(*ptmplt) {
				switch(*ptmplt) {
				case '_':
					if(*ptext) {
						*(pctext++) = *(ptext++);
					}
					else {
						*(pctext++) = '_';
					};
	
					ptmplt++;
					break;
					
				default:
					*(pctext++) = *(ptmplt++);
				};
			};
			
			*pctext = '\0';
			text = ctext;
			
			bfill = ob_spec.tedinfo->te_color.pattern;
			bcolour = ob_spec.tedinfo->te_color.fillc;
		};
		break;
		
	case G_TEXT:
	case G_BOXTEXT:
		text = ob_spec.tedinfo->te_ptext;

		bfill = ob_spec.tedinfo->te_color.pattern;
		bcolour = ob_spec.tedinfo->te_color.fillc;
		break;
		
	case G_TITLE:
	case G_STRING:
	case G_BUTTON:
		text = ob_spec.free_string;
		break;

	case G_BOXCHAR:
		ctext[0] = ob_spec.obspec.character;
		ctext[1] = 0;
		text = ctext;

		bfill = ob_spec.obspec.fillpattern;
		bfill = ob_spec.obspec.interiorcol;
	};

	/* set font, alignment, color and writemode */

	if(text) {		
		switch(type) {
		case G_TEXT:
		case G_BOXTEXT:
		case G_FTEXT:
		case G_FBOXTEXT:
			{
				TEDINFO *textblk = (TEDINFO *)ob_spec.tedinfo;

				switch(textblk->te_font)	/* Set the correct text size & font */
				{
					case GDOS_PROP:		/* Use a proportional SPEEDOGDOS font (AES4.1 style) */
					case GDOS_MONO:		/* Use a monospaced SPEEDOGDOS font (AES4.1 style) */
					case GDOS_BITM:		/* Use a GDOS bitmap font (AES4.1 style) */
						Vdi_vst_font(vid,textblk->te_fontid);
						Vdi_vst_point(vid,textblk->te_fontsize,&temp,&temp,&temp,&temp);
						ty = par_y + ob->ob_y + ((ob->ob_height - globals.clheight) / 2);
						break;

					case IBM:		/* Use the standard system font (probably 10 point) */
						Vdi_vst_font(vid,globals.fnt_regul_id);
						Vdi_vst_point(vid,globals.fnt_regul_sz,&temp,&temp,&temp,&temp);
						ty = par_y + ob->ob_y + ((ob->ob_height - globals.clheight) / 2);
						break;

					case SMALL:			/* Use the small system font (probably 8 point) */
						Vdi_vst_font(vid,globals.fnt_small_id);
						Vdi_vst_point(vid,globals.fnt_small_sz,&temp,&temp,&temp,&temp);
						
						ty = par_y + ob->ob_y + ((ob->ob_height - globals.csheight) / 2);
				}
				
				switch(textblk->te_just)			/*Set text alignment - why on earth did */
				{									/* atari use a different horizontal alignment */
				case 0:							/* code for GEM to the one the VDI uses? */
					tx = par_x + ob->ob_x;
					Vdi_vst_alignment(vid,0,5,&temp,&temp);
					break;
				case 1:
					tx = par_x + ob->ob_x + ob->ob_width - 1;
					Vdi_vst_alignment(vid,2,5,&temp,&temp);
					break;
				case 2:
					tx = par_x + ob->ob_x + (ob->ob_width >> 1);
					Vdi_vst_alignment(vid,1,5,&temp,&temp);
				}
				
				tcolour = ob_spec.tedinfo->te_color.textc;

				if(draw3d) {
					writemode = SWRM_TRANS;
				}
				else {
					writemode = ob_spec.tedinfo->te_color.opaque;
				};
				break;
				
			case G_STRING:
			case G_TITLE:
				Vdi_vst_font(vid,globals.fnt_regul_id);
				Vdi_vst_point(vid,globals.fnt_regul_sz,&temp,&temp,&temp,&temp);
				ty = par_y + ob->ob_y + ((ob->ob_height - globals.clheight) / 2);

				tx = par_x + ob->ob_x;
				Vdi_vst_alignment(vid,0,5,&temp,&temp);

				tcolour = BLACK;
		
				if(is_top) {
					writemode = SWRM_REPLACE;
				}
				else {		
					writemode = SWRM_TRANS;
				};
				break;

			case G_BOXCHAR:
				Vdi_vst_font(vid,globals.fnt_regul_id);
				Vdi_vst_point(vid,globals.fnt_regul_sz,&temp,&temp,&temp,&temp);
				ty = par_y + ob->ob_y + ((ob->ob_height - globals.clheight) / 2);

				tx = par_x + ob->ob_x + (ob->ob_width >> 1);
				Vdi_vst_alignment(vid,1,5,&temp,&temp);

				tcolour = ob_spec.obspec.textcol;
				
				if(draw3d) {
					writemode = SWRM_TRANS;
				}
				else {
					writemode = ob_spec.obspec.textmode;
				};
				break;			
				
			case G_BUTTON:
				Vdi_vst_font(vid,globals.fnt_regul_id);
				Vdi_vst_point(vid,globals.fnt_regul_sz,&temp,&temp,&temp,&temp);
				ty = par_y + ob->ob_y + ((ob->ob_height - globals.clheight) / 2);

				tx = par_x + ob->ob_x + (ob->ob_width >> 1);
				Vdi_vst_alignment(vid,1,5,&temp,&temp);

				tcolour = BLACK;
				
				writemode = SWRM_TRANS;
			}
		};
		
			
		if(ob->ob_state & DISABLED) {
			txteff |= LIGHT;
		};
		
		Vdi_vst_effects(vid,txteff);
		
		if(draw3d) {
			if(ob->ob_state & SELECTED) {
				if(((draw3d == FL3DIND) && ocolours.move_ind) ||
					((draw3d == FL3DACT) && ocolours.move_act)) {
					tx += D3DOFFS;
					ty += D3DOFFS;
				};
				
				if(((draw3d == FL3DIND) && ocolours.alter_ind) ||
					((draw3d == FL3DACT) && ocolours.alter_act)) {
					invertcolour = TRUE;
				};
			};
			
			if((bcolour == WHITE) && (bfill == 0)) {
				switch(draw3d) {
				case FL3DACT:
					bcolour = ocolours.colour_act;
					break;

				case FL3DIND:
					bcolour = ocolours.colour_ind;
					break;
					
				case FL3DBAK:
					bcolour = ocolours.colour_bkg;
					break;
				}
				
				bfill = 7;
			};
		}
		else {
			if(ob->ob_state & SELECTED) {
				invertcolour = TRUE;
			};
			
			if(bfill == 0) {
				bcolour = WHITE;
			};
		};
		
		if(!(bcolour < globals.num_pens)) {
			bcolour = BLACK;
		};
		
		if(!(tcolour < globals.num_pens)) {
			tcolour = BLACK;
		};
		
		if((tcolour == bcolour) && (bfill == 7)) {
			tcolour = invertcolor(tcolour);
		};
		
		if(invertcolour) {
			tcolour = invertcolor(tcolour);
			bcolour = invertcolor(bcolour);
		};

		if((writemode == SWRM_REPLACE) && (bcolour != WHITE)) {
			set_write_mode(vid,SWRM_INVTRANS);
			Vdi_vst_color(vid,bcolour);
			Vdi_v_gtext(vid,tx,ty,text);
			
			set_write_mode(vid,SWRM_TRANS);
		}
		else {
			set_write_mode(vid,writemode);
		};
		
		Vdi_vst_color(vid,tcolour);
		Vdi_v_gtext(vid,tx,ty,text);
	};
}

static void	drawframe(WORD vid,RECT *r,WORD framesize) {
	WORD incr;
	WORD size[10];
	WORD thick;
	
	if(framesize) {
		if(framesize > 0) {
			thick = framesize;
			incr = 1;
			size[0] = size[6] = size[8] = r->x;
			size[1] = size[3] = size[9] = r->y;
			size[2] = size[4] = size[0] + r->width - 1;
			size[5] = size[7] = size[1] + r->height - 1;
		}
		else {
			thick =  -framesize;
			incr = -1;
			size[0] = size[6] = size[8] = r->x - 1;
			size[1] = size[3] = size[9] = r->y - 1;
			size[2] = size[4] = r->x + r->width;
			size[5] = size[7] = r->y + r->height;
		};
			
		while(thick > 0) {
			Vdi_v_pline(vid,5,size);
			thick--;
			if(!thick) {
				break;
			};
				
				
			size[0] += incr;
			size[1] += incr;
			size[2] -= incr;
			size[3] += incr;
			size[4] -= incr;
			size[5] -= incr;
			size[6] += incr;
			size[7] -= incr;
			size[8] += incr;
			size[9] += incr;		
		};
	};
}

static void	draw_filled_rect(WORD vid,RECT *r) {
	WORD size[4];
	
	size[0] = r->x;
	size[1] = r->y;
	size[2] = r->width + size[0] - 1;
	size[3] = r->height + size[1] - 1;

	Vdi_vr_recfl(vid,size);
}


static void	draw_bg(WORD vid,OBJECT *ob,WORD par_x,WORD par_y) {
	WORD      type = ob->ob_type & 0xff;
	RECT      r;
	WORD      draw = 1;
	WORD      filltype;
	WORD      fillcolour;
	WORD      bcolour = WHITE;
	WORD      mode3d;
	WORD      invertcolour = 0;
	U_OB_SPEC ob_spec;
	
	if(ob->ob_flags & INDIRECT) {
		ob_spec = *ob->ob_spec.indirect;
	}
	else {
		ob_spec = ob->ob_spec;
	};

	switch(type) {
	case G_BOXCHAR:
	case G_BOX		:
		r.x = ob->ob_x + par_x;
		r.y = ob->ob_y + par_y;
		r.width = ob->ob_width;
		r.height = ob->ob_height;
						
		fillcolour = ob_spec.obspec.interiorcol;
		filltype = ob_spec.obspec.fillpattern;
		break;
		
	case G_BOXTEXT:
	case G_FBOXTEXT:
		{
			r.x = ob->ob_x + par_x;
			r.y = ob->ob_y + par_y;
			r.width = ob->ob_width;
			r.height = ob->ob_height;
			
			fillcolour = ob_spec.tedinfo->te_color.fillc;
			filltype = ob_spec.tedinfo->te_color.pattern;
		};
		break;

	case G_STRING:
	case G_TITLE:
		if(ob->ob_state & SELECTED) {
			r.x = ob->ob_x + par_x;
			r.y = ob->ob_y + par_y;
			r.width = ob->ob_width;
			r.height = ob->ob_height;
			
			fillcolour = WHITE;

			if(ob->ob_flags & FLD3DANY) {
				filltype = 0;
			}
			else {
				filltype = 7;
			};
		}
		else {
			draw = 0;
		};
		break;

	case G_BUTTON:
		r.x = ob->ob_x + par_x;
		r.y = ob->ob_y + par_y;
		r.width = ob->ob_width;
		r.height = ob->ob_height;
		
		fillcolour = WHITE;

		if(ob->ob_flags & FLD3DANY) {
			filltype = 0;
		}
		else {
			filltype = 7;
		};
		break;	
		
	default:
		draw = 0;
	};

	if(draw) {
		mode3d = ob->ob_flags & FLD3DANY;
		
		if(mode3d) {
			if((mode3d == FL3DACT) || (mode3d == FL3DIND)) {
					r.x--;
					r.y--;
					r.width += 2;
					r.height += 2;
			};
			
			if((fillcolour == WHITE) && (filltype == 0)) {
				switch(mode3d) {
				case FL3DACT:
					fillcolour = ocolours.colour_act;
					break;

				case FL3DIND:
					fillcolour = ocolours.colour_ind;
					break;
					
				case FL3DBAK:
					fillcolour = ocolours.colour_bkg;
					break;
				};

				filltype = 7;
			};

			if(ob->ob_state & SELECTED) {
				if(((mode3d == FL3DIND) && ocolours.alter_ind) ||
					((mode3d == FL3DACT) && ocolours.alter_act)) {
					invertcolour = TRUE;
				};
			};
		}
		else if(ob->ob_state & SELECTED) {
			invertcolour = TRUE;
		};

		set_write_mode(vid,SWRM_REPLACE);
		
		if(!(fillcolour < globals.num_pens)) {
			fillcolour = BLACK;
		};
		
		if(!(bcolour < globals.num_pens)) {
			bcolour = BLACK;
		};
		
		if(invertcolour) {
			fillcolour = invertcolor(fillcolour);
			bcolour = invertcolor(bcolour);
		};
		
		if(filltype != 7) {
			Vdi_vsf_color(vid,bcolour);
			setfilltype(vid,7);
	
			draw_filled_rect(vid,&r);
		};
		
		if(filltype != 0) {		
			set_write_mode(vid,SWRM_TRANS);
			Vdi_vsf_color(vid,fillcolour);

			setfilltype(vid,filltype);
			draw_filled_rect(vid,&r);
		};
	};
}

static void draw_3dshadow(WORD vid,RECT *r,WORD selected) {
	WORD pnt[6];

	if (selected) {
		Vdi_vsl_color(vid,ocolours.br);
	}
	else {
		Vdi_vsl_color(vid,ocolours.tl);
	};

	pnt[0] = r->x;
	pnt[1] = r->y + r->height - 1;
	pnt[2] = r->x;
	pnt[3] = r->y;
	pnt[4] = r->x + r->width - 1;
	pnt[5] = r->y;
	Vdi_v_pline(vid,3,pnt);

	if (selected) {
		Vdi_vsl_color(vid,ocolours.tl);
	}
	else {
		Vdi_vsl_color(vid,ocolours.br);
	};

	pnt[0] = r->x + 1;
	pnt[1] = r->y + r->height - 1;
	pnt[2] = r->x + r->width - 1;
	pnt[3] = r->y + r->height - 1;
	pnt[4] = r->x + r->width - 1;
	pnt[5] = r->y + 1;
	Vdi_v_pline(vid,3,pnt);
}

static void	draw_frame(WORD vid,OBJECT *ob,WORD par_x,WORD par_y) {
	WORD      type = ob->ob_type & 0xff;
	RECT      r;
	WORD      draw = 1;
	WORD      framesize;
	U_OB_SPEC ob_spec;
	
	if(ob->ob_flags & INDIRECT) {
		ob_spec = *ob->ob_spec.indirect;
	}
	else {
		ob_spec = ob->ob_spec;
	};

	switch(type) {
	case G_IBOX :
	case G_BOX  :	/*0x14*/
	case G_BOXCHAR:
		{
			r.x = ob->ob_x + par_x;
			r.y = ob->ob_y + par_y;
			r.width = ob->ob_width;
			r.height = ob->ob_height;
			
			framesize = ob_spec.obspec.framesize;

			Vdi_vsl_color(vid,ob_spec.obspec.framecol);
		};
		break;

	case G_BOXTEXT:
	case G_FBOXTEXT:
		{
			r.x = ob->ob_x + par_x;
			r.y = ob->ob_y + par_y;
			r.width = ob->ob_width;
			r.height = ob->ob_height;
			
			framesize = ob_spec.tedinfo->te_thickness;

			Vdi_vsl_color(vid,ob_spec.tedinfo->te_color.borderc);
		};
		break;

	case G_STRING:
		{
			r.x = ob->ob_x + par_x;
			r.y = ob->ob_y + par_y;
			r.width = ob->ob_width;
			r.height = ob->ob_height;
			
			framesize = 0;
		};
		break;

	case G_BUTTON:
		{
			r.x = ob->ob_x + par_x;
			r.y = ob->ob_y + par_y;
			r.width = ob->ob_width;
			r.height = ob->ob_height;
			
			if(ob->ob_flags & DEFAULT) {
				framesize = -DEFBUTFRAME;
			}
			else {
				framesize = -BUTTONFRAME;
			};

			Vdi_vsl_color(vid,BLACK);
		};
		break;
			
	default:
		draw = 0;
	};

	if(draw) {
		WORD mode3d = ob->ob_flags & FLD3DANY;

		Vdi_vsl_type(vid,1);
		
		set_write_mode(vid,SWRM_REPLACE);

		if((mode3d == FL3DIND) || (mode3d == FL3DACT)) {
			r.x -= D3DSIZE;
			r.y -= D3DSIZE;
			r.width += D3DSIZE << 1;
			r.height += D3DSIZE << 1;
			
			drawframe(vid,&r,framesize);

			if(framesize > 0) {
				r.x += framesize;
				r.y += framesize;
				r.width -= framesize << 1;
				r.height -= framesize << 1;			
			};

			draw_3dshadow(vid,&r,ob->ob_state & SELECTED);
		}
		else {
			drawframe(vid,&r,framesize);

			if(ob->ob_state & OUTLINED) {
				r.x -= OUTLINESIZE;	
				r.y -= OUTLINESIZE;	
				r.width += OUTLINESIZE << 1;	
				r.height += OUTLINESIZE << 1;
				
				
				if(mode3d == FL3DBAK) {
					WORD i = OUTLINESIZE - 1;
					
					Vdi_vsl_color(vid,ocolours.br);
					drawframe(vid,&r,1);
					
					while(i--) {
						r.x++;
						r.y++;
						r.width -= 2;
						r.height -= 2;
						draw_3dshadow(vid,&r,0);
					};
				}
				else {
					drawframe(vid,&r,1);

					Vdi_vsl_color(vid,WHITE);
			
					r.x += 1;
					r.y += 1;
					r.width -= 2;
					r.height -= 2;
			
					drawframe(vid,&r,OUTLINESIZE - 1);
				};
			}
		};
	};
}

static void drawimage(WORD vid,WORD x,WORD y,BITBLK *bb,WORD state) {
	MFDB	d,s;

	WORD	xyarray[8];
	WORD	colour[2];
	
	xyarray[0] = 0;
	xyarray[1] = 0;
	xyarray[2] = (bb->bi_wb << 3) - 1;
	xyarray[3] = bb->bi_hl - 1;
	xyarray[4] = x + bb->bi_x;
	xyarray[5] = y + bb->bi_y;
	xyarray[6] = x + bb->bi_x + (bb->bi_wb << 3) - 1;
	xyarray[7] = y + bb->bi_y + bb->bi_hl - 1;

	(LONG)s.fd_addr = (LONG)bb->bi_pdata;
	s.fd_w = (bb->bi_wb << 3);
	s.fd_h = bb->bi_hl;
	s.fd_wdwidth = (bb->bi_wb >> 1);
	s.fd_stand = 0;
	s.fd_nplanes = 1;

	(LONG)d.fd_addr = 0L;

	colour[0] = bb->bi_color;
	
	if(!(colour[0] < globals.num_pens)) {
		colour[0] = BLACK;
	};
	
	if(state & SELECTED) {
		colour[0] = invertcolor(colour[0]);
	};

	Vdi_vrt_cpyfm(vid,MD_TRANS,xyarray,&s,&d,colour);
}

static void drawicon(WORD vid,WORD x,WORD y,ICONBLK *ib,WORD state) {
	BYTE	ch[2];
	
	MFDB	d,s;

	WORD xyarray[8];
	WORD color[2];
	WORD icon_colour = ib->ib_char >> 12;
	WORD mask_colour = (ib->ib_char & 0x0f00) >> 8;
	
	RECT	r;
	
	if(!(mask_colour < globals.num_pens)) {
		mask_colour = BLACK;
	};
	
	if(!(icon_colour < globals.num_pens)) {
		icon_colour = BLACK;
	};
	
	xyarray[0] = 0;
	xyarray[1] = 0;
	xyarray[2] = ib->ib_wicon - 1;
	xyarray[3] = ib->ib_hicon - 1;
	xyarray[4] = x + ib->ib_xicon;
	xyarray[5] = y + ib->ib_yicon;
	xyarray[6] = x + ib->ib_xicon + ib->ib_wicon - 1;
	xyarray[7] = y + ib->ib_yicon + ib->ib_hicon - 1;

	(LONG)s.fd_addr = (LONG)ib->ib_pmask;
	s.fd_w = ib->ib_wicon;
	s.fd_h = ib->ib_hicon;
	s.fd_wdwidth = ((ib->ib_wicon +15) >> 4);
	s.fd_stand = 0;
	s.fd_nplanes = 1;

	(LONG)d.fd_addr = 0L;

	if(state & SELECTED) {
		color[0] = icon_colour;
	}
	else {
		color[0] = mask_colour;
	};
	
	Vdi_vrt_cpyfm(vid,MD_TRANS,xyarray,&s,&d,color);

	if(state & SELECTED) {
		color[0] = mask_colour;
	}
	else {
		color[0] = icon_colour;
	};
	
	(LONG)s.fd_addr = (LONG)ib->ib_pdata;
	Vdi_vrt_cpyfm(vid,MD_TRANS,xyarray,&s,&d,color);

	r.x = x + ib->ib_xtext;
	r.y = y + ib->ib_ytext;
	r.width = ib->ib_wtext;
	r.height = ib->ib_htext;

	drawtext(vid,ib->ib_ptext,&r,2,ib->ib_char >> 12,5,MD_REPLACE,state);

	r.x = x + ib->ib_xchar;
	r.y = y + ib->ib_ychar;
	r.width = 0;
	r.height = 0;
	
	ch[0] = ib->ib_char & 0x00ff;
	ch[1] = 0;

	drawtext(vid,ch,&r,0,ib->ib_char >> 12,5,MD_REPLACE,state);
}

static void drawcicon(WORD vid,WORD x,WORD y,CICONBLK *cib,WORD state) {
	BYTE	ch[2];
	
	MFDB	d,s;

	WORD	xyarray[8];
	WORD	color[] = {WHITE,BLACK};
	
	RECT	r;
	CICON *best = NULL,*ciwalk = cib->mainlist;
	WORD  bestplanes = 0;

	while(ciwalk) {
		if((ciwalk->num_planes <= num_planes) &&
			(ciwalk->num_planes > bestplanes)) {
			best = ciwalk;
			bestplanes = best->num_planes;
			
			if(bestplanes == num_planes) {
				break;
			};
		};
		
		ciwalk = ciwalk->next_res;
	};

	if(!best) {
		drawicon(vid,x,y,&cib->monoblk,state);
	}
	else {
		xyarray[0] = 0;
		xyarray[1] = 0;
		xyarray[2] = cib->monoblk.ib_wicon - 1;
		xyarray[3] = cib->monoblk.ib_hicon - 1;
		xyarray[4] = x + cib->monoblk.ib_xicon;
		xyarray[5] = y + cib->monoblk.ib_yicon;
		xyarray[6] = x + cib->monoblk.ib_xicon + cib->monoblk.ib_wicon - 1;
		xyarray[7] = y + cib->monoblk.ib_yicon + cib->monoblk.ib_hicon - 1;
	
		(LONG)s.fd_addr = (LONG)best->col_mask;
		s.fd_w = cib->monoblk.ib_wicon;
		s.fd_h = cib->monoblk.ib_hicon;
		s.fd_wdwidth = ((cib->monoblk.ib_wicon +15) >> 4);
		s.fd_stand = 0;
		s.fd_nplanes = 1;
	
		(LONG)d.fd_addr = 0L;
	
		Vdi_vrt_cpyfm(vid,MD_TRANS,xyarray,&s,&d,color);

		s.fd_nplanes = best->num_planes;	
		(LONG)s.fd_addr = (LONG)best->col_data;
		
		Vdi_vro_cpyfm(vid,S_OR_D,xyarray,&s,&d);
	
		r.x = x + cib->monoblk.ib_xtext;
		r.y = y + cib->monoblk.ib_ytext;
		r.width = cib->monoblk.ib_wtext;
		r.height = cib->monoblk.ib_htext;
	
		drawtext(vid,cib->monoblk.ib_ptext,&r,2,cib->monoblk.ib_char >> 12,5,MD_REPLACE,state);
	
		r.x = x + cib->monoblk.ib_xchar;
		r.y = y + cib->monoblk.ib_ychar;
		r.width = 0;
		r.height = 0;
		
		ch[0] = cib->monoblk.ib_char & 0x00ff;
		ch[1] = 0;
	
		drawtext(vid,ch,&r,0,cib->monoblk.ib_char >> 12,5,MD_REPLACE,state);
	};
}

static void draw_object(WORD vid,OBJECT *tree,WORD object,RECT *clip,WORD par_x,WORD par_y,WORD is_top) {
	WORD      type = tree[object].ob_type & 0xff;
	U_OB_SPEC ob_spec;
	RECT      ci = *clip, cu;
	
	ci.x -= par_x;
	ci.y -= par_y;
	
	if(!Misc_intersect((RECT *)&tree[object].ob_x,&ci,&cu)) {
		return;
	};

	if(tree[object].ob_flags & INDIRECT) {
		ob_spec = *tree[object].ob_spec.indirect;
	}
	else {
		ob_spec = tree[object].ob_spec;
	};
			
	switch(type) {			
		case G_IMAGE: /*0x17*/
			drawimage(vid,tree[object].ob_x + par_x,tree[object].ob_y + par_y
				,(BITBLK *)ob_spec.index,tree[object].ob_state);
			break;
	
		case G_PROGDEF: /*0x18*/
			{
				PARMBLK pb;
				WORD    remainstate;
				RECT    oclip;

				pb.pb_tree = tree;
				pb.pb_obj = object;
				pb.pb_prevstate = tree[object].ob_state;
				pb.pb_currstate = tree[object].ob_state;
				
				Objc_do_offset(tree,object,(WORD *)&pb.pb_x);
				pb.pb_w = tree[object].ob_width;
				pb.pb_h = tree[object].ob_height;
				
				Objc_calc_clip(tree,object,&oclip);
				
				if(Misc_intersect(&oclip,clip,(RECT *)&pb.pb_xc)) {
					pb.pb_parm = ob_spec.userblk->ub_parm;

					remainstate = ob_spec.userblk->ub_code(&pb);
					
					NOT_USED(remainstate);
				};
			};
			break;

		case	G_ICON:
			drawicon(vid,tree[object].ob_x + par_x,tree[object].ob_y + par_y
				,ob_spec.iconblk,tree[object].ob_state);
			break;
		
		case	G_CICON:
			drawcicon(vid,tree[object].ob_x + par_x,tree[object].ob_y + par_y
				,(CICONBLK *)ob_spec.index,tree[object].ob_state);
			
			break;
			
		
		default:
			draw_bg(vid,&tree[object],par_x,par_y);
			draw_text(vid,&tree[object],par_x,par_y,is_top);
			draw_frame(vid,&tree[object],par_x,par_y);
	}

	if(tree[object].ob_state & CHECKED) {
		WORD dum;
		
		Vdi_vst_alignment(vid,0,5,&dum,&dum);
		Vdi_v_gtext(vid,tree[object].ob_x + par_x,tree[object].ob_y + par_y,
			"\x8");
	};
}

static void get_char_bound(OBJECT *tree,WORD obj,WORD object,WORD last,
														RECT *r) {
	BYTE      *ptmplt;
	WORD      firstreal = 0,lastreal = 0;
	U_OB_SPEC ob_spec;
	
	if(tree[obj].ob_flags & INDIRECT) {
		ob_spec = *tree[obj].ob_spec.indirect;
	}
	else {
		ob_spec = tree[obj].ob_spec;
	};

	ptmplt = ob_spec.tedinfo->te_ptmplt;
	
	while(*ptmplt) {
		if(*ptmplt == '_') {
			object--;
			last--;
		};

		if(object >= 0) {
			firstreal++;
		};
		
		if(last >= 0) {
			lastreal++;
		};
		
		ptmplt++;
	};

	Objc_do_offset(tree,obj,(WORD *)r);

	r->y += (tree[obj].ob_height - globals.clheight) >> 1;
	r->height = globals.clheight;
	r->width = globals.clwidth * (lastreal - firstreal);
	
	switch(ob_spec.tedinfo->te_just) {
	case	0	:
		break;
	case	1	:
		r->x += (tree[obj].ob_width - 
						(globals.clwidth * (WORD)strlen(ob_spec.tedinfo->te_ptmplt)));
		break;
	case	2	:
		r->x += ((tree[obj].ob_width -
						(globals.clwidth * (WORD)strlen(ob_spec.tedinfo->te_ptmplt))) >> 1);
		break;
	};

	r->x = r->x + (firstreal * globals.clwidth);
}

static void draw_cursor(WORD vid,WORD pos,OBJECT *tree,WORD obj) {
	RECT r;
	WORD xy[4];
	
	get_char_bound(tree,obj,pos,pos,&r);

	xy[0] = r.x;
	xy[1] = r.y;
	xy[2] = xy[0];
	xy[3] = xy[1] + r.height;

	Vdi_vswr_mode(vid,MD_XOR);
	Vdi_v_pline(vid,2,xy);
}

static WORD handle_ed_char(WORD vid,WORD idx,OBJECT *tree,WORD obj,
						WORD kc) {
	RECT      clip;
	U_OB_SPEC ob_spec;
	
	if(tree[obj].ob_flags & INDIRECT) {
		ob_spec = *tree[obj].ob_spec.indirect;
	}
	else {
		ob_spec = tree[obj].ob_spec;
	};
	
	switch(kc) {
	case 0x0e08: /* backspace */
	  if(idx > 0) {
	    draw_cursor(vid,idx,tree,obj);
			
	    strcpy(&ob_spec.tedinfo->te_ptext[idx - 1],
		   &ob_spec.tedinfo->te_ptext[idx]);
	    
	    get_char_bound(tree,obj,idx - 1,
			   (WORD)strlen(ob_spec.tedinfo->te_ptext)
			   + 2,&clip);

	    Objc_do_draw(vid,tree,0,9,&clip);
			
	    draw_cursor(vid,idx - 1,tree,obj);
	    return idx - 1;
	  };
	  return idx;
		
	case 0x4b00: /* left */
		if(idx > 0) {
			draw_cursor(vid,idx,tree,obj);
			draw_cursor(vid,idx - 1,tree,obj);
			return idx - 1;
		};
		return idx;
	
	case 0x4d00: /* right */
		if(idx < strlen(ob_spec.tedinfo->te_ptext)) {
			draw_cursor(vid,idx,tree,obj);
			draw_cursor(vid,idx + 1,tree,obj);
			return idx + 1;
		};
		return idx;

	case 0x537f: /* delete */
		if(idx < strlen(ob_spec.tedinfo->te_ptext)) {
			draw_cursor(vid,idx,tree,obj);
			
			strcpy(&ob_spec.tedinfo->te_ptext[idx],
							&ob_spec.tedinfo->te_ptext[idx + 1]);

			get_char_bound(tree,obj,idx,
				(WORD)strlen(ob_spec.tedinfo->te_ptext) + 1,&clip);
			Objc_do_draw(vid,tree,0,9,&clip);
			
			draw_cursor(vid,idx,tree,obj);
		};
		return idx;
		
	default:
		if(ob_spec.tedinfo->te_ptext[idx] != '\0') {
			BYTE i = strlen(ob_spec.tedinfo->te_ptext);
			
			while(i >= idx) {
				ob_spec.tedinfo->te_ptext[i + 1] = 
					ob_spec.tedinfo->te_ptext[i];
				
				i--;
			};
		}
		else {
			ob_spec.tedinfo->te_ptext[idx + 1] = '\0';
		};
		
		ob_spec.tedinfo->te_ptext[idx] = (BYTE)kc;

		draw_cursor(vid,idx,tree,obj);
		get_char_bound(tree,obj,idx,
										(WORD)strlen(ob_spec.tedinfo->te_ptext),&clip);
		Objc_do_draw(vid,tree,0,9,&clip);
		draw_cursor(vid,idx + 1,tree,obj);
		
		return idx + 1;
	};
}

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

void	init_objc(void) {	
	WORD work_out[57];
	
	Vdi_vq_extnd(globals.vid,1,work_out);
	
	num_planes = work_out[4];
	
	Vdi_v_show_c(globals.vid,0);

	textyoffs = globals.clheight >> 1;

	/* if we don't have enough colours; use monochrome mode! */
	
	if(globals.num_pens < 16) {
		ocolours.br = BLACK;	       /* Colour used for bottom right 3d edge */
		ocolours.tl = WHITE;         /* Colour used for top left 3d edge */
		ocolours.colour_ind = WHITE; /* Default indicator colour */
		ocolours.colour_act = WHITE; /* Default activator colour */
		ocolours.colour_bkg = WHITE; /* Default background colour */
	};
}

void	exit_objc(void) {
}

void	do_objc_add(OBJECT *t,WORD p,WORD c) {
	if(t[p].ob_tail < 0) {
		t[p].ob_head = c;
		t[p].ob_tail = c;
		t[c].ob_next = p;
	}
	else
	{
		t[c].ob_next = p;
		t[t[p].ob_tail].ob_next = c;
		t[p].ob_tail = c;
	};
}

/*objc_add	0x0028*/

void	Objc_add(AES_PB *apb) {
	do_objc_add((OBJECT *)apb->addr_in[0],apb->int_in[0]
		,apb->int_in[1]);
	
	apb->int_out[0] = 1;
}


/* objc_delete	0x0029 */

void Objc_do_delete(OBJECT *tree,WORD object) {
	WORD i;
	WORD prev = -1;
	WORD next;
	
	i = 0;
	
	next = tree[object].ob_next;
	
	if(next != -1) {
		if(tree[next].ob_tail == object) {
			next = -1;
		}
	}
	
	while(1) {	
		if((tree[i].ob_next == object) && (tree[object].ob_tail != i)) {
			prev = i;
			tree[i].ob_next = tree[object].ob_next;
	
			break;
		}
	
		if(tree[i].ob_flags & LASTOB) {
			break;
		};
		
		i++;
	}
	
	i = 0;
	
	while(1) {	
		if(tree[i].ob_head == object) {
			tree[i].ob_head = next;
		}

		if(tree[i].ob_tail == object) {
			tree[i].ob_tail = prev;
		}

		if(tree[i].ob_flags & LASTOB) {
			break;
		};
		
		i++;
	}
}

void	Objc_delete(AES_PB *apb) {
	Objc_do_delete((OBJECT *)apb->addr_in[0],apb->int_in[0]);
	
	apb->int_out[0] = 1;
}

/*objc_draw	0x002a*/

/****************************************************************************
 * Objc_do_draw                                                             *
 *  Implementation of objc_draw().                                          *
 ****************************************************************************/
WORD              /* 0 if an error occured, or 1.                           */
Objc_do_draw(     /*                                                        */
WORD   vid,       /* VDI workstation id.                                    */
OBJECT *tree,     /* Resource tree.                                         */
WORD   object,    /* Start object.                                          */
WORD   depth,     /* Maximum draw depth.                                    */
RECT   *clip)     /* Clipping rectangle.                                    */
/****************************************************************************/
{
	WORD current = object;
	WORD next;

	WORD xy[2];
	WORD xyxy[4];
	WORD x,y;

	if((tree == NULL) || (object < 0) || (depth < 0) || (clip == NULL)) {
		return 0;
	};

	if(Objc_do_offset(tree,object,xy) == 0) {
		return 0;
	};

	x = xy[0] - tree[object].ob_x;
	y = xy[1] - tree[object].ob_y;

	xyxy[0] = clip->x;
	xyxy[1] = clip->y;
	xyxy[2] = xyxy[0] + clip->width - 1;
	xyxy[3] = xyxy[1] + clip->height - 1;
	
	Vdi_vs_clip(vid,1,xyxy);

	Vdi_v_hide_c(vid);
			
	do {
		if(!(tree[current].ob_flags & HIDETREE)) {
			draw_object(vid,tree,current,clip,x,y,object == current);

			next = tree[current].ob_head;
			
			if(next != -1) {
				x += tree[current].ob_x;
				y += tree[current].ob_y;
			};
		};
		
		if(((next == -1) || (depth <= 0)) && (current == object)) {
			break;
		};
		
		if((depth < 0) || (next == -1) || (tree[current].ob_flags & HIDETREE)) {
			next = tree[current].ob_next;
			
			if(next == -1) {
				break;
			};
						
			while((tree[next].ob_tail == current) && (current != object)) {
				depth++;

				if(current == next) {
					break;
				};
	
				current = next;

				x -= tree[current].ob_x;
				y -= tree[current].ob_y;

				next = tree[current].ob_next;

				if(next == -1) {
					break;
				};
			};
			
			if(current == next) {
				break;
			};
			
			if(current != object) {
				current = next;
			};
		}
		else {
			depth--;
			
			current = next;
		};
	}while(current != object);

	Vdi_v_show_c(vid,1);

	Vdi_vs_clip(vid,0,xyxy);
	
	return 1;
}

void	Objc_draw(AES_PB *apb) {
	apb->int_out[0] = Objc_do_draw(apb->global->int_info->vid,(OBJECT *)apb->addr_in[0],apb->int_in[0]
		,apb->int_in[1],(RECT *)&apb->int_in[2]);
}

/*objc_find 0x002b*/

/****************************************************************************
 * Objc_do_find                                                             *
 *  Implementation of objc_find().                                          *
 ****************************************************************************/
WORD              /* Object index, or -1.                                   */
Objc_do_find(     /*                                                        */
OBJECT *t,        /* Resource tree to search.                               */
WORD startobject, /* Start object.                                          */
WORD depth,       /* Maximum depth.                                         */
WORD x,           /* X offset.                                              */
WORD y,           /* Y offset.                                              */
WORD level)       /* Current depth of search.                               */
/****************************************************************************/
{
	if(t[startobject].ob_flags & HIDETREE) {
		return -1;
	};

	if(level == 0) {
		WORD	lxy[2];
		Objc_do_offset(t,startobject,lxy);

		x -= lxy[0];
		y -= lxy[1];
	};
	
	if((x >= 0) && (x < t[startobject].ob_width) 
		&& (y >= 0) && (y < t[startobject].ob_height)) {
		WORD deeper;
		WORD bestobj = startobject;
			
		if((depth > 0) && (t[startobject].ob_head >= 0)) {
			WORD i = t[startobject].ob_head;
			
			while(i != startobject) {
				deeper = Objc_do_find(t,i,depth - 1,
					x - t[i].ob_x,
					y - t[i].ob_y,level + 1);

				if(deeper >= 0) {
					bestobj = deeper;
				};

				i = t[i].ob_next;
			};
		};
		
		return bestobj;
	};
		
	return -1;
}

void	Objc_find(AES_PB *apb) {
	apb->int_out[0] = Objc_do_find((OBJECT *)apb->addr_in[0],apb->int_in[0],
		apb->int_in[1],apb->int_in[2],apb->int_in[3],0);
}

/*objc_offset 0x002c*/

/****************************************************************************
 * Objc_do_offset                                                           *
 *  Implementation of objc_offset().                                        *
 ****************************************************************************/
WORD              /* 0 if error, or 1.                                      */
Objc_do_offset(   /*                                                        */
OBJECT *tree,     /* Resource tree.                                         */
WORD   object,    /* Object index.                                          */
WORD   *xy)       /* X and Y coordinates of object if successfull.          */
/****************************************************************************/
{
	if((tree == NULL)) {
		return 0;
	};
	
	xy[0] = 0;
	xy[1] = 0;
	
	do {
		WORD	last;
		
		xy[0] += tree[object].ob_x;
		xy[1] += tree[object].ob_y;
		
		if((tree[object].ob_next < 0) || (object == 0)) {
			break;
		};
		
		do {
			last = object;
			object = tree[object].ob_next;
		}while(last != tree[object].ob_tail);	
	}while(1);
	
	if(object == 0) {
		return 1;
	}
	else {
		return 0;
	};
}


void	Objc_offset(AES_PB *apb) {
	apb->int_out[0] = Objc_do_offset((OBJECT *)apb->addr_in[0]
		,apb->int_in[0], &apb->int_out[1]);
};

/****************************************************************************
 * Objc_do_edit                                                             *
 *  Implementation of objc_edit().                                          *
 ****************************************************************************/
WORD              /* 0 if an error occured, or 1.                           */
Objc_do_edit(     /*                                                        */
WORD   vid,       /* VDI workstation handle.                                */
OBJECT *tree,     /* Resource tree.                                         */
WORD   obj,       /* Object index.                                          */
WORD   kc,        /* Key code to process.                                   */
WORD   *idx,      /* Character index.                                       */
WORD   mode)      /* Edit mode.                                             */
/****************************************************************************/
{
	WORD      type;
	U_OB_SPEC ob_spec;

	if(tree[obj].ob_flags & INDIRECT) {
		ob_spec = *tree[obj].ob_spec.indirect;
	}
	else {
		ob_spec = tree[obj].ob_spec;
	};
	
	if((obj < 0) || (tree == NULL) || (idx == NULL)) {
		return 0;
	};
	
	if(((type = tree[obj].ob_type & 0xff) != G_FTEXT) &&
			(type != G_FBOXTEXT)) {
		return 0;
	};
	
	switch(mode) {
	case ED_INIT:
		*idx = (WORD)strlen(ob_spec.tedinfo->te_ptext);
		draw_cursor(vid,*idx,tree,obj);
		break;
	
	case ED_CHAR:
		*idx = handle_ed_char(vid,*idx,tree,obj,kc);
		break;
		
	case ED_END:
		draw_cursor(vid,*idx,tree,obj);
		break;
		
	default:
		DB_printf("%s: Line %d: Objc_do_edit:\r\n"
						"Unknown mode %d\r\n",__FILE__,__LINE__,mode);
		return 0;
	}

	return 1;
}

/****************************************************************************
 * Objc_edit                                                                *
 *   0x002e objc_edit().                                                    *
 ****************************************************************************/
void              /*                                                        */
Objc_edit(        /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	apb->int_out[1] = apb->int_in[2];
	apb->int_out[0] = Objc_do_edit(apb->global->int_info->vid,
										(OBJECT *)apb->addr_in[0],apb->int_in[0],
										apb->int_in[1],&apb->int_out[1],
										apb->int_in[3]);
}

/****************************************************************************
 * Objc_do_change                                                           *
 *  Implementation of objc_change().                                        *
 ****************************************************************************/
WORD              /* 0 if an error occured, or 1.                           */
Objc_do_change(   /*                                                        */
WORD   vid,       /* VDI workstation handle.                                */
OBJECT *tree,     /* Resource tree.                                         */
WORD   obj,       /* Object index.                                          */
RECT   *clip,     /* Clipping rectangle.                                    */
WORD   newstate,  /* New object state.                                      */
WORD   drawflag)  /* Drawing flag.                                          */
/****************************************************************************/
{
	if(vid == -1) {
		return 0;
	};
	
	tree[obj].ob_state = newstate;
	
	if(drawflag == REDRAW) {
		Objc_do_draw(vid,tree,obj,9,clip);
	};
	
	return 1;
}

/****************************************************************************
 * Objc_change                                                              *
 *   0x002f objc_change().                                                  *
 ****************************************************************************/
void              /*                                                        */
Objc_change(      /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	apb->int_out[0] = Objc_do_change(apb->global->int_info->vid,
										(OBJECT *)apb->addr_in[0],apb->int_in[0],
										(RECT *)&apb->int_in[2],
										apb->int_in[6],apb->int_in[7]);
}

/****************************************************************************
 * Objc_do_sysvar                                                           *
 *  Implementation of objc_sysvar().                                        *
 ****************************************************************************/
WORD              /* 0 if an error occured, or 1.                           */
Objc_do_sysvar(   /*                                                        */
WORD   mode,      /* Operation mode.                                        */
WORD   which,     /* Variable to read/alter.                                */
WORD   in1,       /* Inparameter 1.                                         */
WORD   in2,       /* Inparameter 2.                                         */
WORD   *out1,     /* Outparameter 1.                                        */
WORD   *out2)     /* Outparameter 2.                                        */
/****************************************************************************/
{
	if(mode == SV_INQUIRE) {
		switch(which) {
		case LK3DIND:
			*out1 = ocolours.move_ind;
			*out2 = ocolours.alter_ind;
			return 1;

		case LK3DACT:
			*out1 = ocolours.move_act;
			*out2 = ocolours.alter_act;
			return 1;
		
		case INDBUTCOL:
			*out1 = ocolours.colour_ind;
			return 1;

		case ACTBUTCOL:
			*out1 = ocolours.colour_act;
			return 1;

		case BACKGRCOL:
			*out1 = ocolours.colour_bkg;
			return 1;
		
		case AD3DVAL:
			*out1 = D3DSIZE;
			*out2 = D3DSIZE;
			return 1;
		};
	}
	else if(mode == SV_SET) {
		switch(which) {
		case LK3DIND:
			ocolours.move_ind = in1;
			ocolours.alter_ind = in2;
			return 1;

		case LK3DACT:
			ocolours.move_act = in1;
			ocolours.alter_act = in2;
			return 1;
		
		case INDBUTCOL:
			ocolours.colour_ind = in1;
			return 1;

		case ACTBUTCOL:
			ocolours.colour_act = in1;
			return 1;

		case BACKGRCOL:
			ocolours.colour_bkg = in1;
			return 1;
		};
	};

	DB_printf("Objc_do_sysvar: mode=%d which=%d",mode,which);

	return 0;
}

/****************************************************************************
 * Objc_sysvar                                                              *
 *  0x0030 objc_sysvar().                                                   *
 ****************************************************************************/
void              /*                                                        */
Objc_sysvar(      /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	apb->int_out[0] = Objc_do_sysvar(apb->int_in[0],apb->int_in[1],apb->int_in[2],
									apb->int_in[3],&apb->int_out[1],&apb->int_out[2]);
}


/****************************************************************************
 *  Objc_area_needed                                                        *
 *   Calculate how large area an object covers.                             *
 ****************************************************************************/
void              /*                                                        */
Objc_area_needed( /*                                                        */
OBJECT *tree,     /* Pointer to the root of the resource tree.              */
WORD   object,    /* Index of interesting object.                           */
RECT   *rect)     /* Buffer where the requested area size will be placed.   */
/****************************************************************************/
{
	WORD mode3d = tree[object].ob_flags & FLD3DANY;
	U_OB_SPEC ob_spec;
	
	if(tree[object].ob_flags & INDIRECT) {
		ob_spec = *tree[object].ob_spec.indirect;
	}
	else {
		ob_spec = tree[object].ob_spec;
	};
	
	Objc_do_offset(tree,object,(WORD *)rect);
	
	rect->width = tree[object].ob_width;
	rect->height = tree[object].ob_height;
	
	switch(tree[object].ob_type) {
		case	G_BOX:
		case	G_IBOX:
		case	G_BOXCHAR:
			if(ob_spec.obspec.framesize < 0) {
				rect->x += ob_spec.obspec.framesize;
				rect->y += ob_spec.obspec.framesize;
				rect->width -= (ob_spec.obspec.framesize << 1);
				rect->height -= (ob_spec.obspec.framesize << 1);
			};
			break;
		case	G_BUTTON:
			if(tree[object].ob_flags & DEFAULT) {
				rect->x -= DEFBUTFRAME;
				rect->y -= DEFBUTFRAME;
				rect->width += (DEFBUTFRAME << 1);
				rect->height += (DEFBUTFRAME << 1);
			}
			else {
				rect->x -= BUTTONFRAME;
				rect->y -= BUTTONFRAME;
				rect->width += (BUTTONFRAME << 1);
				rect->height += (BUTTONFRAME << 1);
			};
			break;
	};
	
	if(tree[object].ob_state & OUTLINED) {
		rect->x -= OUTLINESIZE;
		rect->y -= OUTLINESIZE;
		rect->width += (OUTLINESIZE << 1);
		rect->height += (OUTLINESIZE << 1);
	};

	if((mode3d == FL3DIND) || (mode3d == FL3DACT)) {
		rect->x -= D3DSIZE;
		rect->y -= D3DSIZE;
		rect->width += (D3DSIZE << 1);
		rect->height += (D3DSIZE << 1);
	};
}

/****************************************************************************
 *  Objc_calc_clip                                                          *
 *   Calculate required clip area for object.                               *
 ****************************************************************************/
void              /*                                                        */
Objc_calc_clip(   /*                                                        */
OBJECT *tree,     /* Pointer to the root of the resource tree.              */
WORD   object,    /* Index of interesting object.                           */
RECT   *rect)     /* Buffer where the requested area size will be placed.   */
/****************************************************************************/
{
	WORD owalk = object;
	
	while(1) {
		if(tree[owalk].ob_next == -1) {
			owalk = -1;
			break;
		};
		
		if(tree[tree[owalk].ob_next].ob_tail == owalk) {
			owalk = tree[owalk].ob_next;
			break;
		};
		
		owalk = tree[owalk].ob_next;
	};
	
	if(owalk == -1) {
		Objc_area_needed(tree,object,rect);
	}
	else {
		Objc_do_offset(tree,owalk,(WORD *)rect);
	
		rect->width = tree[owalk].ob_width;
		rect->height = tree[owalk].ob_height;
	};
}
