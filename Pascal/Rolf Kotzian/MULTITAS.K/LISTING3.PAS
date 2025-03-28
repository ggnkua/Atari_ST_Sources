(*
    Programm : Scheduling-Simulator
    Modul    : Round_Robin.pas
    Funktion : Prozess-Verarbeitung nach dem
               Round-Robin Verfahren

    Edit     : 13.04.91
    Autor    : Rolf Kotzian, Paderborn

    Copyright: (c) MAXON Computer GmbH
*)


Program Round_Robin (input, output);

Uses Queue, Tasks;

(* Variablen-Vereinbarungen *)

Var dat : File of task;
    t   : task;
    s   : Schlange;
    time_slice: integer;


Begin (* Main *)

    ClrScr;  
    Writeln ('Scheduling-Simulator');
    Write   ('Prozess-Verarbeitung nach dem ');
    Writeln ('Round-Robin Verfahren');
    Writeln ('by Rolf Kotzian, Paderborn');
    Writeln;
    Writeln ('(c) 1991 MAXON Computer GmbH');
    Writeln; Writeln;


    Reset (dat, 'tasks.in');
    if IOresult = 0 then
    begin            
            (* leere Warteschlange erzeugen *)
            create_queue (s); 

            while not eof (dat) do
            begin
                    (* Prozessdaten aus File
                       lesen und in eine Warte-
                       schlange einfÅgen... *)
                    
                    Read (dat, t);    
                    enq_queue (s, t);  
            end;
    end
    else
    begin
            (* leider konnte das File 'tasks.in' 
               nicht gelesen werden... *)

            Writeln ('Kann Daten nicht lesen !');
            Halt;
    end;


    Write  ('Wie groû ist die Zeitscheibe? ');
    Readln (time_slice); Writeln;
    
    (* Nun wird der Scheduler aufgerufen, der die
       Bearbeitung der Tasks steuert... *)

    Write   ('PID:    ANKUNFT:    LéNGE:   ');
    Writeln (' PRIORITéT:');
    Write   ('=============================');
    Writeln ('===========');
    Writeln;

    schedule_rr (s, time_slice);
    Readln;  

End. (* Main *)


(* Listing 3 *)
