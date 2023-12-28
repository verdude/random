import sys


class PascalsTriangle:
    def __init__(self):
        self.triangle = [[1], [1,1]]

    def addlevel(self):
        idx = len(self.triangle)
        prev_row = self.triangle[idx-1]
        new = [1]
        for x in range(1, idx):
            p1, p2 = prev_row[x-1:x+1]
            n = p1 + p2
            new.append(n)
        new.append(1)
        self.triangle.append(new)

    def _join(self, idx) -> str:
        joinstr = "|"
        strrow = [str(x) for x in self.triangle[idx]]
        return joinstr.join(strrow)

    def __str__(self) -> str:
        t = self._join(-1)
        linelength = len(t)
        t += "\n"
        for x in range(len(self.triangle) - 2, -1, -1):
            curline = self._join(x)
            l = len(curline)
            padding = " " * ((linelength - l) // 2)
            curline = f"{padding}{curline}\n"
            t += curline
        return t

    def nchoosek(self, n: int, k: int) -> int:
        if n >= len(self.triangle):
            for x in range(len(self.triangle), n+1):
                print("add level", x, file=sys.stderr)
                self.addlevel()
        return self.triangle[n][k]
