///////////////////////////////////////////////////////////////////////////////
// filename:    wMath.uc
// revision:    101
// authors:     various UnrealWiki members (http://wiki.beyondunreal.com)
//              http://wiki.beyondunreal.com/El_Muerte_TDS/WUtils
///////////////////////////////////////////////////////////////////////////////

class wMath extends Object;

// Checks if a string is numeric
static final function bool IsNumeric(coerce string Param, optional bool bPositiveOnly, optional bool bNoFloat)
{
  local int p;

  p=0;
  while (Mid(Param, p, 1) == " ") p++;
  if (!bPositiveOnly) if (Mid(Param, p, 1) == "-") p++;
  while (Mid(Param, p, 1) >= "0" && Mid(Param, p, 1) <= "9" || (!bNoFloat && Mid(Param, p, 1) == ".")) p++;
  while (Mid(Param, p, 1) == " ") p++;
  if (Mid(Param, p) != "") return false;
  return true;
}

// Check if a string is an int
static final function bool IsInt(coerce string Param, optional bool bPositiveOnly)
{
  return IsNumeric(param, bPositiveOnly, true);
}

// Check if a string is an float (example: '3.14' -> true '3' -> true);
static final function bool IsFloat(coerce string Param, optional bool bPositiveOnly)
{
  return IsNumeric(param, bPositiveOnly, false);
}

/* Michaeel's CRC32 code
   http//wiki.beyondunreal.com/wiki/CRC32 */

// This function needs to be called the first time you want to use CRC32
static final function CRC32Init(out int CrcTable[256]) 
{
  const CrcPolynomial = 0xedb88320;

  local int CrcValue;
  local int IndexBit;
  local int IndexEntry;
  
  for (IndexEntry = 0; IndexEntry < 256; IndexEntry++) 
  {
    CrcValue = IndexEntry;

    for (IndexBit = 8; IndexBit > 0; IndexBit--)
      if ((CrcValue & 1) != 0)
        CrcValue = (CrcValue >>> 1) ^ CrcPolynomial;
      else
        CrcValue = CrcValue >>> 1;
    
    CrcTable[IndexEntry] = CrcValue;
  }
}

// Calculate the CRC32 checksum of Text
static final function int CRC32(coerce string Text, int CrcTable[256]) 
{
  local int CrcValue;
  local int IndexChar;
  
  CrcValue = 0xffffffff;
  
  for (IndexChar = 0; IndexChar < Len(Text); IndexChar++)
    CrcValue = (CrcValue >>> 8) ^ CrcTable[Asc(Mid(Text, IndexChar, 1)) ^ (CrcValue & 0xff)];

  return CrcValue;
}