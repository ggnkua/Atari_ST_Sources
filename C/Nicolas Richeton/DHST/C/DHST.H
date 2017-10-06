
#if !defined (DHST_ADD)
#define	DHST_ADD			0xdadd
#endif

#if !defined (DHST_ACK)
#define	DHST_ACK			0xdade
#endif

#if !defined (DHSTINFO)
typedef struct
{
	char	*appname,
			*apppath,
			*docname,
			*docpath;
} DHSTINFO;
#endif

EXTERN	ULONG DHST_ServerId( VOID );

 
EXTERN	ULONG	DHST_write( ULONG ap_id, ULONG count, UBYTE *appname, UBYTE *apppath,
                                            UBYTE *docname, UBYTE *docpath);

EXTERN	ULONG	DHST_init( ULONG ap_id );
 
EXTERN	ULONG DHST_exit( ULONG ap_id, ULONG count );

EXTERN	ULONG DHST_evnt_ack( ULONG ap_id, ULONG count, ULONG msg0, ULONG msg3, ULONG msg4 );
