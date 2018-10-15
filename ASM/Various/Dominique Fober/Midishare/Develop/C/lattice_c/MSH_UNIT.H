/***********************************************************************
 *                                MIDI SHARE									
 *----------------------------------------------------------------------
 * MidiShare is a multi-tasking, real-time software environment, 
 * specially devised for the developing of MIDI applications with a 
 * triple target :
 * 
 * 	ùTo propose solutions to currently met problems when developing 
 * 	 a real-time MIDI application : memory management, communication 
 *   management, time management, task management. 
 * 
 * 	ùTo enable the real-time and multi-tasking functioning of these 
 *   applications, i.e. to enable the sharing of all the necessary 
 *   resources and their simultaneous access.
 *
 * 	ùTo make easier cooperation between independent MIDI applications by  
 *   proposing a real-time mechanism of inter-application communications.
 * 
 * This file contains a complete description of all the MidiShare 
 * functions and procedures, as well as all the data structures in use.
 *----------------------------------------------------------------------
 * 		            c GRAME 1989, 1990, 1991, 1992 
 *	          [Yann Orlarey, Herv‚ Lequay, Dominique fober]						
 *----------------------------------------------------------------------
	
	version Mark Williams C  v.3.00
	version Turbo C  v.1.1
	version Lattice C v5.60		begun colin whyles 25may95
								complete c whyles 01jun95
			Note: programs using this file _must_ be compiled with the 
			default far data -b0 and type aligned stack -aw compiler 
			options.

 *----------------------------------------------------------------------
 *	colin whyles e-mail: whyles_c@btlip03.bt.co.uk
 *	49 Exeter Road, Felixstowe, Suffolk, IP11 9AT, UK
 *----------------------------------------------------------------------
	
 *  english version : YO [29-01-92] DF[09-02-93]
 ***********************************************************************/

#ifndef	_MidiShareUnit_
#define	_MidiShareUnit_


/***********************************************************************
				   	   TYPE DECLARATIONS
 ***********************************************************************/

typedef char * Ptr;
typedef unsigned char Byte;
typedef short 	Boolean;



/***********************************************************************
 * 						MIDISHARE EVENTS									
 *----------------------------------------------------------------------
 * 	The listing below presents the different types of MidiShare handled 
 *  events. This typology contains the whole of the standard Midi 
 *  messages, plus specific messages such as typeNote corresponding to a 
 *  note with its duration; or typeStream corresponding to a series of 
 *  arbitrary bytes, possibly including data and status codes, sent 
 *  directly without any processing; or typePrivate that are application 
 *  private messages.
 * 	
 * 	All these codes may be used in the MidiNewEv function to allocate 
 *  an event of the desirable type and are accessible in an event evType 
 *  field.
 ***********************************************************************/
			
#define typeNote		0 	/* note with pitch, velocity and duration	*/	
		
#define typeKeyOn		1 	/* Note On with pitch, velocity 			*/
#define typeKeyOff		2 	/* Note Off with pitch, velocity 			*/
#define typeKeyPress 	3 	/* Poly Key Pressure with pitch and pressure*/
#define typeCtrlChange	4 	/* Control Change with controller ID and value*/
#define typeProgChange	5 	/* Program Change with program ID number	*/
#define typeChanPress	6 	/* Channel Pressure with pressure value		*/
#define typePitchWheel	7 	/* Pitch Bend Change with LSB and MSB values*/
		
#define typeSongPos		8 	/* Song Position Pointer with LSB and MSB values*/
#define typeSongSel		9 	/* Song Select with song ID number			*/
#define typeClock		10 	/* Timing Clock						*/
#define typeStart		11 	/* Start								*/
#define typeContinue	12 	/* Continue							*/
#define typeStop		13	/* Stop								*/
		
#define typeTune		14 	/* Tune Request						*/
#define typeActiveSens	15 	/* Active Sensing						*/
#define typeReset		16	/* System Reset						*/
	
#define typeSysEx		17 	/* System Exclusive (only data bytes)		*/
#define typeStream		18 	/* arbitrary midi bytes (data and status codes)	*/
		
#define typePrivate		19	/*19..127 Private events for applications internal use*/
#define typeProcess		128	/* used by MidiShare for MidiCall and MidiTask*/
#define typeDProcess	129	/* used by MidiShare for MidiDTask			*/
#define typeQuarterFrame 130  /* Midi time code quarter frame			*/

