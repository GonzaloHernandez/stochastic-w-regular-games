int: MIN = 0;
int: MAX = 1;
int: RND = 2;
int: SNK = 3;

set of int : types = {MIN,MAX,RND,SNK};
int: nvertices;
int: nedges;

set of int  : vertices  = 1..nvertices;
set of int  : edges     = 1..nedges;
set of float: prob      = 0.0..1.0; 

% -------------------------------------------------------------------------

array[vertices] of types    : owners;
array[vertices] of float    : values;
array[edges]    of vertices : sources;
array[edges]    of vertices : targets;
array[edges]    of prob     : chances;
array[edges]    of int      : rewards;

array[vertices] of var prob : P;
array[vertices] of var bool : V;
array[edges]    of var bool : E;
int: init;

% -------------------------------------------------------------------------

constraint
    V[init];

constraint
    forall(v in vertices where owners[v]=MAX \/ owners[v]=MIN)(
        V[v] -> sum(e in edges where sources[e]=v)(E[e]) = 1
    );

constraint
    forall(v in vertices where owners[v]=RND)(
        V[v] -> forall(e in edges where sources[e]=v)(E[e])
    );

constraint
    forall(e in edges)(
        E[e] -> V[targets[e]]
    );

constraint
    forall(w in vertices where w != init)(
        V[w] -> exists(e in edges where targets[e]=w)(E[e])
    );

constraint
    forall(v in vertices)(
        (not V[v]) -> forall(e in edges where sources[e]=v)(not E[e])
    );

% -------------------------------------------------------------------------

include "globals.mzn";

constraint
    forall(v in vertices where owners[v]=SNK)(
        P[v] = values[v]
    );

constraint
    forall(v in vertices where owners[v]=MAX)(
        let {
            var edges:best = arg_max([e:P[targets[e]] | e in edges where sources[e]=v])
        } in
        P[v] = P[targets[best]] /\ 
        (V[v] -> E[best])
    );

constraint
    forall(v in vertices where owners[v]=MIN)(
        let {
            var edges:best = arg_min([e:P[targets[e]] | e in edges where sources[e]=v])
        } in
        P[v] = P[targets[best]] /\ 
        (V[v] -> E[best])
    );

constraint
    forall(v in vertices where owners[v]=RND)(
        P[v] = sum(e in edges where sources[e]=v)(
            chances[e] * (rewards[e] + P[targets[e]])
        )
    );
    
% -----------------------------------------------------------------

% constraint
%     V[6];

% -----------------------------------------------------------------

% var float : objective;

% constraint
%     if (owners[init]=MAX) then
%         objective = P[init]
%     else
%         objective = 1-P[init]
%     endif;

% solve maximize objective;

% -----------------------------------------------------------------

output[
    "vertices=\(V)\n" ++
    "edges=\(E)\n" ++
    "values=\(P)"
    ];