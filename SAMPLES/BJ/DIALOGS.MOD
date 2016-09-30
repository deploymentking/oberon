(**************************************************************************)
(*                                                                        *)
(*  Fallstudien Betriebssysteme: Windowsprogrammierung mit Oberon-2       *)
(*  Abschlußprojekt:    Black Jack                                        *)
(*  Aufgabe:            Kartenspiel unter Verwendung von cardList.DLL     *)
(*                                                                        *)
(*  Modulname:          DIALOGS.MOD                                       *)
(*  Aufgabe:            Dialog für den Spielbetrieb                       *)
(*                                                                        *)
(*  Autoren:            Gschnell Christian, 9155609, 880                  *)
(*                      Jungwirth Josef,    9155355, 880                  *)
(*                      Köttstorfer Marco,  9155255, 880                  *)
(*                                                                        *)
(*  Erstellt am:        02.05.1995                                        *)
(*  Änderungen:         05.05.1995 - Messages abfangen                    *)
(*                      06.05.1995 - Optimierung der Kartendarstellung    *)
(*                      12.03.1997 - Änderung an windows callback         *)
(*                                   functions                            *)
(*                                                                        *)
(*                                                                        *)
(**************************************************************************)

MODULE Dialogs;

IMPORT W:=Windows, WU := WinUtils, SYSTEM, P:=Players, G := General, C := Cards, Strings;

CONST ID_CARD       = 20;
      ID_STAY       = 21;
      ID_DOUBLE     = 22;
      ID_TILE       = 23;
      ID_INSURE     = 24;
      
      ID_PLAYERNAME = 250;
      ID_BET        = 251;
      ID_HAND0      = 252;
      ID_HAND1      = 253;
      ID_HANDNO     = 254;
      
      ID_CARDS      = 100;


      ID_PLAYER0    = 100;
      ID_PLAYERNAME0= 200;
      
      ID_BETVALUE   = 101;      
      

VAR player     : P.PPlayer;
    cardRect   : W.RECT;        (* Rechteck, in dem die Karten dargestellt werden *)
    hand       : SHORTINT;

    table      : P.PTable;
    playing    : BOOLEAN;
    pdRect     : W.RECT;        (* Rechteck des Spieldialogs     *)
    bdRect     : W.RECT;        (* Rechteck des Einsatzdialogs   *)
    gPlay*     : BOOLEAN;

(**********************************************************************************)

PROCEDURE PaintPlayerDlg(hWin: W.HWND);
  VAR   ps        : W.PAINTSTRUCT;
        dc        : W.HDC;
        dummy     : LONGINT;
        rect      : G.P3DRect;

  BEGIN
    dc := W.BeginPaint(hWin, SYSTEM.ADR(ps));

    NEW(rect); G.Init3DRect(rect, cardRect.left, cardRect.top, cardRect.right, cardRect.bottom,
                            WU.RGB(0, 128, 0), WU.RGB(128, 128, 128), WU.RGB(255, 255, 255), TRUE);
    rect.Draw(dc);
    rect.Destroy(); DISPOSE(rect);

    (* Abfragen, ob eine oder zwei 'Hands' gezeichnet werden müssen *)
    IF (player.tiled) THEN
      player.hand[0].DrawOffs(dc, cardRect.left+15, cardRect.top+10);
      player.hand[1].DrawOffs(dc, cardRect.left+15, cardRect.top+110);
    ELSE
      player.hand[0].DrawOffs(dc, cardRect.left+15, cardRect.top+60);
    END;

    W.EndPaint(hWin, SYSTEM.ADR(ps));
  END PaintPlayerDlg;

(**************************************************************************)

PROCEDURE UpdatePlayerDlg(hDlg : W.HWND);
VAR dummy   : LONGINT;
    onoff   : W.BOOL;
    sum     : ARRAY 255 OF CHAR;
    money   : ARRAY 10  OF CHAR;
    i       : INTEGER;

