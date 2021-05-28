include "../list/List.dfy"

// -------------------------- Datatype -------------------------- //

datatype Leaf = Nil
datatype BST<T> = Leaf | Node(left:BST<T>, data:T, right:BST<T>)

// ---------------------- Function Methods ---------------------- //

function method BST_Init() : (tree:BST<T>)
  ensures bst_is_ordered(tree)
{
  Leaf
}

function method BST_Size(tree:BST<T>) : (n:int)
  decreases tree
{
    match tree {
      case Leaf => 0
      case Node(left, x, right) => BST_Size(left) + 1 + BST_Size(right)
    }
}

function method BST_Insert(tree:BST<T>, d:T) : (result:BST<T>)
  requires bst_is_ordered(tree)
  // ensures bst_is_ordered(result) // Postcondition that might not hold
  decreases tree
{
  match tree {
    case Leaf => Node(Leaf, d, Leaf)
    case Node(left, x, right) => 
      if (d < x)
        then Node(BST_Insert(left, d), x , right)
      else Node(left, x, BST_Insert(right, d))
  }
}

function method BST_InOrder(tree:BST<T>) : (result:List<T>)
  requires bst_is_ordered(tree)
  ensures BST_ToMultiset(tree) == List_ToMultiset(BST_InOrder(tree))
  //ensures list_is_ordered(result) // Postcondition that might not hold
  decreases tree
{
  match tree {
    case Leaf => List_Empty
    case Node(left, x, right) => List_Concat(BST_InOrder(left), Cons(x, BST_InOrder(right)))
  }
}

function method BST_ToMultiset(tree:BST<T>) : multiset<T>
  decreases tree
{
  match tree {
    case Leaf => multiset{}
    case Node(left, x, right) => multiset{x} + BST_ToMultiset(left) + BST_ToMultiset(right)
  }
}

function method BST_Contains(tree:BST<T>, d:T) : bool
  requires bst_is_ordered(tree)
  decreases tree
{
  match tree {
    case Leaf => false
    case Node(left, x, rigth) => BST_Contains(left, d) || BST_Contains(rigth, d)
  }
}

function method BST_Mirror(tree:BST<T>) : BST<T>
  decreases tree
{
  match tree {
    case Leaf => Leaf
    case Node(left, x, right) => Node(BST_Mirror(right), x, BST_Mirror(left))
  }
}

// ---------------------- Predicates ---------------------- //

predicate bst_is_ordered(tree:BST<T>)
  decreases tree
{
  match tree {
    case Leaf => true
    case Node(left, x, right) => 
      bst_is_ordered(left) &&
      bst_is_ordered(right) &&
      bst_high_bound(left, x) &&
      bst_low_bound(right, x)
  }
}

predicate bst_low_bound(tree:BST<T>, d:T)
  decreases tree
{
  match tree {
    case Leaf => true
    case Node(left, x, right) => d <= x && bst_low_bound(left, d) && bst_low_bound(right, d)
  }
}

predicate bst_high_bound(tree:BST<T>, d:T)
  decreases tree
{
  match tree {
    case Leaf => true
    case Node(left, x, right) => d >= x && bst_high_bound(left, d) && bst_high_bound(right, d)
  }
}

// ------------------------ Lemmas ------------------------ //
/*
lemma Lemma_InsertHighBound(tree:BST<T>, d:T, x:T)
  requires bst_high_bound(tree, x)
  requires d < x
  ensures bst_high_bound(BST_Insert(tree, d), x)
{

}

lemma Lemma_InsertLowBound(tree:BST<T>, d:T, x:T)
  requires bst_low_bound(tree, x)
  requires d >= x
  ensures bst_low_bound(BST_Insert(tree, d), x)
{

}
*/

