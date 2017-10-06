0 ' AstroPho
1 '
2 ' programmiert von Daniel Roth
3 ' (pd) sinccom software 1988
4 '
5 ' Datum der letzten énderung: 23.September 1988
6 '
7 ' Programmiersprache: Omikron Basic 2.0
8 '
9 ' Literatur: W.Knapp/H.M.Hahn
10 '            Astrofotografie als Hobby
11 '            vwi Verlag Gerhard KnÅlle, D-8036 Herrsching
12 '
13 ' Anregungen und Verbesserungen verwerte ich gerne!
14 '
15 ' Daniel Roth
16 ' BrÅcker Mauspfad 448
17 ' D-5000 Kîln 91
18 '
19 Anfang
20 Menu_Auswahl
21 Appl_Exit
22 END
23
24 DEF PROC Anfang
25   LOCAL Aufl%L,Ok%L,I%L,Pfad$,Name$,Exp$
26   Appl_Init
27   Menu_Zeile%L= MEMORY(1526)
28   Graf_Mouse(2)
29   Rsrc_Load("ASTROPHO.RSC",Ok%L)
30   IF Ok%L=0 THEN
31     FORM_ALERT (1,"[2][.RSC-Error][EXIT]")
32     Appl_Exit
33     END
34   ENDIF
35   Rsc_Init
36   Rsrc_Gaddr(0,Menu%L,Menu_Adresse%L)
37   Menu_Bar(Menu_Adresse%L)
38   Rsrc_Gaddr(0,Dinfo%L,Info_Adr%L)
39   Form_Center(Info_Adr%L,Infox%L,Infoy%L,Infow%L,Infoh%L)
40   Rsrc_Gaddr(0,Dssplaen%L,Dssp_Adr%L)
41   Form_Center(Dssp_Adr%L,Dsspx%L,Dsspy%L,Dsspw%L,Dssph%L)
42   Rsrc_Gaddr(0,Dmaxbeli%L,Dmax_Adr%L)
43   Form_Center(Dmax_Adr%L,Dmaxx%L,Dmaxy%L,Dmaxw%L,Dmaxh%L)
44   Rsrc_Gaddr(0,Dnotwbel%L,Dnot_Adr%L)
45   Form_Center(Dnot_Adr%L,Dnotx%L,Dnoty%L,Dnotw%L,Dnoth%L)
46   Rsrc_Gaddr(0,Dgrenzhe%L,Dgre_Adr%L)
47   Form_Center(Dgre_Adr%L,Dgrex%L,Dgrey%L,Dgrew%L,Dgreh%L)
48   Rsrc_Gaddr(0,Dsexppau%L,Dsex_Adr%L)
49   Form_Center(Dsex_Adr%L,Dsexx%L,Dsexy%L,Dsexw%L,Dsexh%L)
50   Einlesen(Dssp_Adr%L,Fsspobjk%L,"")
51   Einlesen(Dssp_Adr%L,Fsspbeli%L,"")
52   Einlesen(Dssp_Adr%L,Fsspdekl%L,"")
53   Einlesen(Dmax_Adr%L,Fmaxobje%L,"")
54   Einlesen(Dmax_Adr%L,Fmaxdekl%L,"")
55   Einlesen(Dnot_Adr%L,Fmotempf%L,"")
56   Einlesen(Dnot_Adr%L,Fmotdurc%L,"")
57   Einlesen(Dnot_Adr%L,Fmotobhe%L,"")
58   Einlesen(Dnot_Adr%L,Fmotsexp%L,"")
59   Einlesen(Dgre_Adr%L,Fgreempf%L,"")
60   Einlesen(Dgre_Adr%L,Fgredurc%L,"")
61   Einlesen(Dgre_Adr%L,Fgrebeli%L,"")
62   Einlesen(Dgre_Adr%L,Fgresexp%L,"")
63   DIM Fehl$(11)
64   FOR I%L=0 TO 11
65     J%L=0:Rsrc_Gaddr(5,Fehler0%L+I%L,Adr%L)
66     WHILE PEEK(Adr%L+J%L)<>0
67       Fehl$(I%L)=Fehl$(I%L)+ CHR$( PEEK(Adr%L+J%L))
68       J%L=J%L+1
69     WEND
70   NEXT I%L
71   XBIOS (Aufl%L,4)
72   IF Aufl%L<>2 THEN
73     FORM_ALERT (1,Fehl$(0))
74   ENDIF
75   Zeilen%L=14
76   Pfad$=FN Aktpfad$+"*.EXP"
77   Ok%L=1:Name$="ASTROPHO.EXP"
78   WHILE NOT FN Datei_Existent%L(Name$,Ok%L) AND Ok%L=1
79     Menu_Retten
80     FILL COLOR =0
81     Vs_Clip: PBOX 0,0,640,18
82     V_Gtext(116,14,Fehl$(1))
83     FILESELECT (Pfad$,Name$,Ok%L)
84     Menu_Schreiben
85   WEND
86   DIM Film$(99)
87   Film_Zahl%L=0
88   OPEN "I",1,FN Kmpl$(Pfad$,Name$)
89   LINE INPUT #1,Name$
90   WHILE Name$<>"#"
91     IF LEFT$(Name$+"*",1)<>"*" THEN
92       LINE INPUT #1,Exp$
93       IF Film_Zahl%L<100 THEN
94         IF LEN(Name$+Exp$)>38 THEN
95           FORM_ALERT (1,Fehl$(2))
96         ELSE
97           Film$(Film_Zahl%L)=" "+Name$+ SPACE$(39- LEN(Name$)- LEN(Exp$))+Exp$
98           Film_Zahl%L=Film_Zahl%L+1
99         ENDIF
100       ELSE
101         FORM_ALERT (1,Fehl$(3))
102         EXIT
103       ENDIF
104     ENDIF
105     LINE INPUT #1,Name$
106   WEND
107   CLOSE 1
108   IF Film_Zahl%L<Zeilen%L THEN
109     WPOKE Dsex_Adr%L+Schieber%L*24+22, WPEEK(Dsex_Adr%L+Uschiebe%L*24+22)
110   ELSE
111     WPOKE Dsex_Adr%L+Schieber%L*24+22,Zeilen%L* WPEEK(Dsex_Adr%L+Uschiebe%L*24+22)\Film_Zahl%L
112   ENDIF
113   MODE "D"
114   DEG
115   Graf_Mouse(0)
116 RETURN
117
118 DEF PROC Menu_Auswahl
119   LOCAL Evnt$,Evnt%L,Eintrag%L,Titel%L
120   REPEAT
121     REPEAT
122       Evnt_Mesag(Evnt$)
123       Evnt%L= CVI( MID$(Evnt$,1,2))
124     UNTIL Evnt%L=10
125     Titel%L= CVI( MID$(Evnt$,7,2))
126     Eintrag%L= CVI( MID$(Evnt$,9,2))
127     IF Eintrag%L=Info%L THEN
128       Infobox
129     ENDIF
130     IF Eintrag%L=Ssplaeng%L THEN
131       Ssplaengbox
132     ENDIF
133     IF Eintrag%L=Maxbelic%L THEN
134       Maxbelicbox
135     ENDIF
136     IF Eintrag%L=Notwbeli%L THEN
137       Notwbelibox
138     ENDIF
139     IF Eintrag%L=Grenzhel%L THEN
140       Grenzhelbox
141     ENDIF
142     Menu_Tnormal(Titel%L,1)
143   UNTIL Eintrag%L=Ende%L
144 RETURN
145
146 DEF PROC Infobox
147   LOCAL Exit_Knopf%L
148   Form_Dial(0,Infox%L,Infoy%L,Infow%L,Infoh%L)
149   Form_Dial(1,Infox%L,Infoy%L,Infow%L,Infoh%L)
150   Objc_Draw(0,8,Infox%L,Infoy%L,Infow%L,Infoh%L,Info_Adr%L)
151   Form_Do(0,Info_Adr%L,Exit_Knopf%L)
152   Objc_Change(Exit_Knopf%L,Infox%L,Infoy%L,Infow%L,Infoh%L,0,0,Info_Adr%L)
153   Form_Dial(2,Infox%L,Infoy%L,Infow%L,Infoh%L)
154   Form_Dial(3,Infox%L,Infoy%L,Infow%L,Infoh%L)
155 RETURN
156
157 DEF PROC Ssplaengbox
158   LOCAL Exit_Knopf%L,F!,T!,D!,X!
159   Form_Dial(0,Dsspx%L,Dsspy%L,Dsspw%L,Dssph%L)
160   Form_Dial(1,Dsspx%L,Dsspy%L,Dsspw%L,Dssph%L)
161   Objc_Draw(0,8,Dsspx%L,Dsspy%L,Dsspw%L,Dssph%L,Dssp_Adr%L)
162   REPEAT
163     Form_Do(0,Dssp_Adr%L,Exit_Knopf%L)
164     IF Exit_Knopf%L=Ksspbere%L THEN
165       F!= VAL(FN Auslesen$(Dssp_Adr%L,Fsspobjk%L))
166       T!= VAL(FN Auslesen$(Dssp_Adr%L,Fsspbeli%L))
167       D!= VAL(FN Auslesen$(Dssp_Adr%L,Fsspdekl%L))
168       X!=F!*T!* COS(D!)/13750
169       Einlesen(Dssp_Adr%L,Fsspstri%L, STR$(X!))
170       Objc_Draw(Fsspstri%L,8,Dsspx%L,Dsspy%L,Dsspw%L,Dssph%L,Dssp_Adr%L)
171     ENDIF
172     Objc_Change(Exit_Knopf%L,Dsspx%L,Dsspy%L,Dsspw%L,Dssph%L,0,1,Dssp_Adr%L)
173   UNTIL Exit_Knopf%L=Ksspausg%L
174   Form_Dial(2,Dsspx%L,Dsspy%L,Dsspw%L,Dssph%L)
175   Form_Dial(3,Dsspx%L,Dsspy%L,Dsspw%L,Dssph%L)
176 RETURN
177
178 DEF PROC Maxbelicbox
179   LOCAL Exit_Knopf%L,Fehler%L,F!,D!,T!,Eh$
180   Form_Dial(0,Dmaxx%L,Dmaxy%L,Dmaxw%L,Dmaxh%L)
181   Form_Dial(1,Dmaxx%L,Dmaxy%L,Dmaxw%L,Dmaxh%L)
182   Objc_Draw(0,8,Dmaxx%L,Dmaxy%L,Dmaxw%L,Dmaxh%L,Dmax_Adr%L)
183   REPEAT
184     Form_Do(0,Dmax_Adr%L,Exit_Knopf%L)
185     IF Exit_Knopf%L=Kmaxbere%L THEN
186       Fehler%L=0
187       F!= VAL(FN Auslesen$(Dmax_Adr%L,Fmaxobje%L))
188       D!= VAL(FN Auslesen$(Dmax_Adr%L,Fmaxdekl%L))
189       IF F!=0 THEN
190         FORM_ALERT (1,Fehl$(4))
191         Fehler%L=-1
192       ENDIF
193       IF NOT Fehler%L AND COS(D!)=0 THEN
194         FORM_ALERT (1,Fehl$(5))
195         Fehler%L=-1
196       ENDIF
197       IF NOT Fehler%L THEN
198         T!=412.5/F!/ COS(D!):Eh$=" s"
199         IF T!>60 THEN T!=T!/60:Eh$=" m"
200         IF T!>60 THEN T!=T!/60:Eh$=" h"
201         Einlesen(Dmax_Adr%L,Fmaxmaxb%L, STR$(T!)+Eh$)
202         Objc_Draw(Fmaxmaxb%L,8,Dmaxx%L,Dmaxy%L,Dmaxw%L,Dmaxh%L,Dmax_Adr%L)
203       ENDIF
204     ENDIF
205     Objc_Change(Exit_Knopf%L,Dmaxx%L,Dmaxy%L,Dmaxw%L,Dmaxh%L,0,1,Dmax_Adr%L)
206   UNTIL Exit_Knopf%L=Kmaxausg%L
207   Form_Dial(2,Dmaxx%L,Dmaxy%L,Dmaxw%L,Dmaxh%L)
208   Form_Dial(3,Dmaxx%L,Dmaxy%L,Dmaxw%L,Dmaxh%L)
209 RETURN
210
211 DEF PROC Notwbelibox
212   LOCAL Exit_Knopf%L,Exp$,E%L,Dd!,D!,M!,P!,V!,I!,T!,Eh$
213   Form_Dial(0,Dnotx%L,Dnoty%L,Dnotw%L,Dnoth%L)
214   Form_Dial(1,Dnotx%L,Dnoty%L,Dnotw%L,Dnoth%L)
215   Objc_Draw(0,8,Dnotx%L,Dnoty%L,Dnotw%L,Dnoth%L,Dnot_Adr%L)
216   REPEAT
217     Form_Do(0,Dnot_Adr%L,Exit_Knopf%L)
218     IF Exit_Knopf%L=Knotqsex%L THEN
219       Exp$=FN Schwauswahl$
220       IF Exp$<>"" THEN Einlesen(Dnot_Adr%L,Fmotsexp%L,Exp$)
221       Objc_Draw(0,8,Dnotx%L,Dnoty%L,Dnotw%L,Dnoth%L,Dnot_Adr%L)
222     ENDIF
223     IF Exit_Knopf%L=Knotbere%L THEN
224       Fehler%L=0
225       E%L= CINTL( VAL(FN Auslesen$(Dnot_Adr%L,Fmotempf%L)))
226       Dd!= VAL(FN Auslesen$(Dnot_Adr%L,Fmotdurc%L))
227       D!= VAL(FN Auslesen$(Dnot_Adr%L,Fmotbeug%L))/1000
228       M!= VAL(FN Auslesen$(Dnot_Adr%L,Fmotobhe%L))
229       P!= VAL(FN Auslesen$(Dnot_Adr%L,Fmotsexp%L))
230       IF D!*D!=0 THEN
231         FORM_ALERT (1,Fehl$(6))
232         Fehler%L=-1
233       ENDIF
234       IF NOT Fehler%L AND E%L=0 THEN
235         FORM_ALERT (1,Fehl$(7))
236         Fehler%L=-1
237       ENDIF
238       IF NOT Fehler%L AND P!=0 THEN
239         FORM_ALERT (1,Fehl$(8))
240         Fehler%L=-1
241       ENDIF
242       IF NOT Fehler%L AND Dd!=0 THEN
243         FORM_ALERT (1,Fehl$(9))
244         Fehler%L=-1
245       ENDIF
246       IF NOT Fehler%L THEN
247         V!=Dd!*Dd!/(D!*D!)
248         I!=10^(-.4*M!)*2.06E-6
249         T!=(2.5/(I!*V!*E%L))^(1/P!):Eh$=" s"
250         IF T!>60 THEN T!=T!/60:Eh$=" m"
251         IF T!>60 THEN T!=T!/60:Eh$=" h"
252         Einlesen(Dnot_Adr%L,Knotnotb%L, STR$(T!)+Eh$)
253         Objc_Draw(Knotnotb%L,8,Dnotx%L,Dnoty%L,Dnotw%L,Dnoth%L,Dnot_Adr%L)
254       ENDIF
255     ENDIF
256     Objc_Change(Exit_Knopf%L,Dnotx%L,Dnoty%L,Dnotw%L,Dnoth%L,0,1,Dnot_Adr%L)
257   UNTIL Exit_Knopf%L=Knotausg%L
258   Form_Dial(2,Dnotx%L,Dnoty%L,Dnotw%L,Dnoth%L)
259   Form_Dial(3,Dnotx%L,Dnoty%L,Dnotw%L,Dnoth%L)
260 RETURN
261
262 DEF PROC Grenzhelbox
263   LOCAL Exit_Knopf%L,Exp$,E%L,Dd!,D!,T!,P!,M!
264   Form_Dial(0,Dgrex%L,Dgrey%L,Dgrew%L,Dgreh%L)
265   Form_Dial(1,Dgrex%L,Dgrey%L,Dgrew%L,Dgreh%L)
266   Objc_Draw(0,8,Dgrex%L,Dgrey%L,Dgrew%L,Dgreh%L,Dgre_Adr%L)
267   REPEAT
268     Form_Do(0,Dgre_Adr%L,Exit_Knopf%L)
269     IF Exit_Knopf%L=Kgresexp%L THEN
270       Exp$=FN Schwauswahl$
271       IF Exp$<>"" THEN Einlesen(Dgre_Adr%L,Fgresexp%L,Exp$)
272       Objc_Draw(0,8,Dgrex%L,Dgrey%L,Dgrew%L,Dgreh%L,Dgre_Adr%L)
273     ENDIF
274     IF Exit_Knopf%L=Kgrebere%L THEN
275       Fehler%L=0
276       E%L= CINTL( VAL(FN Auslesen$(Dgre_Adr%L,Fgreempf%L)))
277       Dd!= VAL(FN Auslesen$(Dgre_Adr%L,Fgredurc%L))
278       D!= VAL(FN Auslesen$(Dgre_Adr%L,Fgrebeug%L))/1000
279       T!= VAL(FN Auslesen$(Dgre_Adr%L,Fgrebeli%L))
280       P!= VAL(FN Auslesen$(Dgre_Adr%L,Fgresexp%L))
281       IF D!*D!=0 THEN
282         FORM_ALERT (1,Fehl$(6))
283         Fehler%L=-1
284       ENDIF
285       IF NOT Fehler%L AND T!=0 THEN
286         FORM_ALERT (1,Fehl$(10))
287         Fehler%L=-1
288       ENDIF
289       IF NOT Fehler%L AND E%L=0 THEN
290         FORM_ALERT (1,Fehl$(7))
291         Fehler%L=-1
292       ENDIF
293       IF NOT Fehler%L AND Dd!=0 THEN
294         FORM_ALERT (1,Fehl$(9))
295         Fehler%L=-1
296       ENDIF
297       IF NOT Fehler%L THEN
298         V!=Dd!*Dd!/(D!*D!)
299         M!= LN(2.5/(2.06E-6*(T!^P!)*E%L*V!))/ LN(10)/-.4
300         Einlesen(Dgre_Adr%L,Fgreerhe%L, STR$(M!))
301         Objc_Draw(Fgreerhe%L,8,Dgrex%L,Dgrey%L,Dgrew%L,Dgreh%L,Dgre_Adr%L)
302       ENDIF
303     ENDIF
304     Objc_Change(Exit_Knopf%L,Dgrex%L,Dgrey%L,Dgrew%L,Dgreh%L,0,1,Dgre_Adr%L)
305   UNTIL Exit_Knopf%L=Kgreausg%L
306   Objc_Change(Exit_Knopf%L,Dgrex%L,Dgrey%L,Dgrew%L,Dgreh%L,0,0,Dgre_Adr%L)
307   Form_Dial(2,Dgrex%L,Dgrey%L,Dgrew%L,Dgreh%L)
308   Form_Dial(3,Dgrex%L,Dgrey%L,Dgrew%L,Dgreh%L)
309 RETURN
310
311 DEF FN Schwauswahl$
312   LOCAL Rtrn$,Posi%L,I%L,Which%L,Mx%L,My%L,Unw%L,Code%L,Objekt%L,Stelle%L
313   Rtrn$=""
314   Posi%L=FN Diskret%L(Dsex_Adr%L,Uschiebe%L,Schieber%L,Zeilen%L,Film_Zahl%L)
315   FOR I%L=0 TO Zeilen%L-1
316     Einlesen(Dsex_Adr%L,Emul0%L+I%L,Film$(I%L+Posi%L-Zeilen%L))
317   NEXT I%L
318   Form_Dial(1,Dsexx%L,Dsexy%L,Dsexw%L,Dsexh%L)
319   Objc_Draw(0,8,Dsexx%L,Dsexy%L,Dsexw%L,Dsexh%L,Dsex_Adr%L)
320   REPEAT
321     Evnt_Multi(3,1,1,1,0,0,0,0,0,0,0,0,0,0,0,Evnt$,Which%L,Mx%L,My%L,Unw%L,Unw%L,Code%L,Unw%L)
322     IF Which%L=2 THEN
323       Objc_Find(0,8,Mx%L,My%L,Dsex_Adr%L,Objekt%L)
324     ELSE
325       IF CINT(Code%L AND $FF)=13 THEN Objekt%L=Ksexausg%L
326     ENDIF
327     IF Objekt%L>=Emul0%L AND Objekt%L<=Emul13%L THEN
328       Rtrn$=Film$(Objekt%L-Emul0%L+Posi%L-Zeilen%L)
329       Rtrn$= RIGHT$(Rtrn$, INSTR( MIRROR$(Rtrn$)," ")-1)
330       Stelle%L= INSTR(Rtrn$,".")
331       IF Stelle%L<2 THEN
332         FORM_ALERT (1,Fehl$(11))
333         Rtrn$=""
334       ELSE
335         Objc_Change(Objekt%L,Dsexx%L,Dsexy%L,Dsexw%L,Dsexh%L,1,1,Dsex_Adr%L)
336         Objc_Change(Objekt%L,Dsexx%L,Dsexy%L,Dsexw%L,Dsexh%L,0,0,Dsex_Adr%L)
337         IF LEN(Rtrn$)>4 THEN Rtrn$= LEFT$(Rtrn$,4)
338         Objekt%L=Ksexausg%L
339       ENDIF
340     ENDIF
341     IF Objekt%L=Schieber%L THEN
342       Graf_Mouse(4)
343       Posi%L=FN Benutze_Schieber%L(Dsex_Adr%L,Uschiebe%L,Schieber%L,Zeilen%L,Film_Zahl%L)
344       Graf_Mouse(0)
345       FOR I%L=0 TO Zeilen%L-1
346         Einlesen(Dsex_Adr%L,Emul0%L+I%L,Film$(I%L+Posi%L-Zeilen%L))
347       NEXT I%L
348       Objc_Draw(Emulhuel%L,8,Dsexx%L,Dsexy%L,Dsexw%L,Dsexh%L,Dsex_Adr%L)
349     ENDIF
350   UNTIL Objekt%L=Ksexausg%L
351   Objc_Change(Objekt%L,Dsexx%L,Dsexy%L,Dsexw%L,Dsexh%L,1,1,Dsex_Adr%L)
352   Evnt_Button(1,1,0,Unw%L,Mx%L,My%L,Unw%L,Unw%L)
353   Form_Dial(2,Dsexx%L,Dsexy%L,Dsexw%L,Dsexh%L)
354   Objc_Change(Objekt%L,Dsexx%L,Dsexy%L,Dsexw%L,Dsexh%L,0,0,Dsex_Adr%L)
355   WPOKE Dsex_Adr%L+24*Schieber%L+18,0
356 RETURN (Rtrn$)
357
358 DEF PROC Menu_Retten
359   MOUSEOFF : BITBLT 0,0,640,19 TO Menu_Zeile%L: MOUSEON
360 RETURN
361
362 DEF PROC Menu_Schreiben
363   MOUSEOFF : BITBLT Menu_Zeile%L TO 0,0,640,19: MOUSEON
364 RETURN
365
366 DEF FN Kmpl$(P$,N$)
367 RETURN ( LEFT$(P$, LEN(P$)- INSTR( MIRROR$(P$),"\")+1)+N$+ CHR$(0))
368
369 DEF PROC Einlesen(Adr%L,Objekt%L,Text$)
370   LOCAL Zeiger%L,Ptext%L,Txtlen%L,I%L
371   Text$=Text$+ CHR$(0)+ SPACE$(99)
372   Zeiger%L= LPEEK(Adr%L+24*Objekt%L+12)
373   Ptext%L= LPEEK(Zeiger%L)
374   Txtlen%L= WPEEK(Zeiger%L+24)-2
375   FOR I%L=0 TO Txtlen%L: POKE (Ptext%L+I%L), ASC( MID$(Text$,I%L+1,1)): NEXT I%L
376 RETURN
377
378 DEF FN Auslesen$(Adr%L,Objekt%L)
379   LOCAL Zeiger%L,Ptext%L,Txtlen%L,Text$,I%L
380   Zeiger%L= LPEEK(Adr%L+24*Objekt%L+12)
381   Ptext%L= LPEEK(Zeiger%L)
382   Txtlen%L= WPEEK(Zeiger%L+24)-2
383   I%L=0:Text$=""
384   WHILE PEEK(Ptext%L+I%L)<>0
385     Text$=Text$+ CHR$( PEEK(Ptext%L+I%L)):I%L=I%L+1
386   WEND
387 RETURN Text$
388
389 DEF FN Diskret%L(Dbox%L,Ueb%L,Unt%L,A%L,B%L)
390   LOCAL Delta%L
391   Delta%L= WPEEK(Dbox%L+Ueb%L*24+22)- WPEEK(Dbox%L+Unt%L*24+22)
392   IF Delta%L<>0 THEN
393     RETURN CINT( INT(A%L+(B%L-A%L)* WPEEK(Dbox%L+Unt%L*24+18)\Delta%L+.5))
394   ENDIF
395 RETURN (A%L)
396
397 DEF PROC Setze_Schieber(Dbox%L,Ueb%L,Unt%L,Posi%L,A%L,B%L,Neu%L)
398   LOCAL Delta%L
399   Delta%L=B%L-A%L
400   IF Delta%L<>0 THEN
401     WPOKE Dbox%L+24*Unt%L+18,(Posi%L-A%L)*( WPEEK(Dbox%L+24*Ueb%L+22)- WPEEK(Dbox%L+24*Unt%L+22))\Delta%L
402   ELSE
403     WPOKE Dbox%L+24*Unt%L+18,0
404   ENDIF
405   IF Neu%L THEN Objc_Draw(Ueb%L,8,0,0,640,400,Dbox%L)
406 RETURN
407
408 DEF FN Benutze_Schieber%L(Dbox%L,Ueb%L,Unt%L,A%L,B%L)
409   LOCAL Posi%L
410   Graf_Slidebox(Ueb%L,Unt%L,1,Dbox%L,Posi%L)
411   WPOKE Dbox%L+Unt%L*24+18,(( WPEEK(Dbox%L+Ueb%L*24+22)- WPEEK(Dbox%L+Unt%L*24+22))*Posi%L)\1000
412   Pos_I%L=FN Diskret%L(Dbox%L,Ueb%L,Unt%L,A%L,B%L)
413   Setze_Schieber(Dbox%L,Ueb%L,Unt%L,Pos_I%L,A%L,B%L,-1)
414 RETURN (Pos_I%L)
415
416 DEF FN Datei_Existent%L(Was$,Ok%L)
417   LOCAL Name$,Name_Zeiger%L,Handle%L
418   Name$=Was$+ CHR$(0)
419   Name_Zeiger%L= LPEEK( SEGPTR +28)+ LPEEK( VARPTR(Name$))
420   GEMDOS (Handle%L,$3D, HIGH(Name_Zeiger%L), LOW(Name_Zeiger%L),0)
421   IF Handle%L<0 THEN
422     IF Ok%L<>0 THEN
423       Was$= RIGHT$(Was$, INSTR( MIRROR$("\"+Was$),"\")-1)
424       FORM_ALERT (1,"[1]["+ UPPER$(Was$)+" wurde|nicht gefunden!][Auswahl]")
425     ENDIF
426     RETURN (0)
427   ELSE
428     GEMDOS (,$3E,Handle%L)
429   ENDIF
430 RETURN (-1)
431
432 DEF FN Aktpfad$
433   LOCAL Drive%L,Path$
434   GEMDOS (Drive%L,$19)
435   Path$=" "*64:Adr%L= LPEEK( SEGPTR +28)+ LPEEK( VARPTR(Path$))
436   GEMDOS (,$47, HIGH(Adr%L), LOW(Adr%L),0)
437   Path$= LEFT$(Path$, INSTR(Path$+ CHR$(0), CHR$(0))-1)
438   Path$= CHR$(65+Drive%L)+":"+Path$+"\"
439 RETURN (Path$)
440
441 DEF PROC Rsc_Init
442  ' Resource-Set indicies fuer ASTROPHO
443  Menu%L=0' Menuebaum
444  Info%L=9' STRING in Baum MENU
445  Ende%L=18' STRING in Baum MENU
446  Ssplaeng%L=21' STRING in Baum MENU
447  Maxbelic%L=22' STRING in Baum MENU
448  Notwbeli%L=24' STRING in Baum MENU
449  Grenzhel%L=25' STRING in Baum MENU
450  Dinfo%L=1' Formula/Dialog
451  Kinfo%L=1' BOX in Baum DINFO
452  Dssplaen%L=2' Formula/Dialog
453  Fsspobjk%L=5' FTEXT in Baum DSSPLAEN
454  Fsspbeli%L=6' FTEXT in Baum DSSPLAEN
455  Fsspdekl%L=7' FTEXT in Baum DSSPLAEN
456  Ksspbere%L=8' BUTTON in Baum DSSPLAEN
457  Fsspstri%L=9' FTEXT in Baum DSSPLAEN
458  Ksspausg%L=10' BUTTON in Baum DSSPLAEN
459  Dmaxbeli%L=3' Formula/Dialog
460  Fmaxobje%L=5' FTEXT in Baum DMAXBELI
461  Fmaxdekl%L=6' FTEXT in Baum DMAXBELI
462  Kmaxbere%L=7' BUTTON in Baum DMAXBELI
463  Fmaxmaxb%L=8' FTEXT in Baum DMAXBELI
464  Kmaxausg%L=9' BUTTON in Baum DMAXBELI
465  Dnotwbel%L=4' Formula/Dialog
466  Fmotempf%L=5' FTEXT in Baum DNOTWBEL
467  Fmotdurc%L=7' FTEXT in Baum DNOTWBEL
468  Fmotbeug%L=8' FTEXT in Baum DNOTWBEL
469  Fmotobhe%L=9' FTEXT in Baum DNOTWBEL
470  Fmotsexp%L=10' FTEXT in Baum DNOTWBEL
471  Knotqsex%L=11' BUTTON in Baum DNOTWBEL
472  Knotbere%L=12' BUTTON in Baum DNOTWBEL
473  Knotnotb%L=13' FTEXT in Baum DNOTWBEL
474  Knotausg%L=14' BUTTON in Baum DNOTWBEL
475  Dgrenzhe%L=5' Formula/Dialog
476  Fgreempf%L=4' FTEXT in Baum DGRENZHE
477  Fgredurc%L=6' FTEXT in Baum DGRENZHE
478  Fgrebeug%L=7' FTEXT in Baum DGRENZHE
479  Fgrebeli%L=8' FTEXT in Baum DGRENZHE
480  Fgresexp%L=9' FTEXT in Baum DGRENZHE
481  Kgresexp%L=10' BUTTON in Baum DGRENZHE
482  Kgrebere%L=11' BUTTON in Baum DGRENZHE
483  Fgreerhe%L=12' FTEXT in Baum DGRENZHE
484  Kgreausg%L=13' BUTTON in Baum DGRENZHE
485  Dsexppau%L=6' Formula/Dialog
486  Ksexausg%L=1' STRING in Baum DSEXPPAU
487  Emulhuel%L=2' BOX in Baum DSEXPPAU
488  Emul0%L=3' TEXT in Baum DSEXPPAU
489  Emul13%L=16' TEXT in Baum DSEXPPAU
490  Uschiebe%L=17' BOX in Baum DSEXPPAU
491  Schieber%L=18' BOX in Baum DSEXPPAU
492  Fehler0%L=0' Freier String Index
493  Fehler1%L=1' Freier String Index
494  Fehler2%L=2' Freier String Index
495  Fehler3%L=3' Freier String Index
496  Fehler4%L=4' Freier String Index
497  Fehler5%L=5' Freier String Index
498  Fehler6%L=6' Freier String Index
499  Fehler7%L=7' Freier String Index
500  Fehler8%L=8' Freier String Index
501  Fehler9%L=9' Freier String Index
502  Fehler10%L=10' Freier String Index
503  Fehler11%L=11' Freier String Index
504 RETURN
505
506 END 'GEM Library fÅr OMIKRON-BASIC. Version 2.0.
507 'Copyright (C) Artur Sîdler, Pforzheim & Thomas Kemp, Birkenfeld
508 '
509 'Zeile 64013: $f0,$f4,$f8 fÅr ACCESSORIES, $64,$6c,$7c fÅr APPLICATIONS
510 'Zeile 64018: REMen fÅr ACCESSORIES
511 '
512 'SAVE SYSTEM LPEEK($EC)   ist fÅr MODUL-Interpreter angebracht.
513 '--- und wenn dann nicht alles wieder lÑuft, freû' ich 'nen Besen.
514 '
515 'AES
516 '
517 DEF PROC Appl_Init: LOCAL X%L,Y%L,W%L,H%L: DIM Ctrl%(12),Intin%(128),Addrout%L(1)
518    DIM Intout%(128),Ptsin%(1,128),Ptsout%(1,6),Addrin%L(3),Global%(15)
519    Wi_Pok1%L=$64:Wi_Pok2%L=$6C:Wi_Pok3%L=$7C:Wi_Pok4%L=Wi_Pok2%L+8
520    Mn_Selected%L=10:Wm_Redraw%L=20:Wm_Topped%L=21:Wm_Closed%L=22:Wm_Fulled%L=23:Wm_Arrowed%L=24
521    Wm_Hslid%L=25:Wm_Vslid%L=26:Wm_Sized%L=27:Wm_Moved%L=28:Wm_Newtop%L=29:Ac_Open%L=40
522    Ac_Close%L=41:Mu_Keybd%L=1:Mu_Button%L=2:Mu_M1%L=4:Mu_M2%L=8:Mu_Mesag%L=16:Mu_Timer%L=32
523    Appl_Exit:Graf_Handle(Ctrl%(6)): PRINT CHR$(27);"H"; CHR$(27);"H"; CHR$(27);"f"; CHR$(27);"b1"; CHR$(27);"c0";:Graf_Mouse(0):V_Show_C(0)
524    Wind_Get(0,4,X%L,Y%L,W%L,H%L):Form_Dial(0,X%L,Y%L,W%L,H%L):Form_Dial(3,X%L,Y%L,W%L,H%L)
525    RETURN
526 '
527 DEF PROC Appl_Exit: LOCAL I%L
528    FOR I%L=1 TO 10
529       Wind_Delete(I%L)
530    NEXT I%L
531    Form_Dial(3,0,0,1,1):V_Clsvwk:Rsrc_Free
532    Wind_Update(0):Wind_Update(2):Menu_Bar
533    Graf_Handle(Ctrl%(6)):V_Hide_C: CLIP : PRINT CHR$(27);"H"; CHR$(27);"H";: RETURN 'CLIP  n i c h t  herausnehmen!!! (Anm. des Programmierers, er weiû warum!)
534 '
535 DEF PROC Evnt_Button(Intin%(0),Intin%(1),Intin%(2),R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
536    AES (21,Global%(15),Intin%(3),Addrin%L(0),Intout%(5),Addrout%L(0))
537    RETURN
538 '
539 DEF PROC Evnt_Mesag(R Text$):Text$= CHR$(0)*16
540    Addrin%L(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
541    AES (23,Global%(15),Intin%(0),Addrin%L(1),Intout%(1),Addrout%L(0))
542    IF CVI(Text$)=41 THEN LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) AND 7 SHL 29: LPOKE Wi_Pok4%L, LPEEK(Wi_Pok4%L) AND 7 SHL 29
543    RETURN
544 '
545 DEF PROC Evnt_Multi(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Intin%(6),Intin%(7),Intin%(8),Intin%(9),X%L,Y%L,W%L,H%L,T%L,R Text$,R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4),R Intout%(5),R Intout%(6))
546    Intin%(10)=X%L:Intin%(11)=Y%L:Intin%(12)=W%L:Intin%(13)=H%L
547    Intin%(14)= LOW(T%L):Intin%(15)= HIGH(T%L):Text$= CHR$(0)*16
548    Addrin%L(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
549    AES (25,Global%(15),Intin%(16),Addrin%L(1),Intout%(7),Addrout%L(0))
550    IF Intout%(0) AND 16 THEN
551       IF CVI(Text$)=41 THEN LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) AND 7 SHL 29: LPOKE Wi_Pok4%L, LPEEK(Wi_Pok4%L) AND 7 SHL 29
552    ENDIF RETURN
553 '
554 DEF PROC Menu_Bar(Addrin%L(0),Intin%(0))
555    AES (30,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
556    RETURN
557 DEF PROC Menu_Bar(X%L)
558    Menu_Bar:Menu_Bar%L=X%L:Addrin%L(0)=X%L:Intin%(0)=1
559    LPOKE Wi_Pok4%L, LPEEK(Wi_Pok4%L) OR 1 SHL 30
560    AES (30,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
561    RETURN
562 DEF PROC Menu_Bar
563    Intin%(0)=0:Addrin%L(0)=Menu_Bar%L
564    IF FN Wind_Chek%L(30,8) THEN
565       LPOKE Wi_Pok4%L, LPEEK(Wi_Pok4%L) XOR 1 SHL 30
566       AES (30,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
567    ENDIF Menu_Bar%L=0: RETURN
568 '
569 DEF PROC Menu_Tnormal(Intin%(0),Intin%(1)):Addrin%L(0)=Menu_Bar%L
570    IF Menu_Bar%L THEN
571       AES (33,Global%(15),Intin%(2),Addrin%L(1),Intout%(1),Addrout%L(0))
572    ENDIF RETURN
573 '
574 DEF PROC Objc_Draw(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Addrin%L(0))
575    AES (42,Global%(15),Intin%(6),Addrin%L(1),Intout%(1),Addrout%L(0))
576    RETURN
577 '
578 DEF PROC Objc_Find(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Addrin%L(0),R Intout%(0))
579    AES (43,Global%(15),Intin%(4),Addrin%L(1),Intout%(1),Addrout%L(0))
580    RETURN
581 '
582 DEF PROC Objc_Change(Intin%(0),Intin%(6),Addrin%L(0))
583    Intin%(1)=0:Intin%(7)=0
584    AES (47,Global%(15),Intin%(8),Addrin%L(1),Intout%(1),Addrout%L(0))
585    RETURN
586 DEF PROC Objc_Change(Intin%(0),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Intin%(6),Intin%(7),Addrin%L(0))
587    Intin%(1)=0
588    AES (47,Global%(15),Intin%(8),Addrin%L(1),Intout%(1),Addrout%L(0))
589    RETURN
590 '
591 DEF PROC Form_Do(Intin%(0),Addrin%L(0),R Intout%(0))
592    AES (50,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
593    RETURN
594 '
595 DEF PROC Form_Dial(X%L,Intin%(5),Intin%(6),Intin%(7),Intin%(8))
596    IF X%L=0 THEN IF FN Wind_Chek%L(29,0) THEN RETURN ELSE LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) OR 1 SHL 29
597    IF X%L=3 THEN IF FN Wind_Chek%L(29,0) THEN LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) XOR 1 SHL 29 ELSE RETURN
598    Intin%(1)=Intin%(5)+Intin%(7) SHR 1:Intin%(3)=1:Intin%(0)=X%L
599    Intin%(2)=Intin%(6)+Intin%(8) SHR 1:Intin%(4)=1
600    AES (51,Global%(15),Intin%(9),Addrin%L(0),Intout%(1),Addrout%L(0))
601    RETURN
602 '
603 DEF PROC Form_Center(Addrin%L(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
604    AES (54,Global%(15),Intin%(0),Addrin%L(1),Intout%(5),Addrout%L(0))
605    RETURN
606 '
607 DEF PROC Graf_Slidebox(Intin%(0),Intin%(1),Intin%(2),Addrin%L(0),R Intout%(0))
608    AES (76,Global%(15),Intin%(3),Addrin%L(1),Intout%(1),Addrout%L(0))
609    RETURN
610 '
611 IF TIMER THEN DEF PROC Graf_Handle(R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4)) ELSE DEF PROC Graf_Handle(R Intout%(0))
612    AES (77,Global%(15),Intin%(0),Addrin%L(0),Intout%(5),Addrout%L(0))
613    RETURN
614 '
615 DEF PROC Graf_Mouse(X%L,Y%L,W%L,H%L,T%L): LOCAL I%L
616    IF Graf_Mouse%L=0 THEN Graf_Mouse%L= MEMORY(74)
617    T%L= LPEEK(T%L)+ LPEEK( SEGPTR +20):Intin%(0)=255
618    WPOKE Graf_Mouse%L,X%L: WPOKE Graf_Mouse%L+2,Y%L: WPOKE Graf_Mouse%L+4,0
619    WPOKE Graf_Mouse%L+6,W%L: WPOKE Graf_Mouse%L+8,H%L
620    FOR I%L=0 TO 62 STEP 2: WPOKE Graf_Mouse%L+10+I%L, WPEEK(T%L+I%L): NEXT
621    Addrin%L(0)=Graf_Mouse%L
622    AES (78,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
623    RETURN
624 DEF PROC Graf_Mouse(Intin%(0))
625    AES (78,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
626    RETURN
627 '
628 DEF FN Wind_Chek%L(W%L,H%L)
629    IF LPEEK(Wi_Pok3%L) THEN LPOKE Wi_Pok2%L,0: LPOKE Wi_Pok4%L,0: LPOKE Wi_Pok3%L,0: LPOKE Wi_Pok1%L,0
630    IF W%L<1 THEN RETURN 0
631    RETURN BIT(W%L, LPEEK(Wi_Pok2%L+H%L))
632 '
633 DEF PROC Wind_Close(W%L)
634    IF FN Wind_Chek%L(W%L,8) THEN
635       LPOKE Wi_Pok4%L, LPEEK(Wi_Pok4%L) XOR 1 SHL W%L:Intin%(0)=W%L
636       AES (102,Global%(15),Intin%(1),Addrin%L(0),Intout%(1),Addrout%L(0))
637    ENDIF RETURN
638 '
639 DEF PROC Wind_Delete(W%L):Wind_Close(W%L)
640    IF FN Wind_Chek%L(W%L,0) THEN
641       LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) XOR 1 SHL W%L:Intin%(0)=W%L
642       AES (103,Global%(15),Intin%(1),Addrin%L(0),Intout%(1),Addrout%L(0))
643    ENDIF RETURN
644 '
645 DEF PROC Wind_Get(Intin%(0),Intin%(1),R Intout%(1))
646    IF FN Wind_Chek%L(Intin%(0),0)=0 AND Intin%(1)<>10 THEN RETURN
647    AES (104,Global%(15),Intin%(2),Addrin%L(0),Intout%(5),Addrout%L(0))
648    RETURN
649 DEF PROC Wind_Get(Intin%(0),Intin%(1),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
650    IF FN Wind_Chek%L(Intin%(0),0)=0 AND Intin%(0) THEN RETURN
651    AES (104,Global%(15),Intin%(2),Addrin%L(0),Intout%(5),Addrout%L(0))
652    RETURN
653 '
654 DEF PROC Wind_Update(X%L):Intin%(0)=X%L
655    IF X%L=0 THEN IF FN Wind_Chek%L(30,0)=0 THEN RETURN ELSE LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) XOR 1 SHL 30
656    IF X%L=1 THEN IF FN Wind_Chek%L(30,0) THEN RETURN ELSE LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) XOR 1 SHL 30
657    IF X%L=2 THEN IF FN Wind_Chek%L(31,0)=0 THEN RETURN ELSE LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) XOR 1 SHL 31
658    IF X%L=3 THEN IF FN Wind_Chek%L(31,0) THEN RETURN ELSE LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) XOR 1 SHL 31
659    AES (107,Global%(15),Intin%(1),Addrin%L(0),Intout%(1),Addrout%L(0))
660    RETURN
661 '
662 DEF PROC Rsrc_Load(Text$,R Intout%(0)):Text$=Text$+ CHR$(0)
663    Rsrc_Free:Addrin%L(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
664    AES (110,Global%(15),Intin%(0),Addrin%L(1),Intout%(1),Addrout%L(0))
665    LPOKE Wi_Pok1%L,Global%(5) SHL 16 OR Global%(6)
666    RETURN
667 '
668 DEF PROC Rsrc_Free
669    IF LPEEK(Wi_Pok3%L) THEN LPOKE Wi_Pok2%L,0: LPOKE Wi_Pok4%L,0: LPOKE Wi_Pok3%L,0: LPOKE Wi_Pok1%L,0
670    IF LPEEK(Wi_Pok1%L) THEN
671       Global%(5)= WPEEK(Wi_Pok1%L):Global%(6)= LOW( LPEEK(Wi_Pok1%L)): LPOKE Wi_Pok1%L,0
672       AES (111,Global%(15),Intin%(0),Addrin%L(0),Intout%(1),Addrout%L(0))
673    ENDIF RETURN
674 '
675 DEF PROC Rsrc_Gaddr(Intin%(0),Intin%(1),R Addrout%L(0))
676    AES (112,Global%(15),Intin%(2),Addrin%L(0),Intout%(1),Addrout%L(1))
677    RETURN
678 '
679 'VDI
680 '
681 DEF PROC V_Gtext(Ptsin%(0,0),Ptsin%(1,0),Text$): LOCAL I%L
682    FOR I%L=0 TO LEN(Text$)-1:Intin%(I%L)= ASC( MID$(Text$,I%L+1,1)): NEXT
683    VDI (8,Ctrl%(12),Intin%(I%L),Ptsin%(0,1),Intout%(0),Ptsout%(0,0))
684    RETURN
685 '
686 DEF PROC Vsin_Mode(Intin%(0),Intin%(1))
687    VDI (33,Ctrl%(12),Intin%(2),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
688    RETURN
689 '
690 DEF PROC V_Opnvwk
691    V_Opnvwk(1,1,1,1,1,1,1,1,1,1,2)
692    RETURN
693 DEF PROC V_Opnvwk(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Intin%(6),Intin%(7),Intin%(8),Intin%(9),Intin%(10))
694    VDI (100,Ctrl%(12),Intin%(11),Ptsin%(0,0),Intout%(45),Ptsout%(0,6))
695    RETURN
696 '
697 DEF PROC V_Clsvwk
698    VDI (101,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
699    RETURN
700 '
701 IF TIMER THEN DEF PROC V_Show_C(Intin%(0)) ELSE DEF PROC V_Show_C:Intin%(0)=0
702    VDI (122,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
703    RETURN
704 '
705 DEF PROC V_Hide_C
706    VDI (123,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
707    RETURN
708 '
709 DEF PROC Vs_Clip(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
710    Intin%(0)=1
711    VDI (129,Ctrl%(12),Intin%(1),Ptsin%(0,4),Intout%(0),Ptsout%(0,0))
712    RETURN
713 '
714 DEF PROC Vs_Clip:Intin%(0)=0
715    VDI (129,Ctrl%(12),Intin%(1),Ptsin%(0,4),Intout%(0),Ptsout%(0,0))
716    RETURN
717 '
