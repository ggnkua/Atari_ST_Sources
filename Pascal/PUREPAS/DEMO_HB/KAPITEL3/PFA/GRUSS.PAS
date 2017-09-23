PROGRAM Gruesse;

TYPE	Wochentag	=	(Montag, Dienstag, Mittwoch, Donnerstag,
						Freitag, Samstag, Sonntag);

	PROCEDURE Gruss(x : Wochentag);
	BEGIN
		CASE x OF
			Montag		: WRITELN('Montags fÑngt die Woche an!');
			Dienstag	: WRITELN('Streû am Dienstag.');
			Mittwoch	: WRITELN('Tief am Mittwoch.');
			Donnerstag	: WRITELN('Langer Donnerstag!');
			Freitag		: WRITELN('Freitag ist Freutag.');
			Samstag		: WRITELN('Samstag ist Wochenende.');
			Sonntag		: WRITELN('Sonntag fÅr die Familie.')
		END
	END;

BEGIN
	Gruss(Montag);
	Gruss(Donnerstag)
END.
