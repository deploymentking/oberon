(******************************************************************************)
(* MODULE:      EventMon                                        ME - 29.06.96 *)
(* DESCRIPTION: Main module of application                                    *)
(* LANGUAGE:    Oberon-2                                                      *)
(* COMPILER:    Robinson Associates Oberon-2 V1.18 beta6                      *)
(* WORKBENCH    POW 3.0 beta3                                                 *)
(* AUTHOR:      Martin Erdpresser, k3075e2@c210.edvz.uni-linz.ac.at (ME)      *)
(******************************************************************************)
(* DATE      AUTHOR  CHANGES                                                  *)
(* --------  ------  ---------------------------------------------------------*)
(* 29.06.96  ME      Final release                                            *) 
(******************************************************************************)

MODULE EventMon;  

IMPORT
   W := Windows, File, SYSTEM, Utils, Strings, ft := FlagTab, EmDll, StatLine;

(*-------------------< User defined constants >-------------------------------*) 
CONST 
  IDM_MAIN_START     = 1000;               (* Main menu                       *)
    IDM_MAIN_STOP      = 1100;
    IDM_EXIT           = 1200;

  DLG_STATES         = 22;
 
  IDM_CHANGE_OPTIONS = 2000;               (* Options menu                    *)
    IDD_OFFSET           = 2100; 
    IDD_MOUSE            = 2100;             
    IDD_WINDOW           = 2101;
    IDD_INPUT            = 2102;
    IDD_SYSTEM           = 2103;
    IDD_INIT             = 2104;
    IDD_CLIPBOARD        = 2105;
    IDD_DDE              = 2106;
    IDD_NONCLIENT        = 2107;
    IDD_BUTTONS          = 2108;
    IDD_COMBOBOX         = 2109;
    IDD_LISTBOX          = 2110;
    IDD_EDITBOX          = 2111;
    IDD_OTHER            = 2112;
    IDD_WMUSER           = 2113;

    IDD_ALL              = 2114;
    IDD_SAVEOPTIONS      = 2115;
     
    IDD_TEX              = 2116;
    IDD_TEXHEX           = 2117;
    IDD_HEX              = 2118;

    IDD_ENABLELOG        = 2119;
    IDD_OVERWRITE        = 2120;
    IDD_APPEND           = 2121;
    IDD_EB_FNAME         = 2122; 
    IDD_HELP1            = 2123;             

  IDM_SELECT_WND     = 3000;               (* Window selection menu           *)
    IDD_HELP2           = 3101;               
    IDD_SELLIST         = 3102; 

  IDM_START          = 4000;               (* Start menu                      *)

  IDM_STOP           = 5000;               (* Stop menu                       *)
  
  IDM_CLEAR          = 6000;               (* Clear menu                      *)

  IDM_ABOUT          = 7000;               (* About menu                      *)
    IDD_CTEXT_WINVER  = 7100;
    IDD_CTEXT_DOSVER  = 7200;
     
  
  RC_MENU_NAME   = "ApplMainMenu";
  RC_ABOUT_BOX   = "AboutBox";
  RC_OPTIONS_BOX = "OptionsBox";
  RC_SELWND_BOX =  "SelWndBox"; 
  CLASS_NAME     = "WC_Event_Monitor_V1.0";
  TXT_TITLE_BAR  = "Event Monitor V1.0";
  
  SET_FLAG = 1;                            (* Dialog redraw flags             *)
  CLEAR_FLAG = 0;
  
(*-------------------< User defined types >-----------------------------------*) 
TYPE 
  DlgProcT  = PROCEDURE [WINDOWS] (hDlg: W.HWND;     (* Dialog proc. type     *)
                                   msg:  W.WORD;
                                   wParam: W.WORD;
                                   lParam: LONGINT
                                  ): W.BOOL;

  EnumProcT = PROCEDURE [WINDOWS] (hWnd : W.HWND;    (* Enumeration proc. type*)
                                   lParam : W.LPARAM
                                  ) : W.BOOL;
  
  StateElem = RECORD                                 (* checkbox state type   *)
                checked : W.BOOL;
                flag    : LONGINT;
              END;
                   
  DlgDesc = RECORD                                   (* dialog descriptor     *)
              state : ARRAY DLG_STATES OF StateElem; (* collection of states  *)
              fileName : ARRAY 140 OF CHAR;          (* name of logfile       *)
            END;  

(*-------------------< Global variables >-------------------------------------*) 
VAR
  hInst: W.HANDLE;                         (* Handle to instance              *)
  hMenu: W.HMENU;                          (* Handle to menu                  *)
  hWndTarget,                              (* Window handle to spy on         *)
  hWndSelected,                            (* Selected window of listbox      *)
  hWndThisApp,                             (* Window handle of own appl.      *)
  hDlgThisApp,                             (* Dialog handle of own appl.      *)
  hWndViewer,                              (* Handle to message viewer        *)
  hWndStatLine : W.HWND;                   (* Handle to statusline            *)
  dlgStates,                               (* Holds dialog selections         *)
  dlgStatesTmp : DlgDesc;
  bHooksActive : BOOLEAN;


(*-------------------< Auxiliary procedures >---------------------------------*) 

(*============================================================================*)
(* PURPOSE:  Opens a message box                                              *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* msg            Message to display in box                                   *)
(* title          Title of messagebox                                         *)
(*============================================================================*)
PROCEDURE MsgBox(msg, title : ARRAY OF CHAR);
VAR 
  r : INTEGER;

BEGIN
  W.MessageBeep(-1);
  r := W.MessageBox(W.NULL, 
                    SYSTEM.ADR(msg), 
                    SYSTEM.ADR(title), 
                    W.MB_OK+W.MB_ICONEXCLAMATION);
END MsgBox;


(*============================================================================*)
(* PURPOSE:  Opens a message box with yes-no question                         *)
(*                                                                            *)
(* COMMENTS: Returns true if yes-botton was hit, otherwise false              *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* msg            Message to display in box                                   *)
(* title          Title of messagebox                                         *)
(*============================================================================*)
PROCEDURE YesNoBox(msg, title : ARRAY OF CHAR) : BOOLEAN;
VAR 
  r : INTEGER;

BEGIN
  r := W.MessageBox(W.NULL, 
                    SYSTEM.ADR(msg), 
                    SYSTEM.ADR(title), 
                    W.MB_ICONQUESTION + W.MB_YESNO +
                    W.MB_DEFBUTTON1 + W.MB_APPLMODAL 
                   );
  RETURN r = W.IDYES 
END YesNoBox;


