/* **[NyanCat]****************** */
/* *                           * */
/* * Define                    * */
/* * 20/08/2014 MaJ 14/03/2026 * */
/* ***************************** */

#define	PRG_VERSION		"1.00"
//#define	PRG_ANNEE		"2024"
//#define	PRG_DATE		"Mars " PRG_ANNEE

#define	PRG_FULL_NOM	"NyanCat"
#define	PRG_TITRE_INFO	PRG_FULL_NOM

#define	PRG_NOM			"NYANCAT"
#define	RSC_NOM			PRG_NOM ".RSC"
#define	INF_NOM			PRG_NOM ".INF"

#define	APP_WIN_PREFIX_TITRE "NyanCat"



#define TAILLE_CHEMIN_DATA (FCM_TAILLE_CHEMIN)


#define TASK_TIMER		(2000)


/* Nombre MAX de ligne */
#define FCM_CONSOLE_MAXLIGNE         (10)
/* Nombre MAX de caractere par ligne */
#define FCM_CONSOLE_TEXTE_MAXLEN     (80)



/* Local window index */
/* Les index 0 a (FCM_W_INDEX_APP_START-1) sont réservé pour le coeur */

/* indique au coeur que l'appli a modifié les index, sinon arret de la compilation */
/* un ancien code avec index de fenetre statique va ecraser les index du coeur     */
#define FCM_W_INDEX_APP_START_APPLI_UPDATED    

#define	W_NYANCAT				(FCM_W_INDEX_APP_START+0)
#define	W_OPTIONS				(FCM_W_INDEX_APP_START+1)

#define NB_FENETRE				(FCM_W_INDEX_APP_START+2)

