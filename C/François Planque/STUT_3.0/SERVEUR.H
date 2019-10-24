/*
 * Serveur.h
 *
 * Constantes et structures n‚cessaires … la gestion du serveur
 *
 * Notes:
 * ------
 * Diagrame des dépendances:
 *
 * gemwdef.h   arbotree.h  dfstruct.h    dxf.h
 *     |           |           |           |
 *  WIPARAMS    PAGEARBO  	 DATADIR   COMPACT_RECORD   VOIESTATE
 *     |     ARBO_FIELDPARS DATAPAGE   |      |            |			  gem_dirs.c
 *      \        	 |			 TEXTLINE   |      |            /              |
 *        \      	  \		 TEXTINFO  /  COMPREC_LISTELT  /    ACTION  DIRENTRY
 *          \_________\_______ | ____/_______/___________/_______/_______/
 *                            \|/
 *                            VOIE
 *
 */

/*
 * V‚rifie si les pr‚sentes d‚finitions ont d‚ja ‚t‚ faites:
 */
#ifndef SERVEUR_H
#define SERVEUR_H

/*
 * Headers n‚cessaires
 */
	#include "ARBOTREE.H"
	#include "DFSTRUCT.H"
	#include "WIN_PU.H"
	#include "OS_DIRS.H"
	#include "USLTP.H"
	
/* 
 * Codes touches press‚es / evenements exterieurs survenus:
 */
typedef 
	enum
	{
		KEY_NONE,				/* Aucune touche n'a ‚t‚ press‚e */ 
		KEY_SOMM,            /* Sommaire */
		KEY_GUIDE,           /* Guide */
		KEY_ANNUL,           /* Annulation */
		KEY_CORREC,          /* Correction */
		KEY_RETOUR,          /* Retour */
		KEY_SUITE,           /* Suite */
		KEY_REPET,           /* R‚p‚tition */
		KEY_ENVOI,           /* Envoi */
		KEY_FIN,             /* (Connexion/)Fin */
		KEY_CR,					/* Carriage Return */
		ACTIONS,
		EVT_APPEL,				/* D‚tection d'un appel */
		ACT_DISCONNECT,		/* Connexion vient d'ˆtre interrompue */
		ACT_CONNECT,			/* Connexion vient d'ˆtre ‚tablie */
		ECHEC_CONNECT,			/* La Connexion qu'on tentait d'‚tablir vient d'‚chouer */
	}
	KEYCODE;

/* 
 * Taches possibles a effectuer par une voie:
 */
enum {
	INIT,				/* La voie doit ˆtre initialis‚e */
	HALT,				/* Il y a une Kernel-Panic: le serv est stopp‚ */
	SLEEP,			/* La voie n'est pas active */
	CNCT,				/* Etablissement Connexion en cours */
	DECO,				/* D‚connexion en cours */
	WAIT,				/* On est en attente d'action utilisateur */
	START,			/* D‚but d'une connexion */
	JUMP,				/* On est en phase de changement de page */
	ENPG,				/* On est en ENTER PAGE: effectue initialisations */	
	DISP,				/* On est en phase d'affichage … l'‚cran */
	OPDB,				/* Phase de recherche/ouverture base de donn‚es */
	OTXT,				/* Phase de recherche/ouverture texte */
	DDAT,				/* Phase d'affichage de donn‚es */
	DREC,				/* Phase d'affichage d'un nouveau message */
	DPAG,				/* Phase d'affichage d'une page de message */
	DWLD,				/* Download, Protocole USLTP en cours */
	EFLD,				/* On entre ds un champ */
	CPOS,				/* Repositionnement curseur pour continuer ‚dition */
	CLRF				/* Clear Field (pour nouvelle ‚dition) */
};
		

/*
 * Tranche de temps pour traitement d'une voie:
 */
#define 	TIMESLICE 	(CLK_TCK *100 /100);		/* 100 100Šmes de Seconde */
                                             
                                             
/*
 * Dur‚e de timeout pour les acquitements:
 */
#define	ACQ_TIMEOUT	(CLK_TCK *7);				/* 7 Secondes */
                                             
                                             
/* 
 * Dur‚e de timeout connexion:
 *
 * Notes:
 * ------
 * Attention, il y a un Timeout "hard" dans le Minitel:
 * 40 secondes sur un Minitel 1B
 * 90 secondes sur un Minitel 2
 * Si ce timeout "hard" est d‚pass‚ on recevra un "Echec connexion"
 * Si on force une d‚co avant timeout hard sur M2, 
 * on se retrouve en mode prise de ligne!
 */
#define	CNCT_TIMEOUT	(CLK_TCK *15);				/* 15 Secondes */

/*
 * Edition:
 */
	#define	PARAGRAPH_CONT		'-'
	#define	PARAGRAPH_STOP		'Ý'
	

/* 
 * Codes pour action progress:
 *
 * Purpose:
 * --------
 * utilisés dans les procedures du type connexion ou on attend
 * des acquitements
 */ 
