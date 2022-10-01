     opt l-,c+,p+
***************************************************************************
** sample program to load and display a Spectrum 512 screen ***************
***************************************************************************
* Altered by -THE FINK- this is no longer a .TTP program, it now INCBIN's *
* the Spectrum 512 picture so can be saved with a .PRG extension although *
* I've left the old coding still in, heres some details about the spectrum*
* 512 file......                                                          *
***************************************************************************
* <Spectrum 512> *.SPU							  *
* 80 words	first scan line of picture (unused) --should be zeroes    *
* 15920 words	picture data (screen memory) for scan lines 1 through 199 *
* 9552 words	3 palettes for each scan line (top scan line is not       *
*		included because Spectrum 512 can't display it)		  *
*---------------							  *
* 51104 bytes	total							  *
***************************************************************************
* <Spectrum 512 (Compressed)> *.SPC					  *
* 1 word	flag word [$5350 or "SP"]				  *
* 1 word	reserved for future use [always 0]			  *
* 1 long	lenght of data bit map					  *
* 1 long	lenght of colour bit map				  *
* <=32092 bytes	compressed data bit map					  *
* <=17910 bytes	compressed colour bit map				  *
*---------------							  *
* <=50014 bytes	total							  *
***************************************************************************

SPU_SIZE       equ  51104          SPU file size
SPU_PALETTE    equ  32000          SPU offset to palette
STACK          equ  $400           stack space required


* hardware registers:

vcountlo       equ  $ffff8209		interrupt enable B
syncmode       equ  $ffff820a		synchronization mode
palette        equ  $ffff8240		palette


* gemdos:		(TRAP	#1)

TERM           equ  $00			quits program, back to desktop
RAWCONIO       equ  $06			read keyboard
PRINTLINE      equ  $09			print line
SETDTA         equ  $1a			set disc transfer address
F_OPEN         equ  $3d			open file
F_CLOSE        equ  $3e			close file
F_READ         equ  $3f			read file
SETBLOCK       equ  $4a			reserve a specific area of memory
SFIRST         equ  $4e			check to see if file is present
*					in directory
gemdos    macro
          move.w #\1,-(sp)
          trap #1
          endm


* xbios:		(TRAP	#14)

physbase       equ  2			get phys base address
getrez         equ  4			get resolution
setscreen      equ  5			set screen parameters
setpalette     equ  6			set palette
setcolor       equ  7			set one colour from paslette
ikbdws         equ  25			intelligent keyboard send
wvbl           equ  37			wait for video sync
supexec        equ  38

xbios     macro
          move.w #\1,-(sp)
          trap #14
          endm


* system variables:

flock          equ  $43e		is disc access in progress ?
_vbl_list      equ  $4ce		list of eight standard VBL routines
***************************************************************************
* RESERVE A SPECIFIC AREA OF MEMORY FOR PROGRAM                           *
***************************************************************************
*start     movea.l 4(sp),a0              a0 <= base page pointer
*          move.l #$100,d0               d0.l <= base page length
*          add.l $0c(a0),d0              add text length
*          add.l $14(a0),d0              add data length
*          add.l $1c(a0),d0              add bss length

*          lea 0(a0,d0.l),sp             set up the stack pointer
*          adda.w #STACK,sp

*          addi.l #SPU_SIZE+STACK,d0     add work memory

*          lea basepage(pc),a1
*          move.l a0,(a1)

*          move.l d0,-(sp)               total memory required
*          move.l a0,-(sp)               start address
*          clr.w -(sp)
*          gemdos SETBLOCK               return memory not needed
*          adda.w #12,sp

*          movea.l basepage(pc),a4       get a pointer to the filename
*          adda.w #128,a4                from the command line
*          moveq #0,d0
*          move.b (a4)+,d0
*          clr.b 0(a4,d0.w)
***************************************************************************
* SEARCH FOR FILE (CHECK THAT IT DOES EXIST) OPEN,READ AND CLOSE FILE     *
***************************************************************************
          lea	 file2(pc),a5                 load the Spectrum 512 file
          lea 	file(pc),a0
          move.l a5,(a0)
*          bsr load
***************************************************************************
* SAVE ORIGINAL PALETTE TO 'org_palette'                                  *
***************************************************************************
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
***************************************************************************
* SAVE RESEOLUTION TO 'org_res'                                           *
***************************************************************************
          xbios getrez                  get the original resolution
          addq.w #2,sp
          lea org_res(pc),a0
          move.w d0,(a0)
***************************************************************************
* LOW RES                                                                 *
***************************************************************************
          clr.w -(sp)                   set to low res
          move.l #-1,-(sp)
          move.l #-1,-(sp)
          xbios setscreen
          adda.w #12,sp
***************************************************************************
* TURN MOUSE OFF                                                          *
***************************************************************************
          pea mouse_off(pc)             turn the mouse off
          move.w #1-1,-(sp)
          xbios ikbdws
          addq.w #8,sp
***************************************************************************
* CLEAR SCREEN USING ESCAPE CODES ON THE PRINTLINE TRAP                   *
***************************************************************************
          pea string(pc)                clear the screen and disable
          gemdos PRINTLINE              the cursor
          addq.w #6,sp
***************************************************************************
* GET SCREEN ADDRESS, SAVE IT TO 'screen'                                 *
***************************************************************************
          xbios physbase                get the address of the screen
          addq.w #2,sp
          lea screen(pc),a0
          move.l d0,(a0)
***************************************************************************
* COPY SPECTRUM 512 PICTURE TO SCREEN                                     *
***************************************************************************
          movea.l file(pc),a0		the Spectrum picy address           
          movea.l screen(pc),a1		the screen address
          move.w #32000/4-1,d0		loop counter
start2    move.l (a0)+,(a1)+		copy picture to screen
          dbra d0,start2
***************************************************************************
* RUN PROGRAM AT ADDRESS 'init(pc)' IN SUPERVISOR MODE                    *
***************************************************************************
          pea init(pc)                  execute in supervisor mode
          xbios supexec
          addq.w #6,sp
***************************************************************************
* THE PROGRAM IS NOW DISPLAYING THE 512 PICY, NOW WAIT FOR 'ESC' TO BE    *
* PRESSED TO EXIT PROGRAM                                                 *
***************************************************************************
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
***************************************************************************
* THIS IS THE ACTUAL PROGRAM CODE FOR THE COLOURS, READ AND WEEP...       *
***************************************************************************
* CHECK TO SEE IF MONITOR IS IN 60Hz OR 50Hz (IT RUNS A DIFFERENT VBL     *
* ROUTINE FOR EACH BECAUSE OF THE DIFFERENT SPEEDS OF THE VBL)            *
***************************************************************************
init      move.b (syncmode).w,d1        get the monitor frame rate
          btst #1,d1
          lea vbl50(pc),a0              a0 <= 50 hz vbl routine
          bne.s init1
          lea vbl60(pc),a0              a0 <= 60 hz vbl routine

init1     lea org_vbl(pc),a1            save the original vbl list
          move.l _vbl_list,(a1)		(address $4ce holds the eight 
*					standard VBL routines)
          move.l a0,_vbl_list           re-vector it (run new VBL routines)
          rts				exits back to the check-keyboard
*					loop....
***************************************************************************
* RESTORE THE OLD VBL LIST WHEN EXITING PROGRAM (OTHERWISE BOMBS OUT)     *
***************************************************************************
reset     move.l org_vbl(pc),_vbl_list  restore the original vbl list
          rts
***************************************************************************
* THE 50Hz VBL ROUTINE FOR THE 512 COLOURS                                *
***************************************************************************
* HAS TO WAIT FOR WHILE DISC ACCESS IS IN PROGRESS BECAUSE THE VBL ROUTINE*
* WILL NOT RUN (SO NO 512 COLOURS)                                        *
***************************************************************************
vbl50     tst.w flock                   disk access in progress ?
          bne vbl504                    branch if yes

          move.w sr,-(sp)
          ori.w #$700,sr                disable interrupts

          lea palette,a4		address $ffff8240
          lea vcountlo,a5		$ffff8209 (interrupt enable B)
          lea vbl502(pc),a6
          movea.l file(pc),a3		address of 512 picy
          lea SPU_PALETTE+16<<1(a3),a3	address of palette data for picy
          move.w #197-1,d7		loop counter
          moveq #0,d0
vbl501    tst.b (a5)
          beq.s vbl501
          move.b (a5),d0
          adda.l d0,a6
          jmp (a6)
vbl502    rept 120
          nop
          endr
***************************************************************************
* CHANGE PALETTE THREE TIMES FOR 1 SCAN LINE				  *
***************************************************************************
vbl503    nop
          nop

          lea (a4),a0			palette address
          lea (a4),a1			palette address
          lea (a4),a2			palette address
          rept 16/2
          move.l (a3)+,(a0)+		copy palette data into palette regs
          endr
          rept 16/2
          move.l (a3)+,(a1)+		copy palette data into palette regs
          endr
          rept 16/2
          move.l (a3)+,(a2)+		copy palette data into palette regs	
          endr			

          dbra d7,vbl503		loop, does 196 scan lines 

          nop
          nop

          lea (a4),a0			palette address
          lea (a4),a1			palette address
          lea (a4),a2			palette address
          rept 16/2
          move.l (a3)+,(a0)+		copy palette data into palette regs
          endr
          rept 16/2
          move.l (a3)+,(a1)+		copy palette data into palette regs
          endr
          rept 16/2
          move.l (a3)+,(a2)+		copy palette data into palette regs
          endr				just done scan line 197

          lea (a4),a0			palette address
          lea (a4),a1			palette address
          lea (a4),a2			palette address
          lea -(198*3*16<<1+16<<1)(a3),a4	uses first palette data
          nop				for last palette change because
          nop				theres not enough time to change
          rept 16/2			back from last to first scan line.
          move.l (a3)+,(a0)+		copy palette data into palette regs
          endr
          rept 16/2
          move.l (a3)+,(a1)+		copy palette data into palette regs
          endr
          rept 16/2
          move.l (a4)+,(a2)+		copy palette data into palette regs
          endr				scan line 198 done (the last line) 

          move.w (sp)+,sr		enable interrupts
vbl504    rts				end of VBL routine......
***************************************************************************
* 60Hz VBL ROUTINE                                                        *
***************************************************************************
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

*load      pea dta_buf(pc)               set up a dta buffer
*          gemdos SETDTA
*          addq.w #6,sp
*
*          clr.w -(sp)                   normal access
*          move.l a4,-(sp)               pointer to filename
*          gemdos SFIRST                 search first
*          addq.w #8,sp
*          tst.l d0                      disk error ?
*          bmi exit                      exit if yes

*          lea length(pc),a0             store file length
*          move.l dta_buf+26(pc),(a0)

*          clr.w -(sp)                   read status
*          move.l a4,-(sp)               pointer to filename
*          gemdos F_OPEN                 open file
*          addq.w #8,sp
*          tst.l d0                      disk error ?
*          bmi exit                      exit if yes

*          lea handle(pc),a0             save file handle
*          move.w d0,(a0)

*          move.l a5,-(sp)               load address
*          move.l length(pc),-(sp)       file length
*          move.w handle(pc),-(sp)       file handle
*          gemdos F_READ                 read file
*          adda.w #12,sp
*          tst.l d0                      disk error ?
*          bmi exit                      exit if yes

*          move.w handle(pc),-(sp)       file handle
*          gemdos F_CLOSE                close file
*          addq.w #4,sp
*          tst.l d0                      disk error ?
*          bmi exit                      exit if yes

*          rts


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
file2		incbin	"fink.spu"	change filename !!!!!!
