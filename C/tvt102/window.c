#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <stdio.h>
#include <string.h>
#include "main.h"
#include "tndefs.h"
#include "telvt102.h"

/* Prototypes... */

	void  init_win(void);
	void  draw_win(void);
	void	draw_line(short ,short ,short , const char * );
	void  create_win(const char *);
	void  open_win(void);
	void  close_win(void);
	void  delete_win(void);
	void  full_win(void);

	void do_reset(void);
	void do_jump_scroll(void);
	void do_rev_bs(void);
	void do_chg_fnt(void);
	void do_key_pad(void);
	void do_cur_key(void);
	void do_dump_file(void);
	void do_transcript(void);
	void do_printer(void);
	void do_info(void);
	void clear_fonts(void);
	void resize(void);
	
	short do_menu(short);
	
	short dialog(OBJECT *, short);
	void  set_button(OBJECT *, short, short);
	short get_button(OBJECT *, short);

	extern	short nlines,nchars;
/* Externals... */

	extern void  init_it (void);
	extern void  do_redraw (int handle, GRECT *rect, int scroll);

	extern 	void print_cursor(short);
	extern 	void 		touch_mfdb(void);
	extern	void	redraw_page(void);
	extern	short	choose(short);
	extern	int send_to_socket(int, char *, int);


	extern short 	endmainloop;
	extern short 	pause;
	extern short 	vdi_handle, work_out[57];
	extern WINDOW	win;
	extern MFDB work, screen;
	extern	short oldx,oldy,oldw, oldh, newx,newy, neww,newh;

	extern char ascii_buf[MAX_ROW][MAX_COL];
	extern char attri_buf[MAX_ROW][MAX_COL];
	extern short real_row[MAX_ROW],inv_row[MAX_ROW];

	extern short do_string(int, char *);
	int	s=0;	/*for do_string	*/


	extern 	OBJECT *menu_ptr, *about_ptr, *host_ptr, 
				*sizer_ptr, *chooser, *fsize_ptr;
	extern short chrwid,chrhgt;
	extern short 	blitter, blockcursor, blinkcursor;

	extern short 	openn;
	extern short jump,newline,key_ret,screen_norm,wrap,dont_size;
	extern short keypad,cur_key,rev_bs,jump_scroll,smooth_scroll,sizeable;
	extern short write_file,dump_file,print_it,absolute,info_ok;
	extern short t_off,b_off;
	extern char title[32];
	extern char hostb[80],portb[4];
	extern char fontname[35];
	extern	short fid, ptsize,fnum,bsb,sb; 

	extern short nchb,nlib,fontb, oldfontb,saved, wait,
				reading,read_from_file, remap, mapped, graph_on;
	extern FILE *fp,*savefp;
	extern char savename[12];
	extern	char fname[9],lights[4];
	extern short bps;
	short pxyarray[8], y_adj,k, size_changed;
	extern short win_opened;
  
  char c, out[140], font_name[32];
	short x_rez,y_rez;
	short tfontb, tgfontb, tmap, tnlines, tnchars, tptsize, wid, hgt;

