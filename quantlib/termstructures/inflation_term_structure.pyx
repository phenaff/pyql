# Copyright (C) 2016, Enthought Inc
# Copyright (C) 2016, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

include '../types.pxi'

from libcpp cimport bool
from libcpp.utility cimport pair

cimport quantlib.time._date as _date
from quantlib.time.date cimport Date, Period, date_from_qldate

from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport Handle, shared_ptr, RelinkableHandle

cimport quantlib.time._daycounter as _dc
from quantlib.time.daycounter cimport DayCounter

from quantlib.time._period cimport Frequency 

from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure

cimport quantlib.termstructures.yields._flat_forward as _ff
cimport quantlib._interest_rate as _ir
cimport quantlib.termstructures._inflation_term_structure as _if
cimport quantlib.termstructures.inflation._seasonality as _se

from quantlib.termstructures.inflation.seasonality cimport Seasonality

cdef class InflationTermStructure:

    @property 
    def max_date(self):
        cdef _if.InflationTermStructure* term_structure = self._thisptr.get()
        cdef _date.Date max_date = term_structure.maxDate()
        return date_from_qldate(max_date)

        
cdef class ZeroInflationTermStructure(InflationTermStructure):

    def __cinit__(self):
        pass
    
    def zeroRate(self, Date d,
                 Period inst_obs_lag,
                 bool force_linear_interpolation,
                 bool extrapolate):
        
        cdef _if.ZeroInflationTermStructure* term_structure = \
          <_if.ZeroInflationTermStructure*>self._thisptr.get()
        return term_structure.zeroRate(
            deref(d._thisptr.get()),
            deref(inst_obs_lag._thisptr.get()),
            force_linear_interpolation,
            extrapolate)

    def zeroRate(self, Time t,
                 bool extrapolate):

        cdef _if.ZeroInflationTermStructure* term_structure = \
          <_if.ZeroInflationTermStructure*>self._thisptr.get()
        return term_structure.zeroRate(t, extrapolate)
        
cdef class YoYInflationTermStructure(InflationTermStructure):

    def __cinit__(self):
        pass
    
    def yoyRate(self, Date d,
                Period inst_obs_lag,
                bool force_linear_interpolation,
                bool extrapolate):

        cdef _if.YoYInflationTermStructure* term_structure = \
          <_if.YoYInflationTermStructure*>self._thisptr.get()

        return term_structure.yoyRate(
            deref(d._thisptr.get()),
            deref(inst_obs_lag._thisptr.get()),
            force_linear_interpolation,
            extrapolate)

    def yoyRate(self, Time t,
                bool extrapolate):

        cdef _if.YoYInflationTermStructure* term_structure = \
          <_if.YoYInflationTermStructure*>self._thisptr.get()
        return term_structure.yoyRate(t, extrapolate)


cpdef list inflation_period(Date d, Frequency frequency):

    cdef pair[_date.Date, _date.Date] res
    
    res = _if.inflationPeriod(deref(d._thisptr.get()),
        <_ir.Frequency> frequency)

    return [date_from_qldate(res.first), date_from_qldate(res.second)]

cpdef Time inflation_year_fraction(Frequency f, bool index_is_interpolated,
                               DayCounter day_counter,
                               Date d1, Date d2):
    cdef Time t
    t = _if.inflationYearFraction(<_ir.Frequency> f,
        index_is_interpolated,
        deref(day_counter._thisptr),
        deref(d1._thisptr.get()),
        deref(d2._thisptr.get()))
    return t