#define typeCtrl14b		131	
#define typeNonRegParam	132
#define typeRegParam	133

#define typeSeqNum		134		/* sequence number			*/
#define typeText		135		/* text event				*/
#define typeCopyright	136		/* copyright message 		*/
#define typeSeqName		137		/* sequence or track name	*/
#define typeInstrName	138		/* nom d'instrument			*/
#define typeLyric		139		/* lyrics					*/
#define typeMarker		140		/* marker					*/
#define typeCuePoint	141		/* cue point				*/
#define typeChanPrefix	142		/* Midi Channel Prefix		*/
#define typeEndTrack	143		/* end of track			*/
#define typeTempo		144		/* tempo event				*/
#define typeSMPTEOffset	145		/* smpte offset 			*/

#define typeTimeSign	146		/* time signature			*/
#define typeKeySign		147		/* key signature			*/
#define typeSpecific	148		/* specific m‚ta event 		*/

#define typeReserved	149	/*149..254 reserved for future extensions*/
		
#define typeDead		255	/* dead Task or DTask			*/
		


/***********************************************************************
* 						MIDI STATUS CODE								
************************************************************************/
	
#define NoteOff	0x80	
#define NoteOn		0x90
#define PolyTouch	0xa0
#define ControlChg	0xb0
#define ProgramChg	0xc0
#define AfterTouch 	0xd0
#define PitchBend 	0xe0
#define SysRealTime 0xf0
#define SysEx 		0xf0
#define QFrame  	0xf1
#define SongPos 	0xf2
#define SongSel 	0xf3
#define UnDef2 	0xf4
#define UnDef3 	0xf5
#define Tune 		0xf6
#define EndSysX 	0xf7
#define MClock 	0xf8
#define UnDef4 	0xf9
#define MStart 	0xfa
#define MCont 		0xfb
#define MStop 		0xfc
#define UnDef5 	0xfd
#define ActSense 	0xfe
#define MReset 	0xff


/***********************************************************************
* 						SERIAL PORTS									
*-----------------------------------------------------------------------
* The Modem and printer serial ports ID numbers.							
************************************************************************/
			
#define ModemPort	0
#define PrinterPort	1
		


/***********************************************************************
* 						ERROR CODES								
*-----------------------------------------------------------------------
* List of the error codes returned by some MidiShare functions.																	
************************************************************************/
		
#define MIDIerrSpace 	-1		/* no more space available 	*/
#define MIDIerrRefNum	-2		/* wrong reference number	*/
#define MIDIerrBadType	-3		/* wrong event type 		*/
#define MIDIerrIndex	-4		/* wrong access to an event 	*/



/***********************************************************************
* 					SYNCHRONISATION CODES								
*-----------------------------------------------------------------------
* List of the error codes returned by some MidiShare functions.																	
************************************************************************/
		
#define MIDISyncExternal 0x8000	/* bit-15 for external synchronisation */
#define MIDISyncAnyPort	 0x4000 /* bit-14 for synchronisation on any port */



/***********************************************************************
* 						  CHANGE CODES							
*-----------------------------------------------------------------------
When an application need to know about context modifications like opening 
and closing of applications, opening and closing of midi ports, changes 
in connections between applications, it can install an ApplAlarm (with 
MidiSetApplAlarm). This ApplAlarm is then called by MidiShare every time 
a context modification happens with a 32-bits code describing the 
modification. The hi 16-bits part of this code is the refNum of the 
application involved in the context modification, the low 16-bits part 
describe the type of change as listed here.
************************************************************************/
		
enum{	MIDIOpenAppl=1,
		MIDICloseAppl,
		MIDIChgName,
		MIDIChgConnect,
		MIDIOpenModem,
		MIDICloseModem,
		MIDIOpenPrinter,
		MIDIClosePrinter,
		MIDISyncStart=550,
		MIDISyncStop,
		MIDIChangeSync
};


	
/***********************************************************************
* 				    		EVENTS STRUCTURES							
*-----------------------------------------------------------------------
************************************************************************/


/*--------------------- System Exclusive extension cell ---------------*/

typedef struct TMidiSEX *MidiSEXPtr;	
typedef struct TMidiSEX
{
	MidiSEXPtr link;			/* link to next cell		*/
	Byte data[12];				/* 12 data bytes			*/
}	TMidiSEX;		


