#include "SuJi_glo.h"

int window_handle=-1;
int shaded_or_iconified=0;
unsigned long first_shown=0;
unsigned long lines_to_show=2;
GRECT full={-1,-1,-1,-1};

char window_info_line[80];

int scrolled_left=0;

int open_list_window( GRECT *xywh )
{
	GRECT r,b;

	mt_wind_get_grect(0,WF_WORKXYWH,&b,&global);

	shaded_or_iconified=0;

	window_handle=mt_wind_create_grect(WIND_KIND,&b,&global);

	if(window_handle<0)
		return 0;

	if(mt_appl_getinfo(11,&i,NULL,NULL,NULL,&global) && (i & 0x0020))
		mt_wind_set(window_handle,WF_BEVENT,1,0,0,0,&global);

	if ( xywh->g_x == -1 )
	{
		r.g_x=b.g_x+b.g_w/2;
		r.g_y=b.g_y+b.g_h/2;
		r.g_w=b.g_w-(2*b.g_w)/5;
		r.g_h=b.g_h-(2*b.g_h)/5;
	
		r.g_h=((int) (r.g_h/line_height))*line_height;
	
		r.g_h-=line_height;
		r.g_h+=top_height;
	
		r.g_x-=r.g_w/2;
		r.g_y-=r.g_h/2;
	}
	else
		r = *xywh;

	mt_wind_calc_grect(WC_BORDER,WIND_KIND,&r,&r,&global);

	if(r.g_x<b.g_x)
		r.g_x=b.g_x;
	if(r.g_x<b.g_y)
		r.g_y=b.g_y;
	if(r.g_x+r.g_w>b.g_x+b.g_w)
		r.g_w=b.g_x+b.g_w-r.g_w;
	if(r.g_y+r.g_h>b.g_y+b.g_h)
		r.g_h=b.g_y+b.g_h-r.g_h;

	mt_rsrc_gaddr(5,WINDOW_NAME_W,&alert,&global);
	mt_wind_set_string(window_handle,WF_NAME,alert,&global);
	set_info_line();
	mt_wind_set(window_handle,WF_HSLIDE,1,0,0,0,&global);
	mt_wind_set(window_handle,WF_VSLIDE,1,0,0,0,&global);
	mt_wind_set(window_handle,WF_HSLSIZE,1000,0,0,0,&global);
	mt_wind_set(window_handle,WF_VSLSIZE,1000,0,0,0,&global);

	mt_wind_open_grect(window_handle,&r,&global);

	init_max_breite();

	return 1;
}

void close_list_window( GRECT *xywh )
{
	mt_wind_get_grect(window_handle,WF_WORKXYWH,xywh,&global);
	mt_wind_close(window_handle,&global);
	mt_wind_delete(window_handle,&global);
	window_handle=-1;
}

void set_info_line(void)
{
	char mask[10];
	static unsigned long last_finfos=-1;
	static int message_send=0;

	if(finfos!=last_finfos)
	{
		if(mt_wind_update(BEG_UPDATE|there_is_check_and_set,&global))
		{
			message_send=0;

			if(fsize<1024)
				sprintf(mask,"%.0f B",fsize);
			else if(fsize<1048576l)
				sprintf(mask,"%.1f KB",fsize/((double) 1024));
			else
				sprintf(mask,"%.1f MB",fsize/((double) 1048576l));
		
				/* Ggf. Dezimalkomma */
			{
				OBJECT *tree;

				mt_rsrc_gaddr(0,LANGUAGE_SETTING,&tree,&global);

				if(tree[LS_DEZ_KOMMA].ob_state & SELECTED)
				{
					for(i=0;i<10;i++)
						if(mask[i]=='.')
							mask[i]=',';
				}
			}
						
		
			mt_rsrc_gaddr(5,WINDOW_INFO,&alert,&global);
			sprintf(window_info_line,alert,finfos,mask);
			mt_wind_set_string(window_handle,WF_INFO,window_info_line,&global);

			if(shaded_or_iconified & 2)
			{
				GRECT r={-1,-1,-1,-1};
				redraw_window(&r);
			}

			mt_wind_update(END_UPDATE,&global);
		}
		else if(message_send==0)
		{
			int msg[8];

			message_send=1;

			msg[0]=0x9277;
			msg[1]=ap_id;
			msg[2]=0;
			msg[3]=0x9277;
			msg[4]='si';
	
			mt_appl_write(ap_id,16,msg,&global);
		}
	}
}

