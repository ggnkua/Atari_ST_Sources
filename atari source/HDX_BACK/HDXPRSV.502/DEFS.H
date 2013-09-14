;+
; Conditional assembly
;-
DRIVER	equ	0			; 0: not compiling for AHDI.PRG
DEBUG	equ	1			; 0: don't include debugging code
RDWDL	equ	0			; 0: don't need extra read from WDL

SCSIID	equ	6			; our (host) SCSI ID


;+
; Restraints 
;-
MAXLOG		equ	14		; max # of log units w/o drv A & B
MAXACSI		equ	8		; maximum number of ACSI devices
MAXSCSI		equ	8		; maximum number of SCSI devices
MAXIDE		equ	1		; maximum number of IDE devices
ACSIUNT		equ	7		; highest ACSI unit number
SCSIUNT		equ	15		; highest SCSI unit number
IDEUNT		equ	16		; highest IDE unit number
MAXACSECTS	equ	254		; max # of sectors/ACSI gulp
MAXSPSECTS	equ	16384		; max # of sectors/Sparrow SCSI gulp
MAXSCSECTS	equ	65534		; max # of sectors/SCSI gulp
MAXIDESECTS	equ	256		; max # of sectors/IDE gulp


;+
; Machine type as defined in the _MCH cookie
;-
_MCH		equ	$5f4d4348   ; _MCH
ST		equ	0
STE		equ	$00010000
STBOOK		equ	$00010008
MSTE		equ	$00010010
SPARROW		equ	$00030000
TT		equ	$00020000


;+
; Offsets to ...
;-
DOSPM		equ	$1be		; MSDOS boot sect's partition map
DOSSIG		equ	$1fe		; MSDOS boot sect's signature
HDSIZ		equ	$1c2		; offset to GEMDOS root sect's 


;+
; Constants and Variables
;-
SIG		equ	$55aa		; signature for valid MSDOS boot sects
NRETRIES	equ	3		; #retries-1
MAXNPART	equ	3		; #partition entries in root sect - 1
BPBLEN		equ	18		; length of bpb entry in bytes
FATLEN		equ	6		; max fat size = 2**6 = 64 sectors
SERLEN		equ	3		; length of a serial # in bytes
CHKDATE		equ	$19870422	; ROM date for bootstop checking


;+
; Number of bytes per Buffer Control Block (excluding the data block itself)
;
; struct_bcb {
; 	struct_bcb	*b_link;	/* 4 bytes */
;	int		b_neg1;		/* 2 bytes */
;	int		b_private[5];	/* 10 bytes */
;	char		*b_bufr;	/* 4 bytes */
; };
;
; For GEMDOS buffer lists.
;-
BCBLEN		equ	20


;+
; Number of bytes per IDE drive parameters structure
;
; struct_idedp {
;	int	nhead;		/* # of data heads */
;	int	nspt;		/* # of physical sectors per track */
; };
;-
IDEDPLEN	equ	4


;+
; for extension of OS pool
;-
chunksiz	equ	 66		; #bytes/chunk
chunkno		equ	 4		; chunk# (4 16-byte chunks)


;+
; for checking existence of fast RAM
;	If long word at _ramvalid == RAMMAGIC
; then  _ramtop is valid.  If _ramtop contains 0, no fast RAM is available,
; else _ramtop contains the address of top (end) of memory
;
; Fast RAM always starts at $01000000.
; _ramtop may hold $01000000 meaning there is no fast RAM!
;
; RAMRSV must be smaller than MAXACSECTS
;-
RAMMAGIC	equ	$1357bd13	; magic cookie for fast RAM
RAMBOT		equ	$01000000	; where fast RAM starts
RAMRSV		equ	$80		; # sectors of reserved RAM (64k)


;+
; Vector address
;-
BERR		equ	$8		; Bus ERRor vector
IINS		equ	$10		; Illegal INStruction vector


