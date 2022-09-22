import ballerina/io;

type inputData record {
    readonly int employee_id;
    int odometer_reading;
    float gallons;
    float gas_price;
};

type outputData record {
    int employee_id;
    int gas_fill_up_count;
    float total_fuel_cost;
    float total_gallons;
    int total_miles_accrued;
    int prevOdometerReading;
};

public function main() {

    stream<string[], io:Error?> ipData = checkpanic io:fileReadCsvAsStream("./input.csv");

    inputData[] input_data_arr = [];
    inputData inputEntry;
    outputData outputEntry;
    map<outputData> dataOutput = {};

    string[][] data_output = [];

    checkpanic ipData.forEach(function(string[] val) {
        inputEntry = {
            employee_id: checkpanic int:fromString(val[0]),
            odometer_reading: checkpanic int:fromString(val[1]),
            gallons: checkpanic float:fromString(val[2]),
            gas_price: checkpanic float:fromString(val[3])
        };

        input_data_arr.push(inputEntry);
    });

    foreach var data in input_data_arr {
        if dataOutput.hasKey(data.employee_id.toBalString()) {
            outputEntry = <outputData>dataOutput[data.employee_id.toBalString()];
            dataOutput[data.employee_id.toBalString()] = {
                employee_id: data.employee_id,
                gas_fill_up_count: outputEntry["gas_fill_up_count"]+1,
                total_fuel_cost: outputEntry["total_fuel_cost"] + (data.gallons * data.gas_price),
                total_gallons: outputEntry["total_gallons"] + data.gallons,
                total_miles_accrued: (outputEntry.gas_fill_up_count == 1) ? (data.odometer_reading - outputEntry.prevOdometerReading) : (data.odometer_reading - outputEntry.prevOdometerReading) + outputEntry["total_miles_accrued"],
                prevOdometerReading: data.odometer_reading
            };
        }
        else {
            dataOutput[data.employee_id.toBalString()] = {
                employee_id: data.employee_id,
                gas_fill_up_count: 1,
                total_fuel_cost: (data.gallons * data.gas_price),
                total_gallons: data.gallons,
                total_miles_accrued: data.odometer_reading,
                prevOdometerReading: data.odometer_reading
            };
        }
    }

    foreach var k in dataOutput.keys() {
        data_output.push([
            dataOutput[k]["employee_id"].toBalString(),
            dataOutput[k]["gas_fill_up_count"].toBalString(),
            dataOutput[k]["total_fuel_cost"].toBalString(),
            dataOutput[k]["total_gallons"].toBalString(),
            dataOutput[k]["total_miles_accrued"].toBalString()
        ]);
    }


    checkpanic io:fileWriteCsv("./output.csv", data_output);    
}
