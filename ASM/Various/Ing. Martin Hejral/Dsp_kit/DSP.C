/**************************************************************/
/**********  Desktop Sound Processor ¾ a.d. 1996  *************/
/**************************************************************/
/***************        Martin Hejral        ******************/
/**************************************************************/

#include <aes.h>
#include <tos.h>
#include <vdi.h>
#include <stdio.h>

#include "dspbind.h"
#include "sndbind.h"

#include "dsp_col.h"

#include "imghead.h"
#include "imgproc.h"



/* ---------------------------------------------------------- */
/*       Funktionsprototypen                                  */
/* ---------------------------------------------------------- */

void open_window( void );
int  rc_intersect( GRECT *r1, GRECT *r2 );
void redraw_window( int all );
int  handle_message( int mbuf[8] );
void event_loop( void );

void dsp_free(int active);
long dsp_init(char *lodfile);

void fader_draw(int tree, char *title, int val_l, int val_r);
int fader_control(int *l, int *r);
void fader_free(void);

void volume(void);
void oscilloscope(void);



/* -------------------------------------------------------- */
/*       macros                                             */
/* -------------------------------------------------------- */
/***
#define min(a, b)             ((a) < (b) ? (a) : (b))
#define max(a, b)             ((a) > (b) ? (a) : (b))
***/
#define abs(x) ((x)<0 ? -(x):(x))
#define pf printf
#define mem(a) malloc(sizeof(a))

/* AES macros */
#define radr rsrc_gaddr
#define trf mx-=x1; my-=y1
#define dia(s) rsrc_gaddr(R_TREE,(s),&m); form_center(m,&x,&y,&w,&h); form_dial(1,2,2,1,1,x,y,w,h); objc_draw(m,0,8,x,y,w+9,h+9)
#define undia(s) form_dial(3,2,2,1,1,x,y,w,h)
#define mouse(a,b,c) evnt_button((a),(b),(c),&mx,&my,&mb,&ks)
#define showm graf_mouse( M_ON, (void *)0 )
#define hidem graf_mouse( M_OFF, (void *)0 )
#define setm(x) graf_mouse((x),0)



/* ------------------------------------------------------------ */
/*       Global Variables                                       */
/* ------------------------------------------------------------ */

extern int _app;                    /* das Programm feststellen, ob es  */
                                    /* als Accessory oder normale App-  */
                                    /* likation gestartet wurde.        */

int    whandle;                     /* Handle fr ge”ffnetes Fenster.   */
char   title[] = "DSP Studio";        /* Titelzeile des Fensters.         */
int    gl_wchar,                    /* Gr”že und Breite eines Buchsta-  */
       gl_hchar,                    /* ben (wichtig falls mit unter-    */
       gl_wbox,                     /* schiedlichen Bildschirmaufl”-    */
       gl_hbox;                     /* sungen gearbeitet wird) bzw.     */
                                    /* einer Box.                       */
int    aes_handle,                 /* Handles fr AES und unsere VDI   */
       handle;                      /* Arbeitstation. */
int    appl_id,                     /* Identifikationsnummer des Prog.  */
       menu_id;                     /* Id.-nummer im Men 'Desk'.       */

int   contrl[12],
      intin[128], intout[128], ptsin[128], ptsout[128],
      work_in[12], work_out[57];
/***
int   xm,ym,cm,fm,bitplanes;	/* parametry pracovni stanice / obrazovky */
***/
int xy[32];    	/* pxyarray */
int mx,my,mb,ks;   	/* mouse status */

/* ########################################################## */
/* ########################################################## */
/* SPECIFIC APPLICATION'S VARIABLES place here */
/* ########################################################## */
/* ########################################################## */






/* ---------------------------------------------------------- */
/*       void open_window( void );                            */
/* ---------------------------------------------------------- */

void open_window( void )
{
   if ( whandle <= 0 )
   {
      whandle = wind_create( NAME|CLOSER|MOVER, 0, 0, xm + 1, ym + 1 );
      if ( whandle <= 0 )
         return;

      wind_set( whandle, WF_NAME, title );
      wind_open( whandle, 0, 20, xm+1 , ym-19 );
	 }
   else
      wind_set( whandle, WF_TOP );

}



/* --------------------------------------------------------------- */
/*       boolean rc_intersect( GRECT *r1, GRECT *r2 );             */
/*                                                                 */
/*       Berechnung der Schnittfl„che zweier Rechtecke.            */
/*                                                                 */
/*       -> r1, r2               Pointer auf Rechteckstruktur.     */
/*                                                                 */
/*       <-                      == 0  falls sich die Rechtecke    */
/*                                     nicht schneiden,            */
/*                               != 0  sonst.                      */
/* --------------------------------------------------------------- */

