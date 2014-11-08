#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#include "main.h"
#include "tndefs.h"
#include "telvt102.h"

/* Prototypes... */
  /*void*/
  short  do_string( int, char *);
  void  set_flags( char);
  void  print_string( char *);
  void  increase_row(short);
  void  flip_work(void);
  void  scroll_down(void);
  void  scroll_up(void);
	void  smooth_up(void);
	void  smooth_down(void);
  void  clear_begline(void);
  void  clear_endline(void);
  void  clear_begscreen(void);
  void  clear_endscreen(void);
	void	blink_it(void);
	void	redraw_line(int);
	void	redraw_page(void);
	void pause(short);
	void resequence(void);
/* Externs... */
	extern	int	stci_d(char *, int);
	extern	int	stcd_i(char *, int *);
	extern char * strnset(char *,int, size_t);

  /* Prototypes... */

	 extern int send_to_socket(int, char *, int);
	 extern void draw_win(void);
/*	extern	void draw_line(short ,short ,short , const char * );*/

	extern void do_rev_bs(void);
	extern void do_key_pad(void);
	extern void do_cur_key(void);
	extern void do_dump_file(void);
	extern void do_transcript(void);
	extern void do_printer(void);
	extern void do_info(void);
	extern short	do_menu(short);
	extern	void print_cursor(short);

/*	New window stuff	*/

	extern void  init_it (void);
	extern void  do_redraw (int handle, GRECT *rect, int scroll);
	extern LINE_buf *ascii_buf, *attri_buf, *blink_buf;

	extern	short real_row	[MAX_ROW],blink[MAX_ROW],doubler[MAX_ROW];

	extern	short oldx,oldy,oldw, oldh, newx,newy, neww,newh;
	short	ox,oy;
	extern GRECT  scrn_rec, wind;
	clock_t blink_time/*=clock()+(CLOCKS_PER_SEC)*/;

	void send_iam(int);
#define ESC 27

	extern short	chrhgt, chrwid,fid,savefid;
	extern short	vdi_handle,nlines,nchars;
	extern	short cursor_dark;

	extern MFDB work, screen;
	extern WINDOW  win;
	extern FILE *fp;
	extern char buf1[1024];
/*	extern int keypad; Extra defn???*/ /*i.e num keypad*/
	extern char title[32];
	extern char charmap[255];
	short onscreen, clip[4],rev;
	void *oldlogbase;

/* Flags */

	extern short jump,newline,key_ret,screen_norm,wrap,debug,dont_size;
	extern short keypad,cur_key,rev_bs,jump_scroll,smooth_scroll,sizeable;
	extern short write_file,dump_file,
		print_it, absolute,term=0;
	extern int nchb,nlib,fontb, oldfontb,saved,
			read_from_file,	reading,remap,mapped,graph_on;
	short t_off,b_off;
	char tflags,save_flags,lights[4];
	int n0,nval,val[8],n[8],trow,tn,tval,save_font,info_ok=TRUE;

short do_string(int s, char *str)
	{
	char msg[24], *save,*initsave,*tmpout;
	register char *ptr, *out;
	short junk, top;

	short pxy[4];
	char ntext[132],ntxt[132];
	int i,j;
	
	char	c;
	
	out=ptr=str;
	initsave=save=str+strlen(str);
	onscreen=TRUE; /* was false */
/* temp patch*/
/*	wrap=TRUE;*/

/*	if (blitter==FALSE)
*/		{
			wind_get(vdi_handle, WF_TOP, &top, &junk, &junk, &junk);
			if (top==vdi_handle)
				{
				onscreen=TRUE;
				}
			}

/*	clip[0]=win.w_rect.g_x;
	clip[1]=win.w_rect.g_y;
	clip[2]=clip[0]+win.w_rect.g_w-1;
	clip[3]=clip[1]+win.w_rect.g_h-1;
*/
	if (dump_file)	
		{
		fputs(out,fp);
		c=0;
		fputc(c,fp);
		}
	do
		{
			n[1]=n[2]=n[3]=val[1]=val[2]=val[3]=0;
			if (*ptr<32 || *ptr==IAC)
			{
			switch (*ptr)
				{
				case 0:
					print_string( out);
					out=ptr;
					break;

				case 10:
				case 11:
				case 12:
					*ptr=0;
					if (write_file)
						{
						ntxt[0]=10;
						ntxt[1]=0;
						fputs(ntxt,fp);
						}
					if (print_it)
						{
						ntxt[0]=10;
						ntxt[1]=0;
						lprintf("%s",ntxt);
						}
					print_string( out);
					increase_row(1);

					if (newline) win.col=1;

					out=ptr+1;
					break;

				case 13:
					*ptr=0;
					print_string( out);
					win.col=1;
					if (write_file)
						{
						ntxt[0]=13;
						ntxt[1]=0;
						fputs(ntxt,fp);
						}
					if (print_it)
						{
						ntxt[0]=13;
						ntxt[1]=0;
						lprintf("%s",ntxt);
						}
					out=ptr+1;
					break;

				case ESC:
					*ptr=0;
					print_string( out);
					*ptr=ESC;
					switch (ptr[1])
						{
						case 0:
							save=ptr;
							break;

						case '[':	/*Es[  ?			*/ 

							for (i=1;i<8;i++)
								val[i]=n[i]=0;
							n0=0;
							nval=0;
nextv:
							nval++;
							n[nval]=stcd_i(&ptr[2+n0],&val[nval]);
							n0+=n[nval];
							if (ptr[2+n0] ==';')
								{
								n0++;
								goto nextv;
								}

							switch (ptr[2 + n0])	/* 2+n[1] is char AFTER number	*/
								{
								case 0:
									save=ptr; /*original num	*/
									break;
	
								case 'A':	/*one parm only*/
									if (val[1]  == 0) val[1] = 1;
									win.row -= val[1];
									if (win.row < win.scrolltop) win.row = win.scrolltop;
									break;
								case 'B':
									if (val[1]  == 0) val[1] = 1;
									win.row += val[1];
									if (win.row > win.scrollbot) win.row = win.scrollbot;
									break;
								case 'C':/*curs forward*/
									if (val[1]  == 0) val[1] = 1;
									win.col += val[1];
									if (win.col > nchars)
										win.col = nchars;
									break;
								case 'D':		/*curs back*/
									if (val[1]  == 0) val[1] = 1;
									win.col -= val[1];
									if (win.col < 1) win.col = 1;
									break;
								case 'f':
								case 'H': /*no parms, default home*/
									if (val[1] == 0) val[1] = 1;
									if (val[2] == 0) val[2] = 1;	
									if (absolute)
										win.row= val[1];
									else 
										win.row=win.scrolltop-1+val[1];
									win.col= val[2];
									break;	
								case 'J':	/*erase in display*/
									switch (val[1])
										{
										case 0:
										  clear_endscreen();
											break;
										case 1:
											clear_begscreen();
											break;
										case 2:
											clear_endscreen();
											clear_begscreen();
											for (i=0; i< MAX_ROW; i++)
												{
												memset(attri_buf[i], 0,MAX_COL);
												memset(ascii_buf[i], 0,MAX_COL);
												memset(blink_buf[i], 0,MAX_COL);
												memset(ascii_buf[i], 32, (size_t)(nchars+1));
												real_row[i]= i;
												blink[i]=0;
												doubler[i]=0;
												}
											break;
										default:
											break;
										}
									break;
								case 'K':	/*erase in line*/
									switch (val[1])
										{
										case 0:
										  clear_endline();
											break;
										case 1:
											clear_begline();
											break;
										case 2:
											trow=real_row[win.row];
											blink[trow]=0;
											doubler[trow]=0;
											clear_endline();
											clear_begline();
											break;
										default:
											break;
										}
									break;	
								case 'm':	/*one parm only*/			
									for (i=1;i<=nval;i++)
										set_flags((char) ((char) val[i] + '0'));
									break;
								case 'L': /*insert val[1] lines*/
									{
									short save_s_top,save_s_bot;
									save_s_top = win.scrolltop;
									save_s_bot = win.scrollbot;
									win.scrolltop = win.row;
									for (i=0;i<val[1];i++)
										scroll_down();
									win.scrolltop = save_s_top;
									win.scrollbot = save_s_bot;
									}
									break;
								case 'M': /*delete n lines*/
									{
									short save_s_top,save_s_bot;
									save_s_top = win.scrolltop;
									save_s_bot = win.scrollbot;
									win.scrolltop = win.row;
									for (i=0;i<val[1];i++)
										scroll_up();
									win.scrolltop = save_s_top;
									win.scrollbot = save_s_bot;
									}
									break;
								case 'P': /*delete n chars*/
									{
									char ntext[MAX_COL];
									short i,trow;
									trow=real_row[win.row];
									memset(ntext, 0,MAX_COL);
									strncpy(ntext,ascii_buf[trow],nchars);
									for (i=win.col;i<(nchars-val[1]);i++)
										ntext[i]=ntext[i+val[1]];
									for (i=nchars-val[1];i<=nchars;i++)
										ntext[i]=' ';
									strncpy(ascii_buf[trow],ntext,nchars);
									memset(ntext, 0,MAX_COL);
									strncpy(ntext,blink_buf[trow],nchars);
									for (i=win.col;i<(nchars-val[1]);i++)
										ntext[i]=ntext[i+val[1]];
									for (i=nchars-val[1];i<=nchars;i++)
										ntext[i]=' ';
									strncpy(blink_buf[trow],ntext,nchars);
									memset(ntext, 0,MAX_COL);
									strncpy(ntext,attri_buf[trow],nchars);
									for (i=win.col;i<(nchars-val[1]);i++)
										ntext[i]=ntext[i+val[1]];
									for (i=nchars-val[1];i<=nchars;i++)
										ntext[i]=' ';
									strncpy(attri_buf[trow],ntext,nchars);
									}
									redraw_line(1);
									break;
								case 'q':
									for (i=1;i<=nval;i++)
										{
										if (val[i]==0)
											{lights[3]=lights[2]=lights[1]=lights[0]='O';}
										else lights[val[i]-1]='X';
										}
									do_info();
									pause(1);
									break;
								case 'c': /*who are u?, no or one 0 parm*/
									send_iam(s);
									break;
								case 'h': /*set various modes*/
									switch (val[1])
										{
										case 20:  /*Es[20h newline mode	*/
											newline =TRUE;
											break;
										case 2:
											break;
										case 4:
											break;
										case 12:
											break;
										default: /*Es[nh all other 
												* set mode for now  */
											{
											}
											break;
										}
									break;
								case 'l':/* Es[nl	*/
									switch (val[1])
										{  /* 	all reset modes for now */
										case 20:
											newline=FALSE;
											break;
										case 2:
											break;
										case 4:
											break;
										case 12:
											break;
										default: /*Es[nl all other 
												* reset mode for now  */
											break;
										}
									break;

								case 'r': /*default orig values*/
									if (val[1] == 0)
										{win.scrolltop = win.sstop;}
									else
										win.scrolltop = val[1];
									if (val[2] == 0)
										{win.scrollbot = win.ssbot;}
									else
										win.scrollbot = val[2];
									if (absolute)
										win.row=win.sstop;
									else 
										win.row=win.scrolltop;
									win.col=1;
									break;
																
										/* start Esc[?	*/
								case '?':/*Es[?n*/
									n[nval]=stcd_i(&ptr[3+n0],&val[nval]);
									n0+=n[nval];
									switch (ptr[3 + n0])
										{
										case 0:
											save=ptr;
											break;
										case 'h':
											switch (val[nval])
												{
												case 1:  /*Es[?1h cur key:appl	*/
													cur_key = FALSE;
													do_cur_key(); /* flips it! */
													break;
												case 2: /* */
													break;
												case 3:	/* 132 col */
													savefid=fid;
													if (chrhgt==8)
														fid=46;
													else if (chrhgt==16)	/*fixed*/
														fid=55;
													dont_size=TRUE;
													do_menu(99);
													dont_size=FALSE;
													break;

												case 4:	/* smooth */
													smooth_scroll=TRUE;
													do_info();
													break;
												case 5:	/* screen_rev */

													pxy[0]=win.w_rect.g_x;
													pxy[1]=win.w_rect.g_y;
													pxy[2]=pxy[0]+nchars*chrwid-1;
												  pxy[3]=pxy[1]+nlines*chrhgt-1;
									
													vsf_interior(vdi_handle,1);
													vsf_style(vdi_handle,8);
													vsf_perimeter(vdi_handle,0);
													vswr_mode(vdi_handle,MD_XOR);
													v_bar(vdi_handle, pxy);
													vswr_mode(vdi_handle,MD_REPLACE);
													rev=TRUE;
												/*	pause();*/
													break;
													
												case 6:
													absolute=FALSE;
													do_info();
													break;

												case 7: 
													wrap=TRUE;	/* wrap on */	
													do_info();
													break;
												default: 
													/*Es[?_h all other set modes for now  */
													break;
												}
											break;
										case 'l':
											switch (val[nval])
												{  /* Es[?_l	all reset modes for now */
												case 1:
													cur_key=TRUE;
													do_cur_key();
													break;
												case 2: /* VT52 mode */
													break;
												case 3:	/* 80 col */
													fid=savefid;
													dont_size=TRUE;
													do_menu(99);
													dont_size=FALSE;
													break;
												case 4:	/* jump */
													smooth_scroll=FALSE;
													do_info();
													break;
												case 5:	/* screen norm */
													if (rev)
														{

														pxy[0]=win.w_rect.g_x;
														pxy[1]=win.w_rect.g_y;
														pxy[2]=pxy[0]+nchars*chrwid-1;
													  pxy[3]=pxy[1]+nlines*chrhgt-1;
										
														vsf_interior(vdi_handle,1);
														vsf_style(vdi_handle,8);
														vsf_perimeter(vdi_handle,0);
														vswr_mode(vdi_handle,MD_XOR);
														v_bar(vdi_handle, pxy);
														vswr_mode(vdi_handle,MD_REPLACE);
														rev=FALSE;
														}
												
													break;

												case 6:
													absolute=TRUE;
													do_info();
													break;

												case 7: 
													wrap=FALSE; /* wrap off */
													do_info();
													break;	
												default:
													if (debug)
													{
													strncpy(ntext,ptr,10);
													sprintf(ntxt,"[1][Missing Esc code       |%s][OK]"
															,ntext);
													form_alert(1, ntxt);
													}
													break;
												}
											break;
										}
									ptr++;
									break;
											/*end of Es[?*/
								}
							ptr+=(n0+1);
							break;/*end of any parm Es[n;n;...X */

									/*	Esc+char+ptr	*/
						case ')':	/* char set selections  */
							switch (ptr[2])	/* nothing for now	*/
								{
								case 0:
									save=ptr;
									break;

								case 'B':
									break;
								case '0':
									break;
								case '1':
									break;
								case '2':
									break;
								default:
									break;
								}
								ptr++;
								break;

						case '(':
							switch (ptr[2])	/* nothing for now	*/
								{
								case 0:
									save=ptr;
									break;

								case 'B':
									*ptr=0;
									out=ptr+1;
									if (mapped) remap=FALSE;
									else if (vq_gdos())
										vst_font(vdi_handle,win.font_no);
									graph_on=FALSE;
									break; /*set line drawing set as g0 */
								case '0':
									*ptr=0;
									out=ptr+1;
									if (mapped) remap=TRUE;
									else if (vq_gdos())
										vst_font(vdi_handle,win.gfont_no);
									graph_on=TRUE;
									break; /*set line drawing set as g0 */
								case '1':
									break;
								case '2':
									break;
								default:
									break;
								}
								ptr++;
								break;

						case '#':
							switch (ptr[2])
								{
								case 0:
									save=ptr;
									break;
								case '3':
									trow=real_row[win.row];
									doubler[trow]=DOUBLE3;
									break;
								case '4':
									trow=real_row[win.row];
									doubler[trow]=DOUBLE4;
									break;
								case '5':
									trow=real_row[win.row];
									if (doubler[trow]==DOUBLEW)
										{
										doubler[trow]=0;
										}
									break;
								case '6':
									trow=real_row[win.row];
									doubler[trow]=DOUBLEW;
									break;
								case '8':
									t_off=b_off=0;
									for (i=0; i< MAX_ROW; i++)
										{
										memset(attri_buf[i], 0,MAX_COL);
										memset(ascii_buf[i], 0,MAX_COL);
										memset(blink_buf[i], 0,MAX_COL);
										memset(ascii_buf[i], 32, (size_t)(nchars+1));
										real_row[i]= i;
										blink[i]=0;
										doubler[i]=0;
										}
									clear_begscreen();
									clear_endscreen();
									tmpout=ptr;
									for (j=0;j< (nchars-1);j++)
										ntxt[j]='E';
									ntxt[j]=0;
									for (i=1;i<=win.scrollbot;i++)
										{
										win.col=1;win.row=i;
										print_string(ntxt);
										}
									ptr=tmpout;
									win.row=win.col=1;
								default:
									if (debug)
									{
									strncpy(ntext,ptr,12);
									sprintf(ntxt,"[1][Missing Esc code       | %s][OK]"
											,ntext);
									form_alert(1, ntxt);
									}
									break;
								}
							ptr++;
							break;
									/*	end of Esc+char+ptr	*/

									/*	esc and one char	*/
						case '7':/*Es7 save cursor and attributes */
							win.savecol=win.col;
							win.saverow=win.row;
							save_flags=win.flags;
							break;

						case '8':	/*Es8 restore C & A  */
							if (win.savecol!=0)
								{
								win.col=win.savecol;
								win.row=win.saverow;
								win.flags=save_flags;
								}
							break;

						case 'D':	/*EsD index	*/
							increase_row(1);
							break;
							
						case 'E':	/* Next line	*/
							*ptr=0;
							if (write_file)
								{
								ntxt[0]=10;
								ntxt[1]=0;
								fputs(ntxt,fp);
								}
							if (print_it)
								{
								ntxt[0]=10;
								ntxt[1]=0;
								lprintf("%s",ntxt);
								}
							increase_row(1);

							win.col=1;
							print_string( out);
							out=ptr+1;
							break;

						case 'M':	/*EsM reverse index	*/
						 	increase_row(-1);
							break;

						case 'Z':	/*EsZ who are you?	*/
							send_iam(s);
							break;

						case '>':	/*sel num keypad  */
							keypad=TRUE;
							do_key_pad();/*flips it !!! */
							break;
						case '=':	/*sel alt keypad  */
							keypad=FALSE;
							do_key_pad();/*flips it !!! */
							break;
						case 'N':	/*ss2 */
/*							{
							char txt[2];
							*ptr=0;
							print_string( out);
							out=ptr+1;
							if (mapped) remap=TRUE;
							else
								{
								graph_on = TRUE;
								vst_font(vdi_handle,win.gfont_no);
								}
							txt[0]=out[0];txt[1]=0;
							print_string(txt);
							ptr++;
							if (mapped) remap=FALSE;
							else
								{
								graph_on = FALSE;
								vst_font(vdi_handle,win.font_no);
								}
							}*/
							break;
						case 'O':	/*ss3 */
							/*skip these for now */
							break;
/*						case 'P':	/*some config shit	*/
							break;
*/
						case '<':
							/*enter VT102 mode, already there!	*/
							break;
						case'\\':
							break;
						default:
							if (debug)
							{
							strncpy(ntext,ptr,10);
							sprintf(ntxt,"[1][Missing Esc code      | %s][OK]"
									,ntext);
							form_alert(1, ntxt);
							}
							break;
						}
					ptr++;
					out=ptr+1;
					break;

/* single char commands	*/
				case 7:
					*ptr=0;
					print_string( out);
					Bconout(2, 7);
					out=ptr+1;
					break;

				case 8: /* bs clear space later for destructive */
					*ptr=0;
					print_string( out);
					if (--win.col<1) win.col=1;
					out=ptr+1;
					break;

				case 9:
					*ptr=0;
					print_string( out);
					win.col=((win.col-1)/8)*8+9;
					out=ptr+1;
					if (win.col> nchars) win.col=nchars;
					break;

				case 0x0e:	/* graphics on	*/
					*ptr=0;
					print_string( out);
					out=ptr+1;
					if (mapped) remap=TRUE;
					else
						{
						graph_on = TRUE;
						vst_font(vdi_handle,win.gfont_no);
						}
					break; /*si */
					
				case 0x0f:	/* graphics off*/
					*ptr=0;
					print_string( out);
					out=ptr+1;
					remap=FALSE;	/*unconditional */
					if (vq_gdos())
						{
						graph_on=FALSE;
						vst_font(vdi_handle,win.font_no);
						}
					break; /* so*/
				/* end of esc codes  */

				case IAC:	/*FF 255*/
					*ptr=0;
					print_string( out);
					*ptr=IAC;
					switch (ptr[1])
						{
						case 0:
							save=ptr;
							break;

						case DONT:/*FE 254*/
							if (debug){
								tmpout=ptr;
								sprintf(ntxt, "got a dont %d\r\n",ptr[2]);
								print_string(ntxt);
							}
							msg[0]=IAC;
							msg[1]=WONT;/*FC 252*/
							msg[2]=ptr[2];
							send_to_socket(s, msg, 3);
							if (debug){
									sprintf(ntxt, " sent a wont %d\r\n",ptr[2]);
									print_string(ntxt);
								ptr=tmpout;
								win.row++;win.col=1;
							}
							ptr+=2;
							break;

						case WONT:/*FC 252*/
							if (debug){
								tmpout=ptr;
								sprintf(ntxt, "got a wont %d\r\n",ptr[2]);
								print_string(ntxt);
							}
							msg[0]=IAC;
							msg[1]=WONT;
							msg[2]=ptr[2];
							send_to_socket(s, msg, 3);
							if (debug){
								sprintf(ntxt, " sent a wont %d\r\n",ptr[2]);
								print_string(ntxt);
								ptr=tmpout;
								win.row++;win.col=1;
							}
							ptr+=2;
							break;

						case DO:/*FD 253*/
							if (debug){
								tmpout=ptr;
								sprintf(ntxt, "got a do %d\r\n",ptr[2]);
								print_string(ntxt);
							}
							msg[0]=IAC;/*24 -> 18HEX*/
							if (ptr[2]==1 || ptr[2]==24 || ptr[2] == NAWS)  
								{
								msg[1]=WILL;
								if (debug){
									sprintf(ntxt, " sent a will %d\r\n",ptr[2]);
									print_string(ntxt);
									}
								if (ptr[2] == 24) term=0;
								}
							else			  
								{
								msg[1]=WONT;
								if (debug){
									sprintf(ntxt, " sent a wont %d\r\n",ptr[2]);
									print_string(ntxt);
									}
								}
							msg[2]=ptr[2];
							send_to_socket(s, msg, 3);
							if (ptr[2] == NAWS)
								{
								sizeable=TRUE;
								if (debug){
									sprintf(ntxt, "got a do naws\r\n");
									print_string(ntxt);
								}
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
								if (debug){
									sprintf(ntxt, " sent new r,c\r\n");								
									print_string(ntxt);
									}
								}
							if (debug){				
								ptr=tmpout;
								win.row++;win.col=1;
								}
							ptr+=2;
							break;

						case WILL:/*FB 251*/
							if (debug){
								tmpout=ptr;
								sprintf(ntxt, "got a will %d",ptr[2]);
								print_string(ntxt);
							}
							msg[0]=IAC;
							if (ptr[2]==1 || ptr[2]==3)	/*echo, suppress goahead*/ 
								{
								msg[1]=DO;
							if (debug){
									sprintf(ntxt, " sent a do %d\r\n",ptr[2]);
									print_string(ntxt);
							}
								}
							else
								{	  
								msg[1]=DONT;
								if (debug){
									sprintf(ntxt, " sent a dont %d\r\n",ptr[2]);
									print_string(ntxt);
									}
								}
							msg[2]=ptr[2];
							send_to_socket(s, msg, 3);
							if (debug){
								ptr=tmpout;
								win.row++;win.col=1;
							}
							ptr+=2;
							break;

						case SB:/*FA 250*/
							if (debug){
								tmpout=ptr;
								sprintf(ntxt, "got a send terminal\r\n");
								print_string(ntxt);
								}
							msg[0]=IAC;
							msg[1]=SB;
							msg[2]=24;
							msg[3]=0;
							switch (term)
								{
								case 2:
								case 3:
									strcpy(&msg[4], "DEC-VT102\0");
									msg[14]=IAC;
									msg[15]=SE;
									msg[16]=IAC;
									msg[17]=GA;/*F9 249*/
									msg[18]=0;
									send_to_socket(s, msg, 18);
									if (debug){
										sprintf(ntxt, " sent DEC-VT102\r\n");
										print_string(ntxt);
										}
									term++;
									break;
								case 0:
									strcpy(&msg[4], "VT102\0");
									msg[10]=IAC;
									msg[11]=SE;
									msg[12]=IAC;
									msg[13]=GA;/*F9 249*/
									msg[14]=0;
									send_to_socket(s, msg, 14);
									if (debug){
										sprintf(ntxt, " sent VT102\r\n");
										print_string(ntxt);
										}
									term++;
									break;
								case 1:
									strcpy(&msg[4], "VT100\0");
									msg[10]=IAC;
									msg[11]=SE;
									msg[12]=IAC;
									msg[13]=GA;/*F9 249*/
									msg[14]=0;
									send_to_socket(s, msg, 14);
									if (debug){
										sprintf(ntxt, " sent VT100\r\n");
										print_string(ntxt);
										}
									term++;
									break;
								}
							if (debug){									
								ptr=tmpout;
								win.row++;win.col=1;
								}
							if (term==1)
								{
								msg[0]=IAC;
								msg[1]=WILL;
								msg[2]=NAWS;
								msg[3]=0;	
								send_to_socket(s, msg, 3);
								if (debug){
									sprintf(ntxt, " sent will naws (31)\r\n");
									print_string(ntxt);
									ptr=tmpout;
									win.row++;win.col=1;
									}
								}
							ptr+=3;
							break;

						default:
							if (debug)
							{
							strncpy(ntext,ptr,10);
							sprintf(ntxt,"[1][Missing Esc code      | %s !][OK]"
									,ntext);
							form_alert(1, ntxt);
							}
							ptr++;
							break;
						}
					out=ptr+1;
					break;

				default:
					*ptr=0;
			/*		print_string( out);*/
					out=ptr+1;
					break;
				}
			}
		if(remap) *ptr=charmap[*ptr];
		ptr++;
		}
	while (*out!=0);

	do_info();
	return((short)((long)initsave-(long)save));
	}
	
