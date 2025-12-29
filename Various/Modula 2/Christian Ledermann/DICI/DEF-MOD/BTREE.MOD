 IMPLEMENTATION MODULE BTree;
(* FROM InOut IMPORT WriteString, WriteInt, WriteLn, WriteCard;
 FROM NumIO IMPORT WriteLong; *)
 FROM SYSTEM IMPORT TSIZE;
 IMPORT GEMDOS,FileSystem;

VAR    Tree : PagePtr; 
(* Globale Variable um festzustellen ob ich irgendeinen Eintrag *)
(* In meiner Datei habe *)



PROCEDURE Get( VAR File : FileOf; Pos : LONGINT);
VAR Position : LONGINT;
BEGIN
   IF Pos <= File.Last THEN
       IF Pos >= 0D THEN
	    Position := Pos * File.RecordSize;
	    GEMDOS.Seek(Position,File.Handle,GEMDOS.beginning,Position);
	    GEMDOS.Read(File.Handle,File.RecordSize,File.RecordPtr);
	    File.Current := Pos;
	ELSE (*HALT*);    
	END(*IF*);    
   ELSE
     (*HALT*);
   END(*IF*); 
END Get;

PROCEDURE Put(VAR File : FileOf; Pos : LONGINT);
VAR   Position : LONGINT;
BEGIN
  IF Pos <= File.Last+1D  THEN
     IF Pos >= 0D THEN
         Position := Pos * File.RecordSize;
         GEMDOS.Seek(Position,File.Handle,GEMDOS.beginning,Position);
         GEMDOS.Write(File.Handle,File.RecordSize,File.RecordPtr);
         File.Current := Pos;
     ELSE (*HALT*);    
     END(*IF*);    
  ELSE
    (*HALT*);
  END(*IF*);  
END Put;

PROCEDURE FileLength(FileName : ARRAY OF CHAR; VAR length : LONGINT) :BOOLEAN;
VAR f : FileSystem.File;

BEGIN
    FileSystem.Lookup(f,FileName,FALSE);
    FileSystem.Length(f,length);
    IF f.errorno # 0 THEN RETURN FALSE END(*IF*);
    RETURN length > 0D;
END FileLength;

PROCEDURE Create(VAR File : FileOf);
VAR f : FileSystem.File;

BEGIN
    FileSystem.Lookup(f, File.Name, TRUE);
    FileSystem.Close(f);
END Create;

PROCEDURE Start(VAR File : FileOf);
VAR Length : LONGINT;

BEGIN
   File.Last:=-1D;
   IF FileLength(File.Name,Length) THEN
      File.Last:= Length DIV File.RecordSize -1D;
   END(*IF*);
   GEMDOS.Open(File.Name,2,File.Handle);
   IF (File.Last = Empty) THEN
      Tree := Empty;
   ELSE
      Tree:= TreeRoot;
   END(*IF*);
   File.Current := Tree;
END Start;

PROCEDURE Close(VAR File : FileOf);
VAR OK : BOOLEAN;
BEGIN
   OK:=GEMDOS.Close(File.Handle);
   IF ~OK THEN (*HALT*); END(*IF*);
   Tree := Empty;
   File.Current := Tree;
END Close;

PROCEDURE PutData(VAR DataBase : FileOf; Data : DataType;  Reference : DataPtr);
BEGIN
    Get(DataBase,Reference);
    DataBase.RecordPtr^.Flag := TRUE;
    DataBase.RecordPtr^.Data := Data;
    Put(DataBase,Reference);
END PutData;

PROCEDURE GetData(VAR DataBase : FileOf; VAR Data : DataType; VAR Keys : KeyArray; Reference :DataPtr);
BEGIN
   Get(DataBase,Reference);
   Data := DataBase.RecordPtr^.Data;
   Keys := DataBase.RecordPtr^.Key;
END GetData;

PROCEDURE AddData( VAR DataBase : FileOf; NewData : DataType) : DataPtr;
BEGIN
    DataBase.Last := DataBase.Last +1D;
    DataBase.RecordPtr^.Data := NewData;
    Put ( DataBase, DataBase.Last);
    RETURN DataBase.Last;
END AddData;

PROCEDURE AddKey(VAR Index, DataBase : FileOf; NewKey : KeyType; Reference : DataPtr): BOOLEAN;

VAR h : BOOLEAN;
    u : ItemType;
    PROCEDURE search( x : KeyType;
		      a : PagePtr;
		 VAR  h : BOOLEAN;
		 VAR  v : ItemType): BOOLEAN;
