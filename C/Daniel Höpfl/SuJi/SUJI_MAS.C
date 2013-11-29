#include "SuJi_glo.h"

int writeline(FILE_INFO *par,long max, long max_pfad, FILE *fp);

void simuliere_taste_button(EVNT *events)
{
	int msg[8];

	msg[1]=ap_id;
	msg[2]=0;

	if(events->mwhich & MU_KEYBD)
	{
		msg[0]=AV_SENDKEY;
		msg[3]=events->kstate;
		msg[4]=events->key;

		mt_appl_write(ap_id,16,msg,&global);
	}
	if(events->mwhich & MU_BUTTON)
	{
		msg[0]=AV_SENDCLICK;

		msg[3]=events->mx;
		msg[4]=events->my;
		msg[5]=events->mbutton;
		msg[6]=events->kstate;
		msg[7]=events->mclicks;

		mt_appl_write(ap_id,16,msg,&global);
	}

	events->mwhich&=~(MU_KEYBD|MU_BUTTON);
}

int thread_may_exit=1;

/* Return:  0 = 																													*/
/*				 -1 = ESC																												*/
/*				 -2 = CNTRL_Q, CNTRL_U																					*/
/*				 -3 = CNTRL_F																										*/

int master_event(unsigned int end_if_timer)
{
	do {
		MOBLK m1blk={0};
		MOBLK m2blk={0};

		mt_EVNT_multi(MU_KEYBD|MU_BUTTON|MU_MESAG|
								(end_if_timer ? MU_TIMER : 0)
				,0x102,3,0
				,&m1blk,&m2blk,
				(unsigned long)end_if_timer-1,
				&events,&global);

		if(events.mwhich & MU_MESAG)
		{
			switch(events.msg[0])
			{
				case THR_EXIT:
					if(events.msg[3]==thread_id_inhalt)
					{
						thread_id_inhalt=0;
						simuliere_taste_button(&events);
						thread_ret=events.msg[5];

						if(thread_may_exit)
							return 0;
						else
							mt_appl_write(ap_id,16,events.msg,&global);
					}
					break;
				case WM_SHADED:
					shaded_or_iconified|=1;
					break;
				case WM_UNSHADED:
					shaded_or_iconified&=~1;
					break;
				case WM_ICONIFY:
				case WM_ALLICONIFY:
					mt_wind_set_grect(events.msg[3],WF_ICONIFY,(GRECT *)&events.msg[4],&global);
					full.g_w=full.g_h=-1;
					shaded_or_iconified|=2;
					break;
				case WM_UNICONIFY:
					mt_wind_set_grect(events.msg[3],WF_UNICONIFY,(GRECT *)&events.msg[4],&global);
					calc_slider();
					shaded_or_iconified&=~2;
					break;
				case WM_TOPPED:
					mt_wind_set(events.msg[3],WF_TOP,0,0,0,0,&global);
					break;
				case WM_MOVED:
					mt_wind_set_grect(events.msg[3],WF_CURRXYWH,(GRECT *)&events.msg[4],&global);
					break;
				case WM_FULLED:
				{
					GRECT work;

					if(full.g_h==-1 || full.g_w==-1)
					{
						GRECT to;

						mt_wind_get_grect(0,WF_WORKXYWH,&work,&global);

						mt_wind_get_grect(window_handle,WF_CURRXYWH,&full,&global);

						mt_wind_get_grect(window_handle,WF_WORKXYWH,&to,&global);

						to.g_x=to.g_x+to.g_w/2;
						to.g_y=to.g_y+to.g_h/2;

						to.g_w=6;
						for(i=0;i<6;i++)
						{
							if(show_row[i])
								to.g_w+=max_breite[i];
						}

						to.g_h=work.g_h;

						if(((unsigned long) to.g_h)>=finfos*line_height+top_height)
							to.g_h=(int) ((finfos>2 ? finfos : 3)*line_height+top_height);

						to.g_x-=to.g_w/2;
						to.g_y-=to.g_h/2;

						mt_wind_calc_grect(WC_BORDER,WIND_KIND,&to,&to,&global);

						if(to.g_x<work.g_x)
							to.g_x=work.g_x;
						if(to.g_y<work.g_y)
							to.g_y=work.g_y;
						if(to.g_x+to.g_w>work.g_x+work.g_w)
							to.g_w=work.g_x+work.g_w-to.g_x;
						if(to.g_y+to.g_h>work.g_y+work.g_h)
							to.g_h=work.g_y+work.g_h-to.g_y;

						mt_wind_calc_grect(WC_WORK,WIND_KIND,&to,&to,&global);

						to.g_h=(to.g_h/line_height)*line_height;
	
						lines_to_show=to.g_h/line_height-1;
	
						to.g_h-=line_height;
						to.g_h+=top_height;

						mt_wind_calc_grect(WC_BORDER,WIND_KIND,&to,&to,&global);
	
						mt_wind_set_grect(window_handle,WF_CURRXYWH,&to,&global);
	
						if(calc_slider())
						{
							int msg[8];
	
							msg[0]=WM_REDRAW;
							msg[1]=ap_id;
							msg[2]=0;
							msg[3]=window_handle;
							mt_wind_get_grect(window_handle,WF_WORKXYWH,(GRECT *)&msg[4],&global);
							mt_appl_write(ap_id,16,msg,&global);
						}
					}
					else
					{
						mt_wind_calc_grect(WC_WORK,WIND_KIND,&full,&work,&global);
						work.g_h=(work.g_h/line_height)*line_height;
	
						lines_to_show=work.g_h/line_height-1;
	
						work.g_h-=line_height;
						work.g_h+=top_height;
	
						mt_wind_calc_grect(WC_BORDER,WIND_KIND,&work,&work,&global);
	
						mt_wind_set_grect(window_handle,WF_CURRXYWH,&work,&global);
	
						if(calc_slider())
						{
							int msg[8];
	
							msg[0]=WM_REDRAW;
							msg[1]=ap_id;
							msg[2]=0;
							msg[3]=window_handle;
							mt_wind_get_grect(window_handle,WF_WORKXYWH,(GRECT *)&msg[4],&global);
							mt_appl_write(ap_id,16,msg,&global);
						}

						full.g_w=full.g_h=-1;
					}
					break;
				}
				case WM_REDRAW:
				{
					if(mt_wind_update(BEG_UPDATE|there_is_check_and_set,&global))
					{
						redraw_window((GRECT *)&events.msg[4]);
						mt_wind_update(END_UPDATE,&global);
					}
					else
					{
						mt_appl_write(ap_id,16,events.msg,&global);
						events.mwhich&=~MU_MESAG;
					}
					break;
				}
				case 0x9277:
				{
					if(events.msg[1]==ap_id &&
						events.msg[3]==(int) 0x9277)
					{
						if(mt_wind_update(BEG_UPDATE|there_is_check_and_set,&global))
						{
							if(events.msg[4]=='cs')
							{
								if(calc_slider())
								{
									GRECT r;

									mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);
	
									redraw_window(&r);
								}
							}
							else if(events.msg[4]=='si')
							{
								set_info_line();
							}
							mt_wind_update(END_UPDATE,&global);
						}
						else
						{
							mt_appl_write(ap_id,16,events.msg,&global);
							events.mwhich&=~MU_MESAG;
						}
					}
					break;
				}
				case WM_SIZED:
				{
					GRECT a;

					full.g_w=full.g_h=-1;

					mt_wind_calc_grect(WC_WORK,WIND_KIND,(GRECT *)&events.msg[4],&a,&global);
					a.g_h=(a.g_h/line_height)*line_height;

					lines_to_show=a.g_h/line_height-1;

					a.g_h-=line_height;
					a.g_h+=top_height;

					mt_wind_calc_grect(WC_BORDER,WIND_KIND,&a,&a,&global);

					mt_wind_set_grect(window_handle,WF_CURRXYWH,&a,&global);

					if(calc_slider())
					{
						int msg[8];

						msg[0]=WM_REDRAW;
						msg[1]=ap_id;
						msg[2]=0;
						msg[3]=window_handle;
						mt_wind_get_grect(window_handle,WF_WORKXYWH,(GRECT *)&msg[4],&global);
						mt_appl_write(ap_id,16,msg,&global);
					}
	
					break;
				}
				case WM_ARROWED:
				{
					GRECT a;

					mt_wind_get_grect(window_handle,WF_WORKXYWH,&a,&global);
					switch(events.msg[4])
					{
						case WA_UPPAGE:
							move_up_down(-lines_to_show+1);
							break;
						case WA_DNPAGE:
							move_up_down(lines_to_show-1);
							break;
						case WA_UPLINE:
							move_up_down(-1);
							break;
						case WA_DNLINE:
							move_up_down(1);
							break;
						case WA_LFPAGE:
							move_left_right(-a.g_w+8);
							break;
						case WA_RTPAGE:
							move_left_right(a.g_w-8);
							break;
						case WA_LFLINE:
							move_left_right(-8);
							break;
						case WA_RTLINE:
							move_left_right(8);
							break;
					}
					break;
				}
				case WM_VSLID:
				{
					move_up_down(((long) ((double) ((double) (((double) events.msg[4])*((double) (finfos-lines_to_show))))/1000))-first_shown);
					break;
				}
				case WM_HSLID:
				{
					GRECT a;

					mt_wind_get_grect(window_handle,WF_WORKXYWH,&a,&global);
				
					a.g_x=6;
					for(a.g_h=0;a.g_h<6;a.g_h++)
					{
						if(show_row[a.g_h])
							a.g_x+=max_breite[a.g_h];
					}

					move_left_right((int) ((long) ((double) ((double) (((double) events.msg[4])*((double) (a.g_x-a.g_w))))/1000))-scrolled_left);
					break;
				}
				case WM_CLOSED:
				case AP_TERM:
					shaded_or_iconified=0;
					events.mwhich|=MU_KEYBD;
					events.kstate=0;
					events.key=CNTRL_Q;
					break;
				case AV_SENDKEY:
					if(events.mwhich & MU_KEYBD)
					{
						mt_appl_write(ap_id,16,events.msg,&global);
					}
					else
					{
						events.mwhich|=MU_KEYBD;
						events.kstate=events.msg[3];
						events.key=events.msg[4];
					}
					break;
				case AV_SENDCLICK:
					if(events.mwhich & MU_BUTTON)
					{
						mt_appl_write(ap_id,16,events.msg,&global);
					}
					else
					{
						events.mwhich|=MU_BUTTON;
						events.mx=events.msg[3];
						events.my=events.msg[4];
						events.mbutton=events.msg[5];
						events.kstate=events.msg[6];
						events.mclicks=events.msg[7];
					}
					break;
				case VA_PROTOSTATUS:
					av_server=mt_appl_find((char *)(((((unsigned long) events.msg[6])<<16) & 0xffff0000l)|(((unsigned long) events.msg[7]) & 0x0000ffffl)),&global);
					if(av_server<0)
						av_server=events.msg[1];
					av_server_kennt=(long) (((((unsigned long) events.msg[3])<<16) & 0xffff0000l)|(((unsigned long) events.msg[4]) & 0x0000ffffl));

					if(av_server_kennt & 0x00020000l)
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
					break;
				case VA_FILEFONT:
				case VA_FONTCHANGED:
					set_new_font(events.msg[3],events.msg[4]);
					break;
				case VA_WINDOPEN:
				case VA_XOPEN:
					if(events.msg[3]==0)
					{
						mt_rsrc_gaddr(5,ERR_OPEN_WIND,&alert,&global);
						mt_form_alert(1,alert,&global);
					}
					break;
				case VA_PROGSTART:
				case VA_VIEWED:
					if(av_string)
					{
						if(events.msg[3]==0)
						{
							mt_rsrc_gaddr(5,ERR_AV_PS_VI,&alert,&global);
							mt_form_alert(1,alert,&global);
						}

						Mfree(av_string);
						av_string=NULL;
						simuliere_taste_button(&events);
						return 0;
					}
					break;
				case VA_THAT_IZIT:
					simuliere_taste_button(&events);
					return 0;
				case VA_DRAG_COMPLETE:
					if(av_string)
					{
						Mfree(av_string);
						av_string=NULL;
						simuliere_taste_button(&events);
						return 0;
					}
					break;
				case VA_FILEDELETED:
					if(events.msg[3])
					{ /* Datei(en) konnte gelîscht werden */
						if(av_del_list)
						{
							GRECT r;
							unsigned long *nr;
							unsigned long zahl;
							FILE_INFO *par;

							nr=av_del_list;

							zahl=*nr++;

							while(zahl--)
							{ /* Datei aus der Liste rausnehmen */
								unsigned long l;

								for(l=0;l<finfos;l++)
								{
									par=get_from_list(l+1);
									if(par && par->read_nr==*nr)
									{
										free_from_list(par);
									}
								}

								nr++;
							}

							free(av_del_list);

							mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);

							init_max_breite();
					
							zahl=1;
							do {
								par=get_from_list(zahl);
								zahl++;
								if(par)
									test_max_breite(par);
							} while(par);
							calc_slider();
							set_info_line();
							redraw_window(&r);
						}
					}
					else
					{ /* Fehler beim Lîschen */
						mt_rsrc_gaddr(5,ERR_DEL_FILE,&alert,&global);
						mt_form_alert(1,alert,&global);
					}
					if(av_string)
					{
						Mfree(av_string);
						av_string=NULL;
						simuliere_taste_button(&events);
						return 0;
					}
					break;
				case VA_FILECHANGED:
					if(av_string)
					{
						Mfree(av_string);
						av_string=(char *) (*(unsigned long *)(&(events.msg[3])));
						simuliere_taste_button(&events);
						return 0;
					}
					break;
				case BUBBLEGEM_ACK:
					if((void *) *((unsigned long *)(&(events.msg[5])))!=NULL)
						Mfree((char *) *(unsigned long *)(&(events.msg[5])));
					break;
				case BUBBLEGEM_REQUEST:
					if(events.msg[6]==0)
						bubble_hilfen(events.msg[3],events.msg[4],events.msg[5]);
					break;
				case AP_DRAGDROP:
				{
				    static char pipename[]="U:\\PIPE\\DRAGDROP.AA";
				    long fd;

				    pipename[18]=events.msg[7] & 0x00ff;
				    pipename[17]=(events.msg[7] & 0xff00) >> 8;

				    fd=Fopen(pipename,2);
				    if(fd>=0)
				    {
				        char c=1;

				        Fwrite((int) fd,1,&c);
				        Fclose((int) fd);
				    }
				}
				break;
			}
		}

		if(shaded_or_iconified)	/* Keine TastendrÅcke durchlassen */
		{
			events.mwhich&=~MU_KEYBD;
			events.mwhich&=~MU_BUTTON;
		}

		if(events.mwhich & MU_KEYBD)
		{
			GRECT r;

			mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);

			switch(events.key)
			{
				case CNTRL_0:
				case 0x0b1d:	/* Shift-Cntrl-0 */
				case CNTRL_1:
				case 0x0201:	/* Shift-Cntrl-1 */
				case CNTRL_2:
				case 0x0302:	/* Shift-Cntrl-2 */
				case CNTRL_3:
				case 0x041d:	/* Shift-Cntrl-3 */
				case CNTRL_4:
				case 0x0504:	/* Shift-Cntrl-4 */
				case CNTRL_5:
				case 0x0605:	/* Shift-Cntrl-5 */
				case CNTRL_6:
				case 0x0706:	/* Shift-Cntrl-6 */
				{
					int so;
					GRECT r;

					mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);
					so=1;
					switch(events.key)
					{
						case CNTRL_1:
							so=2;
							break;
						case CNTRL_2:
							so=3;
							break;
						case CNTRL_3:
							so=4;
							break;
						case CNTRL_4:
							so=5;
							break;
						case CNTRL_5:
							so=6;
							break;
						case CNTRL_6:
							so=7;
							break;
						case 0x0b1d:	/* Shift-Cntrl-0 */
							so=-1;
							break;
						case 0x0201:	/* Shift-Cntrl-1 */
							so=-2;
							break;
						case 0x0302:	/* Shift-Cntrl-2 */
							so=-3;
							break;
						case 0x041d:	/* Shift-Cntrl-3 */
							so=-4;
							break;
						case 0x0504:	/* Shift-Cntrl-4 */
							so=-5;
							break;
						case 0x0605:	/* Shift-Cntrl-5 */
							so=-6;
							break;
						case 0x0706:	/* Shift-Cntrl-6 */
							so=-7;
							break;
					}

					sortiere_neu(so);

					redraw_window(&r);

					break;
				}
				case CNTRL_I:
				case TAB:
				{
					FILE_INFO *par;
					unsigned long o;
					int not_sendable=FALSE,ret;

					if(av_server_kennt & 0x80000000l)
					{
						for(o=0;o<finfos;o++)
						{
							par=get_from_list(o+1);
							if(par && par->selected)
							{
								if(test_quote(par,NULL,NULL) &&
									!(av_server_kennt & 0x40000000l))
								{
									not_sendable=TRUE;
								}
								else
								{
									av_string=make_quote(par,0);
									if(!av_string)
									{
										mt_rsrc_gaddr(5,ERR_NO_MEM,&alert,&global);
										mt_form_alert(1,alert,&global);
									}
									else
									{
										int msg[8];

										msg[0]=AV_FILEINFO;
										msg[1]=ap_id;
										msg[2]=0;
										*(unsigned long *)(&(msg[3]))=(unsigned long) av_string;
										msg[5]=msg[6]=msg[7]=0;

										mt_appl_write(av_server,16,msg,&global);

										thread_may_exit=0;
										ret=master_event(0);
										thread_may_exit=1;
										if(ret)
											return ret;

										msg[0]=AV_STARTED;
										msg[1]=ap_id;
										msg[2]=0;
										*(unsigned long *)(&(msg[3]))=(unsigned long) av_string;
										msg[5]=msg[6]=msg[7]=0;

										av_string=0l;
									}
								}
							}
						}

						if(not_sendable)
						{
							mt_rsrc_gaddr(5,ERR_HAS_NO_SP,&alert,&global);
							mt_form_alert(1,alert,&global);
						}
					}
					else
					{
						mt_rsrc_gaddr(5,ERR_HAS_NO_SP,&alert,&global);
						mt_form_alert(1,alert,&global);
					}
					break;
				}
				case CNTRL_A:
				{
					unsigned long l;

					for(l=0;l<finfos;l++)
					{
						FILE_INFO *par;

						par=get_from_list(l+1);
						if(par)
							par->selected=TRUE;
					}

					redraw_window(&r);
					break;
				}
				case 0x011b: /* ESC */
					return -2;
				case CNTRL_Q:
				case CNTRL_U:
					return -1;
				case CNTRL_C:
				{
					unsigned long l;
					char file[1024];
					char mask[1024];

					if(mt_scrp_read(file,&global))
					{
						FILE *fp;

						strcpy(mask,file);
						strcat(mask,"SCRAP.*");

						while(!Fdelete(mask));	/* SCRAP.* lîschen */

						strcpy(mask,file);
						strcat(mask,"scrap.*");

						while(!Fdelete(mask));	/* scrap.* lîschen */

						strcpy(mask,file);
						strcat(mask,"scrap.txt");

/*						handle_option(); */
						
						fp=fopen(mask,"w");
						if(fp)
						{
							int found=0;
							long max=0, max_pfad=0;

							for(l=0;l<finfos;l++)
							{
								FILE_INFO *par;

								par=get_from_list(l+1);
								if(par && strlen(par->name)>max )
									max=strlen(par->name);
								if(par && strlen(par->pfad)>max_pfad )
									max_pfad=strlen(par->pfad);
							}

							for(l=0;l<finfos;l++)
							{
								FILE_INFO *par;

								par=get_from_list(l+1);
								if(par && par->selected)
								{
									found=1;
									if(!writeline(par,max,max_pfad,fp))
									{
										mt_rsrc_gaddr(5,ERR_WRITE_SCRAP,&alert,&global);
										mt_form_alert(1,alert,&global);
										l=finfos;
										fclose(fp);
										fp=NULL;
									}
								}
							}

							if(!found)
							{
								for(l=0;l<finfos;l++)
								{
									FILE_INFO *par;
	
									par=get_from_list(l+1);
									if(par)
									{
										if(!writeline(par,max,max_pfad,fp))
										{
											mt_rsrc_gaddr(5,ERR_WRITE_SCRAP,&alert,&global);
											mt_form_alert(1,alert,&global);
											l=finfos;
											fclose(fp);
											fp=NULL;
										}
									}
								}
							}

							if(fp)
							{
								int ret;

								fclose(fp);

								if(mt_appl_getinfo(10,&ret,NULL,NULL,NULL,&global) && (ret & 0x00ff)>=7)
								{
									int msg[8];

									msg[0]=SC_CHANGED;
									msg[1]=ap_id;
									msg[2]=0;
									msg[3]=2;
									msg[4]='.t';
									msg[5]='xt';
									msg[6]=msg[7]=0;

									mt_shel_write(7,0,0,(void *)msg,NULL,&global);

									msg[0]=SH_WDRAW;

									if(mask[1]==':' && mask[0]>='A' && mask[0]<='Z')
										msg[3]=mask[0]-'A';
									else if(mask[1]==':' && mask[0]>='a' && mask[0]<='z')
										msg[3]=mask[0]-'a';
									else
										msg[3]=-1;

									msg[4]=msg[5]=msg[6]=msg[7]=0;

									mt_appl_write(0,16,msg,&global);
								}
							}
						}
						else
						{
							mt_rsrc_gaddr(5,ERR_WRITE_SCRAP,&alert,&global);
							mt_form_alert(1,alert,&global);
						}
					}
					else
					{
						mt_rsrc_gaddr(5,ERR_NO_SCRAP,&alert,&global);
						mt_form_alert(1,alert,&global);
					}
					break;
				}
				case CNTRL_F:
					return -3;
				case ALT_O:
					handle_option();
				break;
				case HOME:
					get_from_list(0);
					move_up_down(-finfos);
					break;
				case SHFT_HOME:
					move_up_down(finfos);
					break;
				case SHFT_CU:
				case 0x4900:	/* Page Up */
					move_up_down(-lines_to_show+1);
					break;
				case SHFT_CD:
				case 0x5100:	/* Page Down */
					move_up_down(lines_to_show-1);
					break;
				case CUR_UP:
					move_up_down(-1);
					break;
				case CUR_DOWN:
					move_up_down(1);
					break;
				case SHFT_CL:
					move_left_right(-r.g_w+8);
					break;
				case SHFT_CR:
					move_left_right(r.g_w-8);
					break;
				case CUR_LEFT:
					move_left_right(-8);
					break;
				case CUR_RIGHT:
					move_left_right(8);
					break;
				case HELP:
				{
					int stg_id;

					stg_id=mt_appl_find("ST-GUIDE",&global);
					if(stg_id>=0)
					{
						int buffer[8];

						buffer[0]=VA_START;
						buffer[1]=ap_id;
						buffer[2]=0;
						buffer[3]=(int) ((((long) help_str_liste) & 0xffff0000l)>>16);
						buffer[4]=(int) (((long) help_str_liste) & 0xffff);
						mt_appl_write(stg_id,16,buffer,&global);
					}
					else
					{
						mt_rsrc_gaddr(5,ERR_NO_ST_GUIDE,&alert,&global);
						mt_form_alert(1,alert,&global);
					}
					break;
				}
			}
		}

		if(events.mwhich & MU_BUTTON)
		{
			GRECT r;
			int ww;

			ww=6;
			for(i=0;i<6;i++)
			{
				if(show_row[i])
					ww+=max_breite[i];
			}

			mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);

			if(events.mbutton==2 && events.kstate==0)
			{	/* Klick mit der rechten Maustaste */
				OBJECT *tree;
				char *str=0l;

				mt_rsrc_gaddr(0,BUBBLE_HILFEN,&tree,&global);

				if(events.mx>=r.g_x && events.mx<=r.g_x+r.g_w &&
					events.my>=r.g_y && events.my<=r.g_y+r.g_h)
				{ /* Im Fenster */
					if(events.mx<=r.g_x+ww)
					{ /* In der Liste */
						if(events.my<=r.g_y+top_height)
						{ /* Im Listenkopf */
							bubble_hilfen(window_handle,events.mx,events.my);
						}
						else
						{ /* Auf eine der Dateien -> Verschieben/Doppelklick */
							EVNTDATA md;

							mt_wind_update(BEG_MCTRL,&global);

							mt_graf_mkstate(&md.x,&md.y,&md.bstate,&md.bstate,&global);

							if(md.bstate==0)
							{ /* Doppelklick */
								events.mbutton=1;
								events.mclicks=2;
							}
							else
							{ /* Verschieben */
								set_mouse(FLAT_HAND);
								do {
									mt_graf_mkstate(&md.x,&md.y,&md.bstate,&md.bstate,&global);
									if(md.y-events.my>=line_height || events.my-md.y>=line_height)
									{
										move_up_down((events.my-md.y)/line_height);
										events.my-=((events.my-md.y)/line_height)*line_height;
									}
									if(md.x!=events.mx)
									{ /* horizontal pixelweise Scroolen */
										move_left_right(events.mx-md.x);
										events.mx=md.x;
									}
								} while(md.bstate==2);
								set_mouse(ARROW);
							}

							mt_wind_update(END_MCTRL,&global);
						}
					}
					else
						bubble_hilfen(window_handle,events.mx,events.my);
				}

				if(str)
					bubble_hilfen(window_handle,(int)((((unsigned long) str) & 0xffff0000l)/0x00010000l),(int) (((unsigned long) str) & 0xffffl));
			}
			else if(events.mbutton==2 && events.kstate==K_ALT)
			{ /* Fenster toppen */
				int top;

				mt_wind_get_int(window_handle,WF_TOP,&top,&global);
				if(top == window_handle)
				{ /* untoppen, wenn mgl. */
					if(mt_appl_getinfo(11,&top,NULL,NULL,NULL,&global) &&
					   (top & 0x0040))
					{
						mt_wind_set_int(window_handle,WF_BOTTOM,0,&global);
					}
				}
				else
					mt_wind_set_int(window_handle,WF_TOP,0,&global);
			}

			if(events.mbutton==1)
			{ /* Klick mit der linken Maustaste */
				if(events.mx>=r.g_x && events.mx<=r.g_x+r.g_w &&
					events.my>=r.g_y && events.my<=r.g_y+r.g_h)
				{ /* Im Fenster */
					if(events.mx<=r.g_x+ww)
					{ /* In der Liste */
						if(events.my<=r.g_y+top_height)
						{ /* Im Listenkopf */
							int xx;
							int i=0;

							xx=events.mx-r.g_x+scrolled_left;

							while(xx>=0)
							{
								if(show_row[i])
									xx-=max_breite[i];
								i++;
							}

							xx=i+1;

							if(events.kstate & K_CTRL)
								xx=1;

							if((events.kstate & (K_RSHIFT|K_LSHIFT)) &&
								((xx!=sort_by && -xx!=sort_by) || sort_by>0))
								xx=-xx;

							sortiere_neu(xx);

							redraw_window(&r);
						}
						else
						{ /* Innerhalb der Dateiliste */
							unsigned long eintrag;
							FILE_INFO *par;
							EVNTDATA md;
			
							mt_graf_mkstate(&md.x,&md.y,&md.bstate,&md.bstate,&global);
			
							eintrag=first_shown+(events.my-r.g_y-top_height)/line_height;
			
							par=get_from_list(eintrag+1);
		
							if(par)
							{ /* Auf einen Eintrag */
								if((!(events.kstate & 3)) &&	/* keine Shifttaste gedrÅckt? */
									(events.mclicks!=2) &&
									!(md.bstate && events.mclicks==1))
								{
									unsigned long l;
			
									for(l=0;l<finfos;l++)
									{
										FILE_INFO *par;
			
										par=get_from_list(l+1);
			
										if(par->selected)
										{
											if(l!=eintrag)
											{
												par->selected=0;

												if(l>=first_shown && l<=first_shown+lines_to_show)
												{
													GRECT red;
	
													red=r;
													red.g_y+=((int) (l-first_shown))*line_height+top_height;
													red.g_h=line_height;
	
													redraw_window(&red);
												}
											}
										}
										else if(l==eintrag)
										{
											par->selected=1;

											if(l>=first_shown && l<=first_shown+lines_to_show)
											{
												GRECT red;

												red=r;
												red.g_y+=((int) (l-first_shown))*line_height+top_height;
												red.g_h=line_height;

												redraw_window(&red);
											}
										}
									}
								}
								else
								{ /* Shifttaste gedrÅckt */
									if(!(md.bstate && events.mclicks==1))
									{
										if(events.mclicks!=2 || !par->selected)
										{
											par->selected=!par->selected;
			
											if(eintrag>=first_shown && eintrag<=first_shown+lines_to_show)
											{
												GRECT red;

												red=r;
												red.g_y+=((int) (eintrag-first_shown))*line_height+top_height;
												red.g_h=line_height;

												redraw_window(&red);
											}
										}
									}
									else
									{
										if(!par->selected)
										{
											if(events.kstate & 3)
											{
												par->selected=TRUE;

												if(eintrag>=first_shown && eintrag<=first_shown+lines_to_show)
												{
													GRECT red;
	
													red=r;
													red.g_y+=((int) (eintrag-first_shown))*line_height+top_height;
													red.g_h=line_height;
	
													redraw_window(&red);
												}
											}
											else
											{
												unsigned long l;

												par->selected=TRUE;
												redraw_window(&r);

												for(l=0;l<finfos;l++)
												{
													FILE_INFO *par;

													par=get_from_list(l+1);

													if(l!=eintrag && par && par->selected)
													{
														par->selected=FALSE;
														if(l>=first_shown && l<=first_shown+lines_to_show)
														{
															GRECT red;

															red=r;
															red.g_y+=((int) (l-first_shown))*line_height+top_height;
															red.g_h=line_height;

															redraw_window(&red);
														}
													}
												}
											}
										}
									}
								}
			
								if(md.bstate && events.mclicks==1)
								{	/* D&D */
									unsigned long l;
									int msg[8];
									int ret;
								
									if(av_server_kennt & 0x02000000l)
									{
										GRECT xywh;
										EVNTDATA md;

										set_mouse(FLAT_HAND);

										mt_wind_get_grect(0,WF_WORKXYWH,&xywh,&global);
									
										mt_graf_dragbox((r.g_w<ww ? r.g_w : ww),line_height,r.g_x,r.g_y+((int) (eintrag-first_shown))*line_height+top_height,
																			xywh.g_x,xywh.g_y,xywh.g_h,xywh.g_w,&xywh.g_x,&xywh.g_y,&global);
									
										mt_graf_mkstate(&md.x,&md.y,&md.bstate,&md.bstate,&global);

										if(mt_wind_find(md.x,md.y,&global)!=window_handle)
										{
											set_mouse(BUSYBEE);

											if(!(av_server_kennt & 0x40000000l))
											{
												int not_sendable=0;
												unsigned long size=0l;
										
												for(l=0;l<finfos;l++)
												{
													par=get_from_list(l+1);
										
													if(par && par->selected)
													{
														if(test_quote(par,NULL,NULL))
															not_sendable=1;
														else
															size+=strlen(par->pfad)+strlen(par->name)+1;
													}
												}
										
												if(not_sendable)
												{
													mt_rsrc_gaddr(5,ERR_HAS_NO_QUOTE,&alert,&global);
													mt_form_alert(1,alert,&global);
												}
										
												if(size)
												{
													av_string=(char *)Mxalloc(size+1,0x22);
													if(av_string==(char *) (-32))
														av_string=(char *)Malloc(size+1);
										
													if(!av_string)
													{
														mt_rsrc_gaddr(5,ERR_NO_MEM,&alert,&global);
														mt_form_alert(1,alert,&global);
													}
													else
													{
														av_string[0]='\0';
														for(l=0;l<finfos;l++)
														{
															par=get_from_list(l+1);
										
															if(par && par->selected)
															{
																if(!test_quote(par,NULL,NULL))
																{
																	strcat(av_string,par->pfad);
																	strcat(av_string,par->name);
																	strcat(av_string," ");
																}
															}
														}
														av_string[strlen(av_string)-1]='\0';
													}
												}
											}
											else
											{
												av_string=make_quote(NULL,0);
												if(!av_string)
												{
													mt_rsrc_gaddr(5,ERR_NO_MEM,&alert,&global);
													mt_form_alert(1,alert,&global);
												}
											}
										
											if(av_string)
											{
												msg[0]=AV_WHAT_IZIT;
												msg[1]=ap_id;
												msg[2]=0;
												msg[3]=md.x;
												msg[4]=md.y;
												msg[5]=msg[6]=msg[7]=0;
										
												mt_appl_write(av_server,16,msg,&global);
										
												thread_may_exit=0;
												ret=master_event(0);
												thread_may_exit=1;
												if(ret)
													return ret;

													/* VA_THAT_IZIT auswerten */
												if((events.msg[4]==VA_OB_TRASHCAN || events.msg[4]==VA_OB_SHREDDER) &&
													(av_server_kennt & 0x00000002l))
												{ /* Dateien sollen gelîscht werden */
													int really;
													unsigned long selektiert=0;

													msg[0]=AV_DELFILE;
													msg[1]=ap_id;
													msg[2]=0;
													msg[3]=(int) ((((long) av_string) & 0xffff0000l)/0x00010000l);
													msg[4]=(int) (((long) av_string) & 0x0000ffffl);
													msg[5]=0;
													msg[6]=0;
													msg[7]=0;

													for(l=0;l<finfos;l++)
													{
														par=get_from_list(l+1);
											
														if(par && par->selected)
															selektiert++;
													}

													av_del_list=malloc(sizeof(unsigned long)*(selektiert+1));
													if(!av_del_list)
													{ /* Speichermangel */
														mt_rsrc_gaddr(5,ASK_MEM_DEL_FILE,&alert,&global);
														really=mt_form_alert(1,alert,&global) == 1;
													}
													else
													{
														unsigned long *help;

														help=av_del_list;

														*help++=selektiert;

														for(l=0;l<finfos;l++)
														{
															par=get_from_list(l+1);
												
															if(par && par->selected)
															{
																*help++=par->read_nr;
															}
														}
														really=1;
													}

													if(really)
													{
														mt_appl_write(av_server,16,msg,&global);

														thread_may_exit=0;
														ret=master_event(0);
														thread_may_exit=1;
														if(ret)
															return ret;
													}
												}
												else
												{
													msg[0]=AV_DRAG_ON_WINDOW;
													msg[1]=ap_id;
													msg[2]=0;
													msg[3]=md.x;
													msg[4]=md.y;
													msg[5]=md.kstate;
													msg[6]=(int) ((((long) av_string) & 0xffff0000l)/0x00010000l);
													msg[7]=(int) (((long) av_string) & 0x0000ffffl);
											
													mt_appl_write(av_server,16,msg,&global);
										
													msg[0]=AV_STARTED;
													msg[1]=ap_id;
													msg[2]=0;
													msg[3]=events.msg[6];
													msg[4]=events.msg[7];
													msg[5]=msg[6]=msg[7]=0;
										
													mt_appl_write(av_server,16,msg,&global);

													thread_may_exit=1;
													ret=master_event(0);
													thread_may_exit=1;
													if(ret)
														return ret;
												}
											}
										}

										set_mouse(ARROW);
									}
								}
			
								if(events.mclicks==2)
								{ /* Doppelklick */
									unsigned long l;
									int w;
									
									w=0;
									for ( i=BR_FILE; i<=BR_ATTR; i++)
									{
										if(show_row[i])
											w +=max_breite[i];
									}

									if(events.mx<=r.g_x+left_space+w)
									{ /* Datei îffnen */
										if(av_server_kennt & 0x00200004l)
										{
											int not_sendable=0;

											for(l=0;l<finfos;l++)
											{
												FILE_INFO *par;

												par=get_from_list(l+1);

												if(!(events.kstate & 3) &&
													l!=eintrag &&
													par && par->selected)
												{
													par->selected=FALSE;
													if(l>=first_shown && l<=first_shown+lines_to_show)
													{
														GRECT red;

														red=r;
														red.g_y+=((int) (l-first_shown))*line_height+top_height;
														red.g_h=line_height;

														redraw_window(&red);
													}
												}

												if(par && par->selected)
												{
													av_string=(char *)Mxalloc(strlen(par->pfad)+strlen(par->name)+1,0x22);
													if(av_string==(char *) (-32))
														av_string=(char *)Malloc(strlen(par->pfad)+strlen(par->name)+1);

													if(!av_string)
														not_sendable++;
													else
													{
														int msg[8];
														int ret;

														strcpy(av_string,par->pfad);
														strcat(av_string,par->name);

														if(!(av_server_kennt & 0x00000004l))
															msg[0]=AV_STARTPROG;
														else if(!(av_server_kennt & 0x00200000l))
															msg[0]=AV_VIEW;
														else if(events.kstate & K_ALT)
															msg[0]=AV_VIEW;
														else
															msg[0]=AV_STARTPROG;

														msg[1]=ap_id;
														msg[2]=0;
														msg[3]=(int) ((((long) av_string) & 0xffff0000l)/0x00010000l);
														msg[4]=(int) (((long) av_string) & 0x0000ffffl);
														msg[5]=0;
														msg[6]=0;
														msg[7]=0;

														mt_appl_write(av_server,16,msg,&global);

														thread_may_exit=0;
														ret=master_event(0);
														thread_may_exit=1;
														if(ret)
															return ret;
													}
												}
											}

											if(not_sendable)
											{
												mt_rsrc_gaddr(5,ERR_NO_MEM,&alert,&global);
												mt_form_alert(1,alert,&global);
											}
										}
										else
										{
											mt_rsrc_gaddr(5,ERR_HAS_NO_SP,&alert,&global);
											mt_form_alert(1,alert,&global);
										}
									}
									else
									{ /* Pfad îffnen */
										if(av_server_kennt & 0x08100000l)
										{
											for(l=0;l<finfos;l++)
											{
												FILE_INFO *par;

												par=get_from_list(l+1);

												if(!(events.kstate & 3) &&
													l!=eintrag &&
													par && par->selected)
												{
													par->selected=FALSE;
													if(l>=first_shown && l<=first_shown+lines_to_show)
													{
														GRECT red;

														red=r;
														red.g_y+=((int) (l-first_shown))*line_height+top_height;
														red.g_h=line_height;

														redraw_window(&red);
													}
												}

												if(par && par->selected)
												{
													int msg[8];

													if(av_server_kennt & 0x08000000l)
													{
														msg[0]=AV_XWIND;
														msg[7]=2;
													}
													else
													{
														msg[0]=AV_OPENWIND;
														msg[7]=0;
													}

													msg[1]=ap_id;
													msg[2]=0;
													msg[3]=(int) ((((long) par->pfad) & 0xffff0000l)/0x00010000l);
													msg[4]=(int) (((long) par->pfad) & 0x0000ffffl);
													msg[5]=(int) ((((long) par->name) & 0xffff0000l)/0x00010000l);
													msg[6]=(int) (((long) par->name) & 0x0000ffffl);
								
													appl_write(av_server,16,msg);
								
												}
											}
										}
										else
										{
											mt_rsrc_gaddr(5,ERR_HAS_NO_WO,&alert,&global);
											mt_form_alert(1,alert,&global);
										}
									}
								}
							}
							else
							{ /* auf keinen Eintrag */
								unsigned long l;
		
								for(l=0;l<finfos;l++)
								{
									FILE_INFO *par;
		
									par=get_from_list(l+1);
		
									if(par && par->selected)
									{
										par->selected=FALSE;
										if(l>=first_shown && l<=first_shown+lines_to_show)
										{
											GRECT red;

											red=r;
											red.g_y+=((int) (l-first_shown))*line_height+top_height;
											red.g_h=line_height;

											redraw_window(&red);
										}
									}
								}
							}
						}
					}
					else
					{ /* Neben die Liste */
						unsigned long l;

						for(l=0;l<finfos;l++)
						{
							FILE_INFO *par;

							par=get_from_list(l+1);

							if(par && par->selected)
							{
								par->selected=FALSE;
								if(l>=first_shown && l<=first_shown+lines_to_show)
								{
									GRECT red;

									red=r;
									red.g_y+=((int) (l-first_shown))*line_height+top_height;
									red.g_h=line_height;

									redraw_window(&red);
								}
							}
						}
					}
				}
			}
		}
	} while(events.mwhich!=MU_TIMER);

	return 0;
}

