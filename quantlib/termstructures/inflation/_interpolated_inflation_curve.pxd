include '../../types.pxi'

from libcpp.vector cimport vector
from libcpp cimport bool
from libcpp.pair cimport pair

from quantlib.handle cimport Handle
from quantlib.termstructures._inflation_term_structure cimport ZeroInflationTermStructure

from quantlib.time._date cimport Date
from quantlib.time._period cimport Period, Frequency
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/termstructures/inflation/interpolatedzeroinflationcurve.hpp' namespace 'QuantLib':

    cdef cppclass InterpolatedZeroInflationCurve[I](ZeroInflationTermStructure):
        InterpolatedZeroInflationCurve(const Date& referenceDate,
                                       const Calendar& calendar,
                                       const DayCounter& dayCounter,
                                       const Period& lag,
                                       Frequency frequency,
                                       bool indexIsInterpolated,
                                       const Handle[YieldTermStructure]& yTS,
                                       const vector[Date]& dates,
                                       const vector[Rate]& rates
                                       #const I& interpolator
                                       ) except +

        const Date baseDate()
        # FIXME:
        # ambigous overloaded method
        # const Date maxDate()

        const vector[Date]& dates()
        const vector[Time]& times()
        const vector[Real]& data()
        const vector[Rate]& rates()
        const vector[pair[Date,Rate]] nodes()
