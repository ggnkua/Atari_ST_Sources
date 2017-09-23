program wurmie;
{$X+} {$I-}

(* Diese Programm war ursprÅnglich ein Basic-Listing. Es wurde in Pure
	Pascal umgesetzt. Es darf somit nicht als vorbildliche Programmierung
	unter Pascal gelten, es ist jedoch auch interessant, wie ein 
	ursprÅngliches Basic-Listing umgesetzt werden kann. Das typische ist
	meist die groûe Anzahl globaler Variablen.
	Das das Spiel ganz unterhaltsam ist, wurde es Pure Pascal beigelegt,
	vielleicht findet sich ja doch die eine oder andere nÅtzliche 
	Routine. 
	Oliver Buchmann, Juni 1992
*)

uses crt, gem, tos, geminit;

type sondertasten = (lshift, lshift_ctrl, keine_sondertaste);
type untergrund = (frei, mauer1, mauer2, futter, exit);
		m_modus = (m_aus, m_an);
		
const	max_hind = 4800; (* max 1280*960 *)

var	screenmfdb, bild, sprites, hintergrund : MFDB;
		xmax, ymax, bitplanes, level, futtertyp, verzoegerung, plus, 
		zaehler, max_aepfel, lives, count_hind, laenge, anz_aepfel, 
		alt_richtungx, richtungx, alt_richtungy, richtungy : integer;
		startxpos, startypos, new_x_pos, new_y_pos, fehlernr : integer;
		fatal, midres, schluss, fertig, animate, exit_draw : boolean;		
	   wurmx, wurmy : ARRAY[0..max_hind] OF INTEGER;
	   levels : ARRAY[0..20] OF INTEGER;
		Spieler : ARRAY[0..21] OF string;
	   Punkte : ARRAY[0..21] OF LONGINT;
	 	screen : ARRAY[0..80] OF ARRAY[0..60] OF untergrund;
    	anz_hind : ARRAY[1..12] OF INTEGER;
    	anz_hind2 : ARRAY[1..12] OF INTEGER;
	   hindernisx, hindernisy, hindernisx2, hindernisy2 : ARRAY [1..12] OF ARRAY[0..max_hind] OF INTEGER;
		speicherbedarf, start_time, max_zeit : longint;
		rect_kopf, rect_koerper, rect_m_koerper : ARRAY[0..6] OF array_8;
		rect_futter, rect_m_futter : ARRAY[0..9] OF array_8;
		rect, rect_exit, rect_mauer, rect_m_kopf, koordinaten : array_8;
		infostr : array[0..1300] of char;		


function clock : longint;
var oldsupstack: longint;
begin
	oldsupstack:=Super(nil);	(*Nun sind wir im Supervisor-Modus*)
	clock:=longint(pointer($4BA)^);
	Super(pointer(oldsupstack)); (*Und nun sind wir wieder zurÅck.*)
end;

procedure maus(modus : m_modus);
begin
	if modus=m_an then
		graf_mouse( M_ON, NIL ) (* Maus an *)
	else
		graf_mouse( M_OFF, NIL ); (* Maus aus *)
end;

procedure holebildspeicher;
begin
		bild.fd_addr:=Malloc(speicherbedarf);
		hintergrund.fd_addr:=Malloc(speicherbedarf);
		sprites.fd_addr:=malloc(speicherbedarf);
		screenmfdb.fd_addr:=NIL;
		screenmfdb.fd_w:=xmax*16;
		screenmfdb.fd_h:=ymax*16;
		screenmfdb.fd_wdwidth:=40;
		screenmfdb.fd_stand:=0;
		screenmfdb.fd_nplanes:=bitplanes;
		if (bild.fd_addr=nil) or (hintergrund.fd_addr=nil) or (sprites.fd_addr=nil) then
		begin
			fatal:=true;
			fehlernr:=6;
		end;
end;
procedure gib_bildspeicher_wieder_frei;
begin
		mfree(bild.fd_addr);
		mfree(hintergrund.fd_addr);
		mfree(sprites.fd_addr);
end;

procedure bildkonvert(var zielmfdb : mfdb);
	var mymfdbsrc:	MFDB;
begin
	mymfdbsrc.fd_addr:=zielmfdb.fd_addr;
	mymfdbsrc.fd_w:=640;
	mymfdbsrc.fd_h:=400;
	mymfdbsrc.fd_wdwidth:=40;
	mymfdbsrc.fd_stand:=1;
	mymfdbsrc.fd_nplanes:=1;
	zielmfdb.fd_w:=xmax*16;
	zielmfdb.fd_h:=ymax*16;
	zielmfdb.fd_wdwidth:=40;
	zielmfdb.fd_stand:=0;
	zielmfdb.fd_nplanes:=1;
	vr_trnfm(vdihandle,mymfdbsrc,zielmfdb);
