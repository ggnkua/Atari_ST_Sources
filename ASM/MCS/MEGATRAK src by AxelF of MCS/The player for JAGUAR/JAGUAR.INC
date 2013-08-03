;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	JAGUAR.INC  Hardware Equates for JAGUAR System
;
;	COPYRIGHT 1992-1994 Atari Computer Corporation
;	UNAUTHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,
;	PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR
;	THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.
;	ALL RIGHTS RESERVED.
;
;      Last Modified: 9/19/94 - SDS
;                     2/16/95 - MF
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      GENERIC DEFINES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DRAM		EQU	$000000	; First system RAM location
USERRAM		EQU	$004000	; Beginning of non-reserved RAM
ENDRAM		EQU	$200000	; End of DRAM
INITSTACK	EQU	ENDRAM-4	; Good place to initialize stack

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      CPU REGISTERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LEVEL0		EQU	$100		; 68000 Level 0 Autovector Interrupt
USER0		EQU	$100		; Pseudonym for LEVEL0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Masks for INT1 CPU Interrupt Control Register

C_VIDENA	EQU	$0001		; Enable Video time-base interrupts
C_GPUENA	EQU	$0002		; Enable GPU register-write interrupt
C_OPENA		EQU	$0004		; Enable OP stop-object interrupt
C_PITENA	EQU	$0008		; Enable PIT interrupt
C_JERENA	EQU	$0010		; Enable Jerry interrupt

C_VIDCLR	EQU	$0100		; Clear pending video interrupts
C_GPUCLR	EQU	$0200		; Clear pending GPU interrupts
C_OPCLR		EQU	$0400		; Clear pending OP interrupts
C_PITCLR	EQU	$0800		; Clear pending PIT interrupts
C_JERCLR	EQU	$1000		; Clear pending Jerry interrupts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	JAGUAR REGISTERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BASE		EQU	$F00000	; TOM Internal Register Base

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	TOM REGISTERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HC		EQU	BASE + 4	; Horizontal Count
VC		EQU	BASE + 6	; Vertical Count
LPH		EQU	BASE + 8	; Horizontal Lightpen
LPV		EQU	BASE + $0A	; Vertical Lightpen
OB0		EQU	BASE + $10	; Current Object Phrase
OB1		EQU	BASE + $12
OB2		EQU	BASE + $14
OB3		EQU	BASE + $16
OLP		EQU	BASE + $20	; Object List Pointer
OBF		EQU	BASE + $26	; Object Processor Flag
VMODE		EQU	BASE + $28	; Video Mode
BORD1		EQU	BASE + $2A	; Border Color (Red & Green)
BORD2		EQU	BASE + $2C	; Border Color (Blue)
HDB1		EQU	BASE + $38	; Horizontal Display Begin One
HDB2		EQU	BASE + $3A	; Horizontal Display Begin Two
HDE		EQU	BASE + $3C	; Horizontal Display End
VS		EQU	BASE + $44	; Vertical Sync
VDB		EQU	BASE + $46	; Vertical Display Begin
VDE		EQU	BASE + $48	; Vertical Display End
VI		EQU	BASE + $4E	; Vertical Interrupt
PIT0		EQU	BASE + $50	; Programmable Interrupt Timer (Lo)
PIT1		EQU	BASE + $52	; Programmable Interrupt Timer (Hi)
BG		EQU	BASE + $58	; Background Color

INT1		EQU	BASE + $E0	; CPU Interrupt Control Register
INT2		EQU	BASE + $E2	; CPU Interrupt Resume Register

CLUT		EQU	BASE + $400	; Color Lookup Table

LBUFA		EQU	BASE + $800	; Line Buffer A
LBUFB		EQU	BASE + $1000	; Line Buffer B
LBUFC		EQU	BASE + $1800	; Line Buffer Current

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      OBJECT PROCESSOR EQUATES 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BITOBJ		EQU	0
SCBITOBJ	EQU	1
GPUOBJ		EQU	2
BRANCHOBJ	EQU	3
STOPOBJ		EQU	4

O_REFLECT	EQU	$00002000	; OR with top LONG of BITMAP object
O_RMW		EQU	$00004000
O_TRANS		EQU	$00008000
O_RELEASE	EQU	$00010000

