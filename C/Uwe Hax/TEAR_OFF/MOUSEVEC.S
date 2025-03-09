;(c)1995 by MAXON-Computer

EXPORT _m_newvec

IMPORT _m_oldvec
IMPORT mouse_in_menu
IMPORT tear_menu
IMPORT aes_version

_m_newvec:      cmp     #2,d0           ;rechte Maustaste?
                beq     _m_next         ;ja
                move.l  _m_oldvec,a1    ;nein
                jsr     (a1)
                rts
                
_m_next:
                movem.l d0-a6,-(sp)     
                jsr     mouse_in_menu   ;Maus in einem MenÅ?
                movem.l (sp)+,d0-a6

                move.l  _m_oldvec,a1    ;Original-Routine noch aufrufen

                tst     tear_menu       ;Ein MenÅ an Mausposition?
                bmi     _m_end          ;nein, fertig

                move    #1,d0
                jsr     (a1)            ;ja, Button Down senden
                move    #0,d0
                jsr     (a1)            ;Button Up
                move    #2,d0           ;Right Button Down
                
_m_end:         jsr     (a1)            ;das MenÅ schliessen
                rts

