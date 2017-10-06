/*----------------------------------------------------------------*/
/*                       Window-Bibliothek                        */
/*                                                                */
/*                   Autor: Andreas Loetscher                     */
/*                (c) 1992 Maxon Computer GmbH                    */
/*----------------------------------------------------------------*/

#include <string.h>
#include <aes.h>
#include <vdi.h>
#include "GEM_INEX.H"
#include "windlib.h"

#define Min(a,b) (a < b) ? a : b
#define Max(a,b) (a > b) ? a : b

WIND_DATA windows[40];

/*-----------------------------------*/
/* erweiterte open_window()-Funktion */
/*-----------------------------------*/
int open_window(char *w_name, char *w_info,	/* Ptr auf Namensstring */
				void (*redraw)(int work[]), /* Ptr auf Redraw-Funktion */
				int was, /* Liste der Elemente */
				int algn, /* align-Wert */
				int snp, /* snappen? (TRUE/FALSE) */
				int s_x, int s_y, /* Scrollwerte X / Y */
				int doc_l,int doc_w, /* Dokumentsl„nge / -breite */
				int x1,int y1,int w1,int h1, /* Startkoordinaten */
				int mx,int my,int mw,int mh) /* Maximalkoordinaten */
{
	int w_handle;

	void clear_window(int w_hndl);
	void set_slider_size(int w_handle);
	void set_slider_pos(int w_handle);

	/* und meldet ein Fenster an */
	if(!mw && !mh)
	{
		mx = desk.g_x;
		my = desk.g_y;
		mw = desk.g_w;
		mh = desk.g_h;
	}

	w_handle = wind_create(was, mx, my, mw, mh);

	/* tr„gt wichtige Daten in Struktur ein: */
	windows[w_handle].max.g_x = mx;
	windows[w_handle].max.g_y = my;
	windows[w_handle].max.g_w = mw;
	windows[w_handle].max.g_h = mh;
	windows[w_handle].elements = was;
	windows[w_handle].align = algn;
	windows[w_handle].snap = snp;
	windows[w_handle].w_redraw = redraw;+
	windows[w_handle].scroll_x = s_x;
	windows[w_handle].scroll_y = s_y;
	windows[w_handle].doc_length = doc_l;
	windows[w_handle].doc_width = doc_w;
	windows[w_handle].doc_x = 0;
	windows[w_handle].doc_y = 0;
	strcpy(windows[w_handle].name, w_name);
	strcpy(windows[w_handle].info, w_info);
	windows[w_handle].full = ((x1 == mx) && (y1 == my) && (w1 == mw) && (h1 == mh));
	wind_calc(WC_WORK, was, x1, y1, w1, h1,
				&windows[w_handle].work.g_x, &windows[w_handle].work.g_y,
				&windows[w_handle].work.g_w, &windows[w_handle].work.g_h);

	/* Setzen des Fensternamens: */
	if(windows[w_handle].elements & NAME)
		wind_set(w_handle, 2, windows[w_handle].name, 0, 0);
	if(windows[w_handle].elements & INFO)
		wind_set(w_handle, WF_INFO, windows[w_handle].info, 0, 0);

	wind_open(w_handle, x1, y1, w1, h1);
	if((windows[w_handle].elements & VSLIDE) || (windows[w_handle].elements & HSLIDE))
	{
		set_slider_size(w_handle);
		set_slider_pos(w_handle);
	}

	/* schliežlich geben wir die Identifikationsnummer des Fensters zurck: */
	return(w_handle);
}

