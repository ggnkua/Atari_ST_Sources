        extrn   STEshift,TimerA,F030shift

;* F030 hardware adress emulation
;*
;**************************
        align 4

ReadHW_B:
        test  b [R_SR_H],20h      ; Super?
        jz    short RHW_BusError
        ret
ReadHW_W:
ReadHW_L:
	test  b [R_SR_H],20h      ; Super?
        jz    short RHW_BusError

        jmp   ebx

RHW_BusError:
	pop   ebx ; correct stack
	sub   esi,2
	mov   al,2
        call  Exception
        jmp   DebugExit

	ALIGN 4



WriteHW_B:
WriteHW_W:
WriteHW_L:
	test  b [R_SR_H],20h      ; Super?
        jz    RHW_BusError

	cmp   edi,0ff8260h	;STE shift
	jz    @@STEshift
	cmp   edi,0ff8266h	;Falcon shift
	jz    @@F030shift
	cmp   edi,0fffa19h	;Timer A
	jz    @@TimerA
 
        jmp     ebx
 
@@TimerA:
	mov   d [TimerA],-1
        jmp     ebx
@@STEshift:
	mov   d [STEshift],-1
        jmp     ebx
@@F030shift:
	mov   d [F030shift],-1
        jmp     ebx


HW_BusError:
	pop   ebx ; correct stack
	sub   esi,2
	mov   al,2
	call  Exception
        jmp   DebugExit

Write:
        cmp  edi,0ff8000h
        jge  short @@write

        ; ROM
        mov  edi,0fffff0h       ; avoid writing to wright place
        jmp  ebx

@@write:
        jmp   ebx
