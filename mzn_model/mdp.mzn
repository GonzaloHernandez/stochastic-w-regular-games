enum states;
enum actions;
array[states,actions,states] of float: P;
array[states,actions,states] of float: R;
float : g;

array[states,actions]   of var float : EU;
array[states]           of var -100.0..100.0 : OU;

constraint
    forall(s in states,a in actions)(
        EU[s,a] = 
        sum(s_ in states) (
            (P[s,a,s_])*(R[s,a,s_]+(g*OU[s_]))
        )
    );

constraint
    forall(s in states) (
        OU[s] = max(a in actions) (
            EU[s,a]
        )
    );

constraint
    forall(s in states, a in actions) (
        OU[s] >= EU[s,a]
    );

% solve minimize sum(OU);

include "globals.mzn";
array[states] of var actions : OP;
constraint
    forall(s in states) ( 
        OP[s] = arg_max(a in actions)(
            EU[s,a]
        )
    );

output 
    ["\(to_enum(actions,arg_max(a in actions)(fix(EU[s,a])))) " | s in states ];