end;	

procedure first_init;
	var i : integer;
begin
	fehlernr:=0;
	xmax:=(workout[0]+1) div 16; (* Auflîsung horiz./16 *)
	ymax:=(workout[1]+1) div 16; (* Auflîsung vert./16 *)
	if xmax>80 then xmax:=80; (* nur bis normale Grossbildschimrgrîsse *)
	if ymax>60 then ymax:=60; (* s.o. *)
	if ymax<25 then midres:=true; (* ST - Mittel *)
	if xmax<40 then 
	begin
		fatal:=true;
		fehlernr:=1;
	end;
	vq_extnd(vdihandle, 1, workout);
	bitplanes := workout[4];
	speicherbedarf:=xmax*(ymax+1);
	speicherbedarf:=bitplanes*32*speicherbedarf;
	FOR i:=1 TO 20 DO
	begin
		Spieler[i]:='          ';
		Punkte[i]:=0;
		levels[i]:=0;
	end;
	Randomize;
end;

PROCEDURE spiel_init;
BEGIN
    animate:=TRUE;
    plus:=1;
    zaehler:=0;
    max_aepfel:=0;
	 lives:=3;
    verzoegerung:=5;
    Punkte[21]:=0;
    level:=1;
    futtertyp:=1;
	 count_hind:=1;
END;

procedure bild_lesen(filename:string; adresse:pointer);
	var Fhandle : integer;
begin
	Fhandle := Fopen(filename,0);
	if Fhandle>=0 then
	begin
		Fread( Fhandle, 32000, adresse );
		Fclose (Fhandle);
	end;	
end;

procedure sprites_lesen;
	var error, Fhandle : integer;
	filename: string;	
begin
	filename := 'wurm.dat';
	Fhandle := Fopen(filename,0);
	if Fhandle>=0 then
		begin
			Fread( Fhandle, 4000, sprites.fd_addr );
			error := Fclose (Fhandle);
			if error<>0 then
			begin
				fatal:=true;
				fehlernr:=2;
			end;
			bildkonvert(sprites);
		end
	else
		begin
			fatal:=true;
			fehlernr:=3;
	end;
end;

procedure rastercopy(x1,y1,x2,y2,x3,y3,x4,y4 : integer; m1, m2 : mfdb);
var	pxyarray:	ARRAY_8;
		colind:	ARRAY_2;
begin
	pxyarray[0]:=x1; pxyarray[1]:=y1;
	pxyarray[2]:=x2; pxyarray[3]:=y2;
	pxyarray[4]:=x3; pxyarray[5]:=y3;
	pxyarray[6]:=x4; pxyarray[7]:=y4;
	vro_cpyfm(vdihandle,s_only,pxyarray,m1,m2);
end;

PROCEDURE put_hintergrundbild;
var	pxyarray:	ARRAY_8;
		colind:	ARRAY_2;
BEGIN
	rastercopy(0,0,xmax*16-1,ymax*16-1,0,0,xmax*16-1,ymax*16-1, bild,screenmfdb);
END;

procedure showbild;
var mymfdbscreen:	MFDB;
	pxyarray:	ARRAY_8;
	colind:	ARRAY_2;
begin
	mymfdbscreen.fd_addr:=NIL;
	rastercopy(0,0,639,399,0,0,639,399,bild,mymfdbscreen);
end;

PROCEDURE hiscore;
	var i, j, pos:integer;
		sorted : boolean;
begin
	sorted:=false;
	highvideo;
	clrscr;
	pos:=0;
	IF Punkte[21]>Punkte[20] then
	begin
		write('Gib Deinen Namen ein : ');
		readln(spieler[21]);
		FOR i:=1 TO 20 do
		begin
			if not sorted then 
			begin
		      IF Punkte[21]>Punkte[i] then 
		      begin
					pos:=i;
					FOR j:=20 DOWNTO i do
					begin
						Punkte[j]:=Punkte[j-1];
						spieler[j]:=spieler[j-1];
						levels[j]:=levels[j-1];
					end;
					spieler[i]:=spieler[21];
					Punkte[i]:=Punkte[21];
					levels[i]:=level;
					sorted:=true;
				end;
			end;
		end;
	end;
	clrscr;
	gotoxy(20,2);
	write('Pos.');
	gotoxy(26,2);
	write('Name');
	gotoxy(50,2);
	write('Punktezahl');
	gotoxy(70,2);
	write('Level');
	FOR i:=1 to 20 do
	begin
		if i=pos then		
				highvideo
		else
				lowvideo;
		gotoxy(22,i+3);
		write(i);write('  ');
		gotoxy(26,i+3);
		write(spieler[i]:20);
		gotoxy(50,i+3);
		write(punkte[i]);
		gotoxy(70,i+3);
		write(levels[i]);
	end;
	gotoxy(60,25);
	write('DrÅcke Taste...');
	repeat until keypressed;
	lowvideo;
	Punkte[21]:=0;
	schluss:=TRUE;
