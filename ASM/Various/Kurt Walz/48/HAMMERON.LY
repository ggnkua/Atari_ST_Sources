* hier nur hammer angesteuert: bit4_port1 0=aktiv

reset:
 mov  A,  0F0  * disports  disable all ports
 outl p1, A
 mov  A,  0FF
 movd p4, A
 movd p5, A
 movd p6, A
 movd p7, A    alle stepper off
 mov  r0, 7F   oberste RAMadresse
 clr  A
clrRAM:
 mov  @r0,A
 djnz r0, clrRAM
 dec  r0          * ab jetzt r0 als dat_stackpointer verwenden
 
 anl  p1,  0BF  * portson  bit6_p1_set= dis all ports. clr:prinzpEN,aber siehe weitere bits!
* orl  p1,  020  * bit0_clr= dis walze&farbband  bit6_clr= dis schlittn

sloo:
 anl   p1, 0EF   hammer
 call zeitot
 orl   p1, 010
 mov   r5, 0DD
z2lo:
 call zeitot
 djnz  r5, z2lo
 jmp  sloo


*.org 400
* ab hier die subroutines

zeitot:
 call puA7_1
 mov  r7, 2
 mov  r6, 0
ztloo:
 djnz r6, ztloo
 djnz r7, ztloo
 call pop1_7A
 ret

pop2_7A:    * wird benutzt, wenn vorher puA7_1, nun aber neues r1 zu erhalten
 inc r0
 jmp popab2

pop1_7A:
 mov A, @r0
 mov r1,A
 inc r0
popab2:
 mov A, @r0
 mov r2,A
 inc r0
 mov A, @r0
 mov r3,A
 inc r0
 mov A, @r0
 mov r4,A
 inc r0
 mov A, @r0
 mov r5,A
 inc r0
 mov A, @r0
 mov r6,A
 inc r0
 mov A, @r0
 mov r7,A
 inc r0
 mov A, @r0
 inc r0
ret

puA7_1:
 dec r0
 mov @r0,A
 dec r0
 mov A,  r7
 mov @r0,A
 dec r0
 mov A,  r6
 mov @r0,A
 dec r0
 mov A,  r5
 mov @r0,A
 dec r0
 mov A,  r4
 mov @r0,A
 dec r0
 mov A,  r3
 mov @r0,A
 dec r0
 mov A,  r2
 mov @r0,A
 dec r0
 mov A,  r1
 mov @r0,A
*            nun A (und r1) wiederherstellen
 mov A, r0
 add A, #7  zeig Stelle, wo alter A abgelegt
 mov r1,A
 mov A, @r1
 mov r1,A    vorerst in r1 aufheben
 mov A, @r0  altes r1
 xch A, r1
ret


nxfhalf:anl A, 0F
        add A, nxftab   *-> sr !A
        movp A, @A      halfStepVor
        ret

nxbhalf:mov  R7, 07      *-> sr !R7A  7vor=1rÅck
nx7fha: call nxfhalf     halfStepRÅck
nxftab: djnz R7, nx7fha
        ret

.dcb    07 #folgtAuf3(stepr)
.dcb   0FF
.dcb   0FF
.dcb    0E #folgtAuf6
.dcb    06 #folgtAuf7
.dcb   0FF
.dcb    0B #folgtAuf9
.dcb   0FF
.dcb    03 #folgtAufB 
.dcb    0D #folgtAufC
.dcb    09 #folgtAufD
.dcb    0C #folgtAufE

