from quantlib.handle cimport shared_ptr
cimport quantlib.termstructures.inflation._inflation_helpers as _ih

cdef class ZeroCouponInflationHelper:
	pass
	
cdef class ZeroCouponInflationSwapHelper(ZeroCouponInflationHelper):
	cdef shared_ptr[_ih.ZeroCouponInflationSwapHelper]* _thisptr

cdef class YearOnYearInflationSwapHelper(ZeroCouponInflationHelper):
	cdef shared_ptr[_ih.YearOnYearInflationSwapHelper]* _thisptr
