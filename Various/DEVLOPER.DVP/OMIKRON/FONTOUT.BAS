 '  Affichage de tous les caractŠres par Bconout
 '  OMIKRON-BASIC       FONTOUT.BAS
 '
 BIOS (,3,2,27): BIOS (,3,2, ASC("E")): REM Escape + E = effacer l'‚cran
 '
 FOR Char%=0 TO 255
   IF Char% MOD 16=0
     THEN BIOS (,3,2,13): REM 13 + 10 = Return + saut de ligne
          BIOS (,3,2,10)
     ENDIF
   BIOS (,3,5,Char%): REM fonction 3 (Bconout), p‚riph‚rique 5 (canal ASCII)
   BIOS (,3,5,32): REM espaces
 NEXT Char%
 '
 PRINT @(20,1);"La police de caractŠres de l'ATARI ST"
 END
 '
