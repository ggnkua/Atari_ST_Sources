#include <vdi.h>
#include <aes.h>

#include "HighWire.h"

//******************** Comment out ********************

/*
void
blit_block(struct frame_item *frame,short distance, enum direction direction_of_scroll)
{
	struct fdbstr screen;
	short pts[8],x,y,w,h;
	
	frame->frame.x=frame->clip.x-frame->horizontal_scroll;
	frame->frame.y=frame->clip.y-frame->vertical_scroll;
	vsf_color(vdi_handle,background_colour);
	wind_get(window_handle,WF_FIRSTXYWH,&x,&y,&w,&h);
	do
	{
		if(x<frame->clip.x+frame->clip.w && y<frame->clip.y+frame->clip.h && frame->clip.x<x+w && frame->clip.y<y+h)
		{
			pts[4]=pts[0]=max(x,frame->clip.x);
			pts[5]=pts[1]=max(y,frame->clip.y);
			pts[6]=pts[2]=min(x+w,frame->clip.x+frame->clip.w)-1;
			pts[7]=pts[3]=min(y+h,frame->clip.y+frame->clip.h)-1;
			screen.fd_addr=0;
			vs_clip(vdi_handle,1,pts);
			switch(direction_of_scroll)
			{
				case d_up:
					if(pts[3]-distance>pts[1])
					{
						pts[3]-=distance;	
						pts[5]+=distance;
						vro_cpyfm(vdi_handle,3,pts,&screen,&screen);
						pts[3]=pts[5];
					}
					vr_recfl(vdi_handle,pts);
					draw_frame_contents(frame->item,frame->frame.x,frame->frame.y,frame->frame.w,pts[3]-pts[1],pts[1]);
					break;
				case d_down:
					if(pts[1]+distance<pts[3])
					{
						pts[1]+=distance;
						pts[7]-=distance;
						vro_cpyfm(vdi_handle,3,pts,&screen,&screen);
						pts[1]=pts[7];
					}
					vr_recfl(vdi_handle,pts);
					draw_frame_contents(frame->item,frame->frame.x,frame->frame.y,frame->frame.w,pts[3]-pts[1],pts[1]);
					break;
				case d_left:
					if(pts[2]-distance>pts[0])
					{
						pts[2]-=distance;
						pts[4]+=distance;
						vro_cpyfm(vdi_handle,3,pts,&screen,&screen);
						pts[2]=pts[4];
					}
					vr_recfl(vdi_handle,pts);
					draw_frame_contents(frame->item,frame->frame.x,frame->frame.y,frame->frame.w,pts[3]-pts[1],pts[1]);
					break;
				case d_right:
					if(pts[0]+distance<pts[2])
					{
						pts[0]+=distance;
						pts[6]-=distance;
						vro_cpyfm(vdi_handle,3,pts,&screen,&screen);
						pts[0]=pts[6];
					}
					vr_recfl(vdi_handle,pts);
					draw_frame_contents(frame->item,frame->frame.x,frame->frame.y,frame->frame.w,pts[3]-pts[1],pts[1]);
					break;
			}
			vs_clip(vdi_handle,0,0);
		}
		wind_get(window_handle,WF_NEXTXYWH,&x,&y,&w,&h);
	}
	while(w+h>0);
}


void redraw(short handle,short rx, short ry, short rw, short rh, struct frame_item *current_frame)
{
	
	vsf_color(vdi_handle,background_colour);
	
	if(frames_recalculated==true)
		wind_get(window_handle,WF_WORKXYWH,&rx,&ry,&rw,&rh);
	
	while(current_frame!=0)
	{
		redraw_frame(handle,rx,ry,rw,rh,current_frame);
		draw_frame_borders(current_frame,0);
		current_frame=current_frame->next_frame;
	}
	frames_recalculated=false;
}

void
redraw_frame(short handle,short rx,short ry,short rw,short rh,struct frame_item *current_frame)
{
	short pts[4],x,y,w,h;

	if(current_frame->frame_named_location!=0)
	{
		current_frame->vertical_scroll=search_for_named_location(current_frame->frame_named_location,current_frame->first_named_location);
		current_frame->frame_named_location=0;
		if(current_frame->vertical_scroll>current_frame->current_page_height-current_frame->frame.h)
			current_frame->vertical_scroll=current_frame->current_page_height-current_frame->frame.h;
	}
		
	current_frame->frame.x=current_frame->clip.x-current_frame->horizontal_scroll;
	current_frame->frame.y=current_frame->clip.y-current_frame->vertical_scroll;
	
	wind_get(window_handle,WF_FIRSTXYWH,&x,&y,&w,&h);
	vsf_color(vdi_handle,background_colour);
	
	if(current_frame->clip.x<rx+rw && current_frame->clip.y<ry+rh && rx<current_frame->clip.x+current_frame->clip.w && ry<current_frame->clip.y+current_frame->clip.h)
	{
		wind_get(window_handle,WF_FIRSTXYWH,&x,&y,&w,&h);
		graf_mouse(M_OFF,0);
		wind_update(BEG_UPDATE);
		
		do
		{
			if(x<rx+rw && y<ry+rh && rx<x+w && ry<y+h && x<current_frame->clip.x+current_frame->clip.w && y<current_frame->clip.y+current_frame->clip.h && current_frame->clip.x<x+w && current_frame->clip.y<ry+rh)
			{
				pts[0]=max(current_frame->clip.x,max(x,rx));
				pts[1]=max(current_frame->clip.y,max(y,ry));
				pts[2]=min(current_frame->clip.x+current_frame->clip.w,min(x+w,rx+rw))-1;
				pts[3]=min(current_frame->clip.y+current_frame->clip.h,min(y+h,ry+rh))-1;
				vs_clip(vdi_handle,1,pts);
				vr_recfl(vdi_handle,pts);
				draw_frame_contents(current_frame->item,current_frame->frame.x,current_frame->frame.y,current_frame->frame.w,pts[3],pts[1]);
				vs_clip(vdi_handle,0,0);
			}
			wind_get(window_handle,WF_NEXTXYWH,&x,&y,&w,&h);
		}
		while(w+h>0);
		
		wind_update(END_UPDATE);
		graf_mouse(M_ON,0);
	}
}


void
draw_sliders(struct frame_item *frame)
{
	short pts[4];
	long slider_length,slider_pos,scroll_length;
	
	if(frame->v_scroll_on==true)
	{
		scroll_length=frame->clip.h-1-scroll_bar_width*2;
		slider_length=frame->clip.h*scroll_length/frame->current_page_height;
		if(slider_length<scroll_bar_width)
			slider_length=scroll_bar_width;
		slider_pos=((scroll_length-slider_length)*frame->vertical_scroll/(frame->current_page_height-frame->clip.h))+frame->clip.y+scroll_bar_width+1;
	
		pts[2]=pts[0]=frame->clip.x+frame->clip.w+1;
		pts[2]+=scroll_bar_width-3;
		pts[3]=pts[1]=slider_pos+1;
		pts[3]+=slider_length-3;
		vsf_color(vdi_handle,8);
		vr_recfl(vdi_handle,pts);
		vsf_color(vdi_handle,9);
		pts[1]=frame->clip.y+scroll_bar_width+1;
		pts[3]=slider_pos-1;
		if(pts[1]<pts[3])
			vr_recfl(vdi_handle,pts);
		pts[1]=++pts[3];
		v_pline(vdi_handle,2,pts);
		pts[3]=pts[1]=slider_pos+slider_length-1;
		v_pline(vdi_handle,2,pts);
		pts[1]++;
		pts[3]=frame->clip.y+frame->clip.h-1-scroll_bar_width;
		if(pts[1]<pts[3])
			vr_recfl(vdi_handle,pts);
	}
	
	if(frame->h_scroll_on==true)
	{
		scroll_length=frame->clip.w-1-scroll_bar_width*2;
		slider_length=frame->clip.w*scroll_length/frame->frame.w;
		if(slider_length<scroll_bar_width)
			slider_length=scroll_bar_width;
		slider_pos=((scroll_length-slider_length)*frame->horizontal_scroll/(frame->frame.w-frame->clip.w))+frame->clip.x+scroll_bar_width+1;
	
		pts[3]=pts[1]=frame->clip.y+frame->clip.h+1;
		pts[3]+=scroll_bar_width-3;
		pts[2]=pts[0]=slider_pos+1;
		pts[2]+=slider_length-3;
		vsf_color(vdi_handle,8);
		vr_recfl(vdi_handle,pts);
		vsf_color(vdi_handle,9);
		pts[0]=frame->clip.x+scroll_bar_width+1;
		pts[2]=slider_pos-1;
		if(pts[0]<pts[2])
			vr_recfl(vdi_handle,pts);
		pts[0]=++pts[2];
		v_pline(vdi_handle,2,pts);
		pts[2]=pts[0]=slider_pos+slider_length-1;
		v_pline(vdi_handle,2,pts);
		pts[0]++;
		pts[2]=frame->clip.x+frame->clip.w-1-scroll_bar_width;
		if(pts[0]<pts[2])
			vr_recfl(vdi_handle,pts);
	}	
}

void
draw_frame_borders(struct frame_item *current_frame,short flag)
{
	short pts[8],clip[4],x,y,w,h;
	
	wind_get(window_handle,WF_FIRSTXYWH,&x,&y,&w,&h);
	graf_mouse(M_OFF,0);
	wind_update(BEG_UPDATE);
	do
	{
		clip[0]=x;
		clip[1]=y;
		clip[2]=x+w-1;
		clip[3]=y+h-1;
		vs_clip(vdi_handle,1,clip);
		
		draw_sliders(current_frame);
		
		if(flag==1)
		{
			vs_clip(vdi_handle,0,0);
			wind_get(window_handle,WF_NEXTXYWH,&x,&y,&w,&h);
			continue;
		}
		
		if(current_frame->border==true)
		{
			pts[2]=pts[0]=current_frame->clip.x-1;
			pts[3]=pts[1]=current_frame->clip.y-1;
			pts[3]+=current_frame->clip.h+2;
			if(current_frame->h_scroll_on==true)
				pts[3]+=scroll_bar_width-1;
			v_pline(vdi_handle,2,pts);
			pts[3]=pts[1];
			pts[2]+=current_frame->clip.w+2;
			if(current_frame->v_scroll_on==true)
				pts[2]+=scroll_bar_width-1;
			v_pline(vdi_handle,2,pts);
		}
			
		if(current_frame->h_scroll_on==true || current_frame->border==true)
		{		
			pts[2]=pts[0]=current_frame->clip.x;
			pts[2]+=current_frame->clip.w-1;
			pts[3]=pts[1]=current_frame->clip.y+current_frame->clip.h;
			v_pline(vdi_handle,2,pts);
			if(current_frame->h_scroll_on==true)
			{
				pts[1]=pts[3]+=scroll_bar_width-1;
				v_pline(vdi_handle,2,pts);
				pts[1]-=scroll_bar_width-2;
				pts[3]--;
				pts[2]=pts[0];
				v_pline(vdi_handle,2,pts);
				pts[0]++;
				pts[2]+=scroll_bar_width-1;
				vsf_color(vdi_handle,8);
				vr_recfl(vdi_handle,pts);
				pts[0]=++pts[2];
				v_pline(vdi_handle,2,pts);
				pts[0]=pts[2]=current_frame->clip.x+current_frame->clip.w-scroll_bar_width;
				v_pline(vdi_handle,2,pts);
				pts[2]+=scroll_bar_width-1;
				pts[0]++;
				vr_recfl(vdi_handle,pts);
				pts[0]=++pts[2];
				v_pline(vdi_handle,2,pts);
				
				//left arrow
				pts[5]=pts[3]=pts[1]=current_frame->clip.y+current_frame->clip.h;
				pts[6]=pts[2]=pts[0]=current_frame->clip.x+scroll_bar_width/3;
				pts[7]=pts[1]+=scroll_bar_width/2;
				pts[3]+=scroll_bar_width/4;
				pts[5]+=scroll_bar_width*3/4;
				pts[4]=pts[2]+=scroll_bar_width/2;
				v_pline(vdi_handle,4,pts);
				
				//right arrow
				pts[6]=pts[2]=pts[0]=current_frame->clip.x+current_frame->clip.w-scroll_bar_width/3;
				pts[4]=pts[2]-=scroll_bar_width/2;
				v_pline(vdi_handle,4,pts);
			}
		}
		
		if(current_frame->v_scroll_on==true || current_frame->border==true)
		{
			pts[3]=pts[1]=current_frame->clip.y;
			pts[3]+=current_frame->clip.h-1;
			pts[2]=pts[0]=current_frame->clip.x+current_frame->clip.w;
			v_pline(vdi_handle,2,pts);
			if(current_frame->v_scroll_on==true)
			{
				pts[0]=pts[2]+=scroll_bar_width-1;
				v_pline(vdi_handle,2,pts);
				vsf_color(vdi_handle,8);
				pts[0]-=scroll_bar_width-2;
				pts[2]--;
				pts[3]=pts[1];
				v_pline(vdi_handle,2,pts);
				pts[1]++;
				pts[3]+=scroll_bar_width-1;
				vr_recfl(vdi_handle,pts);
				pts[1]=++pts[3];
				v_pline(vdi_handle,2,pts);
				pts[1]=pts[3]=current_frame->clip.y+current_frame->clip.h-scroll_bar_width;
				v_pline(vdi_handle,2,pts);
				pts[3]+=scroll_bar_width-1;
				pts[1]++;
				vsf_color(vdi_handle,8);
				vr_recfl(vdi_handle,pts);
				pts[1]=++pts[3];
				v_pline(vdi_handle,2,pts);
				
				//up arrow
				pts[4]=pts[2]=pts[0]=current_frame->clip.x+current_frame->clip.w;
				pts[7]=pts[3]=pts[1]=current_frame->clip.y+scroll_bar_width/3;
				pts[6]=pts[0]+=scroll_bar_width/2;
				pts[2]+=scroll_bar_width/4;
				pts[4]+=scroll_bar_width*3/4;
				pts[5]=pts[3]+=scroll_bar_width/2;
				v_pline(vdi_handle,4,pts);
				
				//down arrow
				pts[7]=pts[3]=pts[1]=current_frame->clip.y+current_frame->clip.h-scroll_bar_width/3;
				pts[5]=pts[3]-=scroll_bar_width/2;
				v_pline(vdi_handle,4,pts);
			}
		}
		
		if(current_frame->v_scroll_on==true && current_frame->h_scroll_on==true)
		{
			pts[2]=pts[0]=current_frame->clip.x+current_frame->clip.w+1;
			pts[3]=pts[1]=current_frame->clip.y+current_frame->clip.h+1;
			pts[2]+=scroll_bar_width-3;
			pts[3]+=scroll_bar_width-3;
			vr_recfl(vdi_handle,pts);
			pts[0]=++pts[2];
			pts[3]++;
			v_pline(vdi_handle,2,pts);
			pts[1]=pts[3];
			pts[0]-=scroll_bar_width-2;
			v_pline(vdi_handle,2,pts);
		}
		vs_clip(vdi_handle,0,0);
		wind_get(window_handle,WF_NEXTXYWH,&x,&y,&w,&h);
	}
	while(w+h>0);
	wind_update(END_UPDATE);
	graf_mouse(M_ON,0);
}	

*/

