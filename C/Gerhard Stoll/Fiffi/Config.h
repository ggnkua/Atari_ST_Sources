#define	SaveConf	0x1
#define	TT_Auto	0x0
#define	TT_Bin	0x1
#define	TT_Ascii	0x2

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
WORD	cdecl	HandleConf1Dialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
WORD	cdecl	HandleConf2Dialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
WORD	ReadConfig( void );
WORD	WriteConfig( void );