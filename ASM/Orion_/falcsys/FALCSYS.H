/*
	FalconSystem v5 - General Demo/Game System Library for the Falcon 030/060 by Orion_ [2009 - 2013]
*/

// Videl routine by Anders Eriksson from DHS
// C2P routine by Mikael Kalms from TBL, Improved by MiKRO
// IKBD routine by Patrice Mandin

#ifndef	_FALCSYS_H_
#define	_FALCSYS_H_

#include "TYPES.H"
#include <TOS.H>

//------------------------------------------
// FalconInit Flags

#define	VM_320x240_8BITS	0x00
#define	VM_320x240_16BITS	0x01
#define	VM_640x480_8BITS	0x02
#define	DOUBLE_BUFFER		0x04
#define	TRIPLE_BUFFER		0x08
#define	CT60_MODE			0x10
#define	EMULATOR_MODE		0x20	// Don't enable 060 Full Cache & Superscalar mode (if CT60_MODE is set) because emulator like aranym will crash
#define	EXIT_ON_SPACE_KEY	0x40
#define	FORCE_WAIT_VBL		0x80

//------------------------------------------
// FalconLoop User function return flags

#define	FL_EXIT	0
#define	FL_COPY	1
#define	FL_C2P	2

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
// Mouse & Keyboard Utils

#define IKBD_MOUSE_BUTTON_LEFT	2
#define IKBD_MOUSE_BUTTON_RIGHT	1
#define IKBD_MOUSE_BOTH_BUTTONS	3

#define IKBD_JOY_UP				(1 << 0)
#define IKBD_JOY_DOWN			(1 << 1)
#define IKBD_JOY_LEFT			(1 << 2)
#define IKBD_JOY_RIGHT			(1 << 3)
#define IKBD_JOY_FIRE			(1 << 7)

#define IKBD_KEY_PRESSED		0xFF
#define IKBD_KEY_UNDEFINED		0x80
#define IKBD_KEY_RELEASED		0x00

#define IKBD_KEY_F1				59
#define IKBD_KEY_F2				60
#define IKBD_KEY_F3				61
#define IKBD_KEY_F4				62
#define IKBD_KEY_F5				63
#define IKBD_KEY_F6				64
#define IKBD_KEY_F7				65
#define IKBD_KEY_F8				66
#define IKBD_KEY_F9				67
#define IKBD_KEY_F10			68

#define IKBD_KEY_SPACE			0x39
#define IKBD_KEY_RETURN			0x1c
#define IKBD_KEY_UP				0x48
#define IKBD_KEY_DOWN			0x50
#define IKBD_KEY_LEFT			0x4b
#define IKBD_KEY_RIGHT			0x4d
#define IKBD_KEY_BACKSPACE		0x0e
#define IKBD_KEY_DELETE			0x53
#define IKBD_KEY_ESC			0x01
#define IKBD_KEY_TAB			0x0F
#define IKBD_KEY_CONTROL		0x1d
#define IKBD_KEY_ALT			0x38
#define IKBD_KEY_LSHIFT			0x2a
#define IKBD_KEY_RSHIFT			0x36
#define IKBD_KEY_INSERT			0x52
#define IKBD_KEY_HELP			0x62
#define IKBD_KEY_UNDO			0x61
#define IKBD_KEY_CLRHOME		0x47
#define IKBD_KEY_CAPSLOCK		0x3a

//------------------------------------------
// User Vars

extern	volatile	u16		FS_nFrames;
extern	volatile	u32		FS_Timer200Hz;
extern				short	FS_ScreenWidth;
extern				short	FS_ScreenHeight;
extern				short	FS_ScreenBpp;
extern				void	*FS_STscreen[3];
extern				void	*FS_TTscreen;
extern	volatile	void	(*FS_VBLFuncPtr)();	// Set this pointer to start a function during the VBL Interrupt (ex: sound mixer)
extern				u8		FS_CurrentScreen;