// *************************************************************

void
render_page_contents(struct paragraph_item *current_paragraph, short frame_x, long current_height, short frame_w, short frame_h, short top_of_page)
{
	struct word_item *current_word,*line_start,*line_end;
	short left_indent,right_indent,line_height,current_line_width,line_tail=0;
	short u,alignment_spacer,height_spacer;
	short previous_word_height=0,pts[4];
	
	while(current_paragraph!=0 && current_height+current_paragraph->current_paragraph_height<top_of_page)
	{
		current_height+=current_paragraph->current_paragraph_height;
		if(current_paragraph->eop_space<0)
			current_height+=current_paragraph->eop_space;
		current_paragraph=current_paragraph->next_paragraph;
	}
	if(current_paragraph==0)
		return;
	current_word=current_paragraph->item;
	vst_effects(vdi_handle,8*(current_word->styles.underlined!=0));
	vst_font(vdi_handle,fonts[current_word->styles.font][(current_word->styles.bold!=0)][(current_word->styles.italic!=0)]);
	vst_arbpt(vdi_handle,current_word->styles.font_size,&u,&u,&u,&u);
	vst_color(vdi_handle,current_word->colour);
		
	while(current_paragraph!=0)
	{
		current_word=current_paragraph->item;
		
		if(current_paragraph->paragraph_code==hr)
		{
			if(current_word->word_width<0)
				current_line_width=current_word->word_width*(frame_w/10)/-10;
			else
				current_line_width=current_word->word_width;
			switch(current_paragraph->eop_space)
			{
				case center:
					pts[0]=(frame_w-current_line_width)/2;
					pts[2]=frame_w-pts[0];
					break;
				case right:
					pts[0]=(frame_w-current_line_width);
					pts[2]=frame_w;
					break;
				default:
					pts[0]=0;
					pts[2]=current_line_width;
			}
			pts[0]+=frame_x;
			pts[2]+=(frame_x-1);
			pts[1]=pts[3]=current_height+10;
			if(current_word->word_height<1)
			{
				pts[3]-=current_word->word_height;
				vsf_color(vdi_handle,1);
				vr_recfl(vdi_handle,pts);
			}
			else
			{
				pts[3]+=current_word->word_height-1;
				vsf_color(vdi_handle,9);
				vr_recfl(vdi_handle,pts);
				vsf_color(vdi_handle,8);
				pts[0]++;pts[1]++;pts[2]++;pts[3]++;
				vr_recfl(vdi_handle,pts);
			}
			current_height+=abs(current_word->word_height)+20;
			current_paragraph=current_paragraph->next_paragraph;
			continue;
		}
	
		left_indent=current_paragraph->left_border;
		right_indent=current_paragraph->right_border;
		
		while(current_word!=0)
		{
			current_line_width=0;
			line_start=current_word;
			line_height=0;
			line_tail=0;
			while(current_word!=0 && (current_line_width+current_word->word_width)<(frame_w-left_indent-right_indent))
			{
				if(current_word->word_code==br && current_word != line_start)
					break;
				current_line_width+=current_word->word_width;
				if(line_height<current_word->word_height)
					line_height=current_word->word_height;
				if(line_tail<current_word->word_tail_drop)
					line_tail=current_word->word_tail_drop;
				current_word=current_word->next_word;
			}
			
			current_height+=line_height;
			line_end=current_word;
			current_word=line_start;
		
			switch(current_paragraph->alignment)
			{
				case center:
					alignment_spacer=(frame_w-current_line_width-left_indent-right_indent)/2+left_indent;break;
				case right:
					alignment_spacer=(frame_w-current_line_width-left_indent);break;
				default:
					alignment_spacer=left_indent;
			}
			
			current_line_width=0;
			
			while(current_word!=line_end)
			{
				if(current_word->changed.style==true)
					vst_effects(vdi_handle,8*(current_word->styles.underlined!=0));
				
				if(current_word->changed.font==true)
				{
					vst_font(vdi_handle,fonts[current_word->styles.font][(current_word->styles.bold!=0)][(current_word->styles.italic!=0)]);
					vst_arbpt(vdi_handle,current_word->styles.font_size,&u,&u,&u,&u);
				}
				
				if(current_word->changed.colour==true)
					if(current_highlighted_link_area!=0 && current_word->link!=0)	
					{	vst_color(vdi_handle,highlighted_link_colour);}
					else
					{	vst_color(vdi_handle,current_word->colour);}
					
				switch(current_word->vertical_align)
				{
					case below:
						height_spacer=-(current_word->word_height/2);break;
					case above:
						height_spacer=previous_word_height-current_word->word_height;break;
					case bottom:
						previous_word_height=current_word->word_height;
					default:
						height_spacer=0;
				}
			
				if(current_line_width==0 && *current_word->item==Space_Code)
					switch(current_paragraph->alignment)
					{
						case right:
							break;
						case center:
							alignment_spacer-=current_word->space_width/2;break;
						default:
							alignment_spacer-=current_word->space_width;
					}
				
				if(current_height>top_of_page-line_tail-2)
				{
					v_ftext16(vdi_handle,frame_x+current_line_width+alignment_spacer,current_height-height_spacer,current_word->item);
				
					if(current_word->styles.strike !=0)
					{
						pts[0]=frame_x+current_line_width+alignment_spacer;
						pts[1]=pts[3]=current_height-(current_word->word_height/3);
						pts[2]=pts[0]+current_word->word_width;
						v_pline(vdi_handle,2,pts);
					}
				}
				current_line_width+=current_word->word_width;
				current_word=current_word->next_word;
			}
			current_height+=line_tail;
			if(current_height+(current_paragraph->eop_space<0?current_paragraph->eop_space:0)>frame_h+top_of_page)
				return;
		}
		current_height+=current_paragraph->eop_space;
		current_paragraph=current_paragraph->next_paragraph;
	}
}
