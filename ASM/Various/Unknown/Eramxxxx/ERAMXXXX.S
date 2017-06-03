* This Program is a modification of the Public Domain Program ETERNAL,
* and was produce with the source listing provided with it. ETERNAL is
* a reset survivable ram disk which comes with a configuration program to 
* produce a data file which instructs ETERNAL which ram disk to install and
* what size in kilo bytes it should be, this file and ETERNAL are then put
* into the auto folder as the first program to run.
* What this modified version does is to READ what drive number and size
* the ram disk should be from its own filename.
* The search string used by the sfirst gemdos call is "\AUTO\ERAM*.PRG".
* For a ram disk 'D' of size 349K you would rename this program to
* ERAMD349.PRG, put it in the AUTO folder and cold boot (switch on).
* The sfirst search attribute is $37, which searches for files and folders,
* so you could rename this program to anything you like and create a 
* folder or file with and acceptable file name as above.
* If an incorrect filename is found or sfirst returns an error or a 0
* size, the program defaults to drive 'D' of size 349K.
* Do not forget to install the drive on the desktop and then save the
* desktop.    

*                   Absolute Default Values
default_device      equ       3             Default device number ( 3 = D )
default_size        equ       349         Default ramdisk size ( 1K units )
magic               equ       $200                   Used to detect restart

*                   Absolute Memory Locations
reset_vector        equ       $004
membot              equ       $432
memtop              equ       $436
phystop             equ       $42E
hdv_bpb             equ       $472
hdv_rw              equ       $476
hdv_mediach         equ       $47E
drivebits           equ       $4C4

*                   DOS Codes
Mshrink             equ       $4A
Super               equ       $20
Fopen               equ       $3D
Fclose              equ       $3E
Fread               equ       $3F

**************************************************************************
program_start       movea.l   a7,a5                      save old stack ptr
                    movea.l   #stack,a7                            new stack
                    movea.l   4(a5),a5             get address of base page
                    move.l    12(a5),d0           compute length of program
                    add.l     20(a5),d0
                    add.l     28(a5),d0
                    add.l     #$100,d0

                    move.l    d0,-(a7)                                 size
                    move.l    a5,-(a7)                                  mem
                    move.w    d0,-(a7)                                 zero
                    move.w    #Mshrink,-(a7)           return unused memory
                    trap      #1                                        DOS
                    adda.l    #12,a7                              pop stack

                    clr.l     -(a7)                     set supervisor mode
                    move.w    #Super,-(a7)                            Super
                    trap      #1                                        DOS
                    addq.l    #6,a7                               pop stack
                    move.l    d0,old_ssp                       save old SSP

                    movea.l   #memtop,a4
                    movea.l   #phystop,a5
                    movea.l   (a5),a1
                    cmpi.w    #magic,(a1)
                    beq       restart

                    move.w    #$2F,-(sp)                    get current dta
                    trap      #1
                    addq.l    #2,sp
                    move.l    d0,current_dta               save current dta

                    move.l    #my_dta,-(sp)                   set up my dta
                    move.w    #$1a,-(sp)
                    trap      #1
                    addq.l    #6,sp
 
                    move.w    #$37,-(sp)    find this programs own filename
                    move.l    #filename,-(sp)
                    move.w    #$4e,-(sp)                             sfirst
                    trap      #1
                    addq.l    #8,sp
                    tst.l     d0
                    bne       size_error  error use default size and device

find_device_letter  clr.l     d0
                    move.l    #my_dta+34,a0   point to device letter in dta
                    move.b    (a0),d0        get drive letter from filename
                    sub.b     #$41,d0            convert letter to a number
                    bmi       get_size      if < 0 (A) use default device D
                    cmp.b     #15,d0
                    bhi       get_size     if > 15 (P) use default device D
                    move.w    d0,device_no               save device number
                    move.w    d0,rd_mediach+2              modify this code
                    move.w    d0,rd_bpb+2            with the device number
                    move.w    d0,rd_rw+2

***                 auto size this program from its own filename
*                   using the 6th, 7th, and 8th, letters only,
*                   but they do not all have to be there
*                   zeroes and leading zeroes are accepted
get_size            clr.l     d7                     d7 = letter to convert
                    clr.l     d0                         d0 = number result
                    move.l    #my_dta+35,a0           point to first letter
auto_size_loop      move.b    (a0)+,d7       get first letter from filename
                    beq       got_size        finish if 0 (end of filename)
                    cmp.b     #$2e,d7                      compare with "."
                    beq       got_size            branch if end of filename
                    sub.b     #$30,d7              convert letter to number
                    bmi       size_error             branch if < 0 to error
                    cmp.b     #$0a,d7                          test for > 9
                    bge       size_error             branch if > 9 to error
                    mulu      #$000a,d0                      multiply by 10
                    add.w     d7,d0   add new result to previouse result
                    bra       auto_size_loop      loop and do other letters
got_size            tst.l     d0
                    beq       size_error       if size = 0 use default 349k
                    bra       restore_dta

size_error          move.l    #default_size,d0 file not found, default size

restore_dta         move.l    d0,save_size             save the size number

                    move.l    current_dta,-(sp)           reset current dta
                    move.w    #$1a,-(sp)                            set dta
                    trap      #1
                    addq.l    #6,sp

                    move.l    save_size,d0
                    move.w    d0,numcl        put number of clusters in bpb
                    moveq.l   #10,d2
                    lsl.l     d2,d0                 d0 = ramd size in bytes
                    add.l     #9216+512,d0      leave space for boot sector

