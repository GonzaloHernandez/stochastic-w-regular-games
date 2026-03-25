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

array[vertices] of var float : P;

constraint
    forall(v in vertices where types[v]=RND)(
        P[v] = rewards[v] + 0.95*sum(e in edges where sources[e]=v) (chances[e] * P[targets[e]])
    );
