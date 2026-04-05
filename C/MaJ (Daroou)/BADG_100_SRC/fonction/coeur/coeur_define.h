/*-[Coeur application]----------------------------*/
/*                                                */
/* Define concernant le coeur des applications    */
/* 11/05/2002    MaJ 29/11/2025                   */
/*------------------------------------------------*/


#ifndef __COEUR_DEFINE_H__
#define __COEUR_DEFINE_H__


#define FCM_COEUR_VERSION	"3.11"          /* version du coeur */


/* Define pour Evnt_Multi() */
#define FCM_EVENT_MBCLICKS (258)
#define FCM_EVENT_MBMASK   (3)
#define FCM_EVENT_MBSTATE  (0)




/* Define pour gestion fenetre */
/* --------------------------- */



/* index des id de fenetres du coeur */
/* --------------------------------- */
#define W_DIALTEMP          (0) /* Pour les dialogues en fenetre provisoire, Select pixel format par exemple */
#define W_LAUNCH            (1) /* fenetre de lancement si elle est utilise */
#define W_INFO_PRG          (2) /* fenetre info programme */
#define	W_OPTION_PREFERENCE (3) /* option preference du coeur de l'application */
#define	W_CONSOLE           (4) /* console en fenetre */
#define	W_POPUP             (5) /* PopUP en fenetre */
#define	W_FORM_ALERT        (6) /* Form Alerte en fenetre */


/* Pour la fonction Fcm_ouvre_fenetre_start() afin qu'elle ne tente pas d'ouvrir */
/* les index win qui ne doivent pas etre ouvert automatiquement, */
/* les index de W_CONSOLE <- à -> W_COEUR_END ne sont pas ouvert auto */
#define	W_COEUR_END         (9) /* dernier index reservé au coeur */

/* index de depart pour l'application */
#define	FCM_W_INDEX_APP_START  (W_COEUR_END+1)





#define FCM_NO_MY_WINDOW	   NB_FENETRE	   /* signification dans Fcm_get_indexwindow(), defini par l'application */

#define FCM_NO_OPEN_WINDOW	   (-1)            /* pas de fenetre */
#define FCM_GO_OPEN_WINDOW	   (-2)            /* la fenetre doit etre ouverte (au demarrage de l'appli) */

#define FCM_NO_WINPOS		   (-9999)            /* pas de parametre fenetre, valeur par defaut */




#define FCM_NO_RSC_DEFINED	(-1)   /* pas de RSC dans la fenetre */
/*#define FCM_NO_WIN_RSC		(FCM_NO_RSC_DEFINED)*/ /* ancienne appelation, reste presente en local */
#define FCM_NO_WIN_TITRE	(-1)   /* pas de titre defini pour la fenetre */



#define FCM_WU_BLOCK		(0)
#define FCM_WU_NO_BLOCK		(NO_BLOCK)	   /* NO_BLOCK defini dans include/mt_gem.h */

#define FCM_BT_PAUSE_DOWN	(100)
#define FCM_BT_PAUSE_UP		 (50)


/* abandonné */
/*#define FCM_TASK_TIMER		(TASK_TIMER/5)*/ /* TASK_TIMER defini dans l'application */


#define FCM_CLOSE_ALL_WIN	(9999)      /* valeur special pour fermer toutes les fenetres */




/* -- gestion du clic souris fenetre -- */
#define FCM_MOUSE_THROUGH		(TRUE)     /* l'evenement souris doit toujours etre transmis a la fonction de gestion de la fenetre */
#define FCM_NO_MOUSE_THROUGH	(FALSE)    /* l'evenement souris doit etre transmis que si un objet est la cible du clic */

#define FCM_NO_OBJET_FOUND		(-1)	   /* no objet found width objc_find() */


#define FCM_FONCTION_NON_DEFINI	((void *)0) /* valeur par defaut des tableaux de fonction */


/*#define FCM_NOINDEX_ALLICONIFIED	(-1) */   /* ??? plus ou jamais utilisé ... */









/*#define TAILLE_BUFFER	(512)*/ /* a supprimer, chaque fonction doit creer son buffer avec une taille adequate */




#define FCM_TAILLE_CHEMIN	(256)
#define FCM_TAILLE_FICHIER	(128) /* ??? a reduire apres verification des fonctions qui l'utilise */


#define FCM_TAILLE_CHEMIN_COURANT   FCM_TAILLE_CHEMIN
#define FCM_TAILLE_CHEMIN_CONFIG    FCM_TAILLE_CHEMIN



/* a modifier => placer dans un autre fichier ??? ( MACRO ??? ) */
#define CRLF			"\015\012"
#define CR				"\015"
#define LF				"\012"
#define TAB4			"    "
#define TAB8			"        "
#define TAB12			"            "
#define TAB16			"                "

#define SLASH			(92)



/* a modifier => placer dans un autre fichier ??? ( MACRO ??? ) */
#ifndef MIN
#define MIN(x,y) 		( ((x)>(y))?(y): (x) )
#endif
#ifndef MAX
#define MAX(x,y) 		( ((x)>(y))?(x): (y) )
#endif
#ifndef ABS
#define ABS(x)			( ((x)> 0) ?(x):-(x) )
#endif

/*#ifndef SET_BIT
#define SET_BIT(field,bit,val) field = (val)?((field)|(bit)):((field) & ~(bit))
#endif*/

#ifndef SET_BIT_W
//#define SET_BIT_W(field,bit,val) field = ((uint16)val)?(((uint16)field)|((uint16)bit)):(((uint16)field) & ~((uint16)bit))
#define SET_BIT_W(field,bit,val) field = (val)?((field)|(bit)):((field) & (uint16)(~(bit)))
#endif

#ifndef CLEAR_BIT_W
#define CLEAR_BIT_W(field,bit) field = field & (uint16)(~bit)
#endif




/* VDI define */
/* a modifier => placer dans un autre fichier ??? ( MACRO ??? ) */
#define CLIP_ON				(1)
#define CLIP_OFF			(0)


/* define pour Fcm_systeme.xbios_sound_mode */
/* a modifier => FCM_xxx ??? */
#define XBIOS_SOUND_MODE_STE_TT  (1)
#define XBIOS_SOUND_MODE_FALCON  (2)


/* from EmuTOS 'portab.h', merci ! */
#define UNUSED(x)       (void)(x)               /* Unused variable         */
#define MAYBE_UNUSED(x) UNUSED(x)               /* Maybe unused variable   */


#ifndef EXIT_SUCCESS
#define EXIT_SUCCESS 0
#endif



/* indique qu'il faut utiliser le nombre de plan de l'ecran */
/* pour les MFDB */
#define FCMGFX_SCREEN_NBPLAN   (0)



#endif /*  __COEUR_DEFINE_H__  */

