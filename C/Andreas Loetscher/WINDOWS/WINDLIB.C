/*----------------------------------------------------------------*/
/* 												Window-Bibliothek       								*/
/*																																*//* 										Autor: Andreas Loetscher  									*//* 									(c) 1992 Maxon Computer GmbH									*/
/*----------------------------------------------------------------*/

#include	<string.h>
#include	<aes.h>
#include	<vdi.h>
#include	"windlib.h"


#define		Min(a,b)		(a<b)? a:b
#define		Max(a,b)		(a>b)? a:b
	int     	ap_id, handle, work_in[12], work_out[57];
WIND_DATA windows[8];
/*-----------------------------------*/
/* erweiterte open_window()-Funktion *//*-----------------------------------*/

int  open_window(char *w_name,								/* Ptr auf Namensstring    */
								 void (*redraw)(),	  			  /* Ptr auf Redraw-Funktion */
								 int was,											/* Liste der Elemente      */
								 int algn,										/* align-Wert 						 */
								 boolean snp,									/* snappen? (TRUE/FALSE)   */
								 int s_x, int s_y,						/* Scrollwerte X/Y         */
								 int doc_l,int doc_w,					/* Dokumentslaenge/-breite */
								 int x1,int y1,int w1,int h1,	/* Startkoordinaten				 */                 int mx,int my,int mw,int mh)	/* Maximalkoordinaten			 */{	int     w_handle;	
	void		clear_window(int w_hndl);
	void  	set_slider_size(int w_handle);
	void		set_slider_pos(int w_handle);	
	
  if(mw==0)    /* ermittelt die Gr”sse des Desktop:      */    wind_get(0,4,&mx,&my,&mw,&mh);
    /* und meldet ein Fenster an              */  w_handle=wind_create(was,mx,my,mw,mh);
  /* traegt wichtige Daten in Struktur ein :*/  windows[w_handle].max.g_x  = mx;  windows[w_handle].max.g_y  = my;  windows[w_handle].max.g_w  = mw;  windows[w_handle].max.g_h  = mh;  windows[w_handle].elements = was;  windows[w_handle].align    = algn;  windows[w_handle].snap     = snp;  windows[w_handle].w_redraw = redraw;  windows[w_handle].scroll_x = s_x;  windows[w_handle].scroll_y = s_y;  windows[w_handle].doc_length = doc_l;  windows[w_handle].doc_width  = doc_w;  windows[w_handle].doc_x = 0;  windows[w_handle].doc_y = 0;  strcpy(windows[w_handle].name,w_name);  windows[w_handle].full = (x1==mx && y1==my && w1==mw && h1==mh);  wind_calc(WC_WORK,was,x1,y1,w1,h1, 
  					&windows[w_handle].work.g_x,            &windows[w_handle].work.g_y,
            &windows[w_handle].work.g_w,            &windows[w_handle].work.g_h);
    /* setzen des Fensternamens :             */  wind_set(w_handle,2, windows[w_handle].name, 0,0);	
  /* zeichnet ”ffnende Box:                 */  graf_growbox(0,0,0,0,x1,y1,w1,h1);	
  wind_open(w_handle,x1,y1,w1,h1);  clear_window(w_handle);  set_slider_size(w_handle);  set_slider_pos(w_handle);	
  /* schliesslich geben wir dem rufenden Programm 
     die Identifikationsnummer des Fensters zurck: */  return(w_handle);}