void init_win(void)
	{
	GRECT rect, deskrect;

	wind_get(DESK, WF_WXYWH, &deskrect.g_x, &deskrect.g_y, &deskrect.g_w,
			&deskrect.g_h);

	wind_update(BEG_UPDATE);
	wind_get(win.handle, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

/*	y_adj = (win.row>nlines ? win.row-nlines : 0) * 16;
	y_adj=0;
*/
	do
			{
			if (rc_intersect(&win.w_rect, &rect))
				{
				rc_intersect(&deskrect, &rect);
				pxyarray[4]=rect.g_x;
				pxyarray[5]=rect.g_y;
				pxyarray[6]=rect.g_x+rect.g_w-1;
				pxyarray[7]=rect.g_y+rect.g_h-1/*+chrhgt*/;
				pxyarray[0]=pxyarray[4]-win.w_rect.g_x;
				pxyarray[1]=pxyarray[5]-win.w_rect.g_y;
				pxyarray[2]=pxyarray[6]-win.w_rect.g_x;
				pxyarray[3]=pxyarray[7]-win.w_rect.g_y;
				v_hide_c(vdi_handle);
				vro_cpyfm(vdi_handle, 3, pxyarray, &work, &screen);
				v_show_c(vdi_handle, 1);
				}
			wind_get(win.handle, WF_NEXTXYWH, &rect.g_x, &rect.g_y,
						&rect.g_w, &rect.g_h);
			}
	while (rect.g_w & rect.g_h);

	wind_update(END_UPDATE);
	}

void draw_win(void)
	{
	short pxy[8];
	GRECT rect, deskrect;
	wind_get(DESK, WF_WORKXYWH, &deskrect.g_x, &deskrect.g_y, 
				&deskrect.g_w, &deskrect.g_h);

	wind_get(win.handle, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, 
				&rect.g_w, &rect.g_h);
	wind_update(BEG_UPDATE);
/*
	oldx=deskrect.g_x;oldy=deskrect.g_y;oldw=deskrect.g_w;oldh=deskrect.g_h;
	newx=rect.g_x;newy=rect.g_y;neww=rect.g_w;newh=rect.g_h;

		sprintf(out,"a %d %d %d %d %d %d %d %d"
				, oldx,newx,oldy, newy, oldw, neww,oldh, newh);
	lprintf("%s\n\r",out);
*/
/*		wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), 
				NULL, NULL);
*/
	do
		{
		if (rc_intersect(&win.w_rect, &rect))
			{
			rc_intersect(&deskrect, &rect);
/*
				newx=rect.g_x;newy=rect.g_y;neww=rect.g_w;newh=rect.g_h;

				sprintf(out,"b %d %d %d %d   %d %d %d %d"
						, oldx,newx,oldy, newy, oldw, neww,oldh, newh);
				lprintf("%s\n\r",out);
*/
				pxy[4]=rect.g_x;
				pxy[5]=rect.g_y;
				pxy[6]=rect.g_x+rect.g_w-1;
				pxy[7]=rect.g_y+rect.g_h-1;
				pxy[0]=pxy[4]-win.w_rect.g_x;
				pxy[1]=pxy[5]-win.w_rect.g_y;
				pxy[2]=pxy[6]-win.w_rect.g_x;
				pxy[3]=pxy[7]-win.w_rect.g_y;
				v_hide_c(vdi_handle);
				vro_cpyfm(vdi_handle, 3, pxy, &work, &screen);
				v_show_c(vdi_handle, 1);
			}
		wind_get(win.handle, WF_NEXTXYWH, &rect.g_x, &rect.g_y, 
					&rect.g_w, &rect.g_h);
		}
	while (rect.g_w | rect.g_h);

	wind_update(END_UPDATE);
	}

/*void draw_line(short handle,short tx,short ty, const char *t )
	{
	short pxy[8];
	GRECT rect, deskrect;
	graf_mouse(M_OFF,NULL);
	wind_get(DESK, WF_WORKXYWH, &deskrect.g_x, &deskrect.g_y, 
				&deskrect.g_w, &deskrect.g_h);
	wind_get(win.handle, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, 
				&rect.g_w, &rect.g_h);
	wind_update(BEG_UPDATE);
	do
		{
		if (rc_intersect(&win.w_rect, &rect))
			{
				rc_intersect(&deskrect, &rect);
				pxy[4]=rect.g_x;
				pxy[5]=rect.g_y;
				pxy[6]=rect.g_x+rect.g_w-1;
				pxy[7]=rect.g_y+rect.g_h-1;
				pxy[0]=pxy[4]-win.w_rect.g_x;
				pxy[1]=pxy[5]-win.w_rect.g_y;
				pxy[2]=pxy[6]-win.w_rect.g_x;
				pxy[3]=pxy[7]-win.w_rect.g_y;
				v_hide_c(vdi_handle);
				
/*				vs_clip(vdi_handle,1,pxy);*/
	
				v_gtext(handle, tx, ty, t); 

/*				vs_clip(vdi_handle,0,pxy);*/

				v_show_c(vdi_handle, 1);
			}
		wind_get(win.handle, WF_NEXTXYWH, &rect.g_x, &rect.g_y, 
					&rect.g_w, &rect.g_h);
		}
	while (rect.g_w | rect.g_h);

	wind_update(END_UPDATE);
	graf_mouse(M_ON,NULL);
	}