/*------------------------------*/
/* allgemeine Fensterverwaltung */
/*------------------------------*/
void handle_window(int buffer[])
{
	int algn;

	void clear_window(int w_hndl);
	void set_slider_size(int w_handle);
	void set_slider_pos(int w_handle);
	void w_c_work(int w_handle, int x, int y, int w, int h);
	void handle_full(int w_hndl);
	void snap(GRECT *w1,GRECT *w2);
	int align(int k,int n);
	void full_redraw(int w_handle);
	void do_redraw(int buffer[]);
	void wind_hslide(int w_handle,int newpos);
	void wind_vslide(int w_handle,int newpos);
	void scroll_wind(int w_handle,int what);

	switch(buffer[0])
	{
		case WM_ARROWED:
			scroll_wind(buffer[3], buffer[4]);
			full_redraw(buffer[3]);
		break;
		case WM_CLOSED:
        break;
		case WM_FULLED:
			handle_full(buffer[3]);
			if((windows[buffer[3]].elements & VSLIDE) || (windows[buffer[3]].elements & HSLIDE))
				set_slider_size(buffer[3]);
		break;
		case WM_HSLID:
			wind_hslide(buffer[3], buffer[4]);
			full_redraw(buffer[3]);
		break;
		case WM_NEWTOP:
			clear_window(buffer[3]);
		break;
		case WM_REDRAW:
			do_redraw(buffer);
		break;
		case WM_SIZED:
		case WM_MOVED:
			/* Wenn Fenster auf maximaler Groesse und    */
			/* Breite bzw. Hoehe vergroessert -> Abbruch */
			if(windows[buffer[3]].full && ((buffer[6] > windows[buffer[3]].max.g_w) || (buffer[7] > windows[buffer[3]].max.g_h)))
				break;

			/* Wenn kleiner Minimalgroesse vergroessern: */
/*			if(buffer[6] < 133)
				buffer[6] = 133;
			if(buffer[7] < 133)
				buffer[7] = 133; */
			/* Ausrichten der X-Koordinate, falls algn nicht gleich 0 */
			algn = windows[buffer[3]].align;
			if(algn)
				buffer[4] = align(buffer[4], algn) - 1;

			/* Falls Fenster aužerhalb Maximalkoordinaten wieder zurckschieben: */
			if(windows[buffer[3]].snap)
				snap(&windows[buffer[3]].max, (GRECT *)&buffer[4]);

			/* Mit den neu berechneten Koordinaten das Fenster neu positionieren: */
			wind_set(buffer[3], WF_CURRXYWH, buffer[4], buffer[5], buffer[6], buffer[7]);
			w_c_work(buffer[3], buffer[4], buffer[5], buffer[6], buffer[7]);
			if((windows[buffer[3]].elements & VSLIDE) || (windows[buffer[3]].elements & HSLIDE))
				set_slider_size(buffer[3]);
		break;
		case WM_TOPPED:
			wind_set(buffer[3], WF_TOP,buffer[3], 0, 0, 0);
		break;
		case WM_VSLID:
			wind_vslide(buffer[3], buffer[4]);
			full_redraw(buffer[3]);
		break;
	}
}

/*------------------------*/
/* loescht Fensterinhalt  */
/*------------------------*/
void clear_window(int w_hndl)
{
	int clip[4];

	wind_get(w_hndl, WF_WORKXYWH, &clip[0], &clip[1], &clip[2], &clip[3]);
	clip[2] += clip[0];
	clip[2]--;
	clip[3] += clip[1];
	clip[3]--;
	vsf_color(handle, 0);
	vs_clip(handle, 1, clip);
	v_bar(handle, clip);
}

/*-------------------------------*/
/* Setzen der Groesse der Slider */
/*-------------------------------*/
void set_slider_size(int w_handle)
{
	long h_size, v_size;

	h_size = (long)windows[w_handle].work.g_w * 1000L / (long)windows[w_handle].doc_width;
	if(h_size > 1000L)
		h_size = 1000L;
	v_size = (long)windows[w_handle].work.g_h * 1000L / windows[w_handle].doc_length;
	if(v_size > 1000L)
		v_size = 1000L;
	wind_set(w_handle, WF_HSLSIZE, (int)h_size, 0, 0, 0);
	wind_set(w_handle, WF_VSLSIZE, (int)v_size, 0, 0, 0);
}

/*--------------------------------*/
/* Setzen der Position der Slider */
/*--------------------------------*/
void set_slider_pos(int w_handle)
{
	long  x_pos, y_pos;

	if(windows[w_handle].doc_width <= windows[w_handle].work.g_w)
		x_pos = 0L;
	else
	  	x_pos = (long)windows[w_handle].doc_x * 1000L / ((long)windows[w_handle].doc_width - (long)windows[w_handle].work.g_w);
	if(x_pos > 1000L)
		x_pos = 1000L;
	if(windows[w_handle].doc_length <= windows[w_handle].work.g_h)
		y_pos = 0L;
	else
		y_pos = (long)windows[w_handle].doc_y * 1000L / (windows[w_handle].doc_length - (long)windows[w_handle].work.g_h);
	if(y_pos > 1000L)
		y_pos = 1000L;
	wind_set(w_handle, WF_HSLIDE, (int)x_pos, 0, 0, 0);
	wind_set(w_handle, WF_VSLIDE, (int)y_pos, 0, 0, 0);
}

