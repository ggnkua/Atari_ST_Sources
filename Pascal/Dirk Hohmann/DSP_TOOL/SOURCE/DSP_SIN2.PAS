
{------ Erzeugen eines Sinustons mit dem DSP --------------}

{ Version mit LOD-Datei }

program dsp_sin2;
uses tos,dsp;


var kennung :word;
	buffer :^longint;
	
begin
	locksnd;
	if dsp_init=FALSE then exit;   {Funktion der Unit DSP}
	
	dsptristate(1,1);              {Soundsystem einrichten }
	setmode(1);
	settracks(0,0);
	soundcmd(4,3);
	devconnect(1,8,0,1,1);
	kennung:=Dsp_RequestUniqueAbility;
	dsp_reserve(200,200);
  	
	buffer:=malloc(2000);      {Puffer fÅr DSP-Programm einrichten}
	
  if dsp_loadprog('C:\DSP_TOOL\LODS\SINUS.LOD',kennung,buffer)=-1 then begin
		writeln('Fehler beim Laden');
		unlocksnd;
		exit;
	end;
	
	dsp_exit;                     {Funktion der Unit DSP}
	mfree(buffer);                {Puffer freigeben }
	unlocksnd;
end.