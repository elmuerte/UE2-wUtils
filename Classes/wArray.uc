///////////////////////////////////////////////////////////////////////////////
// filename:    wArray.uc
// revision:    102
// authors:     various UnrealWiki members (http://wiki.beyondunreal.com)
//              http://wiki.beyondunreal.com/El_Muerte_TDS/WUtils
///////////////////////////////////////////////////////////////////////////////

class wArray extends Object;

// Add the elements of A and B to the result (string arrays)
static final function array<string> AddS(array<string> A, array<string> B)
{
  local int i;
  for (i = 0; i < B.length; i++)
  {
    A.length = A.length+1;
    A[A.length-1] = B[i];
  }
  return A;
}

// Add the elements of A and B to the result (int arrays)
static final function array<int> AddI(array<int> A, array<int> B)
{
  local int i;
  for (i = 0; i < B.length; i++)
  {
    A.length = A.length+1;
    A[A.length-1] = B[i];
  }
  return A;
}

// Add the elements of A and B to the result (object arrays)
static final function array<object> AddO(array<object> A, array<object> B)
{
  local int i;
  for (i = 0; i < B.length; i++)
  {
    A.length = A.length+1;
    A[A.length-1] = B[i];
  }
  return A;
}

// Calculate the diffirence between A and B
static final function array<string> RemoveS(array<string> A, array<string> B)
{
  local int i;
  while (B.length > 0)
  {
    for (i = 0; i < A.length; i++)
    {
      if (A[i] == B[0])
      {
        A.remove(i, 1);
        break;
      }
    }
    B.remove(0, 1);
  }
  return A;
}

// Calculate the diffirence between A and B
static final function array<int> RemoveI(array<int> A, array<int> B)
{
  local int i;
  while (B.length > 0)
  {
    for (i = 0; i < A.length; i++)
    {
      if (A[i] == B[0])
      {
        A.remove(i, 1);
        break;
      }
    }
    B.remove(0, 1);
  }
  return A;
}

// Calculate the diffirence between A and B
static final function array<object> RemoveO(array<object> A, array<object> B)
{
  local int i;
  while (B.length > 0)
  {
    for (i = 0; i < A.length; i++)
    {
      if (A[i] == B[0])
      {
        A.remove(i, 1);
        break;
      }
    }
    B.remove(0, 1);
  }
  return A;
}

// Remove the first element of the array and return this element
static final function string ShiftS(out array<string> ar)
{
  local string result;
  if (ar.length > 0)
  {
    result = ar[0];
    ar.remove(0,1);
  }
  return result;
}

// Remove the first element of the array and return this element
static final function object ShiftO(out array<object> ar)
{
  local object result;
  if (ar.length > 0)
  {
    result = ar[0];
    ar.remove(0,1);
  }
  return result;
}

// Remove the first element of the array and return this element
static final function int ShiftI(out array<int> ar)
{
  local int result;
  if (ar.length > 0)
  {
    result = ar[0];
    ar.remove(0,1);
  }
  return result;
}

// Join the elements of a string array to an array
static final function string Join(array< string > ar, optional string delim, optional bool bIgnoreEmpty)
{
  local string result;
  local int i;
  for (i = 0; i < ar.length; i++)
  {
    if (result != "") result = result$delim;
    if (bIgnoreEmpty && ar[i] == "") continue;
    result = result$ar[i];
  }
  return result;
}

// internal function for SortS
static private final function SortSArray(out array<string> ar, int low, int high, optional bool bCaseInsenstive)
{
  local int i,j;
  local string x, y;

  i = Low;
  j = High;
  x = ar[(Low+High)/2];
  if (bCaseInsenstive) x = Caps(x);

  do {
    if (bCaseInsenstive)
    {
      while (Caps(ar[i]) < x) i += 1; 
      while (Caps(ar[j]) > x) j -= 1;
    }
    else {
      while (ar[i] < x) i += 1; 
      while (ar[j] > x) j -= 1;
    }
    if (i <= j)
    {
      y = ar[i];
      ar[i] = ar[j];
      ar[j] = y;
      i += 1; 
      j -= 1;
    }
  } until (i > j);
  if (low < j) SortSArray(ar, low, j, bCaseInsenstive);
  if (i < high) SortSArray(ar, i, high, bCaseInsenstive);
}

// Sort an string array
static final function SortS(out array<string> ar, optional bool bCaseInsenstive)
{
  SortSArray(ar, 0, ar.length-1, bCaseInsenstive);
}

// internal function for SortI
static private final function SortIArray(out array<int> ar, int low, int high)
{
  local int i,j,x,y;

  i = Low;
  j = High;
  x = ar[(Low+High)/2];

  do {    
    while (ar[i] < x) i += 1; 
    while (ar[j] > x) j -= 1;
    if (i <= j)
    {
      y = ar[i];
      ar[i] = ar[j];
      ar[j] = y;
      i += 1; 
      j -= 1;
    }
  } until (i > j);
  if (low < j) SortIArray(ar, low, j);
  if (i < high) SortIArray(ar, i, high);
}

// sort an int array
static final function SortI(out array<int> ar)
{
  SortIArray(ar, 0, ar.length-1);
}

// Return the highest value
static final function int MaxI(out array<int> ar)
{
  local int i, tmp;
  tmp = ar[1];
  for (i = 1; i < ar.length; i++)
  {
    if (ar[i] > tmp) tmp = ar[i];
  }
  return tmp;
}

// Return the highest value
static final function string MaxS(out array<string> ar)
{
  local int i;
  local string tmp;
  tmp = ar[1];
  for (i = 1; i < ar.length; i++)
  {
    if (ar[i] > tmp) tmp = ar[i];
  }
  return tmp;
}

// Return the lowest value
static final function int MinI(out array<int> ar)
{
  local int i, tmp;
  tmp = ar[1];
  for (i = 1; i < ar.length; i++)
  {
    if (ar[i] < tmp) tmp = ar[i];
  }
  return tmp;
}

// Return the lowest value
static final function string MinS(out array<string> ar)
{
  local int i;
  local string tmp;
  tmp = ar[1];
  for (i = 1; i < ar.length; i++)
  {
    if (ar[i] < tmp) tmp = ar[i];
  }
  return tmp;
}

// search a string array for an element, return it's index or -1 if not found
static final function int BinarySearch(array<string> Myarray, string SearchString, optional int Low, optional int High, optional bool bIgnoreCase)
{
  local int Middle;
  if (High == 0) High = MyArray.length-1;
  if (bIgnoreCase) SearchString = Caps(SearchString);

  while (Low <= High) 
  {
    Middle = (Low + High) / 2;
    if (bIgnoreCase) if (MyArray[Middle] ~= SearchString) return Middle;
      else if (MyArray[Middle] == SearchString) return Middle;
    if (MyArray[Middle] > SearchString) High = Middle - 1;
      else if (MyArray[Middle] < SearchString) Low = Middle + 1;
  }
  return -1;           
}

// returns the common beginning of items in a string array
static final function string GetCommonBegin(array<string> slist)
{
  local int i;
  local string common, tmp2;

  common = slist[0];
  for (i = 1; i < slist.length; i++)
  {
    tmp2 = slist[i];
    while ((InStr(tmp2, common) != 0) && (common != "")) common = Left(common, Len(common)-1);
    if (common == "") return "";
  }
  return common;
}