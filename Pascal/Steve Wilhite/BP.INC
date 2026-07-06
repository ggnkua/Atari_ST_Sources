{[b+,t=3]}
{-----------------------------------------------------------------------------
! Copyright (c) 1985 by Steve Wilhite, Worthington, Ohio
!
! Permission is granted to use or distribute this software without any
! restrictions at long as this entire copyright notice is included intact.
! You may include it in any software product that you sell for profit.
!
! This software is distributed as is, and is not guaranteed to work on any
! given hardware/software configuration.  Furthermore, no liability is granted
! with this software.
+-----------------------------------------------------------------------------
! ABSTRACT:
!
!       The following function, Transfer_File, implements error-free file
!       transfer using CompuServe's "B" protocol.
!
!       It has been assumed that the start-of-packet sequence, DLE "B", has
!       been detected and the next byte not received yet is the packet
!       sequence number (an ASCII digit).
!
!       The following routines are external to the BP package:
!
!       1)  procedure Start_Timer(Seconds: Integer);
!
!               Enable the timer for the specified number of seconds.
!
!       2)  function Timer_Expired: Boolean;
!
!               Returns "true" if the timer has expired, "false" otherwise.
!
!       3)  function Wants_To_Abort: Boolean;
!
!               Returns "true" if the user wants to abort the file transfer,
!               "false" otherwise.
!
!       4)  function Read_Modem(var Ch: Char): Boolean;
!
!               Read a character from the comm port.  Returns "true" if a
!               character is available, "false" if no character is available.
!               If a character is available, it is returned in the variable
!               "Ch", else "Ch" is undefined.
!
!       5)  function Write_Modem(Ch: Char): Boolean;
!
!               Sends a character to the comm port.  Returns "true" if
!               successful, "false" otherwise.
!
!       6)  function Create_File(Name: Filename_Str;
!                                Attribute: Integer): Integer;
!
!               Creates a new file or truncates an old file to zero length
!               in preparation for writing.
!
!       7)  function Open_File(Name: Filename_Str;
!                              Access: Integer) : Integer;
!
!               Opens a file for the specified access.
!
!       8)  function Close_File(Handle: Integer): Integer);
!
!               Closes the file associated with a specified file handle.
!
!       9)  function Read_File(Handle: Integer;
!                              var Buffer;
!                              Bytes_To_Read: Integer): Integer;
!
!               Transfers a specified number of bytes from a file into a
!               buffer location.  If the returned value for the number of
!               bytes read is zero, then the program tried to read from the
!               end of file.
!
!       10) function Write_File(Handle: Integer;
!                               var Buffer;
!                               Bytes_To_Write: Integer): Integer;
!
!               Transfers a specified number of bytes from a buffer into a
!               file.  If the number of bytes written is not the same as the
!               number requested, then an error has occurred.
!
! ENVIRONMENT: Turbo Pascal, machine independent.
!
! AUTHOR: Steve Wilhite, CREATION DATE: 29-May-85
!
! REVISION HISTORY:
!
+----------------------------------------------------------------------------}