(*============================================================================*)
(* PURPOSE:  Init checkmarks and map message group flags of options menu      *)
(*           to default values.                                               *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* s              Structure to init                                           *)
(*============================================================================*)
PROCEDURE InitDlgStates(VAR s : DlgDesc);
BEGIN
  s.state[0].checked  := W.true;                        (* IDD_MOUSE                *)
  s.state[0].flag     := ft.MSG_TYPE_MOUSE; 
  s.state[1].checked  := W.false;                       (* IDD_WINDOW               *)
  s.state[1].flag     := ft.MSG_TYPE_WND;
  s.state[2].checked  := W.false;                       (* IDD_INPUT                *)   
  s.state[2].flag     := ft.MSG_TYPE_INPUT;
  s.state[3].checked  := W.false;                       (* IDD_SYSTEM               *)
  s.state[3].flag     := ft.MSG_TYPE_SYS;
  s.state[4].checked  := W.false;                       (* IDD_INIT                 *)
  s.state[4].flag     := ft.MSG_TYPE_INIT;
  s.state[5].checked  := W.false;                       (* IDD_CLIPBOARD            *)
  s.state[5].flag     := ft.MSG_TYPE_CLPBRD;
  s.state[6].checked  := W.false;                       (* IDD_DDE                  *)
  s.state[6].flag     := ft.MSG_TYPE_DDE;
  s.state[7].checked  := W.false;                       (* IDD_NONCLIENT            *)
  s.state[7].flag     := ft.MSG_TYPE_NCL;
  s.state[8].checked  := W.false;                       (* IDD_BUTTONS              *)
  s.state[8].flag     := ft.MSG_TYPE_BM;
  s.state[9].checked  := W.false;                       (* IDD_COMBOBOX             *)
  s.state[9].flag     := ft.MSG_TYPE_CB;
  s.state[10].checked := W.false;                       (* IDD_LISTBOX              *)
  s.state[10].flag    := ft.MSG_TYPE_LB;
  s.state[11].checked := W.false;                       (* IDD_EDITBOX              *)
  s.state[11].flag    := ft.MSG_TYPE_EM;
  s.state[12].checked := W.false;                       (* IDD_OTHER                *)
  s.state[12].flag    := ft.MSG_TYPE_OTHER;
  s.state[13].checked := W.false;                       (* IDD_WMUSER               *)
  s.state[13].flag    := ft.MSG_TYPE_WMUSER;
  s.state[14].checked := W.false;                       (* IDD_ALL                  *)
  s.state[14].flag    := ft.MSG_TYPE_ALL;

  s.state[15].checked := W.true;                        (* IDD_SAVEOPTIONS          *)
  s.state[16].checked := W.true;                        (* IDD_TEX                  *)
  s.state[17].checked := W.false;                       (* IDD_TEXHEX               *)
  s.state[18].checked := W.false;                       (* IDD_HEX                  *)
  s.state[19].checked := W.true;                        (* IDD_ENABLELOG            *)
  s.state[20].checked := W.true;                        (* IDD_OVERWRITE            *)
  s.state[21].checked := W.false;                       (* IDD_APPEND               *)
  s.fileName := ""
END InitDlgStates;

 
(*============================================================================*)
(* PURPOSE:  Set check marks of option dialog                                 *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hDlg           Handle to dialog                                            *)
(* s              Structure that holds the information                        *)
(*============================================================================*)
PROCEDURE SetDlgStates(hDlg: W.HWND; s : DlgDesc);
VAR 
  i : INTEGER;
  r : W.LRESULT;

BEGIN
  FOR i := 0 TO DLG_STATES-1 DO
    r := W.SendDlgItemMessage(hDlg,i+IDD_OFFSET, W.BM_SETCHECK,s.state[i].checked, 0)
  END;
  r := W.SendDlgItemMessage(hDlg, IDD_EB_FNAME, W.WM_SETTEXT, 0, SYSTEM.ADR(s.fileName)); 
END SetDlgStates;    
  

(*============================================================================*)
(* PURPOSE:  Get content of option dialog                                     *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hDlg           Handle to dialog                                            *)
(* s              Structure to receive dialog states                          *)
(*============================================================================*)
PROCEDURE GetDlgStates(hDlg: W.HWND; VAR s : DlgDesc);
VAR 
  i : INTEGER;
  r : W.LRESULT;

BEGIN
  FOR i := 0 TO DLG_STATES-1 DO
      s.state[i].checked := SYSTEM.VAL(W.BOOL,
                                       W.SendDlgItemMessage
                                       (hDlg,i+IDD_OFFSET,W.BM_GETCHECK,0,0))
  END;
  r :=  W.SendDlgItemMessage(hDlg, 
                             IDD_EB_FNAME, 
                             W.WM_GETTEXT, LEN(s.fileName), SYSTEM.ADR(s.fileName))
END GetDlgStates;


(*============================================================================*)
(* PURPOSE:  Makes filename with specified extension                          *)
(*                                                                            *)
(* COMMENTS: Same path and name as application, but with choosen extension.   *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hInst          Instance handle of application                              *)
(* extension      Extension of filename to build                              *)
(* str            String to receive filename                                  *)
(*============================================================================*)
PROCEDURE MakeFileName(hInst : W.HINSTANCE; 
                       extension : ARRAY OF CHAR;
                       VAR str : ARRAY OF CHAR);
VAR
  temp : ARRAY 128 OF CHAR;
  pos : INTEGER;
  r : W.LRESULT;
  
