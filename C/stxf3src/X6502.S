
;**************************************************************************
;
;   X6502.S 
;
;   - 6502 opcodes and other asm routines
;
;   11/25/88 created
;
;   07/09/89 21:00
;
***************************************************************************

    .include "atari.sh"
    .include "x6502.sh"

; bit masks for NMI interrupt byte (matches $D40E)
INT_DLI     = $80
INT_VBI     = $40

BIT_DLI     = 7
BIT_VBI     = 6

; bit masks for IRQ interrupt byte (matches $D20E)
INT_BREAK   = $80
INT_KEY     = $40
INT_4       = $04
INT_2       = $02
INT_1       = $01

BIT_BREAK   = 7
BIT_KEY     = 6
BIT_4       = 2
BIT_2       = 1
BIT_1       = 0

; these are the BSS data structures

    .bss
_heap::

; 64K WStat array, signed offsets
    ds.l    8192
_lWStat0::
    ds.l    8192        ; 64K write stat array

; XL RAM under ROM swap space
_lXLRAM::
    ds.b    14336

; non-zero means that the XL ROMs have been swapped out with RAM
_fXLRAM::
	ds.w    1

; Display List structures, 4K should be more than enough!
_rgDL::
    ds.b    4000

; screen address near pointers
_lScrPtrs::
    ds.l    8800

; normal memory, 64K
_lMem0::
    ds.l    16384

; 64K extra bank for 130XE
    ds.l    16384
    ds.l    4096    ; padding

; note - the 64K address space moves within the 128K block defined above.


    .data

