/*
	FalconSystem - General Demo System Library for the Falcon 030/060 by Orion_ [2009 - 2011]
*/

// Videl functions by Anders Eriksson from DHS
// C2P function by Mikael Kalms from TBL, Improved by MiKRO

#ifndef	_FALCSYS_H_
#define	_FALCSYS_H_

#include "TYPES.H"
#include <TOS.H>

//------------------------------------------
// FalconInit Flags

#define	VM_320x240_8BITS	0x00
#define	VM_320x240_16BITS	0x01
#define	VM_640x480_8BITS	0x02
#define	DOUBLE_BUFFER		0x10
#define	CT60_MODE			0x20

//------------------------------------------
// User Utils

#define	SCREEN_WIDTH	FS_ScreenWidth
#define	SCREEN_HEIGHT	FS_ScreenHeight
#define	SCREEN_BPP		FS_ScreenBpp
#define	SCREEN_SIZE		(FS_ScreenWidth * FS_ScreenHeight * (FS_ScreenBpp / 8))

#define	MSEC_TO_TIMER(a)	((a) / (1000 / 200))

#define	RGB8_TO_FALC(r, g, b)	((((r) << 24) | ((g) << 16) | (b)) & 0xFCFC00FC)
#define	RGB8_TO_FALC16(r, g, b)	((((r) >> 3) << 11) | (((g) >> 2) << 5) | ((b) >> 3))

#define	VBL_WHITE	RGB8_TO_FALC(255, 255, 255)
#define	VBL_RED		RGB8_TO_FALC(255, 0, 0)
#define	VBL_GREEN	RGB8_TO_FALC(0, 255, 0)
#define	VBL_BLUE	RGB8_TO_FALC(0, 0 255)
#define	VBL_BLACK	RGB8_TO_FALC(0, 0, 0)

#define	SET_RAW_PALETTE(_index_, _color_)	*((volatile u32 *)(0xFF9800 + (_index_ * 4))) = _color_;

//------------------------------------------
// User Vars

extern	volatile	u16		FS_nFrames;
extern	volatile	u32		FS_Timer200Hz;
extern	short				FS_ScreenWidth;
extern	short				FS_ScreenHeight;
extern	short				FS_ScreenBpp;

//------------------------------------------
// User Functions

bool	FalconInit(u32 flags, u32 *pal);
void	FalconExit(void);
// INFO: The screen parameter is the screen you need to work in
// INFO: Return the screen to be drawn at the end of the function
// INFO: To exit the loop, just press the "space" bar, or return a NULL value
// WARNING: C2P Mode only supported in CT60 mode !!
void	FalconLoop(void *(*func)(void *screen, bool *do_c2p));

void	SetVblColor(u32 color);

// Data must be 32bits aligned, and size must not exceed more than 256Kbytes (you know dbra ...)
void	FastCopy32(__reg("a0") void *src, __reg("a1") void *dst, __reg("d0") long size);
void	FastClear32(__reg("a0") void *dst, __reg("d0") u32 size, __reg("d1") u32 data);

void	FastCopy16Skip(__reg("a0") void *src, __reg("a1") void *dst, __reg("d0") u32 size, __reg("d1") u16 skip);
void	FastCopy32Skip16(__reg("a0") void *src, __reg("a1") void *dst, __reg("d0") u32 size, __reg("d1") u16 skip);

void	FastC2P_8BPP(__reg("a0") void *src, __reg("a1") void *dst, __reg("d0") int size);

// 8bits HLine in plannar mode (this one is not so "fast")
void	FastHLine320_8(__reg("a0") void *screen, __reg("d0") int x1, __reg("d1") int x2, __reg("d2") int y, __reg("d3") int color);

//******************************************


//------------------------------------------
// Internal Stuff (Do Not Use !)

#define	VM_MASK		0x0000000F
#define	OPT_MASK	0xFFFFFFF0

extern	volatile	u16		FS_VblAck;
extern	volatile	u16		FS_SetNewScreen;
extern	volatile	void	*FS_NewScreenAdrs;
extern	volatile	u16		FS_KeyPressed;
extern	volatile	u16		FS_Vmode;

extern	volatile	u32		*FS_PalettePtr;

extern	volatile	u32		CpuSaveCACR;
extern	volatile	u32		CpuSavePCR;

void	SetMouse(bool activ);

LONG	SetVidel(void);
LONG	SaveVidel(void);
LONG	RestoreVidel(void);

LONG	SetupInterrupts(void);
LONG	RestoreInterrupts(void);

LONG	CpuSaveState(void);
LONG	CpuEnableFullCacheSuperscalar(void);
LONG	CpuRestoreState(void);

#endif
