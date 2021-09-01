unit UserScript;

var
  f: IInterface;
  npcs: array[0..10000] of IInterface;
  races: TStringList;
  npc: integer;
  lastFile: string;
  hasRequiredMaster: boolean;
function GetDisplayName(e: IInterface): string;
begin
  Result := GetElementEditValues(e, 'FULL');
  if SameText('', Result) then
    Result := GetEditValue(e);
 end;
//============================================================================
function RegisterKeyword(edid: string; form_id: string): IInterface;
var
  group: IInterface;
begin
  group := GroupBySignature(f, 'KYWD');
  if not Assigned(group) then
    group := Add(f, 'KYWD', True);
  Result := Add(group, 'KYWD', true);
  Add(Result, 'EDID', True);
  SetElementEditValues(Result, 'EDID', edid);
  SetLoadOrderFormID(Result, form_id);
end;
function Initialize: integer;
begin
  f := AddNewFile;
  if not Assigned(f) then
  begin
    Result := 1;
    Exit;
  end;
  races := TStringList.Create();
  npc := 0;
  lastFile := '';
  hasRequiredMaster := False;

  AddMasterIfMissing(f, 'Update.esm', False);
  AddMasterIfMissing(f, 'WeightAndHeight.esl', False);

  RegisterKeyword('idrinthKeywordSizeTiny', '01F01DA9');
  RegisterKeyword('idrinthKeywordSizeSmall', '01F01DAA');
  RegisterKeyword('idrinthKeywordSizeTall', '01F01DAD');
  RegisterKeyword('idrinthKeywordSizeLarge', '01F01DAC');
  RegisterKeyword('idrinthKeywordSizeMedium', '01F01DAB');

  RegisterKeyword('idrinthKeywordWeightHeavy', '01F01DA8');
  RegisterKeyword('idrinthKeywordWeightMedium', '01F01DA6');
  RegisterKeyword('idrinthKeywordWeightMediumLight', '01F01DA5');
  RegisterKeyword('idrinthKeywordWeightMediumHeavy', '01F01DA7');
  RegisterKeyword('idrinthKeywordWeightLight', '01F01DA4');
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
procedure ProcessNPC(e: IInterface);
var
  i: integer;
  edit: string;
begin
  if Signature(e) <> 'NPC_' then
    Exit;
  if not IsMaster(e) then
    Exit;
  e := WinningOverride(e);
  npcs[npc] := e;
  npc := npc + 1;
end;
function IsValidKeyword(e: IInterface): boolean;
var
  keywords: IInterface;
  race: string;
begin
  Result := True;
  keywords := ElementBySignature(e, 'KWDA');
  if HasKeyword(keywords, 'ActorTypeNPC [KYWD:00013794]') then
    Exit;
  Result := False;
end;
procedure ProcessRace(e: IInterface);
var
  i: integer;
  form_id: string;
begin
  if Signature(e) <> 'RACE' then
    Exit;
  if not IsMaster(e) then
    Exit;
  e := WinningOverride(e);
  if not IsValidKeyword(e) then
    Exit;
  AddMessage('  Found new npc-race: ' + GetDisplayName(e));
  races.Add(GetElementEditValues(e, 'Record Header\FormID'));
end;
procedure AddKeyword(keywords: IInterface; keywordId: string);
var
  k: IInterface;
begin
  k := ElementAssign(keywords, HighInteger, nil, False);
  SetEditValue(k, keywordId);
end;
procedure SetHeightKeywords(keywords: IInterface; height: float);
begin
  if (height < 0.98) then
  begin
    AddKeyword(keywords, '01F01DA9');//tiny
    Exit;
  end;
  if (height < 1) then
  begin
    AddKeyword(keywords, '01F01DAA');//small
    Exit;
  end;
  if (height > 1.02) then
  begin
    AddKeyword(keywords, '01F01DAD');//tall
    Exit;
  end;
  if (height > 1) then
  begin
    AddKeyword(keywords, '01F01DAC');//large
    Exit;
  end;
  AddKeyword(keywords, '01F01DAB');//medium
  Exit;
end;
procedure SetWeightKeywords(keywords: IInterface; weight: float);
begin
  if (weight < 20) then
  begin
    AddKeyword(keywords, '01F01DA4');//light
    Exit;
  end;
  if (weight < 40) then
  begin
    AddKeyword(keywords, '01F01DA5');//medium light
    Exit;
  end;
  if (weight < 60) then
  begin
    AddKeyword(keywords, '01F01DA6');//medium
    Exit;
  end;
  if (weight < 80) then
  begin
    AddKeyword(keywords, '01F01DA7');//medium heavy
    Exit;
  end;
  AddKeyword(keywords, '01F01DA8');//heavy
  Exit;
end;
procedure SetKeywords(keywords: IInterface; weight: float; height: float);
begin
  SetWeightKeywords(keywords, weight);
  SetHeightKeywords(keywords, height);
end;
function IsValidNPC(e: IInterface): boolean;
var
  keywords: IInterface;
  raceId: string;
  i: integer;
begin
  Result := True;
  if IsValidKeyword(e) then
  begin
    AddMessage('  Added '+GetDisplayName(e)+' due to keyword');
    Exit;
  end;
  if races.IndexOf(GetElementEditValues(e, 'RNAM')) <> -1 then
  begin
    AddMessage('  Added '+GetDisplayName(e)+' due to race');
    Exit;
  end;
  Result := False;
end;
procedure AddLocalNPCs();
var
  i, previous: integer;
  weight, height: string;
  e, b, keywords: IInterface;
begin
  if npc = 0 then
    Exit;
  for i := 0 to npc - 1 do
  begin
    e := npcs[i];
    if not Assigned(e) then
      Continue;
    if not IsValidNPC(e) then
      Continue;
    weight := GetElementEditValues(e, 'NAM7');
    if SameText(weight, '') then
      Continue;
    height := GetElementEditValues(e, 'NAM6');
    if SameText(height, '') then
      height := '1.0';
    AddRequiredElementMasters(e, f, False);
    b := wbCopyElementToFile(e, f, False, True);
    if not ElementExists(b, 'KWDA') then
      Add(b, 'KWDA', True);
    keywords := ElementBySignature(b, 'KWDA');
    SetKeywords(keywords, StrToFloat(weight), StrToFloat(height));
    if not ElementExists(b, 'KSIZ') then
      Add(b, 'KSIZ', True);
    SetElementNativeValues(b, 'KSIZ', ElementCount(keywords));
  end;
  npc := 0;
end;
function Process(e: IInterface): integer;
var
    currentFile: string;
begin
  currentFile := GetFileName(GetFile(e));
  if not SameText(lastFile, currentFile) then
  begin
    AddLocalNPCs();
    lastFile := currentFile;
    if SameText(lastFile, 'WeightAndHeight.esl') then
      hasRequiredMaster := True;
    AddMessage(lastFile);
  end;
  ProcessRace(e);
  ProcessNPC(e);
end;
//============================================================================
function Finalize: integer;
begin
  if not hasRequiredMaster then
    AddMessage('Missing required WeightAndHeight.esl');
  SortMasters(f);
end;

end.
