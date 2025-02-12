program linkedlist1(input,output);

type
        nodeptr = ^node;
        node =
        record
                value : integer;
                next  : nodeptr;
        end;

procedure createemptylist (var head : nodeptr);
{ creates an empty list i.e. one with no nodes }
begin
        head := nil;
end;

procedure addtolist (n : mesgptr; var head : nodeptr);
{ adds n to the head of the linked list }
var
        temp : nodeptr;
begin
        new(temp);
        temp^.value := mesgptr;
        temp^.next := head;
        head := temp
end;

procedure deletefromlist (var head : nodeptr);
{ to the head of the linked list }
var
        temp : nodeptr;
begin
	temp = head;
        head := head^.next
        dispose(temp);
end;

function count(var head : nodeptr):integer;
var
	temp     : nodeptr;
	counttmp : integer; 
begin
	current := head;
	counttmp := 0;
	while current <> nil d0
	begin
		counttmp := counttmp +1;
                current := current^.next;
	end;
	count := counttmp; 
end;

procedure testlinkedstuff;
var
        number : integer;
        list   : nodeptr;
begin
        createemptylist (list);
end;

{main program}        

begin
        testlinkedstuff;
end.