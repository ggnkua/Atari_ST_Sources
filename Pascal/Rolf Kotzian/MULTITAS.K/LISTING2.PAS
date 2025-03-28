(*
    Programm : Scheduling-Simulator
    Unit     : tasks.pas
    Funktion : Hilfsroutinen zum Task-Handling

    Edit     : 13.04.91
    Autor    : Rolf Kotzian, Paderborn

    Copyright: (c) MAXON Computer GmbH
*)


UNIT Tasks;

(* Public Symbols *)
Interface
Uses Queue;


(* Prototyping *)
procedure task_state  (t: task);
procedure work_task   (var s:Schlange; var t:task;
                       time: integer);

procedure schedule_rr (var s:Schlange; time_slice:
                       integer);


(* Private Symbols *)
Implementation


(* 'task_state':  wird bei jedem Aufruf der Task
                  't' aufgerufen und gibt deren
                  aktuellen Zustand wie folgt aus:
             
                  - Prozesskennung (PID)
                  - Ankunftszeit der Task
                  - (gesch„tzte) (Rest-) Laufzeit
                  - Priorit„t 
*)

procedure task_state (t: task);
begin
        Write   (t.pid:2, '   ', t.ankunft:8);
        Write   ('   ', t.laenge:8);
        Writeln (t.prior:11);

end; (* task_state *)



(* 'work_task':  l„žt den Prozess 't' genau 'time'
                 Zeiteinheiten arbeiten uns stoppt
                 diesen anschliežend. *)

procedure work_task (var s:Schlange; var t:task;
                     time: integer);
var i: integer;
begin
          
        task_state (t);

        for i := 1 to time do        
        (* Unsere Task darf jetzt genau 'time' 
           Zeiteinheiten schuften ! *)
                ;
        
        (* Restlaufzeit ermitteln *)
        t.laenge := t.laenge - time;
        if t.laenge > 0 then
            (* Task wieder einreihen *) 
            enq_queue (s, t);

        (* Schlangenkopf entfernen *)
        deq_queue (s);

end; (* work_task *)


                        
(* 'schedule_rr':  Scheduling-Algorithmus, bei dem
                   die Prozesse nach dem Round-
                   Robin Verfahren (RR) ausgew„hlt
                   werden... *)

procedure schedule_rr (var s: Schlange; 
                       time_slice: integer);
var t: task;
time: integer;
begin

        (* Es wird so lange gearbeitet, bis alle 
           Prozesse komplett bedient wurden, die
           Warteschlange also leer ist... *)

        while not is_empty_queue(s) do
        begin
                (* erste Taks aus der Warte-
                   schlange holen... *)

                front (s,t);

                (* reicht das Limit der Zeit-
                   scheibe zur vollst„ndigen
                   Bearbeitung der Task aus ? *)

                if t.laenge > time_slice then
                    (* Nein ! *)
                    work_task (s, t, time_slice)

                else (* Ja, Limit reicht aus ! *)
                work_task (s, t, t.laenge);
        end; 

end; (* schedule_rr *)


Begin
End.    (* End of Unit 'Tasks' *)


(* Listing 2 *)