/*
lemma {:induction tree} Lemma_InsertOrdered(tree:BST<T>, d:T)
  requires bst_is_ordered(tree)
  ensures bst_is_ordered(BST_Insert(tree, d))
  decreases tree
{
  match tree {
    case Leaf =>
      calc == {
        bst_is_ordered(BST_Insert(tree, d));
          { assert tree == Leaf; }
        bst_is_ordered(BST_Insert(Leaf, d));
          { assert BST_Insert(Leaf, d) == Node(Leaf, d, Leaf); }
        bst_is_ordered(Node(Leaf, d, Leaf));
        true;
      }
    case Node(left, x, right) =>
      calc == {
        bst_is_ordered(BST_Insert(tree, d));
          { assert tree == Node(left, x, right); }
        bst_is_ordered(BST_Insert(Node(left, x, right), d));
        { if d < x {
          calc == {
            bst_is_ordered(BST_Insert(left, d));
              { Lemma_InsertOrdered(left, d); }
              //{ Lemma_InsertHighBound(left, d, x); }
          }
        } else {
          calc == {
            bst_is_ordered(BST_Insert(right, d));
              { Lemma_InsertOrdered(right, d); }
              //{ Lemma_InsertLowBound(right, d, x); }
          }
        } }
        bst_is_ordered(BST_Insert(Leaf, d));
          { assert BST_Insert(Leaf, d) == Node(Leaf, d, Leaf); }
        bst_is_ordered(Node(Leaf, d, Leaf));
        true;
      }
  }
}
*/

lemma {:induction tree} Lemma_BSTSameElementsThanInOrder(tree:BST<T>)
  requires bst_is_ordered(tree)
  ensures BST_ToMultiset(tree) == List_ToMultiset(BST_InOrder(tree))
  decreases tree
{
  match tree {
    case Leaf =>
      calc == {
        BST_ToMultiset(tree);
          { assert tree == Leaf; }
        BST_ToMultiset(Leaf);
          { assert BST_ToMultiset(Leaf) == multiset{}; }
        multiset{};
          { assert multiset{} == List_ToMultiset(List_Empty); }
        List_ToMultiset(List_Empty);
          { assert List_Empty == BST_InOrder(Leaf); }
        List_ToMultiset(BST_InOrder(Leaf));
          { assert Leaf == tree; }
        List_ToMultiset(BST_InOrder(tree));
      }
    case Node(left, x, right) =>
      calc == {
        List_ToMultiset(BST_InOrder(tree));
          { assert List_ToMultiset(BST_InOrder(tree)) == List_ToMultiset(BST_InOrder(Node(left, x, right))); }
        List_ToMultiset(BST_InOrder(Node(left, x, right)));
          { assert List_ToMultiset(BST_InOrder(Node(left, x, right))) == List_ToMultiset(List_Concat(BST_InOrder(left), Cons(x, BST_InOrder(right)))); }
        List_ToMultiset(List_Concat(BST_InOrder(left), Cons(x, BST_InOrder(right))));
          { assert List_ToMultiset(List_Concat(BST_InOrder(left), Cons(x, BST_InOrder(right)))) == List_ToMultiset(BST_InOrder(left)) + List_ToMultiset(Cons(x, BST_InOrder(right))); }
        List_ToMultiset(BST_InOrder(left)) + List_ToMultiset(Cons(x, BST_InOrder(right)));
          { assert List_ToMultiset(Cons(x, BST_InOrder(right))) == List_ToMultiset(Cons(x, List_Empty)) + List_ToMultiset(BST_InOrder(right)); }
        List_ToMultiset(BST_InOrder(left)) + List_ToMultiset(Cons(x, List_Empty)) + List_ToMultiset(BST_InOrder(right));
          { assert List_ToMultiset(Cons(x, List_Empty)) == multiset{x} + List_ToMultiset(List_Empty); }
        List_ToMultiset(BST_InOrder(left)) + multiset{x} + List_ToMultiset(List_Empty) + List_ToMultiset(BST_InOrder(right));
          { assert List_ToMultiset(List_Empty) == multiset{}; }
        List_ToMultiset(BST_InOrder(left)) + multiset{x} + multiset{} + List_ToMultiset(BST_InOrder(right));
          { assert multiset{x} + multiset{} == multiset{x}; }
        List_ToMultiset(BST_InOrder(left)) + multiset{x} + List_ToMultiset(BST_InOrder(right));
          { Lemma_BSTSameElementsThanInOrder(left); }
          { Lemma_BSTSameElementsThanInOrder(right); }
        BST_ToMultiset(tree);
      }
  }
}