*/
void create_win(const char *title)
	{
	GRECT deskrect, windrect, calcrect;
/*	short calc;*/
	x_rez = work_out[0] +1;
	y_rez = work_out[1] +1;
	if ((work_out[1]+1)<=201) win.y_offset=8+3;
	else win.y_offset=16+3;
	y_rez = y_rez - win.y_offset;
/*	win.y_offset=win.y_offset+2*(16+3);
*/
	wind_get(DESK, WF_PREVXYWH, &deskrect.g_x, &deskrect.g_y, 
				&deskrect.g_w,&deskrect.g_h);
	wind_calc(WC_BORDER, WINTYPE,
				0, 0, nchars*chrwid, nlines*chrhgt+1,
				&windrect.g_x, &windrect.g_y, &windrect.g_w, &windrect.g_h);

/*	windrect.g_x=deskrect.g_x;
	windrect.g_y=deskrect.g_y;
*/
	windrect.g_x=0;
	windrect.g_y=win.y_offset;
	windrect.g_w=min(windrect.g_w, deskrect.g_w);
	windrect.g_h=min(windrect.g_h, deskrect.g_h);

	wind_calc(WC_WORK, WINTYPE, windrect.g_x, windrect.g_y, windrect.g_w, windrect.g_h,
			&calcrect.g_x, &calcrect.g_y, &calcrect.g_w, &calcrect.g_h);

/*	rc_center(&deskrect, &windrect);
*/
	win.handle=wind_create(WINTYPE, windrect.g_x, windrect.g_y, windrect.g_w,
				windrect.g_h);
	if (win.handle>=0)
			{
			wind_title(win.handle, title);
			wind_open(win.handle, windrect.g_x, windrect.g_y, 
					windrect.g_w, windrect.g_h);
			}

	oldx=windrect.g_x;oldy=windrect.g_y;oldw=windrect.g_w;oldh=windrect.g_h;
	win.b_rect=windrect;

	wind_calc(WC_WORK, WINTYPE, win.b_rect.g_x,	win.b_rect.g_y,  
				win.b_rect.g_w,	win.b_rect.g_h,
				&win.w_rect.g_x, &win.w_rect.g_y, &win.w_rect.g_w, &win.w_rect.g_h);
	win_opened=TRUE;
	}
	

void open_win(void)
	{
	wind_open(win.handle, win.b_rect.g_x, win.b_rect.g_y, win.b_rect.g_w,
				win.b_rect.g_h);
	}

void close_win(void)
	{
	wind_close(win.handle);
	}

void delete_win(void)
	{
	wind_delete(win.handle);
	}
	
