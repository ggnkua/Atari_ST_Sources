; ADJUST MAP FOR CONVERTED CHARACTER SETS

  data
fileprompt:             ; prompt for filename
  dc.b 'Please enter the filename (& pathname if needed) of the',10,13,0
oldpic1:
  DC.B 'first character file of the original characters.',13,10,0
oldpic2:
  DC.B 'second character file of the original characters.',13,10,0
newpic1:
  dc.b 'first character file of the new characters.',10,13,0
newpic2:
  dc.b 'second character file of the new characters.',10,13,0
MAPIN:
        DC.B 'original map.',10,13,0
MAPOUT:
        DC.B 'new map to be saved.',10,13,0
reading:
  dc.b 10,13,'Loading picture. ',10,13,0
readMAP:
  dc.b 10,13,'Loading map. ',10,13,0
converting:
  dc.b 'Converting map.',10,13,10,0
saveing:
  dc.b 10,13,'Saving map.',10,13,10,0
nomatch:
        DC.B 'There is no match for original character number '
NUM     DC.B '000.',10,13,0

input:                  ; adress of input string
  dc.b 64,0
filespec:               ; actual string begins here
  ds.b 64

  bss
handle:                 ; space for file handle
  ds.w 1
BUFFER:
  DS.w 1                ; res value
pal:
  ds.w 16               ; palette
oldpic:                 ; character images
  ds.b 64000
newpic:
  ds.b 64000
oldmap:                    ; map
        ds.b 40*144*2
