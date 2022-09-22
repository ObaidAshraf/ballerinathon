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
};


public function main() {
    // map<inputData>|io:Error ipData = io:fileReadCsv("./input.csv");
    string[][]|io:Error ipData = io:fileReadCsv("./input.csv");
    // table<inputData> key(employee_id) ipData = io:fileReadCsv("./input.csv");
    io:println(ipData);
}
