/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <stdlib.h>
#ifdef LATTICE
#undef abs		/* MiNTlib (PL46) #define is buggy! */
#define abs(i)	__builtin_abs(i)
#endif
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "K_DEFS.H"
#include "RECTLIST.H"
#include "BOX3D.H"
#include "objects.h"

/*
	OBJECT TREE ROUTINES
*/

const short selected_colour[]={1,0,13,15,14,10,12,11,8,9,5,7,6,2,4,3};
const short selected3D_colour[]={1,0,13,15,14,10,12,11,9,8,5,7,6,2,4,3};

short global_clip[4];	/* Bloody progdefs need to know the clip rectangle */

void set_clip(short x, short y, short w, short h)
{
	global_clip[0]=x;
	global_clip[1]=y;
	global_clip[2]=x+w-1;
	global_clip[3]=y+h-1;
	vs_clip(V_handle,1,global_clip);
}

/* Set clipping to entire screen */
void clear_clip(void)
{
	global_clip[0]=display.x;
	global_clip[1]=display.y;
	global_clip[2]=display.x+display.w-1;
	global_clip[3]=display.y+display.h-1;
	vs_clip(V_handle,1,global_clip);
}

/*
	Draw a 2d box outline (allows 'proper' thickness - 1,2,3,etc)
	Note: expects writing mode to be set up by caller.
*/
void draw_2d_box(short x, short y, short w, short h, short border_thick, short colour)
{
	short coords[4];
	short vo;
	
	if (border_thick<0)
	{
		border_thick++;
		vo=-border_thick-1;
	}else{
		border_thick--;
		vo=border_thick+1;
	}

	if (border_thick>5)
		border_thick=0;

	vsf_interior(V_handle, FIS_SOLID);
	vsf_color(V_handle, colour);
			
	coords[0]=x;
	coords[1]=y-vo;
	coords[2]=x+border_thick;
	coords[3]=y+h+vo;
	v_bar(V_handle, coords);
	coords[0]=x+w;
	coords[1]=y-vo;
	coords[2]=x+w-border_thick;
	coords[3]=y+h+vo;
	v_bar(V_handle, coords);
	coords[0]=x;
	coords[1]=y;
	coords[2]=x+w;
	coords[3]=y+border_thick;
	v_bar(V_handle, coords);
	coords[0]=x;
	coords[1]=y+h;
	coords[2]=x+w;
	coords[3]=y+h-border_thick;
	v_bar(V_handle, coords);

}

/*
	Format a G_FTEXT type text string from it's template,
	and return the real position of the text cursor in this
*/
short format_dialog_text(char *text_out, char *template, char *text_in,short edit_pos)
{
	short index=0,edit_index,tpos=0;
	
	while(*template)
	{
		switch(*template)
		{
			case '_':				/* Found text field */
				if (tpos==edit_pos)
					edit_index=index;
				
				if (*text_in)
				{
					*text_out=*text_in;
					text_in++;
				}else{
					*text_out='_';
				}
				tpos++;
				
				text_out++;
				template++;
				break;
			default:				/* Formatting characters */
				*text_out=*template;
				text_out++;
				template++;
				break;
		}
		index++;
	}
	*text_out='\0';
	
	return edit_index;
}

