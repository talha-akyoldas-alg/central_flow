//report_helper.js file for the scheduled workflow

const fs = require('fs');
const https = require('https');
const path = require('path');

fs.readFile('newman_json_report.json' , 'utf8', (err, data) => {
  if (err) {
    console.error(err);
    return;
  }
  data = JSON.parse(data);

  const results = {
    ITERATIONS_TOTAL: data.run.stats.iterations.total,
    ITERATIONS_FAILED: data.run.stats.iterations.failed,
    REQUESTS_TOTAL: data.run.stats.requests.total,
    REQUESTS_FAILED: data.run.stats.requests.failed,
    ASSERTIONS_TOTAL: data.run.stats.assertions.total,
    ASSERTIONS_FAILED: data.run.stats.assertions.failed,
    TEST_SCRIPTS_TOTAL: data.run.stats.testScripts.total,
    TEST_SCRIPTS_FAILED: data.run.stats.testScripts.failed,
    PRE_REQUEST_SCRIPTS_TOTAL: data.run.stats.prerequestScripts.total,
    PRE_REQUEST_SCRIPTS_FAILED: data.run.stats.prerequestScripts.failed,
    RUN_DURATION_TOTAL: ((data.run.timings.completed - data.run.timings.started)/ 1000).toFixed(2),
    DATA_RECEIVED_TOTAL: (data.run.transfers.responseTotal / (1024 * 1024)).toFixed(2), // Convert to MB
    RESPONSE_TIME_TOTAL: Math.round(data.run.timings.responseAverage), // Rounded value
    RESPONSE_TIME_MIN: Math.round(data.run.timings.responseMin), // Rounded value
    RESPONSE_TIME_MAX: (data.run.timings.responseMax/1000).toFixed(2),  // Rounded value
    SUCCESS_RATIO: (((data.run.stats.prerequestScripts.total) - (data.run.stats.assertions.failed))/(data.run.stats.prerequestScripts.total))*100
  };

  const extractedResults = Object.entries(results).map(([key, value]) =>
  `${key}=${value}`).join('\n');

  fs.writeFileSync('extracted_results.txt', extractedResults);

});