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
        OU[s] = max(EU[s,..])
    );


include "globals.mzn";
array[states] of var actions : OP;
constraint
    forall(s in states) ( 
        OP[s] = arg_max(EU[s,..])
    );


% solve maximize sum(OU);