(* Suche SchlÅssel x im B-Baum mit Wurzel a; falls nicht vorhanden fÅge 
 ein Element mit SchlÅssel x in den Baum ein. Ein Element, das auf eine
 tiefere Stufe zu bingen ist, ist v zuzuweisen; h := Baum ist gewachsen *)
 		 

	VAR k, l, r : INTEGER;
	    u : ItemType;




	    PROCEDURE insert;

	    VAR i : INTEGER;
		b : PageType;

	    BEGIN (* insert *)
	      Get(Index , a); (* fÅge u rechts von Index^.Item[r] ein *)
	      WITH Index.RecordPtr1^ DO
		 IF Anz < nn THEN
		    (*INC(Anz,1);*)
		    Anz := Anz +1;
		    h:= FALSE;
		    FOR i := Anz TO r+2 BY -1 DO
			Item[i]:= Item[i-1];
		    END(*FOR*);
		    Item[r+1] := u;
		    Put (Index,a);
		 ELSE (* SeitenÅberlauf! Teile Seite auf
		       und weise v das herausfallende Element zu *)
		 IF r<=n THEN
		       IF r=n THEN
			  v:=u
		       ELSE
			 v:=Item[n];
			 FOR i:= n TO r+2 BY -1 DO
			    Item[i]:=Item[i-1];
			 END(*FOR*);
			 Item[r+1] :=u;
			END;
		     FOR i:= 1 TO n DO
			b.Item[i]:=Item[i+n];
		     END(*FOR*);
		 ELSE (* fÅge u in die rechte Seite ein *)
		    r:= r-n;
		    v:= Item[n+1];
		    FOR i := 1 TO r-1 DO
			b.Item[i]:=Item[i+n+1];
		    END(*FOR*);
		    b.Item[r]:=u;
		    FOR i:=r+1 TO n DO
			b.Item[i]:=Item[i+n];
		    END(*FOR*);
		 END;
		 Anz := n;
		 Put (Index,a);
		 b.Anz:=n;
		 b.Ptr0:= v.Ptr;
		 Index.RecordPtr1^:=b;
		 Index.RecordPtr1^.Flag:= TRUE;
		 Index.Last:=Index.Last+1D;
		 (*INC(Index.Last,1);*)
		 Put( Index, Index.Last);
		 v.Ptr:=Index.Last;
	       END(*IF*);
	      END;(*with*)
	    END insert;

	BEGIN (* search *)
	(* suche SchlÅssel x auf Seite a; NOT h *)
	
	  IF a = Empty THEN (* rekursive Abruchbedingung *)
	                    (* Element mit SchlÅssel x ist nicht im Baum *)
	    h:= TRUE; (* -> auf hîherer Seite einfÅgen! *)
	    WITH v DO
	      Key:=x;
	      Ptr := Empty;
	      RecordNr:= DataBase.Last
	    END;(*with*)
	  ELSE
	     Get(Index,a);
	     WITH Index.RecordPtr1^ DO
	       l:=1; (* BinÑre Suche auf der Seite *)
	       r:= Anz;
	       REPEAT
		 k:=(l+r) DIV 2;
		 IF x <= Item[k].Key THEN
		    r:= k-1;
		 END(*IF*);
		 IF x >=Item[k].Key THEN
		    l:= k+1;
		 END(*IF*);
	       UNTIL r < l;
	       IF (l-r >1) THEN  (* Element gefunden ! *)
				 (* -> kein énderung am B-Baum *)
				 (* Neues Element in die NachfolgerListe  *)
		    IF Index.MultipleKeys THEN		 
		    (* Das letzte eingefÅgte Element ist das erste in der Nachfolgerliste *)
		    (* Dies ist so um mîglichst wenig Plattenzugriffe zu haben *)
	                  Get(DataBase,Item[k].RecordNr);
	                  DataBase.RecordPtr^.Prev[Index.Type] := Reference;
	                  Put(DataBase,Item[k].RecordNr);
			  Get(DataBase,Reference);
			  DataBase.RecordPtr^.Next[Index.Type] := Item[k].RecordNr;
			  Put(DataBase,Reference);
			  Item[k].RecordNr := Reference;
			  Put(Index,a);
			  h:= FALSE;
		     ELSE
		        (*HALT*); (* Eintrag gefunden obwohl doppelte SchlÅssel nicht erlaubt sind *)
		        RETURN FALSE
		     END(*IF*);	  
	       ELSE
		 IF r=0 THEN (* Element nicht gefunden *)
			      (* -> Suche geht rekursiv weiter *)
		   IF  ~search(x,Ptr0,h,u) THEN
		       RETURN FALSE
		   END(*IF*);
		 ELSE
		    IF ~search(x,Item[r].Ptr,h,u) THEN 
		        RETURN FALSE
		    END(*IF*);    
		 END(*IF*);
		 IF h THEN (* Element einfÅgen *)
		    insert;
		 END(*IF*);
	       END(*if*);
	     END; (*with*)
	   END; (*if*)
	 RETURN TRUE  
	 END search;

BEGIN (*insert data*)
    Get(DataBase,Reference);
    WITH DataBase.RecordPtr^ DO (* DatenPuffer initialisieren  *)
       Flag := TRUE;
       IF Index.MultipleKeys THEN
	       Next[Index.Type] := Empty;
	       Prev[Index.Type] := Empty;
       END(*IF*);       
       Key[Index.Type] := NewKey;
    END; (*with*)
    Put(DataBase, Reference);
    IF Index.Last=Empty THEN
       Tree := Empty;
    END(*IF*);   
    IF search( NewKey, Tree, h, u) THEN
	    IF h THEN (* Nach dem Aufruf von search kann sich noch ein Element *)
		      (* in v befinden. Dieses Element wird dann zur Wurzel des *)
		      (* Baumes *)
		IF Index.Last # Empty THEN
		   Get(Index,0D);
		END(*IF*);
		Index.RecordPtr1^.Flag := TRUE;
		Index.Last:= Index.Last+1D;
		(*INC(Index.Last,1);*)
		Put (Index, Index.Last);
		Tree:= TreeRoot;
		WITH Index.RecordPtr1^ DO
		   Anz:=1;
		   IF Index.Last =0D THEN
		      Ptr0:=-1D;
		   ELSE
		      Ptr0 := Index.Last;
		   END(*IF*);
		   Item[1]:=u;
		END;(*with*)
		Put(Index,TreeRoot);(* Wurzel befindet sich immer an Position 0 *)
				    (* der Datei ! *)
	    END; (*if*)
	    RETURN TRUE
    ELSE
        (*HALT*);
    	RETURN FALSE
    END(*IF*);    
END AddKey;

PROCEDURE Delete(VAR Index, DataBase : FileOf; Key : KeyType; VAR DataPointer : DataPtr): BOOLEAN;
(* Suche und Lîsche SchlÅssel Key im B-Baum; tritt Unterlauf ein so gleiche
  falls mîglich mit benachbarter Seite aus, sonst lege mit ihr zusammen;
  h:= 'Seite ist nicht voll genug ', d.h. m<n *)

