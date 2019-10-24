/*
 * minitel.h
 *
 * Purpose:
 * --------
 * Definit tous les codes minitel utilises par le programme.
 *
 */


  
/*
 * Codes - Couleurs MINITEL:
 */
	#define	MNOIR			0
	#define	MROUGE		1
	#define	MVERT			2
	#define	MJAUNE		3
	#define	MBLEU			4
	#define	MMAGENTA		5
	#define	MCYAN			6
	#define	MBLANC		7
 
 
/* Standard */
	#define		NUL		0x00		/* Code nul */
	#define		BEL		0x07		/* Beeeeeeeep */
	#define		BS			0x08		/* D‚placement gauche */
	#define		HT			0x09		/* D‚placement droite */
	#define		LF			0x0A		/* D‚placement bas */
	#define		VT			0x0B		/* D‚placement haut */
	#define		FF			0x0C		/* Efface ‚cran */
	#define		CR			0x0D		/* Retour chariot */
	#define		SO			0x0E		/* graphmode */
	#define		SI			0x0F		/* textmode */
	#define		CSR_ON	0x11		/* Allume curseur */
	#define		REP		0x12		/* R‚p‚tition du dernier caractŠre */
	#define		SEP		0x13		/* SEP=(d)19 */
	#define		CSR_OFF	0x14		/* Eteind curseur */
	#define		CAN		0x18		/* CAN=(d)24 */
	#define		SS2		0x19		/* ACCENT-SPECIAL=(d)25 */
	#define		ESC		0x1B		/* Escape */
	#define		HOME		0x1E		/* Home */
	#define		US			0x1F		/* 31 */ 

	#define		MNTL_DEL	0x7F		/* 127 Delete */

	#define		INVALID	'_'		/* Pour caractŠre invalide */

/* SS2 */
	#define		LIVRE				0x23
	#define		DOLLAR			0x24
	#define		DIESE				0x26
	#define		PARAGRPH			0x27
	#define		FLECHE_GAUCHE	0x2C
	#define		FLECHE_HAUT		0x2D
	#define		FLECHE_DROITE	0x2E
	#define		FLECHE_BAS		0x2F
	#define		DEGRE				0x30
	#define		PLUSMOINS		0x31
	#define		DIVISE			0x38
	#define		QUART				0x3C
	#define		DEMI				0x3D
	#define		TROISQUARTS		0x3E
	#define		GRAVE				0x41
	#define		AIGU				0x42
	#define		CIRC				0x43
	#define		TREMA				0x48
	#define		CEDILLE			0x4B
	#define		OE_MAJ			0x6A
	#define		OE_MIN			0x7A
	#define		BETA				0x7B

/* SEP */
	#define		ENVOI				0x41		/* Touche [ENVOI] */
 	#define		RETOUR			0x42		/* Touche [RETOUR] */
	#define		REPET				0x43		/* Touche [REPETITION] */
	#define		GUIDE				0x44		/* Touche [GUIDE] */
	#define		ANNUL				0x45		/* Touche [ANNULATION] */
	#define		SOMM				0x46		/* Touche [SOMMAIRE] */
	#define		CORREC			0x47		/* Touche [CORRECTION] */
	#define		SUITE				0x48		/* Touche [SUITE] */
	#define		CNX_FIN			0x49		/* Touche [CONNEXION/FIN] */

	#define		ACQ_OPPO			0x50		/* Changement d'‚tat … la connexion (Minitel mis en opposition) */
	#define		ACQ_CNX			0x53		/* Connexion ou D‚connexion Physique du Modem */
	#define		PHASE_CNX		0x59		/* Phase de connexion/d‚connexion */

	#define		ACQ_RESET		0x5E		/* Reset ou Chge mode TELEINF <-> T‚l‚tel */

	#define		APPEL				0x6C		/* D‚tection d'appel */
	
