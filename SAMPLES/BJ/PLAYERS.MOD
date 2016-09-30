(**************************************************************************)
(*                                                                        *)
(*  Fallstudien Betriebssysteme: Windowsprogrammierung mit Oberon-2       *)
(*  Abschlußprojekt:    Black Jack                                        *)
(*  Aufgabe:            Kartenspiel unter Verwendung von CARDS.DLL        *)
(*                                                                        *)
(*  Modulname:          PLAYERS.MOD                                       *)
(*  Aufgabe:            Funktionalität von Tisch, Croupier, Spieler       *)
(*                                                                        *)
(*  Autoren:            Gschnell Christian, 9155609, 880                  *)
(*                      Jungwirth Josef,    9155355, 880                  *)
(*                      Köttstorfer Marco,  9155255, 880                  *)
(*                                                                        *)
(*  Erstellt am:        16.04.95 - TTable, TCroupier, TPlayer             *)
(*  Änderungen:         16.03.97 - Als vorgeschlagener Wetteinsatz eines  *)
(*                                 Spielers wird der Minimumeinsatz am    *)
(*                                 Tisch eingestellt.                     *)
(*                                                                        *)
(**************************************************************************)

MODULE Players;

IMPORT W := Windows, SYSTEM, C := Cards, G := General, Strings, I := Ini;

CONST MAXPLAYERS = 7;

TYPE PTable*    = POINTER TO TTable;
     PCroupier* = POINTER TO TCroupier;
     PPlayer*   = POINTER TO TPlayer;

TYPE TPlayer* = RECORD(G.TDrawable)
       table-     : PTable;
       croupier-  : PCroupier;
       name-      : ARRAY G.MAXSTRLEN+1 OF CHAR;
       hand-      : ARRAY 2 OF C.PCardList;
       stayed-    : ARRAY 2 OF BOOLEAN;
       credit-    : LONGINT;
       bet-       : LONGINT;
       doubled-   : BOOLEAN;
       tiled-     : BOOLEAN;
       insured-   : BOOLEAN;
       lastProfit-: LONGINT;
       number     : LONGINT;
     END;

     TCroupier* = RECORD(G.TDrawable)
       table-       : PTable;
       hand-        : C.PCardList;
     END;

     TTable* = RECORD(G.TDrawable)
       wnd-         : W.HWND;
       stack-       : C.PCardList;
       croupier-    : PCroupier;
       noOfPlayers- : SHORTINT;
       playerList-  : ARRAY MAXPLAYERS OF PPlayer;
       minBet-      : LONGINT;
       maxBet-      : LONGINT;
     END;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE InitCroupier*(c : PCroupier; aX, aY : INTEGER; aTable : PTable);
BEGIN
  G.InitDrawable(c, aX, aY);
  c.table := aTable;
  NEW(c.hand); C.InitCardList(c.hand, TRUE, NIL);
END InitCroupier;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR c : TCroupier) TakeCardList*(aList : C.PCardList);
BEGIN
  c.table.stack.Merge(aList^);
END TakeCardList;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR c : TCroupier) Reset*();
VAR i : SHORTINT;
BEGIN
  c.TakeCardList(c.hand);
END Reset;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR c : TCroupier) Destroy*();
BEGIN
  c.Reset();
  c.hand.Destroy(); DISPOSE(c.hand);
  c.Destroy^();
END Destroy;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR c : TCroupier) GiveCard*() : C.PCard;
BEGIN
  RETURN c.table.stack.Retrieve();
END GiveCard;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR c : TCroupier) HasBlackJack*() : BOOLEAN;
BEGIN
  RETURN c.hand.IsBlackJack();
END HasBlackJack;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE (VAR p : TPlayer) Reset*();
BEGIN
  p.croupier.TakeCardList(p.hand[0]);
  p.croupier.TakeCardList(p.hand[1]);
  p.doubled    := FALSE;
  p.tiled      := FALSE;
  p.insured    := FALSE;
  p.stayed[0]  := FALSE;
  p.stayed[1]  := FALSE;
  p.lastProfit := 0;
END Reset;

(*---------------------------------------------------------------------------*)