newmap:                    ; map
        ds.b 40*144*2

  text
  move.l #fileprompt,d0 ; prompt for filename input     OLDPIC1
  jsr prtline
  move.l #oldpic1,d0
  jsr prtline

  move.l #input,-(sp)   ; input filename
  move #$a,-(sp)
  trap #1
  addq.l #6,sp

  lea filespec,a0
  move.b #0,(a0,d0.w)   ; null terminate the string

  move #2,-(sp)         ; open file
  move.l #filespec,-(sp)
  move #$3d,-(sp)
  trap #1
  addq.l #8,sp
  move d0,handle

  move.l #reading,d0    ; inform reading
  jsr prtline

  move.l #buffer,-(sp)  ; read
  move.l #32034,-(sp)
  move handle,-(sp)
  move #$3f,-(sp)
  trap #1
  add.l #12,sp

  move handle,-(sp)     ; close file
  move #$3e,-(sp)
  trap #1
  addq.l #4,sp

  move.l #fileprompt,d0 ; prompt for filename input     OLDPIC2
  jsr prtline
  move.l #oldpic2,d0
  jsr prtline

  move.l #input,-(sp)   ; input filename
  move #$a,-(sp)
  trap #1
  addq.l #6,sp

  lea filespec,a0
  move.b #0,(a0,d0.w)   ; null terminate the string

  move #2,-(sp)         ; open file
  move.l #filespec,-(sp)
  move #$3d,-(sp)
  trap #1
  addq.l #8,sp
  move d0,handle

  move.l #reading,d0    ; inform reading
  jsr prtline

  move.l #buffer,-(sp)  ; read  init pic bullshit
  move.l #34,-(sp)
  move handle,-(sp)
  move #$3f,-(sp)
  trap #1
  add.l #12,sp

  move.l #buffer+32034,-(sp)  ; read more image
  move.l #32000,-(sp)
  move handle,-(sp)
  move #$3f,-(sp)
  trap #1
  add.l #12,sp

  move handle,-(sp)     ; close file
  move #$3e,-(sp)
  trap #1
  addq.l #4,sp

  move.l #fileprompt,d0 ; prompt for filename input     NEWPIC1
  jsr prtline
  move.l #newpic1,d0
  jsr prtline

  move.l #input,-(sp)   ; input filename
  move #$a,-(sp)
  trap #1
  addq.l #6,sp

  lea filespec,a0
  move.b #0,(a0,d0.w)   ; null terminate the string

  move #2,-(sp)         ; open file
  move.l #filespec,-(sp)
  move #$3d,-(sp)
  trap #1
  addq.l #8,sp
  move d0,handle

  move.l #reading,d0    ; inform reading
  jsr prtline

  move.l #buffer,-(sp)  ; read  init pic bullshit
  move.l #34,-(sp)
  move handle,-(sp)
  move #$3f,-(sp)
  trap #1
  add.l #12,sp

  move.l #newpic,-(sp)  ; read  new characterset 1
  move.l #32000,-(sp)
  move handle,-(sp)
  move #$3f,-(sp)
  trap #1
  add.l #12,sp

  move handle,-(sp)     ; close file
  move #$3e,-(sp)
  trap #1
  addq.l #4,sp

  move.l #fileprompt,d0 ; prompt for filename input     NEWPIC2
  jsr prtline
  move.l #newpic2,d0
  jsr prtline

  move.l #input,-(sp)   ; input filename
  move #$a,-(sp)
  trap #1
  addq.l #6,sp

  lea filespec,a0
  move.b #0,(a0,d0.w)   ; null terminate the string

  move #2,-(sp)         ; open file
  move.l #filespec,-(sp)
  move #$3d,-(sp)
  trap #1
  addq.l #8,sp
  move d0,handle

  move.l #reading,d0    ; inform reading
  jsr prtline

  move.l #buffer,-(sp)  ; read  init pic bullshit
  move.l #34,-(sp)
  move handle,-(sp)
  move #$3f,-(sp)
  trap #1
  add.l #12,sp

  move.l #newpic+32000,-(sp)  ; read more image
  move.l #32000,-(sp)
  move handle,-(sp)
  move #$3f,-(sp)
  trap #1
  add.l #12,sp

  move handle,-(sp)     ; close file
  move #$3e,-(sp)
  trap #1
  addq.l #4,sp

  move.l #fileprompt,d0 ; prompt for filename input     MAP
  jsr prtline
  move.l #mapin,D0
  jsr prtline

  move.l #input,-(sp)   ; input filename
  move #$a,-(sp)
  trap #1
  addq.l #6,sp

  lea filespec,a0
  move.b #0,(a0,d0.w)   ; null terminate the string

  move #2,-(sp)         ; open file
  move.l #filespec,-(sp)
  move #$3d,-(sp)
  trap #1
  addq.l #8,sp
  move d0,handle

  move.l #readmap,d0    ; inform reading
  jsr prtline

  move.l #oldmap,-(sp)  ; read map
  move.l #40*144*2,-(sp)
  move handle,-(sp)
  move #$3f,-(sp)
  trap #1
  add.l #12,sp

  move handle,-(sp)     ; close file
  move #$3e,-(sp)
  trap #1
  addq.l #4,sp

  move.l #converting,d0 ; inform user of conversion process
  jsr prtline

        move    #500-1,d7       ; loop thru 500 chrs  IN THE OLD CHRS
BIGGERCOMPLOOP:
        MOVE    #500-1,D6       ; LOOP THRU 500 NEW CHRS LOOKING FOR A MATCH
BIGCMPLOOP1:                    ; COMPARE THE CHRS
        LEA     OLDPIC,A0
        LEA     NEWPIC,A1
        CLR.L   D0
        MOVE    D7,D0
        DIVU    #20,D0  ; DIVIDE BY SCREENW
        MOVE    D0,D1   ; SAVE RESULT IN D1
        SWAP    D0      ; GET REMAINDER
        MULU    #8,D0   ; CHR OFFSET TO RIGHT
        ADD.L   D0,A0   ; ADD TO CHR POINTER
        MULU    #20*8*16,D1 ; CHARACTER 16 LINE OFFSET
        ADD.L   D1,A0   ; ADD TO CHR PTR

        CLR.L   D0
        MOVE    D6,D0
        DIVU    #20,D0  ; DIVIDE BY SCREENW
        MOVE    D0,D1   ; SAVE RESULT IN D1
        SWAP    D0      ; GET REMAINDER
        MULU    #8,D0   ; CHR OFFSET TO RIGHT
        ADD.L   D0,A1   ; ADD TO CHR POINTER
        MULU    #20*8*16,D1 ; CHARACTER 16 LINE OFFSET
        ADD.L   D1,A1   ; ADD TO CHR PTR

        MOVE #16-1,D5
