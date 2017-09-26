#include <ec_gem.h>

#include "io.h"
#include "ioglobal.h"

#include "online.h"

WINDOW wpmlist;
DINFO  dpmlist;
OBJECT *opmlist;

/* Toleranz fÅr Wiedererkennung der Mail */
#define TOLERANZ_BYTES 15

int	sock;

extern void net_alert(int code);
void dial_pm_list(int ob);
int get_top(long ix);

void draw_pmlframe(void)
{
	w_objc_draw(&wpmlist, PMLFRAME, 8, sx,sy,sw,sh);
	w_objc_draw(&wpmlist, PMLBAR, 8, sx,sy,sw,sh);
	w_objc_draw(&wpmlist, PMLTITEL, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void pml_init_inf(void)
{
	minf.offset=minf.mem_old_pms;
}

/* -------------------------------------- */

void pml_get_toggle(long a)
{
	if(minf.pms[a].flags & PMF_GET)
		minf.pms[a].flags &= (~PMF_GET);
	else
		minf.pms[a].flags |= PMF_GET;
}
/* -------------------------------------- */
void pml_del_toggle(long a)
{
	if(minf.pms[a].flags & PMF_DEL)
		minf.pms[a].flags &= (~PMF_DEL);
	else
		minf.pms[a].flags |= PMF_DEL;
}

/* -------------------------------------- */

void pml_get_info(long a)
{
	static char path[256];
	long	fhl;
	int		fh;
	
	if(minf.pms[a].head[0]==0)
	{
		graf_mouse(BUSYBEE, NULL);
		if((fh=get_top(a))<0) {graf_mouse(ARROW, NULL);net_alert(fh); return;}
		graf_mouse(ARROW, NULL);
	}
	
	if(minf.pms[a].head[0]==0) return;
	
	strcpy(path, db_path);
	strcat(path, "\\TMP\\");
	strcat(path, get_free_file(path));
	strcat(path, ".TXT");
	fhl=Fcreate(path, 0);
	if(fhl < 0) {gemdos_alert(gettext(CREATEERR), fhl); return;}
	fh=(int)fhl;
	Fwrite(fh, strlen(minf.pms[a].head), minf.pms[a].head);
	Fclose(fh);
	pbuf[0]=AV_STARTPROG;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	*((char**)(&pbuf[3]))=path;
	pbuf[5]=pbuf[6]=0;
	appl_write(0, 16, pbuf);	
}

/* -------------------------------------- */

void pml_set_dial(void)
{
	long	a;
	long	t, l;
	
	/* Slider setzen */

	/* Ggf. Listenoffset korrigieren */
	l=(I1PMLLAST-I1PML1)/4+1;	/* Sichtbare Zeilen */
	if(minf.offset+l > minf.total_pms)	minf.offset=minf.total_pms-l;
	if(minf.offset < 0) 	minf.offset=0;
	
	a=minf.offset;
	
	if(minf.total_pms <= l)
	{
		opmlist[PMLSLIDE].ob_y=0;
		opmlist[PMLSLIDE].ob_height=opmlist[PMLBAR].ob_height;
		goto _pml_text;
	}
	
	/* Slidergrîûe */
	t=(long)minf.total_pms*(long)(opmlist[PML1].ob_height);	/* Gesamte Liste in Pixeln */
	opmlist[PMLSLIDE].ob_height=(int)( ((long)opmlist[PMLBAR].ob_height*(long)(l*(long)opmlist[PML1].ob_height))/t);
	if(opmlist[PMLSLIDE].ob_height < opmlist[PMLSLIDE].ob_width)
		opmlist[PMLSLIDE].ob_height=opmlist[PMLSLIDE].ob_width;
	
	/* Sliderpos. */
	opmlist[PMLSLIDE].ob_y=(int)(
				((long)(opmlist[PMLBAR].ob_height-opmlist[PMLSLIDE].ob_height)*
				 (long)(minf.offset)) 
				 / 
				 (minf.total_pms-l));

_pml_text:
	/* Strings setzen */
	while((a < minf.total_pms) && (a-minf.offset <= (I1PMLLAST-I1PML1)/4))
	{
		if(minf.pms[a].size > 1024)
		{
			ltoa(minf.pms[a].size/1024, opmlist[PML1+(a-minf.offset)*4].ob_spec.tedinfo->te_ptext, 10);
			strcat(opmlist[PML1+(a-minf.offset)*4].ob_spec.tedinfo->te_ptext, " Kbyte");
		}
		else
		{
			ltoa(minf.pms[a].size, opmlist[PML1+(a-minf.offset)*4].ob_spec.tedinfo->te_ptext, 10);
			strcat(opmlist[PML1+(a-minf.offset)*4].ob_spec.tedinfo->te_ptext, " Byte");
		}

		opmlist[I1PML1+(a-minf.offset)*4].ob_flags &= (~HIDETREE);
		opmlist[I2PML1+(a-minf.offset)*4].ob_flags &= (~HIDETREE);
		opmlist[PMLINF1+(a-minf.offset)*4].ob_flags &= (~HIDETREE);
		if(sw_mode)
		{
			opmlist[I1PML1+(a-minf.offset)*4].ob_type=G_ICON;
			if(minf.pms[a].flags & PMF_GET)
				opmlist[I1PML1+(a-minf.offset)*4].ob_spec.iconblk=ovorl[GRP_SW_SEL].ob_spec.iconblk;
			else
				opmlist[I1PML1+(a-minf.offset)*4].ob_spec.iconblk=ovorl[GRP_SW_UNSEL].ob_spec.iconblk;

			opmlist[I2PML1+(a-minf.offset)*4].ob_type=G_ICON;
			if(minf.pms[a].flags & PMF_DEL)
				opmlist[I2PML1+(a-minf.offset)*4].ob_spec.iconblk=ovorl[GRP_SW_SEL].ob_spec.iconblk;
			else
				opmlist[I2PML1+(a-minf.offset)*4].ob_spec.iconblk=ovorl[GRP_SW_UNSEL].ob_spec.iconblk;
		}
		else
		{
			opmlist[I1PML1+(a-minf.offset)*4].ob_spec.iconblk=ovorl[GRP_ABO].ob_spec.iconblk;
			if(minf.pms[a].flags & PMF_GET)
				opmlist[I1PML1+(a-minf.offset)*4].ob_state |= SELECTED;
			else
				opmlist[I1PML1+(a-minf.offset)*4].ob_state &= (~SELECTED);
	
			opmlist[I2PML1+(a-minf.offset)*4].ob_spec.iconblk=ovorl[GRP_ABO_RED].ob_spec.iconblk;
			if(minf.pms[a].flags & PMF_DEL)
				opmlist[I2PML1+(a-minf.offset)*4].ob_state |= SELECTED;
			else
				opmlist[I2PML1+(a-minf.offset)*4].ob_state &= (~SELECTED);
		}
		++a;
	}

	while(a-minf.offset <= (I1PMLLAST-I1PML1)/4)
	{
		opmlist[PML1+(a-minf.offset)*4].ob_spec.tedinfo->te_ptext[0]=0;
		opmlist[I1PML1+(a-minf.offset)*4].ob_flags |= HIDETREE;
		opmlist[I2PML1+(a-minf.offset)*4].ob_flags |= HIDETREE;
		opmlist[PMLINF1+(a-minf.offset)*4].ob_flags |= HIDETREE;
		++a;
	}
}

/* -------------------------------------- */

void	pm_list_dial(void)
{
	int dum;

	rsrc_gaddr(0, PM_LIST, &opmlist);
	opmlist[PMLOK].ob_state &= (~SELECTED);
	dpmlist.tree=opmlist;
	dpmlist.support=0;
	dpmlist.dservice=dial_pm_list;
	dpmlist.osmax=0;
	dpmlist.odmax=8;
	w_dinit(&wpmlist);

	pml_init_inf();
	pml_set_dial();
	wpmlist.dinfo=&dpmlist;
	w_dial(&wpmlist, D_CENTER);
	/*wpmlist.name="";
	w_set(&wpmlist, NAME);*/
	w_open(&wpmlist);
	
	w_modal(&wpmlist, MODAL_ON);
	while(wpmlist.open) 
		w_devent(&dum,&dum,&dum,&dum,&dum);
	w_kill(&wpmlist);
	w_modal(&wonline, MODAL_ON);
}

/* -------------------------------------- */

void slide_pmlist(void)
{
	int		mb, my, oy=-1, miny, maxy, offy, dum;
	long	l, off;

	maxy=opmlist[PMLBAR].ob_height-opmlist[PMLSLIDE].ob_height;
	if(maxy==0) return;
	
	wind_update(BEG_MCTRL);
	graf_mouse(FLAT_HAND, NULL);

	objc_offset(opmlist, PMLSLIDE, &dum, &offy);
	graf_mkstate(&dum, &my, &dum, &dum);
	offy=my-offy;
	objc_offset(opmlist, PMLBAR, &dum, &miny);
	
	do
	{
		graf_mkstate(&dum, &my, &mb, &dum);
		my-=miny+offy;
		if(my < 0) my=0;
		if(my > maxy) my=maxy;
		if(my==oy) continue;	
		
		/* Neuen Offset ausrechnen */
		l=(I1PMLLAST-I1PML1)/4+1;		/* Sichtbare Zeilen */
		off=(int)(((long)my*(minf.total_pms-l))/(long)maxy);
		if(off!=minf.offset)
		{
			minf.offset=off;
			pml_set_dial();
			draw_pmlframe();
		}	
	}while(mb & 3);
	
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
}

/* -------------------------------------- */

void dial_pm_list(int ob)
{
	long	a;
	int		b;
	int		dum, my, oy;
	
	switch(ob)
	{
		case PMLOK:
			w_close(&wpmlist);
		break;
		
		case PMLUP:
			a=minf.offset-1;
		goto _new_pml_offset;
		case PMLDOWN:
			a=minf.offset+1;
		goto _new_pml_offset;
		case PMLSLIDE:
			slide_pmlist();
		break;
		case PMLBAR:
			graf_mkstate(&dum, &my, &dum, &dum);
			objc_offset(opmlist, PMLSLIDE, &dum, &oy);
			if(my < oy)
				a=minf.offset-((I1PMLLAST-I1PML1)/4+1);
			else
				a=minf.offset+((I1PMLLAST-I1PML1)/4+1);
		goto _new_pml_offset;
	}

	if((ob >= I1PML1)&&(ob <= PMLINFLAST))
	{
		a=ob-I1PML1; 
		b=(int)(a & 3);
		a/=4; a+=minf.offset;
		if(a >= minf.total_pms) return;
		switch(b)
		{
			case 0:	/* Donwload */
				pml_get_toggle(a);
				pml_set_dial();
				w_objc_draw(&wpmlist, ob, 8, sx,sy,sw,sh);
			break;
			case 1:	/* Delete */
				pml_del_toggle(a);
				pml_set_dial();
				w_objc_draw(&wpmlist, ob, 8, sx,sy,sw,sh);
			break;
			case 2:	/* Grîûe -> nix */
			break;
			case 3:
				pml_get_info(a);
			break;
		}
	}
	return;
	
_new_pml_offset:
	if(a+(I1PMLLAST-I1PML1)/4+1 > minf.total_pms)
		a=minf.total_pms-((I1PMLLAST-I1PML1)/4+1);
	if(a < 0) a=0;
	if(a==minf.offset) return;
	minf.offset=a;
	pml_set_dial();
	draw_pmlframe();
}

/* -------------------------------------- */
/* -------------------------------------- */

int equal_pm(long a, long b, long toleranz)
{/* a <= b <= a+toleranz 
		return: 1 wenn erfÅllt, sonst 0
		Hintergrund: Nach dem ersten Download speichern
		einige Server im Header eine zusÑtzliche Zeile
		("Status: RO\r\n"), so daû die Mail z.B. um 12
		Byte wÑchst. Um die Mail beim nÑchsten Download
		als bekannt einstufen zu kînnen, muû eine Toleranz
		beim Grîûenvergleich eingefÅhrt werden.
*/
	if((a <= b) && (b <= a+toleranz)) return(1);
	return(0);
}

int	store_pm_info(char *c)
{
	char	*x;
	PMAIL	*pmn;
	int		stored_flags=-1, fh;
	long	stored_size=-1, fhl;
	char path[256];
	ulong	a;
	
	if(minf.old_pms) /* Wird runtergezÑhlt, s.u. */
	{/* PrÅfen, ob zu dieser Nachricht noch Infos gespeichert sind */
		strcpy(path, db_path);
		strcat(path, "\\PM.IDX");	
		fhl=Fopen(path, FO_READ);
		if(fhl > -1)
		{
			fh=(int)fhl;
			fhl=4+6*(minf.total_pms);	/* Info-Position. total_pms wird hochgezÑhlt, solange old_pms runtergezÑhlt wird */
			if(Fseek(fhl, fh, 0) == fhl)
			{
				Fread(fh, 2, &stored_flags);
				Fread(fh, 4, &stored_size);
			}
			Fclose(fh);
		}
	}

	x=strchr(c, ' ');
	if(x==NULL) x=strchr(c, 9);
	if(x==NULL) x=c;
	if(atol(x)==0) return(1);	/* Vermutlich Leerzeile */
	
	pmn=malloc(sizeof(PMAIL)*(minf.total_pms+1));
	if(pmn==NULL){form_alert(1, gettext(NOMEM)); return(0);}
	a=0;
	while(a < minf.total_pms)
	{	pmn[a]=minf.pms[a]; ++a;}
	if(minf.pms) free(minf.pms);
	minf.pms=pmn;
	
	++minf.total_pms;

	pmn[a].size=atol(x);
	pmn[a].head[0]=0;
	
	pmn[a].flags=0;
	if(minf.old_pms)
	{
		--minf.old_pms;
		if((stored_size==-1) || (equal_pm(stored_size, pmn[a].size, TOLERANZ_BYTES)))
		{/* Nachricht ist bereits bekannt oder nicht in INF-Datei (altes Format), dann wird gelesen angenommen */
			if((stored_flags==-1) || (stored_flags & PMF_GOT))
			{
				pmn[a].flags|=PMF_GOT;
				if(ios.server_del)
					pmn[a].flags|=PMF_DEL;
			}
			else /* Infos vorhanden */
			{
				if(!(stored_flags & PMF_GOT))
					pmn[a].flags|=PMF_GET;
				if(ios.server_del)
					pmn[a].flags|=PMF_DEL;
			}
		}
		else
		{/* Infos zwar gespeichert, passen aber nicht auf Nachricht,
				diese wird daher als neue Nachricht gewertet */
			goto _new_pm;
		}
	}
	else
	{
_new_pm:
		++minf.new_pms;
		pmn[a].flags|=PMF_GET;
		if(ios.server_del)
		{
			pmn[a].flags|=PMF_DEL;
		}
	}
	return(1);
}

/* -------------------------------------- */

int get_pm_list(int s)
{/* s=socket, Return 0=-ERR, 1=+OK, <0=Error */
 /* Receives until CR/LF.CR/LF is received */
 	time_t	now;
	int			ret, a;
	long		line_pos=0;
	char		buf[501], act_line[501];
	fd_set	mask;
	timeval	tout;

	now=time(NULL);

	do
	{
		FD_ZERO(&mask);
		FD_SET(s, &mask);
		tout.tv_sec=0;
		tout.tv_usec=0;
		
		ret=select(s+1, &mask, NULL, NULL, &tout);
		if(ret==0)
		{
			ret=(int)sread(s, buf, 500);
			if(ret < 0)	return(ret);
			/* Maybe a segment just arrived between select and sread */
			if(ret > 0) goto _get_pm_incoming;
			
			if(time(NULL)-now < TO_REPLY_SEK)
			{
				evnt_timer(100,0);
				continue;
			}
			return(ETIMEDOUT);
		}

		/* Incoming data, reset timeout */
		
		ret=(int)sread(s, buf, 500);
		if(ret < 0)	return(ret); /* Foreign closed, error */
		
_get_pm_incoming:
		now=time(NULL);

		if(ret==0)	continue;	/* Empty reply, continue waiting */

		a=0;
		while(a < ret) 
		{
			act_line[line_pos]=buf[a++];
			if((act_line[line_pos]==13) || (act_line[line_pos]==10))
			{/* Line ends */
				act_line[line_pos]=0;
				if(line_pos) {Flog(act_line);Flog("\r\n");}
				line_pos=0;
				while((act_line[line_pos]==10)||(act_line[line_pos]==13))++line_pos;
				if(act_line[line_pos]=='-')	/* Reply-Line, ERR */
				{
					return(0);
				}
				if(act_line[line_pos]=='+') /* Reply-Line, OK */
				{
					line_pos=0; continue;
				}
				if((act_line[line_pos]=='.')&&(act_line[line_pos+1]==0))
				{/* Done */
					return(1);
				}
				if(store_pm_info(&(act_line[line_pos]))==0)
				{
					return(0);
				}
				line_pos=0;
			}
			else
				++line_pos;
		}
	}while(1);
}

/* -------------------------------------- */

int get_top(long ix)
{	/* Receives until CR/LF.CR/LF is received */
	/* Copies max. 2047 Bytes to minf.pms[ix].head */
	
 	time_t	now;
	int			ret, a, res_check=0;
	long		line_pos=0, copied=0;
	char		buf[501], act_line[501];
	fd_set	mask;
	timeval	tout;

	strcpy(buf, "TOP ");
	ltoa(ix+1, &(buf[4]), 10);
	strcat(buf, " 10");
	send_string(sock, buf, 1);

	now=time(NULL);

	do
	{
		FD_ZERO(&mask);
		FD_SET(sock, &mask);
		tout.tv_sec=0;
		tout.tv_usec=0;
		
		ret=select(sock+1, &mask, NULL, NULL, &tout);
		if(ret==0)
		{
			ret=(int)sread(sock, buf, 500);
			if(ret < 0)	return(ret);
			/* Maybe a segment just arrived between select and sread */
			if(ret > 0) goto _get_top_incoming;
			
			if(time(NULL)-now < TO_REPLY_SEK)
			{
				evnt_timer(100,0);
				continue;
			}
			return(ETIMEDOUT);
		}

		/* Incoming data, reset timeout */
		
		ret=(int)sread(sock, buf, 500);
		if(ret < 0)	return(ret); /* Foreign closed, error */
		
_get_top_incoming:
		now=time(NULL);

		if(ret==0)	continue;	/* Empty reply, continue waiting */

		a=0;
		while(a < ret) 
		{
			if(copied < 2047)
			{
				minf.pms[ix].head[copied++]=buf[a];
				minf.pms[ix].head[copied]=0;
			}
			act_line[line_pos]=buf[a++];
			if((act_line[line_pos]==13) || (act_line[line_pos]==10))
			{/* Line ends */
				act_line[line_pos]=0;
				Flog(act_line); Flog("\r\n");
				line_pos=0;
				while((act_line[line_pos]==10)||(act_line[line_pos]==13))++line_pos;
				if((!res_check) && (act_line[line_pos]=='-'))	/* Reply-Line, ERR */
				{
					return(0);
				}
				if((!res_check) && (act_line[line_pos]=='+')) /* Reply-Line, OK */
				{
					res_check=1;
					line_pos=0; continue;
				}
				if((act_line[line_pos]=='.')&&(act_line[line_pos+1]==0))
				{/* Done */
					return(1);
				}
				line_pos=0;
			}
			else
			{
				if((act_line[line_pos]!='.') && (line_pos > 498))
					line_pos=0;	/* Flush buffer */
				else
					++line_pos;
			}
		}
	}while(1);
}

/* -------------------------------------- */

int user_pm_list(int s)
{/* Return: 0=Nothing to do, 1=GETs or DELs */
	int dialog=0, action=0, f_del, ret;
	long	a;

	sock=s;
	
	if((ios.pllrequest)||(minf.always_show))
	{		
		if(stop_download_filter())
		{
			set_act("Filter check...");
			a=0;
			while(a < minf.total_pms)
			{
				if(minf.pms[a].flags & PMF_GET)
				{
					graf_mouse(BUSYBEE, NULL);
					if((ret=get_top(a))<0) {graf_mouse(ARROW, NULL);net_alert(ret); return(0);}
					if(check_download_filter(minf.pms[a].head, &f_del))
					{
						minf.pms[a].flags &= (~PMF_GET);
						if(f_del) minf.pms[a].flags |= PMF_DEL;
					}
					graf_mouse(ARROW, NULL);
				}
				++a;
			}
			set_act("");
		}

		a=0;
		while(a < minf.total_pms)
		{
			if((minf.pms[a].flags & PMF_GET) && (minf.pms[a].size > (long)ios.pllsize*1024))
				dialog=1;
			++a;
		}
	
		if(dialog || (minf.always_show))	pm_list_dial();
	}
	
	a=0;
	while(a < minf.total_pms)
	{
		if(minf.pms[a].flags) action=1;
		++a;
	}
	return(action);
}