from .unittest_tools import unittest

from quantlib.currency.api import USDCurrency
from quantlib.instruments.cpiswap import CPISwap, Payer, Receiver
from quantlib.indexes.libor import Libor
from quantlib.market.market import libor_market
from quantlib.pricingengines.swap import DiscountingSwapEngine
from quantlib.settings import Settings
from quantlib.termstructures.yields.api import (
    FlatForward, YieldTermStructure
)
from quantlib.time.api import (
    Unadjusted, ModifiedFollowing, Date, Days,
    November, December, February, March, May, September, June,
    Period,
    Annual, Years, Months, Actual365Fixed, Thirty360, TARGET, Actual360,
    Schedule, Forward, UnitedKingdom
)
from quantlib.util.converter import pydate_to_qldate
from quantlib.quotes import SimpleQuote
from quantlib.currency.currencies import GBPCurrency
from quantlib.termstructures.yield_term_structure import YieldTermStructure


class TestQuantLibCPISwap(unittest.TestCase):

    def setup(selfself):

        # UK RPI index fixing data
                evaluation_date = Date(13, August, 2007)
        evaluation_date = UnitedKingdom().adjust(evaluation_date)

        settings = Settings()
        settings.evaluation_date = evaluation_date

        from_date = Date(20, July, 2007)
        to_date = Date(20, November, 2009)
        rpi_schedule = Schedule(from_date, to_date, Period(1, Months),
            UnitedKingdom(), ModifiedFollowing)

        fix_data = [206.1, 207.3, 208.0, 208.9, 209.7, 210.9,
                209.8, 211.4, 212.1, 214.0, 215.1, 216.8,
                216.5, 217.2, 218.4, 217.7, 216,
                212.9, 210.1, 211.4, 211.3, 211.5,
                212.8, 213.4, 213.4, 213.4, 214.4,
                -999.0, -999.0]

        ii = UKRPI(False)
        for dt, fix in zip(rpi_schedule, fix_data):
            ii.add_fixing(dt, fix, True)

        # nominal term structure

        nominalData = [[Date(26, November, 2009), 0.475 ],
                [ Date(2, December, 2009), 0.47498 ],
                [ Date(29, December, 2009), 0.49988 ],
                [ Date(25, February, 2010), 0.59955 ],
                [ Date(18, March, 2010), 0.65361 ],
                [ Date(25, May, 2010), 0.82830 ],
                #  [ Date(17, June, 2010), 0.7 ],  // can't boostrap with this data point
                [ Date(16, September, 2010), 0.78960 ],
                [ Date(16, December, 2010), 0.93762 ],
                [ Date(17, March, 2011), 1.12037 ],
                [ Date(16, June, 2011), 1.31308 ],
                [ Date(22, September, 2011),1.52011 ],
                [ Date(25, November, 2011), 1.78399 ],
                [ Date(26, November, 2012), 2.41170 ],
                [ Date(25, November, 2013), 2.83935 ],
                [ Date(25, November, 2014), 3.12888 ],
                [ Date(25, November, 2015), 3.34298 ],
                [ Date(25, November, 2016), 3.50632 ],
                [ Date(27, November, 2017), 3.63666 ],
                [ Date(26, November, 2018), 3.74723 ],
                [ Date(25, November, 2019), 3.83988 ],
                [ Date(25, November, 2021), 4.00508 ],
                [ Date(25, November, 2024), 4.16042 ],
                [ Date(26, November, 2029), 4.15577 ],
                [ Date(27, November, 2034), 4.04933 ],
                [ Date(25, November, 2039), 3.95217 ],
                [ Date(25, November, 2049), 3.80932 ],
                [ Date(25, November, 2059), 3.80849 ],
                [ Date(25, November, 2069), 3.72677 ],
                [ Date(27, November, 2079), 3.63082 ]]

            nomD = [x[0] for x in nominalData]
            nomR = [x[1] for x in nominalData]

            nominalTS = YieldTermStructure(relinkable=True)
            nominalTS.link_to(ZeroCurve(nomD, nomR, dcNominal))

            nominalTS.linkTo(nominal)

    def test_cpiswap_consistency(self):
        """
        Translated from QL inflationcpiswap.cpp
        Check inflation leg vs calculation directly from inflation TS
        """

        type = Payer
        nominal = 1000000.0
        subtractInflationNominal = True
        # float+spread leg
        spread = 0.0
        floatDayCount = Actual365Fixed()
        floatPaymentConvention = ModifiedFollowing
        fixingDays = 0
        float_index = Libor('GBP Libor', Period(6, Months),
                            settlement_days, GBPCurrency(),
                            TARGET(), Actual360(), termStructure)

    # fixed x inflation leg
    fixedRate = 0.1     # 105
    baseCPI = 206.1     # would be 206.13871 if we were interpolating
    fixedDayCount = Actual365Fixed()
    fixedPaymentConvention = ModifiedFollowing
    paymentCalendar = UnitedKingdom()
   
    # link from cpi index to cpi TS
    interp = False      # this MUST be false because the observation lag is only 2 months
                    # for ZCIIS; but not for contract if the contract uses a bigger lag.
     ii = UKRPI(interp, hcpi)
