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

float                       : g = 0.95;
float: max_r = max(rewards);
float: min_r = min(rewards);
float: upper_bound = if max_r > 0 then max_r/(1.0-g) else max_r endif;
float: lower_bound = if min_r < 0 then min_r/(1.0-g) else min_r endif;
array[vertices] of var lower_bound .. upper_bound: P;

% array[vertices] of float : bs = [(1.0/(1-g))*rewards[v] | v in vertices];
% array[vertices] of var min(bs) .. max(bs): P;

include "globals.mzn";

% --- Rewards over vertices -----------------------------------------------

constraint
    forall(v in sinks)(
        P[v] =  rewards[v]
    );

constraint
    forall(v in vertices where types[v]=RND /\ not(v in sinks))(
        P[v] =  rewards[v] +
                g * sum(e in edges where sources[e]=v) (
                        chances[e] * P[targets[e]]
                    )
    );

constraint
    forall(v in vertices where types[v]!=RND /\ not(v in sinks))(
        P[v] =  rewards[v] +
                g * max(e in edges where sources[e]=v)(
                        P[targets[e]]
                    )
    );

% Pending analysis of
% - using the discount factor in non-random states.