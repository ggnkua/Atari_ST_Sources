make -DTARGET=%1
%1 -l test.out %1.tst
fc test.out %1.tut
