import ballerina/io;

type inputData record {
    readonly int employee_id;
    int odometer_reading;
    float gallons;
    float gas_price;
};

type outputData record {
    readonly int employee_id;
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
    string[][] data_output = [];

    table<outputData> key(employee_id) output_data_table = table[];

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
        if output_data_table.hasKey(data.employee_id) {
            outputEntry = <outputData>output_data_table[data.employee_id];

            _ = output_data_table.remove(data.employee_id);
            output_data_table.add({
                employee_id: data.employee_id,
                gas_fill_up_count: outputEntry["gas_fill_up_count"]+1,
                total_fuel_cost: outputEntry["total_fuel_cost"] + (data.gallons * data.gas_price),
                total_gallons: outputEntry["total_gallons"] + data.gallons,
                total_miles_accrued: (outputEntry.gas_fill_up_count == 1) ? (data.odometer_reading - outputEntry.prevOdometerReading) : (data.odometer_reading - outputEntry.prevOdometerReading) + outputEntry["total_miles_accrued"],
                prevOdometerReading: data.odometer_reading
            });

        }
        else {
            output_data_table.add({
                employee_id: data.employee_id,
                gas_fill_up_count: 1,
                total_fuel_cost: (data.gallons * data.gas_price),
                total_gallons: data.gallons,
                total_miles_accrued: data.odometer_reading,
                prevOdometerReading: data.odometer_reading
            });
        }
    }

    foreach var data in output_data_table {
        data_output.push([
            data["employee_id"].toBalString(),
            data["gas_fill_up_count"].toBalString(),
            data["total_fuel_cost"].toBalString(),
            data["total_gallons"].toBalString(),
            data["total_miles_accrued"].toBalString()
        ]);
    }

    checkpanic io:fileWriteCsv("./output.csv", data_output);
}
