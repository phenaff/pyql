include '../../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, Handle

from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.string cimport string

cimport _piecewise_inflation_curve as _pic
cimport quantlib.termstructures.inflation._inflation_helpers as _ih
cimport quantlib.termstructures._inflation_term_structure as _its
cimport quantlib._interest_rate as _ir
cimport quantlib.termstructures._yield_term_structure as _yts

from quantlib.time.date cimport Date, Period, date_from_qldate
cimport quantlib.time._date as _date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time._period cimport Frequency
from quantlib.time.calendar cimport Calendar
from quantlib.termstructures.inflation_term_structure cimport \
    ZeroInflationTermStructure
from quantlib.termstructures.inflation.inflation_helpers cimport \
    ZeroCouponInflationSwapHelper 



cdef class PiecewiseZeroInflationCurve(InflationTermStructure):

    def __init__(self):
      pass

    def __init__(self, Interpolator interpolator,
               Date evaluation_date,
               Calendar calendar,
               DayCounter day_counter,
               Period lag,
               Frequency frequency,
               bool index_is_interpolated,
               Rate base_zero_rate,
               ZeroInflationTermStructure ts,
               list helpers,
               Real accuracy = 1.0e-12):

        # convert Python list to std::vector
        cdef vector[shared_ptr[_pic.ZeroInflationHelper]] instruments

        for helper in helpers:
            instruments.push_back(
                <shared_ptr[_pic.ZeroInflationHelper]>\
                deref((<ZeroCouponInflationSwapHelper?>helper)._thisptr)
            )

        self._trait = None
        self._interpolator = interpolator

        cdef Handle[_yts.YieldTermStructure] ts_handle = \
            deref(<Handle[_yts.YieldTermStructure]*> ts._thisptr)

        
        if interpolator == Linear:
            self._thisptr = shared_ptr[_its.InflationTermStructure](
                new _pic.PiecewiseZeroInflationCurve[_pic.Linear](
                    deref(evaluation_date._thisptr),
                    deref(calendar._thisptr),
                    deref(day_counter._thisptr),
                     deref(lag._thisptr.get()),
                     <_ir.Frequency>frequency,
                     index_is_interpolated,
                     base_zero_rate,
                     ts_handle,
                     instruments,
                     accuracy))

        elif interpolator == LogLinear:
            self._thisptr = shared_ptr[_its.InflationTermStructure](
                new _pic.PiecewiseZeroInflationCurve[_pic.LogLinear](
                    deref(evaluation_date._thisptr),
                    deref(calendar._thisptr),
                    deref(day_counter._thisptr),
                     deref(lag._thisptr.get()),
                     <_ir.Frequency>frequency,
                     index_is_interpolated,
                     base_zero_rate,
                     ts_handle,
                     instruments,
                     accuracy))
