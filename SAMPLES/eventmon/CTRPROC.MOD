(******************************************************************************)
(* MODULE:      CtrProc                                         ME - 29.06.96 *)
(* DESCRIPTION: Decoding procedures for control messages                      *)
(* LANGUAGE:    Oberon-2                                                      *)
(* COMPILER:    Robinson Associates Oberon-2 V1.18 beta6                      *)
(* WORKBENCH    POW 3.0 beta3                                                 *)
(* AUTHOR:      Martin Erdpresser, k3075e2@c210.edvz.uni-linz.ac.at (ME)      *)
(******************************************************************************)
(* DATE      AUTHOR  CHANGES                                                  *)
(* --------  ------  ---------------------------------------------------------*)
(* 29.05.96  ME      Initial Version                                          *)
(******************************************************************************)

MODULE CtrProc;

IMPORT W := Windows, Strings, Utils, SYSTEM, htConst;


CONST
  STR_LEN = 128;

(*==============< Decoding procedures for control messages   >================*)
(* This Application provides for button message group:                        *)
(*                BM_GETCHECK    (using default)                              *)
(*                BM_SETCHECK                                                 *)
(*                WM_GETSTATE    (using default)                              *)
(*                WM_SETSTATE                                                 *)
(*                WM_SETSTYLE                                                 *)
(*============================================================================*)


(*============================================================================*)
(* PURPOSE:  Decoding procedure for BM_SETCHECK                               *)
(*                                                                            *)
(* COMMENTS: An application sends a BM_SETCHECK message to set the            *)
(*           check state of a button.                                         *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) fCheck: check state                       *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_BM_SETCHECK*(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," fCheck:");
  IF (wParam = 0) THEN
    Strings.Append(str,"unchecked")
  ELSIF (wParam = 1) THEN
    Strings.Append(str,"checked")
  ELSIF (wParam = 2) THEN
    Strings.Append(str,"indeterminate")
  ELSE
    Strings.Append(str,"unknown"); 
  END;
  Strings.Append(str," (="); numStr := "";    
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);
  Strings.AppendChar(str,")")
END Proc_BM_SETCHECK;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for BM_SETSTATE                               *)
(*                                                                            *)
(* COMMENTS: An application sends a BM_SETSTATE message to set the            *)
(*           highlight state of a button.                                     *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) fState: highlight state                   *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_BM_SETSTATE*(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);

