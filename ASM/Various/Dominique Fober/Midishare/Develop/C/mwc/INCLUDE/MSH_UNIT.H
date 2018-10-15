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

#ifdef TURBO_C
	typedef  void (* TaskPtr)( long date, short refNum, long a1,long a2,long a3 );
	typedef  void (* RcvAlarmPtr)( short refNum );
	typedef  void (* ApplAlarmPtr)( short refNum, long code );
	typedef  void (* ApplyProcPtr)( MidiEvPtr e );
#else
	typedef void (* TaskPtr)();
	typedef void (* RcvAlarmPtr)();
	typedef void (* ApplAlarmPtr)();
	typedef void (* ApplyProcPtr)();
#endif


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



/***********************************************************************
* 								ENTRY POINTS									
************************************************************************/

#ifdef TURBO_C
	extern int _trapCode_[];
	extern unsigned long cdecl (* micro_rtx)();
#else
	extern unsigned long micro_rtx();
#endif

 
/*--------------------- Global MidiShare environment ------------------*/

#define MidiGetVersion() 	(short)micro_rtx(0)

#define MidiCountAppls() 	(short)micro_rtx(1)

/* MidiGetIndAppl( short index) => short */
#define MidiGetIndAppl(a) 	(short)micro_rtx(2,a)	

/* MidiGetNamedAppl( MidiName name) => short */
#define MidiGetNamedAppl(a)	(short)micro_rtx(3,a)	 

 
/*----------------------- SMPTE synchronization -----------------------*/

/* void MidiGetSyncInfo(SyncInfoPtr p) */
#define MidiGetSyncInfo(p)			(void)micro_rtx(0x39,p)

/* void MidiSetSyncMode(unsigned short mode) */
#define MidiSetSyncMode(mode)			(void)micro_rtx(0x3A,mode)

/* MidiGetExtTime(void) => long */
#define MidiGetExtTime()				(long)micro_rtx(0x3E)

/* MidiInt2ExtTime(long) => long */
#define MidiInt2ExtTime(time)			(long)micro_rtx(0x3F,time)

/* MidiExt2IntTime(long) => long */
#define MidiExt2IntTime(time)			(long)micro_rtx(0x40,time)

/* void MidiTime2Smpte(long time, short format, SmpteLocPtr loc) */
#define MidiTime2Smpte(time, format, loc)	(void)micro_rtx(0x41,time,format,loc)

/* MidiSmpte2Time(SmpteLocPtr loc) => long */
#define MidiSmpte2Time(loc)			(long)micro_rtx(0x42,loc)


/*---------------------- Open / close application ---------------------*/

/* MidiOpen( MidiName applName) => short */
#define MidiOpen(a) 		(short)micro_rtx(4,a)	 

/* MidiClose( short refNum) */
#define MidiClose(a)	 	(void)micro_rtx(5,a) 


/*----------------------- Application configuration -------------------*/

/* MidiGetName( short refNum) => MidiName */
#define MidiGetName(a) 		(char *)micro_rtx(6,a) 

/* MidiSetName( short refNum, MidiName applName) */
#define MidiSetName(a,b) 	(void)micro_rtx(7,a,b) 

/* MidiGetInfo( short refNum) => Ptr */
#define MidiGetInfo(a) 		(Ptr)micro_rtx(8,a) 

/* MidiSetInfo( short refNum, Ptr infoZone) */
#define MidiSetInfo(a,b) 	(void)micro_rtx(9,a,b) 

/* MidiGetFilter( short refNum) => FilterPtr */
#define MidiGetFilter(a) 	(FilterPtr)micro_rtx(0xA,a)	

/* MidiSetFilter( short refNum, FilterPtr filter) */
#define MidiSetFilter(a,b) 	(void)micro_rtx(0xB,a,b) 

/* MidiGetRcvAlarm( short refNum) => RcvAlarmPtr */
#define MidiGetRcvAlarm(a) 	(RcvAlarmPtr)micro_rtx(0xC,a)	