/*------------------------------*//* allgemeine Fensterverwaltung *//*------------------------------*/
void	handle_window(int buffer[]){
	int		algn;
	
	void		clear_window(int w_hndl);
	int 		rc_intersect(GRECT *p1,GRECT *p2);
	boolean	rc_equal(GRECT *p1, GRECT *p2);
	void  	set_slider_size(int w_handle);
	void		set_slider_pos(int w_handle);	void		w_c_work(int w_handle, int x, int y, int w, int h);
	void		handle_full(int w_hndl);
	void		snap(GRECT *w1,GRECT *w2);
	int			align(int k,int n);
	void		full_redraw(int w_handle);
	void		do_redraw(int buffer[]);
	void		wind_hslide(int w_handle,int newpos);
	void		wind_vslide(int w_handle,int newpos);
	void		scroll_wind(int w_handle,int what);
	
		switch(buffer[0])  {    case WM_ARROWED:
 	   		scroll_wind(buffer[3], buffer[4]);        full_redraw(buffer[3]);				break;		
    case WM_CLOSED:
    		wind_close(buffer[3]);
        break;
    
    case WM_FULLED: 
    		handle_full(buffer[3]);        set_slider_size(buffer[3]);		    break;		
    case WM_HSLID:
    		wind_hslide(buffer[3], buffer[4]);	      full_redraw(buffer[3]);				break;		
   case WM_NEWTOP: 
    		clear_window(buffer[3]);
        break;
    
    case WM_REDRAW: 
    		do_redraw(buffer);
		    break;
		
    case MN_SELECTED: 
    		break;
    
    case WM_SIZED:
    case WM_MOVED:
 		   											/* Wenn Fenster auf maximaler Groesse und
          										 Breite bzw. Hoehe vergroessert -> Abbruch */
    		if(windows[buffer[3]].full 
  						&&( buffer[6]>windows[buffer[3]].max.g_w 
  						|| buffer[7]>windows[buffer[3]].max.g_h))
        	break;
       
    												/* Wenn kleiner Minimalgroesse vergroessern: */
       	if(buffer[6]<133)
       		buffer[6] = 133;
       	if(buffer[7]<133)
       		buffer[7] = 133;
 												   /* Ausrichten der X-Koordinate, falls algn
												       nicht gleich 0                            */
        algn=windows[buffer[3]].align;
        if(algn)
        	buffer[4] = align(buffer[4],algn)-1;

											    /* Falls Fenster auserhalb Maximalkoordinaten
											       wieder zurueckschieben :                  */
        if(windows[buffer[3]].snap)
          snap(&windows[buffer[3]].max,(GRECT *)&buffer[4]);

											    /* Mit den neu berechneten Koordinaten das
											       Fenster neu positionieren :               */
        wind_set(buffer[3],WF_CURRXYWH,buffer[4],buffer[5],buffer[6],buffer[7]);
        w_c_work(buffer[3],buffer[4],buffer[5],buffer[6],buffer[7]);        set_slider_size(buffer[3]);		    break;
        case WM_TOPPED: 
    		wind_set(buffer[3],WF_TOP,buffer[3],0,0,0);
        break;
    
    case WM_VSLID:
    		wind_vslide(buffer[3], buffer[4]);        full_redraw(buffer[3]);    		break;
    		
    default: 
    		break;
  }}

/*------------------------*/
/* loescht Fensterinhalt  */
/*------------------------*/

void	clear_window(int w_hndl) 
{
  int		clip[4];
	
	
  wind_get(w_hndl,WF_WORKXYWH, &clip[0],&clip[1],&clip[2],&clip[3]);
  clip[2] += clip[0]; 
  clip[2]--;
  clip[3] += clip[1]; 
  clip[3]--;
  v_hide_c(handle);
  vsf_color(handle,0);
  vs_clip(handle,1,clip);
  v_bar(handle,clip);
  v_show_c(handle,1);
}


/*----------------------------------------------*//* ueberprueft, ob sich p1 und p2 ueberlappen : */
/*----------------------------------------------*/
int rc_intersect(GRECT *p1,GRECT *p2)
{
	int		tx, ty, tw, th;
	
	
  tw = Min(p1->g_x + p1->g_w, p2->g_x + p2->g_w);
  th = Min(p1->g_y + p1->g_h, p2->g_y + p2->g_h);
  tx = Max(p1->g_x, p2->g_x);
  ty = Max(p1->g_y, p2->g_y);

  p2->g_x = tx;
  p2->g_y = ty;
  p2->g_w = tw - tx;
  p2->g_h = th - ty;

  return ((tw > tx) && (th > ty));
}


/*-------------------------------------------------*/
/* vergleicht zwei GRECT-Strukturen auf Gleichheit */
/*-------------------------------------------------*/

boolean	rc_equal(GRECT *p1, GRECT *p2)
{
  if((p1->g_x != p2->g_x) ||
     (p1->g_y != p2->g_y) ||
     (p1->g_w != p2->g_w) ||
     (p1->g_h != p2->g_h)) return(FALSE);
  return(TRUE);
}

