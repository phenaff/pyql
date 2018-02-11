"""
 Copyright (C) 2018, Enthought Inc
 Copyright (C) 2018, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

cimport _swap
cimport _cpiswap
cimport _instrument

cimport quantlib.indexes._ibor_index as _ib
cimport quantlib.indexes._inflation_index as _ii
cimport quantlib.time._businessdayconvention as _bc

from cython.operator cimport dereference as deref
from libcpp cimport bool

from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.time.schedule cimport Schedule
from quantlib.time.daycounter cimport DayCounter
from quantlib.time._businessdayconvention cimport ModifiedFollowing, BusinessDayConvention
from quantlib.time._calendar cimport BusinessDayConvention
from quantlib.time.date cimport Period
from quantlib.indexes.ibor_index cimport IborIndex
from quantlib.indexes.inflation_index cimport ZeroInflationIndex
from quantlib.cashflow cimport Leg

cpdef public enum CPISwapType:
    Payer    = _cpiswap.Payer
    Receiver = _cpiswap.Receiver
    
cpdef public enum InterpolationType:
    AsIndex = _cpiswap.AsIndex
    Flat    = _cpiswap.Flat
    Linear  = _cpiswap.Linear

cdef inline _cpiswap.CPISwap* get_cpiswap(CPISwap swap):
    """ Utility function to extract a properly casted CPISwap pointer out of the
    internal _thisptr attribute of the Instrument base class. """

    cdef _cpiswap.CPISwap* ref = \
         <_cpiswap.CPISwap*>swap._thisptr.get()
    return ref

cdef class CPISwap(Swap):
    """
    CPI swap class
    """
    
    def __init__(self, CPISwapType type,
                Real nominal,
                bool subtract_inflation_nominal,
                Spread spread,
                DayCounter float_daycount,
                Schedule float_schedule,
                BusinessDayConvention float_roll,
                Natural fixing_days,
                IborIndex float_index,
                Rate fixed_rate,
                Real base_CPI,
                DayCounter fixed_daycount,
                Schedule fixed_schedule,
                BusinessDayConvention fixed_roll,
                Period observation_lag,
                ZeroInflationIndex fixed_index,
                InterpolationType observation_interpolation,
                Real inflation_nominal):
    
        self._thisptr = new shared_ptr[_instrument.Instrument](
            new _cpiswap.CPISwap(
                <_cpiswap.Type>type,
                nominal,
                subtract_inflation_nominal,
                spread,
                deref(float_daycount._thisptr),
                deref(float_schedule._thisptr),
                float_roll,
                fixing_days,
                static_pointer_cast[_ib.IborIndex](float_index._thisptr),
                fixed_rate,
                base_CPI,
                deref(fixed_daycount._thisptr),
                deref(fixed_schedule._thisptr),
                fixed_roll,
                deref(observation_lag._thisptr),
                static_pointer_cast[_ii.ZeroInflationIndex](\
                    fixed_index._thisptr),
                observation_interpolation,
                inflation_nominal
            )
        )
    
                
    @property 
    def float_leg_npv(self):
       cdef Real res = get_cpiswap(self).floatLegNPV()
       return res
    
    @property 
    def fair_spread(self):
        cdef Real res = get_cpiswap(self).fairSpread()
        return res

    @property 
    def cpi_leg(self):
        cdef Leg leg = Leg.__new__(Leg)
        leg._thisptr = get_cpiswap(self).cpiLeg()
        return leg

