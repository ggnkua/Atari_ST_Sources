{**************************************
 *  O b j e c t G E M   Version 1.20  *
 *  Copyright 1992-94 by Thomas Much  *
 **************************************
 *            Unit  O D B             *
 **************************************
 *    Softdesign Computer Software    *
 *    Thomas Much, Gerwigstraûe 46,   *
 *  76131 Karlsruhe, (0721) 62 28 41  *
 *         Thomas Much @ KA2          *
 *  UK48@ibm3090.rz.uni-karlsruhe.de  *
 **************************************
 *    erstellt am:        23.05.1994  *
 *    letztes Update am:  23.05.1994  *
 **************************************}

{
  WICHTIGE ANMERKUNGEN ZUM QUELLTEXT:

  ObjectGEM wird mit dem _vollstÑndigen_ Quelltext ausgeliefert, d.h.
  jeder kann sich die Unit selbst compilieren, womit die extrem lÑstigen
  KompatibilitÑtsprobleme mit den PP-Releases beseitigt sind.
  ObjectGEM ist und bleibt aber trotzdem SHAREWARE, d.h. wer die Biblio-
  thek regelmÑûig benutzt, muû sich REGISTRIEREN lassen. DafÅr gibt es
  die neueste Version und - gegen einen geringen Aufpreis - auch ein
  gedrucktes Handbuch.

  WICHTIG: Wer den Quelltext verÑndert und dann Probleme beim Compilieren,
  AusfÅhren o.Ñ. hat, kann nicht damit rechnen, daû ich den Fehler suche;
  tritt der Fehler allerdings auch mit dem Original-Quelltext auf, wÅrde
  ich mich Åber eine genaue Fehlerbeschreibung freuen. VerÑnderte Quell-
  texte dÅrfen _nicht_ weitergegeben werden, dies wÑre ein Verstoû gegen
  das Copyright!

  Wer beim Durchstîbern des Textes auf vermeintliche Fehler oder verbesse-
  rungswÅrdige Stellen trifft (von letzterem gibt es sicherlich noch viele),
  kann mir dies gerne mitteilen - ich habe auch ich nichts gegen kostenlos
  zur VerfÅgung gestellte optimierte Routinen (sofern sich jemand die MÅhe
  macht). Wer in anderen Projekten, die nicht in direkter Konkurrenz zu
  ObjectGEM stehen, einzelne Routinen verwenden mîchte, wendet sich bitte
  an mich (ein solcher Austausch sollte kein Problem sein).

  Wer sich auf nicht dokumentierte "implementation"- oder "private"-Eigen-
  schaften verlÑût, darf sich nicht Åber InkompatibilitÑten zu spÑteren
  Versionen wundern; wer meint, eine DokumentationslÅcke entdeckt zu haben,
  kann mir dies gerne mitteilen.

  Kleine Info zum Schluû: Als "default tabsize" verwende ich 2. Wer drei
  Punkte ("...") im Quelltext entdeckt, hat eine Stelle gefunden, an der
  ich z.Z. arbeite ;-)

  "Mîge die OOP mit Euch sein!"
}


{$IFDEF DEBUG}
	{$B+,D+,G-,I-,L+,N-,P-,Q+,R+,S+,T-,V-,X+,Z-}
{$ELSE}
	{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}
{$ENDIF}

unit ODB;

interface

uses

	Objects;

type

	PXBase = ^TXBase;
	TXBase = object(TObject)
		public
		{ ... }
	end;



implementation


{ *** Objekt TXBASE *** }


{ *** TXBASE *** }

end.