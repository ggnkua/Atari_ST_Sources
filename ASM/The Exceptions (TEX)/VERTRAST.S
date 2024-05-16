


; this little bastard generates more than 16 colors in one line !
; based on an idea from T. Crowther on the '64 (one or two centuries ago)
; ST programming and calculator typing by Es from TEX !
; (for the K-Seka assembler)

start:

clr.l  -(sp)                  ; supervisor mode on
move.w #$20,-(sp)
trap   #1
addq.l #6,sp

move.w #$2700,sr              ; shut up all you interrupts !
move.b #02,$ff820a            ; activate 50 Hz vertical sync .

loop:                         ; beginning of the super-complex-
move.w #$777,$ff8240          ; machine-code-program !
move.w #$766,$ff8240          ; $ff8240 = background color.
move.w #$755,$ff8240
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
move.w #$767,$ff8240
jmp    loop                   ; again and again...




