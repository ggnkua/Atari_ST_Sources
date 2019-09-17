
* This MACRO file was created by Mic Barnard, for my own use. I know
* there are loads of MACRO files already waiting for me to use, but I
* like being awkward and so I'm making my own.

* Started - 23rd May 1994.

* Listed alphabeticly.

*************************************************************************
*                              MICSMACS.S                               *
*************************************************************************
*
*/      add1screen      Creates (1) extra 32k screen in memory.
*                       Requires a reserved area of memory in the BSS
*                         called 'screenmem', to be 32,256 bytes big.
*                       Returns the address of the new screen in d0.
*                       Corrupts - d0
*
*       add2screen      Creates (2) extra 32k screens in memory.
*                       Requires a reserved area of memory in the BSS
*                         called 'screenmem', to be 64,256 bytes big.
*                       Returns the address' of the new screens in d0
*                         and d1.
*                       Corrupts - d0,d1
*
*       add3screen      Creates (3) extra 32k screens in memory.
*                       Requires a reserved area of memory in the BSS
*                         called 'screenmem', to be 96,256 bytes big.
*                       Returns the address' of the new screens in d0,
*                         d1 and d2.
*                       Corrupts - d0,d1,d2
*
*       add4screen      Creates (4) extra 32k screens in memory.
*                       Requires a reserved area of memory in the BSS
*                         called 'screenmem', to be 128,256 bytes big.
*                       Returns the address' of the new screens in d0,
*                         d1,d2 and d3.
*                       Corrupts - d0,d1,d2,d3
*
*/      cls             Clear a 32k screen to colour 0.
*                       Pass the address of the screen to be cleared as
*                         a longword on the stack.
*                       Corrupts - ALL registers
*
*       getkey          Examines the keyboard buffer. If empty d0 is
*                         clear, else d0 contains the ascii in the low
*                         byte of the low word and the scan code in the
*                         low byte of the high word.
*                       Does NOT echo to the screen.
*
*       getlogbase      Get the logical screens base address.
*                       Returns address in d0.l
*                       Corrupts - d0,d1,d2,a0,a1,a2
*               
*       getpal          Copy all pallette data to a 16 word buffer .
*                       \1 .l   Address of the buffer.
*                       Corrupts - d0,d1,d2,d3,a0,a1,a2,a3
*
*/      getphysbase     Get the physical screens base address.
*                       Returns address in d0.l
*                       Corrupts - d0,d1,d2,a0,a1,a2
*
*/      getrez          Get screen resolution.
*                       Returns resolution in d0.w
*                       Corrupts - d0,d1,d2,a0,a1,a2
*               
*       loaddegaspic    A routine to load a degas picture from disc to
*                         a selected screen in memory. The user needs to 
*                         tell the routine :
*                               the file name of the picture
*                               do you wish to put the header into a
*                                 palette buffer? (put -1 into the buffer
*                                 address if not)
*                               the buffers address
*                               the address of the screen
*
*                       Example call to loaddegaspic:
*
*                       move.l  #pic1,-(sp)     address of filename
*                       move.l  #header,-(sp)   address of header buffer (or-1)
*                       move.l  screenl,-(sp)   address of screen
*                       bsr     loadpic
*                       add.l   #12,sp
*
*                       Corrupts - d0,d1,d2,d7,a0,a1,a2
*
*       printastring    Print a string of characters to the current
*                         cursor position. The string must be finished
*                         with a zero byte.
*                       Put the Address of the string onto the stack
*                       Corrupts - d0,d1,d2,a0,a1,a2
*               
*       scrnswap        Swaps the addresses of screenp and screenl then
*                         waits for the next vbl. Then calls xbios 5 to 
*                         set the screen paramaters.
*                       Corrupts - d0,d1,d2,a0,a1,a2
*
*       setcol          Set a colour register to a colour value
*                       \1 .w   colour value (eg $070). if -1 is sent
*                         the current colour is returned (in d0?)
*                       \2 .w   colour register (0-15)
*                       Corrupts - d0,d1,d2,a0,a1,a2
*               
*       setpal          Set a complete colour pallette.
*                       \1 .l   address of new pallette data
*                       Corrupts - d0,d1,d2,a0,a1,a2
*               
*/      setscreen       Set the current screen parameters. (send -1
*                         if no changes to a parameter are required.)
*                       \1 .w   resolution. (0=low,1=med,2=high rez)
*                       \2 .l   physical screen address
*                       \3 .l   logical screen address
*                       Corrupts - d0,d1,d2,a0,a1,a2
*               
*       superoff        Switch the processor into user mode.
*                       A longword variable, 'oldssp', is needed to find
*                         the old stack address. 
*                       Corrupts - d0,d1,d2,a0,a1,a2
*
*       superon         Switch the processor into supervisor mode.
*                       A longword variable, 'oldssp' is needed to store
*                         the old stack address
*                       Corrupts - d0,d1,d2,a0,a1,a2
*               
*       term            TERMinate the program. Will drop back to the
*                         calling program or desktop, immediatley.
*
*       waitvbl         The program is locked into this call untill a
*                         vbl interrupt is generated. The vbl queue is
*                         actioned then control is returned.
*                       Corrupts - d0,d1,d2,a0,a1,a2
*
*************************************************************************

