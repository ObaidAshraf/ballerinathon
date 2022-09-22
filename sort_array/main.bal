import ballerina/io;

function allocateCubicles (int[] requests) returns int[] {
   int[] unique = [];
    int idx = 0;
    int prev = -1;

    foreach var req in requests.sort() {
        if req != prev {
            unique[idx] = req;
            idx += 1;
        }
        prev = req;
    }

    return unique;
}

public function main() {
    int[] arr = [5, 6, 18, 56, 18, 8, 1];
    // int[] arr = [65, 1, 56];

    int[] sorted = allocateCubicles(arr);

    foreach var item in sorted {
        io:println(item);
    }
}
