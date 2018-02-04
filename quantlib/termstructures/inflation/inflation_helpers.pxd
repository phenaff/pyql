from quantlib.handle cimport shared_ptr
cimport quantlib.termstructures.inflation._inflation_helpers as _ih

cdef class ZeroCouponInflationSwapHelper:
	cdef shared_ptr[_ih.ZeroCouponInflationSwapHelper]* _thisptr

cdef class YearOnYearInflationSwapHelper:
	cdef shared_ptr[_ih.YearOnYearInflationSwapHelper]* _thisptr