* + FAT + root dir + BPB + driver
                    move.l    d0,d1            leave at least 128K for user
                    add.l     membot,d1
                    add.l     #$20000,d1
                    cmp.l     (a4),d1
                    bge.s     exit

                    sub.l     d0,(a4)               okay, so reserve memory
                    sub.l     d0,(a5)
                    move.l    hdv_bpb,old_bpb+2         save hdv_bpb vector
                    move.l    hdv_rw,old_rw+2            save hdv_rw vector
                    move.l    hdv_mediach,old_mediach+2    save hdv_mediach 

                    movea.l   #driver,a0    copy drivers to reserved memory
                    movea.l   (a5),a1
                    moveq.l   #127,d7                        move 512 bytes
L4                  move.l    (a0)+,(a1)+
                    dbf       d7,L4

                    movea.l   reset_vector,a0                 force a reset
                    jmp       (a0)

restart             move.l    (a5),d1
                    add.l     #rd_bpb-driver,d1
                    move.l    d1,hdv_bpb                 set hdv_bpb vector

                    move.l    (a5),d1
                    add.l     #rd_rw-driver,d1
                    move.l    d1,hdv_rw                   set hdv_rw vector

                    move.l    (a5),d1
                    add.l     #rd_mediach-driver,d1
                    move.l    d1,hdv_mediach         set hdv_mediach vector

                    movea.l   (a5),a0               mark ramdisk as present
                    adda.l    #device_no-driver,a0
                    move.w    (a0),d1      
                    move.w    drivebits,d0
                    bset      d1,d0
                    move.w    d0,drivebits

exit                move.l    old_ssp,-(a7)           leave supervisor mode
                    move.w    #Super,-(a7)
                    trap      #1
                    addq.l    #6,a7
                    clr.w     -(a7)                       exit using Pterm0
                    trap      #1

* Following bytes moved into high memory
* ramdisk bios parameter block
                    even
driver:
recsiz              dc.w      512             physical sector size in bytes
clsiz               dc.w      2                     cluster size in sectors
clsizb              dc.w      1024                    cluster size in bytes
rdlen               dc.w      7                  root dir length in sectors
fsiz                dc.w      5                         FAT size in sectors
fatrec              dc.w      6                      sector # 2nd FAT start
datrec              dc.w      18                        sector # data start
numcl               dc.w      $01EC    number of clusters (filled in above)
bflags              dc.w      0

rd_mediach          cmpi      #default_device,4(a7)         mediach handler
                    bne       old_mediach
                    moveq.l   #0,d0
                    rts

rd_bpb              cmpi      #default_device,4(a7)             bpb handler
                    bne       old_bpb
                    move.l    phystop,d0
                    rts

rd_rw               cmpi      #default_device,14(a7)             rw handler
                    bne       old_rw
                    movea.l   phystop,a0
                    adda.l    #512,a0            start of ramdisk data area
                    movea.l   6(a7),a1                       buffer address
                    moveq.l   #0,d1
                    move.w    12(a7),d1               logical record number
                    moveq.l   #9,d0                                     2^9 
                    asl.l     d0,d1
                    adda.l    d1,a0         + ramdisk base = sector address
                    move.w    10(a7),d0                        sector count
                    move.l    a1,d2                  is buffer address odd?
                    btst      #0,d2
                    bne.s     L8                           yes, then branch
                    btst      #0,5(a7)                           check mode
                    bne.s     L6                            branch if write
                    exg       a1,a0           read, so copy other way round
L6                  move.w    #15,d1                          loop 16 times
L7                  move.l    (a1)+,(a0)+             move 32 bytes quickly
                    move.l    (a1)+,(a0)+
                    move.l    (a1)+,(a0)+
                    move.l    (a1)+,(a0)+
                    move.l    (a1)+,(a0)+
                    move.l    (a1)+,(a0)+
                    move.l    (a1)+,(a0)+
                    move.l    (a1)+,(a0)+
                    dbf       d1,L7
                    subq.l    #1,d0                         decrement count
                    bne.s     L6               loop if more sectors to move
                    rts

L8                  btst      #0,5(a7)    odd address buffer, use slow move
                    bne.s     L9                            branch if write
                    exg       a1,a0           read, so copy other way round
L9                  move.w    #63,d1                          loop 64 times
L10                 move.b    (a1)+,(a0)+                      move 8 bytes
                    move.b    (a1)+,(a0)+
                    move.b    (a1)+,(a0)+
                    move.b    (a1)+,(a0)+
                    move.b    (a1)+,(a0)+
                    move.b    (a1)+,(a0)+
                    move.b    (a1)+,(a0)+
                    move.b    (a1)+,(a0)+
                    dbf       d1,L10
                    subq.l    #1,d0                         decrement count
                    bne.s     L9               loop if more sectors to move
                    rts

old_bpb             jmp       0                   vector to old bpb handler
old_mediach         jmp       0               vector to old mediach handler
old_rw              jmp       0                     vector to old rw handle

                    even
device_no           dc.w      default_device
current_dta         ds.l      1
save_size           ds.l      1
filename            dc.b      "\AUTO\ERAM*.PRG",0         i.e. ERAMD340.PRG
                    even
my_dta              ds.b      44
old_ssp             ds.l      1         * saved system stack pointer
                    ds.w      200       * stack
stack               ds.l      1
                    end
**************************************************************************
