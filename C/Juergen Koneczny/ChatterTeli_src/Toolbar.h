#ifndef	__TOOLBAR__
#define	__TOOLBAR__

typedef	WORD	( *HNDL_TOOL )( EVNT *Events, void *UserData, WORD Global[15] );

/*-----------------------------------------------------------------------------*/
/* Strukturdefinitionen                                                        */
/*-----------------------------------------------------------------------------*/
typedef	struct	_Tool_Bar
{
	HNDL_TOOL	HandleToolbar;
	OBJECT		*Tree;
} TOOL_BAR;

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/

#endif