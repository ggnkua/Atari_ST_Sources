 Address Objectcode  Line    Sourcetext RYES_PNO.S Assembled in PC-relative mode                                

000000 :                1   ; Program Name: RYES_PNO.S
000000 :                2
000000 :                3   ; Assembly Instructions:
000000 :                4
000000 :                5   ;    The algorithms in this program can be assembled in Relocatable or
000000 :                6   ; PC-relative mode.  But when they are assembled in PC-relative mode, the
000000 :                7   ; code is not always what we want.
000000 :                8
000000 :                9   ; Experiment 1.
000000 :               10
000000 :               11   ;    Shows that a pointer, declared in the data section, to a variable
000000 :               12   ; declared in the bss section will contain the correct address when
000000 :               13   ; assembly is in Relocatable mode; but when assembled in PC-relative mode,
000000 :               14   ; the pointer will contain the location at which the variable resided
000000 :               15   ; during the assembly process.
000000 :               16
000000 :207A002E       17   movea.l   _variable, a0       ; A pointer to a variable is loaded into
000004 :               18                                 ; an address register.
000004 :               19   ; End of Experiment 1.
000004 :               20
000004 :               21   ; Experiment 2.
000004 :               22
000004 :               23   ;    Illustrates that the instructions
000004 :               24
000004 :               25   ;         move.l #label, -(sp)
000004 :               26   ;         move.l #label, An
000004 :               27
000004 :               28   ; are not compatible with assembly in the PC-relative mode, and that
000004 :               29   ; the following instructions must be used instead.
000004 :               30
000004 :               31   ;         pea    label
000004 :               32   ;         lea    label.
000004 :               33
000004 :2F3C0000002C   34   move.l    #label_1, -(sp)
00000A :207C0000002C   35   move.l    #label_1, a0
000010 :2F3C00000034   36   move.l    #label_2, -(sp)
000016 :227C00000034   37   move.l    #label_2, a1
00001C :               38
00001C :487A000E       39   pea       label_1
000020 :41FA000A       40   lea       label_1, a0
000024 :487A000E       41   pea       label_2
000028 :43FA000A       42   lea       label_2, a1
00002C :               43
00002C :               44   ; End of Experiment 2.
00002C :               45
00002C :               46   data
00002C :00000001       47  label_1:   dc.l      1
000030 :00000038       48  _variable: dc.l variable       ; _variable is a pointer to variable.
000034 :               49   bss
000034 : ^     4       50  label_2:   ds.l      1
000038 : ^     4       51  variable:  ds.l      1         ; During loading, we want the address of
00003C :               52                                 ; this variable to be stored in the
00003C :               53                                 ; location addressed by the pointer.
00003C :               54   end
