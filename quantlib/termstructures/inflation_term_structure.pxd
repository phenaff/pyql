cimport quantlib.termstructures._inflation_term_structure as _its
from quantlib.handle cimport shared_ptr
"""
from quantlib.handle cimport RelinkableHandle
"""
from libcpp cimport bool

from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time._period cimport Frequency 

cdef class InflationTermStructure:
    cdef shared_ptr[_its.InflationTermStructure] _thisptr

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
