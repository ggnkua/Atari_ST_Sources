/ Disassembly listing of eternal ramdisk program
/
default_device  = 7	/ Default device number (7=H:)
default_size = 100	/ Default ramdisk size (in units of 1K)
magic   = 0x200		/ Used to detect restart


/ Absolute memory locations
/
reset_vector= 0x004
membot      = 0x432
memtop      = 0x436
phystop	    = 0x42E
hdv_bpb     = 0x472
hdv_rw      = 0x476
hdv_mediach = 0x47E
drivebits   = 0x4C4


/ DOS operation codes
/
Mshrink = 0x4A
Super   = 0x20
Fopen	= 0x3D
Fclose	= 0x3E
Fread	= 0x3F

/---------------------------------------------------------------
		.shri

           movea.l   a7, a5	/ save old stack ptr
           movea.l   $stack, a7	/ new stack
           movea.l   4(a5), a5	/ get address of base page
           move.l    12(a5), d0	/ compute length of program
           add.l     20(a5), d0
           add.l     28(a5), d0
           add.l     $0x100, d0

           move.l    d0, -(a7)	/ size
           move.l    a5, -(a7)	/ mem
           move.w    d0, -(a7)	/ zero
           move.w    $Mshrink, -(a7)  / return unused memory
           trap      $1		/ DOS
           adda.l    $12, a7	/ pop stack

           clr.l     -(a7)		/ 0
           move.w    $Super, -(a7)	/ Super
           trap      $1			/ DOS
           addq.l    $6, a7		/ pop stack
           move.l    d0, old_ssp	/ save old SSP

           movea.l   $memtop, a4
           movea.l   $phystop, a5
           movea.l   (a5), a1
           cmpi.w    $magic, (a1)
           beq       restart

/ read file "\auto\ramdisk.dat"

	   move.w    $0,-(a7)		/ open file
	   move.l    $filename,-(a7)
           move.w    $Fopen,-(a7)
           trap	     $1
	   addq.l    $8,a7

	   cmpi.w    $0, d0		/ check for error
           bmi       L3			/ branch if open failed
	   move.w    d0,d7		/ save file handle	   
	   	   
	   move.l    $buffer,-(a7)	/ read file
	   move.l    $3,-(a7)
	   move.w    d7,-(a7)
	   move.w    $Fread,-(a7)
           trap	     $1
           adda.l    $12,a7
	   cmpi.l    $3,d0
           bne.s     L3			/ make sure 3 bytes were read

	   move.w    d7,-(a7)		/ close file
	   move.w    $Fclose,-(a7)
	   trap	     $1
           addq.l    $4,a7

	   clr.l     d0
	   move.b    buffer, d0
           move.w    d0, device_no	/ save for future use
	   move.w    d0, rd_mediach+2	/ put device number in cmpi instr.
	   move.w    d0, rd_bpb+2
	   move.w    d0, rd_rw+2

	   move.b    buffer+1, d0	/ get ramdisk size (in K-bytes)
           lsl.l     $8,d0
           move.b    buffer+2, d0
	   bra.s     L5
	
 L3:	   move.l    $default_size, d0	/ file not found -- use default size

 L5:       move.w    d0, numcl		/ put number of clusters in bpb
           moveq.l   $10, d2
           lsl.l     d2, d0		/ d0 = ramd size in bytes
           add.l     $[9216+512], d0	/ leave space for boot sector
					/ + FAT + root dir + BPB + driver

           move.l    d0, d1	/ make sure to leave at least 128K to user
           add.l     membot, d1
           add.l     $0x20000, d1
           cmp.l     (a4), d1
           bge.s     exit

           sub.l     d0, (a4)		/ okay, so reserve memory
           sub.l     d0, (a5)
           move.l    hdv_bpb, old_bpb+2	        / save hdv_bpb vector
           move.l    hdv_rw, old_rw+2	        / save hdv_rw vector
           move.l    hdv_mediach, old_mediach+2 / save hdv_mediach vector

           movea.l   $driver, a0	/ copy drivers to reserved memory
           movea.l   (a5), a1	
           moveq.l   $127, d7		/ move 512 bytes
  L4:      move.l    (a0)+, (a1)+
           dbf       d7, L4

           movea.l   reset_vector, a0	/ force a reset
           jmp       (a0)

  restart:
           move.l    (a5), d1
           add.l     $[rd_bpb - driver], d1
           move.l    d1, hdv_bpb		/ set hdv_bpb vector

           move.l    (a5), d1
           add.l     $[rd_rw - driver], d1
           move.l    d1, hdv_rw			/ set hdv_rw vector

           move.l    (a5), d1
           add.l     $[rd_mediach - driver], d1
           move.l    d1, hdv_mediach		/ set hdv_mediach vector

	   movea.l   (a5), a0			/ mark ramdisk as present
           adda.l    $[device_no - driver], a0
           move.w    (a0), d1      
           move.w    drivebits, d0
           bset      d1, d0
           move.w    d0, drivebits

  exit:    move.l    old_ssp, -(a7)		/ leave supervisor mode
           move.w    $Super, -(a7)
           trap      $1
           addq.l    $6, a7
           clr.w     -(a7)			/ exit using Pterm0
           trap      $1