/*------------------------- Private extension cell --------------------*/

typedef struct TMidiST *MidiSTPtr;		
typedef struct TMidiST					
{
	Ptr ptr1;					/* 4 32-bits fields 		*/
	Ptr ptr2;							
	Ptr ptr3;
	Ptr ptr4;						
}	TMidiST;						


/*------------------------- Common Event Structure --------------------*/

typedef struct TMidiEv *MidiEvPtr;		
typedef struct TMidiEv
{
	MidiEvPtr link;			/* link to next event		*/
	unsigned long date;			/* event date (in ms)		*/
	Byte evType;				/* event type		 		*/
	Byte refNum;				/* sender reference number	*/
	Byte port;				/* Midi port 				*/
	Byte chan;				/* Midi channel			*/
	union {					/* info depending of event type*/
		struct {					/* for notes			*/
			Byte pitch;				/* pitch  		*/
			Byte vel;					/* velocity 		*/
			unsigned short dur;			/* duration 		*/
		} note;

		struct {					/* for MidiFile time signature  	*/
			Byte numerator;			/* numerator				*/
			Byte denominator;			/* denominator as neg power	*/
									/* of 2. (2= quarter note)	*/
			Byte nClocks;				/* number of Midi clocks in 	*/
									/* a metronome click		*/
			Byte n32nd;				/* number of 32nd notes in	*/
									/* a Midi quarter note		*/
		} timeSign;

		struct {					/* for MidiFile key signature		*/
			char ton;					/* 0: key of C, 1: 1 sharp	*/
									/* -1: 1 flat etc...		*/
			Byte mode;				/* 0: major 1: minor		*/
			Byte unused[2];
		} keySign;

		struct {					/* for MidiFile sequence number */
			unsigned short number;
			short unused;
		} seqNum;
		long tempo;				/* MidiFile tempo in		*/
								/* microsec/Midi quarter note	*/
		Byte data[4];				/* for other small events	 */
		MidiSEXPtr linkSE;			/* link to last sysex extension*/
		MidiSTPtr linkST;			/* link to private extension	*/
	} info;
} TMidiEv;		


	
/*------------------------------ sequence header ----------------------*/

typedef struct TMidiSeq *MidiSeqPtr;	
typedef struct TMidiSeq
{
	MidiEvPtr first;			/* first event pointer 		*/
	MidiEvPtr last;			/* last event pointer 		*/
	Ptr undef1;
	Ptr undef2;
}	TMidiSeq;
	

/*------------------------------ input Filter -------------------------*/

typedef struct TFilter *FilterPtr;
typedef struct TFilter
{
	char port[32];					/* 256 bits	*/
	char evType[32];				/* 256 bits 	*/
	char channel[2];				/*  16 bits	*/
	char unused[2];				/*  16 bits 	*/
} TFilter; 
	


/*------------------------ MidiShare application name -----------------*/

typedef char * MidiName;


/*------------------------ Synchronisation informations ---------------*/

typedef struct TSyncInfo *SyncInfoPtr;
typedef struct TSyncInfo
{
 	long		time;
 	long		reenter;
 	unsigned short	syncMode;
 	Byte		syncLocked; 
 	Byte		syncPort;
	long		syncStart;
	long		syncStop;
	long		syncOffset;
	long		syncSpeed;
	long		syncBreaks;
	short		syncFormat;
} TSyncInfo; 

typedef struct TSmpteLocation *SmpteLocPtr;
typedef struct TSmpteLocation
{
 	short		format;	/* (0:24f/s, 1:25f/s, 2:30DFf/s, 3:30f/s) */
 	short		hours;	/* 0..23							*/
 	short		minutes;	/* 0..59							*/
 	short		seconds;	/* 0..59							*/
 	short		frames;	/* 0..30 (according to format)		*/
 	short		fracs;	/* 0..99 (1/100 of frames)			*/
} TSmpteLocation; 


/***********************************************************************
				   				 STATISTICS
************************************************************************/

typedef struct MidiStat *MidiStatPtr;
typedef struct	MidiStat 
{
	long rcvErrs;				/* number of receive errors */
	long allocErrs;			/* number of allocation errors */
	long rcvEvs;				/* number of rcv events */
	long xmtEvs;				/* number of xmt events */
} MidiStat;

	
/*----------------------------- Alarms prototypes ---------------------*/

