;***************************************************************
;* MC68030 Exception Processing
;* 02-07-2000 FvN  Added 68030 StackFrame, VBR register

        public DebugExitW,DebugExit,Exception

M68030_Reset:
	pushad

; Build Jump Table (not optimised!)

	lea   edi,[OPCODETABLE]		; Jump Table
	lea   esi,[COMPTABLE]		; RLE Compressed Table
RESET0:
	mov   eax,d [esi]
	add   esi,4
	xor   ecx,ecx
	mov   cx,[esi]		; Repeats
	add   esi,2
	test  ecx,ecx
	jz    short RESET2		; Finished!
RESET1:
	mov   d [edi],eax
	add   edi,4
	dec   ecx
	jnz   short RESET1
	jmp   short RESET0
RESET2:
	mov   eax,d [ebp]         ; Reset ISP
	rol   eax,16
	mov   d [R_ISP],eax
	mov   eax,d [ebp+4]       ; Reset PC
	rol   eax,16
	mov   d [R_PC],eax
        mov   eax,23h             ; Reset SuperMode, T0&T1=0, S=1
	mov   d [R_SR_H],eax
        xor     eax,eax
        mov     d [R_VBR],eax           ; reset VBR
        mov     d [R_CACR],eax          ; reset CACR
	popad
	ret

	ALIGN 4
DebugExitW:
        pop     ebx                     ; correct stack for adress/bus error
DebugExit:
	mov   d [R_PC],esi		; Save PC
	mov   d [R_CCR],edx
	test  b [R_SR_H],20H
	mov   eax,d [R_A7]		; Get A7
	jne   short @@ME1		; Mode ?
	mov   d [R_USP],eax		;Save in USP
	jmp   short @@MC68Kexit
	ALIGN 4
@@ME1:
	mov   d [R_ISP],eax

@@MC68Kexit:
	popad
	add   esp,4
	ret
	ALIGN 4
M68030_Run:
	pushad
	mov   esi,d [R_PC]
	and   esi,0ffffffh
	mov   edx,d [R_CCR]

; Check for Interrupt waiting

	test  b [R_IRQ],07fH
	jne   short interrupt

IntCont:
	cmp   esi,d BRK
	je    DebugExit

	xor   ecx,ecx		; Avoid Stall (P2)
	mov   cx,[esi+ebp]

	add   esi,2
	jmp   [OPCODETABLE+ecx*4]
	ALIGN 4

MainExit:
	mov   d [R_PC],esi		; Save PC
	mov   d [R_CCR],edx
	test  b [R_SR_H],20H
	mov   eax,d [R_A7]		; Get A7
	jne   short ME1		; Mode ?
	mov   d [R_USP],eax		;Save in USP
	jmp   short MC68Kexit
	ALIGN 4
ME1:
	mov   d [R_ISP],eax

MC68Kexit:
	popad
	ret
	ALIGN 4



interrupt:
	mov   al,b [R_IRQ]
	mov   ebx,d [R_SR_H]		; int mask
	and   ebx,07H
	test  b [IRQmask+ebx],al		; MASK IRQ?
	jz    short IntCont		; Quick Leave


procint:
	and   al,b [IRQmask+ebx]		; MASK IRQ?
	test  al,1		; MFP?
	jnz   short @@MFP
	test  al,2		; VBL?
	jnz   short @@VBL
	test  al,4		; HBL?
	jz    short IntCont		; Geen IRQ
	mov   eax,26		; HBL vector
	call  Exception
	and   b [R_IRQ],3		; remove HBL
        jmp   IntCont
@@VBL:
	mov   eax,28		; VBL vector
	call  Exception
	and   b [R_IRQ],5		; remove VBL
	jmp   IntCont
@@MFP:
        mov   al,[ebp+0fffa16h]         ; Vector Register
        and   eax,255           ; ZeroExtend
        test  b [IRQpending+eax],-1
        jnz   @@noKeys
        mov   b [IRQpending+eax],-1
        jmp   @@MFP1
@@noKeys:
        and   b [R_IRQ],6               ; remove MFP
        jmp     IntCont

@@MFP1: call  Exception
        and   b [R_IRQ],6               ; remove MFP
        jmp   IntCont
	ALIGN 4


Exception:
	push  edx		; Save flags
	and   eax,0FFH		; Zero Extend IRQ Vector
	push  eax		; Save for Later
        dec   d [M68030_ICount]                         ; Decrement ICount

        mov   eax,edx                   ; make Flags
	mov   ah,b [R_XC]
	mov   ECX,edx
	and   ECX,1
	shr   eax,4
	and   eax,01Ch 		; X, N & Z
        or    eax,ECX           ; C
	mov   ECX,edx
	shr   ECX,10
	and   ECX,2
        or    eax,ECX           ; O
	mov   ah,b [R_SR_H] 	; T, S & I

	mov   edi,d [R_A7]		; Get A7
        test  ah,20H                    ; Which Mode ?
	jne   short ExSuperMode		; Supervisor
        or    b [R_SR_H],20H            ; Set Supervisor Mode
	mov   d [R_USP],edi		; Save in USP
	mov   edi,d [R_ISP]		; Get ISP

ExSuperMode:
        sub   edi,8             ; Create StackFrame on a 68030 (8 bytes min.)
        and   edi,0ffffffh
	mov   d [R_A7],edi		; Put in A7
        mov   w [ebp+EDI],ax    ; store SR
	add   edi,2
        mov   eax,esi           ; get PC
	rol   eax,16
        mov   d [ebp+EDI],eax   ; store PC
	pop   ecx		;Level
	add   edi,4
        mov   w [ebp+EDI],cx    ; store vector and FrameType
@@noLong1:
	shl   ecx,2
        add   ecx,d [R_VBR]     ; add Vector Base Register
        mov   esi,d [ebp+ECX]
        rol   esi,16
        and   esi,0ffffffh      ;MAX 16Mb
	pop   edx		; Restore flags
	ret
