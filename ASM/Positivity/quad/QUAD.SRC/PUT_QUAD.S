;2009/04/26 baah of Arm's Tech
;Put depacker and lz77 packed prog in bootsector


; $00 lea PackedData(pc),a0
; $04 bra $1e
; ...
; $1e BOOT (lea Where2Depack(pc),a1 etc)
;Previous version was putting the above code, but outline rules
;ask to use XBIOS 18 (Protobt) to compute checksum, etc...

  opt o+

  clr.l     -(sp)           ;Switch to supervisor
  move.w    #32,-(sp)
  trap      #1
  addq.l    #6,sp
  pea       Text            ;Print message
  move.w    #9,-(sp)
  trap      #1
  addq.l    #6,sp
WaitAKey:  
  move.w    #7,-(sp)        ;Wait a key
  trap      #1
  addq.l    #2,sp
  cmp.w     #" ",d0         ;Space?
  beq.s     PutBoot
Exit:
  clr.w     -(sp)           ;Else exit.
  trap      #1

PutBoot:
  move.w    #1,-(sp)        ;Read sector
  clr.w     -(sp)           ;Side 0
  clr.w     -(sp)           ;Track 0
  move.w    #1,-(sp)        ;Sector 1
  clr.w     -(sp)           ;Disk A
  clr.l     -(sp)
  move.l    #OldBoot,-(sp)  ;Buffer
  move.w    #8,-(sp)
  trap      #14             ;Floppy read
  add.l     #20,sp
; Put the following
;   $00 lea PackedData(pc),a0
;   $04 bra NewBoot
;  move.w    #$41fa,OldBoot  ;
;  move.w    #PackedData-NewBoot+$1e-2,OldBoot+2
;  move.w    #$6018,OldBoot+4 ;Put "bra $1e" ($18=$1e-4-2)

  move.w    #$601c,OldBoot  ;put "bra $1e" ($1c=$1e-2)
;Copy NewBoot
  move.l    #NewBoot,a0
  move.l    #OldBoot+$1e,a1
  move.w    #511,d0         ;We'll copy too much
Copy:
  move.b    (a0)+,(a1)+
  dbra      d0,Copy
;Set checksum so that the sum of words is $1234
;Checksum:
;  move.l    #OldBoot,a0
;  moveq.l   #0,d0
;  move.l    #254,d1         ;Sum up 255 words
;AddWord:
;  add.w     (a0)+,d0
;  dbra      d1,AddWord
;  move.w    #$1234,d1
;  sub.w     d0,d1           ;d1=$1234-sum
;  move.w    d1,(a0)
  move.w    #1,-(sp)        ;execflag (1=exec / 0=non exec / -1=no change)
  move.w    #-1,-(sp)       ;disktype (no change)
  move.l    #-1,-(sp)       ;serial (no change)
  pea       OldBoot
  move.w    #18,-(sp)       ;XBIOS 18=Protobt
  trap      #14
  add.l     #14,sp
;Save new boot
  move.w    #1,-(sp)        ;Write sector
  clr.w     -(sp)           ;Side 0
  clr.w     -(sp)           ;Track 0
  move.w    #1,-(sp)        ;Sector 1
  clr.w     -(sp)           ;Disk A
  clr.l     -(sp)
  move.l    #OldBoot,-(sp)  ;Buffer
  move.w    #9,-(sp)
  trap      #14             ;Floppy write
  add.l     #20,sp
  bra       WaitAKey        ;Another boot to install?

Text:
  dc.b    'Bootsector by baah of Arm''s Tech.',$d,$a
  dc.b    '',$d,$a
  dc.b    'Press <space> to install bootsector.',$d,$a
  dc.b    '',$d,$a
  dc.b    '',$d,$a
  dc.b    '',$d,$a,$0

 even

;*********** LouZy77 depacker and packed file ************
Min EQU 3 ;3 words

NewBoot

;IN  a0=@PackedData
;    a1=@Where2Depack
;OUT a0 points after packed data
;    a1 point after depacked data
Depacker
  lea       PackedData(pc),a0   ;This is in the first bytes
  move.l    $432.w,a1           ;!!!Start of free gemdos memory
  move.l    a1,a6
;    lea       Where2Depack(pc),a1
DpkControlByte  
  move.w    (a0)+,d0    ;d0=ControlByte
  beq.s     DpkEnd
  bmi.s     DpkMatch
DpkNoMatch
  move.l    a0,a2       ;a2=@CopyFrom=@PackedData
  add.w     d0,a0       ;a0+=NbNoMatch
  bra.s     DpkCopyOne
DpkMatch
  move.w    (a0)+,d1    ;d1=Offset
  move.l    a1,a2       ;a2=@Where2Depack
  sub.w     d1,a2       ;a2=@CopyFrom=@Where2Depack-Offset
  sub.w     #32768-2*(Min-1),d0 ;d0=NbMatch=Control-32768+2*(Min-1)
DpkCopyOne
  move.w    (a2)+,(a1)+
  subq.w    #2,d0
  bne.s     DpkCopyOne
  bra.s     DpkControlByte
DpkEnd
  jmp       (a6)

PackedData
  incbin 'quad.wpk'
  
  even
Where2Depack
 REPT 3
  dc.b 'baAhBaAhbaaHBAAHbaahbAaHBaahbAAhbAAHBaAHBAaHbaaHbAaHbaahBAAH'
  dc.b 'BaahbaAhBAahbaAHbaAHBAaHBAAhBaahBaAhBaahbAAHBAahbaaHbAAhbaaH'
  dc.b 'BaaHBAAhBAAHbAahbAaHbAahbaAHBAAhbaahBaAHbaahBAahBAAHbAAHBaAh'
 ENDR

;*************************************************************************

  Section BSS

OldBoot:        ; Un bootsecteur=512 octets.
  ds.w    256
  ds.w    256    ; Un petit extra.
