#include "start.h"

/*#include <aes.h>
#include <vdi.h>*/
#include <tos.h>
#include <av.h>
#include <portab.h>
#include <string.h>
#include <stddef.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <time.h>
#include <ext.h>
#include "sounds.h"
#include "global.h"
#include "option.h"
#include "memdebug.h"

#ifdef _DEBUG
	int debug_handle;
#endif

#define CLOSE_WIN(a)	{ mt_wind_close(a, (short*)&_GemParBlk.global[0]); mt_wind_delete(a, (short*)&_GemParBlk.global[0]); a=0;	}

int modify_time_format(char *in, char *out, struct _tm *tim)
	{
	int pos_in=0, pos_out=0;
	int american=0;

	for(pos_in=0; pos_in<strlen(in); pos_in++, pos_out++)
		{
		if(in[pos_in]=='%')
			{
			out[pos_out++] = in[pos_in++];
			switch(in[pos_in])
				{
				case 'A':
					sprintf(&out[pos_out-1], "%s", dni[tim->tm_wday+1]);
					break;
				case 'a':
					american=1;
					pos_out--;
					break;
				case 'D':
					sprintf(&out[pos_out-1], "%.3s", dni[tim->tm_wday+1]);	/*  = 'a';	*/
					break;
				case 'M':
					out[pos_out] = 'b';
					break;
				case 'y':
					out[pos_out] = 'Y';
					break;
				case 'Y':
					out[pos_out] = 'y';
					break;
				case 't':
					if(american==1)
						strcat(&out[pos_out], "I:%M");
					else
						strcat(&out[pos_out], "H:%M");
					pos_out+=3;
					break;
				case 'B':
					{
					char *month = (char*)monthspopup[tim->tm_mon+1].ob_spec.free_string;
					int len = strcspn(&month[1], " ");
					if(in[pos_in+1]=='%')												/* Skrocenie dlugosci nazwy miesiaca		*/
						{
						sprintf(&out[pos_out-1], "%.*s", min(len, in[pos_in+2]-'0'), &month[1]);
						pos_in+=2;
						}
					else
						sprintf(&out[pos_out-1], "%.*s", len, &month[1]);
					break;
					}
				default:
					out[pos_out] = in[pos_in];
					break;
				}
			}
		else
			out[pos_out] = in[pos_in];
		}
	return(american);
	}


void close_window(int w)
	{
	if(w==MyTask.whandle)
		CLOSE_WIN(MyTask.whandle)
	else if(w==MyTask.wh_calendar)
		CLOSE_WIN(MyTask.wh_calendar)
	}

int read_line(int f_h, char *input)
	{
	int ii=0, j, jj=0;
	while((j=(int)read(f_h, &input[ii], 1))==1)
		{
		if(input[ii]=='\n')
			{
			jj++;
			input[strcspn(input, "\n\r")] = 0;
			break;
			}
		ii++;
		}
	return(jj);
	}


void reset_texts(void)
	{
	int i;

	if(options.language==GERMAN)
		return;

	for(i=0; i<13; i++)
		free(miesiac[i]);
	for(i=0; i<8; i++)
		free(dni[i]);
	for(i=0; i<4; i++)
		free(bubble_calendar[i]);

	free_lang_pop();
	}			/* reset_texts()	*/