VAR DelList : DataPtr;
	   q : PagePtr;
	   h, DoDeleteData : BOOLEAN;

  PROCEDURE search (   x : KeyType;
		       a : PagePtr;
		   VAR h : BOOLEAN);

    VAR q : PagePtr;
	i,
	k,
	l,
	r: (*INTEGER;*) CARDINAL;
        Next, Previous : DataPtr;
   PROCEDURE underflow( c,
			a : PagePtr;
			s : CARDINAL;
		    VAR h : BOOLEAN);

(* a = Seite mit Unterlauf, c = VorgÑngerseite *)
   VAR b : PagePtr;
       i,
       k,
       mb,
       mc : CARDINAL;
       ic,
       ia : PageType;

       BEGIN (* underflow *)
		Get(Index,c);
		ic:= Index.RecordPtr1^;
		Get (Index,a);
		ia := Index.RecordPtr1^;
		mc := ic.Anz;  
		IF s<mc THEN  (* b := rechts von a *)
		  s:= s+1;
		  (*INC(s,1);*)
		  b:=ic.Item[s].Ptr;
		  Get (Index,b);
		  mb := Index.RecordPtr1^.Anz;
		  k:=(mb-n+1)  DIV 2;
		  ia.Item[n]:=ic.Item[s];
		  ia.Item[n].Ptr :=Index.RecordPtr1^.Ptr0;
		  IF k>0 THEN (* bringe k Elemente von b nach a *)
		  (* Ausgleich zwischen den Seiten *)
		     FOR i := 1 TO k-1 DO
			 ia.Item[i+n]:= Index.RecordPtr1^.Item[i];
		     END(*FOR*);
		     ic.Item[s]:=Index.RecordPtr1^.Item[k];
		     ic.Item[s].Ptr := b;
		     Index.RecordPtr1^.Ptr0:= Index.RecordPtr1^.Item[k].Ptr;
		     mb := mb-k;
		     FOR i:=1 TO mb DO
			 Index.RecordPtr1^.Item[i]:= Index.RecordPtr1^.Item[i+k];
		     END(*FOR*);
		     Index.RecordPtr1^.Anz := mb;
		     ia.Anz := n-1+k;
		     h:= FALSE;
		  ELSE (* mische Seiten a und b *)
		  (*Seiten werden zu einer Seite zusammengefasst *)
		     FOR i:= 1 TO n DO
			ia.Item[i+n] := Index.RecordPtr1^.Item[i];
		     END(*FOR*);
		     FOR i:= s TO (mc-1) DO
			 ic.Item[i]:= ic.Item[i+1];
		     END(*FOR*);
		     ia.Anz := nn;
		     ic.Anz := mc-1;
		     h:= mc<=n;
		     Index.RecordPtr1^.Flag:= FALSE;
		  END (*if*)
		ELSE (* b:= Seite links von a *)
		  IF s=1 THEN
		     b:=ic.Ptr0
		  ELSE
		    b:= ic.Item[s-1].Ptr;
		  END(*IF*);
		  Get(Index,b);
		  mb := Index.RecordPtr1^.Anz+1;
		  k:=(mb-n) DIV 2;
		  IF k>0 THEN (* bringe k Elemente von b nach a *)
		  (* Ausgleich zwischen denSeiten *)
		    FOR i := n-1 TO 1 BY -1 DO
		       ia.Item[i+k]:=ia.Item[i];
		    END(*FOR*);
		    ia.Item[k]:=ic.Item[s];
		    ia.Item[k].Ptr := ia.Ptr0;
		    mb:=mb-k;
		    FOR i := k-1 TO 1 BY -1 DO
			ia.Item[i] := Index.RecordPtr1^.Item[i+mb];
		    END(*FOR*);
		    ia.Ptr0 := Index.RecordPtr1^.Item[mb].Ptr;
		    ic.Item[s]:= Index.RecordPtr1^.Item[mb];
		    ic.Item[s].Ptr := a;
		    Index.RecordPtr1^.Anz:=mb-1;
		    ia.Anz:= n-1 +k;
		    h := FALSE;
		  ELSE (* mische Seiten a und b *)
		  (* Seiten werden zusammngefasst *)
		      Index.RecordPtr1^.Item[mb]:=ic.Item[s];
		      Index.RecordPtr1^.Item[mb].Ptr:= ia.Ptr0;
		      FOR i:=1 TO n-1 DO
			  Index.RecordPtr1^.Item[i+mb]:=ia.Item[i];
		      END(*FOR*);
		      Index.RecordPtr1^.Anz := nn;
		      ic.Anz := mc-1;
		      h:=mc<=n;
		      ia.Flag:= FALSE;
		  END; (*if*)
		END; (*if*)
		Put(Index,b);
		Index.RecordPtr1^:=ia;
		Put(Index,a);
		Index.RecordPtr1^:=ic;
		Put(Index,c);
	END underflow;

	PROCEDURE del( p : PagePtr;
		   VAR h : BOOLEAN );

	VAR q : PagePtr;
	   ip : PageType;
        
	BEGIN (*del*)
	   Get (Index,p);
	   ip := Index.RecordPtr1^;
	   WITH ip DO
	       q:=Item[Anz].Ptr;
	       IF q # Empty THEN
		   del(q,h);
		   IF h THEN
		      underflow(p,q,Anz,h);
		   END(*IF*);
		ELSE
		   (* k- ter Eintrag des Elements a durch den letzten Eintrag *)
		   (* der ermittelten Blattseite p ersetzen *)
		   Get(Index,a);
		   Item[Anz].Ptr:=Index.RecordPtr1^.Item[k].Ptr;
		   Index.RecordPtr1^.Item[k]:=Item[Anz];
		   Anz:=Anz-1;
		   h:= Anz<n;
		   Put(Index,a);
		   Index.RecordPtr1^:= ip;
		   Put (Index,p);
		END; (*if*)
	   END; (*with*)
	 END del;

	 BEGIN (* search *)
	     IF a=Empty THEN (* Element nicht gefunden ->  Fertig ! *)
		h:= FALSE;
		DelList:= Empty;
		DoDeleteData := FALSE;
	     ELSE
		Get (Index,a);
		WITH Index.RecordPtr1^ DO
		   l:=1;
		   r:= Anz;
		   REPEAT
		      k:=(l+r) DIV 2;
		      IF x <= Item[k].Key THEN
			  r:= k-1;
		      END(*IF*);
		      IF x >= Item[k].Key THEN
			 l:= k+1;
		      END(*IF*);
		    UNTIL r<l;
		    IF r=0 THEN
		      q:= Ptr0
		    ELSE
		      q:= Item[r].Ptr;
		    END(*IF*);
		    IF l-r>1 THEN (* Eintrag gefunden *)
		       DelList:= Item[k].RecordNr;
		       IF Index.MultipleKeys THEN
		         LOOP (* Achtung falls fÅr die Variable DataPointer Unsinn öbergeben wurde passiert hier auch Unsinn *)
		            IF  DelList # DataPointer THEN (* Der zu lîschende Record stimmt nicht mit dem gefundenen Åberein *)
		                Get(DataBase,DelList);
		                DelList := DataBase.RecordPtr^.Next[Index.Type];
		             ELSE (* Ich hab den gesuchten Record gefunden *)
		                Get(DataBase,DelList);(* Den Record zwecks VerÑnderung laden *)
		                IF DataBase.RecordPtr^.Prev[Index.Type] # Empty THEN 
		                     (* Der Record hat einen VorgÑnger, muû also 
		                      nur aus der Verkettung der DatensÑtzte 
		                      untereinander gelîst werden *)
		                      Next := DataBase.RecordPtr^.Next[Index.Type];
		                      Previous := DataBase.RecordPtr^.Prev[Index.Type];
		                      Get(DataBase,Previous);
		                      DataBase.RecordPtr^.Next[Index.Type] := Next;
		                      Put(DataBase,Previous);
		                      IF Next # Empty THEN 
		                        (* Den NÑchsten Record an den (jetzt aktuellen) anfÅgen *)
		                        Get(DataBase,Next);
		                        DataBase.RecordPtr^.Prev[Index.Type] := Previous;
		                        Put(DataBase,Next)
		                      END(*IF*);  
		                   END(*IF*);
		                EXIT;
		             END(*IF*);      
		             IF DelList = Empty THEN
		                (*HALT*); (* Alle Nachfolger wurden durchlaufen aber kein Eintrag gefunden der den Spezifikationen entspricht *)
		                      (* Bedingung hierfÅr siehe Anfang des LOOPs *)
		                EXIT;
		             END(*IF*);
		          END(*LOOP*);
		          
		          IF DataPointer = Item[k].RecordNr THEN (* Der Erste Eintrag unter diesem SchlÅssel war auch der Gesuchte *)
		             Get(DataBase,Item[k].RecordNr);
		             IF DataBase.RecordPtr^.Next[Index.Type] # Empty THEN (* und er hat auch einen Nachfolger *)
          		             Item[k].RecordNr :=DataBase.RecordPtr^.Next[Index.Type]; (* Nur den Zeiger von diesem Eintrag auf den nÑchsten umbiegen *)
	        	             Put(Index,a);
	        	             Get(DataBase,Item[k].RecordNr);(* Verweiû auf den jetzt gelîschten VorgÑnger entfernen *)
	        	             DataBase.RecordPtr^.Prev[Index.Type] := Empty;
	        	             Put(DataBase,Item[k].RecordNr);
	        	             h:= FALSE;
	        	             RETURN
	        	     END(*IF*);    
	        	  ELSE (* Der erste Eintrag unter diesem SchlÅssel war nicht unser gesuchter *)
	        	      (* (Die Verkettung der DatensÑtze untereinander haben wir schon im LOOP geÑndert) *)
	        	      h := FALSE;
	        	      RETURN
	        	  END(*IF*);        
		        END(*IF*);  
		      IF q = Empty THEN (* AusfÅgen aus einer Blatt-seite *)
			  Anz := Anz -1;
			  h:= Anz < n;
			  FOR i:= k TO Anz DO
			      Item[i]:= Item[i+1];
			   END(*FOR*);
			   Put (Index,a);
		       ELSE
			  del(q,h);
			  IF h THEN
			     underflow(a,q,r,h);
			  END(*IF*);
		       END; (*if*)
		    ELSE
		       search(x,q,h);
		       IF h THEN
			  underflow(a,q,r,h);
		       END(*IF*);
		    END; (*if*)
		END(*WITH*);
	     END(*IF*);
	   END search;

 BEGIN (* delete_data *)
    IF Tree # Empty THEN
       DoDeleteData:= TRUE;
       search(Key,Tree,h);
       IF h THEN
	  Get (Index,Tree);
	  IF Index.RecordPtr1^.Anz =0 THEN
	       IF Index.RecordPtr1^.Ptr0 = Empty THEN
	       (* Baum ist vîllig entleert *)
		  Tree := Empty;
		  Index.RecordPtr1^.Flag := FALSE;
		  Put(Index,TreeRoot);
		ELSE
		(* Bei einem linken Nachfolger wird dieser zur Wurzelseite *)
		(* q und Tree werden physikalisch ausgetauscht ! *)
		   q:= Index.RecordPtr1^.Ptr0;
		   Get(Index,q);
		   Put(Index,Tree);
		   Index.RecordPtr1^.Flag:= FALSE;
		   Put(Index,q);
		END; (*if*)
	   END(*IF*);
	 END;(*if h *)
	 DataPointer := DelList;
	 IF DelList # Empty THEN
	 (* Dateiseiten des gelîschten SchlÅssels aus Datenbank entfernen*)
	     Get(DataBase,DelList);
	     DataBase.RecordPtr^.Flag:=FALSE;
	     Put(DataBase,DelList);
	   (* DelList:= DataBase.RecordPtr^.Next[Index.Type]; END; (*while*) *)
	  ELSE
	     RETURN FALSE (* Der Zeiger ist leer *)
	  END(*IF*);
    END; (*if*)
    RETURN DoDeleteData
