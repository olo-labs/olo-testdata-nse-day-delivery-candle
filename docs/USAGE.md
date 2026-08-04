# Usage recipes

These examples favor transparent, reproducible loading over maximum performance.
For repeated full-history analysis, convert validated files into a columnar format
such as Parquet in a separate derived-data directory.

## Python with pandas

### Read one day

```python
import pandas as pd

day = pd.read_csv(
    "Day_Delivery/NSE/delivery_31-Jul-2026.csv",
    skipinitialspace=True,
    parse_dates=["DATE1"],
)

day.columns = day.columns.str.strip()
print(day.dtypes)
```

### Read a date range

```python
from datetime import date
from pathlib import Path
import pandas as pd

start = date(2026, 7, 1)
end = date(2026, 7, 31)
frames = []

for path in Path("Day_Delivery/NSE").glob("delivery_*.csv"):
    filename_date = pd.to_datetime(
        path.stem.removeprefix("delivery_"), format="%d-%b-%Y"
    ).date()
    if not start <= filename_date <= end:
        continue

    frame = pd.read_csv(path, skipinitialspace=True)
    frame.columns = frame.columns.str.strip()
    frames.append(frame)

month = pd.concat(frames, ignore_index=True)
month["DATE1"] = pd.to_datetime(month["DATE1"], format="%d-%b-%Y")
month = month.sort_values(["DATE1", "SYMBOL", "SERIES"])
```

### Build one symbol's OHLC history

```python
symbol = "20MICRONS"

history = (
    month.loc[
        month["SYMBOL"].eq(symbol) & month["SERIES"].eq("EQ"),
        ["DATE1", "OPEN_PRICE", "HIGH_PRICE", "LOW_PRICE", "CLOSE_PRICE",
         "TTL_TRD_QNTY", "DELIV_QTY", "DELIV_PER"],
    ]
    .sort_values("DATE1")
    .set_index("DATE1")
)

history["RETURN_PCT"] = history["CLOSE_PRICE"].pct_change() * 100
print(history.tail())
```

### Find high-delivery sessions

```python
screen = (
    month.loc[
        month["SERIES"].eq("EQ")
        & month["DELIV_PER"].ge(70)
        & month["TTL_TRD_QNTY"].ge(100_000)
    ]
    .sort_values(["DATE1", "DELIV_PER"], ascending=[False, False])
)
```

This is an analytical screen, not a trading recommendation.

## Python standard library

For applications that do not use pandas:

```python
import csv
from decimal import Decimal
from pathlib import Path

path = Path("Day_Delivery/NSE/delivery_31-Jul-2026.csv")

with path.open(newline="", encoding="utf-8-sig") as handle:
    reader = csv.DictReader(handle, skipinitialspace=True)
    for raw in reader:
        row = {key.strip(): value.strip() for key, value in raw.items()}
        close = Decimal(row["CLOSE_PRICE"])
        print(row["SYMBOL"], close)
```

## PowerShell

### Read and filter one day

```powershell
$rows = Import-Csv '.\Day_Delivery\NSE\delivery_31-Jul-2026.csv'

$equities = $rows | Where-Object {
    $_.SERIES.Trim() -eq 'EQ' -and [decimal]$_.DELIV_PER -ge 70
}

$equities | Select-Object SYMBOL, CLOSE_PRICE, TTL_TRD_QNTY, DELIV_PER
```

PowerShell preserves the spaces in source header names/values differently across
versions and operations. Trim text before comparison and inspect
`$rows[0].PSObject.Properties.Name` if a property is not found as expected.

### Run a bounded download

```powershell
.\download_delivery_data.ps1 `
    -StartDate '2026-08-01' `
    -EndDate '2026-08-31'
```

Existing files are skipped. A downloaded response is saved only when its header
and internal date pass validation.

## DuckDB

DuckDB can query many CSV files without first loading them into a database:

```sql
SELECT
    trim(SYMBOL) AS symbol,
    strptime(trim(DATE1), '%d-%b-%Y')::DATE AS trade_date,
    CLOSE_PRICE,
    DELIV_PER
FROM read_csv_auto(
    'Day_Delivery/NSE/delivery_*.csv',
    header = true,
    ignore_errors = true
)
WHERE trim(SERIES) = 'EQ'
ORDER BY trade_date, symbol;
```

`ignore_errors` makes exploration resilient to a malformed historical file, but
it can conceal problems. Run the checks in `DATA_QUALITY.md` before producing a
trusted derived dataset.

## Reproducible research recommendations

1. Record the Git commit hash used for an analysis.
2. Validate input files and retain the validation report.
3. Filter by both `SYMBOL` and `SERIES`.
4. Join to point-in-time security-master and corporate-action data when needed.
5. Store derived data outside `Day_Delivery/NSE`.
6. Document null handling, adjustment rules, and trading-calendar assumptions.
7. Never treat the latest repository state as a frozen research snapshot.

Retrieve the current commit identifier with:

```bash
git rev-parse HEAD
```