BEGIN
  Strings.Append(str," fState:");
  IF (wParam # W.NULL) THEN
    Strings.Append(str,"TRUE (=highlight)")
  ELSE
    Strings.Append(str,"FALSE (=remove highlight)")
  END
END Proc_BM_SETSTATE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for BM_SETSTYLE                               *)
(*                                                                            *)
(* COMMENTS: An application sends a BM_SETSTYLE message to change the         *)
(*           style of a button.                                               *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam =  (WPARAM) LOWORD(dwStyle): style                   *)
(* lParam         lParam =  MAKELPARAM(fRedraw, 0): redraw flag               *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_BM_SETSTYLE*(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," dwStyle"); numStr := "";    
  Strings.HexStr(wParam,numStr); Strings.Append(str,numStr);
  Strings.Append(str," fRedraw:");
  IF (Utils.LoWord(lParam) # W.NULL) THEN
    Strings.Append(str,"TRUE (=redraw)")
  ELSE
    Strings.Append(str,"FALSE (=don't redraw)")
  END
END Proc_BM_SETSTYLE;


(*============================================================================*)
(* This Application provides for combo-box message group:                     *)
(*                CB_GETEDITSEL      (using default)                          *)
(*                CB_LIMITTEXT                                                *)
(*                CB_SETEDITSEL                                               *)
(*                CB_ADDSTRING                                                *)
(*                CB_DELETESTRING                                             *)
(*                CB_DIR                                                      *)
(*                CB_GETCOUNT        (using default)                          *)
(*                CB_GETCURSEL       (using default)                          *)
(*                CB_GETLBTEXT                                                *)
(*                CB_GETLBTEXTLEN                                             *)
(*                CB_INSERTSTRING                                             *)
(*                CB_RESETCONTENT    (using default)                          *)
(*                CB_FINDSTRING                                               *)
(*                CB_SELECTSTRING                                             *)
(*                CB_SETCURSEL                                                *)
(*                CB_SHOWDROPDOWN                                             *)
(*                CB_GETITEMDATA                                              *)
(*                CB_SETITEMDATA                                              *)
(*                CB_GETDROPPEDCONTROLRECT                                    *)
(*                CB_FINDSTRINGEXACT                                          *)
(*                CB_GETDROPPEDSTATE (using default)                          *)
(*                CB_GETEXTENDEDUI                                            *)
(*                CB_GETITEMHEIGHT                                            *)
(*                CB_SETITEMHEIGHT                                            *)
(*============================================================================*)


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_LIMITTEXT                              *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_LIMITTEXT message to limit the length  *)
(*           of the text that the user may type in the edit control of        *)
(*           a combo box.                                                     *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) cchLimit: maximum number of characters    *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_LIMITTEXT*(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," cchLimit:"); numStr := "";    
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);
END Proc_CB_LIMITTEXT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_SETEDITSEL                             *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_SETEDITSEL message to select characters*)
(*           in the edit control of a combo box.                              *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = 0: not used, must be zero                          *)
(* lParam         lParam = MAKELPARAM((ichStart),(ichEnd)):start,end positions*)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_SETEDITSEL*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," ichStart:"); numStr := "";    
  Strings.Str(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr);
  Strings.Append(str," ichEnd:"); numStr := "";    
  Strings.Str(Utils.HiWord(lParam),numStr); Strings.Append(str,numStr); 
