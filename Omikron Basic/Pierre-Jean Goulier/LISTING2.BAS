0 CLEAR 100000: XBIOS (Rez%,4)
1 IF Rez%=0 THEN CLIP 0,0,320,200:Ext$="PI1":Np%=4
2 IF Rez%=1 THEN CLIP 0,0,640,200:Ext$="PI2":Np%=2
3 IF Rez%=2 THEN CLIP 0,0,640,400:Ext$="PI3":Np%=1
4 MODE =1: CLS : PRINT CHR$(27);"f";
5 OPEN "U",1,"BLOCS.BIT"
6 '
7 Degas= MEMORY(33000):Ch$="*."+Ext$:Nom$=""
8 MOUSEON
9 REPEAT
10   FILESELECT (Ch$,Nom$,R%)
11   IF R%=0 THEN END
12 UNTIL Nom$<>""
13 L%= LEN(Ch$)
14 REPEAT :L%=L%-1: UNTIL MID$(Ch$,L%,1)="\"
15 Nom$= LEFT$(Ch$,L%)+Nom$: BLOAD Nom$,Degas
16 FOR I%=0 TO 15
17   XBIOS (,7,I%, WPEEK(Degas+2+I%*2) AND $777)
18 NEXT I%
19 MOUSEOFF
20 MEMORY_MOVE Degas+34,32000 TO LPEEK($44E)
21 '
22-Boucle
23 MOUSEON
24 REPEAT
25   Xo%= MOUSEX :Yo%= MOUSEY
26   IF MOUSEBUT =2 THEN GOTO Lecture
27 UNTIL MOUSEBUT =1
28 MODE =3: LINE STYLE =5: MOUSEOFF
29 WHILE MOUSEBUT <>0
30   X%= MOUSEX :Y%= MOUSEY
31   L%= ABS(Xo%-X%):H%= ABS(Yo%-Y%)
32   BOX Xo%,Yo%,L%,H%: BOX Xo%,Yo%,L%,H%
33 WEND
34 LINE STYLE =1: MODE =1
35 Taille=6+(L%+15) SHR 4*2*H%*Np%
36 Buffer= MEMORY(Taille)
37 BITBLT Xo%,Yo%,L%,H% TO Buffer
38 PUT 1, MKI$(Taille): PUT 1,Buffer,Taille
39 FRE (Buffer):Nb%=Nb%+1: GOTO Boucle
40 '
41-Lecture
42 MOUSEOFF : CLS : PRINT CHR$(27);"e";
43 REPEAT
44   N$=""
45   INPUT @(2,2);"No du bloc : ";N$ USING "0",R,2
46   IF N$="" THEN CLS : CLOSE : END
47   N%= VAL(N$)
48 UNTIL N%>0 AND N%<=Nb%
49 CLS : PRINT CHR$(27);"f";
50 SEEK 1,0
51 FOR I%=1 TO N%-1
52   GET 1,A$,2:Taille= CVI(A$)
53   SEEK 1,Taille,1
54 NEXT I%
55 GET 1,A$,2
56 Taille= CVI(A$):Buffer= MEMORY(Taille)
57 GET 1,Buffer,Taille
58 L%= WPEEK(Buffer+2):H%= WPEEK(Buffer+4)
59 BITBLT Buffer TO 0,0,L%,H%
60 MOUSEON : REPEAT UNTIL MOUSEBUT
61 WHILE MOUSEBUT : WEND
62 FRE (Buffer): GOTO Lecture
