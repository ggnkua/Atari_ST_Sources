program sequence (input, output);

{ This program maintains a sequence of integers in ascending order. }

{ It uses simple linked lists & recursion to simplify their management }

type

  link = ^seqrec;

  seqrec =
    record
      item : integer;
      next : link
    end;

optype = (add, delete, print, revprint, inseq, quit);

procedure clearseq (var head : link);

{ creates an empty list i.e. one with no nodes }
begin
  head := nil
end;

procedure addtoseq (n : integer; var head : link);

{ adds n to its correct position in the linked list - to maintain the
  elements in ascending order }
var
  temp : link;
begin
  if head = nil then  {add to an empty list}
  begin
    new (head);
    head^.item := n;
    head^.next := nil
  end
  else if head^.item > n then   {add at start of the list}
  begin
    new (temp);
    temp^.item := n;
    temp^.next := head;
    head := temp
  end
  else
    addtoseq (n, head^.next)
end;

procedure deletefromseq (n:integer; var head : link);
var
  p : link;
begin
  if head = nil then
    writeln (n, ' is not in the list or the list is empty')
  else
    if head^.item = n then
    begin
      p := head;
      head := head^.next;
      dispose (p)
    end
    else
      deletefromseq (n, head^.next)
end;

procedure printseq (head : link);
{prints all the item fields from the linked list pointed to by head}
begin
  if head <> nil then
  begin
    writeln (head^.item);
    printseq (head^.next)
  end
end;

procedure revprintseq (head : link);
{prints all the item fields from the linked list pointed to by head}
{in reverse order}
begin
  if head <> nil then 
  begin
    revprintseq (head^.next);
    writeln(head^.item);   
  end
end;

function isinseq (n : integer; X : link) : boolean;
{ this function scans the list pointed at
  by X and returns whether the number n is
  in one of the nodes }
begin
  if X <> nil then
  begin
    if X^.item <> n then
      isinseq := isinseq(n,X^.next)
    else
      isinseq := true;
  end
end;

{#include '/usr/work/pascal/lib/rdstring.i'}

function getseqoperation : optype;
{ returns which operation is to be done on the sequence }
var
  s : string;
begin
  write ('Type add, delete, print, revprint, inseq or quit: ');
  readln(s);
{ rdstring (s);}
  while (s<>'add') and (s<>'delete') and (s<>'print') and (s<>'revprint') and (s<>'inseq') and (s<>'quit') do
  begin
    writeln ('+++ Unable to do this operation on the sequence - try again');
    write ('+++ Type add, delete, print, revprint, inseq or quit: ');
    readln(s)
{   rdstring (s)}
  end;
  if s = 'add' then
    getseqoperation := add
  else if s = 'delete' then
    getseqoperation := delete
  else if s = 'print' then
    getseqoperation := print
  else if s = 'revprint' then
    getseqoperation := revprint
  else if s = 'inseq' then
    getseqoperation := inseq
  else
    getseqoperation := quit
end;

procedure testseq;

{ This procedure is  a test-bed used to test the three sequence processing 
  procedures ... addtoseq, deletefromseq, revprintseq and printseq }

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
      revprint: begin
                  writeln ('Sequence(reversed) contains .....');
                  revprintseq (sequence)
                end;
      inseq:    begin
                  write ('Number to search for in sequence? ');
                  readln (number);
                  if isinseq(number,sequence) then
                    writeln('Value is in Sequence')
                  else
                    writeln('Value not in Sequence')
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
  writeln ('    revprint -  prints the elements of the sequence in descending');
  writeln ('                order if add & delete implemented correctly');
  writeln;
  writeln ('    print    -  prints the elements of the sequence in ascending');
  writeln ('                order if add & delete implemented correctly');
  writeln;
  writeln ('    inseq    -  searches for an integer in the sequence, and returns');
  writeln ('                whether or not the number is in the sequence');
  writeln;
  writeln ('    quit     -  quits the program');
  writeln;
  writeln
end;

begin
  preamble;
  testseq
end.
