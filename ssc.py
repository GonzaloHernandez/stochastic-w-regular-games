import socket
def send_to_graphing(message):
    host = '127.0.0.1'
    port = 65432
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect((host, port))
            s.sendall((message + "\n").encode('utf-8'))
    except ConnectionRefusedError:
        print("The Graphing session listener is not running")

# --------------------------------------------------------------------


# engine = "org.chuffed.chuffed"
# engine = "org.gecode.gecode"
engine = "org.minizinc.mip.highs"

from minizinc import Instance, Model, Solver, Status
model = Model("mzn_model/ssc.mzn")
model.add_file("data/ssg-Somla.dzn")
gecode = Solver.lookup(engine)
instance = Instance(gecode, model)
instance["init"] = 1

result = instance.solve()

if result.status == Status.SATISFIED or result.status == Status.OPTIMAL_SOLUTION:
    print("P=",result["P"])
    print("O=",result["objective"])

    v_as_binary = "".join(["1" if x else "0" for x in result["V"]])
    e_as_binary = "".join(["1" if x else "0" for x in result["E"]])
    send_to_graphing(f"{v_as_binary},{e_as_binary}")
else:
    print("UNSATISFIABLE")