end;

procedure pause;
begin
	delay(verzoegerung*10);
end;

PROCEDURE put_screen(modus : boolean);
	var t1, t2 : integer;	
BEGIN
	for t1:=0 to xmax-1 do
	begin
		for t2:=0 to ymax-1 do
		begin
			if (modus=true) or (screen[t1][t2]<>frei) then
			begin
				rastercopy(t1*16,t2*16,t1*16+15,t2*16+15,t1*16,t2*16,t1*16+15,t2*16+15, hintergrund, screenmfdb);
			end;
		end;
	end;
END;

procedure put_sprite_modus(x, y : integer; koordinaten : array_8; modus : integer);
begin	
	koordinaten[4]:=x*16;
	koordinaten[5]:=y*16;
	koordinaten[6]:=koordinaten[4]+15;
	koordinaten[7]:=koordinaten[5]+15;
	vro_cpyfm( vdiHandle, modus, koordinaten,	sprites, screenmfdb );
end;

procedure put_sprite(x, y : integer; koordinaten : array_8);
begin
	koordinaten[4]:=x*16;
	koordinaten[5]:=y*16;
	koordinaten[6]:=koordinaten[4]+15;
	koordinaten[7]:=koordinaten[5]+15;
	vro_cpyfm( vdiHandle, S_OR_D, koordinaten, sprites, screenmfdb );
end;

procedure put_maske(x, y : integer; koordinaten : array_8);
begin
	koordinaten[4]:=x*16;
	koordinaten[5]:=y*16;
	koordinaten[6]:=koordinaten[4]+15;
	koordinaten[7]:=koordinaten[5]+15;
	vro_cpyfm( vdiHandle, S_AND_D, koordinaten,	sprites, screenmfdb );		
end;

procedure baue_hindernis;
	var i : integer;
begin
	FOR i:=1 TO anz_hind[count_hind] DO
	begin
		IF (hindernisx[count_hind,i]<=xmax) AND (hindernisy[count_hind,i]<=ymax) THEN
		begin
	      screen[hindernisx[count_hind,i],hindernisy[count_hind,i]]:=mauer1;
			put_sprite_modus(hindernisx[count_hind,i],hindernisy[count_hind,i], rect_mauer, S_ONLY);
		END;
	END;
	FOR i:=1 TO anz_hind2[count_hind] DO
	begin
		IF (hindernisx2[count_hind,i]<=xmax) AND (hindernisy2[count_hind,i]<=ymax) THEN
		begin
	      screen[hindernisx2[count_hind,i],hindernisy2[count_hind,i]]:=mauer2;
			put_sprite_modus(hindernisx2[count_hind,i],hindernisy2[count_hind,i], rect_mauer, S_ONLY);
			put_sprite_modus(hindernisx2[count_hind,i],hindernisy2[count_hind,i], rect_mauer, S_XOR_D);
			put_sprite_modus(hindernisx2[count_hind,i],hindernisy2[count_hind,i], rect_mauer, NOT_SORD);
		END;
	END;
   count_hind:=count_hind+1;
	if count_hind=13 then count_hind:=1;
end;

procedure setze_futter;
	var i, j : integer;
	zufall : real;
begin
	max_aepfel:=0;
	repeat
		i:=system.random(xmax);
		j:=system.random(ymax-1)+1;
	   IF (i<>startxpos-1) AND (j<>startypos) and (i<>startxpos) THEN
		begin
			IF screen[i,j]=frei THEN
			begin
				put_maske(i,j,rect_m_futter[futtertyp]);
				put_sprite(i,j,rect_futter[futtertyp]);
				screen[i,j]:=futter;
				max_aepfel:=max_aepfel+1;
			end;
	    end;
    until (max_aepfel=level*10) or (max_aepfel>150);
    max_zeit:=max_aepfel*10;
end;

procedure helptext;
	var st : string;
		y, i, j, k, ypos : integer;
		warte : longint;
