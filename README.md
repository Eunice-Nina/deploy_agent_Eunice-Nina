This project is a Bash automation script for the setup of a Student Attendance Tracker workspace using a shell script. Instead of manually creating directories and files, the script builds an entire project structure, updates configuration settings, validates the environment, and safely handles interruptions.

It automatically:

Prompts the user for a project name.

Generates required Python, CSV, and JSON files.

Performs a system health check.

Allows dynamic threshold configuration.

Handles safe interruption (Ctrl + C) with backup.

Here's a step by step procedure

 Run the script by writing bash script.sh

 Provide the project name as requested

 The script then demonstrates the directory structure

 Provide a new warning value as requested

 Provide a new failure value as requested

 Move into the directory by writing cd attendance_tracker_<project_name>

 Write python3 attendance_checker.py to run the attendance checking program