mpSTto8:
    dc.w    $FFFF, $FFFF      ; $00           
    dc.w    $1C5C, $9CDC      ; $01 Esc       
    dc.w    $1F5F, $9FDF      ; $02 1         
    dc.w    $1E75, $9EDE      ; $03 2 map to @ not "
    dc.w    $1A5A, $9ADA      ; $04 3         
    dc.w    $1858, $98D8      ; $05 4         
    dc.w    $1D5D, $9DDD      ; $06 5         
    dc.w    $1B47, $9BDB      ; $07 6 map to ^ not &
    dc.w    $335B, $B3F3      ; $08 7 map to & not '
    dc.w    $3507, $B5F5      ; $09 8 map to * not @
    dc.w    $3070, $B0F0      ; $0A 9         
    dc.w    $3272, $B2F2      ; $0B 0         
    dc.w    $0E4E, $8ECE      ; $0C -         
    dc.w    $0F06, $8FCF      ; $0D =         
    dc.w    $3474, $B4F4      ; $0E Backspace 
    dc.w    $2C6C, $ACEC      ; $0F Tab       
    dc.w    $2F6F, $AFEF      ; $10 q         
    dc.w    $2E6E, $AEEE      ; $11 w         
    dc.w    $2A6A, $AAEA      ; $12 e         
    dc.w    $2868, $A8E8      ; $13 r         
    dc.w    $2D6D, $ADED      ; $14 t         
    dc.w    $2B6B, $ABEB      ; $15 y         
    dc.w    $0B4B, $8BCB      ; $16 u         
    dc.w    $0D4D, $8DCD      ; $17 i         
    dc.w    $0848, $88C8      ; $18 o         
    dc.w    $0A4A, $8ACA      ; $19 p         
    dc.w    $6060, $A0E0      ; $1A [         
    dc.w    $6262, $A2E2      ; $1B ]         
    dc.w    $0C4C, $8CCC      ; $1C Return    
    dc.w    $FFFF, $FFFF      ; $1D Control   
    dc.w    $3F7F, $BFFF      ; $1E a         
    dc.w    $3E7E, $BEFE      ; $1F s         
    dc.w    $3A7A, $BAFA      ; $20 d         
    dc.w    $3878, $B8F8      ; $21 f         
    dc.w    $3D7D, $BDFD      ; $22 g         
    dc.w    $3979, $B9F9      ; $23 h         
    dc.w    $0141, $81C1      ; $24 j         
    dc.w    $0545, $85C5      ; $25 k         
    dc.w    $0040, $80C0      ; $26 l         
    dc.w    $0242, $82C2      ; $27 ;         
    dc.w    $735E, $B3F3      ; $28 ' map to " not 7
    dc.w    $FFFF, $FFFF      ; $29 `         
    dc.w    $FFFF, $FFFF      ; $2A l shift
    dc.w    $464F, $FFFF      ; $2B \
    dc.w    $1757, $97D7      ; $2C z         
    dc.w    $1656, $96D6      ; $2D x         
    dc.w    $1252, $92D2      ; $2E c         
    dc.w    $1050, $90D0      ; $2F v         
    dc.w    $1555, $95D5      ; $30 b         
    dc.w    $2363, $A3E3      ; $31 n         
    dc.w    $2565, $A5E5      ; $32 m         
    dc.w    $2036, $A0E0      ; $33 ,         
    dc.w    $2237, $A2E2      ; $34 .         
    dc.w    $2666, $A6E6      ; $35 /         
    dc.w    $FFFF, $FFFF      ; $36 r shift   
    dc.w    $FFFF, $FFFF      ; $37           
    dc.w    $2767, $A7E7      ; $38 alt = atari key
    dc.w    $2161, $A1E1      ; $39 space     
    dc.w    $3C7C, $BCFC      ; $3A caps      
    dc.w    $0343, $83C3      ; $3B F1        
    dc.w    $0444, $84C4      ; $3C F2        
    dc.w    $1353, $93D3      ; $3D F3        
    dc.w    $1454, $94D4      ; $3E F4        
    dc.w    $FFFF, $FFFF      ; $3F F5        
    dc.w    $FFFF, $FFFF      ; $40 F6        
    dc.w    $FFFF, $FFFF      ; $41 F7        
    dc.w    $FFFF, $FFFF      ; $42 F8        
    dc.w    $FFFF, $FFFF      ; $43 F9        
    dc.w    $FFFF, $FFFF      ; $44 F10       
    dc.w    $FFFF, $FFFF      ; $45           
    dc.w    $FFFF, $FFFF      ; $46           
    dc.w    $7676, $B6F6      ; $47 Home
    dc.w    $0E4E, $8ECE      ; $48 up arrow  
    dc.w    $FFFF, $FFFF      ; $49           
    dc.w    $0E4E, $8ECE      ; $4A pad -     
    dc.w    $0646, $86C6      ; $4B l arrow   
    dc.w    $FFFF, $FFFF      ; $4C           
    dc.w    $0747, $87C7      ; $4D r arrow   
    dc.w    $0646, $86C6      ; $4E pad +     
    dc.w    $FFFF, $FFFF      ; $4F           
    dc.w    $0F4F, $8FCF      ; $50 d arrow   
    dc.w    $FFFF, $FFFF      ; $51           
    dc.w    $3777, $B7F7      ; $52 Insert    
    dc.w    $3474, $B4F4      ; $53 Delete    
    dc.w    $FFFF, $FFFF      ; $54           
    dc.w    $FFFF, $FFFF      ; $55           
    dc.w    $FFFF, $FFFF      ; $56           
    dc.w    $FFFF, $FFFF      ; $57           
    dc.w    $FFFF, $FFFF      ; $58           
    dc.w    $FFFF, $FFFF      ; $59           
    dc.w    $FFFF, $FFFF      ; $5A           
    dc.w    $FFFF, $FFFF      ; $5B           
    dc.w    $FFFF, $FFFF      ; $5C           
    dc.w    $FFFF, $FFFF      ; $5D           
    dc.w    $FFFF, $FFFF      ; $5E           
    dc.w    $FFFF, $FFFF      ; $5F           
    dc.w    $FFFF, $FFFF      ; $60           
    dc.w    $FFFF, $FFFF      ; $61 Undo      
    dc.w    $1151, $91D1      ; $62 Help      
    dc.w    $7070, $B0F0      ; $63 pad (     
    dc.w    $7272, $B2F2      ; $64 pad )     
    dc.w    $2666, $A6E6      ; $65 pad /     
    dc.w    $0747, $87C7      ; $66 pad *     
    dc.w    $3373, $B3F3      ; $67 pad 7     
    dc.w    $3575, $B5F5      ; $68 pad 8     
    dc.w    $3070, $B0F0      ; $69 pad 9     
    dc.w    $1858, $98D8      ; $6A pad 4     
    dc.w    $1D5D, $9DDD      ; $6B pad 5     
    dc.w    $1B5B, $9BDB      ; $6C pad 6     
    dc.w    $1F5F, $9FDF      ; $6D pad 1     
    dc.w    $1E5E, $9EDE      ; $6E pad 2     
    dc.w    $1A5A, $9ADA      ; $6F pad 3     
    dc.w    $3272, $B2F2      ; $70 pad 0     
    dc.w    $2262, $A2E2      ; $71 pad .     
    dc.w    $0C4C, $8CCC      ; $72 Enter     
    dc.w    $FFFF, $FFFF      ; $73           
    dc.w    $FFFF, $FFFF      ; $74           
    dc.w    $FFFF, $FFFF      ; $75           
    dc.w    $FFFF, $FFFF      ; $76           
    dc.w    $FFFF, $FFFF      ; $77           
    dc.w    $FFFF, $FFFF      ; $78           
    dc.w    $FFFF, $FFFF      ; $79           
    dc.w    $FFFF, $FFFF      ; $7A           
    dc.w    $FFFF, $FFFF      ; $7B           
    dc.w    $FFFF, $FFFF      ; $7C           
    dc.w    $FFFF, $FFFF      ; $7D           
    dc.w    $FFFF, $FFFF      ; $7E           
    dc.w    $FFFF, $FFFF      ; $7F           


    .text

; used as a breakpoint opcode
op80:
    opinit
    nop
    move.w  a3,d7
    subq.w  #1,d7
;    cmp.w   _brkpnt,d7
;    bne     .notbp
    move.w  #3,_exit_code
    rts

.notbp:
    unused
    dispatch

_brkpnt:
    dc.w    0



; handle write access to a ROM location
rom:
    setorg  op80,128
    dispatch

; STA (zp,X)
    setorg  op80,256
op81:
    opinit
    nop
    EA_zpXind
    WriteAService

; write access to XL RAM/ROM location
    setorg  op81,128
    btst    #0,portb(a4)
    bne.s   .x
    move.b  d0,(a0)
.x:
    dispatch

    setorg  op81,256
op82:                   ;Special opcode for text draw
    opinit              ;Replaces first instruction at $F2B0
    nop
    cmpi.b  #$82,(a3)
    bne.s   not82
    move.b  d1,$2fb(a6) ;STA $2FB
    tst.b   $57(a6)     ;use OS code if DINDEX <> 0
    bne.s   old
.wait:
    tst.b   $11(a6)     ;BRKKEY
    beq.s   brk
    tst.b   $2ff(a6)    ;SSFLAG
    bne.s   .wait

    move.b  $55(a6),d7  ;use OS if COLCRS >= RMARGIN
    cmp.b   $53(a6),d7
    bcc.s   old

    move.b  d1,d7
    and.b   #$7f,d7
    cmp.b   #$7d,d7     ;use OS if non-printing char
    bcc.s   old
    cmp.b   #$20,d7
    bcc     dochr
    cmp.b   #$1b,d7
    bcs.s   doctl
old:
    addq.w  #2,a3       ;Skip 2nd $82 and NOP
not82:
    dispatch

brk:
    move.b  $80,d3      ;Set Y=$80
    move.b  d3,d6
    ext.w   d6          ;Set MI
    move.b  d3,$11(a6)
    jmp $6012(a4)       ;Do an  RTS

doctl:
    add.b   #$40,d1
    bra put

    setorg  op82,128
; handle write access to screen memory
wsScreen:
    cmp.b   (a0),d0
    beq.s   .ws
    move.b  d0,(a0)         ; write byte to 6502 address space

    btst    #5,dmactl(a4)   ; is DMA enabled?
    beq     .ws

    tst.b   fRedraw(a4)     ; is a redraw pending?
    bne     .ws
    movem.l d0-d1/d5-d7/a1-a3/a6,-(sp)

    move.l  a0,d5           ; store pointer to 6502 bytes
    lea     _rgDL,a0        ; get first DL structure

.loop:
    move.w  bScan(a0),d1    ; get scan line and mode
    beq.s   .exit

    cmp.w   uStart(a0),d5   ; compare address to start
    bcs.s   .next

    cmp.w   uEnd(a0),d5     ; compare to end
    bcc     .next

    move.w  d5,d7
    sub.w   uStart(a0),d7   ; get offset into screen block
    add.w   d7,d7
    add.w   d7,d7           ; times 4
    move.l  plPtrs(a0),a3   ; screen pointers
    adda.w  d7,a3

    move.w  #0,d1           ; count of bytes - 1
    move.l  pfPlot(a0),a2
    jsr     (a2)            ; go plot
    subq.w  #1,d5           ; d5 was incremented

.next:
    lea     sizeDL(a0),a0   ; go to next DL
    bra.s   .loop

.exit:
    movem.l (sp)+,d0-d1/d5-d7/a1-a3/a6
.ws:
    dispatch

    setorg  op82,256
op83:
    opinit
    nop
    unused
    dispatch


    setorg  op83,128
    ; write access to a display list byte
wsDL:
    cmp.b   (a0),d0
    beq.s   .ws
    move.b  d0,(a0)         ; write byte to 6502 address space

    addq.b  #1,fRedraw(a4)
.ws:
    dispatch

; STY zp
    setorg  op83,256
op84:
    opinit
    nop
    EA_zp
    move.b  d3,(a0)
    dispatch

    setorg  op84,128
    ; write access to display list byte which contains an address
wsDLa:
    cmp.b   (a0),d0
    beq.s   .ws
    move.b  d0,(a0)         ; write byte to 6502 address space

    addq.b  #1,fRedraw(a4)
.ws:
    dispatch

; STA zp
    setorg op84,256
op85:
    opinit
    nop
    EA_zp
    move.b  d1,(a0)
    dispatch

dochr:
    cmp.b   #$60,d7
    bcc.s   put
    sub.b   #$20,d1
put:
    movem.l d0-d1/d5-d7/a1-a3,-(sp)
    movep   $5f(a6),d7      ;OLDADR
    move.b  $5e(a6),d7
    move.w  d1,d3           ;move A to Y
    move.w  savrc(pc),d0
    cmp.w   $54(a6),d0
    beq.s   .samloc         ;Cursor is still where we left it
    move.b  $5d(a6),d0
    bsr.s   putd7
    movep   $59(a6),d7      ;Calc new screen adr based on
    move.b  $58(a6),d7      ;SAVMSC and cursor position
    move.b  $55(a6),d0
    add.w   d0,d7
    move.b  $54(a6),d0
    mulu    #40,d0
    add.w   d0,d7

.samloc:
    move.w  d3,d0
    bsr.s   putd7
    addq.w  #1,d5
    move.l  d5,a0
    move.b  (a0),$5d(a6)
    move.b  d5,$5e(a6)      ;Put new adr back into OLDADR
    lsr.w   #8,d5
    move.b  d5,$5f(a6)
    addq.b  #1,$55(a6)      ;Inc COLCRS
    addq.b  #1,$63(a6)      ; & LOGCOL

    tst.b   $2f0(a6)        ;Ck CRSINH
    bne.s   nocrs
    move.b  (a0),d0
    eor.b   #$80,d0
    bsr.s   putscn
nocrs:
    lea savrc(pc),a1
    move.w  $54(a6),(a1)
    movem.l (sp)+,d0-d1/d5-d7/a1-a3
    move.b  d0,d3           ;Set Y=1
    move.w  d0,d6           ;Clr N
    jmp $6012(a4)           ;Do an  RTS

putd7:                  ;putscn is copied from wsScreen, except I need
    move.l  d7,a0       ; an RTS at the end
putscn:
    move.l  a0,d5           ; store pointer to 6502 bytes
    cmp.b   (a0),d0
    beq.s   .exit
    move.b  d0,(a0)         ; write byte to 6502 address space
    btst    #5,dmactl(a4)   ; is DMA enabled?
    beq.s   .exit
    tst.b   fRedraw(a4)     ; is a redraw pending?
    bne.s   .exit
    lea     _rgDL,a0        ; get first DL structure

.loop:
    move.w  bScan(a0),d1    ; get scan line and mode
    beq.s   .exit
    cmp.w   uStart(a0),d5   ; compare address to start
    bcs.s   .next
    cmp.w   uEnd(a0),d5     ; compare to end
    bcc.s   .next
    move.w  d5,d7
    sub.w   uStart(a0),d7   ; get offset into screen block
    add.w   d7,d7
    add.w   d7,d7           ; times 4
    move.l  plPtrs(a0),a3   ; screen pointers
    adda.w  d7,a3
    move.w  #0,d1           ; count of bytes - 1
    move.l  pfPlot(a0),a2
    jsr     (a2)            ; go plot
    subq.w  #1,d5           ; d5 was incremented
.next:
    lea     sizeDL(a0),a0   ; go to next DL
    bra.s   .loop
.exit:
    move.w  #1,d0
    rts
savrc:
    dc.w    $ffff

; STX zp
    setorg op85,256
op86:
    opinit
    nop
    EA_zp
    move.b  d2,(a0)
    dispatch

    setorg op86,256
op87:
    opinit
    nop
    unused
    dispatch

; DEY
    setorg .op,256
op88:
    opinit
    nop
    subq.b  #1,d3
    move.b  d3,d6
    ext.w   d6
    dispatch

_nameXCX::
    dc.b    'AUTOEXEC.XCX',0     ; 12 bytes for file name
_pathXCX::
    dc.b    'A:\\',0    ; remainder (~200 bytes) for path
    dc.l    0,0,0,0,0,0,0,0,0,0
    dc.l    0,0,0,0,0,0,0,0,0,0
    dc.l    0,0,0,0,0,0,0,0,0,0

    setorg op88,256
op89:
    opinit
    nop
    unused
    dispatch

_rgqBank::
    dc.l    0
    dc.l    0
    dc.l    0
    dc.l    0
    dc.l    0
    dc.l    0
    dc.l    0
    dc.l    0

_qoldbank::
    dc.l    0

swap_XE:
    movem.l d0/d7/a0-a1,-(sp)
    move.l  _lMemory(pc),d7
    move.l  _qoldbank(pc),a1    ; address of old bank

    move.b  _portb(pc),d7
    andi.w  #$001C,d7
    lea     _rgqBank(pc),a0
    adda.w  d7,a0
    move.l  (a0),a0         ; get address of new bank
    cmp.l   a0,a1
    beq.s   .x              ; swapping same bank, shouldn't happen!

    move.l  a0,_qoldbank
    move.w  #1023,d7
.1:
    move.l  (a0),d0
    move.l  (a1),(a0)+
    move.l  d0,(a1)+
    move.l  (a0),d0
    move.l  (a1),(a0)+
    move.l  d0,(a1)+
    move.l  (a0),d0
    move.l  (a1),(a0)+
    move.l  d0,(a1)+
    move.l  (a0),d0
    move.l  (a1),(a0)+
    move.l  d0,(a1)+
    dbf     d7,.1

.x:
    movem.l (sp)+,d0/d7/a0-a1
    rts

; TXA
    setorg op89,256
op8A:
    opinit
    nop
    move.b  d2,d1
    move.b  d1,d6
    ext.w   d6
    dispatch

swap_XL:
    movem.l d0-d1/d7/a0-a1,-(sp)
    move.l  _lMemory(pc),d7

	move.w  _fXLRAM,d7
    or.b    _portb(pc),d7
    btst    #0,d7
    bne.s   .x

	eori.w  #1,_fXLRAM

    ; swap 4K space between 48K and 52K
    move.w  #$C000,d7
    move.l  d7,a0
    lea     _lXLRAM,a1
    move.w  #255,d0
    bsr     swap

    move.w  #$D800,d7
    move.l  d7,a0
    move.w  #639,d0
    bsr     swap

.x:
    movem.l (sp)+,d0-d1/d7/a0-a1
    rts

swap:
    move.l  (a0),d1
    move.l  (a1),(a0)+
    move.l  d1,(a1)+

    move.l  (a0),d1
    move.l  (a1),(a0)+
    move.l  d1,(a1)+

    move.l  (a0),d1
    move.l  (a1),(a0)+
    move.l  d1,(a1)+

    move.l  (a0),d1
    move.l  (a1),(a0)+
    move.l  d1,(a1)+
    dbf     d0,swap
    rts

    setorg op8A,256
op8B:
    opinit
    nop
    unused
    dispatch


; STY abs
    setorg op8B,256
op8C:
    opinit
    nop
    EA_abs
    WriteYService

; PIA location $D300
    setorg  .op,128
wsD300:
    dispatch


; STA abs
    setorg op8C,256
op8D:
    opinit
    nop
    EA_abs
    WriteAService

; PIA location $D301 - banked memory control!
;
;               0       1
;   bit 0 -    RAM   OS ROM
;   bit 1 -   BASIC    RAM      (forced to one value at init time)
;   bit 2 -   b0
;   bit 3 -   b1
;   bit 4 -    bank    64K      (CPE)
;   bit 5 - unused, set to 1    (VBE)
;   bit 6 - unused, set to 1  
;   bit 7 - unused, set to 1    (self test ROM)

    setorg  .op,128
wsD301:
    ori.w   #$E0,d0         ; force top 3 bits to 1
    move.w  #$D301,d7
    move.l  d7,a0
    move.b  d0,(a0)         ; store new value
    move.b  d0,4(a0)
    move.b  d0,8(a0)
    move.b  d0,12(a0)
    move.b  d0,16(a0)
    move.b  d0,20(a0)
    move.b  d0,24(a0)
    move.b  d0,28(a0)
    move.b  d0,32(a0)
    move.b  d0,36(a0)
    move.b  d0,40(a0)
    move.b  d0,44(a0)

    move.b  portb(a4),d7    ; load old value
    eor.b   d0,d7           ; see which bits changed
    andi.w  #$0002,d7       ; isolate Atari BASIC
    eor.b   d7,d0           ; and force it to old value
    cmp.b   portb(a4),d0    ; compare new value and old value
    beq.s   .x              ; exit if same
    move.b  portb(a4),d7    ; get old value again
    move.b  d0,portb(a4)
    eor.b   d0,d7
    lsl.w   #8,d7
    move.b  d0,d7           ; bits 15-8 = changes   bits 7-0 = new value
.0:
    btst    #8,d7
    beq.s   .2

    bsr     swap_XL

.2:
    btst    #10,d7
    bne.s   .swap_XE
    btst    #11,d7
    bne.s   .swap_XE
    btst    #12,d7
    beq.s   .x

.swap_XE:
    bsr     swap_XE

.x:
    dispatch


; STX abs
    setorg op8D,256
op8E:
    opinit
    nop
    EA_abs
    WriteXService

; PIA location $D302
    setorg  .op,128
wsD302:
    dispatch

    setorg op8E,256
op8F:
    opinit
    nop
    unused
    dispatch

; PIA location $D303
    setorg  .op,128
wsD303:
    dispatch

; BCC
    setorg op8F,256
op90:
    opinit
    nop
    tst.b   d4
    bne.s   .nobcc
    move.b  (a3)+,d7
    ext.w   d7
    adda.w  d7,a3
    dispatch
.nobcc:
    addq.w  #1,a3
    dispatch

; GTIA location $D000
    setorg  .op,128
wsD000:
    dispatch

; STA (zp),Y
    setorg op90,256
op91:
    opinit
    nop
    EA_zpYind
    WriteAService

; GTIA location $D001
    setorg  .op,128
wsD001:
    dispatch

    setorg op91,256
op92:
    opinit
    nop
    unused
    dispatch

; GTIA location $D002
    setorg  .op,128
wsD002:
    dispatch

    setorg op92,256
op93:
    opinit
    nop
    unused
    dispatch

; GTIA location $D003
    setorg  .op,128
wsD003:
    dispatch

; STY zp,X
    setorg op93,256
op94:
    opinit
    nop
    EA_zpX
    move.b  d3,(a0)
    dispatch

; GTIA location $D004
    setorg  .op,128
wsD004:
    dispatch

; STA zp,X
    setorg op94,256
op95:
    opinit
    nop
    EA_zpX
    move.b  d1,(a0)
    dispatch

; GTIA location $D005
    setorg  .op,128
wsD005:
    dispatch

; STX zp,Y
    setorg op95,256
op96:
    opinit
    nop
    EA_zpY
    move.b  d2,(a0)
    dispatch

; GTIA location $D006
    setorg  .op,128
wsD006:
    dispatch

    setorg op96,256
op97:
    opinit
    nop
    unused
    dispatch

; GTIA location $D007
    setorg  .op,128
wsD007:
    dispatch

; TYA
    setorg op97,256
op98:
    opinit
    nop
    move.b  d3,d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; GTIA location $D008
    setorg  .op,128
wsD008:
    dispatch

; STA abs,Y
    setorg op98,256
op99:
    opinit
    nop
    EA_absY
    WriteAService

; GTIA location $D009
    setorg  .op,128
wsD009:
    dispatch

; TXS
    setorg op99,256
op9A:
    opinit
    nop
    move.l  a2,d7
    move.b  d2,d7
    move.l  d7,a2
    dispatch

; GTIA location $D00A
    setorg  .op,128
wsD00A:
    dispatch

    setorg op9A,256
op9B:
    opinit
    nop
    unused
    dispatch
    
; GTIA location $D00B
    setorg  .op,128
wsD00B:
    dispatch

    setorg op9B,256
op9C:
    opinit
    nop
    unused
    dispatch
    
; GTIA location $D00C
    setorg  .op,128
wsD00C:
    dispatch

; STA abs,X
    setorg op9C,256
op9D:
    opinit
    nop
    EA_absX
    WriteAService

; GTIA location $D00D
    setorg  .op,128
wsD00D:
    dispatch

    setorg op9D,256
op9E:
    opinit
    nop
    unused
    dispatch

; GTIA location $D00E
    setorg  .op,128
wsD00E:
    dispatch

    setorg op9E,256
op9F:
    opinit
    nop
    unused
    dispatch

; GTIA location $D00F
    setorg  .op,128
wsD00F:
    dispatch

; LDY #
    setorg op9F,256
opA0:
    opinit
    nop
    move.b  (a3)+,d3
    move.b  d3,d6
    ext.w   d6
    dispatch

; GTIA location $D010
    setorg  .op,128
wsD010:
    dispatch

; LDA (zp,X)
    setorg opA0,256
opA1:
    opinit
    nop
    EA_zpXind
    move.b  (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; GTIA location $D011
    setorg  .op,128
wsD011:
    dispatch

; LDX #
    setorg opA1,256
opA2:
    opinit
    nop
    move.b  (a3)+,d2
    move.b  d2,d6
    ext.w   d6
    dispatch

; GTIA location $D012
    setorg  .op,128
wsD012:
    dispatch

    setorg opA2,256
opA3:
    opinit
    nop
    unused
    dispatch

; GTIA location $D013
    setorg  .op,128
wsD013:
    dispatch

; LDY zp
    setorg opA3,256
opA4:
    opinit
    nop
    EA_Yzp
    move.b  (a0),d3
    move.b  d3,d6
    ext.w   d6
    dispatch

; GTIA location $D014
    setorg  .op,128
wsD014:
    dispatch

; LDA zp
    setorg opA4,256
opA5:
    opinit
    nop
    EA_Azp
    move.b  (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; GTIA location $D015
    setorg  .op,128
wsD015:
    dispatch

; LDX zp
    setorg opA5,256
opA6:
    opinit
    nop
    EA_Xzp
    move.b  (a0),d2
    move.b  d2,d6
    ext.w   d6
    dispatch

; GTIA location $D016 - COLPF0 - playfield color 0
    setorg  .op,128
wsD016:
    move.b  d0,colpf0(a4)
    btst    #5,dmactl(a4)   ; is DMA enabled?
    beq.s   .0
    lea     rgwRainbow,a0
    andi.w  #$FE,d0
    move.w  0(a0,d0.w),d7
    move.w  d7,_rgwAtColors+2
    move.w  d7,$FFFF8242
    dispatch

.0:
    clr.w   $FFFF8242
    dispatch

    setorg opA6,256
opA7:
    opinit
    nop
    unused
    dispatch

; GTIA location $D017 - COLPF1
    setorg  .op,128
wsD017:
    move.b  d0,colpf1(a4)
    btst    #5,dmactl(a4)   ; is DMA enabled?
    beq.s   .0
    lea     rgwRainbow,a0
    andi.w  #$FE,d0
    move.w  0(a0,d0.w),d7
    move.w  d7,_rgwAtColors+4
    move.w  d7,$FFFF8244

    ; do wierd stuff for mode 2
    move.b  colpf2(a4),d7
    andi.w  #$F0,d7
    andi.w  #$0E,d0
    or.w    d7,d0
    move.w  0(a0,d0.w),d7
    move.w  d7,_rgwAtColors+14
    move.w  d7,$FFFF824E
    dispatch

.0:
    clr.w   $FFFF8244
    clr.w   $FFFF824E
    dispatch

; TAY
    setorg opA7,256
opA8:
    opinit
    nop
    move.b  d1,d3
    move.b  d3,d6
    ext.w   d6
    dispatch

; GTIA location $D018 - COLPF2
    setorg  .op,128
wsD018:
    move.b  d0,colpf2(a4)
    btst    #5,dmactl(a4)   ; is DMA enabled?
    beq.s   .0
    lea     rgwRainbow,a0
    andi.w  #$FE,d0
    move.w  0(a0,d0.w),d7
    move.w  d7,_rgwAtColors+6
    move.w  d7,$FFFF8246

    ; do wierd stuff for mode 2
    move.b  colpf1(a4),d7
    andi.w  #$0E,d7
    andi.w  #$F0,d0
    or.w    d7,d0
    move.w  0(a0,d0.w),d7
    move.w  d7,_rgwAtColors+14
    move.w  d7,$FFFF824E
    dispatch

.0:
    clr.w   $FFFF8246
    clr.w   $FFFF824E
    dispatch

; LDA #
    setorg opA8,256
opA9:
    opinit
    nop
    move.b  (a3)+,d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; GTIA location $D019 - COLPF3
    setorg  .op,128
wsD019:
    move.b  d0,colpf3(a4)
    btst    #5,dmactl(a4)   ; is DMA enabled?
    beq.s   .0
    lea     rgwRainbow,a0
    andi.w  #$FE,d0
    move.w  0(a0,d0.w),d7
    move.w  d7,_rgwAtColors+8
    move.w  d7,$FFFF8248
    dispatch

.0:
    clr.w   $FFFF8248
    dispatch

; TAX
    setorg opA9,256
opAA:
    opinit
    nop
    move.b  d1,d2
    move.b  d2,d6
    ext.w   d6
    dispatch

; GTIA location $D01A - COLBK
    setorg  .op,128
wsD01A:
    move.b  d0,colbk(a4)        ; background color always shows up
    lea     rgwRainbow,a0
    andi.w  #$FE,d0
    move.w  0(a0,d0.w),d7
    move.w  d7,_rgwAtColors
    move.w  d7,$FFFF8240
    dispatch

    setorg opAA,256
opAB:
    opinit
    nop
    unused
    dispatch

; GTIA location $D01B
    setorg  .op,128
wsD01B:
    dispatch

; LDY abs
    setorg opAB,256
opAC:
    opinit
    nop
    EA_abs

    move.b  (a0),d3
    move.b  d3,d6
    ext.w   d6
    dispatch

; GTIA location $D01C
    setorg  .op,128
wsD01C:
    dispatch

; LDA abs
    setorg opAC,256
opAD:
    opinit
    nop
    EA_abs

    move.b  (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; GTIA location $D01D
    setorg  .op,128
wsD01D:
    dispatch

; LDX abs
    setorg opAD,256
opAE:
    opinit
    nop
    EA_abs

    move.b  (a0),d2
    move.b  d2,d6
    ext.w   d6
    dispatch

; GTIA location $D01E
    setorg  .op,128
wsD01E:
    dispatch

    setorg opAE,256
opAF:
    opinit
    nop
    unused
    dispatch

; GTIA location $D01F
    setorg  .op,128
wsD01F:
    move.w  #$D01F,d7
    move.l  d7,a0
    not.b   d0
    andi.b  #$0F,d0
    move.b  d0,consol(a4)

    and.b   #$08,d0
    sne     d0
    andi.b  #$0F,d0         ; volume is $0 or $8

    lea     $FFFF8800,a0
    move.b  #10,(a0)
    move.b  d0,2(a0)        ; set C volume = $F
    move.b  #7,(a0)
    move.b  (a0),d0
    andi.b  #$DF,d0
    move.b  d0,2(a0)        ; enable C noise
    dispatch

; BCS
    setorg opAF,256
opB0:
    opinit
    nop
    tst.b   d4
    beq.s   .nobcs
    move.b  (a3)+,d7
    ext.w   d7
    adda.w  d7,a3
    dispatch
.nobcs:
    addq.w  #1,a3
    dispatch

; POKEY location $D200
sd1:
    move.b  audf1(a4),d0
    lsr.b   #2,d0
    move.b  #6,(a0)
    move.b  d0,2(a0)
    move.b  #7,(a0)
    move.b  (a0),d0
    andi.b  #$F7,d0
    ori.w   #$01,d0
    move.b  #7,(a0)
    move.b  d0,2(a0)
    dispatch

    setorg  opB0,128
wsD200:
    move.b  d0,audf1(a4)
snd1:
    lea     $FFFF8800,a0
    move.b  #7,(a0)
    move.b  (a0),d0
    ori.w   #$9,d0
    move.b  d0,2(a0)     ; sound and volume off

    move.b  audc1(a4),d0
    andi.w  #$F,d0
    move.b  #8,(a0)
    move.b  d0,2(a0)        ; volume A
;    move.b  #15,2(a0)        ; volume A

    move.b  audc1(a4),d0
    andi.w  #$A0,d0
    cmpi.w  #$A0,d0
    bne     sd1

    move.b  audf1(a4),d0
    add.w   d0,d0
    add.w   d0,d0
    move.b  #0,(A0)
    move.b  D0,2(A0)
    lsr.w   #8,D0
    move.b  #1,(A0)
    move.b  D0,2(A0)
    move.b  #7,(a0)
    move.b  (a0),d0
    andi.b  #$FE,d0
    move.b  #7,(a0)
    move.b  d0,2(a0)
    dispatch

; LDA (zp),Y
    setorg opB0,256
opB1:
    opinit
    nop
    EA_zpYind
    move.b  (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; POKEY location $D201
    setorg  .op,128
wsD201:
    move.b  d0,audc1(a4)
    bra     snd1
    dispatch

    setorg opB1,256
opB2:
    opinit
    nop
    unused
    dispatch

; POKEY location $D202
sd2:
    move.b  audf2(a4),d0
    lsr.b   #2,d0
    move.b  #6,(a0)
    move.b  d0,2(a0)
    move.b  #7,(a0)
    move.b  (a0),d0
    andi.b  #$EF,d0
    ori.w   #$02,d0
    move.b  #7,(a0)
    move.b  d0,2(a0)
    dispatch

    setorg  opB2,128
wsD202:
    move.b  d0,audf2(a4)
snd2:
    lea     $FFFF8800,a0
    move.b  #7,(a0)
    move.b  (a0),d0
    ori.w   #$12,d0
    move.b  d0,2(a0)     ; sound and volume off

    move.b  audc2(a4),d0
    andi.w  #$F,d0
    move.b  #9,(a0)
    move.b  d0,2(a0)        ; volume B

    move.b  audc2(a4),d0
    andi.w  #$A0,d0
    cmpi.w  #$A0,d0
    bne     sd1

    move.b  audf2(a4),d0
    add.w   d0,d0
    add.w   d0,d0
    move.b  #2,(A0)
    move.b  D0,2(A0)
    lsr.w   #8,D0
    move.b  #3,(A0)
    move.b  D0,2(A0)
    move.b  #7,(a0)
    move.b  (a0),d0
    andi.b  #$FD,d0
    ori.w   #$10,d0
    move.b  #7,(a0)
    move.b  d0,2(a0)
    dispatch

    setorg opB2,256
opB3:
    opinit
    nop
    unused
    dispatch

; POKEY location $D203
    setorg  .op,128
wsD203:
    move.b  d0,audc2(a4)
    bra     snd2
    dispatch

; LDY zp,X
    setorg opB3,256
opB4:
    opinit
    nop
    EA_zpX
    move.b  (a0),d3
    move.b  d3,d6
    ext.w   d6
    dispatch

; POKEY location $D204
    setorg  .op,128
wsD204:
    move.b  d0,audf3(a4)
    move.b  d0,audf1(a4)
    bra     snd1
    dispatch

; LDA zp,X
    setorg opB4,256
opB5:
    opinit
    nop
    EA_zpX
    move.b  (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; POKEY location $D205
    setorg  .op,128
wsD205:
    move.b  d0,audc3(a4)
    move.b  d0,audc1(a4)
    bra     snd1
    dispatch

; LDX zp,Y
    setorg opB5,256
opB6:
    opinit
    nop
    EA_zpY
    move.b  (a0),d2
    move.b  d2,d6
    ext.w   d6
    dispatch

; POKEY location $D206
    setorg  .op,128
wsD206:
    move.b  d0,audf4(a4)
    move.b  d0,audf2(a4)
    bra     snd2
    dispatch

    setorg opB6,256
opB7:
    opinit
    nop
    unused
    dispatch

; POKEY location $D207
    setorg  .op,128
wsD207:
    move.b  d0,audc4(a4)
    move.b  d0,audc2(a4)
    bra     snd2
    dispatch

; CLV
    setorg opB7,256
opB8:
    opinit
    nop
    clr.b   d5
    dispatch

; POKEY location $D208
    setorg  .op,128
wsD208:
    move.b  d0,audctl(a4)
    dispatch

; LDA abs,Y
    setorg opB8,256
opB9:
    opinit
    nop
    EA_absY

    move.b  (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; POKEY location $D209
    setorg  .op,128
wsD209:
    dispatch

; TSX
    setorg opB9,256
opBA:
    opinit
    nop
    move.w  a2,d6
    move.b  d6,d2
    ext.w   d6
    dispatch

; POKEY location $D20A - SKREST
; reset bits 5..7 in $D20F
    setorg  .op,128
wsD20A:
    andi.w  #$FF0F,d7
    move.l  d7,a0
    ori.b   #$E0,5(a0)
    move.b  5(a0),d0
    move.b  d0,$15(a0)
    move.b  d0,$25(a0)
    move.b  d0,$35(a0)
    move.b  d0,$45(a0)
    move.b  d0,$55(a0)
    move.b  d0,$65(a0)
    move.b  d0,$75(a0)
    move.b  d0,$85(a0)
    move.b  d0,$95(a0)
    move.b  d0,$A5(a0)
    move.b  d0,$B5(a0)
    move.b  d0,$C5(a0)
    move.b  d0,$D5(a0)
    move.b  d0,$E5(a0)
    move.b  d0,$F5(a0)
    dispatch

    setorg opBA,256
opBB:
    opinit
    nop
    unused
    dispatch

; POKEY location $D20B
    setorg  .op,128
wsD20B:
    dispatch

; LDY abs,X
    setorg opBB,256
opBC:
    opinit
    nop
    EA_absX

    move.b  (a0),d3
    move.b  d3,d6
    ext.w   d6
    dispatch

; POKEY location $D20C
    setorg  .op,128
wsD20C:
    dispatch

; LDA abs,X
    setorg opBC,256
opBD:
    opinit
    nop
    EA_absX

    move.b  (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; POKEY location $D20D
    setorg  .op,128
wsD20D:
    dispatch

; LDX abs,Y
    setorg opBD,256
opBE:
    opinit
    nop
    EA_absY

    move.b  (a0),d2
    move.b  d2,d6
    ext.w   d6
    dispatch

; POKEY location $D20E
    setorg  .op,128
wsD20E:
    andi.w  #$FF0F,d7
    move.l  d7,a0
    andi.b  #$C0,d0         ; we only allow BREAK and KEY interrupts
    move.b  d0,irqen(a4)
    and.b   d0,bIRQ(a4)     ; clear IRQ status bits
    not.b   d0              ; invert enable bits and use them to
    or.b    d0,(a0)         ; clear IRQ status bits
    move.b  (a0),d0
    move.b  d0,$10(a0)
    move.b  d0,$20(a0)
    move.b  d0,$40(a0)
    move.b  d0,$60(a0)
    move.b  d0,$80(a0)
    move.b  d0,$F0(a0)
    dispatch

    setorg opBE,256
opBF:
    opinit
    nop
    unused
    dispatch

; POKEY location $D20F - SKCTL
; only bits we are interested in are:
;  -  b0 (debounce enable)
;  -  b1 (key scan enable)
    setorg  .op,128
wsD20F:
    dispatch

; CPY #
    setorg opBF,256
opC0:
    opinit
    nop
    move.b  d3,d6
    sub.b   (a3)+,d6
    scc     d4
    ext.w   d6
    dispatch

; ANTIC location $D400 - DMACTL
    setorg  .op,128
wsD400:
    ; check bit 5 for 0->1 transition (DMA is being enabled)
    btst    #5,dmactl(a4)
    bne.s   .1
    btst    #5,d0
    beq.s   .1
    addq.b  #7,fRedraw(a4)
.1:
    move.b  d0,dmactl(a4)
    dispatch

; CMP (zp,X)
    setorg opC0,256
opC1:
    opinit
    nop
    EA_zpXind

    move.b  d1,d6        ; must do a subtract without affecting d1
    sub.b   (a0),d6
    scc     d4
    ext.w   d6
    dispatch

; ANTIC location $D401 - CHACTL
    setorg  .op,128
wsD401:
    dispatch

    setorg opC1,256
opC2:
    opinit
    nop
    unused
    dispatch

; ANTIC location $D402 - DLISTL
    setorg  .op,128
wsD402:
    cmp.b   dlistl(a4),d0
    beq.s   .1
    move.b  d0,dlistl(a4)
    addq.b  #7,fRedraw(a4)
.1:
    dispatch

    setorg opC2,256
opC3:
    opinit
    nop
    unused
    dispatch

; ANTIC location $D403 - DLISTH
    setorg  .op,128
wsD403:
    cmp.b   dlisth(a4),d0
    beq.s   .1
    move.b  d0,dlisth(a4)
    addq.b  #7,fRedraw(a4)
.1:
    dispatch

; CPY zp
    setorg opC3,256
opC4:
    opinit
    nop
    EA_zp
    move.b  d3,d6
    sub.b   (a0),d6
    scc     d4
    ext.w   d6
    dispatch

; ANTIC location $D404 - HSCROL
    setorg  .op,128
wsD404:
    dispatch

; CMP zp
    setorg opC4,256
opC5:
    opinit
    nop
    EA_zp
    move.b  d1,d6        ; must do a subtract without affecting d1
    sub.b   (a0),d6
    scc     d4
    ext.w   d6
    dispatch

; ANTIC location $D405 - VSCROL
    setorg  .op,128
wsD405:
    dispatch

; DEC zp
    setorg opC5,256
opC6:
    opinit
    nop
    EA_zp
    subq.b  #1,(a0)
    move.b  (a0),d6
    ext.w   d6
    dispatch

; ANTIC location $D406 - unused
    setorg  .op,128
wsD406:
    dispatch

    setorg opC6,256
opC7:
    opinit
    nop
    unused
    dispatch

; ANTIC location $D407 - PMBASE
    setorg  .op,128
wsD407:
    dispatch

; INY
    setorg opC7,256
opC8:
    opinit
    nop
    addq.b  #1,d3
    move.b  d3,d6
    ext.w   d6
    dispatch

; ANTIC location $D408 - unused
    setorg  .op,128
wsD408:
    dispatch

; CMP #
    setorg opC8,256
opC9:
    opinit
    nop
    move.b  d1,d6        ; must do a subtract without affecting d1
    sub.b   (a3)+,d6
    scc     d4
    ext.w   d6
    dispatch

; ANTIC location $D409 - CHBASE
    setorg  .op,128
wsD409:
    cmp.b   chbase(a4),d0
    beq.s   .1
    move.b  d0,chbase(a4)
    addq.b  #7,fRedraw(a4)
.1:
    dispatch

; DEX
    setorg opC9,256
opCA:
    opinit
    nop
    subq.b  #1,d2
    move.b  d2,d6
    ext.w   d6
    dispatch

; ANTIC location $D40A - WSYNC
    setorg  .op,128
wsD40A:
    dispatch

    setorg opCA,256
opCB:
    opinit
    nop
    unused
    dispatch

; ANTIC location $D40B - unused
    setorg  .op,128
wsD40B:
    dispatch

; CPY abs
    setorg opCB,256
opCC:
    opinit
    nop
    EA_abs

    move.b  d3,d6
    sub.b   (a0),d6
    scc     d4
    ext.w   d6
    dispatch

; ANTIC location $D40C - unused
    setorg  .op,128
wsD40C:
    dispatch

; CMP abs
    setorg opCC,256
opCD:
    opinit
    nop
    EA_abs

    move.b  d1,d6        ; must do a subtract without affecting d1
    sub.b   (a0),d6
    scc     d4
    ext.w   d6
    dispatch

; ANTIC location $D40D - unused
    setorg  .op,128
wsD40D:
    dispatch

; DEC abs
    setorg opCD,256
opCE:
    opinit
    nop
    EA_abs

    move.b  (a0),d6
    subq.b  #1,d6
    ext.w   d6
    WriteService

; ANTIC location $D40E
; handle NMIEN
    setorg  .op,128
wsD40E:
    andi.b  #$40,d0
    move.b  d0,nmien(a4)
    dispatch

    setorg opCE,256
opCF:
    opinit
    nop
    unused
    dispatch

; ANTIC location $D40F - NMIRES
; clears NMI status
    setorg  .op,128
wsD40F:
    andi.w  #$FF0F,d7
    move.l  d7,a0
    move.w  #$1F,d0
    move.b  d0,(a0)   ; Poke $D40F,$1F
    move.b  d0,$10(a0)
    move.b  d0,$20(a0)
    move.b  d0,$40(a0)
    move.b  d0,$70(a0)
    move.b  d0,$80(a0)
    move.b  d0,$F0(a0)
    clr.b   bNMI(a4)
    dispatch

; BNE
    setorg opCF,256
opD0:
    opinit
    nop
    tst.b   d6
    beq.s   .nobne
    move.b  (a3)+,d7
    ext.w   d7
    adda.w  d7,a3
    dispatch
.nobne:
    addq.w  #1,a3
    dispatch

; CMP (zp),Y
    setorg .op,256
opD1:
    opinit
    nop
    EA_zpYind

    move.b  d1,d6        ; must do a subtract without affecting d1
    sub.b   (a0),d6
    scc     d4
    ext.w   d6
    dispatch

; 3 unused opcodes, used for F: OPEN, CLOSE, and
    setorg .op,256
opD2:
    opinit
    nop
    move.w  #10,_exit_code
    rts
    unused
    dispatch

    setorg .op,256
opD3:
    opinit
    nop
    move.w  #11,_exit_code
    rts
    unused
    dispatch

    setorg .op,256
opD4:
    opinit
    nop
    move.w  #12,_exit_code
    rts
    unused
    dispatch

; CMP zp,X
    setorg .op,256
opD5:
    opinit
    nop
    EA_zpX
    move.b  d1,d6        ; must do a subtract without affecting d1
    sub.b   (a0),d6
    scc     d4
    ext.w   d6
    dispatch

; DEC zp,X
    setorg .op,256
opD6:
    opinit
    nop
    EA_zpX
    subq.b  #1,(a0)
    move.b  (a0),d6
    ext.w   d6
    dispatch

    setorg .op,256
opD7:
    opinit
    nop
    unused
    dispatch

; CLD
    setorg .op,256
opD8:
    opinit
    nop
    bclr    #31,d6

    tst.w   fTrace(a4)
    bne.s   .tr

    lea     iBin(a4),a5
.tr:
    dispatch

; CMP abs,Y
    setorg .op,256
opD9:
    opinit
    nop
    EA_absY

    move.b  d1,d6        ; must do a subtract without affecting d1
    sub.b   (a0),d6
    scc     d4
    ext.w   d6
    dispatch

    setorg .op,256
opDA:
    opinit
    nop
    move.w  #13,_exit_code
    rts
    unused
    dispatch

    setorg .op,256
opDB:
    opinit
    nop
    move.w  #14,_exit_code
    rts
    unused
    dispatch

    setorg .op,256
opDC:
    opinit
    nop
    move.w  #15,_exit_code
    rts
    unused
    dispatch

; CMP abs,X
    setorg .op,256
opDD:
    opinit
    nop
    EA_absX

    move.b  d1,d6        ; must do a subtract without affecting d1
    sub.b   (a0),d6
    scc     d4
    ext.w   d6
    dispatch

; DEC abs,X
    setorg .op,256
opDE:
    opinit
    nop
    EA_absX

    move.b  (a0),d6
    subq.b  #1,d6
    ext.w   d6
    WriteService

; use opcode $DF as SIO entry point!

    setorg .op,256
opDF:
    opinit
    nop
    cmpi.b  #$DF,(a3)       ; if next byte is also $DF, it's SIO
    bne.s   .1

    move.w  #8,_exit_code
    rts

.1:
    unused
    dispatch

; CPX #
    setorg opDF,256
opE0:
    opinit
    nop
    move.b  d2,d6
    sub.b   (a3)+,d6
    scc     d4
    ext.w   d6
    dispatch

; SBC (zp,X)
    setorg .op,256
opE1:
    opinit
    bra.s   .dec

    EA_zpXind
    move.b  (a0),d0
    not.b   d4
    add.b   d4,d4
    subx.b  d0,d1
    scc     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch
.dec:
    EA_zpXind
    move.b  (a0),d0
    not.b   d4
    add.b   d4,d4     ; set X flag
    sbcd    d0,d1
    scc     d4
    dispatch

    setorg .op,256
opE2:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
opE3:
    opinit
    nop
    unused
    dispatch

; CPX zp
    setorg .op,256
opE4:
    opinit
    nop
    EA_zp
    move.b  d2,d6
    sub.b   (a0),d6
    scc     d4
    ext.w   d6
    dispatch

; SBC zp
    setorg .op,256
opE5:
    opinit
    bra.s   .dec

    EA_zp
    move.b  (a0),d0
    not.b   d4
    add.b   d4,d4
    subx.b  d0,d1
    scc     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch
.dec:
    EA_zp
    move.b  (a0),d0
    not.b   d4
    add.b   d4,d4     ; set X flag
    sbcd    d0,d1
    scc     d4
    dispatch

; INC zp
    setorg .op,256
opE6:
    opinit
    nop
    EA_zp
    addq.b  #1,(a0)
    move.b  (a0),d6
    ext.w   d6
    dispatch

    setorg .op,256
opE7:
    opinit
    nop
    unused
    dispatch

; INX
    setorg .op,256
opE8:
    opinit
    nop
    addq.b  #1,d2
    move.b  d2,d6
    ext.w   d6
    dispatch

; SBC #
    setorg .op,256
opE9:
    opinit
    bra.s   .dec

    move.b  (a3)+,d0
    not.b   d4
    add.b   d4,d4
    subx.b  d0,d1
    scc     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch
.dec:
    move.b  (a3)+,d0
    not.b   d4
    add.b   d4,d4     ; set X flag
    sbcd    d0,d1
    scc     d4
    dispatch

; NOP
    setorg .op,256
opEA:
    opinit
    nop
    dispatch

_rgwAtColors::
    dc.w        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
_rgwPalSav::
    dc.w        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
_rgwPal::
    dc.w        $777,$622,$476,$200,0,0,0,0,0,0,0,0,0,0,0,0

    setorg opEA,256
opEB:
    opinit
    nop
    unused
    dispatch

; CPX abs
    setorg .op,256
opEC:
    opinit
    nop
    EA_abs

    move.b  d2,d6
    sub.b   (a0),d6
    scc     d4
    ext.w   d6
    dispatch

; SBC abs
    setorg .op,256
opED:
    opinit
    bra.s   .dec

    EA_abs
    move.b  (a0),d0
    not.b   d4
    add.b   d4,d4
    subx.b  d0,d1
    scc     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch
.dec:
    EA_abs
    move.b  (a0),d0
    not.b   d4
    add.b   d4,d4     ; set X flag
    sbcd    d0,d1
    scc     d4
    dispatch

; INC abs
    setorg .op,256
opEE:
    opinit
    nop
    EA_abs

    move.b  (a0),d6
    addq.b  #1,d6
    ext.w   d6
    WriteService

    setorg .op,256
opEF:
    opinit
    nop
    unused
    dispatch

; BEQ
    setorg .op,256
opF0:
    opinit
    nop
    tst.b   d6
    bne.s   .nobeq
    move.b  (a3)+,d0   ; get relative offset
    ext.w   d0
    adda.w  d0,a3
    dispatch
.nobeq:
    addq.w  #1,a3
    dispatch

; SBC (zp),Y
    setorg .op,256
opF1:
    opinit
    bra.s   .dec

    EA_zpYind
    move.b  (a0),d0
    not.b   d4
    add.b   d4,d4
    subx.b  d0,d1
    scc     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch

.dec:
    EA_zpYind
    move.b  (a0),d0
    not.b   d4
    add.b   d4,d4     ; set X flag
    sbcd    d0,d1
    scc     d4
    dispatch

    setorg .op,256
opF2:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
opF3:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
opF4:
    opinit
    nop
    unused
    dispatch

; SBC zp,X
    setorg .op,256
opF5:
    opinit
    bra.s   .dec

    EA_zpX
    move.b  (a0),d0
    not.b   d4
    add.b   d4,d4
    subx.b  d0,d1
    scc     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch
.dec:
    EA_zpX
    move.b  (a0),d0
    not.b   d4
    add.b   d4,d4     ; set X flag
    sbcd    d0,d1
    scc     d4
    dispatch

; INC zp,X
    setorg .op,256
opF6:
    opinit
    nop
    EA_zpX
    addq.b  #1,(a0)
    move.b  (a0),d6
    ext.w   d6
    dispatch

    setorg .op,256
opF7:
    opinit
    nop
    unused
    dispatch

; SED
    setorg .op,256
opF8:
    opinit
    nop
    bset    #31,d6

    tst.w   fTrace(a4)
    bne.s   .tr

    lea     iDec(a4),a5
.tr:
    dispatch

; SBC abs,Y
    setorg .op,256
opF9:
    opinit
    bra.s   .dec

    EA_absY
    move.b  (a0),d0
    not.b   d4
    add.b   d4,d4
    subx.b  d0,d1
    scc     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch
.dec:
    EA_absY
    move.b  (a0),d0
    not.b   d4
    add.b   d4,d4     ; set X flag
    sbcd    d0,d1
    scc     d4
    dispatch

    setorg .op,256
opFA:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
opFB:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
opFC:
    opinit
    nop
    unused
    dispatch

; SBC abs,X
    setorg .op,256
opFD:
    opinit
    bra.s   .dec

    EA_absX
    move.b  (a0),d0
    not.b   d4
    add.b   d4,d4
    subx.b  d0,d1
    scc     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch

.dec:
    EA_absX
    move.b  (a0),d0
    not.b   d4
    add.b   d4,d4     ; set X flag
    sbcd    d0,d1
    scc     d4
    dispatch

; INC abs,X
    setorg .op,256
opFE:
    opinit
    nop
    EA_absX

    move.b  (a0),d6
    addq.b  #1,d6
    ext.w   d6
    WriteService
  

reboot:
    clr.w   fReboot(a4)

    move.w  #$1FF,D7        ; set SP = $1FF
    move.l  d7,a2

    move.w  #$C2AA,d7
    move.l  d7,a3           ; set PC = ($FFFC) = $C2AA

    ; clear all the hardware registers

    clr.b   nmien(a4)       ; NMI enable
    clr.b   irqen(a4)       ; IRQ enable
    clr.w   bShift          ; shift key status
    clr.w   bShifts
    clr.b   dmactl(a4)
    clr.w   dlisth(a4)
    clr.w   chbase(a4)

    move.w  fBasic(a4),d0
    seq     d0
    ori.w   #$FD,d0
    or.b    d0,porta(a4)    ; force BASIC ROM/RAM bit
    move.w  #$4000,d7
    move.l  d7,_qoldbank    ; force 130XE memory to 6502 address
    rts



    setorg opFE,256
opFF:
    opinit
    nop
    unused
    dispatch


DLI:
    subq.l  #1,a3
    bsr     push           ; save P and PC
    st      reg_I(a4)      ; turn on I flag

    lea     iDec(a4),a5
    tst.l   d6
    bmi.s   .dli

    addq.l  #iBin-iDec,a5

.dli:
     move.w  #$200,d7
     move.l  d7,a3
     jmp     $4C00(a5)      ; jmp($200)


; only NMI that we handle here is a VBI, since RESET and DLI are special
NMI:
    subq.l  #1,a3

; entry point from RTI (should never really happen)
NMI2:
    bsr     push           ; save P and PC
    st      reg_I(a4)      ; turn on I flag

    lea     iBin(a4),a5
    tst.l   d6
    bpl.s   .nmi

    lea     iDec(a4),a5

.nmi:
;    move.w  #$FFFA,d7
;    move.l  d7,a3
;    movep.w 1(a3),d7
;    move.b  (a3),d7
    move.w  #$C018,d7       ; hard code it
    move.l  d7,a3
    dispatch


; IRQ interrupt entry point
IRQ:
    subq.l  #1,a3

; entry point from RTI and CLI
IRQ2:
    lea     iBin(a4),a5
    tst.l   d6
    bpl.s   .irq

    lea     iDec(a4),a5

.irq: 
    move.b  bIRQ(a4),D0     ; get interrupt byte
    beq.s   .exit           ; exit if not IRQ????

    bsr     push            ; save P and PC
    st      reg_I(a4)       ; turn on I flag

;    move.w  #$FFFE,d7
;    move.l  d7,a3
;    movep.w 1(a3),d7
;    move.b  (a3),d7
    move.w  #$C02C,d7       ; hard code the vector due to bug in
    move.l  d7,a3           ; TOS 1.0 which messesup location $FFFF

.exit:
    dispatch

doBRK:
    addq.w  #1,a3
    bsr     push
    move.b  d1,(a2)
    subq.w  #1,a2
    st      reg_I(a4)
    st      reg_B(a4)
    move.w  #$206,d7
    move.l  d7,a3
    movep.w 1(a3),d7
    move.b  (a3),d7
    move.l  d7,a3
    dispatch

;
; this is the centre of the universe, pointed to by a4
;

; BRK
    setorg  opFF,256
op00::
    opinit
    nop
    bra     doBRK

    setorg  op00,32
    dc.b    'XF', $02, $50      ; file header for XCX file

    ; GTIA write locations
_hposp0::   dc.b 0
_hposp1::   dc.b 0
_hposp2::   dc.b 0
_hposp3::   dc.b 0
_hposm0::   dc.b 0
_hposm1::   dc.b 0
_hposm2::   dc.b 0
_hposm3::   dc.b 0
_sizep0::   dc.b 0
_sizep1::   dc.b 0
_sizep2::   dc.b 0
_sizep3::   dc.b 0
_sizem::    dc.b 0
_grafp0::   dc.b 0
_grafp1::   dc.b 0
_grafp2::   dc.b 0
_grafp3::   dc.b 0
_grafm::    dc.b 0
_colpm0::   dc.b 0
_colpm1::   dc.b 0
_colpm2::   dc.b 0
_colpm3::   dc.b 0

_colpf0::   dc.b 0
_colpf1::   dc.b 0
_colpf2::   dc.b 0
_colpf3::   dc.b 0
_colbk::    dc.b 0

colpf0 = _colpf0 - op00
colpf1 = _colpf1 - op00
colpf2 = _colpf2 - op00
colpf3 = _colpf3 - op00
colbk  = _colbk - op00

_prior::    dc.b 0
_vdelay::   dc.b 0
_gractl::   dc.b 0
_hitclr::   dc.b 0

_consol:: dc.b 0
consol = _consol - op00

    .even

    ; POKEY write locations
_audf1:: dc.b 0
_audc1:: dc.b 0
_audf2:: dc.b 0
_audc2:: dc.b 0
_audf3:: dc.b 0
_audc3:: dc.b 0
_audf4:: dc.b 0
_audc4:: dc.b 0
_audctl:: dc.b 0

audf1 = _audf1 - op00
audf2 = _audf2 - op00
audf3 = _audf3 - op00
audf4 = _audf4 - op00
audc1 = _audc1 - op00
audc2 = _audc2 - op00
audc3 = _audc3 - op00
audc4 = _audc4 - op00
audctl = _audctl - op00

_stimer::   dc.b 0
_skrest::   dc.b 0
_potgo::    dc.b 0
_D20C::     dc.b 0
_serout::   dc.b 0

_irqen:: dc.b 0
irqen = _irqen - op00

_skctl:: dc.b 0

    .even

    ; PIA write locations
_porta:: dc.b 0
_portb:: dc.b 0
_pactl:: dc.b 0
_pbctl:: dc.b 0
porta = _porta - op00
portb = _portb - op00
pactl = _pactl - op00
pbctl = _pbctl - op00

    ; ANTIC write locations
_dmactl::   dc.b 0
_chactl::   dc.b 0
dmactl = _dmactl - op00
chactl = _chactl - op00

    .even

_dlisth::   dc.b 0
_dlistl::   dc.b 0
dlisth = _dlisth - op00
dlistl = _dlistl - op00

_hscrol::   dc.b 0
_vscrol::   dc.b 0
_D406::     dc.b 0
_pmbase::   dc.w 0
_D408::     dc.b 0
hscrol = _hscrol - op00
vscrol = _vscrol - op00
pmbase = _pmbase - op00

    .even

_chbase:: dc.w 0
chbase = _chbase - op00

_wsync:: dc.b 0
wsync = _wsync - op00

_D40B::     dc.b 0
_D40C::     dc.b 0
_D40D::     dc.b 0
_nmien:: dc.b 0
_nmires:: dc.b 0
nmien = _nmien - op00
nmires = _nmires - op00

    .even

_reg_PC:: dc.w    0
_reg_SP:: dc.w    $1FF
_reg_A::  dc.w    0
_reg_X::  dc.w    0
_reg_Y::  dc.w    0
_reg_P::  dc.w    0     ; accessed as a byte!!
_reg_C::  dc.w    0
_reg_V::  dc.w    0

_reg_I::  dc.w    0     ; accessed as a byte!
_reg_B::  dc.w    0     ; accessed as a byte!

_reg_DNZ::
_reg_D::  dc.w    0     ; these must be defined together!!
_reg_NZ::
_reg_N::  dc.b    0
_reg_Z::  dc.b    0

reg_PC = _reg_PC - op00
reg_SP = _reg_SP - op00
reg_A = _reg_A - op00
reg_X = _reg_X - op00
reg_Y = _reg_Y - op00
reg_P = _reg_P - op00
reg_C = _reg_C - op00
reg_V = _reg_V - op00
reg_I = _reg_I - op00
reg_B = _reg_B - op00
reg_DNZ = _reg_DNZ - op00
reg_D = _reg_D - op00
reg_NZ = _reg_NZ - op00
reg_N = _reg_N - op00
reg_Z = _reg_Z - op00


; radio button options
;
_fFastFP:: dc.w 0           ; Fastchip FP option
_fXCD:: dc.w 0              ; Xformer Cable option with D:
_fXCP:: dc.w 0              ; Xformer Cable option with P:
_fBasic:: dc.w 0            ; Atari BASIC option
_mdFont:: dc.w 0            ; 0 - 7
_uAtRAM:: dc.w 0            ; 40K or 48K
_uAtMin:: dc.w 0            ; minimum screen byte

fFastFP = _fFastFP - op00
fXCD = _fXCD - op00
fXCP = _fXCP - op00
fBasic = _fBasic - op00
mdFont = _mdFont - op00
uAtRAM = _uAtRAM - op00
uAtMin = _uAtMin - op00

;  anytime we must force a reboot, this will disable Continue button
_fReboot:: dc.w 1
fReboot = _fReboot - op00

_fTrace::
    dc.w    0       ; TRUE if trace mode on
fTrace = _fTrace - op00

_exit_code::
    dc.w    0

    .even

_bNMI::
    dc.b 0
_bIRQ::
    dc.b 0
bNMI = _bNMI - op00
bIRQ = _bIRQ - op00

_fRedraw::
    dc.b 0
fRedraw = _fRedraw - op00

    .even


; ORA (zp,X)
    setorg  op00,256
op01:
    opinit
    nop
    EA_zpXind

    or.b    (a0),d1      ; ORA with accumualtor
    move.b  d1,d6
    ext.w   d6
    dispatch                ; and go do another opcode

_execute::
    movem.l d0-d7/a0-a6,-(sp)
    lea     op00(PC),a4     ; A4 is the centre of the universe

    lea     _exit_code(pc),a1
    clr.w   (a1)
    tst.w   fTrace(a4)
    bne.s   .tr

    bsr     int_on
    addq.w  #1,(a1)

.tr:
    move.l  lMemory(a4),d7
    move.l  d7,a6
    lea     reg_PC(a4),a1
    move.w  (a1)+,d7
    move.l  d7,a3
    move.w  (a1)+,d7
    move.l  d7,a2
    move.w  (a1)+,d7
    move.l  d7,d1
    move.w  (a1)+,d7
    move.l  d7,d2
    move.w  (a1)+,d7
    move.l  d7,d3
    addq.w  #2,a1
    move.w  (a1)+,d7
    move.l  d7,d4
    move.w  (a1)+,d7
    move.l  d7,d5
    move.l  reg_DNZ(a4),d6
    clr.w   d7
    move.l  d7,d0
    move.l  lWStat(a4),a1

    tst.w   fTrace(a4)      ; won't force reboot in trace mode
    bne.s   exec

    tst.w   fReboot(a4)
    beq.s   exec

    bsr     reboot

exec:
; clear all interrupts
    clr.b   bNMI(a4)
    clr.b   bIRQ(a4)

    move.w  764,d7
    move.l  d7,a0
    st      (a0)        ; Poke 764,255 to prevent repeating keys
    move.w  #$D20F,d7
    move.l  d7,a0
    bset    #2,(A0)     ; key is not pressed
    bset    #2,$10(A0)  ; key is not pressed

; the dispatch routine is not called directly, since we have to JSR
    move.l  a4,a5           ; A5 is A4 + offset to opcode entry point

    ; for tracing purposes we use a0 (so A4 can be pointed to RTS)
    lea     iDec(a4),a0     ; assume decimal mode
    tst.l   d6
    bmi.s   .go

    addq.l  #iBin-iDec,a0   ; if binary, skip over to iBin

.go:
    tst.w   fTrace(a4)      ; if trace is on, A5 is already set
    bne.s   .go2

    move.l  a0,a5           ; not tracing, add offset to a5

.go2:
    move.b  (a3)+,$+6-op00(a4)  ; dispatcher
    jsr     0(a0)

    ; save 6502 context
    move.w  d1,reg_A(a4)
    move.w  d2,reg_X(a4)
    move.w  d3,reg_Y(a4)
    move.w  d4,reg_C(a4)
    move.w  d5,reg_V(a4)
    move.l  d6,reg_DNZ(a4)

    move.w  a2,reg_SP(a4)   ; set SP

    subq.l  #1,a3           ; decrement PC so that we can re-execute opcode
    move.w  a3,reg_PC(a4)

    bsr     ST_to_P         ; save status register

    tst.w   fTrace(a4)
    bne.s   .tr

    bsr     int_off
;    nop

.tr:
    movem.l (sp)+,d0-d7/a0-a6
    rts

    setorg  op01,256
op02:
    opinit
    nop
    unused
    dispatch

;foo:
;    dc.w    0

AtariVBI::
    ori.w   #$0700,sr
    movem.l d0/a0,-(sp)
    bsr     randomize

;    tst.b   reg_I(a4)   ; are interrupts enabled?
;    bne.s   .vbi        ; nope, so no VBI

    btst    #6,nmien(a4)
    beq.s   .vbi

    btst    #0,portb(a4)    ; if XL ROM disabled, don't even try it!
    beq.s   .vbi

    move.l  d7,d0
    move.w  #$D40F,d0
    move.l  d0,a0
    move.b  #$5F,(a0)   ; Poke $D01F,($1F | $40)

    lea     iVBI(a4),a5 ; force interrupt
    st      bNMI(a4)    ; no need to mask a bit since only one type of NMI
    
.vbi:
    lea     $FFFF8800,a0
    move.b  #10,(a0)
    clr.b   2(a0)        ; set C volume = 0 to kill keyclick noise

    movem.l (sp)+,d0/a0
;    move.l  VBIsave,-(sp)
;    rts
    rte

new_200::
    ori.w   #$0700,sr
    bsr     randomize

    tst.b   fRedraw(a4)
    beq.s   .1

    subq.b  #1,fRedraw(a4)
    bne.s   .1

    movem.l d0-d7/a0-a3/a6,-(sp)
    jsr     _newDL
    jsr     _Redraw
    move.l  _lMemory(PC),d0
    move.w  764,d0
    move.l  d0,a0
    st      (a0)        ; Poke 764,255 to prevent repeating keys
    move.w  #$D20F,d0
    move.l  d0,a0
    bset    #2,(A0)     ; key is not pressed
    bset    #2,$10(A0)  ; key is not pressed
    movem.l (sp)+,d0-d7/a0-a3/a6

.1:
    bclr    #5,$FFFFFA11
    rte

old_200:
    dc.l    0

oldKey:
    dc.l    0

VBIsave:
    dc.l    0


    setorg  op02,256
op03:
    opinit
    nop
    unused
    dispatch

int_on::
    move.l  a1,-(sp)

    ; get old VBI vector
    move.l  $0070,VBIsave
    move.l  #AtariVBI,$0070

    ; get old 200 Hz vector
    move.l  $114,old_200
    lea     new_200(pc),a1
    move.l  a1,$114

    ; get old keyboard vector
    move.l  $118,oldKey
    lea     KeyPatch(pc),a1
    move.l  a1,$118

    movem.l (sp)+,a1
    rts

int_off::
    move.l  VBIsave,$0070       ; recover the old VBI vector
    move.l  old_200,$114        ; recover the old 200Hz vector
    move.l  oldKey,$118         ; recover the old keyboard vector
    rts

_m_off::
    movem.l d0-d2/a0-a2,-(sp)

    ; turn off mouse     = Bconout(4,$12)
    move.w  #$12,-(A7)
    move.w  #4,-(A7)
    move.w  #3,-(A7)
    trap    #13
    addq.l  #6,A7

    ; turn on joysticks = Bconout(4,$14)
    move.w  #$14,-(A7)
    move.w  #4,-(A7)
    move.w  #3,-(A7)
    trap    #13
    addq.l  #6,A7

    movem.l (sp)+,d0-d2/a0-a2
    rts

_m_on::
    movem.l d0-d2/a0-a2,-(sp)

    ; turn off joysticks = Bconout(4,$1A)
    move.w  #$1a,-(A7)
    move.w  #4,-(A7)
    move.w  #3,-(A7)
    trap    #13
    addq.l  #6,A7
    
    ; turn on mouse      = Bconout(4,$8)
    move.w  #$8,-(A7)
    move.w  #4,-(A7)
    move.w  #3,-(A7)
    trap    #13
    addq.l  #6,A7

    movem.l (sp)+,d0-d2/a0-a2
    rts

    setorg  op03,256
op04:
    opinit
    nop
    unused
    dispatch

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Keyboard handler to map the ST scan code to an 8 bit internal scan code.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; some safety room
    dc.w    0

Joy0:
    dc.b    0
Joy1:
    dc.b    0
semaJoy:
    dc.w    0

KeyPatch:
    movem.l a0-a1/a4/d0-d1,-(sp)

    lea     op00(pc),a4

    move.w  #$FC00,a0
    move.b  (a0),d0
    btst    #7,d0
    beq     Lkpexit

    clr.w   D0
    move.b  2(a0),d0

;    move.l  _lScr(PC),a0
;    adda.w  #8000,a0
;    move.b  d0,(a0)
;    move.b  d0,80(a0)
;    move.b  d0,160(a0)
;    move.b  d0,240(a0)

    tst.w   semaJoy
    bne.s   LgetJoy

    cmpi.b  #$F6,D0            ; check for a keypress
    bcs     Lkp1

    cmpi.b  #$FE,D0            ; if not joystick event, get out
    bcs     Lkpexit

    not.b   D0
    andi.w  #$01,D0
    addq.b  #1,D0
    move.w  D0,semaJoy          ; set joystick semaphore
    bra     Lkpexit             ; and go exit so next interrupt can occur

LgetJoy:
    not.w   d0
    move.w  semaJoy(pc),D1
    lea     Joy0(pc),A1
    move.b  D0,-1(A1,D1.w)      ; store joystick packet
    clr.w   semaJoy

    move.l  _lMemory(pc),d0
    move.w  #$D300,d0
    move.l  d0,a0               ; $D300
    move.w  #$D010,d0
    move.l  d0,a1               ; $D010

    move.b  Joy0(pc),d0
    move.b  d0,d1
    andi.b  #$0F,d0
    move.b  d0,(a0)
    move.b  d0,$10(a0)
    move.b  d0,$20(a0)
    lsr.b   #7,d1
    move.b  d1,$10(a1)
    move.b  d1,$20(a1)
    move.b  d1,(a1)+

    move.b  Joy1(pc),d0
    move.b  d0,d1
    lsl.w   #4,d0
    andi.b  #$F0,d0
    or.b    d0,(a0)
    or.b    d0,$10(a0)
    or.b    d0,$20(a0)
    lsl.w   #4,d1
    lsr.b   #7,d1
    move.b  d1,(a1)
    move.b  d1,$10(a1)
    move.b  d1,$20(a1)
    
    bra     Lkpexit

    
; ORA zp
    setorg  op04,256
op05:
    opinit
    nop
    EA_zp
    or.b    (a0),d1       ; ORA with accumualtor
    move.b  d1,d6
    ext.w   d6
    dispatch

Lkp1:
    cmpi.b  #$3F,D0
    bne.s   Lkp2

    clr.w   _exit_code
    move.l  a4,a5               ; hit F5, so exit
    bra     Lkpexit
        
Lkp2:
    cmpi.b  #$44,D0            ; F10 key is SYSTEM RESET (always enabled)
    bne     Lkp3

    move.w  #4,_exit_code
    
    tst.b   bShifts             ; if shift pressed, also hard reset
    beq.s   .1

    move.w  #5,_exit_code
    
.1:
    move.l  a4,a5               ; force exit
    bra     Lkpexit

Lkp3:
    cmpi.b  #$61,D0            ; UNDO key is BREAK
    bne     Lkp10

    btst    #BIT_BREAK,irqen(a4)   ; check if BREAK is enabled
    beq     Lkpexit             ; exit if not

    move.l  _lMemory(pc),d0
    move.w  #$D20E,d0
    move.l  d0,a0
    bclr    #BIT_BREAK,(a0)   ; set a IRQ interrupt for the key
;    bne     Lkpexit              ; exit if already set

    bset    #BIT_BREAK,bIRQ(a4)           ; set a IRQ interrupt for the BREAK key

    tst.b   reg_I(a4)
    bne     Lkpexit             ; if I bit set...

    lea     iIRQ(a4),a5

    bra     Lkpexit

Lkp10:
    move.l  _lMemory(pc),D1
    move.w  #$D01F,D1
    move.l  D1,A0               ; A0 = pointer to mem[$D01F]

    cmpi.b  #$C1,D0            ; F7 is START
    bne.s     Lkp11

    ori.b   #$01,(A0)
    bra     Lkpexit  
    
Lkp11:
    cmpi.b  #$41,D0
    bne.s     Lkp12

    andi.b  #~$01,(A0)
    bra     Lkpexit
        
Lkp12:
    cmpi.b  #$C2,D0            ; F8 is SELECT
    bne.s     Lkp13
    
    ori.b   #$02,(A0)
    bra     Lkpexit  
    
Lkp13:
    cmpi.b  #$42,D0
    bne.s     Lkp14
    
    andi.b  #~$02,(A0)
    bra     Lkpexit
        
Lkp14:
    cmpi.b  #$C3,D0            ; F9 is OPTION
    bne     Lkp15
    
    ori.b   #$04,(A0)
    bra     Lkpexit  
    
Lkp15:
    cmpi.b  #$43,D0
    bne     Lkp20

    andi.b  #~$04,(A0)
    bra     Lkpexit



; ASL zp
    setorg  op05,256
op06:
    opinit
    nop
    EA_zp
    move.b  (a0),d6    ; must do in register as memory shifts word
    add.b   d6,d6
    scs     d4
    ext.w   d6
    move.b  d6,(a0)
    dispatch

; Check control and shift keys   
; The byte bShift contains   b1 = control  b0 = shift key
; The byte bShifts contains  b1 = right shift  b0 = left shift
Lkp20:
    lea     bShift(PC),A0
    cmpi.b  #$1D,D0            ; Control key
    bne.s     Lkp21

    bset    #1,(A0)
    bra     Lkpexit
    
Lkp21:
    cmpi.b  #$9D,D0            ; Control key up
    bne.s     Lkp22

    bclr    #1,(A0)
    bra     Lkpexit
    
Lkp22:
    lea     bShifts(PC),A0
    cmpi.b  #$2A,D0            ; left shift down
    bne.s     Lkp23
    
    bset    #0,(A0)
    bra.s     LShifts

Lkp23:
    cmpi.b  #$AA,D0            ; left shift up
    bne.s     Lkp24
    
    bclr    #0,(A0)
    bra.s     LShifts

Lkp24:
    cmpi.b  #$36,D0            ; right shift down
    bne.s     Lkp25
    
    bset    #1,(A0)
    bra.s     LShifts

Lkp25:
    cmpi.b  #$B6,D0            ; right shift down
    bne     Lkp30
    
    bclr    #1,(A0)

LShifts:
    move.b  (A0),D0             ; get shift keys status
    lea     bShift(PC),A0
    tst.b   D0                  ; any shift key pressed
    bne.s   lShiftDown
    bclr    #0,(A0)             ; no, clear shift bit in bShift
    bra.s     lSh2
lShiftDown:
    bset    #0,(A0)             ; yes, set shift but

lSh2:
    bra     Lkpexit
    
    setorg  op06,256
op07:
    opinit
    nop
    unused
    dispatch

Lkp30:
    move.b  #$FF,D1            ; assume scan code will be $FF
    btst    #7,D0               ; if up stroke, definately $FF
    bne.s   lStoreKey
    
    andi.w  #$7F,D0                    ; else key pressed, look up in table
    add.w   D0,D0
    add.w   D0,D0
    or.b    bShift(PC),D0
    lea     mpSTto8,A0
    move.b  0(A0,D0.w),D1
    
lStoreKey:
    move.l  _lMemory(pc),D0
    move.w  #$D209,D0
    move.l  D0,A0
    move.b  D1,(A0)                     ; and store scan code
    move.b  d1,$10(a0)
    move.b  d1,$20(a0)
    move.b  d1,$40(a0)
    move.b  d1,$80(a0)

; set bits in $D20F
    move.w  #$D20F,D0
    move.l  D0,A0
    move.b  bShift(PC),D0
    btst    #0,D0
    beq.s   lShiftUp
    bclr    #3,(A0)         ; shift key still pressed
    bclr    #3,$10(A0)
    bra     lSK2
lShiftUp:
    bset    #3,(A0)

lSK2:
    cmpi.b  #$FF,D1
    beq.s   lKeyUp     
    bclr    #2,(A0)         ; key still pressed
    bclr    #2,$10(A0)
    bclr    #2,$20(A0)
    bclr    #2,$40(A0)
    bclr    #2,$80(A0)

; if key just pressed, force IRQ
;    btst    #BIT_KEY,irqen(a4)   ; check if keyboard int enabled
;    beq     lSK3                ; exit if not

    bclr    #BIT_KEY,-1(a0)   ; set a IRQ interrupt for the key
;    bne     lSK3                ; exit if already set

    bset    #BIT_KEY,bIRQ(a4)

    tst.b   reg_I(a4)
    bne.s     lSK3                ; if I bit set...

    lea     iIRQ(a4),a5

    bra.s     lSK3

lKeyUp:
    bset    #2,(A0)

lSK3:

Lkpexit:
    bclr     #6,$FFFFFA11
    movem.l  (SP)+,a0-a1/a4/d0-d1
    rte

bShift:
    dc.w    0           ; bit 0 = any shift    bit 1 = control
bShifts:
    dc.w    0           ; bit 0 = left shift   bit 1 = right shift

; PHP - do a 68000 to 6502 flag conversion, like in the init code
    setorg  op07,256
op08:
    opinit
    nop
    bsr.s   ST_to_P
    move.b  reg_P(a4),(a2)
    subq.l  #1,a2
    dispatch

; convert CCR register BDIXNZVC to P register NV_BDIZC
ST_to_P:
    move.w  d6,-(sp)
    move.b  reg_B(a4),d7
    andi.w  #BBIT,d7 
    tst.l   d6
    smi     d0
    andi.w  #DBIT,d0
    or.b    d0,d7
    move.b  reg_I(a4),d0
    andi.w  #IBIT,d0
    or.b    d0,d7
    move.b  d5,d0
    andi.w  #VBIT,d0
    or.b    d0,d7
    move.b  d4,d0
    andi.w  #CBIT,d0
    or.b    d0,d7
    move.b  d6,d0
    seq     d0  
    andi.b  #ZBIT,d0
    or.b    d0,d7
    lsr.w   #1,d6
    andi.b  #$80,d6
    or.b    d6,d7
    ori.b   #$20,d7 
    move.b  d7,reg_P(a4)
    move.w  (sp)+,d6
    rts

; push PC and P on stack to simulate interrupt
push:
    subq.l  #3,a2
    move.l  a3,d7
    move.b  d7,2(a2)        ; push PClo
    lsr.w   #8,d7
    move.b  d7,3(a2)        ; push PChi
    bsr.s   ST_to_P
    move.b  reg_P(a4),1(a2)   ; push P
    rts


; ORA #
    setorg op08,256
op09:
    opinit
    nop
    or.b    (a3)+,d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; heap pointers
;
_lWStat:: dc.l 0            ; 64K block of write status bytes
_lMemory:: dc.l 0           ; 64K normal address space of 6502, 64K boundary 

lWStat = _lWStat - op00
lMemory = _lMemory - op00

_lEmul:: dc.l op00          ; pointer to op00
_fIsMono:: dc.w 0           ; mono or color
_lScr:: dc.l 0

lEmul = _lEmul - op00
fIsMono = _fIsMono - op00
lScr = _lScr - op00

;  pointers to the 2 system fonts
_lFont8:: dc.l 0
_lFont16:: dc.l 0

; ASL A
    setorg op09,256
op0A:
    opinit
    nop
    add.b   d1,d1
    scs     d4
    move.b  d1,d6
    ext.w   d6
    dispatch

    setorg .op,256
op0B:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op0C:
    opinit
    nop
    unused
    dispatch

; ORA abs
    setorg .op,256
op0D:
    opinit
    nop
    EA_abs

    or.b    (a0),d1      ; ORA with accumualtor
    move.b  d1,d6
    ext.w   d6
    dispatch                ; and go do another opcode

; ASL abs
    setorg .op,256
op0E:
    opinit
    nop
    EA_abs

    move.b  (a0),d6   ; must do in register as memory shifts word
    add.b   d6,d6
    scs     d4
    ext.w   d6
    WriteService

    setorg .op,256
op0F:
    opinit
    nop
    unused
    dispatch

; BPL
    setorg .op,256
op10:
    opinit
    nop
    tst.w   d6
    bmi.s   .nobpl
    move.b  (a3)+,d7
    ext.w   d7
    adda.w  d7,a3
    dispatch
.nobpl:
    addq.w  #1,a3
    dispatch

; ORA (zp),Y
    setorg .op,256
op11:
    opinit
    nop
    EA_zpYind

    or.b    (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

    setorg .op,256
op12:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op13:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op14:
    opinit
    nop
    unused
    dispatch

; ORA zp,X
    setorg .op,256
op15:
    opinit
    nop
    EA_zpX
    or.b    (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; ASL zp,X
    setorg .op,256
op16:
    opinit
    nop
    EA_zpX
    move.b  (a0),d6     ; must do in register as memory shifts word
    add.b   d6,d6
    scs     d4
    ext.w   d6
    move.b  d6,(a0)
    dispatch

    setorg .op,256
op17:
    opinit
    nop
    unused
    dispatch
    
; CLC
    setorg .op,256
op18:
    opinit
    nop
    clr.b    d4
    dispatch

; ORA abs,Y
    setorg .op,256
op19:
    opinit
    nop
    EA_absY

    or.b    (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

    setorg .op,256
op1A:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op1B:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op1C:
    opinit
    nop
    unused
    dispatch

; ORA abs,X
    setorg .op,256
op1D:
    opinit
    nop
    EA_absX

    or.b    (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; ASL abs,X
    setorg .op,256
op1E:
    opinit
    nop
    EA_absX

    move.b  (a0),d6   ; must do in register as memory shifts word
    add.b   d6,d6
    scs     d4
    ext.w   d6
    WriteService

    setorg .op,256
op1F:
    opinit
    nop
    unused
    dispatch

; JSR abs
    setorg .op,256
op20:
    opinit
    nop
    subq.l  #2,a2
    move.w  a3,d7
    addq.w  #1,d7
    move.b  d7,1(a2)    ; push PClo
    move.w  d7,-(sp)
    move.b  (sp)+,2(a2)   ; push PChi
    movep.w 1(a3),d7
    move.b  (a3),d7
    move.l  d7,a3

    dispatch

; AND (zp,X)
    setorg .op,256
op21:
    opinit
    nop
    EA_zpXind

    and.b   (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

    setorg .op,256
op22:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op23:
    opinit
    nop
    unused
    dispatch

; BIT zp
    setorg .op,256
op24:
    opinit
    nop
    EA_zp
    move.b  (a0),d6
    ext.w   d6      ; N bit
    btst    #6,d6
    sne     d5      ; V bit
    and.b   d1,d6   ; Z bit
    dispatch

; AND zp
    setorg .op,256
op25:
    opinit
    nop
    EA_zp
    and.b   (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; ROL zp
    setorg .op,256
op26:
    opinit
    nop
    EA_zp
    move.b  (a0),d6     ; get byte
    add.b   d4,d4
    addx.b  d6,d6       ; shift it
    scs     d4
    ext.w   d6
    move.b  d6,(a0)   ; save in memory
    dispatch

    setorg .op,256
op27:
    opinit
    nop
    unused 
    dispatch

; PLP
    setorg .op,256
op28:
    opinit
    nop
    addq.l  #1,a2
    move.b  (a2),reg_P(a4)
    bsr.s   P_to_ST
    dispatch

; convert P register NV_BDIZC to CCR register BDIXNZVC 
P_to_ST:
    move.b  reg_P(a4),d0
    btst    #4,d0
    sne     reg_B(a4)   ; set B
    btst    #3,d0
    sne     d6
    ext.w   d6
    move.w  d6,reg_D(a4)
    ext.l   d6          ; set D
    move.b  d0,d6
    ext.w   d6          ; set N
    btst    #2,d0  
    sne     reg_I(a4)   ; set I
    btst    #6,d0  
    sne     d5          ; set V
    btst    #0,d0  
    sne     d4          ; set C
    andi.b  #ZBIT,d0
    seq     d6          ; set Z

    tst.w   fTrace(a4)
    bne.s   .tr

    lea     iBin(a4),a5
    tst.l   d6
    bpl.s   .tr

    lea     iDec(a4),a5
.tr:
    rts

; AND #
    setorg op28,256
op29:
    opinit
    nop
    and.b   (a3)+,d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; ROL A
    setorg .op,256
op2A:
    opinit
    nop
    add.b   d4,d4
    addx.b  d1,d1
    scs     d4
    move.b  d1,d6
    ext.w   d6
    dispatch

    setorg .op,256
op2B:
    opinit
    nop
    unused
    dispatch

; BIT abs
    setorg .op,256
op2C:
    opinit
    nop
    EA_abs

    move.b  (a0),d6
    ext.w   d6      ; N bit
    btst    #6,d6
    sne     d5      ; V bit
    and.b   d1,d6   ; Z bit
    dispatch

; AND abs
    setorg .op,256
op2D:
    opinit
    nop
    EA_abs

    and.b   (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; ROL abs
    setorg .op,256
op2E:
    opinit
    nop
    EA_abs

    move.b  (a0),d6     ; get byte
    add.b   d4,d4
    addx.b  d6,d6       ; shift it
    scs     d4
    ext.w   d6
    WriteService

    setorg .op,256
op2F:
    opinit
    nop
    unused
    dispatch

; BMI
    setorg .op,256
op30:
    opinit
    nop
    tst.w   d6
    bpl.s   .nobmi
    move.b  (a3)+,d7
    ext.w   d7
    adda.w  d7,a3
    dispatch
.nobmi:
    addq.w  #1,a3
    dispatch

; AND (zp),Y
    setorg .op,256
op31:
    opinit
    nop
    EA_zpYind

    and.b   (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

    setorg .op,256
op32:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op33:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op34:
    opinit
    nop
    unused
    dispatch

; AND zp,X
    setorg .op,256
op35:
    opinit
    nop
    EA_zpX
    and.b   (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; ROL zp,X
    setorg .op,256
op36:
    opinit
    nop
    EA_zpX
    move.b  (a0),d6     ; get byte
    add.b   d4,d4
    addx.b  d6,d6       ; shift it
    scs     d4
    ext.w   d6
    move.b  d6,(a0)       ; save in memory
    dispatch

    setorg .op,256
op37:
    opinit
    nop
    unused
    dispatch

; SEC
    setorg .op,256
op38:
    opinit
    nop
    st      d4
    dispatch

; AND abs,Y
    setorg .op,256
op39:
    opinit
    nop
    EA_absY

    and.b   (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

    setorg .op,256
op3A:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op3B:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op3C:
    opinit
    nop
    unused
    dispatch

; AND abs,X
    setorg .op,256
op3D:
    opinit
    nop
    EA_absX

    and.b   (a0),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; ROL abs,X
    setorg .op,256
op3E:
    opinit
    nop
    EA_absX

    move.b  (a0),d6     ; get byte
    add.b   d4,d4
    addx.b  d6,d6       ; shift it
    scs     d4
    ext.w   d6
    WriteService

    setorg .op,256
op3F:
    opinit
    nop
    unused
    dispatch

; RTI
    setorg .op,256
op40:
    opinit
    nop
    movep.w 3(a2),d7        ; pull PChi
    move.b  2(a2),d7        ; pull PClo
    move.l  d7,a3           ; do NOT increment PC for an RTI
    move.b  1(a2),reg_P(a4)   ; pull processor
    bsr     P_to_ST
    addq.l  #3,a2

    tst.b   bNMI(a4)        ; check if NMI pending
    bne     NMI2

    tst.b   reg_I(a4)
    bne.s   .1

    tst.b   bIRQ(a4)        ; check if other interrupts pending
    bne     IRQ2

.1:
    dispatch


; EOR (zp,X)
    setorg .op,256
op41:
    opinit
    nop
    EA_zpXind

    move.b  (a0),d0
    eor.b   d0,d1
    move.b  d1,d6
    ext.w   d6
    dispatch

    setorg .op,256
op42:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op43:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op44:
    opinit
    nop
    unused
    dispatch

; EOR zp
    setorg .op,256
op45:
    opinit
    nop
    EA_zp
    move.b  (a0),d0
    eor.b   d0,d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; LSR zp
    setorg .op,256
op46:
    opinit
    nop
    EA_zp
    move.b   (a0),d6
    lsr.b    #1,d6
    scs     d4
    ext.w   d6
    move.b   d6,(a0)
    dispatch

    setorg .op,256
op47:
    opinit
    nop
    unused
    dispatch

; PHA
    setorg .op,256
op48:
    opinit
    nop
    move.b  d1,(a2)      ; push acc
    subq.l  #1,a2
    dispatch

; EOR #
    setorg .op,256
op49:
    opinit
    nop
    move.b  (a3)+,d0
    eor.b   d0,d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; LSR A
    setorg .op,256
op4A:
    opinit
    nop
    lsr.b   #1,d1
    scs     d4
    move.b  d1,d6
    ext.w   d6
    dispatch

    setorg .op,256
op4B:
    opinit
    nop
    unused
    dispatch

; JMP abs
    setorg .op,256
op4C:
    opinit
    nop
    movep.w 1(a3),d7
    move.b  (a3),d7
    move.l  d7,a3
    dispatch

; EOR abs
    setorg .op,256
op4D:
    opinit
    nop
    EA_abs

    move.b  (a0),d0
    eor.b   d0,d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; LSR abs
    setorg .op,256
op4E:
    opinit
    nop
    EA_abs

    move.b   (a0),d6
    lsr.b    #1,d6
    scs     d4
    ext.w   d6
    WriteService

    setorg .op,256
op4F:
    opinit
    nop
    unused
    dispatch

; BVC
    setorg .op,256
op50:
    opinit
    nop
    tst.b   d5
    bne.s   .nobvc
    move.b  (a3)+,d7
    ext.w   d7
    adda.w  d7,a3
    dispatch
.nobvc:
    addq.w  #1,a3
    dispatch

; EOR (zp),Y
    setorg .op,256
op51:
    opinit
    nop
    EA_zpYind

    move.b  (a0),d0
    eor.b   d0,d1
    move.b  d1,d6
    ext.w   d6
    dispatch

    setorg .op,256
op52:
    opinit
    nop

    ; R: OPEN
    move.w  #1,d3
    move.w  d3,d6
    bra     _rts

    setorg .op,256
op53:
    opinit
    nop

    ; R: CLOSE
    move.w  #1,d3
    move.w  d3,d6
    bra     _rts

    setorg .op,256
op54:
    opinit
    nop

    ; R: GET
    move.w  sr,-(sp)
;    ori.w   #$0700,sr
    movem.l d1-d7/a1-a3,-(sp)
    Bconstat #AUX
    tst.b   d0
    beq.s   .exit_no

    Bconin  #AUX

.exit_ok:
    movem.l (sp)+,d1-d7/a1-a3
    move.w  (sp)+,sr
    move.b  d0,d1
    move.w  #1,d3
    move.w  d3,d6
    bra     _rts

.exit_no:
    movem.l (sp)+,d1-d7/a1-a3
    move.w  (sp)+,sr
    move.w  #136,d3
    move.b  d3,d6
    ext.w   d6
    bra     _rts

; EOR zp,X
    setorg .op,256
op55:
    opinit
    nop
    EA_zpX
    move.b  (a0),d0
    eor.b   d0,d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; LSR zp,X
    setorg .op,256
op56:
    opinit
    nop
    EA_zpX
    move.b   (a0),d6
    lsr.b    #1,d6
    scs     d4
    ext.w   d6
    move.b   d6,(a0)
    dispatch

    setorg .op,256
op57:
    opinit
    nop
    unused
    dispatch

; CLI
    setorg .op,256
op58:
    opinit
    nop

    clr.b   reg_I(a4)

    tst.b   bIRQ(a4)        ; check if other interrupts pending
    bne     IRQ2

    dispatch

; EOR abs,Y
    setorg .op,256
op59:
    opinit
    nop
    EA_absY

    move.b  (a0),d0
    eor.b   d0,d1
    move.b  d1,d6
    ext.w   d6
    dispatch

    setorg .op,256
op5A:
    opinit
    nop

    ; R: PUT
    move.w  sr,-(sp)
;    ori.w   #$0700,sr
    movem.l d1-d7/a1-a3,-(sp)
    move.w  d1,-(sp)
    Bcostat  #AUX
    tst.b   d0
    beq.s   .exit_no

    move.w  (sp)+,d1
    Bconout  #AUX,d1

.exit_ok:
    movem.l (sp)+,d1-d7/a1-a3
    move.w  (sp)+,sr
    move.w  #1,d3
    move.w  d3,d6
    bra     _rts

.exit_no:
    move.w  (sp)+,d1
    movem.l (sp)+,d1-d7/a1-a3
    move.w  (sp)+,sr
    move.w  #136,d3
    move.b  d3,d6
    ext.w   d6
    bra     _rts

    setorg .op,256
op5B:
    opinit
    nop

    ; R: STATUS
    move.w  sr,-(sp)
;    ori.w   #$0700,sr
    movem.l d1-d7/a1-a3,-(sp)
    Bconstat #AUX
    movem.l (sp)+,d1-d7/a1-a3
    move.w  (sp)+,sr
    tst.b   d0
    sne     d0
    andi.b  #1,d0
    move.w  #747,d7
    move.l  d7,a0
    move.b  d0,(a0)+    ; store 0 or 1 in 747
    clr.b   (a0)+       ; clear 748

    tst.b   d0
    bne     .ok
    move.w  #136,d3     ; Y = 136
    move.b  d3,d6
    ext.w   d6
    bra     _rts
.ok:
    move.w  #1,d3       ; Y = 1
    move.w  d3,d6
    bra     _rts

    setorg .op,256
op5C:
    opinit
    nop

    ; R: SPECIAL
    move.b  #146,d3
    move.b  d3,d6
    ext.w   d6
    bra     _rts


; EOR abs,X
    setorg .op,256
op5D:
    opinit
    nop
    EA_absX

    move.b  (a0),d0
    eor.b   d0,d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; LSR abs,X
    setorg .op,256
op5E:
    opinit
    nop
    EA_absX

    move.b   (a0),d6
    lsr.b    #1,d6
    scs     d4
    ext.w   d6
    WriteService

    setorg .op,256
op5F:
    opinit
    nop
    unused
    dispatch

; RTS
    setorg .op,256
op60:
    opinit
    nop
_rts:
    move.l  a2,d7
    addq.b  #2,d7
    movea.l d7,a2     ; increment SP by wrapping around
    movep.w 0(a2),d7  ; pull PChi
    move.b  -1(a2),d7  ; pull PClo
    addq.w  #1,d7
    move.l  d7,a3
    dispatch

; ADC (zp,X)
    setorg op60,256
op61:
    opinit
    bra.s   .dec

    EA_zpXind
    move.b  (a0),d0
    add.b   d4,d4
    addx.b  d0,d1
    scs     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch

.dec:
    EA_zpXind
    move.b  (a0),d0
    add.b   d4,d4     ; set X flag
    abcd    d0,d1
    scs     d4
    dispatch

    setorg .op,256
op62:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op63:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op64:
    opinit
    nop
    unused
    dispatch

; ADC zp
    setorg .op,256
op65:
    opinit
    bra.s   .dec

    EA_zp
    move.b  (a0),d0
    add.b   d4,d4
    addx.b  d0,d1
    scs     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch

.dec:
    EA_zp
    move.b  (a0),d0
    add.b   d4,d4     ; set X flag
    abcd    d0,d1
    scs     d4
    dispatch

; ROR zp
    setorg .op,256
op66:
    opinit
    nop
    EA_zp
    move.b  (a0),d6
    add.b   d4,d4
    roxr.b  #1,d6
    scs     d4
    ext.w   d6
    move.b  d6,(a0)
    dispatch

    setorg .op,256
op67:
    opinit
    nop
    unused
    dispatch

; PLA
    setorg .op,256
op68:
    opinit
    nop
    addq.l  #1,a2
    move.b  (a2),d1
    move.b  d1,d6
    ext.w   d6
    dispatch

; ADC #
    setorg .op,256
op69:
    opinit
    bra.s   .dec

    move.b  (a3)+,d0
    add.b   d4,d4
    addx.b  d0,d1
    scs     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch

.dec:
    move.b  (a3)+,d0
    add.b   d4,d4     ; set X flag
    abcd    d0,d1
    scs     d4
    dispatch

; ROR A
    setorg .op,256
op6A:
    opinit
    nop
    add.b   d4,d4
    roxr.b  #1,d1
    scs     d4
    move.b  d1,d6
    ext.w   d6
    dispatch

    setorg .op,256
op6B:
    opinit
    nop
    unused
    dispatch

; JMP (abs)
    setorg .op,256
op6C:
    opinit
    nop
    movep.w 1(a3),d7
    move.b  (a3),d7
    move.l  d7,a3

    movep.w 1(a3),d7
    move.b  (a3),d7
    move.l  d7,a3
    dispatch

; ADC abs
    setorg .op,256
op6D:
    opinit
    bra.s   .dec

    EA_abs
    move.b  (a0),d0
    add.b   d4,d4
    addx.b  d0,d1
    scs     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch

.dec:
    EA_abs
    move.b  (a0),d0
    add.b   d4,d4     ; set X flag
    abcd    d0,d1      ; ADDX.B or ABCD d0,d1
    scs     d4
    dispatch

; ROR abs
    setorg .op,256
op6E:
    opinit
    nop
    EA_abs

    move.b  (a0),d6
    add.b   d4,d4
    roxr.b  #1,d6
    scs     d4
    ext.w   d6
    WriteService

    setorg .op,256
op6F:
    opinit
    nop
    unused
    dispatch

; BVS
    setorg .op,256
op70:
    opinit
    nop
    tst.b   d5
    beq.s   .nobvs
    move.b  (a3)+,d7
    ext.w   d7
    adda.w  d7,a3
    dispatch
.nobvs:
    addq.w  #1,a3
    dispatch

; ADC (zp),Y
    setorg .op,256
op71:
    opinit
    bra.s   .dec

    EA_zpYind
    move.b  (a0),d0
    add.b   d4,d4
    addx.b  d0,d1
    scs     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch

.dec:
    EA_zpYind
    move.b  (a0),d0
    add.b   d4,d4     ; set X flag
    abcd    d0,d1
    scs     d4
    dispatch

    setorg .op,256
op72:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op73:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op74:
    opinit
    nop
    unused
    dispatch

; ADC zp,X
    setorg .op,256
op75:
    opinit
    bra.s   .dec

    EA_zpX
    move.b  (a0),d0
    add.b   d4,d4
    addx.b  d0,d1
    scs     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch

.dec:
    EA_zpX
    move.b  (a0),d0
    add.b   d4,d4     ; set X flag
    abcd    d0,d1
    scs     d4
    dispatch

; ROR zp,X
    setorg .op,256
op76:
    opinit
    nop
    EA_zpX
    move.b  (a0),d6
    add.b   d4,d4
    roxr.b  #1,d6
    scs     d4
    ext.w   d6
    move.b  d6,(a0)
    dispatch

    setorg .op,256
op77:
    opinit
    nop
    unused
    dispatch

; SEI
    setorg .op,256
op78:
    opinit
    nop
    st      reg_I(a4)
    dispatch

; ADC abs,Y
    setorg .op,256
op79:
    opinit
    bra.s   .dec

    EA_absY
    move.b  (a0),d0
    add.b   d4,d4
    addx.b  d0,d1
    scs     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch

.dec:    
    EA_absY
    move.b  (a0),d0
    add.b   d4,d4     ; set X flag
    abcd    d0,d1      ; ADDX.B or ABCD d0,d1
    scs     d4
    dispatch

    setorg .op,256
op7A:
    opinit
    nop
    unused
    dispatch

    setorg .op,256
op7B:
    opinit
    nop
    unused
    dispatch

__blit::
;    .cargs .qfrom.l, .qto.l
    .qfrom = 12
    .qto   = 16
    movem.l a0/a1,-(sp)
    move.l  .qfrom(sp),a0
    move.l  .qto(sp),a1
.blit:
    move.b  (a0)+,(a1)+     ; transfer a byte
    bne.s   .blit           ; until a zero
    move.l  a1,d0
    subq.l  #1,d0
    movem.l (sp)+,a0/a1
    rts

__blitb::
;    .cargs .qfrom.l, .qto.l, .cb.w
    .qfrom = 12
    .qto   = 16
    .cb    = 20
    movem.l a0/a1,-(sp)
    move.l  .qfrom(sp),a0
    move.l  .qto(sp),a1
    move.w  .cb(sp),d0
    subq.w  #1,d0
.blitb:
    move.b  (a0)+,(a1)+     ; transfer a byte
    dbf     d0,.blitb       ; until out of bytes
;    move.l  a1,d0
    movem.l (sp)+,a0/a1
    rts

__blitzb::
;    .cargs .qto.l, .cb.w
    .qto   = 8
    .cb    = 12
    move.l  a0,-(sp)
    move.l  .qto(sp),a0
    move.w  .cb(sp),d0
    subq.l  #1,d0
.blitzb:
    clr.b   (a0)+           ; clear a byte
    dbf     d0,.blitzb      ; until out of bytes
;    move.l  a0,d0
    move.l  (sp)+,a0
    rts

__blitzl::
;    .cargs .qto.l, .cl.w
    .qto   = 8
    .cl    = 12
    move.l  a0,-(sp)
    move.l  .qto(sp),a0
    move.w  .cl(sp),d0
    subq.l  #1,d0
.blitzl:
    clr.l   (a0)+           ; clear a long
    dbf     d0,.blitzl      ; until out of bytes
;    move.l  a0,d0
    move.l  (sp)+,a0
    rts

    setorg op7B,256
op7C:
    opinit
    nop
    unused
    dispatch

__blitl::
;    .cargs .qfrom.l, .qto.l, .cl.w
    .qfrom = 12
    .qto   = 16
    .cl    = 20
    movem.l a0/a1,-(sp)
    move.l  .qfrom(sp),a0
    move.l  .qto(sp),a1
    move.w  .cl(sp),d0
    subq.l  #1,d0
.blitl:
    move.b  (a0)+,(a1)+     ; transfer a long
    dbf     d0,.blitl       ; until out of longs
    move.l  a1,d0
    movem.l (sp)+,a0/a1
    rts

__blitc::
;    .cargs  .bb.w, .qto.l, .cb.w
    .bb    = 8
    .qto   = 10
    .cb    = 14
    move.l  a0,-(sp)
    move.l  .qto(sp),a0
    move.w  .bb(sp),d1
    move.w  .cb(sp),d0
    subq.l  #1,d0
.blitc:
    move.b  d1,(a0)+        ; store byte
    dbf     d0,.blitc       ; until out of bytes
    move.l  a0,d0
    move.l  (sp)+,a0
    rts

__blitcz::
;    .cargs  .bb.w, .qto.l, .cb.w
    .bb    = 8
    .qto   = 10
    .cb    = 14
    move.l  a0,-(sp)
    move.l  .qto(sp),a0
    move.w  .bb(sp),d1
    move.w  .cb(sp),d0
    subq.l  #1,d0
.blitcz:
    move.b  d1,(a0)+        ; store byte
    dbf     d0,.blitcz       ; until out of bytes
    clr.b   (a0)
    move.l  a0,d0
    move.l  (sp)+,a0
    rts

cnt:
    dc.w    0

randomize:
    movem.l d7/a0,-(sp)

    move.l  _lMemory(PC),d7
;    move.w  #$D011,d7       ; Paperclip key emulation!
;    move.l  d7,a0
;    bchg    #0,(a0)
;    move.w  #$D300,d7
;    move.l  d7,a0
;    bclr    #7,(a0)

    move.w  #53770,d7
    move.l  d7,a0
    move.w  d1,d7
    add.w   d7,d7
    add.w   d2,d7
    add.b   $FFFF8207,d7
    add.b   $FFFF8209,d7
    move.b  d7,(a0)
    move.b  d7,$10(a0)
    move.b  d7,$20(a0)
    move.b  d7,$40(a0)
    move.b  d7,$80(a0)

    lea     54283-53770(a0),a0
    move.b  $FFFF8207,d7
    andi.b  #$7F,d7
    move.b  d7,(a0)
    move.b  d7,$10(a0)
    move.b  d7,$20(a0)
    move.b  d7,$40(a0)
    move.b  d7,$80(a0)

    add.w   #$400,cnt
    bne.s   .1

    move.b  #130,(a0)       ; force 130 into VCOUNT

.1:
    movem.l (sp)+,d7/a0
    rts


    setorg op7C,256
; ADC abs,X
op7D:
    opinit
    bra.s   .dec

    EA_absX
    move.b  (a0),d0
    add.b   d4,d4
    addx.b  d0,d1
    scs     d4
    svs     d5
    move.b  d1,d6
    ext.w   d6
    dispatch

.dec:
    EA_absX
    move.b  (a0),d0
    add.b   d4,d4     ; set X flag
    abcd    d0,d1
    scs     d4
    dispatch

; ROR abs,X
    setorg .op,256
op7E:
    opinit
    nop
    EA_absX
    move.b  (a0),d6
    add.b   d4,d4
    roxr.b  #1,d6
    scs     d4
    ext.w   d6
    WriteService


    setorg .op,256
op7F:
    opinit
    nop
    nop
    unused
    dispatch

;*********************************************************************


