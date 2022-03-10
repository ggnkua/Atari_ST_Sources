

{IncludeFrom=general_2 <p2c/general_2.h>}


{*VarStrings=0} {*ExportSymbol=P_%s} {*Export_Symbol=%s}


MODULE GENERAL_2;
IMPORT    iodeclarations;  

EXPORT

   PROCEDURE readnumber ( device : type_device ; VAR num: REAL ) ;
   PROCEDURE writenumber ( device : type_device ; value  : REAL ) ;
   PROCEDURE readstring ( device : type_device ; VAR str: STRING ) ;
   PROCEDURE readstring_until ( term   : CHAR ; device : type_device ;
                                VAR str: STRING );
   PROCEDURE writestring ( device : type_device ; str    : io_STRING ) ;
   PROCEDURE readnumberln ( device : type_device ; VAR num: REAL );
   PROCEDURE writenumberln ( device : type_device ; value  : REAL );
   PROCEDURE writestringln ( device : type_device ; str    : io_STRING );
   PROCEDURE readuntil  ( term   : CHAR ; device : type_device );
   PROCEDURE skipfor    ( count  : INTEGER ; device : type_device );
END.