/* Escapes */
	#define	MNTL_ENOIR		0x40		/* Encre noire */
	#define	MNTL_EROUGE		0x41		/* Encre rouge */
	#define	MNTL_EVERT		0x42		/* Encre verte */
	#define	MNTL_EJAUNE		0x43		/* Encre jaune */
	#define	MNTL_EBLEU		0x44		/* Encre bleue */
	#define	MNTL_EMAGENTA	0x45		/* Encre magenta */
	#define	MNTL_ECYAN		0x46		/* Encre cyan */
	#define	MNTL_EBLANC		0x47		/* Encre blanc */

	#define	MNTL_FLASH_ON		0x48
	#define	MNTL_FLASH_OFF		0x49

	#define	MNTL_SIZE_NORM		0x4C
	#define	MNTL_SIZE_HIGH		0x4D	/* Double hauteur */
	#define	MNTL_SIZE_WIDE		0x4E	/* Double largeur */
	#define	MNTL_SIZE_DOUBLE	0x4F

	#define	MNTL_FNOIR		0x50		/* Fond noire */
	#define	MNTL_FROUGE		0x51		/* Fond rouge */
	#define	MNTL_FVERT		0x52		/* Fond verte */
	#define	MNTL_FJAUNE		0x53		/* Fond jaune */
	#define	MNTL_FBLEU		0x54		/* Fond bleue */
	#define	MNTL_FMAGENTA	0x55		/* Fond magenta */
	#define	MNTL_FCYAN		0x56		/* Fond cyan */
	#define	MNTL_FBLANC		0x57		/* Fond blanc */

	#define	MNTL_LINE_OFF		0x59	
	#define	MNTL_LINE_ON		0x5A	

	#define	MNTL_INVERSE_OFF	0x5C	
	#define	MNTL_INVERSE_ON	0x5D	
	
	
/* PRO 1 */
	#define	PRO1			0x39

	#define	PLSD			0x53		/* Prise de Ligne (Sur Demande?) */
	#define	LL				0x57		/* Lib‚ration de Ligne */

	#define	DECONNEXION	0x67		/* D‚connexion physique */
	#define	CONNEXION	0x68		/* Connexion physique */

	#define	RET1			0x6C		/* Retournement modem E1200 R75 */
	#define	RET2			0x6D		/* Retournement modem E75 R1200 */
	#define	OPPO			0x6F		/* Opposition (Passage en RET1 … la connexion) */
	
	#define	RESET			0x7F	/* Remise … l'‚tat initial du Minitel */

/* PRO 2 */
	#define	PRO2			0x3A

	/* X */
	#define	AIGUIL_DEM	0x62	/* Demande de Status … module "TO" */
	#define	AIGUIL_REP	0x63	/* FROM */

	#define	TRANSPARENCE 0x66	/* Transparence protocole */	

	#define	P_START		0x69	/* START mode de fonctionnement */
	#define	P_STOP		0x6A	/* STOP mode de fonctionnement */

	#define	PROG			0x6B	/* Programmation vitesse prise */

	#define	REP_STATUS_FONCTIONNEMENT	0x73	/* R‚ponse... */

	/* Y */
	#define	RE_ECRAN		0x58
	#define	RE_CLAVIER	0x59
	#define	RE_MODEM		0x5A
	#define	RE_PRISE		0x5B
	/* modes de fonctionnement */
	#define	ROULEAU		0x43
	#define	PROCEDURE	0x44
	#define	MINUSCULES	0x45

	/* Vitesses prise: */
		/* Minitel 1B: */
	#define	PERI_R300	0x02
	#define	PERI_R1200	0x04
	#define	PERI_R4800	0x06
	#define	PERI_E300	0x10
	#define	PERI_E1200	0x20
	#define	PERI_E4800	0x30
		/* Minitel 2 (compatibilit‚ ascendente) */
	#define	PERI_300		0x52
	#define	PERI_1200	0x64
	#define	PERI_4800	0x76
	#define	PERI_9600	0x7F

/* PRO 3 */
	#define	PRO3			0x3B

	/* X */
	#define	AIGUIL_OFF	0x60	/* Demande de couper */
	#define	AIGUIL_ON	0x61	/* Demande d'installer */

	/* codes P_START et P_STOP equvantents ds PRO2/X */

	/* Y */
	/* codes R‚c‚pteur equivalents … PRO2/Y */
	
	/* Z */
	#define	EM_ECRAN		0x50
	#define	EM_CLAVIER	0x51
	#define	EM_MODEM		0x52
	#define	EM_PRISE		0x53

	#define	VEILLE		0x41		/* Ecran en veille */
	#define	ETEN			0x41		/* Clavier en mode ‚tendu */
	#define	C0				0x43		/* codage touches curseur avec colonne 00 et 01 du tableau ASCII */

/* CSI */
	#define	CSI			0x5B

/* Identifiant fonction CSI */	
	#define	CSI_UP				0x41
	#define	CSI_DOWN				0x42
	#define	CSI_RIGHT			0x43
	#define	CSI_LEFT				0x44
	#define	CSI_HOME				0x48
	#define	CSI_CLS				0x4A
	#define	CSI_INSLINE			0x4C
	#define	CSI_SUPLINE			0x4D
	#define	CSI_SUPCAR			0x50
	#define	CSI_START_INSCAR	0x68
	#define	CSI_STOP_INSCAR	0x6C