void full_win(void)
	{
	GRECT deskrect,windrect;
/*	short junk;*/
/*
	wind_get(DESK, WF_FULLXYWH, &deskrect.g_x, &deskrect.g_y, &deskrect.g_w,
				&deskrect.g_h);
	wind_calc(WC_BORDER, WINTYPE, 0, 0, nchars*chrwid, nlines*chrhgt,
				&win.b_rect.g_x, &win.b_rect.g_y, &win.b_rect.g_w, &win.b_rect.g_h);
	win.b_rect.g_w=min(win.b_rect.g_w, deskrect.g_w);
	win.b_rect.g_h=min(win.b_rect.g_h, deskrect.g_h);
	rc_center(&deskrect, &win.b_rect);
	wind_calc(WC_WORK, WINTYPE, win.b_rect.g_x, win.b_rect.g_y, 
				win.b_rect.g_w, win.b_rect.g_h,
				&win.w_rect.g_x, &win.w_rect.g_y, &win.w_rect.g_w, &win.w_rect.g_h);
	wind_set(win.handle, WF_CXYWH, win.b_rect.g_x, win.b_rect.g_y, 
				win.b_rect.g_w, win.b_rect.g_h);
	wind_set(win.handle, WF_HSLSIZE,
				(short)(((long)win.w_rect.g_w*1000)/(nchars*chrwid)), 0, 0, 0);
	wind_set(win.handle, WF_VSLSIZE,
				(short)(((long)win.w_rect.g_h*1000)/(nlines*chrhgt)), 0, 0, 0);
	wind_get(win.handle, WF_HSLIDE, &junk, NULL, NULL, NULL);
	win.x_offset=(short)(((long)junk*((nchars*chrwid)-(long)win.w_rect.g_w))/1000);
	wind_get(win.handle, WF_VSLIDE, &junk, NULL, NULL, NULL);
	win.y_offset=(short)(((long)junk*((nlines*chrhgt)-(long)win.w_rect.g_h))/1000);
*/
	wind_get(DESK, WF_PREVXYWH, &deskrect.g_x, &deskrect.g_y, &deskrect.g_w,
				&deskrect.g_h);
	windrect.g_x=0;
	windrect.g_y=56;
	windrect.g_w=nchars*chrwid;
	windrect.g_h=nlines*chrhgt-1/*+4*/;

/*	wind_calc(WC_BORDER, WINTYPE,
				0,0, windrect.g_w, windrect.g_h,
				&windrect.g_x, &windrect.g_y, &windrect.g_w, &windrect.g_h);
*/

	win.b_rect=windrect;

	wind_calc(WC_WORK, WINTYPE, win.b_rect.g_x,	win.b_rect.g_y,  
				win.b_rect.g_w,	win.b_rect.g_h,
				&win.w_rect.g_x, &win.w_rect.g_y, &win.w_rect.g_w, &win.w_rect.g_h);
	}

void resize(void)
	{
	short i, k;
	k=0;
	for (i=0; i< nlines; i++)
		{
		k++; if (k>nlines) k-=nlines;
		real_row[i]=k;
		strcpy(ascii_buf[i],ascii_buf[i+1]);


		}

/*	int i,k,j,n;
	char tmp[132],tmp1[8];
/* if tnlines > nlines, add some at end.
		else remove some from top.
		in tnchars > nchars, add spaces at end,
		else null out ends.	*/

	if (wait)
		for (i=0;i< nlines;i++)
			{
			k=real_row[i];
			sprintf(tmp,"%2d %2dxyz",k,i);
			sprintf(tmp1,"%2d",i);
/*			strncpy(ascii_buf[k],tmp1,2);*/
			strncpy(ascii_buf[i],tmp,5);
/*
			for (n=0;n<=3;n++)
				for (j=0; j<=10000/**/;j++);

			redraw_page();
*/
			}	
*/
	}

short do_menu(short menu_item)
	{
	short junk;
	
	switch (menu_item)
		{
		case AboutTelnet:
			dialog(about_ptr, 0);
			break;

		case OpenHostO:
			openn |=OPENABLE;		
			read_from_file=FALSE;
			break;

		case OpenLocalL:
			read_from_file=TRUE;
			break;

		case CloseC:
			openn|=CLOSING;
			break;

		case QuitQ:
			endmainloop=TRUE;
			break;
			
		case FontIDN:
				choose(k); /* falls thru	*/
		
		case 99:
				tfontb=fid;
				tptsize=ptsize;
				if (fid!=0)
					{
					vst_font(vdi_handle,fid);
/*					vqt_name(vdi_handle, fnum, fontname);
*/
					vst_point(vdi_handle, ptsize, &junk, &junk, &wid, &hgt);
					}
					
				switch (fid)
					{
					case 45: /*8,10 ASCII */
						tgfontb = 53;
						tmap=FALSE;
						goto done;
						break;						
						
					case 46:	/*8,10	ASCII THIN*/
						goto g54;
						
					case 52:	/*6,7,8,9,10 STANSI*/
						goto g58;
					
					case 55:	/*8,9,10 THANSI*/
						goto m55;
						
					case 56:	/*8,9,10 	7x? fonts*/
						goto m56;

					default:
						switch (wid)
							{
							case 3:
								switch (hgt)
									{
									case 16:
										goto m55;
									default:
										goto none;
									}
									
							case 4:
								switch (hgt)
									{
									case 5:
									case 6:
									case 8:
									case 16:
										goto g58;
									default:
										goto none;
									}
							case 5:
								switch (hgt)
									{
									case 6:
										goto m56;
									case 8:
									case 16:
										goto g54;
									default:
										goto none;
									}
							case 6:
								switch (hgt)
									{
									case 6:
										goto g58;
									default:
										goto none;
									}
							case 7:
								switch (hgt)
									{
									case 8:
									case 16:
										goto m56;
									default:
										goto none;
									}
							case 8:
								switch (hgt)
									{
									case 8:
									case 16:
										goto g58;
									default:
										goto none;

									}
							default:
								goto none;
							}
						break;
					}
g54:		tgfontb=54;
				tmap=FALSE;
				goto done;
g58:		tgfontb=58;
				tmap=FALSE;
				goto done;
m54:		tgfontb=54;
				tmap=TRUE;
				goto done;
m55:		tgfontb=54;
				tmap=TRUE;
				goto done;
m56:		tgfontb=56;
				tmap=TRUE;
				goto done;
none:		tmap=TRUE;
				tgfontb=tfontb;
done:
/*				sprintf(out, "[1][You chose font name:|%s %d %dpt. %dx%d][OK]", 
								fontname,fid,ptsize,wid,hgt);
				form_alert(1, out);
*/
				win.font_no=fid;
				win.gfont_no=tgfontb;
				win.gfont_size = win.font_size = ptsize;
				mapped=tmap;				

/*				goto chg_fnt;
*/
chg_fnt:
			tnchars=nchars;
			tnlines=nlines;
			vst_font(vdi_handle,win.font_no);
			vst_point(vdi_handle, win.font_size, &junk, &junk, &wid, &hgt);
			if (saved == FALSE)

				{
				nchb=nchars=x_rez/wid;
				if ((work_out[1]+1)<=201) 
					nlines=(y_rez-2*(8+3))/hgt;
				else
					nlines=(y_rez-2*(16+3))/hgt;
				if (nchars>=128) nchars=132;
				if (nchars<=127)
					{if (nchars>=80) nchars=80;}
				if (nlines>=25) nlines = (nlines/5)*5;	
				if (nlines>=tnlines) nlines = tnlines;	
				if ((oldfontb!=fontb) || (nlines!=nlib) || (nchars!=nchb)) 
					if (!dont_size)
						do_menu(LineCharS); /* I hope its recursive!! */
				}
/*				if ((nlines != tnlines) || (tnchars != tnchars))
*/					resize();
				chrwid=wid;
				chrhgt=hgt;

chg_fnt1:
			win.ssbot=win.scrollbot=nlines;
			if (saved == FALSE)
				do_chg_fnt();
			break;

		case LineCharS:
/*		short tfontb, tlines, tnchars, tptsize;*/
			oldfontb=fontb;
			sprintf(out,"%2d",nlines);
			strcpy(((TEDINFO *)
					(sizer_ptr[Numberoflines].ob_spec))->te_ptext,out);
			sprintf(out,"%3d",nchars);
			strcpy(((TEDINFO *)
					(sizer_ptr[NumberofChars].ob_spec))->te_ptext,out);
			dialog(sizer_ptr, 0/*Numberoflines*/);

			strcpy(out,((TEDINFO *)
					(sizer_ptr[Numberoflines].ob_spec))->te_ptext);
			k=0;
			c=out[k];
			if ((c >= '0') && (c <= '9'))
				{
				nlines=0;
				do
					{
					nlines = (10*nlines) +(c-'0');
					k++; c= out[k];
					} while ((c >= '0') && (c <= '9'));
				}
			if (nlib !=nlines) size_changed=TRUE;
			else size_changed=FALSE;
			nlib=nlines;

			strcpy(out,((TEDINFO *)
					(sizer_ptr[NumberofChars].ob_spec))->te_ptext);
			k=0;
			c=out[k];
			if ((c >= '0') && (c <= '9'))
				{
				nchars=0;
				do
					{
					nchars = (10*nchars) +(c-'0');
					k++; c= out[k];
					} while ((c >= '0') && (c <= '9'));
				}
			if ((nchb !=nchars) || (size_changed==TRUE)) size_changed=TRUE;
			else size_changed=FALSE;
			nchb=nchars; /* have an exit for recurse */
			goto chg_fnt1;

		case SavePrefs:
			if ((savefp = fopen(savename,"w")) != NULL) 
				{
				sprintf(out,"Host=%s\n",hostb);
				fputs(out,savefp);			
				sprintf(out,"Port=%s\n",portb);
				fputs(out,savefp);			
				sprintf(out,"Bs<->Del=%d\n",bsb);
				fputs(out,savefp);			
				sprintf(out,"Font ID.=%d\n",fid);
				fputs(out,savefp);
				sprintf(out,"Size=%d\n",ptsize);
				fputs(out,savefp);
				sprintf(out,"font name = %s\n",fontname);
				fputs(out,savefp);
				sprintf(out,"Lines=%d\n",nlib);
				fputs(out,savefp);			
				sprintf(out,"Chars=%d\n",nchars);
				fputs(out,savefp);			
				sprintf(out,"Rapid scroll=%d\n",sb);
				fputs(out,savefp);			
				fclose(savefp);
				}
			break;

/*		case MOBlitter:
			if (blitter==TRUE)
				{
				menu_icheck(menu_ptr, MOBlitter, 0);
				blitter=FALSE;
				}
			else
				{
				menu_icheck(menu_ptr, MOBlitter, 1);
				blitter=TRUE;
				}
			break;
*/
		case BlockCurs:
			print_cursor( 0);
			if (blockcursor==TRUE)
				{
				menu_icheck(menu_ptr, BlockCurs, 0);
				blockcursor=FALSE;
				}
			else
				{
				menu_icheck(menu_ptr, BlockCurs, 1);
				blockcursor=TRUE;
				}
			break;

/*		case BlinkCurs:
			print_cursor( 1);
			if (blinkcursor==TRUE)
				{
				menu_icheck(menu_ptr, BlinkCurs, 0);
				blinkcursor=FALSE;
				}
			else
				{
				menu_icheck(menu_ptr, BlinkCurs, 1);
				blinkcursor=TRUE;
				}
			break;
*/
		case KpadmodeK:
			do_key_pad();
			break;

		case CursmodeA:
			do_cur_key();
			break;

		case DumpFileF:
			do_dump_file();
			break;

		case CharFileT:
			do_transcript();
			break;

		case PrinterP:
			do_printer();
			break;		

		case BSDelB:
			do_rev_bs();		
			break;

		case ResetR:
			do_reset();
			break;
			
		case FastscrollJ:
			do_jump_scroll();		
			break;
		
		}
	return (endmainloop);
	}
	
