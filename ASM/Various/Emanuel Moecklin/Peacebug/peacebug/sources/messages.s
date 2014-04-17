*-------------------------------------------------------------------------------

		.EXPORT		BU_MESSAGE_1,BU_MESSAGE_2,AD_MESSAGE_1,AD_MESSAGE_2
		.EXPORT		IL_MESSAGE,DI_MESSAGE,CH_MESSAGE,TV_MESSAGE,PR_MESSAGE
		.EXPORT		LA_MESSAGE,LF_MESSAGE,CP_MESSAGE,FO_MESSAGE,IN_MESSAGE
		.EXPORT		SI_MESSAGE,VB_MESSAGE,NM_MESSAGE,TP_MESSAGE,GE_MESSAGE
		.EXPORT		AE_MESSAGE,VD_MESSAGE,BI_MESSAGE,XB_MESSAGE,C1_MESSAGE
		.EXPORT		C1_MESSAGE,C2_MESSAGE,C3_MESSAGE,C4_MESSAGE,C5_MESSAGE
		.EXPORT		C6_MESSAGE,C7_MESSAGE,PC_MESSAGE,PI_MESSAGE,PA_MESSAGE
		.EXPORT		HZ_MESSAGE,KB_MESSAGE,RI_MESSAGE,ET_MESSAGE
		.EXPORT		RE_MESSAGE_1,RE_MESSAGE_2

		.EXPORT		Installed,NotInstalled,JumpinMessage,SymbolLoaded
		.EXPORT		Alive,Terminated

		.EXPORT		PERMANENT_MESSAGE,ANZAHL_MESSAGE

		.EXPORT		MenueZeile,MenueFlags,MenueMaske_1,MenueMaske_2,MenusMaske_3

		.EXPORT		OBSERVE_MESSAGE
		.EXPORT		TIMEOUT_ERROR,UNGERADE_ADRESSE
		.EXPORT		BPT_SET_MESSAGE,BPT_WEG_MESSAGE
		.EXPORT		PTERM_MESSAGE_1,PTERM_MESSAGE_2,PTERM_MESSAGE_3
		.EXPORT		CHEAT_ON_MESSAGE,CHEAT_OFF_MESSAGE
		.EXPORT		RESET_WITHIN

		.EXPORT		HelpRecord

		.INCLUDE	'EQU.S'
		.INCLUDE	'MACRO.S'

		.DATA

*-------------------------------------------------------------------------------

* Exceptionmessages

BU_MESSAGE_1:		dc.b	'Bus Error at $, reading from $, FC $',0
BU_MESSAGE_2:		dc.b	'Bus Error at $, writting to $, FC $',0
AD_MESSAGE_1:		dc.b	'Address Error at $, reading from $, FC $',0
AD_MESSAGE_2:		dc.b	'Address Error at $, writting to $, FC $',0
					dc.b	-1
IL_MESSAGE:			dc.b	'Illegal Instruction at $',0
DI_MESSAGE:			dc.b	'Zero Divide at $',0
CH_MESSAGE:			dc.b	'CHK/CHK2 Instruction at $',0
TV_MESSAGE:			dc.b	'TRAPV/TRAPcc/cpTRAPcc Instructions at $',0
					dc.b	-1
PR_MESSAGE:			dc.b	'Privilege Violation at $',0
					dc.b	-1
LA_MESSAGE:			dc.b	'LINEA at $',0
					dc.b	-1
LF_MESSAGE:			dc.b	'LINEF at $',0
					dc.b	-1
CP_MESSAGE:			dc.b	'Coprocessor Protocol Violation at $',0
					dc.b	-1
