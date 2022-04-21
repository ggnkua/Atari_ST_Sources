/* Beispiel Source fr DigiTape Modul */


#include "\dt_modul\dt_local.h" /* UP-Anbindung */
#include "\dt_modul\dt_defin.h" /* Globale Definitionen */

#include "hall.d" 	/* DSP-Programm */
#include "hall.dh" 	/* defines DSP Programm */

#include "hall.h"          		/* Defines Resource-File */
#include "hall.r"          		/* Dump Resource-File */

#define ECHO_BUFF_SIZE 0x1e00  /* max. 0x1e00 */
#define NR_REFLECT 10

typedef struct
{
	Modul_header mh;
	Modul_globals mg;

	int rev_index;		/* Index des akt. Paremetersatzes */
	int	dsp_deltab; 	/* abwechselnd delay/pegel/... */
	int dsp_feedback; /* pegel */
	int dsp_eptr;			/* Zeiger fr Ringbuffer */
	long buff_adr; 		/* Datenbereich */
} Rev_globals;

static Rsc_info rsc_reverb=
{
	FORM1, TEXT, SOLO, UNLOCK_M, L_BUTT_M, V_M, VS_M, P_M, PS_M
};

static Module_info dtm_reverb=
{
	0,
	0, 0, 0, ECHO_BUFF_SIZE,	/* x6 x8 x15 xbuff */
	2, 2*NR_REFLECT, 0, 0,		/* y6 y8 y15 ybuff */
	"Example reverb modul"
};


/* Aufbau deltab: long Reflektorabstand in cm
									(max. ECHO_BUFF_SIZE beachten!)
									long Pegel fr diesen Reflektor
									( 1.0 entspricht 1000 )          */
char *texte[]={"Theater", "Club", "Nature", "Chamber", 0L};

/* Laengste Verzoegerung zuerst */
int deltab[][NR_REFLECT]=
{
{2300, 2150, 2000, 1300, 1200, 1100, 1000, 600, 550, 500},
{ 250,  270,  300,  400,  450,  500,  550, 150, 175, 200},

{1500, 1400, 1300, 1000, 900, 600, 500, 400, 300, 200},
{ 200,  200,  200,  100, 100, 200, 350, 500, 400, 300},

{3400, 3200, 3000, 2800, 2600, 2400, 2200, 600, 550, 500},
{ 140,  160,  180,  200,  220,  240,  260, 500, 500, 500},

{1139,  912,  526,  491,  447,  187,  159,  132,  99,   70},
{ 200,  200,  600,  550,  500,  600,  800,  700,  700, 800}
};

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Klick auf Button abfragen
++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
int	check_reverb_buttons( int button, Rev_globals *glob );

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++
	Slot-Lautst„rke L/R und Echo setzen
	+++++++++++++++++++++++++++++++++++++++++++++++++++++*/
void init_reverb_volumes( Rev_globals *glob );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Reverb-Auswahl bearbeiten
++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
void	do_reverb_type( Rev_globals *glob );

/*++++++++++++++++++++++++++++++++++++++++++++*
 * Delaytabelle entsprechend Abtastfrequenz
 * umrechnen und an DSP schicken
 *++++++++++++++++++++++++++++++++++++++++++++*/
void load_deltab( Rev_globals *glob );

/*+++++++++++++++++++++++++++++++++++++++++++
	Echo-Modul
	bei LOAD_DSP: dsp-Quelladresse in x
								dsp-Zieladresse in y
								dsp-Buffer-Address in param
+++++++++++++++++++++++++++++++++++++++++++++*/
long cdecl do_module_reverb( int module_action, Rev_globals *glob,
													 int x, int y, int param )