/*----------------------------------------------*/
/* Berechnung der Arbeitsflaeche eines Fensters */
/*----------------------------------------------*/
void w_c_work(int w_handle, int x, int y, int w, int h)
{
	wind_calc(WC_WORK, windows[w_handle].elements, x, y, w, h,
			&windows[w_handle].work.g_x, &windows[w_handle].work.g_y,
			&windows[w_handle].work.g_w, &windows[w_handle].work.g_h);
}

/*------------------------------------*/
/* ermittelt die momentane, vorherige */
/* und maximale Groesse des Fensters  */
/*------------------------------------*/
void handle_full(int w_hndl)
{
	GRECT prev;
	GRECT curr;
	GRECT full;

	wind_get(w_hndl, WF_CURRXYWH, &curr.g_x, &curr.g_y, &curr.g_w, &curr.g_h);
	wind_get(w_hndl, WF_PREVXYWH, &prev.g_x, &prev.g_y, &prev.g_w, &prev.g_h);
	wind_get(w_hndl, WF_FULLXYWH, &full.g_x, &full.g_y, &full.g_w, &full.g_h);
	if(rc_equal(&curr, &full))
	{
		/* Window ist auf voller Gr”že, jetzt auf alte Gr”že setzen */
		wind_set(w_hndl, WF_CURRXYWH, prev.g_x, prev.g_y, prev.g_w, prev.g_h);
		windows[w_hndl].full = 0;
		w_c_work(w_hndl, prev.g_x, prev.g_y, prev.g_w, prev.g_h);
	}
	else
	{
		/* Window ist nicht auf voller Gr”že, deshalb auf volle Gr”že setzen */
		wind_set(w_hndl, WF_CURRXYWH, full.g_x, full.g_y, full.g_w, full.g_h);
		windows[w_hndl].full = 1;
		w_c_work(w_hndl, full.g_x, full.g_y, full.g_w, full.g_h);
	}
}

/*---------------------------------------------*/
/* Routine, die dafuer sorgt, dass ein Fenster */
/* vollstaendig innerhalb eines spezifizierten */
/* Rechtecks liegt (z.B. Desktop)              */
/*---------------------------------------------*/
void snap(GRECT *w1, GRECT *w2)
{
	if(w2->g_x < w1->g_x)
		w2->g_x = w1->g_x;

	if(w2->g_y < w1->g_y)
		w2->g_y = w1->g_y;

	if((w2->g_x + w2->g_w) > (w1->g_x + w1->g_w))
		w2->g_x = (w1->g_x + w1->g_w) - w2->g_w;

	if((w2->g_y + w2->g_h) > (w1->g_y + w1->g_h))
		w2->g_y = (w1->g_y + w1->g_h) - w2->g_h;

	if(w2->g_x < w1->g_x)
	{
		w2->g_x = w1->g_x;
		w2->g_w = w1->g_w;
	}

	if(w2->g_y < w1->g_y)
	{
		w2->g_y = w1->g_y;
		w2->g_h = w1->g_h;
	}
}

/*---------------------------------------*/
/* Routine, die die Koordinate k auf ein */
/* Vielfaches von v "snappt"             */
/*---------------------------------------*/
int align(int k, int n)
{
	k += (n>>1) - 1;
	k  = n * (k / n);
	return(k);
}

/*-----------------------------*/
/* zeichnet ganzes Fenster neu */
/*-----------------------------*/
void full_redraw(int w_handle)
{
	int work[4];

	graf_mouse(M_OFF, 0);
	wind_update(BEG_UPDATE);
	clear_window(w_handle);
	wind_get(w_handle, WF_WORKXYWH, &work[0], &work[1], &work[2], &work[3]);
	(*windows[w_handle].w_redraw)(work);
	wind_update(END_UPDATE);
	graf_mouse(M_ON, 0);
}

