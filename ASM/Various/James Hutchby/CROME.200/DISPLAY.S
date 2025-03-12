     opt l-,c+,p+
***************************************************************************
** sample program to load and display a Spectrum 512 screen ***************
***************************************************************************


SPU_SIZE       equ  51104          SPU file size
SPU_PALETTE    equ  32000          SPU offset to palette
STACK          equ  $400           stack space required


* hardware registers:

vcountlo       equ  $ffff8209
syncmode       equ  $ffff820a
palette        equ  $ffff8240


* gemdos:

TERM           equ  $00
RAWCONIO       equ  $06
PRINTLINE      equ  $09
SETDTA         equ  $1a
F_OPEN         equ  $3d
F_CLOSE        equ  $3e
F_READ         equ  $3f
SETBLOCK       equ  $4a
SFIRST         equ  $4e

gemdos    macro
          move.w #\1,-(sp)
          trap #1
          endm


* xbios:

physbase       equ  2
getrez         equ  4
setscreen      equ  5
setpalette     equ  6
setcolor       equ  7
ikbdws         equ  25
wvbl           equ  37
supexec        equ  38

xbios     macro
          move.w #\1,-(sp)
          trap #14
          endm


* system variables:

flock          equ  $43e
_vbl_list      equ  $4ce


start     movea.l 4(sp),a0              a0 <= base page pointer
          move.l #$100,d0               d0.l <= base page length
          add.l $0c(a0),d0              add text length
          add.l $14(a0),d0              add data length
          add.l $1c(a0),d0              add bss length

          lea 0(a0,d0.l),sp             set up the stack pointer
          adda.w #STACK,sp

          addi.l #SPU_SIZE+STACK,d0     add work memory

          lea basepage(pc),a1
          move.l a0,(a1)

          move.l d0,-(sp)               total memory required
          move.l a0,-(sp)               start address
          clr.w -(sp)
          gemdos SETBLOCK               return memory not needed
          adda.w #12,sp

          movea.l basepage(pc),a4       get a pointer to the filename
          adda.w #128,a4                from the command line
          moveq #0,d0
          move.b (a4)+,d0
          clr.b 0(a4,d0.w)

          movea.l sp,a5                 load the Spectrum 512 file
          lea file(pc),a0
          move.l a5,(a0)
          bsr load

          lea org_palette(pc),a4        get the original palette and
          moveq #0,d4                   store it
start1    move.w #-1,-(sp)
          move.w d4,-(sp)
          xbios setcolor
          addq.w #6,sp
          move.w d0,(a4)+
          addq.w #1,d4
          cmpi.w #16,d4
          bne.s start1

          xbios getrez                  get the original resolution
          addq.w #2,sp
          lea org_res(pc),a0
          move.w d0,(a0)

          clr.w -(sp)                   set to low res
          move.l #-1,-(sp)
          move.l #-1,-(sp)
          xbios setscreen
          adda.w #12,sp

          pea mouse_off(pc)             turn the mouse off
          move.w #1-1,-(sp)
          xbios ikbdws
          addq.w #8,sp

          pea string(pc)                clear the screen and disable
          gemdos PRINTLINE              the cursor
          addq.w #6,sp

          xbios physbase                get the address of the screen
          addq.w #2,sp
          lea screen(pc),a0
          move.l d0,(a0)

          movea.l file(pc),a0           copy the colour planes
          movea.l screen(pc),a1
          move.w #32000/4-1,d0
start2    move.l (a0)+,(a1)+
          dbra d0,start2

          pea init(pc)                  execute in supervisor mode
          xbios supexec
          addq.w #6,sp

start3    move.w #$ff,-(sp)             wait for ESC to be pressed
          gemdos RAWCONIO
          addq.w #4,sp
          swap d0
          cmpi.b #1,d0
          bne.s start3

          pea reset(pc)                 execute in supervisor mode
          xbios supexec
          addq.w #6,sp

          pea mouse_on(pc)              turn the mouse on
          move.w #1-1,-(sp)
          xbios ikbdws
          addq.w #8,sp

          move.w org_res(pc),-(sp)      restore the original mode
          move.l #-1,-(sp)
          move.l #-1,-(sp)
          xbios setscreen
          adda.w #12,sp

          pea org_palette(pc)           restore the original palette
          xbios setpalette
          addq.w #6,sp

          xbios wvbl                    wait for video
          addq.w #2,sp

exit      gemdos TERM                   return to desktop


init      move.b (syncmode).w,d1        get the monitor frame rate
          btst #1,d1
          lea vbl50(pc),a0              a0 <= 50 hz vbl routine
          bne.s init1
          lea vbl60(pc),a0              a0 <= 60 hz vbl routine

init1     lea org_vbl(pc),a1            save the original vbl list
          move.l _vbl_list,(a1)
          move.l a0,_vbl_list           re-vector it
          rts


reset     move.l org_vbl(pc),_vbl_list  restore the original vbl list
          rts


