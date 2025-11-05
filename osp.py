class MDPModel :
    def __init__(self, sqsize, p):
        self.sqsize = sqsize
        self.size   = sqsize*sqsize
        self.p      = p

    def getSize(self) :
        return self.size

    def getDegree(self, s) :
        assert s >= 1 and s <= self.size
        degree = 5
        if s % self.sqsize == 1:            # left edge
            degree -= 1
        if s % self.sqsize == 0:            # right edge
            degree -= 1
        if s <= self.sqsize:                # top edge
            degree -= 1
        if s > self.size - self.sqsize:     # bottom edge
            degree -= 1
        return degree

    def getTargets(self, s) :
        assert s >= 1 and s <= self.size
        targets = [s]
        if s % self.sqsize != 1:            # left edge
            targets.append(s - 1)
        if s % self.sqsize != 0:            # right edge
            targets.append(s + 1)
        if s > self.sqsize:                 # top edge
            targets.append(s - self.sqsize)
        if s <= self.size - self.sqsize:    # bottom edge
            targets.append(s + self.sqsize)
        return targets

    def getProbability(self, s, r):
        if r not in self.getTargets(s):
            return 0
        if r == s:
            return self.p
        
        return (1-self.p) / (self.getDegree(s)-1)

def pod(r) :
    return 0.3

M = MDPModel(3, 0.3)

from minizinc import Instance, Model, Solver

model = Model("mzn_model/osp.mzn")
gecode = Solver.lookup("org.minizinc.mip.highs")
instance = Instance(gecode, model)
instance["maxV"] = M.size
instance["maxT"] = 6
instance["M"] = [[M.getProbability(s,r) for r in range(1,M.size+1)] for s in range(1,M.size+1)]
instance["pod"] = [pod(r) for r in range(1,M.size+1)]
instance["searcher"] = 1
instance["mobile"] = 5

result = instance.solve()
print(result["Y"])
