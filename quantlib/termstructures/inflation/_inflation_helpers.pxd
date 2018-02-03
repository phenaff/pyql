"""
 Copyright (C) 2018, Enthought Inc
 Copyright (C) 2018, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from quantlib.termstructures.inflation_term_structure import YoYInflationTermStructure


include '../../types.pxi'
from libcpp cimport bool

from quantlib.handle cimport Handle
from quantlib._quote cimport Quote
from quantlib.time._calendar cimport BusinessDayConvention, Calendar
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Period, Frequency
from quantlib.termstructures.yields._flat_forward cimport YieldTermStructure
from quantlib.time._schedule cimport Rule

from quantlib.termstructures._default_term_structure cimport \
                                            DefaultProbabilityTermStructure
from quantlib.termstructures._helpers cimport BootstrapHelper, \
                                            RelativeDateBootstrapHelper

cdef extern from 'ql/termstructures/credit/inflationhelpers.hpp' namespace 'QuantLib':

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
    		shared_ptr[ZeroInflationIndex]& zii) except +

    	void setTermStructure(ZeroInflationTermStructure& iTS) except +
    	Real impliedQuote() 

    cdef cppclass YoYInflationSwapHelper(YoYInflationHelper):
    	YoYInflationSwapHelper(
    		Handle[Quote]& quote,
    		Period& swapObsLag,
    		Date& maturity,
    		Calendar& calendar,
    		int paymentConvention,
    		DayCounter& DayCounter,
    		shared_ptr[YoYInflationIndex]& zii) except +

    	void setTermStructure(YoYInflationTermStructure& iTS) except +
    	Real impliedQuote() 
