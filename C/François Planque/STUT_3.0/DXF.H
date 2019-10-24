/*
 * Dxf.h
 *
 * Structures de donn‚es de la norme DXF:
 *
 * Purpose:
 * --------
 * Ce fichier contient toutes les structures de donn‚es n‚cessaires
 * … la gestion de données par la norme Data eXchange Format.
 * 
 * Notes:
 * ------
 * Norme DXF by Fran‡ois PLANQUE & Xavier CANY:
 *
 *  	  FULC_DIFF
 *				|
 *  	 RECORD_DIFF
 *				|
 *		RECORD_NUMBER   RECORD_FLAGS
 *					  \		/
 * 				 HEAD_STRING      		  FOOT_STRING
 *          	 /	 		 \  			     	/
 *	 COMPACT_HEADER	      {RECORD_FIELD}
 *			 |        
 *  COMPACT_RECORD			 COMPACT_FIELD
 *			 |
 *	  DATA_RECORDS     
 */
               
/*
 * V‚rifie si les pr‚sentes d‚finitions ont d‚ja ‚t‚ faites:
 */
#ifndef _DXF_H_
#define _DXF_H_
               
   
   #include <time.h>            
             
/*
 * FULC_DIFF: Division d'un numero de differenciation d'un Record DXF:
 *
 * Notes:
 * ------
 * Division en 3 variables selon Fulchrom. Peut varier d'une implémentation
 * à l'autre de la norme.
 */
typedef
	struct
	{
		unsigned char			magic;		/* Choisissez votre num‚ro */
		unsigned char			repeat;		/* Au cas ou vous envoyez */
													/*	plusieurs messages … la */
													/*	mˆme seconde */
		int						random;		/* Nombre al‚atoire */
	}
	FULC_DIFF;
                                 
                                 
/*
 * RECORD_DIFF: Partie du numéro de différentiation d'un record DXF:
 */                        
typedef
	union
	{
		unsigned long			value;		/* Nombre anonyme */
		FULC_DIFF				fulc;			/* Exemple de gestion de Fulchrom */
	}
	RECORD_DIFF;
                                   
                                   
/*
 * RECORD_NUMBER: Num‚ro de diff‚rentiation global d'un record DXF:
 *
 * Purpose:
 * --------
 * Sert … distinguer n'importe quel record de n'importe quel autre
 * … l'‚chelle mondiale.
 *
 * Notes:
 * ------
 * Type qui va etre inclus 2 fois a RECORD_HEAD 
 */              
typedef						
	struct
	{
		time_t					date;			/* Date format **IX */
		RECORD_DIFF				diff;			/* No de diff‚renciation */
	} 
	RECORD_NUMBER;
   

/*
 * RECORD_FLAGS: Flags qualifiant l'enregistrement
 */
typedef
	struct
	{
		BOOL	b_Private	:	1;		/* Le message est priv‚ (le dest est ds DSTA par exemple) */
		int	n_Junk		:	15;	/* Mettre tout ‡a … 0 */
	}
	RECORD_FLAGS;
	
               
/*
 * HEAD_STRING: HEADER d'un record DXF 
 */
typedef		
	struct
	{
		unsigned long			rec_length;	/* Long totale record */
				/* (Utile lorsque l'on sauve ou qu'on charge sur disque) */
				/* Permet egalement de supprimer ou d'ajouter des infos */
		RECORD_NUMBER			rec_idnb;	/* Num‚ro d'identification de l'enregistrement */
		RECORD_NUMBER			ref_idnb;	/* Num‚ro d'identif de la r‚f‚rence */
		RECORD_FLAGS			RecFlags;	/* Flags qualifiant l'enregistrement */
	}
	HEAD_STRING;


/*
 * FOOT_STRING: FOOTER d'un record DXF 
 *
 * Suggest:
 * --------
 * Inclure un CRC16 ou CRC32 Check optionnel
 */
