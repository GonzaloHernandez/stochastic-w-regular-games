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


engine = "org.chuffed.chuffed"
# engine = "org.gecode.gecode"
# engine = "org.minizinc.mip.highs"

from minizinc import Instance, Model, Solver
model = Model("mzn_model/ssc.mzn")
model.add_file("data/ssg-Somla-SN3.dzn")
gecode = Solver.lookup(engine)
instance = Instance(gecode, model)
instance["init"] = 1
result = instance.solve()
v_as_binary = "".join(["1" if x else "0" for x in result["V"]])
e_as_binary = "".join(["1" if x else "0" for x in result["E"]])
# print(result["V"])
# print(result["E"])
print(result["P"])
print(result["objective"])
print(f"{v_as_binary},{e_as_binary}")
send_to_graphing(f"{v_as_binary},{e_as_binary}")
