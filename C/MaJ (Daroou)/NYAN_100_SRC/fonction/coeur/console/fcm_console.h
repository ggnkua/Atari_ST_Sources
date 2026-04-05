/* *[Console]******************* */
/* *                           * */
/* * 01/01/2024 MaJ 29/11/2025 * */
/* ***************************** */



#ifndef ___CONSOLE_H___
#define ___CONSOLE_H___


#ifndef FCM_CONSOLE_MAXLIGNE
#error "fcm_console.h : FCM_CONSOLE_MAXLIGNE n'est pas defini !"
#endif
#ifndef FCM_CONSOLE_TEXTE_MAXLEN
#error "fcm_console.h : FCM_CONSOLE_TEXTE_MAXLEN n'est pas defini !"
#endif


/* Nombre MAX de ligne */
// #define FCM_CONSOLE_MAXLIGNE         (10/*1200*/)
/* Nombre MAX de caractere par ligne */
//#define FCM_CONSOLE_TEXTE_MAXLEN     (80)



#define FCM_CONSOLE_LARGEUR_MINI    (72) /* en pixel */
#define FCM_CONSOLE_HAUTEUR_MINI    (70)


/* buffer MACRO pour la transmission des messages Console */
#define FCM_CONSOLE_TEXTE_BUFLEN     (FCM_TAILLE_CHEMIN*2)
char Fcm_console_texte[FCM_CONSOLE_TEXTE_BUFLEN];


/* buffer pour mémoriser les messages Console (ré-entrance) */
#define FCM_CONSOLE_MESSAGE_SAVE_MAX (32)
char  Fcm_console_message_save[FCM_CONSOLE_MESSAGE_SAVE_MAX][FCM_CONSOLE_TEXTE_MAXLEN];
int16 Fcm_console_couleur_save[FCM_CONSOLE_MESSAGE_SAVE_MAX];


/* buffer pour générer les message appl_write() de redraw */
int16 console_aes[8];



/* on verifie la taille des buffers (gemlib)        */
/* le texte est affiché avec v_gtext(), qui utilise */
/* INTIN pour stocker le texte                      */
#if( VDI_INTINMAX < FCM_CONSOLE_TEXTE_MAXLEN )
#error "la longueur des lignes est superieur au tableau INTIN VDI"
#endif



typedef struct
{
    char   texte[FCM_CONSOLE_TEXTE_MAXLEN];
	int16  texte_lenght;
	int16  texte_color;
} s_CONSOLE_LIGNE;

s_CONSOLE_LIGNE Fcm_struct_console_texte[FCM_CONSOLE_MAXLIGNE];


typedef struct
{
	int16 ligne_active;
	int16 ligne_start;
	int16 lettre_start;
	int16 nbligne_visible;
	int16 nblettre_visible;
	int16 char_cellw;
	int16 char_cellh;
	int16 zone_w_max;
	int16 zone_h_max;
} s_CONSOLE_GLOBAL;

s_CONSOLE_GLOBAL Fcm_struct_console_global;



void  Fcm_console_init( void );
void  Fcm_console_clear( void );
void  Fcm_console_ouvre_fenetre( void );
void  Fcm_console_redraw( const GRECT *rd , const int16 index_tab_win);
void  Fcm_gestion_redraw_console( void );

void  Fcm_console_debug( char *texte );
void  Fcm_console_add( char *texte, int16 color );


void  Fcm_console_gestion_sized( void );
void  Fcm_console_gestion_widget( void );
void  Fcm_console_set_slider( void );

void  Fcm_console_display_stats( void );


/* from EmuTOS source portab.h   --- Merci --- */
/* This is grammatically equivalent to a call to a function which does nothing.
 * It is useful as placeholder in conditional macros, when there is nothing to
 * do. So such macros can safely be called in if / else / while / for contexts,
 * without any potential side effects regarding to the grammar.
 */
#ifndef NULL_FUNCTION
#define NULL_FUNCTION() do { } while (0)
#endif



/*#define FCM_DESACTIVE_MESSAGE_CONSOLE_ALL   (1)*/
/*#define FCM_DESACTIVE_MESSAGE_CONSOLE_ADD   (1)*/
/*#define FCM_DESACTIVE_MESSAGE_CONSOLE_DEBUG (1)*/




#ifdef FCM_DESACTIVE_MESSAGE_CONSOLE_ALL
#define FCM_DESACTIVE_MESSAGE_CONSOLE_ADD   (1)
#define FCM_DESACTIVE_MESSAGE_CONSOLE_DEBUG (1)
#endif


#ifdef FCM_DESACTIVE_MESSAGE_CONSOLE_ADD

