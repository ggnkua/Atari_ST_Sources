#include <minix/config.h>
#if (CHIP == M68000)
#ifdef ACK
! (ACK needs an #ifdef before the first comment !)
! Note: ACK converts move.l, sub.l add.l to moveq,subq,addq where possible !

!****************************************************************************
!
!     C O P Y _ 6 8 K . S                                       M I N I X
!
!     Basic fast copy routines used by the kernel 
!****************************************************************************
!
! Contents:
!
!   flipclicks   exchange two block of clicks
!   zeroclicks   zero a block of clicks
!   copyclicks   copy a block of clicks
!   phys_copy    copy a block of bytes
!
!============================================================================
! Edition history
!
!  #    Date                         Comments                       By
! --- -------- ---------------------------------------------------- --- 
!   1 13.06.89 fast phys_copy by Dale Schumacher                    DAL
!   2 16.06.89 bug fixes and code impromvement by Klamer Schutte    KS
!   3 12.07.89 bug fix and further code improvement to phys_copy    RAL
!   4 14.07.89 flipclicks,zeroclicks,copyclicks added               RAL
!   5 15.07.89 fast copy routine for messages added to phys_copy    RAL
!   6 03.08.89 clr.l <ea> changed to move.l #0,<ea> (= moveq )      RAL
!
!****************************************************************************

           .sect    .text
           .sect    .rom
           .sect    .data
           .sect    .bss


           .sect    .text

           .extern  _flipclicks
           .extern  _zeroclicks
           .extern  _copyclicks
           .extern  _phys_copy


!****************************************************************************
!
!          f l i p c l i c k s
!
!          exchange to blocks of n clicks
!****************************************************************************
!
! Input:   on stack:
!                 fnclick.w   - number of clicks to copy
!                 fadr2cl.w   - physical click address 2
!                 fadr1cl.w   - physical click address 1
!          (a7) ->(rts_ptr.l) - abs. return ptr.
!
! Output:  d0,d1,a0,a1  - *
!
!****************************************************************************

fadr1cl    =        0x4                   ! click address 1          .w
fadr2cl    =        0x6                   ! click address 2          .w
fnclick    =        0x8                   ! number of clicks to flip .w

_flipclicks:
           move.l   #0,d0
           move.w   fadr1cl(a7),d0        ! address 1 in clicks
           lsl.l    #8,d0
           move.l   d0,a0                 ! address 1 ptr.
           move.l   #0,d0
           move.w   fadr2cl(a7),d0        ! address 2 in clicks
           lsl.l    #8,d0
           move.l   d0,a1                 ! address 2 ptr.
           move.l   #0,d0
           move.w   fnclick(a7),d0        ! number of clicks to exchange
           lsl.l    #2,d0                 ! need 4 loops to flip a click
           movem.l  d2-d7/a2-a6,-(a7)     ! save registers used for flip
           bra      endflip
flip64:
           movem.l  (a0)+,d1-d6           ! load from adr1  6x4 bytes
           movem.l  (a1)+,d7/a2-a6        ! load from adr2  6x4 bytes
           movem.l  d7/a2-a6,-24(a0)      ! store to  adr1  6x4 bytes
           movem.l  d1-d6,-24(a1)         ! store to  adr2  6x4 bytes
           movem.l  (a0)+,d1-d6           ! load from adr1  6x4 bytes
           movem.l  (a1)+,d7/a2-a6        ! load from adr2  6x4 bytes
           movem.l  d7/a2-a6,-24(a0)      ! store to  adr1  6x4 bytes
           movem.l  d1-d6,-24(a1)         ! store to  adr2  6x4 bytes
           movem.l  (a0)+,d1-d4           ! load from adr1  4x4 bytes
           movem.l  (a1)+,a2-a5           ! load from adr2  4x4 bytes
           movem.l  a2-a5,-16(a0)         ! store to  adr1  4x4 bytes
           movem.l  d1-d4,-16(a1)         ! store to  adr2  4x4 bytes
endflip:
           dbra     d0,flip64             ! decrement count, test and loop
           sub.l    #0x10000,d0           ! dbra handles only word counters
           bhi      flip64                !  -> next 64 x 64k bytes
           movem.l  (a7)+,d2-d7/a2-a6     ! restore registers used to flip
           rts

!****************************************************************************
!
!          z e r o c l i c k s
!
!          zero n clicks from source click to destination click address
!****************************************************************************
!
! Input:   on stack:
!                 znclick.w   - number of clicks to zero
!                 zdestcl.w   - physical destination click address
!          (a7) ->(rts_ptr.l) - abs. return ptr.
!
! Output:  d0,d1,a0,a1  - *
!
!****************************************************************************

zdestcl    =        0x4                   ! destination click address .w
znclick    =        0x6                   ! number of clicks to zero  .w

_zeroclicks:
           move.l   #0,d0
           move.w   zdestcl(a7),d0        ! destination address in clicks
           lsl.l    #8,d0
           move.l   d0,a0                 ! destination ptr.
           move.w   znclick(a7),d0        ! number of clicks to zero
           movem.l  d2-d7/a2-a6,-(a7)     ! save registers used to zero
           move.l   #0,d1                 ! zero registers
           move.l   d1,d2
           move.l   d1,d3
           move.l   d1,d4
           move.l   d1,d5
           move.l   d1,d6
           move.l   d1,d7
           move.l   d1,a1
           move.l   d1,a2
           move.l   d1,a3
           move.l   d1,a4
           move.l   d1,a5
           move.l   d1,a6
           lea      256(a0),a0            ! top of first click
           bra      endzero
zero256:
           movem.l  d1-d7/a1-a6,-(a0)     ! zero 13x4 bytes
           movem.l  d1-d7/a1-a6,-(a0)     ! zero 13x4 bytes
           movem.l  d1-d7/a1-a6,-(a0)     ! zero 13x4 bytes
           movem.l  d1-d7/a1-a6,-(a0)     ! zero 13x4 bytes
           movem.l  d1-d7/a1-a5,-(a0)     ! zero 12x4 bytes
           lea      512(a0),a0            ! top of next click
endzero:
           dbra     d0,zero256            ! decrement count, test and loop
           movem.l  (a7)+,d2-d7/a2-a6     ! restore registers used to zero
           rts

!****************************************************************************
!
!          c o p y c l i c k s
!
!          copy n clicks from source click to destination click address
!****************************************************************************
!
! Input:   on stack:
!                 cnclick.w   - number of clicks to copy
!                 cdestcl.w   - physical destination click address
!                 csrccl.w    - physical source click address
!          (a7) ->(rts_ptr.l) - abs. return ptr.
!
! Output:  d0,d1,a0,a1  - *
!
! Rem.: subroutines for this call are common to phys_copy !
!
!****************************************************************************

csrccl     =        0x4                   ! source click address      .w
cdestcl    =        0x6                   ! destination click address .w
cnclick    =        0x8                   ! number of clicks to copy  .w

_copyclicks:
           move.l   #0,d0
           move.w   csrccl(a7),d0         ! source address in clicks
           lsl.l    #8,d0
           move.l   d0,a0                 ! source ptr.
           move.l   #0,d0
           move.w   cdestcl(a7),d0        ! destination address in clicks
           lsl.l    #8,d0
           move.l   d0,a1                 ! destination ptr.
           move.w   cnclick(a7),d0        ! number of clicks to copy
           movem.l  d2-d7/a2-a6,-(a7)     ! save registers used for copy
           move.l   #0,d1                 ! no remainder
           bra      end256
loop256:
           movem.l  (a0)+,d2-d7/a2-a6     ! copy 11x4 bytes
           movem.l  d2-d7/a2-a6,(a1)
           movem.l  (a0)+,d2-d7/a2-a6     ! copy 11x4 bytes
           movem.l  d2-d7/a2-a6,44(a1)
           movem.l  (a0)+,d2-d7/a2-a6     ! copy 11x4 bytes
           movem.l  d2-d7/a2-a6,88(a1)
           movem.l  (a0)+,d2-d7/a2-a6     ! copy 11x4 bytes
           movem.l  d2-d7/a2-a6,132(a1)
           movem.l  (a0)+,d2-d7/a2-a6     ! copy 11x4 bytes
           movem.l  d2-d7/a2-a6,176(a1)
           movem.l  (a0)+,d2-d7/a2-a4     ! copy  9x4 bytes
           movem.l  d2-d7/a2-a4,220(a1)
           lea      256(a1),a1
end256:
           dbra     d0,loop256            ! decrement count, test and loop
           move.l   d1,d0                 ! remainder becomes new count
           beq      done                  ! more to copy? no!
           and.b    #0x3F,d1              ! + count mod 64
           lsr.b    #6,d0                 ! + count div 64
           bra      end64


!****************************************************************************
!
!          p h y s _ c o p y
!
!          copy n bytes from source to destination address
!****************************************************************************
!
! Input:   on stack:
!                 pnbytes.l   - number of bytes to copy
!                 pdestptr.l  - physical destination address ptr.
!                 psrcptr.l   - physical source address ptr.
!          (a7) ->(rts_ptr.l) - abs. return ptr.
!
! Output:  d0,d1,a0,a1  - *
!
! Rem.: - subroutines for this call are common to copyclick !
!       - this subroutine contains a special handling for fast message copy.
!         If the message size should change no errors would occur, but the
!         performance wouldn't be optimal any longer. Therefore this routine
!         always be updated with changing message sizes.
!
!****************************************************************************

psrcptr    =        0x4                   ! source address      .l
pdestptr   =        0x8                   ! destination address .l
pnbytes    =        0xc                   ! number of bytes to copy  .l

_phys_copy:
           move.l   psrcptr(a7),a0        ! + load source pointer
           move.l   pdestptr(a7),a1       ! + load destination pointer
           move.l   a0,d0
           move.l   a1,d1
           eor.b    d1,d0
           btst     #0,d0                 ! pointers mutually aligned?
           bne      copy1                 ! +
           move.l   pnbytes(a7),d0        ! +
           beq      end                   ! if cnt == 0 && pointers both odd ...
           btst     #0,d1                 ! pointers aligned, but odd?
           beq      check64               ! no
           move.b   (a0)+,(a1)+           ! copy odd byte
           sub.l    #1,d0                 ! decrement count
check64:
           cmp.l    #26,d0                ! message copy ?
           beq      copy_mes
           move.l   #63,d1                ! +
           cmp.l    d1,d0                 ! +
           ble      copy4                 ! + count < 64
           movem.l  d2-d7/a2-a6,-(a7)     ! save regs for movem use
           move.b   d0,d1                 ! count mod 256
           lsr.l    #8,d0                 ! count div 256
           bra      end256
done:
           movem.l  (a7)+,d2-d7/a2-a6     ! restore regs for movem use
end:
           rts
loop64:
           movem.l  (a0)+,d2-d7/a4-a5     ! copy 8x4 bytes
           movem.l  d2-d7/a4-a5,(a1)
           movem.l  (a0)+,d2-d7/a4-a5     ! copy 8x4 bytes
           movem.l  d2-d7/a4-a5,32(a1)
           lea      64(a1),a1
end64:
           dbra     d0,loop64             ! decrement count, test and loop
           movem.l  (a7)+,d2-d7/a2-a6     ! restore regs for movem use
           move.l   d1,d0                 ! remainder becomes new count
copy4:
           move.b   d0,d1                 ! +
           and.b    #3,d1                 ! +
           lsr.b    #2,d0                 ! +
           bra      end4
loop4:
           move.l   (a0)+,(a1)+
end4:
           dbra     d0,loop4              ! decrement count, test and loop
           move.l   d1,d0                 ! remainder becomes new count
           bra      end1
loop1:
           move.b   (a0)+,(a1)+
end1:
           dbra     d0,loop1              ! decrement count, test and loop
           rts
           
copy_mes:  
           move.l   (a0)+,(a1)+           ! fast copy for messages (26 bytes)
           move.l   (a0)+,(a1)+           !   (depends on message size !) 
           move.l   (a0)+,(a1)+
           move.l   (a0)+,(a1)+
           move.l   (a0)+,(a1)+
           move.l   (a0)+,(a1)+
           move.w   (a0)+,(a1)+
           rts
copy1:
           move.l   pnbytes(a7),d0
                                          ! count can be big; test on it !
           move.l   #16,d1                ! == moveq; 4
           cmp.l    d1,d0                 ! 6
           blt      end1
copy16:
           move.b   d0,d1
           and.b    #0x0F,d1
           lsr.l    #4,d0
           bra      end16
loop16:
           move.b   (a0)+,(a1)+
           move.b   (a0)+,(a1)+
           move.b   (a0)+,(a1)+
           move.b   (a0)+,(a1)+
           move.b   (a0)+,(a1)+
           move.b   (a0)+,(a1)+
           move.b   (a0)+,(a1)+
           move.b   (a0)+,(a1)+
           move.b   (a0)+,(a1)+
           move.b   (a0)+,(a1)+
           move.b   (a0)+,(a1)+
           move.b   (a0)+,(a1)+
           move.b   (a0)+,(a1)+
           move.b   (a0)+,(a1)+
           move.b   (a0)+,(a1)+
           move.b   (a0)+,(a1)+
end16:
           dbra     d0,loop16
           sub.l    #0x10000,d0           ! count can even be bigger (>1MB)
           bhi      loop16                !  (dbra handles only word counters)
           move.l   d1,d0
           bra      end1
#endif
#endif

