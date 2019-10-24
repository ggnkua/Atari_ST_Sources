/* 
 * Options de compilation pour STUT ONE 3
 * Ce fichier est une sorte de "master file"
 *
 * Suggest:
 * --------
 * Pour l'ensemble du programme:
 * implementer une relation texte/valeur avec fonctions de consultation
 * eventuellement 2 textes/1 valeur et des trucs du genre utilis‚s
 * en divers endroits du logiciel.
 */

/*
 * Contr“le de version:
 */
/*
 * Nom complet
 * Apparait dans dialogue About et sur minitel au lancement du logiciel
 */
#define	STUT_FULLNAME		"Stut One 3.01 Alpha"
#define	STUT_RELEASEINFO	"Preview Release 5"
/*
 * Nom donn‚ … l'AES (apparait dans menu Desk sous multitos)
 */
#define	STUT_REGISTERNAME	"  Stut One 3.0 Alpha "
/*
 * Connect Name
 * Affich‚ lors d'une connexion en mode normal
 */
#define	STUT_CONNECTNAME	"Logiciel serveur STUT ONE 3.0"

/*
 * Options de compilation pour cette version:
 */
/* R‚solution: */
	#define	MIN_WIDTH				640
	#define	MIN_HEIGHT				200
	#define	MIN_RES_STRING			"640 * 200"

/*
 * Faut'il accepter les appels … distance
 * (d‚tection sonnerie)
 * OUI sauf sur versions ALPHA
 */
	#define	ACCEPT_REMOTE			YES1

/*
 * Faut'il accepter des fontes 8*8 en plus des 8*16?
 * YES1 si on accepte la moyenne r‚solution
 * (IntŠgre les ic“nes moyenne r‚solution etc...)
 */
	#define	ACCEPT_SMALLFONTS		YES1

/*
 * Sert a tester les couleurs de relief si pas AES 4
 */
	#define	COLOR_TEST				NO0

/*
 * Cette option valide la compilation 
 * d'instructions bidons utilisant les paramŠtres inutilis‚s
 * des fonctions … protoype g‚n‚rique afin
 * d'‚viter des warnings bidons.
 */
#define		ANTI_WARNING			YES1


/*
 * D‚termine si l'appui sur GUIDE provoque l'affichage du champ
 * en cours de saisie sur l'‚cran ST ou pas?.
 * uniquement pour debugger
 */
#define		DEBUG_DISPLAY			NO0


/*
 * Taille des buffers:
 */
#define		TMP_BUFFER_SIZE		512
#define		SECOND_BUFFER_SIZE	512




/* PROVISOIRE */
/* Voie utilisant la d‚tection sonnerie par click sur bouton droit */
#define		VOIE_SOURIS		1



/*
 * Types courant - compatibilit‚
 */
typedef	int					BOOL;
typedef	unsigned	int		UINT;

typedef	         void    VOID;
typedef	         char    BYTE;
typedef	         int     WORD;
typedef	         long    LONG;
typedef	unsigned char    UBYTE;
typedef	unsigned int     UWORD;
typedef	unsigned long    ULONG;




/* 
 * Pour debugguer:
 * #define	WIND_UPDATE_BEG_MCTRL	wind_update( BEG_MCTRL ); printf("\033Y !M");
 * #define	WIND_UPDATE_END_MCTRL	wind_update( END_MCTRL ); printf("\033Y !-");
 */
#define	WIND_UPDATE_BEG_MCTRL	wind_update( BEG_MCTRL );
#define	WIND_UPDATE_END_MCTRL	wind_update( END_MCTRL );
