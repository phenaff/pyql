"""
 Copyright (C) 2018, Enthought Inc
 Copyright (C) 2018, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from libcpp cimport bool

from quantlib.handle cimport shared_ptr
from _instrument cimport Instrument
from quantlib.time._calendar cimport BusinessDayConvention
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._schedule cimport Schedule
from quantlib.time._period cimport Period
from libcpp cimport bool
from quantlib.instruments._swap cimport Swap

from quantlib.indexes._ibor_index cimport IborIndex
from quantlib.indexes._inflation_index cimport ZeroInflationIndex

cdef extern from 'ql/instruments/cpiswap.hpp' namespace 'QuantLib::CPISwap':

    ctypedef enum Type:
        Receiver
        Payer

cdef extern from 'ql/cashflows/cpicoupon.hpp' namespace 'QuantLib::CPI':
    ctypedef enum InterpolationType:
            AsIndex,   # same interpolation as index
            Flat,      # flat from previous fixing
            Linear     # linearly between bracketing fixings

cdef extern from 'ql/instruments/cpiswap.hpp' namespace 'QuantLib::CPISwap':

    ctypedef enum Type:
        Receiver
        Payer
    

cdef extern from 'ql/instruments/cpiswap.hpp' namespace 'Quantlib':
    cdef cppclass CPISwap(Swap):
    
        CPISwap(Type type,
                Real nominal,
                bool subtractInflationNominal,
                # float+spread leg
                Spread spread,
                DayCounter& floatDayCount,
                Schedule& floatSchedule,
                BusinessDayConvention& floatRoll,
                Natural fixingDays,
                shared_ptr[IborIndex] floatIndex,
                # fixed x inflation leg
                Rate fixedRate,
                Real baseCPI,
                DayCounter& fixedDayCount,
                Schedule& fixedSchedule,
                BusinessDayConvention& fixedRoll,
                Period& observationLag,
                shared_ptr[ZeroInflationIndex] fixedIndex,
                InterpolationType observationInterpolation,
                Real inflationNominal)

        Real floatLegNPV()
        Spread fairSpread()