PROCEDURE InitPlayer*(p : PPlayer; aX, aY : INTEGER; 
                      aPlayerNo : SHORTINT;aTable : PTable);
(*VAR numberStr : ARRAY 2 OF CHAR;*)
BEGIN
  G.InitDrawable(p, aX, aY);
  p.table := aTable;
  p.croupier := aTable.croupier;
(*  Strings.Str(aPlayerNo, numberStr);
  p.name := "Spieler ";*)
  Strings.Copy(I.PlayerTable[aPlayerNo-1],p.name,1,Strings.Length(I.PlayerTable[aPlayerNo-1]));
  p.number := aPlayerNo;
(*  Strings.Append(p.name, numberStr);*)
  NEW(p.hand[0]); C.InitCardList(p.hand[0], TRUE, NIL);
  NEW(p.hand[1]); C.InitCardList(p.hand[1], TRUE, NIL);
  p.credit := G.DEF_CREDIT;
  p.bet    := I.minBet; (* G.DEF_BET; *)
  p.Reset();
END InitPlayer;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) Destroy*();
BEGIN
  p.Reset();
  p.hand[0].Destroy(); DISPOSE(p.hand[0]);
  p.hand[1].Destroy(); DISPOSE(p.hand[1]);
  p.Destroy^();
END Destroy;

(*---------------------------------------------------------------------------*)

PROCEDURE CheckHandNo(no : SHORTINT);
BEGIN
  ASSERT((no = 0) OR (no = 1));
END CheckHandNo;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) DrawHand*(dc : W.HDC; aHand : SHORTINT);
BEGIN
  CheckHandNo(aHand);
  p.hand[aHand].Draw(dc);
END DrawHand;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) SetCredit*(aCredit : LONGINT);
BEGIN
  ASSERT(aCredit > 0);
  p.credit := aCredit;
END SetCredit;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) SetBet*(aBet : LONGINT; VAR ok : BOOLEAN);
BEGIN
  ok := (aBet >= p.table.minBet) & (aBet <= p.table.maxBet) & (aBet <= p.credit);
  IF ok THEN p.bet := aBet END;
END SetBet;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) GetBet*(): LONGINT;
VAR      result    : LONGINT;
BEGIN
  result := p.bet;
  IF (p.tiled OR p.doubled) THEN
    result := 2 * result;
  END;

  IF (p.insured) THEN
    result := result + (p.bet+1) DIV 2;
  END;
  RETURN result;
END GetBet;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) HasEnoughMoney*(): BOOLEAN;
  BEGIN
    RETURN (p.credit >= p.table.minBet);
  END HasEnoughMoney;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) SetName*(VAR aName : ARRAY OF CHAR);
BEGIN
  G.StringCopy(p.name, aName);
  G.StringCopy(I.PlayerTable[p.number-1],p.name);
END SetName;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) HasBlackJack*(aHand : SHORTINT) : BOOLEAN;
BEGIN
  CheckHandNo(aHand);
  RETURN ~p.tiled & p.hand[aHand].IsBlackJack();
END HasBlackJack;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) HasTriplet*(aHand : SHORTINT) : BOOLEAN;
BEGIN
  CheckHandNo(aHand);
  RETURN p.hand[aHand].IsTriplet();
END HasTriplet;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) IsCardActivateable*(aHand : SHORTINT) : BOOLEAN;
BEGIN
  CheckHandNo(aHand);
  IF p.stayed[aHand] THEN RETURN FALSE END;
  IF (p.tiled & (p.hand[aHand].cardList[0].valency = 11) & 
                (p.hand[aHand].noOfCards = 2)) THEN
    RETURN FALSE;
  END;
  RETURN p.hand[aHand].GetBestCardSum() <= 21;
END IsCardActivateable;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) ActionCard*(aHand : SHORTINT);
BEGIN
  ASSERT(p.IsCardActivateable(aHand));
  p.hand[aHand].Insert(p.croupier.GiveCard());
  IF p.HasTriplet(aHand) THEN INC(p.credit, p.bet) END;
                                             (* Prämie in Höhe des Einsatzes *)
END ActionCard;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) IsStayActivateable*(aHand : SHORTINT) : BOOLEAN;
BEGIN
  RETURN p.IsCardActivateable(aHand);
