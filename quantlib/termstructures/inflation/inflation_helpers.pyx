"""
 Copyright (C) 2018, Enthought Inc
 Copyright (C) 2018, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'
from libcpp cimport bool

from quantlib.handle cimport shared_ptr, Handle, static_pointer_cast
from cython.operator cimport dereference as deref

cimport quantlib._quote as _qt
cimport quantlib.indexes._inflation_index as _ii
cimport quantlib.termstructures._helpers as _he
cimport quantlib.time._calendar as _cal
cimport _inflation_helpers as _ih
cimport quantlib.termstructures._inflation_term_structure as _its

from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Period, Date
from quantlib.time.calendar cimport Calendar
from quantlib.indexes.inflation_index cimport (ZeroInflationIndex,
    YoYInflationIndex)
from quantlib.quotes cimport Quote

from quantlib.termstructures.inflation_term_structure cimport (
    YoYInflationTermStructure, ZeroInflationTermStructure)


cdef class ZeroCouponInflationSwapHelper:

    def __init__(self, Quote quote,
            Period swapObsLag,
            Date maturity,
            Calendar calendar,
            int paymentConvention,
            DayCounter DayCounter,
            ZeroInflationIndex zii):

        cdef Handle[_qt.Quote] quote_handle = \
            Handle[_qt.Quote](deref(quote._thisptr))

        self._thisptr = new shared_ptr[_ih.ZeroCouponInflationSwapHelper](
            new _ih.ZeroCouponInflationSwapHelper(quote_handle,
            deref(swapObsLag._thisptr),
            deref(maturity._thisptr.get()),
            deref(calendar._thisptr),
            <_cal.BusinessDayConvention> paymentConvention,
            deref(DayCounter._thisptr),
            static_pointer_cast[_ii.ZeroInflationIndex](zii._thisptr)
            ))

    def set_term_structure(self, ZeroInflationTermStructure zits):
        cdef _its.InflationTermStructure* _iTS = zits._thisptr.get()
        self._thisptr.get().setTermStructure(\
            <_its.ZeroInflationTermStructure*>_iTS)
        
# cdef class YearOnYearInflationSwapHelper:

#     def __init__(self, Quote quote,
#             Period swapObsLag,
#             Date maturity,
#             Calendar calendar,
#             int paymentConvention,
#             DayCounter DayCounter,
#             YoYInflationIndex zii):

#         cdef Handle[_qt.Quote] quote_handle = \
#             Handle[_qt.Quote](deref(quote._thisptr))

        
#         self._thisptr = new shared_ptr[_ih.YearOnYearInflationSwapHelper](
#             new _ih.YearOnYearInflationSwapHelper(quote_handle,
#             deref(swapObsLag._thisptr),
#             deref(maturity._thisptr.get()),
#             deref(calendar._thisptr),
#             <_cal.BusinessDayConvention> paymentConvention,
#             deref(DayCounter._thisptr),
#             static_pointer_cast[_ii.YoYInflationIndex](zii._thisptr)
#             ))

#     def set_term_structure(self, ZeroInflationTermStructure zits):
#         cdef _its.InflationTermStructure* _iTS = zits._thisptr.get()
#         self._thisptr.get().setTermStructure(
#             <_its.YoYInflationTermStructure*>_iTS)

