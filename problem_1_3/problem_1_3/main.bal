import ballerina/io;

// Ballerina record type definition
type FillUpEntry record {|
    int employeeId;
    int odometerReading;
    decimal gallons;
    decimal gasPrice;
|};

// Ballerina record type definition
type EmployeeFillUpSummary record {|
    int employeeId;
    int gasFillUpCount;
    decimal totalFuelCost;
    decimal totalGallons;
    int totalMilesAccrued;
    int prevOdometerReading;
|};

function processFuelRecords(string inputFilePath, string outputFilePath) returns error? {
    json[] content = check io:fileReadJson(inputFilePath).ensureType();
    map<EmployeeFillUpSummary> dataOutput = {};

    FillUpEntry entry;
    EmployeeFillUpSummary outputEntry;
    json[] output_json = [];

    foreach var data in content {
        entry = check data.cloneWithType();
        FillUpEntry {employeeId, odometerReading, gallons, gasPrice} = entry;
        if dataOutput.hasKey(employeeId.toBalString()) {
            outputEntry = <EmployeeFillUpSummary>dataOutput[employeeId.toBalString()];
            dataOutput[employeeId.toBalString()] = {
                employeeId: employeeId,
                gasFillUpCount: outputEntry["gasFillUpCount"] + 1,
                totalFuelCost: outputEntry["totalFuelCost"] + (gallons * gasPrice),
                totalGallons: outputEntry["totalGallons"] + gallons,
                totalMilesAccrued: (outputEntry.gasFillUpCount == 1) ? (odometerReading - outputEntry.prevOdometerReading) : (odometerReading - outputEntry.prevOdometerReading) + outputEntry["totalMilesAccrued"],
                prevOdometerReading: odometerReading
            };
        }
        else {
            dataOutput[employeeId.toBalString()] = {
                employeeId: employeeId,
                gasFillUpCount: 1,
                totalFuelCost: gallons * gasPrice,
                totalGallons: gallons,
                totalMilesAccrued: odometerReading,
                prevOdometerReading: odometerReading
            };
        }
    }

    string[] sortedKeys = dataOutput.keys().sort();

    foreach var key in sortedKeys {
        output_json.push({
            employeeId: dataOutput[key]["employeeId"],
            gasFillUpCount: dataOutput[key]["gasFillUpCount"],
            totalFuelCost: dataOutput[key]["totalFuelCost"],
            totalGallons: dataOutput[key]["totalGallons"],
            totalMilesAccrued: dataOutput[key]["totalMilesAccrued"]
        }.toJson());
    }

    check io:fileWriteJson(outputFilePath, output_json);
}

// public function main() {
//     error? e = processFuelRecords("tests/resources/example01_input.json"", "target/example01_output.json");
// }