void redraw_window(GRECT *r)
{
	int xx,yy,ww,hh;
	int w_x,w_y,w_w,w_h;
	int cxy[4];
	int no_first_next=FALSE;
	OBJECT *tree;
	int handle;

	int x,y,w,h;
	x=r->g_x;
	y=r->g_y;
	w=r->g_w;
	h=r->g_h;

	if(shaded_or_iconified & 2)
	{
		int only_the_number;
		GRECT r;

		only_the_number=x==-1 && y==-1 && w==-1 && h==-1;

		mt_wind_update(BEG_UPDATE,&global);
		set_mouse(M_OFF);
		mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);

		mt_rsrc_gaddr(0,MASKE_ICONIFY,&tree,&global);
		tree[0].ob_x=r.g_x;
		tree[0].ob_y=r.g_y;
		tree[0].ob_width=r.g_w;
		tree[0].ob_height=r.g_h;

		tree[SU_ICON].ob_x=r.g_w/2-tree[SU_ICON].ob_width/2;
		tree[SU_ICON].ob_y=r.g_h/2-tree[SU_ICON].ob_height/2-tree[ICON_ZAHL].ob_height/2;

		sprintf(tree[ICON_ZAHL].ob_spec.tedinfo->te_ptext,"%ld",finfos);
		tree[ICON_ZAHL].ob_x=0;
		tree[ICON_ZAHL].ob_y=r.g_h-tree[ICON_ZAHL].ob_height-1;
		tree[ICON_ZAHL].ob_width=r.g_w;

		mt_wind_get_grect(window_handle,WF_FIRSTXYWH,&r,&global);
		while(r.g_w && r.g_h)
		{
			if(only_the_number)
				mt_objc_draw_grect(tree,ICON_ZAHL,8,&r,&global);
			else
				mt_objc_draw_grect(tree,0,8,&r,&global);
			mt_wind_get_grect(window_handle,WF_NEXTXYWH,&r,&global);
		}

		set_mouse(M_ON);
		mt_wind_update(END_UPDATE,&global);
		return;
	}

	if(av_server_kennt & 0x00020000l &&
		!(av_server_kennt & 0x10000000l))
	{
		int msg[8];

		msg[0]=AV_ASKFILEFONT;
		msg[1]=ap_id;
		msg[2]=0;
		msg[3]=0;
		msg[4]=0;
		msg[5]=0;
		msg[6]=0;
		msg[7]=0;
		mt_appl_write(av_server,16,msg,&global);
	}

	mt_wind_update(BEG_UPDATE,&global);
	set_mouse(M_OFF);

	mt_wind_get(window_handle,WF_WORKXYWH,&w_x,&w_y,&w_w,&w_h,&global);

	if(x<=-1 && y<=-1 && w<=-1 && h<=-1)
	{
		no_first_next=TRUE;

		x=-x;
		y=-y;
		w=-w;
		h=-h;
	}

	handle=vdi_h;

	lines_to_show=w_h/line_height-1;

	w_x-=scrolled_left;
	w_w+=scrolled_left;

	vst_alignment(handle,0,5,&dummy,&dummy);

	if(no_first_next)
	{
		xx=x;
		yy=y;
		ww=w;
		hh=h;
	}
	else
		mt_wind_get(window_handle,WF_FIRSTXYWH,&xx,&yy,&ww,&hh,&global);
	while(ww && hh)
	{
		unsigned long l;
		int xy[8];

		ww=(xx+ww<x+w ? xx+ww : x+w)-(xx>x ? xx : x);
		hh=(yy+hh<y+h ? yy+hh : y+h)-(yy>y ? yy : y);
		xx=xx>x ? xx : x;
		yy=yy>y ? yy : y;

		if(((xx+ww<x+w ? xx+ww : x+w) > (xx>x ? xx : x)) && ((yy+hh<y+h ? yy+hh : y+h) > (yy>y ? yy : y)))
		{
			cxy[0]=xx;
			cxy[1]=yy;
			cxy[2]=xx+ww-1;
			cxy[3]=yy+hh-1;

			if(!no_first_next)
				vs_clip(handle,1,cxy);

			vswr_mode(handle,MD_REPLACE);

			if(vsf_color(handle,LWHITE)!=LWHITE)
				vsf_color(handle,WHITE);

			v_bar(handle,cxy);

			if(vsl_color(handle,LBLACK)!=LBLACK)
			{
				vsl_color(handle,BLACK);

				xy[0]=w_x-3+left_space;
				xy[1]=w_y+top_height-3;
				xy[2]=xy[0]-left_space+4;
				xy[3]=xy[1];

				for(i=0;i<6;i++)
				{
					if(show_row[i])
						xy[2]+=max_breite[i];
				}

				v_pline(handle,2,xy);

				xy[1]=w_y+top_height-2;
				xy[3]=xy[1];

				v_pline(handle,2,xy);

				xy[0]=w_x-3+left_space;
				xy[1]=w_y;
				xy[2]=xy[0];
				xy[3]=w_y+w_h-1;
				v_pline(handle,2,xy);

				xy[0]-=left_space-5;

				for(i=0;i<6;i++)
				{
					if(show_row[i])
					{
						xy[0]+=max_breite[i];
						xy[2]=xy[0];

						v_pline(handle,2,xy);
					}
				}
			}
			else
			{
				xy[0]=w_x+left_space-2;
				xy[2]=w_x+left_space-6;

				for(i=0;i<6;i++)
				{
					int xy2[4];

					if(show_row[i])
					{
						xy[1]=w_y+top_height-1;
						xy[3]=xy[1];
		
						xy[2]+=max_breite[i];
	
						vsl_color(handle,LBLACK);
						v_pline(handle,2,xy);	/* Linie ber den Dateien */
	
						xy2[0]=xy[0];
						xy2[1]=xy[1]-3;
						xy2[2]=xy[2];
						xy2[3]=xy[3]-3;
	
						vsl_color(handle,WHITE);
						v_pline(handle,2,xy2);	/* Linie unter der šberschrift */
	
						xy2[0]=xy[0];
						xy2[1]=xy[1];
						xy2[2]=xy[0];
						xy2[3]=w_y+w_h;
	
						vsl_color(handle,LBLACK);
						v_pline(handle,2,xy2);	/* Linie links/Dateien */
	
						xy2[1]=w_y;
						xy2[3]=w_y+top_height-4;
	
						v_pline(handle,2,xy2);	/* Linie links/šberschrift */
	
						xy[0]+=max_breite[i];
	
						xy2[0]=xy[0]-4;
						xy2[1]=xy[1];
						xy2[2]=xy[0]-4;
						xy2[3]=w_y+w_h;
	
						vsl_color(handle,WHITE);
						v_pline(handle,2,xy2);	/* Linie rechts/Dateien */
	
						xy2[1]=w_y;
						xy2[3]=w_y+top_height-4;
	
						v_pline(handle,2,xy2);	/* Linie rechts/šberschrift */
					}
				}
			}

			vswr_mode(handle,MD_TRANS);

			{
				int x;
	
				x=w_x+left_space;
				mt_rsrc_gaddr(5,TIT_FILE,&alert,&global);
				if(sort_by==2 || sort_by==-2)
					vst_effects(handle,9);
				else
					vst_effects(handle,0);
				v_gtext(handle,x,w_y,alert);
	
				x+=max_breite[BR_FILE];
				if(show_row[BR_SIZE])
				{
					mt_rsrc_gaddr(5,TIT_SIZE,&alert,&global);
					if(sort_by==3 || sort_by==-3)
						vst_effects(handle,9);
					else
						vst_effects(handle,0);
					v_gtext(handle,x,w_y,alert);
		
					x+=max_breite[BR_SIZE];
				}

				if(show_row[BR_TIME])
				{
					mt_rsrc_gaddr(5,TIT_TIME,&alert,&global);
					if(sort_by==4 || sort_by==-4)
						vst_effects(handle,9);
					else
						vst_effects(handle,0);
					v_gtext(handle,x,w_y,alert);
		
					x+=max_breite[BR_TIME];
				}

				if(show_row[BR_DATE])
				{
					mt_rsrc_gaddr(5,TIT_DATE,&alert,&global);
					if(sort_by==5 || sort_by==-5)
						vst_effects(handle,9);
					else
						vst_effects(handle,0);
					v_gtext(handle,x,w_y,alert);
		
					x+=max_breite[BR_DATE];
				}
				
				if(show_row[BR_ATTR])
				{
					mt_rsrc_gaddr(5,TIT_ATTR,&alert,&global);
					if(sort_by==6 || sort_by==-6)
						vst_effects(handle,9);
					else
						vst_effects(handle,0);
					v_gtext(handle,x,w_y,alert);
		
					x+=max_breite[BR_ATTR];
				}
				
				if(show_row[BR_PATH])
				{
					mt_rsrc_gaddr(5,TIT_PATH,&alert,&global);
					if(sort_by==7 || sort_by==-7)
						vst_effects(handle,9);
					else
						vst_effects(handle,0);
					v_gtext(handle,x,w_y,alert);
				}
			}

			vst_effects(handle,0);

			if(sort_by>1 || sort_by<-1)
			{
				xy[0]=w_x+left_space;
				for(i=0;i<(sort_by < 0 ? -sort_by : sort_by)-1;i++)
				{
					if(show_row[i])
						xy[0]+=max_breite[i];
				}

				if(vsl_color(handle,LBLACK)==LBLACK)
					xy[0]-=13;
				else
					xy[0]-=10;
				if(top_height>=10)
				{
					xy[1]=w_y+top_height/2-3;
					xy[2]=xy[0]+4;
					xy[3]=xy[1];
					xy[4]=xy[0]+2;
					if(sort_by>0)
						xy[5]=xy[1]-2;
					else
						xy[5]=xy[1]+2;
				}
				else
				{
					xy[1]=w_y+top_height/2-2;
					xy[2]=xy[0]+2;
					xy[3]=xy[1];
					xy[4]=xy[0]+1;
					if(sort_by>0)
						xy[5]=xy[1]-1;
					else
						xy[5]=xy[1]+1;
				}
				xy[6]=xy[0];
				xy[7]=xy[1];

				vsl_color(handle,BLACK);
				v_pline(handle,4,xy);
			}

			{
				FILE_INFO *fi;
				int xes[6];
				unsigned long first;
				unsigned long last;

				xes[0]=w_x+left_space;
				xes[1]=w_x+left_space+max_breite[BR_FILE]+max_breite[BR_SIZE]-9;

				xes[2]=w_x+left_space;
				for(i=BR_FILE;i<=BR_SIZE;i++)
				{
					if(show_row[i])
						xes[2]+=max_breite[i];
				}
				xes[3]=w_x+left_space;
				for(i=BR_FILE;i<=BR_TIME;i++)
				{
					if(show_row[i])
						xes[3]+=max_breite[i];
				}
				xes[4]=w_x+left_space;
				for(i=BR_FILE;i<=BR_DATE;i++)
				{
					if(show_row[i])
						xes[4]+=max_breite[i];
				}
				xes[5]=w_x+left_space;
				for(i=BR_FILE;i<=BR_ATTR;i++)
				{
					if(show_row[i])
						xes[5]+=max_breite[i];
				}

/*				
				xes[2]=w_x+left_space+max_breite[BR_FILE]+max_breite[BR_SIZE];
				xes[3]=w_x+left_space+max_breite[BR_FILE]+max_breite[BR_SIZE]+max_breite[BR_TIME];
				xes[4]=w_x+left_space+max_breite[BR_FILE]+max_breite[BR_SIZE]+max_breite[BR_TIME]+max_breite[BR_DATE];
				xes[5]=w_x+left_space+max_breite[BR_FILE]+max_breite[BR_SIZE]+max_breite[BR_TIME]+max_breite[BR_DATE]+max_breite[BR_ATTR];
*/

				first=first_shown;
				if((cxy[1]-w_y)>top_height)
					first+=(unsigned long) ((cxy[1]-w_y-top_height)/line_height);

				last=((cxy[3]-w_y-top_height)/line_height)+1+first_shown;

				fi=get_from_list(first+1);

				l=first;
				while(fi && l<last)
				{
					int y;
					char mein[11];

					y=w_y+top_height+(int) ((l-first_shown)*line_height);

					v_gtext(handle,xes[0],y,fi->name);

					/* Dislpay file size */
					if(show_row[BR_SIZE])
					{
						vst_alignment(handle,2,5,&dummy,&dummy);
						ultoa(fi->size,mein,10);
						v_gtext(handle,xes[1],y,mein);
						vst_alignment(handle,0,5,&dummy,&dummy);
					}

					/* Dislpay file time */
					if(show_row[BR_TIME])
					{
						sprintf(mein,"%02d:%02d:%02d",
							(fi->time & 0xf800)/0x0800,
							(fi->time & 0x07e0)/0x0020,
							(fi->time & 0x001f)*2);
						v_gtext(handle,xes[2],y,mein);
					}

					/* Dislpay file date */
					if(show_row[BR_DATE])
					{
						{ /* Prfen, ob Tag oder Monat vorne stehen soll */
							OBJECT *tree;
							char trenner;
	
							mt_rsrc_gaddr(0,LANGUAGE_SETTING,&tree,&global);
							trenner=tree[LS_DM_TRENNER].ob_spec.tedinfo->te_ptext[0];
	
							if(tree[LS_DAY_MONTH].ob_state & SELECTED)
							{
								sprintf(mein,"%02d%c%02d%c%04d",
									(fi->date & 0x001f),
									trenner,
									(fi->date & 0x01e0)/0x0020,
									trenner,
									(fi->date & 0xfe00)/0x0200+1980);
							}
							else
							{
								sprintf(mein,"%02d%c%02d%c%04d",
									(fi->date & 0x01e0)/0x0020,
									trenner,
									(fi->date & 0x001f),
									trenner,
									(fi->date & 0xfe00)/0x0200+1980);
							}
						}
						v_gtext(handle,xes[3],y,mein);
					}

					/* Dislpay file attribute */
					if(show_row[BR_ATTR])
					{
						mein[0]=(fi->attrib & FA_READONLY) ? 'R' : '-';
						mein[1]=(fi->attrib & FA_HIDDEN) ? 'H' : '-';
						mein[2]=(fi->attrib & FA_SYSTEM) ? 'S' : '-';
						mein[3]=(fi->attrib & FA_VOLUME) ? 'V' : '-';
						mein[4]=(fi->attrib & FA_ARCHIVE) ? 'A' : '-';
						mein[5]='\0';
						v_gtext(handle,xes[4],y,mein);
					}

					if(show_row[BR_PATH])
						v_gtext(handle,xes[5],y,fi->pfad);

					if(fi->selected)
					{
						int k;
						int xy[4];

						vswr_mode(handle,MD_XOR);

						vsf_color(handle,BLACK);

						xy[1]=y;
						xy[3]=y+line_height;

						xy[0]=w_x+left_space-1;
						xy[2]=xy[0]+max_breite[0]-7;

						for(i=1;i<6;i++)
						{
							if(show_row[i])
							{
								v_bar(handle,xy);

								for(k=i; k>0; k--)
								{
									if(show_row[k-1])
									{
										xy[0]+=max_breite[k-1];
										break;
									}
								}
								
								
								xy[2]=xy[0]+max_breite[i]-7;
							}
						}

						v_bar(handle,xy);

						vswr_mode(handle,MD_TRANS);
					}

					fi=get_next_in_list(fi);
					l++;
				}
			}
		}
		if(no_first_next)
		{
			ww=0;
			hh=0;
		}
		else
			mt_wind_get(window_handle,WF_NEXTXYWH,&xx,&yy,&ww,&hh,&global);
	}

	set_mouse(M_ON);
	mt_wind_update(END_UPDATE,&global);
}

