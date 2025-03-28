(*
    Programm : Extended Standard-Library
    Unit     : queue.pas
    Funktion : Implementation des abstrakten
               Datentyps 'Schlange'
    
    Edit     : 09.04.91
    Autor    : Rolf Kotzian, Paderborn

    Copyright: (c) MAXON Computer GmbH
*)


UNIT Queue;

(* Public-Symbols *)
Interface

Type task = 
record
    pid      : integer;     (* Prozess-Kennung *)
    ankunft,                (* Ankunftszeit    *)
    laenge   : Longint;     (* geschÑtzte Aus-
                               fÅhrungszeit    *)
    prior    : integer;     (* PrioritÑt       *)
end;

Squeue = ^Selem; 
Schlange = record
                anfang, ende : Squeue;
           end;
                
Selem = record
                value : task;
                rest  : Squeue;
        end;                                                        
             
                                                                     
                
(* Prototyping *)

procedure create_queue  (var schlange: Schlange);
function is_empty_queue (schlange: Schlange): 
                        boolean;

procedure front         (schlange: Schlange; 
                         var t: task);

procedure deq_queue     (var schlange: Schlange);
procedure enq_queue     (var schlange: Schlange;
                         t: task);


(* Private Symbols *)

Implementation


(* 'create_queue':  erzeugt eine leere Schlange *)

procedure create_queue (var schlange: Schlange);
begin
        schlange.ende := Nil;
        
end; (* create_queue *)



(* 'is_empty_queue': prÅft, ob Schlange leer... *)

function is_empty_queue (schlange: Schlange): 
         boolean;
begin
        is_empty_queue := (schlange.ende = Nil);
        
end; (* is_empty_queue *)



(* 'front':  liefert (vorderstes) Element der
             Schlange... *)

procedure front (schlange: Schlange; var t: task);
var dummy: ^Selem;
begin
        if not is_empty_queue (schlange) then
        begin
                dummy := schlange.anfang;

                t.pid     := dummy^.value.pid;
                t.ankunft := dummy^.value.ankunft;
                t.laenge  := dummy^.value.laenge;
                t.prior   := dummy^.value.prior;
        end;
                      
end; (* front *)



(* 'deq_queue':  entfernt (vorderstes) Element
                 der Schlange... *)

procedure deq_queue (schlange: Schlange);
var dummy: ^Selem;
begin
        if not is_empty_queue (schlange) then
        begin
                dummy := schlange.anfang;
                schlange.anfang := schlange.
                                   anfang^.rest;                
                if schlange.anfang = Nil then 
                    schlange.ende := Nil;
        
                dispose (dummy);
        end;
        
end; (* deq_queue *)



(* 'enq_queue':  hÑngt neues Element (hinten) an 
                 die Schlange... *)

procedure enq_queue (var schlange: Schlange; 
                     t: task);
var dummy : ^Selem;
begin
        new (dummy);
        dummy^.value.pid     := t.pid;
        dummy^.value.ankunft := t.ankunft;
        dummy^.value.laenge  := t.laenge;
        dummy^.value.prior   := t.prior;
        dummy^.rest  := Nil;
        
        if schlange.ende = Nil then 
                 schlange.anfang := dummy
        else schlange.ende^.rest := dummy; 
        
        schlange.ende := dummy;
        
end; (* enq_queue *)


Begin
End.  (* End of Unit 'queue' *)


(* Listing 1 *)