vbl50     tst.w flock                   disk access in progress ?
          bne vbl504                    branch if yes

          move.w sr,-(sp)
          ori.w #$700,sr                disable interrupts

          lea palette,a4
          lea vcountlo,a5
          lea vbl502(pc),a6
          movea.l file(pc),a3
          lea SPU_PALETTE+16<<1(a3),a3
          move.w #197-1,d7
          moveq #0,d0
vbl501    tst.b (a5)
          beq.s vbl501
          move.b (a5),d0
          adda.l d0,a6
          jmp (a6)
vbl502    rept 120
          nop
          endr

vbl503    nop
          nop

          lea (a4),a0
          lea (a4),a1
          lea (a4),a2
          rept 16/2
          move.l (a3)+,(a0)+
          endr
          rept 16/2
          move.l (a3)+,(a1)+
          endr
          rept 16/2
          move.l (a3)+,(a2)+
          endr

          dbra d7,vbl503

          nop
          nop

          lea (a4),a0
          lea (a4),a1
          lea (a4),a2
          rept 16/2
          move.l (a3)+,(a0)+
          endr
          rept 16/2
          move.l (a3)+,(a1)+
          endr
          rept 16/2
          move.l (a3)+,(a2)+
          endr

          lea (a4),a0
          lea (a4),a1
          lea (a4),a2
          lea -(198*3*16<<1+16<<1)(a3),a4
          nop
          nop
          rept 16/2
          move.l (a3)+,(a0)+
          endr
          rept 16/2
          move.l (a3)+,(a1)+
          endr
          rept 16/2
          move.l (a4)+,(a2)+
          endr

          move.w (sp)+,sr
vbl504    rts


vbl60     tst.w flock                   disk access in progress ?
          bne vbl604                    branch if yes

          move.w sr,-(sp)
          ori.w #$700,sr                disable interrupts

          lea palette,a4
          lea vcountlo,a5
          lea vbl602(pc),a6
          movea.l file(pc),a3
          lea SPU_PALETTE+16<<1(a3),a3
          move.w #197-1,d7
          moveq #0,d0
vbl601    tst.b (a5)
          beq.s vbl601
          move.b (a5),d0
          adda.l d0,a6
          jmp (a6)
vbl602    rept 120
          nop
          endr

vbl603    nop

          lea (a4),a0
          lea (a4),a1
          lea (a4),a2
          rept 16/2
          move.l (a3)+,(a0)+
          endr
          rept 16/2
          move.l (a3)+,(a1)+
          endr
          rept 16/2
          move.l (a3)+,(a2)+
          endr

          dbra d7,vbl603

          lea (a4),a0
          lea (a4),a1
          lea (a4),a2
          rept 16/2
          move.l (a3)+,(a0)+
          endr
          rept 16/2
          move.l (a3)+,(a1)+
          endr
          rept 16/2
          move.l (a3)+,(a2)+
          endr

          lea (a4),a0
          lea (a4),a1
          lea (a4),a2
          lea -(198*3*16<<1+16<<1)(a3),a4
          nop
          nop
          rept 16/2
          move.l (a3)+,(a0)+
          endr
          rept 16/2
          move.l (a3)+,(a1)+
          endr
          rept 16/2
          move.l (a4)+,(a2)+
          endr

          move.w (sp)+,sr
vbl604    rts


* This subroutine loads a file from disk. Fed with a4 pointing to the
* filename, and a5 containing the load address.

load      pea dta_buf(pc)               set up a dta buffer
          gemdos SETDTA
          addq.w #6,sp

          clr.w -(sp)                   normal access
          move.l a4,-(sp)               pointer to filename
          gemdos SFIRST                 search first
          addq.w #8,sp
          tst.l d0                      disk error ?
          bmi exit                      exit if yes

          lea length(pc),a0             store file length
          move.l dta_buf+26(pc),(a0)

          clr.w -(sp)                   read status
          move.l a4,-(sp)               pointer to filename
          gemdos F_OPEN                 open file
          addq.w #8,sp
          tst.l d0                      disk error ?
          bmi exit                      exit if yes

          lea handle(pc),a0             save file handle
          move.w d0,(a0)

          move.l a5,-(sp)               load address
          move.l length(pc),-(sp)       file length
          move.w handle(pc),-(sp)       file handle
          gemdos F_READ                 read file
          adda.w #12,sp
          tst.l d0                      disk error ?
          bmi exit                      exit if yes

          move.w handle(pc),-(sp)       file handle
          gemdos F_CLOSE                close file
          addq.w #4,sp
          tst.l d0                      disk error ?
          bmi exit                      exit if yes

          rts


string         dc.b 27,'E',27,'f',0
mouse_on       dc.b $08
mouse_off      dc.b $12

basepage       ds.l 1         address of the base page
screen         ds.l 1         base address of the screen
file           ds.l 1         base address of the file
org_vbl        ds.l 1         original vbl routine
org_res        ds.w 1         original resolution
org_palette    ds.w 16        original palette
handle         ds.w 1         file handle
length         ds.l 1         file length
dta_buf        ds.b 44        dta buffer

