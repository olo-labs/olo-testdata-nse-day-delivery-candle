# NSE OHLC and delivery data FAQ

Answers to common questions about finding, downloading, interpreting, and using
the NSE India daily OHLC and security delivery CSV dataset in this repository.

## Dataset discovery

### What is this repository?

It is a date-partitioned archive of NSE India end-of-day security data. Normal
files contain daily open, high, low, close, previous close, last price, average
price, total traded quantity, turnover, number of trades, deliverable quantity,
and delivery percentage.

### Where are the NSE historical CSV files?

They are in `Day_Delivery/NSE`. Files follow this pattern:

```text
Day_Delivery/NSE/delivery_DD-MMM-YYYY.csv
```

For example, `delivery_31-Jul-2026.csv` represents the report requested for
31 July 2026.

### What period does the NSE delivery dataset cover?

The archive begins on 30 September 2019 and is updated as reports become
available. Discover the current final date from filenames rather than relying on
a hard-coded date in an application.

### What keywords describe this dataset?

NSE India historical data, daily OHLC CSV, NSE bhavcopy, security deliverable
data, delivery percentage, deliverable quantity, stock market volume, Indian
equity dataset, end-of-day price data, pandas finance dataset, and backtesting
test data all describe aspects of the archive.

## OHLC and price questions

### Which columns form the daily OHLC candle?

```text
open  = OPEN_PRICE
high  = HIGH_PRICE
low   = LOW_PRICE
close = CLOSE_PRICE
```

`LAST_PRICE` is the last traded price and can differ from the official
`CLOSE_PRICE`. `PREV_CLOSE` is the previous applicable session's close, while
`AVG_PRICE` is the average traded price reported in the source.

### Is this intraday or end-of-day data?

It is end-of-day/daily data. It does not contain tick, one-minute, five-minute,
hourly, bid/ask, or order-book records.

### Are NSE prices adjusted for corporate actions?

No adjustment factor is provided. Treat OHLC prices as raw exchange-reported
values. Splits, bonuses, dividends, rights issues, symbol changes, and other
events can create discontinuities.

### Are all rows ordinary equities?

No. `SERIES` distinguishes exchange series and files may include more than
regular `EQ` rows. Filter `SERIES == "EQ"` when an analysis specifically requires
the regular equity series.

## Delivery and volume questions

### What is delivery quantity in NSE data?

`DELIV_QTY` is the quantity the source report marks as deliverable for that
security and session. It differs from `TTL_TRD_QNTY`, the total traded quantity.

### What is delivery percentage?

`DELIV_PER` is the exchange-reported percentage of traded quantity marked as
deliverable. As a quality check, it should approximately satisfy:

```text
DELIV_PER = 100 * DELIV_QTY / TTL_TRD_QNTY
```

Rounding, missing fields, zero volume, or instrument rules may affect this
relationship.

### What does TURNOVER_LACS mean?

`TURNOVER_LACS` is traded value expressed in lakh rupees for INR-denominated
instruments. One lakh is 100,000. Confirm the instrument's quotation convention
before normalizing values.

## Download and update questions

### How do I download all files?

```bash
git clone https://github.com/olo-labs/olo-testdata-nse-day-delivery-candle.git
```

A normal `git pull` retrieves files added in later automated commits.

### How do I download only recently missing data?

On Windows, execute `delivery_data_downloader.bat`. For a bounded range:

```powershell
.\download_delivery_data.ps1 -StartDate '2026-08-01' -EndDate '2026-08-31'
```

Existing files are skipped. New responses must pass header and date checks.

### How often is the repository updated?

GitHub Actions checks several times after the Indian market session and once the
following morning. A commit is created only when a new CSV is downloaded.

### Why is a date missing?

It may be a weekend, NSE holiday, unpublished report, download failure, or known
data-quality gap. Special sessions can also occur on weekends. Compare against an
authoritative trading calendar rather than assuming Monday through Friday alone.

## Loading and analysis questions

### How do I read these CSV files in pandas?

Use `skipinitialspace=True` because source formatting includes spaces after
commas:

```python
import pandas as pd

df = pd.read_csv(
    "Day_Delivery/NSE/delivery_31-Jul-2026.csv",
    skipinitialspace=True,
    parse_dates=["DATE1"],
)
```

See the [usage recipes](USAGE.md) for more examples.

### What is the unique key?

Use `(DATE1, SYMBOL, SERIES)`. A symbol by itself is not a stable issuer ID and
can be renamed or reused over a long history.

### Can AI agents and data catalogues understand the repository?

The repository provides `llms.txt`, Schema.org Dataset JSON-LD, CSVW-style
column metadata, a data dictionary, an FAQ, and citation metadata. Systems vary
in which formats they consume, so these assets improve machine readability but
cannot guarantee indexing or ranking.

### Can I use this for trading decisions or production backtests?

The dataset is provided without warranty and is not investment advice. Production
research should validate source files and account for adjustments, symbol
history, delistings, survivorship bias, costs, liquidity, holidays, and timing.

## Rights, attribution, and contributions

### Is the market data covered by the Apache 2.0 license?

The repository's original code and documentation are Apache-2.0 licensed. That
does not grant ownership of or additional rights to underlying NSE market data.
Review current NSE/NSE Data policies for your intended use and redistribution.

### How should I cite the project?

GitHub can read `CITATION.cff` and expose a citation action. Record the repository
URL, access date, and exact Git commit hash for reproducibility.

### How can I report bad data?

Open an issue with the commit hash, filename, affected symbol and series,
expected and actual values, validation command, and authoritative reference. See
the [data-quality guide](DATA_QUALITY.md) and [contribution guide](../CONTRIBUTING.md).
