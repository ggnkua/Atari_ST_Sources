0 '
1 ' Easy-Windows.
2 ' Fenˆtres textes : Programme de d‚mo No 4.
3 '                   Affichage d'un catalogue. S‚lection d'une ligne.
4 '
5 ' Auteur Easy-Windows : Pierre-Jean Goulier.
6 ' ½ Start Micro & P-Jean Goulier.
7 '
8 ON ERROR GOTO Erreur
9 '
10 Easy_Init
11 Win_Getwork(Desktop%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
12 Twin_Open(F1%L,Xdesk%L,Ydesk%L,Wdesk%L\2,Hdesk%L,37,100,"CATALOGUE","",G_All%L)
13 Twin_Open(F2%L,Xdesk%L+Wdesk%L\2,Ydesk%L,Wdesk%L\2,Hdesk%L,100,100,"VOIR","",G_All%L-G_Close%L)
14 Twin_Cls(F1%L):Twin_Cls(F2%L):Win_Top(F1%L): DIM T$(500)
15 '
16 Easy_Fsel(Nom$,Index$,"Choisissez un chemin",Cancel%L)
17 Get_Path(Path$):Ch$=Path$+Index$:Dir(Ch$,Nb_Fic%)
18 Win_Info(F1%L,Ch$)
19 '
20 FOR I%=0 TO Nb_Fic%:Twin_Iprint(F1%L,T$(I%)): NEXT I%
21 Twin_Print(F1%L, MID$( STR$(Nb_Fic%),2)+" fichiers")
22 '
23 REPEAT
24   Easy_Mesag(Dummy%L,X$,Mx%L,My%L,Mb%L,Shift%L)
25   Win_Domessages(X$)
26   IF Mb%L=1 AND Shift%L=8 THEN
27     Win_Mousepos(Fen%L,Mx%L,My%L,C%L,L%L)
28     IF Fen%L=F1%L THEN
29       F$=FN Twin_Getline$(F1%L,L%L)
30       IF F$<>"" AND L%L<Nb_Fic% THEN
31         Twin_Select(F1%L,L%L,1)
32         Get_Infofile(Path$+F$,Size%L,D$,H$,Att%L)
33         IF BIT(4,Att%L) THEN Att$="Dossier" ELSE Att$="Fichier"
34         IF BIT(0,Att%L) THEN Att$=Att$+" prot‚g‚." ELSE Att$=Att$+" libre."
35         FORM_ALERT (1,"[3][Nom    : "+F$+"|Taille :"+ STR$(Size%L)+"|Date   : "+D$+"|Heure  : "+H$+"|Statut : "+Att$+"][OK]")
36         Twin_Select(F1%L,L%L,0)
37       ENDIF
38     ENDIF
39   ENDIF
40   IF Mb%L=2 THEN
41     Win_Mousepos(Fen%L,Mx%L,My%L,C%L,L%L)
42     IF Fen%L=F1%L THEN
43       Easy_Fsel(Nom$,Index$,"Choisissez un chemin",Cancel%L)
44       Get_Path(Path$):Ch$=Path$+Index$:Dir(Ch$,Nb_Fic%)
45       Win_Info(F1%L,Ch$):Win_Top(F1%L):Twin_Cls(F1%L)
46       FOR I%=0 TO Nb_Fic%:Twin_Iprint(F1%L,T$(I%)): NEXT I%
47       Twin_Print(F1%L, MID$( STR$(Nb_Fic%),2)+" fichiers"):Win_Redraw(F1%L)
48     ENDIF
49     WHILE MOUSEBUT : WEND
50   ENDIF
51   IF Mb%L=1 AND Shift%L=4 THEN
52     Win_Mousepos(Fen%L,Mx%L,My%L,C%L,L%L)
53     IF Fen%L=F1%L THEN
54       F$=FN Twin_Getline$(F1%L,L%L)
55       IF F$<>"" AND L%L<Nb_Fic% THEN
56         F$=Path$+F$:Get_Infofile(F$,Size%L,D$,H$,Att%)
57         IF NOT BIT(4,Att%) THEN
58           Twin_Select(F1%L,L%L,1)::Twin_Cls(F2%L)
59           OPEN "I",1,F$
60           WHILE NOT EOF(1)
61             LINE INPUT #1,A$:Twin_Iprint(F2%L,A$)
62           WEND
63           CLOSE 1
64           Twin_Select(F1%L,L%L,0):Win_Redraw(F2%L):Win_Info(F2%L,F$)
65         ENDIF
66       ENDIF
67     ENDIF
68   ENDIF
69 UNTIL FN Win_Closed%L(F1%L)
70 '
71-Fin
72 Easy_Exit
73 IF COMPILER THEN SYSTEM ELSE EDIT
74 '
75 DEF PROC Dir(Ch$,R Nb_Fic%)
76   LOCAL Nom$,I%
77   FOR I%=0 TO 500:T$(I%)="": NEXT I%:Nb_Fic%=0
78   OPEN "F",16,Ch$,63
79   REPEAT
80     GET 16,1: IF EOF(16) THEN EXIT
81     FIELD 16,21,1 AS Att$,2 AS Tim$,2 AS Dat$,4 AS Len$,14 AS Name$
82     Nom$= LEFT$(Name$, INSTR(Name$, CHR$(0))-1)
83     IF Nom$<>"." AND Nom$<>".." THEN T$(Nb_Fic%)=Nom$:Nb_Fic%=Nb_Fic%+1
84   UNTIL 0
85   CLOSE 16
86   SORT T$(Nb_Fic%)
87 RETURN
88 '
89-Erreur
90   IF ERR =62 THEN
91     FORM_ALERT (1,"[2][|Fichier illisible !|Ce n'est pas un fichier ASCII.][OK]")
92     RESUME NEXT
93   ENDIF
94   FORM_ALERT (1,"[2][|Erreur : "+ ERR$ +"|Ligne  :"+ STR$( ERL )+"][???]")
95   RESUME Fin
