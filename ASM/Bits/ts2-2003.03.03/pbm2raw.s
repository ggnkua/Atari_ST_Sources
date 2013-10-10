*    
* pbm2raw.s
*
* Copyright (c) 2003 
* by Hermann Samso (Spacewalker)
*
* Convert portable .pbm to
* 59 raw serialized 16x16 ASCII
* chars from [space]-Z.
*

start
* a5 = (user stack + 4) =
* loaded binary start address (basepage)
        move.l  4(a7),a5
* + text, data, BSS segment sizes
        move.l  $c(a5),d0     ;text
        add.l   $14(a5),d0    ;data
        add.l   $1c(a5),d0    ;BSS
* + basepage size
        add.l   #$100,d0
* reserve only necessary memory
        move.l  d0,-(sp)
        move.l  a5,-(sp)
        clr.w   -(sp)
        move.w  #$4a,-(sp)
* free the rest
        trap    #1
        lea     12(sp),sp
	
* Supervisor mode
        clr.l   -(sp)
        move.w  #$20,-(sp)
        trap    #1
        addq.l  #6,sp    
        move.l  d0,savesp

* open input file
        move.w  #0,-(sp)
        move.l  #ifname,-(sp)
        move.w  #$3D,-(sp)
        trap    #1
        addq.l  #8,sp
        move.w  d0,ifhndl

* seek end of file, get file size
        move.w  #2,-(sp)  seek from end
        move.w  ifhndl,-(sp)
        move.l  #0,-(sp)
        move.w  #$42,-(sp)
        trap    #1
        add.l   #10,sp
        move.l  d0,ifsize
	
* reserve mem for input buffer
        move.l  ifsize,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
        move.l  d0,pbuffer

* seek back start of file
	move.w	#0,-(sp)
	move.w	ifhndl,-(sp)
	move.l	#0,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	add.l	#10,sp
	
* read whole file at 'pbuffer'
        move.l  pbuffer,-(sp)
        move.l  ifsize,-(sp)
        move.w  ifhndl,-(sp)
        move.w  #$3F,-(sp)
        trap    #1
        add.l   #12,sp

* calc size of letter 'lsize'
        * size of letter scan line
        clr.l   d0
        move.w  lwidth,d0
        subq.w  #1,d0     error if <0
        lsr.w   #4,d0           *16
        addq.w  #1,d0
        lsl.w   #1,d0           /2
        * by height of letter
        mulu.w  lheight,d0
        * store 'lsize'
        move.w  d0,lsize
* calc size of output 'ofsize'
        * by 'lnumber'
        mulu.w  lnumber,d0
        * store 'ofsize'
        move.l  d0,ofsize

* reserve mem for result output
        move.l  ofsize,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
        move.l  d0,presult

* skip binary .pbm magic header
        movea.l pbuffer,a0
        cmp.b   #'P',(a0)+
        bne     end
        cmp.b   #'4',(a0)+
        bne     end

* skip blanks
        bsr     skipBlanks
* skip comment
        bsr     skipComment

* parse width (from a0, res d0)
        bsr     parseNumber
        move.w  d0,iwidth

* calc scan line size 'ilinesz'
        subq.w  #1,d0
        lsr.w   #3,d0   /8
        addq.w  #1,d0
        move.w  d0,ilinesz

* skip blanks
        bsr     skipBlanks
* skip comment
        bsr     skipComment

* parse height (from a0, res d0)
        bsr     parseNumber
        move.w  d0,iheight

* skip blanks and comments
skip    move.l  a0,a1
        bsr     skipBlanks
        bsr     skipComment
        cmpa.l  a0,a1
        bne     skip

* Convert input .pbm to
* serialized 16x16
        move.l  a0,pbuffer   skip-header
        movea.l presult,a1
        moveq.l #0,d3  count letter rows
        moveq.l #0,d4  count letters
** one row of letters
loop3   move.w  iwidth,d2
        ext.l   d2
        divu    lwidth,d2
        subq.w  #1,d2
