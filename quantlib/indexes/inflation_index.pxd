from quantlib.index cimport Index

cdef class InflationIndex(Index):
    pass

cdef class ZeroInflationIndex(InflationIndex):
    pass

cdef class YoYInflationIndex(InflationIndex):
    pass

cdef class UKRPI(ZeroInflationIndex):
    pass

cdef class AUCPI(ZeroInflationIndex):
    pass

cdef class YYUKRPI(YoYInflationIndex):
    pass