END Delete;


PROCEDURE SearchPtr(VAR Index, DataBase : FileOf; Page : PagePtr; Key : KeyType; VAR found : BOOLEAN) : DataPtr;
(* sucht die Random-Acess-Adresse eines durch Key bezeichneten Datenbankeintrags *)
	VAR q	       : PagePtr;
	    l, r, k    : CARDINAL;
	    SearchPtr0 : DataPtr;

BEGIN (* seach_ptr*)
   IF Tree = Empty THEN
       found := FALSE; (* Die Datei ist leer, es gibt nichts was man finden kînnte *)
       RETURN Empty;
   END(*IF*);    
   IF Page = Empty THEN
      found := FALSE;(* Auf einer leeren Seite kann man nichts finden *)
      RETURN Empty;
   ELSE
      Get(Index,Page);
      WITH Index.RecordPtr1^ DO
	 l:=1;
	 r:= Anz;
	 REPEAT
	    k := (l+r) DIV 2;
	    IF Key <= Item[k].Key THEN
	       r := k-1;
	    END(*IF*);
	    IF Key >= Item[k].Key THEN
	      l:= k+1;
	    END(*IF*);
	 UNTIL r<l;
	 IF r=0 THEN
	    q:= Ptr0
	 ELSE
	    q:=Item[r].Ptr;
	 END(*IF*);
	 IF (l-r)>1 THEN
	    found := TRUE;
	    RETURN Item[k].RecordNr
	 ELSE
	    SearchPtr0:= SearchPtr(Index,DataBase,q,Key,found);
	    IF SearchPtr0 = Empty THEN
	      IF r=0 THEN
	         SearchPtr0:= Item[1].RecordNr; 
	         (* Das ist zwar nicht ganz korrekt        *)
	         (* (Der nÑchst grîûere Eintrag steht      *)
	         (* wahrscheinlich auf einer hîheren Seite) *)
	         (* aber so spar ich mir etwas Arbeit      *)
	      ELSE
	         SearchPtr0:= Item[r].RecordNr;
	         (* NÑchst grîûerer Eintrag *)
	      END(*IF*);
	      found := FALSE;
	    END(*IF*);        
	    RETURN SearchPtr0
	 END(*IF*);
     END; (* with*)
   END; (*if*)