begin
	if midres then ypos:=6 else  ypos:=12;
	st:='';
	for i:=1 to xmax*2 do
		st:=st+infostr[i];
	st:=st+' ';
	FOR i:=xmax*16 downto -7 do
	begin
		warte:=clock;
		repeat until clock-warte=1;
		v_gtext( vdihandle, i, ypos, st);
	end;
	st:='';
	for i:=2 to 1123 do
	begin
		if Bconstat(2)<>-1 then
		begin
			for j:=i to i+xmax*2 do st:=st+infostr[j];
			for k:=1 downto -6 do
			begin
				warte:=clock;
				repeat until clock-warte=1;
				v_gtext( vdihandle, k, ypos, st);
			end;
			st:='';
		end;
	end;
	st:='';	
	for i:=0 to xmax*2 do st:=st+' ';
	v_gtext(vdihandle,0,ypos,st);
end;

function ermittle_taste : longint;
VAR Taste : longint;
BEGIN
	Taste:=0;
	if Bconstat(2)=-1 then
	begin
		Taste:=Bconin(2);
		taste:=taste div 65536;
	end;
	ermittle_taste:=taste;
end;

PROCEDURE Zeige_Punkte;
	VAR str : string;
BEGIN
	gotoxy(1,1);
	Write('Wurmie   ');
	write('Leben : ',lives,'  ');
	write('Bonus : ',max_zeit-(clock-start_time) div 200,'   ');
	write('Hiscore : ',punkte[1],'   ');
	write('Punkte : ',punkte[21],'   ');
	write('Level : ',level,' ');
END; 

procedure beenden; forward;

PROCEDURE init2;
	var button : integer;
		leer:string;
begin
	leer:='                                                                               ';
   gotoxy(1,1);Write(leer);
   schluss:=FALSE;
	richtungx:=1;
	richtungy:=0;
	zaehler:=0;
	plus:=1;
	startxpos:=xmax div 2;
	startypos:=12;	
	new_x_pos:=startxpos+1;
	new_y_pos:=startypos;
	wurmx[1]:=startxpos;
	wurmy[1]:=startypos;
	if midres=true then
	begin
		startypos:=5;
		new_y_pos:=5;
		wurmy[1]:=5;
	end;
	repeat
		maus(m_an);
		button:=form_alert( 1, '[3][Kann es losgehen ? ][Ja|Info|Ende]' );
		maus(m_aus);
	   IF button=2 THEN helptext;
	   IF button=3 THEN beenden;
	until button<>2;
	start_time:=clock;
end;

procedure level_init;
	var i, j : integer;
begin
   FOR i:=0 TO xmax DO
 	begin
	   FOR j:=0 TO ymax DO screen[i,j]:=frei;
   END;
   FOR i:=0 TO xmax*ymax DO
	begin
      wurmx[i]:=0;
      wurmy[i]:=0;
   END;
   exit_draw:=false;
   laenge:=1;
   anz_aepfel:=0;
   baue_hindernis;
   Setze_Futter;
	init2;
end;

procedure beenden;
	var button : integer;
BEGIN
	if Punkte[21]>punkte[20] then hiscore;
	level:=1;
	futtertyp:=1;
	count_hind:=1;
	lives:=3;
	maus(m_an);
	button:=form_alert( 2, '[3][ Nochmal? ][ JA | NEIN ]' );
	maus(m_aus);
	if button=1 then
	begin
		put_screen(true);
		spiel_init;
		level_init;
	end
	else
	begin
		maus(m_an);
		form_alert( 1, '[1][ Bye, Bye ][So isses]' );
		maus(m_aus);
		schluss:=true;
	end;
end;

function ermittle_sondertasten : sondertasten;
	var	status : INTEGER;
BEGIN
	status:=Kbshift(-1);
	IF status>15 then status:=status-16;
	case status of
		2 : ermittle_sondertasten:=lshift;
		6 : ermittle_sondertasten:=lshift_ctrl;
	else
		ermittle_sondertasten:=keine_sondertaste;
	end;
end;


procedure geschafft;
BEGIN
	Punkte[21]:=Punkte[21]+max_zeit-(clock-start_time) div 200;
	maus(m_an);
	form_alert( 1, '[1][ Geschafft ][ Yeah ]' );
	maus(m_aus);
	level:=level+1;
	futtertyp:=futtertyp+1;
	IF futtertyp=10 THEN futtertyp:=1;
	put_screen(false); 
	level_Init;
	fertig:=FALSE;
end;

procedure put_hintergrund(x, y : integer);
	var rect:array_8;
