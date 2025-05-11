/* Verwalten von DialogbÑumen in Fenstern */
/* Version 1.0 */
/* Erweiterungen in Form von Tastaturshortcuts usw. sind nicht direkt
   vorgesehen, die Abarbeitung erfolgt mittels Let 'em fly */

/*
   Nutzung der Routinen in eigenen Programmen uneingeschrÑnkt erlaubt,
   Erweiterungen erwÅnscht, ich mîchte allerdings in Form von Quelltext
   oder zur Not Objektfiles diese auch nutzten kînnen.

   von J. Starzynski und T. Baade
*/

#include <tos.h>

#include "ltmf_lib.h"
#include "ltmf_lib.c"

#include "winddial.h"

/* Fenster wird Titelzeile, Move-Balken und Schlieûknopf haben */
#define PROPS (NAME|MOVER|CLOSER)

/*	initialisieren und zeichnen des Fensterrahmens */
/*	erste 4 Parameter: wie form_center
	wind :	Zeiger auf zu bearbeitende Window-Struktur
	title:  Titel des Fensters
	return:	im Fehlerfall !=0 , sonst 0
*/
int form_wind(OBJECT *ptr,int *center_x,int *center_y,
				int *center_w,int *center_h,wi_data *wind,char *title)
{
/* Desktop-Koordinaten */
	int x_desk,y_desk,w_desk,h_desk;
/* Gesamtgrîûe des Windows, Fehlerflag */
	int x,y,w,h,error=0;
/* Keine Ausgaben erlauben */
	wind_update(BEG_UPDATE);
/* Fensterstruktur initialisieren */
/* 1.: mit Object-Baumadresse */
	wind->obj=ptr;
/* 2.: gemalt-flag null setzen */
	wind->flags.drawed=0;
/* 3.: nur eigenes Fenster toppen */
	wind->flags.auto_top=0;
/* 4.: let 'em fly nutzen */
	wind->flags.ltmf=1;
/* 5.: Åbergebene Clipp-Koordinaten in Struktur Åbernehmen */
	wind->m=center_x;
	wind->n=center_y;
	wind->o=center_w;
	wind->p=center_h;
/* Desktop-Grîûe holen */
	wind_get(0,WF_WORKXYWH,&x_desk,&y_desk,&w_desk,&h_desk);
/* Window kreieren */
	wind->wi_handle=wind_create(PROPS,x_desk,y_desk,w_desk,h_desk);
/* Fehler? */
	if(wind->wi_handle<0)
	{
		error=-1;
	}
	else
	{
/* Gesamtgrîûe des Fensters berechnen */
		wind_calc(WC_BORDER,PROPS,
				  *center_x,*center_y,*center_w,*center_h,&x,&y,&w,&h);
/* Test, ob Fenste Åber linken oder oberen Deskrand hinausgeht */
/* wenn ja, Korrektur der Koordinaten */
		if(x<x_desk)
		{
			int xdiff=x_desk-x;
			x=xdiff;
			ptr->ob_x+=xdiff;
			*center_x+=xdiff;
		}
		if(y<y_desk)
		{
			int ydiff=y_desk-y;
			y=ydiff;
			ptr->ob_y+=ydiff;
			*center_y+=ydiff;
		}
/* Titel eintragen */
		wind_set(wind->wi_handle,WF_NAME,title);
/* Fenster îffnen */
		if(!wind_open(wind->wi_handle,x,y,w,h)) error=-1;
	}
/* fertig gemalt, der Rahmen steht */
	wind_update(END_UPDATE);
/* Fehler aufgetreten */
	if(error)
	{
/* Handle zur Kennzeichnung negativ */
		wind->wi_handle=-1;
/* normalen Dialog ohne Fenster vorbereiten */
		wind_update(BEG_MCTRL);
		form_center(ptr,center_x,center_y,center_w,center_h);
		form_dial(FMD_START,0,0,0,0,*center_x,*center_y,*center_w,*center_h);
	}
	return error;
}

/* Dialog beenden, Fenster schlieûen */
int form_wclose(wi_data *wind)
{
/* es war kein Fenster offen */
	if(wind->wi_handle<0)
	{
/* Bildschirm wieder freigeben */
		wind_update(END_MCTRL);
/* aktuelle Koordinaten der Box holen (Let 'em Fly!) */
		form_center(wind->obj,wind->m,wind->n,wind->o,wind->p);
		form_dial(FMD_FINISH,0,0,0,0,*wind->m,*wind->n,*wind->o,*wind->p);
		return -1;
	}
/* Fenster schlieûen und freigeben */
	wind_close(wind->wi_handle);
	wind_delete(wind->wi_handle);
	wind->wi_handle=-1;
	return 0;
}