int rc_intersect( GRECT *r1, GRECT *r2 )
{
   int x, y, w, h;

   x = max( r2->g_x, r1->g_x );
   y = max( r2->g_y, r1->g_y );
   w = min( r2->g_x + r2->g_w, r1->g_x + r1->g_w );
   h = min( r2->g_y + r2->g_h, r1->g_y + r1->g_h );

   r2->g_x = x;
   r2->g_y = y;
   r2->g_w = w - x;
   r2->g_h = h - y;

   return ( ((w > x) && (h > y) ) );
}



/* ---------------------------------------------------------- */
/*       void redraw_window( int all );                       */
/* ---------------------------------------------------------- */

void redraw_window( int all )
{
GRECT     box,work;
int       clip[4];

wind_update( BEG_UPDATE );
hidem;
vsf_color( handle, 1 );                       /* set fill */
vswr_mode( handle, 1 );                       /* set replace mode */

wind_get( whandle, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h );
wind_get( whandle, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h );

while( box.g_w > 0 && box.g_h > 0 )
{
    if( rc_intersect( &work, &box ) )
    {
       clip[0] = box.g_x;
       clip[1] = box.g_y;
       clip[2] = box.g_x + box.g_w - 1;
       clip[3] = box.g_y + box.g_h - 1;
       vs_clip( handle, 1, clip );
       if( all )
          vr_recfl( handle, clip );     /* fill rectangle */
/*            v_gtext( handle, (work.g_x + work.g_w / 2) 
                - (int)strlen( s ) * gl_wchar / 2,
                work.g_y + ym / 10, s );
*/    }
    wind_get( whandle, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h );
} /* next rectangle */
showm;
wind_update( END_UPDATE );
} /* redraw_window() */



/* ---------------------------------------------------------- */
/*       int handle_message( int mbuf[8] )                    */
/* ---------------------------------------------------------- */

int handle_message( int mbuf[8] )
{

   switch ( mbuf[0] )
   {

/***
      case WM_REDRAW:
         redraw_window( 1 );
      break;

      case WM_TOPPED:
         wind_set( whandle, WF_TOP );
      break;

      case WM_CLOSED:
         if ( mbuf[3] == whandle )
         {
            wind_close( whandle );
            wind_delete( whandle );
            whandle = 0;
         }
         if ( _app )
            return( 1 );
      break;

      case WM_MOVED:
      case WM_SIZED:
         if ( mbuf[3] == whandle )
            wind_set( whandle, WF_CURRXYWH,  mbuf[4], mbuf[5], mbuf[6], mbuf[7] );
     break;
***/
      case AC_OPEN:
/*         if ( mbuf[4] == menu_id )**/
            volume();
            /*open_window();*/
      break;

      case AC_CLOSE:
         if ( mbuf[3] == menu_id )
            whandle = 0;
      break;
   }
   return 0;
}



/* ---------------------------------------------------------- */
/*    event_loop()                                            */
/*                                                            */
/*    Die Multi-Event-Schleife.                               */
/* ---------------------------------------------------------- */

void event_loop( void )
{
   int x, y,
       kstate,
       key,
       clicks,
       event,
       state;
   int mbuf[8];
   int quit=0;

   do {
      if( _app )	/* accessory ? */
      	pf("\r\x1Bk\x1Bv Enter command: \r");
      event = evnt_multi( MU_MESAG|MU_KEYBD,
                          2, 0x1, 1,
                          0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0,
                          mbuf,
                          1000, 0,
                          &x, &y, &state, &kstate, &key, &clicks );
      if( _app )	/* accessory ? */
      	pf("\r                     \r");

/**      wind_update( BEG_UPDATE );**/

/* ########################################################## */
/*               Here call your specific routines             */
/* ########################################################## */

      if ( event & MU_MESAG ) {
		quit = handle_message(mbuf);
	 }

	if ( event & MU_KEYBD ) {
		switch(key & 0xFF) {
			case 'o': oscilloscope(); break;
			case 'v': volume(); break;
			case 'q': quit=1; break;

		} /* switch(key) */
	} /* if(event & MU_KEYBD) */

/* ########################################################## */
/* ########################################################## */

/**      wind_update( END_UPDATE );**/
   } while ( !quit );
} /* evnt_loop() */



/************************************************/

int opnwk(int device)
{
   int index,du;

Cconws("\x1BH\x1Bv");

   if( appl_init() != -1)
   {   
      for(index = 0; index < 10; work_in[index++] = 1);
      work_in[0]  = device;            /* cislo zarizeni */
      work_in[7]  = 3;                 /* typ vyplnovani */
      work_in[8]  = 6;                 /* index vzoru    */
      work_in[10] = 2;                 /* RC             */
      handle = aes_handle = graf_handle(&du,&du,&du,&du);
      if( device < 11 ) {
         v_opnvwk(work_in,&handle,work_out); /* obrazovka */
      } else {
         v_opnwk(work_in,&handle,work_out); /* ostatni periferie */
      }
      xm = work_out[0]+1;
      ym = work_out[1]+1;
      cm = work_out[13];	/* pocet indexu barev */
/**      v_clrwk(handle);**/
      return(handle);
   }
   return(0); /* chyba */
} /* opnwk() */