int calc_slider(void)
{
	int ret=0;
	int x,y,w,h;
	static int message_send=0;

	if(mt_wind_update(BEG_UPDATE|there_is_check_and_set,&global))
	{
		message_send=0;

		mt_wind_get(window_handle,WF_WORKXYWH,&x,&y,&w,&h,&global);
	
		x=6;
		for(h=0;h<6;h++)
		{
			if(show_row[h])
				x+=max_breite[h];
		}
	
		if(w>=x)
		{
			mt_wind_set(window_handle,WF_HSLSIZE,1000,0,0,0,&global);
			mt_wind_set(window_handle,WF_HSLIDE,0,0,0,0,&global);
			if(scrolled_left!=0)
			{
				scrolled_left=0;
				ret=1;
			}
		}
		else
		{
			int help;
	
			if(scrolled_left>x-w)
			{
				scrolled_left=x-w;
				ret=1;
			}
	
			if(w)
				mt_wind_set(window_handle,WF_HSLSIZE,(int) ((((unsigned long) w)*1000l)/x),0,0,0,&global);
			else
				mt_wind_set(window_handle,WF_HSLSIZE,-1,0,0,0,&global);
	
			help=(int) (((double) ((double) ((scrolled_left)))/((double) (x-w)))*1000);
	
			if(help<1)
				mt_wind_set(window_handle,WF_HSLIDE,0,0,0,0,&global);
			else
				mt_wind_set(window_handle,WF_HSLIDE,help,0,0,0,&global);
		}
	
		if(lines_to_show>=finfos)
		{
			mt_wind_set(window_handle,WF_VSLSIZE,1000,0,0,0,&global);
			mt_wind_set(window_handle,WF_VSLIDE,0,0,0,0,&global);
			if(first_shown!=0l)
			{
				first_shown=0l;
				ret=1;
			}
		}
		else
		{
			int help;
	
			if(first_shown>finfos-lines_to_show)
			{
				first_shown=finfos-lines_to_show;
				ret=1;
			}
	
			if(lines_to_show)
				mt_wind_set(window_handle,WF_VSLSIZE,(int) ((((unsigned long) lines_to_show)*1000l)/finfos),0,0,0,&global);
			else
				mt_wind_set(window_handle,WF_VSLSIZE,-1,0,0,0,&global);
	
			help=(int) ((double) ((double) ((first_shown)*1000))/((double) (finfos-lines_to_show)));
	
			if(help<1)
				mt_wind_set(window_handle,WF_VSLIDE,0,0,0,0,&global);
			else
				mt_wind_set(window_handle,WF_VSLIDE,(int) ((double) ((double) ((first_shown)*1000))/((double) (finfos-lines_to_show))),0,0,0,&global);
		}

		mt_wind_update(END_UPDATE,&global);
	
		return ret;
	}
	else
	{
		int msg[8];

		if(message_send==0)
		{
			message_send=1;

			msg[0]=0x9277;
			msg[1]=ap_id;
			msg[2]=0;
			msg[3]=0x9277;
			msg[4]='cs';
	
			mt_appl_write(ap_id,16,msg,&global);
		}

		return 0;
	}
}