COMPLOOP:
        MOVE.L  (A0),D0         ; COMPARE THE CHRS
        CMP.L   (A1),D0
        BNE     NEXTCHR         ; NOMATCH EXIT
        MOVE.L  4(A0),D0
        CMP.L   4(A1),D0
        BNE     NEXTCHR         ; NOMATCH EXIT
        ADD.L   #20*8,A0        ; NEXTLINE
        ADD.L   #20*8,A1
        DBRA    D5,COMPLOOP     ; IF WE MAKE IT THROUGH THIS THEN WE
        JMP     MATCH           ; GOT IT!
NEXTCHR:
        DBRA    D6,BIGCMPLOOP1  ; CHECK NEXT CHR

        LEA     NUM+3,A0
        MOVE.B  D7,D0           ; HERE IS A NO MATCH SITUATION
        AND.B   #$F,D0          ; DISPLAY D7 IN STRING
        CMP.B   #$A,D0
        BLT     LTA1
        ADD.B   #'A'-'0'-10,D0
LTA1    ADD.B   #'0',D0
        MOVE.B  D0,-(A0)
        MOVE.B  D7,D0
        LSR.B   #4,D0
        CMP.B   #$A,D0
        BLT     LTA2
        ADD.B   #'A'-'0'-10,D0
LTA2    ADD.B   #'0',D0
        MOVE.B  D0,-(A0)
        MOVE.W  D7,D0
        LSR.B   #8,D0
        AND.B   #$F,D0
        CMP.B   #$A,D0
        BLT     LTA3
        ADD.B   #'A'-'0'-10,D0
LTA3    ADD.B   #'0',D0
        MOVE.B  D0,-(A0)

        MOVE.L  #NOMATCH,D0
        JSR     PRTLINE
        JMP     ENDLOOP

MATCH:
        LEA     OLDMAP,A6
        LEA     NEWMAP,A5
        MOVE.L  #40*144,D5     ; LOOP THRU MAP & FIND ALL


REPLACELOOP:                   ; REFRENCES TO D7
        CMP     (A6),D7        ; COMPARE
        BNE     NOREPLACE
        MOVE    D6,(A5)        ; REPLACE REF
NOREPLACE:
        ADD.L   #2,A6
        ADD.L   #2,A5
        SUBQ.L  #1,D5
        BNE     REPLACELOOP

ENDLOOP:
        DBRA    D7,BIGGERCOMPLOOP

  move.l #fileprompt,d0 ; prompt for filename output
  jsr prtline
  move.l #MAPOUT,d0
  jsr prtline

  move.l #input,-(sp)   ; input filename
  move #$a,-(sp)
  trap #1
  addq.l #6,sp

  lea filespec,a0
  move.b #0,(a0,d0.w)   ; null terminate the string

  move #0,-(sp)         ; create file
  move.l #filespec,-(sp)
  move #$3c,-(sp)
  trap #1
  addq.l #8,sp
  move d0,handle

  move.l #saveing,d0    ; inform saveing
  jsr prtline

  move.l #NEWMAP,-(sp)  ; save
  move.l #40*2*144,-(sp)
  move handle,-(sp)
  move #$40,-(sp)
  trap #1
  add.l #12,sp

  move handle,-(sp)     ; close file
  move #$3e,-(sp)
  trap #1
  addq.l #4,sp

  clr -(sp)             ; term
  trap #1

; ***** subroutines *****

prtline:
  move.l d0,-(sp)
  move #$09,-(sp)
  trap #1
  addq.l #6,sp
  rts

  end
 