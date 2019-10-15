/* Schreibt aktuellen Bildschirm in 
   die Datei BILD.PI3 im aktuelle Pfad */
int writeDegas(void)
{
  char bildkopf[34];
  int handle;
  long len;
	/* erzeuge neue, normale Datei */
	handle = Fcreate("BILD.PI3",0);	
	if (handle > 0) {	/* nur bei OK weiter */
		bildkopf[1] = 2;	/* Degasinfo setzen */
		/* 34 Byte des Bildkopfs in Datei schreiben */
		Fwrite(handle,(long)sizeof(bildkopf),&bildkopf);
		/* 32000 Byte des Bildes in die Datei schreiben */
		len = Fwrite(handle,32000L,Logbase());
		if (len != 32000L)	/* 32000 Byte geschrieben? */
			Fwrite(1,24L,"Datei nicht vollst„ndig\n");
		Fclose(handle);	/* Datei wieder schliežen */
	}
	return handle;	/* <0:Fehler, >0:OK */
}
