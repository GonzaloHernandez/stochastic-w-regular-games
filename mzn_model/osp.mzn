int: maxV;
int: maxT;

set of int: T = 1..maxT;
set of int: V = 1..maxV;
array [V,V] of float: M;
array [V] of float: pod;

V: searcher;
V: mobile;

% decision variables
array [T] of var V: Y;

% non-decision variables used to compute the COS
array [T,V] of var 0.0..1.0: POC;
array [T,V] of var 0.0..1.0: POS;

constraint
    Y[searcher] = 1;

constraint
    POC[1,mobile] = 1.0;

constraint
    forall(t in 2..maxT) (
        M[Y[t-1],Y[t]] > 0.0
    );

constraint
    forall(t in T,r in V) (
        ((Y[t] == r) -> (POS[t,r] = POC[t,r]*pod[r])) /\
        ((Y[t] != r) -> (POS[t,r] = 0.0))
    );

constraint
    forall(t in 2..maxT,r in V)(
        POC[t,r] = sum (s in V) (M[s,r] * (POC[t-1,s]-POS[t-1,s]))
    );

solve maximize sum (t in T, r in V)(POS[t,r]);