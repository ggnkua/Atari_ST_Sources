(*
    Programm : Scheduling-Simulator
    Modul    : Multi_Level_Queue.pas
    Funktion : Prozess-Verarbeitung nach dem
               MLQ-Verfahren...

    Edit     : 14.04.91
    Autor    : Rolf Kotzian, Paderborn

    Copyright: (c) MAXON Computer GmbH
*)


Program Multi_Level_Queue (input, output);

Uses Queue, Tasks;

(* Variablen-Vereinbarungen *)

Var dat : File of task;
    t   : task;
    s   : array[1..4] of Schlange;
    time: array[1..4] of integer;


Begin (* MAIN *)

    ClrScr;
    Writeln ('Scheduling-Simulator');
    Write   ('Prozess-Verarbeitung nach dem ');
    Writeln ('Multi-Level-Queue Verfahren');
    Writeln ('by Rolf Kotzian, Paderborn');
    Writeln;
    Writeln ('(c) 1991 MAXON Computer GmbH');
    Writeln; Writeln;

    Reset (dat, 'tasks.in');
    if IOResult = 0 then
    begin
            (* leere Warteschlangen erzeugen *)
            create_queue (s[1]);
            create_queue (s[2]);
            create_queue (s[3]);
            create_queue (s[4]);

            while not eof (dat) do
            begin
                    (* die Prozessdaten werden aus
                      dem File gelesen, und in die
                      entsprechende Warteschlange
                      (abhÑngig von der PrioritÑt)
                      eingereiht... *)

                    Read (dat, t);
                    enq_queue (s[t.prior], t);
            end;
    end
    else
    begin
            (* leider konnte das File 'tasks.in'
               nicht gelesen werden... *)

            Writeln ('Kann Daten nicht lesen !');
            Halt;
    end;

    (* Nun werden die Zeitscheiben fÅr jede zu
       bearbeitende Klasse festgelegt... *)

    Write ('Zeitscheibe der Klasse 1: '); 
    Readln (time[1]);

    Write ('Zeitscheibe der Klasse 2: ');
    Readln (time[2]);

    Write ('Zeitscheibe der Klasse 3: '); 
    Readln (time[3]);

    Write ('Zeitscheibe der Klasse 4: '); 
    Readln (time[4]);

    (* Jede Klasse wird wiederum nach dem
       Round-Robin Verfahren bearbeitet... *)

    Write   ('PID:    ANKUNFT:    LéNGE:   ');
    Writeln (' PRIORITéT:');
    Write   ('=============================');
    Writeln ('===========');
    Writeln;
    
    schedule_rr (s[1], time[1]);
    schedule_rr (s[2], time[2]);
    schedule_rr (s[3], time[3]);
    schedule_rr (s[4], time[4]);
    
    Readln;

End. (* MAIN *)


(* Listing 4 *)

