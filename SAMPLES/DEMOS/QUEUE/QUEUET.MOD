MODULE QueueT;


IMPORT Display, Queue;


PROCEDURE [WINDOWS] ProgMain*;

  VAR
    choice: INTEGER;
    elem:   INTEGER;
    q:      Queue.Q;
    result: CHAR;
    
BEGIN

  NEW(q);
  q.Init(); 
  
  REPEAT
  
    Display.WriteLn;
    Display.WriteStr("Menü:"); Display.WriteLn;
    Display.WriteStr("-----"); Display.WriteLn;
    Display.WriteStr(" 1 .. Element in die Queue einfügen"); Display.WriteLn;
    Display.WriteStr(" 2 .. Element aus der Queue entfernen"); Display.WriteLn;
    Display.WriteStr("99 .. Programm beenden"); Display.WriteLn;
    Display.WriteLn;
    Display.ReadInt(choice, 5, result); Display.WriteLn;
    CASE choice OF 
      1: Display.WriteStr("Geben Sie das neue Element ein: ");
         Display.ReadInt(elem, 5, result);
         Display.WriteLn;
         IF q.Add(elem) THEN
           Display.WriteStr("Das Element "); Display.WriteInt(elem, 0); Display.WriteStr(" wurde eingefügt."); Display.WriteLn;
         ELSE 
           Display.WriteStr("Die Queue ist voll."); Display.WriteLn;
         END;
     |2: IF q.Del(elem) THEN 
           Display.WriteStr("Das Element "); Display.WriteInt(elem, 0); Display.WriteStr(" wurde aus der Queue entnommen."); Display.WriteLn;
         ELSE 
           Display.WriteStr("Die Queue ist leer."); Display.WriteLn;
         END;
      ELSE
    END;
    
  UNTIL choice = 99;

END ProgMain;

END QueueT.
