{------ Erzeugen eines Sinustons mit dem DSP -------------}

{ Version mit dazugelinktem DSP-Programm }

program dsp_sin1;
uses tos,dsp;


var kennung :word;
	buffer :^longint;
	lng :longint;
	
procedure dsp_sinus; external;

{$L C:\DSP_TOOL\LODS\SINUS.O }  {Linken des DSP-Programms}
	
begin
	locksnd;
	if dsp_init=FALSE then exit;  {Funktion der Unit DSP}

	dsptristate(1,1);             {Soundsystem einrichten}
	setmode(1);
	settracks(0,0);
	soundcmd(4,3);
	devconnect(1,8,0,1,1);
	kennung:=Dsp_RequestUniqueAbility;
	dsp_reserve(200,200);
	
	buffer:=@dsp_sinus;
	
	lng:=buffer^;
	buffer:=pointer(longint(buffer)+4);
	
	dsp_execprog(buffer,lng,kennung); {DSP-Programm ausfÅhren}
	 
	dsp_exit;            {Funktion der Unit DSP}
	unlocksnd;
end.