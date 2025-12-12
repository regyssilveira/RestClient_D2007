unit Service.DTO.Base;

interface

uses
  SysUtils, Classes, TypInfo, SuperObject;

type
  TJsonDTO = class(TPersistent)
  public
    procedure FromJson(AJson: ISuperObject); virtual;
  end;

implementation

{ TJsonDTO }

procedure TJsonDTO.FromJson(AJson: ISuperObject);
var
  LPropCount, I: Integer;
  LPropList: PPropList;
  LPropInfo: PPropInfo;
  LPropName: string;
  LJsonVal: ISuperObject;
begin
  if AJson = nil then Exit;

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
        
        // Simple case-insensitive matching
        LJsonVal := AJson.O[LPropName]; 
        if LJsonVal = nil then
          LJsonVal := AJson.O[LowerCase(LPropName)];

        if LJsonVal = nil then Continue;

        case LPropInfo^.PropType^.Kind of
          tkInteger, tkInt64:
            SetOrdProp(Self, LPropInfo, LJsonVal.AsInteger);
          tkFloat:
            begin
              if LJsonVal.DataType = stString then
                SetFloatProp(Self, LPropInfo, StrToFloatDef(StringReplace(LJsonVal.AsString, '.', DecimalSeparator, [rfReplaceAll]), 0.0))
              else
                SetFloatProp(Self, LPropInfo, LJsonVal.AsDouble);
            end;
          tkString, tkLString, tkWString:
            SetStrProp(Self, LPropInfo, LJsonVal.AsString);
          tkEnumeration:
             if GetTypeData(LPropInfo^.PropType^)^.BaseType^ = TypeInfo(Boolean) then
               SetOrdProp(Self, LPropInfo, Integer(LJsonVal.AsBoolean));
        end;
      end;
    finally
      FreeMem(LPropList);
    end;
  end;
end;

end.
