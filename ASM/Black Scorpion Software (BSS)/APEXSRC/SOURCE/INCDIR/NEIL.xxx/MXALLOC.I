*********************************************************************
* GEMDOS MXAlloc system call Macros
*********************************************************************

;--------------------------------------------------------------------
; Allocate GEMDOS RAM
; Push TYPE.w and AMOUNT.l on stack
; ADDRESS.l returned if OK, -1 otherwise
;--------------------------------------------------------------------

MXAlloc macro
	push.w	#68
	trap	#1
	addq	#8,sp
	endm

;--------------------------------------------------------------------
; Free GEMDOS RAM
; Push ADDRESS.l on stack
;--------------------------------------------------------------------

MXFree	macro
	push.w	#73
	trap	#1
	addq	#6,sp
	endm

;--------------------------------------------------------------------
; Get amount of free GEMDOS RAM
; Push TYPE.w on stack
; Amount returned in D0.l
;--------------------------------------------------------------------

MXGetFree 	macro
	pea	-1.w
	push.w	#68
	trap	#1
	addq	#8,sp
	endm
