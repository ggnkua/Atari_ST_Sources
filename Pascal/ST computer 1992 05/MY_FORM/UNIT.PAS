{(c) 1992 MAXON Computer}

UNIT MyForm;

INTERFACE

USES DOS,BIOS,GEMAes;

TYPE
    Tabellen_Typ = PACKED ARRAY [0..128] OF CHAR;
    Tabellen_Zeiger = ^ Tabellen_Typ;
    Tabellen_Puffer = RECORD 
        Normal :Tabellen_Zeiger;
        Shift  :Tabellen_Zeiger;
        Capslock :Tabellen_Zeiger;
        END;
    KeyPtr = ^Tabellen_Puffer;            

    MSG_feld  = ARRAY[0..7] OF INTEGER;    
    
    C_String   = PACKED ARRAY [0..255] OF CHAR;
    String_Ptr = ^C_string;


{ Die Struktur Objekt enth„lt alle wichtigen }
{ Informationen ber Objekte. (z.B. Boxen,   }
{ Menutitel,-eintr„ge) siehe hierzu in [1]   }
    Object   = RECORD                      
    ob_next, ob_head, ob_tail,
            ob_type, ob_flags, ob_state : 
            INTEGER;
            ob_spec : String_Ptr;
            ob_x, ob_y, ob_w, ob_h  :  INTEGER;
            END;
            
    Tree     = ARRAY [0..50] of Object;      
    ObPtr  = ^Tree;


    controlary     =    ARRAY[0..5] OF INTEGER ;   
    globalary      =    ARRAY[0..15] OF INTEGER ;
    intinary       =    ARRAY[0..16] OF INTEGER ;
    intoutary      =    ARRAY[0..7] OF INTEGER ; 
    adrinary       =    ARRAY[0..2] OF ObPtr ;  
    adroutary      =    ARRAY[0..5] OF LongInt ;

    GEMParBlk = RECORD                
        control     :    ^controlary;   
        global      :    ^globalary;
        intin       :    ^intinary ;
        intout      :    ^intoutary ; 
        adrin       :    ^adrinary ;  
        adrout      :    ^adroutary ;
        END;


FUNCTION My_Form_Do(dia:ObPtr;child:INTEGER)
            :INTEGER;

                    
IMPLEMENTATION

VAR     stptr : POINTER;
        OldAdr: LongInt;
{ Zeiger auf den Parameterblock }
        aespb : ^GEMParBlk;
        keytab: KeyPtr;
        

PROCEDURE AesCall;ASSEMBLER;
ASM
       move.l   aespb,d1        
{ AES-Parameterblock }
       move.w   #200,d0         
{ Magic-Number fr AES }
       trap     #2              
{ GEM-Aufruf }
END;       
            

FUNCTION form_keybd(VAR fo_ktree:ObPtr;
    fo_kobject,fo_kobnext,fo_kchar :INTEGER;
    VAR fo_knextobject,fo_knextchar :INTEGER)
    :INTEGER; 
BEGIN
{ Ich trage nun die Variablen in die Felder ein}
    aespb^.adrin^[0]:=fo_ktree;
{ Zeiger auf Dialogbox                   }

    aespb^.intin^[0]:=fo_kobject;
{ Objektindex des aktuellen Edit-Objektes }
 
    aespb^.intin^[1]:=fo_kchar;
{ gedrckte Taste }

    aespb^.intin^[2]:=fo_kobnext;
{ unbenutzt, deshalb 0 w„hlen  }

{ Funktionsnummer des AES ist hier 55 }
    aespb^.control^[0]:=55;
{ Anzahl der Elemente in intinary }
    aespb^.control^[1]:=3;
{ Anzahl der Elemente in intoutary }
    aespb^.control^[2]:=3;
{ Anzahl der Elemente in adrinary }
    aespb^.control^[3]:=1;
{ Anzahl der Elemente in adroutary }
    aespb^.control^[4]:=0;
    AesCall;
    fo_knextobject:=aespb^.intout^[1]; 
{ Objektindex des neuen Edit-Objektes  }
{ z.B. bei [TAB]                       }

    fo_knextchar:=aespb^.intout^[2];
{ in den Text einzutragendes Zeichen;    }
{ hierzu wird objc_edit benutzt         }

    form_keybd:=aespb^.intout^[0];
{ Flag zum Verlassen des Dialoges;     }
{ 0: Dialog verlassen                  }

END;


FUNCTION form_button(VAR fo_btree:ObPtr;
    fo_bobject,fo_bclicks:INTEGER; VAR 
    fo_bnxtobj:INTEGER):INTEGER; 
BEGIN
    aespb^.adrin^[0]:=fo_btree;
{ Zeiger auf Dialogbox                   }

    aespb^.intin^[0]:=fo_bobject;
{ Objektindex des angeklickten Objektes }

    aespb^.intin^[1]:=fo_bclicks;
{ Anzahl der Mausklicks  }

{ Funktionsnummer des AES ist hier 56}
    aespb^.control^[0]:=56;
    aespb^.control^[1]:=2;
    aespb^.control^[2]:=2;
    aespb^.control^[3]:=1;
    aespb^.control^[4]:=0;
    AesCall;

    fo_bnxtobj:=aespb^.intout^[1]; 
{  Objektindex des neuen aktuellen Objektes }

    form_button:=aespb^.intout^[0];
{ Flag zum Verlassen des Dialoges;      }
{ 0: Dialog verlassen                  }

