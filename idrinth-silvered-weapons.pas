unit userscript;

var
	f: IInterface;
  allWeapons, allMelee: boolean;
  wood,silver,iron,steel,moonstone,dwarven,orichalcum,malachite,ebony,dragonbone,chaurus: string;
  spidWeapons: TStringList;
function Initialize: integer;
var
  buttonSelected: integer;
begin
  f := AddNewFileName('SilveredWeapons.esp');
  spidWeapons := TStringList.Create;
  buttonSelected := MessageDlg('YES: all melee weapons; NO: all bladed weapons; ALL: all weapons?',mtConfirmation, [mbYes,mbAll,mbNO], 0);
  allWeapons := False;
  allMelee := False;
  if buttonSelected = mrYes then
  begin
    allMelee := True;
    AddMessage('All melee weapons will be patched');
  end;
  if buttonSelected = mrAll then
  begin
    allWeapons := True;
    allMelee := True;
    AddMessage('All weapons will be patched');
  end;
  AddMasterIfMissing(f, 'Skyrim.esm', False);
  AddMasterIfMissing(f, 'Update.esm', False);
  AddMasterIfMissing(f, 'Dawnguard.esm', False);
  AddMasterIfMissing(f, 'HearthFires.esm', False);
  AddMasterIfMissing(f, 'Dragonborn.esm', False);
  silver := Name(RecordByFormID(FileByIndex(0), '5ACE3', False));
  iron := Name(RecordByFormID(FileByIndex(0), '5ACE4', False));
  steel := Name(RecordByFormID(FileByIndex(0), '5ACE5', False));
  moonstone := Name(RecordByFormID(FileByIndex(0), '5AD9F', False));
  dwarven := Name(RecordByFormID(FileByIndex(0), 'DB8A2', False));
  orichalcum := Name(RecordByFormID(FileByIndex(0), '5AD99', False));
  malachite := Name(RecordByFormID(FileByIndex(0), '5ADA1', False));
  ebony := Name(RecordByFormID(FileByIndex(0), '5AD9D', False));
  dragonbone := Name(RecordByFormID(FileByIndex(0), '3ADA4', False));
  chaurus := Name(RecordByFormID(FileByIndex(0), '3AD57', False));
  wood := Name(RecordByFormID(FileByIndex(0), '6F993', False));
end;
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
  k := ElementAssign(keywords, HighInteger, nil, False);
  SetEditValue(k, keywordId);
end;
procedure AddRecipes(e: IInterface; b: IInterface);
var
  c, conditions, materials, material, item, keywords: IInterface;
  bName,edid: string;
begin
  bName := Name(b);
  edid := GetElementEditValues(b, 'EDID');

  c := wbCopyElementToFile(RecordByFormID(FileByIndex(0), 'DA76A', False), f, True, True);
  SetElementEditValues(c, 'EDID', 'RecipeWeapon' + edid);
  materials := ElementByName(c, 'Items');
  material := ElementByIndex(materials, 0);
  item := ElementByIndex(materials, 1);
  SetElementEditValues(item, 'CNTO\Item', Name(e));
  SetElementEditValues(material, 'CNTO\Item', silver);
  SetElementEditValues(c, 'CNAM', bName);

  c := wbCopyElementToFile(RecordByFormID(FileByIndex(0), 'E4D', False), f, True, True);
  SetElementEditValues(c, 'EDID', 'TamperWeapon' + edid);
  SetElementEditValues(c, 'CNAM', bName);
  materials := ElementByName(c, 'Items');
  material := ElementByIndex(materials, 0);
  keywords := ElementBySignature(e, 'KWDA');
  SetElementEditValues(material, 'CNTO\Item', silver);
  if HasKeyword(keywords, 'WeapMaterialWood [KYWD:0001E717]') then
    SetElementEditValues(material, 'CNTO\Item', wood);
  if HasKeyword(keywords, 'WeapMaterialIron [KYWD:0001E718]') then
    SetElementEditValues(material, 'CNTO\Item', iron);
  if HasKeyword(keywords, 'WeapMaterialSteel [KYWD:0001E719]') then
    SetElementEditValues(material, 'CNTO\Item', steel);
  if HasKeyword(keywords, 'WeapMaterialDwarven [KYWD:0001E71A]') then
    SetElementEditValues(material, 'CNTO\Item', dwarven);
  if HasKeyword(keywords, 'WeapMaterialElven [KYWD:0001E71B]') then
    SetElementEditValues(material, 'CNTO\Item', moonstone);
  if HasKeyword(keywords, 'WeapMaterialOrcish [KYWD:0001E71C]') then
    SetElementEditValues(material, 'CNTO\Item', orichalcum);
  if HasKeyword(keywords, 'WeapMaterialGlass [KYWD:0001E71D]') then
    SetElementEditValues(material, 'CNTO\Item', malachite);
  if HasKeyword(keywords, 'WeapMaterialEbony [KYWD:0001E71E]') then
    SetElementEditValues(material, 'CNTO\Item', ebony);
  if HasKeyword(keywords, 'WeapMaterialDaedric [KYWD:0001E71F]') then
    SetElementEditValues(material, 'CNTO\Item', ebony);
  if HasKeyword(keywords, 'WeapMaterialImperial [KYWD:000C5C00]') then
    SetElementEditValues(material, 'CNTO\Item', steel);
  if HasKeyword(keywords, 'WeapMaterialDraugr [KYWD:000C5C01]') then
    SetElementEditValues(material, 'CNTO\Item', iron);
  if HasKeyword(keywords, 'WeapMaterialDraugrHoned [KYWD:000C5C02]') then
    SetElementEditValues(material, 'CNTO\Item', steel);
  if HasKeyword(keywords, 'WeapMaterialFalmer [KYWD:000C5C03]') then
    SetElementEditValues(material, 'CNTO\Item', chaurus);
  if HasKeyword(keywords, 'WeapMaterialFalmerHoned [KYWD:000C5C04]') then
    SetElementEditValues(material, 'CNTO\Item', chaurus);
  if HasKeyword(keywords, 'WeapMaterialSilver [KYWD:0010AA1A]') then
    SetElementEditValues(material, 'CNTO\Item', silver);
  if HasKeyword(keywords, 'DLC1WeapMaterialDragonbone [KYWD:02019822]') then
    SetElementEditValues(material, 'CNTO\Item', dragonbone);
  if HasKeyword(keywords, 'DLC2WeaponMaterialStalhrim [KYWD:0402622F]') then
    SetElementEditValues(material, 'CNTO\Item', steel);
  if HasKeyword(keywords, 'DLC2WeaponMaterialNordic [KYWD:04026230]') then
    SetElementEditValues(material, 'CNTO\Item', steel);
