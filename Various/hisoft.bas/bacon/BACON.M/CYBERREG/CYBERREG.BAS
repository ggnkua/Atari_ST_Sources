
' [CYBERREG.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1998 Matthew Bacon & Paul Jones

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

DEFINT a-z

REM $include F:\CADENZA\CYBERREG\cyberreg.bh

REM $include F:\CADENZA\CYBERREG\toolbx_a.bas
REM $include F:\ENCHANT\MODULES\cursor.bas
REM $include F:\ENCHANT\MODULES\error.bas
REM $include F:\ENCHANT\MODULES\file.bas
REM $include F:\ENCHANT\MODULES\printer.bas
REM $include F:\ENCHANT\MODULES\st-guide.bas

MyProgram$="CyberReg"
CALL StartProgram (CURDIR$+"\cyberreg.RSC",FORM_MENU,MENU_QUIT,FORM_ICONIFY)

REM $include F:\CADENZA\CYBERREG\init.bas

CALL xENCHANTloop
CALL StopProgram

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

REM $include F:\CADENZA\CYBERREG\user.bas
REM $include F:\CADENZA\CYBERREG\form.bas
REM $include F:\CADENZA\CYBERREG\summary.bas
REM $include F:\CADENZA\CYBERREG\software.bas
REM $include F:\CADENZA\CYBERREG\print.bas

'[*END OF FILE*]

