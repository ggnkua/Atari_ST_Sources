/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#ifdef __cplusplus
extern "C" {
#endif																		/* __cplusplus */

/*----------------------------------------------------------------------------------------*/
/* Makros für Parameterübergabe auf 68k																	*/
/*----------------------------------------------------------------------------------------*/
#if __MWERKS__ && MC68K													/* Registerübergabe für CodeWarrior 68k */

#define	__D0(x)	x##:__D0
#define	__D1(x)	x##:__D1
#define	__D2(x)	x##:__D2
#define	__A0(x)	x##:__A0
#define	__A1(x)	x##:__A1

#else																			/* Pure C und nicht 68k-Compiler */

#define	__D0(x)	x
#define	__D1(x)	x
#define	__D2(x)	x
#define	__A0(x)	x
#define	__A1(x)	x

#endif

/*----------------------------------------------------------------------------------------*/
/* Makros für "A5 World" auf 68k																				*/
/*----------------------------------------------------------------------------------------*/
#if __MWERKS__ && MC68K

extern void	_A5world_ptr( void );									/* Codewarrior wants function for DC.L <address> */

static inline asm int32	SetA5World( void )
{
	DC.W	0x200D															/* move.l	a5,d0 */
	DC.W	0x2A79															/* movea.l	_A5world_ptr,a5 */
	DC.L	_A5world_ptr 
}

static void	ResetA5(int32 _oldA5_:__D0) = (0x2A40);			/* movea.l d0,a5 */

#define ENTER_CALLBACK()	int32 _oldA5_ = SetA5World()
#define EXIT_CALLBACK()		ResetA5( _oldA5_ )

#else

#define	ENTER_CALLBACK()
#define	EXIT_CALLBACK()

#endif

#ifdef __cplusplus
}
#endif																		/* __cplusplus */
