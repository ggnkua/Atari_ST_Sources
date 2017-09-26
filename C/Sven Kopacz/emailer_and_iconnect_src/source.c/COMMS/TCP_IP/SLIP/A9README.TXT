Sodele, jetzadle,

ich hab mal nach der Absturzstelle (68000er) in SOCKETS.PRG gefahndet
und sie dank des Zahlencodes auch gleich gefunden. Das Ergebnis liegt 
im Archiv.
Allerdings steht wie gesagt zu befrchten, da das nicht die einzige
Stelle war. Ich hab da einfach nicht dran gedacht.
Dummerweise konnte ich hier niemanden mit einem Original-Atari
auftreiben, d.h. wenn das so nicht funktioniert komm ich doch einfach
mal n„chste Woche fr einen Tag nach Heidelberg, dann kann ich das
ja auf eurem Mega-ST vollends entwanzen?

Dann ist mir noch aufgefallen, da das in der Anleitung erw„hnte
GET_IP.PRG ja noch garnicht existiert (wird z.B. bei der Erkl„rung
zum SERVICES-Setup erw„hnt). Drum hab ich das mal noch geschrieben,
liegt ebenfalls bei. Das kann natrlich nicht viel, man gibt halt
einfach einen Hostnamen ein und wenn der DNS den kennt (und das sollte
er) dann bekommt man die IP-Adresse geliefert (die man auch ins
Clipboard legen und so bequem per CTRL+V in ICONF einfgen kann).

Das ist halt ganz praktisch, wenn der Provider nur die Namen der
einzelnen Server liefert (z.B. "News-Server=news.thisnet.de") und
nicht die IP-Adressen, dann w„hlt man sich einfach ein und holt sich
die selber.

Vielleicht wird das auch mal irgendwann ausgebaut, so da man sich
ein Cache-File fr den Resolver aufbauen kann (fr oft benutzte 
Hosts), aber das kann warten (z.B. bis zum ersten Update;-)

Die n„chsten Tage kn”pfe ich mir erstmal das CAB.OVL vor zwecks
Redirection und Forms senden. Vielleicht langts ja sogar noch fr
einen SMTP-Client (um eMails aus CAB zu versenden), aber das ist 
halt ein ganz anderes Protokoll, mal gucken wie aufwendig das wird...

Au, da f„llt mir ein, da die Sachen fr die Registrierung noch rein
sollten. Hm, wo mach ich die denn rein? Sockets? Oder Iconf? K”nnen
wir ja morgen mal besprechen.

Ich ruf mal im Lauf des Tages an,
 Gru Sven