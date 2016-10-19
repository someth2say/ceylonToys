import ceylon.collection {

    ArrayList,
    HashSet
}

shared void run() {
    print({1,2,3.0}.narrow<Integer>);
}

alias RefFamily<Type> => Boolean(Collection<Type>);

Boolean(Collection<Object>) ref => (Collection<Object> col) => true;
RefFamily<Object> ref2 => (Collection<Object> col) => true;
RefFamily<Integer> ref3 => (Collection<Integer> col) => true;

// Allowed, but verbose...
shared alias Transformer<ListOfElements,SetOfElement,Element>
given Element satisfies Object
given ListOfElements satisfies List<Element>
given SetOfElement satisfies Set<Element>
=> ListOfElements(SetOfElement);

Transformer<List<Object>,Set<Object>,Object> allGeneric => (Set<Object> par) => ArrayList<Object>();
Transformer<ArrayList<Object>,HashSet<Object>,Object> allConcrete => (HashSet<Object> par) => ArrayList<Object>();
Transformer<ArrayList<Object>,Set<Object>,Object> concreteOnReturnType => (Set<Object> par) => ArrayList<Object>();
Transformer<List<Object>,HashSet<Object>,Object> concreteOnParam => (HashSet<Object> par) => ArrayList<Object>();

// Good, but does not express type restrictions...
shared alias Transformer2<ElementType>
given ElementType satisfies Object
=> List<ElementType>(Set<ElementType>);
Transformer2<Object> generic2 => (Set<Object> par) => ArrayList<Object>();
//Transformer2<Object> concrete2 => (HashSet<Object> par) => ArrayList<Object>(); //ArrayList<Object>(HashSet<Object>) is not assignable to ... (List<Object>(Set<Object>))

//
//// Disallowed...
//shared alias Transformer3<ElementType>
//		given ElementType satisfies Object
//		given LHCollectionType satisfies List<ElementType>
//		given RHCollectionType satisfies Set<ElementType>
//		=> LHCollectionType(RHCollectionType);
//
//Transformer3<List<Object>, Set<Object>, Object> generic3 => (Set<Object> par) => ArrayList<Object>();
//Transformer3<ArrayList<Object>, HashSet<Object>, Object> concrete3  => (HashSet<Object> par) => ArrayList<Object>();

shared abstract class Sup() {}

T func<T>(T i) => identity(i);
Integer base = 1;
// Proposal for function chain
//Integer result = {*identity, ?func, identity}(base);
//Integer result = [*identity, ?func, identity](base);


/** The base class hierarchy **/

shared class A() {
    shared default class B() {}
}

shared class SubA() extends A() {
    shared actual class B() extends super.B() {}
}

shared class Z(){}

/** Now, we want another class that can accept any kind of A's **/
shared class C<AType>() given AType satisfies A {
    //AType.B bThing = nothing; // Type parameter should not occur as qualifying type
    alias AAlias => AType;
    AAlias.B bThingAliased = nothing; // OK
}

shared class D<BType>() given BType satisfies A.B {}