typedef		/* Chaine du FOOTER */
	struct
	{
		unsigned	int			checksum;	/* Checksum */
	}
	FOOT_STRING;
                                

/*
 * RECORD_FIELD: Champ d'un record DXF NON COMPACTE
 * AVEC pointeur NEXT
 */
typedef
	struct	record_field
	{
		struct record_field	*	next;			/* Pointeur sur le prochain champ */
		unsigned long				field_id;	/* Type de champ */
		size_t						length;		/* Longueur du champ */
		union											/* Informations utiles */
		{
			HEAD_STRING		*	head;		/* Info header */
			unsigned	char	*	string;	/* chaine pple du champ */					
			FOOT_STRING		*	foot;
		}								info;
	}
	RECORD_FIELD;
                  

/*
 * COMPACT_HEADER: HEADER de Record DXF sous forme compacte:
 *
 * Purpose:
 * --------
 * L'arrangement des donn‚es est ici telles qu'on les trouve
 * sur disque... 
 * Permet de lire le d‚but d'un record sur disque et de d‚terminer
 * la taille m‚moire n‚cessaire pour le stocker sous forme de
 * COMPACT_RECORD
 */
typedef
	struct
	{
		unsigned	long					head_id;			/* Contient 'HEAD' */
		unsigned long					head_length;	/* Longueur du header */
		HEAD_STRING						header;			/* Header */
	}
	COMPACT_HEADER;
                


/*
 * COMPACT_FIELD: Champ d'un record DXF COMPACTE
 * Suggest: remplacer tous les compact_headers par ‡a!
 * UNKNOWN SIZE @ COMPILATION
 */
typedef
	struct
	{
		ULONG		UL_FieldId;			/* Type de champ */
		size_t	size_FieldLen;		/* Longueur du champ */
		UBYTE		bytes[];		/* Contenu du champ */
	}
	COMPACT_FIELD;

               
/*
 * COMPACT_RECORD: Record DXF sous forme compacte:
 *
 * Purpose:
 * --------
 * L'arrangement des données est ici telles qu'on les trouve
 * sur disque... Chargement/sauvegarde rapides
 * Les FIELDS sont les uns à la suite des autres.
 * Pointeur vers l'avant et l'arriere pour recherche.
 *
 * History:
 * --------
 * 17.05.94: fplanque: ajout des ReadLocks
 * 18.11.94: d‚plac‚ l'union data de taille VARIABLE … la fin... obligatoire ‡a!
 */
typedef
	struct	compact_record
	{
		struct	compact_record		*prev;			/* Record Pr‚c‚dent */
		struct	compact_record		*next;			/* Record Suivant */
		struct	s_reclocks
			{
			int	nb_ReadLocks	: 15;					/* Nbre de Locks partag‚s sur cet enregistrement */
			int	b_XLock			: 1;					/* !=0 s'il existe un XLock sur ce champ */
			}								locks;
		union
			{
			COMPACT_HEADER			header;				/* Header compact‚ (to be removed sooner or later) */
			COMPACT_FIELD			CompactField;		/* Champ compact‚ */
			char						compact_rec[];		/* Message compact‚ UNKNOWN SIZE AT COMPILATION */
			}								data;
	}	
	COMPACT_RECORD;
                                  

/*
 * DATA_RECORDS: Point d'entr‚e d'une liste chainee de records DXF
 *
 * Purpose:
 * --------
 * AccŠs … une base de donn‚es en m‚moire sous forme d'une liste
 * chaŒn‚e de COMPACT_RECORD 
 */                                  
typedef
	struct
	{
		long					nb_records;		/* Nbre d'enregistrements */
		COMPACT_RECORD		*first_record;	/* 1er enregistrement */
		COMPACT_RECORD		*last_record;	/* dernier enregistrement */
	}
	DATA_RECORDS;
           

/*
 * Fin du test anti red‚finition:
 */
#endif
                       