# from quantlib.instruments.cpiswap import CPISwap, Payer, Receiver
from quantlib.currency.api import USDCurrency
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


frequency = Annual
volatility = 0.01
length = 7
calendar = UnitedKingdom()
convention = ModifiedFollowing
today = Date(25, November, 2009)
evaluationDate = calendar.adjust(today)
settings = Settings()
settings.evaluationDate = evaluationDate
settlementDays = 0
fixingDays = 0
settlement = calendar.advance(today, settlementDays, Days)
startDate = settlement
daycount_ZCIIS = ActualActual()
dcNominal = ActualActual()

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

inflation_index = UKRPI(False)
for dt, fix in zip(rpi_schedule, fix_data):
    inflation_index.add_fixing(dt, fix, True)

nominalData = [[Date(26, November, 2009), 0.475],
        [Date(2, December, 2009), 0.47498],
        [Date(29, December, 2009), 0.49988],
        [Date(25, February, 2010), 0.59955],
        [Date(18, March, 2010), 0.65361],
        [Date(25, May, 2010), 0.82830],
        #  [Date(17, June, 2010), 0.7],  // can't boostrap with this data point
        [Date(16, September, 2010), 0.78960],
        [Date(16, December, 2010), 0.93762],
        [Date(17, March, 2011), 1.12037],
        [Date(16, June, 2011), 1.31308],
        [Date(22, September, 2011), 1.52011],
        [Date(25, November, 2011), 1.78399],
        [Date(26, November, 2012), 2.41170],
        [Date(25, November, 2013), 2.83935],
        [Date(25, November, 2014), 3.12888],
        [Date(25, November, 2015), 3.34298],
        [Date(25, November, 2016), 3.50632],
        [Date(27, November, 2017), 3.63666],
        [Date(26, November, 2018), 3.74723],
        [Date(25, November, 2019), 3.83988],
        [Date(25, November, 2021), 4.00508],
        [Date(25, November, 2024), 4.16042],
        [Date(26, November, 2029), 4.15577],
        [Date(27, November, 2034), 4.04933],
        [Date(25, November, 2039), 3.95217],
        [Date(25, November, 2049), 3.80932],
        [Date(25, November, 2059), 3.80849],
        [Date(25, November, 2069), 3.72677],
        [Date(27, November, 2079), 3.63082]]

nomD = [x[0] for x in nominalData]
nomR = [x[1] / 100. for x in nominalData]

dcNominal = Actual360()
nominal_TS = YieldTermStructure(relinkable=True)

# ZeroCurve is InterpolatedZeroCurve<Linear>
nominal = ZeroCurve(nomD, nomR, dcNominal)
nominal_TS.link_to(nominal)

r = nominalTS.zero_rate(Date(10, 5, 2017), Actual360(), 2)
print r

observation_lag = Period(2, Months)
contract_observation_lag = Period(3, Months)
contract_observation_interpolation = Flat

zciisData = [[Date(25, November, 2010), 3.0495],
    [Date(25, November, 2011), 2.93],
    [Date(26, November, 2012), 2.9795],
    [Date(25, November, 2013), 3.029],
    [Date(25, November, 2014), 3.1425],
    [Date(25, November, 2015), 3.211],
    [Date(25, November, 2016), 3.2675],
    [Date(25, November, 2017), 3.3625],
    [Date(25, November, 2018), 3.405],
    [Date(25, November, 2019), 3.48],
    [Date(25, November, 2021), 3.576],
    [Date(25, November, 2024), 3.649],
    [Date(26, November, 2029), 3.751],
    [Date(27, November, 2034), 3.77225],
    [Date(25, November, 2039), 3.77],
    [Date(25, November, 2049), 3.734],
    [Date(25, November, 2059), 3.714]]

zciisD = [x[0] for x in zciisData]
zciisR = [x[1] for x in zciisData]

# now build the helpers ...

helpers = []

for i in range(len(zciisR)):
    maturity_date = zciisD[i]
    rate = SimpleQuote(zciisR[i]/100.0)

    h = ZeroCouponInflationSwapHelper(rate,
        observationLag, calendar, convention, dcZCIIS, ii) 
    helpers.append(h)
    

# we can use historical or first ZCIIS for this
# we know historical is WAY off market-implied, so use market implied flat.

baseZeroRate = zciisR[0]/100.0

CPI_zero_curve = PiecewiseZeroInflationCurve(Linear,
    evaluationDate, calendar, daycount_ZCIIS, observation_lag,
                        inflation_index.frequency,
                        inflation_index.interpolated, baseZeroRate,
                        nominal_TS, helpers)

CPI_zero_curve.recalculate();

// cpiTS = boost::dynamic_pointer_cast<ZeroInflationTermStructure>(pCPIts);


// make sure that the index has the latest zero inflation term structure
hcpi.linkTo(pCPIts);

type = Payer
nominal = 1000000.0
subtractInflationNominal = True
    # float+spread leg
spread = 0.0
float_daycount = Actual365Fixed()
float_payment_convention = ModifiedFollowing
fixing_days = 0
float_index = Libor('GBP Libor', Period(6,Months),
                    settlement_days, GBPCurrency(),
                    TARGET(), Actual360(), nominalTS)
    
# fixed x inflation leg
fixed_rate = 0.1     # 105
base_CPI = 206.1     # would be 206.13871 if we were interpolating
fixed_daycount = Actual365Fixed()
fixed_payment_convention = ModifiedFollowing
payment_calendar = UnitedKingdom()

fixed_index = UKRPI(False, common.ii;
contract_observation_lag = common.contractObservationLag;
observationInterpolation = common.contractObservationInterpolation;

    # set swap schedules
start_date = Date(2, October, 2007)
end_date = Date(2, October, 2052)
floatSchedule = Schedule(start_date,
                         end_date,
                         Period(6,Months),
                         payment_calendar,
                         float_payment_convention,
                         float_payment_convention,
                         Backward, False)

fixedSchedule = Schedule(start_date,
                         end_date,
                         Period(6,Months),
                         payment_calendar,
                         Unadjusted,
                         Unadjusted,
                         Backward, False)



zi_swap = CPISwap(type, nominal, subtractInflationNominal,
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
        floatIndex.add_fixing(floatSchedule[i], float_F,True)
         # true=overwrite

        zi_coupon = zi_swap.cpiLeg[i]
        if (zic is not None):
            if (zic.fixing_date < (evaluation_date - Period(1,Months))):
                fixed_index.add_fixing(zic.fixing_date, cpiFix[i], True);

# simple structure so simple pricing engine - most work done by index
engine = DiscountingSwapEngine(termStructure, False, settlement_date,
                               settlement_date)

zi_swap.setPricingEngine(engine)

# get float+spread & fixed*inflation leg prices separately
InfLegNPV = 0.0

for inf_coupon, cpi_coupon in zip(zi_swap.float_leg, zi_swap.cpi_leg):
    zi_swap_pay_date = inf_coupon.date
    if zi_swap_pay_date > as_of_date:
        InfLegNPV += inf_coupon.amount * discount(zi_swap_pay_date)
    

    diff = fabs( zi_swap.rate - (fixed_rate*(zi_swap.index_fixing/baseCPI)) )
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