void do_chg_fnt(void)
	{
	char msg[10];
	int s=0;
	
	nlib=nlines; nchb=nchars;
	touch_mfdb();
	close_win();delete_win();
	create_win(title);
	init_win();
	draw_win();
	if (sizeable==TRUE)
		{
		msg[0]=IAC;
		msg[1]=SB;
		msg[2]=NAWS;
		msg[3]=0;
		msg[4]=nchars;
		msg[5]=0;
		msg[6]=nlines;
		msg[7]=IAC;
		msg[8]=SE;
		msg[9]=0;
		send_to_socket(s, msg, 9);
		}
	do_info();
	}

void do_key_pad(void)
	{
	keypad=!keypad;
	if (keypad)
		menu_icheck(menu_ptr, KpadmodeK, 1);
	else
		menu_icheck(menu_ptr, KpadmodeK, 0);
	do_info();
	}
void do_cur_key(void)
	{
	cur_key=!cur_key;
	if (cur_key)
		menu_icheck(menu_ptr, CursmodeA, 1);
	else
		menu_icheck(menu_ptr, CursmodeA, 0);
	}
void do_dump_file(void)
	{
	dump_file=!dump_file;
	if (dump_file)
		{
		fp = fopen(fname,"ab");
		menu_icheck(menu_ptr, DumpFileF, 1);
		}
	else
		{
		menu_icheck(menu_ptr, DumpFileF, 0);
		fclose(fp);
		}
	if (dump_file)
		{
		menu_icheck(menu_ptr, CharFileT, 0);
		write_file=FALSE;
		}
	do_info();
	}
