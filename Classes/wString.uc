///////////////////////////////////////////////////////////////////////////////
// filename:    wString.uc
// revision:    101
// authors:     various UnrealWiki members (http://wiki.beyondunreal.com)
//              http://wiki.beyondunreal.com/El_Muerte_TDS/WUtils
///////////////////////////////////////////////////////////////////////////////

class wString extends Object;

// Shifts an element off a string
// example (delim = ' '): 'this is a string' -> 'is a string'
static final function string StrShift(out string line, string delim)
{
  local int pos;
  local string result;

  pos = Instr(line, delim);
  if (pos == -1)
  {
    result = line;
    line = "";
  }
  else {
    result = Left(line,pos);
    line = Mid(line,pos+len(delim));
  }
  return result;
}

// StrReplace using an array with replacements
// will return the changed string, will replace all occurences
static final function string StrReplace(coerce string target, array<string> replace, array<string> with, optional bool bOnlyFirst)
{
  local int i,j;
	local string Input;

  Input = target;
  target = "";
  // cycle trough replacement list
  for (j = 0; j < replace.length; j++)
  {
  	i = InStr(Input, Replace[j]);
	  while(i != -1)
  	{	
	  	target = target $ Left(Input, i) $ With[j];
		  Input = Mid(Input, i + Len(Replace[j]));	
      if (bOnlyFirst) break; // only replace first occurance
  		i = InStr(Input, Replace[j]);
	  }
  	target = target $ Input;
  }
  return target;
}

// Turn a string to lower case
// example: 'This Is A String' -> 'this is a string'
static final function string Lower(coerce string Text) 
{
  local int IndexChar;
  for (IndexChar = 0; IndexChar < Len(Text); IndexChar++)
    if (Mid(Text, IndexChar, 1) >= "A" &&
        Mid(Text, IndexChar, 1) <= "Z")
      Text = Left(Text, IndexChar) $ Chr(Asc(Mid(Text, IndexChar, 1)) + 32) $ Mid(Text, IndexChar + 1);
  return Text;
}

// Checks if a string is all uppercase
static final function bool IsUpper(coerce string S)
{
    return S == Caps(S);
}

// Checks if a string is all lowercase
static final function bool IsLower(coerce string S)
{
    return S == Lower(S);
}

// Trim leading spaces
static final function string LTrim(coerce string S)
{
    while (Left(S, 1) == " ")
        S = Right(S, Len(S) - 1);
    return S;
}

// Trim trailing spaces
static final function string RTrim(coerce string S)
{
    while (Right(S, 1) == " ")
        S = Left(S, Len(S) - 1);
    return S;
}

// Trim leading and trailing spaces
static final function string Trim(coerce string S)
{
    return LTrim(RTrim(S));
}

// Internal function used for MaskedCompare
static private final function bool _match(out string mask, out string target)
{
  local string m;
  if (mask == "") return true; 
  m = Left(mask,1);
  if (m == "*") 
  { 
    mask = Mid(mask, 1);
    return _matchstar(m, mask, target);
  }
  if (Len(target) > 0 && (m == "?" || m == Left(target,1)) ) 
  {
    mask = Mid(mask, 1);
    target = Mid(target, 1);
    return _match(mask, target);
  }
  return false;
}

// Internal function used for MaskedCompare
// this will process a *
static private final function bool _matchstar(string m, out string mask, out string target)
{
  local int i, j;
  local string t;

  if (mask == "") return true;

  for (i = 0; (i < Len(target)) && (m == "?" || m == Mid(target, i, 1)); i++)
  {
    j = i;
    do {
      t = Left(target, j);
      if (_match(mask, t)) return true;
    } until (j-- <= 0)
  }
  return false;
}

// Compare a string with a mask
// Wildcards: * = X chars; ? = 1 char
// Wildcards can appear anywhere in the mask
static final function bool MaskedCompare(coerce string target, string mask, optional bool casesensitive)
{
  if (!casesensitive)
  {
    mask = Caps(mask);
    target = Caps(target);
  }
  if (mask == "*") return true;

  do {
    if ( _match(mask, target)) return true;
    target = Mid(target, 1);
  } until (Len(target) <= 0);
  return false;
}

// InStr starting from an offset
static final function int InStrFrom(coerce string StrText, coerce string StrPart, optional int OffsetStart)
{
  local int OffsetPart;

  OffsetPart = InStr(Mid(StrText, OffsetStart), StrPart);
  if (OffsetPart >= 0)
    OffsetPart += OffsetStart;
  return OffsetPart;
}

// Replace key=value sets: ?key=valye?otherkey=othervalue?...
// Options: the string containing these key=value sets
// Key: the key to replace/add
// NewValue: the new value of the Key
// bAddIfMissing: add the key=value pair if it doesn't exist
// OldValue: this will contain the previous value
// delim: the delimiter of the key=value pairs, by default: ?
static final function bool ReplaceOption( out string Options, string Key, string NewValue, optional bool bAddIfMissing, optional out string OldValue, optional string delim)
{
  local array<string> OptionsArray;
  local int i;
  local string CurrentKey, CurrentValue;
  local bool bReplaced;
  bReplaced = false;

  if (delim == "") delim = "?"; // default delim is ?
  Split2( Options, delim, OptionsArray );
  // find the key
  for ( i = 0; i < OptionsArray.Length; i++ ) {
    Divide( OptionsArray[i], "=", CurrentKey, CurrentValue );

    if ( CurrentKey ~= Key ) {
      OldValue = CurrentValue;
      OptionsArray[i] = CurrentKey$"="$NewValue;
      bReplaced = true;
    }
  }
  // add if missing
  if ( !bReplaced && bAddIfMissing ) OptionsArray[OptionsArray.Length] = Key$"="$NewValue;
  // join the strings
  Options = class'wArray'.static.Join(OptionsArray, delim);
  return bReplaced;
}

// Capitalize a string
// example: 'this is a STRING' -> 'This Is A String'
static final function string Capitalize(coerce string S)
{
  local array<string> parts;
  local int i;
  Split2(s, " ", parts);
  for (i = 0; i < parts.length; i++)
  {
    parts[i] = Caps(Left(parts[i], 1))$Lower(Mid(parts[i], 1));
  }
  return class'wArray'.static.join(parts, " ");
}

// Fixed split method
// no problems when it starts with a delim
// no problems with ending spaces
// delim can be a string
static final function int Split2(coerce string src, string delim, out array<string> parts)
{
  Parts.Remove(0, Parts.Length);
  if (delim == "" || Src == "" ) return 0;
  while (src != "")
  {
    parts.length = parts.length+1;
    parts[parts.length-1] = StrShift(src, delim);
  }
  return parts.length;
}