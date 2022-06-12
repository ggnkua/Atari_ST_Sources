/*
	FalconSystem - General Demo System Library for the Falcon 030/060 by Orion_ [2009 - 2011]
*/

#include "FALCSYS.H"

void	*FS_screenadrsP;
void	*FS_screenadrsL;
u16		FS_screenrez;
void	*FS_superstack;
void	*FS_STscreen[2];
void	*FS_TTscreen;
u8		FS_CurrentScreen;
u32		FS_Flags;
short	FS_ScreenWidth;
short	FS_ScreenHeight;
short	FS_ScreenBpp;

//---

bool	FalconInit(u32 flags, u32 *pal)
{
	FS_Flags = flags & OPT_MASK;
	FS_Vmode = (u16)(flags & VM_MASK);
	FS_PalettePtr = pal;

	switch (FS_Vmode)
	{
		case VM_320x240_8BITS:
			FS_ScreenWidth = 320;
			FS_ScreenHeight = 240;
			FS_ScreenBpp = 8;
		break;

		case VM_320x240_16BITS:
			FS_ScreenWidth = 320;
			FS_ScreenHeight = 240;
			FS_ScreenBpp = 16;
		break;

		case VM_640x480_8BITS:
			FS_ScreenWidth = 640;
			FS_ScreenHeight = 480;
			FS_ScreenBpp = 8;
		break;

		// Video mode not supported !
		default:
			return (false);
	}

	// Alloc ST Screen
	if (!(FS_STscreen[0] = Mxalloc(SCREEN_SIZE, MX_STRAM)))
		return (false);

	// Double Buffer if needed
	if (FS_Flags & DOUBLE_BUFFER)
		if (!(FS_STscreen[1] = Mxalloc(SCREEN_SIZE, MX_STRAM)))
		{
			Mfree(FS_STscreen[0]);
			return (false);
		}

	// TODO: Detect CT60 if CT60_MODE set !
		// just unset the flag in FS_Flags

	// Alloc Working Screen in Fast Ram if CT60 mode
	if (FS_Flags & CT60_MODE)
		if (!(FS_TTscreen = Mxalloc(SCREEN_SIZE, MX_TTRAM)))
		{
			Mfree(FS_STscreen[1]);
			Mfree(FS_STscreen[0]);
			return (false);
		}

	SetMouse(false);

	// Save Current Screen & Palette
	Supexec(SaveVidel);

	// Set New Screen Resolution
	if (!Supexec(SetVidel))
	{
		Mfree(FS_TTscreen);
		Mfree(FS_STscreen[1]);
		Mfree(FS_STscreen[0]);
		return (false);
	}

	// Init Low Level Interrupts
	Supexec(SetupInterrupts);

	// Setup CPU Flags for Max Speed
	if (FS_Flags & CT60_MODE)
	{
		Supexec(CpuSaveState);
		Supexec(CpuEnableFullCacheSuperscalar);
	}

	// Clear Screens
	FastClear32(FS_STscreen[0], SCREEN_SIZE, 0);
	if (FS_Flags & DOUBLE_BUFFER)
		FastClear32(FS_STscreen[1], SCREEN_SIZE, 0);
	if (FS_Flags & CT60_MODE)
		FastClear32(FS_TTscreen, SCREEN_SIZE, 0);

	// Set a Screen and Wait VSync
	if (FS_Flags & DOUBLE_BUFFER)
		FS_NewScreenAdrs = FS_STscreen[1];
	else
		FS_NewScreenAdrs = FS_STscreen[0];
	FS_VblAck = 0;
	FS_CurrentScreen = 0;
	FS_SetNewScreen = 1;
	while (!FS_VblAck);

	return (true);
}


void	FalconLoop(void *(*func)(void *screen, bool *do_c2p))
{
	FS_VblAck = 0;
	FS_KeyPressed = 0;

	while (!FS_KeyPressed)
	{
		void	*todraw;
		bool	do_c2p;

		// Start User Function
		if (FS_Flags & CT60_MODE)
			todraw = func(FS_TTscreen, &do_c2p);
		else
			todraw = func(FS_STscreen[FS_CurrentScreen], &do_c2p);

		if (!todraw)	// If NULL, exit loop !
			break;

		// C2P from TTRAM to STRAM (take about 70% of the VBL @ 60Hz)
		// Optimized C2P is as fast as a Raw Planar 32bits Copy
		// This is due to STram being very slow
		if (FS_Flags & CT60_MODE)
		{
			if (do_c2p)
				FastC2P_8BPP(todraw, FS_STscreen[FS_CurrentScreen], SCREEN_SIZE);
			else
				FastCopy32(todraw, FS_STscreen[FS_CurrentScreen], SCREEN_SIZE);
		}

		// Set New Screen and Flip
		if (FS_Flags & DOUBLE_BUFFER)
		{
			FS_NewScreenAdrs = todraw;
			FS_SetNewScreen = 1;
			FS_CurrentScreen ^= 1;
		}

		// Vsync only if the computation took less than a VBL
		while (!FS_VblAck);	// Else, we go on !

		FS_VblAck = 0;
	}
}


void	FalconExit(void)
{
	// Restore CPU Flags
	if (FS_Flags & CT60_MODE)
		Supexec(CpuRestoreState);

	// Restore Interrupts
	Supexec(RestoreInterrupts);

	// Free Memory
	if (FS_Flags & CT60_MODE)
		Mfree(FS_TTscreen);
	if (FS_Flags & DOUBLE_BUFFER)
		Mfree(FS_STscreen[1]);
	Mfree(FS_STscreen[0]);

	// Restore Screen & Palette
	Supexec(RestoreVidel);

	SetMouse(true);
}

// ----

u32	SetVblColorC;

LONG	SetVblColorS(void)
{
	SET_RAW_PALETTE(0, SetVblColorC);
	return (0);
}

void	SetVblColor(u32 color)
{
	SetVblColorC = color;
	Supexec(SetVblColorS);
}

void	SetMouse(bool activ)
{
	char	mousebuf;

	if (activ)
		mousebuf = 0x8;
	else
		mousebuf = 0x12;

	Ikbdws(0, &mousebuf);
}
