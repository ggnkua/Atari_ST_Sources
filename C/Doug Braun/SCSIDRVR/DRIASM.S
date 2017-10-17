name driasm


STACKSIZ equ 512

_TEXT	segment	public 'CODE'

;This forces everything into the same segment
DGROUP	GROUP	_TEXT, _DATA, _EMUSEG, _CVTSEG, _SCNSEG, _BSS, _BSSEND

ASSUME	CS:_TEXT, DS:DGROUP, SS:DGROUP

;This must be first
include dheader.s

; This is the pointer to the request header
; Together they are a far pointer
public _request_off
_request_off 	dw ?		;must be in code segment
_request_seg	dw ?

;This is to keep turbo C happy
public DGROUP@
DGROUP@ dd ?		;must be in code segment

;These are local storage for the callers sp and ss
oldss	dw	?
oldsp	dw ?

; This is the local stack
db STACKSIZ dup (?)
localstk_top label word


; This is the "strategy" entry point
_strat	proc	far
	mov	word ptr cs:_request_off,bx
	mov	word ptr cs:_request_seg,es
	mov cs:DGROUP@, cs		;Turbo C uses this for interrupt functions
	ret	
_strat	endp


; This is the "interrupt" entry point
_intr	proc	far
    cli
	push ds
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push bp
	pushf

	mov cs:oldss, ss
	mov cs:oldsp, sp

	mov ax, cs ;make local data addressable
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov ax, offset localstk_top
	mov sp, ax
	mov bp, ax
	sti

	mov	ax, cs:_request_seg
	push ax
	mov	ax, cs:_request_off
	push ax
	call _dointr	;call dointr() with far pointer to header
	pop ax
	pop ax

	cli
	mov ax, cs:oldss
	mov ss, ax
	mov ax, cs:oldsp
	mov sp, ax
	popf
	pop bp
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	pop ds
	sti
	ret
_intr	endp


	public	_intr
	public	_strat



    extrn _dointr:near

_TEXT	ends

_BSSEND segment byte public 'BSSEND'
public _edata
_edata label byte
_BSSEND ends

	end