/* MidiSetRcvAlarm( short refNum, RcvAlarmPtr alarm) */
#define MidiSetRcvAlarm(a,b) 	(void)micro_rtx(0xD,a,b)	

/* MidiGetApplAlarm( short refNum) => ApplAlarmPtr */
#define MidiGetApplAlarm(a) 	(ApplAlarmPtr)micro_rtx(0xE,a)	

/* MidiSetApplAlarm( short refNum, ApplAlarmPtr alarm) */
#define MidiSetApplAlarm(a,b)	(void)micro_rtx(0xF,a,b)	


/*--------------------- Inter-Application Connections -----------------*/

/* MidiConnect( shotr src, short dest, Boolean state) */
#define MidiConnect(a,b,c) 	(void)micro_rtx(0x10,a,b,c)

/* MidiIsConnected( short src, short dest) => Boolean */
#define MidiIsConnected(a,b) 	(Boolean)micro_rtx(0x11,a,b)	


/*--------------------------- Serial ports ----------------------------*/

/* MidiGetPortState( short port) => Boolean */
#define MidiGetPortState(a) 	(Boolean)micro_rtx(0x12,a)	

/* MidiSetPortState( short port, Boolean state) */
#define MidiSetPortState(a,b)	(void)micro_rtx(0x13,a,b)


/*----------------------- Events and memory managing ------------------*/

#define MidiFreeSpace() 		(long)micro_rtx(0x14)

/* MidiNewCell() => MidiEvPtr */
#define MidiNewCell()		(MidiEvPtr)micro_rtx(0x33)

/* MidiFreeCell( MidiEvPtr ev) */
#define MidiFreeCell(a)		(void)micro_rtx(0x34,a)

/* MidiNewEv( short typeNum) => MidiEvPtr */
#define MidiNewEv(a) 		(MidiEvPtr)micro_rtx(0x15,a)	

/* MidiCopyEv( MidiEvPtr ev) => MidiEvPtr */
#define MidiCopyEv(a) 		(MidiEvPtr)micro_rtx(0x16,a)	

/* MidiFreeEv( MidiEvPtr ev) */
#define MidiFreeEv(a) 		(void)micro_rtx(0x17,a)	

/* MidiAddField( MidiEvPtr ev, long v) */
#define MidiAddField(a,b) 	(void)micro_rtx(0x1A,a,b)

/* OldMidiSetField( MidiEvPtr ev, short f, long v) */
#define OldMidiSetField(a,b,c) 	(void)micro_rtx(0x18,a,b,c)

/* OldMidiGetField( MidiEvPtr ev, short f) => long */
#define OldMidiGetField(a,b)	(long)micro_rtx(0x19,a,b)

/* OldMidiCountFields( MidiEvPtr ev) => short */
#define OldMidiCountFields(a) 	(short)micro_rtx(0x1B,a)	

/* MidiSetField( MidiEvPtr ev, long f, long v) */
#define MidiSetField(a,b,c) 	(void)micro_rtx(0x3B,a,b,c)

/* MidiGetField( MidiEvPtr ev, long f) => long */
#define MidiGetField(a,b)	(long)micro_rtx(0x3C,a,b)

/* MidiCountFields( MidiEvPtr ev) => long */
#define MidiCountFields(a) 	(long)micro_rtx(0x3D,a)	


/*-------------------------- Sequence managing ------------------------*/

/* MidiNewSeq() => MidiSeqPtr */
#define MidiNewSeq() 		(MidiSeqPtr)micro_rtx(0x1D)	

/* MidiAddSeq( MidiSeqPtr s, MidiEvPtr ev) */
#define MidiAddSeq(a,b) 		(void)micro_rtx(0x1E,a,b)

/* MidiFreeSeq( MidiSeqPtr s) */
#define MidiFreeSeq(a) 		(void)micro_rtx(0x1F,a)	

/* MidiClearSeq( MidiSeqPtr s) */
#define MidiClearSeq(a) 		(void)micro_rtx(0x20,a)	