/*
	Display a primitive object
*/
void display_object(OBJECT *tree,short object,short parent_x,short parent_y)
{
	unsigned long ob_spec;
	OBJC_COLORWORD *colourword;
	OBJECT *ob=tree+object;
	unsigned short t,zap;
	short border_thick=0,coords[10];
	short temp,icx,icy,cols[2];
	TEDINFO *textblk;
	ICONBLK *iconblk;
	CICONBLK *ciconblk;
	CICON	*this_cicon;
	CICON	*best_cicon;
	BITBLK *bitblk;
	MFDB Mscreen;
	MFDB Micon;
	short msk_col,icn_col,x;
	char temp_text[200];
	short tx,ty,txt_curs,tw,th;
	short selected;
	short colourmode=(display.colours>=16) ;
	short state_mask=(SELECTED|CROSSED|CHECKED|DISABLED); /* -> G_PROGDEF */
	short obx=parent_x+ob->ob_x;
	short oby=parent_y+ob->ob_y;
	short obx2=obx+ob->ob_width-1;
	short oby2=oby+ob->ob_height-1;

	if ((obx>global_clip[2])			/* Exit immediately if object is totally outside clip area */
		||((obx2<global_clip[0])
		||((oby>global_clip[3])
		||(oby2<global_clip[1]))))
	{
		return;
	}

	ob_spec=(unsigned long)ob->ob_spec;
	t=(ob->ob_type)&0xff;
	selected=ob->ob_state&SELECTED;
		
	colourword=(OBJC_COLORWORD*)&zap;

	if ((ob->ob_flags&DEFAULT) &&	/* Default exit object */
		(t==G_BUTTON) &&				/* Only BUTTONS change appearance! */
		(ob->ob_flags&FLD3DANY))	/* 2D buttons are handled elsewhere */
	{
		vsf_color(V_handle,BLACK);
		vsf_interior(V_handle, FIS_SOLID);
		coords[0]=parent_x+ob->ob_x-2;
		coords[1]=parent_y+ob->ob_y-2;
		coords[2]=coords[0]+ob->ob_width+3;
		coords[3]=coords[1]+ob->ob_height+3;
		v_bar(V_handle, coords);
	}

	switch(t)	/* Sort out the colourword */
	{
		case G_BOXCHAR:
			temp_text[0]=(ob_spec&0xff000000L)>>24;
			temp_text[1]='\0';
			zap=(unsigned short)ob->ob_spec&0xffff;
			border_thick=(short)((ob_spec&0xff0000L)>>16);
			if (border_thick&128)
				border_thick=-(1+(border_thick^0xff));
			break;
			
		case G_BOX:
		case G_IBOX:
			zap=(unsigned short)ob->ob_spec&0xffff;
			border_thick=(short)((ob_spec&0xff0000L)>>16);
			if (border_thick&128)
				border_thick=-(1+(border_thick^0xff));
			break;
			
		case G_FTEXT:
		case G_FBOXTEXT:
		case G_TEXT:
		case G_BOXTEXT:
			textblk=(TEDINFO*)ob->ob_spec;
			zap=(unsigned short)textblk->te_color;
			border_thick=textblk->te_thickness;

			if (ob->ob_state&IS_EDIT)
				txt_curs=textblk->te_tmplen;
			
			switch(textblk->te_just)			/*Set text alignment - why on earth did */
			{									/* atari use a different horizontal alignment */
				case 0:							/* code for GEM to the one the VDI uses? */
					vst_alignment(V_handle,0,5,&temp,&temp);
					break;
				case 1:
					vst_alignment(V_handle,2,5,&temp,&temp);
					break;
				case 2:
					vst_alignment(V_handle,1,5,&temp,&temp);
					break;
			}
			
			switch(textblk->te_font)	/* Set the correct text size & font */
			{
				case TE_GDOS_PROP:		/* Use a proportional SPEEDOGDOS font (AES4.1 style) */
				case TE_GDOS_MONO:		/* Use a monospaced SPEEDOGDOS font (AES4.1 style) */
				case TE_GDOS_BITM:		/* Use a GDOS bitmap font (AES4.1 style) */
					vst_font(V_handle,textblk->te_fontid);
					vst_point(V_handle,textblk->te_fontsize,&temp,&temp,&temp,&temp);
					tw=display.c_max_w;
					th=display.c_max_h;
					ty=parent_y + ob->ob_y + ((ob->ob_height-display.c_max_h)/2);
					break;
				case TE_STANDARD:		/* Use the standard system font (probably 10 point) */
					vst_font(V_handle,display.standard_font_id);
					vst_point(V_handle,display.standard_font_point,&temp,&temp,&temp,&temp);
					tw=display.c_max_w;
					th=display.c_max_h;
					ty=parent_y + ob->ob_y + ((ob->ob_height-display.c_max_h)/2);
					break;
				case TE_SMALL:			/* Use the small syatem font (probably 8 point) */
					vst_font(V_handle,display.small_font_id);
					vst_point(V_handle,display.small_font_point,&temp,&temp,&temp,&temp);
					tw=display.c_min_w;
					th=display.c_min_h;
					ty=parent_y + ob->ob_y + ((ob->ob_height-display.c_min_h)/2);
					break;
			}
			
			vst_color(V_handle, colourword->textc);

			break;
			
		case G_BUTTON:
			zap=0x11f8;
			/* Negative border thickness - outside border! */
			border_thick=-1;
			if (ob->ob_flags&EXIT)
				border_thick--;
			if (ob->ob_flags&DEFAULT)
				border_thick--;
			ty=parent_y + ob->ob_y + ((ob->ob_height-display.c_max_h)/2);
			break;
			
		case G_STRING:
			zap=0x0100;
			ty=parent_y + ob->ob_y + ((ob->ob_height-display.c_max_h)/2);
			break;
			
		case G_CICON:
			ciconblk=(CICONBLK*)ob->ob_spec;

			best_cicon=NULL; this_cicon=ciconblk->mainlist;
			while(this_cicon)
			{
				if ((this_cicon->num_planes<=display.planes)
					&&((!best_cicon)||(this_cicon->num_planes>best_cicon->num_planes)))
				{
						best_cicon=this_cicon;
				}
				
				this_cicon=this_cicon->next_res;	
			}
			
			if (!best_cicon)							/* No matching icon, so use the mono one instead */
			{
				t=G_ICON;
			}else{
				this_cicon=best_cicon;
			}
			
			iconblk=(ICONBLK*)ob->ob_spec;
			break;
			
		case G_ICON:
			iconblk=(ICONBLK*)ob->ob_spec;
			break;
			
		case G_IMAGE:
			bitblk=(BITBLK*)ob->ob_spec;
			zap=(unsigned short)bitblk->bi_color;
			colourword->pattern=7;
			break;
	}

	/*	Are we shadowing this object? (Borderless objects aren't shadowed!) */
	if (border_thick && (ob->ob_state&SHADOWED))
	{
		short offset, increase;

		if (border_thick>0)
			{ offset=border_thick ; increase=border_thick-1 ; }
		else
			{ offset=0 ; increase=-3*border_thick-1 ; }

		vsf_color(V_handle,colourword->borderc);
		vsf_interior(V_handle, FIS_SOLID);
		coords[0]=parent_x+ob->ob_x+offset;
		coords[1]=parent_y+ob->ob_y+offset;
		coords[2]=coords[0]+ob->ob_width+increase;
		coords[3]=coords[1]+ob->ob_height+increase;
		v_bar(V_handle, coords);
	}

	/* Note: `colourword->opaque' applies *only* to the text
		part of an object!!!!!! */
	vswr_mode(V_handle, MD_REPLACE);

	vsf_interior(V_handle, FIS_PATTERN);
	if (colourword->pattern==7)
	{
		vsf_style(V_handle, 8);
	}else{
		if (colourword->pattern==0)
		{
			vsf_style(V_handle, 8);
			if ((colourword->fillc==0)&&(ob->ob_flags&FLD3DANY))	/* Object inherits default dialog background colour? */
			{
				vswr_mode(V_handle, MD_TRANS);
				colourword->fillc=display.dial_colours.bg_col;
			}else{
				colourword->fillc=WHITE;
			}
		}else{
			vsf_style(V_handle, colourword->pattern);
		}
	}

	if (colourmode && selected)
	{
		if (ob->ob_flags&FLD3DANY)		/* Allow a different colour set for 3d push  */
			vsf_color(V_handle, selected3D_colour[colourword->fillc]);
		else
			vsf_color(V_handle, selected_colour[colourword->fillc]);
	}else{
		vsf_color(V_handle, colourword->fillc);
	}
	
	vsf_perimeter(V_handle, 0);
	
	switch(t)
	{
		case G_PROGDEF:	/* Not sure about this code..... */
			{
				APPLBLK *ab=(APPLBLK*)ob->ob_spec;
				PARMBLK p;
			
				p.pb_tree=tree;
				p.pb_obj=object;
				
				p.pb_prevstate=p.pb_currstate=ob->ob_state;
				
				p.pb_x=parent_x+ob->ob_x;
				p.pb_y=parent_y+ob->ob_y;
				p.pb_w=ob->ob_width;
				p.pb_h=ob->ob_height;
				
				p.pb_xc=global_clip[0];
				p.pb_yc=global_clip[1];
				p.pb_wc=global_clip[2]-global_clip[0]+1;
				p.pb_hc=global_clip[3]-global_clip[1]+1;
				
				p.pb_parm=ab->ab_parm;
			
				/* The PROGDEF function returns the ob_state bits that
					remain to be handled by the AES: */
				state_mask = (short)(*(ab->ab_code))(&p);
				/* BUG: SELECTED bit only handled in non-color mode!!! */
				/* (Not too serious I believe... <mk>) */
			}
			break;
		case G_BOX:
			if (ob->ob_flags&FLD3DANY)
			{
				XA_3D_pushbutton(parent_x+ob->ob_x-1, parent_y+ob->ob_y-1, ob->ob_width+1, ob->ob_height+1, selected);
			}else{
				coords[0]=parent_x+ob->ob_x;
				coords[1]=parent_y+ob->ob_y;
				coords[2]=coords[0]+ob->ob_width-1;
				coords[3]=coords[1]+ob->ob_height-1;
				v_bar(V_handle, coords);
				if (border_thick)			/* Display a border? */
				{
					draw_2d_box(parent_x+ob->ob_x, parent_y+ob->ob_y, 
								ob->ob_width, ob->ob_height, 
								border_thick, colourword->borderc);
				}
			}
			break;
		case G_IBOX:					/* G_IBOX is like a box but doesn't get filled. */
			if (border_thick)			/* Display a border? */
			{
				draw_2d_box(parent_x+ob->ob_x, parent_y+ob->ob_y, 
							ob->ob_width, ob->ob_height, 
							border_thick, colourword->borderc);
			}
			break;
		case G_BOXCHAR:
			tx=parent_x + ob->ob_x + ((ob->ob_width-display.c_max_w)/2);	/* Centre the text in the box */
			ty=parent_y + ob->ob_y + ((ob->ob_height-display.c_max_h)/2);

			if (ob->ob_flags&FLD3DANY)
			{
				XA_3D_pushbutton(parent_x+ob->ob_x-1, parent_y+ob->ob_y-1, ob->ob_width+1, ob->ob_height+1, selected);
				if (selected)
				{
					tx+=PUSH3D_DISTANCE; ty+=PUSH3D_DISTANCE;
				}
			}else{
/*				if (colourword->opaque)*/
				{
					coords[0]=parent_x+ob->ob_x;
					coords[1]=parent_y+ob->ob_y;
					coords[2]=coords[0]+ob->ob_width-1;
					coords[3]=coords[1]+ob->ob_height-1;
					v_bar(V_handle, coords);
				}
				if (border_thick)			/* Display a border? */
				{
					draw_2d_box(parent_x+ob->ob_x, parent_y+ob->ob_y, 
								ob->ob_width, ob->ob_height,
								border_thick, colourword->borderc);
				}
			}
			
			vst_font(V_handle,display.standard_font_id);
			vst_point(V_handle,display.standard_font_point,&temp,&temp,&temp,&temp);
			vst_alignment(V_handle,0,5,&x,&x);
			vst_color(V_handle, colourword->textc);
			
			vswr_mode(V_handle, colourword->opaque ? MD_REPLACE:MD_TRANS);
			v_gtext(V_handle,tx,ty,temp_text);
			break;
		case G_FBOXTEXT:
			switch(textblk->te_just)
			{
				case 0:
					tx=parent_x+ob->ob_x;
					break;
				case 1:
					tx=parent_x+ob->ob_x+ob->ob_width;
					break;
				case 2:
					tx=parent_x+ob->ob_x+(ob->ob_width/2);
					break;
			}

			txt_curs=format_dialog_text(temp_text, textblk->te_ptmplt, textblk->te_ptext, textblk->te_tmplen);

			if (ob->ob_flags&FLD3DANY)
			{
				XA_3D_pushbutton(parent_x+ob->ob_x-1, parent_y+ob->ob_y-1, ob->ob_width+1, ob->ob_height+1, selected);
				if (selected)
				{
					tx+=PUSH3D_DISTANCE; ty+=PUSH3D_DISTANCE;
				}
				vswr_mode(V_handle, colourword->opaque ? MD_REPLACE:MD_TRANS);
				v_gtext(V_handle,tx,ty,temp_text);
			}else{
/*				if (colourword->opaque)*/
				{
					coords[0]=parent_x+ob->ob_x;
					coords[1]=parent_y+ob->ob_y;
					coords[2]=coords[0]+ob->ob_width-1;
					coords[3]=coords[1]+ob->ob_height-1;
					v_bar(V_handle, coords);
				}
				
				vswr_mode(V_handle, colourword->opaque ? MD_REPLACE:MD_TRANS);
				v_gtext(V_handle,tx,ty,temp_text);

				if (selected)
				{
					coords[0]=parent_x+ob->ob_x;
					coords[1]=parent_y+ob->ob_y;
					coords[2]=coords[0]+ob->ob_width-1;
					coords[3]=coords[1]+ob->ob_height-1;
					vswr_mode(V_handle,MD_XOR);
					vsf_color(V_handle,BLACK);
					vsf_interior(V_handle,FIS_SOLID);
					v_bar(V_handle, coords);
				}
				
				if (border_thick)	/* Display a border? */
				{
					vswr_mode(V_handle, MD_REPLACE);
					draw_2d_box(parent_x+ob->ob_x, parent_y+ob->ob_y, 
								ob->ob_width, ob->ob_height, 
								border_thick, colourword->borderc);
				}
			}
			
			if (ob->ob_state&IS_EDIT)
			{
				coords[0]=parent_x+ob->ob_x+txt_curs*tw;
				coords[1]=parent_y+ob->ob_y;
				coords[2]=coords[0]+tw-1;
				coords[3]=coords[1]+th-1;
				vswr_mode(V_handle,MD_XOR);
				vsf_color(V_handle,BLACK);
				vsf_interior(V_handle,FIS_SOLID);
				v_bar(V_handle, coords);
			}

			break;
		case G_BOXTEXT:
			switch(textblk->te_just)
			{
				case 0:
					tx=parent_x+ob->ob_x;
					break;
				case 1:
					tx=parent_x+ob->ob_x+ob->ob_width;
					break;
				case 2:
					tx=parent_x+ob->ob_x+(ob->ob_width/2);
					break;
			}
			if (ob->ob_flags&FLD3DANY)
			{
				XA_3D_pushbutton(parent_x+ob->ob_x-1, parent_y+ob->ob_y-1, ob->ob_width+1, ob->ob_height+1, selected);
				if (selected)
				{
					tx+=PUSH3D_DISTANCE; ty+=PUSH3D_DISTANCE;
				}
				vswr_mode(V_handle, colourword->opaque ? MD_REPLACE:MD_TRANS);
				v_gtext(V_handle,tx,ty,textblk->te_ptext);
			}else{
/*				if (colourword->opaque)*/
				{
					coords[0]=parent_x+ob->ob_x;
					coords[1]=parent_y+ob->ob_y;
					coords[2]=coords[0]+ob->ob_width-1;
					coords[3]=coords[1]+ob->ob_height-1;
					v_bar(V_handle, coords);
				}
				
				vswr_mode(V_handle, colourword->opaque ? MD_REPLACE:MD_TRANS);
				v_gtext(V_handle,tx,ty,textblk->te_ptext);

				if (selected)
				{
					coords[0]=parent_x+ob->ob_x;
					coords[1]=parent_y+ob->ob_y;
					coords[2]=coords[0]+ob->ob_width-1;
					coords[3]=coords[1]+ob->ob_height-1;
					vswr_mode(V_handle,MD_XOR);
					vsf_color(V_handle,BLACK);
					vsf_interior(V_handle,FIS_SOLID);
					v_bar(V_handle, coords);
				}

				if (border_thick)	/* Display a border? */
				{
					vswr_mode(V_handle, MD_REPLACE);
					draw_2d_box(parent_x+ob->ob_x, parent_y+ob->ob_y, 
								ob->ob_width, ob->ob_height, 
								border_thick, colourword->borderc);
				}
			}
			
			if (ob->ob_state&IS_EDIT)
			{
				coords[0]=parent_x+ob->ob_x+txt_curs*tw;
				coords[1]=parent_y+ob->ob_y;
				coords[2]=coords[0]+tw-1;
				coords[3]=coords[1]+th-1;
				vswr_mode(V_handle,MD_XOR);
				vsf_color(V_handle,BLACK);
				vsf_interior(V_handle,FIS_SOLID);
				v_bar(V_handle, coords);
			}

			break;
		case G_BUTTON:
			tx=parent_x+ob->ob_x+(ob->ob_width/2);
			if (ob->ob_flags&FLD3DANY)
			{
				XA_3D_pushbutton(parent_x+ob->ob_x-1, parent_y+ob->ob_y-1, ob->ob_width+1, ob->ob_height+1, selected);
				if (selected)
				{
					tx+=PUSH3D_DISTANCE; ty+=PUSH3D_DISTANCE;
				}
			}else{
				
				if (colourmode && selected)
				{
					coords[0]=parent_x+ob->ob_x+border_thick;
					coords[1]=parent_y+ob->ob_y+border_thick;
					coords[2]=coords[0]+ob->ob_width-border_thick*2-1;
					coords[3]=coords[1]+ob->ob_height-border_thick*2-1;
					vswr_mode(V_handle, MD_REPLACE);
					vsf_color(V_handle,BLACK);
					vsf_interior(V_handle,FIS_SOLID);
					v_bar(V_handle, coords);
					vst_color(V_handle,WHITE);
				
				}else{
					coords[0]=parent_x+ob->ob_x+border_thick;
					coords[1]=parent_y+ob->ob_y+border_thick;
					coords[2]=coords[0]+ob->ob_width-border_thick*2-1;
					coords[3]=coords[1]+ob->ob_height-border_thick*2-1;
					vswr_mode(V_handle, MD_REPLACE);
					vsf_color(V_handle,WHITE);
					vsf_interior(V_handle,FIS_SOLID);
					v_bar(V_handle, coords);
				
					draw_2d_box(parent_x+ob->ob_x, parent_y+ob->ob_y,
							ob->ob_width, ob->ob_height,
							border_thick, BLACK);
					vst_color(V_handle,BLACK);
				
				}
			}
			vst_font(V_handle,display.standard_font_id);
			vst_point(V_handle,display.standard_font_point,&temp,&temp,&temp,&temp);
			vswr_mode(V_handle, MD_TRANS);
			vst_alignment(V_handle,1,5,&temp,&temp);
			v_gtext(V_handle,tx,ty,(char*)ob->ob_spec);
			break;
		case G_STRING:
			vst_font(V_handle,display.standard_font_id);
			vst_point(V_handle,display.standard_font_point,&temp,&temp,&temp,&temp);
			vswr_mode(V_handle, MD_TRANS);
			vst_alignment(V_handle,0,5,&temp,&temp);
			vst_color(V_handle, colourword->textc);
			v_gtext(V_handle,parent_x+ob->ob_x,ty,(char*)ob->ob_spec);
			break;
		case G_FTEXT:
			DIAGS(("G_FTEXT:\ntext=%s\n",textblk->te_ptext));
			DIAGS(("template=%s\n",textblk->te_ptmplt));
			if (textblk->te_pvalid)
				DIAGS(("valid=%s\n",textblk->te_pvalid));
			
			txt_curs=format_dialog_text(temp_text, textblk->te_ptmplt, textblk->te_ptext,textblk->te_tmplen);
			vst_color(V_handle, colourword->textc);
			vswr_mode(V_handle, colourword->opaque ? MD_REPLACE:MD_TRANS);
			switch(textblk->te_just)
			{
				case 0:
					v_gtext(V_handle,parent_x+ob->ob_x,ty,temp_text);
					break;
				case 1:
					v_gtext(V_handle,parent_x+ob->ob_x+ob->ob_width,ty,temp_text);
					break;
				case 2:
					v_gtext(V_handle,parent_x+ob->ob_x+(ob->ob_width/2),ty,temp_text);
					break;
			}
			
			if (ob->ob_state&IS_EDIT)
			{
				coords[0]=parent_x+ob->ob_x+txt_curs*tw;
				coords[1]=parent_y+ob->ob_y;
				coords[2]=coords[0]+tw-1;
				coords[3]=coords[1]+th-1;
				vswr_mode(V_handle,MD_XOR);
				vsf_color(V_handle,BLACK);
				vsf_interior(V_handle,FIS_SOLID);
				v_bar(V_handle, coords);
			}
			
			if (selected)
			{
				coords[0]=parent_x+ob->ob_x;
				coords[1]=parent_y+ob->ob_y;
				coords[2]=coords[0]+ob->ob_width-1;
				coords[3]=coords[1]+ob->ob_height-1;
				vswr_mode(V_handle,MD_XOR);
				vsf_color(V_handle,BLACK);
				vsf_interior(V_handle,FIS_SOLID);
				v_bar(V_handle, coords);
			}
			
			break;
		case G_TEXT:
			vst_color(V_handle, colourword->textc);
			vswr_mode(V_handle, colourword->opaque ? MD_REPLACE:MD_TRANS);
			switch(textblk->te_just)
			{
				case 0:
					v_gtext(V_handle,parent_x+ob->ob_x,ty,textblk->te_ptext);
					break;
				case 1:
					v_gtext(V_handle,parent_x+ob->ob_x+ob->ob_width,ty,textblk->te_ptext);
					break;
				case 2:
					v_gtext(V_handle,parent_x+ob->ob_x+(ob->ob_width/2),ty,textblk->te_ptext);
					break;
			}

			if (ob->ob_state&IS_EDIT)
			{
				coords[0]=parent_x+ob->ob_x+txt_curs*tw;
				coords[1]=parent_y+ob->ob_y;
				coords[2]=coords[0]+tw-1;
				coords[3]=coords[1]+th-1;
				vswr_mode(V_handle,MD_XOR);
				vsf_color(V_handle,BLACK);
				vsf_interior(V_handle,FIS_SOLID);
				v_bar(V_handle, coords);
			}

			if (selected)
			{
				coords[0]=parent_x+ob->ob_x;
				coords[1]=parent_y+ob->ob_y;
				coords[2]=coords[0]+ob->ob_width-1;
				coords[3]=coords[1]+ob->ob_height-1;
				vswr_mode(V_handle,MD_XOR);
				vsf_color(V_handle,BLACK);
				vsf_interior(V_handle,FIS_SOLID);
				v_bar(V_handle, coords);
			}
			
			break;
		case G_CICON:		/* If t==G_CICON by we get here, we've definitely got a valid CICON for this res.... */
			icx=parent_x+ob->ob_x+iconblk->ib_xicon;
			icy=parent_y+ob->ob_y+iconblk->ib_yicon;
			
			coords[0]=coords[1]=0;
			coords[2]=iconblk->ib_wicon-1; coords[3]=iconblk->ib_hicon-1;
			coords[4]=icx; coords[5]=icy;
			coords[6]=icx+iconblk->ib_wicon-1; coords[7]=icy+iconblk->ib_hicon-1;
			
			Micon.fd_w=iconblk->ib_wicon;
			Micon.fd_h=iconblk->ib_hicon;
			Micon.fd_wdwidth=(Micon.fd_w+15)>>4;
			Micon.fd_nplanes=1;
			Micon.fd_stand=0;
			Mscreen.fd_addr=NULL;
			
			if (selected)
			{
				Micon.fd_addr=this_cicon->sel_mask;
			}else{
				Micon.fd_addr=this_cicon->col_mask;
			}
			cols[0]=1; cols[0]=0;
			vrt_cpyfm(V_handle, MD_TRANS, coords, &Micon, &Mscreen, cols);

			if (selected)
			{
				Micon.fd_addr=this_cicon->sel_data;
			}else{
				Micon.fd_addr=this_cicon->col_data;
			}
			Micon.fd_nplanes=display.planes;
			
			vro_cpyfm(V_handle, S_OR_D, coords, &Micon, &Mscreen);
			break;

		case G_ICON:
			icx=parent_x+ob->ob_x+iconblk->ib_xicon;
			icy=parent_y+ob->ob_y+iconblk->ib_yicon;
			
			coords[0]=coords[1]=0;
			coords[2]=iconblk->ib_wicon-1; coords[3]=iconblk->ib_hicon-1;
			coords[4]=icx; coords[5]=icy;
			coords[6]=icx+iconblk->ib_wicon-1; coords[7]=icy+iconblk->ib_hicon-1;
			
			Micon.fd_w=iconblk->ib_wicon;
			Micon.fd_h=iconblk->ib_hicon;
			Micon.fd_wdwidth=(Micon.fd_w+15)>>4;
			Micon.fd_nplanes=1;
			Micon.fd_stand=0;
			Mscreen.fd_addr=NULL;
			
			Micon.fd_addr=iconblk->ib_pmask;
			if (selected)
			{
				icn_col=((iconblk->ib_char)>>8)&0xf;
				msk_col=((iconblk->ib_char)>>12)&0xf;
			}else{
				icn_col=((iconblk->ib_char)>>12)&0xf;
				msk_col=((iconblk->ib_char)>>8)&0xf;
			}
			
			cols[0]=msk_col;
			cols[1]=icn_col;
			vrt_cpyfm(V_handle, MD_TRANS, coords, &Micon, &Mscreen, cols);
			
			Micon.fd_addr=iconblk->ib_pdata;
			cols[0]=icn_col;
			cols[1]=msk_col;
			vrt_cpyfm(V_handle, MD_TRANS, coords, &Micon, &Mscreen, cols);
			
			vst_color(V_handle, icn_col);
			vswr_mode(V_handle, MD_REPLACE);
			vst_font(V_handle,display.small_font_id);
			vst_point(V_handle,display.small_font_point,&temp,&temp,&temp,&temp);
			v_gtext(V_handle, icx+iconblk->ib_xtext, icy+iconblk->ib_ytext,iconblk->ib_ptext);
			break;
			
		case G_IMAGE:
			icx=parent_x+ob->ob_x;
			icy=parent_y+ob->ob_y;

			Micon.fd_w=(bitblk->bi_wb)<<3;
			Micon.fd_h=bitblk->bi_hl;
			Micon.fd_wdwidth=(Micon.fd_w+15)>>4;
			Micon.fd_nplanes=1;
			Micon.fd_stand=0;
			Mscreen.fd_addr=NULL;
			
			Micon.fd_addr=bitblk->bi_pdata;
			cols[0]=colourword->fillc;
			cols[1]=0;
			
			coords[0]=bitblk->bi_x;
			coords[1]=bitblk->bi_y;
			coords[2]=Micon.fd_w-1-coords[0]; coords[3]=Micon.fd_h-1-coords[1];
			coords[4]=icx; coords[5]=icy;
			coords[6]=icx+Micon.fd_w-1-coords[0]; coords[7]=icy+Micon.fd_h-1-coords[1];
			vrt_cpyfm(V_handle, MD_TRANS, coords, &Micon, &Mscreen, cols);
			break;
	}

	if (ob->ob_state&CROSSED)
	{
		vsl_color(V_handle,colourword->borderc);
		coords[0]=parent_x+ob->ob_x;
		coords[1]=parent_y+ob->ob_y;
		coords[2]=parent_x+ob->ob_x+ob->ob_width-1;
		coords[3]=parent_y+ob->ob_y+ob->ob_height-1;
		v_pline(V_handle,2,coords);
		coords[0]=parent_x+ob->ob_x+ob->ob_width-1;
		coords[2]=parent_x+ob->ob_x;
		v_pline(V_handle,2,coords);
	}
	
	/* Handle CHECKED object state: */
	if ( ob->ob_state & state_mask & CHECKED )
	{
		vst_font(V_handle,display.standard_font_id);
		vst_point(V_handle,display.standard_font_point,&temp,&temp,&temp,&temp);
		vswr_mode(V_handle, MD_TRANS);
		vst_alignment(V_handle,0,5,&temp,&temp);
		vst_color(V_handle, BLACK);
		v_gtext(V_handle, obx+2, oby, "\10");	/* ASCII 8 = checkmark */
	}

	/* Handle CROSSED object state: */
	if ( ob->ob_state & state_mask & CROSSED )
	{
		coords[0]=coords[4]=obx-border_thick;
		coords[1]=coords[7]=oby-border_thick;
		coords[2]=coords[6]=obx2+border_thick;
		coords[3]=coords[5]=oby2+border_thick;

		vswr_mode(V_handle, MD_TRANS);
		vsl_color(V_handle, WHITE);
		vsl_width(V_handle, 1);
		vsl_type(V_handle, 1);
		v_pline(V_handle, 2, &coords[0]);
		v_pline(V_handle, 2, &coords[4]);
	}

	coords[0]=obx;
	coords[1]=oby;
	coords[2]=obx2;
	coords[3]=oby2;
	if (border_thick > 0)		/* Inside border */
	{
		coords[0]+=border_thick;
		coords[1]+=border_thick;
		coords[2]-=border_thick;
		coords[3]-=border_thick;
	}

	/* Handle DISABLED state: */
	/* (May not look too hot in colour mode, but it's better than
		no disabling at all...) */
	if ( ob->ob_state & state_mask & DISABLED )
	{
		static short pattern[16]={
			0x5555, 0xaaaa, 0x5555, 0xaaaa,
			0x5555, 0xaaaa, 0x5555, 0xaaaa,
			0x5555, 0xaaaa, 0x5555, 0xaaaa,
			0x5555, 0xaaaa, 0x5555, 0xaaaa };

		vswr_mode(V_handle, MD_TRANS);
		vsf_color(V_handle, WHITE);
		vsf_udpat(V_handle, pattern, 1);
		vsf_interior(V_handle, FIS_USER);
		vr_recfl(V_handle, coords);
	}

	/* Handle SELECTED state only in non-colour mode: */
	if (!colourmode && selected && (state_mask&SELECTED))
	{
		vswr_mode(V_handle, MD_XOR);
		vsf_color(V_handle, BLACK);
		vsf_interior(V_handle, FIS_SOLID);
		vr_recfl(V_handle, coords);
	}

	vswr_mode(V_handle,MD_TRANS);
}

