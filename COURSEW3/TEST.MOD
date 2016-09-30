MODULE Test;

IMPORT In, Out, l := List;

PROCEDURE ProgMain*;
VAR
    word : l.ListItem;
    count : l.Count;
    list1 : l.List;

BEGIN 
    list1 := l.Create();
    list1 := l.Insert(list1, "apple");
    list1 := l.Insert(list1, "hello");
    list1 := l.Insert(list1, "world");
    list1 := l.Insert(list1, "hello");
    list1 := l.Insert(list1, "apple");

    list1 := l.Insert(list1, "hello");    
    list1 := l.Insert(list1, "may"); 
    
    l.Head(list1, word, count);
    Out.String(word);
    Out.Int(count, 3);
    Out.Ln;
    list1 := l.Tail(list1); 
    
    l.Head(list1, word, count);
    Out.String(word);
    Out.Int(count, 3);
    Out.Ln;
    list1 := l.Tail(list1); 


    l.Head(list1, word, count);
    Out.String(word);
    Out.Int(count, 3);
    Out.Ln;
    list1 := l.Tail(list1);

    l.Head(list1, word, count);
    Out.String(word);
    Out.Int(count, 3);
    Out.Ln;
    list1 := l.Tail(list1);
END ProgMain;
END Test.
