include "globals.mzn";

int: MIN = 0;
int: MAX = 1;
int: RND = 2;
int: SNK = 3;

set of int : TYPES = {MIN,MAX,RND,SNK};
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

% -------------------------------------------------------------------------

% float                       : g = 0.999;
% float: max_r = max(rewards);
% float: min_r = min(rewards);
% float: upper_bound = if max_r > 0 then max_r/(1.0-g) else max_r endif;
% float: lower_bound = if min_r < 0 then min_r/(1.0-g) else min_r endif;
% array[vertices] of var lower_bound .. upper_bound: P;

float                       : g = 1.0;
array[vertices] of var prob : P;

% -------------------------------------------------------------------------

constraint
    forall(v in vertices where v in sinks)(
        P[v] = rewards[v]
    );

constraint
    forall(v in vertices where types[v]=RND /\ not(v in sinks))(
        P[v] =  rewards[v] +
                g * sum(e in edges where sources[e]=v) (
                        chances[e] * P[targets[e]]
                    )
    );

constraint
    forall(v in vertices where types[v]=MIN /\ not(v in sinks))(
        P[v] =  rewards[v] + 
                min(e in edges where sources[e]=v)(
                    P[targets[e]]
                )
    );

constraint
    forall(v in vertices where types[v]=MAX /\ not(v in sinks))(
        P[v] =  rewards[v] + 
                max(e in edges where sources[e]=v)(
                    P[targets[e]]
                )
    );

solve minimize sum(P);

% -------------------------------------------------------------------------

int: dummy = -1;
array[vertices] of edges union {dummy} : policy::output_only = [
    if types[v]=RND \/ v in sinks then
        dummy 
    elseif types[v]=MIN /\ not(v in sinks) then
        arg_min([e:fix(P[targets[e]]) | e in edges where sources[e]=v])
    else 
        arg_max([e:fix(P[targets[e]]) | e in edges where sources[e]=v])
    endif
    | v in vertices ];

output[
    "P      =\(P) \n" 
    ++ "policy =\(policy) \n"
    ]