void clswk(int dev, int hand)
{
	if( dev < 11 )  v_clsvwk(hand);  else  v_clswk(hand);
}



/***** initialize GEM *****/
int gem_init(int device)
{
	appl_id=appl_init();

	opnwk(device);
	
	/* check for TRUE COLOR (FALCON or graphic card) */
	vq_extnd( handle, 1, work_out );
	bitplanes = work_out[4];
	
	if( !_app )	/* accessory ? */
		menu_id = menu_register( appl_id, "  DSP" );
	else
		graf_mouse( 0, (void*)0 );

	return 0;	
} /* gem_init() */



/* ---------------------------------------------------------- */
/*                        USER ROUTINES                       */
/* ---------------------------------------------------------- */

/*** this procedure is executed at end of program ***/
void end(void)
{
}



/*** inicializace specificke pro dany program ***/
void my_init(void)
{
/**	atexit(end);**/
/**save_palette();**/
}



/* posila vahove koeficienty pro DSP program - ovlada hlasitost */
void volume(void)
{
	static int left=255,right=255;
	/* 11 DSP words - comm. protocoll: */
	static char to_dsp[11*3]=
	{
	0x12,0x34,0x56,	/* magic number */
	0x00,0x00,0x01,	/* code 1: send 8 channel weights */
	0x00,0x00,0x08,	/* number of DSP data words */
	0x30,0x00,0x00,	/* channel 1L */
	0x70,0x00,0x00, 	/* channel 1R */
	0x30,0x00,0x00,	/* channel 2L */
	0x70,0x00,0x00, 	/* channel 2R */
	0x30,0x00,0x00,	/* channel 3L */
	0x70,0x00,0x00, 	/* channel 3R */
	0x30,0x00,0x00,	/* channel 4L */
	0x70,0x00,0x00 	/* channel 4R */
	};
	
	fader_draw(FADER,"VOLUME CTRL", left, right);
	while( fader_control(&left, &right) ) {
printf("\rL%3i-R%3i; ",left,right);
		to_dsp[ 9] = (char)( left>>1);
		to_dsp[12] = (char)(right>>1);
/*printf(">DSP $%X; ", Dsp_HStat() );*/
		if( Dsp_HStat() == 6 )	/* k vys¡l n¡ pripraven */
			Dsp_DoBlock(to_dsp,11,0,0);
/*printf(">>DSP $%X; ", Dsp_HStat() );*/
	}
	fader_free();
} /* volume() */



extern draw_scope(int x, int y, int *data);

void oscilloscope(void)
{
int *dma_buff;
int i;
IMAGE picture;

Buffoper(0);
Devconnect(ADC, DSPREC|DMAREC, INTERNAL_25M, CLK25K, NO_HANDSHAKE);
dma_buff = Malloc(1024*10);
/**printf("buff=$%p;",dma_buff); evnt_keybd();**/
Setbuffer(1, dma_buff, dma_buff+1024);
/**Setbuffer(0, dma_buff, dma_buff+1024);**/
Buffoper( RECORD_REPEAT|RECORD_ENABLE );

vs_clip(handle, 0, xy);
read_img("SCOPE.IMG", &picture);
show_palette(222,133);
show_image(16,97,257,129,0,0,&picture);
show_image(16,97,257,129,288,0,&picture);
show_image(16,97,257,129,0,200,&picture);
show_image(16,97,257,129,288,200,&picture);
delete_image(&picture);
for(i=0; i<256; i++) {
	draw_scope(0,0,dma_buff);
	draw_scope(288,0,dma_buff+512);
	draw_scope(0,200,dma_buff+2);
	draw_scope(288,200,dma_buff+512+2);
	evnt_timer(40,0);
}

Buffoper(0);
Mfree(dma_buff);
/**Devconnect(ADC, DSPREC, INTERNAL_25M, CLK25K, NO_HANDSHAKE);**/
}



/* ---------------------------------------------------------- */
/*       void main( void );                                   */
/* ---------------------------------------------------------- */

long main( void )
{
	int device=1,err;

	my_init();		/* USER's SPECIFIC INIT */

	gem_init(device);

	init_imglib();

	if(dsp_init("MIXER.LOD")<0) {
		clswk(device,handle);  appl_exit();
		return -1;
	}

	if(rsrc_load("DSP_COL.RSC")==0) {
		clswk(device,handle);  appl_exit();
		return -1;
	}

	event_loop();	/* main application loop */

	rsrc_free();

	dsp_free(1);	/* 1 = signal processing continued */

	clswk(device,handle);

	appl_exit();

	return 0;

} /* main() */
