from hash_to_base import *
from utils import *

# P384
p = 2^384 - 2^128 - 2^96 + 2^32 - 1
F = GF(p)
A = 0
B = 0x1
E = EllipticCurve([F(A), F(B)])

h2c_suite = "H2C-P384-SHA512-BF-"

def bonehfranklin(alpha):
    u = h2b_from_label(h2c_suite, alpha)
    u = F(u)
    x = (u^2 - B)^((2*p-1)//3)
    return E(x, u) # raises expection if not on curve

ONE_THIRD = (2 * p - 1) // 3 # in ZZ

def bonehfranklin_slp(alpha):
    u = h2b_from_label(h2c_suite, alpha)
    tv("u ", u, 48)

    u = F(u)
    t0 = u ^ 2
    assert t0 == u^2
    tv("t0", t0, 48)

    t1 = t0 - B
    assert t1 == (u^2 - B)
    tv("t1", t1, 48)

    x = t1 ^ ONE_THIRD
    assert x == ((u^2 - B)^((2*p-1)//3))
    tv("x", x, 48)

    y = u
    #tv("x ", x, 48)
    #tv("y ", y, 48)

    assert x^3 + A*x + B == y^2
    return E(x, y)

if __name__ == "__main__":
    enable_debug()
    print "## Boneh-Franklin to P-384"
    for alpha in map2curve_alphas:
        print "\n~~~"
        print("Input:")
        print("")
        tv_text("alpha", pprint_hex(alpha))
        print("")
        print("Intermediate values:")
        print("")
        pA, pB = bonehfranklin(alpha), bonehfranklin_slp(alpha)
        assert pA == pB
        print("")
        print("Output:")
        print("")
        tv("x", pB[0], 48)
        tv("y", pB[1], 48)
        print "~~~"
