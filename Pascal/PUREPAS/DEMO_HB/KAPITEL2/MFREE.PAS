PROGRAM FreierSpeicher;
{$X+}
(* Das Programm kann als Programm oder als Accessory gestartet
	werden, die einzige Funktion, die es hat, ist den freien 
	Speicherplatz anzuzeigen *)
	
	USES GEM, TOS;
	
	VAR 	ap_id, vdi_handle, menu_id : INTEGER;	

PROCEDURE event_loop;
	VAR 	mg_buff : ARRAY_8;
BEGIN
	REPEAT
		EVNT_MESAG(mg_buff);
	UNTIL (mg_buff[0]=AC_OPEN); 
	(* wartet bis Accessory-Meneintrag angeklickt wurde *)	
END;

PROCEDURE Show_box;
	VAR 	frei : LONGINT;
			infostring, freistr : STRING;
			button : INTEGER;
			memptr : POINTER;
BEGIN
	memptr:=MALLOC(-1);
	frei:=LONGINT(memptr);
	str(frei,freistr);
	Infostring:='[1][Freier Speicher: |'+freistr+' Bytes][ OK ]';
	form_alert(1,infostring)
END;

BEGIN
	ap_id:=appl_init;
	if ap_id>=0 then
	begin
		IF appflag THEN
		begin
			Show_box;
			appl_exit;
		end
		ELSE
		BEGIN
	      menu_id := MENU_REGISTER( ap_id, '  Freier Speicher');
			WHILE menu_id>=0 DO
			BEGIN
		      event_loop;
				Show_box;
			END;
		END;
	END;
	if not(appflag) then
		WHILE TRUE DO
			event_loop;
END.