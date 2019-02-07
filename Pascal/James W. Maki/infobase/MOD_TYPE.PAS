{InfoBaseST by James W. Maki (c) Copyright 1990 by Antic Publishing, Inc.}
{
                 *****    Miscellaneous Data Types    *****
}
    Str50 = String[50] ;
    Str20 = String[20] ;
    StrChar = String[1] ;
{
***************************************************************************
*                 -------------                                           *
*  Data Store -- | D3 | Data                                              *
*                 -------------                                           *
***************************************************************************

	     All data is stored in the record DataStore.  Pointers to the
	first DataStore record are stored in the DataInfo record.  
	DataInfo^.Data points to the first DataStore record and 
	additional DataStore records are pointed to by DataStore^.Next.

	     DataInfo^.Next and Prev are list pointers.  OrderMore and 
	OrderLess are used by sort routines to organize the records in a
	particular order using a binary sort.

                    *****    D3 | DATA DICTIONARY    *****
}
    DataStorePtr = ^DataStore ;
    DataStore    = record
                    DataStr : Str50 ;
                    Next    : DataStorePtr ;
                   end ;

    DataPtr = ^DataInfo ;
    DataInfo = record
                Next,
                Prev,
                OrderMore,
                OrderLess : DataPtr ;
                Data      : DataStorePtr ;
              end ;

{
****************************************************************************
*                 ------------------                                       *
*  Data Store -- | D1 | Design Specs                                       *
*                 ------------------                                       *
****************************************************************************

             Screen Design Data Store.  The X and Y variable would 
        be the x and y coordinants, window relative, of the 
        label. XPos and YPos are the x and y coordinants of the Data Input 
        Area. XInPos is the variable X coordinant for data base input.
        Offset and Size refer to the location and the size of the data
        string stored in the DataInfo record.  LabelStr is the Label 
        displayed on the screen as well as the field name used in search
        procedures.

             Next and Prev are pointers to the Next and Prev ScrInfo 
        records.

             DataType is a code indicating the way the data should be 
        treated.  The type of data are :
        
                   A : String
                   B : Boolean : CheckMark Toggle Switch/Length 1
                   C : Integer
                   D : Long_Integer
                   E : Real
                   F : Dollar
                   G : Date
                   H : Name

                    *****    D1 | DATA DICTIONARY    ***** 
}
    ScrPtr = ^ScrInfo ;
    ScrInfo = record
                LabelStr   : Str20 ;
                DataType   : char ;
                X, Y,
                XInPos,
                XPos, 
                YPos,
                Offset,
                Size       : short_integer ;
                Next,
                Prev       : ScrPtr ;
              end ;

   IntPtr = ^IntStore ;
   IntStore = record
                Match : short_integer ;
                Next,
                Prev  : IntPtr ;
              end ;

{
****************************************************************************
*                 -------------------                                      *
*  Data Store -- | D2 | Screen Design                                      *
*                 -------------------                                      *
****************************************************************************

          Menu Design variables
}
    GemMenu = record
                Title : array[1..5]  of short_integer ;
                Item  : array[1..25] of short_integer ;
              end ;
