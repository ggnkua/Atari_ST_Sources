program linkedlist1 (input,output);

{ The program reads a series of integers into a linked list, storing each }
{ integer at the head of the list ... and then prints out the contents of }
{ the list...starting at the the head of the list . }

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

procedure addtolist (n : integer; var head : nodeptr);
{ adds n to the head of the linked list }
var
        temp : nodeptr;
begin
        new(temp);
        temp^.value := n;
        temp^.next := head;
        head := temp
end;

procedure printlist (head : nodeptr);
{Prints all the value fields from the linked list pointed to by head}
var
        current : nodeptr;
begin
        current :=head;
        while current <> nil do
        begin
                writeln(current^.value);
                current := current^.next;
        end;
end;


function reverse1(x : nodeptr) : nodeptr;
{ this function creates a new list whose
  nodes contain the same values as those
  in X - but in reverse order.  It
  returns a pointer to the start of the
  new list  }

var
        temp : nodeptr;
begin
        new(temp);
        while x <> nil do
        begin
                addtolist(x^.value,temp^.next);
                x := x^.next;
        end;
        reverse1 :=temp^.next;
end;
        
function reverse2(x : nodeptr) : nodeptr;
{ this function modifies all the pointers
  in the list X so that the nodes end up
  chained in the opposite direction! No
  new nodes are created. It returns a
  pointer to this reversed list }

var
        x1,x2 : nodeptr;
begin
        x1 := nil;
        while x <> nil do
        begin
                x2 := x^.next;
                x^.next :=x1;
                x1 := x;
                x  := x2;
        end;        
        reverse2 := x1;
end;

procedure testlinkedstuff;
{ tests the functions "reverse1" and "reverse2" with user input data}
var
        number : integer;
        list   : nodeptr;
begin
        createemptylist (list);
        while not eoln do
        begin
                readln(number);
                addtolist(number,list)
        end;
        writeln;
        writeln('The linked list contains nodes with the values:');
        printlist (list);
        writeln('The linked list is reversed with the function "reverse1":');
        list := reverse1(list);
        printlist (list);
        writeln('And reversed again with the function "reverse2":');
        list := reverse2(list);
        printlist (list);
end;

{main program}        

begin
        testlinkedstuff;
end.