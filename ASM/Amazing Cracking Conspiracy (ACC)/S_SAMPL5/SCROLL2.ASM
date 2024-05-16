* Scroll.asm
* 
* Try to create a nice scroll
*
* Started 30-01-88
* version 2.0 : with rasters

COLORS          equ     $ff8240        * adress of color palette

begin:          move.w  #$2,-(sp)       * get physbase
                trap    #14
                addq.l  #$2,sp
                move.l  d0,screenc
                move.w  #4,-(sp)        * get resolution
                trap    #14
                move.w  d0,res
                lea     endcode,a0
                move.l  a0,screena
                add.l   #32000,a0
                move.l  a0,screenb
                add.l   #5920,a0
                move.l  a0,alphabet
                add.l   #32000,a0
                move.l  a0,textdata
               
init:           move.l  #inittxt,-(sp)  * print welcome message
                move.w  #$09,-(sp)
                trap    #1
                addq.l  #6,sp

load1:          move.w  #$2,-(sp)       * open BACKDROP.PI1
                move.l  #name1,-(sp)
                move.w  #$3d,-(sp)
                trap    #1
                addq.l  #8,sp
                tst.w   d0
                bpl     load1.1
                move.l  #error1,-(sp)   * open error
                move.w  #$09,-(sp)
                trap    #1
                addq.l  #6,sp
                bsr     getkey
                bra     end1
load1.1:        move.l  d0,d1
                move.l  #messag1,-(sp)  * Loading BACKDROP.PI1
                move.w  #$09,-(sp)
                trap    #1
                addq.l  #6,sp
                move.l  #picture,-(sp)  * load palette+picture
                move.l  #32034,-(sp)
                move.w  d1,-(sp)
                move.w  #$3f,-(sp)
                trap    #1
                add.l   #12,sp
                tst.l   d0
                bpl     load2
lerr1           move.l  #error1.1,-(sp) * load error
                move.w  #$09,-(sp)
                trap    #1
                addq.l  #6,-(sp)
                bsr     getkey
                bra     end1
               
load2:          move.w  d1,-(sp)        * close file
                move.w  #$3e,-(sp)
                trap    #1
                addq.l  #4,sp
                move.w  #$2,-(sp)       * open ALPHABET.PI1
                move.l  #name2,-(sp)
                move.w  #$3d,-(sp)
                trap    #1
                addq.l  #8,sp
                tst.w   d0
                bpl     load2.1
                move.l  #error2,-(sp)   * open error
                move.w  #$09,-(sp)
                trap    #1
                addq.l  #6,sp
                bsr     getkey
                bra     end1
load2.1:        move.l  d0,d1
                move.l  #messag2,-(sp)  * Loading ALPHABET.PI1
                move.w  #$09,-(sp)
                trap    #1
                addq.l  #6,sp
                move.w  #1,-(sp)        * seek past palette
                move.w  d1,-(sp)
                move.l  #34,-(sp)
                move.w  #$42,-(sp)
                trap    #1
                add.l   #10,sp
                tst.w   d0
                bmi     lerr1
                move.l  alphabet,-(sp)  * load it
                move.l  #32000,-(sp)
                move.w  d1,-(sp)
                move.w  #$3f,-(sp)
                trap    #1
                add.l   #12,sp
                tst.l   d0
                bmi     lerr1

load3:          move.w  d1,-(sp)        * close file
                move.w  #$3e,-(sp)
                trap    #1
                addq.l  #4,sp
                move.w  #$2,-(sp)       * open SCROLL.TXT
                move.l  #name3,-(sp)
                move.w  #$3d,-(sp)
                trap    #1
                addq.l  #8,sp
                tst.w   d0
                bpl     load3.1
                move.l  #error3,-(sp)   * open error
                move.w  #$09,-(sp)
                trap    #1
                addq.l  #6,sp
                bsr     getkey
                bra     end1
load3.1:        move.l  d0,d1
                move.l  #messag3,-(sp)  * Loading SCROLL.TXT
                move.w  #$09,-(sp)
                trap    #1
                addq.l  #6,sp
                move.l  textdata,a1     * text comes in a1
loadtxt:        move.l  #char,-(sp)     * load character
                move.l  #1,-(sp)
                move.w  d1,-(sp)
                move.w  #$3f,-(sp)
                trap    #1
                add.l   #12,sp
                tst.l   d0
                bmi     lerr1
                ble     closeit         * EOF reached

                move.b  char,d0
                cmp.b   #$20,d0         * space?
                bne.s   l1
                move.b  #50,(a1)+
                bra     loadtxt
