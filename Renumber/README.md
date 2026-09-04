# BASIC Program Renumbering Tool

## Overview

The renumbering tool can be used to change the line numbering for a BASIC application using parameters defined in the application configuration file. It performs the following actions:

- Renumber the lines in the program file
- Amend GOSUB statements to respect the updated numbering
- Amend GOTO statements to respect the updated numbering

## Building the Tool

While the renumbering tool can be run from source each time, it is recommended to publish it to a standalone executable.

### Pre-Requisites

The .NET 8 SDK should be installed from https://dotnet.microsoft.com/en-us/download/dotnet/8.0

### Building the Application

- Check out a working copy of the renumbering application
- From the root folder of the working copy (the folder containing the .sln solution file), enter the following command:

```bash
dotnet publish Renumber\Renumber.csproj -c Release -r rid --self-contained -o \target\folder
```

- Replace "\target\folder" with the path to the folder to which the compiled application should be published
- Replace "rid" with the runtime identifier for the system on which the application will be run
- Further information on .NET RIDs is available at https://learn.microsoft.com/en-us/dotnet/core/rid-catalog

### Application Settings

- The renumbering parameters are defined in the "appsettings.json" file in the "Renumber" project
- This will be copied to the output folder when the project is built and should be modified so match the required defaults
- The defaults can be overwritten using the command line arguments indicated in the table, below

| Setting     | Default | CLI              | Purpose                                                                                                                  |
| ----------- | ------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------ |
| InPlace     | false   | --inplace, -i    | If true, the renumbered file overwrites the original. If false, a backup file with the ".bak" extension is created first |
| StartAt     | 10      | --start, -s      | Initial line number in the renumbered file                                                                               |
| IncrementBy | 10      | --increment, -in | Increment in line number                                                                                                 |

- Note that "default" refers to the value in the appsettings.json file that is part of the repository

## Renumbering a Program

- Assuming the application has been compiled to \target\folder, per the instructions above, enter the following command:

```bash
\target\folder\Renumber.exe --renumber \path\to\program.bas
```

- Replace "\path\to\program.bas" with the path to a file to renumber
- The output should look similar to the following:

```
BASIC Renumbering Tool v1.1.0.0

File to renumber: Barycenter.bas
In-place renumbering: False
Initial line number: 10
Line number increment: 10

Reading file: ..............
14 lines read

Renumbering lines: ..............
14 lines renumbered

Writing file: ..............
14 lines written
```
