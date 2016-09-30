(******************************************************************************)
(* MODULE:      HtConst                                         ME - 29.06.96 *)
(* DESCRIPTION: Defines hit- and scroll code string table                     *)
(* LANGUAGE:    Oberon-2                                                      *)
(* COMPILER:    Robinson Associates Oberon-2 V1.18 beta6                      *)
(* WORKBENCH    POW 3.0 beta3                                                 *)
(* AUTHOR:      Martin Erdpresser, k3075e2@c210.edvz.uni-linz.ac.at (ME)      *)
(******************************************************************************)
(* DATE      AUTHOR  CHANGES                                                  *)
(* --------  ------  ---------------------------------------------------------*)
(* 29.05.96  ME      Initial Version                                          *)
(******************************************************************************)

MODULE HtConst;

VAR 
  i : INTEGER;
  htTab- : ARRAY 256 OF ARRAY 14 OF CHAR;   (* string table: hHitCode         *)
  sbHscrTab-, 
  sbVscrTab- : ARRAY 9 OF ARRAY 18 OF CHAR; (* string table: scroll codes     *)

BEGIN

  (*-- Init string tables --*)
  FOR i := 0 TO LEN(htTab)-1 DO htTab[i] := "" END;
  FOR i := 0 TO LEN(sbHscrTab)-1 DO sbHscrTab[i] := "" END;
  FOR i := 0 TO LEN(sbVscrTab)-1 DO sbVscrTab[i] := "" END;
  
  (*----------< Hit-Test codes >----------------------------------------------*) 
  htTab[0]   := "HTNOWHERE";
  htTab[1]   := "HTCLIENT";
  htTab[2]   := "HTCAPTION";
  htTab[3]   := "HTSYSMENU";
  htTab[4]   := "HTGROWBOX";
  htTab[5]   := "HTMENU";
  htTab[6]   := "HTHSCROLL";
  htTab[7]   := "HTVSCROLL";
  htTab[8]   := "HTREDUCE";
  htTab[9]   := "HTZOOM";
  htTab[10]  := "HTLEFT";
  htTab[11]  := "HTRIGHT";
  htTab[12]  := "HTTOP";
  htTab[13]  := "HTTOPLEFT";
  htTab[14]  := "HTTOPRIGHT"; 
  htTab[15]  := "HTBOTTOM";
  htTab[16]  := "HTBOTTOMLEFT";
  htTab[17]  := "HTBOTTOMRIGHT";
  htTab[18]  := "HTBORDER";
  htTab[19]  := "HTOBJECT";   (* new *) 
  htTab[20]  := "HTCLOSE";    (* new *)
  htTab[21]  := "HTHELP";     (* new *) 
  htTab[254] := "HTERROR";
  htTab[255] := "HTTRANSPARENT";

  (*----------< Horizontal scroll bar codes >---------------------------------*) 
  sbHscrTab[7] := "SB_BOTTOM";
  sbHscrTab[8] := "SB_ENDSCROLL";
  sbHscrTab[0] := "SB_LINELEFT";
  sbHscrTab[1] := "SB_LINERIGHT";
  sbHscrTab[2] := "SB_PAGELEFT";
  sbHscrTab[3] := "SB_PAGERIGHT";
  sbHscrTab[4] := "SB_THUMBPOSITION";
  sbHscrTab[5] := "SB_THUMBTRACK";
  sbHscrTab[6] := "SB_TOP";

  (*----------< Vertical scroll bar codes >-----------------------------------*) 
  sbVscrTab[7] := "SB_BOTTOM";
  sbVscrTab[8] := "SB_ENDSCROLL";
  sbVscrTab[1] := "SB_LINEDOWN";
  sbVscrTab[0] := "SB_LINEUP";
  sbVscrTab[3] := "SB_PAGEDOWN";
  sbVscrTab[2] := "SB_PAGEUP";
  sbVscrTab[4] := "SB_THUMBPOSITION";
  sbVscrTab[5] := "SB_THUMBTRACK";
  sbVscrTab[6] := "SB_TOP";

END HtConst.
