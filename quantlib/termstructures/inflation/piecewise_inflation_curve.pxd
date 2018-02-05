from quantlib.termstructures.inflation_term_structure cimport \
		InflationTermStructure

cdef enum Interpolator:
	Linear
	LogLinear

cdef enum IndexTrait:
	Zero
	YoY

cdef class PiecewiseInflationCurve(InflationTermStructure):
	cdef readonly IndexTrait _trait
	cdef readonly Interpolator _interpolator