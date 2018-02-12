from quantlib.termstructures.inflation_term_structure cimport \
		InflationTermStructure

# FIXME: use globals() instead?
cdef enum Interpolator:
	Linear
	LogLinear

cdef class PiecewiseInflationCurve(InflationTermStructure):
	cdef readonly Interpolator _interpolator