/*
	Walk an object tree, calling display for each object
*/
short draw_object_tree(OBJECT *tree, short object, short depth)
{
	short next;
	short current=0,rel_depth=1,head;
	short x=0,y=0,start_drawing=FALSE;
	
	depth++;
	
	do {
		
		if (current==object)
		{
			start_drawing=TRUE;
			rel_depth=0;
		}
		
		if ((start_drawing)&&(!(tree[current].ob_flags&HIDETREE)))
		{
			display_object(tree,current,x,y);	/* Display this object */
		}

		head=tree[current].ob_head;
										/* Any non-hidden children? */
		if (((head!=-1)&&(!(tree[current].ob_flags&HIDETREE)))
			&&((!start_drawing)||((start_drawing)&&(rel_depth<depth))))
		{
		
			x+=tree[current].ob_x; y+=tree[current].ob_y;
			rel_depth++;
			current=head;
		
		}else{

			next=tree[current].ob_next;		/* Try for a sibling */
	
			while((next!=-1)				/* Trace back up tree if no more siblings */
					&&(tree[next].ob_tail==current))
			{
				current=next;
				x-=tree[current].ob_x;
				y-=tree[current].ob_y;
				next=tree[current].ob_next;
				rel_depth--;
			}
			current=next;
		}
	
	}while((current!=-1)&&(!((start_drawing)&&(rel_depth<1))));

	vst_alignment(V_handle,0,5,&x,&x);
	vswr_mode(V_handle, MD_TRANS);
	vst_font(V_handle,display.standard_font_id);
	vst_point(V_handle,display.standard_font_point,&next,&next,&next,&next);
	vsf_interior(V_handle, FIS_SOLID);

	return TRUE;
}