void read_texts(void)
	{
	int f_h=-1, i=-1, j=1, jj, text=0, max_len=0;
	char YES[10], NO[10], CANCEL[10], OK[10], MELDE[30];
	char line[100]={0};
	OBJECT *dialogi[]={apppopup_magic, apppopup_mint, startpopup, (OBJECT*)message, (OBJECT*)1L, (OBJECT*)rs_tedinfo_calender, (OBJECT*)miesiac, (OBJECT*)dni, (OBJECT*)bubble_calendar, popup_app_icon}, *dial;

	switch(options.language)
		{
		case POLISH:
			f_h = open("polish.lan", O_RDONLY);
			break;
		case GERMAN:
			f_h = open("german.lan", O_RDONLY);
			break;
		case ENGLISH:
			f_h = open("english.lan", O_RDONLY);
			break;
		case FRENCH:
			f_h = open("french.lan", O_RDONLY);
			break;
		case SWEDISH:
			f_h = open("swedish.lan", O_RDONLY);
			break;
		case NORWEGIAN:
			f_h = open("norweg.lan", O_RDONLY);
			break;
		}
	if(f_h>0)
		{
		int read_len=0;
		dial = dialogi[i];
		while((read_len=read_line(f_h, line))>0 && i<13)
			{
			if(line[1]=='#')								/* Tylko jak na poczatku linii jest ## to przejsc do kolejnego dialogu	*/
				{																	/* Inaczej jest to zwykly komenatrz	:)																	*/
				i++;
				if(dial && max_len)								/* Czy jest jakis dialog i max dlugosc tekstu?	*/
					{
					dial->ob_width = max_len;				/* Zmiana szerokosci popupmenu				*/
					for(jj=0; jj<(dial->ob_tail+1); jj++)
						{
						dial[jj].ob_width = max_len;	/* Zmiana szerokosci wpisow						*/
						if(jj!=2 && jj!=0 && strlen(dial[jj].ob_spec.free_string)>max_len)
							dial[jj].ob_spec.free_string[max_len] = 0;
						}
					}
				dial = dialogi[i];
				max_len=0;
				j=1;
				text = 0;
				}
			else if(line[0]!='#')
				{
				if(dial!=(OBJECT*)message && dial!=(OBJECT*)1L && dial!=(OBJECT*)rs_tedinfo_calender && dial!=(OBJECT*)miesiac && dial!=(OBJECT*)dni && dial!=(OBJECT*)bubble_calendar && dial!=(OBJECT*)popup_app_icon)
					{
					while(dial[j].ob_state&OS_DISABLED)
						j++;
					if(j<=dial->ob_tail)
						{
						memset(dial[j].ob_spec.free_string, ' ', strlen(dial[j].ob_spec.free_string));
						strncpy(dial[j].ob_spec.free_string, line, min(strlen(line), strlen(dial[j].ob_spec.free_string)));
						if(strlen(line)>max_len)
							max_len = (int)strlen(line);
						}
					j++;
					}
				else if(dial==(OBJECT*)message)
					{
					switch(text)
						{
						case 0:
							strcpy(CANCEL, line);
							break;
						case 1:
							strcpy(YES, line);
							break;
						case 2:
							strcpy(NO, line);
							break;
						case 3:
							strcpy(OK, line);
							break;
						case 4:
							strcpy(MELDE, line);
							break;
						case 5:
							sprintf(message[0], "[1][ |%s ][%s]", line, CANCEL);
							break;
						case 6:
							sprintf(message[1], "%s\n", line, CANCEL);
							break;
						case 7:
							sprintf(message[2], "[2][ |%s ][%s | %s]", line, YES, NO);
							break;
						case 8:
							sprintf(message[3], "[1][ |%s ", line);
							break;
						case 9:
							sprintf(message[4], "[1][ |%s ][%s]", line, CANCEL);
							sprintf(message[5], "[1][ |%s ][%s]", line, CANCEL);
							break;
						case 10:
							sprintf(message[6], ").][%s]", CANCEL);
							break;
						case 11:
							sprintf(message[7], "[1][%s ][%s]", line, CANCEL);
							break;
						case 12:
							sprintf(message[8], "[1][%s ][%s]", line, CANCEL);
							break;
						case 13:
							sprintf(message[9], "[1][%s ][%s]", line, OK);
							break;
						case 14:
							sprintf(message[10], "[1][%s ][%s]", line, OK);
							break;
						case 15:
							sprintf(message[11], "[1][%s ", line);
							break;
 						case 16:
							sprintf(message[12], "[1][%s ][%s]", line, OK);
							break;
 						case 17:
							sprintf(message[13], "[1][%s ][%s]", line, MELDE);
							break;
						case 18:
							sprintf(message[MSG_ALT_KONF], "[1][%s ][%s]", line, OK);
							break;
						case 19:
							sprintf(message[MSG_FILE_PROBLEMS], "[1][%s ][%s]", line, OK);
							break;

 						case 20:
							sprintf(languages_text[0], "%s", line);
							break;
 						case 21:
							sprintf(languages_text[1], "%s", line);
							break;
 						case 22:
							sprintf(languages_text[2], "%s", line);
							break;
 						case 23:
							sprintf(languages_text[3], "%s", line);
							break;
 						case 24:
							sprintf(languages_text[4], "%s", line);
							break;
 						case 25:
							sprintf(languages_text[5], "%s", line);
							break;
						}
					text++;
					}
				else if(dial==(OBJECT*)1L)
					{
					switch(text)
						{
						case 0:
							memset(drventry, ' ', strlen(drventry));
							strncpy(drventry, line, min(strlen(line), strlen(drventry)));
							break;
						case 1:
							memset(docentry, ' ', strlen(docentry));
							strncpy(docentry, line, min(strlen(line), strlen(docentry)));
							break;
						case 2:
							memset(appentry, ' ', strlen(appentry));
							strncpy(appentry, line, min(strlen(line), strlen(appentry)));
							break;
						case 3:
							memset(fseltitle, ' ', strlen(fseltitle));
							strncpy(fseltitle, line, min(strlen(line), strlen(fseltitle)));
							break;
						case 4:
							memset(xaccusr, ' ', strlen(xaccusr));
							strncpy(xaccusr, line, min(strlen(line), strlen(xaccusr)));
							break;
						case 5:
							memset(bubbleinfo, ' ', strlen(bubbleinfo));
							strncpy(bubbleinfo, line, min(strlen(line), strlen(bubbleinfo)));
							break;
						case 6:
							memset(options_text, ' ', strlen(options_text));
							strncpy(options_text, line, min(strlen(line), strlen(options_text)));
							break;
						}
					text++;
					}
				else if(dial==(OBJECT*)rs_tedinfo_calender)
					{
					strcpy(rs_tedinfo_calender[1].te_ptext, line);
					}
				else if(dial==(OBJECT*)miesiac && text<13 && strcmp(miesiac[text+1], "???")!=0)
					{
					if(strlen(miesiac[text+1])<strlen(line))
						{
						free(miesiac[text+1]);
						miesiac[text+1] = calloc(1,strlen(line)+1L);
						}
					memset(miesiac[text+1], 0, strlen(line)+1);
					strcpy(miesiac[text+1], line);
					memset(monthspopup[text+1].ob_spec.free_string, ' ', strlen(monthspopup[text+1].ob_spec.free_string));
					strncpy((char*)(&monthspopup[text+1].ob_spec.free_string[1]), line, min(strlen(line), strlen((char*)(&monthspopup[text+1].ob_spec.free_string[1]))));
					text++;
					}
				else if(dial==(OBJECT*)dni && text<8 && strcmp(dni[text+1],"???")!=0)
					{
					if(strlen(dni[text+1])<strlen(line))
						{
						free(dni[text+1]);
						dni[text+1] = calloc(1,strlen(line)+1L);
						}
					memset(dni[text+1], 0, strlen(line)+1);
					strcpy(dni[text+1], line);
					text++;
					}
				else if(dial==(OBJECT*)bubble_calendar && text<4)
					{
					if(bubble_calendar[++text]!=NULL)
						{
						free(bubble_calendar[text]);
						bubble_calendar[text] = calloc(1,strlen(line));
						if(bubble_calendar[text])
							strcpy(bubble_calendar[text], line);
						}
					text++;
					}
				else if(dial==popup_app_icon)
					{
					if(text==0)
						text = 2;
					memset(popup_app_icon[text].ob_spec.free_string, ' ', strlen(popup_app_icon[text].ob_spec.free_string));
					strncpy(popup_app_icon[text].ob_spec.free_string, line, min(strlen(line), strlen(popup_app_icon[text].ob_spec.free_string)));
					if(strlen(line)>max_len)
						max_len = (int)strlen(line) + 1;
					if(popup_app_icon->ob_width < max_len)
						popup_app_icon->ob_width = max_len;
					text++;
					}
				}
			memset(line, 0, 100);
			}
		close(f_h);
		}
	}