l1:             cmp.b   #$21,d0         * between '!' and ')' ?
                bcs     loadtxt
                cmp.b   #41,d0
                bhi.s   l2
                sub.b   #7,d0
                cmp.b   #32,d0
                bcs.s   l1a
                subq.b  #1,d0
l1a:            move.b  d0,(a1)+
                bra     loadtxt
l2:             cmp.b   #91,d0          * between 'A' and 'Z' ?
                bcc     loadtxt
                cmp.b   #65,d0
                bcs.s   l3
                sub.b   #65,d0
                move.b  d0,(a1)+
                bra     loadtxt
l3:             cmp.b   #48,d0          * between '0' and '9' ?
                bcs     l3a
                cmp.b   #57,d0
                bhi     l3a
                sub.b   #8,d0
                move.b  d0,(a1)+
                bra     loadtxt
l3a:            cmp.b   #44,d0          * ',' ?
                bne.s   l4
                move.b  #34,(a1)+
                bra     loadtxt
l4:             cmp.b   #46,d0          * '.' ?
                bne.s   l5
                move.b  #35,(a1)+
                bra     loadtxt
l5:             cmp.b   #59,d0          * ';' ?
                bne.s   l6
                move.b  #36,(a1)+
                bra     loadtxt
l6:             cmp.b   #58,d0          * ':' ?
                bne.s   l7
                move.b  #37,(a1)+
                bra     loadtxt
l7:             cmp.b   #63,d0          * '?' ?
                bne.s   l8
                move.b  #38,(a1)+
                bra     loadtxt
l8:             cmp.b   #45,d0          * '-' ?
                bne     loadtxt
                move.b  #39,(a1)+
                bra     loadtxt          

closeit         move.b  #$ff,(a1)       * ff: EOT
                move.w  d1,-(sp)        * close file
                move.w  #$3e,-(sp)
                trap    #1
                addq.l  #4,sp
                bsr     getkey

display         clr.l   -(sp)           * superon
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp
                move.l  d0,oldstack

                move.l  #COLORS,a0      * save palette
                move.l  #oldpall,a1
                movem.l (a0),d0-d7
                movem.l d0-d7,(a1)

                move.l  #palet1,a1      * set new palette
                movem.l (a1),d0-d7
                movem.l d0-d7,(a0)

                clr.w   -(sp)           * force low-res
                move.l  #-1,-(sp)
                move.l  #-1,-(sp)
                move.w  #5,-(sp)
                trap    #14
                add.l   #12,sp

                bsr     backdrop
                bsr     hblon           * init interrupts
                move.w  #-1,vsync

                move.l  screenb,a6      * buffer for letter
                move.l  textdata,a3     * pointer to text
                clr.b   d3              * scrollcounter
sc1:            bsr     do_scroll
                bsr     do_scroll
                bsr     do_scroll
                bsr     do_scroll
sync            move.w  vsync,d0
                bne.s   sync
                move.w  #-1,vsync
                dbra    d3,sc1
                move.b  (a3)+,d7
                cmp.b   #$ff,d7
                bne.s   sc2
                move.l  textdata,a3
                move.b  (a3)+,d7
sc2:            move.l  #prop,a1
                and.w   #$00ff,d7
                move.b  0(a1,d7.w),d3
                and.w   #$00ff,d3
                bsr     letter
                move.w  #$ff,-(sp)
                move.w  #07,-(sp)
                trap    #1
                addq.l  #4,sp
                cmp.b   #32,d0
                beq     the_end
                bra     sc1

do_scroll:      move.l  screenc,a0
                add.l   #23680,a0
                move.l  a6,a1
                move.w  #37,d0
dos1:           lsl.w   14(a1)
                roxl.w  6(a1)
                roxl.w  158(a0)
                roxl.w  150(a0)
                roxl.w  142(a0)
                roxl.w  134(a0)
                roxl.w  126(a0)
                roxl.w  118(a0)
                roxl.w  110(a0)
                roxl.w  102(a0)
                roxl.w  94(a0)
                roxl.w  86(a0)
                roxl.w  78(a0)
                roxl.w  70(a0)
                roxl.w  62(a0)
                roxl.w  54(a0)
                roxl.w  46(a0)
                roxl.w  38(a0)
                roxl.w  30(a0)
                roxl.w  22(a0)
                roxl.w  14(a0)
                roxl.w  6(a0)
                move.l  #160,d1
                add.l   d1,a1
                add.l   d1,a0
                dbra    d0,dos1
                rts

