(****************************************************************************)
(*
   Tools V0.04a (Tools.MOD)
   ============
   
   Programmierer: Alexander Graf (Mat.Nr. 9355752)
                  Dietmar Schinnerl (Mat.Nr. 9355075)
   Projekt: Fallstudie Betriebssysteme: Windowsprogrammierung mit Oberon-2
   Compiler: POW! Oberon-2
   
                           (C) by Alexander Graf & Dietmar Schinnerl, 1996
                           
 ---------------------------------------------------------------------------
 
 History:                          
 
  19.08.1996 / 0.04a : Dokumentation
  21.05.1996 / 0.03a : FormatDate
  18.05.1996 / 0.02a : Strings-Compare hinzufuegen
  10.05.1996 / 0.01a : Grundgeruest
                                                                            *)
(****************************************************************************)

MODULE Tools;


 (***************************************************************************)
 (* Benoetige Module importieren                                            *)
 
 IMPORT Strings;
 

 (***************************************************************************)
 (* globale Typen, Konstanten und Variablen                                 *)


 (***************************************************************************)

 
 (*-------------------------------------------------------------------------
   <FormatDate> formatiert das uebergebene Datum in das Format 'tt.mm.jjjj'.
   -------------------------------------------------------------------------*)  

 PROCEDURE FormatDate* (VAR date : ARRAY OF CHAR);
  BEGIN
   IF (date[1] = ".")
    THEN Strings.InsertChar ("0", date, 0);
   END;

   IF (date[3] = " ")
    THEN date[3] := "0";
   END;
  END FormatDate;


 (*-------------------------------------------------------------------------
   <Compare> vergleicht zwei Zeichenketten auf Gleichheit.
   -------------------------------------------------------------------------*)  

 PROCEDURE Compare* (str1, str2 : ARRAY OF CHAR) : BOOLEAN;
  VAR ctr : LONGINT;
  BEGIN
   IF (Strings.Length (str1) # Strings.Length (str2))
    THEN RETURN FALSE;
   END;
   
   ctr := 0;
   WHILE (ctr < Strings.Length (str1)) & (str1[ctr] = str2[ctr]) DO
    INC (ctr);
   END;
   
   RETURN (str1[ctr] = str2[ctr]);
  END Compare;
  
END Tools.
 
(****************************************************************************)