int find_appicon_by_objc(int objc)
	{
	if(icons_spec_app)
		{
		int i;
		for(i=0; i<icons_spec_app->no; i++)
			{
			if(icons_spec_app[i].rsc_no == objc)
				return(i);
			}
		}
	return(-1);
	}


void open_window(OBJECT *tree, int *handler, int mx, int my, char *title, int *w, int *h)
	{
	if ((*handler)<=0)
		{
		(*handler) = mt_wind_create(NAME|CLOSER|MOVER,desk.g_x,desk.g_y,desk.g_w,desk.g_h, (short*)&_GemParBlk.global[0]);
	
		if ((*handler)<=0)
			{
	   	mt_form_alert(1,message[1], (short*)&_GemParBlk.global[0]);
			return;
			}
		
		clip_startinf();

		if(mx!=-1)
			tree->ob_x = mx;
		if(my!=-1)
			tree->ob_y = my;
		mt_wind_calc(WC_BORDER, WINDOWSTYLE, (short)tree->ob_x,(short)tree->ob_y,(short)tree->ob_width,(short)tree->ob_height,(short*)&wx,(short*)&wy,(short*)&ww,(short*)&wh, (short*)&_GemParBlk.global[0]);

		(*w) = ww+8;
		(*h) = wh+22;
		mt_wind_open(*handler, wx, wy, options.w, options.h, (short*)&_GemParBlk.global[0]);
    mt_wind_set(*handler, WF_BEVENT, 1, 0, 0, 0, (short*)&_GemParBlk.global[0]);
		if(title!=NULL)
    	{
    	int p[4]={0};
    	*(char **) (p) = title;
  	  mt_wind_set(*handler,WF_NAME, p[0], p[1], p[2], p[3], (short*)&_GemParBlk.global[0]);
  	  }
		}
 	else
 		{
 		if (!untop)
 			mt_wind_set(*handler,WF_TOP,0,0,0,0, (short*)&_GemParBlk.global[0]);
	 	}
	}

struct _alias *alias_name;

void importiere_longname(char *name)
	{
	int fh, i=1;
	unsigned long fsize;
	char *file=NULL, *tmp=NULL, *tmp1;

	fh=open(name, O_RDONLY);
	if(fh>0)
		{
		fsize = Fseek(0, fh, 2);
		Fseek(0, fh, 0);
		tmp = file = calloc(1,fsize+10L);
		memset(file, 0,fsize+10); 
		read(fh, file, fsize);
		close(fh);
		if(strstr(file, "LONGNAME_")!=NULL)
			{
			file += (strstr(file, "LONGNAME_") - file);
			file++;
			tmp1 = file;
			while(strstr(file, "LONGNAME_")!=NULL)
				{
				file += (strstr(file, "LONGNAME_") - file);
				i++;
				file++;
				}
			file = tmp1-1;
			if(alias_name)
				free(alias_name);
			alias_name = calloc(1,i*sizeof(struct _alias));
			alias_name->no = i;
			i = 0;
			while(strstr(file, "LONGNAME_")!=NULL)
				{
				int len;
				file += strlen("LONGNAME_");
				len = (int)strcspn(file, "=")+1;
				alias_name[i].name = calloc(1,len);		memset(alias_name[i].name, 0, len);
				strncpy(alias_name[i].name, file, len-1);
				file += len;
				len = (int)strcspn(file, "\r\n")+1;
				alias_name[i].alias = calloc(1,len);		memset(alias_name[i].alias, 0, len);
				strncpy(alias_name[i].alias, file, len-1);

				file += (strstr(file, "LONGNAME_") - file);
				i++;
				}
			}
		}
	if(tmp)
		free(tmp);
	}