BEGIN
  temp := "";
  r := W.GetModuleFileName(hInst,SYSTEM.ADR(str),SHORT(LEN(str)));
  IF (r # W.NULL) & (extension # "EXE") & (extension # "exe") THEN
    pos := SHORT(Strings.Pos(".EXE",str,1)); Strings.Copy(str, temp, 1, pos);
    Strings.Append(temp, extension);  
    Strings.Copy(temp, str, 1, Strings.Length(temp))
  END
END MakeFileName;


(*============================================================================*)
(* PURPOSE:  Reads program configuration from ini-file. If ini-file does't    *)
(*           exist, default values are used.                                  *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hInst          Instance handle of application                              *)
(* s              Structure to hold settings                                  *)
(*============================================================================*)
PROCEDURE ReadIniFile(hInst : W.HINSTANCE; VAR s : DlgDesc);
VAR
  iniFile,
  logFile : ARRAY 140 OF CHAR;
  r : INTEGER;
  
BEGIN
  iniFile := ""; logFile := "";
  MakeFileName(hInst,"INI", iniFile); MakeFileName(hInst,"LOG",logFile);
  
  (*-- Ini-file not found, set defaults --*)
  IF ~File.Exist(iniFile) THEN
    InitDlgStates(s); 
    Strings.Copy(logFile, s.fileName, 1, Strings.Length(logFile));

  (*-- Get values from ini-file --*)
  ELSE
    s.state[0].checked  := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("Mouse_Checked"),
                                                  W.true,
                                                  SYSTEM.ADR(iniFile)); 
    s.state[0].flag     := ft.MSG_TYPE_MOUSE;
  
    s.state[1].checked  := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("Window_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile)); 
    s.state[1].flag     := ft.MSG_TYPE_WND;

    s.state[2].checked  := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("Input_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile));
    s.state[2].flag     := ft.MSG_TYPE_INPUT;
  
    s.state[3].checked  := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("System_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile));
    s.state[3].flag     := ft.MSG_TYPE_SYS;

    s.state[4].checked  := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("Init_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile));
    s.state[4].flag     := ft.MSG_TYPE_INIT;

    s.state[5].checked  := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("ClpBrd_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile)); 
    s.state[5].flag     := ft.MSG_TYPE_CLPBRD;

    s.state[6].checked  := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("DDE_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile));
    s.state[6].flag     := ft.MSG_TYPE_DDE;

    s.state[7].checked  := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("NonClient_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile));
    s.state[7].flag     := ft.MSG_TYPE_NCL;

    s.state[8].checked  := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("Buttons_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile));
    s.state[8].flag     := ft.MSG_TYPE_BM;

    s.state[9].checked  := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("ComboBox_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile));
    s.state[9].flag     := ft.MSG_TYPE_CB;
  
    s.state[10].checked := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("ListBox_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile));
    s.state[10].flag    := ft.MSG_TYPE_LB;

    s.state[11].checked := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("EditBox_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile));
    s.state[11].flag    := ft.MSG_TYPE_EM;

    s.state[12].checked := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("Other_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile));
    s.state[12].flag    := ft.MSG_TYPE_OTHER;
  
    s.state[13].checked := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("WMUser_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile));
    s.state[13].flag    := ft.MSG_TYPE_WMUSER;

    s.state[14].checked := W.false;           (* must be deselected initially *)
    s.state[14].flag    := ft.MSG_TYPE_ALL;

    s.state[15].checked := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("SaveOptions_Checked"),
                                                  W.true,
                                                  SYSTEM.ADR(iniFile));

    s.state[16].checked := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("TextMode_Checked"),
                                                  W.true,
                                                  SYSTEM.ADR(iniFile));

    s.state[17].checked := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("TextHexMode_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile));

    s.state[18].checked := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("HexMode_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile));

    s.state[19].checked := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("EnableLog_Checked"),
                                                  W.true,
                                                  SYSTEM.ADR(iniFile));

    s.state[20].checked := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("OverWrite_Checked"),
                                                  W.true,
                                                  SYSTEM.ADR(iniFile));

    s.state[21].checked := W.GetPrivateProfileInt(SYSTEM.ADR(CLASS_NAME), 
                                                  SYSTEM.ADR("Append_Checked"),
                                                  W.false,
                                                  SYSTEM.ADR(iniFile));
       
    r := W.GetPrivateProfileString(SYSTEM.ADR(CLASS_NAME), 
                                   SYSTEM.ADR("LogFile"),
                                   SYSTEM.ADR(logFile),
                                   SYSTEM.ADR(s.fileName), 
                                   LEN(s.fileName),
                                   SYSTEM.ADR(iniFile))
  END
END ReadIniFile;


(*============================================================================*)
(* PURPOSE:  Writes program configuration to ini-file.                        *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hInst          Instance handle of application                              *)
(* s              Structure to hold settings                                  *)
(*============================================================================*)
PROCEDURE WriteIniFile(hInst : W.HINSTANCE; s : DlgDesc);
VAR
  iniFile,
  logFile, 
  str,num : ARRAY 140 OF CHAR;
  res : INTEGER;
  fHnd : File.Handle;
  
BEGIN
  iniFile := ""; logFile := "";
  MakeFileName(hInst,"INI", iniFile); MakeFileName(hInst,"LOG",logFile);

  (*-- Delete old ini-file --*)                      
  IF File.Exist(iniFile) THEN
    File.Delete(iniFile,res)
  END;

  File.Open(iniFile,
            TRUE, 
            File.DENYALL, 
            File.READWRITE, fHnd, res);
    
  (*-- New ini-file successfully created, write values to file --*)
  IF res = File.NOERROR THEN
    (*-- All message groups are currently selected, restore prev. settings --*)
    IF (dlgStates.state[IDD_ALL-IDD_OFFSET].checked = W.true) THEN
      s := dlgStatesTmp
    END; 
    str := "["; Strings.Append(str,CLASS_NAME); Strings.Append(str,"]");
    File.WriteLn(fHnd, str, res); 
   
    str := "Mouse_Checked = ";       num := ""; Strings.Str(s.state[0].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 

    str := "Window_Checked = ";      num := ""; Strings.Str(s.state[1].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 
      
    str := "Input_Checked = ";       num := ""; Strings.Str(s.state[2].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 

    str := "System_Checked = ";      num := ""; Strings.Str(s.state[3].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 
      
    str := "Init_Checked = ";        num := ""; Strings.Str(s.state[4].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 

    str := "ClpBrd_Checked = ";      num := ""; Strings.Str(s.state[5].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 
      
    str := "DDE_Checked = ";         num := ""; Strings.Str(s.state[6].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 

    str := "NonClient_Checked = ";   num := ""; Strings.Str(s.state[7].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 

    str := "Buttons_Checked = ";     num := ""; Strings.Str(s.state[8].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 

    str := "ComboBox_Checked = ";    num := ""; Strings.Str(s.state[9].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 

    str := "ListBox_Checked = ";     num := ""; Strings.Str(s.state[10].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 

    str := "EditBox_Checked = ";     num := ""; Strings.Str(s.state[11].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 

    str := "Other_Checked = ";       num := ""; Strings.Str(s.state[12].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 

    str := "WMUser_Checked = ";      num := ""; Strings.Str(s.state[13].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 
    
    str := "All_Checked = ";         num := ""; Strings.Str(s.state[14].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 
    
    str := "SaveOptions_Checked = "; num := ""; Strings.Str(s.state[15].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 
    
    str := "TextMode_Checked = ";    num := ""; Strings.Str(s.state[16].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 

    str := "TextHexMode_Checked = "; num := ""; Strings.Str(s.state[17].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 
    
    str := "HexMode_Checked = ";     num := ""; Strings.Str(s.state[18].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 
    
    str := "EnableLog_Checked = ";   num := ""; Strings.Str(s.state[19].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 

    str := "OverWrite_Checked = ";   num := ""; Strings.Str(s.state[20].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 

    str := "Append_Checked = ";      num := ""; Strings.Str(s.state[21].checked,num); 
    Strings.Append(str,num);         File.WriteLn(fHnd, str, res); 

    str := "LogFile = ";            
    Strings.Append(str,s.fileName);  File.WriteLn(fHnd, str, res);
    File.Close(fHnd)
    
  (*-- Creation of ini-file failed --*)
  ELSE
    str := "Can't create ini-file, Error:";  num := "";  
    File.GetErrorMessage(res,num); Strings.Append(str,num);
    MsgBox(str,"ERROR: EventMon.WriteIniFile")
  END  
END WriteIniFile;


(*============================================================================*)
(* PURPOSE:  Return number of selected message groups                         *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*) 
(* hDlg           Handle to dialog                                            *)
(*============================================================================*)
PROCEDURE NrOfSelections(hDlg : W.HWND) : INTEGER;
VAR 
  i, r, nr : INTEGER;
  
BEGIN
  nr := 0;
  FOR i := IDD_MOUSE-IDD_OFFSET TO IDD_ALL-IDD_OFFSET DO
    r := W.IsDlgButtonChecked(hDlg, i+IDD_OFFSET); ASSERT(r # -1); 
    IF r = W.true THEN INC(nr) END 
  END;
  RETURN nr; 
END NrOfSelections; 


(*============================================================================*)
(* PURPOSE:  Join the message group flags of current selection to summarizing *)
(*           selection flag.                                                  *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* s              Structure with dialog states                                *)
(*============================================================================*)
PROCEDURE GetSelectionFlag(s : DlgDesc) : LONGINT;
VAR 
  i : INTEGER;
  groupFlg : LONGINT;

BEGIN
  groupFlg := 0;
  FOR i := IDD_MOUSE-IDD_OFFSET TO IDD_ALL-IDD_OFFSET DO
    IF s.state[i].checked = W.true THEN
      groupFlg := Utils.BitOrL(groupFlg,s.state[i].flag);
    END
  END;
  RETURN groupFlg; 
END GetSelectionFlag;


(*============================================================================*)
(* PURPOSE:  Sets display mode according to state of dialog box               *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* s              Structure with current dialog states                        *)
(*============================================================================*)
PROCEDURE SetDisplayMode(s : DlgDesc);
VAR 
  i : INTEGER;

BEGIN
  IF (s.state[IDD_TEX-IDD_OFFSET].checked = W.true) THEN 
    EmDll.SetText(); 
  ELSIF (s.state[IDD_TEXHEX-IDD_OFFSET].checked = W.true) THEN
    EmDll.SetTextHex(); 
  ELSIF (s.state[IDD_HEX-IDD_OFFSET].checked = W.true) THEN
    EmDll.SetHex(); 
  ELSE
    MsgBox("Invalid change attempt",
           "ERROR: EventMon.SetDisplayMode");
  END; 
END SetDisplayMode;     


(*============================================================================*)
(* PURPOSE:  Set message filters                                              *)
(*                                                                            *)
(* COMMENTS: Returns true on success                                          *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(*                                                                            *)
(*============================================================================*)
PROCEDURE SetFilters() : BOOLEAN;
VAR
  r : BOOLEAN;
      
BEGIN
  IF ~EmDll.InstallFilter(W.WH_GETMESSAGE, TRUE) THEN
    RETURN FALSE
  ELSIF ~EmDll.InstallFilter(W.WH_CALLWNDPROC, TRUE) THEN 
     r := EmDll.InstallFilter(W.WH_GETMESSAGE, FALSE); ASSERT(r = TRUE);
    RETURN FALSE
  ELSE
    RETURN TRUE
  END
END SetFilters;


(*============================================================================*)
(* PURPOSE:  Reset all installed filters                                      *)
(*                                                                            *)
(* COMMENTS: Returns true on success                                          *) 
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* s              Structure with current dialog states                        *)
(*============================================================================*)
PROCEDURE ResetFilters() : BOOLEAN;
BEGIN
  IF ~EmDll.InstallFilter(W.WH_GETMESSAGE, FALSE) THEN
    RETURN FALSE
  ELSIF ~EmDll.InstallFilter(W.WH_CALLWNDPROC, FALSE) THEN 
    RETURN FALSE
  ELSE
    RETURN TRUE
  END
END ResetFilters;


(*============================================================================*)
(* PURPOSE:  Enables message logging to file                                  *)
(*                                                                            *)
(* COMMENTS:                                                                  *) 
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(*                                                                            *)
(*============================================================================*)
PROCEDURE StartMsgLogging();
VAR
  str : ARRAY 128 OF CHAR;
BEGIN
  str := ""; 
  IF (dlgStates.state[IDD_ENABLELOG-IDD_OFFSET].checked = W.true) & 
    ~EmDll.StartFileLog() THEN
    Strings.Append(str,"Can't access Logfile "); Strings.AppendChar(str,'"');
    Strings.Append(str, dlgStates.fileName); Strings.AppendChar(str,'"'); 
    MsgBox(str,"Event Monitor: Error");
  END
END StartMsgLogging;


(*============================================================================*)
(* PURPOSE:  Disables message logging to file                                 *)
(*                                                                            *)
(* COMMENTS:                                                                  *) 
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(*                                                                            *)
(*============================================================================*)
PROCEDURE StopMsgLogging();
VAR
  str : ARRAY 128 OF CHAR;
  
BEGIN
  str := ""; 
  IF ~EmDll.StopFileLog() THEN
    Strings.Append(str,"Can't write to Logfile "); Strings.AppendChar(str,'"');
    Strings.Append(str, dlgStates.fileName); Strings.AppendChar(str,'"'); 
    MsgBox(str,"Event Monitor: Error");
  END;
END StopMsgLogging;


(*============================================================================*)
(* PURPOSE:  Toggles menu entries to start position                           *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*) 
(* hMenu          Menu handle                                                 *)
(*============================================================================*)
PROCEDURE ToggleMenuToStart(hMenu : W.HWND);
VAR
  ok : W.BOOL;

BEGIN        
  ok := W.EnableMenuItem(hMenu,IDM_MAIN_STOP, W.MF_GRAYED);  ASSERT(ok # -1);
  ok := W.EnableMenuItem(hMenu,IDM_MAIN_START,W.MF_ENABLED); ASSERT(ok # -1);
  ok := W.EnableMenuItem(hMenu,IDM_EXIT,      W.MF_ENABLED); ASSERT(ok # -1);
  ok := W.EnableMenuItem(hMenu,IDM_STOP,      W.MF_GRAYED);  ASSERT(ok # -1);
  ok := W.EnableMenuItem(hMenu,IDM_START,     W.MF_ENABLED); ASSERT(ok # -1);
END ToggleMenuToStart;  


(*============================================================================*)
(* PURPOSE:  Toggles menu entries to stop position                            *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*) 
(* hMenu          Menu handle                                                 *)
(*============================================================================*)
PROCEDURE ToggleMenuToStop(hMenu : W.HWND);
VAR
  ok : W.BOOL;

BEGIN        
  ok := W.EnableMenuItem(hMenu,IDM_MAIN_STOP, W.MF_ENABLED); ASSERT(ok # -1);
  ok := W.EnableMenuItem(hMenu,IDM_MAIN_START,W.MF_GRAYED);  ASSERT(ok # -1);
  ok := W.EnableMenuItem(hMenu,IDM_EXIT,      W.MF_GRAYED);  ASSERT(ok # -1);
  ok := W.EnableMenuItem(hMenu,IDM_START,     W.MF_GRAYED);  ASSERT(ok # -1); 
  ok := W.EnableMenuItem(hMenu,IDM_STOP,      W.MF_ENABLED); ASSERT(ok # -1);
END ToggleMenuToStop;


(*============================================================================*)
(* PURPOSE:  Work procedure for windows-enumeration function.                 *)
(*           Adds all existing windows to selection Listbox                   *)
(*                                                                            *)
(* COMMENTS: The function must return nonzero to continue enumeration;        *)
(*           to stop enumeration, it must return zero.                        *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hDlg           Current window handle                                       *)
(* lphLBox        Handle to dialog listbox                                    *)
(*============================================================================*)
PROCEDURE [WINDOWS]AddItemToLBox*(hWnd : W.HWND; lphLBox : W.LPARAM) : W.BOOL;
VAR 
  name,                                    (* Window title                    *)
  clname,                                  (* Window class name               *)
  dest : ARRAY 64 OF CHAR;                 (* Result string                   *)
  formatStr : ARRAY 16 OF CHAR;            
  argList : ARRAY 1 OF INTEGER;
  lphWnd : W.LPARAM;                       (* dWord handle                    *)
  nLbIndex : W.LRESULT;                    (* Listbox index                   *)
  r : INTEGER;                             (* Dummy return value              *)

BEGIN
  name := ""; clname := ""; dest := "";                 

  (*-- Skip own / unknown / stupid applications --*) 
  IF (hWnd = hWndThisApp) OR (hWnd = hDlgThisApp) OR
     (W.GetClassName(hWnd, SYSTEM.ADR(clname), LEN(clname)) = W.NULL) OR 
     (W.GetWindowText(hWnd, SYSTEM.ADR(name), W.GetWindowTextLength(hWnd)+1) = W.NULL) OR 
     (clname = "Progman") THEN
    RETURN W.true                          
 
  (*-- Some valid window found ----------*)
  ELSE
    (*-- Build address string --*)
    formatStr := "%8.8X: "; argList[0] := hWnd; 
    r := W.wvsprintf(SYSTEM.ADR(dest),
                     SYSTEM.ADR(formatStr), 
                     SYSTEM.ADR(argList)
                    ); 

    (*-- Add stuff to listbox --*)
    lphWnd := hWnd;                    
    Strings.Append(dest,name);
    nLbIndex := W.SendMessage(SYSTEM.VAL(W.HWND,lphLBox),
                              W.LB_ADDSTRING, 
                              W.NULL, 
                              SYSTEM.VAL(W.LPARAM, SYSTEM.ADR(dest))
                             );
                                           
    (*-- Check, if listbox access was ok --*)
    IF ((nLbIndex = W.LB_ERR) OR (nLbIndex = W.LB_ERRSPACE)) THEN
      RETURN W.false
    ELSIF (W.SendMessage(SYSTEM.VAL(W.HWND,lphLBox),
                         W.LB_SETITEMDATA, 
                         SYSTEM.VAL(W.WPARAM,nLbIndex),
                         lphWnd
                        ) = W.LB_ERR ) THEN
      RETURN W.false
    END;
    RETURN W.true
  END;
END AddItemToLBox;  

 
(*============================================================================*)
(* PURPOSE:  Fills listbox with all available windows.                        *)
(*                                                                            *)
(* COMMENTS: own window is skipped                                            *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hLBox          Handle to dialog's listbox                                  *)
(*============================================================================*)
PROCEDURE [WINDOWS] InitListBox*(hLBox : W.HWND);
VAR 
  workProc : EnumProcT;                     (* Holds proc. to fill listbox    *)
  r : W.LRESULT;                            (* Return values                  *)
  b : W.BOOL;

BEGIN
  ASSERT(hLBox # W.NULL);
  r := W.SendMessage(hLBox, W.LB_RESETCONTENT, 0, 0); 
  r := W.SendMessage(hLBox, W.WM_SETREDRAW, (* Disable redrawing while filling*)
                     CLEAR_FLAG, W.NULL);   (* the listbox.                   *)

  workProc := AddItemToLBox; 
  b := W.EnumWindows(SYSTEM.VAL(W.FARPROC,workProc),SYSTEM.VAL(W.LPARAM,hLBox)); 
  ASSERT(b # W.NULL);
               
  r := W.SendMessage(hLBox, W.WM_SETREDRAW, (* Enable redrawing               *)
                     SET_FLAG, W.NULL); 
END InitListBox; 
 

(*============================================================================*)
(* PURPOSE:  Search identified window in listbox                              *)
(*                                                                            *)
(* COMMENTS: Returns index of window or LB_ERR when not found                 *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hLBox          Handle to dialog's listbox                                  *)
(* hWndToFind     Window handle to find                                       *)
(*============================================================================*)
PROCEDURE [WINDOWS]LocateWnd*(hLBox, hWndToFind : W.HWND) : INTEGER; 
VAR 
  pattern: ARRAY 11 OF CHAR;                (* Holds window address           *)
  formatStr : ARRAY 8 OF CHAR;
  argList : ARRAY 1 OF INTEGER;
  r : INTEGER;                              (* Return values                  *)
  nIndex : INTEGER; 

BEGIN
  formatStr := "%8.8X: "; argList[0] := hWndToFind; (* Build search pattern   *)
  r := W.wvsprintf(SYSTEM.ADR(pattern),SYSTEM.ADR(formatStr), SYSTEM.ADR(argList));
  nIndex := SYSTEM.VAL(INTEGER,
                       W.SendMessage(hLBox, 
                                     W.LB_FINDSTRING,
                                     -1,
                                     SYSTEM.VAL(W.LPARAM,SYSTEM.ADR(pattern))));
  RETURN nIndex; 
END LocateWnd;


(*-------------------< Dialog Procedures >------------------------------------*) 

(*============================================================================*)
(* PURPOSE:  Processes messages for "About" dialog box                        *)
(*                                                                            *)
(* MESSAGES:                                                                  *)
(*   W.WM_INITDIALOG - Initialize dialog box                                  *)
(*   W.WM_COMMAND    - Input received                                         *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hDlg           Window handle of the dialog box                             *)
(* msg            Type of message                                             *)
(* wParam         First parameter for the message                             *)
(* lParam         Second parameter for the message                            *)
(*============================================================================*)
PROCEDURE [WINDOWS] About*(hDlg: W.HWND;   
                           msg:  W.WORD;   
                           wParam: W.WORD; 
                           lParam: LONGINT
                          ): W.BOOL;

VAR
  winVersion, dosVersion,
  formatStr : ARRAY 64 OF CHAR;
  argList   : ARRAY 2 OF INTEGER;
  dwVersion : W.DWORD;
  r : INTEGER;

BEGIN
  (*-- Message: initialize dialog box ----------------------------------------*)
  IF msg = W.WM_INITDIALOG THEN            
    winVersion := ""; dosVersion := "";
    dwVersion := W.GetVersion();
    
    (*-- Get current windows version --*)
    formatStr := ("Windows Version: %d.%d"); 
    argList[0] := Utils.BitAnd(255,  Utils.LoWord(dwVersion));
    argList[1] := Utils.BitAnd(-256, Utils.LoWord(dwVersion)) DIV 256;
    r := W.wvsprintf(SYSTEM.ADR(winVersion),
                     SYSTEM.ADR(formatStr), 
                     SYSTEM.ADR(argList));

    (*-- Get current DOS version --*)
    formatStr := ("MS-DOS Version: %d.%d"); 
    argList[0] := Utils.BitAnd(-256, Utils.HiWord(dwVersion)) DIV 256;
    argList[1] := Utils.BitAnd(255,  Utils.HiWord(dwVersion)); 
    r := W.wvsprintf(SYSTEM.ADR(dosVersion),
                     SYSTEM.ADR(formatStr), 
                     SYSTEM.ADR(argList));
                     
    (*-- Set version information in dialog --*)
    W.SetDlgItemText(hDlg, IDD_CTEXT_WINVER, SYSTEM.ADR(winVersion));
    W.SetDlgItemText(hDlg, IDD_CTEXT_DOSVER, SYSTEM.ADR(dosVersion));
    RETURN W.true

  (*-- Message: received a command -------------------------------------------*)
  ELSIF msg = W.WM_COMMAND THEN            
    IF (wParam = W.IDOK) OR (wParam = W.IDCANCEL) THEN
      W.EndDialog(hDlg, W.true)            (* Exits the dialog box            *)
    END;
    RETURN W.true
  END;

  (*-- Didn't process a message ----------------------------------------------*)
  RETURN W.false                           
END About;


(*============================================================================*)
(* PURPOSE:  Processes messages for "Options" dialog box                      *)
(*                                                                            *)
(* MESSAGES:                                                                  *)
(*   W.WM_INITDIALOG - Initialize dialog box                                  *)
(*   W.WM_COMMAND    - Input received                                         *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hDlg           Window handle of the dialog box                             *)
(* msg            Type of message                                             *)
(* wParam         First parameter for the message                             *)
(* lParam         Second parameter for the message                            *)
(*============================================================================*)
PROCEDURE [WINDOWS] Options*(hDlg: W.HWND;
                             msg:  W.WORD;
                             wParam: W.WORD;
                             lParam: LONGINT
                            ): W.BOOL;

VAR
  i : INTEGER; 
  r : SHORTINT;  
  b : BOOLEAN;
    
BEGIN

  (*-- Message: initialize dialog box ----------------------------------------*)
  IF msg = W.WM_INITDIALOG THEN            
    SetDlgStates(hDlg,dlgStates);
    (*-- Gray group selector,  if all msgs are default selected --*)
    IF (W.IsDlgButtonChecked(hDlg, IDD_ALL) = 1) THEN
      FOR i := IDD_MOUSE-IDD_OFFSET TO IDD_WMUSER-IDD_OFFSET DO
        W.CheckDlgButton(hDlg,i+IDD_OFFSET,2); 
      END;    
    END;
    RETURN W.true;
    
  (*-- Message: received a command (eg. checkbox hit ) -----------------------*)
  ELSIF msg = W.WM_COMMAND THEN
  
    (*-- Checkbox to select all messages hit --------*)            
    IF (wParam = IDD_ALL) THEN
      IF (W.IsDlgButtonChecked(hDlg, wParam) = 1) THEN
        GetDlgStates(hDlg,dlgStatesTmp);         (* get current checkmarks    *)
        FOR i := IDD_MOUSE-IDD_OFFSET TO IDD_WMUSER-IDD_OFFSET DO
          W.CheckDlgButton(hDlg,i+IDD_OFFSET,2); (* gray all other controls   *)
        END;
      ELSE                                  (* Box deselected, restore others *)
        FOR i := IDD_MOUSE-IDD_OFFSET TO IDD_WMUSER-IDD_OFFSET DO
          W.CheckDlgButton(hDlg,i+IDD_OFFSET,dlgStatesTmp.state[i].checked);
        END;
      END;
      
    (*-- One of the message group selectors hit ----*) 
    ELSIF (wParam >= IDD_MOUSE) &          (* toggle checkmark, they have     *)
      (wParam <= IDD_WMUSER) THEN          (* no BS_AUTO... style             *)
      r := SYSTEM.VAL(SHORTINT,W.IsDlgButtonChecked(hDlg, wParam));
      b := ~(SYSTEM.VAL(BOOLEAN,r)); 
      W.CheckDlgButton(hDlg,wParam,SYSTEM.VAL(SHORTINT,b)); 
  
    (*-- Ok - Button selected, make changes valid --*) 
    ELSIF (wParam = W.IDOK) THEN
      StopMsgLogging(); 
      GetDlgStates(hDlg,dlgStates);
      SetDisplayMode(dlgStates);
      
      (*-- Validate selections --*)
      IF (NrOfSelections(hDlg) = 0) THEN   
        MsgBox("Select at least one message group","Event Monitor: Attention");
        RETURN W.true; 
      END;
      
      (*-- Check name of logfile --*)
      IF (dlgStates.state[IDD_ENABLELOG-IDD_OFFSET].checked = W.true) & 
        ~EmDll.RegisterLogFile(dlgStates.fileName,
                               (dlgStates.state[IDD_OVERWRITE-IDD_OFFSET].checked 
                                = W.true)) THEN 
        MsgBox("Could not open logfile","Event Monitor: Error");
        RETURN W.true;
      END;
       
      EmDll.RegisterSelection(GetSelectionFlag(dlgStates));

      (*-- Remove Hooks --*)
      IF ResetFilters() THEN               
        ToggleMenuToStart(hMenu); bHooksActive := FALSE; 
      ELSE
        MsgBox("Error removing Filter Function","Event Monitor: Error");
      END; 
      W.EndDialog(hDlg, W.true); 
    
    (*-- Cancel button hit, keep current state ------*) 
    ELSIF (wParam = W.IDCANCEL) THEN
      IF (NrOfSelections(hDlg) # 0) THEN
        W.EndDialog(hDlg, W.true)          (* Exits the dialog box            *)
      ELSE  
        MsgBox("Select at least one message group","Event Monitor: Attention");
      END; 
    END;
    RETURN W.true 
  END;

  (*-- Didn't process a message ----------------------------------------------*)
  RETURN W.false                           
END Options;


(*============================================================================*)
(* PURPOSE:  Handles messages for window selection dialog                     *)
(*                                                                            *)
(* MESSAGES:                                                                  *)
(*   W.WM_INITDIALOG - initialize dialog box                                  *)
(*   W.WM_COMMAND    - Input received                                         *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hDlg           window handle of the dialog box                             *)
(* msg            type of message                                             *)
(* wParam         first parameter for the message                             *)
(* lParam         second parameter for the message                            *)
(*============================================================================*)
PROCEDURE [WINDOWS] SelectWnd*(hDlg: W.HWND;   
                               msg:  W.WORD;   
                               wParam: W.WORD; 
                               lParam: LONGINT
                              ): W.BOOL;
 
VAR 
  hListBox,                                 (* Handle to listbox              *)
  nIndex : INTEGER;                         (* Listbox index                  *)
  r : W.HWND;                               (* Some return values             *)
  ok : W.LRESULT; 
    
BEGIN
  (*-- Message: initialize dialog box ----------------------------------------*)
  IF msg = W.WM_INITDIALOG THEN            
    (*-- Fill listbox --*) 
    hDlgThisApp := hDlg;
    hListBox := W.GetDlgItem(hDlg, IDD_SELLIST); InitListBox(hListBox);

    (*-- Highlite current target window ---*)
    IF (hWndTarget # W.NULL) & (W.IsWindow(hWndTarget) # W.NULL) THEN            
      nIndex := LocateWnd(hListBox, hWndTarget); ASSERT(nIndex # W.LB_ERR);
      ok := W.SendMessage(hListBox, W.LB_SETCURSEL, nIndex, 0); ASSERT(ok # W.LB_ERR);
    END; 
    r := W.SetFocus(hDlg);                  (* Set input focus to listbox     *)
    RETURN W.true

  (*-- Message: received a command -------------------------------------------*)
  ELSIF msg = W.WM_COMMAND THEN             

    (*-- Ok-button of dialog was pressed ---*)
    IF wParam = W.IDOK THEN
      StopMsgLogging(); 
      hWndTarget := hWndSelected;
      IF ResetFilters() THEN                (* Remove Hooks                   *)
        ToggleMenuToStart(hMenu); W.DrawMenuBar(hWndThisApp); bHooksActive := FALSE; 
      ELSE
        MsgBox("Error removing Filter Function","Event Monitor: Error");
      END;
      W.EndDialog(hDlg, W.true);
      RETURN W.true

    (*-- Cancel-button of dialog pressed --*)
    ELSIF wParam = W.IDCANCEL THEN          
      W.EndDialog(hDlg, W.false);
      RETURN W.true

    (*-- Listbox was hit ------------------*)
    ELSIF wParam = IDD_SELLIST THEN         
      hListBox := W.GetDlgItem(hDlg, IDD_SELLIST); ASSERT(hListBox # W.NULL);
      
      IF Utils.HiWord(lParam) = W.LBN_SELCHANGE THEN   (* selection changed   *)
        nIndex := SYSTEM.VAL(INTEGER,W.SendMessage(hListBox, W.LB_GETCURSEL, 0, 0));
        ASSERT(nIndex # W.LB_ERR);
        hWndSelected := SYSTEM.VAL(W.HWND,W.SendMessage(hListBox, 
                                                        W.LB_GETITEMDATA, 
                                                        SYSTEM.VAL(W.WPARAM,nIndex), 
                                                        0));
        IF (W.IsWindow(hWndSelected) = W.NULL) THEN hWndSelected := 0; END                                             
      END
    END 
  END;
  
  (*-- Didn't process a message ----------------------------------------------*)
  RETURN W.false  
END SelectWnd;  
 

(*============================================================================*)
(* PURPOSE:  Processes messages                                               *)
(*                                                                            *)
(* MESSAGES:                                                                  *)
(*   W.WM_CREATE     - attempt to create window                               *)
(*   W.WM_COMMAND    - application menu                                       *)
(*   W.WM_DESTROY    - destroy window                                         *)
(*   W.WM_MENUSELECT - menu was selected                                      *)
(*   W.WM_SIZE       - window size changed                                    *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hWnd           Window handle                                               *)
(* msg            Message for the window                                      *)
(* wParam         First parameter for the message                             *)
(* lParam         Second parameter for the message                            *)
(*============================================================================*)
PROCEDURE [WINDOWS] MainWndProc*(hWnd: W.HWND;                                  
                                 msg:  W.WORD;                                  
                                 wParam: W.WPARAM;                              
                                 lParam: W.LPARAM                               
                                ): LONGINT;

VAR
  b  : BOOLEAN;
  r  : LONGINT;
  str : ARRAY 128 OF CHAR;

BEGIN
  (*-- Windows will be created, init common stuff ----------------------------*)
  IF msg = W.WM_CREATE THEN                    
     ToggleMenuToStart(hMenu);
     hWndThisApp := hWnd;                  (* catch own application           *)
     hWndTarget  := W.NULL;
     bHooksActive := FALSE;
     ReadIniFile(hInst,dlgStates); dlgStatesTmp := dlgStates;
     EmDll.RegisterSelection(GetSelectionFlag(dlgStates));
     IF (dlgStates.state[IDD_ENABLELOG-IDD_OFFSET].checked = W.true) THEN
       b := EmDll.RegisterLogFile(dlgStates.fileName,
            (dlgStates.state[IDD_OVERWRITE-IDD_OFFSET].checked = W.true));
     END;
     
  (*-- Window being destroyed ------------------------------------------------*)
  ELSIF msg = W.WM_DESTROY THEN            
     StopMsgLogging();
     IF bHooksActive & ~ResetFilters() THEN
       MsgBox("Error removing message filter","Event Monitor: Error");
     END;
     IF (dlgStates.state[IDD_SAVEOPTIONS-IDD_OFFSET].checked = W.true) THEN
       WriteIniFile(hInst,dlgStates);
     END;
     r := W.DestroyMenu(hMenu); ASSERT(r # W.NULL);
     W.PostQuitMessage(0)
     
  (*-- Window size changed, so change size of child windows too --------------*)
  ELSIF msg = W.WM_SIZE THEN
    IF bHooksActive THEN b := ResetFilters() END;  (* disable hooks temorarly *)
    r := W.SendMessage(hWndViewer, W.WM_SIZE, 0, 0);
    r := W.SendMessage(hWndStatLine, W.WM_SIZE, 0, 0);
    IF bHooksActive THEN b := SetFilters() END

  (*-- Menu selection activated, set text in statusline ----------------------*) 
  ELSIF msg = W.WM_MENUSELECT THEN
    str := "";
    IF W.LoadString(hInst,wParam, SYSTEM.ADR(str), LEN(str)) > 0 THEN
      StatLine.SetStatusLine(hWndStatLine, str);
    ELSE
      StatLine.SetStatusLine(hWndStatLine, "");
    END

  (*-- Command from application menu -----------------------------------------*)
  ELSIF msg = W.WM_COMMAND THEN            

    (*-- Menu entry "Exit" selected ------*)
    IF wParam = IDM_EXIT THEN              
      IF YesNoBox("Do you want to exit this program ?","Program Exit") THEN 
        RETURN W.DestroyWindow(hWnd)
      END;

    (*-- Menu entry "Select Window" hit --*)  
    ELSIF wParam = IDM_SELECT_WND THEN     
      r := W.DialogBox(hInst,              (* Current instance                *)
                       SYSTEM.ADR(RC_SELWND_BOX), (* Resource to use          *)
                       hWnd,               (* Parent handle                   *)
                       SelectWnd);         (* SelectWnd() instance address    *)
      ASSERT(r # -1); 

    (*-- Menu entry "Change options" -----*)
    ELSIF wParam = IDM_CHANGE_OPTIONS THEN 
      r := W.DialogBox(hInst,              
                       SYSTEM.ADR(RC_OPTIONS_BOX), 
                       hWnd,               
                       Options);           
      ASSERT(r # -1);
      W.DrawMenuBar(hWnd); 

    (*-- Menu entry "About" selected -----*)
    ELSIF wParam = IDM_ABOUT THEN          
      r := W.DialogBox(hInst,              
                       SYSTEM.ADR(RC_ABOUT_BOX), 
                       hWnd,               
                       About);             
      ASSERT(r # -1); 

    (*-- Start attempt by user -----------*)
    ELSIF ((wParam = IDM_MAIN_START) OR (wParam = IDM_START)) THEN
      (*-- Check target window --*)
      IF hWndTarget = W.NULL THEN
        MsgBox("No target window selected","Event Monitor: Attention");
      ELSIF (W.IsWindow(hWndTarget) = W.NULL) THEN
        MsgBox("Invalid window handle","Event Monitor: Error"); 
      ELSE
        EmDll.SetTargetWnd(hWndTarget);
        IF SetFilters() THEN               (* Insert Hooks                    *)
          ToggleMenuToStop(hMenu); W.DrawMenuBar(hWnd); bHooksActive := TRUE; 
          StartMsgLogging();
        ELSE
          MsgBox("Error installing Filter Function","Event Monitor: Error");
        END;
      END 

    (*-- Stop attempt by user ------------*)
    ELSIF ((wParam = IDM_MAIN_STOP) OR (wParam = IDM_STOP))THEN 
      IF ResetFilters() THEN               (* Remove Hooks                    *)
        ToggleMenuToStart(hMenu); W.DrawMenuBar(hWnd); bHooksActive := FALSE; 
        StopMsgLogging();
      ELSE
        MsgBox("Error removing Filter Function","Event Monitor: Error");
      END 

    (*-- User want's to clear viewer -----*)
    ELSIF (wParam = IDM_CLEAR) THEN 
      IF ResetFilters() THEN                                                    
        ToggleMenuToStart(hMenu); W.DrawMenuBar(hWnd); bHooksActive := FALSE; 
        StopMsgLogging();
        EmDll.ClearAll();
      ELSE
        MsgBox("Error removing Filter Function","Event Monitor: Error");
      END 

    (*-- No message to process -----------*)
    ELSE                                   
      RETURN W.DefWindowProc(hWnd, msg, wParam, lParam)
    END
  
  (*-- Let's Windows do the rest ---------------------------------------------*)
  ELSE                                
    RETURN W.DefWindowProc(hWnd, msg, wParam, lParam)
  END; 
  
  RETURN W.NULL 
END MainWndProc;


(*============================================================================*)
(* PURPOSE:  Initializes window data and registers window class               *)
(*                                                                            *)
(* COMMENTS: This function is called at initialization time only if no other  *)
(*           instances of the application are running.                        *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hInstCurr      Instance handle of the current instance                     *)
(*============================================================================*)
PROCEDURE InitApplication(hInstCurr: W.HANDLE): BOOLEAN;

VAR
  wc: W.WNDCLASS;

BEGIN
  (*-- Fill in window class structure --*)
  wc.style := W.CS_VREDRAW + W.CS_HREDRAW;  (* Class style(s).                *)
  wc.lpfnWndProc := MainWndProc;          (* Function to handle messages      *)
  wc.cbClsExtra := 0;                     (* No per-class extra data.         *)
  wc.cbWndExtra := 0;                     (* No per-window extra data.        *)
  wc.hInstance := hInstCurr;              (* Application that owns the class. *)
  wc.hIcon := W.LoadIcon(hInstCurr, SYSTEM.ADR("ApplIcon"));
  wc.hCursor := W.LoadCursor(W.NULL, W.IDC_ARROW);
  wc.hbrBackground := W.GetStockObject(W.WHITE_BRUSH); 
  wc.lpszMenuName := W.NULL;
  wc.lpszClassName := SYSTEM.ADR(CLASS_NAME); (* Name used in CreateWindow    *)
                                          (* Register the window class and    *)
                                          (*  return success/failure code.    *)
  RETURN W.RegisterClass(SYSTEM.ADR(wc)) # 0
END InitApplication;


(*============================================================================*)
(* PURPOSE:  Saves instance handle and creates main window                    *)
(*                                                                            *)
(* COMMENTS: This function is called at initialization time for every         *)
(*           instance of this application.                                    *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hInstCurr      Instance handle of the current instance                     *)
(* nCmdShow       Param for first ShowWindow() call                           *)
(*============================================================================*)
PROCEDURE InitInstance(hInstCurr:W.HANDLE;
                       nCmdShow: INTEGER  
                      ): BOOLEAN;

VAR 
  r: INTEGER;
  hWnd: W.HWND;                           (* Main window handle.              *)

BEGIN
  (*-- Save the instance handle in static variable --*)
  hInst := hInstCurr;
  hMenu := W.LoadMenu(hInst,SYSTEM.ADR(RC_MENU_NAME));

  (*-- Create a main window for this application instance. --*)
  hWnd := W.CreateWindow(SYSTEM.ADR(CLASS_NAME),(* Name of Class              *)
                         SYSTEM.ADR(TXT_TITLE_BAR),(* Text in window title bar*)
                         W.WS_OVERLAPPEDWINDOW, (* Window style(s)            *)
                         W.CW_USEDEFAULT, (* Default horizontal position      *)
                         W.CW_USEDEFAULT, (* Default vertical position        *)
                         W.CW_USEDEFAULT, (* Default width                    *)
                         W.CW_USEDEFAULT, (* Default height                   *)
                         W.NULL,          (* Overlapped windows have no parent*)
                         hMenu,           (* Use the window class menu        *)
                         hInstCurr,       (* This instance owns this window   *)
                         W.NULL);         (* Pointer not needed               *)

  (*-- If window could not be created, return "failure" --*)
  IF hWnd = 0 THEN RETURN FALSE END;

  (*-- Make the window visible; update its client area --*)                   
  r := W.ShowWindow(hWnd, nCmdShow);      (* Show the window                  *)
  W.UpdateWindow(hWnd);                   (* Sends WM_PAINT message           *)
 
  (*-- Create viewer window where output goes to --*) 
  hWndViewer := EmDll.CreateViewer(hWnd, hInstCurr);
  ASSERT(hWndViewer # 0);
  EmDll.SetBottomSpace(25);
  r := W.ShowWindow(hWndViewer, nCmdShow);(* Show the window                  *)
  W.UpdateWindow(hWndViewer);             (* Sends WM_PAINT message           *)
  
  (*-- Create statusline --*) 
  hWndStatLine := StatLine.CreateStatusLine(hWnd, hInstCurr);
  ASSERT(hWndStatLine # 0);
  r := W.ShowWindow(hWndStatLine, nCmdShow);(* Show the window                  *)
  StatLine.SetStatusLine(hWndStatLine,"Welcome to Event Monitor V1.0");
  W.UpdateWindow(hWndStatLine);             (* Sends WM_PAINT message           *)
  
  RETURN TRUE 
END InitInstance;


(*============================================================================*)
(* PURPOSE:  Calls initialization function, processes message loop            *)
(*                                                                            *)
(* COMMENTS: Windows recognizes this function by name as the initial entry    *)
(*           point for the program.  This function calls the application      *)
(*           initialization routine, if no other instance of the program is   *)
(*           running, and always calls the instance initialization routine.   *)
(*           It then executes a message retrieval and dispatch loop that is   *)
(*           the top-level control structure for the remainder of execution.  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hInstCurr      Instance handle for the current instance of this application*)
(* hInstPrev      Instance handle for the previously loaded instance          *)
(* lpCmdLine      Command line (far pointer to a null terminated string)      *)
(* nCmdShow       This parameter says how the main window should be displayed.*)
(*============================================================================*)
PROCEDURE [WINDOWS] WinMain*(hInstCurr: W.HANDLE;    
                             hInstPrev: W.HANDLE;    
                             lpCmdLine: W.LPSTR;     
                             nCmdShow: INTEGER       
                            ): INTEGER;              

VAR 
  r: LONGINT;                              (* Dummy result value              *)
  msg: W.MSG;                              (* Message                         *)

BEGIN

  (*-- Initialize first instance --*)
  IF hInstPrev = W.NULL THEN               (* Other instances of app running? *)
    IF ~InitApplication(hInstCurr) THEN    (* Initialize shared things        *)
      MsgBox("Could not register window class !","Event Monitor: Error");
      RETURN W.false;                      (* Exits if unable to initialize   *)
    END;
  ELSE
    MsgBox("Application is already running !","Event Monitor: Attention");
    RETURN W.false; 
  END;
                                          
  (*-- Initialize the current instance --*)
  IF ~InitInstance(hInstCurr, nCmdShow) THEN
    MsgBox("Could not create main window", "Event Monitor: Error");
    RETURN W.false; 
  END;
  
  (*-- Standard message loop --*)
  WHILE W.GetMessage(SYSTEM.ADR(msg),      (* Message structure               *)
                     W.NULL,               (* Handle of window receiving msg  *)
                     W.NULL,               (* Lowest message to examine       *)
                     W.NULL) # 0 DO        (* Highest message to examine      *)

    r := W.TranslateMessage(SYSTEM.ADR(msg)); (* Translates virtual key codes *)
    r := W.DispatchMessage(SYSTEM.ADR(msg))   (* Dispatches message to window *)
  END;
  RETURN msg.wParam 
END WinMain;

BEGIN 
END EventMon.
