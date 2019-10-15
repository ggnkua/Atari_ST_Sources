0
1 ' Programmiersprache: Omikron-Basic (TOS)
2 ' Programmierer: Martin Rost / E-Mail: MROST@TPKI.TOPPOINT.DE
3 ' Erlaeuterungen zum Programmablauf stehen unter: LIVEHILF.TXT
4 ' Eine Literatur-Datei zum Testen ist beigefuegt: LIT.TXT
5 '
6 ' Siehe zur Einfuehrung des ganzen Konzeptes den Artikel zur
7 ' Literaturverwaltung in Editoren in TOS 12/92
8 '
9 ' Bedanken moechte ich mich bei...
10 ' - Werner Herwig fuer das Ausleihen seines Laptops
11 ' - Michael Schack fuer Programm-Wuensche, -Anregungen sowie -Tests
12 ' - Anja Rohwer fuer viel Liebe
13
14 CLEAR
15 ON ERROR GOTO Fehlerbehandlung
16 Version$="LIVE-V920924"
17 Variablen
18 Mhauptmenue
19
20 DEF PROC Variablen
21 '***** Recherche, Sortieren, Aufbereiten *****
22 Nld$="LIT.TXT":Lnld%= LEN(Nld$)'Literaturdatei
23 Ntd$="LIT_TR.TXT":Lntd%= LEN(Ntd$)'Trefferdatei
24 Ntld$="LIT_P.TXT":Lntld%= LEN(Ntld$)'Protokoll- , Fehler- oder Kommentartextdatei
25 '** Recherche **
26 Gs$="/ai/":Lgs%= LEN(Gs$)'Gesuchter String
27 Tld$="n"'keine Datei ohne Treffer anlegen
28 Mof$="m"'Trefferdatei mit Footer-Ausgabe
29 '** Sortieren **
30 Mzd%L=15000'Maximale Anzahl an Zeilen einer Literatur-Datei
31 Slt%=50'  String-Sortierlaenge der Titelzeile
32 '** Aufbereiten **
33 Footer$="D:920923-th ^M:/ ^F: ^S: ^Z:/ ^B://// ^E: ^T:"'Default-Footer
34 Kte$="n"' Keinen Kommentartext auf Extradatei unter ^T ransetzen
35 Nkj1$="):":Lnkj1%= LEN(Nkj1$)'           Kriterium 1 fuer Notationskorrektur Jahr
36 Nkj2$="(1":Lnkj2%= LEN(Nkj2$):Lnkj21%=1' Kriterium 2 fuer Notationskorrektur Jahr
37 Hze$="j"' Im Footer soll nach ^D:xxyyzz-bb ein Zaehler ergaenzt werden
38 Hzes%=1'Startzahl des Zaehlers
39 Hzep$=" ^M:":Lhzep%= LEN(Hzep$)'Kriterium fuer die Positionierung des Zaehlers, hier vor ^M
40 '***** ParameterP *****
41 Pi$="P:\"' Pfad-Literaturdatei
42 Po$="P:\"' Pfad-Trefferdatei
43 Pp$="P:\"' Pfad-Protokoll/Fehlerdatei/Kommentartextdatei/Hilfsdatei
44 Hilfsfile$=Pp$+"LIVEHILF.TXT"
45 '***** ParameterD *****
46 Bs$="{":Lbs%= LEN(Bs$)
47 Be$="}":Lbe%= LEN(Be$)
48 Fs$="(^":Lfs%= LEN(Fs$)
49 Fe$="^)":Lfe%= LEN(Fe$)
50 Jr1$=", 1":Ljr1%= LEN(Jr1$):Ljr11%=1'Kriterium 1, an dem eine Jahresangabe erkannt wird
51 Jr2$=":":Ljr2%= LEN(Jr2$)'           Kriterium 2, -"-
52 Kr$="^D:":Lkr%= LEN(Kr$)
53 Rga$=">":Lra%= LEN(Rga$)
54 Rka$="<":Lka%=Lra%' <- ACHTUNG: rga$ und rka$ mssen gleich lang sein!
55 Ts1$="%":Lts1%= LEN(Ts1$)'Trennzeichen im Sortier-Feld, Record-Start im Fg$-Feld
56 Ts2$="Ý":Lts2%= LEN(Ts2$)'Trennzeichen im Sortier-Feld, Record-Ende im Fg$-Feld
57  'ACHTUNG: Ts1$ und Ts2$ sollten in der Titelzeile eines Records nicht vorkommen!
58 Mzr%=1000'Maximale Laenge eines Records in Zeilen
59 '***** allgemeine Programmablauf-Variablen *****
60 Cdown%=25'Cursor Down: ASCII-Code (CTRL Y)
61 Cup%=1'   Cursur up: ASCII-Code (CTRL A)
62 Cok%=13'  Bestaetigung (RETURN)
63 Aa$=""'   Anzeiger fuer Option
64 Dpp%=39'  Doppelpunkt bei Input-Position
65 Him%=22'  y-Position fuer Bildschirm-Meldungen
66 Him2%=24' y-Position fuer kleine Menuezeile
67 Ps%=0'    Dient dem Festhalten der Cursorposition beim Springen zur MHilfe
68 RETURN
69 DEF PROC Mhauptmenue
70 Pn$="hm"
71 CLS
72 PRINT "  --- HAUPTMENUE      ";Version$;" ---"
73 PRINT
74 PRINT "  Literatur recherchieren            :"
75 PRINT "  Literaturliste sortieren           :"
76 PRINT "  Rohe Literatursammlung aufbereiten :"
77 PRINT "  Datei-Parameter ver„ndern          :"
78 PRINT "  Programm-Parameter ver„ndern       :"
79 PRINT "       * Hilfe                       :"
80 PRINT "       * Programm beenden            :"
81 PRINT "       * Neustart                    :"
82 Hilfe
83 Panfang%=3:Pende%=10
84 P%=Panfang%:Pquit%=Pende%-1:Philfe%=Pende%-2
85 IF Ps%>Panfang% THEN
86  P%=Ps%:Ps%=0
87  ENDIF
88 WHILE P%>Panfang%-1 AND P%<Pende%+1
89  Eingabe
90  IF T%=27 OR T%=Cok% OR T$="h" OR T$="s" THEN
91   EXIT
92   ENDIF
93  WEND
94 IF T%=27 THEN
95  Ende
96  ENDIF
97 IF T$="h" THEN
98  Mhilfe
99  Weiter
100  ENDIF
101 IF P%=Panfang% THEN
102  Mrecherche
103  ENDIF
104 IF P%=Panfang%+1 THEN
105  Msortieren
106  ENDIF
107 IF P%=Panfang%+2 THEN
108  Maufbereiten
109  ENDIF
110 IF P%=Panfang%+3 THEN
111  Mparameterd
112  ENDIF
113 IF P%=Panfang%+4 THEN
114  Mparameterp
115  ENDIF
116 IF P%=Philfe% THEN
117  Mhilfe
118  Weiter
119  ENDIF
120 IF P%=Pquit% THEN
121  Ende
122  ENDIF
123 IF P%=Panfang%+7 THEN
124  CLS : RUN
125  ENDIF
126 RETURN
127 DEF PROC Mrecherche
128 Pn$="rc"
129 CLS
130 PRINT "RECHERCHE..."
131 PRINT
132 PRINT "Gesuchte Zeichen (Schlagwort mit //!): ";Gs$
133 PRINT "Name der Literaturdatei              : ";Nld$
134 PRINT "Name der Trefferdatei                : ";Ntd$
135 PRINT "Datei ohne Treffer anlegen (j/n)     : ";Tld$
136 PRINT " Name dieser trefferlosen Datei      : ";Ntld$
137 PRINT "Ausgabe mit-/ ohne Footer (m/o)      : ";Mof$
138 PRINT "       * Start                       : "
139 PRINT "       * Directory Pfad Inputdatei   : "
140 PRINT "       * Hilfe                       : "
141 PRINT "       * Zurueck                     : "
142 PRINT "       * Programm beenden            : "
143 Hilfe
144 Panfang%=3:Pende%=13
145 P%=Panfang%:Pok%=Pende%-4:Pdir%=Pende%-3:Philfe%=Pende%-2:Pzurueck%=Pende%-1:Pquit%=Pende%
146 IF Ps%>Panfang% THEN
147  P%=Ps%:Ps%=0
148  ENDIF
149 WHILE P%>Panfang%-1 AND P%<Pende%+1
150  Eingabe
151  IF T%=27 OR T$="s" OR T$="h" THEN
152   EXIT
153   ENDIF
154  IF T%=Cok% THEN
155   IF P%=Pok% OR P%=Pzurueck% OR P%=Pquit% OR P%=Philfe% OR P%=Pdir% THEN
156    EXIT
157    ENDIF
158   LOCATE P%,Dpp%: PRINT "                             "
159   LOCATE P%,Dpp%: LINE INPUT Eing$
160  IF P%=Panfang% THEN
161   Gs$=Eing$:Lgs%= LEN(Gs$)
162   ENDIF
163  IF P%=Panfang%+1 THEN
164   Nld$=Eing$:Lnld%= LEN(Nld$)
165   ENDIF
166  IF P%=Panfang%+2 THEN
167   Ntd$=Eing$:Lntd%= LEN(Ntd$)
168   ENDIF
169  IF P%=Panfang%+3 THEN
170   Tld$=Eing$:Ltld%= LEN(Tld$)
171   ENDIF
172  IF P%=Panfang%+4 THEN
173   Ntld$=Eing$:Lntld%= LEN(Ntld$)
174   ENDIF
175  IF P%=Panfang%+5 THEN
176   Mof$=Eing$
177   ENDIF
178  P%=P%+1
179  ENDIF
180 WEND
181 Hidizuqu
182 Precherche
183 RETURN
184 DEF PROC Msortieren
185 Pn$="st"
186 CLS
187 PRINT "SORTIEREN..."
188 PRINT
189 PRINT "Name der unsortierten Literaturdatei : ";Nld$
190 PRINT "Name der sortierten Literaturdatei   : ";Ntd$
191 PRINT "Name der Fehler-Protokoll-Datei      : ";Ntld$
192 PRINT "Maximale Zeilenzahl einer Datei      : ";Mzd%L
193 PRINT "Maximale Sortierlaenge eines Titels  : ";Slt%
194 PRINT "       * Start                       : "
195 PRINT "       * Directory Pfad Inputdatei   : "
196 PRINT "       * Hilfe                       : "
197 PRINT "       * Zurueck                     : "
198 PRINT "       * Programm verlassen          : "
199 Hilfe
200 Panfang%=3:Pende%=12
201 P%=Panfang%:Pok%=Pende%-4:Pdir%=Pende%-3:Philfe%=Pende%-2:Pzurueck%=Pende%-1:Pquit%=Pende%
202 IF Ps%>Panfang% THEN
203  P%=Ps%:Ps%=0
204  ENDIF
205 WHILE P%>Panfang%-1 AND P%<Pende%+1
206  Eingabe
207  IF T%=27 OR T$="s" OR T$="h" THEN
208   EXIT
209   ENDIF
210 IF T%=Cok% THEN
211  IF P%=Pok% OR P%=Pzurueck% OR P%=Pquit% OR P%=Philfe% OR P%=Pdir% THEN
212   EXIT
213   ENDIF
214  LOCATE P%,Dpp%: PRINT "                             "
215  LOCATE P%,Dpp%: LINE INPUT Eing$
216  IF P%=Panfang% THEN
217   Nld$=Eing$:Lnld%= LEN(Nld$)
218   ENDIF
219  IF P%=Panfang%+1 THEN
220   Ntd$=Eing$:Lntd%= LEN(Ntd$)
221   ENDIF
222  IF P%=Panfang%+2 THEN
223   Ntld$=Eing$:Lntld%= LEN(Ntld$)
224   ENDIF
225  IF P%=Panfang%+3 THEN
226   Mzd%L= VAL(Eing$)
227   ENDIF
228  IF P%=Panfang%+4 THEN
229   Slt%= VAL(Eing$)
230   ENDIF
231  IF P%=Panfang%+5 THEN
232   EXIT
233   ENDIF
234   P%=P%+1
235  ENDIF
236 WEND
237 Hidizuqu
238 Psortieren
239 RETURN
240 DEF PROC Maufbereiten
241 Pn$="ab"
242 CLS
243 PRINT "ROHLITERATURLISTE AUFBEREITEN..."
244 PRINT
245 PRINT "Datei-Name der rohen Literaturliste  : ";Nld$
246 PRINT "Datei-Name der aufbereiteten Liste   : ";Ntd$
247 PRINT "Eingabe des Footers : ";Footer$
248 PRINT "Kommentartext unter ^T: ergaenzen?   : ";Kte$
249 PRINT "  Name dieser Kommentartext-Datei    : ";Ntld$
250 PRINT "  Max. Zeilenlaenge des Kommentartext: ";Mzr%
251 PRINT "Kriterium 1 Notationskorrektur Jahr  : ";Nkj1$
252 PRINT "Kriterium 2 Notationskorrektur Jahr  : ";Nkj2$
253 PRINT "Zaehler bei ^D:xxyyzz-aa ergaenzen?  : ";Hze$
254 PRINT "  Zaehler-Start                      : ";Hzes%
255 PRINT "  Kriterium zur Position. d. Zaehlers: ";Hzep$
256 PRINT "       * Start                       : "
257 PRINT "       * Directory Pfad Inputdatei   : "
258 PRINT "       * Hilfe                       : "
259 PRINT "       * Zurueck                     : "
260 PRINT "       * Programm verlassen          : "
261 LOCATE Him%,0
262 PRINT " ACHTUNG! Am Anfang jeden Roh-Titels muss ein ";Bs$;" stehen und die Titel muessen"
263 PRINT "          durch eine Leerzeile voneinander getrennt sein."
264 Panfang%=3:Pende%=18
265 P%=Panfang%:Pok%=Pende%-4:Pdir%=Pende%-3:Philfe%=Pende%-2:Pzurueck%=Pende%-1:Pquit%=Pende%
266 Hilfe
267 IF Ps%>Panfang% THEN
268  P%=Ps%:Ps%=0
269  ENDIF
270 WHILE P%>Panfang%-1 AND P%<Pende%+1
271  Eingabe
272  IF T%=27 OR T$="s" OR T$="h" THEN
273   EXIT
274   ENDIF
275  IF T%=Cok% THEN
276   IF P%=Pok% OR P%=Pzurueck% OR P%=Pquit% OR P%=Philfe% OR P%=Pdir% THEN
277    EXIT
278    ENDIF
279   IF P%=Panfang%+2 THEN
280    ' Footer-Spezialbehandlung
281    Dpp%=Dpp%-17
282    LOCATE P%,Dpp%: PRINT "                                                    "
283    ENDIF
284   LOCATE P%,Dpp%: PRINT "                                    "
285   LOCATE P%,Dpp%: LINE INPUT Eing$
286   IF P%=Panfang% THEN
287    Nld$=Eing$:Lnld%= LEN(Nld$)
288    ENDIF
289   IF P%=Panfang%+1 THEN
290    Ntd$=Eing$:Lnld%= LEN(Ntd$)
291    ENDIF
292   IF P%=Panfang%+2 THEN
293    Footer$=Eing$
294    Dpp%=Dpp%+17
295    ENDIF
296   IF P%=Panfang%+3 THEN
297     Eingstand
298     Kte$=Eing$
299    ENDIF
300   IF P%=Panfang%+4 THEN
301    Ntld$=Eing$:Lnld%= LEN(Ntld$)
302    ENDIF
303   IF P%=Panfang%+5 THEN
304    Mzr%= VAL(Eing$)
305    ENDIF
306   IF P%=Panfang%+6 THEN
307    Nkj1$=Eing$:Lnkj1%= LEN(Nkj1$)
308    ENDIF
309   IF P%=Panfang%+7 THEN
310    Nkj2$=Eing$:Lnkj2%= LEN(Nkj2$)
311    ENDIF
312   IF P%=Panfang%+8 THEN
313    Eingstand
314    Hze$=Eing$
315    ENDIF
316   IF P%=Panfang%+9 THEN
317    Hzes%= VAL(Eing$)
318    ENDIF
319   IF P%=Panfang%+10 THEN
320    Hzep$=Eing$:Lhzep%= LEN(Hzep$)
321    ENDIF
322   IF P%=Pok% OR T$="s" THEN
323    EXIT
324    ENDIF
325   P%=P%+1
326   ENDIF
327  WEND
328  Hidizuqu
329 Paufbereiten
330 RETURN
331 DEF PROC Mparameterp
332 Pn$="pmp"
333 CLS
334 PRINT "PROGRAMM-PARAMETER..."
335 PRINT
336 PRINT "Pfad fuer Input-Datei                : ";Pi$
337 PRINT "Pfad fuer Output-Datei               : ";Po$
338 PRINT "Pfad fuer Protokoll-Datei            : ";Pp$
339 PRINT "Hilfsdatei (Pfad mit angeben!)       : ";Hilfsfile$
340 PRINT "       * Directory Pfad Inputdatei   : "
341 PRINT "       * Hilfe                       : "
342 PRINT "       * Zurueck                     : "
343 PRINT "       * Programm verlassen          : "
344 Hilfe
345 Panfang%=3:Pende%=10
346 P%=Panfang%:Pdir%=Pende%-3:Philfe%=Pende%-2:Pzurueck%=Pende%-1:Pquit%=Pende%
347 IF Ps%>Panfang% THEN
348  P%=Ps%:Ps%=0
349  ENDIF
350 WHILE P%>Panfang%-1 AND P%<Pende%+1
351  Eingabe
352 IF T%=27 OR T$="s" OR T$="h" THEN
353  EXIT
354  ENDIF
355 IF T%=Cok% THEN
356  IF P%=Pok% OR P%=Pzurueck% OR P%=Pquit% OR P%=Philfe% OR P%=Pdir% THEN
357   EXIT
358   ENDIF
359  LOCATE P%,Dpp%: PRINT "                             "
360  LOCATE P%,Dpp%: LINE INPUT Eing$
361  IF P%=Panfang% THEN
362   Pi$=Eing$:Lpi%= LEN(Pi$)
363   ENDIF
364  IF P%=Panfang%+1 THEN
365   Po$=Eing$:Lpo%= LEN(Po$)
366   ENDIF
367  IF P%=Panfang%+2 THEN
368   Pp$=Eing$:Lpp%= LEN(Pp$)
369   ENDIF
370  IF P%=Panfang%+3 THEN
371   Hilfsfile$=Eing$
372   ENDIF
373   P%=P%+1
374  ENDIF
375 WEND
376 Hidizuqu
377 RETURN
378 DEF PROC Mparameterd
379 Pn$="pmd"
380 CLS
381 PRINT "DATEI-PARAMETER..."
382 PRINT
383 PRINT "Body-Start                           : ";Bs$
384 PRINT "Body-Ende                            : ";Be$
385 PRINT "Footer-Start                         : ";Fs$
386 PRINT "Footer-Ende                          : ";Fe$
387 PRINT "Kennzeichen 1 Jahr                   : ";Jr1$
388 PRINT "Kennzeichen 2 Jahr                   : ";Jr2$
389 PRINT "Kennzeichen Referenz-Nummer          : ";Kr$
390 PRINT "Groesser als                         : ";Rga$
391 PRINT "Kleiner als                          : ";Rka$
392 PRINT "Feldtrenner 1 - Sortieren            : ";Ts1$
393 PRINT "Feldtrenner 2 - Sortieren            : ";Ts2$
394 PRINT "Maximale Zeilenzahl eines Records    : ";Mzr%
395 PRINT "       * Directory Pfad Inputdatei   : "
396 PRINT "       * Hilfe                       : "
397 PRINT "       * Zurueck                     : "
398 PRINT "       * Programm verlassen          : "
399 Hilfe
400 Panfang%=3:Pende%=18
401 P%=Panfang%:Pdir%=Pende%-3:Philfe%=Pende%-2:Pzurueck%=Pende%-1:Pquit%=Pende%
402 IF Ps%>Panfang% THEN
403  P%=Ps%:Ps%=0
404  ENDIF
405 WHILE P%>Panfang%-1 AND P%<Pende%+1
406  Eingabe
407 IF T%=27 OR T$="h" THEN
408  EXIT
409  ENDIF
410 IF T%=Cok% THEN
411  IF P%=Pok% OR P%=Pzurueck% OR P%=Pquit% OR P%=Philfe% OR P%=Pdir% THEN
412   EXIT
413   ENDIF
414  LOCATE P%,Dpp%: PRINT "                             "
415  LOCATE P%,Dpp%: LINE INPUT Eing$
416  IF P%=Panfang% THEN
417   Bs$=Eing$:Lbs%= LEN(Bs$)
418   ENDIF
419  IF P%=Panfang%+1 THEN
420   Be$=Eing$:Lbe%= LEN(Be$)
421   ENDIF
422  IF P%=Panfang%+2 THEN
423   Fs$=Eing$:Lfs%= LEN(Fs$)
424   ENDIF
425  IF P%=Panfang%+3 THEN
426   Fe$=Eing$:Lfe%= LEN(Fe$)
427   ENDIF
428  IF P%=Panfang%+4 THEN
429   Jr1$=Eing$:Ljr1%= LEN(Jr1$)
430   ENDIF
431  IF P%=Panfang%+5 THEN
432   Jr2$=Eing$:Ljr2%= LEN(Jr2$)
433   ENDIF
434  IF P%=Panfang%+6 THEN
435   Kr$=Eing$:Lkr%= LEN(Kr$)
436   ENDIF
437  IF P%=Panfang%+7 THEN
438   Rga$=Eing$:Lra%= LEN(Rga$)
439   ENDIF
440  IF P%=Panfang%+8 THEN
441   Rka$=Eing$
442   ENDIF
443  IF P%=Panfang%+9 THEN
444   Ts1$=Eing$:Lra%= LEN(Ts1$)
445   ENDIF
446  IF P%=Panfang%+10 THEN
447   Ts2$=Eing$:Lra%= LEN(Ts2$)
448   ENDIF
449  IF P%=Panfang%+11 THEN
450   Mzr%= VAL(Eing$)
451   ENDIF
452   P%=P%+1
453  ENDIF
454 WEND
455 Hidizuqu
456 RETURN
457 DEF PROC Eingabe
458 LOCATE P%,Dpp%-2:T$= INPUT$(1)
459 T%= ASC(T$)
460 IF T%=Cdown% THEN
461  LOCATE P%,Dpp%-2
462  P%=P%+1
463  ENDIF
464 IF T%=Cup% THEN
465  LOCATE P%,Dpp%-2
466  P%=P%-1
467  ENDIF
468 IF P%=Pende%+1 THEN
469  P%=Panfang%
470  ENDIF
471 IF P%=Panfang%-1 THEN
472  P%=Pende%
473  ENDIF
474 RETURN
475 DEF PROC Eingstand
476 IF Eing$="ja" OR Eing$="Ja" OR Eing$="JA" THEN
477  Eing$="j"
478  ENDIF
479 RETURN
480 DEF PROC Devtest
481 IF MID$(Nld$,2,2)=":\" THEN
482  Pi$=""
483  ENDIF
484 IF MID$(Ntd$,2,2)=":\" THEN
485  Po$=""
486  ENDIF
487 IF Ntld$<>"" THEN
488  IF MID$(Ntld$,2,2)=":\" THEN
489   Pp$=""
490   ENDIF
491  Ntld$=Pp$+Ntld$
492  ENDIF
493 Nld$=Pi$+Nld$
494 Ntd$=Po$+Ntd$
495 RETURN
496 DEF PROC Trefftest
497 Rzal%L= VAL(Rzal$)
498 IF Rv$=Rga$ THEN
499  IF Rzal%L>Rn%L THEN
500   ' Treffer Zahl groesser als angegebener Muster-String
501   Treff%=1:It%=It%+1
502   ENDIF
503  ENDIF
504 IF Rv$=Rka$ THEN
505  IF Rzal%L<Rn%L THEN
506   ' Treffer Zahl kleiner als angegebenen Muster-String
507   Treff%=1:It%=It%+1
508   ENDIF
509  ENDIF
510 Ira2%=0
511 RETURN
512 DEF PROC Ende
513 CLS
514 LOCATE 11,12: PRINT "Verlassen?   Ende: LEERTASTE   Weitermachen: RETURN"
515 T$= INPUT$(1)
516 T%= ASC(T$)
517 IF T%=13 THEN
518  Mhauptmenue
519 ENDIF
520 IF T%=32 OR T%=27 THEN
521  STOP : END
522  ENDIF
523 RETURN
524 DEF PROC Hilfe
525 LOCATE Him2%,1: PRINT "Hilfe:h    Quit:ESC   Up:CTRL_A    Down:CTRL_Y    Anwahl:RETURN    Start:S"
526 RETURN
527 DEF PROC Break
528 IF INKEY$ <>"" THEN
529  LOCATE Him%,0
530  PRINT "Fortsetzen .......... RETURN"
531  PRINT "Neustart des Programms . ESC"
532  PRINT "Programm verlassen ....... q"
533  Abin$= INPUT$(1)
534  ENDIF
535  IF Abin$= CHR$(27) THEN
536   CLOSE : RUN
537   ENDIF
538  IF Abin$="q" THEN
539   CLOSE :Pn$="hm":Ende
540   ENDIF
541 RETURN
542 DEF PROC Weiter
543 PRINT "Weiter: RETURN"
544 Dummy$= INPUT$(1)
545 IF ASC(Dummy$)=32 AND Fi%=1 THEN
546  Fi%=0
547  CLS
548  Hi%=0
549  OPEN "i",4,Ntd$
550  WHILE NOT EOF(4)
551   LINE INPUT #4,Z$
552   Hi%=Hi%+1
553   PRINT Z$
554   IF Hi%=Him% THEN
555    Hi%=0
556    PRINT "___"
557    PRINT "Weiter: LEERTASTE / Zurueck: ESC"
558    Dummy$= INPUT$(1)
559    IF ASC(Dummy$)=27 THEN
560     EXIT
561     ENDIF
562    CLS
563    ENDIF
564   WEND
565  CLOSE 4
566  PRINT
567  PRINT "Zurueck zum Programm: RETURN"
568  Dummy$= INPUT$(1)
569  ENDIF
570 IF Pn$="hm" THEN
571  Mhauptmenue
572  ENDIF
573 IF Pn$="rc" THEN
574  Mrecherche
575  ENDIF
576 IF Pn$="st" THEN
577  Msortieren
578  ENDIF
579 IF Pn$="ab" THEN
580  Maufbereiten
581  ENDIF
582 IF Pn$="pmp" THEN
583  Mparameterp
584  ENDIF
585 IF Pn$="pmd" THEN
586  Mparameterd
587  ENDIF
588 RETURN
589 DEF PROC Mhilfe
590 CLS
591 Hi%=0
592 OPEN "i",4,Hilfsfile$
593 WHILE NOT EOF(4)
594  LINE INPUT #4,Z$
595  IF INSTR(Z$,"#") THEN
596   IF INSTR(Z$,Pn$) THEN
597    EXIT
598    ENDIF
599   ENDIF
600  WEND
601 Hi%=0
602 WHILE NOT EOF(4)
603  LINE INPUT #4,Z$
604  Hi%=Hi%+1
605  IF INSTR(Z$,"#") THEN
606   EXIT
607   ENDIF
608  PRINT Z$
609  IF Hi%=Him% THEN
610   Hi%=0
611   PRINT "___"
612   PRINT "LEERTASTE / ESC"
613   Dummy$= INPUT$(1)
614   IF ASC(Dummy$)=27 THEN
615    EXIT
616    ENDIF
617   CLS
618   ENDIF
619  WEND
620 CLOSE 4
621 Ps%=P%
622 RETURN
623 DEF PROC Hidizuqu
624 IF P%=Philfe% OR T$="h" THEN
625  Mhilfe
626  Weiter
627  ENDIF
628 IF P%=Pzurueck% OR T%=27 THEN
629  Mhauptmenue
630  ENDIF
631 IF P%=Pdir% THEN
632  CLS
633  FILES Pi$+"*.*"
634  Weiter
635  ENDIF
636 IF P%=Pquit% THEN
637  Ende
638  ENDIF
639 RETURN
640 DEF PROC Precherche
641 DIM Feldrec$(Mzr%):' Feld, in das ein Record eingelesen wird
642 Devtest
643 Gs2$=Gs$:Lgs2%= LEN(Gs2$)
644 Ira%=0:Ira2%=0:Xra$= LEFT$(Gs$,Lra%)
645 IF Xra$=Rga$ OR Xra$=Rka$ THEN
646  Ira%=1:Ira2%=1:Rn$= RIGHT$(Gs$,Lgs%-Lra%):Rn%L= VAL(Rn$)
647  Rv$=Xra$
648  Gs$=Rn$:Lgs%= LEN(Gs$)
649  ENDIF
650 IF Mof$="mit" OR Mof$="MIT" THEN
651  Mof$="m"
652  ENDIF
653 IF Mof$="ohne" OR Mof$="OHNE" THEN
654  Mof$="o"
655  ENDIF
656 OPEN "i",1,Nld$
657 OPEN "o",2,Ntd$
658 IF Ntld$<>"" THEN
659  OPEN "o",3,Ntld$
660  ENDIF
661 PRINT #2,""
662 PRINT #2,Version$
663 PRINT #2, DATE$ ;" - "; TIME$
664 PRINT #2,"Input-File : ";Nld$
665 PRINT #2,"Output-File: ";Ntd$
666 PRINT #2,"Gesuchter String: ";Gs2$
667 PRINT #2,"=================="+ STRING$(Lgs2%,"=")
668 PRINT #2,""
669 CLS
670 PRINT "Abbruch durch ESC..."
671 PRINT
672 PRINT Version$
673 PRINT "ZEILE / TREFFER (";Gs2$;")"
674 PRINT "------------------"+ STRING$(Lgs2%,"-")
675 Ig%=0:' Gesamtzeilenzaehler
676 It%=0:' Trefferzaehler
677 Is%=0:' Feld-Zaehler
678 Treff%=0:' Wenn Treffer gefunden, dann treff%=1,
679               '                        sonst treff%=0
680 WHILE NOT EOF(1)
681 Break
682 LINE INPUT #1,Z$
683 Ig%=Ig%+1: LOCATE 6,1: PRINT Ig%,It%
684 Is%=Is%+1
685 Feldrec$(Is%)=Z$
686 Se%= INSTR(Z$,Fe$):' Test auf Recordende
687 IF Ira%=0 THEN
688  Gsi%= INSTR(Z$,Gs$)
689  IF Gsi%>0 THEN
690   'Treffer bei Stringgleichheit
691   Treff%=1:It%=It%+1
692   ENDIF
693  ENDIF
694 IF Ira%=1 AND Ira2%=1 THEN
695  ' Treffer bei < oder > - Eingabe
696  Sbs%= INSTR(Z$,Bs$)
697  Sfs%= INSTR(Z$,Fs$)
698  IF Sbs%>0 AND Lgs%=4 THEN
699   ' Test auf Titel-Jahr
700   Sjr1%= INSTR(Z$,Jr1$)
701   Sjr2%= INSTR(Z$,Jr2$)
702   IF Sjr2%>Sjr1% THEN
703    Rzal$= MID$(Z$,Sjr1%+Ljr1%-Ljr11%,Lgs%)
704    Trefftest
705    ENDIF
706   ENDIF
707  IF Sfs%>0 AND Lgs%=6 THEN
708   ' Test auf Erfassungsdatum ^D:
709   Sdp2%= INSTR(Z$,Kr$)
710   Rzal$= MID$(Z$,Sdp2%+Lkr%,Lgs%)
711   Trefftest
712   ENDIF
713  ENDIF
714 IF Se%>0 AND Treff%=0 AND Tld$="j" THEN
715  ' Rausschreiben der Datei ohne die Treffer-Records
716  FOR I%=1 TO Is%
717   PRINT #3,Feldrec$(I%)
718   NEXT
719   Ira2%=1
720  ENDIF
721 IF Se%>0 AND Treff%=0 THEN
722  ' Kein Treffer, kein Rausschreiben, Feldzaehler wird genullt
723  Is%=0:Ira2%=1
724  ENDIF
725 IF Se%>0 AND Treff%=1 THEN
726  ' In die Trefferdatei schreiben
727  I%=0
728  WHILE I%<Is%
729   I%=I%+1
730   Zs$=Feldrec$(I%):Lzs%= LEN(Zs$)
731   Sfs%= INSTR(Zs$,Fs$)
732   IF Sfs%>0 AND Mof$="o" THEN
733    EXIT
734    ENDIF
735
736   Sbs%= INSTR(Zs$,Bs$)
737   IF Sbs%>0 THEN
738    Zs$= MID$(Zs$,Sbs%,Lzs%)
739    IF Mof$="o" THEN
740     Zs$= MID$(Zs$,Sbs%+Lbs%,Lzs%-Lbs%)
741     ENDIF
742    ENDIF
743   Lzs%= LEN(Zs$)
744   Sbe%= INSTR(Zs$,Be$)
745   IF Sbe%>0 THEN
746    Zs$= MID$(Zs$,1,Lzs%)
747    IF Mof$="o" THEN
748     Zs$= MID$(Zs$,1,Lzs%-Lbe%)
749     ENDIF
750    ENDIF
751
752   IF Zs$<>"" THEN
753    PRINT #2,Zs$
754    ENDIF
755   WEND
756  PRINT #2,""
757  Is%=0:Treff%=0:Ira2%=1
758  ENDIF
759 WEND
760 PRINT #2,""
761 PRINT #2,"=================="
762 PRINT #2,"Trefferzahl: ";It%
763 PRINT #2,"=================="
764 CLOSE
765 Fi%=1' Dient in der Weiter-Proc als Anzeiger fuer Fertig
766 PRINT
767 PRINT "* FERTIG - ";It%;" Treffer: ";Gs2$
768 PRINT "* Die Datei mit den gefundenen Records: ";Ntd$
769 IF Tld$="j" THEN
770  PRINT "* Siehe die Datei mit den geloeschten Eintraegen: ";Ntld$
771  ENDIF
772 PRINT
773 PRINT "Trefferdatei ansehen: LEERTASTE"
774 Weiter
775 RETURN
776 DEF PROC Psortieren
777 DIM Fges$(Mzd%L):' Das Inputfile wird komplett in dieses Feld eingelesen
778 DIM Fsort$(Mzd%L/2):' Das Sortierfeld
779 ' Das Sortierfeld Fsort$ beinhaltet die slt%-Bytes einer Zeile sowie daran
780 ' angeschlossen, den Anfang ss% und das Ende se% eines Literatureintrags,
781 ' wobei ss% zwischen Ts1$ und Ts2$ und se% durch Ts2$ bis String-Ende
782 ' kenntlich gemacht werden.
783 ' Nachdem Fsort$ sortiert wurde, werden ss% und se% wieder
784 ' herausgeschnitten und entsprechend diesen Angaben wird das Record
785 ' aus dem Fges$-Feld herausgeschrieben.
786 Devtest
787 Ig%=0:' Gesamtzeilenz„hler
788 I%=0:' Recordz„hler
789 Sch%=0:' Sch geht auf 1, wenn Formatfehler
790 CLS
791 PRINT Version$
792 PRINT "Einlesen von ";Nld$;" ins Feld..."
793 PRINT "RECORD"
794 PRINT "======"
795 OPEN "i",1,Nld$
796 OPEN "o",2,Ntd$
797 OPEN "o",3,Ntld$
798 WHILE NOT EOF(1)
799  Break
800  LINE INPUT #1,Z$
801  Ig%=Ig%+1
802  IF LEFT$(Z$,Lbe%)=Be$ THEN
803   Sch%=1: PRINT #3,"Formatfehler in Zeile: ";Ig%
804   ENDIF
805  Fges$(Ig%)=Z$
806  Ss%= INSTR(Z$,Bs$)
807  IF Ss%>0 THEN
808   Ssi%=Ig%
809   ENDIF
810  Sbs%= INSTR(Z$,Bs$)
811  IF Sbs%>0 THEN
812   ' Neues Record gefunden
813   Sbs$= MID$(Z$,1,Slt%)
814   ENDIF
815  Se%= INSTR(Z$,Fe$)
816  IF Se%>0 THEN
817   ' Record-Ende gefunden
818   Sei%=Ig%
819   I%=I%+1: LOCATE 6,1: PRINT I%
820   Fsort$(I%)=Sbs$+Ts1$+ STR$(Ssi%)+Ts2$+ STR$(Sei%)
821   ' Reinschreiben der ersten Zeile (slt%-lang) ins Sortierfeld fsort$
822   ' sowie den Feldstart und das Feldende des Records im Gesamtfeld Fges$
823   ENDIF
824  WEND
825 IF Sch%=0 THEN
826  ' Keinen Formatfehler entdeckt
827  CLS
828  PRINT "Sortieren..."
829  SORT Fsort$(I%): REM ***** Was fuer eine Luxus-Programmiersprache :-)!
830  REM                        Lexikalisch korrektes Sortieren!
831  CLS
832  PRINT "Rausschreiben der sortierten Records..."
833  PRINT "Test auf Doppeleintr„ge..."
834  PRINT "RECORD"
835  PRINT "======"
836  De1$=" ":De2$=" ":Dei%=0
837  PRINT #3,"Verdacht auf Doppeleintrag:"
838  PRINT #3,"==========================="
839  FOR M%=1 TO I%
840   LOCATE 6,1: PRINT M%
841   Ms$=Fsort$(M%):Lms%= LEN(Ms$)
842   Mss%= INSTR(Ms$,Ts1$)
843   Mse%= INSTR(Ms$,Ts2$)
844   Mss$= MID$(Ms$,Mss%+Lts1%,Mse%-Lts2%)
845   Mse$= MID$(Ms$,Mse%+Lts2%,Lms%)
846   Gss%= VAL(Mss$)
847   Gse%= VAL(Mse$)
848   De1$=De2$
849   De2$= LEFT$(Ms$,Mss%-Lts1%):Des%=0
850   IF De1$=De2$ THEN
851    Des%=1:Dei%=Dei%+1: LOCATE 8,2: PRINT Dei%: PRINT #3,""
852    ENDIF
853   IF Gss%<>0 AND Gse%<>0 AND Gse%>Gss% THEN
854    FOR N%=Gss% TO Gse%
855     IF Fges$(N%)<>"" THEN
856      PRINT #2,Fges$(N%)
857      IF Des%=1 THEN
858       PRINT #3,Fges$(N%)
859       ENDIF
860      ENDIF
861     NEXT N%
862     PRINT #2,""
863    ELSE
864    PRINT #3," --- Fehler (Format?), Zeile-Start/ Zeilenende ";Gss%;Gse%
865    Dei%=Dei%+1
866    ENDIF
867   NEXT M%
868  CLOSE
869  Fi%=1' Dient in der weiter-Proc als Anzeiger fuer Fertig
870  CLS
871  PRINT
872  PRINT "* Sortierte Datei steht unter    : ";Ntd$
873  PRINT "* Die Protokoll-Datei steht unter: ";Ntld$
874  PRINT
875  PRINT "Sortierte Datei ansehen: LEERTASTE"
876  ENDIF
877 IF Sch%=1 THEN
878  ' Formatfehler entdeckt
879  CLS
880  PRINT "* ABBRUCH..."
881  PRINT "* Formatfehler in ";Nld$;" entdeckt."
882  PRINT "* Ein Protokoll der Fehler findet sich in der Datei: ";Ntld$
883  PRINT "* Nach Behebung der Fehler Programm erneut starten."
884  ENDIF
885 Weiter
886 RETURN
887 DEF PROC Paufbereiten
888 IF RIGHT$(Footer$,Lfe%)<>Fe$ THEN Footer$=Footer$+Fe$: ENDIF
889 IF LEFT$(Footer$,Lfs%)<>Fs$ THEN Footer$=Fs$+Footer$: ENDIF
890 Lfooter%= LEN(Footer$)
891 Devtest
892 OPEN "i",1,Nld$
893 OPEN "o",2,Ntd$
894 IF Kte$="j" THEN
895  ' Einlesen des Kommentartextes, der standardisiert an ^T: rangesetzt werden soll
896  OPEN "i",3,Ntld$
897  DIM Feld$(Mzr%)
898  It%=0
899  WHILE NOT EOF(3)
900   It%=It%+1
901   LINE INPUT #3,Tfeld$(It%)
902   WEND
903  Footer$= LEFT$(Footer$,Lfooter%-Lfe%)
904  ' Kommentartext steht in Tfeld$, deshalb muss das Footer-Ende-Zeichen
905  ' fe$ ^) zunaechst wieder weggenommen werden
906  CLOSE 3
907  ENDIF
908 IF Hze$="j" THEN
909  Footp1%= INSTR(Footer$,Hzep$)
910  Footer1$= LEFT$(Footer$,Footp1%-1)
911  Footer2$= MID$(Footer$,Footp1%)
912  ENDIF
913 CLS
914 DIM Feld$(Mzr%)
915 Ig%=0' Gesamtzaehler
916 Is%=0' Zeilenzaehler des Titels
917 Le%=0' Indikator fuer gefundenen Titel
918 Ihzes%=Hzes%-1' Start fuer Hochzaehlen nach ^D:xxyyzz-aa und vor ^M:
919 PRINT #2,""
920 PRINT #2,Version$
921 PRINT #2, DATE$ ;" - "; TIME$
922 PRINT #2,"Input-File : ";Nld$
923 PRINT #2,"Output-File: ";Ntd$
924 PRINT #2,"=================="+ STRING$(Lntd%,"=")
925 PRINT #2,""
926 CLS
927 PRINT "Abbruch durch ESC..."
928 PRINT
929 PRINT Version$
930 PRINT "ZEILE"
931 PRINT "-----"
932 WHILE NOT EOF(1)
933  Break
934  LINE INPUT #1,Z$
935  Lz%= LEN(Z$)
936  Ig%=Ig%+1: LOCATE 6,1: PRINT Ig%
937  Is%=Is%+1
938  Sbs%= INSTR(Z$,Bs$)
939  IF Sbs%>0 THEN
940   ' Neuer Literatureintrag ist gefunden
941   Ihzes%=Ihzes%+1
942   Le%=1
943   ENDIF
944  IF RIGHT$(Z$,1)<>" " THEN
945   ' Leerzeichen Zeilenende anfuegen wegen Formatierung
946   Z$=Z$+" "
947   ENDIF
948  Sk1%= INSTR(Z$,Nkj1$)' Jahresangabe vor Doppelpunkt in Klammern?
949  Sk2%= INSTR(Z$,Nkj2$)' dito, 2. Kriterium
950  IF Sk2%>0 AND Sk1%>Sk2% THEN
951   ' Jahresangabe zurechtstutzen ohne ()
952   Skdif%=Sk1%-Sk2%-Lkj21%
953   Z$= LEFT$(Z$,Sk2%-Lnkj2%)+", "+ MID$(Z$,Sk2%+Lnk12%,Skdif%)+":"+ MID$(Z$,Sk1%+Lnkj1%,Lz%-Sk1%)
954   ENDIF
955  Feld$(Is%)=Z$
956  IF Z$=" " AND Le%=1 THEN
957   ' Ende eines neuen Literatureintrags ist gefunden, das mit dem Lit-Eintrag
958   ' angefuellte Feld$ wird rausgeschrieben, anschliessend  ggbfs.
959   ' noch der Kommentar aus Tfeld$
960   FOR I%=1 TO Is%-2
961    PRINT #2,Feld$(I%)
962    NEXT I%
963   Lbz$=Feld$(Is%-1)
964   Llbz%= LEN(Lbz$)
965   ' Leerzeichen als letztes Zeichen in der letzten Zeile loeschen und
966   '  Body-Ende-Zeichen sofort anschliessen.
967   Spt$= RIGHT$(Lbz$,1)
968   IF Spt$=" " THEN Lbz$= MID$(Lbz$,1,Llbz%-1): ENDIF
969   PRINT #2,Lbz$+Be$
970   IF Hze$="j" THEN
971    Ihzes$= STR$(Ihzes%)
972    IF INSTR(Ihzes$," ") THEN
973     Ihzes$= MID$(Ihzes$,2)
974     ENDIF
975    Footer$=Footer1$+Ihzes$+Footer2$
976   ENDIF
977   PRINT #2,Footer$
978   IF Kte$="j" THEN
979    FOR I%=1 TO It%-1
980     PRINT #2,Tfeld$(I%)
981     NEXT I%
982    PRINT #2,Tfeld$(It%)+Fe$
983    ENDIF
984   Le%=0:Is%=0
985   ENDIF
986  WEND
987 CLOSE
988 Fi%L=1' Dient in der weiter-Proc als Anzeiger fuer Fertig
989 CLS
990 PRINT
991 PRINT "* Die aufbereitete Literaturliste steht unter: ";Ntd$
992 PRINT
993 PRINT "Die aufbereitete Literaturliste ansehen: LEERTASTE"
994 Weiter
995 RETURN
996
997-Fehlerbehandlung
998 LOCATE Him%,0
999 PRINT "                                                                             "
1000 PRINT "                                                                             "
1001 PRINT "                                                                             "
1002 LOCATE Him%,0
1003 PRINT "** FEHLER ** "; ERR
1004 IF ERR =6 THEN
1005  PRINT "Angegebene Zahl ist zu gross."
1006  ENDIF
1007 IF ERR =7 THEN
1008  PRINT "Der RAM-Speicher ist zu klein."
1009  ENDIF
1010 IF ERR =9 OR ERR =13 THEN
1011  PRINT "Falsche Zahl oder falsches Zeichen eingegeben."
1012  ENDIF
1013 IF ERR =53 THEN
1014  PRINT "Angegebene Datei(en) sind nicht vorhanden."
1015  ENDIF
1016 IF ERR =55 THEN
1017  PRINT "Die angegebene Datei war noch offen. Alle Dateien werden geschlossen."
1018  CLOSE
1019  ENDIF
1020 IF ERR =61 OR ERR =67 THEN
1021  PRINT "Das Zieldevice (Diskette, Platte, Ram-Disk) ist voll."
1022  ENDIF
1023 RESUME W2
1024-W2
1025 Weiter
1026
1027