BEGIN
  Strings.Str(player.bet,money);
  W.SetDlgItemText(hDlg,ID_BET,SYSTEM.ADR(money));
  i := player.hand[hand].GetBestCardSum();
  (* Wenn sich der arme Spieler die Finger verbrannt hat, drehen wir ihm *)
  (* den Dialog noch nicht gleich ab, sondern wir lassen ihm die bren-   *)
  (* nende Hand noch bewundern. Wenn er sich satt gesehen hat, kann er   *)
  (* sein Leiden mit dem Button 'Schließen' beenden.                     *)
  IF (i > 21) THEN
    W.SetDlgItemText(hDlg, ID_HAND0+hand, SYSTEM.ADR("obrennd!!"));


    IF ((hand = 0) & player.tiled) THEN
      hand := 1;
      W.SetDlgItemText(hDlg, ID_HANDNO, SYSTEM.ADR("Hand 2"));
    ELSE
      dummy := W.ShowWindow(W.GetDlgItem(hDlg, ID_STAY), W.SW_HIDE);
      dummy := W.ShowWindow(W.GetDlgItem(hDlg, W.IDCANCEL), W.SW_NORMAL);
      dummy := W.SetFocus(W.GetDlgItem(hDlg, W.IDCANCEL));
      (* alle anderen Buttons deaktivieren *)
      FOR i := ID_CARD TO ID_INSURE DO
        dummy := W.EnableWindow(W.GetDlgItem(hDlg, i), W.false);
      END;
      RETURN;
    END;

  ELSE
    IF player.HasBlackJack(hand) THEN
      W.SetDlgItemText(hDlg, ID_HAND0+hand, SYSTEM.ADR("Black Jack"));
    ELSIF player.HasTriplet(hand) THEN
      W.SetDlgItemText(hDlg, ID_HAND0+hand, SYSTEM.ADR("Triplet"));
    ELSE
      Strings.Str(player.hand[hand].GetBestCardSum(), sum);
      W.SetDlgItemText(hDlg, ID_HAND0+hand, SYSTEM.ADR(sum));
    END;
  END;

  IF player.IsDoubleActivateable(hand) THEN onoff := 1 ELSE onoff := 0 END;
  dummy := W.EnableWindow(W.GetDlgItem(hDlg, ID_DOUBLE), onoff);

  IF player.IsCardActivateable(hand) THEN onoff := 1 ELSE onoff := 0 END;
  dummy := W.EnableWindow(W.GetDlgItem(hDlg, ID_CARD), onoff);

  IF player.IsStayActivateable(hand) THEN onoff := 1 ELSE onoff := 0 END;
  dummy := W.EnableWindow(W.GetDlgItem(hDlg, ID_STAY), onoff);

  IF player.IsTileActivateable(hand) THEN onoff := 1 ELSE onoff := 0 END;
  dummy := W.EnableWindow(W.GetDlgItem(hDlg, ID_TILE), onoff);

  IF player.IsInsureActivateable(hand) THEN onoff := 1 ELSE onoff := 0 END;
  dummy := W.EnableWindow(W.GetDlgItem(hDlg, ID_INSURE), onoff);

END UpdatePlayerDlg;

(**************************************************************************)

PROCEDURE [WINDOWS] PlayerDlgProc*(hDlg: W.HWND; message: W.WORD;
                                   wParam: W.WORD; lParam: LONGINT): W.BOOL;
VAR dc       : W.HDC;
    ps       : W.PAINTSTRUCT;
    cardWnd  : W.HWND;
    p        : W.POINT;
    dummy    : INTEGER;
    sum      : ARRAY 6 OF CHAR;