/----------------------------------------------------------
/ Following bytes moved into high memory

  driver:

/ ramdisk bios parameter block

   recsiz: .word     512	/ physical sector size in bytes
   clsiz:  .word     2		/ cluster size in sectors
   clsizb: .word     1024	/ cluster size in bytes
   rdlen:  .word     7		/ root dir length in sectors
   fsiz:   .word     5		/ FAT size in sectors
   fatrec: .word     6		/ sector # 2nd FAT start
   datrec: .word     18		/ sector # data start
   numcl:  .word     0x01EC	/ number of clusters (filled in above)
   bflags: .word     0

rd_mediach:
           cmpi      $default_device, 4(a7)	/ mediach handler
           bne       old_mediach
           moveq.l   $0, d0
           rts

rd_bpb:
           cmpi      $default_device, 4(a7)	/ bpb handler
           bne       old_bpb
           move.l    phystop, d0
           rts

rd_rw:
           cmpi      $default_device, 14(a7)	/ rw handler
           bne       old_rw
           movea.l   phystop, a0
           adda.l    $512, a0		/ start of ramdisk data area
           movea.l   6(a7), a1		/ buffer address
           moveq.l   $0, d1
           move.w    12(a7), d1		/ logical record number
           moveq.l   $9, d0		/   * 2^9 
           asl.l     d0, d1
           adda.l    d1, a0		/   + ramdisk base = sector address
           move.w    10(a7), d0		/ sector count
           move.l    a1, d2		/ is buffer address odd?
           btst      $0, d2
           bne.s     L8			/ --yes, then branch
           btst      $0, 5(a7)		/ check mode
           bne.s     L6			/ branch if write
           exg       a1, a0		/ read, so copy other way round
   L6:     move.w    $15, d1		/ loop 16 times
   L7:     move.l    (a1)+, (a0)+	/ move 32 bytes quickly
           move.l    (a1)+, (a0)+
           move.l    (a1)+, (a0)+
           move.l    (a1)+, (a0)+
           move.l    (a1)+, (a0)+
           move.l    (a1)+, (a0)+
           move.l    (a1)+, (a0)+
           move.l    (a1)+, (a0)+
           dbf       d1, L7
           subq.l    $1, d0		/ decrement count
           bne.s     L6			/ loop if more sectors to move
           rts

  L8:      btst      $0, 5(a7)		/ odd address buffer, so use slow move
           bne.s     L9			/ branch if write
           exg       a1, a0		/ read, so copy other way round
  L9:      move.w    $63, d1		/ loop 64 times
  L10:     move.b    (a1)+, (a0)+	/ move 8 bytes
           move.b    (a1)+, (a0)+
           move.b    (a1)+, (a0)+
           move.b    (a1)+, (a0)+
           move.b    (a1)+, (a0)+
           move.b    (a1)+, (a0)+
           move.b    (a1)+, (a0)+
           move.b    (a1)+, (a0)+
           dbf       d1, L10
           subq.l    $1, d0		/ decrement count
           bne.s     L9			/ loop if more sectors to move
           rts

old_bpb:
           jmp       0			/ vector to old bpb handler
old_mediach:
           jmp       0			/ vector to old mediach handler
old_rw:
           jmp       0			/ vector to old rw handler

device_no: .word     default_device

/
/----------------------- end of driver code -------------------------

	   .prvd
filename:  .ascii    "\\auto\\ramdisk.dat\0"

	   .bssd
	   .even
buffer: .=.+4		/ character buffer
old_ssp:.=.+0x4		/ saved system stack pointer
	.=.+0x200	/ stack
stack:
