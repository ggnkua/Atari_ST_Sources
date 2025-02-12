
;--------------------------------------------------------------------
;	Module:		COOKIE.S
;
;	Abstract:	Everything you need for accessing the 
;				cookie jar on Atari ST/TT computers.
;
;	Author:		Arnd Beissner, SciLab GmbH - Germany
;				Parts of the code are derived from Atari's 
;				TOS 1.06 Release Notes.
;
;	Compatibility:
;				Any ST/TT-compatible machine, any TOS version.
;
;	Language:	MAS68K by Borland
;
;	Version:	1.01
;
;	Date:		05.01.1991
;	
;	History:
;
;	05.01.1991	AB	- fixed a bug in CK_ReadJar
;
;--------------------------------------------------------------------
;	Comments:
;
;	Most functions in this module must be called in supervisor mode.
;	No registers except D0 (for the return value) are modified.
;--------------------------------------------------------------------

RESMAGIC        equ     $31415926

_p_cookies		equ		$5A0
_resvalid       equ     $426
_resvector      equ     $42a

;--------------------------------------------------------------------

		.globl	CK_JarInstalled
		.globl	CK_UsedEntries
		.globl	CK_JarSize
		.globl	CK_ResizeJar
		.globl	CK_ReadJar
		.globl	CK_WriteJar
		.globl	CK_SetOptions
		
		.text

;--------------------------------------------------------------------
; CK_JarInstalled
;
; See if the cookie jar is installed.
;
; Return value:
;		D0.L	= pointer to the cookie jar (0 = not installed)
;--------------------------------------------------------------------

CK_JarInstalled:
		move.l	_p_cookies,d0
		rts	


;--------------------------------------------------------------------
; CK_UsedEntries
;
; Inquire the number of used cookie jar entries. The number includes
; the null cookie, so a return value of 0 means that there is no
; cookie jar at all.
;
; Return value:
;		D0.W = number of used cookie jar entries
;--------------------------------------------------------------------

CK_UsedEntries:
		move.l	a0,-(sp)
		move.l	_p_cookies,d0
		beq		_ue_end
		
		move.l	d0,a0
		clr.w	d0
_ue_loop:
		addq.w	#1,d0
		tst.l	(a0)
		beq		_ue_end
		addq.l	#8,a0
		bra		_ue_loop
_ue_end:
		move.l	(sp)+,a0
		rts

		
;--------------------------------------------------------------------
; CK_JarSize
;
; Inquire the total number of cookie jar entries.
;
; Return value:
;		D0.W = total number of cookie jar entries
;--------------------------------------------------------------------

CK_JarSize:
		move.l	a0,-(sp)
		move.l	_p_cookies,d0
		beq		_js_end
		
		move.l	d0,a0
_js_loop:
		tst.l	(a0)
		beq		_js_found
		addq.l	#8,a0
		bra		_js_loop
		
_js_found:
		move.l	4(a0),d0
_js_end:
		move.l	(sp)+,a0
		rts
		

;--------------------------------------------------------------------
; CK_ResizeJar
;
; Resize the cookie jar to the desired size.
;
; Input arguments:
;		D0.W	= desired cookie jar size, number of entries
;
; Return value:
;		D0.W	= state (0=FALSE, 1=TRUE)
;--------------------------------------------------------------------

CK_ResizeJar:
		movem.l	d1-a6,-(sp)
		
		; allocate a buffer for the new cookie jar
		andi.l	#$FFFF,d0
		move.l	d0,d7
		lsl.w	#3,d0				; 8 bytes per entry
		move.l	d0,-(sp)
		move.w	#$48,-(sp)			; Malloc
		trap	#1
		addq.l	#6,sp
		tst.l	d0					; allocation successful?
		beq		_rj_end
		bpl		_rj_allocok
		clr.w	d0
		bra		_rj_end
		
_rj_allocok:
		; copy the contents of the old cookie jar to the new buffer
		move.l	d0,a2
		move.l	d0,a0
		move.l	_p_cookies,a1
		bsr		CK_UsedEntries
		subq.w	#1,d0
		bra		_rj_cpend
_rj_copy:
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
_rj_cpend:
		dbf		d0,_rj_copy				
		
		; insert the null cookie
		clr.l	(a0)+				; null cookie
		move.l	d7,(a0)				; cookie jar size
		
		; install the pointer to the new cookie jar
		move.l	a2,_p_cookies
		
		move.w	#1,d0				; success
		
_rj_end:
		movem.l	(sp)+,d1-a6
		rts


;--------------------------------------------------------------------
; _instReset			**** internal ****
;
; Install a reset handler which clears the cookie jar on reboot.
; This is necessary for TOS versions before 1.06
;--------------------------------------------------------------------

