unit Service.DTO.Base;

interface

uses
  SysUtils, Classes, Contnrs, TypInfo, SuperObject;

type
  {$M+}
  TJsonDTO = class(TInterfacedObject)
  public
    function GetItemClass(const APropName: string): TClass; virtual;
    procedure FromJson(AJson: ISuperObject); virtual;
  protected
    function ParseISO8601Date(const ADateStr: string): TDateTime;
  end;
  {$M-}

implementation

{ TJsonDTO }

procedure TJsonDTO.FromJson(AJson: ISuperObject);
var
  LPropCount, I: Integer;
  LPropList: PPropList;
  LPropInfo: PPropInfo;
  LJsonVal: ISuperObject;
  LPropName, LJsonName: string;
  LObj: TObject;
  LList: TObjectList;
  LItemClass: TClass;
  LArray: ISuperArray;
  LItem: TJsonDTO;
  J: Integer;
begin
  if AJson = nil then
    Exit;

  LPropCount := GetPropList(Self.ClassInfo, tkProperties, nil);
  if LPropCount > 0 then
  begin
    GetMem(LPropList, LPropCount * SizeOf(PPropInfo));
    try
      GetPropList(Self.ClassInfo, tkProperties, LPropList);
      for I := 0 to LPropCount - 1 do
      begin
        LPropInfo := LPropList^[I];
        LPropName := string(LPropInfo^.Name);

        // Try exact match first
        LJsonVal := AJson.O[LPropName];
        
        // If not found, try camelCase (common convention: AccountNumber -> accountNumber)
        if LJsonVal = nil then
        begin
          if Length(LPropName) > 0 then
          begin
            LJsonName := LowerCase(Copy(LPropName, 1, 1)) + Copy(LPropName, 2, Length(LPropName));
            LJsonVal := AJson.O[LJsonName];
          end;
        end;

        if LJsonVal = nil then Continue;

        case LPropInfo^.PropType^.Kind of
          tkInteger, tkInt64:
            begin
              SetOrdProp(Self, LPropInfo, LJsonVal.AsInteger);
            end;

          tkFloat:
            begin
              if LJsonVal.DataType = stString then
              begin
                if (Length(LJsonVal.AsString) >= 10) and (LJsonVal.AsString[5] = '-') then
                  SetFloatProp(Self, LPropInfo, ParseISO8601Date(LJsonVal.AsString))
                else
                  SetFloatProp(Self, LPropInfo, StrToFloatDef(StringReplace(LJsonVal.AsString, '.', DecimalSeparator, [rfReplaceAll]), 0.0));
              end
              else
                SetFloatProp(Self, LPropInfo, LJsonVal.AsDouble);
            end;

          tkString, tkLString, tkWString:
            begin
              SetStrProp(Self, LPropInfo, LJsonVal.AsString);
            end;

          tkEnumeration:
            begin
              if GetTypeData(LPropInfo^.PropType^)^.BaseType^ = TypeInfo(Boolean) then
                SetOrdProp(Self, LPropInfo, Integer(LJsonVal.AsBoolean));
            end;

          tkClass:
            begin
              LObj := GetObjectProp(Self, LPropInfo);
              if LObj <> nil then
              begin
                if (LObj is TObjectList) and (LJsonVal.DataType = stArray) then
                begin
                  LList := TObjectList(LObj);
                  LList.Clear;
                  LItemClass := GetItemClass(LPropName);
                  // DEBUG
                  // WriteLn('Property: ', LPropName, ', ItemClass: ', Pointer(LItemClass)); 
                  if (LItemClass <> nil) and LItemClass.InheritsFrom(TJsonDTO) then
                  begin
                    LArray := LJsonVal.AsArray;
                    for J := 0 to LArray.Length - 1 do
                    begin
                      LItem := TJsonDTO(LItemClass.Create);
                      LItem.FromJson(LArray.O[J]);
                      LList.Add(LItem);
                    end;
                  end;
                end
                else if LObj.InheritsFrom(TJsonDTO) then
                begin
                   TJsonDTO(LObj).FromJson(LJsonVal);
                end;
              end;
            end;
        end;
      end;
    finally
      FreeMem(LPropList);
    end;
  end;
end;

function TJsonDTO.GetItemClass(const APropName: string): TClass;
begin
  Result := nil;
end;

function TJsonDTO.ParseISO8601Date(const ADateStr: string): TDateTime;
var
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin
  Result := 0;
  try
    if Length(ADateStr) >= 10 then
    begin
      Year := StrToInt(Copy(ADateStr, 1, 4));
      Month := StrToInt(Copy(ADateStr, 6, 2));
      Day := StrToInt(Copy(ADateStr, 9, 2));
      Result := EncodeDate(Year, Month, Day);

      if (Length(ADateStr) >= 19) and (UpCase(ADateStr[11]) = 'T') then
      begin
        Hour := StrToInt(Copy(ADateStr, 12, 2));
        Min := StrToInt(Copy(ADateStr, 15, 2));
        Sec := StrToInt(Copy(ADateStr, 18, 2));
        MSec := 0;
        if (Length(ADateStr) > 20) and (ADateStr[20] = '.') then
             MSec := StrToIntDef(Copy(ADateStr, 21, 3), 0);
        Result := Result + EncodeTime(Hour, Min, Sec, MSec);
      end;
    end;
  except
    Result := 0;
  end;
end;

end.