/* Fenster-Redraw in den angegebenen Koordinaten */
void wi_redraw(wi_data *wind,int *buf)
{
	int x,y,w,h,xr=buf[4],yr=buf[5],xm,ym;

/* gÑ. T34 */
	if(wind->wi_handle != buf[3])
		return;
	wind_update(BEG_UPDATE);
/*	breite+hîhe in koordinaten umrechnen */
	xm=xr+buf[6];
	ym=yr+buf[7];
/* Begin der Rechteckliste */
	wind_get(wind->wi_handle,WF_FIRSTXYWH,&x,&y,&w,&h);
/* noch was zu tun */
	while(w&&h)
	{
/* rc_intersect fÅr aes */
			w+=x;
			h+=y;
			if(xr>x) x=xr;
			if(yr>y) y=yr;
			if(xm>w) w-=x;
			else w=xm-x;
			if(ym>h) h-=y;
			else h=ym-y;
/* und malen */
			if(h>0&&w>0)
			{
/*				vs_clip(int handle, int clip_flag, int *pxyarray ); */
				objc_draw(wind->obj, 0, MAX_DEPTH, x, y, w, h);
			}
/* nÑchste Rechteck */
		wind_get(wind->wi_handle,WF_NEXTXYWH,&x,&y,&w,&h);
	}
	wind_update(END_UPDATE);
}

/* ab jetzt bis zu wind_do() Original-Profibuch */
#define FMD_BACKWARD -1
#define FMD_FORWARD  -2
#define FMD_DFLT     -3

#define TRUE 1

/* OBJECT best. Typs suchen */
static int find_object(OBJECT *tree,int start_obj,int which)
{
	int object,flag,theflag,inc;
	object=0;
	flag=EDITABLE;
	inc=1;
	switch(which)
	{
		case FMD_BACKWARD:
			inc=-1;
		case FMD_FORWARD:
			object=start_obj+inc;
			break;
		case FMD_DFLT:
			flag=DEFAULT;
			break;
	}
	while(object>=0)
	{
		theflag=tree[object].ob_flags;
		if(theflag&flag) return object;
		if(theflag&LASTOB) object=-1;
		else object+=inc;
	}
	return start_obj;
}

static int ini_field(OBJECT *tree,int start_field)
{
	if(start_field==0) start_field=find_object(tree,0,FMD_FORWARD);
	return start_field;
}

/* stellt Beziehung zwischen Mausclick und Cursor fest (T34) */
/* Parameter:
   obj        : Baum
   No         : editierbares Object
   mx         : x - Position des Mausclicks
   return     : Cursorposition
*/
static int find_position(OBJECT *obj, int No, int mx)
{
	int te_x= 0;	/* absolute Koordinaten des Textes */
	int P_text= 0; /* Buchstaben im Text */
	int P_mask= 0; /* Buchstaben in der Maske */
	int size;		/* Buchstabenbreite */
	int i, Child;

	size= obj[No].ob_spec.tedinfo->te_font==3 ? 8 : 6;	/* 6 od. 8 Punkt Font */
	te_x= obj[No].ob_spec.tedinfo->te_just
		? obj[No].ob_width - (obj[No].ob_spec.tedinfo->te_tmplen-1) * size : 0;
	if(obj[No].ob_spec.tedinfo->te_just==2)
		te_x/= 2;
	te_x+= obj[No].ob_x + size/2;		/* Start der Maske ohne Parent's */
/* Parent suchen */
	Child= No;
	for(i= No-1; 0<=i; i--)
	{
		if((obj[i].ob_head <= Child) && (Child <= obj[i].ob_tail))
		{
			Child= i;		/* Parent found */
			te_x+= obj[i].ob_x;
		}
	}
	while((te_x < mx) && (P_mask < obj[No].ob_spec.tedinfo->te_tmplen - 1))
	{
		if(obj[No].ob_spec.tedinfo->te_ptmplt[P_mask++] == '_')
			P_text++;
		te_x+= size;
	}
	return P_text;
}

/* form_do() in Fenstern: wind_do() */
/* Parameter:
   wind		  : von form_wind() bearbeitetes wind-Objekt
   start_field: Objektnummer, in dem sich der Textcursor zuerst
   				befinden soll
   buf[8]     : Messagepuffer
   return     : Nummer des angesprochenen Objektes oder
   				-1 Nach Eintreffen einer Message
*/