for (Size i=0; i<rpiSchedule.size();i++) {
    ii->addFixing(rpiSchedule[i], fixData[i], true);// force overwrite in case multiple use
};

    fixedIndex = common.ii;
    
    contractObservationLag = common.contractObservationLag;
    observationInterpolation = common.contractObservationInterpolation;

    # set the schedules
    startDate = Date(2, October, 2007)
    endDate = Date(2, October, 2052)
    floatSchedule = Schedule(startDate,
                             endDate,
                             Period(6,Months),
                             paymentCalendar,
                             floatPaymentConvention,
                             floatPaymentConvention,
                             Backward, False)
    
    fixedSchedule = Schedule(startDate,
                             endDate,
                             Period(6,Months),
                             paymentCalendar,
                             Unadjusted,
                             Unadjusted,
                             Backward, False)
    


    zisV = CPISwap(type, nominal, subtractInflationNominal,
                 spread, floatDayCount, floatSchedule,
                 floatPaymentConvention, fixingDays, floatIndex,
                 fixedRate, baseCPI, fixedDayCount, fixedSchedule,
                 fixedPaymentConvention, contractObservationLag,
                 fixedIndex, observationInterpolation)
    
    asofDate = settings.evaluation_date
    
    floatFix = [0.06255,0.05975,0.0637,0.018425,0.0073438,-1,-1]
    cpiFix = [211.4,217.2,211.4,213.4,-2,-2]
    
    for float_F, cpi_F in zip(floatFix, cpiFix):
        if (floatSchedule[i] < common.evaluationDate): 
            floatIndex.add_fixing(floatSchedule[i], float_F,True) #//true=overwrite

        """
                boost::shared_ptr<CPICoupon>
        zic = boost::dynamic_pointer_cast<CPICoupon>(zisV.cpiLeg()[i]);
        if (zic) {
            if (zic->fixingDate() < (common.evaluationDate - Period(1,Months))) {
                fixedIndex->addFixing(zic->fixingDate(), cpiFix[i],true);
            }
        }
        """
        zic = zisV.cpiLeg()[i]
        if zic:
            if (zic.fixing_date < (common.evaluationDate - Period(1,Months))): 
                fixedIndex.add_fixing(zic.fixing_date, cpi_Fix,True)

    # simple structure so simple pricing engine - most work done by index
    engine = DiscountingSwapEngine(termStructure, False, settlement_date,
                                   settlement_date)
    
    zisV.setPricingEngine(engine)

    # get float+spread & fixed*inflation leg prices separately
    testInfLegNPV = 0.0
    for inf_coupon, cpi_coupon in zip(zisV.float_leg, zisV.cpi_leg):
        zicPayDate = inf_coupon.date
        if zicPayDate > asofDate:
            testInfLegNPV += inf_coupon.amount * discount(zicPayDate)
        

        diff = fabs( zicV.rate - (fixedRate*(zicV.index_fixing/baseCPI)) )
        self.assertAlmostEqual(diff, 0.0, tol)
    

    error = fabs(testInfLegNPV - zisV.leg_NPV)
    self.assertAlmostEqual(testInfLegNPV, zisV.leg_NPV, delta=1.e-6)

    diff = fabs(1-zisV.NPV/4191660.0)
    #ifndef QL_USE_INDEXED_COUPON
    max_diff = 1e-5
    #else
    max_diff = 3e-5
    #endif
    self.assertAlmostEqual(diff, 0.0, delta=max_diff)

    // remove circular refernce
    common.hcpi.linkTo(boost::shared_ptr<ZeroInflationTermStructure>());
}


if __name__ == '__main__':
    unittest.main()