/* MidiApplySeq( MidiSeqPtr s, ApplyProcPtr ProcPtr) */
#define MidiApplySeq(a,b) 	(void)micro_rtx(0x21,a,b)


/*------------------------------ Time ---------------------------------*/

#define MidiGetTime()	 	(long)micro_rtx(0x22)



/*----------------------------- Sending -------------------------------*/

/* MidiSendIm( short refNum, MidiEvPtr ev) */
#define MidiSendIm(a,b)	 	(void)micro_rtx(0x23,a,b)

/* MidiSend( short refNum, MidiEvPtr ev) */
#define MidiSend(a,b) 		(void)micro_rtx(0x24,a,b)

/* MidiSendAt( short refNum, MidiEvPtr ev, long d) */
#define MidiSendAt(a,b,c) 	(void)micro_rtx(0x25,a,b,c)


/*------------------------------- Receving ----------------------------*/

/* MidiCountEvs( short refNum) =>long */
#define MidiCountEvs(a)	 	(long)micro_rtx(0x26,a)	

/* MidiGetEv( short refNum) => MidiEvPtr */
#define MidiGetEv(a) 		(MidiEvPtr)micro_rtx(0x27,a)	

/* MidiAvailEv( short refNum) => MidiEvPtr */
#define MidiAvailEv(a) 		(MidiEvPtr)micro_rtx(0x28,a)	

/* MidiFlushEvs( short refNum) */
#define MidiFlushEvs(a)		(void)micro_rtx(0x29,a)	


/*----------------------------- Mail boxes ----------------------------*/

/* MidiReadSync( Ptr adrMem) => Ptr */
#define MidiReadSync(a)	 	(Ptr)micro_rtx(0x2A,a)	

/* MidiWriteSync( Ptr adrMem, Ptr val) => Ptr */
#define MidiWriteSync(a,b) 	(Ptr)micro_rtx(0x2B,a,b)


/*------------------------------ Task Managing ------------------------*/

/* MidiCall( TaskPtr proc, long date, short refNum, long a1, long a2, long a3) */
#define MidiCall(a,b,c,d,e,f)		(void)micro_rtx(0x2C,a,b,c,d,e,f)

/* extensions taches diff‚r‚es */

/* MidiTask( TaskPtr proc, long date, short refNum, long a1, long a2, long a3) => MidiEvPtr */
#define MidiTask(a,b,c,d,e,f)		(MidiEvPtr)micro_rtx(0x2D,a,b,c,d,e,f)

/* MidiDTask( TaskPtr proc, long date, short refNum, long a1, long a2, long a3) => MidiEvPtr */
#define MidiDTask(a,b,c,d,e,f)	(MidiEvPtr)micro_rtx(0x2E,a,b,c,d,e,f)

/* MidiForgetTask( MidiEvPtr *ev) */
#define MidiForgetTask(a)		(void)micro_rtx(0x2F,a)

/* MidiCountDTasks( short refNum) => long */
#define MidiCountDTasks(a)		(long)micro_rtx(0x30,a)

/* MidiFlushDTasks( short refNum) */
#define MidiFlushDTasks(a)		(void)micro_rtx(0x31,a)

/* MidiExec1DTask( short refNum) */
#define MidiExec1DTask(a)		(void)micro_rtx(0x32,a)

/* MidiTotalSpace() => long */
#define MidiTotalSpace()			(long)micro_rtx(0x35)

/* MidiGetStatPtr() => MidiStatPtr */
#define MidiGetStatPtr()			(MidiStatPtr)micro_rtx(0x36)

/* MidiGrowSpace( long space) => long */
#define MidiGrowSpace(a)			(long)micro_rtx(0x37,a)
/* ATTENTION : MidiGrowSpace ne peut etre appel‚ que par un 
   accessoire de bureau ! */

/*-------------------------------- MidiShare --------------------------*/

extern Boolean MidiShare();


#endif

/******************************* End of MshUnit.h ******************************/
