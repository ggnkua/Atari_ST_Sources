COMPILER "STACK 16384; BAS_MEM 16384; MBS ; TRACE ON; CUTLIB"
IPL 3 SHL 31: PRINT @(0,0);"f"
Version$="02.10.2014"
Name_Prg$="TRANS_H7"
DIM Ctrl%(12),Intin%(128),Addrout%L(128),Intout%(128),Ptsin%(1,128),Ptsout%(1,128),Addrin%L(3),Global%(15)
Intin%L= LPEEK( SEGPTR +20)+ LPEEK( VARPTR(Intin%(0)))
Addrin%L= LPEEK( SEGPTR +20)+ LPEEK( VARPTR(Addrin%L(0)))
Ap_Id%=-1
AES (10,Global%(0),Intin%(11),Addrin%L(0),Intout%(1),Addrout%L(0))
IF Intout%(0)<0 THEN END ENDIF 
Ap_Id%=Intout%(0)
IF COMPILER THEN
Sh_Rpcmd%L= MEMORY( SPC(128))
Sh_Rp_Tail%L= MEMORY( SPC(100))
Intin%(0)=128
Intin%(1)=100
MEMORY_MOVE VARPTR(Sh_Rpcmd%L),8 TO Addrin%L
MEMORY_MOVE VARPTR(Sh_Rp_Tail%L),8 TO Addrin%L+8
AES (120,Global%(0),Intin%(2),Addrin%L(2),Intout%(1),Addrout%L(0))
Rpcmd$=FN Path$(Sh_Rpcmd%L)
WHILE Z%>0: IF PEEK(Sh_Rpcmd%L+Z%)=92 THEN EXIT ENDIF Z%=Z%-1 WEND
IF Z%=0 THEN
Chem_Prg$="a:\"
ELSE
Chem_Prg$= LEFT$(Rpcmd$,Z%+1)
ENDIF
FRE (Sh_Rp_Tail%L)
FRE (Sh_Rpcmd%L)
Accessory%= ABS(Z%=0)
ENDIF
Name_Prg$="TRANS_H7."+ MID$("PRGACC",Accessory%*3+1,3)
COMPILER OFF
Chem_Prg$="b:\"
COMPILER ON
Lang%=1:Lang$="F"
IF Accessory%=0 THEN
ON ERROR GOTO Traite_Err
Init_Prg:Trans_H
Clean_Desktop
Appl_Exit
ON ERROR GOTO 0
END
ENDIF
Me_Text%L= MEMORY("  "+Name_Prg$+" ")
Intin%(0)=Ap_Id%
MEMORY_MOVE VARPTR(Me_Text%L),8 TO Addrin%L
AES (35,Global%(0),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
Acc_Id%=Intout%(0)
IF Acc_Id%=-1 THEN IPL 3: END ENDIF
DIM Msg%(7):Adr_Msg%L= LPEEK( VARPTR(Msg%(0)))
MOUSEON : MOUSEON
REPEAT
MEMORY_MOVE VARPTR(Adr_Msg%L),8 TO Addrin%L
AES (23,Global%(3),Intin%(0),Addrin%L(1),Intout%(7),Addrout%L(0))
Msg%L=Msg%(0)
IF Msg%(4)=Acc_Id% THEN
IF Msg%L=40 THEN
Wind_Update(1):Wind_Update(3)
ON ERROR GOTO Traite_Err
Init_Prg
Trans_H
Clean_Desktop
ON ERROR GOTO 0
Wind_Update(2):Wind_Update(0)
ENDIF
ENDIF
UNTIL 0
DEF PROC Init_Prg
Ctrl%(6)=1
Intin%(0)=1
WPOKE Ctrl%L+12,1
WPOKE Intin%L,1
VDI (100,Ctrl%(0),Intin%(11),Ptsin%(0,0),Intout%(45),Ptsout%(0,0))
IF WPEEK(Ctrl%L+12)<=0 THEN END ENDIF
Vdi_Handle%= WPEEK(Ctrl%L+12)
Pal%L= MEMORY(32): MEMORY_MOVE $FF8240,32 TO Pal%L
WPOKE $FF8240,$FFF: WPOKE $FF8240+2,$F00: WPOKE $FF8240+4,$F: WPOKE $FF8240+6,0: WPOKE $FF8240+30,$0
MOUSEOFF : MODE =1: FILL STYLE =1,0: OUTLINE ON : TEXT HEIGHT =6
DIM Path$(3)
Dta%L= MEMORY(44): GEMDOS (R%L,26, HIGH(Dta%L), LOW(Dta%L))
Inf_Alert$=Name_Prg$+" "+Version$+"  |-----------------------|"
-New_Lang
MOUSEON :Alert(3,"A0",Alert%)
IF Alert%<>3 THEN
Lang%=Alert%
Lang$= MID$("FG",Alert%,1)
GOTO New_Lang
ENDIF
IF Info_Prg%=0 THEN Alert(1,"A1",Dummy%):Alert(1,"A2",Dummy%) ENDIF
Info_Prg%=Info_Prg%=0
RETURN
DEF PROC Clean_Desktop
Ctrl%(6)=Vdi_Handle%: VDI (101,Ctrl%(0),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
MEMORY_MOVE Pal%L,32 TO $FF8240: FRE (Dta%L): FRE (Pal%L):Gabardage
WHILE MOUSEBUT <>0 WEND
RETURN
DEF PROC Trans_H
-Trans_H
Cd%=0
Ext$="H"
-Re_Select
Graf_Mouse(0)
Selecteur( MID$("OPENSAVE",Cd%*4+1,4),Path$(Cd%),Path$(Cd%+2),Ext$,Path$(Cd%),Path$(Cd%+2),Ret%)
IF Ret%=0 THEN IF Cd%=1 THEN Cd%=0:Ext$="H": GOTO Re_Select ELSE RETURN ENDIF ENDIF
IF Cd%=0 THEN
Tail_S%L= LPEEK(Dta%L+26)
Alert(1,"B4",Choix%)
Avec_Sans%= ABS( BIT(1,Choix%))+1
Reduct%= ABS(Choix%=1=0 AND (Choix%=2=-1)-1)
Ext$="RC"+ MID$("123",Choix%,1)
IF Path$(1)="" THEN Path$(1)=Path$(0) ENDIF
Path$(3)=Path$(2)
Cd%=1: GOTO Re_Select
ENDIF
Graf_Mouse(2)
B$=""
OPEN "I",1,Path$(0)+Path$(2)+"H": OPEN "O",2,Path$(1)+Path$(3)+Ext$
WHILE NOT EOF(1)
A%=0:B%=0:Z$="":A$=""
INPUT #1,A$
IF LEFT$(A$,1)="#" THEN
A%= INSTR(A$," ")
B%= INSTR(A%+1,A$," ")
C%=B%
WHILE MID$(A$,C%,1)=" ":C%=C%+1 WEND
IF Avec_Sans%=1 THEN
D%= INSTR(C%,A$,"/*")+1
E%= INSTR(D%+1,A$,"*/")
Z$= MID$(A$,A%+1,B%-A%-1)+"%="+ MID$(A$,C%, INSTR(C%+1,A$," ")-C%)+"' "+ MID$(A$,D%+1,E%-D%-2)+" "
ELSE
Z$= MID$(A$,A%+1,B%-A%-1)+"%="+ MID$(A$,C%, INSTR(C%+1,A$," ")-C%)
ENDIF
IF Reduct%=1 THEN
IF MID$(Z$,1,1)<>"'" THEN
IF ( LEN(B$)+ LEN(Z$)+1)<250 THEN
IF LEN(B$)>0 THEN B$=B$+":"+Z$ ELSE B$=B$+Z$ ENDIF
ELSE
PRINT #2,B$; CHR$(0):B$=Z$
ENDIF
ENDIF
ELSE
PRINT #2,Z$; CHR$(0)
ENDIF
ELSE
A%= INSTR(A$,"/*")
IF A%>0 THEN
B%= INSTR(A%,A$,"*/")
A$="'"+"-"*22+ MID$(A$,A%+2,B%-A%-2)+"-"*22
IF Reduct%<>1 THEN PRINT #2,A$; CHR$(0) ENDIF
ENDIF
ENDIF
Gabardage
WEND
IF Reduct%=1 THEN
IF LEN(B$)>0 THEN PRINT #2,B$; CHR$(0) ENDIF
ENDIF
CLOSE
Gabardage
Graf_Mouse(0)
GOTO "TRANS_H"
RETURN
DEF PROC Selecteur(Apltxt$,Chem$,File$,Ext$,R Chem$,R File$,R Select%)
Gabardage
LOCAL Memo_Chem$=Chem$,Memo_File$=File$
-Selecteur
IF LEN(Chem$)=0 THEN
Chem$=Chem_Prg$:Path$(Cd%)=Chem$:File$=""
Path$(Cd%+2)=""
ELSE
IF File$<>"" THEN File$=File$+Ext$
ENDIF
Chem$=Chem$+"*."+Ext$
Inpath%L= MEMORY(Chem$+ CHR$(0)+ SPC(64- LEN(Chem$)))
Insel%L= MEMORY(File$+ CHR$(0)+ SPC(64- LEN(Lile$)))
Label%L= MEMORY(Apltxt$+" : FICHIER."+Ext$+ CHR$(0))
MEMORY_MOVE VARPTR(Inpath%L),8 TO Addrin%L
MEMORY_MOVE VARPTR(Insel%L),8 TO Addrin%L+4
MEMORY_MOVE VARPTR(Label%L),8 TO Addrin%L+8
AES (91,Global%(0),Intin%(0),Addrin%L(3),Intout%(2),Addrout%L(0))
Select%=Intout%(1)
Chem$=FN Path$(Inpath%L):File$=FN Path$(Insel%L)
FRE (Label%L): FRE (Insel%L): FRE (Inpath%L)
IF Select%=0 THEN
Chem$=Path$(Cd%)
File$=Path$(Cd%+2)
Gabardage
RETURN
ENDIF
Chem$= MIRROR$(Chem$):Chem$= MIRROR$( MID$(Chem$, INSTR(Chem$,"\")))
Ext%= INSTR(File$,"."+Ext$)
IF Ext%>1 THEN
IF MID$(File$,Ext%+1)<>Ext$ THEN
File$=Path$(Cd%+2):Alert(1,"F1",Dummy%): GOTO Selecteur
ENDIF
ELSE
File$=Path$(Cd%+2): GOTO Selecteur
ENDIF
IF Cd%=1 THEN IF File$<>Path$(2)+Ext$ THEN Alert(1,"A6",Dummy%):File$=Path$(2): GOTO Selecteur ENDIF ENDIF
IF NOT FN Find%L THEN Chem$=Path$(Cd%):File$=Path$(Cd%+2): GOTO Selecteur ENDIF
File$= MIRROR$(File$):File$= MIRROR$( MID$(File$, INSTR(File$,".")))
Gabardage
RETURN
DEF FN Path$(Adresse%L)
Z%=0: WHILE PEEK(Adresse%L+Z%)>0:Z%=Z%+1 WEND
Adr$= SPC(Z%)
MEMORY_MOVEB Adresse%L,Z% TO LPEEK( SEGPTR +28)+ LPEEK( VARPTR(Adr$))
RETURN Adr$
DEF FN Find%L
MOUSEON
GEMDOS (Dta%L,47)
Adr%L= MEMORY(Chem$+File$): GEMDOS (R%L,78,L (Adr%L),63): FRE (Adr%L)
IF R%L=0 THEN
IF PEEK(Dta%L+21)=$8 OR PEEK(Dta%L+21)=$10 THEN Alert(1,"S1",Dummy%): RETURN 0 ENDIF
IF Cd%=0 THEN RETURN -1 ENDIF
Alert(1,"R3",Ok%): IF Ok%=2 THEN RETURN 0 ENDIF
Adr%L= MEMORY(Chem$+File$)
GEMDOS (R%L,67,L Adr%L,1,0)
FRE (Adr%L)
IF FN Test_Err%L(0,R%L) THEN RETURN 0 ENDIF
ELSE
IF FN Test_Err%L(-33*Cd%,R%L) THEN RETURN 0 ENDIF
ENDIF
Libre%L= FRE(Chem$)
IF Libre%L<Tail_S%L+1024 THEN
Libre$=" "*(7- LEN( STR$(Libre%L)))+ STR$(Libre%L)
Besoin$=" "*(7- LEN( STR$(Tail_S%L)))+ STR$(Tail_S%L)
Alert(1,"A4",Dummy%)
Libre$=""
RETURN 0
ENDIF
PRINT @(2,0)
Adr%L= MEMORY(Chem$+File$+ CHR$(0))
GEMDOS (Handle%L,60,L Adr%L,0)
PRINT 
FRE (Adr%L)
R%L=Handle%L
IF FN Test_Err%L(0,Handle%L) THEN RETURN 0 ENDIF
GEMDOS (R%L,62,Handle%L)
IF FN Test_Err%L(0,R%L) THEN RETURN 0 ENDIF
RETURN -1
DEF FN Test_Err%L(Apl%L,Apl1%L)
IF Apl%L<>Apl1%L AND Apl1%L<0 THEN
IF Apl1%L=-33 THEN Alert(1,"R2",Dummy%): RETURN -1 ENDIF
IF Apl1%L=-13 THEN Alert(1,"F0",Dummy%): RETURN -1 ENDIF
ERROR 57-Apl1%L*256
RETURN -1
ELSE
RETURN 0
ENDIF
RETURN 0
-Traite_Err
MOUSEON : FORM_ALERT (1,"[3]["+Name_Prg$+"| |"+ ERR$ +"|erreur :"+ STR$( ERR )+"|ligne  :"+ STR$( ERL )+"][Ok]")
RESUME NEXT
DEF PROC Alert(Boutons%,Drapeau$,R R_Alert%):R_Alert%=0: RESTORE Lang$+Drapeau$: READ Alert$,Txt_Alert$,Boton$: MOUSEON : FORM_ALERT (Boutons%,"["+Alert$+"]["+Inf_Alert$+Txt_Alert$+"][ "+Boton$+" ]",R_Alert%): WHILE MOUSEBUT <>0 WEND :Gabardage: RETURN
DEF PROC Appl_Exit: AES (19,Global%(0),Intin%(0),Addrin%L(0),Intout%(1),Addrout%L(0)): RETURN
DEF PROC Graf_Mouse(Intin%(0)): AES (78,Global%(0),Intin%(1),Addrin%L(0),Intout%(1),Addrout%L(1)): RETURN
DEF PROC Wind_Update(X%L)
Intin%(0)=X%L
AES (107,Global%(15),Intin%(1),Addrin%L(0),Intout%(1),Addrout%L(0))
RETURN
DEF PROC Gabardage:Free_Memory%L= FRE(""): RETURN
-Fa0: DATA "0","Transforme les fichiers|ressource "+ CHR$($22)+"H"+ CHR$($22)+" de ORCS.PRG |pour le basic OMIKRON ","FR|GB| Suite"
-Fa1: DATA "0","Basic Omikron 3.01|Compilateur 4.08 |Fontionne aussi en "+ MID$("ACCPRG",Accessory%*3+1,3)+" "," - Suite - "
-Fa2: DATA "0","Contact : |rocky.one@hotmail.fr |"," - Ok - "
-Fa4: DATA "3","Place insufisante|Libre  : "+Libre$+" octets|besoin : "+Besoin$+" octets"," - Abandon - "
-Fa6: DATA "3","Vous ne pouvez pas|modifier le nom du|fichier de sauvegarde"," - Ok - "
-Fb4: DATA "2","RC1 garde les commentaires|RC2 ote les commentaires|RC3 reduction des lignes"," RC1 | RC2 | RC3 "
-Ff1: DATA "2"," |Extention "+ CHR$(34)+Ext$+ CHR$(34)+" obligatoire| "," - Ok - "
-Fr3: DATA "2","Destination "+File$+"|existant| ","êcrasser|Abandon"
-Fs1: DATA "3","Nom dÇjÖ utilisÇ par la|disquette ou par un dossier"," - Abandon - "
-Ff0: DATA "3","Accäs disque imposible|en Çcriture."," - Abandon - "
-Fr2: DATA "3","Pas trouvÇ : "+File$+"|"," - Abandon - "
-Ga0: DATA "0","Transforms the ressource|file "+ CHR$($22)+"H"+ CHR$($22)+" ORCS.PRG |for the basic ˇMIKRON","FR|GB| Suite"
-Ga1: DATA "0","Basic Omikron 3.01|Compiler 4.08 |Also works in "+ MID$("ACCPRG",Accessory%*3+1,3)+" "," - Suite - "
-Ga2: DATA "0","e-mail:|rocky.one@hotmail.fr| "," - Ok - "
-Ga4: DATA "3","Insufisant space|Free : "+Libre$+" bytes|Need : "+Besoin$+" Bytes"," - Abort - "
-Ga6: DATA "3","You can not change the|name of the destination|file"," - Ok - "
-Gb4: DATA "0","RC1 guard comments|RC2 deleted comments|RC3 reduces the lines"," RC1 | RC2 | RC3 "
-Gf1: DATA "2","Mandadory extention|"+ CHR$(34)+Ext$+ CHR$(34)+"| "," - Ok - "
-Gr3: DATA "3","Backup file|"+File$+Ext$+"existing| ","Continue|Abort"
-Gs1: DATA "3","Name already used by|the disk or folder"," - Abort - "
-Gf0: DATA "3","Not disk write access."," - Abort - "
-Gr2: DATA "3","No found : "+File$+"| "," - Abort - "
COMPILER OFF
DEF PROC C: IPL 3: CLS : EXEC "A:\COMPILER.PRG","M:\TRANS_H7.BAS": RETURN
DEF PROC D: IPL 3: CLS : EXEC "A:\CUTLIB2.PRG","M:\TRANS_H7.PRG -NNN": RETURN
COMPILER ON
