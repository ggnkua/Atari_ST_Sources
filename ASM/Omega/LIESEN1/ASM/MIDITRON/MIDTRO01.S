; MIDI-Tron           / Martin Liesen
                PART 'Introduction Text'
; Started 22/07 92   at Electra,Armada & Omega meeting at my place
; Totaly PC-realtive code.
;
; There is two Send bufferts. One is for None-interrupt data-filling and
; one is for interrupt data-filling. This way a interrupt can directly pass
; on the bytes it recives, and the none-interrupt don't need worry about
; getting theier tables trashed.  The sender routine will take the interrupt
; buffert before the non-irq when he's about to start sending a new command.
;
; The endmark in a send buffert is "KARIN<", hopfully this will never occure
; within the command.
;
; To reduce the time to make a command pass through the link I have limited
; the number of linked computers to 8.  This way the commands reaches
; all the computers quicker... and I can send both dest. ID/group
; and source ID (for stoping the link) in the same header-command.
;
;       yyyyxxxx
;
;       xxxx = 0-7   dest ID
;              8     To everyone
;              9     To Master
;              A-F   Reserved (group messages)
;
;       yyyy = 0-7   source ID
;              8     from Master
;              A-F   Reserved (could be used for special commands)
;
; Then follows the command byte
;
; >>>>>>>>> H a n d s h a k e
;
;               * RQ - to Everyone
;               * Id you should take (add this with one when passing on)
;

; >>>>>>>>> S e t u p

; Set new color
;               * CL - to Everyone
;               * hi-byte   color
;               * lo-byte
; Set username
;               * NM - to Everyone
;               ** 15 bytes name (null ending if less)
; Set crashmessage
;               * CR - to Everyone
;               ** 39 bytes (null ending if less)
; Set killed ya message
;               * KL - to Everyone
;               ** 39 bytes (null ending if less)
;
;
;
;
; An error detector mechanism is the circle buffert with all commands
; which has been send. Checking the tail and the time passed since it was
; send you can see if something has been send wrong somewhere.
;
;
                ENDPART


                OPT P+

                PART 'MIDI recive'
M_Recive:       movem.l D0-A6,-(A7)
                lea     s(PC),A6

                movea.l _M_Rc_head(PC),A0   ; Put in buf
                move.b  D0,(A0)+
                lea     _M_Rc_buf_end(PC),A1
                cmpa.l  A0,A1
                bne.s   .NoWrap
                lea     _M_Rc_buf_start(PC),A0
                move.l  A0,_M_Rc_head-s(A6)

                subi.w  #1,_M_CharCount-s(A6) ; Reduce char counter
                bpl.s   .TakeCare

                cmp.w   #-1,D0              ; A entire new command?
                beq.s   .GetBelonger

; Here is new command identifier

.GetBelonger:
                move.w  D0,D1
                and.w   #$0F,D0
                andi.w  #$F0,D1





.TakeCare:
                tst.b   _M_JumpEveryF-s(A6) ; Every time jump?
                bne.s   .NotJumpNow
                movea.l _M_JumpAddr(PC),A0
                jsr     (A0)
                bra.s   .QuitMR

.NotJumpNow:    tst.w   _M_CharCount-s(A6)  ; Last byte?
                bne.s   .NotFinito
                movea.l _M_JumpAddr(PC),A0
                jsr     (A0)

.QuitMR:        movem.l (A7)+,D0-A6
                rts


MidiOut:        PART 'Send to MIDI'
                movem.l D0-A6,-(A7)
                movea.l Hoppa(PC),A0
                jmp     (A0)

Hoppa:          DS.L 1




                movem.l (A7)+,D0-A6
                rts
                ENDPART




_M_JumpEveryF:  DS.B 1                      ; 0<>Jump for every recived byte
                EVEN

_M_JumpAddr:    DS.L 1

_M_CharCount:   DS.W 1
_M_Rc_head:     DS.L 1
_M_Rc_tail:     DS.L 1


_M_Rc_buf_start:DS.B 256
_M_Rc_buf_end:
                ENDPART

                >PART 'Player Data'

_Players:
                REPT 8
                DC.W 0                      ; color
                DS.B 16                     ; name
                DS.B 40                     ; crash mssg
                DS.B 40                     ; killed him mssg
                DC.W 0                      ; pos X
                DC.W 0                      ; pos Y
                DC.W 0                      ; Status bits
                ENDR
; Status bits;
;               0=   (1=Dead)
;               1=
;               2=
                ENDPART

_M_Que_Busy:    DS.B 1                      ; 0<>Busy sending data to QUE
                EVEN
_M_Sd_head:     DS.L 1
_M_Sd_tail:     DS.L 1



_ID:            DS.W 1                      ; This computers Id
                EVEN
                END
