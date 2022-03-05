
 {$E-}
{==============================}
Procedure XModem_Send;

	Var	Tbytes, RC, J, X: Integer;
		Fbl : Boolean;
		Done: Boolean;
		Ch  : Char;
		Total_Blocks: Integer;
		Lo : Integer;

	Begin

	XM_Short_Inquiry;

	Case UserRec.XModem_Type of
		0  : Packet_Size := 128;
		1  : Packet_Size := 128;
	Else : Packet_Size := 1024;
	End; {case}

	Total_Blocks := DTA_Data.Blocksize;
	If Packet_Size > 128 then begin
		Lo := DTA_Data.Blocksize mod 8;
		Total_Blocks := (DTA_Data.Blocksize div 8) + Lo;
	End;

	CR_LF;
	EchoSE ('Begin File Transfer Now...');

	Fbl := True;
	XSector := 1;
	XBlock  := 1;
	XIdx    := MaxBuff;
	OldIdx  := MaxBuff;
	Xtotal  := 0;
	Xtries  := 0;
	Done    := False;

	Purge;

	Repeat
		Xin := 0;
		GetX (40);
		If Aborted then
			Put_Modem (CAN);

		If NOT Aborted then
			If Tout then
				Aborted := True;

		If NOT Aborted then begin
			Case Xin of
			CAN : Aborted := True;
			ACK : Begin
			XBlock := (XBlock + 1) & $ff;
			XSector := XSector + 1;
			Xtotal := Xtotal + Packet_Size;
			Xtries := 1;
			If XIdx < MaxBuff-1 then                    { partial buffer }
				If XIdx >= Tbytes then
				Begin
					Signal_EOT;
					Done := True;
				End;
			End;
		Else : Begin
			If (Xin = 67) and (XSector = 1) then        { 'C' }
			Begin
				SysCR;
				Writ ('Entering CRC Mode!');
				SysCR;
				CRC_Mode := True;
				Xin := NAK;
			End;
		If Xin <> NAK then
			Purge;
			XIdx := OldIdx;
			Xtries := Xtries + 1;
			If Xtries > 9 then
				Begin
					Aborted := True;
					Put_Modem (CAN);
				End
			Else
				If (Xtries > 5) and (XBlock = 0) then
					Xblock := (XBlock + 1) & $ff;
				End;
			End; {case in}

			If (Carrier_Lost) or (Aborted) then
				Done := True;

			If NOT Done then
				Begin
				If Xidx > MaxBuff - 6 then
					Begin
					Xidx := 0;
					Tbytes := BlockRead (XM_Handle, MaxBuff, Xbuffer.Buffer);
					If Tbytes < 0 then
						Begin
						Aborted := True;
						Done := True;
						Put_Modem (CAN);
						Show_Error (Tbytes,Xfn,'Error BlockReading - XModem Send');
						End
				Else
            (** Jay -- Here's where it switches to 128 Byte
             blocks during an Xmodem-1K transfer...**)
					If Tbytes < MaxBuff then
					Begin
					Packet_Size := 128;
					J := Tbytes Mod 128;
					If UserRec.Pad_Type = 1 then
						J := 26;                            { ^Z pad }
						For X := Tbytes to MaxBuff do
							XBuffer.Data [X] := J;
						End;
					If Tbytes = 0 then begin
						Signal_EOT;
						Done := True;
					End;
				End;
			End; {if xidx > maxbuff-6}
		End;  {if NOT done}

		If NOT Done then begin
			Writ ('Sending Block ');
			WritI (XSector);
			Writ (' of ');
			WritI (Total_Blocks);
			PutC (#13);

			If Packet_Size = 128 then   { xmodem }
				Put_Modem ( SOH )
			Else
				Put_Modem ( STX );        { ymodem }

			Put_Modem (XBlock);
			Put_Modem (255-Xblock);
			Send_Data_Block;
			End;
		Until (Done) or (Carrier_Lost) or (Aborted);
	End;


