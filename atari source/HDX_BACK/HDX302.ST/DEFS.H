;+
; Conditional assembly
;-
SCDMA	equ	1			; 0: not doing SCSI DMA
SCFRDMA	equ	0			; 0: don't allow SCSI DMA to fast RAM
DRIVER	equ	0			; 0: not to be included in driver

;+
; Restraints 
;-
MAXUNITS	equ	14		; max # of log units w/o drv A & B
MAXACSI		equ	8		; maximum number of ACSI devices
MAXSCSI		equ	8		; maximum number of SCSI devices
ACSIUNT		equ	7		; highest ACSI unit number
SCSIUNT		equ	15		; highest SCSI unit number
MAXACSECTS	equ	254		; max # of sectors at one ACSI gulp
MAXSCSECTS	equ	65534		; max # of sectors at one SCSI gulp


;+
; Offsets to ...
;-
DOSPM		equ	$1be		; MSDOS boot sect's partition map
DOSSIG		equ	$1fe		; MSDOS boot sect's signature
HDSIZ		equ	$1c2		; offset to GEMDOS root sect's 
							; hard disk size

;+
; Constants and Variables
;-
SIG		equ	$55aa		; signature for valid MSDOS boot sects
NRETRIES	equ	3		; #retries-1
MAXNPART	equ	3		; #partition entries in root sect - 1
BPBLEN		equ	18		; length of bpb entry in bytes
FATLEN		equ	64		; max fat size = 64 sectors
SERLEN		equ	3		; length of a serial # in bytes
CHKDATE		equ	$19870422	; ROM date for bootstop checking


;+
; Number of bytes per Buffer Control Block (excluding the data block itself)
;
; struct_bcb {
; 	struct_bcb	*b_link;	 /*4 bytes */
;	int		b_neg1;		 	 /*2 bytes */
;	int		b_private[5];	 /*10 bytes*/ 
;	char		*b_bufr;	 /*4 bytes*/
; };
;
; For GEMDOS buffer lists.
;-
BCBLEN		equ	20


;+
; for extension of os pool
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


