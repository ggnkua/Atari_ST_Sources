
tasks         equ 10     ; maximale Anzahl
taskstacksize equ 1024   ; Stapelgr”e fr jeden Task in Bytes

; Verwendung:

; taskinit();
; ...
; if (!do_task(tasksub,n,arg1,arg2,...,argn)) /* Task starten */
;     { /* liefert do_task() ein "false", so ist kein Task mehr frei */
;     puts("kein Task mehr frei!");
;     }
; ...
; /*evtl.*/ stoptask(); /* stoppt alle Tasks */
; ...
; taskexit();

; tasksub()
; {
;       ...
;       waittask();
;       ...
;       /* Taskroutine wird normal beendet */
; }


; Struktur eines Task-Datenblocks:

task_pc    equ 0              ; Speicher fr PC des Tasks
task_sp    equ task_pc+4      ; Speicher fr SP des Tasks
task_aktiv equ task_sp+4      ; Kennung, ob Task aktiv
task_regs  equ task_aktiv+2   ; Speicher fr Taskregisterinhalte
task_stack equ task_regs+15*4 ; jeder Task hat seinen eigenen Stapel

tasklen    equ task_stack+taskstacksize ; L„nge eines Datenblocks

*----------------------------------------*

; Routinen, auf die das C-Programm zugreifen darf :
        xdef taskinit,taskexit,do_task,waittask,stoptask
        
*----------------------------------------*

; Installieren und L”schen des Taskmanagers:

taskinit                         ; taskinit()
        movem.l d0-d7/a0-a6,-(sp)
        move #-1,tasknummer
        lea task,a0
        moveq #tasks-1,d0
x1      move.l #waittask,task_pc(a0)
        clr task_aktiv(a0)
        lea tasklen(a0),a0
        dbf d0,x1
        pea init_slot
        move #$26,-(sp)
        trap #14
        addq.l #6,sp
        movem.l (sp)+,d0-d7/a0-a6
        rts

init_slot
        move.l $456,a0
x2      tst.l (a0)+
        bne.s x2
        move.l #task_manager,-(a0)
        rts

taskexit                        ; taskexit()
        movem.l d0-d7/a0-a6,-(sp)
        pea restore_slot
        move #$26,-(sp)
        trap #14
        addq.l #6,sp
        movem.l (sp)+,d0-d7/a0-a6
        rts

restore_slot        ; Sloteintrag wieder l”schen
        move.l $456,a0
x3      cmp.l #task_manager,(a0)+
        bne.s x3
        clr.l -(a0)
        rts

*----------------------------------------*

stoptask                      ; stoptask()
        movem.l d0-d7/a0-a6,-(sp)
        clr tasknummer
        lea task,a0
        moveq #tasks-1,d0
x4      move.l #waittask,task_pc(a0)
        clr task_aktiv(a0)
        lea tasklen(a0),a0
        dbf d0,x4
        movem.l (sp)+,d0-d7/a0-a6
        rts

*----------------------------------------*

; word do_task(subroutine,n,arg1,arg2,...,argn);

do_task

subroutine equ 8
n          equ 12
arg1       equ 16

        link a6,#0
        movem.l d1-d7/a0-a6,-(sp)
        lea task,a0
        moveq #tasks-1,d0
x5      tst task_aktiv(a0)
        beq.s x6
        lea tasklen(a0),a0
        dbf d0,x5
        moveq #0,d0             ; kein Task mehr frei !
        movem.l (sp)+,d1-d7/a0-a6
        unlk a6
        rts
x6
        lea task_stack+taskstacksize(a0),a2
        move.l n(a6),d0
        move.l d0,d1
        addq #1,d1
        lsl.l #2,d1
        sub.l d1,a2
        move.l a2,task_sp(a0)
        move.l #exittask,(a2)+ ; Returnadresse auf Taskstapel
        lea arg1(a6),a1
        bra.s x7
x8      move.l (a1)+,(a2)+     ; arg1-argn auf Taskstapel
x7      dbf d0,x8
        move.l subroutine(a6),task_pc(a0)
        move #1,task_aktiv(a0)
        movem.l (sp)+,d1-d7/a0-a6
        moveq #1,d0
        unlk a6
        rts

*----------------------------------------*

task_manager            ; wird jede 1/60 Sekunde aufgerufen.
        clr tasknummer
x9      moveq #0,d0
        move tasknummer,d0
        cmp #tasks,d0
        beq.s x10
        lea task,a0
        mulu #tasklen,d0
        add.l d0,a0
        tst task_aktiv(a0)
        beq.s x11
        bsr do_one_task
x11     addq #1,tasknummer
        bra.s x9
x10     move #-1,tasknummer
        rts

do_one_task
        pea (a0)
        move.l sp,t_m_sp
        move.l task_sp(a0),sp
        movem.l task_regs(a0),d1-d7/a1-a6
        move.l task_pc(a0),a0
        jmp (a0)

*----------------------------------------*

; waittask();
waittask
        tst tasknummer    ; nur beachten, wenn aus Taskroutine 
        bpl.s x12         ; aufgerufen.
        rts
x12     moveq #0,d0
        move tasknummer,d0
        mulu #tasklen,d0
        lea task,a0
        add.l d0,a0
        movem.l d1-d7/a1-a6,task_regs(a0)
        move.l (sp)+,task_pc(a0)
        move.l sp,task_sp(a0)
        move.l t_m_sp,sp
        addq.l #4,sp
        rts

*----------------------------------------*

exittask                 
        moveq #0,d0     
        move tasknummer,d0
        mulu #tasklen,d0
        lea task,a0
        add.l d0,a0
        clr task_aktiv(a0)
        move.l t_m_sp,sp
        addq.l #4,sp
        rts

*----------------------------------------*

        bss

tasknummer ds 1               ; enth„lt Tasknummer des aktiven Tasks
                              ; oder -1, wenn kein Task l„uft.
t_m_sp     ds.l 1             ; Zwichenspeicher fr Stapelz„hler.
task       ds.b tasklen*tasks ; Speicherplatz fr Tasks.

        end
        
