# NSE India Daily OHLC, Bhavcopy and Delivery Data (CSV)

A searchable, community-friendly archive of **NSE India daily OHLC data**,
**full bhavcopy**, trading volume, and **security deliverable data** in plain CSV
files. It provides one place to download historical National Stock Exchange of
India price candles and delivery statistics for stocks and other reported
security series.

The repository is designed for research, education, reproducible examples,
backtesting inputs, and data-engineering experiments. Each file represents one
market date and contains one row per security/series reported by NSE.

> [!IMPORTANT]
> This is an independent community project. It is not affiliated with, endorsed
> by, or operated by the National Stock Exchange of India. The files are
> historical market data, not investment advice. Review [Data rights and
> licensing](#data-rights-and-licensing) before using or redistributing them.

## What is included

- Daily open, high, low, close, last-traded, previous-close, and average prices
- Total traded quantity, turnover, and number of trades
- Deliverable quantity and delivery percentage
- Separate CSV files for each available date
- Data beginning on **30 September 2019**
- An automated downloader for keeping recent dates current
- A scheduled GitHub Actions workflow that commits only newly downloaded files

The archive currently lives under [`Day_Delivery/NSE`](Day_Delivery/NSE). The
latest available date changes as the scheduled downloader adds files, so clients
should discover files dynamically instead of relying on a date written in this
README.

**Common search terms:** NSE historical data CSV, NSE daily bhavcopy download,
NSE stock OHLC dataset, NSE delivery percentage history, Indian stock market
dataset, NSE end-of-day data, NSE volume and deliverable quantity, and NSE equity
data for Python, pandas, DuckDB, machine learning, or backtesting.

## Documentation index

| Resource | What it answers |
| --- | --- |
| [Data dictionary](docs/DATA_DICTIONARY.md) | What every OHLC, volume, trade, and delivery column means |
| [Usage recipes](docs/USAGE.md) | How to load NSE CSV data with Python, pandas, PowerShell, and DuckDB |
| [Data quality](docs/DATA_QUALITY.md) | How to validate dates, schemas, values, and malformed files |
| [Frequently asked questions](docs/FAQ.md) | Quick answers phrased for human and AI search |
| [Discoverability guide](docs/DISCOVERABILITY.md) | GitHub topics, metadata, landing-page, and indexing recommendations |
| [Dataset metadata](metadata/dataset.jsonld) | Schema.org `Dataset` metadata for machines and catalogues |
| [CSVW schema](metadata/csvw.json) | Machine-readable definitions for all 15 CSV columns |
| [LLM index](llms.txt) | Concise repository map for AI assistants and retrieval systems |
| [Citation metadata](CITATION.cff) | How research and tools can cite this repository |

## Quick start

Clone the repository:

```bash
git clone https://github.com/olo-labs/olo-testdata-nse-day-delivery-candle.git
cd olo-testdata-nse-day-delivery-candle
```

Load one date with Python and pandas:

```python
import pandas as pd

path = "Day_Delivery/NSE/delivery_31-Jul-2026.csv"
day = pd.read_csv(path, skipinitialspace=True, parse_dates=["DATE1"])

equities = day.loc[day["SERIES"].eq("EQ")]
print(equities[["SYMBOL", "DATE1", "OPEN_PRICE", "HIGH_PRICE",
                "LOW_PRICE", "CLOSE_PRICE", "DELIV_PER"]].head())
```

Load the complete archive:

```python
from pathlib import Path
import pandas as pd

files = sorted(Path("Day_Delivery/NSE").glob("delivery_*.csv"))
frames = []

for path in files:
    try:
        frame = pd.read_csv(path, skipinitialspace=True)
    except (UnicodeDecodeError, pd.errors.ParserError):
        print(f"Skipping unreadable file: {path}")
        continue

    required = {"SYMBOL", "SERIES", "DATE1", "OPEN_PRICE", "HIGH_PRICE",
                "LOW_PRICE", "CLOSE_PRICE", "DELIV_QTY", "DELIV_PER"}
    if required.issubset(frame.columns):
        frames.append(frame)

data = pd.concat(frames, ignore_index=True)
data["DATE1"] = pd.to_datetime(data["DATE1"], format="%d-%b-%Y")
data = data.sort_values(["SYMBOL", "SERIES", "DATE1"])
```

The defensive checks in this example are intentional. See
[`docs/DATA_QUALITY.md`](docs/DATA_QUALITY.md) for known limitations.

## Repository layout

```text
.
|-- .github/
|   `-- workflows/
|       `-- download-delivery-data.yml  # Scheduled download and commit job
|-- Day_Delivery/
|   `-- NSE/
|       |-- delivery_30-Sep-2019.csv
|       |-- delivery_01-Oct-2019.csv
|       `-- delivery_DD-MMM-YYYY.csv     # One file per available date
|-- docs/
|   |-- DATA_DICTIONARY.md               # Column-by-column schema
|   |-- DATA_QUALITY.md                  # Validation and known limitations
|   |-- DISCOVERABILITY.md               # Search and AI discovery guidance
|   |-- FAQ.md                           # Common human and AI search questions
|   `-- USAGE.md                         # Loading and analysis recipes
|-- metadata/
|   |-- csvw.json                        # Machine-readable CSV column schema
|   `-- dataset.jsonld                   # Schema.org Dataset metadata
|-- CITATION.cff                         # Research citation metadata
|-- CONTRIBUTING.md                      # How to propose improvements
|-- delivery_data_downloader.bat         # Windows entry point
|-- download_delivery_data.ps1           # Downloader implementation
|-- LICENSE                              # Apache 2.0 for project code/docs
|-- llms.txt                             # Compact AI/retrieval documentation map
`-- README.md
```

## File naming and organization

Files use this convention:

```text
Day_Delivery/NSE/delivery_DD-MMM-YYYY.csv
```

For example, `delivery_31-Jul-2026.csv` contains the report requested for
31 July 2026. Month names use English three-letter abbreviations. The date is
also present in every data row as `DATE1`; consumers should validate that field
instead of trusting only the filename.

Not every calendar date is expected to have a file. Weekends, exchange holidays,
and dates for which NSE has not published the report can be absent. Special
weekend trading sessions can exist, so do not infer the trading calendar solely
from the day of week.

## CSV structure

Each normal CSV contains 15 columns:

| Column | Meaning | Typical type |
| --- | --- | --- |
| `SYMBOL` | NSE trading symbol/security identifier | string |
| `SERIES` | NSE market series, such as `EQ` | string |
| `DATE1` | Trading date in `dd-MMM-yyyy` format | date |
| `PREV_CLOSE` | Previous reported closing price | decimal |
| `OPEN_PRICE` | First traded price for the session | decimal |
| `HIGH_PRICE` | Highest traded price for the session | decimal |
| `LOW_PRICE` | Lowest traded price for the session | decimal |
| `LAST_PRICE` | Last traded price reported for the session | decimal |
| `CLOSE_PRICE` | Official closing price | decimal |
| `AVG_PRICE` | Average traded price reported by NSE | decimal |
| `TTL_TRD_QNTY` | Total traded quantity | integer |
| `TURNOVER_LACS` | Traded value expressed in lakh rupees | decimal |
| `NO_OF_TRADES` | Number of trades | integer |
| `DELIV_QTY` | Quantity marked as deliverable | integer/nullable |
| `DELIV_PER` | Deliverable quantity as a percentage of traded quantity | decimal/nullable |

See [`docs/DATA_DICTIONARY.md`](docs/DATA_DICTIONARY.md) for units, keys,
relationships, parsing guidance, and caveats.

### Example record

```csv
SYMBOL, SERIES, DATE1, PREV_CLOSE, OPEN_PRICE, HIGH_PRICE, LOW_PRICE, LAST_PRICE, CLOSE_PRICE, AVG_PRICE, TTL_TRD_QNTY, TURNOVER_LACS, NO_OF_TRADES, DELIV_QTY, DELIV_PER
20MICRONS, EQ, 31-Jul-2026, 200.07, 200.00, 212.52, 191.10, 191.50, 192.46, 201.27, 808418, 1627.09, 17755, 164091, 20.30
```

Spaces after delimiters are part of the source formatting. Use
`skipinitialspace=True` in pandas or trim column names and string values in other
CSV readers.

## What “daily candle” means here

For a given `(SYMBOL, SERIES, DATE1)` tuple:

- `OPEN_PRICE`, `HIGH_PRICE`, `LOW_PRICE`, and `CLOSE_PRICE` form the daily OHLC
  candle.
- `PREV_CLOSE` is useful for overnight gap and daily-return calculations.
- `LAST_PRICE` can differ from the official `CLOSE_PRICE`.
- `TTL_TRD_QNTY` describes exchange-reported traded volume.
- `DELIV_QTY` and `DELIV_PER` add delivery context to the price/volume candle.

Prices should be treated as exchange-reported raw values. This repository does
not provide split-, bonus-, dividend-, or rights-adjusted OHLC series. Symbols
and series can change over time, and the same symbol is not a permanent issuer
identifier.

## Dataset metadata summary

| Property | Value |
| --- | --- |
| Dataset name | NSE India Daily OHLC, Bhavcopy and Delivery Data |
| Geography | India |
| Exchange | National Stock Exchange of India (NSE) |
| Frequency | Daily/end of day |
| Temporal coverage | 30 September 2019 onward, subject to available reports |
| File format | CSV |
| Granularity | One row per trading date, symbol, and series |
| Price fields | Previous close, open, high, low, last, close, average |
| Activity fields | Traded quantity, turnover in lakhs, number of trades |
| Delivery fields | Deliverable quantity and delivery percentage |
| Source report | NSE “Full Bhavcopy and Security Deliverable data” |
| Update method | Scheduled GitHub Actions plus manual PowerShell downloader |

Machine-readable versions of this information are available in
[`metadata/dataset.jsonld`](metadata/dataset.jsonld) and
[`metadata/csvw.json`](metadata/csvw.json).

## Updating the data locally

On Windows, run:

```bat
delivery_data_downloader.bat
```

Or invoke PowerShell directly:

```powershell
.\download_delivery_data.ps1
```

Override the configured date range when needed:

```powershell
.\download_delivery_data.ps1 -StartDate '2026-08-01' -EndDate '2026-08-31'
```

The downloader:

1. Uses `Day_Delivery/NSE` relative to the script directory by default.
2. Checks weekdays from the configured start date through the current date.
3. Skips files that already exist.
4. Downloads to a temporary file.
5. Verifies the CSV header and its internal trading date.
6. Moves only validated files into the dataset directory.

The default start date is defined in `download_delivery_data.ps1`. Older files
already in the archive are not re-downloaded by the normal scheduled run.

## Automated updates

The workflow in
[`download-delivery-data.yml`](.github/workflows/download-delivery-data.yml)
runs at these times each day in Indian Standard Time:

```text
07:00, 16:00, 16:30, 17:00, 17:30, 18:00, 19:00, 20:00, 22:00 IST
```

It can also be started manually from the GitHub Actions page. The workflow:

- runs on a Windows GitHub-hosted runner;
- prevents overlapping download jobs;
- stages only CSV files under `Day_Delivery/NSE`;
- creates a commit only if a newly downloaded CSV is present; and
- pushes the commit to the repository's default branch.

GitHub scheduled jobs are best-effort and may start later than the exact cron
minute. Repository or organization settings must allow GitHub Actions to write
repository contents.

## Common uses

- Daily price and delivery-volume research
- Liquidity and delivery-percentage screening
- Reproducible examples for data-processing libraries
- Backtest fixture generation
- ETL and data-quality pipeline testing
- Cross-sectional studies by symbol and series

This archive alone is not enough for production-grade backtesting. A robust
system should additionally model corporate actions, delistings, symbol changes,
survivorship bias, market holidays, transaction costs, and point-in-time index
membership.

## Data quality and reproducibility

Consumers should check at least the following:

- file content is text CSV rather than HTML, ZIP, or another response format;
- the header contains the expected 15 columns;
- all `DATE1` values agree with the filename date;
- `(SYMBOL, SERIES, DATE1)` rows are unique;
- `LOW_PRICE <= OPEN_PRICE/LAST_PRICE/CLOSE_PRICE <= HIGH_PRICE` where applicable;
- quantities and trade counts are non-negative; and
- `DELIV_PER` is in the range 0–100 when present.

Known issues and copy-pasteable validation examples are maintained in
[`docs/DATA_QUALITY.md`](docs/DATA_QUALITY.md). Please report newly discovered
problems with the filename, expected behavior, actual behavior, and a minimal
reproduction.

## Data rights and licensing

The repository's original software and documentation are licensed under the
[Apache License 2.0](LICENSE). That license does **not** imply ownership of, or
grant additional rights to, underlying NSE market data.

NSE/NSE Data may impose separate conditions on accessing, using, processing, or
redistributing market data. Before using this dataset—especially commercially or
for redistribution—review the current:

- [NSE Data Sharing & Usage Policy](https://www.nseindia.com/static/market-data/nse-data-policy)
- [NSE Terms of Use](https://www.nseindia.com/static/nse-terms-of-use)
- [NSE All Reports page](https://www.nseindia.com/all-reports)

Each user is responsible for determining whether their intended use is permitted.
Maintainers and contributors provide this repository without warranty and do not
guarantee completeness, accuracy, timeliness, or fitness for trading.

## Contributing

Contributions are welcome: documentation corrections, reproducible data-quality
reports, downloader improvements, validation tools, and examples are especially
useful. Read [`CONTRIBUTING.md`](CONTRIBUTING.md) before opening a pull request.

Please keep changes focused. Do not add credentials, personal data, generated
logs, unrelated binaries, or files from sources whose redistribution terms are
unclear.

## Support

Use GitHub Issues for reproducible bugs and data-quality reports. For questions
about exchange data definitions, availability, or permitted use, consult NSE's
official documentation directly.

## Frequently asked questions

### Where can I download free NSE daily OHLC and delivery data as CSV?

Clone this repository and read the files under `Day_Delivery/NSE`. Each filename
contains its report date and each row contains the NSE symbol, series, OHLC
prices, volume, trades, deliverable quantity, and delivery percentage.

### Does this dataset include NSE bhavcopy and delivery percentage history?

Yes. The files are based on NSE's “Full Bhavcopy and Security Deliverable data”
report and combine price, trading, and security-level delivery fields. Coverage
starts on 30 September 2019, with caveats documented in the data-quality guide.

### Is the OHLC data adjusted for splits, dividends, and bonus issues?

No. Values should be treated as raw exchange-reported prices. Join a verified
corporate-action source before calculating a continuous adjusted price series.

### Can I use the repository for machine learning or backtesting?

It is useful for research inputs and test fixtures, but a serious pipeline must
also handle corporate actions, symbol changes, delistings, survivorship bias,
holidays, transaction costs, and point-in-time membership. Validate every file
before use. More answers are in [`docs/FAQ.md`](docs/FAQ.md).
