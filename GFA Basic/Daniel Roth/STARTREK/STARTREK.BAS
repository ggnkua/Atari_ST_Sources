0 ' STar Treck 1.0
1 '
2 ' fÅr alle Raumschiff Enterprise Fans
3 '
4 ' nach Computer-Kurzweil von A.K.Dewdney
5 ' aus Spektrum der Wissenschaft Januar 1987
6 '
7 ' programmiert von Daniel Roth - sinccom software
8 ' auf ATARI ST unter Omikron Basic
9 ' Adresse: BrÅcker Mauspfad 448
10 '          D-5000 Kîln 91
11 '
12 '
13 ' Zentrierte Ausagbe von Text$
14 '
15 DEF FN Zen$(Text$)= SPACE$((80- LEN(Text$))/2)+Text$
16 '
17 ' Initialisierungen
18 '
19 ' weiûe Schrift, schwarzer Bildschirm
20 '
21 PRINT CHR$(27);"b0"; CHR$(27);"c1";
22 '
23 ' Cursor ausschalten
24 '
25 PRINT CHR$(27);"f";
26 '
27 ' Tastaturklick ausschalten
28 '
29 POKE $484,10
30 '
31 ' Winkelberechnungen in Altgrad
32 '
33 DEG
34 '
35 ' Kraftfunktion
36 '
37 DEF FN Kraft!(Abstand!)=800/Abstand!^2
38 '
39 ' Geschwindigkeiten und Positionen
40 '
41 DIM Vel!(22,2),Pos!(22,2),Apos!(22,2)
42 '
43 ' Alter, Zustand der Torpedos
44 '
45 DIM Zeit%L(22),Aus%L(22),Zug%L(22)
46 '
47 DIM Torp%L(2),Schub%L(2),Rechts%L(2),Links%L(2),Orient%L(2),Aorient%L(2),Feuer%L(2),Treib!(2),C%L(2)
48 '
49 ' Erfîffnung
50 '
51-Eroeffnung
52 CLS
53 PRINT
54 PRINT FN Zen$("STar Treck")
55 PRINT
56 PRINT FN Zen$("nach Computer-Kurzweil von A.K.Dewdney")
57 PRINT FN Zen$("aus Spektrum der Wissenschaft Januar 1987")
58 PRINT
59 PRINT FN Zen$("programmiert von Daniel Roth - sinccom software")
60 PRINT
61 PRINT
62 PRINT FN Zen$("Steuerung des Raumschiffes der Fîderation:")
63 PRINT
64 PRINT "   A - Schub","S - Drehung links","D - Drehung rechts","F - Feuer"
65 PRINT
66 PRINT
67 PRINT FN Zen$("Steuerung des Raumschiffes der Klingonen:")
68 PRINT
69 PRINT "   4 - Schub","5 - Drehung links","6 - Drehung rechts","+ - Feuer"
70 PRINT
71 PRINT
72 PRINT
73 PRINT FN Zen$("Zum Start: Taste drÅcken!")
74 REPEAT Taste$= INKEY$ UNTIL Taste$<>""
75 IF ASC( MID$(Taste$,2,1))=$61 THEN
76   PRINT CHR$(27);"b1"; CHR$(27);"c0"
77   POKE $484,15
78   END
79 ENDIF
80 CLS
81 LINE COLOR =0:C%L(1)=1:C%L(2)=1
82 FILL COLOR =0
83 PCIRCLE 320,200,10
84 '
85 ' Aktive Torpedos
86 '
87 Torpak%L=0
88 '
89 ' Orientierungen von Fîderations- und Klingonenschiff
90 ' 0-Osten, 90-Norden, ...
91 '
92 Orient%L(1)=0:Aorient%L(1)=0:Orient%L(2)=180:Aorient%L(2)=180
93 '
94 ' TreibstoffvorrÑte
95 '
96 Treib!(1)=10:Treib!(2)=10
97 '
98 ' Geschwindigkeiten und Positionen lîschen
99 '
100 FOR I%L=1 TO 22
101   Vel!(I%L,1)=0:Vel!(I%L,2)=0:Pos!(I%L,1)=0:Pos!(I%L,2)=0:Apos!(I%L,1)=0:Apos!(I%L,2)=0
102 NEXT I%L
103 '
104 ' Torpedozeiten und ZustÑnde lîschen
105 '
106 FOR I%L=1 TO 22
107   Zeit%L(I%L)=0:Aus%L(I%L)=0:Zug%L(I%L)=0
108 NEXT I%L
109 '
110 ' Zeiger innerhalb zirkulÑrer Warteschlange der Torpedos
111 '
112 Alt%L=3:Neu%L=3
113 '
114 ' Startpositionen der Raumschiffe
115 '
116 Pos!(1,1)=100:Pos!(1,2)=200
117 Pos!(2,1)=540:Pos!(2,2)=200
118 '
119 Torp%L(1)=0:Torp%L(2)=0:Torpak%L=0
120 '
121-Start
122 Taste$= INKEY$
123 IF Taste$<>"" THEN
124   Scan%L= ASC( MID$(Taste$,2,1))
125   IF Scan%L=$1E THEN Schub%L(1)=1
126   IF Scan%L=$1F THEN Rechts%L(1)=1
127   IF Scan%L=$20 THEN Links%L(1)=1
128   IF Scan%L=$21 AND Torp%L(1)<10 THEN Feuer%L(1)=1:Torpak%L=Torpak%L+1:Torp%L(1)=Torp%L(1)+1
129   IF Scan%L=$6A THEN Schub%L(2)=1
130   IF Scan%L=$6B THEN Rechts%L(2)=1
131   IF Scan%L=$6C THEN Links%L(2)=1
132   IF Scan%L=$4E AND Torp%L(2)<10 THEN Feuer%L(2)=1:Torpak%L=Torpak%L+1:Torp%L(2)=Torp%L(2)+1
133 ENDIF
134 '
135 FOR I%L=1 TO 2
136   X!=Pos!(I%L,1):Y!=Pos!(I%L,2)
137   Abstand!= SQR((X!-320)^2+(Y!-200)^2)
138   IF Abstand!<10 THEN
139     IF I%L=1 THEN
140       PRINT "Das Raumschiff der Fîderation ist in der Sonne verglÅht!"
141     ELSE
142       PRINT "Das Raumschiff der Klingonen ist in der Sonne verglÅht!"
143     ENDIF
144     WAIT 2
145     REPEAT UNTIL INKEY$ =""
146     REPEAT UNTIL INKEY$ <>""
147     EXIT TO Eroeffnung
148   ENDIF
149   Kraft!=FN Kraft!(Abstand!)
150   IF Schub%L(I%L)=1 THEN
151     Schub%L(I%L)=0
152     IF Treib!(I%L)>1 THEN
153       Treib!(I%L)=Treib!(I%L)-.1
154       Vel!(I%L,1)=Vel!(I%L,1)+ COS(Orient%L(I%L))
155       Vel!(I%L,2)=Vel!(I%L,2)+ SIN(Orient%L(I%L))
156     ENDIF
157   ENDIF
158   IF Links%L(I%L)=1 THEN
159     Links%L(I%L)=0
160     Aorient%L(I%L)=Orient%L(I%L)
161     Orient%L(I%L)=Orient%L(I%L)+90: IF Orient%L(I%L)=360 THEN Orient%L(I%L)=0
162   ENDIF
163   IF Rechts%L(I%L)=1 THEN
164     Rechts%L(I%L)=0
165     Aorient%L(I%L)=Orient%L(I%L)
166     Orient%L(I%L)=Orient%L(I%L)-90: IF Orient%L(I%L)=-90 THEN Orient%L(I%L)=270
167   ENDIF
168   Vel!(I%L,1)=Vel!(I%L,1)-Kraft!*(X!-320)/Abstand!
169   Vel!(I%L,2)=Vel!(I%L,2)-Kraft!*(Y!-200)/Abstand!
170   Schiff(I%L,Apos!(I%L,1),Apos!(I%L,2),Aorient%L(I%L))
171   Pos!(I%L,1)=X!+Vel!(I%L,1):Pos!(I%L,1)=Pos!(I%L,1)- INT(Pos!(I%L,1)/640)*640
172   Pos!(I%L,2)=Y!+Vel!(I%L,2):Pos!(I%L,2)=Pos!(I%L,2)- INT(Pos!(I%L,2)/400)*400
173   Schiff(I%L,Pos!(I%L,1),Pos!(I%L,2),Orient%L(I%L))
174   Apos!(I%L,1)=Pos!(I%L,1):Apos!(I%L,2)=Pos!(I%L,2):Aorient%L(I%L)=Orient%L(I%L)
175   IF Feuer%L(I%L)=1 THEN
176     Feuer%L(I%L)=0:Zug%L(Neu%L)=I%L
177     NOISE 1,6*I%L: VOLUME 1,15,1000
178     Pos!(Neu%L,1)=Pos!(I%L,1)+6* COS(Orient%L(I%L)):Pos!(Neu%L,2)=Pos!(I%L,2)+6* SIN(Orient%L(I%L))
179     Vel!(Neu%L,1)=Vel!(I%L,1)+3* COS(Orient%L(I%L)):Vel!(Neu%L,2)=Vel!(I%L,2)+3* SIN(Orient%L(I%L))
180     Neu%L=Neu%L+1:Neu%L=Neu%L- INT((Neu%L-3)/20)*20
181   ENDIF
182 NEXT I%L
183 IF (Pos!(1,1)-Pos!(2,1))^2+(Pos!(1,2)-Pos!(2,2))^2<36 THEN
184   PRINT "Die beiden Raumschiffe sind kollidiert!"
185   WAIT 2
186   REPEAT UNTIL INKEY$ =""
187   REPEAT UNTIL INKEY$ <>""
188   GOTO Eroeffnung
189 ENDIF
190 J%L=0
191 WHILE J%L<Torpak%L
192   I%L=J%L+Alt%L:I%L=I%L- INT((I%L-3)/20)*20
193   Zeit%L(I%L)=Zeit%L(I%L)+1
194   X!=Pos!(I%L,1):Y!=Pos!(I%L,2)
195   Abstand!= SQR((X!-320)^2+(Y!-200)^2)
196   IF Zeit%L(I%L)=75 THEN
197     Torpak%L=Torpak%L-1:Torp%L(Zug%L(I%L))=Torp%L(Zug%L(I%L))-1:Zeit%L(I%L)=0
198     Alt%L=Alt%L+1:Alt%L=Alt%L- INT((Alt%L-3)/20)*20
199     IF Aus%L(I%L)=0 THEN LINE COLOR =1: DRAW Apos!(I%L,1),Apos!(I%L,2)
200     Aus%L(I%L)=0
201   ELSE
202     IF Aus%L(I%L)=0 THEN
203       IF Abstand!<10 THEN
204         Aus%L(I%L)=1
205         LINE COLOR =1: DRAW Apos!(I%L,1),Apos!(I%L,2)
206         PCIRCLE 320,200,10
207       ELSE
208         Kraft!=FN Kraft!(Abstand!)
209         Vel!(I%L,1)=Vel!(I%L,1)-Kraft!*(X!-320)/Abstand!
210         Vel!(I%L,2)=Vel!(I%L,2)-Kraft!*(Y!-200)/Abstand!
211         LINE COLOR =1: DRAW Apos!(I%L,1),Apos!(I%L,2)
212         Apos!(I%L,1)=Pos!(I%L,1):Apos!(I%L,2)=Pos!(I%L,2)
213         Pos!(I%L,1)=X!+Vel!(I%L,1):Pos!(I%L,1)=Pos!(I%L,1)- INT(Pos!(I%L,1)/640)*640
214         Pos!(I%L,2)=Y!+Vel!(I%L,2):Pos!(I%L,2)=Pos!(I%L,2)- INT(Pos!(I%L,2)/400)*400
215         LINE COLOR =0: DRAW Pos!(I%L,1),Pos!(I%L,2)
216         Apos!(I%L,1)=Pos!(I%L,1):Apos!(I%L,2)=Pos!(I%L,2)
217         IF (Pos!(I%L,1)-Pos!(1,1))^2+(Pos!(I%L,2)-Pos!(1,2))^2<9 THEN
218           PRINT "Das Raumschiff der Fîderation wurde zerstîrt!"
219           WAIT 2
220           REPEAT UNTIL INKEY$ =""
221           REPEAT UNTIL INKEY$ <>""
222           EXIT TO Eroeffnung
223         ENDIF
224         IF (Pos!(I%L,1)-Pos!(2,1))^2+(Pos!(I%L,2)-Pos!(2,2))^2<9 THEN
225           PRINT "Das Raumschiff der Klingonen wurde zerstîrt!"
226           WAIT 2
227           REPEAT UNTIL INKEY$ =""
228           REPEAT UNTIL INKEY$ <>""
229           EXIT TO Eroeffnung
230         ENDIF
231       ENDIF
232     ENDIF
233   ENDIF
234   J%L=J%L+1
235 WEND
236 '
237 GOTO Start
238 '
239 DEF PROC Schiff(I%L,X%L,Y%L,Phi%L)
240   LINE COLOR =C%L(I%L):C%L(I%L)=1-C%L(I%L)
241   IF I%L=1 THEN
242     IF Phi%L=0 THEN
243       DRAW X%L-4,Y%L-2 TO X%L-1,Y%L-2: DRAW X%L+1,Y%L-2 TO X%L+3,Y%L-2
244       DRAW X%L-4,Y%L+2 TO X%L-1,Y%L+2: DRAW X%L+1,Y%L+2 TO X%L+3,Y%L+2
245       DRAW X%L-2,Y%L-1 TO X%L-2,Y%L+1: DRAW X%L,Y%L-1 TO X%L,Y%L+1
246       DRAW X%L+4,Y%L-1 TO X%L+4,Y%L+1: DRAW X%L-1,Y%L
247     ENDIF
248     IF Phi%L=90 THEN
249       DRAW X%L-2,Y%L+3 TO X%L-2,Y%L+1: DRAW X%L-2,Y%L-1 TO X%L-2,Y%L-4
250       DRAW X%L+2,Y%L+3 TO X%L+2,Y%L+1: DRAW X%L+2,Y%L-1 TO X%L+2,Y%L-4
251       DRAW X%L-1,Y%L-2 TO X%L+1,Y%L-2: DRAW X%L-1,Y%L TO X%L+1,Y%L
252       DRAW X%L-1,Y%L+4 TO X%L+1,Y%L+4: DRAW X%L,Y%L-1
253     ENDIF
254     IF Phi%L=180 THEN
255       DRAW X%L-3,Y%L-2 TO X%L-1,Y%L-2: DRAW X%L+1,Y%L-2 TO X%L+4,Y%L-2
256       DRAW X%L-3,Y%L+2 TO X%L-1,Y%L+2: DRAW X%L+1,Y%L+2 TO X%L+4,Y%L+2
257       DRAW X%L-4,Y%L+1 TO X%L-4,Y%L-1: DRAW X%L,Y%L+1 TO X%L,Y%L-1
258       DRAW X%L+2,Y%L+1 TO X%L+2,Y%L-1: DRAW X%L+1,Y%L
259     ENDIF
260     IF Phi%L=270 THEN
261       DRAW X%L-2,Y%L-1 TO X%L-2,Y%L-3: DRAW X%L+2,Y%L-1 TO X%L+2,Y%L-3
262       DRAW X%L-1,Y%L-4 TO X%L+1,Y%L-4: DRAW X%L-1,Y%L TO X%L+1,Y%L
263       DRAW X%L-2,Y%L+1 TO X%L-2,Y%L+4: DRAW X%L+2,Y%L+1 TO X%L+2,Y%L+4
264       DRAW X%L-1,Y%L+2 TO X%L+1,Y%L+2: DRAW X%L,Y%L+1
265     ENDIF
266   ELSE
267     IF Phi%L=0 THEN
268       DRAW X%L-3,Y%L TO X%L+3,Y%L: DRAW X%L+4,Y%L+1 TO X%L+4,Y%L-1
269       DRAW X%L-3,Y%L+1 TO X%L-1,Y%L+1: DRAW X%L-3,Y%L-1 TO X%L-1,Y%L-1
270       DRAW X%L-4,Y%L+2 TO X%L-2,Y%L+2: DRAW X%L-4,Y%L-2 TO X%L-2,Y%L-2
271     ENDIF
272     IF Phi%L=90 THEN
273       DRAW X%L,Y%L+3 TO X%L,Y%L-3: DRAW X%L-1,Y%L+4 TO X%L+1,Y%L+4
274       DRAW X%L-1,Y%L-1 TO X%L-1,Y%L-3: DRAW X%L+1,Y%L-1 TO X%L+1,Y%L-3
275       DRAW X%L-2,Y%L-2 TO X%L-2,Y%L-4: DRAW X%L+2,Y%L-2 TO X%L+2,Y%L-4
276     ENDIF
277     IF Phi%L=180 THEN
278       DRAW X%L-4,Y%L-1 TO X%L-4,Y%L+1: DRAW X%L-3,Y%L TO X%L+3,Y%L
279       DRAW X%L+1,Y%L+1 TO X%L+3,Y%L+1: DRAW X%L+1,Y%L-1 TO X%L+3,Y%L-1
280       DRAW X%L+2,Y%L+2 TO X%L+4,Y%L+2: DRAW X%L+2,Y%L-2 TO X%L+4,Y%L-2
281     ENDIF
282     IF Phi%L=270 THEN
283       DRAW X%L,Y%L+3 TO X%L,Y%L-3: DRAW X%L-1,Y%L-4 TO X%L+1,Y%L-4
284       DRAW X%L-1,Y%L+1 TO X%L-1,Y%L+3: DRAW X%L+1,Y%L+1 TO X%L+1,Y%L+3
285       DRAW X%L-2,Y%L+2 TO X%L-2,Y%L+4: DRAW X%L+2,Y%L+2 TO X%L+2,Y%L+4
286     ENDIF
287   ENDIF
288 RETURN
289 '
