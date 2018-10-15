/****************************************************************

	CON_DEFS.H
	
	Midi Connecte
	D‚finition de constantes et structures de donn‚es.
	
****************************************************************/

#include <msh_unit.h>

#define NUMVERSION	141

/* Quelques constantes */

#define nil		0
#define TRUE		1
#define FALSE		0

/* Les sous fenetres de l'application */
#define SFAPP		0
#define SFIN		1
#define SFOUT		2
#define NBRE_SF	3

#define H_LINE		10				/* hauteur d'une ligne d'affichage  */

/* actions sur les sliders */
#define PAGEUP		0
#define PAGEDOWN	1
#define LINEUP		2
#define LINEDOWN	3

/* Pour les erreurs */

#define NO_RSC			-1			/* pas de fichier de ressources 			*/
#define RSC_DAMAGED		-2			/* fichier de ressources endommag‚ 		*/
#define NO_MORE_WINDOW	-3			/* plus de fenetre disponible				*/
#define NO_MIDISHARE	-4			/* MidiShare n'est pas install‚ 			*/
#define MIDISHARE_FULL	-5			/* pas d'application MidiShare disponibles 	*/
#define ERR_MEM		-6			/* pas de m‚moire disponible 				*/
#define ERR_FULL		-7			/* plus de struct APPL disponible 			*/
#define BAD_VERSION		-8			/* mauvaise version de MidiShare			*/

#define	MAX_APPLS	128				/* nbre max d'applications en cours */

typedef struct midi_appl
{
	short	refnum;
	char  	*name;
	Byte		in[MAX_APPLS/8];
	Byte		out[MAX_APPLS/8];
	struct APPL *next;
}APPL;

struct GEST
{
	APPL *appl;			/* liste des applications en service */
	APPL *aff[NBRE_SF];		/* premiŠres appl. affich‚es         */
	APPL *sel;			/* l'application s‚lectionn‚e		  */
	short state;			/* ‚tat de l'application 		  */
};