function Transfer_File: Boolean;

   label
      99;

   const
      ETX = #$03;
      ENQ = #$05;
      DLE = #$10;
      XON = #$11;
      XOFF = #$13;
      NAK = #$15;
      Max_Time = 10;
      Max_Errors = 10;
      Packet_Size = 512;

   type
      Buffer =
         record
            Size: Integer;
            Data: array [1..Packet_Size] of Char
         end;

   var
      Filename: string [64];  { pathname }
      Ch: Char;
      I: Integer;
      Checksum: Integer;
      Seq_Num: Integer;
      RCV, XMT: Buffer;
      Timed_Out: Boolean;
      XOFF_Flag: Boolean;
      Seen_ETX: Boolean;


   procedure Do_Checksum(Ch: Char);
      begin
      Checksum := Checksum shl 1;
      if Checksum > 255 then Checksum := (Checksum and $FF) + 1;
      Checksum := Checksum + Ord(Ch);
      if Checksum > 255 then Checksum := (Checksum and $FF) + 1;
      end;


   procedure Send_Byte(Ch: Char);

      var
         TCh: Char;

      begin

      { Listen for XOFF from the network }

      repeat
         while Read_Modem(TCh) do
            if TCh = XON then XOFF_Flag := false
            else if TCH = XOFF then XOFF_Flag := true;
      until not XOFF_Flag;

      while not Write_Modem(Ch) do;

      end;


   procedure Send_Masked_Byte(Ch: Char);
      begin

      if Ch in [ETX, ENQ, DLE, XON, XOFF, NAK] then
         begin
         Send_Byte(DLE);
         Send_Byte(Chr(Ord(Ch) + 64));
         end
      else Send_Byte(Ch);

      end;


   procedure Send_ACK;
      begin
      Send_Byte(DLE);
      Send_Byte(Chr(Seq_Num + 48));
      end;



   procedure Read_Byte;
      begin
      Timed_Out := false;

      if not Read_Modem(Ch) then
         begin
         Start_Timer(Max_Time);

         repeat
            Timed_Out := Timer_Expired;
         until Timed_Out or Read_Modem(Ch);
         end;

      end;


   procedure Read_Masked_Byte;
      begin
      Seen_ETX := false;
      Read_Byte;

      if not Timed_Out then
         if Ch = DLE then
            begin
            Read_Byte;
            if not Timed_Out then Ch := Chr(Ord(Ch) and $1F);
            end
         else if Ch = ETX then Seen_ETX := true;

      end;


   type
      RCV_Actions = (R_Get_DLE, R_Get_B, R_Get_Seq, R_Get_Data,
                     R_Get_Checksum, R_Send_NAK, R_Send_ACK, R_Finish);


   function Read_Packet(Action: RCV_Actions;
                        var RCV: Buffer): Boolean;
    {
    | Receive a packet from the host.
    }

      var
         Errors: Integer;
         Next_Seq: Integer;

      begin
      Errors := 0;

      while (Action <> R_Finish) and (Errors < Max_Errors) do
         case Action of
            R_Get_DLE:
               begin
               Read_Byte;

               if Timed_Out then Action := R_Send_NAK
               else if Ch = DLE then Action := R_Get_B
               else if Ch = ENQ then Action := R_Send_ACK;
               end;

            R_Get_B:
               begin
               Read_Byte;

               if Timed_Out then Action := R_Send_NAK
               else if Ch = 'B' then Action := R_Get_Seq
               else Action := R_Get_DLE
               end;

            R_Get_Seq:
               begin
               Read_Byte;

               if Timed_Out then Action := R_Send_NAK
               else
                  begin
                  Checksum := 0;
                  Next_Seq := Ord(Ch) - 48;
                  Do_Checksum(Ch);
                  RCV.Size := 0;
                  Action := R_Get_Data;
                  end;
               end;

            R_Get_Data:
               begin
               Read_Masked_Byte;

               if Timed_Out then Action := R_Send_NAK
               else if Seen_ETX then Action := R_Get_Checksum
               else if RCV.Size = Packet_Size then Action := R_Send_NAK
               else
                  begin
                  RCV.Size := RCV.Size + 1;
                  RCV.Data[RCV.Size] := Ch;
                  Do_Checksum(Ch);
                  end;
               end;

            R_Get_Checksum:
               begin
               Do_Checksum(ETX);
               Read_Masked_Byte;

               if Timed_Out then Action := R_Send_NAK
               else if Checksum <> Ord(Ch) then Action := R_Send_NAK
               else if Next_Seq = Seq_Num then
                  Action := R_Send_ACK  {Ignore duplicate packet}
               else if Next_Seq <> (Seq_Num + 1) mod 10 then
                  Action := R_Send_NAK
               else
                  begin
                  Seq_Num := Next_Seq;
                  Action := R_Finish;
                  end;
               end;

            R_Send_NAK:
               begin
	       Write('-');
               Errors := Errors + 1;
               Send_Byte(NAK);
               Action := R_Get_DLE;
               end;

            R_Send_ACK:
               begin
               Send_ACK;
               Action := R_Get_DLE;
               end;
            end;  {case}

      Read_Packet := Errors < Max_Errors
      end;  {Read_Packet}



   function Send_Packet(XMT: Buffer): Boolean;
    {
    | Send the specified packet to the host.
    }

      type
         Actions = (S_Send_Packet, S_Get_DLE, S_Get_Num, S_Get_Seq,
                    S_Get_Data, S_Get_Checksum, S_Timed_Out, S_Send_NAK,
		    S_Finish);

      var
         Action: Actions;
         Next_Seq: Integer;
	 RCV_Num: Integer;
         I: Integer;
         Errors: Integer;

      begin
      Next_Seq := (Seq_Num + 1) mod 10;
      Errors := 0;
      Action := S_Send_Packet;

      while (Action <> S_Finish) and (Errors < Max_Errors) do
         case Action of
            S_Send_Packet:
               begin
               Checksum := 0;
               Send_Byte(DLE);
               Send_Byte('B');
               Send_Byte(Chr(Next_Seq + 48));
               Do_Checksum(Chr(Next_Seq + 48));

               for I := 1 to XMT.Size do
                  begin
                  Send_Masked_Byte(XMT.Data[I]);
                  Do_Checksum(XMT.Data[I]);
                  end;

               Send_Byte(ETX);
               Do_Checksum(ETX);
               Send_Masked_Byte(Chr(Checksum));
               Action := S_Get_DLE;
               end;

            S_Get_DLE:
               begin
               Read_Byte;

               if Timed_Out then Action := S_Timed_Out
               else if Ch = DLE then Action := S_Get_Num
               else if Ch = NAK then
                  begin
                  Errors := Errors + 1;
                  Action := S_Send_Packet;
                  end;
               end;

            S_Get_Num:
               begin
               Read_Byte;

               if Timed_Out then Action := S_Timed_Out
               else
                  case Ch of
                     '0'..'9':
                        if Ch = Chr(Seq_Num + 48) then
                        { Ignore duplicate ACK }
                           Action := S_Get_DLE
                        else if Ch = Chr(Next_Seq + 48) then
                           begin  { Correct sequence number }
                           Seq_Num := Next_Seq;
                           Action := S_Finish;
                           end
                        else if Errors = 0 then Action := S_Send_Packet
                        else Action := S_Get_DLE;

                     ';':  { Wait Acknowledge }
                        begin
                        Delay(5000);  { sleep for 5 seconds }
                        Action := S_Get_DLE;
                        end;

                     'B': Action := S_Get_Seq;

                     else Action := S_Get_DLE;

                     end;  {case}
               end;

            S_Get_Seq:
               begin
               { Start of a "B" protocol packet. The only packet }
               { that makes any sense here is a failure packet.  }

	       Read_Byte;

	       if Timed_Out then Action := S_Timed_Out
	       else
		  begin
		  Checksum := 0;
		  RCV_Num := Ord(Ch) - 48;
		  Do_Checksum(Ch);
		  RCV.Size := 0;
		  Action := S_Get_Data;
		  end;
               end;

	    S_Get_Data:
	       begin
	       Read_Masked_Byte;

	       if Timed_Out then Action := S_Send_NAK
	       else if Seen_ETX then Action := S_Get_Checksum
	       else if RCV.Size = Packet_Size then Action := S_Send_NAK
	       else
		  begin
		  RCV.Size := RCV.Size + 1;
		  RCV.Data[RCV.Size] := Ch;
		  Do_Checksum(Ch);
		  end;
	       end;

	    S_Get_Checksum:
	       begin
	       Do_Checksum(ETX);
	       Read_Masked_Byte;

	       if Timed_Out then Action := S_Send_NAK
	       else if Checksum <> Ord(Ch) then Action := S_Send_NAK
	       else if RCV_Num <> (Next_Seq + 1) mod 10 then
		  Action := S_Send_NAK
	       else
		  begin
		  { Assume the packet is a failure packet. It makes no }
		  { difference since any other type of packet would be }
		  { invalid anyway.  Return false to caller.           }

		  Errors := Max_Errors;
		  end;
	       end;

            S_Timed_Out:
               begin
               Errors := Errors + 1;
               Action := S_Get_DLE;
               end;

	    S_Send_NAK:
	       begin
	       Write('-');
	       Errors := Errors + 1;
	       Send_Byte(NAK);
	       Action := S_Get_DLE;
	       end;
            end;  {case}

      Send_Packet := Errors < Max_Errors;
      end;  {Send_Packet}



   procedure Send_Failure(Code: Char);
   {
   ! Send a failure packet to the host.
   }

      var
         Dummy: Boolean;

      begin
      XMT.Data[1] := 'F';
      XMT.Data[2] := Code;
      XMT.Size := 2;
      Dummy := Send_Packet(XMT);
      end;



   function Receive_File: Boolean;

      label
         99;

      var
         Data_File: Integer;
         Status: Integer;
         Done: Boolean;

      begin
      Data_File := Create_File(Filename, 0);

      if Data_File < 0 then
         begin
         WriteLn('[ Cannot create file ]');
         Send_Failure('E');
         Receive_File := false;
         goto 99;
         end;

      Send_ACK;
      Done := false;

      repeat
         if Read_Packet(R_Get_DLE, RCV) then
            case RCV.Data[1] of
               'N':
                  begin  { Data packet }
                  Status := Write_File(Data_File, RCV.Data[2], RCV.Size - 1);

                  if Status <> (RCV.Size - 1) then
                     begin
                     WriteLn('[ Disk write error ]');
                     Send_Failure('E');  {disk write error}
                     Receive_File := false;
                     Done := true;
                     end
                  else if Wants_To_Abort then
                     begin
                     Send_Failure('A');  {the user wants to kill the xfer}
                     Receive_File := false;
                     Done := true;
                     end
                  else
		     begin
		     Send_ACK;
		     Write('+');
		     end;

                  end;

               'T':
                  begin  { Transfer packet }

                  if RCV.Data[2] = 'C' then  {close file}
                     begin
                     Send_ACK;
                     Receive_File := true;
                     Done := true;
                     end
                  else
                     begin
                     { Unexpected "T" packet. Something is rotten on the }
                     { other end. Send a failure packet to kill the transfer }
                     { cleanly. }

                     WriteLn('[ Unexpected packet type ]');
                     Send_Failure('E');
                     Receive_File := false;
                     Done := true;
                     end;

                  end;

               'F':
                  begin  { Failure packet }
                  Send_ACK;
                  Receive_File := false;
                  Done := true;
                  end;
               end  {case}
         else
            begin
            Receive_File := false;
            Done := true;
            end;

      until Done;

      Status := Close_File(Data_File);
   99:
      end;  {Receive_File}



   function Send_File: Boolean;

      label
         99;

      var
         Data_File: Integer;
         N: Integer;

      begin
      Data_File := Open_File(Filename, 0);

      if Data_File < 0 then
         begin
         WriteLn('[ Cannot access that file ]');
         Send_Failure('E');  {could not open the file for input}
         Send_File := false;
         goto 99;
         end;

      repeat
         XMT.Data[1] := 'N';
         N := Read_File(Data_File, XMT.Data[2], Packet_Size - 1);

         if N > 0 then
            begin
            XMT.Size := N + 1;

            if not Send_Packet(XMT) then
               begin
               Send_File := false;
               goto 99;
               end;

            if Wants_To_Abort then
               begin
               Send_Failure('A');  {user wants to abort the transfer}
               Send_File := false;
               goto 99;
               end;

	    Write('+');
            end;

      until N < 1;

      if N = 0 then
	 begin
	 N := Close_File(Data_File);
	 XMT.Data[1] := 'T';
	 XMT.Data[2] := 'C';
	 XMT.Size := 2;
	 Send_File := Send_Packet(XMT);
	 end
      else
	 begin
	 WriteLn('[ Disk read error ]');
	 Send_Failure('E');
	 Send_File := false;
	 end;
   99:
      end;  {Send_File}


   begin  {Transfer_File}
   XOFF_Flag := false;
   Seq_Num := 0;

   if Read_Packet(R_Get_Seq, RCV) then
      if RCV.Data[1] = 'T' then  {transfer packet}
         begin

         { Check the direction }

         if (RCV.Data[2] <> 'D') and (RCV.Data[2] <> 'U') then
            begin
            Send_Failure('N');  {not implemented}
            Transfer_File := false;
            goto 99;
            end;

         { Check the file type }

         if (RCV.Data[3] <> 'A') and (RCV.Data[3] <> 'B') then
            begin
            Send_Failure('N');  {not implemented}
            Transfer_File := false;
            goto 99;
            end;

         { Collect the file name }

         if RCV.Size - 3 > 63 then Filename[0] := Chr(63)
         else Filename[0] := Chr(RCV.Size - 3);

         for I := 1 to Length(Filename) do Filename[I] := RCV.Data[I + 3];

         { Do the transfer }

         if RCV.Data[2] = 'U' then Transfer_File := Send_File
         else Transfer_File := Receive_File;
         end
      else
         begin
         Send_Failure('E');  {wrong type of packet}
         Transfer_File := false;
         end
   else Transfer_File := false;
99:
   end;  {Transfer_File}
