format:         move.l  4(sp),a0    ! get address of parameters
                move.w  #79,d5      ! 80 tracks
                move.l  (a0),d6     ! get #sides
                move.l  4(a0),a6    ! format buffer
                move.l  8(a0),d4    ! device (drive A or B)

loop:           move.w  d6,d7       ! d6=sides
loop1:          bsr     frmt        ! format track
                bne     error       ! something went wrong
                bsr     mess        ! inform user
                dbra    d7,loop1    ! next side
                dbra    d5,loop     ! next track 

boot:           move.l  #$6038001c,(a6) ! immuzine factor
                move.w  #$4e75,$3a(a6)  ! RTS in bootcode
                move.w  #1,-(sp)        ! 1: executable
                moveq.w #2,d0           ! 80 tracks single sided
                or.w    d6,d0           ! double-sided?
                move.w  d0,-(sp)        
                move.l  #$1000000,-(sp) ! create random serial
                move.l  a6,-(sp)        ! format buffer
                move.w  #18,-(sp)       ! protobt
                trap    #14
                add.l   #14,sp

                move.w  #1,-(sp)        ! 1 sector
                clr.l   -(sp)           ! side 0, track 0
                move.w  #1,-(sp)        ! sector 1
                move.w  d4,-(sp)        ! device
                clr.l   -(sp)           ! filler
                move.l  a6,-(sp)        ! buffer
                move.w  #9,-(sp)        ! flopwr
                trap    #14
                add.l   #20,sp

error:          rts

frmt:           move.w  #$0,-(sp)               ! virgin
                move.l  #$87654321,-(sp)        ! magic
                move.w  #1,-(sp)                ! interleave
                move.w  d7,-(sp)                ! side
                move.w  d5,-(sp)                ! track
                move.w  #9,-(sp)                ! sect./track
                move.w  d4,-(sp)                ! device
                clr.l   -(sp)                   ! filler
                move.l  a6,-(sp)                ! buffer
                move.w  #10,-(sp)               ! flopfmt
                trap    #14
                add.l   #26,sp
                tst.w   d0
                rts

mess:           move.w  d7,d0           ! side in D0
                add.b   #'1',d0         ! make ASCII digit
                lea     side(pc),a0     ! addres to put side
                move.b  d0,(a0)         ! store it
                move.w  #80,d0          ! 80 tracks
                sub.b   d5,d0           ! tracks count 80 to 1
                lea     track(pc),a0    ! address to put track
                cmp.b   #10,d0          ! track# > 10?
                bcc.s   mess1           ! yes
                move.b  #'0',(a0)+      ! no, first digit a '0'
                bra.s   mess2           ! put next digit
mess1:          divs    #10,d0          ! divide by 10
                move.b  d0,d1           ! result in d1
                add.b   #'0',d1         ! make ASCII digit
                move.b  d1,(a0)+        ! store it
                swap    d0              ! get rest
mess2:          add.b   #'0',d0         ! make ASCII digit
                move.b  d0,(a0)         ! store it
                movem.l a0-a1/d0-d1,-(sp)    ! save registers
                pea     message(pc)     ! address of message
                move.w  #9,-(sp)        ! prline
                trap    #1
                addq.l  #6,sp
                movem.l (sp)+,a0-a1/d0-d1    ! restore registers
                rts

message:        dc.b    27,'Y',32,32    ; cursor to top of screen
                dc.b    'Formatting side '
side:           ds.b    1
                dc.b    ' track '
track:          ds.b    2
                dc.b    0