void  send_iam(int s)
	{

	char  iam[8];

	iam[0] = ESC;	iam[1] = '[';iam[2] = '?';	iam[3] = '1';
	iam[4] = ';';	iam[5] = '2';	iam[6] = 'c';
	send_to_socket(s, iam, 7);
	}

void set_flags( char c)
	{
	if (c=='0')
		{
		win.flags=0;
		}
	else if (c=='1')
		{
		win.flags|=BOLD;
		}
	else if (c=='2')
		{
		win.flags|=LIGHT;
		}
	else if (c=='4')
		{
		win.flags|=UNDERSCORE;
		}
	else if (c=='5')
		{
		win.flags|=LIGHT;	/*blink*/
		}
	else if (c=='7')
		{
		win.flags|=REVERSE;
		}
	}

void print_string( char *out)
/*						Setscreen(oldlogbase, (void *)-1, -1);
						draw_win();
						oldlogbase=Logbase();
						Setscreen(work.fd_addr, (void *)-1, -1);
*/
	{

	GRECT rect,deskrect;

	short /*nwraps=0,*/effect = 0;
	short i, /*j,*/ trow,junk,crow,tmprow,more_text;
	size_t outlen,tmplen;
	short cxy[4],pxy[4],bpxy[8]/*,pxyarray[8]*/;
/*	char txt[132], tmp[16];*/
	char ntext[MAX_COL]/*,ntxt[MAX_COL]*/;
	outlen=(short) strlen(out);

	if ((outlen)!=0)
		{

		more_text=FALSE;
	
		if (write_file) fputs(out,fp);
		if (print_it) lprintf("%s",out);
		wind_get(DESK, WF_WORKXYWH, &deskrect.g_x, &deskrect.g_y, 
				&deskrect.g_w, &deskrect.g_h);
		wind_get(win.handle, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, 
				&rect.g_w, &rect.g_h);
		ox = rect.g_x-deskrect.g_x+1;oy=rect.g_y-deskrect.g_y+win.y_offset;

		trow=real_row[win.row];
		tflags=win.flags;	/*get saved value	*/
		if (graph_on)
			tflags |= NEWFONT;
		cxy[0]=ox;
		cxy[2]=cxy[0]+nchars*chrwid-1;

		if (doubler[trow] & DOUBLE3)
			{
			t_off=0;
			b_off=chrhgt;
			vst_point(vdi_handle, 2*win.font_size, &junk, &junk
							, &chrwid,&junk);
			}
		else
		if (doubler[trow] & DOUBLE4)
			{
			t_off=chrhgt;
			b_off=chrhgt;
			vst_point(vdi_handle, 2*win.font_size, &junk, &junk
							, &chrwid,&junk);
			}
		else
		if (doubler[trow] & DOUBLEW)
			{	
			t_off=0;
			b_off=chrhgt;
			vst_point(vdi_handle, 2*win.font_size, &junk, &junk
							, &chrwid,&junk);
			}
		else
			vst_point(vdi_handle, win.font_size, &junk, &junk
							, &chrwid, &chrhgt);

		effect=0;
		if (win.flags & BOLD)		  effect|=THICKENED;
/*
		if (win.flags & LIGHT)		effect|=SHADED;
*/
		if (win.flags & UNDERSCORE)  effect|=UNDERLINED;
		vst_effects(vdi_handle, effect);
more:
		if ((wrap) && ((win.col + outlen-1) > nchars))
			{
			outlen=nchars-win.col+1; /*win.col starts at 1!!!*/
			strncpy(ntext,out,outlen);
			more_text=TRUE;
			out=out+outlen;
			tmplen=strlen(out);
			if (tmplen<0)
					form_alert(1,"[1][Bad wrap! ][OK]");
			}
		else
			{
			strcpy(ntext,out);
			more_text=FALSE;
			}
		trow=real_row[win.row];
		strncpy(&ascii_buf[trow][win.col-1],ntext,outlen);
		memset(&attri_buf[trow][win.col-1],tflags,outlen);
		if (win.flags & BLINK)
			{
			memset(&blink_buf[trow][win.col-1],0xff,outlen);
			blink[trow]=1;
			}
		else
			{
			memset(&blink_buf[trow][win.col-1],0,outlen);
			blink[trow]=0;
			}
		

		if (doubler[trow] & DOUBLEW)	/*see if it's set	*/
			{
			tmprow=win.row;win.row=2;
			cxy[1]=(win.row-1)*chrhgt+oy;
			cxy[3]=cxy[1]+2*chrhgt-1;

			oldlogbase=Logbase();
			Setscreen(work.fd_addr, (void *)-1, -1);
/*			This draws it in work	*/
			}
		else
			{
			cxy[1]=(win.row-1)*chrhgt+oy;
			cxy[3]=cxy[1]+chrhgt-1;
			}
/**		vs_clip(vdi_handle,1,cxy);**/

		if (win.flags & REVERSE)
			{
			pxy[0]=(win.col-1)*chrwid+ox;
			pxy[2]=pxy[0]+(short)outlen*chrwid-1;
			pxy[1]=(win.row-1)*chrhgt-t_off+oy;
			pxy[3]=pxy[1]+chrhgt+b_off-1;
			vsf_color(vdi_handle, 1);
			v_bar(vdi_handle, pxy);
			vst_color(vdi_handle, 0);
			vswr_mode(vdi_handle, MD_XOR);

			v_gtext(vdi_handle, (win.col-1)*chrwid+ox, 
						(win.row-1)*chrhgt+oy-t_off, ntext);
			vswr_mode(vdi_handle, MD_REPLACE);
			}
		else
			{
			vst_color(vdi_handle, 1);


			v_gtext(vdi_handle, (win.col-1)*chrwid+ox, 
						(win.row-1)*chrhgt+oy-t_off, ntext);

			}
		if (doubler[trow] & DOUBLEW)
			{
			crow=win.row;
			win.row=tmprow;
	/*	Now copy it to the screen	*/
		Setscreen(oldlogbase, (void *)-1, -1);
			cxy[0]=(win.col-1)*chrwid+ox;
			cxy[2]=cxy[0]+(short)outlen*chrwid/*-1*/;
			cxy[1]=(win.row-1)*chrhgt+oy;
			cxy[3]=cxy[1]+chrhgt-1;

			bpxy[0]=bpxy[4]=(win.col-1)*chrwid+ox;
			bpxy[2]=bpxy[6]=bpxy[0]+(short)outlen*chrwid-1;

			bpxy[1]=(crow-1)*chrhgt+oy-1;
			bpxy[3]=bpxy[1]+1;
			bpxy[5]=(win.row-1)*chrhgt+oy-1;
			bpxy[7]=bpxy[5]+1;

			cxy[3]=cxy[3]+chrhgt;
/**			vs_clip(vdi_handle,1,cxy);**/
			for (i=0;i< chrhgt;i++)
				{
				vro_cpyfm(vdi_handle, 3, bpxy, &work, &screen);
				bpxy[1]+=2;bpxy[3]+=2;bpxy[5]++;bpxy[7]++;
				}
			}
		win.col+=(short)outlen;
		if (more_text)
			{
			outlen=strlen(out);
			win.col=1;
			win.row++;
			goto more;
			}
/**		vs_clip(vdi_handle,0,cxy);**/
		vst_effects(vdi_handle, 0);
		}
	if (doubler[trow] & DOUBLE3 || doubler[trow] & DOUBLE4 || doubler[trow] & DOUBLEW)
		{
		b_off=t_off=0;
		vst_point(vdi_handle, win.font_size, &junk, &junk, &chrwid, &chrhgt);
		}
/*	pause(1);*/
	}
	