begin
	rect[0]:=x*16;
	rect[1]:=y*16;
	rect[2]:=rect[0]+15;
	rect[3]:=rect[1]+15;
	rect[4]:=x*16;
	rect[5]:=y*16;
	rect[6]:=rect[4]+15;
	rect[7]:=rect[5]+15;
	vro_cpyfm( vdiHandle, S_ONLY, rect,	hintergrund, screenmfdb );
end;

PROCEDURE neuaufbau;
	var i, j : integer;
begin
	FOR i:=0 TO xmax-1 do
	begin
		FOR j:=0 TO ymax-1 do
		begin
			case screen[i,j] of
				frei:	put_hintergrund(i,j);
				mauer1: put_sprite_modus(i,j,rect_mauer,s_only);
				mauer2 : 
				begin
					put_sprite_modus(i,j,rect_mauer,s_only);
					put_sprite_modus(i,j,rect_mauer,6);
					put_sprite_modus(i,j,rect_mauer,8);
				end;
				futter : 
				begin
					put_hintergrund(i,j);
					put_maske(i,j,rect_m_futter[futtertyp]);
					put_sprite(i,j,rect_futter[futtertyp]);
				end;
				exit : 
				begin
					put_sprite_modus(i,j,rect_exit,s_only);
					exit_draw:=TRUE;
				end;
			end;
		end;
	end;
end;

procedure bic;
	var i : integer;
		pxyarray:array_4;
begin
	clrscr;
	pxyarray[0]:=0;
	pxyarray[1]:=0;
	pxyarray[2]:=xmax*16-1;
	pxyarray[3]:=ymax*16-1;
	vsf_interior( vdihandle,2 );
	vsf_style( vdihandle,4 );
	v_bar( vdihandle, pxyarray);
	FOR i:=0 TO 24 do
	put_sprite_modus(i,ymax div 2,rect_futter[8],s_only);
	repeat
		repeat until KeyPressed;
	until Readkey = #32;
	put_screen(true);
	neuaufbau;
	FOR i:=1 TO laenge do
	begin
		IF wurmy[i]>0 then
		begin
			put_hintergrund(wurmx[i],wurmy[i]);
			put_sprite_modus(wurmx[i],wurmy[i],rect_m_koerper[1],1);
			put_sprite_modus(wurmx[i],wurmy[i],rect_koerper[1],7);
		end;
	end;
end;

procedure taste_auswerten;
	var	t : longint;
			button: integer;
begin
	if ermittle_sondertasten<>lshift then pause;
	t:=ermittle_taste;
	CASE t OF 
	1 : (* Esc zum Beenden *)
	begin
		repeat
			maus(m_an);
			button:=form_alert( 1, '[3][Hyperwurm | beenden? ][Ja|Nein|Info]' );
			maus(m_aus);
		   IF button=1 THEN beenden else if button=3 then helptext else	schluss:=FALSE;
		until button<>3;
	end;
	98 : if ermittle_sondertasten=lshift_ctrl THEN
	begin
		Punkte[21]:=Punkte[21]-max_zeit-(clock-start_time) div 200;   (* Shift-Ctrl-Help, um Level zu beenden *)
		fertig:=TRUE;
		geschafft;
	END
		else helptext;
	97 : bic;
	30 : animate:=NOT(animate); (* 'a' schaltet Animation ab *)
	77 : 
		begin			
			richtungx:=1;
			richtungy:=0;
		end;
    75 : 
		begin
			richtungx:=-1;
			richtungy:=0;
		end;
	80 : 
		begin
			richtungy:=1;
			richtungx:=0;
		end;
    72 : 
		begin
			richtungy:=-1;
			richtungx:=0;
		end;
	END;
	IF ((t>58) AND (t<69)) THEN (* Tempo durch Funktionstasten *)
	    verzoegerung := t-59;
	alt_richtungx:=richtungx;
	alt_richtungy:=richtungy;
	IF alt_richtungx+richtungx=0 THEN
    	richtungx:=alt_richtungx;
	IF alt_richtungy+richtungy=0 THEN
	    richtungy:=alt_richtungy;
end;

PROCEDURE get_screen;
BEGIN
	rastercopy(0,0,xmax*16-1,ymax*16-1,0,0,xmax*16-1,ymax*16-1,screenmfdb,hintergrund);
END;

