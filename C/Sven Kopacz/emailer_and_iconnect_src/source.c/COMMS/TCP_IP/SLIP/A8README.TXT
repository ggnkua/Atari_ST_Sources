nderungen:

ICONNECT

-In S/W werden jetzt die Status/Command-Angaben korrekt gezeichnet, d.h
 es bleiben keine Reste des vorherigen Eintrags stehen.
 (Ist das eigentlich ein Fehler in MagiC? Die Objekte sind immerhin deckend
 und nicht transparent und werden ber die ganze Breite neu gezeichnet. Ich
 mute Sie jetzt bis zum Ende mit Leerzeichen fllen, um den gewnschten
 Effekt zu erzielen. In Farbe bzw. 3D geht das dagegen auch so)
 
-Der Button im PPP-Error-Report wurde nicht deselektiert. Wenn also ein
 folgender Verbindungs-Versuch auch schief ging, wurde der Dialog mit
 bereits selektiertem Button ge”ffnet.

-Wegen des ISDN-Zugangs und der Logfiles: Ich hab mir das angeschaut und
 das einzige was da anders l„uft, ist da sich der T-Online-Server schlicht
 und ergreifend tot stellt, d.h. er macht einfach nicht mehr weiter. Da
 hab ich natrlich keinen Einflu drauf, denn bis zu diesem Punkt l„uft
 das Protokoll identisch zum funktionierenden Zugang ab.
 Das ist eindeutig ein Fehler in der Telekom-Software. Denn selbst wenn
 die ICON-PPP-Antwort falsch w„re oder nicht mal ankommen wrde, mu
 (nach RFC-Def) auf jeden Fall der Timeout fr eine Retransmission bei
 T-Online sorgen. Da passiert aber offensichtlich nix.
 Also hab ich jetzt einfach mal die sock-init-Phase in ICONNECT knstlich
 verl„ngert, d.h. zwischen <Script beendet> und <PPP konfig> wird einfach
 eine Sekunde Pause eingelegt. N„mlich bei <sockets initialisieren>. Das
 sieht dann auf den ersten Blick komisch aus, wenn man den bisherigen
 Ablauf gewohnt ist, weil er da natrlich noch nie stehen geblieben ist,
 hat sowas von Fehler, ist aber keiner;-)
 
 Jedenfalls sollte der ISDN-Zugang damit immer, auch ohne Pause im Script,
 klappen.

-L„t sich jetzt auch als Accessory installieren. Ist vielleicht ganz
 praktisch, fr die, die Accessories m”gen.
 

ICONF

-Was lange w„hrt...ich glaube ich hab den Fehler jetzt endlich gefunden.
 Da hatte sich ein Initialisierungs-Fehler in meiner Lib eingeschlichen,
 d.h. die Cursorposition fr das erste Einschalten des Cursors in einem
 Fenster wurde uninitialisiert bergeben, da konnte also irgendwas stehen.
 Bei objc_edit (zum Einschalten) rannte MagiC dann in den Wald (das
 zurckliefern eines Fehlercodes w„re natrlich auch nicht schlecht
 gewesen...)
 
-Der Cursor sollte nicht mehr auerhalb des Fensters auftauchen. Das
 passierte bisher beim Scrollen im Script, wenn der Cursor in ein Feld
 sprang, das krzer war, als der ausgefllte Teil im vorherigen Feld.
 
-Die einzelnen Edit-Dialoge sollten eigentlich alle Applikations-modal
 sein. Waren sie auch, bis neulich, weil ich beim ndern was vergessen
 hatte. Jetzt sind sie es wieder.
 
 
SOCKETS:

Da ich noch keinen rechten Plan habe, wo der Adressfehler herkommt, hab
ich jetzt eine zus„tzliche Ausgabe eingebaut (da die Debug-gelinkte
Version nix bringt, weil es ein TSR ist, ist mir auch erst heute
aufgefallen).

Und zwar sollten beim Start von ICONNECT oben links auf dem Bildschirm
Zahlen erscheinen. Auf jeden Fall sollte in der ersten Zeile etwas
durchgez„hlt werden, mit etwas Glck kommt auch noch etwas in der
zweiten Zeile und mit noch mehr Glck kommt noch was in der Dritten.
Maximal erscheint 9,6,7, aber auf dem 68000er wird's wohl irgendwo
vorher stehen bleiben.
Diese Zahlen brauche ich dann, um den Absturzort einzukreisen.
Dazu ruf ich dann morgen einfach mal im Lauf des Tages an.


So, und jetzt berleg ich, ob ich gleich ins Bett gehe oder erst noch
eine Runde F18 fliege.....;-))

Gru, Sven