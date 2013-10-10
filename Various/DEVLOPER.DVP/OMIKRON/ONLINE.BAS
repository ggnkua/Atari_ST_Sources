 '
 ' Teste par Bcostat si l'imprimante est prˆte
 ' OMIKRON-BASIC      ONLINE.BAS
 '
 BIOS (Status%L,8,0)
 IF Status%L=-1
   THEN PRINT "L'imprimante est prˆte!"
   ELSE PRINT "L'imprimante n'est pas prˆte!"
 ENDIF
 END