_instReset:
		move.l	cookieJarXBRA,xbraId
     	move.l	_resvalid,oldResValid
     	move.l	#RESMAGIC,_resvalid
    	move.l	_resvector,oldReset
     	move.l	#newReset,_resvector
     	rts

     	dc.b	"XBRA"
xbraId:	dc.b	"ck01"   			; XBRA-structure
oldReset:
     	dc.l    0
newReset:
     	clr.l	_p_cookies			; clear the cookie jar
     	move.l	oldReset,_resvector
     	move.l	oldResValid,_resvalid
     	jmp		(a6)


;--------------------------------------------------------------------
; _searchJar			**** internal ****
;
; search the position of the specified cookie
;
; Input arguments:
;		D0.L	= cookie name
;
; Return value:
;		D0.L	= pointer to cookie
;--------------------------------------------------------------------

_searchJar:
		movem.l	d2/a0,-(sp)
		move.l	d0,d2
		move.l	_p_cookies,d0
		beq		_search_end
		
		move.l	d0,a0
		clr.l	d0
_search_next:
		tst.l	(a0)			; null cookie?
		beq		_search_end
		cmp.l	(a0),d2			; cookie found?
		beq		_search_found
		addq.l	#8,a0
		bra		_search_next
		
_search_found:
		move.l	a0,d0		

_search_end:
		movem.l	(sp)+,d2/a0
		rts


;--------------------------------------------------------------------
; CK_ReadJar
;
; Read the value of the specified cookie.
;
; Input arguments:
;		D0.L	= cookie name
;		A0		= pointer to cookie value
;
; Return value:
;		D0.W	= state (0=FALSE, 1=TRUE)
;--------------------------------------------------------------------

CK_ReadJar:
		move.l	a1,-(sp)
		bsr		_searchJar			; get a pointer to the jar entry
		tst.l	d0
		beq		_ck_rdend			; entry not found
		move.l	d0,a1
		move.l	4(a1),(a0)			; read the cookie value
		move.w	#1,d0				; success!	

_ck_rdend:
		move.l	(sp)+,a1
		rts
		

;--------------------------------------------------------------------
; CK_WriteJar
;
; Insert a new entry into the cookie jar. If no cookie jar exists
; or the current cookie jar is full, a new, bigger cookie jar is
; installed. The increment in size can be set using CK_SetOptions.
;
; Input arguments:
;		D0.L	= cookie name
;		D1.L	= cookie value
;
; Return value:
;		D0.W	= state (0=FALSE, 1=TRUE)
;--------------------------------------------------------------------

CK_WriteJar:
		movem.l	d2-d3/a0,-(sp)
		move.l	d0,d2
		bsr		_searchJar
		tst.l	d0
		bne		_ck_we_found
		
		; cookie not found --> allocate one
		bsr		CK_JarSize
		move.w	d0,d3
		bsr		CK_UsedEntries
		sub.w	d0,d3
		bgt		_ck_we_write
		
		; no space for more cookies --> allocate a new cookie jar
		; before that, install a reset function which resets the
		; cookie jar on reboot. This is only necessary if no cookie
		; jar exists.
		tst.l	_p_cookies
		bne		_ck_we_inc
		bsr		_instReset
		
_ck_we_inc:		
		add.w	cookieJarIncrement,d0
		bsr		CK_ResizeJar
		tst.w	d0
		beq		_ck_we_end						; allocation failed
		bsr		CK_UsedEntries

		; write the cookie to location d0-1
_ck_we_write:
		subq.w	#1,d0
		lsl.w	#3,d0
		move.l	_p_cookies,a0
		add.w	d0,a0
		clr.l	8(a0)
		move.l	4(a0),12(a0)
		move.l	d2,(a0)
		move.l	d1,4(a0)
		bra		_ck_we_ok
		
_ck_we_found:
		; cookie found --> overwrite with new value
		move.l	d0,a0
		move.l	d1,4(a0)

_ck_we_ok:
		move.w	#1,d0		
	
_ck_we_end:
		movem.l	(sp)+,d2-d3/a0
		rts


;--------------------------------------------------------------------
; CK_SetOptions
;
; Set cookie jar options.
;
; Input arguments:
;		D0.W	= cookie jar increment when allocating a new buffer
;		D1.L	= xbra id for reset handler
;--------------------------------------------------------------------

CK_SetOptions:
		move.w	d0,cookieJarIncrement
		move.l	d1,cookieJarXBRA
		rts

;--------------------------------------------------------------------

		.data
		
cookieJarIncrement:
		dc.w	20

cookieJarXBRA:
		dc.b	'ck01'

;--------------------------------------------------------------------

		.bss

oldResValid:
		ds.l	1
				
		.end

