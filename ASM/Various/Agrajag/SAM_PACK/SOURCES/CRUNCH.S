;************************************************************************
;* De Crunch routine heeft als functie het packen van een samplebestand *
;* tot de helft van de oorspronkelijke lengte. De oorspronkelijke pack  *
;* routines waren in C geschreven. Maar aangezien de C code traag en    *
;* onnodig lang was heb ik hem herschreven in Assembler.                *
;*                                                                      *
;* Vanuit C wordt de routine als volgt aangeroepen:                     *
;*                                                                      *
;*           int Crunch(char *InputFname, char *OutputFname)            *
;*                                                                      *
;* De returnvalue is ongelijk aan nul op het moment dat er een fout is  *
;* opgetreden. Nul betekent dus dat compressie goed is verlopen         *
;************************************************************************

Crunch::        movem.l d1-d7/a2-a6,-(sp)
                move.l  a1,-(sp)        ;Target Filename
                move.l  a0,-(sp)        ;Source filename

                move.l  #-1,-(sp)
                move.w  #$48,-(sp)      ;Free memory
                trap    #1              ;Malloc
                addq.l  #6,sp
                move.l  d0,buflen

                move.l  d0,-(sp)
                move.w  #$48,-(sp)      ;Allocate all free memory
                trap    #1              ;Malloc
                addq.l  #6,sp
                bclr    #0,d0           ;2 bytes -> 1 byte compression
                move.l  d0,memstrt

                movea.l (sp)+,a0        ;Inputfilename
                move.w  #0,-(sp)        ;Readonly
                move.l  a0,-(sp)
                move.w  #$3d,-(sp)
                trap    #1              ;Fopen
                addq.l  #8,sp
                move.w  d0,handlei
                bmi     error           ;Error

                movea.l (sp)+,a0        ;Target filename
                clr.w   -(sp)
                move.l  a0,-(sp)
                move.w  #$3c,-(sp)
                trap    #1              ;Fcreate
                addq.l  #8,sp
                move.w  d0,handleo
                bmi     error           ;Error


loop:           move.l  memstrt,-(sp)   ;Buffer
                move.l  buflen,-(sp)    ;Count
                move.w  handlei,-(sp)
                move.w  #$3f,-(sp)
                trap    #1              ;Fread
                adda.l  #$0c,sp
                bclr    #0,d0
                move.l  d0,buflen
                bmi     error           ;Error
                beq     endoffile

                >PART
                movea.l memstrt,a0      ;Bufferpointer
                movea.l a0,a1           ;Outputpointer
                lea     crntab,a2       ;Crunched offsets
                lea     decrntab,a3     ;Decrunched offsets
                clr.w   d1
                clr.w   d2
                clr.w   byte1           ;Last byte start with 0
                move.l  buflen,d0
crnloop:        move.b  (a0)+,d1
                bsr     crnoffset       ;Crunch sample
                lsl.b   #4,d1           ;Into upper nibble
                move.b  d1,d3           ;Store
                move.b  (a0)+,d1
                bsr     crnoffset
                eor.b   d3,d1           ;D3 1st byte, D1 last byte
                move.b  d1,(a1)+
                subq.l  #2,d0
                bne     crnloop
                ENDPART

                move.l  memstrt,-(sp)
                move.l  buflen,d0
                lsr.l   #1,d0           ;/2
                move.l  d0,-(sp)
                move.w  handleo,-(sp)
                move.w  #$40,-(sp)
                trap    #1
                adda.l  #$0c,sp
                tst.l   d0
                bmi     error
                bra     loop

crnoffset:      >PART
                sub.w   byte1,d1        ;Offset
                bpl     crnoffset_3
                neg.w   d1              ;Make negative offset positive
                move.b  0(a2,d1.w),d1   ;Crunch the offset
crnoffset_1:    move.b  0(a3,d1.w),d2   ;And decrunch it again
                sub.w   d2,byte1        ;New sample
                bpl.s   crnoffset_2     ;No $00-$ff border cross
                add.w   d2,byte1        ;take previous sample
                subq.w  #1,d1           ;Decrease crunched offset by 1
                bra     crnoffset_1     ;And try again
crnoffset_2:    bset    #3,d1           ;Make it a negative Nibble
                bra.s   crnoffset_5
crnoffset_3:    move.b  0(a2,d1.w),d1   ;Crunch the offset
crnoffset_4:    move.b  0(a3,d1.w),d2   ;Decrunch it
                add.w   d2,byte1        ;New sample
                cmpi.w  #$ff,byte1
                bls.s   crnoffset_5     ;No $ff-$00 border cross
                sub.w   d2,byte1        ;Take previous sample
                subq.w  #1,d1           ;Decrease crunched offset by 1
                bra     crnoffset_4     ;And try again
crnoffset_5:    rts
                ENDPART

closeall:       >PART
                move.l  memstrt,-(sp)
                move.w  #$49,-(sp)
                trap    #1              ;Mfree
                addq.l  #6,sp

                move.w  handlei,-(sp)   ;Close inputfile
                move.w  #$3e,-(sp)
                trap    #1              ;Fclose
                addq.l  #4,sp

                move.w  handleo,-(sp)   ;Close outputfile
                move.w  #$3e,-(sp)
                trap    #1              ;Fclose
                addq.l  #4,sp
                rts
                ENDPART

endoffile:      >PART
                bsr     closeall
                clr.w   d0              ;No errors
                bra     return
                ENDPART

error:          >PART
                bsr     closeall
                move.w  #-1,d0          ;Error
                ENDPART

return:         movem.l (sp)+,d1-d7/a2-a6
                rts

                DATA
crntab:         IBYTES 'CRNTAB.BIN'
decrntab:       IBYTES 'DECRNTAB.BIN'


                BSS
buflen:         DS.L 1          ;Lengte van de buffer
memstrt:        DS.L 1          ;Start van de buffer
handlei:        DS.W 1          ;handle nr inputfile
handleo:        DS.W 1          ;handle nr outputfile
byte1:          DS.W 1
                END
