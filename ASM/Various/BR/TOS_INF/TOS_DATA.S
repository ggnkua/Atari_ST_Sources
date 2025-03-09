* --------------------------------------------------------------------------
* test for aes initialization, TOS, GEMDOS & AES versions etc.     ½ br 9/89
* --------------------------------------------------------------------------
start:    bra.s     action
* --------------------------------------------------------------------------
* write word (max 5 decimal places) in d0 as decimal ASCII to string in a1

dec_w:    move.w    #3,d1               ;4 decimal places
          move.l    #10000,d2           ;4 decimal places
yeah:     divu      #10,d2
          ext.l     d0                  ;ready for div
          divu      d2,d0
          addi.b    #$30,d0             ;to ASCII
          move.b    d0,(a1)+            ;write to string
          swap      d0
          dbf       d1,yeah

          rts
* --------------------------------------------------------------------------
* kill leading or trailing zero in string

zero:     cmpi.b    #$30,-1(a1)         ;'0' ?
          bne.s     leave

          move.b    #$20,-1(a1)         ;SPC
leave:    rts
* --------------------------------------------------------------------------
* write long in d0 as hex to string in a1

wrthex: moveq   #7,d1           ;loop for 8 nibbles
nibble: rol.l   #4,d0           ;get nibble
        move.l  d0,d2
        andi.b  #$0f,d2         ;mask
        addi.b  #48,d2          ;add '0' for '0'..'9'
        cmpi.b  #57,d2          ;>9?
        ble.s   wrt_it

        addq.b  #7,d2           ;'A'..'F'
wrt_it: move.b  d2,(a1)+        ;write to string
        dbf     d1,nibble

        rts
* --------------------------------------------------------------------------
action:   move.l    4(sp),a0            ;basepage addr
          lea       mystk,a1            ;end of code
          move.l    a1,sp               ;new sp
          suba.l    a0,a1               ;prog length

          move.l    a1,-(sp)            ;newsize
          move.l    a0,-(sp)            ;block
          clr       -(sp)               ;filler
          move.w    #$4A,-(sp)          ;Mshrink
          trap      #1                  ;GEMDOS
          lea       $C(sp),sp

          lea       tos_dat(pc),a4      ;header msg
          bsr       print

          pea       sysinfo(pc)
          move.w    #$26,-(sp)          ;Supexec
          trap      #14                 ;XBIOS
          addq.l    #6,sp

          movea.l   a0,a3               ;save sysbase

          lea       os_base(pc),a4
          lea       18(a4),a1
          move.l    8(a3),d0            ;get os_base
          bsr       wrthex
          bsr       print               ;display addr of os_base

          lea       os_start(pc),a4
          lea       18(a4),a1
          move.l    4(a3),d0            ;get os_start
          bsr       wrthex
          bsr       print               ;display addr of os_start

          lea       os_memb(pc),a4
          lea       18(a4),a1
          move.l    $C(a3),d0           ;get os_membot
          bsr       wrthex
          bsr       print               ;display addr of os_membot

          lea       tosver(pc),a4       ;message string
          lea       13(a4),a1           ;position to be patched
          move.b    2(a3),d0            ;get 1st byte
          addi.b    #$30,d0             ;to ASCII
          move.b    d0,(a1)             ;write it there
          addq      #2,a1               ;position to be patched
          move.b    3(a3),d0            ;get 2nd byte
          addi.b    #$30,d0             ;to ASCII
          move.b    d0,(a1)             ;write it there
          bsr       print               ;display TOS version number

          lea       bcd_date(pc),a4
          lea       16(a4),a1
          lea       $18(a3),a0
          move.b    (a0)+,d0            ;get month
          bsr       bcd_conv
          bsr       bcd_conv
          addq.l    #1,a1
          move.b    (a0)+,d0            ;get day
          bsr       bcd_conv
          bsr       bcd_conv
          addq.l    #1,a1
          move.b    (a0)+,d0            ;get 1st half of year
          bsr       bcd_conv
          bsr       bcd_conv
          move.b    (a0)+,d0            ;get 2nd half of year
          bsr       bcd_conv
          bsr       bcd_conv
          bsr       print               ;display TOS BCD date

          cmpi.b    #$1E,7(a3)          ;oldest TOS version ?
          beq.s     next

          lea       dos_date(pc),a4
          lea       16(a4),a1           ;position to be patched
          move.w    $1E(a3),d3          ;get GEMDOS coded TOS date
          move.w    d3,d0
          andi.w    #$1F,d0             ;get day
          bsr       decimal
          addq      #1,a1
          lsr       #5,d3               ;get month into position
          move.b    d3,d0
          andi.b    #$F,d0              ;get month
          bsr       decimal
          addq      #1,a1
          lsr       #4,d3               ;get (year - 1980) into position
          move.b    d3,d0
          andi.w    #$7F,d0             ;get (year - 1980)
          addi.w    #1980,d0            ;year
          bsr       dec_w
          bsr       print               ;display TOS DOS date