void increase_row(short a)
	{
	short junk/*,trow*/;
						  /*change to do...while*/
	if (a >=1)
		{
		do
			{
			if (win.row==win.scrollbot)
				{
				if (smooth_scroll)
					smooth_up();
				else
					scroll_up();
				}
			else
				win.row++;
			a--;
			if (win.row >win.ssbot) win.row=win.ssbot;
			} while (a>0);
		}
	else if (a<=-1)
		{ /* neg a, decrease row	*/
		do
			{
			if (win.row==win.scrolltop)
				{
				if (smooth_scroll)
					smooth_down();
				else
					scroll_down();
				}
			else
				win.row--;
			a++;
			if (win.row <win.sstop) win.row=win.sstop;
			} while (a<0);
		}

	if (doubler[trow] & DOUBLE3 || doubler[trow] & DOUBLE4||doubler[trow] & DOUBLEW)
		{
		b_off=t_off=0;
		vst_point(vdi_handle, win.font_size, &junk, &junk
				, &chrwid,&chrhgt);
		}
	if (blink_time < clock())
		{
		short ib;
		
		for (ib=1;((ib<nlines));ib++)
			if (blink[ib]>0)
				{
				blink_it();
				ib=MAX_ROW;
				}
		blink_time = clock() + CLOCKS_PER_SEC;
		}
	}
	
