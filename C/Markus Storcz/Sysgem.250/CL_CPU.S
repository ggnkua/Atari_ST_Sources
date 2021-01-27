
import	get_cpu

export	ClearCache

;------------------------------------------------------------------
;		ClearCache ( void )
;			
; 	L”scht ggf. vorhandene CPU-Cashes. Dies ist immer dann
;		n”tig, wenn 'selbsmodifizierender Code' benutzt wird.
;		Also z.B. beim setzen/l”schen von Breakpoints, schreiben
;		in XBRA-Strukturen,... 
;		Hier wird zwar 68040-Code verwendet, da aber der _CPU-Cookie
;		ausgewertet wird sollte er nur auf 68040-Cpu's ausgefhrt werden
;		Das macht also keine Probleme.
;
;		Parameter: 		keine
;		Rckgabe : 		keine
;
;
;------------------------------------------------------------------

MC68040


.MODULE  ClearCache
        jsr			get_cpu
        SUB.L   #20,d0             ; at least 68020?
        bcs.s    .exit             ; no ->

        move.l   a2,-(sp)          ; keep register for Pure C
        lea      .clr20(pc),a0     ; ^default function
        sub.l    #20,d0            ; 68040 or higher?
        bcs.s    .super            ; no ->

        lea      .clr40(pc),a0     ; yes: use alternative function

.super: PEA     (A0)               ; ^function to execute
        MOVE.W  #38,-(sp)          ; opcode of Supexec
        TRAP    #14                ; XBIOS: execute in Supervisor mode
        addq.l   #6,sp             ; clean stack
        move.l   (sp)+,a2          ; restore

.exit:   rts                        ; bye


                                    ; 68020 or 68030:
.clr20: MOVE.W  SR,D0               ; keep sr
        OR.W    #$700,SR            ; lock all interrupts
        MOVEC   CACR,D1             ; get cache control register
        ORI.W   #$0808,D1           ; clear all cache
        MOVEC   D1,CACR             ; set ccr
        MOVE.W  D0,SR               ; restore sr
        RTS

        mc68040
                                    ; 68040 or higher:
.clr40: NOP                         ; invalidate something?
    ;   cpusha   dc/ic              ; clear instruction cache
        DC.W    $4E71,$F4F8
        RTS                         ; bye

MC68000
