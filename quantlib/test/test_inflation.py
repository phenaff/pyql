"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from .unittest_tools import unittest
from quantlib.settings import Settings

from quantlib.indexes.inflation_index import AUCPI, UKRPI
from quantlib.time.api import (Monthly, Months, Period, Date,
                               January, August, UnitedKingdom)

from quantlib.time.businessdayconvention import ModifiedFollowing
from quantlib.time.schedule import Schedule
from quantlib.termstructures.inflation_term_structure import inflation_period


def makeHelpers(inflation_index_data, inflation_index, observation_lag,
                calendar, business_day_convention, day_counter):

    instruments = []

    for maturity, rate in inflation_index_data:
        quote = SimpleQuote(rate/100.0)

        helper = ZeroCouponInflationSwapHelper(rate, observation_lag,
                                               maturity, calendar,
                                               business_day_convention,
                                               day_counter,
                                               inflation_index)
        instruments.append(helper)
    return instruments


class InflationIndexTestCase(unittest.TestCase):

    def test_zero_index(self):

        aucpi = AUCPI(Monthly, True, True)

        self.assertEqual(aucpi.name, "Australia CPI")

        self.assertEqual(aucpi.frequency, Monthly)

        self.assertEqual(aucpi.availabilityLag, Period(2, Months))

    def test_inflation_period(self):

        evaluation_date = Date(13, August, 2007)
        evaluation_date = UnitedKingdom().adjust(evaluation_date)

        settings = Settings()
        settings.evaluation_date = evaluation_date

        from_date = Date(1, January, 2005)
        to_date = Date(13, August, 2007)
        rpi_schedule = Schedule(from_date, to_date, Period(1, Months),
            UnitedKingdom(), ModifiedFollowing)

        fix_data = [189.9, 189.9, 189.6, 190.5, 191.6, 192.0,
            192.2, 192.2, 192.6, 193.1, 193.3, 193.6,
            194.1, 193.4, 194.2, 195.0, 196.5, 197.7,
            198.5, 198.5, 199.2, 200.1, 200.4, 201.1,
            202.7, 201.6, 203.1, 204.4, 205.4, 206.2,
            207.3, 206.1]

        iir = UKRPI(False)
        for dt, fix in zip(rpi_schedule, fix_data):
            iir.add_fixing(dt, fix)

        today_minus_lag = evaluation_date - iir.availabilityLag

        lim = inflation_period(today_minus_lag, iir.frequency)
        today_minus_lag = lim[0]

        eps = 1.e-6
        for i in range(rpi_schedule.size()):
            lim = inflation_period(rpi_schedule[i], iir.frequency)
            d = lim[0]
            while d <= lim[1]:
                if(d < inflation_period(today_minus_lag, iir.frequency)[0]):
                    self.assertLess(abs(iir.fixing(d)-fix_data[i]), eps)
                d += 1

    def test_zero_term_structure(self):

    # try the Zero UK
    calendar = UnitedKingdom()
    bdc = ModifiedFollowing
    evaluation_date = Date(13, August, 2007)
    evaluation_date = calendar.adjust(evaluation_date)
    Settings.instance().evaluation_date = evaluation_date

    # fixing data
    from_date = Date(1, January, 2005)
    to_date = Date(13, August, 2007)
    rpi_schedule = MakeSchedule(from_date,
        to_date,
        Period(1, Months),
        calendar,
        bdc)

    fixData = [189.9, 189.9, 189.6, 190.5, 191.6, 192.0,
        192.2, 192.2, 192.6, 193.1, 193.3, 193.6,
        194.1, 193.4, 194.2, 195.0, 196.5, 197.7,
        198.5, 198.5, 199.2, 200.1, 200.4, 201.1,
        202.7, 201.6, 203.1, 204.4, 205.4, 206.2,
        207.3]

    hz = ZeroInflationTermStructure()
    interp = False
    inflation_index_UKRPI = UKRPI(interp, hz)
    for dt, fix in zip(rpi_schedule, fix_data):
        inflation_index_UKRPI.add_fixing(dt, fix)

    inflation_index = ZeroInflationIndex(inflation_index_UKRPI)
    nominal_TS = nominalTermStructure()

    # now build the zero inflation curve
    zcData = [[ Date(13, August, 2008), 2.93 ],
        [ Date(13, August, 2009), 2.95 ],
        [ Date(13, August, 2010), 2.965 ],
        [ Date(15, August, 2011), 2.98 ],
        [ Date(13, August, 2012), 3.0 ],
        [ Date(13, August, 2014), 3.06 ],
        [ Date(13, August, 2017), 3.175 ],
        [ Date(13, August, 2019), 3.243 ],
        [ Date(15, August, 2022), 3.293 ],
        [ Date(14, August, 2027), 3.338 ],
        [ Date(13, August, 2032), 3.348 ],
        [ Date(15, August, 2037), 3.348 ],
        [ Date(13, August, 2047), 3.308 ],
        { Date(13, August, 2057), 3.228 ]]

    observation_lag = Period(2,Months)
    day_counter = Thirty360()
    frequency = Monthly

    helpers = makeHelpers(inflation_index_data, inflation_index, 
        observation_lag,
        calendar, business_day_convention, day_counter)

    
    base_zero_rate = zcData[0][1]/100.0
    zero_inflation_curve = PiecewiseZeroInflationCurve(Linear, 
                        evaluation_date, calendar, day_counter, observation_lag,
                        frequency, inflation_index.interpolated, base_zero_rate,
                        nominal_TS, helpers)
    
    zero_inflation_TS.recalculate()

    # first check that the zero rates on the curve match the data
    # and that the helpers give the correct impled rates
    
    eps = 0.00000001
    force_linear_interpolation = False
    
    # test interpolation from curve at node points

    for maturity, rate in zcData:
        interpolated_rate = zero_inflation_TS.zeroRate(maturity, 
            observation_lag, force_linear_interpolation)
        self.assertLess(abs(rate/100.0 - interpolated_rate), eps)
                
    for zc, helper in zip(zcData, helpers):
        rate_zc = zc[1]/100.0
        rate_helper = helper.impliedQuote
        self.assertEqual(rate_zc, rate_helper)

if __name__ == '__main__':
    unittest.main()
