include '../../types.pxi'

from libcpp.vector cimport vector
from libcpp cimport bool
from quantlib.handle cimport shared_ptr, Handle

cimport quantlib.termstructures.inflation._inflation_helpers as _ih

from quantlib.termstructures._inflation_term_structure cimport \
    ZeroInflationTermStructure, InflationTermStructure
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from quantlib.time._period cimport Period, Frequency
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure

from quantlib.termstructures._helpers cimport BootstrapHelper

from quantlib.termstructures._inflation_term_structure cimport (
    YoYInflationTermStructure, ZeroInflationTermStructure)

cdef extern from 'ql/termstructures/inflation/inflationtraits.hpp' namespace 'QuantLib':

    cdef cppclass ZeroInflationTraits:
        pass

    cdef cppclass YoYInflationTraits:
        pass

cdef extern from 'ql/math/interpolations/all.hpp' namespace 'QuantLib':
    cdef cppclass Linear:
        pass

    cdef cppclass LogLinear:
        pass

cdef extern from 'ql/termstructures/inflation/interpolatedzeroinflationcurve.hpp' namespace 'QuantLib':
    cdef cppclass InterpolatedZeroInflationCurve[I](ZeroInflationTermStructure):
        pass

cdef extern from 'ql/termstructures/inflation/piecewisezeroinflationcurve.hpp' namespace 'QuantLib':

    #cdef cppclass PiecewiseZeroInflationCurve[I]:
    cdef cppclass PiecewiseZeroInflationCurve[I](InflationTermStructure):
        PiecewiseZeroInflationCurve(Date& referenceDate,
               Calendar& calendar,
               DayCounter& dayCounter,
               Period& lag,
               Frequency frequency,
               bool indexIsInterpolated,
               Rate baseZeroRate,
               Handle[YieldTermStructure]& nominalTS,
               # vector[shared_ptr[_ih.ZeroCouponInflationSwapHelper]]& instruments,
               vector[shared_ptr[BootstrapHelper[ZeroInflationTermStructure]]]& instruments,
               Real accuracy) except +

