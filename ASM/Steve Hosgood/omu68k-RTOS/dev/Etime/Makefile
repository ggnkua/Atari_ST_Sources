timehand: time.o rtc.o
	ld -x -r -o timehand time.o rtc.o

time.o: time.c time.h
	cc -c -OPS time.c

rtc.o: rtc.c rtc.h
	cc -c -OPS rtc.c