END SearchPtr;



PROCEDURE SearchFirst(VAR Index, DataBase : FileOf;  Key : KeyType; 
                      VAR Data : DataType; VAR Keys : KeyArray): BOOLEAN;
(* Sucht den ersten Datensatz mit bezeichneten SchlÅssel in der Datenbank *)
VAR NextList : DataPtr;
    found : BOOLEAN;
BEGIN
   NextList:=SearchPtr(Index,DataBase,Tree,Key,found);
   IF NextList # Empty THEN
      Get (DataBase,NextList);
      Data := DataBase.RecordPtr^.Data;
      Keys := DataBase.RecordPtr^.Key;
   END; (*if*)
   RETURN found
END SearchFirst;

PROCEDURE SearchNext(VAR Index, DataBase : FileOf; VAR Data : DataType; VAR Keys : KeyArray) : BOOLEAN;
(* Sucht den nÑchsten Eintrag mit gleichem SchlÅssel *)
 VAR NextList : DataPtr; 
BEGIN
     IF Index.MultipleKeys THEN
           NextList := DataBase.RecordPtr^.Next[Index.Type];   
           IF DataBase.Current = NextList THEN
              (* Falls der Eintrag auf sich selber zeigt *)
              (* kann vorkommen ! *)
              RETURN FALSE 
              (* Leider sind falsche Verkettungen Åber mehrere EintrÑge *)
              (* 1 -> 2 -> 3 -> 1 oder Ñhnlich nicht so leicht abzufangen *)
              (* dafÅr kommen sie aber auch so gut wie nie vor. *)
           END(*IF*);   
	   IF NextList # Empty THEN
	      Get(DataBase,NextList);
	      Data := DataBase.RecordPtr^.Data;
              Keys := DataBase.RecordPtr^.Key;
	      RETURN TRUE
	   ELSE
	      RETURN FALSE
	   END; (*if*)
      ELSE
          RETURN FALSE
      END(*IF*);   
END SearchNext;

PROCEDURE SearchPrevious(VAR Index, DataBase : FileOf; VAR Data : DataType;VAR Keys : KeyArray) : BOOLEAN;
(* Sucht den vorigen Eintrag mit gleichem SchlÅssel *)
VAR PrevList : DataPtr;

BEGIN
  IF Index.MultipleKeys THEN
   IF DataBase.RecordPtr^.Prev[Index.Type] # Empty THEN
      PrevList := DataBase.RecordPtr^.Prev[Index.Type]; 
      IF DataBase.Current = PrevList THEN
         RETURN FALSE (* Eintrag zeigt auf sich selbst ! *)
      END(*IF*);
      (* Get  sollte auch ohne die Zwischenvariable PrevList funktionieren *)
      (* aber sicher ist sicher *)
      Get(DataBase,PrevList);
      Data := DataBase.RecordPtr^.Data;
      Keys := DataBase.RecordPtr^.Key;

      RETURN TRUE
   ELSE
      RETURN FALSE
   END; (*if*)
 ELSE
    RETURN FALSE
 END(*IF*);  
END SearchPrevious;

PROCEDURE First(VAR Index, DataBase : FileOf; VAR Key : KeyType; 
                 VAR Data : DataType; VAR Keys : KeyArray);
 (* Ersten Eintrag in der Indexdatei ermitteln *)
