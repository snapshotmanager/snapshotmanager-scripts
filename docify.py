#!/bin/python3
from subprocess import run, PIPE, STDOUT
import sys


def print_man(command):
    print(".EX")
    for line in command:
        print(line)
    print(".EE")

def print_md(command):
    print("```")
    for line in command:
        print(line)
    print("```")


def main(argv):
    argv.pop(0)
    cmd = run(argv, stdout=PIPE, stderr=STDOUT)
    output = cmd.stdout.decode("utf8").splitlines()

    command = ["# " + " ".join(argv)] + output

    for line in command:
        print(line)
    print()

    print_md(command)
    print()

    print_man(command)


if __name__ == "__main__":
    main(sys.argv)
