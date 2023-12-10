/*
 *		Menu Manager for Pure C Application:
 *		For used GEM menu more easily...
 *
 *	Author  : FunShip
 *	File	: PCXApp.h
 *	Date    : 01 October 1991
 *	Revision: 11 September 1997
 *	Version : 1.00
 *	Release : 1.00
 *	Language: Pure C, Version du 3 Fevrier 1992 
 *	Origine : FRANCE
 *	
 *
 */

#ifndef	__APPLICATION__
#define	__APPLICATION__		__APPLICATION__


#include <Aes.h>
#include <Vdi.h>

#include <PCAes4_1.h>

/*
 * ------------- Critical error that kill our application ! --------
 */

#define	ERROR_CODE_AES		-1
#define	ERROR_CODE_VDI		-2
#define	ERROR_CODE_APP		-3

/*
 * ----------------------------- Publics Types ---------------------
 */

typedef	struct	{
					char	*Version;
					char	*Date;					
				} TAadsVersion;
				
typedef struct	{
                  int   inutile;		/* From TOS 1.0 ! */
                  int   version;
                  long  reseth;
                  long  os_beg;
                  long  os_end;
                  long  os_rsvl;
                  long  os_magic;
                  long  os_date;
                  int   os_conf;
                  int   os_dosdate;    
                  long  p_root;			/* From TOS 1.2 */
                  long  pkbshift;
                  long  p_run;
                  long  p_rsv2;			/* From TOS 1.4 */
                } Type_SysEntete;
        

typedef	struct	{
		  int		ap_version;
		  int		ap_count;
		  int		ap_id;
		  long		ap_private;
		  long		ap_ptree;
		  long		ap_1res;
		  long		ap_2res;
		  long		ap_3res;
		  long		ap_4res;
		} Type_Aes_Info;

typedef	struct	{
		  int		LargeurStation;
		  int		HauteurStation;
		  int		Coordonnee;
		  int		LargeurPoint;
		  int		HauteurPoint;
		  int		NombreHauteurCar;
		  int		NombreTypeLigne;
		  int		NombreLargeurLigne;
		  int		NombreTypeMarqueur;
		  int		NombreTailleMarqueur;
		  int		JeuxCaracteres;
		  int		NombreMotifs;
		  int		NombreHachures;
		  int		NombreCouleurs;
		  int		NombreGdp;
		  int		Fonct1;
		  int		Fonct2;
		  int		Fonct3;
		  int		Fonct4;
		  int		Fonct5;
		  int		Fonct6;
		  int		Fonct7;
		  int		Fonct8;
		  int		Fonct9;
		  int		Fonct10;
		  int		Attribut1;
		  int		Attribut2;
		  int		Attribut3;
		  int		Attribut4;
		  int		Attribut5;
		  int		Attribut6;
		  int		Attribut7;
		  int		Attribut8;
		  int		Attribut9;
		  int		Attribut10;
		  int		AffichageCouleur;
		  int		RotationTexte;
		  int		Remplissage;
		  int		CellArray;
		  int		NombrePalette;
		  int		ControlCurseur;
		  int		NbPeriphEntree;
		  int		ToucheParticuliere;
		  int		EntreeAlpha;
		  int		TypeStation;

		  int		LargeurCarMin;
		  int		HauteurCarMin;
		  int		LargeurCarMax;
		  int		HauteurCarMax;
		  int		LargeurLigneMin;
		  int		Unknow1;
		  int		HauteurLigneMax;
		  int		Unknow2;
		  int		LargeurMarqueurMin;
		  int		HauteurMarqueurMin;
		  int		LargeurMarqueurMax;
		  int		HauteurMarqueurMax;
		} Type_Vdi_Info;

typedef	struct	{
		  /* Extract from Cookies Jar */
		  int		Processor;		/* Processor type */
		  long		Machine;		/* Machine type */
		  int		Switch;			/* Mother board switch */
		  long		Fdc;			/* Floppy Disk Controler */
		  int		Keyboard;		/* Keyboard type */
		  int		Language;		/* Current Language */
		  long		Shifter;		/* Video circuit */
		  int		Sound;			/* Sound System */
		  int		Fpu;			/* Flotting Point Unit */
		  int		Separator;		/* Date separator */
		  int		Date;			/* date format */
		  int		Time;			/* time format */
		  /* Version extract from system's call */
		  int		TosVersion;
		  int		GemdosVersion;
		  int		AesVersion; 
		  /* Calculate from Cookie "MiNT" */
		  int		MultiTosVersion;
		} Type_Mch_Info;

/*
 * ----------------------------- Publics datas ---------------------
 */
		
extern	Type_Aes_Info	*AesInfo;			/* Aes data infos */
extern	Type_Vdi_Info	VdiInfo;			/* Vdi data infos */
extern	Type_Mch_Info	MchInfo;			/* Machine Infos  */
extern	int 		VdiHandle;			/* Handle of VWKS */
extern	int 		AesHandle;			/* Handle of AES  */

/* 
	Event Informations 
*/
extern	int 		A_Event,			/* Event type     */
			A_Message[8],			/* GEM buffer message */
			A_Key,				/* ScanCode & ASCII */
			A_Clic,				/* Number of clics  */
			A_MouseX,			/* Mouse position when */
			A_MouseY,			/* Mouse event */
			A_MouseButton;			/*	Mouse buttons */
/*
	Mouse global datas
*/

extern	int		A_Mouse;			/* Standard Mouse shape */
extern	MFORM		*A_MouseForm;			/* User defined shape */

/*
 * ----------------------------- Publics procedures ---------------------
 */

int	A_Open(char *ressource_file);
void	A_Close(void);

void A_GetVersion( TAadsVersion *AadsVersion);

void	A_HeaderSystem(Type_SysEntete *type);

int	A_FselInput(char *Prefix, char *Dummy, int *Bouton, char *Title);	/* new AADS II */
int	A_FileSelector( char *pathname,char *nom_fichier,char *suffix,
			char *prefix,char *label);
void	A_GetPath(char *Chemin,char *Label);			/* new AADS II */

int	A_GFontHeigh(void);
int	A_GFontWidth(void);
int	A_GCellHeigh(void);
int	A_GCellWidth(void);

void	A_WaitEvent(void);
void	A_CycleTimer(int TimeHi,int TimeLo);
void	A_SetCodeTimer(void (*UserTimer)(void));
void	A_OnTimer(void);
void	A_OffTimer(void);

int	A_SetMouse(int Mouse,MFORM *MouseForm);

#endif