procedure sprite_init;
  VAR i : INTEGER;
  		j : untergrund;
  BEGIN
    rect_mauer[0]:=0;
    rect_mauer[1]:=34;
    rect_mauer[2]:=15;
    rect_mauer[3]:=34+15;
    rect_exit[0]:=136;
    rect_exit[1]:=34;
    rect_exit[2]:=136+14;
    rect_exit[3]:=34+14;
    FOR i:=0 TO 6 DO
	begin
      	rect_kopf[i][0]:=i*17;
		rect_kopf[i][1]:=0;
      	rect_kopf[i][2]:=rect_kopf[i][0]+15;
		rect_kopf[i][3]:=rect_kopf[i][1]+15;
    END;
    FOR i:=0 TO 6 DO
	begin
    	rect_koerper[i][0]:=i*17+17;
		rect_koerper[i][1]:=34;
    	rect_koerper[i][2]:=rect_koerper[i][0]+15;
		rect_koerper[i][3]:=rect_koerper[i][1]+15;
    END;
    FOR i:=0 TO 6 DO
	begin
    	rect_m_koerper[i][0]:=i*17+119;
		rect_m_koerper[i][1]:=1;
    	rect_m_koerper[i][2]:=rect_m_koerper[i][0]+15;
		rect_m_koerper[i][3]:=rect_m_koerper[i][1]+15;
    END;
    rect_futter[1][0]:=0;
    rect_futter[2][0]:=447;
    rect_futter[3][0]:=579;
    rect_futter[4][0]:=405;
    rect_futter[5][0]:=292;
    rect_futter[6][0]:=361;
    rect_futter[7][0]:=489;
    rect_futter[8][0]:=255;
    rect_futter[9][0]:=535;
    rect_futter[1][1]:=17;
	for i:=2 to 9 do rect_futter[i][1]:=0;
    rect_m_futter[1][0]:=237;
    rect_m_futter[2][0]:=466;
    rect_m_futter[3][0]:=598;
    rect_m_futter[4][0]:=425;
    rect_m_futter[5][0]:=314;
    rect_m_futter[6][0]:=340;
    rect_m_futter[7][0]:=512;
    rect_m_futter[8][0]:=366;
    rect_m_futter[9][0]:=555;
    rect_m_futter[1][1]:=0;
    rect_m_futter[2][1]:=0;
    rect_m_futter[3][1]:=0;
    rect_m_futter[4][1]:=0;
    rect_m_futter[5][1]:=22;
    rect_m_futter[6][1]:=22;
    rect_m_futter[7][1]:=0;
    rect_m_futter[8][1]:=22;
    rect_m_futter[9][1]:=0;
    FOR i:=1 TO 9 DO
	begin
      rect_futter[i][2]:=rect_futter[i][0]+15;
      rect_futter[i][3]:=rect_futter[i][1]+15;
      rect_m_futter[i][2]:=rect_m_futter[i][0]+15;
      rect_m_futter[i][3]:=rect_m_futter[i][1]+15;
    END;
    FOR i:=0 TO 6 DO
	begin
      rect_kopf[i][2]:=rect_kopf[i][0]+15;
      rect_kopf[i][3]:=rect_kopf[i][1]+15;
      rect_koerper[i][2]:=rect_koerper[i][0]+15;
      rect_koerper[i][3]:=rect_koerper[i][1]+15;
      rect_m_koerper[i][1]:=0;
      rect_m_koerper[i][2]:=rect_m_koerper[i][0]+15;
      rect_m_koerper[i][3]:=rect_m_koerper[i][1]+15;
    END;
    rect_m_kopf:=rect_m_koerper[1];
END;

procedure lade_hindernis_daten;
	type	feld = array[0..6000] of byte;
			feldptr = ^feld;
	var i, j, k, Fhandle, error : integer;
		Filename : string;
		f : feld;
		ptr : feldptr;
begin
	ptr:=@f;
	filename := 'wurm.lev';
	Fhandle := Fopen(filename,0);
	if Fhandle>=0 then
	begin
		Fread( Fhandle, 5654, ptr );
		error := Fclose (Fhandle);
		if error<>0 then
		begin
			fatal:=true;
			fehlernr:=4;
		end;
	end
	else
	begin
		fatal:=true;
		fehlernr:=5;
	end;
	for i:=1 to 12 do
	begin
		anz_hind[i]:=(integer(f[i*4-4]))*256+integer(f[i*4-3]);
		anz_hind2[i]:=(integer(f[i*4-2]))*256+integer(f[i*4-1]);
	end;
	k:=48;
	for i:=1 to 12 do
	begin
		for j:=1 to anz_hind[i] do
		begin
			hindernisx[i,j]:=f[k];
			hindernisy[i,j]:=f[k+1];
			if midres then hindernisy[i,j]:=hindernisy[i,j] div 2;
			k:=k+2;
		end;	
		for j:=1 to anz_hind2[i] do
		begin
			hindernisx2[i,j]:=f[k];
			hindernisy2[i,j]:=f[k+1];
			if midres then hindernisy2[i,j]:=hindernisy2[i,j] div 2;
			k:=k+2;
		end;	
	end;
	for i:=4531 to 5653 do 
		infostr[i-4530]:=chr(f[i]);
