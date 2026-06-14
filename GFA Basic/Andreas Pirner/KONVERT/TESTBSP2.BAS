100   print "Testbsp2.bas"
110   rem                  ErgÑnzungen und 'strukturelle' Leerzeichen eingebaut
120   rem
130   '
140   a = asc ("TEST")
150   print using "###"; a
160   for a=1 to 5  : print a;: next a   :rem next MIT var a
170   '
180   for A=1 to 5  : print a : next a   :rem Variable A=a !!
190   '
200   a = 3.1415
210   a = int (a)                        :rem 'Struktur'blank
220   '
230   if a = 3 goto 250                  :rem if...goto OHNE then
240   print "Zu Åberspringen 1"
250   print "Ziel von Sprung 1           :rem fehlendes End-GÑnsefÅûchen
260   rem : : :  :   :                   :rem Diverser TrennmÅll
270   if a=3 then  290                   :rem if...then OHNE goto
280   print "Zu Åberspringen"
290   ? "Ziel von Sprung 2"
300   '
310   gotoxy a,3    : print "*1*"        :rem gotoxy mit Variable,Festwert
320   gotoxy 8,a    : print "*2*"        :rem            Festwert,Variable
330   b = 5
340   gotoxy a, a*b : print "*3*"        :rem            Var,Var-Berechnung
350   b=0
360   '
370   print "ENDE von testbsp2.bas"