#define FCM_CONSOLE_ADD(texte, color)                            NULL_FUNCTION()
#define FCM_CONSOLE_ADD2(texte,arg1, color)                      NULL_FUNCTION()
#define FCM_CONSOLE_ADD3(texte,arg1,arg2, color)                 NULL_FUNCTION()
#define FCM_CONSOLE_ADD4(texte,arg1,arg2,arg3, color)            NULL_FUNCTION()
#define FCM_CONSOLE_ADD5(texte,arg1,arg2,arg3,arg4, color)       NULL_FUNCTION()
#define FCM_CONSOLE_ADD6(texte,arg1,arg2,arg3,arg4,arg5, color)  NULL_FUNCTION()

#else

#define FCM_CONSOLE_ADD(texte, color)                            FCM_CONSOLE_ADD_TEXTE1(texte, color)
#define FCM_CONSOLE_ADD2(texte,arg1, color)                      FCM_CONSOLE_ADD_TEXTE2(texte,arg1, color)
#define FCM_CONSOLE_ADD3(texte,arg1,arg2, color)                 FCM_CONSOLE_ADD_TEXTE3(texte,arg1,arg2, color)
#define FCM_CONSOLE_ADD4(texte,arg1,arg2,arg3, color)            FCM_CONSOLE_ADD_TEXTE4(texte,arg1,arg2,arg3, color)
#define FCM_CONSOLE_ADD5(texte,arg1,arg2,arg3,arg4, color)       FCM_CONSOLE_ADD_TEXTE5(texte,arg1,arg2,arg3,arg4, color)
#define FCM_CONSOLE_ADD6(texte,arg1,arg2,arg3,arg4,arg5, color)  FCM_CONSOLE_ADD_TEXTE6(texte,arg1,arg2,arg3,arg4,arg5, color)
#endif





#ifdef FCM_DESACTIVE_MESSAGE_CONSOLE_DEBUG

#define FCM_CONSOLE_DEBUG(texte)                                 NULL_FUNCTION()
#define FCM_CONSOLE_DEBUG1(texte,arg1)                           NULL_FUNCTION()
#define FCM_CONSOLE_DEBUG2(texte,arg1,arg2)                      NULL_FUNCTION()
#define FCM_CONSOLE_DEBUG3(texte,arg1,arg2,arg3)                 NULL_FUNCTION()
#define FCM_CONSOLE_DEBUG4(texte,arg1,arg2,arg3,arg4)            NULL_FUNCTION()
#define FCM_CONSOLE_DEBUG5(texte,arg1,arg2,arg3,arg4,arg5)       NULL_FUNCTION()
#define FCM_CONSOLE_DEBUG6(texte,arg1,arg2,arg3,arg4,arg5,arg6)  NULL_FUNCTION()

#else

#define FCM_CONSOLE_DEBUG(texte)                                 FCM_CONSOLE_DEBUG_TEXTE(texte)
#define FCM_CONSOLE_DEBUG1(texte,arg1)                           FCM_CONSOLE_DEBUG_TEXTE1(texte,arg1)
#define FCM_CONSOLE_DEBUG2(texte,arg1,arg2)                      FCM_CONSOLE_DEBUG_TEXTE2(texte,arg1,arg2)
#define FCM_CONSOLE_DEBUG3(texte,arg1,arg2,arg3)                 FCM_CONSOLE_DEBUG_TEXTE3(texte,arg1,arg2,arg3)
#define FCM_CONSOLE_DEBUG4(texte,arg1,arg2,arg3,arg4)            FCM_CONSOLE_DEBUG_TEXTE4(texte,arg1,arg2,arg3,arg4)
#define FCM_CONSOLE_DEBUG5(texte,arg1,arg2,arg3,arg4,arg5)       FCM_CONSOLE_DEBUG_TEXTE5(texte,arg1,arg2,arg3,arg4,arg5)
#define FCM_CONSOLE_DEBUG6(texte,arg1,arg2,arg3,arg4,arg5,arg6)  FCM_CONSOLE_DEBUG_TEXTE6(texte,arg1,arg2,arg3,arg4,arg5,arg6)

#endif


/* Ne pas utiliser la fonction directement, la chaine est modifié dans */
/* Fcm_console_add() pour retirer la commande NOCRLF                   */
/* Sinon c'est la chaine texte dans le programme qui va etre modifié   */
#define FCM_CONSOLE_DEBUG_TEXTE(texte) \
{ \
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, texte" "CRLF ); \
	Fcm_console_texte[ (FCM_CONSOLE_TEXTE_MAXLEN-1) ] = 0; \
	Fcm_console_debug( Fcm_console_texte ); \
} \
NULL_FUNCTION()

#define FCM_CONSOLE_DEBUG_TEXTE1(texte, arg1 ) \
{ \
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, texte" "CRLF, arg1 ); \
	Fcm_console_texte[ (FCM_CONSOLE_TEXTE_MAXLEN-1) ] = 0; \
	Fcm_console_debug( Fcm_console_texte ); \
} \
NULL_FUNCTION()