/*
	Get the true screen coords of an object
*/
short object_abs_coords(OBJECT *tree, short object, short *obx, short *oby)
{
	short next;
	short current=0;
	short x=0,y=0;
	
	do {
		if (current==object)	/* Found the object in the tree? cool, return the coords */
		{
			*obx=x+tree[current].ob_x;
			*oby=y+tree[current].ob_y;
			return 1;
		}
		
		if (tree[current].ob_head!=-1)		/* Any children? */
		{
			x+=tree[current].ob_x; y+=tree[current].ob_y;
			current=tree[current].ob_head;
		}else{
			next=tree[current].ob_next;							/* Try for a sibling */

			while((next!=-1)&&(tree[next].ob_tail==current))	/* Trace back up tree if no more siblings */
			{
				current=next;
				x-=tree[current].ob_x;
				y-=tree[current].ob_y;
				next=tree[current].ob_next;
			}
			current=next;
		}
	} while(current!=-1);		/* If 'current' is -1 then we have finished */

	return 0;	/* Bummer - didn't find the object, so return error */
}

/*
	Find which object is at a given location
*/
short find_object(OBJECT *tree, short object, short depth, short obx, short oby)
{
	short next;
	short current=0,rel_depth=1;
	short x=0,y=0,start_checking=FALSE;
	short pos_object=-1;
	
	do {
		if (current==object)	/* We can start considering objects at this point */
		{
			start_checking=TRUE;
			rel_depth=0;
		}
		
		if (start_checking)
		{
			if ((tree[current].ob_x+x<=obx)
				&&((tree[current].ob_y+y<=oby)
				&&((tree[current].ob_x+x+tree[current].ob_width>=obx)
				&&(tree[current].ob_y+y+tree[current].ob_height>=oby))))
			{
				pos_object=current;	/* This is only a possible object, as it may have children on top of it. */
			}
		}

		if (((!start_checking)||(rel_depth<depth))&&(tree[current].ob_head!=-1))		/* Any children? */
		{
			x+=tree[current].ob_x; y+=tree[current].ob_y;
			rel_depth++;
			current=tree[current].ob_head;
		}else{
			next=tree[current].ob_next;							/* Try for a sibling */

			while((next!=-1)&&(tree[next].ob_tail==current))	/* Trace back up tree if no more siblings */
			{
				current=next;
				x-=tree[current].ob_x;
				y-=tree[current].ob_y;
				next=tree[current].ob_next;
				rel_depth--;
			}
			current=next;
		}
		
	} while((current!=-1)&&(rel_depth>0));

	return pos_object;
}

