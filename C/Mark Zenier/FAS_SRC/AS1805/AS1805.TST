	org 2300h
expr	equ *
immed	equ $55
	 adc
	 adci # immed
	 add
	 adi # immed
	 and
	 ani # immed
	 b1 expr
	 b2 expr
	 b3 expr
	 b4 expr
	 bci expr
	 bdf expr
	 bge expr
	 bl expr
	 bm expr
	 bn1 expr
	 bn2 expr
	 bn3 expr
	 bn4 expr
	 bnf expr
	 bnq expr
	 bnz expr
	 bpz expr
	 bq expr
	 br expr
	 bxi expr
	 bz expr
	 cid
	 cie
	 daci # immed
	 dadc
	 dadd
	 dadi # immed
	 dbnz 0 , expr
	 dbnz 1 , expr
	 dbnz 10 , expr
	 dbnz 11 , expr
	 dbnz 12 , expr
	 dbnz 13 , expr
	 dbnz 14 , expr
	 dbnz 15 , expr
	 dbnz 2 , expr
	 dbnz 3 , expr
	 dbnz 4 , expr
	 dbnz 5 , expr
	 dbnz 6 , expr
	 dbnz 7 , expr
	 dbnz 8 , expr
	 dbnz 9 , expr
	 dec 0
	 dec 1
	 dec 10
	 dec 11
	 dec 12
	 dec 13
	 dec 14
	 dec 15
	 dec 2
	 dec 3
	 dec 4
	 dec 5
	 dec 6
	 dec 7
	 dec 8
	 dec 9
	 dis
	 dsav
	 dsbi # immed
	 dsm
	 dsmb
	 dsmi # immed
	 dtc
	 etq
	 gec
	 ghi 0
	 ghi 1
	 ghi 10
	 ghi 11
	 ghi 12
	 ghi 13
	 ghi 14
	 ghi 15
	 ghi 2
	 ghi 3
	 ghi 4
	 ghi 5
	 ghi 6
	 ghi 7
	 ghi 8
	 ghi 9
	 glo 0
	 glo 1
	 glo 10
	 glo 11
	 glo 12
	 glo 13
	 glo 14
	 glo 15
	 glo 2
	 glo 3
	 glo 4
	 glo 5
	 glo 6
	 glo 7
	 glo 8
	 glo 9
	 idl
	 inc 0
	 inc 1
	 inc 10
	 inc 11
	 inc 12
	 inc 13
	 inc 14
	 inc 15
	 inc 2
	 inc 3
	 inc 4
	 inc 5
	 inc 6
	 inc 7
	 inc 8
	 inc 9
	 inp 1
	 inp 2
	 inp 3
	 inp 4
	 inp 5
	 inp 6
	 inp 7
	 irx
	 lbdf expr
	 lbnf expr
	 lbnq expr
	 lbnz expr
	 lbq expr
	 lbr expr
	 lbz expr
	 lda 0
	 lda 1
	 lda 10
	 lda 11
	 lda 12
	 lda 13
	 lda 14
	 lda 15
	 lda 2
	 lda 3
	 lda 4
	 lda 5
	 lda 6
	 lda 7
	 lda 8
	 lda 9
	 ldc
	 ldi # immed
	 ldn 1
	 ldn 10
	 ldn 11
	 ldn 12
	 ldn 13
	 ldn 14
	 ldn 15
	 ldn 2
	 ldn 3
	 ldn 4
	 ldn 5
	 ldn 6
	 ldn 7
	 ldn 8
	 ldn 9
	 ldx
	 ldxa
	 lsdf
	 lsie
	 lskp
	 lsnf
	 lsnq
	 lsnz
	 lsq
	 lsz
	 mark
	 nbr *+3
	 nlbr expr
	 nop
	 or
	 ori # immed
	 out 1
	 out 2
	 out 3
	 out 4
	 out 5
	 out 6
	 out 7
	 phi 0
	 phi 1
	 phi 10
	 phi 11
	 phi 12
	 phi 13
	 phi 14
	 phi 15
	 phi 2
	 phi 3
	 phi 4
	 phi 5
	 phi 6
	 phi 7
	 phi 8
	 phi 9
	 plo 0
	 plo 1
	 plo 10
	 plo 11
	 plo 12
	 plo 13
	 plo 14
	 plo 15
	 plo 2
	 plo 3
	 plo 4
	 plo 5
	 plo 6
	 plo 7
	 plo 8
	 plo 9
	 req
	 ret
	 rldi 0 , # expr
	 rldi 1 , # expr
	 rldi 10 , # expr
	 rldi 11 , # expr
	 rldi 12 , # expr
	 rldi 13 , # expr
	 rldi 14 , # expr
	 rldi 15 , # expr
	 rldi 2 , # expr
	 rldi 3 , # expr
	 rldi 4 , # expr
	 rldi 5 , # expr
	 rldi 6 , # expr
	 rldi 7 , # expr
	 rldi 8 , # expr
	 rldi 9 , # expr
	 rlxa 0
	 rlxa 1
	 rlxa 10
	 rlxa 11
	 rlxa 12
	 rlxa 13
	 rlxa 14
	 rlxa 15
	 rlxa 2
	 rlxa 3
	 rlxa 4
	 rlxa 5
	 rlxa 6
	 rlxa 7
	 rlxa 8
	 rlxa 9
	 rnx 0
	 rnx 1
	 rnx 10
	 rnx 11
	 rnx 12
	 rnx 13
	 rnx 14
	 rnx 15
	 rnx 2
	 rnx 3
	 rnx 4
	 rnx 5
	 rnx 6
	 rnx 7
	 rnx 8
	 rnx 9
	 rshl
	 rshr
	 rsxd 0
	 rsxd 1
	 rsxd 10
	 rsxd 11
	 rsxd 12
	 rsxd 13
	 rsxd 14
	 rsxd 15
	 rsxd 2
	 rsxd 3
	 rsxd 4
	 rsxd 5
	 rsxd 6
	 rsxd 7
	 rsxd 8
	 rsxd 9
	 sav
	 scal 0 , expr
	 scal 1 , expr
	 scal 10 , expr
	 scal 11 , expr
	 scal 12 , expr
	 scal 13 , expr
	 scal 14 , expr
	 scal 15 , expr
	 scal 2 , expr
	 scal 3 , expr
	 scal 4 , expr
	 scal 5 , expr
	 scal 6 , expr
	 scal 7 , expr
	 scal 8 , expr
	 scal 9 , expr
	 scm1
	 scm2
	 sd
	 sdb
	 sdbi # immed
	 sdi # immed
	 sep 0
	 sep 1
	 sep 10
	 sep 11
	 sep 12
	 sep 13
	 sep 14
	 sep 15
	 sep 2
	 sep 3
	 sep 4
	 sep 5
	 sep 6
	 sep 7
	 sep 8
	 sep 9
	 seq
	 sex 0
	 sex 1
	 sex 10
	 sex 11
	 sex 12
	 sex 13
	 sex 14
	 sex 15
	 sex 2
	 sex 3
	 sex 4
	 sex 5
	 sex 6
	 sex 7
	 sex 8
	 sex 9
	 shl
	 shlc
	 shr
	 shrc
	 skp
	 sm
	 smb
	 smbi # immed
	 smi # immed
	 spm1
	 spm2
	 sret 0
	 sret 1
	 sret 10
	 sret 11
	 sret 12
	 sret 13
	 sret 14
	 sret 15
	 sret 2
	 sret 3
	 sret 4
	 sret 5
	 sret 6
	 sret 7
	 sret 8
	 sret 9
	 stm
	 stpc
	 str 0
	 str 1
	 str 10
	 str 11
	 str 12
	 str 13
	 str 14
	 str 15
	 str 2
	 str 3
	 str 4
	 str 5
	 str 6
	 str 7
	 str 8
	 str 9
	 stxd
	 xid
	 xie
	 xor
	 xri # immed
