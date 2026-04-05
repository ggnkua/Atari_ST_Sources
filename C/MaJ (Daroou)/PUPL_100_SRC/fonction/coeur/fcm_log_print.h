

#define BUF_LOG_SIZE (512+128)

void  log_print	( const int16 mode );


#ifdef LOG_FILE
  char texte[160]="";   /* affichage barbare sur l'‚cran a virer, reste encore quelque trace ci et là ... */
  char buf_log[BUF_LOG_SIZE]=""; /* pour sortie fichier LOG_FILE.TXT */
#endif


/* from EmuTOS source portab.h   --- Merci --- */
/* This is grammatically equivalent to a call to a function which does nothing.
 * It is useful as placeholder in conditional macros, when there is nothing to
 * do. So such macros can safely be called in if / else / while / for contexts,
 * without any potential side effects regarding to the grammar.
 */
#ifndef NULL_FUNCTION
#define NULL_FUNCTION() do { } while (0)
#endif


#ifdef LOG_FILE
#define FCM_LOG_PRINT(texte)                      FCM_LOG_PRINT_MAKE(texte)
#define FCM_LOG_PRINT1(texte,arg1)                FCM_LOG_PRINT_MAKE1(texte, arg1)
#define FCM_LOG_PRINT2(texte,arg1,arg2)           FCM_LOG_PRINT_MAKE2(texte, arg1, arg2)
#define FCM_LOG_PRINT3(texte,arg1,arg2,arg3)      FCM_LOG_PRINT_MAKE3(texte, arg1, arg2, arg3)
#define FCM_LOG_PRINT4(texte,arg1,arg2,arg3,arg4) FCM_LOG_PRINT_MAKE4(texte, arg1, arg2, arg3, arg4)
#define FCM_LOG_PRINT5(texte,arg1,arg2,arg3,arg4,arg5) FCM_LOG_PRINT_MAKE5(texte, arg1, arg2, arg3, arg4, arg5)
#define FCM_LOG_PRINT6(texte,arg1,arg2,arg3,arg4,arg5,arg6) FCM_LOG_PRINT_MAKE6(texte, arg1, arg2, arg3, arg4, arg5, arg6)
#else
#define FCM_LOG_PRINT(texte)                      NULL_FUNCTION()
#define FCM_LOG_PRINT1(texte,arg1)                NULL_FUNCTION()
#define FCM_LOG_PRINT2(texte,arg1,arg2)           NULL_FUNCTION()
#define FCM_LOG_PRINT3(texte,arg1,arg2,arg3)      NULL_FUNCTION()
#define FCM_LOG_PRINT4(texte,arg1,arg2,arg3,arg4) NULL_FUNCTION()
#define FCM_LOG_PRINT5(texte,arg1,arg2,arg3,arg4,arg5) NULL_FUNCTION()
#define FCM_LOG_PRINT6(texte,arg1,arg2,arg3,arg4,arg5,arg6) NULL_FUNCTION()
#endif


/* MACRO pour logger un texte sans parametre */
#define FCM_LOG_PRINT_MAKE(texte) \
	snprintf( buf_log, BUF_LOG_SIZE, texte""CRLF ); \
	log_print(FALSE); \
	NULL_FUNCTION()

/* MACRO pour logger un texte avec 1 parametre */
#define FCM_LOG_PRINT_MAKE1(texte, arg1) \
	snprintf( buf_log, BUF_LOG_SIZE, texte""CRLF, arg1 ); \
	log_print(FALSE); \
	NULL_FUNCTION()

/* MACRO pour logger un texte avec 2 parametre */
#define FCM_LOG_PRINT_MAKE2(texte, arg1, arg2) \
	snprintf( buf_log, BUF_LOG_SIZE, texte""CRLF, arg1, arg2 ); \
	log_print(FALSE); \
	NULL_FUNCTION()

/* MACRO pour logger un texte avec 3 parametre */
#define FCM_LOG_PRINT_MAKE3(texte, arg1, arg2, arg3) \
	snprintf( buf_log, BUF_LOG_SIZE, texte""CRLF, arg1, arg2, arg3); \
	log_print(FALSE); \
	NULL_FUNCTION()

/* MACRO pour logger un texte avec 4 parametre */
#define FCM_LOG_PRINT_MAKE4(texte, arg1, arg2, arg3, arg4) \
	snprintf( buf_log, BUF_LOG_SIZE, texte""CRLF, arg1, arg2, arg3, arg4); \
	log_print(FALSE); \
	NULL_FUNCTION()

/* MACRO pour logger un texte avec 5 parametre */
#define FCM_LOG_PRINT_MAKE5(texte, arg1, arg2, arg3, arg4, arg5) \
	snprintf( buf_log, BUF_LOG_SIZE, texte""CRLF, arg1, arg2, arg3, arg4, arg5); \
	log_print(FALSE); \
	NULL_FUNCTION()

/* MACRO pour logger un texte avec 6 parametre */
#define FCM_LOG_PRINT_MAKE6(texte, arg1, arg2, arg3, arg4, arg5, arg6) \
	snprintf( buf_log, BUF_LOG_SIZE, texte""CRLF, arg1, arg2, arg3, arg4, arg5, arg6); \
	log_print(FALSE); \
	NULL_FUNCTION()
/* fin MACRO */






/* exemple: FCM_LOG_PRINT( "xxxxxxxxxxx" ); */