O_DEPTH1	EQU	(0<<12)	; DEPTH Field for BITMAP objects
O_DEPTH2	EQU	(1<<12)
O_DEPTH4	EQU	(2<<12)
O_DEPTH8	EQU	(3<<12)
O_DEPTH16	EQU	(4<<12)
O_DEPTH32	EQU	(5<<12)

O_NOGAP		EQU	(1<<15)	; Phrase GAP between image phrases
O_1GAP		EQU	(2<<15)
O_2GAP		EQU	(3<<15)
O_3GAP		EQU	(4<<15)
O_4GAP		EQU	(5<<15)
O_5GAP		EQU	(6<<15)
O_6GAP		EQU	(7<<15)

O_BREQ		EQU	(0<<14)	; CC field of BRANCH objects
O_BRGT		EQU	(1<<14)
O_BRLT		EQU	(2<<14)
O_BROP		EQU	(3<<14)
O_BRHALF	EQU	(4<<14)

O_STOPINTS	EQU	$00000008	; Enable Interrupts in STOP object

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      VIDEO INITIALIZATION CONSTANTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NTSC_WIDTH	EQU	1409		; Width of screen in pixel clocks
NTSC_HMID	EQU	823		; Middle of screen in pixel clocks
NTSC_HEIGHT	EQU	241		; Height of screen in scanlines
NTSC_VMID	EQU	266		; Middle of screen in halflines

PAL_WIDTH	EQU	1381		; Same as above for PAL...
PAL_HMID	EQU	843
PAL_HEIGHT	EQU	287
PAL_VMID	EQU	322

;;; The following mask will extract the PAL/NTSC flag bit from the
;;; CONFIG register. NTSC = Bit Set, PAL = Bit Clear

VIDTYPE		EQU	$10 

;;; The following are Video Mode register flags

VIDEN		EQU	$0001		; Enable video-time base generator

CRY16		EQU	$0000		; Enable 16-bit CRY mode
RGB24		EQU	$0002		; Enable 24-bit RGB mode
DIRECT16	EQU	$0004		; Enable 16-bit DIRECT mode
RGB16		EQU	$0006		; Enable 16-bit RGB mode

GENLOCK		EQU	$0008		; Not Supported in Jaguar Console
INCEN		EQU	$0010		; Enable encrustation
BINC		EQU	$0020		; Select local border color
CSYNC		EQU	$0040		; Enable composite sync
BGEN		EQU	$0080		; Clear line buffer to BG
VARMOD		EQU	$0100		; Enable variable-color resolution mode

PWIDTH1		EQU	$0000		; Select pixels 1 clock wide
PWIDTH2		EQU	$0200		; Select pixels 2 clocks wide
PWIDTH3		EQU	$0400		; Select pixels 3 clocks wide
PWIDTH4		EQU	$0600		; Select pixels 4 clocks wide
PWIDTH5		EQU	$0800		; Select pixels 5 clocks wide
PWIDTH6		EQU	$0A00		; Select pixels 6 clocks wide
PWIDTH7		EQU	$0C00		; Select pixels 7 clocks wide
PWIDTH8		EQU	$0E00		; Select pixels 8 clocks wide

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	GPU REGISTERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

G_FLAGS 	EQU	BASE + $2100	; GPU Flags
G_MTXC		EQU	BASE + $2104	; GPU Matrix Control
G_MTXA		EQU	BASE + $2108	; GPU Matrix Address
G_END		EQU	BASE + $210C	; GPU Data Organization
G_PC		EQU	BASE + $2110	; GPU Program Counter
G_CTRL		EQU	BASE + $2114	; GPU Operation Control/Status
G_HIDATA 	EQU	BASE + $2118	; GPU Bus Interface high data
G_REMAIN 	EQU	BASE + $211C	; GPU Division Remainder
G_DIVCTRL 	EQU	BASE + $211C	; GPU Divider control
G_RAM		EQU	BASE + $3000	; GPU Internal RAM
G_ENDRAM	EQU	G_RAM +(4*1024)	; 4K bytes

;;;
;;; GPU Flags Register Equates
;;;