void do_transcript(void)
	{
	write_file=!write_file;
	if (write_file)
		{
		menu_icheck(menu_ptr, CharFileT, 1);
		fp = fopen(fname,"ab");
		}
	else
		{
		menu_icheck(menu_ptr, CharFileT, 0);
		fclose(fp);
		}
	if (write_file)
		{
		menu_icheck(menu_ptr, DumpFileF, 0);
		dump_file=FALSE;
		}
	do_info();
	}
void do_printer(void)
	{
	print_it=!print_it;
	if (print_it)
		menu_icheck(menu_ptr, PrinterP, 1);
	else
		{
		menu_icheck(menu_ptr, PrinterP, 0);
		fflush(NULL);
		}
	do_info();
	}

void do_reset(void)
	{
	win.flags=0;
	absolute=TRUE;
	wrap= !wrap;
	vst_font(vdi_handle,win.font_no);
/*	remap=FALSE;*/
	graph_on=FALSE;
	reading=FALSE;
	read_from_file=FALSE;
	if (dump_file) do_dump_file();
	if (print_it) do_printer();
	if (write_file) do_transcript();
	if (openn & OPENING) newline=FALSE;
	smooth_scroll=FALSE;
	redraw_page();
	do_info();
	}

void do_jump_scroll(void)
	{
	jump_scroll=!jump_scroll;
	if (jump_scroll)
		{
		menu_icheck(menu_ptr, FastscrollJ, 1);
		sb=TRUE;
		}
	else
		{
		menu_icheck(menu_ptr, FastscrollJ, 0);
		sb=FALSE;
		}
	}
	
	void do_rev_bs(void)
	{
	rev_bs=!rev_bs;
	if (rev_bs)
		{
		menu_icheck(menu_ptr, BSDelB, 1);
		bsb=TRUE;
		}
	else
		{
		bsb=FALSE;
		menu_icheck(menu_ptr, BSDelB, 0);
		}
	do_info();
	}
	
	