typedef  void (* TaskPtr)( long date, short refNum, long a1,long a2,long a3 );
typedef  void (* RcvAlarmPtr)( short refNum );
typedef  void (* ApplAlarmPtr)( short refNum, long code );
typedef  void (* ApplyProcPtr)( MidiEvPtr e );


/***********************************************************************
* 							   FIELD MACROS							
*-----------------------------------------------------------------------
* Somes macros to read and write event's fields					 
************************************************************************/

#define Link(e) 	( (e)->link )
#define Date(e) 	( (e)->date )
#define EvType(e) 	( (e)->evType )
#define RefNum(e) 	( (e)->refNum )	
#define Port(e) 	( (e)->port )
#define Canal(e)	( (e)->chan )
#define Chan(e)	( (e)->chan )
#define Pitch(e) 	( (e)->info.note.pitch ) 
#define Vel(e) 	( (e)->info.note.vel ) 
#define Dur(e) 	( (e)->info.note.dur )
#define Data(e) 	( (e)->info.data )
#define LinkSE(e) 	( (e)->info.linkSE )
#define LinkST(e) 	( (e)->info.linkST )

#define TSNum(e)	( (e)->info.timeSign.numerator )
#define TSDenom(e)	( (e)->info.timeSign.denominator )
#define TSClocks(e)	( (e)->info.timeSign.nClocks )
#define TS32nd(e)	( (e)->info.timeSign.n32nd )

#define KSTon(e)	( (e)->info.keySign.ton )
#define KSMode(e)	( (e)->info.keySign.mode )

#define Tempo(e)	( (e)->info.tempo )
#define SeqNum(e)	( (e)->info.seqNum.number )
#define ChanPrefix(e) ((e)->info.data[0] )

#define First(e)	( (e)->first )
#define Last(e)	( (e)->last )
#define FirstEv(e)	( (e)->first )
#define LastEv(e)	( (e)->last )


/***********************************************************************
* 							  FILTER MACROS							
*-----------------------------------------------------------------------
* somes macros to set and reset filter's bits. 
************************************************************************/

#define AcceptBit(a,n)		(((Byte *)(a))[(n)>>3] |= (1<<((n)&7)))
#define RejectBit(a,n)		(((Byte *)(a))[(n)>>3] &= ~(1<<((n)&7)))
#define InvertBit(a,n)		(((Byte *)(a))[(n)>>3] ^= (1<<((n)&7)))
#define IsAcceptedBit(a,n)	(((Byte *)(a))[(n)>>3] & (1<<((n)&7)))

/*---------------------- Function Prototypes --------------------------*/

extern Boolean MidiShare( void );

