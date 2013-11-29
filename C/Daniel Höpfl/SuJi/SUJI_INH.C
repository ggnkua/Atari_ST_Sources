#include "SuJi_glo.h"

long cdecl thread(long *par);

int thread_id_inhalt;
int thread_ret;

/* inhalt_add_error:
	-1		-> Fragen / keine Fehler
	0		-> Nein
	>0		-> Zahl der Fehler */

int inhalt_add_error=-1;

static int handle_error(char *datei, int about)
{
	if(inhalt_add_error==-1)
	{
		/* Dialog l„uft modal ab */
		GRECT r;
		void *flydial;
		int button;
		OBJECT *tree;

		mt_rsrc_gaddr(0,ASK_INHALT,&tree,&global);

		if(about==1)
		{
			tree[AI_MEM].ob_flags &= ~HIDETREE;
			tree[AI_READ].ob_flags |= HIDETREE;
		}
		else
		{
			tree[AI_READ].ob_flags &= ~HIDETREE;
			tree[AI_MEM].ob_flags |= HIDETREE;
		}
		tree[AI_REMEMBER].ob_state &= ~SELECTED;

		if(strlen(datei)<=32)
		{
			strcpy(tree[AI_DATEINAME].ob_spec.free_string,datei);
		}
		else
		{
			char *ziel;
			unsigned long l;

			ziel=tree[AI_DATEINAME].ob_spec.free_string;

			l=strlen(datei);
			while(l && datei[l]!='\\')
				l--;

			if(strlen(datei)-l<29)
			{
				for(i=0;i<29-(strlen(datei)-l);i++)
				{
					ziel[i]=datei[i];
				}
				ziel[i]='.';
				ziel[i+1]='.';
				ziel[i+2]='.';
				ziel[i+3]='\0';

				strcat(ziel,&datei[l]);
			}
			else
			{
				ziel[0]='.';
				ziel[1]='.';
				ziel[2]='.';
				ziel[3]='\0';
				strcat(ziel,&datei[strlen(datei)-29]);
			}
		}

		mt_form_center_grect(tree,&r,&global);
		mt_wind_update(BEG_MCTRL,&global);
		mt_form_xdial_grect(FMD_START,&r,&r,&flydial,&global);
		mt_objc_draw_grect(tree,ROOT,MAX_DEPTH,&r,&global);

		do {
			button=mt_form_xdo(tree,0,&i,NULL,flydial,&global) & 0x7fff;
		} while(button!=AI_YES && button!=AI_NO);

		mt_form_xdial_grect(FMD_FINISH,&r,&r,&flydial,&global);
		mt_wind_update(END_MCTRL,&global);

		if(tree[AI_REMEMBER].ob_state & SELECTED)
		{
			if(button==AI_NO)
				inhalt_add_error=0;
			else
				inhalt_add_error=1;
		}

		tree[button].ob_state &= ~SELECTED;

		return (button==AI_YES ? 2 : 1);
	}
	else if(inhalt_add_error==0)
	{
		return 1;
	}
	else
	{
		inhalt_add_error++;
		return 2;
	}
}

int test_inhalt(char *maske,char *pfad,DTA *dta,int big_is_small)
{
	THREADINFO thi={(void *)thread,0l,1024,0,0l};
	long werte[4];
	char *datei;

	werte[0]=(long) maske;
	werte[1]=(long) pfad;
	werte[2]=(long) dta;
	werte[3]=(long) big_is_small;

	if(!mt_appl_getinfo(10,&i,NULL,NULL,NULL,&global) || (i & 0x00ff)<SHW_THR_CREATE)
	{
		thread_ret=(int) thread(werte);
	}
	else
	{
		thread_id_inhalt=mt_shel_write(SHW_THR_CREATE,1,0,(char *) &thi,(char *)&werte,&global);
		if(thread_id_inhalt==0)
		{
			thread_ret=(int) thread(werte);
		}
		else
		{
			master_event(0);
		}
	}

	if(thread_id_inhalt==0)
	{
		if(thread_ret==3)
		{
			datei=malloc(strlen(pfad)+strlen(dta->d_fname)+1);	
			if(datei)
			{
				strcpy(datei,pfad);
				strcat(datei,dta->d_fname);
	
				thread_ret=handle_error(datei,1);
	
				free(datei);
			}
			else
			{
				thread_ret=handle_error(dta->d_fname,1);
			}
		}
		if(thread_ret==4)
		{
			datei=malloc(strlen(pfad)+strlen(dta->d_fname)+1);	
			if(datei)
			{
				strcpy(datei,pfad);
				strcat(datei,dta->d_fname);
	
				thread_ret=handle_error(datei,2);
	
				free(datei);
			}
			else
			{
				thread_ret=handle_error(dta->d_fname,2);
			}
		}

		return thread_ret;
	}

	return 0;
}

long cdecl thread(long *par)
{
	FILE *fp;
	char lmask[103];
	char *buffer;
	char ersatz='\1';
	unsigned long l;
	int ret;
	char *datei;

	char *maske;
	char *pfad;
	DTA *dta;
	int big_is_small;

	maske=(char *) par[0];
	pfad=(char *) par[1];
	dta=(DTA *) par[2];
	big_is_small=(int) par[3];

	if(dta->d_length==0l)
	{	/* leere Datei */
		ret=0;

		while(maske[ret])
		{
			if(maske[ret++]!='*')
				return 1;
		}
		return 2;
	}

	lmask[0]='*';
	lmask[1]='\0';
	strcat(lmask,maske);
	lmask[strlen(lmask)+1]='\0';
	lmask[strlen(lmask)]='*';

	l=0;
	while(lmask[l])
	{
		if(lmask[l]==ersatz)
		{
			ersatz++;
			l=-1;
		}

		l++;
	}

	datei=malloc(strlen(pfad)+strlen(dta->d_fname)+1);	
	if(datei)
	{
		strcpy(datei,pfad);
		strcat(datei,dta->d_fname);

		fp=fopen(datei,"rb");
		if(fp)
		{
			buffer=malloc(dta->d_length+1);
	
			if(buffer)
			{
				buffer[dta->d_length]='\0';
	
				if(fread(buffer,dta->d_length,1,fp)==1)
				{
					l=0;
					while(l<dta->d_length)
					{
						if(buffer[l]=='\0')
							buffer[l]=ersatz;
						l++;
					}
	
					ret=wildchar(lmask,buffer,big_is_small)+1;

					free(buffer);
					fclose(fp);
				}
				else
				{
					free(buffer);
					fclose(fp);
					ret=4;
				}
			}
			else
			{
				fclose(fp);
	
				ret=3;
			}
		}
		else
			ret=4;

		free(datei);
	}
	else
		ret=3;

	return ret;
}