end;

procedure laden;
	var i, drive : integer;
	pfad : string;
	dateiname : Text;
	error : longint;
begin
	drive:=Dgetdrv;
	pfad:='';
	pfad:=pfad+char(drive+65)+':\paswurm.hsc';
	Assign(dateiname,pfad);
	Reset(dateiname);
	error:=IOResult;
	if error=0 then
	begin
		for i:=1 to 20 do
		begin	
			readln(dateiname,spieler[i]);
			readln(dateiname,punkte[i]);
			readln(dateiname,levels[i]);
		end;
		close(dateiname);
	end
	else
	begin
		for i:=1 to 20 do
		begin	
			spieler[i]:='';
			punkte[i]:=0;
			levels[i]:=0;
		end;
	end;
end;

procedure speichern;
	var i, drive : integer;
	pfad : string;
	dateiname : Text;
begin
	drive:=Dgetdrv;
	pfad:='';
	pfad:=pfad+char(drive+65)+':\paswurm.hsc';
	Assign(dateiname,pfad);
	ReWrite(dateiname);
	for i:=1 to 20 do
	begin	
		writeln(dateiname,spieler[i]);
		writeln(dateiname,punkte[i]);
		writeln(dateiname,levels[i]);
	end;
	close(dateiname);
end;

procedure tot;
	VAR i:INTEGER;
BEGIN
	FOR i:=1 TO laenge DO
	begin
		put_hintergrund(wurmx[i],wurmy[i]);
		put_maske(wurmx[i],wurmy[i],rect_m_koerper[6]);
		put_sprite(wurmx[i],wurmy[i],rect_koerper[6]);
		screen[wurmx[i]][wurmy[i]]:=frei;
	END;
	FOR i:=1 TO laenge DO
	begin
		put_hintergrund(wurmx[i],wurmy[i]);
		wurmx[i]:=0;
		wurmy[i]:=0;
	END;
	schluss:=TRUE;
	lives:=lives-1;
end;

procedure zeichne_exit;
var i, j : integer;
begin
	FOR i:=5 TO xmax-5 do
	begin
	    IF (exit_draw=FALSE) THEN
		begin		
   	     	FOR j:=5 TO ymax-5 do
			begin
			    IF (exit_draw=FALSE) THEN
				begin
					IF screen[i,j]=frei then
					begin
						put_sprite_modus(i, j, rect_exit, S_ONLY);
			    		screen[i,j]:=exit;
						exit_draw:=true;
					end;
				end;		
			end;
		end;
	end;
end;

PROCEDURE berechne_neue_position;
BEGIN
  new_x_pos:=new_x_pos+richtungx;
  new_y_pos:=new_y_pos+richtungy;
  IF new_x_pos=xmax THEN
    new_x_pos:=0;
  IF new_y_pos=ymax THEN
    new_y_pos:=1;
  IF new_x_pos=-1 THEN
    new_x_pos:=xmax-1;
  IF new_y_pos=0 THEN
    new_y_pos:=ymax-1;
END;

PROCEDURE bewege;
VAR i,j:INTEGER;
BEGIN
	berechne_neue_position;
	IF (screen[new_x_pos,new_y_pos]=mauer1) or (screen[new_x_pos,new_y_pos]=mauer2) THEN
	begin
		maus(m_an);
		form_alert( 1, '[1][  Das kostet | |  ein Leben ][ MIST ]');
		maus(m_aus);
		tot;
		if lives=-1 then
		begin
			maus(m_an);
			form_alert( 1, '[1][  Das wars | dann wohl | ][JAWOLL]');
			maus(m_aus);
		   	beenden;
		end
		else
		begin
			neuaufbau;
			init2;
		end
    END;
	if (schluss=false) and (fertig=false) then
	begin
		if screen[new_x_pos,new_y_pos]<>frei then
		begin
			case screen[new_x_pos,new_y_pos] of
				exit:
				begin
					put_hintergrund(new_x_pos,new_y_pos);
			       	fertig:=TRUE;
					geschafft;
				end;
				futter:
				begin
					screen[new_x_pos,new_y_pos]:=frei;
					laenge:=laenge+1;
					Punkte[21]:=Punkte[21]+20;
					anz_aepfel:=anz_aepfel+1;
				end;
			end;
		end
		else
		begin
			if wurmy[1]>0 then
				put_hintergrund(wurmx[1],wurmy[1]);
			screen[wurmx[1],wurmy[1]]:=frei;
			FOR i:=0 TO laenge-1 DO
			begin
				wurmx[i]:=wurmx[i+1];
			    wurmy[i]:=wurmy[i+1];
			end;
		end;
	END;
    wurmx[laenge]:=new_x_pos;
    wurmy[laenge]:=new_y_pos;
    screen[new_x_pos,new_y_pos]:=mauer1;
    IF anz_aepfel=max_aepfel THEN
	begin
	    IF (exit_draw=FALSE) THEN
		zeichne_exit;
	end;