G_CPUENA	EQU	$00000010	; CPU Interrupt enable bits
G_DSPENA	EQU	$00000020	; DSP Interrupt enable bits
G_PITENA	EQU	$00000040	; PIT Interrupt enable bits
G_OPENA		EQU	$00000080	; Object Processor Interrupt enable bits
G_BLITENA	EQU	$00000100	; Blitter Interrupt enable bits
G_CPUCLR	EQU	$00000200	; CPU Interrupt clear bits
G_DSPCLR	EQU	$00000400	; DSP Interrupt clear bits
G_PITCLR	EQU	$00000800	; PIT Interrupt clear bits
G_OPCLR		EQU	$00001000	; Object Processor Interrupt clear bits
G_BLITCLR	EQU	$00002000	; Blitter Interrupt clear bits

;;;
;;; GPU Control/Status Register
;;;

GPUGO		EQU	$00000001	; Start and Stop the GPU
;GPUINT0		EQU	$00000004	; generate a GPU type 0 interrupt

G_CPULAT	EQU	$00000040	; Interrupt Latches
G_DSPLAT	EQU	$00000080
G_PITLAT	EQU	$00000100
G_OPLAT		EQU	$00000200
G_BLITLAT	EQU	$00000400

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	BLITTER REGISTERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

A1_BASE 	EQU	BASE + $2200	; A1 Base Address
A1_FLAGS	EQU	BASE + $2204	; A1 Control Flags
A1_CLIP		EQU	BASE + $2208	; A1 Clipping Size
A1_PIXEL	EQU	BASE + $220C	; A1 Pixel Pointer
A1_STEP		EQU	BASE + $2210	; A1 Step (Integer Part)
A1_FSTEP	EQU	BASE + $2214	; A1 Step (Fractional Part)
A1_FPIXEL	EQU	BASE + $2218	; A1 Pixel Pointer (Fractional)
A1_INC		EQU	BASE + $221C	; A1 Increment (Integer Part)
A1_FINC		EQU	BASE + $2220	; A1 Increment (Fractional Part)
A2_BASE		EQU	BASE + $2224	; A2 Base Address
A2_FLAGS	EQU	BASE + $2228	; A2 Control Flags
A2_MASK		EQU	BASE + $222C	; A2 Address Mask
A2_PIXEL	EQU	BASE + $2230	; A2 PIXEL
A2_STEP		EQU	BASE + $2234	; A2 Step (Integer)

B_CMD		EQU	BASE + $2238	; Command
B_COUNT		EQU	BASE + $223C	; Counters
B_SRCD		EQU	BASE + $2240	; Source Data
B_DSTD		EQU	BASE + $2248	; Destination Data
B_DSTZ		EQU	BASE + $2250	; Destination Z
B_SRCZ1		EQU	BASE + $2258	; Source Z (Integer)
B_SRCZ2		EQU	BASE + $2260	; Source Z (Fractional)
B_PATD		EQU	BASE + $2268	; Pattern Data
B_IINC		EQU	BASE + $2270	; Intensity Increment
B_ZINC		EQU	BASE + $2274	; Z Increment
B_STOP		EQU	BASE + $2278	; Collision stop control

B_I3		EQU	BASE + $227C	; Blitter Intensity 3
B_I2		EQU	BASE + $2280	; Blitter Intensity 2
B_I1		EQU	BASE + $2284	; Blitter Intensity 1
B_I0		EQU	BASE + $2288	; Blitter Intensity 0

B_Z3		EQU	BASE + $228C	; Blitter Z 3
B_Z2		EQU	BASE + $2290	; Blitter Z 2
B_Z1		EQU	BASE + $2294	; Blitter Z 1
B_Z0		EQU	BASE + $2298	; Blitter Z 0

;;;
;;; BLITTER Command Register equates
;;;

SRCEN		EQU	$00000001	; d00:     source data read (inner loop)
SRCENZ		EQU	$00000002	; d01:     source Z read (inner loop)
SRCENX		EQU	$00000004	; d02:     source data read (realign)
DSTEN		EQU	$00000008	; d03:     dest data read (inner loop)
DSTENZ		EQU	$00000010	; d04:     dest Z read (inner loop)
DSTWRZ		EQU	$00000020	; d05:     dest Z write (inner loop)
CLIP_A1		EQU	$00000040	; d06:     A1 clipping enable
UPDA1F		EQU	$00000100	; d08:     A1 update step fraction
UPDA1		EQU	$00000200	; d09:     A1 update step
UPDA2		EQU	$00000400	; d10:     A2 update step
DSTA2		EQU	$00000800	; d11:     reverse usage of A1 and A2
GOURD		EQU	$00001000	; d12:     enable Gouraud shading
ZBUFF		EQU	$00002000	; d13:     polygon Z data updates
TOPBEN		EQU	$00004000	; d14:     intensity carry into byte
TOPNEN		EQU	$00008000	; d15:     intensity carry into nibble
PATDSEL		EQU	$00010000	; d16:     Select pattern data
ADDDSEL		EQU	$00020000	; d17:     diagnostic
					; d18-d20: Z comparator inhibit