void  scroll_up(void)
	{
	GRECT rect;
	int xy_clip[4];
	short bpxy[8];
	short i, trow, temp;
/*		char ntext[MAX_COL];*/
/*	scroll virtual screen	*/	
	temp=real_row[win.scrolltop];

	for (i=win.scrolltop; i < win.scrollbot;i++)
			trow=real_row[i]= real_row[i+1];
	real_row[win.scrollbot]=temp;
	strnset(ascii_buf[temp],32,(size_t)nchars+1);
	strnset(attri_buf[temp],0,(size_t)MAX_COL);
	strnset(blink_buf[temp],0,(size_t)MAX_COL);
	blink[temp]=0;
	doubler[temp]=0;
	wind_update(BEG_UPDATE);
	graf_mouse(M_OFF, NULL);
	wind_get(win.handle, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, 
				&rect.g_w, &rect.g_h);
	while (rect.g_w !=0 && rect.g_h !=0)
		{
		if (rc_intersect(&win.w_rect, &rect))
			{
			xy_clip[0] = rect.g_x;
			xy_clip[1] = rect.g_y;
			xy_clip[2] = rect.g_x + rect.g_w - 1;
			xy_clip[3] = rect.g_y + rect.g_h - 1;
			vs_clip(vdi_handle,TRUE,xy_clip);
	

			bpxy[0]=bpxy[4]=0+ox;
			bpxy[2]=bpxy[6]=nchars*chrwid-1+ox;

			bpxy[1]=win.scrolltop*chrhgt+oy;
			bpxy[3]=win.scrollbot*chrhgt-1+oy;
			bpxy[5]=bpxy[1]-chrhgt;
			bpxy[7]=bpxy[3]-chrhgt;
			vro_cpyfm(vdi_handle, 3, bpxy, &screen, &screen);
			bpxy[1]=bpxy[3]-chrhgt+1;
			vsf_color(vdi_handle,0);
			v_bar(vdi_handle,bpxy);
			vs_clip(vdi_handle, FALSE, xy_clip);
			wind_get(win.handle, WF_NEXTXYWH, &rect.g_x, &rect.g_y, 
					&rect.g_w, &rect.g_h);
			}
		}
	graf_mouse(M_ON, NULL);
	wind_update(END_UPDATE);
	}


