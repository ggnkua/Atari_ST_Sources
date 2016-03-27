; TABSIZE = 8
;  #[ Structures Macros:

StructInit	macro
X		set	0
		endm

SizeOF		macro	\1
\1		equ	X
		endm

WordEven	macro
		ifne	X-((X/2)*2)
X		set	X+1
		endc
		endm

LongEven	macro
		WordEven
		ifne	X-((X/4)*4)
X		set	X+2
		endc
		endm

Byte		macro
		ifnc	'\1',''
\1		equ	X
		endc
		ifc	'\2',''
X		set	X+1
		elseif
X		set	X+(\2)
		endc
		endm

Struct		macro
\1		equ	X
X		set	X+(\2)
		endm

Word		macro
		ifnc	'\1',''
\1		equ	X
		endc
		ifc	'\2',''
X		set	X+2
		elseif
X		set	X+(2*(\2))
		endc
		endm

Long		macro
		ifnc	'\1',''
\1		equ	X
		endc
		ifc	'\2',''
X		set	X+4
		elseif
X		set	X+(4*(\2))
		endc
		endm

Ptr		macro
		ifnc	'\1',''
\1		equ	X
		endc
		ifc	'\2',''
X		set	X+4
		elseif
X		set	X+(4*(\2))
		endc
		endm

;  #] Structures Macros: 
;  #[ Cookie Structure:

 StructInit
 Long CookieVersion
 Ptr  CookieOpenDriver
 Ptr  CookieCloseDriver
 Ptr  CookieGetStructSize
 Ptr  CookieGetImageInfo
 Ptr  CookieGetImageSize
 Ptr  CookieDecodeImage
 SizeOF CookieStruct

;  #] Cookie Structure: 
;  #[ VDI MFDB Structure:

 StructInit
 Ptr  MFDBAddress
 Word MFDBPixelWidth
 Word MFDBPixelHeight
 Word MFDBWordSize
 Word MFDBFormatFlag
 Word MFDBBitPlanes
 Word MFDBReserved,3
 SizeOF MFDBStruct

;  #] VDI MFDB Structure: 
;  #[ JPEG Decoder Structure:

 StructInit
;
; Officially Referenced Structure:
;
 Ptr  InPointer				; JPEG Image Pointer
 Ptr  OutPointer			; Output Buffer/Filename Pointer (see OutFlag)
 Long InSize				; JPEG Image Size (Bytes)
 Long OutSize				; Output Image Size (Bytes)
 Word InComponents			; JPEG Image Components Number (1->4)
 Word OutComponents			; Output Components Number (1->4)
 Word OutPixelSize			; Output Pixel Size (1->4)
 Word OutFlag				; 0 (RAM Output) / -1 (Disk Output)
 Word XLoopCounter			; Number of MCUs per Row
 Word YLoopCounter			; Number of MCUs per Column
 Ptr  CreateOutputPtr			; Pointer to User Routine / 0
 Ptr  WriteOutputPtr			; Pointer to User Routine / 0
 Ptr  CloseOutputPtr			; Pointer to User Routine / 0
 Ptr  SigTermOutputPtr			; Pointer to User Routine / 0
 Ptr  Comp1GammaPtr			; Component 1 Gamma Table / 0
 Ptr  Comp2GammaPtr			; Component 2 Gamma Table / 0
 Ptr  Comp3GammaPtr			; Component 3 Gamma Table / 0
 Ptr  Comp4GammaPtr			; Component 4 Gamma Table / 0
 Ptr  UserRoutinePtr			; Pointer to User Routine (Called during Decompression) / 0
 Ptr  OutTmpPointer			; Current OutPointer / Temporary Disk Buffer Pointer (see OutFlag)
 Word MCUsCounter			; Number of MCUs not Decoded
 Word OutTmpHeight			; Number of Lines in OutTmpPointer
 Long UserLong1				; Free, Available for User
 Long UserLong2				; Free, Available for User
 Word OutHandle				; 0 / Output File Handle (see OutFlag)
 Struct OutMFDB,MFDBStruct		; Output Image MFDB
 SizeOF JPEGDecoderStruct

;  #] JPEG Decoder Structure: 
;  #[ EQUates:
;
; JPEG Structure Release Number
;
VERSION		equ	1

;
; Message returned by the decoder
;
NOERROR		equ	0		; File correctly uncompressed
UNKNOWNFORMAT	equ	1		; File is not JFIF (Error)
INVALIDMARKER	equ	2		; Reserved CCITT Marker Found (Error)
SOF1MARKER	equ	3		; Mode not handled by the decoder (Error)
SOF2MARKER	equ	4		; Mode not handled by the decoder (Error)
SOF3MARKER	equ	5		; Mode not handled by the decoder (Error)
SOF5MARKER	equ	6		; Mode not handled by the decoder (Error)
SOF6MARKER	equ	7		; Mode not handled by the decoder (Error)
SOF7MARKER	equ	8		; Mode not handled by the decoder (Error)
SOF9MARKER	equ	10		; Mode not handled by the decoder (Error)
SOF10MARKER	equ	11		; Mode not handled by the decoder (Error)
SOF11MARKER	equ	12		; Mode not handled by the decoder (Error)
SOF13MARKER	equ	13		; Mode not handled by the decoder (Error)
SOF14MARKER	equ	14		; Mode not handled by the decoder (Error)
SOF15MARKER	equ	15		; Mode not handled by the decoder (Error)
RSTmMARKER	equ	16		; Unexpected RSTm found (Error)
BADDHTMARKER	equ	17		; Buggy DHT Marker (Error)
DACMARKER	equ	18		; Marker not handled by the decoder (Error)
BADDQTMARKER	equ	19		; Buggy DQT Marker (Error)
DNLMARKER	equ	20		; Marker not handled by the decoder (Error)
BADDRIMARKER	equ	21		; Invalid DRI Header Size (Error)
DHPMARKER	equ	22		; Marker not handled by the decoder (Error)
EXPMARKER	equ	23		; Marker not handled by the decoder (Error)
BADSUBSAMPLING	equ	24		; Invalid components subsampling (Error)
NOTENOUGHMEMORY	equ	25		; Not enough memory... (Error)
DECODERBUSY	equ	26		; Decoder is busy (Error)
DSPBUSY		equ	27		; Can't lock the DSP (Error)
DSPLODERROR	equ	28		; Can't find .LOD File (Error)
BADSOFnMARKER	equ	29		; Buggy SOFn marker (Error)
BADSOSMARKER	equ	30		; Buggy SOS marker (Error)
HUFFMANERROR	equ	31		; Buggy Huffman Stream (Error)
BADPIXELFORMAT	equ	32		; Invalid Output Pixel Format (Error)
DISKFULL	equ	33		; Hard/Floppy Disk Full (Error)
MISSINGMARKER	equ	34		; Marker expected but not found (Error)
IMAGETRUNCATED	equ	35		; More bytes Needed (Error)
EXTRABYTES	equ	36		; Dummy Bytes after EOI Marker (Warning)
BADDNLMARKER	equ	37		; Unexpected or Invalid DNL found (Error)
NODNLMARKER	equ	38		; No DNL Marker found (Error)
USERABORT	equ	39		; User Routine signaled 'Abort'
DSPMEMORYERROR	equ	40		; Not Enough DSP RAM (Error)
NORSTmMARKER	equ	41		; RSTm Marker expected but not found
BADRSTmMARKER	equ	42		; Invalid RSTm Marker Number
DRIVERCLOSED	equ	43		; Driver is Already Closed.
ENDOFIMAGE	equ	44		; Stop Decoding (Internal Message, Should Never Appear)

;  #] EQUates: 