end;
procedure AddSPID(b: IInterface);
var
  keywords: IInterface;
  minLevel: integer;
begin
  keywords := ElementBySignature(b, 'KWDA');
  minLevel := 0;
  if HasKeyword(keywords, 'WeapMaterialWood [KYWD:0001E717]') then
    minLevel := 10;
  if HasKeyword(keywords, 'WeapMaterialIron [KYWD:0001E718]') then
    minLevel := 10;
  if HasKeyword(keywords, 'WeapMaterialSteel [KYWD:0001E719]') then
    minLevel := 10;
  if HasKeyword(keywords, 'WeapMaterialDwarven [KYWD:0001E71A]') then
    minLevel := 20;
  if HasKeyword(keywords, 'WeapMaterialElven [KYWD:0001E71B]') then
    minLevel := 25;
  if HasKeyword(keywords, 'WeapMaterialOrcish [KYWD:0001E71C]') then
    minLevel := 15;
  if HasKeyword(keywords, 'WeapMaterialGlass [KYWD:0001E71D]') then
    minLevel := 30;
  if HasKeyword(keywords, 'WeapMaterialEbony [KYWD:0001E71E]') then
    minLevel := 35;
  if HasKeyword(keywords, 'WeapMaterialDaedric [KYWD:0001E71F]') then
    minLevel := 40;
  if HasKeyword(keywords, 'WeapMaterialImperial [KYWD:000C5C00]') then
    minLevel := 10;
  if HasKeyword(keywords, 'WeapMaterialDraugr [KYWD:000C5C01]') then
    minLevel := 15;
  if HasKeyword(keywords, 'WeapMaterialDraugrHoned [KYWD:000C5C02]') then
    minLevel := 20;
  if HasKeyword(keywords, 'WeapMaterialFalmer [KYWD:000C5C03]') then
    minLevel := 15;
  if HasKeyword(keywords, 'WeapMaterialFalmerHoned [KYWD:000C5C04]') then
    minLevel := 20;
  if HasKeyword(keywords, 'DLC1WeapMaterialDragonbone [KYWD:02019822]') then
    minLevel := 35;
  if HasKeyword(keywords, 'DLC2WeaponMaterialStalhrim [KYWD:0402622F]') then
    minLevel := 25;
  if HasKeyword(keywords, 'DLC2WeaponMaterialNordic [KYWD:04026230]') then
    minLevel := 25;
  spidWeapons.Add('Item = 0x' + IntToHex(FormID(b) and $00fffff, 1) + ' - ' + GetFileName(GetFile(b)) + ' | IsGuardFaction | NONE | ' + IntToStr(minLevel) + '/150 | NONE | 1 | 1');
  spidWeapons.Add('Item = 0x' + IntToHex(FormID(b) and $00fffff, 1) + ' - ' + GetFileName(GetFile(b)) + ' | JobGuardCaptainFaction | NONE | ' + IntToStr(minLevel) + '/150 | NONE | 1 | 2');
  spidWeapons.Add('Item = 0x' + IntToHex(FormID(b) and $00fffff, 1) + ' - ' + GetFileName(GetFile(b)) + ' | VigilantOfStendarrFaction | NONE | ' + IntToStr(minLevel) + '/150 | NONE | 1 | 2');
  spidWeapons.Add('Item = 0x' + IntToHex(FormID(b) and $00fffff, 1) + ' - ' + GetFileName(GetFile(b)) + ' | DLC1DawnguardFaction | NONE | ' + IntToStr(minLevel) + '/150 | NONE | 1 | 2');
  spidWeapons.Add('Item = 0x' + IntToHex(FormID(b) and $00fffff, 1) + ' - ' + GetFileName(GetFile(b)) + ' | SilverHandFaction | NONE | ' + IntToStr(minLevel) + '/150 | NONE | 1 | 5');
