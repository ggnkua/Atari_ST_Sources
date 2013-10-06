**************************************************************************************
*
* Falcon030 File Library
*
* [c] 1999 Reservoir Gods 
*
**************************************************************************************

	export	File_Init

	export	File_Open
	export	File_Create
	export	File_Read
	export	File_Write
	export	File_Seek
	export	File_Close

	export	File_Exists
	export	File_Size

	export	File_Save
	export	File_Load

**************************************************************************************
;	EQUATES
**************************************************************************************

eS_READ			equ	0	; open file for read only
eS_WRITE		equ	1	; open file for write only
eS_READWRITE	equ	2	; open file for read/write

eSEEK_SET		equ	0	; seek to offset
eSEEK_CUR		equ	1	; seek from current file pointer
eSEEK_END		equ	2	; seek to (end-offset)

eFA_READONLY	equ	0	; read only file
eFA_HIDDEN		equ	1	; hidden file
eFA_SYSTEM		equ	2	; system file
eFA_VOLUME		equ	3	; volume label
eFA_ARCHIVE		equ	5	; archive file

eRW_READ		equ	0	; read sector
eRW_WRITE		equ	1	; write sector
eRW_NOMEDIACH	equ	2	; do not modify media change status
eRW_NORETRIES	equ	4	; disable retries
eRW_NOTRANSLATE	equ	3	; do not translate logical sectors into physical

eDTA_RESERVED	equ	0					; rs.b	21
eDTA_ATTRIB		equ	eDTA_RESERVED+21	; rs.b	1
eDTA_TIME		equ	eDTA_ATTRIB+1		; rs.w	1
eDTA_DATE		equ	eDTA_TIME+2			; rs.w	1
eDTA_LENGTH		equ	eDTA_DATE+2			; rs.l	1
eDTA_FNAME		equ	eDTA_LENGTH+4		; rs.b	14
eDTA_SIZEOF		equ	eDTA_FNAME+14		; rs.w	1


**************************************************************************************
	TEXT
**************************************************************************************


*------------------------------------------------------------------------------------*
*
* Function:    void File_Init()
*
* Description: initialises file system
*
* Created:     11.04.99 PNK
*
*------------------------------------------------------------------------------------*

File_Init:
	move.l	a0,-(a7)			; save registers

	lea		fileDTA,a0			; new DTA address
	bsr		File_SetDTA			; set DTA

	move.l	(a7)+,a0			; restore registers
	rts


*------------------------------------------------------------------------------------*
*
* Function:    S32 File_Open( char * apFname )
*
* Description: opens a file
*
* Created:     11.04.99 PNK
*
*------------------------------------------------------------------------------------*

File_Open:
	movem.l	d1-d2/a0-a2,-(a7)	; save registers

	move.w	#eS_READWRITE,-(a7)	; mode
	pea		(a0)				; filename
	move.w	#$3d,-(a7)			; Fopen()
	trap	#1					; call GEMDOS
	addq.l	#8,a7				; fix stack
	move.w	d0,fileHandle		; save file handle

	movem.l	(a7)+,d1-d2/a0-a2	; restore registers
	rts


*------------------------------------------------------------------------------------*
*
* Function:    S32 File_Create( char * apFname )
*
* Description: creates a file
*
* Created:     11.04.99 PNK
*
*------------------------------------------------------------------------------------*

File_Create:
	movem.l	d1-d2/a0-a2,-(a7)	; save registers

	move.w	#eFA_SYSTEM,-(a7)	; file attribute
	pea		(a0)				; filename
	move.w	#$3c,-(a7)			; Fcreate()
	trap	#1					; call GEMDOS
	addq.l	#8,a7				; fix stack
	move.w	d0,fileHandle		; save file handle

	movem.l	(a7)+,d1-d2/a0-a2	; restore registers
	rts


*------------------------------------------------------------------------------------*
*
* Function:    S32 File_Read( U32 aBytes, void * apAdr )
*
* Description: reads bytes to pAdr
*
* Created:     11.04.99 PNK
*
*------------------------------------------------------------------------------------*

File_Read:
	movem.l	d1-d2/a0-a2,-(a7)	; save registers

	pea		(a0)				; address
	move.l	d0,-(a7)			; length
	move.w	fileHandle,-(a7)	; file handle
	move.w	#$3f,-(a7)			; Fread()
	trap	#1					; call GEMDOS
	lea		12(a7),a7			; fix stack	

	movem.l	(a7)+,d1-d2/a0-a2	; restore registers
	rts


*------------------------------------------------------------------------------------*
*
* Function:    S32 File_Seek( U16 aMode, U32 aOffset)
*
* Description: seeks into a file
*
* Created:     11.04.99 PNK
*
*------------------------------------------------------------------------------------*

File_Seek:
	movem.l	d1-d2/a0-a2,-(a7)	; save registers

	move.w	d0,-(a7)			; mode
	move.w	fileHandle,-(a7)	; file handle
	move.l	d1,-(a7)			; offset
	move.w	#$42,-(a7)			; Fseek()
	trap	#1					; call GEMDOS
	lea		10(a7),a7			; fix stack

	movem.l	(a7)+,d1-d2/a0-a2	; restore registers
	rts


*------------------------------------------------------------------------------------*
*
* Function:    S32 File_Write( U32 aBytes, void * apAdr )
*
* Description: writes bytes from pAdr
*
* Created:     11.04.99 PNK
*
*------------------------------------------------------------------------------------*

