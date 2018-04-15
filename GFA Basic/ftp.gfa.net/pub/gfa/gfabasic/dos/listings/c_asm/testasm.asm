

_DATA	segment word public 'DATA'
	ends
DGROUP	GROUP	_DATA

	assume	ds:DGROUP
XX_TEXT segment word public 'CODE'
	assume cs:XX_TEXT

	public	TestAsm
TestAsm proc	far
	push	bp
	mov	bp,sp
	mov	ax,6[bp]    ;get last (only) parameter
	add	ax,ax
	add	ax,ax
	add	ax,ax
	add	ax,ax	    ;FUNCTIONs return DX:AX
	cwd
	pop	bp
	ret	2
	endp
;FUNCTION test(x&)
; is called with Parameters on stack in the left to right order,
; the is the first parameter is pushed first. The called routine
; is responsible for stack cleanup.
;The Routine is not allowed to destroy DS,SS,SI,DI,BP



XX_TEXT ends

END
