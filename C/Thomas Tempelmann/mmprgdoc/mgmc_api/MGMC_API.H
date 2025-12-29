/*
 * Definitions for MgMc-Cookie
 * Set TABs to 4
 *
 * asserts: "char" is 1 Byte, "short" is 2 Byte, "long" is 4 Byte
 */

#pragma once

typedef unsigned char byte;

#ifdef __MWERKS__	/* if compiled on a Macintosh */
	#define cdecl
	#pragma options align=mac68k
#else				/* if compiled on an Atari (Pure C) */
	typedef char Boolean;	/* "Boolean" is 1 Byte long! */
	typedef char *Ptr, **Handle;
	typedef unsigned char *StringPtr;
	typedef void PixMap;
	typedef Handle THPrint;
	enum {false,true};
	typedef struct {
		short	vRefNum;
		long	parID;
		byte	name[64];	/* pascal string! */
	} FSSpec;
	typedef struct {
		short	what;
		long	message;
		long	when;
		short	whereV;
		short	whereH;
		short	modifiers;
	} EventRecord;
#endif

typedef struct MgMcCookie MgMcCookie;

typedef long cdecl (*GenProc) (short function, void *data);
typedef Boolean cdecl (*PrSetupProc) (Boolean alwaysInteractively);
typedef void cdecl (*VoidProcPtr) (void);
typedef long cdecl (*LongProcPtr) ();
typedef void cdecl (*MacCtProc) (VoidProcPtr);
typedef Boolean cdecl (*EvtProcPtr) (EventRecord *event);

typedef struct {
	THPrint		printHdl;
	PrSetupProc	doPrintSetup;
	VoidProcPtr	saveSetup;
	long		reserved[7];
} PrintDesc;

enum {	/* status flags (bit numbers) for 'flags1' field */
	emul640x400Bit = 0,		/* ATARI screen simulation (physbase can be changed) */
	emulAtariScreenBit = 0,	/* same as above */
	distinctShiftKeysBit,	/* right & left shift keys give diff. scan codes */
	realTwoButtonMouseBit,	/* 2-button mouse is connected */
	runningOn68KEmulatorBit,/* running on PowerPC with emulation */
	atariIO1Disabled,		/* lower I/O area is not present (has RAM that can be used by applications) */
	atariIO2Disabled,		/* upper I/O area does not respond properly (no BUS Errors or McSTout) */
	speedEmulatorInstalled	/* new in v1.13: Speed Emulator (part of Speed Doubler) is installed */
};

typedef struct {	/* 'vers' resource definition, see Inside Mac docs */
	byte	vm;		/* first part of version number in BCD */
	byte	vn;		/* second and third part of version number in BCD */
	byte	vt;		/* development: 0x20, alpha: 0x40, beta: 0x60, release: 0x80 */
	byte	vd;		/* stage of prerelease version in BCD */
	short	region;	/* region code */
	char	str[];	/* version strings */
} MacVersion;

typedef struct {
	Boolean	inserted;		/* true: disk is inserted and available to GEMDOS/BIOS functions */
	Boolean	highDensity;	/* true: HD disk inserted, false: none or DD disk inserted */
	short	res1;			/* reserved */
	long	res2;			/* reserved */
} FlpDrvInfo;

typedef struct {
	Ptr		start;
	long	length;
} MemArea;

/*
 * The XCMD interface
 * ------------------
 */

enum {
	XCMDMajorVersion	= 1,	/* BCD format */
	XCMDRevision		= 0x01	/* BCD format */
};

enum {	/* some XCMD specific error codes */
	unknownFunctionXErr	= -65539L,	/* on callXCMD: unknown function code */
	notInstalledXErr	= -65540L,	/* on openXCMD: no XCMD with this name found */
	notOpenedXErr		= -65541L,	/* on openXCMD: XCMD refused to open */
	alreadyClosedXErr	= -65542L,	/* on closeXCMD: calls to close > calls to open */
	generalXErr			= -1,
	noXErr				= 0
};