void scroll_down(void)
	{
	GRECT rect;
	int xy_clip[4];
	short i, trow, temp;
	short bpxy[8];

/*	scroll virtual screen	*/	
	temp=real_row[win.scrollbot];
	for (i=win.scrollbot; i > win.scrolltop;i--)
		{
		trow=real_row[i]= real_row[i-1];
		}

	real_row[win.scrolltop]=temp;
	strnset(ascii_buf[temp],32,(size_t)nchars+1);
	strnset(attri_buf[temp],0,(size_t)MAX_COL);
	strnset(blink_buf[temp],0,(size_t)MAX_COL);
	blink[temp]=0;
	doubler[temp]=0;
	wind_update(BEG_UPDATE);
	graf_mouse(M_OFF, NULL);
	wind_get(win.handle, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, 
				&rect.g_w, &rect.g_h);
	while (rect.g_w !=0 && rect.g_h !=0)
		{
		if (rc_intersect(&win.w_rect, &rect))
			{
			xy_clip[0] = rect.g_x;
			xy_clip[1] = rect.g_y;
			xy_clip[2] = rect.g_x + rect.g_w - 1;
			xy_clip[3] = rect.g_y + rect.g_h - 1;
			vs_clip(vdi_handle,TRUE,xy_clip);
	
	
			bpxy[0]=bpxy[4]=ox;
			bpxy[2]=bpxy[6]=nchars*chrwid-1+ox;

			bpxy[1]=(win.scrolltop-1)*chrhgt+oy;
			bpxy[3]=(win.scrollbot-1)*chrhgt-1+oy;
			bpxy[5]=bpxy[1]+chrhgt;
			bpxy[7]=bpxy[3]+chrhgt;
			vro_cpyfm(vdi_handle, 3, bpxy, &screen, &screen);
			bpxy[3]=bpxy[1]+chrhgt-1;
			vsf_color(vdi_handle,0);
			v_bar(vdi_handle,bpxy);
			vs_clip(vdi_handle, FALSE, xy_clip);
			wind_get(win.handle, WF_NEXTXYWH, &rect.g_x, &rect.g_y, 
					&rect.g_w, &rect.g_h);
			}
		}
	graf_mouse(M_ON, NULL);
	wind_update(END_UPDATE);
	}

void  smooth_up(void)
	{
		short bpxy[8];
		short i, k, temp, trow, skipno = 1;

/*	scroll virtual screen	*/	
		temp=real_row[win.scrolltop];

		for (i=win.scrolltop; i < win.scrollbot;i++)
			trow=real_row[i]= real_row[i+1];
		real_row[win.scrollbot]=temp;

		strnset(ascii_buf[temp],32,(size_t)nchars+1);
		strnset(attri_buf[temp],0,(size_t)MAX_COL);
		strnset(blink_buf[temp],0,(size_t)MAX_COL);
		blink[temp]=0;
		doubler[temp]=0;

		bpxy[0]=bpxy[4]=0+ox;
		bpxy[2]=bpxy[6]=nchars*chrwid-1+ox;

		bpxy[1]=(win.scrolltop-1)*chrhgt+skipno+oy;
		bpxy[3]=win.scrollbot*chrhgt-1+oy;
		bpxy[5]=bpxy[1]-skipno;
		bpxy[7]=bpxy[3]-skipno;
		for (k=0;k < chrhgt ;k+=skipno)
		{
			vro_cpyfm(vdi_handle, 3, bpxy, &screen, &screen);
			bpxy[1]=bpxy[3]-skipno+1;
			vsf_color(vdi_handle,0);
			v_bar(vdi_handle,bpxy);
			bpxy[1]=bpxy[5]+skipno;
		}
	}

void  smooth_down(void)
	{
		short bpxy[8];
		short i, k, temp, trow, skipno = 1;

/*	scroll virtual screen	*/	
		temp=real_row[win.scrollbot];
		for (i=win.scrollbot; i > win.scrolltop;i--)
				real_row[i]= real_row[i-1];

		trow=real_row[win.scrolltop]=temp;
		strnset(ascii_buf[temp],32,(size_t)nchars);
		strnset(attri_buf[temp],0,(size_t)MAX_COL);
		strnset(blink_buf[temp],0,(size_t)MAX_COL);
		blink[temp]=0;
		doubler[temp]=0;

		bpxy[0]=bpxy[4]=ox;
		bpxy[2]=bpxy[6]=nchars*chrwid-1+ox;

		bpxy[1]=(win.scrolltop-1)*chrhgt+oy;
		bpxy[3]=win.scrollbot*chrhgt-1+oy;
		bpxy[5]=bpxy[1]+skipno;
		bpxy[7]=bpxy[3]+skipno;
		for (k=0;k<=chrhgt;k+=skipno)
		{
			vro_cpyfm(vdi_handle, 3, bpxy, &screen, &screen);
			bpxy[3]=bpxy[1]+skipno-1;
			vsf_color(vdi_handle,0);
			v_bar(vdi_handle,bpxy);
			bpxy[3]=bpxy[7]-skipno;
		}
	}


void clear_begline(void)
	{
	short pxy[4],temp;
	
	temp=real_row[win.row];
	pxy[0]=ox;
	pxy[1]=(win.row)*chrhgt-chrhgt+oy;
	pxy[2]=win.col*chrwid-1+ox;
	pxy[3]=pxy[1]+chrhgt-1;

	vsf_color(vdi_handle, 0);
	v_bar(vdi_handle, pxy);
	
	real_row[win.row]=temp;
	strnset(ascii_buf[temp],32,(size_t)win.col-1);
	strnset(attri_buf[temp],0,(size_t)win.col-1);
	strnset(blink_buf[temp],0,(size_t)win.col-1);
/*	for (i=0,blink[temp]=0;((i<MAX_COL) && (blink[temp]==0));i++)
		if (&blink_buf[temp][i]!=0)
			blink[temp]=0xff;
*/
	}
void clear_endline(void)
	{
	short pxy[4],temp;

	temp=real_row[win.row];
	pxy[0]=(win.col)*chrwid-chrwid+ox;
	pxy[1]=(win.row)*chrhgt-chrhgt+oy;
	pxy[2]=nchars*chrwid-1+ox;
	pxy[3]=pxy[1]+chrhgt-1;

	vsf_color(vdi_handle, 0);	 /*set box color white*/
	v_bar(vdi_handle, pxy);	  /*write box*/
	
	real_row[win.row]=temp;
	strnset(&ascii_buf[temp][win.col-1],32,(size_t)nchars-win.col);
	strnset(&attri_buf[temp][win.col-1],0,(size_t)nchars-win.col);
	strnset(&blink_buf[temp][win.col-1],0,(size_t)nchars-win.col);
/*	for (i=0,blink[temp]=0;((i<MAX_COL) && (blink[temp]==0));i++)
		if (&blink_buf[temp][i]!=0)
			blink[temp]=0xff;
*/
	}

