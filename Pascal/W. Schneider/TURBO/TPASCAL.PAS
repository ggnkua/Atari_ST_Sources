unit tpascal;
{ Proceduren und Funtionen, die in MAXON-PASCAL  }
{ nicht existieren oder andere Ergebnisse lie-   }
{ fern, werden bereitgestellt  bzw. redefiniert. }

{  W. Schneider, Berlin 12/1991                  }
{  (c) 1992 MAXON Computer                       }

Interface
{$R-,D-,F+}

Type Registers=Record 
     Case Integer of
      0: (AX,BX,CX,DX,BP,SI,DI,DS,ES,Flags :Word);
      1: (AL,AH,BL,BH,CL,CH,DL,DH :Byte);
     End;  

Function  ReadKey :Char;
Procedure Sound (frq :Word); 
Procedure NoSound;
Procedure Intr(IntNo:Integer; Var Regs:Registers);


Implementation

var scancd          :word;
    oldfont,oldexit :pointer;

{*** Redefinition von ReadKey ***}
function readkey:char; assembler;
asm
    tst.w   scancd
    beq     @rk1
    move.w  scancd,@result
    clr.w   scancd
    bra     @rkend
  @rk1:
    move.w  #2,-(sp)            
    move.w  #2,-(sp)       
    trap    #13
    addq.l  #4,sp
    move.w  d0,@result
    clr.w   scancd
    tst.b   d0
    bne     @rkend
    swap    d0
    move.w  d0,scancd
  @rkend:
end;    

{ einfache Soundbefehle, nutzer Kanal A des      }
{ Soundchips                                     }
{*** Sound abschalten ***}
procedure nosound; assembler;
asm
    move.w  #135,-(sp)
    move.w  #$ff,-(sp)
    move.w  #28,-(sp)
    trap    #14
    addq.l  #6,sp
end;         

{*** Ton erzeugen, max. LautstÑrke ***}
procedure sound(frq :word);
var tc :integer;
begin 
  if (frq>30) and (frq<20000) then
  begin
    tc:=round(125000/frq);
    asm
        move.w  tc,d5
        clr.w   d0
        move.b  d5,d0
        move.w  #128,-(sp)
        move.w  d0,-(sp)
        move.w  #28,-(sp)
        trap    #14
        addq.l  #6,sp
        
        lsr.w   #8,d5
        clr.w   d0
        move.b  d5,d0
        move.w  #129,-(sp)
        move.w  d0,-(sp)
        move.w  #28,-(sp)
        trap    #14
        addq.l  #6,sp
        
        move.w  #136,-(sp)
        move.w  #$0f,-(sp)
        move.w  #28,-(sp)
        trap    #14
        addq.l  #6,sp
        
        move.w  #135,-(sp)
        move.w  #$fe,-(sp)
        move.w  #28,-(sp)
        trap    #14
        addq.l  #6,sp
    end;
  end;
end;      

{ Einige oft genutzte DOS-Interrupts emulieren   }
procedure intr(intno :integer;var regs:registers);
var temp :integer;
begin
  if intno=5 then
    asm           { Bildschirm-Hardcopy auslîsen } 
        pea     @sdstrt
        move.w  #38,-(sp)
        trap    #14
        addq.l  #2,sp
        bra     @sdend
      @sdstrt:
        clr.w   $4ee
        rts
      @sdend:  
    end          
  else with regs do
  begin
    if (intno=$10) and (ah=1) then { Cusor konf. }
    begin
      if ch= $20 then 
        asm                        { Cursor aus  }
            move.w  #0,-(sp)
            move.w  #0,-(sp)
            move.w  #21,-(sp)
            trap    #14
            addq.l  #6,sp
        end;    
      if ch<>$20 then 
        asm                        { Cursor ein  }
            move.w  #0,-(sp)
            move.w  #1,-(sp)
            move.w  #21,-(sp)
            trap    #14
            addq.l  #6,sp
        end;    
    end;
    if (intno=$16) and (ah=2) then 
      begin     { Umschaltst. Tastatur ermitteln } 
        asm
            move.w  #-1,-(sp)
            move.w  #11,-(sp)
            trap    #13
            addq.l  #4,sp
            move.w  d0,temp
        end;
        al:=temp;
      end;  
  end;
end;      

{ IBM-Zeichensatz zur VerfÅgung stellen          }
{*** Zeichensatzdaten ***}
procedure ibmfont; external;
{$L a:\ibmfont.o}

{*** Zeichensatz fÅr TOS installieren ***}
function instfont(newfont :pointer):pointer; 
assembler;
asm 
    dc.w     $a000
    move.l   -$16(a0),@result
    move.l   newfont,-$16(a0)
end; 

{ nach Programmende alten Zeichensatz inst.      }
procedure tpexit;
begin
  oldfont:=instfont(oldfont);  
  exitproc:=oldexit;
end;  

{ diverse Initialisierungen                      }

begin
  oldexit:=exitproc;
  exitproc:=@tpexit;
  oldfont:=instfont(@ibmfont); 
  scancd:=0;
end.      
