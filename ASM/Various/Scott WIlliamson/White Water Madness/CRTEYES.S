  data
fileprompt:             ; prompt for filename
  dc.b 'Please enter the filename (& pathname if needed) of the',10,13,0
picture1:
  DC.B 'FIRST picture file to extract the eyes from.',13,10,0
picture2:
  DC.B 'SECOND picture file to extract the eyes from.',13,10,0
eyes:
  dc.b 'file to output the eyes to.',10,13,0
reading:
  dc.b 10,13,'Reading eyes. ',10,13,10,0
saveing:
  dc.b 10,13,'Saving eyes. ',10,13,10,0

input:                  ; adress of input string
  dc.b 64,0
filespec:               ; actual string begins here
  ds.b 64

  bss
handle:                 ; space for file handle
  ds.w 1
BUFFER1:
  DS.w 1                ; res value
pal:
  ds.w 16               ; palette
pic1:
        ds.b    32000   ; picture
BUFFER2:
  DS.w 1                ; res value
  ds.w 16               ; palette
PIC2:   DS.B    32000
eyebuf  ds.w    ((14-5)*8)*(71-44)

  text
;                               ***** PICTURE 1 *****
  move.l #fileprompt,d0 ; prompt for filename input
  jsr prtline
  move.l #picture1,d0
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

  move.l #buffer1,-(sp)  ; read
  move.l #32034,-(sp)
  move handle,-(sp)
  move #$3f,-(sp)
  trap #1
  add.l #12,sp

  move handle,-(sp)     ; close file
  move #$3e,-(sp)
  trap #1
  addq.l #6,sp
;                               ***** PICTURE 2 *****
  move.l #fileprompt,d0 ; prompt for filename input
  jsr prtline
  move.l #picture2,d0
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

  move.l #buffer2,-(sp)  ; read
  move.l #32034,-(sp)
  move handle,-(sp)
  move #$3f,-(sp)
  trap #1
  add.l #12,sp

  move handle,-(sp)     ; close file
  move #$3e,-(sp)
  trap #1
  addq.l #6,sp

        MOVE.L  #PAL,-(SP)      ; SETCOLORS
        MOVE    #6,-(SP)
        TRAP    #14
        ADDQ.L  #6,SP

        move    #2,-(sp)        ; PHYSBASE
        trap    #14
        ADDQ.L  #2,SP
        MOVE.L  D0,A2
        ADD.L   #(44*160)+(5*8),a2

        lea     BUFFER1+34+(44*160)+(5*8),a0
        lea     BUFFER2+34+(44*160)+(5*8),a3
        lea     eyebuf,a1

        move    #71-44,d1       ; COPY & DISPLAY EYES
copy1:
        move    #((14-5)*2)-1,d0
copy:
        MOVE.L  (A0),(A2)+      ; DISPLAY
        MOVE.L  (A0)+,(A1)      ; EOR
        MOVE.L  (A3)+,D3
        EOR.L   D3,(A1)+
        dbra    d0,copy
        add.l   #(160-((14-5)*8)),a0
        add.l   #(160-((14-5)*8)),a2
        add.l   #(160-((14-5)*8)),a3
        dbra    d1,copy1

  move.l #fileprompt,d0 ; prompt for filename output
  jsr prtline
  move.l #eyes,d0
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

  move.l #eyebuf,-(sp)  ; save
  move.l #((14-5)*8)*(71-44),-(sp)
  move handle,-(sp)
  move #$40,-(sp)
  trap #1
  add.l #12,sp

  move handle,-(sp)     ; close file
  move #$3e,-(sp)
  trap #1
  addq.l #6,sp

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