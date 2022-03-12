( Sieve Benchmark	Assembler version- 1.405 secs
   This is the wicked assembler version. It uses the same algorithm as 
  sieve.fth but takes advantage of the 68000's registers. It also goes
  overboard in demonstrating the use of EQU- used for defining string
  equates for effective addresses. In general, you wouldn't use it. % also
  makes things load slower.)
( By the way, 99,991 is the highest of the 9592 prime numbers under 100,000.
  Make sure you've used setSPACES before trying that.)
DECIMAL

: % Begin  0 word  count 0=  swap C@ 13 = or until ; immediate
% because I think it looks better than \; so there!
8192 CONSTANT TheSize 

VARIABLE flags TheSize VALLOT
also assembler

code InitArray	( fills the primes array with 1's to start things)
	MOVE.L	#Flags,A0	% this is how to make sure your program
	LEA	0(A5,A0.L),A0	% will work even if VP is >32k
	MOVE.L	#TheSize,D0
	ASR.L	#2,D0		% I'll fill with longs
@1	MOVE.L	#$01010101,(A0)+
	DBF	D0,@1		% initialize the array
	RTS
end-code mach

% D0: prime counter
% D1: index of numbers to do, also the increment in the inner loop
% D2: the limit in the inner loop
% A1: the index in the inner loop
% A0: address of flags base
% Size: the limit for the index to reach
% D7: the size -which I don't restore. Therefore the FP Stack will float
%	but it'll get reset on the next abort
% D4: just a zero

% I'll rename a bunch of registers with string equates

EQU	PCounter	D0
EQU	ArrayBase	A0
EQU	InnerLimit	D2
EQU	FlagPtr		A1
EQU	(FlagPtr)	(A1)	% remember, these are only string substitutes
EQU	Index		D1
EQU	Increment	D3	% index is also the inc in the inner loop
EQU	Size		D7	% this saves only 9 ticks
EQU	NullFlag	D4	% this saved 10 ticks and brought the
				% time under 2 secs

code primes ( --number of primes) ( does the primes once)
	InitArray			% just what it says
  	MOVEQ.L	#0,PCounter		% init prime counter
	MOVEQ.L	#0,Index		% start with 0

	MOVE.L	#Flags,D7		% in the general case, the VP may
	LEA	0(A5,D7.L),ArrayBase	% be .L. This is how to reference
					% a variable in that case
%	LEA	Flags,ArrayBase		<- this is how you normally do it
	MOVE.L	#TheSize,Size		% keep the size in a register
	MOVEQ.L	#0,NullFlag		% this is real sneaky

@Loop	TST.B	0(A0,D1.L)	% See if Index is a prime
	BEQ.S	@Next		% if it is, try next one
	 MOVE.L	Index,D2	% don't bother flicking if index is >size/4
	 ADD.L	Index,D2		% just increment the prime counter
	 ADDQ.L	#3,D2
	 MOVE.L	D2,Increment
	 ADD.L	Index,D2		% just increment the prime counter
	 CMP.L	Size,D2
	 BGE.S	@Inc			% increment the counter anyways
	    MOVE.L	ArrayBase,InnerLimit
	    ADD.L	Size,InnerLimit	% setting up the flag-flicking loop
	    MOVE.L	ArrayBase,FlagPtr
	    ADDA.L	Index,FlagPtr
	    ADDA.L	Increment,FlagPtr	% the start pt for the inner loop

@InnerLoop	MOVE.B	NullFlag,(FlagPtr)
		ADDA.L	Increment,FlagPtr	% increment to next multiple of index
		CMPA.L	InnerLimit,FlagPtr	% done yet?
		BLE.S	@InnerLoop

@Inc	    ADDQ.L	#1,PCounter	% increment the prime counter
@Next	ADDQ.L	#1,Index
	CMP.L	Size,Index
	BLE.S	@Loop
       MOVE.L	PCounter,-(A6)
       RTS
END-CODE

: sieve 
	COUNTER			( start counting )
	10 0 DO primes LOOP 	( perform 10 iterations )
	TIMER			( stop counting )
        CR . ."   primes"	( print the number of primes )
	 9 0 DO DROP LOOP ;	( clean-up stack )

CR .( Type 'sieve' to execute this benchmark program ) CR
