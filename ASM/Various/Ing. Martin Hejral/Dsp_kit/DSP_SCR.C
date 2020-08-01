/**************************************************************/
/*******  Compute screen on DSP 56001  **  26.Feb.1996  *******/
/**************************************************************/
/***************        Martin Hejral        ******************/
/**************************************************************/

#include <aes.h>
#include <tos.h>
#include <vdi.h>

#include "imghead.h"
#include "imgproc.h"



/* ---------------------------------------------------------- */
/*       Funktionsprototypen                                  */
/* ---------------------------------------------------------- */

int  handle_message( int mbuf[8] );
void event_loop( void );

void dsp_free(int active);
long dsp_mem_init(char *lodfile);

void dsp_screen(void);



/* ------------------------------------------------------------ */
/*       Global Variables                                       */
/* ------------------------------------------------------------ */

extern int _app;                    /* das Programm feststellen, ob es  */
                                    /* als Accessory oder normale App-  */
                                    /* likation gestartet wurde.        */

int    gl_wchar,                    /* Grîûe und Breite eines Buchsta-  */
       gl_hchar,                    /* ben (wichtig falls mit unter-    */
       gl_wbox,                     /* schiedlichen Bildschirmauflî-    */
       gl_hbox;                     /* sungen gearbeitet wird) bzw.     */
                                    /* einer Box.                       */
int    aes_handle,                 /* Handles fÅr AES und unsere VDI   */
       handle;                      /* Arbeitstation. */
int    appl_id,                     /* Identifikationsnummer des Prog.  */
       menu_id;                     /* Id.-nummer im MenÅ 'Desk'.       */

int   contrl[12],
      intin[128], intout[128], ptsin[128], ptsout[128],
      work_in[12], work_out[57];



/* ---------------------------------------------------------- */
/*       int handle_message( int mbuf[8] )                    */
/* ---------------------------------------------------------- */

int handle_message( int mbuf[8] )
{

   switch ( mbuf[0] )
   {
      case AC_OPEN:
      break;

      case AC_CLOSE:
      break;
   }
   return 0;
}



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
	appl_id = appl_init();

	opnwk(device);
	
	if( !_app )	/* accessory ? */
		menu_id = menu_register( appl_id, "  DSP" );
	else
		graf_mouse( 0, (void*)0 );

	return appl_id;
} /* gem_init() */



/* ---------------------------------------------------------- */
/*                        USER ROUTINES                       */
/* ---------------------------------------------------------- */

/*** this procedure is executed at end of program ***/
void end(void)
{
true_colour(0);
/*restore_palette();*/
}



/*** inicializace specificke pro dany program ***/
void my_init(void)
{
atexit(end);
save_palette();
true_colour(1);
init_imglib();
}



/* ---------------------------------------------------------- */
/*       void main( void );                                   */
/* ---------------------------------------------------------- */

long main( void )
{
	int device=1,err;

	my_init();		/* USER's SPECIFIC INIT */

	gem_init(device);

	if(dsp_mem_init("SCREEN.LOD") < 0) {
		clswk(device,handle);  appl_exit();  evnt_keybd();
		return -1;
	}

	graf_mouse(M_OFF, NULL);
	dsp_screen();
	graf_mouse(M_ON, NULL);

	dsp_free(0);

	clswk(device,handle);  appl_exit();
	return 0;

} /* main() */
