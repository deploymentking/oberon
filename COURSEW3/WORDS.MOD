MODULE Words;

IMPORT F := File, In, Out, L := List, S := Strings;

CONST 
    MaxWord = 20;
TYPE
    (*A word is an array specified in the module list*)
    Word = L.ListItem;
    
PROCEDURE IsAlpha (ch:CHAR): BOOLEAN;
(*Indicates whether or not a char is alphabetic.
  Pre-Condition: none.
  Post-Condition: True if ch is upper or lowercase letter.
                  False otherwise*)
BEGIN
    IF ((ch>= "A") & (ch<="Z")) OR
       ((ch>= "a") & (ch<="z")) THEN
       (*Valid letter*)
       RETURN TRUE;
    ELSE
        (*Not a letter*)
        RETURN FALSE;
    END;
END IsAlpha;

PROCEDURE Skip (file:F.Handle; VAR ch:CHAR);
(*Skips over any white space and punctuation marks between words.
Pre-Condition: file must be open for reading
Post-Condition: moves the file pointer past any white space or
                punctuation in the file to the next alphabetic character
                which is returned in ch.*)
CONST
    Space = CHR(32); (*ASCII space*)
VAR
    result : INTEGER; (*For ReadChar to return a result indicating whether
                        or not it worked*)                        
BEGIN
    ch := Space; (*Starting condition*)
    
    (*Read characters one at a time until we reach end of file or an 
      alphabetic character*)
    WHILE (~F.AtEnd(file)) & ~IsAlpha(ch) DO
        F.ReadChar(file, ch, result);
        (*halt program if in error was reported by ReadChar*)
        IF result # F.NOERROR THEN
            Out.String("Could not read character");
            HALT(0);
        END; (*End IF*)
    END;  (*End WHILE*)
END Skip;

PROCEDURE ReadWord (file: F.Handle; VAR word: Word; VAR success : BOOLEAN; VAR wordList : L.List);
(*Reads a single word from a given file.
Pre-Condition: file must be open for reading
Post-Condition: the next word in the file is read into variable
                word. If there is no word to read then success is set
                to FALSE otherwise it is set to TRUE.*)
VAR
    ch : CHAR; (*character read from file*)
    result : INTEGER; (*for ReadChar to return a result indicating whether or
                        not it worked*)
    i : INTEGER; (*ARRAY index for word array*)
    