int writeline(FILE_INFO *par,long max, long max_pfad, FILE *fp)
{
	char ZStr[256];
	int k;

	k=0;
	if(config.clipboard_name)
	{
		k++;
		if(fprintf(fp,"%-*s",(int)max,par->name)==EOF)
			return 0;
	}

	if(k)
		fprintf(fp," ");
	
	if(config.clipboard_size)
	{
		k++;
		ultoa(par->size,ZStr,10);
		if(fprintf(fp,"%8s",ZStr)==EOF)
			return 0;
	}

	if(k)
		fprintf(fp," ");

	if(config.clipboard_time)
	{
		k++;
		sprintf(ZStr,"%02d:%02d:%02d",
			(par->time & 0xf800)/0x0800,
			(par->time & 0x07e0)/0x0020,
			(par->time & 0x001f)*2);
		if(fprintf(fp,"%s",ZStr)==EOF)
			return 0;
	}

	if(k)
		fprintf(fp," ");

	if(config.clipboard_date)
	{ /* PrÅfen, ob Tag oder Monat vorne stehen soll */
		OBJECT *tree;
		char trenner;

		k++;
		mt_rsrc_gaddr(0,LANGUAGE_SETTING,&tree,&global);
		trenner=tree[LS_DM_TRENNER].ob_spec.tedinfo->te_ptext[0];

		if(tree[LS_DAY_MONTH].ob_state & SELECTED)
		{
			sprintf(ZStr,"%02d%c%02d%c%04d",
				(par->date & 0x001f),
				trenner,
				(par->date & 0x01e0)/0x0020,
				trenner,
				(par->date & 0xfe00)/0x0200+1980);
		}
		else
		{
			sprintf(ZStr,"%02d%c%02d%c%04d",
				(par->date & 0x01e0)/0x0020,
				trenner,
				(par->date & 0x001f),
				trenner,
				(par->date & 0xfe00)/0x0200+1980);
		}
		if(fprintf(fp,"%s",ZStr)==EOF)
			return 0;
	}

	if(k)
		fprintf(fp," ");

	if(config.clipboard_flags)
	{
		k++;
		ZStr[0]=(par->attrib & FA_READONLY) ? 'R' : '-';
		ZStr[1]=(par->attrib & FA_HIDDEN) ? 'H' : '-';
		ZStr[2]=(par->attrib & FA_SYSTEM) ? 'S' : '-';
		ZStr[3]=(par->attrib & FA_VOLUME) ? 'V' : '-';
		ZStr[4]=(par->attrib & FA_ARCHIVE) ? 'A' : '-';
		ZStr[5]='\0';
		if(fprintf(fp,"%s",ZStr)==EOF)
			return 0;
	}

	if(k)
		fprintf(fp," ");

	if(config.clipboard_origin)
	{
		k++;
		if(fprintf(fp,"%-*s",(int)max_pfad,par->pfad)==EOF)
			return 0;
	}

	if(k)
		fprintf(fp," ");

	if(config.clipboard_origin_name)
	{
		k++;
		if(fprintf(fp,"%s%s",par->pfad,par->name)==EOF)
			return 0;
	}

	if(k)
		fprintf(fp,"\n");

	return 1;
}