add1screen      MACRO

                move.l  #screenmem,d0
                addi.l  #256,d0
                andi.l  #$ffffff00,d0
        
                ENDM

add2screen      MACRO

                move.l  #screenmem,d0
                addi.l  #256,d0
                andi.l  #$ffffff00,d0
                move.l  d0,d1
                addi.l  #32000,d1
        
                ENDM

add3screen      MACRO

                move.l  #screenmem,d0
                addi.l  #256,d0
                andi.l  #$ffffff00,d0
                move.l  d0,d1
                addi.l  #32000,d1
                move.l  d1,d2
                addi.l  #32000,d2
        
                ENDM

add4screen      MACRO

                move.l  #screenmem,d0
                addi.l  #256,d0
                andi.l  #$ffffff00,d0
                move.l  d0,d1
                addi.l  #32000,d1
                move.l  d1,d2
                addi.l  #32000,d2
                move.l  d2,d3
                addi.l  #32000,d3
        
                ENDM

cls             MACRO

                move.l  4(sp),a6        
                movem.l a0-a6/d0-d7,-(sp)
                adda.l  #32000,a6               
                moveq.l         #0,d0           
                moveq.l         #0,d1           
                moveq.l         #0,d2           
                moveq.l         #0,d3           
                moveq.l         #0,d4           
                moveq.l         #0,d5           
                moveq.l         #0,d6           
                movea.l         d0,a0           
                movea.l         d0,a1           
                movea.l         d0,a2           
                movea.l         d0,a3           
                movea.l         d0,a4           
                movea.l         d0,a5           
                move.w          #614,d7         
.loop           movem.l a0-a5/d0-d6,-(a6)       
                dbra            d7,.loop        
                movem.l         a0-a4,-(a6)     
                movem.l (sp)+,a0-a6/d0-d7       

                ENDM

getkey          MACRO

                move.w  #$0b,-(sp)      examine key buffer
                trap    #1
                addq.l  #2,sp
                
                cmpi    #0,d0           test result
                beq.s   nokey           branch if buffer empty
                
                move.w  #7,-(sp)        get character
                trap    #1
                addq.l  #2,sp
                
nokey           nop
                
                ENDM
                
getlogbase      MACRO

                move.w  #3,-(sp)        function 2
                trap    #14             gemdos
                addq.l  #2,sp           tidy
                
                ENDM

getpal          MACRO

                move.l  \1,a3
                move.w  #0,d3
                
palloop         move.w  #-1,-(sp)
                move.w  d3,-(sp)
                move.w  #7,-(sp)
                trap    #14
                addq.l  #6,sp
                
                move.w  d0,a3+
                addq.w  #1,d3
                cmpi.w  #16,d3
                blt     palloop
                
                ENDM
                
getphysbase     MACRO

                move.w  #2,-(sp)        function 2
                trap    #14             gemdos
                addq.l  #2,sp           tidy
                
                ENDM


getrez          MACRO

                move.w  #4,-(sp)        function 4
                trap    #14             xbios
                addq.l  #2,sp           tidy
                
                ENDM
                
loaddegaspic    MACRO

loadpic

* - open the file

                move.w  #0,-(sp)        file attribute
                move.l  14(sp),-(sp)    address of filename
                move.w  #$3d,-(sp)      function number
                trap    #1              GEMDOS $3D - OPEN A FILE
                add.l   #8,sp           tidy

                tst.w   d0              error code?
                bmi     errors_d        if so, branch
                move.w  d0,d7           else store the handle
        
