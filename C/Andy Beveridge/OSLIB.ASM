****************************************************
*                                                  *
* C bindings for GEMDOS, BIOS and XBIOS functions  *
*       For Metacomco Lattice-C compiler.          *
*  Written by Andy Beveridge. 15th December 1985   *
*                                                  *
****************************************************
*
* THIS FILE IS PROVIDED AS AN EXAMPLE ONLY.
* THIS PROGRAM MAY NOT BE EXECUTED IN THIS FORM.
* THE CODE PRODUCED BY ASSEMBLING THIS FILE IS
* ALREADY PRESENT IN THE LATTICE-C LIBRARY 'CLIB'.
*
* Lattice passes all integer function arguments as
* LONG (32 bit) int values on the A7 stack.
* TOS expects arguments to be on the stack too
* BUT as a mixture of WORD's (16 bit) and LONGS (32 bit).
* These bindings copy the appropriate values off the top
* of the stack and push them in the form required by TOS.
* Since there are rather a lot of GEMDOS/BIOS/XBIOS
* function calls, this is done compactly and efficiently
* using look-up tables.
*
* The C functions are...
*
*  LONG gemdos(n,a,b,c,d,e,f,g,h);
*  LONG   bios(n,a,b,c,d,e,f,g,h);
*  LONG  xbios(n,a,b,c,d,e,f,g,h);
*
* where  WORD n is the function code required
* LONG/WORD (as appropriate for the function) a-h are arguments
*
* individual function calls are further defined as a set of
* parametized macros in the C include file 'OSBIND.H'
* on the Metacomco Lattice-C compiler disk.
*
         xdef     gemdos,bios,xbios

         text

gemdos   lea      gemtab,a1         ;set up a pointer to the lookup table
         move.l   sp,spsav          ;save a copy of the stack pointer
         move.l   sp,a0             ;need a copy of user's stack for access
         move.w   6(sp),d0          ;get call code to d0.w
         asl.w    #1,d0             ; x 2 cos 2 bytes per table entry
         move.b   0(a1,d0),d1       ;get high byte (bit flags) to d1
         move.b   1(a1,d0),d0       ;and low byte (parm count) to d0
         beq      gpushfn           ;if parm count was zero skip next bit
         ext.w    d0                ;extend parm count to a word
         subq.w   #1,d0             ;so parms go 0-7, not 1-8
gnxtparm move.w   d0,d2             ;make a copy of the parm count too
         addq.w   #2,d2             ;add 2 to it
         asl.w    #2,d2             ;& x 4 i.e. d2=d1*4+8 first parm is 8(sp)
         move.l   0(a0,d2),d2       ;get parm d0 to d2
         btst     d0,d1             ;check flag bit in d1 for this parm
         beq      gpushw            ;if flag 0 then go push as a word
gpushl   move.l   d2,-(sp)          ;else push it as a long
         bra      gskword
gpushw   move.w   d2,-(sp)
gskword  subq.w   #1,d0             ;decrement the parm counter
         bpl      gnxtparm          ;& keep going until done parm 0

gpushfn  move.w   6(a0),-(sp)       ;push function code as a word
         trap     #1                ;call GEMDOS
         move.l   spsav,sp          ;tidy up the stack
         rts                        ;and return to C.

         data