end;
function Process(e: IInterface): integer;
var
  isMelee, isVendorable, isDefaultMelee, isWeapon: boolean;
  b, keywords, prop, script: IInterface;
  keyword: string;
  i: integer;
  flags: TStringDynArray;
begin
  if Signature(e) <> 'WEAP' then
    Exit;
  if not IsMaster(e) then
    Exit;
  e := WinningOverride(e);
  if not SameText('', GetElementEditValues(e, 'EITM')) then
    Exit;
  if not SameText('', GetElementEditValues(e, 'VMAD')) then
    Exit;
  if GetElementNativeValues(e, 'DNAM\Flags\0x80') <> 0 then
    Exit;//Unplayable flag
  if SameText(GetElementNativeValues(e, 'FULL'), '') then
    Exit;//dummy item most likely
  keywords := ElementBySignature(e, 'KWDA');
  if not Assigned(keywords) then
    Exit;
  if HasKeyword(keywords, 'WeapMaterialSilver [KYWD:0010AA1A]') then
    Exit;
  for i := 0 to Pred(ElementCount(keywords)) do
  begin
    keyword := GetEditValue(ElementByIndex(keywords, i));
    if not Assigned(keyword) then
      Continue;
    if SameText(keyword, 'WeapTypeSword [KYWD:0001E711]') then
      isDefaultMelee := True;
    if SameText(keyword, 'WeapTypeGreatsword [KYWD:0006D931]') then
      isDefaultMelee := True;
    if SameText(keyword, 'WeapTypeWarAxe [KYWD:0001E712]') then
      isDefaultMelee := True;
    if SameText(keyword, 'WeapTypeDagger [KYWD:0001E713]') then
      isDefaultMelee := True;
    if SameText(keyword, 'WeapTypeBattleaxe [KYWD:0006D932]') then
      isDefaultMelee := True;

    if SameText(keyword, 'WeapTypeMace [KYWD:0001E714]') then
      isMelee := True;
    if SameText(keyword, 'WeapTypeWarhammer [KYWD:0006D930]') then
      isMelee := True;

    if SameText(keyword, 'WeapTypeBow [KYWD:0001E715]') then
      isWeapon := True;

    if SameText(keyword, 'VendorItemClutter [KYWD:000914E9]') then
      Exit;
    if SameText(keyword, 'MagicDisallowEnchanting [KYWD:000C27BD]') then
      Exit;//skip uniques
    if SameText(keyword, 'VendorItemWeapon [KYWD:0008F958]') then
      isVendorable := True;
  end;
  if not isVendorable then
    Exit;
  if not isDefaultMelee and not allMelee then
    Exit;
  isMelee := isMelee or isDefaultMelee;
  if not isMelee and not allWeapons then
    Exit;
  isWeapon := isWeapon or isMelee;
  if not isWeapon then
    Exit;
  AddMasterIfMissing(f, GetFileName(GetFile(e)), False);
  for i := 0 to Pred(MasterCount(GetFile(e))) do
  begin
    if Length(GetFileName(MasterByIndex(GetFile(e), i))) > 0 then
      AddMasterIfMissing(f, GetFileName(MasterByIndex(GetFile(e), i)), False);
  end;
  b := wbCopyElementToFile(e, f, True, True);
  AddKeyword(ElementBySignature(b, 'KWDA'), '10AA1A');
  SetElementEditValues(b, 'KSIZ', ElementCount(ElementBySignature(b, 'KWDA')));
  SetElementEditValues(b, 'EDID', 'Silvered' + GetElementEditValues(e, 'EDID'));
  SetElementEditValues(b, 'FULL', 'Silvered ' + GetElementEditValues(e, 'FULL'));
  SetElementEditValues(b, 'DATA\Value', Round(25 + 1.2 * StrToFloat(GetElementEditValues(e, 'DATA\Value'))));
  SetElementEditValues(b, 'DATA\Weight', 0.5 + StrToFloat(GetElementEditValues(e, 'DATA\Weight')));
  AddRecipes(e, b);
  AddSPID(b);
end;

function Finalize(): integer;
begin
  AddMessage('Saving ' + DataPath + '/SilveredWeapons__DISTR.txt');
  spidWeapons.SaveToFile(DataPath + '/SilveredWeapons__DISTR.txt');
end;

end.