END Proc_CB_SETEDITSEL;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_ADDSTRING                              *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_ADDSTRING message to add a string to   *)
(*           the list box of a combo box. If the combo box does not have the  *)
(*           CBS_SORT style, the string is added to the end of the list.      *)
(*           Otherwise, the string is inserted into the list and the list     *)
(*           is sorted.                                                       *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = 0: not used, must be zero                          *)
(* lParam         lParam = (LPARAM) (LPCSTR) lpsz: address of string to add   *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_ADDSTRING*(wParam : W.WPARAM; 
                                 lParam : W.LPARAM;
                                 VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
  r : LONGINT;

BEGIN
  Strings.Append(str," lpsz:"); numStr := "";          
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr);
  numStr := ""; r := W.lstrcpy(SYSTEM.ADR(numStr),lParam);
  IF (r # W.NULL) THEN
    Strings.Append(str,' ("'); 
    Strings.Append(str,numStr);
    Strings.Append(str,'")') 
  END  
END Proc_CB_ADDSTRING;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_DELETESTRING                           *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_DELETESTRING message to delete a       *)
(*           string in the list box of a combo box.                           *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item to delete                     *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_DELETESTRING*(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," index:"); numStr := "";    
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);
END Proc_CB_DELETESTRING;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_DIR                                    *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_DIR message to add a list of filenames *)
(*           to the list box of a combo box.                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) (UINT) uAttrs: file attributes            *)
(* lParam         lParam = (LPARAM) (LPCSTR) lpszFileSpec: address of filename*)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_DIR*(wParam : W.WPARAM; 
                       lParam : W.LPARAM;
                       VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  r : LONGINT;
  
BEGIN
  Strings.Append(str," uAttrs:"); numStr := "";          
  Strings.HexStr(wParam,numStr); Strings.Append(str,numStr);

  Strings.Append(str," lpsz:"); numStr := "";          
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr);
  numStr := ""; r := W.lstrcpy(SYSTEM.ADR(numStr),lParam);
  IF (r # W.NULL) THEN
    Strings.Append(str,' ("'); 
    Strings.Append(str,numStr);
    Strings.Append(str,'")') 
  END  
END Proc_CB_DIR;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_GETLBTEXT                              *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_GETLBTEXT message to retrieve a string *)
(*           from the list box of a combo box.                                *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = (LPARAM) (LPCSTR) lpszBuffer: address of buffer    *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_GETLBTEXT*(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  
BEGIN
  Strings.Append(str," index:"); numStr := "";          
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);

  Strings.Append(str," lpszBuffer:"); numStr := "";          
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr);
END Proc_CB_GETLBTEXT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_GETLBTEXTLEN                           *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_GETLBTEXTLEN message to retrieve the   *)
(*           length of a string in the list box of a combo box.               *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_GETLBTEXTLEN*(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  
BEGIN
  Strings.Append(str," index:"); numStr := "";          
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);
END Proc_CB_GETLBTEXTLEN;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_INSERTSTRING                           *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_INSERTSTRING message to insert a       *)
(*           string into the list box of a combo box. Unlike the CB_ADDSTRING *)
(*           message, the CB_INSERTSTRING message does not cause a list with  *)
(*           the CBS_SORT style to be sorted.                                 *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = (LPARAM) (LPCSTR) lpsz: address of string to insert*)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_INSERTSTRING*(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  r : LONGINT;
  
BEGIN
  Strings.Append(str," index:"); numStr := "";          
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);

  Strings.Append(str," lpsz:"); numStr := "";          
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr);
  numStr := ""; r := W.lstrcpy(SYSTEM.ADR(numStr),lParam);
  IF (r # W.NULL) THEN
    Strings.Append(str,' ("'); 
    Strings.Append(str,numStr);
    Strings.Append(str,'")') 
  END  
END Proc_CB_INSERTSTRING;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_FINDSTRING                             *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_FINDSTRING message to search the list  *)
(*           box of a combo box for an item that begins with the characters   *)
(*           in a specified string.                                           *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) indexStart: start index                   *)
(* lParam         lParam = (LPARAM) (LPCSTR) lpszFind:addr. of prefix string  *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_FINDSTRING*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  r : LONGINT;
  
BEGIN
  Strings.Append(str," indexStart:"); numStr := "";          
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);

  Strings.Append(str," lpszFind:"); numStr := "";          
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr);
  numStr := ""; r := W.lstrcpy(SYSTEM.ADR(numStr),lParam);
  IF (r # W.NULL) THEN
    Strings.Append(str,' ("'); 
    Strings.Append(str,numStr);
    Strings.Append(str,'")') 
  END  
END Proc_CB_FINDSTRING;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_SELECTSTRING                           *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_SELECTSTRING message to search the     *)
(*           list box of a combo box for an item that begins with the         *)
(*           characters in a specified string. If a matching item is found,   *)
(*           the item is selected and copied to the edit control.             *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) indexStart: start index                   *)
(* lParam         lParam = (LPARAM) (LPCSTR) lpszSelect: addr. of prefix str. *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_SELECTSTRING*(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  r : LONGINT;
  
BEGIN
  Strings.Append(str," indexStart:"); numStr := "";          
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);

  Strings.Append(str," lpszSelect:"); numStr := "";          
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr);
  numStr := ""; r := W.lstrcpy(SYSTEM.ADR(numStr),lParam);
  IF (r # W.NULL) THEN
    Strings.Append(str,' ("'); 
    Strings.Append(str,numStr);
    Strings.Append(str,'")') 
  END  
END Proc_CB_SELECTSTRING;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_SETCURSEL                              *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_SETCURSEL message to select a string   *)
(*           in the list box of a combo box. If necessary, the list box       *)
(*           scrolls the string into view (if the list box is visible).       *)
(*           The text in the edit control of the combo box is changed to      *)
(*           reflect the new selection. Any previous selection in the list    *)
(*           box is removed.                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_SETCURSEL*(wParam : W.WPARAM; 
                             lParam : W.LPARAM;
                             VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_DELETESTRING(wParam,lParam,str)         (* same output, so use this *)
END Proc_CB_SETCURSEL;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_SHOWDROPDOWN                           *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_SHOWDROPDOWN message to show or hide   *)
(*           the list box of a combo box that has the CBS_DROPDOWN or         *)
(*           CBS_DROPDOWNLIST style.                                          *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) (BOOL) fShow: the show/hide flag          *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_SHOWDROPDOWN*(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);
BEGIN
  Strings.Append(str," fShow:");
  IF (wParam = W.true) THEN
    Strings.Append(str,"TRUE (=show)")
  ELSE
    Strings.Append(str,"FALSE (=hide)")
  END
END Proc_CB_SHOWDROPDOWN;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_GETITEMDATA                            *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_GETITEMDATA message to a combo box to  *)
(*           retrieve the application-supplied doubleword value associated    *)
(*           with the specified item in the combo box.                        *)
(*           (This is the value in the lParam parameter of a                  *)
(*            CB_SETITEMDATA message.)                                        *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_GETITEMDATA*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_DELETESTRING(wParam,lParam,str)         (* same output, so use this *)
END Proc_CB_GETITEMDATA;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_SETITEMDATA                            *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_SETITEMDATA message to set the         *)
(*           doubleword value associated with the specified item in a         *)
(*           combo box.                                                       *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = (LPARAM) (DWORD) dwData: item data                 *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_SETITEMDATA*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  
BEGIN
  Strings.Append(str," index:"); numStr := "";          
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);
  Strings.Append(str," dwData:"); numStr := "";          
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr);
END Proc_CB_SETITEMDATA;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_GETDROPPEDCONTROLRECT                  *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_GETDROPPEDCONTROLRECT message to       *)
(*           retrieve the screen coordinates of the visible (dropped-down)    *)
(*           list box of a combo box.                                         *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = 0: not used, must be zero                          *)
(* lParam         lParam = (LPARAM) (RECT FAR* ) lprc: addr. of RECT structure*)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_GETDROPPEDCONTROLRECT*(wParam : W.WPARAM; 
                                         lParam : W.LPARAM;
                                         VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  
BEGIN
  Strings.Append(str," lprc:"); numStr := "";          
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr);
END Proc_CB_GETDROPPEDCONTROLRECT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_FINDSTRINGEXACT                        *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_FINDSTRINGEXACT message to find the    *)
(*           first list box string (in a combo box) that matches the string   *)
(*           specified in the lpszFind parameter.                             *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) indexStart: start index                   *)
(* lParam         lParam = (LPARAM) (LPCSTR) lpszFind:addr. of prefix string  *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_FINDSTRINGEXACT*(wParam : W.WPARAM; 
                                   lParam : W.LPARAM;
                                   VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_FINDSTRING(wParam,lParam,str)           (* same output, so use this *)
END Proc_CB_FINDSTRINGEXACT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_GETITEMHEIGHT                          *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_GETITEMHEIGHT message to retrieve the  *)
(*           height of list items in a combo box.                             *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_GETITEMHEIGHT*(wParam : W.WPARAM; 
                                 lParam : W.LPARAM;
                                 VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_DELETESTRING(wParam,lParam,str)         (* same output, so use this *)
END Proc_CB_GETITEMHEIGHT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_SETEXTENDEDUI                          *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_SETEXTENDEDUI message to select either *)
(*           the default user interface or the extended user interface for a  *)
(*           combo box that has the CBS_DROPDOWN or CBS_DROPDOWNLIST style.   *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) (BOOL) fExtended: extended UI flag        *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_SETEXTENDEDUI*(wParam : W.WPARAM; 
                                 lParam : W.LPARAM;
                                 VAR str : ARRAY OF CHAR);
BEGIN
  Strings.Append(str," fExtendend:");
  IF (wParam = W.true) THEN
    Strings.Append(str,"TRUE (=select extended UI)")
  ELSE
    Strings.Append(str,"FALSE (=select standard UI)")
  END
END Proc_CB_SETEXTENDEDUI;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for CB_SETITEMHEIGHT                          *)
(*                                                                            *)
(* COMMENTS: An application sends a CB_SETITEMHEIGHT message to set the       *)
(*           height of list items in a combo box or the height of the         *)
(*           edit-control (or static-text) portion of a combo box.            *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = (LPARAM) (int) height: item height                 *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_CB_SETITEMHEIGHT*(wParam : W.WPARAM; 
                                 lParam : W.LPARAM;
                                 VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  
BEGIN
  Strings.Append(str," index:"); numStr := "";          
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);
  Strings.Append(str," height:"); numStr := "";          
  Strings.Str(lParam,numStr); Strings.Append(str,numStr)
END Proc_CB_SETITEMHEIGHT;


(*============================================================================*)
(* This Application provides for listbox message group:                       *)
(*                LB_ADDSTRING                                                *)
(*                LB_INSERTSTRING                                             *)
(*                LB_DELETESTRING                                             *)
(*                LB_RESETCONTENT        (using default)                      *)
(*                LB_SETSEL                                                   *)
(*                LB_SETCURSEL           (using default)                      *)
(*                LB_GETSEL                                                   *)
(*                LB_GETCURSEL                                                *)
(*                LB_GETTEXT                                                  *)
(*                LB_GETTEXTLEN                                               *)
(*                LB_GETCOUNT            (using default)                      *)
(*                LB_SELECTSTRING                                             *)
(*                LB_DIR                                                      *)
(*                LB_GETTOPINDEX         (using default)                      *)
(*                LB_FINDSTRING                                               *)
(*                LB_GETSELCOUNT                                              *)
(*                LB_GETSELITEMS                                              *)
(*                LB_SETTABSTOPS                                              *)
(*                LB_GETHORIZONTALEXTENT (using default)                      *)
(*                LB_SETHORIZONTALEXTENT                                      *)
(*                LB_SETCOLUMNWIDTH                                           *)
(*                LB_SETTOPINDEX                                              *)
(*                LB_GETITEMRECT                                              *)
(*                LB_GETITEMDATA                                              *)
(*                LB_SETITEMDATA                                              *)
(*                LB_SELITEMRANGE                                             *)
(*                LB_FINDSTRINGEXACT                                          *)
(*                LB_GETCARETINDEX       (using default)                      *)
(*                LB_GETITEMHEIGHT                                            *)
(*                LB_SETCARETINDEX                                            *)
(*                LB_SETITEMHEIGHT                                            *)
(*============================================================================*)


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_ADDSTRING                              *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_ADDSTRING message to add a string to  *)
(*           a list box. If the list box does not have the CBS_SORT style,    *)
(*           the string is added to the end of the list. Otherwise, the string*)
(*           is inserted into the list and the list is sorted.                *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = 0: not used, must be zero                          *)
(* lParam         lParam = (LPARAM) (LPCSTR) lpsz: address of string to add   *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_ADDSTRING*(wParam : W.WPARAM; 
                             lParam : W.LPARAM;
                             VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_ADDSTRING(wParam,lParam,str);           (* similar to combobox-proc *)
END Proc_LB_ADDSTRING;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_INSERTSTRING                           *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_INSERTSTRING message to insert a      *)
(*           string into a list box. Unlike the LB_ADDSTRING message, the     *)
(*           LB_INSERTSTRING message does not cause a list with the LBS_SORT  *)
(*           style to be sorted.                                              *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = (LPARAM) (LPCSTR) lpsz: address of string to insert*)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_INSERTSTRING*(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_INSERTSTRING(wParam,lParam,str);        (* similar to combobox-proc *)
END Proc_LB_INSERTSTRING;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_DELETESTRING                           *)
(*                                                                            *)
(* COMMENTS: An application sends a LB_DELETESTRING message to delete a       *)
(*           string in a list box.                                            *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item to delete                     *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_DELETESTRING*(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_DELETESTRING(wParam,lParam,str);        (* similar to combobox-proc *)
END Proc_LB_DELETESTRING;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_SETSEL                                 *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_SETSEL message to select a string in  *)
(*           a multiple-selection list box.                                   *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) (BOOL) fSelect: selection flag            *)
(* lParam         lParam = MAKELPARAM(index, 0): item index                   *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_SETSEL*(wParam : W.WPARAM; 
                          lParam : W.LPARAM;
                          VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," fSelect:");
  IF (wParam = W.true) THEN
    Strings.Append(str,"TRUE (=selected)")
  ELSE
    Strings.Append(str,"FALSE (=deselected)")
  END;
  Strings.Append(str," index:"); numStr := "";    
  Strings.Str(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr);
END Proc_LB_SETSEL;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_SETCURSEL                              *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_SETCURSEL message to select a string  *)
(*           and scroll it into view, if necessary. When the new string is    *)
(*           selected, the list box removes the highlight from the previously *)
(*           selected string.                                                 *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_SETCURSEL*(wParam : W.WPARAM; 
                             lParam : W.LPARAM;
                             VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_SETCURSEL(wParam,lParam,str)            (* similar to combobox-proc *)
END Proc_LB_SETCURSEL;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_GETSEL                                 *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_GETSEL message to retrieve the        *)
(*           selection state of an item.                                      *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_GETSEL*(wParam : W.WPARAM; 
                          lParam : W.LPARAM;
                          VAR str : ARRAY OF CHAR);
BEGIN
  Proc_LB_SETCURSEL(wParam,lParam,str)            (* same output, so use this *) 
END Proc_LB_GETSEL;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_GETTEXT                                *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_GETTEXT message to retrieve a string  *)
(*           from a list box.                                                 *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = (LPARAM) (LPCSTR) lpszBuffer: address of buffer    *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_GETTEXT*(wParam : W.WPARAM; 
                           lParam : W.LPARAM;
                           VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_GETLBTEXT(wParam,lParam,str)            (* same output, so use this *)
END Proc_LB_GETTEXT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_GETTEXTLEN                             *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_GETTEXTLEN message to retrieve the    *)
(*           length of a string in a list box.                                *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_GETTEXTLEN*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_GETLBTEXTLEN(wParam,lParam,str)         (* same output, so use this *)
END Proc_LB_GETTEXTLEN;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_SELECTSTRING                           *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_SELECTSTRING message to search a list *)
(*           box for an item that begins with the characters in a specified   *)
(*           string. If a matching item is found, the item is selected.       *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) indexStart: start index                   *)
(* lParam         lParam = (LPARAM) (LPCSTR) lpszSelect: addr. of prefix str. *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_SELECTSTRING*(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_SELECTSTRING(wParam,lParam,str)         (* similar to combobox-proc *)
END Proc_LB_SELECTSTRING;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_DIR                                    *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_DIR message to add a list of          *)
(*           filenames to a list box.                                         *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) (UINT) uAttrs: file attributes            *)
(* lParam         lParam = (LPARAM) (LPCSTR) lpszFileSpec: address of filename*)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_DIR*(wParam : W.WPARAM; 
                       lParam : W.LPARAM;
                       VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_DIR(wParam,lParam,str)                  (* similar to combobox-proc *)
END Proc_LB_DIR;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_FINDSTRING                             *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_FINDSTRING message to search a list   *)
(*           box for an item that begins with the characters in a specified   *)
(*           string.                                                          *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) indexStart: start index                   *)
(* lParam         lParam = (LPARAM) (LPCSTR) lpszSelect: addr. of prefix str. *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_FINDSTRING*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_FINDSTRING(wParam,lParam,str)           (* similar to combobox-proc *)
END Proc_LB_FINDSTRING;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_GETSELITEMS                            *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_GETSELITEMS message to fill a buffer  *)
(*           with an array of integers that specify the item numbers of       *)
(*           selected items in a multiple-selection list box.                 *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) cItems: maximum number of items           *)
(* lParam         lParam = (LPARAM) (int FAR* ) lpItems: address of buffer    *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_GETSELITEMS*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  
BEGIN
  Strings.Append(str," cItems:"); numStr := "";          
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);
  Strings.Append(str," lpItems:"); numStr := "";          
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr)
END Proc_LB_GETSELITEMS;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_SETTABSTOPS                            *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_SETTABSTOPS message to set the        *)
(*           tab-stop positions in a list box.                                *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) cTabs: number of tab stops                *)
(* lParam         lParam = (LPARAM) (int FAR* ) lpTabs: address tab-stop array*)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_SETTABSTOPS*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  
BEGIN
  Strings.Append(str," cTabs:"); numStr := "";          
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);
  Strings.Append(str," lpTabs:"); numStr := "";          
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr)
END Proc_LB_SETTABSTOPS;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_SETHORIZONTALEXTENT                    *)
(*                                                                            *)
(* COMMENTS: An application sends the LB_SETHORIZONTALEXTENT message to set   *)
(*           the width, in pixels, by which a list box can be scrolled        *)
(*           horizontally. If the size of the list box is smaller than this   *)
(*           value, the horizontal scroll bar horizontally scrolls items in   *)
(*           the list box. If the size of the list box is equal to or greater *)
(*           than this value, the horizontal scroll bar is hidden.            *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) cxExtent: horizontal scroll width         *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_SETHORIZONTALEXTENT*(wParam : W.WPARAM; 
                                       lParam : W.LPARAM;
                                       VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," cxExtent:"); numStr := "";    
  Strings.Str(wParam,numStr); Strings.Append(str,numStr)
