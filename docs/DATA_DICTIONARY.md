# Data dictionary

This document describes the daily security-level files in
`Day_Delivery/NSE`. The repository preserves NSE's source-oriented column names
so existing market-data tooling can consume the files with minimal mapping.

## Dataset grain and key

The intended grain is one row per:

```text
(DATE1, SYMBOL, SERIES)
```

Use all three fields as the logical key. `SYMBOL` alone is not sufficient because
a security can appear in different market series, and symbols can be renamed or
reused over a long history.

Each file should normally contain one trading date. The filename date and every
row's `DATE1` should agree.

## Columns

### Identity and date

| Column | Logical type | Format/example | Description |
| --- | --- | --- | --- |
| `SYMBOL` | string | `20MICRONS` | Exchange trading symbol. Preserve as text and do not treat it as a permanent company identifier. |
| `SERIES` | string | `EQ`, `BE`, `GS` | NSE security/market series. Filter explicitly when an analysis requires only regular equity-series instruments. Do not assume every row is an ordinary equity. |
| `DATE1` | date | `31-Jul-2026` | Exchange report/trading date using English month abbreviations and format `dd-MMM-yyyy`. No time zone or time-of-day is stored. |

### Price fields

| Column | Logical type | Unit | Description |
| --- | --- | --- | --- |
| `PREV_CLOSE` | decimal | quoted currency | Closing price carried from the previous applicable trading session. |
| `OPEN_PRICE` | decimal | quoted currency | First traded price reported for the session. |
| `HIGH_PRICE` | decimal | quoted currency | Highest traded price reported for the session. |
| `LOW_PRICE` | decimal | quoted currency | Lowest traded price reported for the session. |
| `LAST_PRICE` | decimal | quoted currency | Last traded price. It is not necessarily the official closing price. |
| `CLOSE_PRICE` | decimal | quoted currency | Official session closing price reported by NSE. |
| `AVG_PRICE` | decimal | quoted currency | Session average traded price reported by NSE. |

For INR-denominated securities, quoted price fields are ordinarily interpreted
as rupees. The file can contain multiple instrument/series types; consumers
should verify instrument-specific price conventions before combining them.

The canonical daily candle is:

```text
open  = OPEN_PRICE
high  = HIGH_PRICE
low   = LOW_PRICE
close = CLOSE_PRICE
```

Do not substitute `LAST_PRICE` for `CLOSE_PRICE` unless that behavior is
deliberate and documented in your analysis.

### Trading and delivery fields

| Column | Logical type | Unit | Description |
| --- | --- | --- | --- |
| `TTL_TRD_QNTY` | integer | units/shares | Total quantity traded during the session. |
| `TURNOVER_LACS` | decimal | lakh rupees | Total traded value expressed in lakhs. One lakh is 100,000. Multiply by `100000` to obtain rupees when the instrument is INR-denominated. |
| `NO_OF_TRADES` | integer | trades | Number of executed trades reported for the session. |
| `DELIV_QTY` | nullable integer | units/shares | Quantity reported as deliverable. Availability can depend on the series/instrument. |
| `DELIV_PER` | nullable decimal | percent | Deliverable quantity as a percentage of total traded quantity. Expected range is 0–100 when populated. |

The approximate relationship is:

```text
DELIV_PER ~= 100 * DELIV_QTY / TTL_TRD_QNTY
```

Rounding, missing values, zero volume, and exchange-specific rules can prevent an
exact equality. Treat NSE's reported percentage as authoritative for the row and
use the relationship as a quality check, not as a replacement value.

## Recommended in-memory types

| Field group | pandas | SQL example | Notes |
| --- | --- | --- | --- |
| `SYMBOL`, `SERIES` | `string` | `VARCHAR` | Preserve case and leading zeros if any. |
| `DATE1` | `datetime64[ns]` | `DATE` | Parse with `%d-%b-%Y` and an English locale. |
| Price fields | `float64` or decimal extension | `DECIMAL(20,6)` | Decimal is preferable when exact arithmetic matters. |
| `TTL_TRD_QNTY`, `NO_OF_TRADES`, `DELIV_QTY` | nullable `Int64` | `BIGINT NULL` | Use a nullable integer for blank delivery values. |
| `TURNOVER_LACS`, `DELIV_PER` | `float64` or decimal extension | `DECIMAL(24,6)` | Keep the original unit unless deliberately normalized. |

The suggested SQL precision is a storage recommendation, not a declaration of
the maximum values guaranteed by NSE.

## CSV parsing details

- Encoding is expected to be ASCII-compatible text for normal files.
- The delimiter is a comma.
- Source files include spaces after commas. Trim headers and string values, or
  enable the CSV reader's “skip initial space” option.
- A header row is present.
- Numeric fields use `.` as the decimal separator and do not use thousands
  separators.
- Missing delivery values should be represented as nulls, not zeros.
- Row order is not a stable API contract; sort explicitly for reproducibility.

## Derived measures

Examples of common derived fields follow. They are not stored in the source CSV.

```text
absolute_change = CLOSE_PRICE - PREV_CLOSE
return_pct       = 100 * (CLOSE_PRICE / PREV_CLOSE - 1)
intraday_range   = HIGH_PRICE - LOW_PRICE
range_pct        = 100 * (HIGH_PRICE - LOW_PRICE) / PREV_CLOSE
turnover_rupees  = TURNOVER_LACS * 100000
delivery_ratio   = DELIV_QTY / TTL_TRD_QNTY
```

Guard all ratios against null or zero denominators.

## Adjustment and entity caveats

The archive does not include a corporate-action adjustment factor or permanent
security master. Consequently:

- historical OHLC values should be treated as unadjusted;
- splits, bonuses, rights issues, and dividends can create discontinuities;
- symbol changes can split one issuer's history across multiple identifiers;
- symbol reuse can join unrelated histories if keyed only by symbol;
- delisted securities remain in historical files; and
- filtering today's symbols creates survivorship bias.

For research requiring continuous adjusted histories, join this dataset to a
point-in-time security master and corporate-action source.
