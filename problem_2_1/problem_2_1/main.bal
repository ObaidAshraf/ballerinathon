import ballerinax/java.jdbc;
import ballerina/sql;
import ballerina/io;
import ballerina/file;

function addEmployee(string dbFilePath, string name, string city, string department, int age) returns int {

    boolean|error fileRes = file:test(dbFilePath, file:EXISTS);
    if fileRes is error{
        return -1;
    }
    string db_file_path = "jdbc:h2:file:" + dbFilePath;

    io:println(db_file_path);

    jdbc:Client dbClient = checkpanic new (db_file_path, "root", "root");

    sql:ExecutionResult result = checkpanic dbClient->execute(`INSERT INTO Employee (name, city, department, age) VALUES (${name}, ${city}, ${department}, ${age})`);

    checkpanic dbClient.close();
    return <int>result.lastInsertId;
}
// public function main() {
//     int last_id = addEmployee("./db/gofigure", "John Doe", "Omaha", "Sales", 24);
//     io:println(last_id);
// }