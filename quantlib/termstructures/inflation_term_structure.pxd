cimport quantlib.termstructures._inflation_term_structure as _its
from libcpp cimport bool as cbool
from libcpp cimport bool
from quantlib.handle cimport shared_ptr, Handle

from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time._period cimport Frequency 

cdef class InflationTermStructure:
    cdef shared_ptr[Handle[_its.InflationTermStructure]]* _thisptr
    cdef cbool relinkable
    cdef _its.InflationTermStructure* _get_term_structure(self)
    cdef _is_empty(self)
    cdef _raise_if_empty(self)

cdef class ZeroInflationTermStructure(InflationTermStructure):
    pass

cdef class YoYInflationTermStructure(InflationTermStructure):
    pass

cpdef list inflation_period(Date date, Frequency f)

cpdef double inflation_year_fraction(Frequency f, 
                             bool index_is_interpolated,
                             DayCounter day_counter,
                             Date d1,
                             Date d2)
