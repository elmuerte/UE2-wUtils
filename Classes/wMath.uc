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

// Calculate: C^D mod N
static final function int PowerMod(int C, int D, int N)
{
  local int f, g, j;
  if ( D % 2 == 0) 
  {
    G = 1;
    for (j = 1; j <= D/2; j++) 
    {
      F = (C*C) % N;
      G = (F*G) % N;
    }  
  } 
  else {
    G = C;
    for (j = 1; j <= D/2; j++) 
    {
      F = (C*C) % N;
      G = (F*G) % N;
    }
  }
  return g;
}

/* RSA Encode\Decode methods
   Written by El Muerte
   http//wiki.beyondunreal.com/wiki/RSA */

// Calculate Greatest Common Divider
static final private function int _RSAGCD(int e, int PHI)
{
  local int great, a;
  if (e > PHI) 
  {
    while (e%PHI != 0) 
    {
      a = e%PHI;
      e = PHI;
      PHI = a;
    }
    great = PHI;
  }
  else {
    while (PHI%e != 0) 
    {
      a = PHI%e;
      PHI = e;
      e = a;
    }
    great = e;
  }
  return great;
}

// Used to calculate the public key E
// P and Q are primes, P!=Q
// You need N=P*Q and E to encrYpt the message
static final function int RSAPublicKeygen(int p, int q)
{
  local int PHI, E, great;
  PHI = (p-1)*(q-1);
  great = 0;
  E = 2;
  while (great != 1)
  {
    E = E+1;
    great = _RSAGCD(E, PHI);
  }
  return E;
}

// PrivateKey is inverse of the Public key E
// You need this key (and N) to decrypt the message
static final function int RSAPrivateKeygen(int E, int p, int q)
{
  local int PHI, u1, u2, u3, v1, v2, v3, t1, t2, t3, z;
  PHI = (p-1)*(q-1);
  u1 = 1;
  u2 = 0;
  u3 = PHI;
  v1 = 0;
  v2 = 1;
  v3 = E;
  while (v3 != 0) 
  {
     z = u3/v3;
     t1 = u1-z*v1;
     t2 = u2-z*v2;
     t3 = u3-z*v3;
     u1 = v1;
     u2 = v2;
     u3 = v3;
     v1 = t1;
     v2 = t2;
     v3 = t3;
  }
  if (u2 < 0) 
  {
    return u2 + PHI;
  } 
  else {
    return u2;
  }
}

static final function RSAEncode(coerce string data, int E, int N, out array<int> data2)
{
  local int i, c;
  data2.length = len(data);
  for (i = 0; i < len(data); i++)
  {
    c = Asc(Mid(data,i,1));
    data2[i] = PowerMod(c,E,N);
  }
}

static final function string RSADecode(array<int> data, int D, int N)
{
  local int i, j, G, F, C;
  local string result;
  for (i = 0; i < data.length; i++)
  {
    c = data[i];
    result = result$chr(PowerMod(c,D,N));
  }
  return result;
}
