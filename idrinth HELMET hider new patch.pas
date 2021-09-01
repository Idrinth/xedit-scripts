unit UserScript;

var
  f: IInterface;
//============================================================================
procedure RegisterKeyword(edid: string;form_id: string);
var
  group, Result: IInterface;
begin
  group := GroupBySignature(f, 'KYWD');
  if not Assigned(group) then
    group := Add(f, 'KYWD', True);
  Result := Add(group, 'KYWD', true);
  Add(Result, 'EDID', True);
  SetElementEditValues(Result, 'EDID', edid);
  SetLoadOrderFormID(Result, form_id);
end;
procedure RegisterKeywords();
begin
  RegisterKeyword('FrostfallEnableKeywordProtection', '01CC0E28');
  RegisterKeyword('FrostfallIsWarmAccessory', '01CC0E20');
  RegisterKeyword('FrostfallIsWeatherproofAccessory', '01CC0E1F');
  RegisterKeyword('FrostfallWarmthFair', '01CC0E11');
  RegisterKeyword('FrostfallWarmthGood', '01CC0E12');
  RegisterKeyword('FrostfallWarmthExcellent', '01CC0E13');
  RegisterKeyword('FrostfallWarmthMax', '01CC0E14');
  RegisterKeyword('FrostfallCoverageFair', '01CC0E17');
  RegisterKeyword('FrostfallCoverageGood', '01CC0E18'); 
  RegisterKeyword('FrostfallCoverageExcellent', '01CC0E19');
  RegisterKeyword('FrostfallCoverageMax', '01CC0E1A');
end;
function Initialize: integer;
begin
  f := AddNewFile;
  if not Assigned(f) then
  begin
    Result := 1;
    Exit;
  end;
  AddMasterIfMissing(f, 'Update.esm', False);
  RegisterKeywords();
end;
//============================================================================
function HasKeyword(keywords: IInterface; keywordId: string): boolean;
var
  i: integer;
  keyword: string;
begin
  Result := False;
  for i := 0 to Pred(ElementCount(keywords)) do
  begin
    keyword := GetEditValue(ElementByIndex(keywords, i));
    if SameText(keyword, keywordId) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;
procedure AddKeyword(keywords: IInterface; keywordId: string);
var
  k: IInterface;
  i: integer;
begin
  if HasKeyword(keywords, keywordId) then
    Exit;
  k := ElementAssign(keywords, HighInteger, nil, False);
  SetEditValue(k, keywordId);
end;
procedure AddHeadPiece(e: IInterface);
var
  i: integer;
  b, keywords: IInterface;
  isMedium: boolean;
  keyword: string;
begin
  AddMessage(GetElementEditValues(e, 'FULL') + ' is new head gear');
  AddRequiredElementMasters(e, f, False);
  b := wbCopyElementToFile(e, f, False, True);
  RemoveElement(b, 'Armature');
  SetElementNativeValues(b, 'BOD2\First Person Flags', $40000000);//Slot 60
  keywords := ElementBySignature(b, 'KWDA');
  if not HasKeyword(keywords, '01CC0E28') then //prevent duplicate frostfall keywords
  begin
    isMedium := True;
    for i := 0 to Pred(ElementCount(keywords)) do
    begin
      keyword := GetEditValue(ElementByIndex(keywords, i));
      if SameText(keyword, 'ArmorHelmet [KYWD:0006C0EE]') then
      begin
        AddKeyword(keywords, '01CC0E1F');//coverage
        AddKeyword(keywords, '01CC0E28');//protection
      end;
      if SameText(keyword, 'ClothingHead [KYWD:0010CD11]') then
      begin
        AddKeyword(keywords, '01CC0E20');//warmth
        AddKeyword(keywords, '01CC0E28');//protection
        AddKeyword(keywords, '01CC0E17');//coverage: fair
        AddKeyword(keywords, '01CC0E14');//warmth: max
        isMedium := False;
      end;
      if SameText(keyword, 'ArmorHeavy [KYWD:0006BBD2]') then
      begin
        AddKeyword(keywords, '01CC0E1A');//coverage: max
        AddKeyword(keywords, '01CC0E11');//warmth: fair
        AddKeyword(keywords, '01CC0E28');//protection
        isMedium := False;
      end;
      if SameText(keyword, 'ArmorLight [KYWD:0006BBD3]') then
      begin
        AddKeyword(keywords, '01CC0E18');//coverage: good
        AddKeyword(keywords, '01CC0E13');//warmth: excellent
        AddKeyword(keywords, '01CC0E28');//protection
        isMedium := False;
      end;
    end;
    if isMedium then
    begin
      AddKeyword(keywords, '01CC0E19');//coverage: excellent
      AddKeyword(keywords, '01CC0E12');//warmth: good
    end;
    if not ElementExists(b, 'KSIZ') then
      Add(b, 'KSIZ', True);
    SetElementNativeValues(b, 'KSIZ', ElementCount(keywords));
  end;
  AddMessage(GetElementEditValues(e, 'FULL') + ' was added');
end;
function Process(e: IInterface): integer;
var
  i: integer;
  b, keywords: IInterface;
  keyword: string;
begin
  if Signature(e) <> 'ARMO' then
    Exit;
  if not IsMaster(e) then
    Exit;
  e := WinningOverride(e);
  keywords := ElementBySignature(e, 'KWDA');
  if not Assigned(keywords) then
    Exit;
  for i := 0 to Pred(ElementCount(keywords)) do
  begin
    keyword := GetEditValue(ElementByIndex(keywords, i));
    if not Assigned(keyword) then
      Continue;
    if SameText(keyword, 'ArmorHelmet [KYWD:0006C0EE]') then
      AddHeadPiece(e);
    if SameText(keyword, 'ClothingHead [KYWD:0010CD11]') then
      AddHeadPiece(e);
  end;
end;
//============================================================================
function Finalize: integer;
begin
  SortMasters(f);
end;

end.