BEGIN
  IF Tree # Empty THEN
    Get ( Index,Tree);
    WHILE Index.RecordPtr1^.Ptr0 # Empty DO
       Get(Index,Index.RecordPtr1^.Ptr0);
    END(*WHILE*);
    Get(DataBase,Index.RecordPtr1^.Item[1].RecordNr);
    Key:= Index.RecordPtr1^.Item[1].Key;
    Keys := DataBase.RecordPtr^.Key;
    Data := DataBase.RecordPtr^.Data;
    (*NextList := DataBase.RecordPtr^.Next[Index.Type];*)
  ELSE
     Key:= 0D
  END(*IF*);     
END First;    

PROCEDURE Last (VAR Index, DataBase : FileOf; VAR Key : KeyType;
                 VAR Data : DataType; VAR Keys : KeyArray);
BEGIN
  IF Tree # Empty THEN
    Get (Index, Tree);    
    WITH Index.RecordPtr1^ DO
      WHILE Item[Anz].Ptr # Empty DO
         Get(Index,Item[Anz].Ptr);
      END(*WHILE*);
      Get(DataBase,Item[Anz].RecordNr);
      Key:= Index.RecordPtr1^.Item[Anz].Key;
      Keys := DataBase.RecordPtr^.Key;
    END(*WITH*);  
    Data := DataBase.RecordPtr^.Data;
    (*NextList := DataBase.RecordPtr^.Next[Index.Type];*)
  ELSE
    Key := 0D;
  END(*IF*);  
END Last;         

PROCEDURE Browse(Index,DataBase : FileOf; Tree : PagePtr; From, To : KeyType; 
                 OutProc : PrintDataProc);
VAR i : CARDINAL;
    copy : PageType;
    
 PROCEDURE BrowseOn;
 BEGIN
    WITH Index.RecordPtr1^ DO
	Get(DataBase, Item[i].RecordNr);
	OutProc(DataBase.RecordPtr^.Data);
	IF Index.MultipleKeys THEN
	   WHILE DataBase.RecordPtr^.Next[Index.Type] # Empty DO
	       Get(DataBase,DataBase.RecordPtr^.Next[Index.Type]);
	       OutProc(DataBase.RecordPtr^.Data);
	   END(*WHILE*);        
	END(*IF*);
	IF copy.Item[i].Ptr # Empty THEN
	        Browse(Index,DataBase, copy.Item[i].Ptr,From, To,OutProc);
	        Get (Index,Tree)
	END(*IF*); 
    END(*WITH*);	
 END BrowseOn;   
 
BEGIN
  IF Tree # Empty THEN
    Get(Index, Tree);
    WITH Index.RecordPtr1^ DO
        copy:=Index.RecordPtr1^;
        IF From < Item[1].Key THEN
         IF Ptr0 # Empty THEN
            Browse(Index,DataBase,Ptr0,From, To,OutProc);       
            Get(Index,Tree);    
         END(*IF*);    
        END(*IF*);
        FOR i:=1 TO Anz DO
          IF i<Anz THEN
            IF (From <= Item[i].Key) AND (To >= Item[i].Key)  THEN
		BrowseOn; 
            ELSIF (From < Item[i+1].Key)  AND (To >= Item[i].Key) THEN
		Browse(Index,DataBase, copy.Item[i].Ptr,From, To,OutProc);
	        Get (Index,Tree)
            END(*IF*);
          ELSE 
             IF (From <= Item[i].Key) AND (To >= Item[i].Key)  THEN
		BrowseOn; 
	     ELSE 	
                Browse(Index,DataBase, copy.Item[i].Ptr,From, To,OutProc);
	        Get (Index,Tree)
	     END(*IF*);
          END(*IF*); 
	END(*FOR*);
     END(*WITH*);
   END(*IF*);
END Browse;                 


PROCEDURE PrintTree(VAR Index, DataBase : FileOf; Tree : PagePtr; 
                    Tiefe : CARDINAL; OutProc : PrintDataProc);
(* Inorder durchlauf durch die B-Baumstrucktur *)
(* zuerst werden alle SchlÅsselwerte durchlaufen *)
(* dann die Liste aller Nachfolger *)
VAR i : CARDINAL;
    copy : PageType;
BEGIN
  IF Tree # Empty THEN
    Get(Index, Tree);
    WITH Index.RecordPtr1^ DO
        copy:=Index.RecordPtr1^;
        IF Ptr0 # Empty THEN
            PrintTree(Index,DataBase,Ptr0,Tiefe+1,OutProc);       
            Get(Index,Tree);    
        END(*IF*);    
        FOR i:=1 TO Anz DO
	   Get(DataBase, Item[i].RecordNr);
	   OutProc(DataBase.RecordPtr^.Data);
	   IF Index.MultipleKeys THEN
	     WHILE DataBase.RecordPtr^.Next[Index.Type] # Empty DO
	       Get(DataBase,DataBase.RecordPtr^.Next[Index.Type]);
	       OutProc(DataBase.RecordPtr^.Data);
	     END(*WHILE*);        
	   END(*IF*);
	   IF copy.Item[i].Ptr # Empty THEN
               PrintTree(Index,DataBase, copy.Item[i].Ptr,Tiefe+1,OutProc);
               Get (Index,Tree)
           END(*IF*);    
	END(*FOR*);
     END(*WITH*);
   END(*IF*);
END PrintTree;


PROCEDURE Next(VAR Index, DataBase : FileOf; Key : KeyType; 
		   VAR NextKey : KeyType; VAR NextData: DataType; 
		   VAR Keys : KeyArray) : BOOLEAN;

CONST above = -2D;		   
VAR NextList : DataPtr;

PROCEDURE SearchNextPtr(VAR Index, DataBase : FileOf; Page : PagePtr; Key : KeyType) : DataPtr;
(* sucht die Random-Acess-Adresse eines durch Key bezeichneten Datenbankeintrags *)
	VAR q, CurrP   : PagePtr;
	    l, r, k    : CARDINAL;
	    SearchPtr0 : DataPtr;

