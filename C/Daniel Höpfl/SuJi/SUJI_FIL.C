#include "SuJi_glo.h"

FILE_INFO first_fi={0l};
FILE_INFO *last_fi=&first_fi;
unsigned long finfos=0;
double fsize;

int durchsuche_alle(char **pfad,int pfade)
{
	int i;
	int stop;
	OBJECT *tree;

	i=0;
	do {
		stop=durchsuche(get_pfad(pfad,i));
		i++;
	} while(i<pfade && !stop);

	searching=FALSE;
	set_mouse(ARROW);

	if(stop==-2)
	{
		mt_rsrc_gaddr(5,WINDOW_NAME_STOP,&alert,&global);
		mt_wind_set_string(window_handle,WF_NAME,alert,&global);
	}
	else
	{
		mt_rsrc_gaddr(5,WINDOW_NAME,&alert,&global);
		mt_wind_set_string(window_handle,WF_NAME,alert,&global);
	}

	mt_rsrc_gaddr(0,MASKE_ICONIFY,&tree,&global);
	tree[SU_ICON1].ob_flags |= HIDETREE;
	tree[SU_ICON3].ob_flags &= ~HIDETREE;

	if(shaded_or_iconified)
	{
		GRECT r;

		mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);
		redraw_window(&r);
	}

	return stop;
}

