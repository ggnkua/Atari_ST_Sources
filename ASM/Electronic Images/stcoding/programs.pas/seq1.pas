program sequence (input, output);

{ This program maintains a sequence of integers in ascending order. }

{ It uses a circular linked list, with the last node pointing back to
  a dummy node at the head of the list.  This representation simplifies
  the implementation of the operations to be performed on the sequence }

type

  link = ^seqrec;

  seqrec =
    record
      item : integer;
      next : link
    end;

  optype = (add, delete, print, quit);

procedure clearseq (var seqhead : link);
{ creates a new empty sequence ... a pointer to a dummy node, the dummy }
{ node pointing to itself }
begin
  new (seqhead);
  seqhead^.next := seqhead
end;

procedure searchseq (seqhead : link; newvalue : integer; var previous : link);
{ searches the sequence for where newvalue either is or would be in the
  sequence, and returns a pointer to the node BEFORE where it is or would be
  in the parameter 'previous' }
var
  current : link;
begin
  {put newvalue into the dummy node ... to ensure search terminates}
  seqhead^.item := newvalue;
  {search has previous pointing one node behind current}
  previous := seqhead;
  current := seqhead^.next;
  while current^.item < newvalue do
  begin
    previous := current;
    current := current^.next
  end
end;

procedure addtoseq (newvalue : integer; var seqhead : link);
{ inserts a node containing newvalue into the correct place in the
  sequence pointed to by seqhead ... to maintain the elements in
  ascending order. Calls searchseq to find where newvalue should go }
var
  current,temp : link; 
begin
  searchseq(seqhead,newvalue,current);
  new(temp);
  temp^.item := newvalue;
  temp^.next := current^.next;
  current^.next := temp
end;

procedure deletefromseq (notwanted : integer; var seqhead : link);
{ deletes the first node in the sequence containing the notwanted
  value ... if present. If the sequence is empty the procedure
  outputs an 'empty sequence' message, and if notwanted is not
  present it outputs a 'value not found' message ... and in both
  cases it returns the sequence unaltered }
var
  current,temp : link;
begin
  if seqhead^.next <> seqhead then
    begin
    searchseq(seqhead,notwanted,current);
    temp := current^.next;
    if (temp<>seqhead) and (temp^.item = notwanted) then
      current^.next := temp^.next
    else
      writeln('value not found');      
    end
  else
    writeln('empty sequence')
end;

procedure printseq (seqhead : link);
{ prints out all the elements in the sequence pointed to by seqhead }
var
  current : link;
begin
  current := seqhead^.next;
  while current <> seqhead do
  begin
    writeln (current^.item);
    current := current^.next
  end
end;

{#include '/usr/work/pascal/lib/rdstring.i'}

function getseqoperation : optype;
{ returns which operation is to be done on the sequence }
var
  s : string;
begin
  write ('Type add, delete, print, or quit: ');
  readln (s);
  {rdstring(s);}
  writeln(s);
  while (s <> 'add') and (s <> 'delete') and (s <> 'print') and (s <> 'quit') do
  begin
    writeln ('+++ Unable to do this operation on the sequence - try again');
    write ('+++ Type add, delete, print, or quit: ');
    readln (s)
    {rdstring(s)}
  end;
  if s = 'add' then
    getseqoperation := add
  else if s = 'delete' then
    getseqoperation := delete
  else if s = 'print' then
    getseqoperation := print
  else
    getseqoperation := quit
end;

procedure testseq;

{ This procedure is  a test-bed used to test the three sequence processing 
  procedures ... addtoseq, deletefromseq, and printseq }

var
  operation : optype;
  number : integer;
  sequence : link;

begin
  clearseq (sequence);
  repeat
    operation := getseqoperation;
    case operation of
      add     : begin
                  write ('Number to be added to the sequence? ');
                  readln (number);
                  addtoseq (number, sequence)
                end;
      delete  : begin
                  write ('Number to be deleted from the sequence? ');
                  readln (number);
                  deletefromseq (number, sequence)
                end;
      print   : begin
                  writeln ('Sequence contains .....');
                  printseq (sequence)
                end;
      quit    : {do nothing}
    end {of case}
  until operation = quit
end;

procedure preamble;
{ writes out a description of what the program does for the user }
begin
  writeln;
  writeln ('SEQUENCE TESTER');
  writeln ('---------------');
  writeln;
  writeln ('A SEQUENCE is a dynamic data structure which can hold zero');
  writeln ('or more data items placed in order according to some pre-defined');
  writeln ('relationship.');
  writeln;
  writeln ('This program maintains a sequence of integers stored in');
  writeln ('ascending order.  Operations which can be performed on this');
  writeln ('sequence are :');
  writeln;
  writeln ('    add      -  adds an integer to the sequence, maintaining');
  writeln ('                the elements of the sequence in ascending order');
  writeln;
  writeln ('    delete   -  deletes an integer from the sequence, if it exists');
  writeln;
  writeln ('    print    -  prints the elements of the sequence in ascending');
  writeln ('                order if add & delete implemented correctly');
  writeln;
  writeln ('    quit     -  quits the program');
  writeln;
  writeln
end;

begin
  preamble;
  testseq
end.