*** one letter
loop2   move.w  lheight,d1
        subq.w  #1,d1
**** one letter line
loop1   move.w  lwidth,d0
        lsr.w   #3,d0
        subq.w  #1,d0
loop0   move.b  (a0)+,(a1)+
        dbra    d0,loop0
**** one letter line
        move.w  ilinesz,d0
        ext.l   d0
        adda.l  d0,a0
        move.w  lwidth,d0
        lsr.w   #3,d0
        ext.l   d0
        suba.l  d0,a0
        dbra    d1,loop1
*** one letter
        addq.l  #1,d4
        cmp.w   lnumber,d4
        beq     loopc
        move.w  lheight,d0
        mulu    ilinesz,d0
        suba.l  d0,a0
        move.w  lwidth,d0
        lsr.w   #3,d0
        ext.l   d0
        adda.l  d0,a0
        dbra    d2,loop2
** one row of letters
        addq.l  #1,d3
        move.w  lheight,d2
        mulu    ilinesz,d2
        mulu    d3,d2
        movea.l pbuffer,a0
        adda.l  d2,a0
        bra     loop3
* all letters done d4=lnumber
loopc

* create file
	clr.w	-(sp)	;attributes
	move.l	#ofname,-(sp)
	move.w	#$3C,-(sp)
	trap	#1
	addq.l	#8,sp		
        move.w  d0,ofhndl

* write to file
        move.l  presult,-(sp)
        move.l  ofsize,-(sp)
        move.w  ofhndl,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	
* free reserved memories
        move.l  pbuffer,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
        move.l  presult,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp

* User mode
        move.l  savesp,-(sp)
        move.w  #$20,-(sp)
        trap    #1
        addq.l  #6,sp
			
* end of program
end     clr.w   -(sp)
	trap	#1


****************************************
* Parse decimal number from a0.
* Result number in d0.
* a0 advanced up to end of number.
****************************************
parseNumber
        movem.l d1,-(sp)

        clr.l   d0
prsNr1  clr.l   d1
        move.b  (a0),d1
        cmp.b   #'0',d1
        blt     prsNr1c
        cmp.b   #'9',d1
        bgt     prsNr1c
        sub.b   #'0',d1
        mulu.w  #10,d0
        add.l   d1,d0
        adda.l  #1,a0
        bra     prsNr1
prsNr1c

        movem.l (sp)+,d1
        rts


****************************************
* skip blanks (\32,\n\t) from a0.
* a0 advanced up to non-blank.
****************************************
skipBlanksAdvance
        adda.l  #1,a0
skipBlanks
        cmp.b   #' ',(a0)
        beq     skipBlanksAdvance
        cmp.b   #',',(a0)
        beq     skipBlanksAdvance
        cmp.b   #10,(a0)        newline
        beq     skipBlanksAdvance
        cmp.b   #9,(a0)         tab
        beq     skipBlanksAdvance

        rts


****************************************
* skip comment starting with '#'
* and ending with '\n'.
* a0 advanced past end of comment
****************************************
skipComment
        cmp.b   #'#',(a0)
        bne     skipCommentEnd
skipComment1
        move.b  (a0)+,d0
        cmp.b   #10,d0          newline
        bne     skipComment1
skipCommentEnd
        rts


savesp  dc.l    0
* i/o buffer attributes
pbuffer dc.l    0
presult dc.l    0
ifsize  dc.l    0
ofsize  dc.l    0

* .pbm attributes
iwidth  dc.w    0   .pbm width
iheight dc.w    0   .pbm height
ilinesz dc.w    0   .pbm line size (Bytes)

* letter attributes
lnumber dc.w    59  nr of letters
lheight dc.w    16  letter height(pixl)
lwidth  dc.w    16  letter width (pixl)
lsize   dc.w    32  letter size  (Bytes)

* file attributes
ifhndl  dc.w    0
ofhndl  dc.w    0
ifname  dc.b    "letras1.pbm",0
ofname  dc.b    "letras1b.ts",0