BEGIN (* *)
  REPEAT
   IF Page = Empty THEN
      (*SearchPtr := Empty*)
      RETURN Empty;
   ELSIF Page = above THEN
      Page := CurrP;
      IF CurrP = Tree THEN (* Ich bin wieder bei der Wurzel angekommen *)
         Get(Index,CurrP);
         IF r < Index.RecordPtr1^.Anz THEN
            NextKey:=Index.RecordPtr1^.Item[r+1].Key;
            RETURN Index.RecordPtr1^.Item[r+1].RecordNr;
         ELSE
            (*HALT*);
            NextKey:= Index.RecordPtr1^.Item[r].Key;
         END(*IF*);   
	 (* ******** IF k=Index.RecordPtr1^.Anz THEN (* Nur bei BÑumen die nur ein Element in der Wurzel haben! *)
	        NextKey:=Index.RecordPtr1^.Item[k].Key;
	        RETURN Index.RecordPtr1^.Item[k].RecordNr;
	 ELSE (* Unser Eintrag ist der NÑchste auf der WurzelSeite *)
	       NextKey := Index.RecordPtr1^.Item[k+1].Key;
	       RETURN Index.RecordPtr1^.Item[k+1].RecordNr;

	  END(*IF*); **** *)
       ELSE (* Page hat einen Wert >= Tree *)
	     Get(Index,CurrP);
	     IF r=Index.RecordPtr1^.Anz THEN (* letzter Eintrag auf dieser Seite, der gesuchte Eintrag befindet sich noch eins hîher!*)
	        RETURN above;
	     ELSE
	       NextKey := Index.RecordPtr1^.Item[r+1].Key; (* Endlich daheim! *)
	       RETURN Index.RecordPtr1^.Item[r+1].RecordNr;
	     END(*IF*);     
       END(*IF*);     
   ELSE
      Get(Index,Page);
      WITH Index.RecordPtr1^ DO
	 l:=1;
	 r:= Anz;
	 REPEAT
	    k := (l+r) DIV 2;
	    IF Key <= Item[k].Key THEN
	       r := k-1;
	    END(*IF*);
	    IF Key >= Item[k].Key THEN
	      l:= k+1;
	    END(*IF*);
	 UNTIL r<l;
	 IF r=0 THEN
	    q:= Ptr0
	 ELSE
	    q:=Item[r].Ptr;
	 END(*IF*);
	 CurrP := Page;
	 IF (l-r)>1 THEN (* Eintrag gefunden ! *)
	    (*SearchPtr:= Item[k].RecordNr*)
	    (*RETURN Item[k].RecordNr*)
	    IF Item[k].Ptr # Empty THEN (* Wir sind nicht auf einer BlattSeite *)
	       Get( Index, Item[k].Ptr);
	       WHILE Index.RecordPtr1^.Ptr0 # Empty DO (* Baum auf linker Seite runterwandern *)
		       Get(Index,Index.RecordPtr1^.Ptr0);
	       END(*WHILE*);
	       NextKey :=Index.RecordPtr1^.Item[1].Key;
	       RETURN Index.RecordPtr1^.Item[1].RecordNr;
	    ELSE (* Wir sind auf einer BlattSeite *)
	       IF k= Anz THEN   (* Letzter Eintrag auf der Blattseite *)
	          RETURN above; (* der nÑchste Eintrag ist auf einer hîheren Seite *)
	       ELSE
	         NextKey := Item[k+1].Key; (* Der nÑchste Eintrag steht eins weiter auf dieser Blattseite !*)
	         RETURN Item[k+1].RecordNr;   
	       END(*IF*);
	    END(*IF*);   
	 ELSE (* Eintrag nicht gefunden -> Suche geht weiter *)
	    SearchPtr0:= SearchNextPtr(Index,DataBase,q,Key);
	    Page := SearchPtr0;
	 END(*IF*);
     END; (* with*)
   END; (*if*)
 UNTIL Page # above;  
 RETURN Page;
END SearchNextPtr;

BEGIN
   IF ~SearchNext(Index,DataBase,NextData,Keys) THEN
       Last(Index,DataBase,NextKey,NextData,Keys);
       IF NextKey = Key THEN
            RETURN FALSE
            (* First(Index,DataBase,NewKey,NewData);*)
       ELSE
	   NextList:=SearchNextPtr(Index,DataBase,Tree,Key);
	   IF NextList # Empty THEN
	      Get (DataBase,NextList);
	      NextData := DataBase.RecordPtr^.Data;
              Keys := DataBase.RecordPtr^.Key;
	     (* NextList := DataBase.RecordPtr^.Next[Index.Type];*)
	      RETURN TRUE
	   ELSE
	       (*HALT*);
	       RETURN FALSE (* Hier darf ich eigentlich nie hinkommen*)
	   END; (*if*)
       END(*IF*);   
    ELSE
        RETURN TRUE  
    END(*IF*);	   
END Next;

PROCEDURE Previous(VAR Index, DataBase : FileOf; Key : KeyType; 
		   VAR NextKey : KeyType; VAR NextData: DataType; 
		   VAR Keys : KeyArray) : BOOLEAN;

CONST above = -2D;		   
VAR NextList : DataPtr;

PROCEDURE SearchPrevPtr(VAR Index, DataBase : FileOf; Page : PagePtr; Key : KeyType) : DataPtr;
(* sucht die Random-Acess-Adresse eines durch Key bezeichneten Datenbankeintrags *)
	VAR q, CurrP   : PagePtr;
	    l, r, k    : CARDINAL;
	    SearchPtr0 : DataPtr;

