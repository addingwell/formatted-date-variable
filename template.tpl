___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "categories": [
    "UTILITY"
  ],
  "displayName": "Formatted Date",
  "description": "Format a timestamp to a specific format",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "timestamp",
    "displayName": "Timestamp value",
    "simpleValueType": true,
    "help": "Either the timestamp value or \"now\" to set to current timestamp.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "SELECT",
    "name": "timestampUnit",
    "displayName": "Timestamp Unit",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "ms",
        "displayValue": "Milliseconds"
      },
      {
        "value": "s",
        "displayValue": "Seconds"
      }
    ],
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "timestamp",
        "paramValue": "now",
        "type": "NOT_EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "format",
    "displayName": "Format",
    "simpleValueType": true,
    "defaultValue": "%YYYY%-%MM%-%DD%T%hh%:%mm%:%ss%.%mmm%Z",
    "help": "Write how you want the date to be formatted. Value between % will be replaced.\n\nYYYY: Year ; \nMM: Month ; \nDD: Day ; \nhh: Hours ; \nmm: Minutes ; \nss: Seconds ; \nmmm: Milliseconds",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const Math = require('Math');
const Object = require('Object');
const getTimestampMillis = require('getTimestampMillis');
const makeNumber = require('makeNumber');

function padTwoNumbers(number) {
  if (number < 10) {
    return '0' + number;
  }

  return '' + number;
}

function padThreeNumbers(number) {
  if (number < 10) {
    return '00' + number;
  }
  
  if (number < 100) {
    return '0' + number;
  }

  return '' + number;
}

function parseDate(timestampMillis) {
  const timestampDays = Math.floor(timestampMillis / 60 / 60 / 24 / 1000);
  const days = timestampDays + 719468;

  const era = Math.floor((days >= 0 ? days : days - 146096) / 146097);
  const doe = days - era * 146097;
  const yoe = Math.floor((doe + (-Math.floor(doe / 1460)) + Math.floor(doe / 36524) - Math.floor(doe / 146096)) / 365);
  const y = yoe + era * 400;
  const doy = doe - (365 * yoe + Math.floor(yoe / 4) - Math.floor(yoe / 100));
  const mp = Math.floor((5 * doy + 2) / 153);
  const d = 1 + doy - Math.floor(((153 * mp) + 2) / 5);
  const m = mp < 10 ? mp + 3 : mp - 9;

  let timeLeft = (timestampMillis - (timestampDays * 60 * 60 * 24 * 1000)) / 1000;
  const hours = Math.floor(timeLeft / 60 / 60);
  timeLeft = timeLeft - hours * 60 * 60;
  const minutes = Math.floor(timeLeft / 60);
  timeLeft = timeLeft - minutes * 60;
  const seconds = Math.floor(timeLeft);
  timeLeft = timeLeft - seconds;

  return {
    year: y + (m <= 2),
    month: padTwoNumbers(m),
    day: padTwoNumbers(d),
    hours: padTwoNumbers(hours),
    minutes: padTwoNumbers(minutes),
    seconds: padTwoNumbers(seconds),
    ms: padThreeNumbers(Math.floor(timeLeft * 1000)),
  };
}

let timestampMillis;
if (data.timestamp === 'now') {
  timestampMillis = getTimestampMillis();
} else {
  if (data.timestampUnit === 's') {
    timestampMillis = makeNumber(data.timestamp) * 1000;
  } else {
    timestampMillis = makeNumber(data.timestamp);
  }
}

const parsedDate = parseDate(timestampMillis);

const replaceArray = {
  'YYYY': parsedDate.year,
  'MM': parsedDate.month,
  'DD': parsedDate.day,
  'hh': parsedDate.hours,
  'mm': parsedDate.minutes,
  'ss': parsedDate.seconds,
  'sss': parsedDate.ms,
};

let finalText = data.format;

for (const entry of Object.entries(replaceArray)) {
  const replace = '%' + entry[0] + '%';
  while (finalText.indexOf(replace) !== -1) {
    finalText = finalText.replace('%' + entry[0] + '%', entry[1]);
  }
}

return finalText;


___TESTS___

scenarios:
- name: With no format it works
  code: |-
    const mockData = {
      timestamp: 'now',
      format: 'test'
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('test');
- name: Date to ISO 8601 works
  code: |-
    const mockData = {
      timestamp: '1668087995262',
      timestampUnit: 'ms',
      format: '%YYYY%-%MM%-%DD%T%hh%:%mm%:%ss%.%sss%'
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('2022-11-10T13:46:35.262');


___NOTES___

Created on 11/10/2022, 2:42:43 PM

