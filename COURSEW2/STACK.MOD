MODULE Stack;

TYPE
    StackItem* = INTEGER;
    Stack* = POINTER TO StackNode;
    StackNode = RECORD
                    item : StackItem;
                    next : Stack;
                END;
 

(*Stack Constructors*)

PROCEDURE Create*(): Stack;
(*Pre condition: None.
  Post condition: Returns an empty stack.*)
BEGIN
    RETURN NIL;     (*Returns a NIL value that the new stack is pointing to*)
END Create;


PROCEDURE Push*(s : Stack; i : StackItem): Stack;
(*Pre condition: None.
  Post condition: Returns a stack s with truck i added to the top*)
VAR
    newNode : Stack;
BEGIN
    NEW (newNode);
    newNode^.item := i;    (*StackItem becomes the new nodes pointer to StackItem*)
    newNode^.next := s;    (*Stack becomes the new nodes pointer to the next stack node*) 
    RETURN newNode;
END Push;


(*Stack Observers*)

PROCEDURE IsEmpty*(s: Stack): BOOLEAN;
(*Pre condition: None.
  Post condition: Returns True if given stack is empty and false otherwise*)
BEGIN
    RETURN s = NIL;     (*Stack becomes equal to NIL value*)
END IsEmpty;


PROCEDURE Top*(s: Stack): StackItem;
(*Pre condition: given stack is non empty.
  Post condition: Returns a copy of the item at the top of the stack*)
BEGIN
    IF ~IsEmpty(s) THEN
        RETURN s^.item;    (*Returns the integer value that stack is pointing to*)
    END;
END Top;


(*Stack modifiers*)

PROCEDURE Pop*(s: Stack): Stack;
(*Pre condition: None.
  Post condition: Given a stack, returns the stack by ignoring the top item of the
                  origial stack. If given a empty stack then pop returns an empty stack*)
VAR
    TempS : Stack;
BEGIN
    TempS := s;
    IF IsEmpty(TempS) THEN
        RETURN TempS;
    ELSE
        DISPOSE (s);           (*Release the memory space held by s*)
        RETURN TempS^.next;    (*Returns the temporary pointer to the next stack node*) 
    END;
END Pop;

BEGIN
(*No initialisation code*)
END Stack.
