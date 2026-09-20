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
array[edges]    of vertices : sources;
array[edges]    of vertices : targets;
array[edges]    of prob     : chances;
array[edges]    of float    : rewards;
set of vertices             : sinks;

float                       : g = 0.999;
float: max_r = max(rewards);
float: min_r = min(rewards);
float: upper_bound = if max_r > 0 then max_r/(1.0-g) else max_r endif;
float: lower_bound = if min_r < 0 then min_r/(1.0-g) else min_r endif;

array[vertices] of var lower_bound .. upper_bound: P;

% --- Rewards over edges --------------------------------------------------

constraint
    forall(v in sinks)(
        P[v] = 0
    );
    
constraint
    forall(v in vertices where types[v]=RND /\ not(v in sinks))(
        P[v] =  sum(e in edges where sources[e]=v) (
                    chances[e] * (rewards[v] + g * P[targets[e]])
                )
    );

constraint
    forall(v in vertices where types[v]!=RND /\ not(v in sinks))(
        P[v] =  g * max(e in edges where sources[e]=v)(
                        rewards[e] + P[targets[e]]
                    )
    );

% Pending analysis of 
% - using the discount factor in non-random states.
% - final states as Sink or Absortion state constraint 1 (self-loops)

int: dummy = -1;
array[vertices] of edges union {dummy} : policy::output_only = [
    if types[v]=RND \/ v in sinks then
        dummy 
    else 
        arg_max([e:fix(P[targets[e]]) | e in edges where sources[e]=v])
    endif
    | v in vertices ];

output[
    "P      =\(P) \n" 
    ++ "policy =\(policy) \n"
    ]