/*-------------------------------*/
/* Setzen der Groesse der Slider *//*-------------------------------*/

void  set_slider_size(int w_handle) 
{ 
	long h_size, v_size;

	h_size = windows[w_handle].work.g_w * 1000 / 
					 windows[w_handle].doc_width;  v_size = windows[w_handle].work.g_h * 1000 /           windows[w_handle].doc_length;  wind_set(w_handle,WF_HSLSIZE,h_size,0,0,0);  wind_set(w_handle,WF_VSLSIZE,v_size,0,0,0);}
/*--------------------------------*/
/* Setzen der Position der Slider *//*--------------------------------*/

void	set_slider_pos(int w_handle){ 
	long  x_pos, y_pos;	
		if(windows[w_handle].doc_width <= windows[w_handle].work.g_w)	  x_pos = 0;  else 
  	x_pos = windows[w_handle].doc_x * 1000 /						( windows[w_handle].doc_width -
						  windows[w_handle].work.g_w );  if(windows[w_handle].doc_length <= windows[w_handle].work.g_h)    y_pos = 0;  else 
  	y_pos = windows[w_handle].doc_y * 1000 /            ( windows[w_handle].doc_length -              windows[w_handle].work.g_h );  wind_set(w_handle,WF_HSLIDE,x_pos,0,0,0);  wind_set(w_handle,WF_VSLIDE,y_pos,0,0,0);}

/*----------------------------------------------*/
/* Berechnung der Arbeitsflaeche eines Fensters *//*----------------------------------------------*/
void	w_c_work(int w_handle, int x, int y, int w, int h) 
{	wind_calc(WC_WORK,windows[w_handle].elements,            x,y,w,h,&windows[w_handle].work.g_x,            &windows[w_handle].work.g_y,            &windows[w_handle].work.g_w,            &windows[w_handle].work.g_h);}
/*------------------------------------*//* ermittelt die momentane, vorherige */ 
/* und maximale Groesse des Fensters  */
/*------------------------------------*/
void	handle_full(int w_hndl){  GRECT prev;
  GRECT curr;
  GRECT full;

  wind_get(w_hndl,WF_CURRXYWH,&curr.g_x,&curr.g_y,&curr.g_w,&curr.g_h);
  wind_get(w_hndl,WF_PREVXYWH,&prev.g_x,&prev.g_y,&prev.g_w,&prev.g_h);
  wind_get(w_hndl,WF_FULLXYWH,&full.g_x,&full.g_y,&full.g_w,&full.g_h);
  if (rc_equal(&curr, &full))
  { /* Window ist auf voller Groesse, jetzt auf alte Groesse setzen */
    graf_shrinkbox(prev.g_x,prev.g_y,prev.g_w,prev.g_h,
    							 full.g_x,full.g_y,full.g_w,full.g_h);
    wind_set(w_hndl,WF_CURRXYWH,prev.g_x,prev.g_y,prev.g_w,prev.g_h);    windows[w_hndl].full = FALSE;    w_c_work(w_hndl,prev.g_x,prev.g_y,prev.g_w,prev.g_h);  }
  else
  { /* Window ist nicht auf voller Groesse, deshalb auf volle Groesse setzen */
    graf_growbox(curr.g_x,curr.g_y,curr.g_w,curr.g_h,
    						 full.g_x,full.g_y,full.g_w,full.g_h);
		wind_set(w_hndl,WF_CURRXYWH,full.g_x,full.g_y,full.g_w,full.g_h);    windows[w_hndl].full = TRUE;    w_c_work(w_hndl,full.g_x,full.g_y,full.g_w,full.g_h);  }}

/*---------------------------------------------*/
/* Routine, die dafuer sorgt, dass ein Fenster */
/* vollstaendig innerhalb eines spezifizierten */
/* Rechtecks liegt (z.B. Desktop)              */
/*---------------------------------------------*/

void	snap(GRECT *w1,GRECT *w2)
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

int	align(int k,int n)
{
  k += (n>>1) - 1;
  k  = n * (k / n);
  return(k);
}


/*-----------------------------*//* zeichnet ganzes Fenster neu *//*-----------------------------*/
void	full_redraw(int w_handle){	
	clear_window(w_handle);
	(*windows[w_handle].w_redraw)();}

