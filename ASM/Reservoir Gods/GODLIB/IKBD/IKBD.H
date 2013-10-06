#ifndef	INCLUDED_IKBD_H
#define	INCLUDED_IKBD_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  ENUMS
################################################################################### */

enum
{
	eIKBDSCAN_A	=	0x1E,
	eIKBDSCAN_B	=	0x30,
	eIKBDSCAN_C	=	0x2E,
	eIKBDSCAN_D	=	0x20,
	eIKBDSCAN_E	=	0x12,
	eIKBDSCAN_F	=	0x21,
	eIKBDSCAN_G	=	0x22,
	eIKBDSCAN_H	=	0x23,
	eIKBDSCAN_I	=	0x17,
	eIKBDSCAN_J	=	0x24,
	eIKBDSCAN_K	=	0x25,
	eIKBDSCAN_L	=	0x26,
	eIKBDSCAN_M	=	0x32,
	eIKBDSCAN_N	=	0x31,
	eIKBDSCAN_O	=	0x18,
	eIKBDSCAN_P	=	0x19,
	eIKBDSCAN_Q	=	0x10,
	eIKBDSCAN_R	=	0x13,
	eIKBDSCAN_S	=	0x1F,
	eIKBDSCAN_T	=	0x14,
	eIKBDSCAN_U	=	0x16,
	eIKBDSCAN_V	=	0x2F,
	eIKBDSCAN_W	=	0x11,
	eIKBDSCAN_X	=	0x2D,
	eIKBDSCAN_Y	=	0x15,
	eIKBDSCAN_Z	=	0x2C,

	eIKBDSCAN_0		=	0x0B,
	eIKBDSCAN_1		=	0x02,
	eIKBDSCAN_2		=	0x03,
	eIKBDSCAN_3		=	0x04,
	eIKBDSCAN_4		=	0x05,
	eIKBDSCAN_5		=	0x06,
	eIKBDSCAN_6		=	0x07,
	eIKBDSCAN_7		=	0x08,
	eIKBDSCAN_8		=	0x09,
	eIKBDSCAN_9		=	0x0A,

	eIKBDSCAN_F1	=	0x3B,
	eIKBDSCAN_F2	=	0x3C,
	eIKBDSCAN_F3	=	0x3D,
	eIKBDSCAN_F4	=	0x3E,
	eIKBDSCAN_F5	=	0x3F,
	eIKBDSCAN_F6	=	0x40,
	eIKBDSCAN_F7	=	0x41,
	eIKBDSCAN_F8	=	0x42,
	eIKBDSCAN_F9	=	0x43,
	eIKBDSCAN_F10	=	0x44,

	eIKBDSCAN_AT					= 0x28,
	eIKBDSCAN_AMPERSAND				= 0x08,
	eIKBDSCAN_BAR					= 0x60,
	eIKBDSCAN_BACKSLASH				= 0x35,
	eIKBDSCAN_CLOSEAPOSTROPHE		= 0x27,
	eIKBDSCAN_CLOSEBRACKET			= 0x0B,
	eIKBDSCAN_CLOSECURLYBRACKET		= 0x1A,
	eIKBDSCAN_CLOSESQUAREBRACKET	= 0x1B,
	eIKBDSCAN_COMMA					= 0x33,
	eIKBDSCAN_COLON					= 0x27,
	eIKBDSCAN_DOLLARSIGN			= 0x05,
	eIKBDSCAN_DOT					= 0x34,
	eIKBDSCAN_EQUALS				= 0x0D,
	eIKBDSCAN_EXCLAMATIONMARK		= 0x02,
	eIKBDSCAN_FORWARDSLASH			= 0x60,
	eIKBDSCAN_GREATERTHAN			= 0x34,
	eIKBDSCAN_HASH					= 0x2B,
	eIKBDSCAN_LESSTHAN				= 0x33,
	eIKBDSCAN_MINUS					= 0x0C,
	eIKBDSCAN_OPENAPOSTROPHE		= 0x29,
	eIKBDSCAN_OPENBRACKET			= 0x0A,
	eIKBDSCAN_OPENCURLYBRACKET		= 0x1A,
	eIKBDSCAN_OPENSQUAREBRACKET		= 0x1A,
	eIKBDSCAN_OVERSCORE				= 0x29,
	eIKBDSCAN_PERCENTAGE			= 0x06,
	eIKBDSCAN_PLUS					= 0x0D,
	eIKBDSCAN_POUNDSIGN				= 0x04,
	eIKBDSCAN_QUOTEMARK				= 0x03,
	eIKBDSCAN_QUESTTIONMARK			= 0x35,
	eIKBDSCAN_SEMICOLON				= 0x27,
	eIKBDSCAN_STAR					= 0x09,
	eIKBDSCAN_TILDE					= 0x2B,
	eIKBDSCAN_UNDERSCORE			= 0x0C,

