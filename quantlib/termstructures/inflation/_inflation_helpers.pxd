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
from quantlib._quote cimport Quote
from quantlib.time._calendar cimport BusinessDayConvention, Calendar
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Period

cimport quantlib.indexes._inflation_index as _ii

from quantlib.termstructures._default_term_structure cimport \
                                            DefaultProbabilityTermStructure
from quantlib.termstructures._helpers cimport BootstrapHelper, \
                                            RelativeDateBootstrapHelper

from quantlib.termstructures._inflation_term_structure cimport (
    YoYInflationTermStructure, ZeroInflationTermStructure)


cdef extern from 'ql/termstructures/inflation/inflationhelpers.hpp' namespace 'QuantLib':

    ctypedef BootstrapHelper[ZeroInflationTermStructure] \
                                        ZeroCouponInflationHelper
    ctypedef BootstrapHelper[YoYInflationTermStructure] \
                                        YoYInflationHelper
                                        
    cdef cppclass ZeroCouponInflationSwapHelper(ZeroCouponInflationHelper):
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

    cdef cppclass YearOnYearInflationSwapHelper(YoYInflationHelper):
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