letter:         cmp.b   #50,d7          * space?
                bne.s   let1
                move.w  #7,d3
                rts
let1:           move.l  d7,d1
                divu    #10,d1          * divide by 10
                move.w  d1,d2           * row # in d2
                swap    d1
                and.l   #$0000ffff,d1   * column # in d1
                mulu    #5920,d2        * row * 160 * 37
                lsl     #4,d1           * column * 16
                move.l  alphabet,a1
                add.l   d2,a1
                add.l   d1,a1           * adress of letter in a1
                move.w  #37,d1          * 37 lines in a letter
                move.l  a6,a5
letter1:        move.w  6(a1),d0
                or.w    d0,6(a5)
                move.w  14(a1),d0
                or.w    d0,14(a5)
                add.l   #160,a5
                add.l   #160,a1
                dbra    d1,letter1      * next row
                rts

cls:            move.l  screenc,a0
                move.w  #8000,d0
cls1:           clr.l   (a0)+
                dbra    d0,cls1
                rts
                
backdrop:       move.l  screenc,a0
                move.l  screena,a1
                move.w  #8000,d0
bc1:            move.l  (a1)+,(a0)+
                dbra    d0,bc1
                rts            
          
getkey:         move.l  #kmessag,-(sp)  * press a key
                move.w  #$09,-(sp)
                trap    #1
                addq.l  #6,sp
                move.w  #1,-(sp)
                trap    #1
                addq.l  #2,sp
                rts
                
the_end:        bsr     hbloff          * restore interrupts
                move.l  #oldpall,a0     * restore palette
                move.l  #COLORS,a1
                movem.l (a0),d0-d7
                movem.l d0-d7,(a1)
                move.w  res,-(sp)       * restore resolution
                move.l  #-1,-(sp)
                move.l  #-1,-(sp)
                move.w  #5,-(sp)
                trap    #14
                add.l   #12,sp
                move.l  oldstack,-(sp)  * superoff
                move.w  #$20,-(sp)      
                trap    #1
                addq.l  #6,sp
end1            clr.w   -(sp)           * exit program
                trap    #1

hblon:          move.l  $120,oldtb       *save all registers
                move.l  $118,oldkey
                move.l  $118,newkey2+2
                move.l  $70,old4         *Interrupt vector 4
                move.l  $70,new4b+2
* MFP68901
                move.b  $fffa07,old07    *Interrupt Enable A
                move.b  $fffa09,old09    *Interrupt Enable B
                move.b  $fffa0b,old0b    *Interrupt Pending A
                move.b  $fffa0d,old0d    *Interrupt Pending B
                move.b  $fffa0f,old0f    *Interrupt In-Service A
                move.b  $fffa11,old11    *Interrupt In-Service B
                move.b  $fffa13,old13    *Interrupt Mask A
                move.b  $fffa15,old15    *Interrupt Mask B
                move.b  $fffa1b,old1b    *Timer B control
                move.b  $fffa21,old21    *Timer B data

                move.l  #contr,a0
                and.b   #$df,$fffa09
                and.b   #$fe,$fffa07
                move.b  (a0)+,d0
                cmp.b   #21,d0
                bne     noinst
                move.l  #newtb,$120      *install new vectors
                move.l  #new4,$70
                move.l  #newkey,$118
                or.b    #1,$fffa07       *allow timer b interrupt
                or.b    #1,$fffa13
noinst:         rts

hbloff:         move.w  sr,-(sp)
                move.w  #$2700,sr
                move.b  contr+1,d0
                cmp.b   #4,d0
                bne     noex
                move.b  old07,$fffa07    *restore all registers
                move.b  old09,$fffa09
                move.b  old0b,$fffa0b
                move.b  old0d,$fffa0d
                move.b  old0f,$fffa0f
                move.b  old11,$fffa11
                move.b  old13,$fffa13
                move.b  old15,$fffa15
                move.b  old1b,$fffa1b
                move.b  old21,$fffa21

                move.l  oldtb,$120       *restore vectors
                move.l  oldkey,$118
                move.l  old4,$70
noex:           move.w  (sp)+,sr
                rts

new4:           movem.l d0-d7,-(sp)             *new level 4 interrupt
                move.b  #0,$fffa1b              *stop timer
                move.b  distanz,$fffa21         *set data register
                move.b  #8,$fffa1b              *start timer
                movem.l palet1,d0-d7            *set first palette
                movem.l d0-d7,$ff8240
                move.l  #palet1,pal             *set start values
                move.l  #distanz,dis
                addq.l  #1,dis
                add.l   #32,pal
                move.w  #0,vsync                * inform scroll routine  
                movem.l (sp)+,d0-d7