	eIKBDSCAN_NUMPAD0				= 0x70,
	eIKBDSCAN_NUMPAD1				= 0x6D,
	eIKBDSCAN_NUMPAD2				= 0x6E,
	eIKBDSCAN_NUMPAD3				= 0x6F,
	eIKBDSCAN_NUMPAD4				= 0x6A,
	eIKBDSCAN_NUMPAD5				= 0x6B,
	eIKBDSCAN_NUMPAD6				= 0x6C,
	eIKBDSCAN_NUMPAD7				= 0x67,
	eIKBDSCAN_NUMPAD8				= 0x68,
	eIKBDSCAN_NUMPAD9				= 0x69,
	eIKBDSCAN_NUMPADOPENBRACKET		= 0x63,
	eIKBDSCAN_NUMPADCLOSEBRACKET	= 0x64,
	eIKBDSCAN_NUMPADDOT				= 0x71,
	eIKBDSCAN_NUMPADENTER			= 0x72,
	eIKBDSCAN_NUMPADMINUS			= 0x4A,
	eIKBDSCAN_NUMPADPLUS			= 0x4E,
	eIKBDSCAN_NUMPADSLASH			= 0x65,
	eIKBDSCAN_NUMPADSTAR			= 0x66,

	eIKBDSCAN_DOWNARROW		= 0x50,
	eIKBDSCAN_LEFTARROW		= 0x4B,
	eIKBDSCAN_RIGHTARROW	= 0x4D,
	eIKBDSCAN_UPARROW		= 0x48,

	eIKBDSCAN_ALTERNATE		=	0x38,
	eIKBDSCAN_BACKSPACE		=	0x0E,
	eIKBDSCAN_CAPSLOCK		=	0x3A,
	eIKBDSCAN_CLRHOME		=	0x47,
	eIKBDSCAN_CONTROL		=	0x1D,
	eIKBDSCAN_DELETE		=	0x53,
	eIKBDSCAN_ESC			=	0x01,
	eIKBDSCAN_HELP			=	0x62,
	eIKBDSCAN_INSERT		=	0x52,
	eIKBDSCAN_LEFTSHIFT		=	0x2A,
	eIKBDSCAN_RETURN		=	0x1C,
	eIKBDSCAN_RIGHTSHIFT	=	0x36,
	eIKBDSCAN_SPACE			=	0x39,
	eIKBDSCAN_TAB			=	0x0F,
	eIKBDSCAN_UNDO			=	0x61,

};


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void			IKBD_Init( void );
void			IKBD_DeInit( void );

U8				IKBD_GetKeyStatus( U8 aScanCode );

S16				IKBD_GetMouseX( void );
S16				IKBD_GetMouseY( void );
U8				IKBD_GetMouseButtonLeft( void );
U8				IKBD_GetMouseButtonRight( void );
void			IKBD_SetMouseX( S16 aX );
void			IKBD_SetMouseY( S16 aY );
void			IKBD_SetMousePosition( S16 aX, S16 aY );
U8				IKBD_GetMouseKeys( void );

U8				IKBD_GetKeyPressedFlag( void );
void			IKBD_ClearKeyPressedFlag( void );
U8				IKBD_GetLastKeyPress( void );
void			IKBD_ClearLastKeyPress( void );

U8				IKBD_GetJoy0Packet( void );
U8				IKBD_GetJoy1Packet( void );

U8				IKBD_GetPad0Dir( void );
U8				IKBD_GetPad1Dir( void );
U16				IKBD_GetPad0Key( void );
U16				IKBD_GetPad1Key( void );

U8				IKBD_GetTeamTapPadDir( const U8 aTap, const U8 aPad );
U16				IKBD_GetTeamTapPadKey( const U8 aTap, const U8 aPad );

U8				IKBD_GetKbdOverflowFlag( void );
U8				IKBD_GetMidiOverflowFlag( void );

void			IKBD_EnableJoysticks( void);
void			IKBD_EnableMouse( void );

void			IKBD_EnableDebugging( void );
void			IKBD_WaitForKey( const U8 aKey );
void			IKBD_WaitAnyKey( void );

U8				IKBD_ConvertScancodeAscii( U8 aScan );
U8				IKBD_ConvertScancodeAsciiCaps( U8 aScan );

extern	U16		IKBD_GetMidiBytesWaiting( void );
extern	U16		IKBD_GetKbdBytesWaiting( void );
extern	U8		IKBD_PopMidiByte( void );
extern	U8		IKBD_PopKbdByte( void );

void			IKBD_WaitForKey( const U8 aKey );
void			IKBD_WaitAnyKey();

void			IKBD_EnableTeamTap0( void );
void			IKBD_EnableTeamTap1( void );
void			IKBD_DisableTeamTap0( void );
void			IKBD_DisableTeamTap1( void );

void			IKBD_ClearBuffer( void );

extern	void	IKBD_Flush( void );
extern	void	IKBD_FlushGemdos( void );


/* ################################################################################ */

#endif	/*	INCLUDED_IKBD_H	*/