ZMODELT		EQU	$00040000	; 	     source < destination
ZMODEEQ		EQU	$00080000	;	     source = destination
ZMODEGT		EQU	$00100000	;	     source > destination
					; d21-d24: Logic function control
LFU_NAN		EQU	$00200000	; 	     !source & !destination
LFU_NA		EQU	$00400000	; 	     !source &  destination
LFU_AN		EQU	$00800000	; 	      source & !destination
LFU_A		EQU	$01000000	; 	      source &  destination

CMPDST		EQU	$02000000	; d25:     pixel compare pattern & dest
BCOMPEN		EQU	$04000000	; d26:     bit compare write inhibit
DCOMPEN		EQU	$08000000	; d27:     data compare write inhibit
BKGWREN		EQU	$10000000	; d28:     data write back
BUSHI		EQU	$20000000	; d29	   blitter priority
SRCSHADE	EQU	$40000000	; d30:	   shade src data w/IINC value

;;;
;;; The following are ALL 16 possible logical operations of the LFUs
;;;

LFU_ZERO	EQU	$00000000	; All Zeros
LFU_NSAND	EQU	$00200000	; NOT Source AND NOT Destination
LFU_NSAD	EQU	$00400000	; NOT Source AND Destination
LFU_NOTS	EQU	$00600000	; NOT Source
LFU_SAND	EQU	$00800000	; Source AND NOT Destination
LFU_NOTD	EQU	$00A00000	; NOT Destination
LFU_N_SXORD	EQU	$00C00000	; NOT (Source XOR Destination)
LFU_NSORND	EQU	$00E00000	; NOT Source OR NOT Destination
LFU_SAD		EQU	$01000000	; Source AND Destination
LFU_SXORD	EQU	$01200000	; Source XOR Destination
LFU_D		EQU	$01400000	; Destination
LFU_NSORD	EQU	$01600000	; NOT Source OR Destination
LFU_S		EQU	$01800000	; Source
LFU_SORND	EQU	$01A00000	; Source OR NOT Destination
LFU_SORD	EQU	$01C00000	; Source OR Destination
LFU_ONE		EQU	$01E00000	; All Ones

; These are some common combinations with less boolean names

LFU_REPLACE	EQU	$01800000	; Source REPLACEs destination
LFU_XOR		EQU	$01200000	; Source XOR with destination
LFU_CLEAR	EQU	$00000000	; CLEAR destination

;;;
;;; BLITTER Flags (A1 or A2) register equates
;;;

; Pitch d00-d01:
;	distance between pixel phrases
PITCH1		EQU	$00000000	; 0 phrase gap
PITCH2		EQU	$00000001	; 1 phrase gap
PITCH4		EQU	$00000002	; 3 phrase gap
PITCH3		EQU	$00000003	; 2 phrase gap

; Pixel d03-d05
;	bit depth (2^n)
PIXEL1		EQU	$00000000	; n = 0	
PIXEL2		EQU	$00000008	; n = 1	
PIXEL4		EQU	$00000010	; n = 2	
PIXEL8		EQU	$00000018	; n = 3	
PIXEL16		EQU	$00000020	; n = 4	
PIXEL32		EQU	$00000028	; n = 5	

; Z offset d06-d08
;	offset from phrase of pixel data from its corresponding
;	Z data phrases
ZOFFS0		EQU	$00000000	; offset = 0	UNUSED
ZOFFS1		EQU	$00000040	; offset = 1
ZOFFS2		EQU	$00000080	; offset = 2
ZOFFS3		EQU	$000000C0	; offset = 3
ZOFFS4		EQU	$00000100	; offset = 4
ZOFFS5		EQU	$00000140	; offset = 5
ZOFFS6		EQU	$00000180	; offset = 6
ZOFFS7		EQU	$000001C0	; offset = 7	UNUSED

