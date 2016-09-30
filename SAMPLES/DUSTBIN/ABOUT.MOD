(****************************************************************************)
(*
   About V0.02a (About.MOD)
   ============
   
   Programmierer: Alexander Graf (Mat.Nr. 9355752)
                  Dietmar Schinnerl (Mat.Nr. 9355075)
   Projekt: Fallstudie Betriebssysteme: Windowsprogrammierung mit Oberon-2
   Compiler: POW! Oberon-2
   
                           (C) by Alexander Graf & Dietmar Schinnerl, 1996
                           
 ---------------------------------------------------------------------------
 
 History:                          
 
  26.05.1996 / 0.02a : WM_TIMER hinzugefuegt
  17.05.1996 / 0.01a : ausgegliedert aus DUSTBINW.MOD
                                                                            *)
(****************************************************************************)

MODULE About;

 (***************************************************************************)
 (* Benoetige Module importieren                                            *)
 
 IMPORT Windows,
        SYSTEM;
 
 
 (***************************************************************************)
 (* globale Typen, Konstanten und Variablen                                 *)

 VAR timer : INTEGER;
     text : ARRAY 10, 16 OF CHAR;
 
 
 (*-------------------------------------------------------------------------
   <AboutDlg>
   -------------------------------------------------------------------------*)  

 PROCEDURE [WINDOWS] AboutDlg* (hDlg : Windows.HWND;
                                msg : Windows.WORD;
                                wParam : Windows.WORD;
                                lParam : LONGINT) : Windows.BOOL;
  VAR dummy : LONGINT;
  BEGIN
   CASE msg OF 
      Windows.WM_INITDIALOG:
       dummy := Windows.SetTimer (hDlg, 0, 5000, Windows.NULL);
       RETURN Windows.true;

    | Windows.WM_COMMAND:
       IF (wParam = Windows.IDOK) OR   (* fuer den OK-Button *)
          (wParam = Windows.IDCANCEL)  (* fuer Close-Button  *)
        THEN 
         dummy := Windows.KillTimer (hDlg, 0);
         Windows.EndDialog (hDlg, Windows.true);
       END;

       RETURN Windows.true;
     
     | Windows.WM_TIMER:
        INC (timer);
        timer := timer MOD 5;
        dummy := Windows.SendDlgItemMessage (
                  hDlg,
                  Windows.IDOK,
                  Windows.WM_SETTEXT,
                  0,
                  SYSTEM.ADR (text[timer]));
        RETURN Windows.true;
        
    ELSE
   END;
   
   RETURN Windows.false;
  END AboutDlg;
  

(*----------------------*)
(* Modulinitialisierung *)

BEGIN
 timer := 0;
 text[0] := "Empty Me!";
 text[1] := "OK";
 text[2] := "Try to push me!";
 text[3] := "I don't bite!";
 text[4] := "Ohhh...";
END About.

(****************************************************************************)