next:     move      #$30,-(sp)          ;Sversion
          trap      #1                  ;GEMDOS
          addq.l    #2,sp

          tst       d0
          beq.s      close

          move.w    d0,d7               ;save version no
          lea       dosver(pc),a4       ;message string
          lea       12(a4),a1           ;position to be patched
          bsr       decimal
          rol       #8,d7
          move.b    d7,d0               ;get highbyte
          addq      #1,a1               ;advance position
          bsr       decimal
          bsr.s     print               ;display GEMDOS version number

          moveq     #10,d0              ;opcode appl_init
          move.l    #$00010000,d1       ;input to control array
          bsr.s     aes
          lea       global,a6
          move      4(a6),d4            ;ap_id
          bmi.s     close               ;function failure -> end prg

          move.w    (a6),d5             ;ap_version
          beq.s     not_inst

          lea       inst(pc),a4         ;message string
          lea       12(a4),a1           ;position to be patched
          rol       #8,d5
          move.b    d5,d0               ;get highbyte
          bsr.s     bcd_conv            ;1st nibble
          bsr       zero                ;kill zero
          bsr.s     bcd_conv            ;2nd nibble
          addq      #1,a1               ;advance position to be patched
          rol       #8,d5
          move.b    d5,d0               ;get lowbyte
          bsr.s     bcd_conv            ;1st nibble
          bsr.s     bcd_conv            ;2nd nibble
          bsr       zero                ;kill zero
go_on:    bsr.s     print
          bsr.s     bconin

          moveq     #19,d0              ;appl_exit
          move.l    #$00010000,d1       ;input to control array
          bsr.s     aes
          move      (a6),d5             ;return value

close:    clr -(sp)
          trap #1
* --------------------------------------------------------------------------
not_inst: lea       missing(pc),a4
          bra       go_on
* --------------------------------------------------------------------------
aes:      lea contrl,a0
          move d0,(a0)            ;opcode
          movep.l d1,3(a0)        ;fill parameter array
          move.l #aespb,d1        ;addr table
          move #$C8,d0            ;AES
          trap #2                 ;GEM
          rts
* --------------------------------------------------------------------------
* string output to console: modelled after Cconws, string addr in A4

print:    move.b    (a4)+,d0            ;string addr
          beq.s     return
          move      d0,-(SP)            ;char
          move      #2,-(sp)            ;con
          move      #3,-(sp)            ;Bconout
          trap      #13                 ;BIOS
          addq.l    #6,sp

          bra       print
return:   rts
* --------------------------------------------------------------------------
bconin:   move      #2,-(sp)            ;con
          move      #2,-(sp)            ;bconin
          trap      #13
          addq.l    #4,sp
          rts
* --------------------------------------------------------------------------
* convert bcd-byte in d0 to 2 position decimal ascii - write to string in a1

bcd_conv: rol.b     #4,d0               ;get nibble
          move.b    d0,d1
          andi.b    #$F,d1              ;mask
          addi.b    #$30,d1             ;to ASCII
          move.b    d1,(a1)+            ;write char to string
          rts
* --------------------------------------------------------------------------
* convert byte in d0 to 2 position decimal ASCII - write to string in a1

decimal:  andi.l  #$FF,d0         ;byte only of interest here, .l for div!
          cmpi.b  #9,d0           ;single
          bls.s   single

          divu    #10,d0          ;get tens
          bsr.s   chgform         ;output
          swap    d0              ;get units
chgform:  add.b   #48,d0          ;to ASCII
          move.b  d0,(a1)+        ;write char to string
          rts

single:   move.b  #' ',(a1)+      ;leading zero
          bra     chgform         ;output
* --------------------------------------------------------------------------
sysinfo:  movea.l   $4F2,a0       ;sysbase
          rts
* --------------------------------------------------------------------------
aespb:    dc.l contrl,global,intin,intout,addrin,addrout

* the following are fixed structs after each label, XX etc are to be patched

inst:     dc.b      13,10,' AES    V XX.XX resident ',13,10,0

missing:  dc.b      13,10,' AES not (yet?) resident ',0

dosver:   dc.b      13,10,' GEMDOS V XX.XX resident ',0

tosver:   dc.b      13,10,' TOS    V  X.X  resident ',0

bcd_date: dc.b      13,10,' TOS BCD date MM/DD/YYYY ',0

dos_date: dc.b      13,10,' TOS DOS date DD.MM.YYYY ',0

os_base:  dc.b      13,10,' os_base       $00XXXXXX ',0

os_start: dc.b      13,10,' os_start      $00XXXXXX ',0

os_memb:  dc.b      13,10,' os_membot     $00XXXXXX ',10,0

tos_dat:  dc.b      27,'E'
          dc.b      13,10,' TOS VERSION INF ½ br 89 ',10,0
* --------------------------------------------------------------------------
          bss
          even
contrl:   ds    5

global:   ds   15

intin:    ds   16

intout:   ds    7

addrin:   ds.l  3

addrout:  ds.l  1

          ds.l 50
mystk:    ds.b  1
* --------------------------------------------------------------------------