void move_up_down(long diff)
{
	GRECT r,b;

	if(diff<0)
	{
		if(-diff>first_shown)
			diff=-first_shown;
	}
	else
	{
		if(first_shown+lines_to_show>=finfos)
			diff=0;
		else if(first_shown+diff+lines_to_show>finfos)
			diff=first_shown+finfos-lines_to_show;
	}

	first_shown+=diff;

	calc_slider();

	if((diff>0 && diff<lines_to_show) ||
		(diff<0 && -diff<lines_to_show))
	{
		mt_wind_update(BEG_UPDATE,&global);
		set_mouse(M_OFF);

		mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);

		r.g_y+=top_height;
		r.g_h-=top_height;

		mt_wind_get_grect(window_handle,WF_FIRSTXYWH,&b,&global);
		while(b.g_w && b.g_h)
		{
			b.g_w=(b.g_x+b.g_w<r.g_x+r.g_w ? b.g_x+b.g_w : r.g_x+r.g_w)-(b.g_x>r.g_x ? b.g_x : r.g_x);
			b.g_h=(b.g_y+b.g_h<r.g_y+r.g_h ? b.g_y+b.g_h : r.g_y+r.g_h)-(b.g_y>r.g_y ? b.g_y : r.g_y);
			b.g_x=b.g_x>r.g_x ? b.g_x : r.g_x;
			b.g_y=b.g_y>r.g_y ? b.g_y : r.g_y;
	
			if(((b.g_x+b.g_w<r.g_x+r.g_w ? b.g_x+b.g_w : r.g_x+r.g_w) > (b.g_x>r.g_x ? b.g_x : r.g_x)) && ((b.g_y+b.g_h<r.g_y+r.g_h ? b.g_y+b.g_h : r.g_y+r.g_h) > (b.g_y>r.g_y ? b.g_y : r.g_y)))
			{
				MFDB quell={0};
				MFDB ziel={0};
				int xy[8];
	
				xy[0]=b.g_x;
				xy[1]=b.g_y;
				xy[2]=xy[0]+b.g_w-1;
				xy[3]=xy[1]+b.g_h-1;
	
				xy[4]=xy[0];
	
				xy[5]=xy[1]-((int) (diff*((long) line_height)));
	
				xy[6]=xy[4]+b.g_w-1;
				xy[7]=xy[5]+b.g_h-1;
	
				vs_clip(vdi_h,1,xy);
	
				vro_cpyfm(vdi_h,S_ONLY,xy,&quell,&ziel);

				xy[0]=b.g_x;
				xy[2]=b.g_w;
			
				if(diff>0)
				{
					xy[1]=xy[7];
					xy[3]=xy[3]-xy[7]+1;
				}
				else
				{
					xy[1]=b.g_y;
					xy[3]=xy[7]-xy[3]+1;
				}

				xy[2]=(xy[0]+xy[2]<b.g_x+b.g_w ? xy[0]+xy[2] : b.g_x+b.g_w)-(xy[0]>b.g_x ? xy[0] : b.g_x);
				xy[3]=(xy[1]+xy[3]<b.g_y+b.g_h ? xy[1]+xy[3] : b.g_y+b.g_h)-(xy[1]>b.g_y ? xy[1] : b.g_y);
				xy[0]=xy[0]>b.g_x ? xy[0] : b.g_x;
				xy[1]=xy[1]>b.g_y ? xy[1] : b.g_y;

				if(((xy[0]+xy[2]<b.g_x+b.g_w ? xy[0]+xy[2] : b.g_x+b.g_w) > (xy[0]>b.g_x ? xy[0] : b.g_x)) &&
					((xy[1]+xy[3]<b.g_y+b.g_h ? xy[1]+xy[3] : b.g_y+b.g_h) > (xy[1]>b.g_y ? xy[1] : b.g_y)))
				{
					xy[4]=xy[0];
					xy[5]=xy[1];
					xy[6]=xy[0]+xy[2]-1;
					xy[7]=xy[1]+xy[3]-1;

					vs_clip(vdi_h,1,&xy[4]);

					xy[0]*=-1;	/* Alle negativ, damit ohne WF_FIRST/NEXTXYWH gezeichet wird */
					xy[1]*=-1;
					xy[2]*=-1;
					xy[3]*=-1;

					redraw_window((GRECT *)xy);
				}
			}
	
			mt_wind_get_grect(window_handle,WF_NEXTXYWH,&b,&global);
		}

		set_mouse(M_ON);
		mt_wind_update(END_UPDATE,&global);
	}
	else if(diff)
	{
		mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);
		redraw_window(&r);
	}
}

