MODULE List;

IMPORT Out;

TYPE
    List* = POINTER TO ListNode;
    ListItem* = ARRAY 25 OF CHAR;
    Count* = INTEGER;
    ListNode = RECORD
                    item : ListItem; 
                    count : Count;
                    next : List;
               END;
           
PROCEDURE Create*(): List;
(*Pre-condition: None
  Post-condition: returns a new and empty list.*)
BEGIN
    RETURN NIL;
END Create;


PROCEDURE IsEmpty*(l : List): BOOLEAN;
(*Pre-condition: None *)
(*Post-condition: returns TRUE if l is empty, FALSE if it isn't.*)
BEGIN
    RETURN l = NIL;
END IsEmpty;


PROCEDURE Cons(l : List; i : ListItem; c : Count): List;
(*Pre-condition: None
  Post-condition: Returns list l with item i added to the head*) 
VAR
    tempL : List; (*Pointer to access new list node*)
BEGIN
    (*First we allocate space for the new list node*)
    NEW(tempL);
    
    (*Now store the new item in the node.*)
    tempL^.item := i;
 
    (*Now store the count of the occurences of the word*)
    tempL^.count := c;
    
    (*Set up the new node's next pointer to point to the head of the
      original list, and then return tempL, so we are returning a 
      pointer to a list with the new node at the head. *)
    tempL^.next := l;
  
    RETURN tempL;
END Cons;


PROCEDURE Tail*(l : List): List;
(*Pre-condition: None
  Post-condition: Returns tail of l. If empty returns l*) 
BEGIN
    IF IsEmpty(l) THEN
        (*Tail of empty list is empty list*)
        RETURN l;
    ELSE
        RETURN l^.next;
    END;
END Tail;


PROCEDURE Head*(l : List; VAR i : ListItem; VAR c : Count);
(*Pre-condition: l is non empty
  Post-condition: returns the item at the head of the list*) 
BEGIN
    IF ~IsEmpty (l) THEN
        i := l^.item;
        c := l^.count;
    ELSE 
        Out.String("PROCEDURE Head: no items, list is empty."); 
        i := CHR(0);
    END;
END Head;


PROCEDURE Insert*(l : List; i : ListItem) : List;
(*Pre-condition: item i is not in the list
  Post-condition: returns list l with item i inserted into the correct position*)
BEGIN
    IF IsEmpty(l) THEN
        (*Add item to the empty list*) 
        RETURN Cons(Create(), i, 1);
    ELSE
        (*List is non empty*)
        IF i = l^.item THEN 
            INC(l^.count);
            RETURN l; (*Already in list - don't add it*)
        ELSIF i < l^.item THEN
            (*i belongs at head of list*) 
            RETURN Cons(l, i, 1);
        ELSE
            (*i belongs further down the list*)
            RETURN Cons(Insert(Tail(l), i), l^.item, l^.count); 
        END; (*Inner IF*)
    END; (*Outer IF*)
END Insert;


PROCEDURE IsIn*(l : List; i : ListItem): BOOLEAN;
(*Pre-condition: none
  Post-condition: returns TRUE if i is in l and FALSE otherwise*)
BEGIN
    IF IsEmpty(l) THEN
        (*Can't find the item in an empty list*)
        RETURN FALSE;
    ELSE
        IF i = l^.item THEN
            (*Item we want is head item*)
            RETURN TRUE
        ELSE
            (*Item is further down the list*)
            RETURN IsIn(Tail(l), i);
        END;  (*Inner IF*)
    END; (*OuterIF*)
END IsIn;

END List.

    



