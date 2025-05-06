lbtarget equ 7890h
stuff equ $99
direct equ 55h
extended equ 6543h
extend equ extended
long equ 567h
middle equ 45
short equ -5
	 abx
	 adca # stuff
	 adca ,y
	 adca direct
	 adca extended
	 adcb # stuff
	 adcb ,y
	 adcb direct
	 adcb extended
	 adda # stuff
	 adda ,y
	 adda direct
	 adda extended
	 addb # stuff
	 addb ,y
	 addb direct
	 addb extended
	 addd # stuff
	 addd ,y
	 addd direct
	 addd extended
	 anda # stuff
	 anda ,y
	 anda direct
	 anda extended
	 andb # stuff
	 andb ,y
	 andb direct
	 andb extended
	 andcc # stuff
	 asl ,y
	 asl direct
	 asl extend
	 asla
	 aslb
	 asr ,y
	 asr direct
	 asr extend
	 asra
	 asrb
	 bcc btarget
	 bcs btarget
	 beq btarget
btarget bge btarget
	 bgt btarget
	 bhi btarget
	 bhs btarget
	 bita # stuff
	 bita ,y
	 bita direct
	 bita extended
	 bitb # stuff
	 bitb ,y
	 bitb direct
	 bitb extended
	 ble btarget
	 blo btarget
	 bls btarget
	 blt btarget
	 bmi btarget
	 bne btarget
	 bpl btarget
	 bra btarget
	 brn btarget
	 bsr btarget
	 bvc btarget
	 bvs btarget
	 clr ,y
	 clr direct
	 clr extend
	 clra
	 clrb
	 cmpa # stuff
	 cmpa ,y
	 cmpa direct
	 cmpa extended
	 cmpb # stuff
	 cmpb ,y
	 cmpb direct
	 cmpb extended
	 cmpd # stuff
	 cmpd ,y
	 cmpd direct
	 cmpd extended
	 cmps # stuff
	 cmps ,y
	 cmps direct
	 cmps extended
	 cmpu # stuff
	 cmpu ,y
	 cmpu direct
	 cmpu extended
	 cmpx # stuff
	 cmpx ,y
	 cmpx direct
	 cmpx extended
	 cmpy # stuff
	 cmpy ,y
	 cmpy direct
	 cmpy extended
	 com ,y
	 com direct
	 com extend
	 coma
	 comb
	 cwai # stuff
	 daa
	 dec ,y
	 dec direct
	 dec extend
	 deca
	 decb
	 eora # stuff
	 eora ,y
	 eora direct
	 eora extended
	 eorb # stuff
	 eorb ,y
	 eorb direct
	 eorb extended
	 exg a,b
	 exg s,pc
	 exg x,y
	 inc ,y
	 inc direct
	 inc extend
	 inca
	 incb
	 jmp ,y
	 jmp direct
	 jmp extend
	 jsr ,y
	 jsr direct
	 jsr extend
	 lbcc lbtarget
	 lbcs lbtarget
	 lbeq lbtarget
	 lbge lbtarget
	 lbgt lbtarget
	 lbhi lbtarget
	 lbhs lbtarget
	 lble lbtarget
	 lblo lbtarget
	 lbls lbtarget
	 lblt lbtarget
	 lbmi lbtarget
	 lbne lbtarget
	 lbpl lbtarget
	 lbra lbtarget
	 lbrn lbtarget
	 lbsr lbtarget
	 lbvc lbtarget
	 lbvs lbtarget
	 lda # stuff
	 lda ,y
	 lda direct
	 lda extended
	 ldb # stuff
	 ldb ,y
	 ldb direct
	 ldb extended
	 ldd # stuff
	 ldd ,y
	 ldd direct
	 ldd extended
	 lds # stuff
	 lds ,y
	 lds direct
	 lds extended
	 ldu # stuff
	 ldu ,y
	 ldu direct
	 ldu extended
	 ldx # stuff
	 ldx ,y
	 ldx direct
	 ldx extended
	 ldy # stuff
	 ldy ,y
	 ldy direct
	 ldy extended
	 leas ,--s
	 leau ,--s
	 leax ,--s
	 leay ,--s
	 leay ,--u
	 leay ,--x
	 leay ,--y
	 leay ,-s
	 leay ,-u
	 leay ,-x
	 leay ,-y
	 leay ,s
	 leay ,s+
	 leay ,s++
	 leay ,u
	 leay ,u+
	 leay ,u++
	 leay ,x
	 leay ,x+
	 leay ,x++
	 leay ,y
	 leay ,y+
	 leay ,y++
	 leay [,--s]
	 leay [,--u]
	 leay [,--x]
	 leay [,--y]
	 leay [,s++]
	 leay [,s]
	 leay [,u++]
	 leay [,u]
	 leay [,x++]
	 leay [,x]
	 leay [,y++]
	 leay [,y]
	 leay [a,s]
	 leay [a,u]
	 leay [a,x]
	 leay [a,y]
	 leay [b,s]
	 leay [b,u]
	 leay [b,x]
	 leay [b,y]
	 leay [d,s]
	 leay [d,u]
	 leay [d,x]
	 leay [d,y]
	 leay [long,s]
	 leay [long,u]
	 leay [long,x]
	 leay [long,y]
	 leay [long]
	 leay [middle,s]
	 leay [middle,u]
	 leay [middle,x]
	 leay [middle,y]
	 leay [*+3456h,pcr]
	 leay [*+67h,pcr]
	 leay [short,s]
	 leay [short,u]
	 leay [short,x]
	 leay [short,y]
	 leay a,s
	 leay a,u
	 leay a,x
	 leay a,y
	 leay b,s
	 leay b,u
	 leay b,x
	 leay b,y
	 leay d,s
	 leay d,u
	 leay d,x
	 leay d,y
	 leay long,s
	 leay long,u
	 leay long,x
	 leay long,y
	 leay middle,s
	 leay middle,u
	 leay middle,x
	 leay middle,y
	 leay *+3456h,pcr
	 leay *+67h,pcr
	 leay short,s
	 leay short,u
	 leay short,x
	 leay short,y
	 lsl ,y
	 lsl direct
	 lsl extend
	 lsla
	 lslb
	 lsr ,y
	 lsr direct
	 lsr extend
	 lsra
	 lsrb
	 mul
	 neg ,y
	 neg direct
	 neg extend
	 nega
	 negb
	 nop
	 ora # stuff
	 ora ,y
	 ora direct
	 ora extended
	 orb # stuff
	 orb ,y
	 orb direct
	 orb extended
	 orcc # stuff
	 pshs a,b,cc,x
	 pshu a,b,cc,x
	 puls a,b,cc,x
	 pulu a,b,cc,x
	 rol ,y
	 rol direct
	 rol extend
	 rola
	 rolb
	 ror ,y
	 ror direct
	 ror extend
	 rora
	 rorb
	 rti
	 rts
	 sbca # stuff
	 sbca ,y
	 sbca direct
	 sbca extended
	 sbcb # stuff
	 sbcb ,y
	 sbcb direct
	 sbcb extended
	 sex
	 sta ,y
	 sta direct
	 sta extended
	 stb ,y
	 stb direct
	 stb extended
	 std ,y
	 std direct
	 std extended
	 sts ,y
	 sts direct
	 sts extended
	 stu ,y
	 stu direct
	 stu extended
	 stx ,y
	 stx direct
	 stx extended
	 sty ,y
	 sty direct
	 sty extended
	 suba # stuff
	 suba ,y
	 suba direct
	 suba extended
	 subb # stuff
	 subb ,y
	 subb direct
	 subb extended
	 subd # stuff
	 subd ,y
	 subd direct
	 subd extended
	 swi
	 swi2
	 swi3
	 sync
	 tfr a,b
	 tfr s,pc
	 tfr x,y
	 tst ,y
	 tst direct
	 tst extend
	 tsta
	 tstb