void move_left_right(int diff)
{
	int old_sl;
	GRECT r,b;

	mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);

	r.g_x=6;
	for(i=0;i<6;i++)
	{
		if(show_row[i])
			r.g_x+=max_breite[i];
	}

	old_sl=scrolled_left;

	scrolled_left+=diff;

	if(scrolled_left<0)
		diff+=-scrolled_left;

	if(scrolled_left>r.g_x-r.g_w)
		diff-=scrolled_left-(r.g_x-r.g_w);

	if(old_sl+diff<0)
		diff=-old_sl;

	scrolled_left=old_sl+diff;

	calc_slider();

	if((diff>0 && diff<r.g_w) ||
		(diff<0 && -diff<r.g_w))
	{
		mt_wind_update(BEG_UPDATE,&global);
		set_mouse(M_OFF);

		mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);

		mt_wind_get_grect(window_handle,WF_FIRSTXYWH,&b,&global);
		while(b.g_w && b.g_h)
		{
			b.g_w=(b.g_x+b.g_w<r.g_x+r.g_w ? b.g_x+b.g_w : r.g_x+r.g_w)-(b.g_x>r.g_x ? b.g_x : r.g_x);
			b.g_h=(b.g_y+b.g_h<r.g_y+r.g_h ? b.g_y+b.g_h : r.g_y+r.g_h)-(b.g_y>r.g_y ? b.g_y : r.g_y);
			b.g_x=b.g_x>r.g_x ? b.g_x : r.g_x;
			b.g_y=b.g_y>r.g_y ? b.g_y : r.g_y;
	
			if(((b.g_x+b.g_w<r.g_x+r.g_w ? b.g_x+b.g_w : r.g_x+r.g_w) > (b.g_x>r.g_x ? b.g_x : r.g_x)) && ((b.g_y+b.g_h<r.g_y+r.g_h ? b.g_y+b.g_h : r.g_y+r.g_h) > (b.g_y>r.g_y ? b.g_y : r.g_y)))
			{
				MFDB quell={0};
				MFDB ziel={0};
				int xy[8];

				xy[0]=b.g_x;
				xy[1]=b.g_y;
				xy[2]=xy[0]+b.g_w-1;
				xy[3]=xy[1]+b.g_h-1;
	
				xy[4]=xy[0]-diff;

				xy[5]=xy[1];
	
				xy[6]=xy[4]+b.g_w-1;
				xy[7]=xy[5]+b.g_h-1;
	
				vs_clip(vdi_h,1,xy);
	
				vro_cpyfm(vdi_h,S_ONLY,xy,&quell,&ziel);
	
				xy[3]=b.g_h;
				xy[1]=b.g_y;

				if(diff>0)
				{
					xy[0]=xy[6];
					xy[2]=xy[2]-xy[6]+1;
				}
				else
				{
					xy[0]=b.g_x;
					xy[2]=xy[6]-xy[2]+1;
				}

				xy[2]=(xy[0]+xy[2]<b.g_x+b.g_w ? xy[0]+xy[2] : b.g_x+b.g_w)-(xy[0]>b.g_x ? xy[0] : b.g_x);
				xy[3]=(xy[1]+xy[3]<b.g_y+b.g_h ? xy[1]+xy[3] : b.g_y+b.g_h)-(xy[1]>b.g_y ? xy[1] : b.g_y);
				xy[0]=xy[0]>b.g_x ? xy[0] : b.g_x;
				xy[1]=xy[1]>b.g_y ? xy[1] : b.g_y;

				if(((xy[0]+xy[2]<b.g_x+b.g_w ? xy[0]+xy[2] : b.g_x+b.g_w) > (xy[0]>b.g_x ? xy[0] : b.g_x)) &&
					((xy[1]+xy[3]<b.g_y+b.g_h ? xy[1]+xy[3] : b.g_y+b.g_h) > (xy[1]>b.g_y ? xy[1] : b.g_y)))
				{
					xy[4]=xy[0];
					xy[5]=xy[1];
					xy[6]=xy[0]+xy[2]-1;
					xy[7]=xy[1]+xy[3]-1;

					vs_clip(vdi_h,1,&xy[4]);

					xy[0]*=-1;	/* Alle negativ, damit ohne WF_FIRST/NEXTXYWH gezeichet wird */
					xy[1]*=-1;
					xy[2]*=-1;
					xy[3]*=-1;

					redraw_window((GRECT *)xy);
				}
			}
	
			mt_wind_get_grect(window_handle,WF_NEXTXYWH,&b,&global);
		}

		set_mouse(M_ON);
		mt_wind_update(END_UPDATE,&global);
	}
	else if(diff)
	{
		mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);
		redraw_window(&r);
	}
}
