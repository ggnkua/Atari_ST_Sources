* Scroll.asm
* 
* Try to create a nice scroll
*
* Started 30-01-88

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
                clr.l   -(sp)
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp
                move.l  #oldpall,a0     * get old color palette
                move.l  #COLORS,a1
                move.w  #15,d1          * transfer color palette
getpall:        move.w  (a1)+,(a0)+     
                dbra    d1,getpall
                move.l  d0,-(sp)
                move.w  #$20,-(sp)
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
                bra     the_end
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
                bra     the_end

               
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
                bra     the_end
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
                bra     the_end
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

display         move.l  #palette,-(sp)  * set palette
                move.w  #6,-(sp)
                trap    #14
                addq.l  #6,sp

                clr.w   -(sp)           * force low-res
                move.l  #-1,-(sp)
                move.l  #-1,-(sp)
                move.w  #5,-(sp)
                trap    #14
                add.l   #10,sp

                bsr     backdrop

                move.l  screenb,a6      * buffer for letter
                move.l  textdata,a3     * pointer to text
                clr.b   d3              * scrollcounter
sc1:            bsr     do_scroll
                bsr     do_scroll
                bsr     do_scroll
                bsr     do_scroll
                move.w  #37,-(sp)       * VSYNC
                trap    #14
                addq.l  #2,sp
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
                move.w  #06,-(sp)
                trap    #1
                addq.l  #4,sp
                and.l   #$000000ff,d0
                cmp.b   #32,d0
                beq     the_end
                cmp.b   #$31,d0
                bcs.s   sc1
                cmp.b   #$36,d0
                bcc.s   sc1
                sub.b   #$31,d0
                lsl.w   #5,d0
                move.l  #palet1,a0
                add.w   d0,a0
                move.l  a0,-(sp)
                move.w  #6,-(sp)
                trap    #14
                addq.l  #6,sp
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
                
the_end:        move.l  #oldpall,-(sp)  * restore palette
                move.w  #6,-(sp)
                trap    #14
                addq.l  #6,sp
                move.w  res,-(sp)       * restore resolution
                move.l  #-1,-(sp)
                move.l  #-1,-(sp)
                move.w  #5,-(sp)
                trap    #14
                add     #10,sp
                clr.w   -(sp)           * exit program
                trap    #1
               
inittxt:        dc.b    'Welcome to the Digital Insanity Scroll',$0d,$0a
                dc.b    '======================================',$0d,$0a
                dc.b    $0d,$0a,0 
name1:          dc.b    'BACKDROP.PI1',0
error1:         dc.b    'cannot open BACKDROP.PI1',$0d,$0a,0
messag1:        dc.b    'loading BACKDROP.PI1',$0d,$0a,0
error1.1:       dc.b    'load error!',$0d,$0a,0
name2:          dc.b    'ALPHABET.PI1',0
messag2:        dc.b    'loading ALPHABET.PI1',$0d,$0a,0
error2:         dc.b    'cannot open ALPHABET.PI1',$0d,$0a,0
name3:          dc.b    'SCROLL.TXT',0
messag3:        dc.b    'loading SCROLL.TXT',$0d,$0a,0
error3:         dc.b    'cannot open SCROLL.TXT',$0d,$0a,0
kmessag:        dc.b    $0d,$0a,'Press a key....',$0d,$0a,0
palet1:         dc.w    $000,$111,$222,$333,$444,$555,$666,$777
                dc.w    $400,$400,$400,$400,$400,$400,$400,$400
palet2:         dc.w    $000,$111,$222,$333,$444,$555,$666,$777
                dc.w    $400,$400,$400,$400,$400,$555,$666,$777
palet3:         dc.w    $000,$111,$222,$333,$444,$555,$666,$777
                dc.w    $400,$111,$222,$333,$444,$555,$666,$777
palet4:         dc.w    $000,$111,$222,$333,$444,$555,$666,$777
                dc.w    $400,$400,$411,$522,$522,$533,$644,$755
palet5:         dc.w    $000,$111,$222,$333,$444,$555,$666,$777
                dc.w    $400,$400,$411,$522,$522,$555,$666,$777

prop:           dc.b    8,7,7,8,6,6,7,7,3,4
                dc.b    7,6,8,7,7,6,7,6,6,6
                dc.b    7,8,8,7,7,6,2,4,5,5
                dc.b    8,2,3,3,2,2,2,2,4,5
                dc.b    5,3,5,5,5,5,5,5,5,5

                DATA

res:            ds.w    1
oldpall:        ds.w    16
char:           ds.w    1

screena:        ds.l    1
screenb:        ds.l    1
screenc:        ds.l    1
alphabet:       ds.l    1
textdata:       ds.l    1
picture:        ds.w    1       * picture mode
palette:        ds.w    16      * color palette
endcode:

                END
