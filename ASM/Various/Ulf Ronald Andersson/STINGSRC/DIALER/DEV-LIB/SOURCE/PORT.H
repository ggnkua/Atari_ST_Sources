BOOLEAN	is_dcd		( WORD func );
VOID	high_dtr	( WORD func, MAPTAB *map );
VOID	low_dtr		( WORD func, MAPTAB *map );
BOOLEAN	SendBlock	( VOID *dev, BYTE *block, LONG len, BOOLEAN tst_dcd );
LONG	GetBlock	( VOID *dev, LONG bufflen, BYTE *buff );
VOID	SetMapM1	( MAPTAB **map );
VOID	SetMapMidi	( MAPTAB **map );
VOID	SetIorec	( IOREC *iorec, BYTE *blk, WORD len );