extern short MidiGetVersion( void );
extern short MidiCountAppls( void );
extern short MidiGetIndAppl( short index );
extern short MidiGetNamedAppl( MidiName name );
extern void MidiGetSyncInfo( SyncInfoPtr p );
extern void MidiSetSyncMode( unsigned short mode );
extern long MidiGetExtTime( void );
extern long MidiInt2ExtTime( long );
extern long MidiExt2IntTime( long );
extern void MidiTime2Smpte( long time, short format, SmpteLocPtr loc);
extern long MidiSmpte2Time( SmpteLocPtr loc );
extern short MidiOpen( MidiName applName );
extern void MidiClose( short refNum );
extern MidiName MidiGetName( short refNum );
extern void MidiSetName( short refNum, MidiName applName );
extern Ptr MidiGetInfo( short refNum );
extern void MidiSetInfo( short refNum, Ptr infoZone );
extern FilterPtr MidiGetFilter( short refNum );
extern void MidiSetFilter( short refNum, FilterPtr filter );
extern RcvAlarmPtr MidiGetRcvAlarm( short refNum );
extern void MidiSetRcvAlarm( short refNum, RcvAlarmPtr alarm );
extern ApplAlarmPtr MidiGetApplAlarm( short refNum );
extern void MidiSetApplAlarm( short refNum, ApplAlarmPtr alarm );
extern void MidiConnect( short src, short dest, Boolean state );
extern Boolean MidiIsConnected( short src, short dest );
extern Boolean MidiGetPortState( short port );
extern void MidiSetPortState( short port, Boolean state );
extern long MidiFreeSpace( void );
extern MidiEvPtr MidiNewCell( void );
extern void MidiFreeCell( MidiEvPtr ev );
extern MidiEvPtr MidiNewEv( short typeNum );
extern MidiEvPtr MidiCopyEv( MidiEvPtr ev );
extern void MidiFreeEv( MidiEvPtr ev );
extern void MidiAddField( MidiEvPtr ev, long v );
extern void OldMidiSetField( MidiEvPtr ev, short f, long v );
extern long OldMidiGetField( MidiEvPtr ev, short f );
extern short OldMidiCountFields( MidiEvPtr ev );
extern void MidiSetField( MidiEvPtr ev, long f, long v );
extern long MidiGetField( MidiEvPtr ev, long f );
extern long MidiCountFields( MidiEvPtr ev );
extern MidiSeqPtr MidiNewSeq( void );
extern void MidiAddSeq( MidiSeqPtr s, MidiEvPtr ev );
extern void MidiFreeSeq( MidiSeqPtr s );
extern void MidiClearSeq( MidiSeqPtr s );
extern void MidiApplySeq( MidiSeqPtr s, ApplyProcPtr ProcPtr );
extern long MidiGetTime( void );
extern void MidiSendIm( short refNum, MidiEvPtr ev );
extern void MidiSend( short refNum, MidiEvPtr ev );
extern void MidiSendAt( short refNum, MidiEvPtr ev, long d );
extern long MidiCountEvs( short refNum );
extern MidiEvPtr MidiGetEv( short refNum );
extern MidiEvPtr MidiAvailEv( short refNum );
extern void MidiFlushEvs( short refNum );
extern Ptr MidiReadSync( Ptr adrMem );
extern Ptr MidiWriteSync( Ptr adrMem, Ptr val );
extern void MidiCall( TaskPtr proc, long date, short refNum, long a1, long a2, long a3 );
extern MidiEvPtr MidiTask( TaskPtr proc, long date, short refNum, long a1, long a2, long a3 );
extern MidiEvPtr MidiDTask( TaskPtr proc, long date, short refNum, long a1, long a2, long a3 );
extern void MidiForgetTask( MidiEvPtr *ev );
extern long MidiCountDTasks( short refNum );
extern void MidiFlushDTasks( short refNum );
extern void MidiExec1DTask( short refNum );
extern long MidiTotalSpace( void );
extern MidiStatPtr MidiGetStatPtr( void );
extern long MidiGrowSpace( long space );



/***********************************************************************
* 								ENTRY POINTS									
************************************************************************/

long _lmshrtx( short );
long _lmshrtxl( short, long );
long _lmshrtxp( short, void * );
long _lmshrtxpl( short, void *, long );
long _lmshrtxs( short, short );

void *_pmshrtx( short );
void *_pmshrtxp( short, void * );
void *_pmshrtxplslll( short, void *, short, long, long, long );
void *_pmshrtxpp( short, void *, void * );
void *_pmshrtxs( short, short );

short _smshrtx( short );
short _smshrtxp( short, void * );
short _smshrtxs( short, short );
short _smshrtxss( short, short, short );

void _vmshrtxlsp( short, long, short, void * );
void _vmshrtxp( short, void * );
void _vmshrtxpl( short, void *, long );
void _vmshrtxpll( short, void *, long, long );
void _vmshrtxplslll( short, void *, long, short, long, long, long );
void _vmshrtxpp( short, void *, void * );
void _vmshrtxpsl( short, void *, short, long );
void _vmshrtxs( short, short );
void _vmshrtxsp( short, short, void * );
void _vmshrtxspl( short, short, void *, long );
void _vmshrtxss( short, short, short );
void _vmshrtxsss( short, short, short, short );
void _vmshrtxu( short, unsigned short );

/*--------------------- Global MidiShare environment ------------------*/

#define MidiGetVersion() 	_smshrtx( 0 )

#define MidiCountAppls() 	_smshrtx( 1 )

/* MidiGetIndAppl( short index) => short */
#define MidiGetIndAppl(a) 			_smshrtxs( 2, a )	

/* MidiGetNamedAppl( MidiName name) => short */
#define MidiGetNamedAppl(a) 		_smshrtxp( 3, a )	 

 
/*----------------------- SMPTE synchronization -----------------------*/