/*--------------------------------------*/
/* fuehrt den Redraw eines Fensters aus */
/*--------------------------------------*/

void	do_redraw(int buffer[])
{
	GRECT   p;
  int			work[4];
  WIND_DATA	zw;
        
  v_hide_c(handle);
  wind_update(BEG_UPDATE);
  wind_get(buffer[3],WF_FIRSTXYWH,
           &p.g_x,&p.g_y,&p.g_w,&p.g_h);
  while(p.g_w>0 && p.g_h>0)
  {
    work[0] = buffer[4]; work[1] = buffer[5];
    work[2] = buffer[6]; work[3] = buffer[7];
    if(rc_intersect(&p,(GRECT *)&work))
    {
      work[2] += work[0]-1;
      work[3] += work[1]-1;
      vs_clip(handle,TRUE,work);
      vsf_color(handle,0);
      v_bar(handle,work);
      (*windows[buffer[3]].w_redraw)();
    }
    wind_get(buffer[3],WF_NEXTXYWH,
             &p.g_x,&p.g_y,&p.g_w,&p.g_h);
  }
  vs_clip(handle,FALSE,work);
  wind_update(END_UPDATE);
  v_show_c(handle,TRUE);
}

/*---------------------------------*/
/* Berechnen der Dokumentsposition *//*---------------------------------*/

/* -> horizontal   */void	wind_hslide(int w_handle,int newpos) 
{  windows[w_handle].doc_x = newpos * (windows[w_handle].doc_width -												              windows[w_handle].work.g_w) / 1000;  wind_set(w_handle,WF_HSLIDE,newpos,0,0,0);}/* -> vertikal     */void	wind_vslide(int w_handle,int newpos) 
{  windows[w_handle].doc_y = newpos * (windows[w_handle].doc_length -												              windows[w_handle].work.g_h) / 1000;  wind_set(w_handle,WF_VSLIDE,newpos,0,0,0);}

/*---------------*//* Slidermanager *//*---------------*/
void	scroll_wind(int w_handle,int what){  switch(what)  {    case WA_UPPAGE : 
    		windows[w_handle].doc_y -= windows[w_handle].work.g_h +                    							 windows[w_handle].scroll_y;        if(windows[w_handle].doc_y <0)       		windows[w_handle].doc_y = 0;    break;		
    case WA_DNPAGE : 
    		windows[w_handle].doc_y += windows[w_handle].work.g_h -							                     windows[w_handle].scroll_y;        if(windows[w_handle].doc_y > windows[w_handle].doc_length)          windows[w_handle].doc_y = windows[w_handle].doc_length;    break;		
    case WA_UPLINE : 
    		windows[w_handle].doc_y -= windows[w_handle].scroll_y;        if(windows[w_handle].doc_y <0)          windows[w_handle].doc_y = 0;    break;		
    case WA_DNLINE : 
    		windows[w_handle].doc_y += windows[w_handle].scroll_y;        if(windows[w_handle].doc_y >          windows[w_handle].doc_length)        windows[w_handle].doc_y = windows[w_handle].doc_length;    break;		
    case WA_LFPAGE : 
    		windows[w_handle].doc_x -= windows[w_handle].work.g_w +
    		    											 windows[w_handle].scroll_x;        if(windows[w_handle].doc_x <0)          windows[w_handle].doc_x = 0;    break;		
    case WA_RTPAGE : 
    		windows[w_handle].doc_x += windows[w_handle].work.g_w -						                       windows[w_handle].scroll_x;        if(windows[w_handle].doc_x > windows[w_handle].doc_width)          windows[w_handle].doc_x = windows[w_handle].doc_width;    break;		
    case WA_LFLINE : 
    		windows[w_handle].doc_x -= windows[w_handle].scroll_x;        if(windows[w_handle].doc_x <0)          windows[w_handle].doc_x = 0;    break;		
    case WA_RTLINE : 
    		windows[w_handle].doc_x += windows[w_handle].scroll_x;        if(windows[w_handle].doc_x > windows[w_handle].doc_width)          windows[w_handle].doc_x = windows[w_handle].doc_width;    break;  }  set_slider_pos(w_handle);}