FO_MESSAGE:			dc.b	'Format Error at $',0
IN_MESSAGE:			dc.b	'Uninitialized Interrupt at $',0
SI_MESSAGE:			dc.b	'Spurious Interrupt at $',0
VB_MESSAGE:			dc.b	'VBL at $',0
NM_MESSAGE:			dc.b	'Non Maskable Interrupt at $',0
TP_MESSAGE:			dc.b	'Trap $ at $',0
GE_MESSAGE:			dc.b	'GEMDOS-Call at $',0
AE_MESSAGE:			dc.b	'AES-Call at $',0
VD_MESSAGE:			dc.b	'VDI-Call at $',0
BI_MESSAGE:			dc.b	'BIOS-Call at $',0
XB_MESSAGE:			dc.b	'XBIOS-Call at $',0
C1_MESSAGE:			dc.b	'FPCP Branch or Set on Unordered Condition at $',0
C2_MESSAGE:			dc.b	'FPCP Inexact result at $',0
C3_MESSAGE:			dc.b	'FPCP Divide by Zero at $',0
C4_MESSAGE:			dc.b	'FPCP Underflow at $',0
C5_MESSAGE:			dc.b	'FPCP Operand Error at $',0
C6_MESSAGE:			dc.b	'FPCP Overflow at $',0
C7_MESSAGE:			dc.b	'FPCP Signaling NAN at $',0
PC_MESSAGE:			dc.b	'PMMU Configuration Error at $',0
PI_MESSAGE:			dc.b	'PMMU Illegal Operation at $',0
PA_MESSAGE:			dc.b	'PMMU Access Level Violation at $',0
HZ_MESSAGE:			dc.b	'HZ200 Timer Interrupt at $',0
KB_MESSAGE:			dc.b	'Keyboard Interrupt at $',0
RI_MESSAGE:			dc.b	'Ring Indicator at $',0
ET_MESSAGE:			dc.b	'ETV_CRITIC at $',0
RE_MESSAGE_1:		dc.b	'Reset: initializing hardware, system variables and BIOS, boot from HD',0
RE_MESSAGE_2:		dc.b	'Reset: searching resident programs, starting autofolder programs',0

*-------------------------------------------------------------------------------

* Installmessages

Installed:			dc.b	13,10,27,112,' Peacebug V'
				.IF (VERSION>>24)>48
					dc.b	VERSION>>24
				.ENDIF
					dc.b	(VERSION>>16)&$FF
					dc.b	'.'
					dc.b	(VERSION>>8)&$FF
					dc.b	VERSION&$FF
				.IF BETATEST
					dc.b	'û'
				.ENDIF
					dc.b	' installed     ',27,113,13,10
					dc.b	32,189,' 1991-95 by Emanuel Mîcklin',13,10,0

*---------------

NotInstalled:		dc.b	13,10,27,112,' Peacebug V'
				.IF (VERSION>>24)>48
					dc.b	VERSION>>24
				.ENDIF
					dc.b	(VERSION>>16)&$FF
					dc.b	'.'
					dc.b	(VERSION>>8)&$FF
					dc.b	VERSION&$FF
				.IF BETATEST
					dc.b	'û'
				.ENDIF
					dc.b	' not installed ',27,113,13,10,0

*---------------

JumpinMessage:		dc.b	'PEACEBUG V'
				.IF (VERSION>>24)>48
					dc.b	VERSION>>24
				.ENDIF
					dc.b	(VERSION>>16)&$FF
					dc.b	'.'
					dc.b	(VERSION>>8)&$FF
					dc.b	VERSION&$FF
				.IF BETATEST
					dc.b	'û'
				.ENDIF
					dc.b	', written by Emanuel Mîcklin',0

*---------------

SymbolLoaded:		dc.b	' Symboltable loaded',13,10,0
Alive:				dc.b	13,10,27,112,' Peacebug is still alive ',27,113,13,10,0
Terminated:			dc.b	13,10,27,112,' Peacebug terminated ',27,113,13,10,0

*-------------------------------------------------------------------------------

* Breakpointmessages

PERMANENT_MESSAGE:	dc.b	'Permanent Breakpoint $ at $',0
ANZAHL_MESSAGE: 	dc.b	'Stop Breakpoint $ at $',0

*-------------------------------------------------------------------------------

* Menue

MenueZeile: 		dc.b	'Trace   Do PC   Tracrts Texecpt Skip PC Ascii   Hexdump Disassm List    Switch  '
					dc.b	'         PEACEBUG V'
				.IF (VERSION>>24)>48
					dc.b	VERSION>>24
				.ENDIF
					dc.b	(VERSION>>16)&$FF
					dc.b	'.'
					dc.b	(VERSION>>8)&$FF
					dc.b	VERSION&$FF
				.IF BETATEST
					dc.b	'û'
				.ENDIF
					dc.b	' written by:',0

MenueFlags:			dc.b	'Tr68020 Tnosubs Tracrte GoTraps Breakpt Font    Symbol+ Insert+ Go PC   00:00:00'
					dc.b	'         Emanuel Mîcklin',0
MenueMaske_1: 		dc.b	'   0000 PC=######## USP=######## ISP=######## MSP=########  SR=TTSM-210---XNZVC '
					dc.b	'         Rainfussweg 7',0
MenueMaske_2: 		dc.b	' D0-D7 ######## ######## ######## ######## ######## ######## ######## ######## '
					dc.b	'         CH-8038 ZÅrich',0
