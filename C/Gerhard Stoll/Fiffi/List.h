int		WorkRList( FILE *MsgHandle, FILE *Handle, BYTE **DataPuf, LONG *DataPufLen, LONG *DataPufOffset, STR_ITEM **Items, WORD GemFtpAppId, WORD Flag, WORD Global[15] );
WORD		GetFileName( STR_ITEM *Item, BYTE **RetPuf );

#define	DIR_ITEM		0x0001
#define	FILE_ITEM	0x0002
#define	LINK_ITEM	0x0004
WORD		GetFileNameList( WORD Flag, STR_ITEM *ItemList, BYTE ***Puf );
WORD		GetFileSizeList( WORD Flag, STR_ITEM *ItemList, LONG **Puf );
void		DelFileNameList( BYTE ***Puf );
void		SortFtpDirList( STR_ITEM *ItemList );