END IsStayActivateable;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) ActionStay*(aHand : SHORTINT);
BEGIN
  ASSERT(p.IsStayActivateable(aHand));
  p.stayed[aHand] := TRUE;
END ActionStay;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) IsDoubleActivateable*(aHand : SHORTINT) : BOOLEAN;
BEGIN
  CheckHandNo(aHand);
  IF p.stayed[aHand] THEN RETURN FALSE END;
  IF (p.tiled OR p.insured) THEN RETURN FALSE END;
  IF (p.credit < 2*p.bet) THEN RETURN FALSE END;
  RETURN p.hand[aHand].IsDoubleable();
END IsDoubleActivateable;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) ActionDouble*(aHand : SHORTINT);
BEGIN
  ASSERT(p.IsDoubleActivateable(aHand));
  p.doubled := TRUE;
  p.hand[aHand].Insert(p.croupier.GiveCard());
  p.stayed[aHand] := TRUE;
END ActionDouble;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) IsTileActivateable*(aHand : SHORTINT) : BOOLEAN;
VAR neededMoney : LONGINT;
BEGIN
  CheckHandNo(aHand);
  IF p.stayed[aHand] THEN RETURN FALSE END;
  IF (p.tiled) THEN RETURN FALSE END;
  neededMoney := p.bet;
  IF (p.insured) THEN INC(neededMoney, (neededMoney+1) DIV 2) END;
  IF (p.credit < 2*neededMoney) THEN RETURN FALSE END;
  RETURN p.hand[aHand].IsTileable();
END IsTileActivateable;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) ActionTile*(aHand : SHORTINT);
VAR dc : W.HDC;
    ps : W.PAINTSTRUCT;
BEGIN
  ASSERT(p.IsTileActivateable(aHand));
  p.hand[0].Tile(p.hand[1]^);
  p.tiled := TRUE;
  p.hand[0].Insert(p.croupier.GiveCard());
  p.hand[1].Insert(p.croupier.GiveCard());
END ActionTile;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) IsInsureActivateable*(aHand : SHORTINT) : BOOLEAN;
BEGIN
  CheckHandNo(aHand);
  IF p.stayed[aHand] THEN RETURN FALSE END;
  IF (p.credit < (p.bet+1) DIV 2) THEN RETURN FALSE END;
  RETURN ~p.tiled & ~p.insured & (p.hand[aHand].noOfCards = 2) &
         (p.croupier.hand.cardList[0].valency = 11);
END IsInsureActivateable;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) ActionInsure*(aHand : SHORTINT);
BEGIN
  ASSERT(p.IsInsureActivateable(aHand));
  p.insured := TRUE;
END ActionInsure;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) IsPlayingDialogActivateable*(aHand : SHORTINT) : BOOLEAN;
BEGIN
  RETURN p.IsCardActivateable(aHand);
END IsPlayingDialogActivateable;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) GetHandString*(aHand : SHORTINT; VAR aStr : ARRAY OF CHAR);
VAR cardSum : INTEGER;
BEGIN
  IF    p.HasBlackJack(aHand) THEN G.StringCopy(aStr, "BJ");
  ELSIF p.HasTriplet(aHand)   THEN G.StringCopy(aStr, "Tri");
  ELSE
    cardSum := p.hand[aHand].GetBestCardSum();
    IF (cardSum > 21) THEN G.StringCopy(aStr, "-") ELSE Strings.Str(cardSum, aStr) END;
  END;
END GetHandString;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) GetHandsString*(VAR aStr : ARRAY OF CHAR);
VAR handNo : SHORTINT;
    str    : ARRAY 10 OF CHAR;
BEGIN
  p.GetHandString(0, aStr);
  IF p.tiled THEN
    Strings.Append(aStr, " / ");
    p.GetHandString(1, str);
    Strings.Append(aStr, str);
  END;
END GetHandsString;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) Profit*(aHand : SHORTINT) : INTEGER;
VAR percent : INTEGER;
BEGIN
  CheckHandNo(aHand);
  IF (p.HasBlackJack(aHand)) THEN
    percent := 150;
  ELSIF (p.croupier.HasBlackJack()) THEN
    IF ~p.insured THEN percent := -100 ELSE percent := 0 END;
  ELSE
    percent := 100*p.hand[aHand].Compare(p.croupier.hand);
  END;
  IF p.doubled THEN percent := 2*percent END;
  RETURN percent;