END; (* bewege*)

PROCEDURE Zeichne_Wurm;
VAR i:INTEGER;
BEGIN
	IF (animate=TRUE) THEN
	begin
		zaehler:=zaehler+plus;
		IF zaehler=6 THEN plus:=-1;
		IF zaehler=0 THEN plus:=1;
		FOR i:=1 TO laenge-1 DO
		begin
			if wurmy[i]>0 then
			begin
				put_hintergrund(wurmx[i],wurmy[i]);
				put_maske(wurmx[i],wurmy[i],rect_m_koerper[zaehler]);
				put_sprite(wurmx[i],wurmy[i],rect_koerper[zaehler]);
			end;
		END;
		if wurmy[laenge]>0 then
		begin
			put_hintergrund(wurmx[laenge],wurmy[laenge]);
			put_maske(wurmx[laenge],wurmy[laenge],rect_m_kopf);
			put_sprite(wurmx[laenge],wurmy[laenge],rect_kopf[zaehler]);
		end;
	end
	ELSE
	begin    
		if wurmy[laenge]>0 then
		begin
			put_hintergrund(wurmx[laenge],wurmy[laenge]);
			put_maske(wurmx[laenge],wurmy[laenge],rect_m_kopf);
			put_sprite(wurmx[laenge],wurmy[laenge],rect_kopf[zaehler]);
		end;
		IF laenge>1 THEN
		begin
			if wurmy[laenge-1]>0 then
			begin
				put_hintergrund(wurmx[laenge-1],wurmy[laenge-1]);
				put_maske(wurmx[laenge-1],wurmy[laenge-1],rect_m_koerper[0]);
				put_sprite(wurmx[laenge-1],wurmy[laenge-1],rect_koerper[0]);
			end;
   	end;
    END;
END;

procedure clipping(i : integer);
	var px : array_4;
begin
	px[0]:=0;	
	px[1]:=0;	
	px[2]:=xmax*16-1;	
	px[3]:=ymax*16-1;	
	vs_clip( vdihandle, i,  px);		
end;

begin
	if initgem=true then
	begin
		graf_mouse(ARROW, NIL);
		maus(m_aus);
		clrscr;
		first_init;
		holebildspeicher;
		if fehlernr<>6 then
		begin
			sprites_lesen;
			bild_lesen('BLUTO.DOO',bild.fd_addr);
			bildkonvert(bild);
			bildkonvert(hintergrund);
			hintergrund.fd_nplanes:=bitplanes;
			hintergrund.fd_wdwidth:=xmax;
			clipping(1);
			showbild;
			spiel_init;
			get_screen;
			sprite_init;
			lade_hindernis_daten;
			if fatal=false then
			begin
				Laden;
				level_init;
				REPEAT
					if frac((clock-start_time) / 200)<0.1 then
						Zeige_punkte; (* nur ca. jede Sekunde die Anzeige eneuern *)
					Zeichne_wurm;
					taste_auswerten;
					bewege;
				UNTIL schluss=TRUE;
				hiscore;
				Speichern;
				put_screen(true);	
			end
			else
			begin
				maus(m_an);
				case fehlernr of 
					1 : form_alert( 1, '[3][ Der Wurm lÑuft nicht | in dieser Auflîsung ][Abbruch]' );	
				
					2 : form_alert( 1, '[3][ Fehler beim Schlieûen | der WURM.DAT-Datei ][Abbruch]' );	

					3 : form_alert( 1, '[3][ Datei WURM.DAT | nicht gefunden ][Abbruch]' );	

					4 : form_alert( 1, '[3][ Fehler beim Schlieûen | der WURM.LEV-Datei ][Abbruch]' );	

					5 : form_alert( 1, '[3][ Datei WURM.LEV | nicht gefunden ][Abbruch]' );	

					else form_alert( 1, '[3][ Fehler bei der | Initialisierung ][Abbruch]' );	
				end;
				maus(m_aus);
			end;		
		end
		else form_alert( 1, '[3][ Kein Speicher mehr frei ][Abbruch]' );	
	end;
	clipping(0);
	maus(m_an);
	gib_bildspeicher_wieder_frei;
end.