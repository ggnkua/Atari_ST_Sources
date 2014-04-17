 ; Program Name: RYES_PNO.S
 ;          aka: PRG_2BR.S

 ; Assembly Instructions:

 ;    The algorithms in this program can be assembled in Relocatable or
 ; PC-relative mode.  But when they are assembled in PC-relative mode, the
 ; code is not always what we want.

 ; Experiment 1.

 ;    Shows that a pointer, declared in the data section, to a variable
 ; declared in the bss section will contain the correct address when
 ; assembly is in Relocatable mode; but when assembled in PC-relative mode,
 ; the pointer will contain the location at which the variable resided
 ; during the assembly process.

 movea.l   _variable, a0       ; A pointer to a variable is loaded into
                               ; an address register.
 ; End of Experiment 1.

 ; Experiment 2.

 ;    Illustrates that the instructions

 ;         move.l #label, -(sp)
 ;         move.l #label, An

 ; are not compatible with assembly in the PC-relative mode, and that
 ; the following instructions must be used instead.

 ;         pea    label
 ;         lea    label.

 move.l    #label_1, -(sp)
 move.l    #label_1, a0
 move.l    #label_2, -(sp)
 move.l    #label_2, a1

 pea       label_1
 lea       label_1, a0
 pea       label_2
 lea       label_2, a1

 ; End of Experiment 2.

 data
label_1:   dc.l      1
_variable: dc.l variable       ; _variable is a pointer to variable.
 bss
label_2:   ds.l      1
variable:  ds.l      1         ; During loading, we want the address of
                               ; this variable to be stored in the
                               ; location addressed by the pointer.
 end