BEGIN
    (*skip over any spaces or punctuation that come before the word*)
    Skip(file, ch);
    (*Check that we have not skipped to the end of the file and therefore
       have no words to read*)
    success := ~F.AtEnd(file);

    IF success THEN
        (*read a word into variable word, storing a CHR(0)at end*)
        i := 0; 
        REPEAT 
            (*store first character in word, if there is room, this character
              is the last one read by skip. Remeber to leave space for CHR(0) at end*)
              IF i < MaxWord-2 THEN
                  word[i] := ch; 
                  INC(i);
              END;
              (*read the next character from file*)
              F.ReadChar(file, ch, result);
              IF ((result # F.NOERROR) & (result # F.EOFREACHED)) THEN
                  Out.String("Could not read character");
                  HALT(0);
              END;
        UNTIL ((~IsAlpha(ch)) OR (result = F.EOFREACHED));
        
        (*store a CHR(0)at the end of the word so out.string can priont it out 
          correctly*)
        word[i]:= CHR(0);
        
        (*Converts all of the characters to uppercase so all words can be sorted together*)
        S.UpCase(word); 
        wordList := L.Insert(wordList, word); 
    END;
    
END ReadWord;


PROCEDURE ProgMain*;
VAR
    result : INTEGER; (*For ReadChar to return a result indicating whether or not it worked*)
    create : BOOLEAN; (*Used by F.Open if true will create a file first, if false will not
                        create file*)
    handle : F.Handle;                    (*File handle for accessing file*)
    word : Word;                          (*word read in*)
    success : BOOLEAN;                    (*Indicates if ReadWord worked or not*) 
    filename : ARRAY 15 OF CHAR;          (*file to be searched, inputted by user*)
    searchWord, tempWord : L.ListItem;    (*specified word to search for*)
    option : ARRAY 2 OF CHAR;             (*array to store the option choice*)
    wordList, tempWordList : L.List;      (*The ordered lists in which to store the text*)
    count : L.Count;       (*count of occurences of each letter in the text*)
    wordCount : INTEGER;   (*count of the number of different words in the text.*)
    fail : INTEGER;        (*REPEAT loop variable for the word search*)
    searchAnswer : ARRAY 2 OF CHAR;       (*Allows exit from the search for a word loop*)
    run : INTEGER;                          (*Allows user to return to start again*)
BEGIN
    run := 0;
    REPEAT

    (*Assign a new and empty list to wordList*)
    wordList := L.Create();
 
    (*Introduction text and prompt for user to input filename*)
    Out.String("~~~~~~~~~~~~~~~~~~~~~~~~~");
    Out.String(" Welcome to CONCORDANCE 2000 ");
    Out.String("~~~~~~~~~~~~~~~~~~~~~~~~~");
    Out.Ln; Out.Ln;
    Out.String("Please type in the name of the file you wish to preview.");
    Out.Ln; Out.Ln;
    In.String(filename);
  
    (*Open file for reading. Create is false because we know we are reading from
    an existing file, and so have no need to tell open to create it if it does not exist*)    
    create := FALSE;
    REPEAT
        (*Information to the reader while the file is being opened*)
        Out.String("Please wait while your file is being processed....");
        Out.Ln; Out.Ln;
        F.Open(filename, create, F.DENYALL, F.READONLY, handle, result);   
        
        IF result # F.NOERROR THEN
            Out.String("ERROR: Could not open file."); Out.Ln; Out.Ln;
            (*Error message with help file option*)
            Out.String("The file '");
            Out.String(filename);
            Out.String("' either does not exist or it is in the wrong directory."); 
            Out.Ln;
            Out.String("Please type 'h' to view the help file or re-type the filename");
            Out.Ln; Out.Ln;
            In.String(filename);
            
            WHILE (filename = "h") OR (filename = "H") DO
                Out.Ln; Out.String("~~~~~~~~~~~~~~~~~~~~");
                Out.String(" Welcome to CONCORDANCE 2000 Help File ");
                Out.String("~~~~~~~~~~~~~~~~~~~~"); Out.Ln; Out.Ln;
                Out.String("This program is designed to look at a text file and give the ");
                Out.Ln;
                Out.String("concordance of words within that file.");Out.Ln;
                Out.String("The file in question must be located within the same directory ");
                Out.Ln; Out.String("as this program. If it is not then the prorgam will not ");
                Out.Ln; Out.String("recognise the file.");
                Out.Ln; Out.String("Alternatively you have entered a file that does not exist");
                Out.Ln; Out.Ln;
                Out.String("Please try to input the filename again or ");
                Out.String("quit and move it to this directory.");
                (*Obtain the filename from the user again*)
                In.String(filename); Out.Ln; Out.Ln;
                Out.String("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                Out.String("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");Out.Ln;Out.Ln;
                Out.Ln;
            END;  (*End WHILE loop*)
        END; (*End IF loop*)
    UNTIL result = F.NOERROR;  (*End REPEAT loop*)
    
    (*read word until readword sets success to false*)
    success := TRUE; 
    WHILE success DO
        ReadWord(handle, word, success, wordList); 
    END;
    (*Before any tests are carried out, this count is reset.*)
    wordCount := 0;
    
    REPEAT
        Out.String("The file you have entered is '");
        Out.String(filename); Out.String("'.");Out.Ln;
        Out.String("Please enter the option you wish to execute and press return.");
        Out.Ln; Out.Ln;
        Out.String("~~~~~~~~~~~~~~~~~~~~~~~~");
        Out.String(" CONCORDANCE 2000 Option File ");
        Out.String("~~~~~~~~~~~~~~~~~~~~~~~~~");
        Out.Ln; Out.Ln;
        Out.String("'W' : View the concordance for the whole file."); Out.Ln;     
        Out.String("'S' : Search the file for a specified word."); Out.Ln;
        Out.String("'A' : View the concordance for the another file."); Out.Ln;
        Out.String("'Q' : Quit this program."); Out.Ln; Out.Ln;
        Out.String("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        Out.String("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");Out.Ln;Out.Ln;
        In.String(option);

        IF (option = 'W') OR (option = 'w') OR  (option = 's') OR (option = 'S') 
                                        OR  (option = 'a') OR (option = 'A') THEN
            
            IF (option = 'W') OR (option = 'w') THEN
                tempWordList := wordList;
                
                Out.String("The following words were found in your file.");
                Out.Ln; Out.Ln; 
                wordCount := 0;
                WHILE ~L.IsEmpty(tempWordList) DO
                    L.Head(tempWordList, word, count);
                    INC(wordCount); 
                    S.LeftAlign(word, 20); 
                    Out.String(word);
                    Out.Int(count, 3); 
                    Out.Ln;
                    tempWordList := L.Tail(tempWordList);
                END; (*End WHILE loop*)
                
                Out.Ln;
                Out.String("There are: ");
                Out.Int(wordCount, 4);
                Out.String(" seperate words in '");Out.String(filename); Out.String("'.");
                Out.Ln;Out.Ln;
                Out.String("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                Out.String("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");Out.Ln;Out.Ln;
                run := 0;
            ELSIF (option = 's') OR (option = 'S') THEN
                tempWordList := wordList;
                
                fail := 0; 
                REPEAT  (*1*)
                          
                    Out.String("Please enter the word you wish to search for.");
                    In.String(searchWord);
                    S.UpCase(searchWord);

                    IF L.IsIn(tempWordList, searchWord) THEN   
                        REPEAT  (*2*)
                            L.Head(tempWordList, tempWord, count);
                            tempWordList := L.Tail(tempWordList);
                        UNTIL tempWord = searchWord;  (*End REPEAT 2 loop*)
                        Out.Ln; Out.Ln;
                        Out.String("The word you searched for was '");
                        Out.String(searchWord); Out.String("' and it appeared "); 
                        IF count = 1 THEN   
                            Out.String("once in the text.");
                        ELSIF count = 2 THEN
                            Out.String("twice in the text.");
                        ELSE
                            Out.Int(count, 3); Out.String(" times in the text");    
                        END; (*End 3rd Inner IF loop*)
                        Out.Ln; Out.Ln;
                        Out.String("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                        Out.String("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");Out.Ln;Out.Ln;
                        fail := 1;                
                    ELSE
                        Out.Ln; Out.Ln;
                        Out.String("The word you searched for was not in the text."); Out.Ln;
                        Out.String("Do you want to try again? Please type 'y' or 'n' and enter.");
                        In.String(searchAnswer);
                        
                        IF (searchAnswer = 'y') OR (searchAnswer = 'Y') THEN (*IF (1) loop*)
                            fail := 0;
                        ELSIF (searchAnswer = 'n') OR (searchAnswer = 'N') THEN
                            fail := 1;
                        ELSE
                            Out.Ln;
                            Out.String("This is not a valid reply, please type lower case 'y' to continue.");
                            REPEAT
                                In.String(searchAnswer)    
                            UNTIL searchAnswer = 'y'; 
                        END; (*End IF (1) loop*)
                        
                        Out.Ln; Out.Ln;
                        Out.String("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                        Out.String("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");Out.Ln;Out.Ln; 
                    END; (*End 2nd Inner IF loop*)
                    
                UNTIL fail = 1; (*End REPEAT 1 loop *)
                run := 0;
                
            ELSIF (option = 'a') OR (option = 'A') THEN
                F.Close(handle);
                IF ~L.IsEmpty(wordList) THEN
                    DISPOSE(wordList);
                END;
                run := 1;
            END; (*End Inner IF loop*)
            
        END; (*End IF Loop*)
        
    UNTIL ((run = 1) OR ((option ='q') OR (option = 'Q'))) ;
    UNTIL (option = 'q') OR (option = 'Q'); (*End of 'option' REPEAT*)
   
    Out.String("Thank you for using CONCORDANCE 2000.");
    Out.Ln; Out.String("Have a nice day!"); Out.Ln;
    Out.String("To clear this screen please click on the 'EXIT' button"); Out.Ln; Out.Ln;
    Out.String("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    Out.String("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");Out.Ln;Out.Ln;

    
END ProgMain;
END Words.
