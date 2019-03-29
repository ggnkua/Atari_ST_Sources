     Gem_Window = Record
                    RL_Button   : short_integer;
                    Up_Down     : short_integer;
                    B_Clicks    : short_integer;
                    Key_Input   : short_integer;
                    B_Count     : short_integer;
                    B_State     : short_integer;
                    X_Mouse     : short_integer;
                    Y_Mouse     : short_integer;
                    Key_State   : short_integer;
                    HiByte      : short_integer;
                    LoByte      : short_integer;
                    Character   : char;
                    Timing      : Long_Integer;
                    msg         : Message_Buffer;
                  end;

     Gem_Menu = record
                  Title : array[1..4]  of short_integer;
                  Item  : array[1..16] of short_integer;
                end;

     DiskRec = record
                 FreeCluster : long_integer;
                 NoCluster   : long_integer;
                 SectorSize  : long_integer;
                 ClusterSize : long_integer;
               end;

     WordPointer = ^WordRecord ;
     WordRecord  = record
                    NewWord : string[96] ;
                    Level,
                    PtLabel : short_integer ;
                    Next,
                    Prev    : WordPointer ;
                    Buffer  : boolean ;
                   end ;

