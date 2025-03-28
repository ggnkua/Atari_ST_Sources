(************************************************
*                                               *
* Interrupt-Programmierung in MAXON-Pascal      *
* Beispielprogramm                              *
* von Thomas Krieger                            *
* (C) 1992 MAXON Computer                       *
*                                               *
************************************************)

(*$S-,R-,D-,F+*)

program timer;

uses Dos, Bios, i_timer, Graph;

var laenge: LongInt;
    driver, mode: Integer;
    
   procedure Ptermres(keep: LongInt; ret: Integer);
   begin
      asm
         move.w   ret,-(sp)
         move.l   keep,-(sp)
         move.w   #$31,-(sp)
         trap     #1
         addq.l   #8,sp
      end;
   end;

begin               
   driver:= detect;
   InitGraph(driver, mode, '');
   
   laenge := 256 + BasePage^.data.size + 
             BasePage^.text.size + 
             BasePage^.bss.size;
   
   Write('Interrupt-Timer (C) 1991, 1992 ... ');
   WriteLn('Thomas Krieger installiert');
   
   init_timer(566,2);
   
   SwapVectors;
   PtermRes(laenge, 0);
end.
