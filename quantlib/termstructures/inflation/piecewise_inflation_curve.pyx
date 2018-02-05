include '../../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr

from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.string cimport string

cimport _piecewise_inflation_curve as _pic

from quantlib.time.date cimport Date, date_from_qldate
cimport quantlib.time._date as _date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.calendar cimport Calendar
cimport quantlib.termstructures.credit._credit_helpers as _ch
from default_probability_helpers cimport CdsHelper
cimport quantlib.termstructures._default_term_structure as _dts
from quantlib.termstructures.default_term_structure cimport DefaultProbabilityTermStructure

cdef class PiecewiseZeroInflationCurve(InflationTermStructure):

	def __init__(self, Interpolator interpolator,
               Calendar calendar,
               DayCounter day_counter,
               Period lag,
               Frequency frequency,
               bool indexIsInterpolated,
               Rate baseZeroRate,
               ZeroInflationTermStructure ts=None,
               list helpers,
               Real accuracy = 1.0e-12):


		# convert Python list to std::vector
        cdef vector[shared_ptr[_ih.ZeroCouponInflationHelper]] instruments

        for helper in helpers:
            instruments.push_back(
                <shared_ptr[_ih.ZeroCouponInflationHelper]>\
                deref((<ZeroCouponInflationSwapHelper?>helper)._thisptr)
            )

        self._trait = None
        self._interpolator = interpolator

        cdef Handle[_its.ZeroInflationTermStructure] ts_handle
        if ts is None:
            ts_handle = Handle[_its.ZeroInflationTermStructure]()
        else:
            ts_handle = deref(<Handle[_its.ZeroInflationTermStructure]*>ts._thisptr.get())


		if interpolator == Linear:
            self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                new _pic.PiecewiseZeroInflationCurve[_pic.Linear](
                    deref(calendar._thisptr),
                    deref(day_counter._thisptr),
                     deref(lag._thisptr.get()),
                     <_ir.Frequency>frequency,
                     index_is_interpolated,
                     base_zero_rate,
                     ts_handle,
                     instruments)

        elif interpolator == LogLinear:
            self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                new _pic.PiecewiseZeroInflationCurve[_pic.LogLinear](
                    deref(calendar._thisptr),
                    deref(day_counter._thisptr),
                     deref(lag._thisptr.get()),
                     <_ir.Frequency>frequency,
                     index_is_interpolated,
                     base_zero_rate,
                     ts_handle,
                     instruments)