new4b:          jmp     $12345678

newkey:         move.w  #$2500,sr               *keyboard shut up!!!
newkey2:        jmp     $12345678

newtb:          clr.b   $fffa1b                 *timer stop
                movem.l d0/d3-d7/a0-a6,-(sp)
                move.l  dis,a0
                move.l  #$fffa21,a4
                move.b  (a0)+,(a4)              *set next distance
                move.b  #8,-6(a4)
                move.l  a0,dis

                move.l  pal,a6                  *prepare palette
                movem.l 2(a6),d4-d7/a0-a2
                move.l  #$ff8240,a5
                move.w  30(a6),d3
                move.b  (a4),d0                 *wait on next right border
wait:           cmp.b   (a4),d0
                beq     wait
                movem.l d4-d7/a0-a2,2(a5)       *fill registers as fast as you can
                move.w  d3,30(a5)
                move.w  (a6),(a5)
                add.l   #32,pal

                movem.l (sp)+,d0/d3-d7/a0-a6
                bclr    #0,$fffa0f              *end of interrupt
                rte
               
inittxt:        dc.b    'Welcome to the Digital Insanity Scroll',$0d,$0a
                dc.b    '======================================',$0d,$0a
                dc.b    $0d,$0a,0 
name1:          dc.b    'E:\DEVELOP\BACKDROP.PI1',0
error1:         dc.b    'cannot open BACKDROP.PI1',$0d,$0a,0
messag1:        dc.b    'loading BACKDROP.PI1',$0d,$0a,0
error1.1:       dc.b    'load error!',$0d,$0a,0
name2:          dc.b    'E:\DEVELOP\ALPHABET.PI1',0
messag2:        dc.b    'loading ALPHABET.PI1',$0d,$0a,0
error2:         dc.b    'cannot open ALPHABET.PI1',$0d,$0a,0
name3:          dc.b    'E:\DEVELOP\SCROLL.TXT',0
messag3:        dc.b    'loading SCROLL.TXT',$0d,$0a,0
error3:         dc.b    'cannot open SCROLL.TXT',$0d,$0a,0
kmessag:        dc.b    $0d,$0a,'Press a key....',$0d,$0a,0
palet1:         dc.w    $000,$111,$222,$333,$444,$555,$666,$777
                dc.w    $400,$400,$400,$400,$400,$555,$666,$777
palet2:         dc.w    $000,$111,$222,$333,$444,$555,$666,$777
                dc.w    $500,$500,$500,$500,$500,$555,$666,$777
palet3:         dc.w    $000,$111,$222,$333,$444,$555,$666,$777
                dc.w    $600,$600,$600,$600,$600,$555,$666,$777
palet4:         dc.w    $000,$111,$222,$333,$444,$555,$666,$777
                dc.w    $700,$700,$700,$700,$700,$700,$666,$777
palet5:         dc.w    $000,$111,$222,$333,$444,$555,$666,$777
                dc.w    $777,$777,$777,$777,$777,$555,$666,$777

prop:           dc.b    8,7,7,8,6,6,7,7,3,4
                dc.b    7,6,8,7,7,6,7,6,6,6
                dc.b    7,8,8,7,7,6,2,4,5,5
                dc.b    8,2,3,3,2,2,2,2,4,5
                dc.b    5,3,5,5,5,5,5,5,5,5

oldstack:       ds.l    1
vsync:          ds.w    1
res:            ds.w    1
oldpall:        ds.w    16
char:           ds.w    1
old4:           dc.l    0
oldtb:          dc.l    0
oldkey:         dc.l    0
old07:          dc.b    0
old09:          dc.b    0  
old0b:          dc.b    0  
old0d:          dc.b    0
old0f:          dc.b    0
old11:          dc.b    0
old13:          dc.b    0
old15:          dc.b    0
old1b:          dc.b    0
old21:          dc.b    0

contr:          dc.b    21,4,15,06
pal:            dc.l    0
dis:            dc.l    0

distanz:        dc.b    120,07,07,07,07,240,00

screena:        ds.l    1
screenb:        ds.l    1
screenc:        ds.l    1
alphabet:       ds.l    1
textdata:       ds.l    1
picture:        ds.w    1       * picture mode
palette:        ds.w    16      * color palette
endcode:

                END