{
	int button;

	switch ( module_action )
	{
		case MOD_GET_VERSION:
		return DTM_VERSION;

		case MOD_RSC_INIT:
			dtm_init(	&dtm_reverb, HALL, &rsc_reverb );
		return DTM_VERSION;

		case MOD_INIT:
			/* Feedback Poti */
			dtm_init_poti( glob, 0, H_POTI, AMPL_M, AMPLS_M, 0);

			glob->rev_index = 0;
 		break;

		case MOD_LOAD_DSP:
			/* dsp-Datenbereich */
			glob->buff_adr = (long)param;
			glob->dsp_deltab = dm_defvar( 'Y', 8, 2*NR_REFLECT ); /* Delay/Ampl abwechs. */
			glob->dsp_feedback = dm_defvar( 'Y', 6, 1 );
			glob->dsp_eptr = dm_defvar( 'Y', 6, 1 ); /* ptr auf Ringpuffer */

			dm_load(	MODUL_HALL,
								HALL_QUELLE, x, HALL_ZIEL, y,
								HALL_DELTAB, glob->dsp_deltab,
								HALL_FBACK, glob->dsp_feedback,
								HALL_EPTR, glob->dsp_eptr,
								HALL_ESIZE, ECHO_BUFF_SIZE-1,
								HALL_EZAHL, NR_REFLECT, -1 );

			/* Delaytabelle */
			load_deltab(glob);

			/* Puffer-Anfangsadresse */
			dm_setvar( 'Y', glob->dsp_eptr, &glob->buff_adr, 1 );
		break;

		case MOD_CLR_MEMORY:
			dsp_setblock( 'X', (int)glob->buff_adr, 0L, ECHO_BUFF_SIZE );
		break;

		case MOD_OUT_VOLS: /* gleich nach Aufruf */
			/* Volumes und Echo setzen */
			init_reverb_volumes( glob );
		break;

		case MOD_LBUTTONDOWN:
		  button = object_find( glob->mh.object_ptr, 0, 10, x, y );

			if ( check_reverb_buttons( button, glob ) )
				return TRUE;
		break;

		case MOD_DRAW:
			DialogPrintf( glob->mh.hdialog, SELECHO, texte[glob->rev_index] );
		break;

		case MOD_SLIDER_MOVED:
			switch ( x )
			{
				case 0:
					/* Echo feedback setzen */
					dm_setvar( 'Y', glob->dsp_feedback, log_tab_entry(y), 1 );
				break;
				default:
					return FALSE;
			}
		return TRUE;
	}

	return FALSE;
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Klick auf Button abfragen
++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
int	check_reverb_buttons( int button, Rev_globals *glob )

{
	switch ( button )
	{
		case SELECHO:
			do_reverb_type( glob );
		break;

		default:
			return FALSE;
	}

	draw_object( glob->mh.object_ptr, button );
	return TRUE;
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++
	Slot-Lautst„rke L/R und Echo setzen
	+++++++++++++++++++++++++++++++++++++++++++++++++++++*/
void init_reverb_volumes( Rev_globals *glob )

{
	/* Echo feedback setzen */
	dm_setvar( 'Y', glob->dsp_feedback,
							log_tab_entry(glob->mg.potis[0].position), 1 );
}

/*++++++++++++++++++++++++++++++++++++++++++++*
 * Delaytabelle entsprechend Abtastfrequenz
 * umrechnen und an DSP schicken
 *++++++++++++++++++++++++++++++++++++++++++++*/
void load_deltab( Rev_globals *glob )
{
	long loc_deltab[2*NR_REFLECT];
	int  *deltab_ptr;
	int i;

	deltab_ptr=deltab[glob->rev_index*2];

	for (i=0; i<2*NR_REFLECT; )
	{
		loc_deltab[i++] = ECHO_BUFF_SIZE -
											(long)*deltab_ptr * glob->mh.sys->Hz / 33000L;
		loc_deltab[i++] = 8388L * *(deltab_ptr++ + NR_REFLECT);
	}	
	dm_setvar( 'Y', glob->dsp_deltab, loc_deltab, 2*NR_REFLECT);
}


/*++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Reverb-Auswahl bearbeiten
++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
void	do_reverb_type( Rev_globals *glob )

{
	if ( texte[++(glob->rev_index)] == 0L )
		glob->rev_index = 0;

	load_deltab(glob);
	DialogPrintf( glob->mh.hdialog, SELECHO, texte[glob->rev_index] );
}