void do_info(void)
	{
	char mess1[4], mess2[4], mess3[4],mess4[4],mess5[4],mess6[4],
			mess7[4],mess8[4],mess9[2];

	if (rev_bs) strcpy( mess1,"BD");
	else strcpy(mess1,"  ");
	if (keypad) strcpy(mess2,"KA");
	else strcpy(mess2,"KN");
	if (dump_file) strcpy(mess3,"Dp");
	else 
	if (write_file) strcpy(mess3,"Tr");
	else  strcpy(mess3,"  ");
	if (print_it) strcpy( mess4,"Pr");
	else strcpy(mess4,"  ");
	if (newline) strcpy( mess5,"CR");
	else strcpy(mess5,"LF");
	if (absolute) strcpy( mess6,"A");
	else strcpy(mess6,"R");
	if (jump_scroll) strcpy( mess7,"F");
	else strcpy(mess7,"");
	if (smooth_scroll) strcpy( mess8,"S");
	else strcpy(mess8,"");
	if (wrap) strcpy( mess9,"W");
	else strcpy(mess9,"");

	sprintf(out,
			"r:%2d c:%2d sc:%2d:%2d %s%s%s%s ch %dx%d font %d %s %s %s %s %s %db/s %s "
			,win.row,win.col, win.scrolltop,win.scrollbot,mess6,mess7,mess8,mess9
			,chrwid,chrhgt, fid	,mess5,mess1,mess2,mess3,mess4,bps,lights);
if (info_ok)
	wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), 
				NULL, NULL);
	}

void clear_fonts(void)
	{
/*	menu_icheck(menu_ptr, x68pt5, 0);
	menu_icheck(menu_ptr, x89pt7, 0);
	menu_icheck(menu_ptr, x1610pt7, 0);
	menu_icheck(menu_ptr, x880col8, 0);
	menu_icheck(menu_ptr, x8132col5, 0);
	menu_icheck(menu_ptr, x1680col8, 0);
	menu_icheck(menu_ptr, x16132col5, 0);
	menu_icheck(menu_ptr, pt456, 0);
	menu_icheck(menu_ptr, pt467, 0);
	menu_icheck(menu_ptr, pt668, 0);
	menu_icheck(menu_ptr, pt889, 0);
	menu_icheck(menu_ptr, pt8161, 0);
	menu_icheck(menu_ptr, pt368, 0);
	menu_icheck(menu_ptr, pt489, 0);
	menu_icheck(menu_ptr, pt4161, 0);
*/	}

short dialog(OBJECT *obj, short edit)
	{
	GRECT rect;
	short exit;
/*		dialog(host_ptr, host);
			s=open_socket(((TEDINFO *)(host_ptr[host].ob_spec))->te_ptext,
					 atoi(((TEDINFO *)(host_ptr[port].ob_spec))->te_ptext));

	strcpy(((TEDINFO *) tree[obj].ob_spec->te_ptext),"");*/
	
	form_center(obj, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);
	form_dial(FMD_START, 0, 0, 0, 0, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
	form_dial(FMD_GROW, rect.g_x+rect.g_w/2, rect.g_y+rect.g_h/2, 0, 0, rect.g_x,
			rect.g_y, rect.g_w, rect.g_h);

	objc_draw(obj, ROOT, MAX_DEPTH, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
	exit=form_do(obj, edit) & 0x7fffu;

	form_dial(FMD_SHRINK, rect.g_x+rect.g_w/2, rect.g_y+rect.g_h/2, 0, 0,
 				rect.g_x, rect.g_y, rect.g_w, rect.g_h);
	form_dial(FMD_FINISH, 0, 0, 0, 0, rect.g_x, rect.g_y, rect.g_w, rect.g_h);

	objc_change(obj,exit,0,rect.g_x,rect.g_y,rect.g_w,rect.g_h,0x0000,0);

		/*obj[exit].ob_state&=~SELECTED;*/

	return (exit);
	}

void set_button(OBJECT *tree, short parent, short button)
{
	short b;

	for (b=tree[parent].ob_head; b!=parent; b=tree[b].ob_next)
			if (b==button)
				tree[b].ob_state|=SELECTED;
			else
				tree[b].ob_state&=~SELECTED;
}

short get_button(OBJECT *tree, short parent)
{
	short b;

	b=tree[parent].ob_head;
	for (; b!=parent && !(tree[b].ob_state&SELECTED); b=tree[b].ob_next);

	return b;
}
