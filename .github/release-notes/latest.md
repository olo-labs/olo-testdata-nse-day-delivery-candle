# Latest NSE India Daily OHLC, Bhavcopy and Delivery Data

Updated on **{{DATE}}** at **{{TIME}} UTC**.

This rolling release contains the latest available archive of NSE India daily
OHLC, full bhavcopy, trading-volume, trade-count, and security-delivery data.

## Latest update

- **New delivery files added:** {{NEW_FILE_COUNT}}
- **Latest source commit:** `{{SHORT_COMMIT}}`
- **Complete archive:** `{{ARCHIVE_NAME}}`
- **Total CSV files:** {{TOTAL_FILE_COUNT}}
- **Uncompressed CSV size:** {{TOTAL_SIZE_MB}} MB

### Files added in this update

{{NEW_FILES}}

## Dataset contents

Each normal daily CSV contains:

- Previous close
- Open, high, low, last and official closing prices
- Average traded price
- Total traded quantity
- Turnover in lakh rupees
- Number of trades
- Deliverable quantity
- Delivery percentage

## Package contents

This release includes:

- `{{ARCHIVE_NAME}}`
- `{{ARCHIVE_NAME}}.sha256`
- `RELEASE_NOTES.md`
- `LICENSE`

The ZIP contains the complete `Day_Delivery` directory together with the release
notes and license.

## Rolling release behavior

This release is replaced whenever one or more new NSE delivery files are
successfully downloaded, validated, committed and published.

The rolling release tag is:

```text
nse-delivery-latest