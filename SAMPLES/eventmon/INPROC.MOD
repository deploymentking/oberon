(******************************************************************************)
(* MODULE:      InProc                                          ME - 29.06.96 *)
(* DESCRIPTION: Decoding procedures for input messages                        *)
(* LANGUAGE:    Oberon-2                                                      *)
(* COMPILER:    Robinson Associates Oberon-2 V1.18 beta6                      *)
(* WORKBENCH    POW 3.0 beta3                                                 *)
(* AUTHOR:      Martin Erdpresser, k3075e2@c210.edvz.uni-linz.ac.at (ME)      *)
(******************************************************************************)
(* DATE      AUTHOR  CHANGES                                                  *)
(* --------  ------  ---------------------------------------------------------*)
(* 29.05.96  ME      Initial Version                                          *)
(******************************************************************************)

MODULE InProc;

IMPORT W := Windows, Strings, Utils;


CONST
  STR_LEN = 128;

VAR 
  i : INTEGER;
  vkTab : ARRAY 146 OF ARRAY 16 OF CHAR;   (* string table: virt. key-code    *)

(*==============< Decoding procedures for input messages >====================*)
(* This Application provides for input message group:                         *)
(*                WM_CHAR                                                     *)
(*                WM_CHARTOITEM                                               *)
(*                WM_COMMAND                                                  *)
(*                WM_DEADCHAR                                                 *)
(*                WM_KEYDOWN                                                  *)
(*                WM_KEYUP                                                    *)
(*                WM_MENUSELECT                                               *)
(*                WM_MENUCHAR                                                 *)
(*                WM_PARENTNOTIFY                                             *)
(*                WM_SYSKEYDOWN                                               *)
(*                WM_SYSKEYUP                                                 *)
(*                WM_SYSCHAR                                                  *)
(*                WM_SYSDEADCHAR                                              *)
(*                WM_TIMER                                                    *)
(*                WM_VKEYTOITEM                                               *)
(*============================================================================*)


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_CHAR                                   *)
(*                                                                            *)
(* COMMENTS: The WM_CHAR message is sent when a WM_KEYUP message and a        *)
(*           WM_KEYDOWN message are translated. The WM_CHAR message contains  *)
(*           the value of the key being pressed or released.                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         nVKey = wParam: virtual-key code                            *)
(* lParam         dwKeyData = (DWORD) lParam: key data                        *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_CHAR*(wParam : W.WPARAM; 
                        lParam : W.LPARAM;
                        VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," VKey:");  
  IF (wParam >= W.VK_LBUTTON) & (wParam <= W.VK_SCROLL) & (vkTab[wParam] # "") THEN
    Strings.Append(str,vkTab[wParam])
  END;
  Strings.Append(str," ="); numStr := "";          
  Strings.HexStr(wParam,numStr); Strings.Append(str,numStr);       
  
  Strings.Append(str," dwKeyData:"); numStr := "";    
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr);
END Proc_WM_CHAR;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_CHARTOITEM                             *)
(*                                                                            *)
(* COMMENTS: The WM_CHARTOITEM message is sent by a list box with the         *)
(*           LBS_WANTKEYBOARDINPUT style to its owner in response to a        *)
(*           WM_CHAR message.                                                 *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         nKey = wParam: key value                                    *)
(* lParam         hwndListBox = (HWND) LOWORD(lParam): list box handle        *)
(*                iCaretPos = HIWORD(lParam): caret position                  *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_CHARTOITEM*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," nKey:"); numStr := "";          
  Strings.HexStr(wParam,numStr); Strings.Append(str,numStr);       

  Strings.Append(str," hwndListBox:"); numStr := "";          
  Strings.HexStr(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr);       
  
  Strings.Append(str," iCaretPos:"); numStr := "";    
  Strings.Str(Utils.HiWord(lParam),numStr); Strings.Append(str,numStr);
END Proc_WM_CHARTOITEM;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_COMMAND                                *)
(*                                                                            *)
(* COMMENTS: The WM_COMMAND message is sent to a window when the user selects *)
(*           an item from a menu, when a control sends a notification message *)
(*           to its parent window, or when an accelerator keystroke is        *)
(*           translated.                                                      *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         idItem = wParam: control or menu item identifier            *)
(* lParam         hwndCtl = (HWND) LOWORD(lParam): handle of control          *)
(*                wNotifyCode = HIWORD(lParam): notification message          *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_COMMAND*(wParam : W.WPARAM; 
                           lParam : W.LPARAM;
                           VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," idItem:"); numStr := "";          
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);       

  Strings.Append(str," hwndCtl:"); numStr := "";          
  Strings.HexStr(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr);       
  
  Strings.Append(str," wNotifyCode:"); numStr := "";    
  Strings.HexStr(Utils.HiWord(lParam),numStr); Strings.Append(str,numStr);
