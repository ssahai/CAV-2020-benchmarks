// is this sequence a derangement?
function is_drng(n: int, der: seq<int>): bool
  requires n > 1
{
    |der| == n &&
    forall i :: (0 <= i < n) ==> (der[i] != i && 0 <= der[i] < n)
}

// does every member of this list of lists have the same length?
function same_len(der_list: seq<seq<int>>): bool
{
    forall i, j :: 
        (0 <= i < |der_list| && 0 <= j < |der_list|) ==> 
            |der_list[i]| == |der_list[j]|
}

function uniq_list(lst: seq<seq<int>>): bool
{
    forall i, j :: 
        (i != j && 0 <= i < |lst| && 0 <= j < |lst|) ==>
            lst[i] != lst[j]
}

function diff_index(n : int, d1: seq<int>, d2: seq<int>, i: int): int
    requires n > 1;
    requires is_drng(n, d1);
    requires is_drng(n, d2);
    requires 0 <= i < |d1|;
    requires d1[i..] != d2[i..];
    ensures i <= diff_index(n, d1, d2, i) < |d1| && 
            d1[diff_index(n, d1, d2, i)] != d2[diff_index(n, d1, d2, i)];
    decreases |d1| - i;
{
    if (d1[i] != d2[i]) 
        then i
        else diff_index(n, d1, d2, i+1)
}

function extension(der: seq<int>, c: int): seq<int>
  requires |der| > 1;
  requires is_drng(|der|, der);
  requires 0 <= c < |der|
  ensures is_drng(|der|+1, extension(der, c));
{
  var extn := der + [|der|];
  extn[|der| := extn[c]][c := |der|]
}

lemma extensions_differ_l(der1: seq<int>, der2: seq<int>, c: int)
  requires |der1| > 1;
  requires |der2| > 1;
  requires |der1| == |der2|;
  requires is_drng(|der1|, der1);
  requires is_drng(|der2|, der2);
  requires 0 <= c < |der1|;
  requires 0 <= c < |der2|;
  requires der1 != der2;
  ensures extension(der1, c) != extension(der2, c);
{
  var e1 := extension(der1, c);
  var e2 := extension(der2, c);
  var len := |der1|;
  var i := diff_index(len, der1, der2, 0);
  assert i < len;
  assert (i == c) ==> e1[len] != e2[len];
  assert (i != c) ==> e1[i] != e2[i];
}

lemma extensions_differ_r(der: seq<int>, c1: int, c2:int)
  requires |der| > 1;
  requires is_drng(|der|, der);
  requires 0 <= c1 < |der|;
  requires 0 <= c2 < |der|;
  requires c1 != c2;
  ensures extension(der, c1) != extension(der, c2);
{
  var e1 := extension(der, c1);
  var e2 := extension(der, c2);
  assert (c1 != |der| && c2 != |der|) ==> e1[c1] != e2[c1];
}

lemma extensions_differ_lr(der1: seq<int>, der2: seq<int>, c1: int, c2:int)
  requires |der1| > 1;
  requires |der2| > 1;
  requires |der1| == |der2|;
  requires is_drng(|der1|, der1);
  requires is_drng(|der2|, der2);
  requires 0 <= c1 < |der1|;
  requires 0 <= c2 < |der2|;
  requires der1 != der2 || c1 != c2;
  ensures extension(der1, c1) != extension(der2, c2);
{
  var e1 := extension(der1, c1);
  var e2 := extension(der2, c2);
  var len := |der1|;
  if (der1 != der2 && c1 == c2) {
    extensions_differ_l(der1, der2, c1);
  } else if (der1 == der2 && c1 != c2) {
    extensions_differ_r(der1, c1, c2);
  } else if (der1 != der2 && c1 != c2) {
    assert e1[c1] == len;
    assert e1[c2] != len;
    assert e2[c2] == len;
    assert e1 != e2;
  } else {
    // will never get here because of the assumptions.
    assert false;
  }
}