void clear_begscreen(void)
	{
	short pxy[4],temp, j;

	if (win.row>1)
		{
		pxy[0]=ox;
		pxy[1]=oy;
		pxy[2]=nchars*chrwid-1+ox;
		pxy[3]=pxy[1]+win.row*chrhgt-chrhgt-1;

		vsf_color(vdi_handle, 0);
		v_bar(vdi_handle, pxy);		
		
		for (j=1;j<=win.row;j++)	/*check	= */
			{
			temp=real_row[j];
			strnset(ascii_buf[temp],32,(size_t)nchars);
			strnset(attri_buf[temp],0,(size_t)MAX_COL);
			strnset(blink_buf[temp],0,(size_t)MAX_COL);
			blink[temp]=0;
			doubler[temp]=0;

			}
		}
	clear_begline();
	}

void clear_endscreen(void)
	{
	short pxy[4],temp, j;

	if (win.row<win.scrollbot)
		{
		pxy[0]=0+ox;
		pxy[1]=(win.row)*chrhgt+oy;
		pxy[2]=nchars*chrwid-1+ox;
		pxy[3]=win.scrollbot*chrhgt-1+oy;

		vsf_color(vdi_handle, 0);
		v_bar(vdi_handle, pxy);

		for (j=win.row/*+1*/;j<=win.scrollbot;j++) /*check +1*/
			{
			temp=real_row[j];
			strnset(ascii_buf[temp],32,(size_t)nchars);
			strnset(attri_buf[temp],0,(size_t)MAX_COL);
			strnset(blink_buf[temp],0,(size_t)MAX_COL);
			blink[temp]=0;
			doubler[temp]=0;
			}
		}
	clear_endline();
	}

void	redraw_line(int skip)
	{
	GRECT rect,deskrect;
	short changed,junk,doubled, nchr, effect = 0,tmprow, crow;
	char ntext[MAX_COL];
	short n, tlen, i, j,/* k, row,*/ trow,/* col,*/ done,outlen, saverow, savecol;
		short cxy[4],pxy[8];

	saverow=win.row;
	savecol=win.col;
	if (skip==1)
		{
		wind_get(DESK, WF_WORKXYWH, &deskrect.g_x, &deskrect.g_y, 
					&deskrect.g_w, &deskrect.g_h);
		wind_get(win.handle, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, 
					&rect.g_w, &rect.g_h);
		ox = rect.g_x-deskrect.g_x+1;oy=rect.g_y-deskrect.g_y+win.y_offset;

		graf_mouse(M_OFF, NULL);
		}
	trow=real_row[win.row];

	j=0;
	win.col=1;
	do
		{
		changed=FALSE;
		done=FALSE;
		n=0;
		tflags=attri_buf[trow][j];
		if ((doubler[trow] & DOUBLE3)||(doubler[trow] & DOUBLE4))
			{
			nchr=nchars/2;
			doubled=TRUE;
			}
		else
			{
			doubled=FALSE;
			nchr=nchars;
			}
			tflags=attri_buf[trow][0];
		for (j=win.col,tlen=1;j<nchr ;tlen++,j++)
			{
			if (attri_buf[trow][j-1]	!= attri_buf[trow][j])
				break;
			}
		if (j>1) tflags=attri_buf[trow][j-1];
		if (j>=nchr)		done=TRUE;
		memset(ntext, 0,MAX_COL);
		strncpy(ntext,&ascii_buf[trow][win.col-1],tlen);
		outlen=tlen;
		
		effect=0;
		if (tflags & BOLD)		  effect|=THICKENED;
/*			if (tflags & LIGHT)		effect|=SHADED;*/
		if (tflags & UNDERSCORE)  effect|=UNDERLINED;
			vst_effects(vdi_handle, effect);
		if (tflags & NEWFONT) /* change font	*/
			{
			vst_font(vdi_handle,win.gfont_no);
			changed=TRUE;
			}
		if (doubler[trow] & DOUBLE3)
			{
			t_off=0;
			b_off=0/*chrhgt*/;
			vst_point(vdi_handle, 2*win.font_size, &junk, &junk, &chrwid,&junk);
			}
		else
		if (doubler[trow] & DOUBLE4)
			{
			t_off=chrhgt;
			b_off=0/*chrhgt*/;
			vst_point(vdi_handle, 2*win.font_size, &junk, &junk, &chrwid,&junk);
			}
		if (doubler[trow] & DOUBLEW)
			{
			t_off=0;
			b_off=chrhgt;
			vst_point(vdi_handle, 2*win.font_size, &junk, &junk
							, &chrwid,&junk);
			tmprow=win.row;win.row=2;
			cxy[1]=(win.row-1)*chrhgt+oy;
			cxy[3]=cxy[1]+2*chrhgt-1;

			oldlogbase=Logbase();
			Setscreen(work.fd_addr, (void *)-1, -1);
/*			This draws it in work	*/
			}
		else
			{
			cxy[1]=(win.row-1)*chrhgt+oy;
			cxy[3]=cxy[1]+chrhgt-1;
			}
		cxy[0]=ox;
		cxy[2]=cxy[0]+nchr*chrwid-1;
		vs_clip(vdi_handle,1,cxy);
		if (tflags & REVERSE)
			{
			if (*ntext!=0)
				{
				pxy[0]=(win.col-1)*chrwid+ox;
				pxy[2]=pxy[0]+tlen*chrwid-1;
				pxy[1]=(win.row-1)*chrhgt+oy-t_off;
				pxy[3]=pxy[1]+chrhgt-1+b_off;
				vs_clip(vdi_handle,1,pxy);
				vsf_color(vdi_handle, 1);
				v_bar(vdi_handle, pxy);
				}
			vst_color(vdi_handle, 0);
			vswr_mode(vdi_handle, MD_XOR);
			v_gtext(vdi_handle, (win.col-1)*chrwid+ox, 
					(win.row-1)*chrhgt+oy-t_off, ntext);
			vswr_mode(vdi_handle, MD_REPLACE);
			}
		else
			{
			vst_color(vdi_handle, 1);
			v_gtext(vdi_handle, (win.col-1)*chrwid+ox, 
					(win.row-1)*chrhgt+oy-t_off, ntext);
			}
		if (doubler[trow] & DOUBLEW)
			{
			crow=win.row;
			win.row=tmprow;
	/*	Now copy it to the screen	*/
		Setscreen(oldlogbase, (void *)-1, -1);
			cxy[0]=(win.col-1)*chrwid+ox;
			cxy[2]=cxy[0]+tlen*chrwid-1;
			cxy[1]=(win.row-1)*chrhgt+oy;
			cxy[3]=cxy[1]+chrhgt-1;
			cxy[3]=cxy[3]+chrhgt;
			vs_clip(vdi_handle,1,cxy);
			
			pxy[0]=pxy[4]=(win.col-1)*chrwid+ox;
			pxy[2]=pxy[6]=pxy[0]+(short)outlen*chrwid-1;

			pxy[1]=(crow-1)*chrhgt+oy-1;
			pxy[3]=pxy[1]+1;
			pxy[5]=(win.row-1)*chrhgt+oy-1;
			pxy[7]=pxy[5]+1;
			for (i=0;i< chrhgt;i++)
				{
				vro_cpyfm(vdi_handle, 3, pxy, &work, &screen);
				pxy[1]+=2;pxy[3]+=2;pxy[5]++;pxy[7]++;
				}

			do_info();
			wind_title(win.handle, title);
			vs_clip(vdi_handle,0,cxy);
			}
			vst_effects(vdi_handle, 0);
			if (changed)
				{
				changed=FALSE;
				vst_font(vdi_handle,win.font_no);
				}
			win.col=j+1;
			} 
		while (done !=TRUE);
		vs_clip(vdi_handle,0,cxy);

		if (doubler[trow] & DOUBLE3 || doubler[trow] & DOUBLE4 || doubler[trow] & DOUBLEW)
			{
			b_off=t_off=0;
			vst_point(vdi_handle, win.font_size, &junk, &junk, &chrwid, &chrhgt);
			}
		if (skip==1) graf_mouse(M_OFF, NULL);
	}
	
