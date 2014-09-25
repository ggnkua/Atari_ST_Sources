;************************************************************************
;* De decrunch routine heeft als functie het decompressen van een met   *
;* Crunch gepackte file. De aanroep van decrunch is als volgt:          *
;*                                                                      *
;*           int Decrunch(char *InputFname, char *OutputFname)          *
;*                                                                      *
;* De returnvalue is ongelijk aan nul op het moment dat er een fout is  *
;* opgetreden. Nul betekent dus dat compressie goed is verlopen         *
;************************************************************************

                GLOBAL decrntab


Decrunch::      movem.l d1-d7/a2-a6,-(sp)
                move.l  a1,-(sp)        ;Target Filename
                move.l  a0,-(sp)        ;Source filename

                move.l  #-1,-(sp)       ;Free memory ?
                move.w  #$48,-(sp)
                trap    #1              ;Malloc
                addq.l  #6,sp
                move.l  d0,-(sp)
                lsr.l   #1,d0           ;Split in 2 2 parts
                move.l  d0,buflen

                move.w  #$48,-(sp)
                trap    #1              ;Malloc
                addq.l  #6,sp
                move.l  d0,memstrt

                movea.l (sp)+,a0        ;Inputfilename
                move.w  #0,-(sp)        ;Readonly
                move.l  a0,-(sp)
                move.w  #$3d,-(sp)
                trap    #1              ;Fopen
                addq.l  #8,sp
                move.w  d0,handlei
                bmi     error           ;error

                movea.l (sp)+,a0        ;Target filename
                clr.w   -(sp)
                move.l  a0,-(sp)
                move.w  #$3c,-(sp)
                trap    #1              ;Fcreate
                addq.l  #8,sp
                move.w  d0,handleo
                bmi     error           ;error


loop:           move.l  buflen,d0
                movea.l memstrt,a0
                adda.l  d0,a0           ;Use Upper half of the buffer
                move.l  a0,-(sp)        ;Buffer
                move.l  d0,-(sp)        ;Count
                move.w  handlei,-(sp)
                move.w  #$3f,-(sp)
                trap    #1              ;Fread
                addq.l  #8,sp
                movea.l (sp)+,a0        ;Buffer pointer
                move.l  d0,buflen
                bmi     error           ;error
                beq     endoffile

                >PART
                movea.l memstrt,a1      ;Outputpointer
                lea     decrntab,a2     ;Table with decrunched offsets
                move.l  buflen,d0
                clr.l   d1
                clr.b   byte1           ;Last byte start with 0
crnloop:        move.b  (a0)+,d1
                ror.l   #4,d1
                bclr    #3,d1
                beq.s   crn_1           ;Was not Negative
                move.b  0(a2,d1.w),d1
                sub.b   d1,byte1
                bra.s   crn_2
crn_1:          move.b  0(a2,d1.w),d1
                add.b   d1,byte1
crn_2:          move.b  byte1,(a1)+
                clr.b   d1

                rol.l   #4,d1
                bclr    #3,d1
                beq.s   crn_3           ;Was not Negative
                move.b  0(a2,d1.w),d1
                sub.b   d1,byte1
                bra.s   crn_4
crn_3:          move.b  0(a2,d1.w),d1
                add.b   d1,byte1
crn_4:          move.b  byte1,(a1)+

                subq.l  #1,d0
                bne     crnloop
                ENDPART

                move.l  memstrt,-(sp)
                move.l  buflen,d0
                lsl.l   #1,d0           ;*2
                move.l  d0,-(sp)
                move.w  handleo,-(sp)
                move.w  #$40,-(sp)
                trap    #1
                adda.l  #$0c,sp
                tst.l   d0
                bmi     error
                bra     loop




closeall:       >PART
                move.l  memstrt,-(sp)
                move.w  #$49,-(sp)
                trap    #1              ;Mfree
                addq.l  #6,sp

                move.w  handlei,-(sp)   ;Sluit Invoerbestand
                move.w  #$3e,-(sp)
                trap    #1              ;Fclose
                addq.l  #4,sp

                move.w  handleo,-(sp)   ;Sluit Uitvoerbestand
                move.w  #$3e,-(sp)
                trap    #1              ;Fclose
                addq.l  #4,sp
                rts
                ENDPART

endoffile:      >PART
                bsr     closeall
                clr.w   d0              ;Geen fouten
                bra.s   return
                ENDPART

error:          >PART
                bsr     closeall
                move.w  #-1,d0          ;Error
                ENDPART

return:         movem.l (sp)+,d1-d7/a2-a6
                rts

                DATA
decrntab::      IBYTES 'DECRNTAB.BIN'


                BSS
buflen:         DS.L 1          ;Lengte van de buffer
memstrt:        DS.L 1          ;Start van de buffer
handlei:        DS.W 1          ;handle nr inputfile
handleo:        DS.W 1          ;handle nr outputfile
byte1:          DS.W 1
                END