/*
	Perform a few fixes on a menu tree prior to installing it
	(ensure title spacing & items fit into their menus)
*/
void fix_menu(OBJECT *root)
{
	short pxy[8];
	short title,mnx=0,mnh,mnw,temp;
	short surround,text;

	title=root[root[root[0].ob_head].ob_head].ob_head;
	surround=root[root[0].ob_tail].ob_head;
	
	while(title!=root[root[0].ob_head].ob_head)		/* Fix title spacings (some resource editors don't set them up right) */
	{
		root[title].ob_x=mnx;
		root[surround].ob_x=mnx;

		vqt_extent(V_handle,(char*)root[title].ob_spec,pxy);
		mnw=(abs(pxy[2]-pxy[0])+4);
		mnx+=mnw;
		root[title].ob_width=mnw;
		root[title].ob_height=display.c_max_h;

		mnw=mnh=0;
		
		for(text=root[surround].ob_head; text!=surround; text=root[text].ob_next)
		{
			vqt_extent(V_handle,(char*)root[text].ob_spec,pxy);
			temp=abs(pxy[2]-pxy[0]);

			if (temp>mnw)
				mnw=temp;
				
			mnh+=display.c_max_h;
		}
		
		root[surround].ob_width=mnw;
		root[surround].ob_height=mnh;

		title=root[title].ob_next;
		surround=root[surround].ob_next;
	}
	
	root[0].ob_width=mnx;
	root[0].ob_height=display.c_max_h;
	root[root[0].ob_head].ob_width=mnx;
	root[root[0].ob_head].ob_height=display.c_max_h;
	root[root[0].ob_tail].ob_width=mnx;
	root[root[0].ob_tail].ob_height=display.c_max_h;
}