void find_alias(char *in, char *out)
	{
	int i;
	if(alias_name==NULL)
		return;
	for(i=0; i<alias_name->no; i++)
		{
		if(alias_name[i].name)
			{
			if(strncmp(in, alias_name[i].name, strcspn(in, " "))==0)
				{
				strncpy(out, alias_name[i].alias, min(24, strlen(alias_name[i].alias)));
				break;
				}
			}
		}
	}


#define CHANGE_HEIGHT(a)	{if(a>0) {vst_point(MyTask.v_handle, a, &chw, &chh, &cw, &ch);} else {vst_height(MyTask.v_handle, a, &chw, &chh, &cw, &ch);} }


int Set_font(int font_id, int *font_height, int font_effect)
	{
	short chw=0, chh=0, cw=0, ch=0;

	if(*font_height>15)
		*font_height = 15;
	vst_font(MyTask.v_handle, font_id);
	if(font_id==1)
		{
		if(*font_height!=0)	/* && *font_height!=startinf.font_height)*/
			{
			CHANGE_HEIGHT(*font_height);
			if(chh!=*font_height)
				{
				int hh=0;		/**font_height;	*/
				while(ch<*font_height)
					CHANGE_HEIGHT(hh++)
				}
			}
		else
			{
			CHANGE_HEIGHT(13)
			if(chh!=13)
				CHANGE_HEIGHT(12)
			}
		}
	else
		{
		if(*font_height!=0)
			{
			CHANGE_HEIGHT(*font_height)
			if(ch!=*font_height)
				{
				int hh=0;		/**font_height;*/
				while(ch<*font_height)
					CHANGE_HEIGHT(hh++)
				}
			}
		else
			CHANGE_HEIGHT(startinf.font_height)
		}
	vst_effects(MyTask.v_handle, font_effect);
	return(chh);
	}



int get_text_width(char *text, int app_no, int font_id, int *font_h)
	{
	OBJECT *tmp=NULL;
	int width=0, font_effect=0;
	short font_pos[10]={0};
	int app=0;
	char alias[30]={0};
	if(app_no!=-1)
		app = find_app_by_id(app_no);

	strcpy(alias, text);
	find_alias(text, alias);

	if(app_no!=-2)
		{
		if(_applications_[app].check==2 && app_no!=-1)
			font_effect = options.frezzy_effect;
		}
	if(options.stic_app_button!=2 || app_no==-1)
		{
		Set_font(font_id, font_h, font_effect);
		vqt_extent( (short)MyTask.v_handle, alias, font_pos );
		width = font_pos[2] + 16;
		}
	else
		width = 12;

	if(app_no!=-2)
		{
		if(options.stic_app_button>0 && app_no!=-1)
			{
			if((tmp=_applications_[app_no].icon)==NULL)
				tmp=_applications_[app_no].icon = stic->str_icon(text, STIC_SMALL);
			if(tmp!=NULL)															/* Czy ikonka wogole istnieje dla tej aplikacji			*/
				width += 10;														/* Tak: poszerzyc przycisk													*/
			}
		}

	return(width);
	}


extern char tmp[];
void SendHTML(char *url, char *name)
	{
	int h;
	char tmp1[256];

	if(strlen(tmp)>0)
			sprintf(tmp1, "%stmp.html", tmp);
	else
			sprintf(tmp1, "c:\\gemsys\\tmp.html", tmp);
	h = open(tmp1, O_CREAT|O_WRONLY|O_TRUNC);
	if(h)
		{
		write(h, "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\r\n", strlen("<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\r\n"));
		write(h, "<html>\r\n", strlen("<html>\r\n"));
		write(h, "<title>", strlen("<title>"));
		write(h, name, strlen(name));
		write(h, "</title>\r\n", strlen("</title>\r\n"));
		write(h, "<meta http-equiv=\"refresh\" content=\"3;URL=", strlen("<meta http-equiv=\"refresh\" content=\"3;URL="));
		write(h, url, strlen(url));
		write(h, "\">\r\n", strlen("\">\r\n"));
		write(h, "</head>\r\n<body>\r\n</body>\r\n", strlen("</head>\r\n<body>\r\n</body>\r\n"));
		close(h);
		start_app(0, SHW_PARALLEL, "HTML", tmp1, NULL);
		}
	}

