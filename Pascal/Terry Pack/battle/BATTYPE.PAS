
   MFdb_fields = (addr1,addr2,wid_pix,ht_pix,wid_wds,flag,num_planes,r1,r2,r3);
   MFdb = array[MFdb_fields] of integer;
   Path_Chars=Packed Array[1..80] of Char;
   ScreenType = PACKED ARRAY [ 1..32000 ] of Byte;
   HeadType = Packed Array[0..63] of Integer;
   Neo_Type=packed record
             Head: HeadType;
             Pic: ScreenType
           End;
   S_Ptr = ^ScreenType;     { pointer to screen data }

