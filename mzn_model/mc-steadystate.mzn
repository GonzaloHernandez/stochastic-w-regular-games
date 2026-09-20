include "globals.mzn";

int: MIN = 0;
int: MAX = 1;
int: RND = 2;


set of int : TYPES = {MIN,MAX,RND};
int: nvertices;
int: nedges;

set of int  : vertices  = 1..nvertices;
set of int  : edges     = 1..nedges;
set of float: prob      = 0.0..1.0;

% -------------------------------------------------------------------------

array[vertices] of TYPES    : types;
array[vertices] of float    : rewards;
array[edges]    of vertices : sources;
array[edges]    of vertices : targets;
array[edges]    of prob     : chances;
set of vertices             : sinks;







array[vertices] of var prob : P;

% --- Probability of stay in every vertex ---------------------------------

constraint
    forall(w in vertices where types[w]=RND /\ not(w in sinks))(
        P[w] =  sum(e in edges where targets[e]=w) (
                    P[sources[e]] * chances[e]
                )
    );

constraint
    1.0 =   sum(v in vertices)(
                P[v]
            );

% Only useful when there is no desicions to make (Markov-Chains)