/* aus dem Profibuch (form_do()), erweitert um Message-Handling */
int wind_do(wi_data *wind,int start_field,int *buf)
{
	OBJECT *tree=wind->obj;
	int edit_object,next_object,which,cont;
	int idx,mx= 0,my,mb,ks,kr,br,show_edit,first= 1;
/* wenn kein Fenster offen: normales form_do()*/
	if(wind->wi_handle<0) return form_do(wind->obj,start_field);
/* Top Window holen */
	wind_get(wind->wi_handle,WF_TOP,&show_edit);
	show_edit=show_edit==wind->wi_handle?-1:0;
/* Let 'em fly initialisieren */
	if(show_edit&&wind->flags.ltmf) init_keys(tree);
	next_object=ini_field(tree,start_field);
	edit_object=0;

	cont=TRUE;

	while(cont)
	{
		if(next_object!=0)
		{
			edit_object=next_object;
			next_object=0;
			if(show_edit)
			{
				/* Buchstabe, vor den der Cursor kommt */
				char	letter, *letterptr;

				if(!first)
				{
					letter= *(letterptr=
						tree[edit_object].ob_spec.tedinfo->te_ptext
							+ find_position(tree, edit_object, mx));
					*letterptr= '\000';
					objc_edit(tree,edit_object,0,&idx,ED_INIT);
					*letterptr= letter;
				} else
					objc_edit(tree,edit_object,0,&idx,ED_INIT);
				first= 0;
			}
		}

		which=evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG,0x02,0x01,
			0x01,0,0,0,0,0,0,0,0,0,0,buf,
			0,0,&mx,&my,&mb,&ks,&kr,&br);
/* interssierende énderung: Message ist angekommen */
		if(which&MU_MESAG)
		{
/* Cursor ausschalten */
			wind_get(wind->wi_handle,WF_TOP,&show_edit);
			show_edit=show_edit==wind->wi_handle?-1:0;
/* Cursor aus */
			if((edit_object!=0) && show_edit)
				objc_edit(tree,edit_object,0,&idx,ED_END);
			switch(buf[0])
			{
/* Fenster wurde bewegt */
			case WM_MOVED:
			{
/* alte Koordinaten zur Offsetberechnung speichern */
				int x=*wind->m,y=*wind->n;
/* Rahmen verschieben */
				wind_set(buf[3],WF_CURRXYWH,buf[4],buf[5],buf[6],buf[7]);
/* Holen, bzw. Errechnen der neuen Koordinaten der ArbeitsflÑche
   und des Object-Baumes */
				wind_get(buf[3],WF_WORKXYWH,wind->m,wind->n,wind->o,wind->p);
				tree->ob_x+=*wind->m-x;
				tree->ob_y+=*wind->n-y;
				break;
			}
			case WM_REDRAW:
/* Redraw nîtig */
					if(wind->flags.drawed) wi_redraw(wind,buf);
					wind->flags.drawed=1;
				break;
/* falls Accessory: beim Anklicken des Slots Fenster toppen */
			case AC_OPEN:
				wind_set(wind->wi_handle,WF_TOP,wind->wi_handle);
				break;
/* bei dieser Message sowieso */
			case WM_TOPPED:
				if(wind->flags.auto_top||wind->wi_handle==buf[3])
					wind_set(buf[3],WF_TOP,buf[3]);
				break;
			}
/* und zurÅck */
			return -1;
		}
		if(which&MU_KEYBD)
		{
/* in Let 'em fly nach Taste suchen */
			int kb_obj=0;
			if(wind->flags.ltmf)
			{
				kb_obj=lookup_key(kr, ks);
				if(kb_obj)
					cont = form_button(tree, kb_obj, 0x01, &next_object);
			}
			if(!kb_obj)
			{
				cont=form_keybd(tree,edit_object,next_object,kr,&next_object,
								&kr);
				if(kr)	objc_edit(tree,edit_object,kr,&idx,ED_CHAR);
			}
		}
		if(which&MU_BUTTON)
		{
			next_object=objc_find(tree,0,MAX_DEPTH,mx,my);

			if(next_object==-1)
			{
				Bconout(2,7);
				next_object=0;
			}
			else
				cont=form_button(tree,next_object,br,&next_object);
		}
		if(!cont||(next_object!=0))
		{
			if(show_edit) objc_edit(tree,edit_object,0,&idx,ED_END);
		}
	}
	return next_object;
}

/* das war's schon, kaum zu glauben, das ich dafÅr 3 Tage rumprobiert habe */