typedef
	enum
	{
		APG_NONE,				/* Pas d'action en cours */
	/* Connexion: */
		APG_CNXSTART,			/* Debut d'un proc‚dure de connexion */
		APG_SPEED,				/* Vitesse modem OK */			
		APG_PORTEUSE,			/* Porteuse envoy‚e */
	/* D‚connexion: */
		APG_PHASE_DECO			/* On entre en phase de d‚connexion */
	}
	ACTPGRS;
	       
	       
	
typedef
	enum
	{
		FLD_NOT_FOUND, 
		FLD_DISABLED,
		FLD_READY
	}
	FLD_STATUS;

	
/*
 * IOFIELD: Champ de saisie d'une voie 
 *
 * 21.08.94: fplanque: Created
 * 05.12.94: introduction du double chainage pour traitement SUITE/RETOUR
 * 18.12.94: changed from INfield to IOfield
 */
typedef
	struct	infield
	{
		struct infield	*	p_next;				/* Ptr sur champ suivant */
		struct infield	*	p_prev;				/* Ptr sur champ pr‚c‚dent */
		union
		{
			OUTPUT_FPAR	*		Output;				/* Champ de sortie */
			INPUT_FPAR	*		Input;				/* Champ de saisie */
		}						FPar;
		TEXTINFO			*	pTextInfo;			/* Buffers de saisie du texte tap‚ */
		TEXTLINE			*	pTextLine_Top;		/* Ligne en haut de la zone d'affichage du champ */
		long					l_TopLine;			/* No de la TopLine; au d‚but: 1 (et pas0!) */
	}
	IOFIELD;

	
/*
 * VOIESTATE: Etats d'une voie
 */
typedef
	struct
	{
		int		log_modemcnx	:	1;		/* Modem connect‚ logiquement */
		int		phys_modemcnx	:	1;		/* Modem connect‚ physiquement */
		UINT		n_speed			:	4;		/* Code vitesse; 0: local; 1: connect‚; 15: inconnue */
	}
	VOIESTATE;   


/*
 * ACTION: Id d'une action a effectuer dans la liste d'attente avec
 *         ses paramŠtres:
 */
typedef
	struct
	{
		int		no;			/* no de l'action */
		int		int1;			/* paramŠtres INT */
		int		int2;
		ULONG		ulong1;		/* ParamŠtres UNSIGNED LONG */
		void *	ptr1;			/* ParamŠtres pointeurs */
	}
	ACTION;


/*
 * Sert … maintenir une liste des records sur lesquels on a un ReadLock
 */
typedef
	struct	CompRec_ListElt
	{
		struct CompRec_ListElt * 	pCRListElt_next;
		COMPACT_RECORD			  *	pCompRec;
	}
	COMPREC_LISTELT;


	
/*
 * VOIE: Toutes les informations utiles à une VOIE du serveur
 * 
 * 13.11.94: ajout fnct champ d‚dition et infos cnt
 * 05.12.94: suppressed infield_index
 * 05.01.94: ACTION prend params / dispartion des champs 'next'
 */
#define	NB_ACTS_MAX	20				/* Nbre maximum d'entrees dans la */
											/* liste des taches a effectuer par */
											/* cette voie */
