#!/bin/sh
# shell date arithmetic

secs()
{
    TZ=UTC date --date="$1" '+%s'
}

date_diff()
{
    expr \( `secs "$1"` - `secs "$2"` \) / 86400
}

days_from_today()
{
    date_diff $1 ""
}

date_plus_days()
{
    date --iso-8601 --date="$1 + $2 days"
}

today_plus_days()
{
    date_plus_days "" $1
}
