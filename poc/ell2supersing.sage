from hash_to_base import *
from utils import *
load("common.sage")

p = PrimeDict["SIKEP503"]
m = 1
q = p^m
F = GF(q)
a1, a2, a3, a4, a6 = F(0), F(0), F(0), F(1), F(0)
B = a4
E = EllipticCurve(F, [a1, a2, a3, a4, a6])

h2c_suite = "H2C-SIKEP503-SHA512-ELL2A0-"

# Textbook implementation
def elligator2A0(alpha):
    assert q%4 == 3
    u = h2b_from_label(h2c_suite, alpha)

    x1 = u
    gx1 = x1^3 + B * x1
    x2 = -x1
    gx2 = x2^3 + B * x2
    if is_square(gx1):
        x = x1
        y = sq_root(gx1, q)
    else:
        x = x2
        y = sq_root(gx2, q)

    return E(x, y)

# Implementation
def elligator2A0_slp(alpha):
    u = h2b_from_label(h2c_suite, alpha)

    x1 = u
    gx1 = x1^2
    gx1 = gx1 + B
    gx1 = gx1 * x1
    tv("gx1", gx1, 63)

    x2 = -x1
    gx2 = -gx1
    tv("gx2", gx2, 63)

    e = is_QR(gx1, q)
    x = CMOV(x2, x1, e)
    gx = CMOV(gx2, gx1, e)
    y = sq_root(gx, q)

    return E(x,y)

if __name__ == "__main__":
    enable_debug()
    print "## Elligator2A0 to SIKE-P503"
    for alpha in map2curve_alphas:
        print "\n~~~"
        print("Input:")
        print("")
        tv_text("alpha", pprint_hex(alpha))
        print("")
        print("Intermediate values:")
        print("")
        pA, pB = elligator2A0(alpha), elligator2A0_slp(alpha)
        assert pA == pB
        print("")
        print("Output:")
        print("")
        tv("x", pB[0], 63)
        tv("y", pB[1], 63)
        print "~~~"