void SendAV(int to_id, int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8)
	{
DEBUG
	if(!pipe)
		{
		if(system_==SYS_MINT)
			pipe = Mxalloc(16, MX_READABLE|3);
		else
			pipe = calloc(1,32L);
		}
	if(pipe)
		{
		pipe[0]=p1;
		pipe[1]=p2;
		pipe[2]=p3;
		pipe[3]=p4;
		pipe[4]=p5;
		pipe[5]=p6;
		pipe[6]=p7;
		pipe[7]=p8;
		
		mt_appl_write(to_id,16,pipe,(short*)&_GemParBlk.global[0]);
		}
	else
		{
		int pi[10];
		pi[0]=p1;
		pi[1]=p2;
		pi[2]=p3;
		pi[3]=p4;
		pi[4]=p5;
		pi[5]=p6;
		pi[6]=p7;
		pi[7]=p8;
				
		mt_appl_write(to_id,16,pi,(short*)&_GemParBlk.global[0]);
		}
DEBUG
	}


void zeige_ordner_popup(char *_path, int mnx, int mny)
	{
	long    b, lmax=0;
	int     c, filanz=0, ret=0;
	char	*path=NULL;
	MENU    menu, msel;
	OBJECT *drvpop = NULL;
	DTA *mydta=NULL;

	path = calloc(1,strlen(_path)+10L);
	memset(path, 0, strlen(_path)+10);
	sprintf(path, "%s\\*.*", _path);

	mydta = Fgetdta();
	if(Fsfirst(path, 0)==0)
		{
		filanz++;
		lmax = max(lmax, strlen(mydta->d_fname));
		while(Fsnext()==0)
			{
			lmax = max(lmax, strlen(mydta->d_fname));
			filanz++;
			}
		}

		drvpop = (OBJECT *)calloc(1,sizeof(OBJECT)*(long)filanz);

		if (drvpop)
		{
			int cnt = 1;

			if (lmax) lmax += 3L;
			lmax += 6L;

			drvpop[ROOT].ob_next   = -1;
			drvpop[ROOT].ob_head   =  1;
			drvpop[ROOT].ob_tail   = filanz-1;
			drvpop[ROOT].ob_type   = G_BOX;
			drvpop[ROOT].ob_flags  = FL3DBAK;
			drvpop[ROOT].ob_state  = OS_NORMAL;
			drvpop[ROOT].ob_spec.index = 0x00ff1100L;
			drvpop[ROOT].ob_x      =  0;
			drvpop[ROOT].ob_y      =  0;
			drvpop[ROOT].ob_width  = (int)lmax-1;
			drvpop[ROOT].ob_height = filanz-1;
			Fsfirst(path, 0);

			for (c=0,b=1;c<filanz;c++)
				{
				drvpop[cnt].ob_next   = cnt+1;
				drvpop[cnt].ob_head   = -1;
				drvpop[cnt].ob_tail   = -1;
				drvpop[cnt].ob_type   = G_STRING;
				drvpop[cnt].ob_flags  = FL3DBAK|OF_SELECTABLE;
				drvpop[cnt].ob_state  = OS_NORMAL;
				drvpop[cnt].ob_spec.free_string = (char *)calloc(1,lmax);
				drvpop[cnt].ob_x      =  0;
				drvpop[cnt].ob_y      = cnt-1;
				drvpop[cnt].ob_width  = (int)lmax-1;
				drvpop[cnt].ob_height =  1;

				if (drvpop[cnt].ob_spec.free_string)
					{
					drvpop[cnt].ob_spec.free_string[0] = ' ';
					strcpy(&drvpop[cnt].ob_spec.free_string[1], mydta->d_fname);
					drvpop[cnt].ob_spec.free_string[3] = c+65;

					while (strlen(drvpop[cnt].ob_spec.free_string)<lmax-1)
						strcat(drvpop[cnt].ob_spec.free_string," ");
					}

				cnt++;
				Fsnext();
				}

			b <<= 1;
			}

		drvpop[filanz-1].ob_next = 0;
		drvpop[filanz-1].ob_flags |= OF_LASTOB;

		fix_tree(drvpop);

		menu.mn_tree     = drvpop;
		menu.mn_menu     = ROOT;
		menu.mn_item     = 1;
		menu.mn_scroll   = 0;
		menu.mn_keystate = 0;

	ret = mt_menu_popup(&menu,mnx,mny,&msel,(short*)&_GemParBlk.global[0]);
	if(ret)
		{
		char *path=calloc(1,strlen(_path)+strlen(drvpop[msel.mn_item].ob_spec.free_string)+3L);
		memset(path, 0, strlen(_path)+strlen(drvpop[msel.mn_item].ob_spec.free_string)+1);
		sprintf(path, "%s%s", _path, drvpop[msel.mn_item].ob_spec.free_string);
		while(path[strlen(path)-1]==' ')
			path[strlen(path)-1]=0;
		start_app(0,SHW_PARALLEL,"Ordner",path,NULL);
		}
	}


