;+
; Equates for systems variables
;-
etv_critic	equ	$404		; critical error handoff vector
phystop		equ	$42e		; physical top of memory
flock		equ	$43e		; FIFO lock variable
_bootdev	equ	$446		; default boot device
hdv_init	equ	$46a		; hdv_init()	** UNUSED **
hdv_bpb		equ	$472		; hdv_bpb(dev)
hdv_rw		equ	$476		; hdv_rw(rw, buf, count, recno, dev)
hdv_boot	equ	$47a		; hdv_boot()	** UNUSED **
hdv_mediach	equ	$47e		; hdv_mediach(dev)
_bufl		equ	$4b2		; 2 buffer-list headers
_hz_200		equ	$4ba		; system 200hz timer
_drvbits	equ	$4c2		; block device bitVector
_dskbufp	equ	$4c6		; pointer to common disk buffer
_sysbase	equ	$4f2		; -> base of OS
pun_ptr		equ	$516		; number of physical units
_p_cookie	equ	$5a0		; pointer to cookie jar
