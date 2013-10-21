char_len        equ         16
area_lengh      equ         671
screen_lengh    equ         639
bprl            equ         160
                lea stack,sp
                move.l #$f8000,scr_adr
                adda.l #2,sp
                clr.l -(sp)
                move.w #$20,-(sp)
                trap #1
                move.l d0,ssp_ssp
                clr.w -(sp)
                move.l #-1,-(sp)
                move.l #-1,-(sp)
                move.w #5,-(sp)
                trap #14
                adda.l #12,sp
                bra ga_hit
                moveq #0,d0
                jsr music+$4d2
                move.l #music+$28,$4d2
                
ga_hit          lea picture,a1
                adda.l #34,a1
                move.l #$f8000,a0
                move.w #32000,d0
move_pic        move.b (a1)+,(a0)+
                dbra d0,move_pic
                pea palette
                move.w #6,-(sp)
                trap #14
                adda.l #6,sp                
*
*
                bsr clr_area
                bsr copy_x               
                move.w #0,slut_flagga
                move.w #0,varv_raek
                move.l #100,d0
                jsr save_scr
                lea chlist,a0
                move.l a0,tknpek
                move.w #0,slut_flagga
naestav         jsr clr_area
                lea xlist,a5
                move.l tknpek,a4
                move.w #40,d2
huvudloop       move.w (a4)+,d1
                bpl avsluta_inte
                move.w #1,slut_flagga 
                bra aendaa
avsluta_inte    move.w (a5)+,d0
                bsr blt_char
                dbra d2,huvudloop
aendaa          move.w #37,-(sp)
                trap #14
                adda.l #2,sp
                bsr rescue_scr
                move.w #100,d0
                bsr blt_area
                cmpi.w #1,slut_flagga
                beq till_dos
                bsr minus    
                addq.w #1,varv_raek
                cmpi.w #8,varv_raek
                bne delay
                add.l #2,tknpek
                bsr copy_x
                clr.w varv_raek                
                bra naestav
delay           bra naestav
till_dos        move.l ssp_ssp,-(sp)
                move.w #$20,-(sp)
                trap #1
                clr.w -(sp)
                trap #1

copy_x          lea xlist,a1
                lea alfa,a0
                move.w #40,d0
copy_loop       move.w (a0)+,(a1)+
                dbra d0,copy_loop
                rts
                
minus           lea xlist,a0
                move.w #40,d0
minus_loop      subq.w #1,(a0)+
                dbra d0,minus_loop
                rts
                           

* This is a library containing 5 routines to aid you in the creation
* of scrolling text.
* The routines and theire usage are:
*
* clr_area: No parameters passed to this routine.
* It clears the internal buffer area in wich the text that is going
* to be written to the screen, is written.
*
* save_scr: This subroutine saves the area (bitplane 3) of the
* screen that is going to be manipulated in an internal buffer.
* The routine expects the upp y-koordinate of the area to be
* in d0.
*
* rescue_scr: No parameters passed to this routine.
* It does the reverse of save_scr, thats is, it writes whats
* in the buffer into screen memory.
*
* blt_area: Writes the internal buffer with the scrolltext into screen memory.
* The subroutine expects the upper y-coordinate to be in register d0.
* 
* blr_char: Writes a character into the internal buffer.
* The program expects the leftmost x-coordinate in register d0, and the 
* character number in d1.This subroutine erases register d6 and d7.
*
* NOTE the character number is not the asciicode. Its the number of
* the character within your own characterset.The startaddress of
* the area were the characters are is called characters and you
* must supply it yourself.
*
* ANOTHER note. You must set scr_adr yourself. It is
* the base address of the screenmemory.
*
* A third note. The program must supply the to buffer areas.
* one called area, that is 672 byte long
* and one called save that is 640 bytes long.
*

clr_area        lea area,a0
                move.w #area_lengh,d0
clr_loop        move.b #0,(a0)+
                dbra d0,clr_loop
                rts
*
* 

save_scr        lea save,a0
                move.l scr_adr,d1  * kalkylerar adressen
                mulu #bprl,d0      * till den foersta byten
                add.l d0,d1        * i
                addi.l #6,d1       * det HAER bitplanet
                move.l d1,a1
                move.l d1,rs_addr
                move.w #screen_lengh/2,d0
save_loop       move.w (a1),(a0)
                add.l #8,a1
                add.l #2,a0
                dbra d0,save_loop
                rts
               
*
*

rescue_scr      lea save,a0
                move.l rs_addr,a1
                move.w #screen_lengh/2,d0  
