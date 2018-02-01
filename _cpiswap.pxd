"""
 Copyright (C) 2018, Enthought Inc
 Copyright (C) 2018, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

cdef extern from 'ql/instruments/cpiswap.hpp' namespace 'QuantLib::CPISwap':

    ctypedef enum Type:
        Receiver
        Payer

cdef extern from 'ql/instruments/cpiswap.hpp' namespace 'Quantlib':
    cdef cppclass CPISwap(Swap):
    
        CPISwap(Type type,
                Real nominal,
                bool subtractInflationNominal,
                // float+spread leg
                Spread spread,
                DayCounter& floatDayCount,
                Schedule& floatSchedule,
                BusinessDayConvention& floatRoll,
                Natural fixingDays,
                const boost::shared_ptr<IborIndex>& floatIndex,
                // fixed x inflation leg
                Rate fixedRate,
                Real baseCPI,
                DayCounter& fixedDayCount,
                Schedule& fixedSchedule,
                BusinessDayConvention& fixedRoll,
                Period& observationLag,
                shared_ptr[ZeroInflationIndex] fixedIndex,
                CPI::InterpolationType observationInterpolation = CPI::AsIndex,
                Real inflationNominal = Null<Real>())