lemma {:induction tree} Lemma_BSTOrderedThenInOrderOrdered(tree:BST<T>)
  requires bst_is_ordered(tree)
  ensures list_is_ordered(BST_InOrder(tree))
{
  match tree {
    case Leaf =>
      calc == {
        list_is_ordered(BST_InOrder(tree));
          { assert tree == Leaf; }
        list_is_ordered(BST_InOrder(Leaf));
          { assert BST_InOrder(Leaf) == List_Empty; }
        list_is_ordered(List_Empty);
        true;
      }
    case Node(left, x, right) =>
      calc == {
        list_is_ordered(BST_InOrder(tree));
          { assert tree == Node(left, x, right); }
        list_is_ordered(BST_InOrder(Node(left, x, right)));
          { assert BST_InOrder(Node(left, x, right)) ==  List_Concat(BST_InOrder(left), Cons(x, BST_InOrder(right))); }
        list_is_ordered(List_Concat(BST_InOrder(left), Cons(x, BST_InOrder(right))));
          { assert bst_low_bound(right, x); }
          { Lemma_BSTLowBoundThenInOrderLowBound(right, x); }
          { assert bst_high_bound(left, x); }
          { Lemma_BSTHighBoundThenInOrderHighBound(left, x); }
          { Lemma_ConcatSortedWithMiddleElement(BST_InOrder(left), x, BST_InOrder(right)); }
        true;
      }
  }
}

lemma {:induction tree} Lemma_BSTHighBoundThenInOrderHighBound(tree:BST<T>, d:T)
  requires bst_is_ordered(tree)
  requires bst_high_bound(tree, d)
  ensures list_high_bound(BST_InOrder(tree), d)
{
  match tree {
    case Leaf =>
      calc == {
        list_high_bound(BST_InOrder(tree), d);
          { assert tree == Leaf; }
        list_high_bound(BST_InOrder(Leaf), d);
          { assert BST_InOrder(Leaf) == List_Empty; }
        list_high_bound(List_Empty, d);
        true;
      }
      case Node(left, x, right) =>
        calc == {
          list_high_bound(BST_InOrder(tree), d);
            { assert tree == Node(left, x, right); }
          list_high_bound(BST_InOrder(Node(left, x, right)), d);
            { assert BST_InOrder(Node(left, x, right)) == List_Concat(BST_InOrder(left), Cons(x, BST_InOrder(right))); }
          list_high_bound(List_Concat(BST_InOrder(left), Cons(x, BST_InOrder(right))), d);
            { assert list_high_bound(BST_InOrder(left), d); }
            { assert list_high_bound(BST_InOrder(right), d); }
            { assert d >= x; }
            { Lemma_IfElemHighBoundOfTwoListsThenIsHighBoundOfConcat(BST_InOrder(left), BST_InOrder(right), d, x); }
          true;
        }
  }
}

lemma {:induction tree} Lemma_BSTLowBoundThenInOrderLowBound(tree:BST<T>, d:T)
  requires bst_is_ordered(tree)
  requires bst_low_bound(tree, d)
  ensures list_low_bound(BST_InOrder(tree), d)
{
  match tree {
    case Leaf =>
      calc == {
        list_low_bound(BST_InOrder(tree), d);
          { assert tree == Leaf; }
        list_low_bound(BST_InOrder(Leaf), d);
          { assert BST_InOrder(Leaf) == List_Empty; }
        list_low_bound(List_Empty, d);
        true;
      }
      case Node(left, x, right) =>
        calc == {
          list_low_bound(BST_InOrder(tree), d);
            { assert tree == Node(left, x, right); }
          list_low_bound(BST_InOrder(Node(left, x, right)), d);
            { assert BST_InOrder(Node(left, x, right)) == List_Concat(BST_InOrder(left), Cons(x, BST_InOrder(right))); }
          list_low_bound(List_Concat(BST_InOrder(left), Cons(x, BST_InOrder(right))), d);
            { assert list_low_bound(BST_InOrder(left), d); }
            { assert list_low_bound(BST_InOrder(right), d); }
            { assert d <= x; }
            { Lemma_IfElemLowBoundOfTwoListsThenIsLowBoundOfConcat(BST_InOrder(left), BST_InOrder(right), d, x); }
          true;
        }
  }
}

/*
function method BST_Load(list:List<T>): (result:BST<T>)
  ensures bst_is_ordered(result)
  ensures BST_ToMultiset(result) == List_ToMultiset(input)
{

}

lemma Lemma_MultisetLoadSameElementsThanList(input:List<T>)
  ensures BST_ToMultiset(BST_Load(input)) == List_ToMultiset(input)
{

}

lemma Lemma_LoadOrdered(input:List<T>)
  ensures bst_is_ordered(BST_Load(input))
{

}
*/
