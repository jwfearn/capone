# Capital One coding challenge

### My Submission

1. [Program source code](https://github.com/jwfearn/capone)
2. To run, install
   [Docker CE](https://www.docker.com/community-edition#/download),
   then, in your shell:
   ```sh
   docker run -it jwfearn/capone
   ```
3. To run tests:
   ```sh
   docker run -it jwfearn/capone xxx
   ```

### Usage
```
mix capone.challenge
```

### Capital One Investing Coding Test Instructions

What We Are Looking For:

We are looking for production quality code with a high level of software
craftsmanship. We value readable code that is tested and easy to modify and
maintain, over code that runs in the fewest CPU cycles possible.

We would like you to write an application that:

Retrieves pricing data from the
[Quandl WIKI Stock Price API](https://urldefense.proofpoint.com/v2/url?u=https-3A__www.quandl.com_databases_WIKIP&d=DwMFaQ&c=pLULRYW__RtkwsQUPxJVDGboCTdgji3AcHNJU0BpTJE&r=kepIekeKnmUGqfnZNVlrPHu_tMertO2EhArFHfiDIJyCJDfLPZ1NCOioFQV4aw8V&m=mzIO7jy1kzeSyRQcKo83WjUorQBbNrSya7V23VCMgHI&s=p14M8WXuZx6nUbTes6sa2vNtRLwTwfdfwXJTWrptxno&e=)
for a given set of securities and date range Displays the Average Monthly Open
and Close prices for each security for each month of data in the data set. The
securities to use are: COF, GOOGL, and MSFT. Perform this analysis for Jan -
June of 2017 Output the data in the below format, or optionally in a prettier
format if you see fit.

```json
{
  "GOOGL": [
    {"month":"2017-01", "average_open": "815.43", "average_close": "$818.34"},
    {"month":"2017-02", "average_open": "825.87", "average_close": "$822.73"},
    {"month":"2017-03", "average_open": "945.24", "average_close": "$951.52"},
    {"month":"2017-04", "average_open": "945.24", "average_close": "$951.52"},
    {"month":"2017-05", "average_open": "945.24", "average_close": "$951.52"},
    {"month":"2017-06", "average_open": "975.37", "average_close": "$977.11"}
  ]
}
```

The documentation of the API can be found
[here](https://urldefense.proofpoint.com/v2/url?u=https-3A__www.quandl.com_databases_WIKIP_documentation_about&d=DwMFaQ&c=pLULRYW__RtkwsQUPxJVDGboCTdgji3AcHNJU0BpTJE&r=kepIekeKnmUGqfnZNVlrPHu_tMertO2EhArFHfiDIJyCJDfLPZ1NCOioFQV4aw8V&m=mzIO7jy1kzeSyRQcKo83WjUorQBbNrSya7V23VCMgHI&s=SD3kCDHwaoez8vcCnY9IdOJhS8FXcEhRXJ-ycLV9myk&e=).
You may use this api_key on your requests: REDACTED

You have considerable latitude on how to display this data, obtain it, and what
language to use. Please do this in the way that feels most comfortable for you.
Many candidates prefer to use a script which is run from the command line.
Others choose a webpage that displays things. For others, it’s a live code
notebook. What’s important is that it is well crafted and reproducible by us.

We’d also like you to try and add at least one “additional feature” to this
program (and if you’re able, all of them). They’re listed below as command line
switches for a terminal program, but we’d accept any method that lets a user
decide how to display this data.

`—max-daily-profit`: We’d like to know which day in our data set would provide
the highest amount of profit for each security if purchased at the day’s low and
sold at the day’s high. Please display the ticker symbol, date, and the amount
of profit.

`—busy-day`: We’d like to know which days generated unusually high activity for
our securities. Please display the ticker symbol, date, and volume for each day
where the volume was more than 10% higher than the security’s average volume
(Note: You’ll need to calculate the average volume, and should display that
somewhere too).

`—biggest-loser`: Which security had the most days where the closing price was
lower than the opening price. Please display the ticker symbol and the number of
days that security’s closing price was lower than that day’s opening price.

When you have completed the exercise, please upload your entire solution to
Github.com and send an email with the URL of your repository to
COFI_Coding_Exercise@capitalone.com and include your name in the email. Please
make sure you have an appropriate README documenting how we should compile (if
necessary) and run your solution.