int durchsuche(char *pfad)
{
	void *handle;
	int err;
	DTA *my_dta;

	handle=DHopendir(pfad);

	do {
		err=DHxreaddir(handle,&my_dta);
		if(!err)
		{
			int ret;

			ret=master_event(1);

			if(ret)
			{
				DHclosedir(handle);
				return ret;
			}

			if(my_dta->d_attrib & FA_SUBDIR)
			{
				char *sub;

				sub=Malloc(strlen(pfad)+1+strlen(my_dta->d_fname)+1);
				if(sub)
				{
					strcpy(sub,pfad);
					strcat(sub,my_dta->d_fname);
					sub[strlen(sub)+1]='\0';
					sub[strlen(sub)]='\\';

					err=durchsuche(sub);

					Mfree(sub);

					if(err)
					{
						DHclosedir(handle);
						return err;
					}
				}
				else
				{
					mt_rsrc_gaddr(5,ERR_NO_MEM2,&alert,&global);
					if(mt_form_alert(1,alert,&global)==2)
					{
						DHclosedir(handle);
						return -1;
					}
				}
			}
			else
			{
				int inh;

				if(suji.inhalt[0]!='\0')
				{
					inh=test_inhalt(suji.inhalt,pfad,my_dta,suji.big_is_small_inhalt);
					if(inh==0)
					{
						DHclosedir(handle);
						return -1;
					}
					else
						inh--;
				}
				else
					inh=1;

				if(suji.min_size<=my_dta->d_length &&
					suji.max_size>=my_dta->d_length &&
					suji.min_date<=my_dta->d_date &&
					suji.max_date>=my_dta->d_date &&
					wildchar(suji.maske,my_dta->d_fname,suji.big_is_small_maske) &&
					inh)
				{
					FILE_INFO *akt;
					long sort_nr;

					akt=add_to_list(my_dta,pfad,&sort_nr);
					if(akt)
					{
						if(test_max_breite(akt) && !shaded_or_iconified)
						{
							GRECT r;

							if(sort_nr-1<first_shown)
							{
								if(finfos>lines_to_show)
									first_shown++;
							}

							calc_slider();
							mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);

							if(mt_wind_update(BEG_UPDATE|there_is_check_and_set,&global))
							{
								redraw_window(&r);
								mt_wind_update(END_UPDATE,&global);
							}
							else
							{
								int msg[8];

								msg[0]=WM_REDRAW;
								msg[1]=ap_id;
								msg[2]=0;
								msg[3]=window_handle;
								msg[4]=r.g_x;
								msg[5]=r.g_y;
								msg[6]=r.g_w;
								msg[7]=r.g_h;

								mt_appl_write(ap_id,16,msg,&global);
							}
						}
						else
						{
							if(!shaded_or_iconified && 
								sort_nr<=first_shown+lines_to_show &&
								(first_shown==0 || sort_nr>=first_shown+2))
							{
								GRECT r,fn;

								if(mt_wind_update(BEG_UPDATE|there_is_check_and_set,&global))
								{
									set_mouse(M_OFF);
									
									mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);
									
									r.g_y+=top_height+(int) ((sort_nr-first_shown-1)*((long) line_height));
									r.g_h-=top_height+(int) ((sort_nr-first_shown-1)*((long) line_height));
									
									mt_wind_get_grect(window_handle,WF_FIRSTXYWH,&fn,&global);
									while(fn.g_w && fn.g_h)
									{
										fn.g_w=(fn.g_x+fn.g_w<r.g_x+r.g_w ? fn.g_x+fn.g_w : r.g_x+r.g_w)-(fn.g_x>r.g_x ? fn.g_x : r.g_x);
										fn.g_h=(fn.g_y+fn.g_h<r.g_y+r.g_h ? fn.g_y+fn.g_h : r.g_y+r.g_h)-(fn.g_y>r.g_y ? fn.g_y : r.g_y);
										fn.g_x=fn.g_x>r.g_x ? fn.g_x : r.g_x;
										fn.g_y=fn.g_y>r.g_y ? fn.g_y : r.g_y;
									
										if(((fn.g_x+fn.g_w<r.g_x+r.g_w ? fn.g_x+fn.g_w : r.g_x+r.g_w) > (fn.g_x>r.g_x ? fn.g_x : r.g_x)) && ((fn.g_y+fn.g_h<r.g_y+r.g_h ? fn.g_y+fn.g_h : r.g_y+r.g_h) > (fn.g_y>r.g_y ? fn.g_y : r.g_y)))
										{
											MFDB quell={0};
											MFDB ziel={0};
											int xy[8];
									
											xy[0]=fn.g_x;
											xy[1]=fn.g_y;
											xy[2]=xy[0]+fn.g_w-1;
											xy[3]=xy[1]+fn.g_h-1;
									
											xy[4]=xy[0];
									
											xy[5]=xy[1]+line_height;
									
											xy[6]=xy[4]+fn.g_w-1;
											xy[7]=xy[5]+fn.g_h-1;
									
											vs_clip(vdi_h,1,xy);
									
											vro_cpyfm(vdi_h,S_ONLY,xy,&quell,&ziel);
									
											xy[0]=fn.g_x;
											xy[2]=fn.g_w;
										
											xy[1]=fn.g_y;
											xy[3]=xy[7]-xy[3]+1;
									
											xy[2]=(xy[0]+xy[2]<fn.g_x+fn.g_w ? xy[0]+xy[2] : fn.g_x+fn.g_w)-(xy[0]>fn.g_x ? xy[0] : fn.g_x);
											xy[3]=(xy[1]+xy[3]<fn.g_y+fn.g_h ? xy[1]+xy[3] : fn.g_y+fn.g_h)-(xy[1]>fn.g_y ? xy[1] : fn.g_y);
											xy[0]=xy[0]>fn.g_x ? xy[0] : fn.g_x;
											xy[1]=xy[1]>fn.g_y ? xy[1] : fn.g_y;
									
											if(((xy[0]+xy[2]<fn.g_x+fn.g_w ? xy[0]+xy[2] : fn.g_x+fn.g_w) > (xy[0]>fn.g_x ? xy[0] : fn.g_x)) &&
												((xy[1]+xy[3]<fn.g_y+fn.g_h ? xy[1]+xy[3] : fn.g_y+fn.g_h) > (xy[1]>fn.g_y ? xy[1] : fn.g_y)))
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
									
										mt_wind_get_grect(window_handle,WF_NEXTXYWH,&fn,&global);
									}

									set_mouse(M_ON);
									mt_wind_update(END_UPDATE,&global);
								}
								else
								{
									int msg[8];
	
									mt_wind_get_grect(window_handle,WF_WORKXYWH,(GRECT *)&msg[4],&global);
									msg[0]=WM_REDRAW;
									msg[1]=ap_id;
									msg[2]=0;
									msg[3]=window_handle;
	
									mt_appl_write(ap_id,16,msg,&global);
								}
							}
							else if(sort_nr-1<first_shown)
							{
								if(finfos>lines_to_show)
									first_shown++;
							}
	
							if(calc_slider() && !shaded_or_iconified)
							{
								if(mt_wind_update(BEG_UPDATE|there_is_check_and_set,&global))
								{
									GRECT r;

									mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);
	
									redraw_window(&r);
									mt_wind_update(END_UPDATE,&global);
								}
								else
								{
									int msg[8];
	
									mt_wind_get_grect(window_handle,WF_WORKXYWH,(GRECT *)&msg[4],&global);
									msg[0]=WM_REDRAW;
									msg[1]=ap_id;
									msg[2]=0;
									msg[3]=window_handle;
	
									mt_appl_write(ap_id,16,msg,&global);
								}
							}
						}

						set_info_line();
					}
					else
					{
						mt_rsrc_gaddr(5,ERR_NO_MEM2,&alert,&global);
						if(mt_form_alert(1,alert,&global)==2)
						{
							DHclosedir(handle);
							return -1;
						}
					}
				}
			}
		}
	} while(!err);

	DHclosedir(handle);

	return 0;
}