void	redraw_page(void)
	{
	GRECT rect,deskrect;
	short saverow, savecol;
	int xy_clip[4];

	saverow=win.row;
	savecol=win.col;
	wind_update(BEG_UPDATE);
	wind_get(DESK, WF_WORKXYWH, &deskrect.g_x, &deskrect.g_y, 
				&deskrect.g_w, &deskrect.g_h);/* MP says not needed*/
	graf_mouse(M_OFF, NULL);
	wind_get(win.handle, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, 
				&rect.g_w, &rect.g_h);
	ox = rect.g_x-deskrect.g_x+1;oy=rect.g_y-deskrect.g_y+win.y_offset;
	while (rect.g_w !=0 && rect.g_h !=0)
		{
		if (rc_intersect(&win.w_rect, &rect))
			{
			xy_clip[0] = rect.g_x;
			xy_clip[1] = rect.g_y;
			xy_clip[2] = rect.g_x + rect.g_w - 1;
			xy_clip[3] = rect.g_y + rect.g_h - 1;
			vs_clip(vdi_handle,TRUE,xy_clip);
	
			for (win.row=win.sstop;win.row <= win.ssbot; win.row++)
				{
				redraw_line(0);
				}
			vs_clip(vdi_handle, FALSE, xy_clip);
			}
		wind_get(win.handle, WF_NEXTXYWH, &rect.g_x, &rect.g_y, 
				&rect.g_w, &rect.g_h);
		}
	graf_mouse(M_ON, NULL);
	wind_update(END_UPDATE);
	win.row=saverow;
	win.col=savecol;
	}

void	blink_it(void)
	{
	GRECT rect/*,deskrect*/;


	short junk,doubled, nchr;
/*	char ntext[MAX_COL];*/
	short n, tlen, j, trow,/* col,*/ done,outlen, saverow, savecol;
	short cxy[4],pxy[8],do_blink;

	b_off=t_off=0;
	saverow=win.row;
	savecol=win.col;
/*	wind_get(DESK, WF_WORKXYWH, &deskrect.g_x, &deskrect.g_y, 
				&deskrect.g_w, &deskrect.g_h);
	wind_get(win.handle, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, 
				&rect.g_w, &rect.g_h);
	ox = rect.g_x-deskrect.g_x+1;oy=rect.g_y-deskrect.g_y+win.y_offset;
*/
/*	graf_mouse(M_OFF, NULL);*/
	
	for (win.row=win.sstop;win.row <= win.ssbot; win.row++)
		{
		trow=real_row[win.row];

		j=0;
		win.col=1;
		if (blink[trow]!=0) do
			{
			done=FALSE;
			n=0;
			tflags=attri_buf[trow][j];
			if ((doubler[trow] & DOUBLE3)||(doubler[trow] & DOUBLE4)
						/*||(doubler[trow] & DOUBLEW)*/)
				{
				nchr=nchars/2;
				doubled=TRUE;
				}
			else
				{
				doubled=FALSE;
				nchr=nchars;
				}

			for (j=win.col,tlen=1;j<nchr ;tlen++,j++)
				{
				if (blink_buf[trow][j-1]	!= blink_buf[trow][j])
					break;
				}
			if (blink_buf[trow][j-1]!=0){ do_blink=TRUE;
				}
			else do_blink=FALSE;
/*			if (j>1) tflags=attri_buf[trow][j-1];*/
			if (j>=nchr)		done=TRUE;
			outlen=tlen;
			
			if (doubler[trow] & DOUBLE3)
				{
				t_off=0;
				b_off=chrhgt;
				vst_point(vdi_handle, 2*win.font_size, &junk, &junk, &chrwid,&junk);
				}
			else
			if (doubler[trow] & DOUBLE4)
				{
				tlen+=tlen;
				t_off=chrhgt;
				b_off=chrhgt;
				vst_point(vdi_handle, 2*win.font_size, &junk, &junk, &chrwid,&junk);
				}
			if (doubler[trow] & DOUBLEW)
				{
				tlen+=tlen;
				t_off=0;
				b_off=0/*2*chrhgt*/;
				vst_point(vdi_handle, 2*win.font_size, &junk, &junk
								, &chrwid,&junk);
/*				tmprow=win.row;win.row=-1;*/
				cxy[1]=(win.row-1)*chrhgt+oy;
				cxy[3]=cxy[1]+2*chrhgt-1;
				}
			else
				{
				cxy[1]=(win.row-1)*chrhgt+oy;
				cxy[3]=cxy[1]+chrhgt-1;
				}
			cxy[0]=(win.col-1)*chrwid+ox;
			cxy[2]=cxy[0]+outlen*chrwid-1;
/*			vs_clip(vdi_handle,1,cxy);*/
			if (do_blink)
				{

				wind_update(BEG_UPDATE);
				graf_mouse(M_OFF, NULL);
				wind_get(win.handle, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, 
							&rect.g_w, &rect.g_h);
				while (rect.g_w !=0 && rect.g_h !=0)
					{
					if (rc_intersect(&win.w_rect, &rect))

						{
						cxy[0] = rect.g_x;
						cxy[1] = rect.g_y;
						cxy[2] = rect.g_x + rect.g_w - 1;
						cxy[3] = rect.g_y + rect.g_h - 1;
						vs_clip(vdi_handle,TRUE,cxy);
						pxy[0]=(win.col-1)*chrwid+ox;
						pxy[2]=pxy[0]+tlen/*(short)strlen(ntext)*/*chrwid-1;
						pxy[1]=(win.row-1)*chrhgt+oy-t_off;
						pxy[3]=pxy[1]+chrhgt-1+b_off;
						vsf_interior(vdi_handle,1);
						vsf_style(vdi_handle,8);
						vsf_perimeter(vdi_handle,0);
						vswr_mode(vdi_handle,MD_XOR);
						v_bar(vdi_handle, pxy);
						vswr_mode(vdi_handle,MD_REPLACE);

						vs_clip(vdi_handle, FALSE, cxy);
						wind_get(win.handle, WF_NEXTXYWH, &rect.g_x, &rect.g_y, 
								&rect.g_w, &rect.g_h);

						}
					}
				graf_mouse(M_ON, NULL);
				wind_update(END_UPDATE);

				}
			vst_effects(vdi_handle, 0);
			win.col=j+1;
			} while (done !=TRUE);
/*		vs_clip(vdi_handle,0,cxy);*/
		if (doubler[trow] & DOUBLE3 || doubler[trow] & DOUBLE4 
					|| doubler[trow] & DOUBLEW)
			{
			vst_point(vdi_handle, win.font_size, &junk, &junk, &chrwid, &chrhgt);
			}
		}
/*	graf_mouse(M_ON, NULL);*/
	b_off=t_off=0;
	win.row=saverow;
	win.col=savecol;
	}
	
void pause(short k)
	{
	int i, j;
	for (i=0;i<=10*k;i++)
		{
		for (j=0; j<=10000/**/;j++)
			{
			}
		}
	Bconout(2, 7); /* ring the bell */

	}