END;


Procedure GetKeyPtr;
VAR    longi   :LongInt;
BEGIN
{ bei bergabe eines Zeigers auf -1 } 
    longi:=-1;    
{ an Keytbl erh„lt man den Zeiger }
    keytab:=KeyTbl(@longi,@longi,@longi);
{ auf die aktuellen Tabellen }
    Bioskeys;
END;    



FUNCTION My_Form_Do(dia:ObPtr;child:INTEGER)
        :INTEGER;

CONST ROOT=0;
      MAX_DEPTH=255;
VAR    
i,j,obj,x,y,pos,button,cli,leave,event:INTEGER;
msg:Msg_Feld;
sp_key,key,new_pos:INTEGER;
ch:CHAR;
specstr :String_Ptr;
    
BEGIN
    leave:=1;
    IF child>0 THEN
        objc_edit(dia,child,chr(0),pos,EDINIT
            ,new_pos); 
{ Cursor einschalten  }    
   
   WHILE (leave>0) DO
   BEGIN
     event:=evnt_multi(MU_KEYBD|MU_BUTTON,$02,
          $01,$01,0,0,0,0,0,0,0,0,0,0,
          msg,0,0,
          x,y,button,
          sp_key,key,
          cli);
      pos:=new_pos;    
      IF (event  & MU_BUTTON >0) THEN
      BEGIN
      obj := objc_find(dia,ROOT,MAX_DEPTH,x,y);
      IF obj >=0 THEN
          BEGIN
          leave:=form_button(dia,obj,cli,obj); 
{ bei editierbaren Feldern Cursor wechseln }
          IF ((dia^[obj].ob_flags &EDITABLE>0)
                AND(obj<>child)) THEN
               BEGIN
               objc_edit(dia,child,chr(sp_key),
                    pos,EDEND,new_pos); 
               child:=obj;
               objc_edit(dia,child,chr(sp_key),
                    pos,EDINIT,new_pos);
               END;
          
          END
      ELSE
{ der beliebte Glockenton }
          Bconout(10,0);        
    END;
      IF (event & MU_KEYBD>0) THEN
{ Jetzt wird es interessant :}
        BEGIN IF (sp_key=$0008) THEN
{ Alternate wurde gedrckt }
            BEGIN
            ch:=CHAR(keytab^.shift^[Hi(key)]);  
{ASCII Zeichen ist ermittelt}
            i:=0;
            REPEAT
            i:=i+1;
            IF (dia^[i].ob_type=G_BUTTON) AND 
                (dia^[i].ob_flags&SELECTABLE>0) 
                THEN
                BEGIN
                specstr:=dia^[i].ob_spec;
{ Zeiger auf Buttontext }
                j:=-1;
                REPEAT 
                j:=j+1;
                UNTIL (specstr^[j]=chr(0) ) 
                    OR (specstr^[j]=ch);    
                IF specstr^[j]<>chr(0) THEN    
{ Der Button ist gefunden }
                    leave:=form_button
                        (dia,i,1,obj);
                END;
            UNTIL dia^[i].ob_flags&LASTOB <> 0;          
            END
        ELSE
            BEGIN    
            leave:=form_keybd(dia,child,0,key,
                obj,sp_key);
            IF (sp_key>0) THEN
                objc_edit(dia,child,chr(sp_key),
                    pos,EDCHAR,new_pos)
                ELSE
                IF ((dia^[obj].ob_flags & 
                    EDITABLE>0)AND(obj<>child)AND
                    (obj<=dia^[ROOT].ob_tail)) 
                    THEN
                    BEGIN
                    objc_edit(dia,child,
                        chr(sp_key),pos,EDEND
                        ,new_pos); 
                    child:=obj;
                    objc_edit(dia,child,
                        chr(sp_key),pos,EDINIT
                        ,new_pos);
                    END; 
            END;
        END;
    END;
    IF (child > 0) THEN 
    objc_edit(dia,child,chr(sp_key),pos,EDEND
        ,new_pos); 
            
    My_Form_Do:=obj;
    
END;


PROCEDURE Install; ASSEMBLER;
ASM
        lea         @GetAespb,a0      
{ GetAespb  in GEM Trap einh„ngen }
        move.l      $00000088,OldAdr  
{ alte Adressse in OldAdr speichern}
        move.l      a0,$00000088      
        lea         @ToEnd,A0
        jmp         (A0)         
@GetAespb:
        cmp.w       #200,d0
{ war es wirklich ein AES-Aufruf ?}
        bne         @jmpold
        move.l      d1,aespb        
{ Adresse des  Parameterblocks kopieren}
        move.l      OldAdr,$88;
@jmpold:        
        move.l      OldAdr,a0       
{ alte Adresse anspringen}
        jmp         (a0)            
@ToEnd:        
        END;



BEGIN
    GetKeyPtr;
{ Vektoren kann man nur im Supervisor }
{ Mode verbiegen }  
    stptr:=SUPER(NIL);
    Install;          
    stptr:=SUPER(stptr);
END.