int do_wildchar(char *mask,char *test,int big_is_small)
{
	int passt=TRUE;

	if(big_is_small)
	{
		while(mask[0])
		{
			if(mask[0]!='*' &&
				mask[0]!='?' &&
				mask[0]!='[' &&
				mask[0]!='{')
			{
				if(mask[0]=='\\' && mask[1])
					mask++;
	
				if(uprchar(mask[0])==uprchar(test[0]))
				{
					mask++;
					test++;
				}
				else
					return FALSE;
			}
			else if(mask[0]=='?')
			{
				mask++;
				test++;
			}
			else if(mask[0]=='*')
			{
				unsigned long i;

				if(mask[1])
				{
					i=0l;
					while(test[i] && passt)
					{
						passt=!do_wildchar(&(mask[1]),&(test[i]),big_is_small);
						i++;
					}
	
					return !passt;
				}
				else
					return TRUE;
			}
			else if(mask[0]=='[' && (mask[1]!='^' && mask[1]!='!'))
			{
				unsigned long i;
				unsigned long j;
	
				if(mask[1]==']')
					return FALSE;
	
				i=0;
				do {
					if(mask[i]=='\\')
						i++;
					if(mask[i])
						i++;
				} while(mask[i]!=']' && mask[i]);
	
				if(!mask[i])
					return FALSE;
	
				passt=FALSE;
	
				j=1;
				do {
					if(mask[j]=='-')
					{
						int x;
	
						if(j==1)
							return FALSE;
	
						x=uprchar(mask[j-1]+1);
	
						j++;
						if(mask[j]==']')
							return FALSE;
						if(mask[j]=='\\')
							j++;
	
						if(uprchar(mask[j])<x)
							return FALSE;
	
						while(x<=uprchar(mask[j]))
						{
							if(x==uprchar(test[0]))
							{
								mask=&mask[i+1];
								test++;
		
								passt=TRUE;
								j=i;
							}
							x++;
						}
					}
					else
					{
						if(mask[j]=='\\')
							j++;
						if(uprchar(mask[j])==uprchar(test[0]))
						{
							mask=&mask[i+1];
							test++;
	
							passt=TRUE;
						}
	
						j++;
					}
				} while(j<i);
	
				if(!passt)
					return FALSE;
			}
			else if(mask[0]=='{' ||
				(mask[0]=='[' && (mask[1]=='^' || mask[1]=='!')))
			{
				unsigned long i;
				unsigned long j;
				char ende='}';

				if(mask[0]=='[')
					ende=']';

				if(mask[1]=='}')
					return FALSE;
	
				i=0;
				do {
					if(mask[i]=='\\')
						i++;
					if(mask[i])
						i++;
				} while(mask[i]!=ende && mask[i]);
	
				if(!mask[i])
					return FALSE;
	
				j=1;
				do {
					if(mask[j]=='-')
					{
						int x;
	
						if(j==1)
							return FALSE;
	
						x=uprchar(mask[j-1]+1);
	
						j++;
						if(mask[j]==ende)
							return FALSE;
						if(mask[j]=='\\')
							j++;

						if(uprchar(mask[j])<x)
							return FALSE;

						while(x<=uprchar(mask[j]))
						{
							if(x==uprchar(test[0]))
								return FALSE;
							x++;
						}

						j++;
					}
					else
					{
						if(mask[j]=='\\')
							j++;
						if(uprchar(mask[j])==uprchar(test[0]))
							return FALSE;

						j++;
					}
				} while(j<i);

				mask=&mask[i+1];
				test++;
			}
		}
	
		if(mask[0]!=test[0])
			passt=FALSE;
	
		return passt;
	}
	else
	{
		while(mask[0])
		{
			if(mask[0]!='*' &&
				mask[0]!='?' &&
				mask[0]!='[' &&
				mask[0]!='{')
			{
				if(mask[0]=='\\' && mask[1])
					mask++;
	
				if(mask[0]==test[0])
				{
					mask++;
					test++;
				}
				else
					return FALSE;
			}
			else if(mask[0]=='?')
			{
				mask++;
				test++;
			}
			else if(mask[0]=='*')
			{
				unsigned long i;

				if(mask[1])
				{	
					i=0;
					while(test[i] && passt)
					{
						passt=!do_wildchar(&(mask[1]),&(test[i]),big_is_small);
						i++;
					}
	
					return !passt;
				}
				else
					return TRUE;
			}
			else if(mask[0]=='[' && (mask[1]!='^' && mask[1]!='!'))
			{
				unsigned long i;
				unsigned long j;
	
				if(mask[1]==']')
					return FALSE;
	
				i=0;
				do {
					if(mask[i]=='\\')
						i++;
					if(mask[i])
						i++;
				} while(mask[i]!=']' && mask[i]);
	
				if(!mask[i])
					return FALSE;
	
				passt=FALSE;
	
				j=1;
				do {
					if(mask[j]=='-')
					{
						int x;
	
						if(j==1)
							return FALSE;
	
						x=mask[j-1]+1;
	
						j++;
						if(mask[j]==']')
							return FALSE;
						if(mask[j]=='\\')
							j++;
	
						if(mask[j]<x)
							return FALSE;
	
						while(x<=mask[j])
						{
							if(x==test[0])
							{
								mask=&mask[i+1];
								test++;
		
								passt=TRUE;
								j=i;
							}
							x++;
						}
					}
					else
					{
						if(mask[j]=='\\')
							j++;
						if(mask[j]==test[0])
						{
							mask=&mask[i+1];
							test++;
	
							passt=TRUE;
						}
	
						j++;
					}
				} while(j<i);
	
				if(!passt)
					return FALSE;
			}
			else if(mask[0]=='{' ||
				(mask[0]=='[' && (mask[1]=='^' || mask[1]=='!')))
			{
				unsigned long i;
				unsigned long j;
				char ende='}';

				if(mask[0]=='[')
					ende=']';
	
				if(mask[1]=='}')
					return FALSE;
	
				i=0;
				do {
					if(mask[i]=='\\')
						i++;
					if(mask[i])
						i++;
				} while(mask[i]!=ende && mask[i]);
	
				if(!mask[i])
					return FALSE;
	
				j=1;
				do {
					if(mask[j]=='-')
					{
						int x;
	
						if(j==1)
							return FALSE;
	
						x=mask[j-1]+1;
	
						j++;
						if(mask[j]==ende)
							return FALSE;
						if(mask[j]=='\\')
							j++;

						if(mask[j]<x)
							return FALSE;

						while(x<=mask[j])
						{
							if(x==test[0])
								return FALSE;
							x++;
						}

						j++;
					}
					else
					{
						if(mask[j]=='\\')
							j++;
						if(mask[j]==test[0])
							return FALSE;

						j++;
					}
				} while(j<i);

				mask=&mask[i+1];
				test++;
			}
		}
	
		if(mask[0]!=test[0])
			passt=FALSE;
	
		return passt;
	}
}