#define FCM_CONSOLE_DEBUG_TEXTE2(texte, arg1, arg2 ) \
{ \
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, texte" "CRLF, arg1, arg2 ); \
	Fcm_console_texte[ (FCM_CONSOLE_TEXTE_MAXLEN-1) ] = 0; \
	Fcm_console_debug( Fcm_console_texte ); \
} \
NULL_FUNCTION()

#define FCM_CONSOLE_DEBUG_TEXTE3(texte, arg1, arg2, arg3 ) \
{ \
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, texte" "CRLF, arg1, arg2, arg3 ); \
	Fcm_console_texte[ (FCM_CONSOLE_TEXTE_MAXLEN-1) ] = 0; \
	Fcm_console_debug( Fcm_console_texte ); \
} \
NULL_FUNCTION()

#define FCM_CONSOLE_DEBUG_TEXTE4(texte, arg1, arg2, arg3, arg4 ) \
{ \
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, texte" "CRLF, arg1, arg2, arg3, arg4 ); \
	Fcm_console_texte[ (FCM_CONSOLE_TEXTE_MAXLEN-1) ] = 0; \
	Fcm_console_debug( Fcm_console_texte ); \
} \
NULL_FUNCTION()

#define FCM_CONSOLE_DEBUG_TEXTE5(texte, arg1, arg2, arg3, arg4, arg5 ) \
{ \
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, texte" "CRLF, arg1, arg2, arg3, arg4, arg5 ); \
	Fcm_console_texte[ (FCM_CONSOLE_TEXTE_MAXLEN-1) ] = 0; \
	Fcm_console_debug( Fcm_console_texte ); \
} \
NULL_FUNCTION()

#define FCM_CONSOLE_DEBUG_TEXTE6(texte, arg1, arg2, arg3, arg4, arg5, arg6 ) \
{ \
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, texte" "CRLF, arg1, arg2, arg3, arg4, arg5, arg6 ); \
	Fcm_console_texte[ (FCM_CONSOLE_TEXTE_MAXLEN-1) ] = 0; \
	Fcm_console_debug( Fcm_console_texte ); \
} \
NULL_FUNCTION()








/* idem remarque que pour FCM_CONSOLE_DEBUG_TEXTE ci-dessus */
#define FCM_CONSOLE_ADD_TEXTE1(texte, color ) \
{ \
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, texte""CRLF ); \
	Fcm_console_texte[ (FCM_CONSOLE_TEXTE_MAXLEN-1) ] = 0; \
	Fcm_console_add( Fcm_console_texte, color ); \
} \
NULL_FUNCTION()

#define FCM_CONSOLE_ADD_TEXTE2(texte, arg1, color ) \
{ \
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, texte""CRLF, arg1 ); \
	Fcm_console_texte[ (FCM_CONSOLE_TEXTE_MAXLEN-1) ] = 0; \
	Fcm_console_add( Fcm_console_texte, color ); \
} \
NULL_FUNCTION()

#define FCM_CONSOLE_ADD_TEXTE3(texte, arg1, arg2, color ) \
{ \
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, texte""CRLF, arg1, arg2 ); \
	Fcm_console_texte[ (FCM_CONSOLE_TEXTE_MAXLEN-1) ] = 0; \
	Fcm_console_add( Fcm_console_texte, color ); \
} \
NULL_FUNCTION()

#define FCM_CONSOLE_ADD_TEXTE4(texte, arg1, arg2, arg3, color ) \
{ \
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, texte""CRLF, arg1, arg2, arg3 ); \
	Fcm_console_texte[ (FCM_CONSOLE_TEXTE_MAXLEN-1) ] = 0; \
	Fcm_console_add( Fcm_console_texte, color ); \
} \
NULL_FUNCTION()

#define FCM_CONSOLE_ADD_TEXTE5(texte, arg1, arg2, arg3, arg4, color ) \
{ \
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, texte""CRLF, arg1, arg2, arg3, arg4 ); \
	Fcm_console_texte[ (FCM_CONSOLE_TEXTE_MAXLEN-1) ] = 0; \
	Fcm_console_add( Fcm_console_texte, color ); \
} \
NULL_FUNCTION()

#define FCM_CONSOLE_ADD_TEXTE6(texte, arg1, arg2, arg3, arg4, arg5, color ) \
{ \
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, texte""CRLF, arg1, arg2, arg3, arg4, arg5 ); \
	Fcm_console_texte[ (FCM_CONSOLE_TEXTE_MAXLEN-1) ] = 0; \
	Fcm_console_add( Fcm_console_texte, color ); \
} \
NULL_FUNCTION()


/* --- exemple ---

 FCM_CONSOLE_ADD("Fcm_gestion_pop_up", G_GREEN);
 FCM_CONSOLE_DEBUG("Syntaxe error lol");

*/




#endif  /*  ___CONSOLE_H___  */