/* void MidiGetSyncInfo(SyncInfoPtr p) */
#define MidiGetSyncInfo(p)			_vmshrtxp( 0x39, p )

/* void MidiSetSyncMode(unsigned short mode) */
#define MidiSetSyncMode(mode)		_vmshrtxu( 0x3A, mode )

/* MidiGetExtTime(void) => long */
#define MidiGetExtTime()			_lmshrtx( 0x3E )

/* MidiInt2ExtTime(long) => long */
#define MidiInt2ExtTime(time)		_lmshrtxl( 0x3F, time )

/* MidiExt2IntTime(long) => long */
#define MidiExt2IntTime(time)		_lmshrtxl( 0x40, time )

/* void MidiTime2Smpte(long time, short format, SmpteLocPtr loc) */
#define MidiTime2Smpte(time, format, loc)	_vmshrtxlsp( 0x41, time, format, loc)

/* MidiSmpte2Time(SmpteLocPtr loc) => long */
#define MidiSmpte2Time(loc)			_lmshrtxp( 0x42, loc )

/*---------------------- Open / close application ---------------------*/

/* MidiOpen( MidiName applName) => short */
#define MidiOpen(a) 		_smshrtxp( 4, a )

/* MidiClose( short refNum) */
#define MidiClose(a)	 	_vmshrtxs( 5, a ) 

/*----------------------- Application configuration -------------------*/

/* MidiGetName( short refNum) => MidiName */
#define MidiGetName(a) 		_pmshrtxs( 6, a )

/* MidiSetName( short refNum, MidiName applName) */
#define MidiSetName(a,b) 	_vmshrtxsp( 7, a, b) 

/* MidiGetInfo( short refNum) => Ptr */
#define MidiGetInfo(a) 		_pmshrtxs( 8, a) 

/* MidiSetInfo( short refNum, Ptr infoZone) */
#define MidiSetInfo(a,b) 	_vmshrtxsp( 9, a, b) 

/* MidiGetFilter( short refNum) => FilterPtr */
#define MidiGetFilter(a) 	_pmshrtxs( 0xA, a )	

/* MidiSetFilter( short refNum, FilterPtr filter) */
#define MidiSetFilter(a,b) 	_vmshrtxsp( 0xB, a, b ) 

/* MidiGetRcvAlarm( short refNum) => RcvAlarmPtr */
#define MidiGetRcvAlarm(a) 	_pmshrtxs( 0xC, a )	

/* MidiSetRcvAlarm( short refNum, RcvAlarmPtr alarm) */
#define MidiSetRcvAlarm(a,b) 	_vmshrtxsp( 0xD, a, b )	

/* MidiGetApplAlarm( short refNum) => ApplAlarmPtr */
#define MidiGetApplAlarm(a) 	_pmshrtxs( 0xE, a )	

/* MidiSetApplAlarm( short refNum, ApplAlarmPtr alarm) */
#define MidiSetApplAlarm(a,b)	_vmshrtxsp( 0xF, a, b )	

/*--------------------- Inter-Application Connections -----------------*/

/* MidiConnect( shotr src, short dest, Boolean state) */
#define MidiConnect(a,b,c) 	_vmshrtxsss( 0x10, a, b, c )

/* MidiIsConnected( short src, short dest) => Boolean */
#define MidiIsConnected(a,b) 	_smshrtxss( 0x11, a, b )	


/*--------------------------- Serial ports ----------------------------*/

/* MidiGetPortState( short port) => Boolean */
#define MidiGetPortState(a) 	_smshrtxs( 0x12, a )	

/* MidiSetPortState( short port, Boolean state) */
#define MidiSetPortState(a,b)	_vmshrtxss( 0x13, a, b )


/*----------------------- Events and memory managing ------------------*/

#define MidiFreeSpace() 		_lmshrtx( 0x14 )

/* MidiNewCell() => MidiEvPtr */
#define MidiNewCell()		_pmshrtx( 0x33 )

/* MidiFreeCell( MidiEvPtr ev) */
#define MidiFreeCell(a)		_vmshrtxp( 0x34, a )

/* MidiNewEv( short typeNum) => MidiEvPtr */
#define MidiNewEv(a) 		_pmshrtxs( 0x15, a )	

