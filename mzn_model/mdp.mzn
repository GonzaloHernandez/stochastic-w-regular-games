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
% array[vertices] of float    : rewards;
array[edges]    of vertices : sources;
array[edges]    of vertices : targets;
array[edges]    of prob     : chances;
array[edges]    of float    : rewards;
set of vertices             : finals = {2};


array[vertices] of var -100.0..100.0: P;
array[vertices] of var edges: policy;
float: g = 0.95;

include "globals.mzn";

% constraint
%     forall(v in vertices where types[v]=RND)(
%         P[v] = rewards[v] + g * sum(e in edges where sources[e]=v) (chances[e] * P[targets[e]])
%     );

constraint
    forall(v in vertices where types[v]=RND)(
        P[v] = g * sum(e in edges where sources[e]=v) (rewards[e] + chances[e] * P[targets[e]])
    );

% constraint
%     forall(v in vertices where types[v]!=RND)(
%         P[v] =  rewards[v] + 
%                 max(e in edges where sources[e]=v)(P[targets[e]])
%     );

constraint
    forall(v in vertices where types[v]!=RND /\ not( v in finals))(
        P[v] =  max(e in edges where sources[e]=v)(rewards[e] + P[targets[e]])
    );

constraint
    forall(v in vertices where types[v] in {MIN,MAX} /\ not(v in finals))(
        policy[v] =  arg_max([e:P[targets[e]] | e in edges where sources[e]=v])
    );

set of vertices : states = {v | v in vertices where types[v] in {MIN,MAX}};

output
%     ["values = {"] ++ ["\(P[i])," | i in vertices] ++ ["}\n"] ++
    ["values = {"] ++ ["\(P[i])," | i in vertices where types[i]!=RND] ++ ["}\n"] ++
    ["states = {"] ++ ["\(states[s])," | s in states  ]++ ["}\n"] ++
    ["policy = {"] ++ ["\(policy[s])," | s in states] ++ ["}"];
    
    
    