END Profit;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR p : TPlayer) ExecPayOut*();
VAR handNo : SHORTINT;
    percent : LONGINT;
BEGIN
  IF p.tiled THEN handNo := 1 ELSE handNo := 0 END;
  p.lastProfit := 0;
  WHILE (handNo >= 0) DO
    percent := p.Profit(handNo);
    INC(p.lastProfit, percent * p.bet DIV 100);
    IF p.insured THEN DEC(p.lastProfit, (p.bet+1) DIV 2) END;
    DEC(handNo);
  END;
  INC(p.credit, p.lastProfit);
END ExecPayOut;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE InitTable*(t : PTable; aWnd : W.HWND; aNoOfPlayers : SHORTINT;
                     aInvisibleShape : G.PBitmap; aMinBet, aMaxBet : LONGINT);
VAR card : C.PCard;
    i : SHORTINT;
    valency : SHORTINT;
    bitmap : G.PBitmap;
BEGIN
  ASSERT(aWnd # W.NULL);
  ASSERT((aNoOfPlayers >= 1) & (aNoOfPlayers <= MAXPLAYERS));
  ASSERT(aInvisibleShape # NIL);
  ASSERT(aMinBet > 0);
  ASSERT(aMinBet < aMaxBet);
  
  G.InitDrawable(t, 0, 0);
  t.wnd  := aWnd;

  t.stack := C.cardList;  
  t.stack.Shuffle();
  
  t.minBet := aMinBet;
  t.maxBet := aMaxBet;
  NEW(t.croupier); InitCroupier(t.croupier, 0, 0, t);
  t.noOfPlayers := aNoOfPlayers;
  FOR i := 0 TO aNoOfPlayers-1 DO
    NEW(t.playerList[i]); InitPlayer(t.playerList[i], 0, 0, i+1, t);
  END;
END InitTable;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR t : TTable) TakeCardList*(aList : C.PCardList);
BEGIN
  t.stack.Merge(aList^);
END TakeCardList;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR t : TTable) Reset*();
VAR i : SHORTINT;
BEGIN
  t.croupier.Reset();
  FOR i := 0 TO t.noOfPlayers-1 DO t.playerList[i].Reset() END;
END Reset;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR t : TTable) SetNoOfPlayers*(aNoOfPlayers : SHORTINT);
VAR i : SHORTINT;
    minNoOfPlayers : SHORTINT;
    playerNames : ARRAY MAXPLAYERS OF ARRAY G.MAXSTRLEN+1 OF CHAR;
BEGIN
  FOR i := 0 TO t.noOfPlayers-1 DO
    G.StringCopy(playerNames[i], t.playerList[i].name);
  END;
  FOR i := 0 TO t.noOfPlayers-1 DO
    t.playerList[i].Destroy(); DISPOSE(t.playerList[i]);
  END;
  IF (t.noOfPlayers < aNoOfPlayers) THEN 
    minNoOfPlayers := t.noOfPlayers;
  ELSE 
    minNoOfPlayers := aNoOfPlayers;
  END;
  t.noOfPlayers := aNoOfPlayers;
  FOR i := 0 TO aNoOfPlayers-1 DO
    NEW(t.playerList[i]); 
    InitPlayer(t.playerList[i], 0, 0, i+1, SYSTEM.VAL(PTable, SYSTEM.ADR(t)));
  END;
  FOR i := 0 TO minNoOfPlayers-1 DO
    G.StringCopy(t.playerList[i].name, playerNames[i]);
  END;
END SetNoOfPlayers;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR t : TTable) Destroy*();
VAR i : SHORTINT;
    card : C.PCard;
    shape : G.PBitmap;
BEGIN
  FOR i := 0 TO t.noOfPlayers-1 DO
    t.playerList[i].Destroy(); DISPOSE(t.playerList[i]);
  END;
  t.croupier.Destroy(); DISPOSE(t.croupier);
  
  t.Destroy^();
END Destroy;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

END Players.