File_Write:
	movem.l	d1-d2/a0-a2,-(a7)	; save registers

	pea		(a0)				; address
	move.l	d0,-(a7)			; length
	move.w	fileHandle,-(a7)	; file handle
	move.w	#$40,-(a7)			; Fwrite()
	trap	#1					; call GEMDOS
	lea		12(a7),a7			; fix stack

	movem.l	(a7)+,d1-d2/a0-a2	; restore registers
	rts


*------------------------------------------------------------------------------------*
*
* Function:    void File_Close()
*
* Description: closes currently open file
*
* Created:     11.04.99 PNK
*
*------------------------------------------------------------------------------------*

File_Close:
	movem.l	d1-d2/a0-a2,-(a7)	; save registers

	move.w	fileHandle,-(a7)	; file handle
	move.w	#$3e,-(a7)			; Fclose()
	trap	#1					; call GEMDOS
	addq.l	#4,a7				; fix stack

	movem.l	(a7)+,d1-d2/a0-a2	; restore registers
	rts


*------------------------------------------------------------------------------------*
*
* Function:    void File_SetDTA()
*
* Description: sets DTA
*
* Comments:    this must be called at start of program to avoid DTA overwriting basepage
*
* Created:     11.04.99 PNK
*
*------------------------------------------------------------------------------------*

File_SetDTA:
	movem.l	d0-d2/a0-a2,-(a7)	; save registers

	pea		(a0)				; new DTA address
	move.w	#$1a,-(a7)			; Fsetdta()
	trap	#1					; call GEMDOS
	addq.l	#6,a7				; fix stack

	movem.l	(a7)+,d0-d2/a0-a2	; restore registers
	rts


*------------------------------------------------------------------------------------*
*
* Function:    void File_First( char * apFname )
*
* Description: reads file information into DTA
*
* Created:     11.04.99 PNK
*
*------------------------------------------------------------------------------------*

File_First:
	movem.l	d1-d2/a0-a2,-(a7)	; save registers

	move.w	d0,-(a7)			; attribs
	pea		(a0)				; filename
	move.w	#$4e,-(a7)			; Fsfirst()
	trap	#1					; call GEMDOS
	addq.l	#8,a7				; fix stack

	movem.l	(a7)+,d1-d2/a0-a2	; restore registers
	rts


*------------------------------------------------------------------------------------*
*
* Function:    void File_ReadSectors( U16 aDevice, U16 aFirstSec, U16 aCount, void * apBuffer )
*
* Description: reads count sectors from aFristSec on aDevice to apBuffer
*
* Comments:    mainly used by me to retrieve data after HD crashes!
*
* Created:     11.04.99 PNK
*
*------------------------------------------------------------------------------------*

File_ReadSectors:

	move.w	d0,-(a7)		; device ( a=0, b=1 etc.)
	move.w	d1,-(a7)		; first sector
	move.w	d2,-(a7)		; count	
	pea		(a0)			; buffer
	move.w	#eRW_READ,-(a7)	; mode ( RW_READ etc.)
	move.w	#$04,-(a7)		; Rwabs()
	trap	#13				; call BIOS
	lea		14(a7),a7		; fix stack
	rts


*------------------------------------------------------------------------------------*
*
* Function:    U32 File_Exists( char * apFname )
*
* Description: checks to see if file exists
*
* Comments:    returns 1 if exists, 0 if not exists
*
* Created:     11.04.99 PNK
*
*------------------------------------------------------------------------------------*

File_Exists:
	bsr		File_Open		; open file
	bmi		.NonExist		; file doesn't exits
	bsr		File_Close		; close file
	moveq	#1,d0			; return TRUE
	rts						
.NonExist:
	moveq	#0,d0			; return FALSE
	rts


*------------------------------------------------------------------------------------*
*
* Function:    U32 File_Size( char * apFname )
*
* Description: calcs length of file
*
* Created:     11.04.99 PNK
*
*------------------------------------------------------------------------------------*

File_Size:

	clr.l	fileDTA+eDTA_LENGTH		; default length to zero
	move.w	#$3f,d0					; search for all files
	bsr		File_First				; read file info
	move.l	fileDTA+eDTA_LENGTH,d0	; return length

	rts


*------------------------------------------------------------------------------------*
*
* Function:    S32 File_Load( char * apFname, void * apAdr )
*
* Description: loads entire file to pAdr
*
* Created:     11.04.99 PNK
*
*------------------------------------------------------------------------------------*

File_Load:	

	bsr		File_Size		; calc length of file
	tst.l	d0				; file exists?
	beq		.err			; no, end load
	move.l	d0,-(a7)		; save file size

	bsr		File_Open		; open file
	tst.l	d0				; check for errors
	bmi		.err			; file not found!

	move.l	(a7)+,d0		; file size
	move.l	a1,a0			; load address
	bsr		File_Read		; read all file
	bsr		File_Close		; close file

.err:
	rts


*------------------------------------------------------------------------------------*
*
* Function:    S32 File_Save( U32 aBytes, char * apFname, void * apAdr )
*
* Description: saves entire file of bytes from pAdr
*
* Created:     11.04.99 PNK
*
*------------------------------------------------------------------------------------*

File_Save:
	move.l	d0,-(a7)		; save file length

	bsr		File_Create		; create file
	bmi		.err			; error creating file

	move.l	(a7)+,d0		; file length
	move.l	a1,a0			; buffer address
	bsr		File_Write		; write file
	bsr		File_Close		; close file

.err:
	rts


**************************************************************************************
	BSS
**************************************************************************************

fileHandle:		ds.w	1
fileDTA:		ds.b	eDTA_SIZEOF