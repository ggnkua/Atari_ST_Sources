******* this little program is commented line by line ********
* if you want a slightly more advanced assembly language     *
* program with line by line commentary, please write to      *
***** Camy Maertens at Budgie UK   ***************************                        
; this little one generates more than 16 colors in one line !
; based on an idea from T. Crowther on the '64 (one or two centuries ago)
; ST programming and calculator typing by Es from TEX !
; slightly modified to allow exit to desktop by Camy of Budgie UK
* star or ; required if comment is at first character pos
start
; a label must start at the first character position
	clr.l  -(sp)                  ; supervisor mode on
; decrement stack pointer by 4, then put 4 nought bytes there
	move.w #$20,-(sp)
; decrement stack pointer (a7) by 2, then put $0020 in it
; # means immediate value
; w means word (2 bytes)
	trap   #1
; call gem routine number 20 that handles supervisor mode	
	addq.l #6,sp
; restore stack pointer
; we deducted one long word in the first instruction
; then a word in the second instruction. That's a total of 6 bytes
; we must therefore now add 6 bytes to the stack pointer
	move.l	d0,old_stack
; take address in D0 (returned to us by gem) and store it in
; a variable called old_stack
; addresses are usually Long words (ie 4 bytes)
	dc.w	$a00a
; special instruction: causes an exception. turn mouse off
	move.w #$2700,sr
; put the value $2700 inside status register: shut all interrupts !
; try #$2500,sr (allowing k/b interrupt) and see massive difference
	move.b #02,$ff820a 
; put a byte $02 inside register $ff820a: activate 50 Hz vertical sync .
	move.w	#32000,d0
; put a value 32000 inside d0
; must be Word. Highest possible byte is 127 or 255
; highest possible word is 32768 signed or 65536 unsigned
; this one here is a loop . Highest loop allowed: 32768
loop:                         ; this is a label
	move.w #$777,$ff8240 
; put the word $0777 inside register $ff8240
; ie make border white
	move.w #$766,$ff8240 
; now, put $0766 in it
	move.w #$755,$ff8240
; and so on
	move.w #$744,$ff8240
	move.w #$733,$ff8240
	move.w #$722,$ff8240
	move.w #$700,$ff8240
	move.w #$710,$ff8240
	move.w #$720,$ff8240
	move.w #$730,$ff8240
	move.w #$740,$ff8240
	move.w #$750,$ff8240
	move.w #$760,$ff8240
	move.w #$770,$ff8240
	move.w #$761,$ff8240
	move.w #$752,$ff8240
	move.w #$743,$ff8240
	move.w #$734,$ff8240
	move.w #$725,$ff8240
	move.w #$716,$ff8240
	move.w #$727,$ff8240
	move.w #$737,$ff8240
	move.w #$747,$ff8240
	move.w #$757,$ff8240
	move.w #$767,$ff8240	25 entries, but only 20 different colors
	dbra	d0,loop
; deduct one from loop counter in D0,
; check whether counter has reached zero
; and if not, repeat operation: go back to label loop
; all in one instruction! (dbra)
	move.w #$2300,sr
; move a word $2300 in status register: restore interrupts 
	dc.w	$a009
; illegal instruction. causes an exception: mouse back on
	move.l old_stack,-(sp)
; decrement stack pointer by 4 THEN
; put the contents of variable 'old_stack' on stack 
; sp is the same as a7
	move.w #$20,-(sp)
; same again; this time put $0020 there
	trap   #1
; causes an exception. turn supervisor off
	addq.l #6,sp
; add 6 bytes to register A7 (ie stack pointer)
	clr.l -(sp)
; decrement stack pointer by 4, then put $00000000 there
	trap  #1
; a gem call: quit. back to desk top

old_stack	dc.l 0		declare initial value as 0
oldpal		ds.w 32		reserve space for 64 bytes

; dc.l 0  means define a long word with initial value 0
; dc.l 3  means define a long word with initial value 3
; ds.l 3  means reserve space for 3 long words (12 bytes)
; dc.b "hello",13,0  means reserve space for 7 bytes and put
;                    h-e-l-l-o-13-0 in them