END Proc_LB_SETHORIZONTALEXTENT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_SETCOLUMNWIDTH                         *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_SETCOLUMNWIDTH message to a           *)
(*           multiple-column list box (created with the LBS_MULTICOLUMN style)*)
(*           to set the width, in pixels, of all columns in the list box.     *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) cxColumn: column width                    *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_SETCOLUMNWIDTH*(wParam : W.WPARAM; 
                                       lParam : W.LPARAM;
                                       VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," cxColumn:"); numStr := "";    
  Strings.Str(wParam,numStr); Strings.Append(str,numStr)
END Proc_LB_SETCOLUMNWIDTH;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_SETTOPINDEX                            *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_SETTOPINDEX message to ensure that a  *)
(*           particular item in a list box is visible.                        *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_SETTOPINDEX*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);
BEGIN
  Proc_LB_GETTEXTLEN(wParam,lParam,str);          (* this works too           *)
END Proc_LB_SETTOPINDEX;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_GETITEMRECT                            *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_GETITEMRECT message to retrieve the   *)
(*           dimensions of the rectangle that bounds an item as it is         *)
(*           currently displayed in the list box window.                      *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = (LPARAM) (RECT FAR* ) lprc: addr. of RECT structure*)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_GETITEMRECT*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  
BEGIN
  Strings.Append(str," index:"); numStr := "";          
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);
  Strings.Append(str," lprc:"); numStr := "";          
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr);
END Proc_LB_GETITEMRECT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_GETITEMDATA                            *)
(*                                                                            *)
(* COMMENTS: An application sends the LB_GETITEMDATA message to retrieve the  *)
(*           application-supplied doubleword value associated with the        *)
(*           specified item in a list box. (This is the value of the lParam   *)
(*           parameter of an LB_SETITEMDATA message.)                         *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_GETITEMDATA*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_GETITEMDATA(wParam,lParam,str)     
END Proc_LB_GETITEMDATA;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_SETITEMDATA                            *)
(*                                                                            *)
(* COMMENTS: An application sends the LB_SETITEMDATA message to set a         *)
(*           doubleword value associated with the specified item in a list box*)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = (LPARAM) dwData: value to associate with item      *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_SETITEMDATA*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_SETITEMDATA(wParam,lParam,str)     
END Proc_LB_SETITEMDATA;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_SELITEMRANGE                           *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_SELITEMRANGE message to select one or *)
(*           more consecutive items in a multiple-selection list box.         *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) (BOOL) fSelect: selection flag            *)
(* lParam         lParam = MAKELPARAM(wFirst, wLast): first and last items    *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_SELITEMRANGE*(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," fSelect:");
  IF (wParam = W.true) THEN
    Strings.Append(str,"TRUE (=selected)")
  ELSE
    Strings.Append(str,"FALSE (=deselected)")
  END;
  Strings.Append(str," wFirst:"); numStr := "";    
  Strings.Str(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr);
  Strings.Append(str," wLast:"); numStr := "";    
  Strings.Str(Utils.HiWord(lParam),numStr); Strings.Append(str,numStr); 
END Proc_LB_SELITEMRANGE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_FINDSTRINGEXACT                        *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_FINDSTRINGEXACT message to find the   *)
(*           first list box string that matches the string specified in the   *)
(*           lpszFind parameter.                                              *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) indexStart: item before start of search   *)
(* lParam         lParam = (LPARAM) (LPCSTR) lpszFind: addr. of search string *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_FINDSTRINGEXACT*(wParam : W.WPARAM; 
                                   lParam : W.LPARAM;
                                   VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_FINDSTRINGEXACT(wParam,lParam,str)        
END Proc_LB_FINDSTRINGEXACT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_GETITEMHEIGHT                          *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_GETITEMHEIGHT message to determine    *)
(*           the height of items in a list box.                               *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_GETITEMHEIGHT*(wParam : W.WPARAM; 
                                 lParam : W.LPARAM;
                                 VAR str : ARRAY OF CHAR);
BEGIN
  Proc_CB_GETITEMHEIGHT(wParam,lParam,str)         
END Proc_LB_GETITEMHEIGHT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_SETCARETINDEX                          *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_SETCARETINDEX message to set the      *)
(*           focus rectangle to the item at the specified index in a          *)
(*           multiple-selection list box. If the item is not visible, it is   *)
(*           scrolled into view.                                              *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = MAKELPARAM(fScroll, 0): flag for scrolling item    *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_SETCARETINDEX*(wParam : W.WPARAM; 
                                 lParam : W.LPARAM;
                                 VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," index:"); numStr := "";    
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);
  Strings.Append(str," fScroll:");
  IF (lParam # W.NULL) THEN
    Strings.Append(str,"TRUE")
  ELSE
    Strings.Append(str,"FALSE")
  END;
END Proc_LB_SETCARETINDEX;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for LB_SETITEMHEIGHT                          *)
(*                                                                            *)
(* COMMENTS: An application sends an LB_SETITEMHEIGHT message to set the      *)
(*           height of items in a list box. If the list box has the           *)
(*           LBS_OWNERDRAWVARIABLE style, this message sets the height of the *)
(*           item specified by the wParam parameter. Otherwise, this message  *)
(*           sets the height of all items in the list box.                    *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) index: item index                         *)
(* lParam         lParam = MAKELPARAM(cyItem, 0): item height                 *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_LB_SETITEMHEIGHT*(wParam : W.WPARAM; 
                                 lParam : W.LPARAM;
                                 VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  
BEGIN
  Strings.Append(str," index:"); numStr := "";          
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);
  Strings.Append(str," cyItem:"); numStr := "";          
  Strings.Str(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr)
END Proc_LB_SETITEMHEIGHT;


BEGIN
END CtrProc.