extern volatile	u8	IKBD_MouseB;		// Buttons Pressed
extern volatile	s16	IKBD_MouseX;
extern volatile	s16	IKBD_MouseY;
extern volatile	u8	IKBD_Joystick0;
extern volatile	u8	IKBD_Joystick1;
extern volatile	u8	IKBD_Keyboard[128];	// Internal

//------------------------------------------
// User Functions

char	*FalconInit(u32 flags, u32 *pal);	// Return NULL if everything is ok, else it will return a string describing the error.
void	FalconExit(void);
// INFO: The screen parameter is the screen you need to work in
// INFO: Return FL_COPY for normal process, or FL_C2P to activate Chunky2Planar conversion of the Screen, only supported in 8bits screen and CT60 mode !
// INFO: To exit the loop, just press the "space" bar, or return the FL_EXIT flag
void	FalconLoop(int (*func)(void *screen));

LONG	IKBD_MouseOn(void);		// Call with Supexec (Mouse On by Default !)
LONG	IKBD_MouseOff(void);	// Call with Supexec
void	IKBD_ReadMouse(void);	// Call before reading IKBD_MouseX/Y
void	IKBD_SetMouseOrigin(signed short x, signed short y, unsigned short w, unsigned short h);
void	IKBD_Flush(void);
#define	IKBD_IsKeyPressed(_scan_)	IKBD_Keyboard[_scan_]

void	SetVblColor(u32 color);

// Data must be 32bits (4bytes) aligned, size must be multiple of 8 bytes and not exceed 500Kbytes
void	FastCopy32(__reg("a0") void *src, __reg("a1") void *dst, __reg("d0") long size);
void	FastClear32(__reg("a0") void *dst, __reg("d0") u32 size, __reg("d1") u32 data);

// Data must be 32bits (4bytes) aligned, size must be multiple of 32 bytes
void	VFastCopy32(__reg("a0") void *src, __reg("a1") void *dst, __reg("d0") long size);
void	VFastClear32(__reg("a0") void *dst, __reg("d0") u32 size, __reg("d1") u32 data);

void	FastCopy16Skip(__reg("a0") void *src, __reg("a1") void *dst, __reg("d0") u32 size, __reg("d1") u16 skip);
void	FastCopy32Skip16(__reg("a0") void *src, __reg("a1") void *dst, __reg("d0") u32 size, __reg("d1") u16 skip);

void	FastC2P_8BPP(__reg("a0") void *src, __reg("a1") void *dst, __reg("d0") int size);

// 8bits HLine in plannar mode (this one is not so "fast")
void	FastHLine320_8(__reg("a0") void *screen, __reg("d0") int x1, __reg("d1") int x2, __reg("d2") int y, __reg("d3") int color);

//******************************************


//------------------------------------------
// Internal Stuff (Do Not Use !)

#define	VM_MASK		0x00000003
#define	OPT_MASK	0xFFFFFFFC

extern	volatile	u16		FS_VblAck;
extern	volatile	u16		FS_SetNewScreen;
extern	volatile	void	*FS_NewScreenAdrs;
extern	volatile	u16		FS_Vmode;

extern	volatile	u32		*FS_PalettePtr;

extern	volatile	u32		CpuSaveCACR;
extern	volatile	u32		CpuSavePCR;

typedef struct
{
	signed short	x;
	signed short	y;
	unsigned short  w;
	unsigned short  h;
	unsigned char   limit;
	unsigned char   b;
}					IKBD_MouseData;

extern IKBD_MouseData	IKBD_Mouse;	// Mouse data

LONG	SetVidel(void);
LONG	SaveVidel(void);
LONG	RestoreVidel(void);

LONG	SetupInterrupts(void);
LONG	RestoreInterrupts(void);

LONG	CpuSaveState(void);
LONG	CpuEnableFullCacheSuperscalar(void);
LONG	CpuRestoreState(void);

LONG	IKBD_Install(void);
LONG	IKBD_Uninstall(void);

LONG	GetCT60Cookie(void);

#endif
