include '../../types.pxi'

from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr
from libcpp.utility cimport pair
from libcpp cimport bool


cimport quantlib.termstructures._inflation_term_structure as _its
cimport quantlib._interest_rate as _ir
cimport quantlib.termstructures.inflation._interpolated_inflation_curve as _iic
cimport quantlib.time._date as _date
cimport quantlib.time._calendar as _calendar

cimport quantlib.math.interpolation as intpl
from quantlib.time.date cimport Date, date_from_qldate, Period
from quantlib.time.frequency cimport Frequency

from quantlib.time.daycounter cimport DayCounter
from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure

from quantlib.time.calendar cimport Calendar

cdef class InterpolatedZeroInflationCurve(ZeroInflationTermStructure):
    """
    """
    def __init__(self, Interpolator interpolator, 
                    Date reference_date,
                    Calendar calendar,
                    DayCounter day_counter,
                    Period lag,
                    Frequency frequency,
                    bool index_is_interpolated,
                    YieldTermStructure yTS,
                    list dates,
                    vector[Rate] rates):

        # convert  list of PyQL dates into a vector of QL dates
        cdef vector[_date.Date] _dates
        for date in dates:
            _dates.push_back(deref((<Date?>date)._thisptr.get()))

        self._trait = interpolator

        if interpolator == Linear:
            self._thisptr = shared_ptr[_its.InflationTermStructure](
                new _iic.InterpolatedZeroInflationCurve[intpl.Linear](
                    deref(reference_date._thisptr.get()),
                    deref(calendar._thisptr),
                    deref(day_counter._thisptr),
                    deref(lag._thisptr),
                    <_ir.Frequency> frequency,
                    index_is_interpolated,
                    yTS._thisptr,
                    _dates,
                    rates))
        elif interpolator == LogLinear:
            self._thisptr = shared_ptr[_its.InflationTermStructure](
                new _iic.InterpolatedZeroInflationCurve[intpl.LogLinear](
                    deref(reference_date._thisptr.get()),
                    deref(calendar._thisptr),
                    deref(day_counter._thisptr),
                    deref(lag._thisptr),
                    <_ir.Frequency> frequency,
                    index_is_interpolated,
                    yTS._thisptr,
                    _dates,
                    rates))
        else:
            raise ValueError("interpolator needs to be any of Linear or LogLinear")

    @property
    def baseDate(self):
        if self._trait == Linear:
            _date = (<_iic.InterpolatedZeroInflationCurve[intpl.Linear]*>
                      self._thisptr.get()).baseDate()
        else:
            _date = (<_iic.InterpolatedZeroInflationCurve[intpl.LogLinear]*>
                       self._thisptr.get()).baseDate()

        qldate = date_from_qldate(_date)
        return qldate

    # TODO: unresolved issue: ambigous overloaded method
    # @property
    # def maxDate(self):
    #     if self._trait == Linear:
    #         _date = (<_iic.InterpolatedZeroInflationCurve[intpl.Linear]*>
    #                   self._thisptr.get()).maxDate()
    #     else:
    #         _date = (<_iic.InterpolatedZeroInflationCurve[intpl.LogLinear]*>
    #                    self._thisptr.get()).maxDate()

    #     qldate = date_from_qldate(_date)
    #     return qldate

    @property
    def nodes(self):
        cdef pair[_date.Date, _date.Date] res
        if self._trait == Linear:
            _date = (<_iic.InterpolatedZeroInflationCurve[intpl.Linear]*>
                      self._thisptr.get()).nodes()
        else:
            _date = (<_iic.InterpolatedZeroInflationCurve[intpl.LogLinear]*>
                       self._thisptr.get()).nodes()

        return [date_from_qldate(res.first), date_from_qldate(res.second)]

    @property
    def dates(self):
        """list of curve dates"""
        cdef vector[_date.Date] _dates
        if self._trait == Linear:
            _dates = (<_iic.InterpolatedZeroInflationCurve[intpl.Linear]*>
                      self._thisptr.get()).dates()
        else:
            _dates = (<_iic.InterpolatedZeroInflationCurve[intpl.LogLinear]*>
                       self._thisptr.get()).dates()

        cdef size_t i
        cdef list r  = []
        for i in range(_dates.size()):
            r.append(date_from_qldate(_dates[i]))
        return r

    @property
    def times(self):
        """list of curve times"""
        if self._trait == Linear:
            return (<_iic.InterpolatedZeroInflationCurve[intpl.Linear]*>
                    self._thisptr.get()).times()
        else:
            return (<_iic.InterpolatedZeroInflationCurve[intpl.LogLinear]*>
                    self._thisptr.get()).times()

    @property
    def data(self):
        """list of curve data"""
        if self._trait == Linear:
            return (<_iic.InterpolatedZeroInflationCurve[intpl.Linear]*>
                    self._thisptr.get()).data()
        else:
            return (<_iic.InterpolatedZeroInflationCurve[intpl.LogLinear]*>
                    self._thisptr.get()).data()

    @property
    def rates(self):
        """list of curve rates"""
        if self._trait == Linear:
            return (<_iic.InterpolatedZeroInflationCurve[intpl.Linear]*>
                self._thisptr.get()).rates()
        else:
            return (<_iic.InterpolatedZeroInflationCurve[intpl.LogLinear]*>
                self._thisptr.get()).rates()
