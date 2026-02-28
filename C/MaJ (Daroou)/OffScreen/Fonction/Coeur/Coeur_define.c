/*-[Fonction communes]--------------*/
/*                                  */
/* 11/05/2002           02/03/2015  */
/*----------------------------------*/


#ifndef  __FCM_DEFINE_COEUR__
 #define __FCM_DEFINE_COEUR__



#define COEUR_VERSION	"3.06"


/* -- Define pour la gestion fenetre -- */
#define FCM_NO_MY_WINDOW	NB_FENETRE		/* ??? … modifier */
#define FCM_NO_OPEN_WINDOW	(-1)
#define FCM_GO_OPEN_WINDOW	(-2)
#define FCM_NO_WINPOS		(-1)
/*#define FCM_NO_QUIT_CLOSEIN (-1)*/



#define FCM_NO_RSC_DEFINED	(-1)
#define FCM_NO_DIALOGUE		(-2)



#define FCM_WU_BLOCK		(0)
#define FCM_WU_NO_BLOCK		NO_BLOCK

#define FCM_BT_PAUSE_DOWN	(200)
#define FCM_BT_PAUSE_UP		 (50)

#define FCM_TASK_TIMER		(TASK_TIMER/5) /* TASK_TIMER defini dans l'application */


#define FCM_CLOSE_ALL_WIN	(9999)

#define FCM_NO_WIN_RSC		(-1)

#define FCM_MOUSE_THROUGH		(TRUE)
#define FCM_NO_MOUSE_THROUGH	(FALSE)

#define FCM_NO_OBJET_FOUND		(-1)	/* no objet width objc_find() */

#define FCM_FONCTION_NON_DEFINI	((void *)0)




#define FCM_NOINDEX_ALLICONIFIED	(-1)




#define ARGV_MAX_ARGUMENT	(128)


#define W_LAUNCH				(0)
#define W_INFO_PRG				(1)
#define	W_OPTION_PREFERENCE		(2)




#define EVENT_BCLICK	(258)





#define TAILLE_BUFFER	(512)
#define TAILLE_CHEMIN	(256)
#define TAILLE_FICHIER	(256)


#define TAILLE_CHEMIN_CONFIG    (256)


#define CRLF			"\015\012"
#define TAB4			"    "
#define TAB8			"        "
#define TAB12			"            "
#define TAB16			"                "



#define SLASH			(92)


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
#define SET_BIT_W(field,bit,val) field = (val)?((field)|((UWORD)bit)):((field) & ~((UWORD)bit))
#endif

/*#ifndef __WINDOM__
#define ObjcString(a,b,c) ((a+b)->ob_spec.free_string)
#endif
*/



#define NO_FRAME			(0)
#define FRAME_ON			(1)

#define COOKIE_NOT_FOUND	(-1)



#define PALETTE_ON			(1)




/* VDI define */
#define CLIP_ON				(1)
#define CLIP_OFF			(0)


/* structure interne systeme define */
#define XBIOS_SOUND_MODE_STE_TT  (1)
#define XBIOS_SOUND_MODE_FALCON  (2)



#endif

