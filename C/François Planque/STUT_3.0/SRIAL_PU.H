/*
 * serial_public.h
 *
 * Purpose:
 * --------
 * Interface publique pour SERIAL.C
 *
 * History:
 * --------
 * 19.11.94: fplanque: Created
 */

#ifndef	_SERIAL_PU_H_
#define	_SERIAL_PU_H_


#include "POPUP_PU.H"


/*
 * ------------------------- CONSTANTES ----------------------------
 */
	/*	
	 * NOMS symboliques des ports s‚rie de l'ATARI: 
	 *
	 * History:
	 * --------
	 * Created by fplanque
	 */
	#define		PRN		0		/* Printer	*/
	#define		AUX		1		/* [S‚rie]	Equ … MOD1 par d‚faut */
	#define		CON		2		/* Console	*/
	#define		MIDI		3		/* Midi 		*/
	#define		IKBD		4		/* Clavier	(Intelligent Keyboard) */
	#define		RAW		5		/* Ecran 	(Direct / Non bufferis‚) */
	#define		MOD1		6		/* Modem1	Compatible ST */
	#define		MOD2		7		/* Modem2	SCC Canal B */
	#define		SER1		8		/* Serial1	MFP2 - Uniquement sur TT */
	#define		SERL		8		/* "Serial2" SCC Canal A (Trappe VME) - Mega STE */
	#define		SER2		9		/* Serial2	SCC Canal A - Sur TT */


	/*
	 * Handshaking:
	 */
	#define		HANDSHAKE_NONE		0
	#define		HANDSHAKE_XONXOFF	1
	#define		HANDSHAKE_RTSCTS	2
	#define		HANDSHAKE_BOTH		3


	/*
	 * UART control:
	 */
	#define		PARITY_NONE			0x00
 	#define		PARITY_ODD			0x04
 	#define		PARITY_EVEN			0x06

 	#define		MODE_SYNCHRONE		0x00
 	#define		MODE_ASYNC1STOP	0x08
 	#define		MODE_ASYNC1_5STOP	0x10
 	#define		MODE_ASYNC2STOP	0x18
 	
	#define		BITS_8				0x00
	#define		BITS_7				0x20
	#define		BITS_6				0x40
	#define		BITS_5				0x60

	/*
	 * Les IORECS systŠme sont rang‚es par deux dans la m‚moire,
	 * voici dans quel ordre:
	 */	
	#define	IOREC_IN		0			/* Index tableau pour les entr‚es */
	#define	IOREC_OUT	1			/* Index tableau pour les sorties */


/*
 * ------------------ VARIABLES GLOBALES PUBLIQUES -------------------
 */

	/* 
	 * Prises s‚rie: 
	 */
	extern	int			G_term_dev;			/* Port utilis‚ par icone terminal */
	extern	long		*	G_inst_abrev;		/* Noms abr‚g‚s en 4 lettres */
	/* 
	 * Menu Pop-Up: 
	 */
	extern	POPUP_ENTRY	*	G_inst_drv_list;	/* Liste des p‚rifs install‚s pourmenu Popup */


/*
 * --------------------------- INLINES -------------------------------
 */

/*
 * ----------------------- OPERATIONS PUBLIQUES -------------------------
 */

void	param_term( const GRECT *start_box );

void	init_serial( void );
void	restore_serial( void );
void	save_serial_ini( 
							FILE *fstream );				/* In: Ptr sur fichier dans lequel on doit sauver */
void	serial_ini( 
							char *object,					/* In: Objet concern‚ (Tete de Ligne lue ds fichier .INI), ici un poet s‚rie */
							char *data );					/* In: Donn‚es associ‚es … l'objet, ici taille des buffers */
void	param_term( 
							const GRECT *start_box );	/* In: Rectangle de d‚part de l'effet graphique d'ouverture */
void	FlushRXBuffer( int n_device );	/* In: Port concern‚ */

int	device_offset(		/* Out: No d'ordre [0..n-1] du port */
			 int device );	/* In: No bconmap du port */

int	find_device_byabrev( 		/* Out: no bconmap du p‚riph‚rique */
				char *abrev_string );	/* In:  abreviation du nom du port */

void	SetPort(
					int		n_devno,				/* In: Port … utiliser, ex AUX */
					long		l_baud_rate,		/* In: Vitesse: ex: 9600 */
					char		c_parity,			/* In: Parit‚: 'E' 'O' ou 'N' */
					int		n_word_length,		/* In: Longueur de car: 5, 6, 7 ou 8 */
					int		n_mode,				/* In: Mode: ex: MODE_ASYNC1STOP */
					int		n_handshake );		/* In: Handshake: ex: HANDSHAKE_NONE */

void	Serial_FlushTX( 
			int n_device );	/* In: Port concern‚ */

void	Serial_WaitTXEmpty( 
			int n_device );	/* In: Port concern‚ */


#endif 		/* _SERIAL_PU_H_ */