/*
 * TOS_Errors.h
 *
 * Messages d'erreur du TOS: 
 */
 
/* Erreurs XBIOS: */
	#define	XERROR	-1		/* Erreur SystŠme */
	#define	XEDVRNR	-2		/* Drive Not Ready */
	#define	XEUNCMD	-3		/* UNknown CoMmanD */
	#define	XE_CRC	-4		/* Erreur CRC */
	#define	XEBARRQ	-5		/* Commande incorrecte */
	#define	XE_SEEK	-6		/* Piste introuvable */
	#define	XEMEDIA	-7		/* Format disquette incorrect */
	#define	XESECNF	-8		/* Secteur introuvable */
	#define	XEPAPER	-9		/* Pas de PAPIER dans l'imprimante */
	#define	XEWRITF	-10	/* Erreur durant l'‚criture */
	#define	XEREADF	-11	/* Erreur durant la lecture */
	#define	XE_GEN	-12	/* Erreur g‚n‚rale */
	#define	XEWPRO	-13	/* Disquette prot‚g‚e en ‚criture */
	#define	XE_CHNG	-14	/* Disquette chang‚e */

/* Erreurs BIOS: */
	#define	BEUNDEV	-15	/* UNknown DEVice: P‚riph‚rique inconnu */
	#define	BEBADSF	-16	/* Mauvais formattage */
	#define	BEOTHER	-17	/* Ins‚rer une autre disquette */

/* Erreurs GEMDOS: */
	#define	GEINVFN	-32	/* Invalid Function: Num‚ro fonction incorrect */
	#define	GEFILNF	-33	/* File Not Found */
	#define	GEPTHNF	-34	/* Path not found */
	#define	GENHNDL	-35	/* No handle: plus d'identificateur */
	#define	GEACCDN	-36	/* AccŠs Denied: AccŠs interdit */
	#define	GEIHNDL	-37	/* Invalid Handle: Handle invalide */
	#define	GENSHEM	-39	/* M‚moire insuffisante */
	#define	GEIMBA	-40	/* Invalid Memory Block Adress */
	#define	GEDRIVE	-46	/* Disque invalide */
	#define	GENMFIL	-49	/* No more file */
	#define	GERANGE	-64	/* Range error: rrreur de champ */
	#define	GEINTRN	-65	/* Internal Error (GEMDOS) */
	#define	GEPLFMT	-66	/* Fichier non executable */
	#define	GEGSBF	-67	/* Erreur accroissement bloc m‚moire */