OBJECT *benutzer_popup;
static int max_len;
void build_app_menu(void)
	{
	short i,j;
	usrdef.ub_code = draw_menu_rect;
	usrdef.ub_parm = 0L;
	if(benutzer_popup==NULL)
		return;
	for(i=0,j=1; i<benutzer_popup->ob_tail ;i++)
		{
		if(popup_app_menu[i].text!=NULL)
			{
			if(popup_app_menu[i].aktion==-4) 			/* Separator	*/
				{
				OBJECT sep={-4,-1,-1,G_STRING,FL3DBAK,OS_DISABLED,0L,0,1,1,1};
				memcpy(&benutzer_popup[j], &sep, sizeof(OBJECT));
				benutzer_popup[j].ob_next   = j+1;
				benutzer_popup[j].ob_y      = j-1;
				benutzer_popup[j].ob_width  = max_len;
				benutzer_popup[j].ob_type = G_USERDEF;
				benutzer_popup[j].ob_spec.userblk = &usrdef;
				}
			else
				{
				benutzer_popup[j].ob_next   = j+1;
				benutzer_popup[j].ob_head   = -1;
				benutzer_popup[j].ob_tail   = -1;
				benutzer_popup[j].ob_type   = G_STRING;
				benutzer_popup[j].ob_flags  = FL3DBAK|OF_SELECTABLE;
				benutzer_popup[j].ob_state  = OS_NORMAL;
				benutzer_popup[j].ob_spec.free_string = (char *)calloc(1,(long)max_len+1L);
				benutzer_popup[j].ob_x      =  0;
				benutzer_popup[j].ob_y      = j-1;
				benutzer_popup[j].ob_width  = max_len;
				benutzer_popup[j].ob_height = 1;
				
				if (benutzer_popup[j].ob_spec.free_string)
					{
					memset(benutzer_popup[j].ob_spec.free_string, 0, max_len+1);
					memset(benutzer_popup[j].ob_spec.free_string, ' ', max_len);
					strncpy(benutzer_popup[j].ob_spec.free_string, popup_app_menu[i].text, strlen(popup_app_menu[i].text));
					}
				}
			j++;
			}
		}
	benutzer_popup[j-1].ob_flags |= OF_LASTOB;
	benutzer_popup[j-1].ob_next = 0;
	}


