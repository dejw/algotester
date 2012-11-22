# Algotester

## Installation

    wget https://raw.github.com/dejw/algotester/master/algotester.sh
    chmod +x algotester.sh

## Usage

    ./algotester.sh program_name [test_directory ...]

Programs are compiled using `make program_name` command. Test directory should
contain an even number of files (2 for each test case).

Test case is an input file (`*.in`) and output file (`*.out`) - base names
should match each other.

Outputs are compared byte by byte.

## Config

You can change timeout (in seconds) and memory limit (in megabytes) at the
top of the file.