/* MidiCopyEv( MidiEvPtr ev) => MidiEvPtr */
#define MidiCopyEv(a) 		_pmshrtxp( 0x16, a )	

/* MidiFreeEv( MidiEvPtr ev) */
#define MidiFreeEv(a) 		_vmshrtxp(0x17,a)	

/* MidiAddField( MidiEvPtr ev, long v) */
#define MidiAddField(a,b) 	_vmshrtxpl(0x1A,a,b)

/* OldMidiSetField( MidiEvPtr ev, short f, long v) */
#define OldMidiSetField(a,b,c) 	_vmshrtxpsl(0x18,a,b,c)

/* OldMidiGetField( MidiEvPtr ev, short f) => long */
#define OldMidiGetField(a,b)	_lmshrtxps(0x19,a,b)

/* OldMidiCountFields( MidiEvPtr ev) => short */
#define OldMidiCountFields(a) 	_smshrtxp(0x1B,a)	

/* MidiSetField( MidiEvPtr ev, long f, long v) */
#define MidiSetField(a,b,c) 	_vmshrtxpll(0x3B,a,b,c)

/* MidiGetField( MidiEvPtr ev, long f) => long */
#define MidiGetField(a,b)		_lmshrtxpl(0x3C,a,b)

/* MidiCountFields( MidiEvPtr ev) => long */
#define MidiCountFields(a) 		_lmshrtxp(0x3D,a)	


/*-------------------------- Sequence managing ------------------------*/

/* MidiNewSeq() => MidiSeqPtr */
#define MidiNewSeq() 			_pmshrtx( 0x1D )	

/* MidiAddSeq( MidiSeqPtr s, MidiEvPtr ev) */
#define MidiAddSeq(a,b) 		_vmshrtxpp(0x1E,a,b)

/* MidiFreeSeq( MidiSeqPtr s) */
#define MidiFreeSeq(a) 			_vmshrtxp(0x1F,a)	

/* MidiClearSeq( MidiSeqPtr s) */
#define MidiClearSeq(a) 		_vmshrtxp(0x20,a)	

/* MidiApplySeq( MidiSeqPtr s, ApplyProcPtr ProcPtr) */
#define MidiApplySeq(a,b) 		_vmshrtxpp(0x21,a,b)


/*------------------------------ Time ---------------------------------*/

#define MidiGetTime()	 		_lmshrtx(0x22)


/*----------------------------- Sending -------------------------------*/

/* MidiSendIm( short refNum, MidiEvPtr ev) */
#define MidiSendIm(a,b)	 		_vmshrtxsp(0x23,a,b)

/* MidiSend( short refNum, MidiEvPtr ev) */
#define MidiSend(a,b) 			_vmshrtxsp(0x24,a,b)

/* MidiSendAt( short refNum, MidiEvPtr ev, long d) */
#define MidiSendAt(a,b,c) 		_vmshrtxspl(0x25,a,b,c)


/*------------------------------- Receiving ----------------------------*/

/* MidiCountEvs( short refNum) =>long */
#define MidiCountEvs(a)	 		_lmshrtxs(0x26,a)	

/* MidiGetEv( short refNum) => MidiEvPtr */
#define MidiGetEv(a) 			_pmshrtxs(0x27,a)	

/* MidiAvailEv( short refNum) => MidiEvPtr */
#define MidiAvailEv(a) 			_pmshrtxs(0x28,a)	

/* MidiFlushEvs( short refNum) */
#define MidiFlushEvs(a)			_vmshrtxs(0x29,a)	


/*----------------------------- Mail boxes ----------------------------*/

/* MidiReadSync( Ptr adrMem) => Ptr */
#define MidiReadSync(a)	 		_pmshrtxp(0x2A,a)	

/* MidiWriteSync( Ptr adrMem, Ptr val) => Ptr */
#define MidiWriteSync(a,b) 		_pmshrtxpp(0x2B,a,b)


/*------------------------------ Task Managing ------------------------*/

/* MidiCall( TaskPtr proc, long date, short refNum, long a1, long a2, long a3) */
#define MidiCall(a,b,c,d,e,f)		_vmshrtxplslll(0x2C,a,b,c,d,e,f)

/* extensions taches diff‚r‚es */

