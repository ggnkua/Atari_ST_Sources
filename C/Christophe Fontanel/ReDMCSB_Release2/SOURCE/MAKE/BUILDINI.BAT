REM Replace C loader object code in the system library used by the Megamax linker
CD \

REM Compile C loader
MMCC.TTP %1\INIT.C
COPY %1\INIT.O %2\INIT.O
DEL %1\INIT.O

REM Disassemble C loader
MMDIS.TTP %2\INIT.O  -o %2\INIT.S

REM Delete current INIT.O from Megamax C system library
MMLIB.TTP dv MEGAMAX\SYSLIB INIT.O

REM Register new INIT.O in Megamax C system library
CD %2
..\..\MMLIB.TTP rv ..\..\MEGAMAX\SYSLIB INIT.O
CD \