/*--------------------------------------*/
/* fhrt das Redraw eines Fensters aus */
/*--------------------------------------*/
void do_redraw(int buffer[])
{
	GRECT p;
	int work[4];
	int mx, my, mk, st;
	char mausaus = 0;

	graf_mkstate(&mx, &my, &mk, &st);
	wind_update(BEG_UPDATE);
	wind_get(buffer[3], WF_FIRSTXYWH, &p.g_x, &p.g_y, &p.g_w, &p.g_h);
	while((p.g_w > 0) && (p.g_h > 0))
	{
		work[0] = buffer[4];
		work[1] = buffer[5];
		work[2] = buffer[6];
		work[3] = buffer[7];
		if(rc_intersect(&desk, (GRECT *)&work))
			if(rc_intersect(&p, (GRECT *)&work))
			{
				work[2] += work[0];
				work[3] += work[1];
				if(!mausaus && (mx + 10 >= work[0]) && (my + 16 >= work[1]) && (mx < work[2]) && (my < work[3]))
				{
					mausaus = 1;
					graf_mouse(M_OFF, 0);
				}
				vs_clip(handle, 1, work);
				(*windows[buffer[3]].w_redraw)(work);
			}
		wind_get(buffer[3], WF_NEXTXYWH, &p.g_x, &p.g_y, &p.g_w, &p.g_h);
	}
	vs_clip(handle, 0, work);
	wind_update(END_UPDATE);
	if(mausaus)
		graf_mouse(M_ON, 0);
}

/*---------------------------------*/
/* Berechnen der Dokumentsposition */
/*---------------------------------*/
/* -> horizontal */
void wind_hslide(int w_handle, int newpos)
{
	windows[w_handle].doc_x = (int)((long)newpos * (long)(windows[w_handle].doc_width - windows[w_handle].work.g_w) / 1000L);
	wind_set(w_handle, WF_HSLIDE, newpos, 0, 0, 0);
}
/* -> vertikal */
void wind_vslide(int w_handle, int newpos)
{
	windows[w_handle].doc_y = (int)((long)newpos * (windows[w_handle].doc_length - (long)windows[w_handle].work.g_h) / 1000L);
	wind_set(w_handle, WF_VSLIDE, newpos, 0, 0, 0);
}

/*---------------*/
/* Slidermanager */
/*---------------*/
void scroll_wind(int w_handle, int what)
{
	switch(what)
	{
		case WA_UPPAGE:
			windows[w_handle].doc_y -= windows[w_handle].work.g_h + windows[w_handle].scroll_y;
			if(windows[w_handle].doc_y < 0)
				windows[w_handle].doc_y = 0;
		break;
		case WA_DNPAGE:
			windows[w_handle].doc_y += windows[w_handle].work.g_h - windows[w_handle].scroll_y;
			if(windows[w_handle].doc_y > windows[w_handle].doc_length - windows[w_handle].work.g_h)
				windows[w_handle].doc_y = (int)windows[w_handle].doc_length - windows[w_handle].work.g_h;
		break;
		case WA_UPLINE:
			windows[w_handle].doc_y -= windows[w_handle].scroll_y;
			if(windows[w_handle].doc_y < 0)
				windows[w_handle].doc_y = 0;
		break;
		case WA_DNLINE:
			windows[w_handle].doc_y += windows[w_handle].scroll_y;
			if(windows[w_handle].doc_y > windows[w_handle].doc_length - windows[w_handle].work.g_h)
				windows[w_handle].doc_y = (int)windows[w_handle].doc_length - windows[w_handle].work.g_h;
		break;
		case WA_LFPAGE:
			windows[w_handle].doc_x -= windows[w_handle].work.g_w + windows[w_handle].scroll_x;
			if(windows[w_handle].doc_x < 0)
				windows[w_handle].doc_x = 0;
		break;
		case WA_RTPAGE:
			windows[w_handle].doc_x += windows[w_handle].work.g_w - windows[w_handle].scroll_x;
			if(windows[w_handle].doc_x > windows[w_handle].doc_width - windows[w_handle].work.g_w)
				windows[w_handle].doc_x = windows[w_handle].doc_width - windows[w_handle].work.g_w;
		break;
		case WA_LFLINE :
			windows[w_handle].doc_x -= windows[w_handle].scroll_x;
			if(windows[w_handle].doc_x < 0)
				windows[w_handle].doc_x = 0;
		break;
		case WA_RTLINE:
			windows[w_handle].doc_x += windows[w_handle].scroll_x;
			if(windows[w_handle].doc_x > windows[w_handle].doc_width - windows[w_handle].work.g_w)
				windows[w_handle].doc_x = windows[w_handle].doc_width - windows[w_handle].work.g_w;
		break;
	}
	if(windows[w_handle].doc_x < 0)
		windows[w_handle].doc_x = 0;
	if(windows[w_handle].doc_y < 0)
		windows[w_handle].doc_y = 0;
	set_slider_pos(w_handle);
}
