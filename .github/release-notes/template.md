# NSE India Daily OHLC, Bhavcopy and Delivery Data {{VERSION}}

Released on **{{DATE}}** from repository commit `{{SHORT_COMMIT}}`.

## Initial dataset package

This release provides a packaged archive of NSE India daily OHLC, full
bhavcopy, trading-volume, trade-count, and security-delivery data in CSV format.

## Dataset summary

- **CSV files:** {{CSV_FILE_COUNT}}
- **Uncompressed CSV size:** {{CSV_TOTAL_SIZE_MB}} MB
- **First archive file:** `{{OLDEST_CSV_FILE}}`
- **Latest archive file:** `{{NEWEST_CSV_FILE}}`
- **Archive:** `{{ARCHIVE_NAME}}`
- **Source commit:** `{{COMMIT}}`

## Included data

Each normal daily CSV includes:

- Previous close
- Open, high, low, last and official close prices
- Average traded price
- Total traded quantity
- Turnover in lakh rupees
- Number of trades
- Deliverable quantity
- Delivery percentage

## Package contents

The release contains:

- The complete `Day_Delivery` directory
- Versioned ZIP archive
- SHA-256 checksum
- Release notes
- Project license

The ZIP also contains `RELEASE_NOTES.md` and `LICENSE` inside its top-level
`Day_Delivery` directory.

## Intended uses

The dataset is intended for:

- Quantitative research
- Backtesting inputs
- Data-engineering experiments
- Delivery-percentage analysis
- Pandas and DuckDB analytics
- Machine-learning experiments
- ETL and data-quality testing

## Important data notes

The price data consists of raw exchange-reported values. It is not adjusted for
stock splits, dividends, bonus issues, rights issues or other corporate actions.

Not every calendar date is expected to have a file. Weekends, exchange holidays,
unavailable reports and exceptional trading sessions should be handled using a
verified trading calendar.

Users should validate the schema, dates, uniqueness and numerical values before
using the files in research or production systems.

## License and data rights

The repository's original software and documentation are licensed under the
Apache License 2.0.

The project license does not imply ownership of, or grant additional rights to,
the underlying NSE market data. Users are responsible for reviewing applicable
NSE data-sharing policies and terms before using or redistributing the data,
particularly for commercial purposes.

## Disclaimer

This is an independent community project. It is not affiliated with, endorsed
by, or operated by the National Stock Exchange of India.

The dataset is supplied without warranty and is not investment advice.