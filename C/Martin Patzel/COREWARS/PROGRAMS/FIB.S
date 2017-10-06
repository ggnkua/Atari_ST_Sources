start:
        MOV     fib1,fib3
        ADD     fib2,fib3
        MOV     fib3,@fib3
        MOV     fib2,fib1
        MOV     fib3,fib2
        JMP     start
fib1    DAT     1
fib2    DAT     1
fib3    DAT     0
