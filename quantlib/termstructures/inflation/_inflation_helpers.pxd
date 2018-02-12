"""
 Copyright (C) 2018, Enthought Inc
 Copyright (C) 2018, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'
from libcpp cimport bool

from quantlib.handle cimport Handle, shared_ptr

cimport quantlib.indexes._inflation_index as _ii
cimport quantlib.termstructures.inflation._inflation_helpers as _ih

from quantlib._quote cimport Quote
from quantlib.time._calendar cimport BusinessDayConvention, Calendar
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Period
from quantlib.termstructures._helpers cimport BootstrapHelper

from quantlib.termstructures._inflation_term_structure cimport (
    YoYInflationTermStructure, ZeroInflationTermStructure)


cdef extern from 'ql/termstructures/inflation/inflationhelpers.hpp' namespace 'QuantLib':
                                        
    cdef cppclass ZeroCouponInflationSwapHelper(BootstrapHelper[ZeroInflationTermStructure]):
        ZeroCouponInflationSwapHelper(
            Handle[Quote]& quote,
            Period& swapObsLag,
            Date& maturity,
            Calendar& calendar,
            int paymentConvention,
            DayCounter& DayCounter,
            shared_ptr[_ii.ZeroInflationIndex]& zii) except +

        void setTermStructure(ZeroInflationTermStructure*) except +
        Real impliedQuote() 

    cdef cppclass YearOnYearInflationSwapHelper:
        YearOnYearInflationSwapHelper(
            Handle[Quote]& quote,
            Period& swapObsLag,
            Date& maturity,
            Calendar& calendar,
            int paymentConvention,
            DayCounter& DayCounter,
            shared_ptr[_ii.YoYInflationIndex]& zii) except +

        void setTermStructure(YoYInflationTermStructure*) except +
        Real impliedQuote() 
