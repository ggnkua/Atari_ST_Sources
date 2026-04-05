/*******************************************************************/
/*                                                                 */
/*                      MOD.LDG  version 0.10a                     */
/*                                                                 */
/*                                                                 */
/*  (c)2003 Jean-Marc Stocklausen / Renaissance        29.12.2003  */
/*                                                                 */
/*******************************************************************/

#ifndef  __MOD_LDG__
 #define __MOD_LDG__



 /* Quelques D‚fines */
 #ifndef	TRUE
  #define	TRUE	1
 #endif

 #ifndef FALSE
  #define	FALSE	0
 #endif

 #undef		CRLF
 #define	CRLF	"\015\012"


 #ifndef CHAR
  #define CHAR	char
 #endif

 #ifndef UCHAR
  #define UCHAR	unsigned char
 #endif

 #ifndef BYTE
  #define BYTE	signed char
 #endif

 #ifndef UBYTE
  #define UBYTE	unsigned char
 #endif

 #ifndef WORD
  #define WORD	signed short
 #endif

 #ifndef UWORD
  #define UWORD	unsigned short
 #endif

 #ifndef LONG
  #define LONG	signed long
 #endif

 #ifndef ULONG
  #define ULONG	unsigned long
 #endif


 #ifndef INT16
  #define INT16	short
 #endif

 #ifndef VOID
  #define VOID	void
 #endif

#define  MOD_PLAY_ON         1
#define  MOD_PLAY_OFF        0


#define  MOD_INIT_OK         0
#define  MOD_INIT_BADSPL    -1

#define  MOD_LOCKED_SOUND	-1
#define  MOD_BAD_FORMAT		-2
#define  MOD_BAD_MODBUF		-3


#define  SET_MCFREQ			0
#define  MCFREQ_12KHZ		0
#define  MCFREQ_25KHZ		1
#define  MCFREQ_50KHZ		2

#define  SET_MCBUFMODE		2
#define  MCINT_POLL_NORMAL	0
#define  MCINT_POLL_LOOP	1
#define  MCINT_GSXB			2
#define  MCINT_TIMERA		3
#define  MCINT_MFP7			4

#define  SET_MCTOOGLE_TEMPO	3


#define INT_POLL_NORMAL		0x00000001
#define INT_POLL_LOOP		0x00000002
#define INT_GSXB			0x00000004
#define INT_TIMERA			0x00000008
#define INT_MFP7			0x00000010


/* prototypes des pointeurs de fonction vers MOD.LDG */
long CDECL (*mod_init    ) ( ULONG *interrupt_info );
void CDECL (*mod_setup   ) ( long function, long value );
long CDECL (*mod_play    ) ( void *ptr_modbuf );
void CDECL (*mod_backward) ( void );
void CDECL (*mod_forward ) ( void );
long CDECL (*mod_stop    ) ( void );
long CDECL (*mod_checkbuf) ( void );
long CDECL (*mod_getpos  ) ( long *songpos, long *patternpos );


/* handle Global pour MOD.LDG */
LDG	*ldg_MOD=NULL;

/* prototype fonction d'initialisation de la LDG MOD */
LONG  init_LDG_MOD( VOID );


/* fonction d'initialisation de la LDG MOD
 *
 * En cas d'erreur, la LDG est referm‚ et une valeur
 * (n‚gative) est retourn‚ par la fonction. Voir message
 * d'erreur dans la Documention LDG, … 'ldg_error()'.
 *
 * Renvoi 'TRUE' en cas de succŠs...
 *
 */
LONG init_LDG_MOD( VOID )
{
	extern 	LDG 	*ldg_MOD;
			LONG 	erreur=FALSE;


	ldg_MOD=ldg_open( "MOD.LDG", ldg_global );


	if( ldg_MOD==NULL )
	{
		return( ldg_error() );
	}


	/* Recherche des 8 fonctions dans MOD.LDG */

	mod_init     = ldg_find( "mod_init",     ldg_MOD );
	if( !mod_init )     erreur=TRUE;

	mod_setup    = ldg_find( "mod_setup",    ldg_MOD );
	if( !mod_setup )    erreur=TRUE;

	mod_play     = ldg_find( "mod_play",     ldg_MOD );
	if( !mod_play )     erreur=TRUE;

	mod_backward = ldg_find( "mod_backward", ldg_MOD );
	if( !mod_backward ) erreur=TRUE;

	mod_forward  = ldg_find( "mod_forward",  ldg_MOD );
	if( !mod_forward )  erreur=TRUE;

	mod_stop     = ldg_find( "mod_stop",     ldg_MOD );
	if( !mod_stop )     erreur=TRUE;

	mod_checkbuf = ldg_find( "mod_checkbuf", ldg_MOD );
	if( !mod_checkbuf ) erreur=TRUE;

	mod_getpos   = ldg_find( "mod_getpos",   ldg_MOD );
	if( !mod_getpos )   erreur=TRUE;


	/* Si une erreur s'est produite ... */
	if( erreur==TRUE )
	{
		ldg_close( ldg_MOD, ldg_global);
		return( LDG_NO_FUNC );
	}

	return(TRUE);
}



#endif	/* #ifndef __MOD_LDG__ */