END Proc_WM_COMMAND;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_DEADCHAR                               *)
(*                                                                            *)
(* COMMENTS: The WM_DEADCHAR message is sent when a WM_KEYUP message and a    *)
(*           WM_KEYDOWN message are translated. It specifies the character    *)
(*           value of a dead key. A dead key is a key, such as the umlaut     *)
(*           (double-dot) character, that is combined with other characters   *)
(*           to form a composite character. For example, the umlaut-O         *)
(*           character consists of the dead key, umlaut, and the O key.       *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         nDeadKey = wParam: dead-key character value                 *)
(* lParam         dwKeyData = (DWORD) lParam: key data                        *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_DEADCHAR*(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," nDeadKey:"); numStr := "";          
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);       
  
  Strings.Append(str," dwKeyData:"); numStr := "";    
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr);
END Proc_WM_DEADCHAR;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_KEYDOWN                                *)
(*                                                                            *)
(* COMMENTS: The WM_KEYDOWN message is sent when a nonsystem key is pressed.  *)
(*           A nonsystem key is a key that is pressed when the ALT key is not *)
(*           pressed, or it is a key that is pressed when a window has the    *)
(*           input focus.                                                     *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         VKey = wParam: virtual-key code                             *)
(* lParam         dwKeyData = lParam: key data                                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_KEYDOWN*(wParam : W.WPARAM; 
                           lParam : W.LPARAM;
                           VAR str : ARRAY OF CHAR);
 
BEGIN
  Proc_WM_CHAR(wParam,lParam,str);            (* same output, so use this one *)
END Proc_WM_KEYDOWN;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_KEYUP                                  *)
(*                                                                            *)
(* COMMENTS: The WM_KEYUP message is sent when a nonsystem key is released.   *)
(*           A nonsystem key is a key that is pressed when the ALT key is not *)
(*           pressed, or it is a key that is pressed when a window has the    *)
(*           input focus.                                                     *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         VKey = wParam: virtual-key code                             *)
(* lParam         dwKeyData = lParam: key data                                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_KEYUP*(wParam : W.WPARAM; 
                         lParam : W.LPARAM;
                         VAR str : ARRAY OF CHAR);
 
BEGIN
  Proc_WM_CHAR(wParam,lParam,str);            (* same output, so use this one *)
END Proc_WM_KEYUP;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_MENUSELECT                             *)
(*                                                                            *)
(* COMMENTS: The WM_MENUSELECT message is sent to the window associated with  *)
(*           a menu when the user selects a menu item.                        *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wIDItem = wParam: item identifier or menu handle            *)
(* lParam         fwMenu = LOWORD(lParam): menu flags                         *)
(*                hmenu = (HMENU) HIWORD(lParam): handle of the menu          *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_MENUSELECT*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," IDItem:"); numStr := "";          
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);       

  Strings.Append(str," fwMenu:"); numStr := "";          
  Strings.HexStr(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr);       
  
  Strings.Append(str," hMenu:"); numStr := "";    
  Strings.HexStr(Utils.HiWord(lParam),numStr); Strings.Append(str,numStr);