enum {	/* predefined XCMD function codes */
	/* negative cmds are functions called by MagiCMac in Mac environment */
	xcmdOpen	= -2,	/* called each time some MagiC program opens this XCMD */
	xcmdClose	= -1	/* called each time some MagiC program closes this XCMD */
};

enum {	/* function codes for cookie functions 'ext' and 'extMac' */
	extMax = 0,
	extAlert,
	extAUXOpenErr,
	extFSSpecToPath,
	extDoMacTasks,
	extMgMcACCMsg,	/* internal use */
	extIntrInfo		/* internal use */
};

typedef struct {	/* to be used with extFSSpecToPath function as parameter */
	FSSpec	specIn;
	char	pathOut[256];	/* 0-terminated string */
} FSSpecToPathRec;

typedef long XCMDHdl;

typedef XCMDHdl cdecl (*XCMDOpenProc) (char *xcmdName);	/* returns handle or error code */
typedef long cdecl (*XCMDCloseProc) (XCMDHdl xcmdHdl);	/* returns error code or 0 if no error */
typedef long cdecl (*XCMDGenProc) (XCMDHdl xcmdHdl, short function, void *data);
typedef GenProc cdecl (*XCMDGetAdrProc) (XCMDHdl xcmdHdl);	/* returns zero, if not valid */

typedef struct {	/* the information in this record is static and the record does not move */
	short			recSize;	/* size of this whole structure */
	byte			majorVers;	/* major version of the XCMD Mgr (== XCMDMajorVersion) */
	byte			revision;	/* revision version of the XCMD Mgr (== XCMDRevision) */
	/* The following routines may be called from Atari User mode or Atari Supervisor mode, */
	/* but not from Interrupts!                                                            */
	XCMDOpenProc	open;		/* negative values mean errors, all positive are valid handles */
	XCMDCloseProc	close;		/* negative values mean errors, zero means OK */
	XCMDGenProc		call;		/* call a user function */
	XCMDGetAdrProc	getAdr;		/* returns the address of the XCMD function dispatcher */
	MgMcCookie		*cookie;	/* back-link to cookie. Is not yet initialized on init! */
	long			res[15];	/* reserved, zero */
} XCMDMgrRec;


/*
 * The cookie structure
 * --------------------
 */

struct MgMcCookie {
	short		vers;			/* Version number of Cookie */
	short		size;
	long		flags1;			/* Bits: see above */
	PixMap		*scrnPMPtr;
	Boolean		*updatePalette;
	VoidProcPtr	modeMac;
	VoidProcPtr	modeAtari;
	VoidProcPtr	getBaseMode;
	LongProcPtr	getIntrCount;
	VoidProcPtr	intrLock;
	VoidProcPtr	intrUnlock;
	MacCtProc	callMacContext;
	Ptr			atariZeroPage;
	Ptr			macA5;
	VoidProcPtr	macAppSwitch;
	VoidProcPtr	controlSwitch;
	long		hardwareAttr1;
	long		hardwareAttr2;
	Ptr			magiC_BP;
	StringPtr	auxOutName;
	StringPtr	auxInName;
	VoidProcPtr	auxControl;
	PrintDesc	*printDescPtr;
	GenProc		configKernel;
	Boolean		*atariModePossible;	/* (1.04) */
	MacVersion	*versionOfMacAppl;	/* (1.06) vers. of MagiCMac application */
	void		*hwEmulSupport;		/* (1.08) supports optional system bus error handler */
	FlpDrvInfo	*floppyDrvInfoPtr;	/* (1.07) array (2 elements) of infos about floppy drives */
	XCMDMgrRec	*xcmdMgrPtr;		/* (1.08) */
	VoidProcPtr	giveTimeToMac;		/* (1.09) call from Mac Context when idle */
	long		minStackSize;		/* (1.09) minimal supervisor stack size */
	GenProc		ext;				/* (1.10) support functions, call from Atari context */
	GenProc		extMac;				/* (1.10) same as "ext", but call from Mac context */
	VoidProcPtr	stackLoad;			/* (1.11) */
	VoidProcPtr	stackUnload;		/* (1.11) */
	EvtProcPtr	eventFilter;		/* (1.14) */
	long		reserved[2];
};

/* EOF */