typedef
	struct		voie
	{
		/*
		 * -------------------
		 * Attributs g‚n‚raux:
		 * -------------------
		 */
		struct voie	*	next;			/* Ptr sur voie suivante */
		int				no_voie;		/* Num‚ro de la voie */
		int				device;		/* No du driver de P‚riph‚rique de communication (No type= AUX) */
		int				mode;			/* Mode de fonctionnement */
		WIPARAMS		*	wi_params;	/* Params fenˆtre associ‚e */

		/*
		 * --------
		 * Service:
		 * --------
		 */
		VOIESTATE	state;					/* Etats de la voie */

		DATADIR	*	arbodir;					/* Dossier arbo dans lequel on se situe */
		DATAPAGE	*	arbopage;				/* Page arbo sur laquelle on se situe */
		PAGEARBO	*	arboparams;				/* ParamŠtres de cette page */

		int			action_head;			/* No Action en cours */
		int			action_tail;			/* No de la derniŠre action */
		ACTION		action[NB_ACTS_MAX];	/* Liste des actions … effectuer */
		
		/*
		 * ----------------------
		 * Affichage pages ‚cran: 
		 * ----------------------
		 */
		DATADIR			*	pecrandir;		/* Dossier dans lequel on doit chercher les pages ‚cran */

		/*
		 * --------
		 * Donn‚es: 
		 * --------
		 * Il faudra bientot plusieurs pointeurs sur 'database' qd il y a plusieurs bases ouvertes simultan‚ment
		 */
		DATADIR			*	pDataDir_Datas;		/* Dossier dans lequel on doit chercher les bases de donn‚es */
		DATAPAGE			*	database;				/* Base de donn‚es concern‚e */

		COMPACT_RECORD	*	curr_comprec;			/* Enregistrement compact en cours de consultation */
		COMPACT_RECORD ** pTCompRec_ptrs;		/* Tableau de pointeurs vers tous les Compact-Records ref‚renc‚s sur la page courante */

		COMPREC_LISTELT*	pCRLstElt_1stRLock;	/* Liste des readlocks */
		COMPACT_RECORD	*	pCompRec_XLock;		/* Enregistrement sur lequel on d‚tient un lock EXCLUSIF! */

		int					nb_MaxDisplayedRecs;	/* Nb max de records pouvant etre affich‚s sur une page == nbre d'entr‚es dans pTCompRec_ptrs */
		int					nb_DisplayedRecs;		/* Nombre de records affich‚s sur page courante */
		int					n_RecIndex_Top;		/* Index de record en haut de la liste (si ya plusieurs recs sur un ‚cran) */
		int					n_RecIndex_Curr;		/* Index de record courant */

		int					n_PageNumber_Curr;	/* No de la page courante */

		/*
		 * Donn‚es ...Directory courant charg‚ en m‚moire:
		 */
		DIRENTRY 		**	TpDirEnt;				/* Tableau de ptrs sur entr‚es de Dir ou NULL */
		int					nb_TableEnt;			/* Nbre d'entr‚es ds tableau */
		int					nb_DirEnt;				/* Nbre d'entr‚es utilis‚es ds dir courant */
		char				*	pMsz_Path;				/* Chemin d'accŠs courant (Initialis‚ uniquement en fin de cnx) */
		

		/*
		 * -------
		 * Textes: 
		 * -------
		 */
		DATADIR			*	pDataDir_Texts;		/* Dossier dans lequel on doit chercher les textes */
		DATAPAGE			*	pDataPage_OpenText;	/* texte actuellement ouvert */


		/*
		 * ----------------------
		 * Affichage des donn‚es:
		 * ----------------------
		 */
		OUTPUT_FPAR		*	pOutputFPar_CurrOut;	/* Ptr sur params d'affichage champ courany (scrollable) */
		IOFIELD			*	pIOField_CurrOut;		/* Ptr sur champ de sortie (scrollable) courant */					


		/*
		 * -------
		 * Saisie: 
		 * -------
		 */
		IOFIELD		*	pIOField_ListIn;	/* Liste des champs de saisie */
		IOFIELD		*	pIOField_CurrIn;	/* Ptr sur Champ d'‚dition courant */	

		int				csr_x, csr_y;		/* Coordonn‚es du curseur */
		int				curr_tcolor;		/* Couleur texte actuellement utilis‚e */
		TEXTLINE		*	curr_textline;		/* Ligne en cours d'‚dition */
		long				l_CurrLine;			/* No de ligne en cours */

		/*
		 * Nombre d'enregistrements cr‚‚s cons‚cutivement sur cette page 
		 * En g‚n‚ral, on posera une limite … un enregistrement/passage
		 * sur la meme page arbo 
		 */
		int			nb_records;			


		/*
		 * ----------------
		 * Entr‚es clavier: 
		 * ----------------
		 * Lorsque l'on re‡oit une s‚quence de caractŠres depuis le Minitel, 
		 * entete_seq prend la valeur du premier octet afin de le m‚moriser 
		 * jusqu'… r‚ception du suivant. En temps normal cette var vaut NIL 
		 */
		int			entete_seq;				
		/*
		 * Compteur du nombre de codes qu'il reste … recevoir  
		 * lors d'une s‚qeunce PRO 1, 2 ou 3   (En temps normal: 0) 
		 */
		int			pro_compte;				
		/*
		 * Code s‚quence CSI (En temps normal=NIL) 
		 */
		int			csi;						
		/*
		 * Code s‚quence de composition (En temps normal=NIL) 
		 */
		int			compose;					
		/*
		 * ACTPGRS : Progession de l'action en cours 
		 * (reception d'acquitements etc...) lors de la cnx, dcnx, etc...
		 */
		int			action_progress;		

		clock_t		acq_timeout;			/* "Heure" de timeout acquitements */
		clock_t		key_timeout;			/* "Heure" de timeout action courante */


		/*
		 * ------
		 * USLTP:
		 * ------
		 */
		USLTP_CTRLBLK * pUCtl;

		/*
		 * -----------------------------
		 * Informations sur le connect‚:
		 * -----------------------------
		 */
		char *	pMsz_Login;			/* Pseudo */
		char *	pMsz_FirstName;	/* Pr‚nom */
		char *	pMsz_LastName;		/* Nom */
		/*
		 * ------------
		 * 'Variables':
		 * ------------
		 */
		char	*	pMsz_VFile;		/* Fichier selectionne */


		/*
		 * ---------------------------------------
		 * ParamŠtres transmis … la page suivante:
		 * ---------------------------------------
		 */
		DATAPAGE			*	pDataPage_LockedDB_OUT;		/* Database contenant le COMPREC lock‚ … transmettre */
		COMPACT_RECORD	*	pCompRec_Locked_OUT;	
		/*
		 * -------------------------------------------
		 * ParamŠtres r‚cup‚r‚s de la page pr‚c‚dente:
		 * -------------------------------------------
		 */
		DATAPAGE			*	pDataPage_LockedDB_IN;		/* Database contenant le COMPREC lock‚ … transmettre */
		COMPACT_RECORD	*	pCompRec_Locked_IN;	
	}
	VOIE;
	

/*
 * Fin du test anti red‚finition:
 */
#endif