END Proc_WM_MENUSELECT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_MENUCHAR                               *)
(*                                                                            *)
(* COMMENTS: The WM_MENUCHAR message is sent when the user presses the key    *)
(*           corresponding to a menu mnemonic character that doesn't match    *)
(*           any of the predefined mnemonics in the current menu. It is sent  *)
(*           to the window that owns the menu.                                *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         chUser = wParam: ASCII character                            *)
(* lParam         fMenu = LOWORD(lParam): menu flag                           *)
(*                hmenu = (HMENU) HIWORD(lParam): handle of the menu          *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_MENUCHAR*(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," chUser:"); Strings.AppendChar(str,CHR(wParam));       

  Strings.Append(str," fwMenu:"); 
  IF Utils.LoWord(lParam) = W.MF_POPUP THEN
    Strings.Append(str,"MF_POPUP")
  ELSIF Utils.LoWord(lParam) = W.MF_SYSMENU THEN
    Strings.Append(str,"MF_SYSMENU")
  ELSE
    numStr := ""; Strings.HexStr(Utils.LoWord(lParam),numStr); 
    Strings.Append(str,numStr);    
  END;
  
  Strings.Append(str," hMenu:"); numStr := "";    
  Strings.HexStr(Utils.HiWord(lParam),numStr); Strings.Append(str,numStr);
END Proc_WM_MENUCHAR;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_SYSKEYDOWN                             *)
(*                                                                            *)
(* COMMENTS: The WM_SYSKEYDOWN message is sent to the window with the input   *)
(*           focus when the user holds down the ALT key and then presses      *)
(*           another key. If no window currently has the input focus,         *)
(*           the WM_SYSKEYDOWN message is sent to the active window.          *)
(*           The window that receives the message can distinguish between     *)
(*           these two contexts by checking the context code in the           *)
(*           dwKeyData parameter.                                             *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         VKey = wParam: virtual-key code                             *)
(* lParam         dwKeyData = lParam: key data                                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_SYSKEYDOWN*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);
 
BEGIN
  Proc_WM_CHAR(wParam,lParam,str);            (* same output, so use this one *)
END Proc_WM_SYSKEYDOWN;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_SYSKEYUP                               *)
(*                                                                            *)
(* COMMENTS: The WM_SYSKEYUP message is sent to the window with the input     *)
(*           focus when the user releases a key that was pressed while the    *)
(*           ALT key was held down. If no window currently has the input      *)
(*           focus, the WM_SYSKEYUP message is sent to the active window.     *)
(*           The window that receives the message can distinguish between     *)
(*           these two contexts by checking the context code in the lParam.   *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         VKey = wParam: virtual-key code                             *)
(* lParam         dwKeyData = lParam: key data                                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_SYSKEYUP*(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);
 
BEGIN
  Proc_WM_CHAR(wParam,lParam,str);            (* same output, so use this one *)
END Proc_WM_SYSKEYUP;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_SYSCHAR                                *)
(*                                                                            *)
(* COMMENTS: The WM_SYSCHAR message is sent to the window with the input      *)
(*           focus when a WM_SYSKEYUP and a WM_SYSKEYDOWN message are         *)
(*           translated. It specifies the virtual-key code of the System-menu *)
(*           key. (The System menu is sometimes referred to as the            *)
(*           Control menu.)                                                   *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wKeyCode = wParam: ASCII key code                           *)
(* lParam         dwKeyData = lParam: key data                                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_SYSCHAR*(wParam : W.WPARAM; 
                           lParam : W.LPARAM;
                           VAR str : ARRAY OF CHAR); 
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," wKeyCode:"); Strings.AppendChar(str,CHR(wParam));       
  Strings.Append(str," (="); numStr := ""; 
  Strings.HexStr(wParam,numStr);Strings.Append(str,numStr);    
  Strings.AppendChar(str,")"); 

  Strings.Append(str," dwKeyData:"); numStr := "";    
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr)
END Proc_WM_SYSCHAR;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_SYSDEADCHAR                            *)
(*                                                                            *)
(* COMMENTS: The WM_SYSDEADCHAR message is sent to the window with the input  *)
(*           focus when WM_SYSKEYUP and WM_SYSKEYDOWN messages are translated.*)
(*           It specifies the character value of a dead key.                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wDeadKey = wParam: dead-key character                       *)
(* lParam         cRepeat = (int) LOWORD(lParam): repeat count                *)
(*                cAutoRepeat = HIWORD(lParam): auto-repeat count             *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_SYSDEADCHAR*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," wDeadKey:"); numStr := "";          
  Strings.Str(wParam,numStr); Strings.Append(str,numStr);       

  Strings.Append(str," cRepeat:"); numStr := "";          
  Strings.Str(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr);       
  
  Strings.Append(str," cAutoRepeat:"); numStr := "";    
  Strings.Str(Utils.HiWord(lParam),numStr); Strings.Append(str,numStr);
