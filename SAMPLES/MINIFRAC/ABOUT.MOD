(* ======================================================================== *)
(* Projekt Minifrac                                                         *)
(*                                                                          *)
(* Fallstudie Betriebssysteme (Windowsprogrammierung unter Oberon-2         *)
(*                                                                          *)
(* Autoren:                                                                 *)
(*          Richard Beitelmair   Matr.Nr.: 9155387 /880   SS1995            *)
(*          Michael Trauner      Matr.Nr.  9356714 /881   SS1996            *)
(*          Peter   Winter       Matr.Nr.: 9355148 /881   SS1996            *)
(*                                                                          *)
(* LVA-Leiter:                                                              *)
(*          Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at           *)
(*                                                                          *)
(* Sprache:                                                                 *)
(*          Pow! 3.0 beta                                                   *)
(*          Oberon-2 Compiler Version 1.18 Beta5                            *)
(*                                                                          *)
(* Datum der letzten Aenderung: 24.09.1996                                  *)
(* ------------------------------------------------------------------------ *)
(* About.mod                                                                *)
(*   definiert den About-Dialog                                             *)
(*   beinhaltet wechselnden Schriftzug im Bestaetigungsbutton               *)
(* ======================================================================== *)

MODULE About;

(* 
 * notwendige Module importieren
 *) 
IMPORT Win := Windows,
       Sys := SYSTEM;
 
 
(*
 * globale Variablen
 *)
VAR timer : INTEGER;
    text  : ARRAY 3, 11 OF CHAR;
 
 
(*
 * About-Dialog
 *)
PROCEDURE [WINDOWS] AboutDlg* (hDlg   : Win.HWND;
                               msg    : Win.WORD;
                               wParam : Win.WORD;
                               lParam : LONGINT) : Win.BOOL;
VAR 
  dummy : LONGINT;
BEGIN
  CASE msg OF 
    Win.WM_INITDIALOG:
       dummy := Win.SetTimer (hDlg, 0, 3000, Win.NULL);
       RETURN Win.true;

  | Win.WM_COMMAND:
      IF ((wParam = Win.IDOK) OR (wParam = Win.IDCANCEL)) THEN  
        dummy := Win.KillTimer (hDlg, 0);
        Win.EndDialog (hDlg, Win.true);
      END;
      RETURN Win.true;
     
  | Win.WM_TIMER:
      INC (timer);
      timer := timer MOD 3;
      dummy := Win.SendDlgItemMessage (hDlg, Win.IDOK, Win.WM_SETTEXT,
                                       0, Sys.ADR(text[timer]));
      RETURN Win.true;
        
  ELSE
      (* keine Aktion *)
  END;

  RETURN Win.false;
END AboutDlg;
  

(* ***** *)


(*
* Modulinitialisierung 
*) 
BEGIN
 timer   := 0;
 text[0] := "OK";
 text[1] := "Hallo";
 text[2] := "neugierig?";
END About.

