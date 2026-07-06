( Some utility code words which are not part of the standard )
( but which are useful and really easy to implement on a 68000 )

code lnot ( dnum --- ~dnum ) long sp ) not  c;
code cnot ( char --- ~char ) byte sp ) not  c;

code << ( num cnt --- num<<cnt ) ( left shift )
  sp )+ d0 move  sp )+ d1 move  d0 d1 lsl  d1 sp -) move
c;

code >> ( num cnt --- num>>cnt ) ( right shift )
  sp )+ d0 move  sp )+ d1 move  d0 d1 lsr  d1 sp -) move
c;

code <<a ( num cnt --- num<<cnt ) ( left shift arithmetic )
  sp )+ d0 move  sp )+ d1 move  d0 d1 asl  d1 sp -) move
c;

code >>a ( num cnt --- num>>cnt ) ( right shift arithmetic )
  sp )+ d0 move  sp )+ d1 move  d0 d1 asr  d1 sp -) move
c;
code l<< ( d cnt --- d<<cnt ) ( left shift )
  sp )+ d0 move  long sp )+ d1 move  d0 d1 lsl  d1 sp -) move
c;

code l>> ( d cnt --- d>>cnt ) ( right shift )
  sp )+ d0 move  long sp )+ d1 move  d0 d1 lsr  d1 sp -) move
c;

code l<<a ( d cnt --- d<<cnt ) ( left shift arithmetic )
  sp )+ d0 move  long sp )+ d1 move  d0 d1 asl  d1 sp -) move
c;

code l>>a ( d cnt --- d>>cnt ) ( right shift arithmetic )
  sp )+ d0 move  long sp )+ d1 move  d0 d1 asr  d1 sp -) move
c;
