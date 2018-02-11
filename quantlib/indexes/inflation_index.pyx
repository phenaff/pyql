"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from quantlib.indexes.inflation_index import ZeroInflationIndex
from quantlib.currency.currencies import GBPCurrency

include '../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport Handle, shared_ptr, static_pointer_cast

from libcpp cimport bool
from libcpp.string cimport string

cimport quantlib._index as _in
cimport quantlib.indexes._inflation_index as _ii
cimport quantlib.termstructures._inflation_term_structure as _its
cimport quantlib._interest_rate as _ir
cimport quantlib.time._period as _pe
from quantlib.time._period cimport Frequency, Months

from quantlib.time.frequency cimport Monthly
from quantlib.index cimport Index
from quantlib.time.date cimport Period, period_from_qlperiod
from quantlib.indexes.region cimport Region
from quantlib.currency.currency cimport Currency
from quantlib.termstructures.inflation_term_structure cimport \
    ZeroInflationTermStructure, YoYInflationTermStructure


from quantlib.currency.api import AUDCurrency, GBPCurrency
from quantlib.indexes.regions import AustraliaRegion, UKRegion

cimport quantlib.currency._currency as _cu
from quantlib.currency.currency cimport Currency

cdef class InflationIndex(Index):

    def __cinit__(self):
        pass

    property family_name:
        def __get__(self):
            cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
            return ref.familyName()

    property frequency:
        def __get__(self):
            cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
            return ref.frequency()

    property availabilityLag:
        def __get__(self):
            cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
            return period_from_qlperiod(ref.availabilityLag())


    property currency:
        def __get__(self):
            cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
            cdef _cu.Currency c = ref.currency()
            return Currency.from_name(c.code())

    property interpolated:
        def __get__(self):
            cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
            cdef bool interpolated = ref.interpolated()
            return interpolated            

    property revised:
        def __get__(self):
            cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
            cdef bool revised = ref.revised()
            return revised            

cdef class ZeroInflationIndex(InflationIndex):
    def __init__(self, str family_name,
                 Region region,
                 bool revised,
                 bool interpolated,
                 Frequency frequency,
                 Period availabilityLag,
                 Currency currency,
                 ZeroInflationTermStructure ts=None):
        
        
        cdef Handle[_its.ZeroInflationTermStructure] ts_handle
        if ts is None:
            ts_handle = Handle[_its.ZeroInflationTermStructure]()
        else:   
            ts_handle = Handle[_its.ZeroInflationTermStructure](
            static_pointer_cast[_its.ZeroInflationTermStructure](ts._thisptr))
        

        # convert the Python str to C++ string
        cdef string c_family_name = family_name.encode('utf-8')

        self._thisptr = shared_ptr[_in.Index](
            new _ii.ZeroInflationIndex(
                c_family_name,
                deref(region._thisptr),
                revised,
                interpolated,
                <_ir.Frequency> frequency,
                deref(availabilityLag._thisptr.get()),
                deref(currency._thisptr),
                ts_handle))

cdef class YoYInflationIndex(InflationIndex):
    def __init__(self, str family_name,
                 Region region,
                 bool revised,
                 bool interpolated,
                 bool ratio,
                 Frequency frequency,
                 Period availabilityLag,
                 Currency currency,
                 YoYInflationTermStructure ts=None):

        cdef Handle[_its.YoYInflationTermStructure] ts_handle
        if ts is None:
            ts_handle = Handle[_its.YoYInflationTermStructure]()
        else:
            ts_handle = Handle[_its.YoYInflationTermStructure](
            static_pointer_cast[_its.YoYInflationTermStructure](ts._thisptr))
        
        # convert the Python str to C++ string
        cdef string c_family_name = family_name.encode('utf-8')

        self._thisptr = shared_ptr[_in.Index](
            new _ii.YoYInflationIndex(
                c_family_name,
                deref(region._thisptr),
                revised,
                interpolated,
                ratio,
                <_ir.Frequency> frequency,
                deref(availabilityLag._thisptr.get()),
                deref(currency._thisptr),
                ts_handle))


cdef class AUCPI(ZeroInflationIndex):
    def __init__(self, Frequency frequency,
                 bool revised,
                 interpolated,
                 ZeroInflationTermStructure ts=None):
        
        super().__init__("CPI", AustraliaRegion(), revised,
                         interpolated, frequency, Period(2, Months),
                         AUDCurrency(), ts)
        
cdef class UKRPI(ZeroInflationIndex):
    """
    UK Retail Price Inflation Index
    """
    def __init__(self, bool interpolated,
                 ZeroInflationTermStructure ts=None):
        
        super().__init__("RPI", UKRegion(), False, interpolated,
                         Monthly, Period(1, Months),
                         GBPCurrency(), ts)
        
cdef class YYUKRPI(YoYInflationIndex):
    """
    Genuine year-on-year UK RPI (i.e. not a ratio of UK RPI)
    """
    def __init__(self, bool interpolated,
                 YoYInflationTermStructure ts=None):
        
        super().__init__("YY_RPI", UKRegion(), False, interpolated,
                         False, Monthly, Period(1, Months),
                         GBPCurrency(), ts)
        

        