END Proc_WM_SYSDEADCHAR;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_TIMER                                  *)
(*                                                                            *)
(* COMMENTS: The WM_TIMER message is posted to the installing application's   *)
(*           message queue or sent to the appropriate TimerProc callback      *)
(*           function after each interval specified in the SetTimer function  *)
(*           used to install a timer.                                         *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wTimerID = wParam: timer identifier                         *)
(* lParam         tmprc = (TIMERPROC FAR* ) lParam: address of timer callback *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_TIMER*(wParam : W.WPARAM; 
                         lParam : W.LPARAM;
                         VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," wTimerID:"); numStr := "";          
  Strings.HexStr(wParam,numStr); Strings.Append(str,numStr);       

  Strings.Append(str," tmprc:"); numStr := "";          
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr); 
END Proc_WM_TIMER;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_VKEYTOITEM                             *)
(*                                                                            *)
(* COMMENTS: The WM_VKEYTOITEM message is sent by a list box with the         *)
(*           LBS_WANTKEYBOARDINPUT style to its owner in response to a        *)
(*           WM_KEYDOWN message.                                              *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wVkey = wParam: virtual-key code                            *)
(* lParam         hwndListBox = (HWND) LOWORD(lParam): list box handle        *)
(*                iCaretPos = HIWORD(lParam): caret position                  *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_VKEYTOITEM*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," VKey:");  
  IF (wParam >= W.VK_LBUTTON) & (wParam <= W.VK_SCROLL) & (vkTab[wParam] # "") THEN
    Strings.Append(str,vkTab[wParam])
  END;
  Strings.Append(str," (="); numStr := "";          
  Strings.HexStr(wParam,numStr); Strings.Append(str,numStr);       
  Strings.AppendChar(str,")");

  Strings.Append(str," hwndListBox:"); numStr := "";          
  Strings.HexStr(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr);       
  
  Strings.Append(str," nCaretPos:"); numStr := "";    
  Strings.Str(Utils.HiWord(lParam),numStr); Strings.Append(str,numStr);
END Proc_WM_VKEYTOITEM;


(*==============< Begin of module-body >======================================*)

BEGIN
  (*-- Init string tables --*)
  FOR i := 0 TO LEN(vkTab)-1 DO vkTab[i] := "" END;

 (*----------< Vertical scroll bar codes >--------------------------------------------------*) 
  vkTab[107] := "VK_ADD";
  vkTab[8]   := "VK_BACK"; 
  vkTab[3]   := "VK_CANCEL";
  vkTab[20]  := "VK_CAPITAL"; 
  vkTab[12]  := "VK_CLEAR";
  vkTab[17]  := "VK_CONTROL";
  vkTab[110] := "VK_DECIMAL"; 
  vkTab[46]  := "VK_DELETE"; 
  vkTab[111] := "VK_DIVIDE";
  vkTab[40]  := "VK_DOWN"; 
  vkTab[35]  := "VK_END";
  vkTab[27]  := "VK_ESCAPE";
  vkTab[43]  := "VK_EXECUTE"; 
  vkTab[112] := "VK_F1";
  vkTab[121] := "VK_F10";
  vkTab[122] := "VK_F11";
  vkTab[123] := "VK_F12";
  vkTab[124] := "VK_F13";
  vkTab[125] := "VK_F14";
  vkTab[126] := "VK_F15";
  vkTab[127] := "VK_F16";
  vkTab[128] := "VK_F17";
  vkTab[129] := "VK_F18";
  vkTab[130] := "VK_F19";
  vkTab[113] := "VK_F2";
  vkTab[131] := "VK_F20";
  vkTab[132] := "VK_F21"; 
  vkTab[133] := "VK_F22";
  vkTab[134] := "VK_F23";
  vkTab[135] := "VK_F24";
  vkTab[114] := "VK_F3";
  vkTab[115] := "VK_F4";
  vkTab[116] := "VK_F5";
  vkTab[117] := "VK_F6";
  vkTab[118] := "VK_F7";
  vkTab[119] := "VK_F8";
  vkTab[120] := "VK_F9"; 
  vkTab[47]  := "VK_HELP";
  vkTab[36]  := "VK_HOME";
  vkTab[45]  := "VK_INSERT";
  vkTab[1]   := "VK_LBUTTON";
  vkTab[37]  := "VK_LEFT";
  vkTab[4]   := "VK_MBUTTON";
  vkTab[18]  := "VK_MENU";
  vkTab[106] := "VK_MULTIPLY";
  vkTab[34]  := "VK_NEXT";
  vkTab[144] := "VK_NUMLOCK";
  vkTab[96]  := "VK_NUMPAD0"; 
  vkTab[97]  := "VK_NUMPAD1";
  vkTab[98]  := "VK_NUMPAD2";
  vkTab[99]  := "VK_NUMPAD3";
  vkTab[100] := "VK_NUMPAD4";
  vkTab[101] := "VK_NUMPAD5";
  vkTab[102] := "VK_NUMPAD6";
  vkTab[103] := "VK_NUMPAD7";
  vkTab[104] := "VK_NUMPAD8";
  vkTab[105] := "VK_NUMPAD9"; 
  vkTab[19]  := "VK_PAUSE";
  vkTab[42]  := "VK_PRINT";
  vkTab[33]  := "VK_PRIOR";
  vkTab[2]   := "VK_RBUTTON";
  vkTab[13]  := "VK_RETURN";
  vkTab[39]  := "VK_RIGHT";
  vkTab[145] := "VK_SCROLL";
  vkTab[41]  := "VK_SELECT";
  vkTab[108] := "VK_SEPARATOR";
  vkTab[16]  := "VK_SHIFT";
  vkTab[44]  := "VK_SNAPSHOT";
  vkTab[32]  := "VK_SPACE";
  vkTab[109] := "VK_SUBTRACT";
  vkTab[9]   := "VK_TAB";
  vkTab[38]  := "VK_UP";
  
END InProc.