/* MidiTask( TaskPtr proc, long date, short refNum, long a1, long a2, long a3) => MidiEvPtr */
#define MidiTask(a,b,c,d,e,f)		_pmshrtxplslll(0x2D,a,b,c,d,e,f)

/* MidiDTask( TaskPtr proc, long date, short refNum, long a1, long a2, long a3) => MidiEvPtr */
#define MidiDTask(a,b,c,d,e,f)		_pmshrtxplslll(0x2E,a,b,c,d,e,f)

/* MidiForgetTask( MidiEvPtr *ev) */
#define MidiForgetTask(a)			_vmshrtxp(0x2F,a)

/* MidiCountDTasks( short refNum) => long */
#define MidiCountDTasks(a)			_lmshrtxs(0x30,a)

/* MidiFlushDTasks( short refNum) */
#define MidiFlushDTasks(a)			_vmshrtxs( 0x31, a )

/* MidiExec1DTask( short refNum) */
#define MidiExec1DTask(a)			_vmshrtxs( 0x32, a )

/* MidiTotalSpace() => long */
#define MidiTotalSpace()			_lmshrtx( 0x35 )

/* MidiGetStatPtr() => MidiStatPtr */
#define MidiGetStatPtr()			_pmshrtx( 0x36 )

/* MidiGrowSpace( long space) => long */
#define MidiGrowSpace(a)			_lmshrtxl( 0x37, a )
/* ATTENTION : MidiGrowSpace ne peut etre appel‚ que par un 
   accessoire de bureau ! */


/*-------------------------------- MidiShare --------------------------*/

extern Boolean MidiShare();

/*-------------------------------- Inlines ----------------------------*/
/*
 | Convention:
 | First character indicates return type: s = short, v = void, p = pointer, l = long, v = void
 | followed by mshrtx
 | Trailing characters indicate parameter types
 |
 | Note: The Lattice documentation doesn't make explicit the fact that the inline pragma
 | only recognises the 'short' cast. Any other cast keyword gives errors. This means that 
 | all other types default to being pushed as long or double.
 */

#define __TRAP_5 { "4E45"; }

#pragma inline d0 = _smshrtx( (short) ) __TRAP_5
#pragma inline d0 = _smshrtxp( (short), ) __TRAP_5
#pragma inline d0 = _smshrtxs( (short), (short) ) __TRAP_5
#pragma inline d0 = _smshrtxss( (short), (short), (short) ) __TRAP_5

#pragma inline d0 = _lmshrtx( (short) ) __TRAP_5
#pragma inline d0 = _lmshrtxl( (short), ) __TRAP_5
#pragma inline d0 = _lmshrtxp( (short), ) __TRAP_5
#pragma inline d0 = _lmshrtxpl( (short), , ) __TRAP_5
#pragma inline d0 = _lmshrtxs( (short), (short) ) __TRAP_5

#pragma inline d0 = _pmshrtx( (short) ) __TRAP_5
#pragma inline d0 = _pmshrtxp( (short), ) __TRAP_5
#pragma inline d0 = _pmshrtxplslll( (short), , , (short), , , ) __TRAP_5
#pragma inline d0 = _pmshrtxpp( (short), , ) __TRAP_5
#pragma inline d0 = _pmshrtxs( (short), (short) ) __TRAP_5

#pragma inline _vmshrtxlsp( (short), , (short), ) __TRAP_5
#pragma inline _vmshrtxp( (short), ) __TRAP_5
#pragma inline _vmshrtxpl( (short), , ) __TRAP_5
#pragma inline _vmshrtxpll( (short), , , ) __TRAP_5
#pragma inline _vmshrtxplslll( (short), , , (short), , , ) __TRAP_5
#pragma inline _vmshrtxpp( (short), , ) __TRAP_5
#pragma inline _vmshrtxpsl( (short), , (short), ) __TRAP_5
#pragma inline _vmshrtxs( (short), (short) ) __TRAP_5
#pragma inline _vmshrtxsp( (short), (short), ) __TRAP_5
#pragma inline _vmshrtxspl( (short), (short), , ) __TRAP_5
#pragma inline _vmshrtxss( (short), (short), (short) ) __TRAP_5
#pragma inline _vmshrtxsss( (short), (short), (short), (short) ) __TRAP_5
#pragma inline _vmshrtxu( (short), (short) ) __TRAP_5

#endif

/******************************* End of MshUnit.h ******************************/