void init_app_menu(void)
	{
	FILE *h;
	char datei[256]={0};
	OBJECT null={-1,1,16,G_BOX,FL3DBAK,OS_NORMAL,(long)0x00ff1100L,0,0,28,16};
	int i=0;

	if(get_cookie('MiNT',NULL)!=0L)
		system_ = SYS_MINT;
	else if(get_cookie('MagX',NULL)!=0L)
		system_ = SYS_MAGIC;
	else
		system_ = SYS_TOS;

	if(strlen(home))
		{
		if(system_==SYS_MINT)
			sprintf(datei, "%s\\mypopup.min", home);
		else
			sprintf(datei, "%s\\mypopup.mag", home);
		}
	else
		{
		if(system_==SYS_MINT)
			sprintf(datei, "mypopup.min");
		else
			sprintf(datei, "mypopup.mag");
		}

	h = fopen(datei, "r");
	if(!h)
		{
		if(get_cookie('MiNT',NULL)!=0L)
			{
			apppopup = apppopup_mint;
			popup_app_menu[2].text = " ";															popup_app_menu[0].aktion = -1;						/* Nazwa	*/
			popup_app_menu[1].text = "  999999 [kB]               ";	popup_app_menu[1].aktion = -2;							/* Pamiec	*/
			popup_app_menu[2].text = "  Prioriaet                 ";	popup_app_menu[2].aktion = DEF_BUTT_PRIORITY;
			popup_app_menu[3].text = " ";															popup_app_menu[3].aktion = -4;							/* Separator	*/
			popup_app_menu[4].text = "  Terminate                 ";	popup_app_menu[4].aktion = DEF_BUTT_TERMINATE;
			popup_app_menu[5].text = "  Ende                      ";	popup_app_menu[5].aktion = DEF_BUTT_QUIT;
			popup_app_menu[6].text = "  Zeige                     ";	popup_app_menu[6].aktion = DEF_BUTT_SHOW;
			popup_app_menu[7].text = "  Verstecke andere          ";	popup_app_menu[7].aktion = DEF_BUTT_HIDE_OTHER;
			popup_app_menu[8].text = "  Verstecken                ";	popup_app_menu[8].aktion = DEF_BUTT_HIDE;
			popup_app_menu[9].text = "  Zeige alle                ";	popup_app_menu[9].aktion = DEF_BUTT_SHOW_ALL;
			popup_app_menu[10].text = " ";														popup_app_menu[10].aktion = -4;							/* Separator	*/
			popup_app_menu[11].text = "  VorÅbergehend verstecken  ";	popup_app_menu[11].aktion = DEF_BUTT_VER_VOR;
			popup_app_menu[12].text = "  Dauerhaft verstecken      ";	popup_app_menu[12].aktion = DEF_BUTT_VER_DAU;
			i = 13;	max_len = (int)strlen("  VorÅbergehend verstecken  ");
			}
		else if(get_cookie('MagX',NULL)!=0L)
			{
			apppopup = apppopup_magic;
			popup_app_menu[2].text = "                            ";															popup_app_menu[0].aktion = -1;						/* Nazwa	*/
			popup_app_menu[1].text = "  999999 [kB]               ";	popup_app_menu[1].aktion = -2;							/* Pamiec	*/
			popup_app_menu[2].text = "                            ";															popup_app_menu[2].aktion = -4;							/* Separator	*/
			popup_app_menu[3].text = "  Terminate                 ";	popup_app_menu[3].aktion = DEF_BUTT_TERMINATE;
			popup_app_menu[4].text = "  Ende                      ";	popup_app_menu[4].aktion = DEF_BUTT_QUIT;
			popup_app_menu[5].text = "  Verstecke andere          ";	popup_app_menu[5].aktion = DEF_BUTT_HIDE_OTHER;
			popup_app_menu[6].text = "  Verstecke                 ";	popup_app_menu[6].aktion = DEF_BUTT_HIDE;
			popup_app_menu[7].text = "  Zeige alle                ";	popup_app_menu[7].aktion = DEF_BUTT_SHOW_ALL;
			popup_app_menu[8].text = "  Zeige                     ";	popup_app_menu[8].aktion = DEF_BUTT_SHOW;
			popup_app_menu[9].text = "  Freezy                    ";	popup_app_menu[9].aktion = DEF_BUTT_FREEZY;
			popup_app_menu[10].text = "  Unfreezy                  ";	popup_app_menu[10].aktion = DEF_BUTT_UNFREEZY;
			popup_app_menu[11].text = "                            ";														popup_app_menu[11].aktion = -4;							/* Separator	*/
			popup_app_menu[12].text = "  VorÅbergehend verstecken  ";	popup_app_menu[12].aktion = DEF_BUTT_VER_VOR;
			popup_app_menu[13].text = "  Dauerhaft verstecken      ";	popup_app_menu[13].aktion = DEF_BUTT_VER_DAU;
			popup_app_menu[14].text = "                            ";														popup_app_menu[14].aktion = -4;							/* Separator	*/
			popup_app_menu[15].text = "  Fenster                   ";	popup_app_menu[15].aktion = -3;							/* Spis okien	*/
			i = 16;	max_len = (int)strlen("  VorÅbergehend verstecken  ");
			}
		else
			system_ = SYS_TOS;
		}
	else
		{
		int len;
		max_len = 0;
		while(fgets(datei, 256, h) && i<MAX_BENUTZER_POPUP)
			{
			len = (int)strcspn(datei, "\t");
			popup_app_menu[i].text = calloc(1, len+1);
			strncpy(popup_app_menu[i].text, datei, len);
			popup_app_menu[i].aktion = atoi(&datei[len+2]);
			if(max_len<strlen(popup_app_menu[i].text))
				max_len = (int)strlen(popup_app_menu[i].text)+2;
			i++;
			}
		fclose(h);
		benutzer_popup = calloc(1, sizeof(OBJECT)*(i+2));
		memcpy(&benutzer_popup[0], &null, sizeof(OBJECT));
		benutzer_popup->ob_tail = i;
		benutzer_popup->ob_width = max_len;
		benutzer_popup->ob_height = i;

		build_app_menu();
		apppopup = benutzer_popup;
		}
	memcpy(options.popup_app_menu, popup_app_menu, sizeof(struct _popup_menu)*MAX_BENUTZER_POPUP);
	}


void app_popup_vorbereiten(OBJECT *popup, int app_no)
	{
	int il=popup->ob_tail, i;
	for(i=0; i<il; i++)
		{
		switch(popup_app_menu[i].aktion)
			{
			case -1:
				{
				char *name=NULL;
				if(strlen(_applications_[app_no].alias)>1)						/* Prawdziwa nazwa czy alias?		*/
					name = _applications_[app_no].alias;
				else
					name = _applications_[app_no].name;
				if(popup[i+1].ob_spec.free_string)					/* Zwolnienie starej pamieci		*/
					{
					free((char*)popup[i+1].ob_spec.free_string);
					popup[i+1].ob_spec.free_string=NULL;
					}
				popup[i+1].ob_spec.free_string = calloc(1,strlen(name)+3L);		/* Nowa pamiec dla nazwy	*/
				popup[i+1].ob_spec.free_string[0] = ' ';
				popup[i+1].ob_spec.free_string[1] = ' ';
				popup[i+1].ob_state |= OS_DISABLED;
				strncpy(&popup[i+1].ob_spec.free_string[2], name, strlen(name));	/* Nowa nazwa				*/
				popup[i+1].ob_spec.free_string[2+strlen(name)] = 0;
				break;
				}
			case -2:
				popup[i+1].ob_spec.free_string[0] = ' ';
				popup[i+1].ob_spec.free_string[1] = ' ';
				itoa(_applications_[app_no].used_memory, &popup[i+1].ob_spec.free_string[2], 10);
				strcat(&popup[i+1].ob_spec.free_string[2], " [kB]");
				break;
			}
		}
	}