int wildchar(char *mask,char *test,int big_is_small)
{
	int ret;
	char meine_maske[256];
	char *maske;

	maske=mask;
	do {
		strcpy(meine_maske,maske);
		for(i=0;i<strlen(meine_maske);i++)
		{
			if(meine_maske[i]==',')
				meine_maske[i]='\0';
			if(meine_maske[i]=='\\')
				i++;
		}
		maske=&maske[strlen(meine_maske)];

		if(*maske==',')
			maske++;

		ret=do_wildchar(meine_maske,test,big_is_small);
	} while(!ret && *maske);

	return ret;
}

int test_maske(char *maske)
{
	int i;

	if(maske[0]=='\0')
		return 1;
	if(maske[0]==',')
		return 1;

	for(i=0;i<(int) strlen(maske);i++)
	{
		if(maske[i]=='[')
		{
			if(maske[i+1]==']')
				return 2;
			if(maske[i+1]=='\0')
				return 3;
			if(maske[i+1]==',')
				return 3;
			if((maske[i+1]=='^' || maske[i+1]=='!') && maske[i+2]==']')
				return 9;
			if((maske[i+1]=='^' || maske[i+1]=='!') && maske[i+2]=='\0')
				return 10;
			if((maske[i+1]=='^' || maske[i+1]=='!') && maske[i+2]==',')
				return 10;

			i++;
			while((maske[i]!='\0' && maske[i]!=',') && maske[i]!=']')
			{
				if(maske[i]=='\\' && maske[i+1])
					i++;
				i++;
			}

			if(maske[i]=='\0')
				return 4;
			if(maske[i]==',')
				return 4;
		}
		if(maske[i]=='{')
		{
			if(maske[i+1]=='}')
				return 5;
			if(maske[i+1]=='\0')
				return 6;
			if(maske[i+1]==',')
				return 6;

			i++;
			while((maske[i]!='\0' && maske[i]!=',') && maske[i]!='}')
			{
				if(maske[i]=='\\' && maske[i+1])
					i++;
				i++;
			}

			if(maske[i]=='\0')
				return 7;
			if(maske[i]==',')
				return 7;
		}
		if(maske[i]=='\\' && maske[i+1]=='\0')
			return 8;

		if(maske[i]=='\\')
			i++;
	}

	return 0;
}