rescue_loop     move.w (a0),(a1)
                add.l #8,a1
                add.l #2,a0
                dbra d0,rescue_loop
                rts
               
*
*
                     
blt_area        lea area,a0
                adda.l #1,a0
                move.l scr_adr,d1
                mulu #bprl,d0
                add.l d0,d1
                addi.l #6,d1
                move.l d1,a1
                move.l #0,d7
                move.w #screen_lengh/2,d0
blt_loop        move.w (a0),d1
                or.w d1,(a1)
                add.l #2,a0
                add.l #8,a1
                addq.w #1,d7
                cmpi.w #20,d7
                bne blt_co
                clr.l d7
                adda.l #2,a0
blt_co          dbra d0,blt_loop
                rts
                
*
*

blt_char        mulu #char_len*2,d1 
                lea characters,a0
                adda.l d1,a0
                cmpi.w #0,d0
                bne not_zero
                clr.w d7
                clr.l rest
                bra cont_blt
not_zero        move.l d0,d7
                divu #8,d7
                move.l d7,rest
                andi.l #$ffff,d7
cont_blt        move.w rest,d6
                lea area,a1
                adda.l d7,a1
                move.w #char_len-1,d0
char_loop       move.w (a0)+,d1
                lsr.w d6,d1
                move.w d1,temp
                move.b temp,d7
                or.b d7,(a1)+
                or.b d1,(a1)
                adda.l #41,a1
                dbra d0,char_loop
                rts
                
* 

sectiondata
chlist          dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.w 1,2,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.w 3,2,1,0,0,0,1,2,3,0,0,0,3,2,1,0,0,0,1,2
                dc.w 3,0,0,0,1,2,3,0,0,0,3,2,1,0,0,0,0,0,0,0,0
                dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.w $ffff
alfa            dc.w 8,16,24,32,40,48,56,64,72,80,88,96,104,112
                dc.w 120,128,136,144,152,160,168,176,184,192,200
                dc.w 208,216,224,232,240,248,256,264,272,280,288,296
                dc.w 304,312,320,328
xlist           ds.w 42

characters     dc.w  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0   * space
               dc.w  %0111110000000000                 * A
               dc.w  %1110001000000000
               dc.w  %1110001000000000
               dc.w  %1110001000000000
               dc.w  %1110001000000000
               dc.w  %1110001000000000
               dc.w  %1110001000000000
               dc.w  %1110001000000000
               dc.w  %1111011100000000
               dc.w  %1111011100000000
               dc.w  %1110011100000000
               dc.w  %1110011100000000
               dc.w  %1110011100000000
               dc.w  %1110011100000000
               dc.w  %1110011100000000
               dc.w  %0110011000000000
               dc.w  %1011111000000000                * B
               dc.w  %1011111100000000
               dc.w  %1000011100000000
               dc.w  %1000011100000000
               dc.w  %1000011100000000
               dc.w  %1000011100000000
               dc.w  %1000011100000000
               dc.w  %1110111000000000
               dc.w  %1110111000000000
               dc.w  %1110000000000000
               dc.w  %1110000000000000
               dc.w  %1110011100000000
               dc.w  %1110011100000000
               dc.w  %1110011100000000
               dc.w  %1110011100000000
               dc.w  %0111111000000000
               dc.w  %0111111000000000                 * C
               dc.w  %1000011100000000
               dc.w  %1000000000000000
               dc.w  %1000000000000000
               dc.w  %1000000000000000
               dc.w  %1000000000000000
               dc.w  %1000000000000000
               dc.w  %1110000000000000
               dc.w  %1110000000000000
               dc.w  %1110000000000000
               dc.w  %1110000000000000
               dc.w  %1110000000000000
               dc.w  %1110000000000000
               dc.w  %1110000000000000
               dc.w  %1111111100000000
               dc.w  %0111111000000000
               
palette         dc.w $000,$037,$057,$705,$007,$707,$077,$555
                dc.w $777,$500,$700,$705,$400,$737,$377,$777
                
sectionbss
slut_flagga     ds.b  2
varv_raek       ds.b  2
tknpek          ds.b  4
ssp_ssp         ds.b  4
filehandle      ds.b  4
scr_adr         ds.b  4
rs_addr         ds.b  4
rest            ds.b  4
temp            ds.b  2
no              ds.b  1
area            ds.b  672
thing           ds.b  1
save            ds.b  640
hello           ds.b  1000
stack           ds.b  10
picture         incbin a:\test.pi1
music           incbin a:\musix\quake.mus    