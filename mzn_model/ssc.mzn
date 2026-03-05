% Use this editor as a MiniZinc scratch book
int: MIN = 0;
int: MAX = 1;
int: AVE = 2;
int: SNK = 3;

set of int : types = {MIN,MAX,AVE,SNK};
int: nvertices;
int: nedges;

set of int  : vertices  = 1..nvertices;
set of int  : edges     = 1..nedges;
set of float: prob      = 0.0..1.0; 

array[vertices] of types: owners;
array[vertices] of prob : values;
array[edges] of vertices: sources;
array[edges] of vertices: targets;
array[edges] of prob    : chances;

array[vertices] of var bool : subgraph;
array[edges]    of var bool : policy;
array[vertices] of var prob : payoffs;
float : gamma = 0.9;
int: init = 1;


constraint
    forall(v in vertices where owners[v]=SNK)(
        payoffs[v] = values[v]
    );

constraint
    forall(v in vertices where owners[v]=MAX \/ owners[v]=MAX)(
        exists(e in edges where sources[e]=v /\ policy[e])(
            payoffs[v] = payoffs[targets[e]]
        )
    );

constraint
    forall(v in vertices where owners[v]=AVE)(
        payoffs[v] = sum(e in edges where sources[e]=v)(
            chances[e]*payoffs[targets[e]]
        )
    );

var float : objective;

constraint
    if (owners[init]=MAX) then
        objective = payoffs[init]
    else
        objective = 1-payoffs[init]
    endif;

solve maximize objective;