MenueMaske_3: 		dc.b	' A0-A7 ######## ######## ######## ######## ######## ######## ######## ######## '
					dc.b	'         peace@soziologie.unizh.ch',0

*-------------------------------------------------------------------------------

OBSERVE_MESSAGE:	dc.b	'The observed memory has changed at $, observed at $',0
TIMEOUT_ERROR:		dc.b	'Timeout',0
UNGERADE_ADRESSE:	dc.b	'Address error exception',0
BPT_SET_MESSAGE:	dc.b	'Stop Breakpoint $ set',0
BPT_WEG_MESSAGE:	dc.b	'Stop Breakpoint $ cleared',0
PTERM_MESSAGE_1:	dc.b	'Pterm0 at $',0
PTERM_MESSAGE_2:	dc.b	'Pterm at $',0
PTERM_MESSAGE_3:	dc.b	'Ptermres at $',0
CHEAT_ON_MESSAGE:	dc.b	'Cheatmode is on',0
CHEAT_OFF_MESSAGE:	dc.b	'Cheatmode is off',0
RESET_WITHIN:		dc.b	'Reset within PEACEBUG',0

*-------------------------------------------------------------------------------

					dc.b	'Ascii [From][,To|#Lines|[Bytes]|.]',0

HelpRecord:			dc.b	'Ascii [From][,To|#Lines|[Bytes]|.]',0
					dc.b	'ASCFind[.w|.l] [From],[To],String',0
					dc.b	'Breakpoints [-|Number-|Number|Number=Address[,Number|,*|,=[Value]]]',0
					dc.b	'Call [Address]',0
					dc.b	'CD [Path]',0
					dc.b	'CHecksumme [Address][,Checksum][,Number]',0
					dc.b	'CLr [From][,To]',0
					dc.b	'COld',0
					dc.b	'COMpare[.b|.w|.l] [From],[To],Destination',0
					dc.b	'COOkie',0
					dc.b	'COPy [From],[To],Destination',0
					dc.b	'Disassemble [From][,To|#Lines|[Bytes]|.]|:[CPUs]',0
					dc.b	'DFree [Drive:]',0
					dc.b	'DIRectory [Path]',0
					dc.b	'DO [Address]',0
					dc.b	'DUmp [From][,To|#Lines|[Bytes]|.]',0
					dc.b	'Exit [Value]',0
					dc.b	'Find[.b|.w|.l] [From],[To],Term{,Term}',0
					dc.b	'FILl [From],[To],Term{,Term}',0
					dc.b	'FRee',0
					dc.b	'Go [Address][,Breakpoint]',0
					dc.b	'Help [Command]',0
					dc.b	'HUnt [From],[To],Term{,Term}',0
					dc.b	'Info',0
					dc.b	'List [From][,To|#Lines|[Bytes]|.]',0
					dc.b	'LAst',0
					dc.b	'LEt Register=Value',0
					dc.b	'LEXecute Filename',0
					dc.b	'LOad Filename[,Start[,End]]|-',0
					dc.b	'LS [Pfad]',0
					dc.b	'Memory [From][,To|#Lines|[Bytes]|.]',0
					dc.b	'MKdirectory Directory',0
					dc.b	'Newformat',0
					dc.b	'Observe [+|-|[Address][,Bytes]]',0
					dc.b	'Page',0
					dc.b	'PRograms',0
					dc.b	'Quit [Value]',0
					dc.b	'Readsector [Track][,Sector][,Side][,Address][,Drive]',0
					dc.b	'REGister [Register]',0
					dc.b	'RESident',0
					dc.b	'RMdirectory Directory|File',0
					dc.b	'Save Filename[,Start,End]',0
					dc.b	'SEt Register=Value',0
					dc.b	'SHowmemory [-|Number-|Number|Term[,List]]',0
					dc.b	'SLow [+|-]',0
					dc.b	'SWitch [ResolutionDebugger][,ResolutionProgram]',0
					dc.b	'SYmbol [From][,To]',0
					dc.b	'SYSinfo',0
					dc.b	'Trace [Number|+|-|*|/]',0
					dc.b	'Warm',0
					dc.b	'WRitesector [Track][,Sector][,Side][,Address][,Drive]',0
					dc.b	'Xbra [FirstVector][,LastVector][,ID]',0
					dc.b	'? Term{,Term}',0
					dc.b	'/ [.b|.w|.a|.l] [Term]{,Term}',0
					dc.b	'! Opcode',0
					dc.b	', [.b|.w|.a|.l] [Term]{,Term}',0
					dc.b	') String',0
					dc.b	': Address[,Term]{,Term}',0

*-------------------------------------------------------------------------------

		.EVEN