*
* The conversion tables for gemdos() function. ( trap #1 )
* note 1: each entry constists of 2 bytes.
*  the first is a set of 1 bit flags, one for each argument, up
*  to a maximum of 8 (of course). 1 => arg is type LONG.
*				  0 => arg is type WORD.
*  the second byte is the number of arguments
*  expected by that function.
*
* Note 2: many of the possible gemdos() calls are
*  not documented by DRI or Atari and so have been
*  left blank. Use them at your own risk!
* 
gemtab
Pterm0   dc.b     0,0               ;terminate process & return 0
Cconin   dc.b     0,0               ;read char from stdin + echo
Cconout  dc.b     %00000000,1       ;write char (word) to stdout
Cauxin   dc.b     0,0               ;read char from AUX: (RS232 port)
Cauxout  dc.b     %00000000,1       ;write char to AUX:
Cprnout  dc.b     %00000000,1       ;write char to printer
Crawio   dc.b     %00000000,1       ;raw i/o (-1 to input)
Crawcin  dc.b     0,0               ;raw char input (no echo)
Cnecin   dc.b     0,0               ;stdin inc. ctrl chars (no echo)
Cconws   dc.b     %00000001,1       ;write string to CON:
Cconrs   dc.b     %00000001,1       ;read string to buffer
Cconis   dc.b     0,0               ;return -1 if char available on stdin
         dc.b     0,0               ;$c  not documented
         dc.b     0,0               ;$d  not documented
Dsetdrv  dc.b     %00000000,1       ;$e  select current drive
         dc.b     0,0               ;$f  not documented
Cconos   dc.b     0,0               ;$10 return -1 if CON: ready for a char
Cprnos   dc.b     0,0               ;$11 return -1 if PRN: ready for a char
Cauxis   dc.b     0,0               ;$12 return -1 if AUX: has a char ready
Cauxos   dc.b     0,0               ;$13 return -1 if AUX: ready for a char
         dc.b     0,0               ;$14 not doc.
         dc.b     0,0               ;$15 not doc.
         dc.b     0,0               ;$16 not doc.
         dc.b     0,0               ;$17 not doc.
         dc.b     0,0               ;$18 not doc.
Dgetdrv  dc.b     0,0               ;$19 get current drive No.
Fsetdta  dc.b     %00000001,1       ;$1a set disk transfer address (DTA)
         dc.b     0,0               ;$1b
         dc.b     0,0               ;$1c
         dc.b     0,0               ;$1d
         dc.b     0,0               ;$1e
         dc.b     0,0               ;$1f
Super    dc.b     %00000001,1       ;$20 hack supervisor priviledge
         dc.b     0,0               ;$21
         dc.b     0,0               ;$22
         dc.b     0,0               ;$23
         dc.b     0,0               ;$24
         dc.b     0,0               ;$25
         dc.b     0,0               ;$26
         dc.b     0,0               ;$27
         dc.b     0,0               ;$28
         dc.b     0,0               ;$29
Tgetdate dc.b     0,0               ;$2a get date
Tsetdate dc.b     %00000000,1       ;$2b set date
Tgettime dc.b     0,0               ;$2c get time
Tsettime dc.b     %00000000,1       ;$2d set time
         dc.b     0,0               ;$2e
Fgetdta  dc.b     0,0               ;$2f get current DTA
Sversion dc.b     0,0               ;$30 get version
Ptermres dc.b     %00000001,2       ;$31 terminate but stay resident
         dc.b     0,0               ;$32
         dc.b     0,0               ;$33
         dc.b     0,0               ;$34
         dc.b     0,0               ;$35
Dfree    dc.b     %00000001,2       ;$36 get disk info
         dc.b     0,0               ;$37
         dc.b     0,0               ;$38
Dcreate  dc.b     %00000001,1       ;$39 create a directory
Ddelete  dc.b     %00000001,1       ;$3a delete a directory
Dsetpath dc.b     %00000001,1       ;$3b set current directory
Fcreate  dc.b     %00000001,2       ;$3c create a file
Fopen    dc.b     %00000001,2       ;$3d open a file
Fclose   dc.b     %00000000,1       ;$3e close a file give handle
Fread    dc.b     %00000110,3       ;$3f read bytes from a file
Fwrite   dc.b     %00000110,3       ;$40 write bytes to a file
Fdelete  dc.b     %00000001,1       ;$41 delete a file given name
Fseek    dc.b     %00000001,3       ;$42 seek to offset within file
Fattrib  dc.b     %00000001,3       ;$43 get file attributes
         dc.b     0,0               ;$44
Fdup     dc.b     %00000000,1       ;$45 return another handle for same file
Fforce   dc.b     %00000000,2       ;$46 force nonstd handle to same file
Dgetpath dc.b     %00000001,2       ;$47 return current directory for drive
Malloc   dc.b     %00000001,1       ;$48 allocate memory
Mfree    dc.b     %00000001,1       ;$49 free a block of memory given pointer
Mshrink  dc.b     %00000110,3       ;$4a shrink memory allocation
Pexec    dc.b     %00001110,4       ;$4b execute a process
Pterm    dc.b     %00000001,1       ;$4c terminate process returning word
         dc.b     0,0               ;$4d
Fsfirst  dc.b     %00000001,2       ;$4e look for a file from start
Fsnext   dc.b     0,0               ;$4f continue file search
         dc.b     0,0               ;$50
         dc.b     0,0               ;$51
         dc.b     0,0               ;$52
         dc.b     0,0               ;$53
         dc.b     0,0               ;$54
         dc.b     0,0               ;$55
Frename  dc.b     %00000110,3       ;$56 rename a file
Fdatime  dc.b     %00000010,3       ;$57 get file date & time info

         text

bios     lea      biostab,a1        ;set up a pointer to the lookup table
         move.l   sp,spsav          ;save a copy of the stack pointer
         move.l   sp,a0             ;just like before
         move.w   6(sp),d0          ;get call code to d0.w
         asl.w    #1,d0             ; x 2 cos 2 bytes per table entry
         move.b   0(a1,d0),d1       ;get high byte (bit flags) to d1
         move.b   1(a1,d0),d0       ;and low byte (parm count) to d0
         beq      bpushfn           ;if parm count was zero skip next bit
         ext.w    d0                ;extend parm count to a word
         subq.w   #1,d0             ;so parms go 0-7, not 1-8
bnxtparm move.w   d0,d2             ;make a copy of the parm count too
         addq.w   #2,d2             ;add 2 to it
         asl.w    #2,d2             ;and x 4 (i.e. d2=d1*4+8)
         move.l   0(a0,d2),d2       ;get parm d0 to d2
         btst     d0,d1             ;check flag bit in d1 for this parm
         beq      bpushw            ;if flag 0 then go push as a word
bpushl   move.l   d2,-(sp)          ;else push it as a long
         bra      bskword
bpushw   move.w   d2,-(sp)
bskword  subq.w   #1,d0             ;decrement the parm counter
         bpl      bnxtparm          ;& keep going until done parm 0

bpushfn  move.w   6(a0),-(sp)       ;push function code as a word
         trap     #13               ;call BIOS
         move.l   spsav,sp          ;tidy up the stack
         rts                        ;and return to C.

         data
*
* similarly, for the Atari (cp/m68k) BIOS calls ( trap #13 ).
*
biostab
getmpb   dc.b     %00000001,1       ;$00 get memory parameter block
bconstat dc.b     %00000000,1       ;$01 return character-device input status
bconin   dc.b     %00000000,1       ;$02 wait for and get from input device
bconout  dc.b     %00000000,2       ;$03 wait for and output to device
rwabs    dc.b     %00000010,5       ;$04 read or write sectors
setexc   dc.b     %00000010,2       ;$05 get or set exception vector
tickcal  dc.b     0,0               ;$06 get system timer calib. value
getbpb   dc.b     %00000000,1       ;$07 get pointer to a BIOS parm block
bcostat  dc.b     %00000000,1       ;$08 return -1 if device ready for output
mediach  dc.b     %00000000,1       ;$09 see if media has changed for a drive
drvmap   dc.b     0,0               ;$0a return bit map of available drives
kbshift  dc.b     %00000000,1       ;$0b get/set keyboard shift bits

         text

xbios    lea      xbiostab,a1       ;set up a pointer to the lookup table
         move.l   sp,spsav          ;save a copy of the stack pointer
         move.l   sp,a0             ;and again
         move.w   6(sp),d0          ;get call code to d0.w
         asl.w    #1,d0             ; x 2 cos 2 bytes per table entry
         move.b   0(a1,d0),d1       ;get high byte (bit flags) to d1
         move.b   1(a1,d0),d0       ;and low byte (parm count) to d0
         beq      xpushfn           ;if parm count was zero skip next bit
         ext.w    d0                ;extend parm count to a word
         subq.w   #1,d0             ;so parms go 0-7, not 1-8
xnxtparm move.w   d0,d2             ;make a copy of the parm count too
         addq.w   #2,d2             ;add 2 to it
         asl.w    #2,d2             ;and x 4 (i.e. d2=d1*4+8)
         move.l   0(a0,d2),d2       ;get parm d0 to d2
         btst     d0,d1             ;check flag bit in d1 for this parm
         beq      xpushw            ;if flag 0 then go push as a word
xpushl   move.l   d2,-(sp)          ;else push it as a long
         bra      xskword
xpushw   move.w   d2,-(sp)
xskword  subq.w   #1,d0             ;decrement the parm counter
         bpl      xnxtparm          ;& keep going until done parm 0

xpushfn  move.w   6(a0),-(sp)       ;push function code as a word
         trap     #14               ;call XBIOS
         move.l   spsav,sp          ;tidy up the stack
         rts                        ;and return to C.

         data
*
* and finally, the Atari extended BIOS calls ( trap #14 ).
*
xbiostab
initmous dc.b     %00000110,3       ;$00 init mouse packet handler
ssbrk    dc.b     %00000000,1       ;$01 reserve amount bytes from top of mem
physbase dc.b     0,0               ;$02 get screen physical base address
logbase  dc.b     0,0               ;$03 get screen logical base address
getrez   dc.b     0,0               ;$04 get screen resolution
setscreen dc.b    %00000011,3       ;$05 set screen parms
setpallete dc.b   %00000001,1       ;$06 change whole color palette
setcolor dc.b     %00000000,2       ;$07 set indiv. palette entry
floprd   dc.b     %00000011,7       ;$08 read a floppy sector
flopwr   dc.b     %00000011,7       ;$09 write a floppy sector
flopfmt  dc.b     0,0               ;$0a format floppy - do not use.
         dc.b     0,0               ;$0b [obsolete function]
midiws   dc.b     %00000010,2       ;$0c write string to midi
mfpint   dc.b     %00000010,2       ;$0d set mfp int to supplied vector
iorec    dc.b     %00000000,1       ;$0e return pointer to dev input buffer
rsconf   dc.b     %00000000,6       ;$0f configure rs232 port
keytbl   dc.b     %00000111,3       ;$10 set/get pointers to kbd trans tables
random   dc.b     0,0               ;$11 return a 24 bit random No.
protobt  dc.b     %00000011,4       ;$12 prototype a boot sector
flopver  dc.b     %00000011,7       ;$13 verify floppy sectors
scrdmp   dc.b     0,0               ;$14 screendump to printer
cursonf  dc.b     %00000000,2       ;$15 configure cursor
settime  dc.b     %00000001,1       ;$16 set ikbd's time & date
gettime  dc.b     0,0               ;$17 get ikbd's time & date
bioskeys dc.b     0,0               ;$18 restore key trans tables
ikbdws   dc.b     %00000010,2       ;$19 write string to ikbd
jdisint  dc.b     %00000000,1       ;$1a disable a mfp interrupt
jenabint dc.b     %00000000,1       ;$1b enable a mfp interrupt
giaccess dc.b     %00000000,2       ;$1c read/write sound chip regs
offgibit dc.b     %00000000,1       ;$1d reset a port A bit
ongibit  dc.b     %00000000,1       ;$1e set a bit in port A
xbtimer  dc.b     %00001000,4       ;$1f set mfp timer
dosound  dc.b     %00000001,1       ;$20 start up the sound daemon
setprt   dc.b     %00000000,1       ;$21 set printer config byte
kbdvbase dc.b     0,0               ;$22 return pointer to kbd vectors
kbrate   dc.b     %00000000,2       ;$23 set kbd repeat rate
prtblk   dc.b     0,0               ;$24 a fairly useless primitive
vsync    dc.b     0,0               ;$25 wait for next vbl int
supexec  dc.b     %00000001,1       ;$26 exec code in supervisor mode
puntaes  dc.b     0,0               ;$27 throw away the AES !?? (reboot)

         bss

spsav    ds.l     1                 ;reserve long for stack pointer save area

         end

