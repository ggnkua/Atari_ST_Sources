**************************
*    Accessory Loader    *
*    By Stuart Burton    *
* ATARI ST USER Marts 89 *
**************************

* Replace CONTROL.ACC with
* the name of your accessory

 PEA PROMPT(PC)    Prompt
 MOVE.W #9,-(SP)   Cconws
 TRAP #1           Gemdos
 ADD.L #6,SP
 PEA CURSOR(PC)    Set cursor
 MOVE.W #9,-(SP)
 TRAP #1
 ADD.L #6,SP       Tidy stack
 PEA OLDNAME(PC)   Filename
 MOVE.W #9,-(SP)
 TRAP #1
 ADD.L #6,SP
INPUT:
 MOVE.W #8,-(SP)   Cnecin
 TRAP #1           Gemdos
 ADD.L #2,SP       Tidy stack
 AND.W #$DF,D0     Upper case
 CMP.W #'Y',D0     Is it Y ?
 BEQ YES
 CMP.W #'N',D0     Is it N ?
 BEQ NO
 BRA INPUT      Loop to INPUT
YES:
 PEA OLDNAME
 PEA NEWNAME
 MOVE.W #0,-(SP)   Dummy
 MOVE.W #$56,-(SP) Rename
 TRAP #1
 ADD.L #12,SP
 BRA FIN
NO:
 PEA NEWNAME
 PEA OLDNAME
 MOVE.W #0,-(SP)   Dummy
 MOVE.W #$56,-(SP) Rename
 TRAP #1
 ADD.L #12,SP
 BRA FIN
FIN:
 MOVE.W #0,-(SP)   Pterm
 TRAP #1
PROMPT:
 DC.B 7
 DC.B '********************',13,10
 DC.B '* Accessory Loader *',13,10
 DC.B '*                  *',13,10
 DC.B '*                  *',13,10
 DC.B '*                  *',13,10
 DC.B '*  Load it (Y/N)?  *',13,10
 DC.B '*                  *',13,10
 DC.B '********************',13,0
NEWNAME:
 DC.B 'CONTROL.ACX',0
 EVEN
OLDNAME:
 DC.B 'CONTROL.ACC',0
 EVEN
CURSOR:
 DC.B 27,'A',27,'A',27,'A',27
 DC.B 'A',27,'C',27,'C',27,'C',0
 EVEN
 END