void get_paths(void)
	{
	char*dummy;
	dummy = getenv("HOME");
	if (dummy)
	{
		strcpy(home,dummy);
		if (strlen(home)>0)
		{
			if (home[strlen(home)-1] != '\\') strcat(home,"\\");
		}
	}
	else
		home[0]=0;

	dummy = getenv("TMP");
	if (dummy)
	{
		strcpy(tmp,dummy);
		if (strlen(tmp)>0)
		{
			if (tmp[strlen(tmp)-1] != '\\') strcat(tmp,"\\");
		}
	}
	else
		tmp[0]=0;

	}


COOKIE *get_cookie_jar(void)
{
	return (COOKIE *)Setexc(360,(void (*)())-1L);
}


int get_cookie(long id, long *value)
{
	COOKIE *cookiejar = get_cookie_jar();

	if (cookiejar)
	{
		while (cookiejar->id)
		{
			if (cookiejar->id == id)
			{
				if (value) *value = cookiejar->value;
				return(1);
			}
			
			cookiejar++;
		}
	}
	
	return(0);
}


int new_cookie(long id, long value)
{
	COOKIE *cookiejar = get_cookie_jar();
	
	if (cookiejar)
	{
		long maxc, anz = 1;
		
		while (cookiejar->id)
		{
			anz++;
			cookiejar++;
		}
		
		maxc = cookiejar->value;
		
		if (anz < maxc)
		{
			cookiejar->id    = id;
			cookiejar->value = value;
			
			cookiejar++;
			
			cookiejar->id    = 0L;
			cookiejar->value = maxc;
			
			return(1);
		}
	}
	
	return(0);
}

int remove_cookie(long id)
{
	COOKIE *cookiejar = get_cookie_jar();
	
	if (cookiejar)
	{
		while ((cookiejar->id) && (cookiejar->id != id)) cookiejar++;
		
		if (cookiejar->id)
		{
			COOKIE *cjo;
			
			do
			{
				cjo = cookiejar++;
			
				cjo->id    = cookiejar->id;
				cjo->value = cookiejar->value;

			} while(cookiejar->id);
			
			return(1);
		}
	}
	return(0);
}

OBJECT *build_popup_thing(STARTMENU *menu)
	{
	OBJECT *popup=NULL;
	STARTENTRY *tmp;

	printf("%s\r\n", menu->entries->name);
	tmp = menu->children->entries;
	while(tmp)
		{
		printf("%s: %s\r\n", tmp->name, tmp->file);
		tmp = tmp->next;
		}
	return(popup);
	}



void Reload_set(void)
	{
	int x2,y2,w2,h2;
	if(menus)
		{
		if(menus->tree)
			free(menus->tree);
		free(menus);
		}
	x2 = bigbutton[START_BUTTON].ob_x;			y2 = bigbutton[START_BUTTON].ob_y;
	w2 = bigbutton[START_BUTTON].ob_width;	h2 = bigbutton[START_BUTTON].ob_height;

	get_system_parameter(NULL, FALSE);

	bigbutton[START_BUTTON].ob_x = x2;			bigbutton[START_BUTTON].ob_y = y2;
	bigbutton[START_BUTTON].ob_width = w2;	bigbutton[START_BUTTON].ob_height = h2;
	}



/** Przygotowanie obiektu czasu/daty do uzytkowania.
  	 	- wyznaczone sa formaty obu linijek
   		- obliczona zostaje szerokosc obu linijek
   		- z powyzszego wieksza wartosc stanowi szerokosc obiektu czasu/daty (TIME_OBJECT)
*/
void prepare_time_object(void)
{
	static unsigned long timer_prev;
	long timer, str_len=0;
	short amer=0;
	struct _tm *tim;
	char time_mode_tmp[20]={0};
	int font_h=6;

	time(&timer);
	if(timer==timer_prev)
		timer++;
	tim = (struct _tm*)localtime(&timer);
	
DEBUG

		{
DEBUG

		amer = modify_time_format(options.time_mode_1, time_mode_tmp, tim);
		strftime(text_time_line1, 20, time_mode_tmp, (struct tm*)tim);
		if(strstr(text_time_line1, "%r")!=NULL)
			sprintf(strstr(text_time_line1, "%r")-2, "%Ld kB", ((unsigned long)Mxalloc(-1, ALLOCMODE))/1000L);

DEBUG

		memset(time_mode_tmp, 0, 20);
		amer = modify_time_format(options.time_mode_2, time_mode_tmp, tim) | amer;
		strftime(text_time_line2, 20, time_mode_tmp, (struct tm*)tim);
		if(strstr(time_mode_tmp, "%r")!=NULL)
			sprintf(&text_time_line2[(strstr(time_mode_tmp, "%r")-time_mode_tmp)], "%Ld kB", ((unsigned long)Mxalloc(-1, ALLOCMODE))/1000L);

DEBUG

		str_len = max(get_text_width(text_time_line1, -2, startinf.timer_font_id, &font_h),	\
									get_text_width(text_time_line2, -2, startinf.timer_font_id, &font_h));
		if(str_len<1)
			str_len = max((int)strlen(text_time_line1), (int)strlen(text_time_line2))*10;

		bigbutton[TIME_OBJECT].ob_width = str_len;
		bigbutton[TIME_OBJECT].ob_x = bigbutton->ob_width - str_len - 2;
		}
	timer_prev=timer;
DEBUG
}