* - test the header paramater

                move.l  8(sp),a0        address of header buffer to a0
                move.l  a0,d0           and to d0, (just for testing)
                tst.l   d0              Is d0 (a0,the address given) neg?
                bpl     .yesbuf         No, branch to yesbuf

* - read the header to the 'waste' buffer

                move.l  #waste,-(sp)    Put the address onto the stack
                move.l  #34,-(sp)       number of bytes to read
                move.w  d7,-(sp)        file's handle
                move.w  #$3f,-(sp)      GEMDOS $3F - READ BYTES FROM FILE
                trap    #1
                add.l   #12,sp          tidy
        
                tst.w   d0              error code?
                bmi     errors_d        if so, deal with it?
        
                bra     .data           avoid .yesbuf

* - read the header to a good buffer

.yesbuf
                move.l  8(sp),-(sp)     Put the buffer address onto the stack
                move.l  #34,-(sp)       number of bytes to read
                move.w  d7,-(sp)        file's handle
                move.w  #$3f,-(sp)      GEMDOS $3F - READ BYTES FROM FILE
                trap    #1
                add.l   #12,sp
        
                tst.w   d0              error code?
                bmi     errors_d        if so, deal with it?
        
* - read the picture data to it's screen buffer

.data
                move.l  4(sp),-(sp)     address of screen buffer
                move.l  #32000,-(sp)    number of bytes to read
                move.w  d7,-(sp)        file's handle
                move.w  #$3f,-(sp)      GEMDOS $3F - READ BYTES FROM FILE
                trap    #1
                add.l   #12,sp

                tst.w   d0              error code?
                bmi     errors_d        if so, deal with it
        
* - close the file

                move.w  d7,-(sp)        file handle
                move.w  #$3e,-(sp)      GEMDOS $3E - CLOSE A FILE
                trap    #1
                addq.l  #4,sp

                tst.w   d0              error code?
                bmi     errors_d        if so, deal with it?
        
                ENDM

printastring    MACRO

                move.l  4(sp),-(sp)
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp
                
                ENDM

scrnswap        MACRO

                move.l  screenl,d0              logic to temp
                move.l  screenp,screenl         physic to logic
                move.l  d0,screenp              temp to physic
                
                move.w  #37,-(sp)               wait for vbl
                trap    #14
                addq.l  #2,sp           
        
                move.w  #-1,-(sp)               no rez change
                move.l  screenp,-(sp)           physical screen address
                move.l  screenl,-(sp)           logical screen address
                move.w  #5,-(sp)                XBIOS 5 - SET SCREEN PARAMETERS
                trap    #14
                add.l   #12,sp
                
                ENDM

setcol          MACRO

                move.w  \1,-(sp)        rgb data - i.e. $0264
                move.w  \2,-(sp)        colour register
                move.w  #7,-(sp)        function 7
                trap    #14             xbios
                addq.l  #6,sp           tidy
                
                ENDM
                
setpal          MACRO

                move.l  \1,-(sp)        address of start of new pal data
                move.w  #6,-(sp)        function 6
                trap    #14             xbios
                addq.l  #6,sp           tidy
                
                ENDM
                
setscreen       MACRO

                move.w  #\1,-(sp)       resolution
                move.l  \2,-(sp)        physical screen address
                move.l  \3,-(sp)        logical screen address
                move.w  #5,-(sp)        function 5
                trap    #14             xbios
                add.l   #12,sp          tidy
                
                ENDM
                
superoff        MACRO

                move.l  oldssp,-(sp)    restore old stack pointer
                move.w  #32,-(sp)       function 32
                trap    #1              gemdos
                addq.l  #6,sp           tidy
                
                ENDM            
                
superon         MACRO

                move.l  #0,-(sp)        0 = use same stack
                move.w  #32,-(sp)       function 32
                trap    #1              gemdos
                addq.l  #6,sp           tidy
                move.l  d0,oldssp       save old stack pointer
                
                ENDM
                
term            MACRO
                
                move.w  #0,-(sp)        function 0
                trap    #1              gemdos
                
                ENDM            
                
waitvbl         MACRO
        
                move.w  #37,-(sp)
                trap    #14
                addq.l  #2,sp
        
                ENDM

                