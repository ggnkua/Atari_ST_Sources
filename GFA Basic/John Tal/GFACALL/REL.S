*  Rel.S
*  05/87   Timothy Purves
*          MichTron
*
*          Substitution for GFA's EXEC loader
*          Walks Fixup list for .PRG to relocate code 
*

magic        equ     0
text_size    equ     2
data_size    equ     6
bss_size     equ     10
sym_size     equ     14
headsize     equ     $1c

     xref      _main
     text
dynamic:
     lea       init(pc),a0
     tst.w     (a0)
     bne       init_done
     move.w    #1,(a0)
     lea       dynamic(pc),a0
     move.l    a0,d0          * text base
     move.l    a0,a1
     sub.w     #headsize,a1     * points to header
     add.l     text_size(a1),a0
     add.l     data_size(a1),a0
     move.l    a0,-(sp)         * address BSS
     move.l    bss_size(a1),-(sp)   * lenght!
     add.l     sym_size(a1),a0
     move.l    (a0),a1          * a1 = rel_offset
     tst.l     (a0)+
     beq       clr_bss        * no relocation
     add.l     d0,a1          * address to relocate
*
*
* a1.l = relocation address
* a0.l = relocation table ptr
* d0.l = adjust factor (text_base)
* d1.w offset to next
*
*
     clr.w     d1
relocate:
     add.l     d0,(a1)       * relocate!
     move.b    (a0)+,d1
     beq       clr_bss        * end of table
     add.w     d1,a1         * move to next location
     cmp.w     #1,d1         * special case (254)
     bne       relocate
     add.w     #253,a1       * case of 1 then add (254 - 1)
     bra       relocate
     
init     dc.w     0

clr_bss:
     move.l   (sp)+,d0
     move.l   (sp)+,a0
     bra   over
clr_loop:
     clr.b   (a0)+
over:
     dbra    d0,clr_loop

init_done:
   jmp     _main

   end