; Width d09-d14
;	width used for address generation
;	This is a 6-bit floating point value in pixels
;	4-bit unsigned exponent
;	2-bit mantissa with implied 3rd bit of 1
WID2		EQU	$00000800	; 1.00 X 2^1  ( 4<<9)
WID4 		EQU	$00001000	; 1.00 X 2^2  ( 8<<9)
WID6		EQU	$00001400	; 1.10 X 2^2  (10<<9)
WID8		EQU	$00001800	; 1.00 x 2^3  (12<<9)
WID10		EQU	$00001A00	; 1.01 X 2^3  (13<<9)
WID12		EQU	$00001C00	; 1.10 X 2^3  (14<<9)
WID14		EQU	$00001E00	; 1.11 X 2^3  (15<<9)
WID16		EQU	$00002000	; 1.00 X 2^4  (16<<9)
WID20		EQU	$00002200	; 1.01 X 2^4  (17<<9)
WID24		EQU	$00002400	; 1.10 X 2^4  (18<<9)
WID28		EQU	$00002600	; 1.11 X 2^4  (19<<9)
WID32		EQU	$00002800	; 1.00 X 2^5  (20<<9)
WID40		EQU	$00002A00	; 1.01 X 2^5  (21<<9)
WID48		EQU	$00002C00	; 1.10 X 2^5  (22<<9)
WID56		EQU	$00002E00	; 1.11 X 2^5  (23<<9)
WID64		EQU	$00003000	; 1.00 X 2^6  (24<<9)
WID80		EQU	$00003200	; 1.01 X 2^6  (25<<9)
WID96		EQU	$00003400	; 1.10 X 2^6  (26<<9)
WID112		EQU	$00003600	; 1.11 X 2^6  (27<<9)
WID128		EQU	$00003800	; 1.00 X 2^7  (28<<9)
WID160		EQU	$00003A00	; 1.01 X 2^7  (29<<9)
WID192		EQU	$00003C00	; 1.10 X 2^7  (30<<9)
WID224		EQU	$00003E00	; 1.11 X 2^7  (31<<9)
WID256		EQU	$00004000	; 1.00 X 2^8  (32<<9)
WID320		EQU	$00004200	; 1.01 X 2^8  (33<<9)
WID384		EQU	$00004400	; 1.10 X 2^8  (34<<9)
WID448		EQU	$00004600	; 1.11 X 2^8  (35<<9)
WID512		EQU	$00004800	; 1.00 X 2^9  (36<<9)
WID640		EQU	$00004A00	; 1.01 X 2^9  (37<<9)
WID768		EQU	$00004C00	; 1.10 X 2^9  (38<<9)
WID896		EQU	$00004E00	; 1.11 X 2^9  (39<<9)
WID1024		EQU	$00005000	; 1.00 X 2^10 (40<<9)
WID1280		EQU	$00005200	; 1.01 X 2^10 (41<<9)
WID1536		EQU	$00005400	; 1.10 X 2^10 (42<<9)
WID1792		EQU	$00005600	; 1.11 X 2^10 (43<<9)
WID2048		EQU	$00005800	; 1.00 X 2^11 (44<<9)
WID2560		EQU	$00005A00	; 1.01 X 2^11 (45<<9)
WID3072		EQU	$00005C00	; 1.10 X 2^11 (46<<9)
WID3584		EQU	$00005E00	; 1.11 X 2^11 (47<<9)

; X add control d16-d17
;	controls the update of the X pointer on each pass
;	round the inner loop
XADDPHR		EQU	$00000000	; 00 - add phrase width and truncate
XADDPIX		EQU	$00010000	; 01 - add pixel size (add 1)	
XADD0		EQU	$00020000	; 10 - add zero
XADDINC		EQU	$00030000	; 11 - add the increment

; Y add control	d18
;	controls the update of the Y pointer within the inner loop.
;	it is overridden by the X add control if they are in add increment
YADD0		EQU	$00000000	; 00 - add zero
YADD1		EQU	$00040000	; 01 - add 1

; X sign d19
;	add or subtract pixel size if X add control = 01 (XADDPIX)
XSIGNADD	EQU	$00000000	; 0 - add pixel size
XSIGNSUB	EQU	$00080000	; 1 - subtract pixel size

