0
: -----------------------------------------
1
: Demo fÅr TINY-PILOT
2
: Mini-Vokabel-Trainer Deutsch/Spanisch
3
: -----------------------------------------
4
k 0  : ZÑhler auf Null
5
ts Demo fÅr TINY-PILOT
6
t
7
t Vokabel-Trainer Deutsch/Spanisch
8
t
9
t
10
s 900
11
t Abend (nach dem Dunkelwerden) ;
12
a
13
c noche
14
s 910
15
s 900
16
t Abendbrot ;
17
a
18
c cena
19
s 910
20
s 900
21
t Abflug ;
22
a
23
c despegue
24
s 910
25
s 900
26
t Abiturient ;
27
a
28
c bachiller
29
s 910
30
s 900
31
t Abmachung ;
32
a
33
c arreglo
34
s 910
35
s 900
36
t Abort ;
37
a 
38
c retrete
39
s 910
40
s 900
41
t Auge ;
42
a 
43
c ojo
44
s 910
45
s 900
46
t Einbruch ;
47
a
48
c robo
49
s 910
50
t usw. ....
51
t Das war nur ein kleines Beispiel fÅr die Programmierung in Pilot.
52
t
53
t
54
t Kommen wir nun zur Auswertung :
55
t
56
t
899
j 930
900
t Wie ist das spanische Wort fÅr ;
901
r
910
yj 920
911
t Nein, ;
912
w
913
t ist leider falsch!
914
j 922
920
t Bravo, das war richtig!
921
g
922
t
923
r
930
g
931
t OK, das waren 8 Fragen.
932
t Richtige Antworten: ;
933
m
934
t
935
t Nochmal;
936
a
937
c ja
938
yj 0
939
c nein
940
ye
941
t
942
t Bitte mit JA oder NEIN antworten!
943
j 935
