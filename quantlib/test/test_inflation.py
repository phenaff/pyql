"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
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


if __name__ == '__main__':
    unittest.main()