; Y sign d20
;	add or subtract pixel size if Y add control = 01 (YADD1)
YSIGNADD	EQU	$00000000	; 0 - add 1
YSIGNSUB	EQU	$00100000	; 1 - sub 1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	JERRY REGISTERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

JPIT1		EQU	BASE + $10000	; Timer 1 Pre-Scaler
JPIT2		EQU	BASE + $10002	; Timer 1 Divider
JPIT3		EQU	BASE + $10004	; Timer 2 Pre-Scaler
JPIT4		EQU	BASE + $10006	; Timer 2 Divider

J_INT           EQU     BASE + $10020   ; Jerry Interrupt control (to TOM)
		
JOYSTICK        EQU     BASE + $14000   ; Joystick register and mute
JOYBUTS		EQU	BASE + $14002	; Joystick register
CONFIG		EQU	BASE + $14002	; Also has NTSC/PAL

MOD_MASK	EQU	BASE + $1A118	; Mask for ADDQ(SUBQ)MOD

SCLK		EQU	BASE + $1A150	; SSI Clock Frequency
SMODE		EQU	BASE + $1A154	; SSI Control

L_I2S		EQU	BASE + $1A148	; I2S Serial Interface	
R_I2S		EQU	BASE + $1A14C	; I2S Serial Interface

;;;
;;; Jerry Interrupt Control Flags
;;;

J_EXTENA	EQU	$0001		; Enable external interrupts
J_DSPENA	EQU	$0002		; Enable DSP interrupts
J_TIM1ENA	EQU	$0004		; Enable Timer 1 interrupts
J_TIM2ENA	EQU	$0008		; Enable Timer 2 interrupts
J_ASYNENA	EQU	$0010		; Enable Asyncronous Serial interrupts
J_SYNENA	EQU	$0020		; Enable Syncronous Serial interrupts

J_EXTCLR	EQU	$0100		; Clear pending external interrupts
J_DSPCLR	EQU	$0200		; Clear pending DSP interrupts
J_TIM1CLR	EQU	$0400		; Clear pending Timer 1 interrupts
J_TIM2CLR	EQU	$0800		; Clear pending Timer 2 interrupts
J_ASYNCLR	EQU	$1000		; Clear pending Asynch. Serial interrupts
J_SYNCLR	EQU	$2000		; Clear pending Synch. Serial interrupts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;     JERRY Joystick Equates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Bits when LONGword is formatted as below (from JOYTEST\JT_LOOP.S).
;
; Format: xxApxxBx RLDU147* xxCxxxox 2580369#

JOY_UP		EQU	20		;joypad
JOY_DOWN	EQU	21
JOY_LEFT	EQU	22
JOY_RIGHT	EQU	23

FIRE_A		EQU	29		;fire buttons
FIRE_B		EQU	25
FIRE_C		EQU	13
OPTION		EQU	9
PAUSE		EQU	28

KEY_STAR	EQU	16		;keypad
KEY_7		EQU	17
KEY_4		EQU	18
KEY_1		EQU	19

KEY_0		EQU	4
KEY_8		EQU	5
KEY_5		EQU	6
KEY_2		EQU	7

KEY_HASH	EQU	0
KEY_9		EQU	1
KEY_6		EQU	2
KEY_3		EQU	3

ANY_JOY		EQU	$00F00000	; AND joyedge with this...
					; joypad was pressed if result is not 0
ANY_FIRE	EQU	$32002200	; AND joyedge with this...
					; A,B C, Option or Pause was pressed
					; if result is not 0
ANY_KEY		EQU	$000F00FF	; AND joyedge with this... 123456789*0#
					; was pressed if result is not 0

;;;
;;;	ROM Tables built into Jerry - 128 samples each
;;;	16 bit samples sign extended to 32
;;;

ROM_TABLE   	EQU	BASE + $1D000	; Base of tables

ROM_TRI     	EQU	BASE + $1D000	; A triangle wave
ROM_SINE    	EQU	BASE + $1D200	; Full amplitude SINE
ROM_AMSINE  	EQU	BASE + $1D400	; Linear (?) ramp SINE
ROM_12W 	EQU	BASE + $1D600	; SINE(X)+SINE(2*X) : (was ROM_SINE12W)
ROM_CHIRP16 	EQU	BASE + $1D800	; SHORT SWEEP
ROM_NTRI    	EQU	BASE + $1DA00	; Triangle w/NOISE
ROM_DELTA   	EQU	BASE + $1DC00	; Positive spike
ROM_NOISE   	EQU	BASE + $1DE00	; Guess

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	JERRY Registers (DSP)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