BEGIN (* *)
  REPEAT
   IF Page = Empty THEN
      (*SearchPtr := Empty*)
      RETURN Empty;
   ELSIF Page = above THEN
      Page := CurrP;
      IF CurrP = Tree THEN (* Ich bin wieder bei der Wurzel angekommen *)
         Get(Index,CurrP);
         IF r <= Index.RecordPtr1^.Anz THEN
            IF r < 1  THEN
                    WHILE Index.RecordPtr1^.Ptr0 # Empty DO
                          Get(Index,Index.RecordPtr1^.Ptr0);
                    END(*WHILE*);
                    NextKey:= Index.RecordPtr1^.Item[Index.RecordPtr1^.Anz].Key;
        	    RETURN Index.RecordPtr1^.Item[(*1*)Index.RecordPtr1^.Anz].RecordNr;
             ELSE
                    NextKey := Index.RecordPtr1^.Item[r].Key;
                    RETURN Index.RecordPtr1^.Item[r].RecordNr;    
	     END(*IF*);    
         ELSE
            (*HALT*);
            NextKey:= Index.RecordPtr1^.Item[r-1].Key;
         END(*IF*);   
      ELSE (* Page hat einen Wert >= Tree *)
	     Get(Index,CurrP);
	     IF r < 1 THEN (* erster Eintrag auf dieser Seite, der gesuchte Eintrag befindet sich noch eins hîher!*)
	        RETURN above;
	     ELSE
	       NextKey := Index.RecordPtr1^.Item[r].Key; (* Endlich daheim! *)
	       RETURN Index.RecordPtr1^.Item[r].RecordNr;
	     END(*IF*);     
       END(*IF*);     
   ELSE
      Get(Index,Page);
      WITH Index.RecordPtr1^ DO
	 l:=1;
	 r:= Anz;
	 REPEAT
	    k := (l+r) DIV 2;
	    IF Key <= Item[k].Key THEN
	       r := k-1;
	    END(*IF*);
	    IF Key >= Item[k].Key THEN
	      l:= k+1;
	    END(*IF*);
	 UNTIL r<l;
	 IF r=0 THEN
	    q:= Ptr0
	 ELSE
	    q:=Item[r].Ptr;
	 END(*IF*);
	 CurrP := Page;
	 IF (l-r)>1 THEN (* Eintrag gefunden ! *)
	       IF k = 1 THEN   (* Erster Eintrag auf der Seite *)
	           IF Ptr0 = Empty THEN (* Wir sind auf einer BlattSeite *)
	                RETURN above; (* der VorgÑnger ist auf einer hîheren Seite *)
                   ELSE (* sonst befindet sich der VorgÑnger an 1. Stelle auf der darunterliegenden untersten rechten (!) Seite *)
                      Get (Index,Ptr0);
                      WHILE Ptr0 # Empty DO (* Ist ein Zeiger leer sin alleleer *)
                          Get(Index, Item[Anz].Ptr);
                      END(*WHILE*);
                      NextKey := Item[Anz].Key;
                      RETURN Item[(*1*) Anz].RecordNr;
                   END(*IF*);   
	        ELSE (* k-ter Eintrag auf der Seite *)
	           IF Item[k].Ptr # Empty THEN (* Wir sind nicht auf einer BlattSeite *)
	                Get(Index,Item[k-1].Ptr);
	                WHILE Item[Anz].Ptr # Empty DO (* Baum auf rechter Seite runter wandern *)
			         Get(Index,Item[Anz].Ptr);
                        END(*WHILE*);
                        NextKey := Item[Anz].Key;
                        RETURN Item[Anz].RecordNr;
                   ELSE (* Wir sind auf einer BlattSeite *)     
	             NextKey := Item[k-1].Key; (* Der vorige Eintrag steht eins weiter vorn auf dieser Blattseite !*)
	             RETURN Item[k-1].RecordNr;   
	           END(*IF*);  
	       END(*IF*);
	 ELSE (* Eintrag nicht gefunden -> Suche geht weiter *)
	    SearchPtr0:= SearchPrevPtr(Index,DataBase,q,Key);
	     (*RETURN SearchPtr0 *)
	    Page := SearchPtr0;
	 END(*IF*);
     END; (* with*)
   END; (*if*)
 UNTIL Page # above;  
 RETURN Page;
END SearchPrevPtr;

BEGIN
   IF ~SearchPrevious(Index,DataBase,NextData,Keys) THEN
       First(Index,DataBase,NextKey,NextData,Keys);
       IF NextKey = Key THEN (* Der erste Eintrag hat naturgemÑû keinen VorgÑnger *)
            RETURN FALSE
            (* Last(Index,DataBase,NewKey,NewData);*)
       ELSE
	   NextList:=SearchPrevPtr(Index,DataBase,Tree,Key);
	   IF NextList # Empty THEN
	      Get (DataBase,NextList);
	      NextData := DataBase.RecordPtr^.Data;
	      NextList := DataBase.RecordPtr^.Next[Index.Type];
              Keys := DataBase.RecordPtr^.Key;
	      RETURN TRUE
	   ELSE
	       (*HALT*);
	       RETURN FALSE (* Hier darf ich eigentlich nie hinkommen*)
	   END; (*if*)
       END(*IF*);   
    ELSE
        RETURN TRUE  
    END(*IF*);	   
END Previous;

BEGIN
(* Falls Order oder PageType geÑndert werden kann man sich hier ohne 
   groû rumzurechnen die Grîûen anzeigen lassen. Sie sollten ganzahlige 
   Vielfache oder Teiler von 1024 sein wegen der Sektorgrîûe des GEMDOS.
   Bei anderen Grîûen wird entweder Plattenspeicher verschleudert oder
   die Zugriffgeschwindigkeit veringert *)
   
(*   WriteString('Size of BaseType:');
   WriteInt(TSIZE(BaseType),5);
   WriteLn;
   WriteString('Size of PageType:');
   WriteInt(TSIZE(PageType),5);
   WriteLn; *)
	
END BTree.
