#ifndef	__TELNET__
#define	__TELNET__
#include	"Emulator.h"

#define	TELNET_SE	240
#define	TELNET_NOP	241
#define	TELNET_DM	242
#define	TELNET_B		243
#define	TELNET_IP	244
#define	TELNET_AO	245
#define	TELNET_AYT	246
#define	TELNET_EC	247
#define	TELNET_EL	248
#define	TELNET_GA	249
#define	TELNET_SB	250
#define	TELNET_WILL	251
#define	TELNET_WONT	252
#define	TELNET_DO	253
#define	TELNET_DONT	254
#define	TELNET_IAC	255


#define	TRANSMIT_BINARY		0	/*	(RFC 856)	*/

#define	ECHO						1	/*	(RFC 857)	*/

#define	SUPPRES_GO_AHEAD		3	/*	(RFC 858)	*/

#define	STATUS					5	/*	(RFC 859)	*/
#define	STATUS_IS				0
#define	STATUS_SEND				1

#define	NAOHTS					11	/* (RCF 653)	*/
#define	NAOHTD					12	/* (RCF 654)	*/

#define	TERMINAL_TYPE			24	/*	(RFC 1091)	*/
#define	TERMINAL_TYPE_IS		0
#define	TERMINAL_TYPE_SEND	1

#define	NAWS						31	/* (RFC 1073)	*/

typedef	struct
{
	BYTE	*Host;
	UWORD	Port;
	WORD	FontId;
	WORD	FontColor;
	WORD	FontEffects;
	LONG	FontPt;
	WORD	WindowColor;
	EMU_TYPE	EmuType;
	XY		Terminal;
	XY		Tab;
	WORD	KeyFlag;
	LONG	PufLines;
	WORD	KeyExport;
	WORD	KeyImport;
	WORD	ProtocolFlag;
}	TELNET;

WORD		OpenTelnet( TELNET *Telnet, WORD Global[15] );
WORD		HandleTelnetWindow( WORD WinId, EVNT *Events, void *UserData, WORD Global[15] );
void		TelnetOptions( TELNET *Telnet, WORD WinId, WORD Flag, WORD Global[15] );
TELNET	*Url2Telnet( BYTE *Url );
void	FreeTelnet( TELNET *Telnet );
TELNET	*CopyTelnet( TELNET *Telnet );
#endif