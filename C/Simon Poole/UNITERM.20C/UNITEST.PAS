Program ShowParmBlock;
{Stupid program to show how to use the $VARBLOCK UniTerm variable} 

Type 
   {ParmBlock contains buffer addresses etc. to be passed on to other
    processes}
   ParmBlock = Record
                  PBLength       : Integer;
                  {Length of ParmBlock in bytes, handy as a version
                   check}
                  PBFlags        : Long_Integer; 
                  {Not used yet}
                  PBTextScreen   : Long_Integer; 
                  {Address of text screen}
                  PBGraphScreen  : Long_Integer; 
                  {Address of graph screen, same as PBTextScreen 
                   if not available}
                  PBScreenBuffer : Long_Integer; 
                  {Address of buffer for screen ops etc.}
                  PBTransBuffer  : Long_Integer; 
                  {Address of buffer used for the various file transfer
                   protocols}
                  PBTransSize    : Long_Integer;
                  {Size of the transfer buffer (in bytes)}
                  PBTransPtrAdr  : ^Long_Integer;
                  {Address of the pointer to the current
                   position in the buffer} 
                  PBHistBuffer   : Long_Integer;
                  {Address of the history buffer}
                  PBHistSize     : Long_Integer;
                  {Size of the history buffer}
                  PBHistBotAdr   : ^Long_Integer;
                  {Address of the pointer to the current bottom
                   of the history buffer}
                  PBHistPtrAdr   : ^Long_Integer;
                  {Address of the pointer to the current position
                   in the history buffer}
                  PBClipSize     : Long_Integer;
                  {Current max size of clipboard}
                  PBClipRecAdr   : ^ClipType;
                  {Pointer to clipboard record}
               End;

  {* Clip Type *}
  ClipBuffer = Packed Array[1..$400000] Of Char; {If anybody needs more...}
  ClipBufferPtr = ^ClipBuffer;
  ClipType = Packed Record
                Len : Long_Integer;
                Buffer : ClipBufferPtr;
             End;

Var ComLine : String;
    Block : Record {If you could only cast in Pascal...} 
               Case Boolean Of {Yuck!}
                  True : (Ptr : ^ParmBlock);
                  False : (Long : Long_Integer);
               End;
    Ch : Char;
    i : Integer;

Begin
   Cmd_Getarg(1,ComLine); 
   {Get first argument from commandline, DON'T DO IT LIKE THIS}
   If ComLine <> '' Then Begin
      ReadV(ComLine,Block.Long);
      {Check that it is a valid address < this applications
       basepage here!}
      WriteLn('Address of Parameter Block: ',Block.Long:8:h);
      {$P-,T-}
      With Block.Ptr^ Do Begin
         WriteLn('Length of parameter block:      ',PBLength:4);
         {In a real application check that PBLength is >= what
          you expect}
         WriteLn('Flags:                      ',PBFlags:8:h); 
         WriteLn('Text screen address:        ',PBTextScreen:8:h); 
         WriteLn('Graphics screen adr:        ',PBGraphScreen:8:h); 
         WriteLn('Screen buffer adr:          ',PBScreenBuffer:8:h); 
         WriteLn('Transfer buffer adr:        ',PBTransBuffer :8:h); 
         WriteLn('Transfer buffer size:       ',PBTransSize:8:h);
         WriteLn('Current position:           ',PBTransPtrAdr^:8:h);
         WriteLn('History buffer adr:         ',PBHistBuffer:8:h);
         WriteLn('History buffer size:        ',PBHistSize:8:h);
         WriteLn('Current history bottom:     ',PBHistBotAdr^:8:h);
         WriteLn('Current hist. position:     ',PBHistPtrAdr^:8:h);
         WriteLn('Current max. clipboard size:',PBClipSize:8:h);
         WriteLn('Current size of clipboard contents:');
         WriteLn('                            ',PBClipRecAdr^.Len:8:h);
         WriteLn('Current clipboard contents:');
         With PBClipRecAdr^ Do  
            For i := 1 To Len Do 
               If Buffer^[i] = Chr(13){CR} Then WriteLn
               Else Write(Buffer^[i])    
      End
      {$P=,T=}
   End;
   Write('Press any key to continue...');
   Read(Ch);
End.
