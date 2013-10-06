#ifndef	INCLUDED_SYSTEM_H
#define	INCLUDED_SYSTEM_H


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>
#include	<GODLIB\COOKIE\COOKIE.H>


/* ###################################################################################
#  ENUMS
################################################################################### */

typedef enum eSYSTEM_MCH
{
	MCH_UNKNOWN,
	MCH_ST,
	MCH_STE,
	MCH_STBOOK,
	MCH_MEGASTE,
	MCH_TT,
	MCH_FALCON,
	MCH_MILAN,
	MCH_HADES,
	MCH_PHENIX,

	MCH_LIMIT
} eSYSTEM_MCH;


typedef enum eSYSTEM_CPU
{
	CPU_UNKNOWN,
	CPU_68000,
	CPU_68010,
	CPU_68020,
	CPU_68030,
	CPU_68040,
	CPU_68060,
	CPU_G4,

	CPU_LIMIT
} eSYSTEM_CPU;


typedef enum eSYSTEM_FPU
{
	FPU_NONE,
	FPU_UNKNOWN,
	FPU_SFP004,
	FPU_68881,
	FPU_68882,
	FPU_68040,

	FPU_LIMIT
} eSYSTEM_FPU;


typedef enum eSYSTEM_DSP
{
	DSP_NONE,
	DSP_UNKNOWN,
	DSP_56000,
	DSP_56001,

	DSP_LIMIT
} eSYSTEM_DSP;


typedef	enum eSYSTEM_VDO
{
	VDO_UNKNOWN,
	VDO_ST,
	VDO_STE,
	VDO_TT,
	VDO_FALCON,

	VDO_LIMIT
} eSYSTEM_VDO;


typedef	enum eSYSTEM_MON
{
	MON_TV,
	MON_RGB,
	MON_VGA,
	MON_MONO,
	MON_MULTISYNC,
	MON_HDTV,

	MON_LIMIT
} eSYSTEM_MON;


typedef	enum eSYSTEM_BLT
{
	BLT_NONE,
	BLT_BLITTER,

	BLT_LIMIT,
} eSYSTEM_BLT;

typedef	enum	eSYSTEM_EMU
{
	EMU_NONE,
	EMU_UNKNOWN,
	EMU_PACIFIST,
	EMU_STEEM,
	EMU_TOSBOX,

	EMU_LIMIT
} eSYSTEM_EMU;

/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U8	VersionMajor;
	U8	VersionMinor;
	U8	SlowMotionFlag;
	U8	SlowMotionSpeed;

	U8	FastForwardFlag;
	U8	Mhz;
	U8	DebugBuildFlag;
	U8	SnapShotFlag;

	U16	RunSpeed;
	U16	CurrentSpeed;
	U32	CycleCounter;
	U32	CycleCountAtVBL;
	U32	CycleCountAtHBL;
} sSystemEmuDesc;


typedef struct
{
	uU32				RefreshRate;
	uU32				HblRate;
	U32					Memory;
	U32					RamST;
	U32					RamTT;
	eSYSTEM_MCH			MCH;
	eSYSTEM_CPU			CPU;
	eSYSTEM_FPU			FPU;
	eSYSTEM_DSP			DSP;
	eSYSTEM_VDO			VDO;
	eSYSTEM_MON			MON;
	eSYSTEM_BLT			BLT;
	eSYSTEM_EMU			EMU;
	U16					TosVersion;
	U16					EmuVersion;
	sSystemEmuDesc *	pEmuDesc;
} sSYSTEM;



/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void		System_Init( void );
void		System_DeInit( void );

eSYSTEM_MCH	System_GetMCH( void );
eSYSTEM_CPU	System_GetCPU( void );
eSYSTEM_FPU	System_GetFPU( void );
eSYSTEM_DSP	System_GetDSP( void );
eSYSTEM_VDO	System_GetVDO( void );
eSYSTEM_MON	System_GetMON( void );
eSYSTEM_BLT	System_GetBLT( void );
eSYSTEM_EMU	System_GetEMU( void );
char *		System_GetNameCPU( void );
char *		System_GetNameDSP( void );
char *		System_GetNameFPU( void );
char *		System_GetNameMCH( void );
char *		System_GetNameMON( void );
char *		System_GetNameVDO( void );
char *		System_GetNameBLT( void );
char *		System_GetNameEMU( void );
uU32 *		System_GetRefreshRate( void );
uU32 *		System_GetHblRate( void );
U16			System_GetTosVersion( void );
U16			System_GetEmuVersion( void );
U32			System_GetMemory( void );
U32			System_GetRamST( void );
U32			System_GetRamTT( void );

U8			System_GetDebugBuildFlag( void );
U8			System_GetFastForwardFlag( void );
U8			System_GetMhz( void );
U8			System_GetSlowMotionFlag( void );
U8			System_GetSlowMotionSpeed( void );
U16			System_GetCurrentSpeed( void );
U16			System_GetRunSpeed( void );
U8			System_GetSnapShotFlag( void );
void		System_SetSnapShotFlag( const U8 aFlag );
U32			System_GetCycleCounter( void );

void		System_SetIML( U16 aIML );
U16			System_GetIML( void );

void		System_CalcInfo( void );
void		System_Calibrate( void );
void		System_CalibrateVbl( void );

void		System_DataCacheDisable( void );
void		System_DataCacheEnable( void );

void		System_SetCPUSpeed( const U16 aMhz );


/* ################################################################################ */

#endif	/* INCLUDED_SYSTEM_H */