BEGIN
  IF message = W.WM_INITDIALOG THEN
     IF (pdRect.left # 0) OR (pdRect.top # 0) THEN
       dummy := W.MoveWindow(hDlg, pdRect.left, pdRect.top, pdRect.right-pdRect.left,
                             pdRect.bottom-pdRect.top, W.false);
     END;

    (* Das Kartenfenster hat eine fixe Position und Größe. Diese ermitteln wir *)
    (* uns hier und können sie dann für das Zeichnen verwenden. Durch das      *)
    (* Gruppenfenster 'Karten' ist die Größe und Position indirekt festgelegt. *)
    (* Wir ermitteln zuerst das Handle dieses Fensters mit dessen Hilfe wir    *)
    (* die Abmessungen erhalten. Nun müssen wir die Position innerhalb des     *)
    (* Dialogfensters ermitteln. Dazu ermitteln wir die Screen-Position und    *)
    (* darauf folgend die Client-Position dieses Ergebnisses im Dialogfenster. *)
    cardWnd := W.GetDlgItem(hDlg, ID_CARDS);
    W.GetClientRect(cardWnd, SYSTEM.ADR(cardRect));
    p.x := cardRect.left;
    p.y := cardRect.top;
    W.ClientToScreen(cardWnd, SYSTEM.ADR(p));
    W.ScreenToClient(hDlg, SYSTEM.ADR(p));

    cardRect.left := cardRect.left + p.x + 5;          (* Rand berücksichtigen *)
    cardRect.top := cardRect.top + p.y + 15;
    cardRect.right := cardRect.right + p.x - 5;
    cardRect.bottom := cardRect.bottom + p.y - 5;

    hand := 0;
    W.SetDlgItemText(hDlg, ID_HANDNO, SYSTEM.ADR("Hand 1"));
    W.SetDlgItemText(hDlg, ID_PLAYERNAME, SYSTEM.ADR(player.name));
    UpdatePlayerDlg(hDlg);                        (* Status der Buttons setzen *)
    RETURN W.true

  ELSIF message = W.WM_PAINT THEN
    PaintPlayerDlg(hDlg)
  ELSIF message = W.WM_COMMAND THEN
    IF (wParam = W.IDCANCEL) THEN
      playing := FALSE;
      W.GetWindowRect(hDlg, SYSTEM.ADR(pdRect));
      W.EndDialog(hDlg, W.true)            (* Exits the dialog box             *)
    ELSE
      IF    (wParam = ID_CARD) THEN player.ActionCard(hand);
      ELSIF (wParam = ID_STAY) THEN
        gPlay := TRUE;
        IF ((hand = 0) & player.tiled) THEN
          hand := 1;
          W.SetDlgItemText(hDlg, ID_HANDNO, SYSTEM.ADR("Hand 2"));
        ELSE
          playing := FALSE;
          W.GetWindowRect(hDlg, SYSTEM.ADR(pdRect));
          W.EndDialog(hDlg, W.true);
        END;
      ELSIF (wParam = ID_DOUBLE) THEN player.ActionDouble(hand);
        gPlay := TRUE;
        dummy := W.ShowWindow(W.GetDlgItem(hDlg, ID_STAY), W.SW_HIDE);
        dummy := W.ShowWindow(W.GetDlgItem(hDlg, W.IDCANCEL), W.SW_NORMAL);
        dummy := W.SetFocus(W.GetDlgItem(hDlg, W.IDCANCEL));
      ELSIF (wParam = ID_TILE) THEN player.ActionTile(hand);
        Strings.Str(player.hand[1].GetBestCardSum(), sum);
        W.SetDlgItemText(hDlg, ID_HAND0+1, SYSTEM.ADR(sum));
        IF ~player.IsCardActivateable(hand) THEN
          gPlay := TRUE;
          dummy := W.ShowWindow(W.GetDlgItem(hDlg, ID_STAY), W.SW_HIDE);
          dummy := W.ShowWindow(W.GetDlgItem(hDlg, W.IDCANCEL), W.SW_NORMAL);
          dummy := W.SetFocus(W.GetDlgItem(hDlg, W.IDCANCEL));
        END;
      ELSIF (wParam = ID_INSURE) THEN player.ActionInsure(hand);
      END;
      UpdatePlayerDlg(hDlg);

      (* Es wird nur das Kartenfenster neu gezeichnet *)
      W.InvalidateRect(hDlg, SYSTEM.ADR(cardRect), 1);
    END;
    RETURN W.true
  ELSIF message = W.WM_CLOSE THEN
    W.GetWindowRect(hDlg, SYSTEM.ADR(pdRect));
    IF playing THEN RETURN W.true; END;
  END;
  RETURN W.false                          (* Didn't process a message         *)
END PlayerDlgProc;

(***********************************************************************************)

PROCEDURE ExecutePlayerDlg*(aInst : W.HINSTANCE; aWnd : W.HWND; aPlayer : P.PPlayer);
VAR i: INTEGER;
BEGIN
  player := aPlayer;
  i := W.DialogBox(aInst,             (* current instance                 *)
                   SYSTEM.ADR("PlayerDlg"),
                                      (* resource to use                  *)
                   aWnd,              (* parent handle                    *)
                   PlayerDlgProc);    (* About() instance address         *)
END ExecutePlayerDlg;

(**************************************************************************)

PROCEDURE [WINDOWS] NameDlgProc*(hDlg: W.HWND; message: W.WORD;
                                 wParam: W.WORD; lParam: LONGINT): W.BOOL;
VAR i     : INTEGER;
    dummy : LONGINT;
    name  :  ARRAY G.MAXSTRLEN+1 OF CHAR;
BEGIN
  IF message = W.WM_INITDIALOG THEN
    FOR i := 1 TO table.noOfPlayers DO
      dummy := W.EnableWindow(W.GetDlgItem(hDlg, ID_PLAYERNAME0 + i), W.true);
      dummy := W.EnableWindow(W.GetDlgItem(hDlg, ID_PLAYER0 + i), W.true);
      W.SetDlgItemText(hDlg,ID_PLAYER0+i,SYSTEM.ADR(table.playerList[i-1].name));
    END;
    RETURN W.true
  ELSIF message = W.WM_COMMAND THEN
    IF (wParam = W.IDOK) THEN
      FOR i := 1 TO table.noOfPlayers DO
        dummy := W.GetDlgItemText(hDlg,ID_PLAYER0+i,SYSTEM.ADR(name), G.MAXSTRLEN);
        table.playerList[i-1].SetName(name);
      END;
      W.EndDialog(hDlg, W.true);
      RETURN W.true;
    ELSIF (wParam = W.IDCANCEL) THEN
      W.EndDialog(hDlg, W.true);         (* Exits the dialog box             *)
      RETURN W.true;
    END;
  END;
  RETURN W.false;
END NameDlgProc;

(***********************************************************************************)

PROCEDURE ExecuteNameDlg*(aInst : W.HINSTANCE; aWnd : W.HWND; aTable : P.PTable);
VAR i: INTEGER;
BEGIN
  table := aTable;
  i := W.DialogBox(aInst,             (* current instance                 *)
                   SYSTEM.ADR("PlayerName"),
                                      (* resource to use                  *)
                   aWnd,              (* parent handle                    *)
                   NameDlgProc);      (* About() instance address         *)
END ExecuteNameDlg;

(***********************************************************************************)

PROCEDURE [WINDOWS] BetDlgProc*(hDlg: W.HWND; message: W.WORD;
                                 wParam: W.WORD; lParam: LONGINT): W.BOOL;
VAR i       : INTEGER;
    dummy   : LONGINT;
    money   : ARRAY 10 OF CHAR;
    ok      : BOOLEAN;
    helpTxt : ARRAY 500 OF CHAR;
    str     : ARRAY 80 OF CHAR;
    bet     : LONGINT;
    eOK     : W.BOOL;
BEGIN
  IF message = W.WM_INITDIALOG THEN
     IF (bdRect.left # 0) OR (bdRect.top # 0) THEN
       dummy := W.MoveWindow(hDlg, bdRect.left, bdRect.top, bdRect.right-bdRect.left,
                             bdRect.bottom-bdRect.top, W.false);
     END;

    W.SetWindowText(hDlg,SYSTEM.ADR(player.name));
    Strings.Str(player.bet,money);
    W.SetDlgItemText(hDlg,ID_BETVALUE,SYSTEM.ADR(money));
    playing := TRUE;
    RETURN W.true
  ELSIF message = W.WM_COMMAND THEN
    IF (wParam = W.IDOK) THEN
      bet := W.GetDlgItemInt(hDlg, ID_BETVALUE, SYSTEM.ADR(eOK), W.false);
      IF (eOK = 0) THEN         (* nicht sehr schön, aber es geht leider nicht anders *)
        ASSERT(W.MessageBox(0, SYSTEM.ADR("Die Eingabe ist leer oder enthält ungültige Ziffern"),
               SYSTEM.ADR("Eingabefehler"), W.MB_OK) # W.NULL);
        RETURN W.true;
      END;

      player.SetBet(bet ,ok);
      IF ok THEN
        W.GetWindowRect(hDlg, SYSTEM.ADR(bdRect));
        W.EndDialog(hDlg, W.true);
      ELSE
        G.StringCopy(helpTxt, "Einsatz muß den Tischrestriktionen (zwischen ");
        Strings.Str(player.table.minBet, str); Strings.Append(helpTxt, str);
        G.StringCopy(str, " und "); Strings.Append(helpTxt, str);
        Strings.Str(player.table.maxBet, str); Strings.Append(helpTxt, str);
        G.StringCopy(str, ") entsprechen und darf nicht höher als ihr Kredit (");
        Strings.Append(helpTxt, str);
        Strings.Str(player.credit, str); Strings.Append(helpTxt, str);
        G.StringCopy(str, ") sein !"); Strings.Append(helpTxt, str);
        ASSERT(W.MessageBox(0, SYSTEM.ADR(helpTxt),
                            SYSTEM.ADR("Ungültiger Einsatz"), W.MB_OK) # W.NULL);
      END;
      RETURN W.true;
    END;
  ELSIF message = W.WM_CLOSE THEN
    RETURN W.true;
  END;
  RETURN W.false;
END BetDlgProc;

(***********************************************************************************)

PROCEDURE ExecuteBetDlg*(aInst : W.HINSTANCE; aWnd : W.HWND; aPlayer : P.PPlayer);
VAR i: INTEGER;
BEGIN
  player := aPlayer;
  i := W.DialogBox(aInst,             (* current instance                 *)
                   SYSTEM.ADR("BetDlg"),
                                      (* resource to use                  *)
                   aWnd,              (* parent handle                    *)
                   BetDlgProc);       (* About() instance address         *)
END ExecuteBetDlg;

(***********************************************************************************)

PROCEDURE [WINDOWS] AboutDlgProc*(hDlg: W.HWND; message: W.WORD;
                                 wParam: W.WORD; lParam: LONGINT): W.BOOL;

BEGIN
  IF message = W.WM_INITDIALOG THEN
    RETURN W.true
  ELSIF message = W.WM_COMMAND THEN
    IF (wParam = W.IDOK) THEN
      W.EndDialog(hDlg, W.true);
      RETURN W.true;
    END;
  END;
  RETURN W.false;
END AboutDlgProc;

(***********************************************************************************)

PROCEDURE ExecuteAboutDlg*(aInst : W.HINSTANCE; aWnd : W.HWND);
VAR i: INTEGER;
BEGIN
  i := W.DialogBox(aInst,             (* current instance                 *)
                   SYSTEM.ADR("About"),
                                      (* resource to use                  *)
                   aWnd,              (* parent handle                    *)
                   AboutDlgProc);     (* About() instance address         *)
END ExecuteAboutDlg;

(***********************************************************************************)


BEGIN
  playing := FALSE;
  pdRect.left := 0;
  pdRect.top := 0;
  bdRect.left := 0;
  bdRect.top := 0;
END Dialogs.
