#!/usr/bin/sage
# vim: syntax=python

import textwrap

from hash_to_field import I2OSP


class Printer:
    """ Prints values in rfc format """

    @staticmethod
    def _pprint_hex(octet_string):
        if isinstance(octet_string, str):
            return "".join("{:02x}".format(ord(c)) for c in octet_string)
        assert isinstance(octet_string, bytes)
        return "".join("{:02x}".format(c) for c in octet_string)

    @staticmethod
    def _tv_wrap(text):
        return textwrap.fill(text, 54).split("\n")

    @staticmethod
    def _lv(label, values):
        prefix = "{:7s} = ".format(label)
        sep_lines = "\n" + " " * 10
        sep_extension = "\n" + " " * 7 + "+i*"
        out = sep_extension.join([sep_lines.join(Printer._tv_wrap(value))
                                  for value in values])
        return prefix + out

    @staticmethod
    def _gf_hex(num, length):
        return [Printer._pprint_hex(I2OSP(ni, length)) for ni in list(num.polynomial())]

    @staticmethod
    def _get_point_length(point):
        return Printer._get_gf_length(point[0])

    @staticmethod
    def _get_gf_length(num):
        prime = num.base_ring().characteristic()
        return len(prime.digits(256))

    class tv:
        @staticmethod
        def text(label, value):
            """ Prints a string message """
            return Printer._lv(label, [value])

        @staticmethod
        def gf(label, num, length=None):
            """ Prints a field element """
            if length is None:
                length = Printer._get_gf_length(num)
            return Printer._lv(label, Printer._gf_hex(num, length))

        @staticmethod
        def point(label, point):
            if point.is_zero():
                return Printer.tv.text(label, "inf")
            (x, y, _) = point
            length = Printer._get_point_length(point)
            return "\n".join([
                Printer.tv.gf("%s.x" % label, x, length),
                Printer.tv.gf("%s.y" % label, y, length)])

    class math:
        @staticmethod
        def gf(num, length=None):
            if length is None:
                length = Printer._get_gf_length(num)
            return ",".join(["0x{0}".format(numi) for numi in Printer._gf_hex(num, length)])

        @staticmethod
        def point(point):
            if point.is_zero():
                return {"inf": True}
            (x, y, _) = point
            length = Printer._get_point_length(point)
            return {"x": Printer.math.gf(x, length), "y": Printer.math.gf(y, length)}
