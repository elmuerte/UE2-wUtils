///////////////////////////////////////////////////////////////////////////////
// filename:    wString.uc
// revision:    103
// authors:     various UnrealWiki members (http://wiki.beyondunreal.com)
//              http://wiki.beyondunreal.com/WUtils
///////////////////////////////////////////////////////////////////////////////

class wString extends Object;

// Shifts an element off a string
// example (delim = ' '): 'this is a string' -> 'is a string'
// if quotechar = " : '"this is" a string' -> 'a string'
static final function string StrShift(out string line, string delim, optional string quotechar)
{
    local int delimpos, quotepos;
    local string result;
    
    if ( quotechar != "" && Left(line, Len(quotechar)) == quotechar ) {
        do {
            quotepos = InstrFrom(line, quotechar, quotepos + 1);
        } until (quotepos == -1 || quotepos + Len(quotechar) == Len(line)
                || Mid(line, quotepos + len(quotechar), len(delim)) == delim);
    }
    if ( quotepos != -1 ) {
        delimpos = InstrFrom(line, delim, quotepos);
    }
    else {
        delimpos = Instr(line, delim);
    }
    
    if (delimpos == -1)
    {
        result = line;
        line = "";
    }
    else {
        result = Left(line,delimpos);
        line = Mid(line,delimpos+len(delim));
    }
    if ( quotechar != "" && Left(result, Len(quotechar)) == quotechar ) {
      result = Mid(result, Len(quotechar), Len(result)-(Len(quotechar)*2));
    }
    return result;
}

// StrReplace using an array with replacements
// will return the changed string, will replace all occurences unless bOnlyFirst
static final function string StrReplace(coerce string target, array<string> replace, array<string> with, optional bool bOnlyFirst)
{
  local int i,j;
  local string Input;

  // cycle trough replacement list
  for (j = 0; j < replace.length; j++)
  {
    Input = target;
    target = "";
    i = InStr(input, Replace[j]);
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

// StrSubst will replace %s in target with r# where # is the place of %s in the string
static final function string StrSubst(coerce string target, optional string r0, optional string r1, optional string r2, optional string r3, 
  optional string r4, optional string r5, optional string r6, optional string r7, optional string r8, optional string r9)
{
  local array<string> replace, with;
  local int i;
  replace.length=10;
  for (i = 0; i < replace.length; i++) replace[i] = "%s";
  with.length=10;
  with[0]=r0;
  with[1]=r1;
  with[2]=r2;
  with[3]=r3;
  with[4]=r4;
  with[5]=r5;
  with[6]=r6;
  with[7]=r7;
  with[8]=r8;
  with[9]=r9;
  return StrReplace(target, replace, with, true);
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
  local string m, mp, cp;
  m = Left(mask, 1);
  while ((target != "") && (m != "*"))
  {
    if ((m != Left(target, 1)) && (m != "?")) return false;
    mask = Mid(Mask, 1);
    target = Mid(target, 1);
		m = Left(mask, 1);
  }

  while (target != "") 
  {
		if (m == "*") 
    {
      mask = Mid(Mask, 1);
			if (mask == "") return true; // only "*" mask -> always true
			mp = mask;
			cp = Mid(target, 1);
      m = Left(mask, 1);
		} 
    else if ((m == Left(target, 1)) || (m == "?")) 
    {
			mask = Mid(Mask, 1);
      target = Mid(target, 1);
  		m = Left(mask, 1);
		} 
    else 
    {
			mask = mp;
      m = Left(mask, 1);
			target = cp;
      cp = Mid(cp, 1);
		}
	}

  while (Left(mask, 1) == "*") 
  {
		mask = Mid(Mask, 1);
	}
	return (mask == "");
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

  return _match(mask, target);
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
static final function int Split2(coerce string src, string delim, out array<string> parts, optional bool ignoreEmpty, optional string quotechar)
{
  local string temp;
  Parts.Remove(0, Parts.Length);
  if (delim == "" || Src == "" ) return 0;
  while (src != "")
  {
    temp = StrShift(src, delim, quotechar);
    if (temp == "")
    {
      if (!ignoreEmpty)
      {
        parts.length = parts.length+1;
        parts[parts.length-1] = temp;
      }
    }
    else {
      parts.length = parts.length+1;
      parts[parts.length-1] = temp;
    }
  }
  return parts.length;
}

// Replaces part of a string with a new string
// ReplaceInString("A stupid string.", 2, 6, "good") == "A good string."
static final function string ReplaceInString(coerce string src, int from, int length, coerce string with)
{
  return Left(src, from)$with$Mid(src, from+length);
}

// Moves NUM lements from Source to Dest
static final function Eat(out string Dest, out string Source, int Num)
{
  Dest = Dest $ Left(Source, Num);
  Source = Mid(Source, Num);
}

// Converts a float to a string representation
static final function string FloatToString(float Value, optional int Precision)
{
  local int IntPart;
  local float FloatPart;
  local string IntString, FloatString;
  
  Precision = Max(Precision, 1);  // otherwise a simple int cast should be used
  
  if ( Value < 0 ) {
    IntString = "-";
    Value *= -1;
  }
  IntPart = int(Value);
  FloatPart = Value - IntPart;
  IntString = IntString $ string(IntPart);
  FloatString = string(int(FloatPart * 10 ** Precision));
  while (Len(FloatString) < Precision)
    FloatString = "0" $ FloatString;
  
  return IntString$"."$FloatString;
}

function static string AlignLeft(coerce string line, int length, optional string padchar)
{
  local int i;
  if (padchar == "") padchar = " ";
  i = length-Len(line);
  while (i > 0)
  {
    line = line$padchar;
    i--;
  }
  if (i < 0) line = Left(line, length);
  return line;
}

function static string AlignRight(coerce string line, int length, optional string padchar)
{
  local int i;
  if (padchar == "") padchar = " ";
  i = length-Len(line);
  while (i > 0)
  {
    line = padchar$line;
    i--;
  }
  if (i < 0) line = Right(line, length);
  return line;
}

function static string AlignCenter(coerce string line, int length, optional string padchar)
{
  local int i, j;
  if (padchar == "") padchar = " ";
  i = Len(line)/2;
  j = Len(line)-i;
  return AlignRight(Left(line, i), length-(length/2), padchar)$AlignLeft(Right(line, j), length/2, padchar);
}

defaultproperties
{
}