D_FLAGS		EQU	BASE + $1A100	; DSP Flags
D_MTXC		EQU	BASE + $1A104	; DSP Matrix Control
D_MTXA		EQU	BASE + $1A108	; DSP Matrix Address
D_END		EQU	BASE + $1A10C	; DSP Data Organization
D_PC		EQU	BASE + $1A110	; DSP Program Counter
D_CTRL		EQU	BASE + $1A114	; DSP Operation Control/Status
D_MOD           EQU     BASE + $1A118   ; DSP Modulo Instruction Mask
D_REMAIN 	EQU	BASE + $1A11C	; DSP Division Remainder
D_DIVCTRL 	EQU	BASE + $1A11C	; DSP Divider control
D_MACHI         EQU     BASE + $1A120   ; DSP Hi byte of MAC operations
D_RAM		EQU	BASE + $1B000	; DSP Internal RAM
D_ENDRAM	EQU	D_RAM +(8*1024)	; 8K bytes

;;;
;;; JERRY Flag Register Equates
;;;

D_CPUENA	EQU	$00000010	; CPU Interrupt Enable Bit
D_I2SENA	EQU	$00000020	; I2S Interrupt Enable Bit
D_TIM1ENA	EQU	$00000040	; Timer 1 Interrupt Enable Bit
D_TIM2ENA	EQU	$00000080	; Timer 2 Interrupt Enable Bit
D_EXT0ENA	EQU	$00000100	; External Interrupt 0 Enable Bit
D_EXT1ENA	EQU	$00010000	; External Interrupt 1 Enable Bit

D_CPUCLR	EQU	$00000200	; CPU Interrupt Clear Bit
D_I2SCLR	EQU	$00000400	; I2S Interrupt Clear Bit
D_TIM1CLR	EQU	$00000800	; Timer 1 Interrupt Clear Bit
D_TIM2CLR	EQU	$00001000	; Timer 2 Interrupt Clear Bit
D_EXT0CLR	EQU	$00002000	; External Interrupt 0 Clear Bit
D_EXT1CLR	EQU	$00020000	; External Interrupt 1 Clear Bit

;;;
;;; JERRY Control/Status Register
;;;

DSPGO		EQU	$00000001	; Start DSP
DSPINT0		EQU	$00000004	; Generate a DSP Interrupt 0

D_CPULAT	EQU	$00000040	; Interrupt Latches
D_I2SLAT	EQU	$00000080
D_TIM1LAT	EQU	$00000100
D_TIM2LAT	EQU	$00000200
D_EXT1LAT	EQU	$00000400
D_EXT2LAT	EQU	$00010000

;;;
;;; JERRY Modulo Instruction Masks
;;;

MODMASK2	EQU	$FFFFFFFE	; 2 byte circular buffer
MODMASK4	EQU	$FFFFFFFC	; 4 byte circular buffer
MODMASK8	EQU	$FFFFFFF8	; 8 byte circular buffer
MODMASK16	EQU	$FFFFFFF0	; 16 byte circular buffer
MODMASK32	EQU	$FFFFFFE0	; 32 byte circular buffer
MODMASK64	EQU	$FFFFFFC0	; 64 byte circular buffer
MODMASK128	EQU	$FFFFFF80	; 128 byte circular buffer
MODMASK256	EQU	$FFFFFF00	; 256 byte circular buffer
MODMASK512	EQU	$FFFFFE00	; 512 byte circular buffer
MODMASK1K	EQU	$FFFFFC00	; 1k circular buffer 
MODMASK2K	EQU	$FFFFF800	; 2k circular buffer
MODMASK4K	EQU	$FFFFF000	; 4k circular buffer
MODMASK8K	EQU	$FFFFE000	; 8k circular buffer
MODMASK16K	EQU	$FFFFC000	; 16k circular buffer
MODMASK32K	EQU	$FFFF8000	; 32k circular buffer
MODMASK64K	EQU	$FFFF0000	; 64k circular buffer
MODMASK128K	EQU	$FFFE0000	; 128k circular buffer
MODMASK256K	EQU	$FFFC0000	; 256k circular buffer
MODMASK512K	EQU	$FFF80000	; 512k circular buffer
MODMASK1M	EQU	$FFF00000	; 1M circular buffer
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; SHARED Equates for TOM (GPU) and JERRY (DSP)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; Control/Status Registers
;;;

RISCGO		EQU	$00000001	; Start GPU or DSP
CPUINT		EQU	$00000002	; Allow the GPU/DSP to interrupt CPU
FORCEINT0	EQU	$00000004	; Cause an INT 0 on GPU or DSP
SINGLE_STEP	EQU	$00000008	; Enter SINGLE_STEP mode
SINGLE_GO	EQU	$00000010	; Execute one instruction

REGPAGE		EQU	$00004000	; Register Bank Select
DMAEN  		EQU	$00008000	; Enable DMA LOAD and STORE

;;;
;;; Flags Register
;;;

ZERO_FLAG	EQU	$00000001	; ALU Zero Flag
CARRY_FLAG	EQU	$00000002	; ALU Carry Flag
NEGA_FLAG	EQU	$00000004	; ALU Negative Flag

IMASK		EQU	$00000008	; Interrupt Service Mask

;;;
;;; Matrix Control Register
;;;

MATRIX3		EQU	$00000003	; use for 3x1 Matrix
MATRIX4		EQU	$00000004	; etc...
MATRIX5		EQU	$00000005
MATRIX6		EQU	$00000006
MATRIX7		EQU	$00000007
MATRIX8		EQU	$00000008
MATRIX9		EQU	$00000009
MATRIX10	EQU	$0000000A
MATRIX11	EQU	$0000000B
MATRIX12	EQU	$0000000C
MATRIX13	EQU	$0000000D
MATRIX14	EQU	$0000000E
MATRIX15	EQU	$0000000F
		
MATROW		EQU	$00000000	; Access Matrix by Row
MATCOL		EQU	$00000010	; Access Matrix by Column

;;;
;;; Data Organisation Register
;;;

BIG_IO		EQU	$00010001	; Use 32-bit registers as big-endian
BIG_PIX		EQU	$00020002	; Pixel organisation is big-endian
BIG_INST	EQU	$00040004	; Word program fetches are big-endian

;;;
;;; Divide Unit Control
;;;

DIV_OFFSET	EQU	$00000001	; Divide 16.16 values if set

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; The following EQU's will be removed from JAGUAR.INC in the next release
;;; or two. For the most part, they are being removed because they are only
;;; useful in Jaguar programming methods we do not recommend.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

COMPAT		EQU	1

		IF	COMPAT
;;;
;;; These registers should never be messed with so these EQUs will
;;; be purged in the next revision of JAGUAR.INC. Please don't use them.
;;;

MEMCON1 	EQU	BASE + 0	; Memory Configuration Register One
MEMCON2 	EQU	BASE + 2	; Memory Configuration Register Two
OLPLO		EQU	BASE + $20
OLPHI		EQU	BASE + $22
ODP		EQU	BASE + $24	; Object Data Pointer
HP		EQU	BASE + $2e	; Horizontal Period
HBB		EQU	BASE + $30	; Horizontal Blanking Begin
HBE		EQU	BASE + $32	; Horizontal Blanking End
HS		EQU	BASE + $34	; Horizontal Sync
HVS		EQU	BASE + $36	; Horizontal Vertical Sync
VP		EQU	BASE + $3e	; Vertical Period
VBB		EQU	BASE + $40	; Vertical Blanking Begin
VBE		EQU	BASE + $42	; Vertical Blanking End
VEB		EQU	BASE + $4a	; Vertical EQUalization Begin
VEE		EQU	BASE + $4c	; Vertical EQUalization End
HEQ		EQU	BASE + $54	; Horizontal EQUalization End
TEST1		EQU	BASE + $56	; Undocumented Register - DO NOT USE

;;; These don't exist on the Jaguar Console so they are going away.
R_DAC		EQU	BASE + $1A148	; These are not connected in Jaguar	
L_DAC		EQU	BASE + $1A14C	; so DO NOT USE!!!

		ENDIF

;;;;;;;;;
;; EOF ;;
;;;;;;;;;
