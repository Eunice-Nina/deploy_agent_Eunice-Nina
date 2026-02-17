#!/bin/bash

trap handler SIGINT


handler() {
    echo ""
    echo "   SCRIPT INTERRUPTED by user (Ctrl+C)!"
    echo " Creating backup archive before cleanup..."

    # Create archive with user's name
    if [ -d "YourProjectDirectory" ]; then
        tar -czf "attendance_tracker_${name}_archive" YourProjectDirectory
        echo " Archive created: attendance_tracker_${name}_archive.tar.gz"

        # Delete incomplete directory
        rm -rf YourProjectDirectory
        echo "  Unfinished folder deleted."
    else
        echo "   No project directory to archive."
    fi

    echo "Cleanup complete. Exiting..."
    exit 1
}

echo "Enter your project name:"
read name

PROJECT_DIR="attendance_tracker_$name"


# Task 1: Directory Architecture


echo "Creating project structure..."


mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"

touch "$PROJECT_DIR/attendance_checker.py"
touch "$PROJECT_DIR/Helpers/assets.csv"
touch "$PROJECT_DIR/Helpers/config.json"
touch "$PROJECT_DIR/reports/reports.log"



cat << 'EOF' > "$PROJECT_DIR/attendance_checker.py"
import csv
import json
import os
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def run_attendance_check():
    # Load config
    with open(os.path.join(BASE_DIR, 'Helpers/config.json')) as f:
        config = json.load(f)

    reports_dir = os.path.join(BASE_DIR, 'reports')
    report_file = os.path.join(reports_dir, 'reports.log')

    # Archive old report
    if os.path.exists(report_file):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename(
            report_file,
            os.path.join(reports_dir, f"reports_{timestamp}.log.archive")
        )

    with open(os.path.join(BASE_DIR, 'Helpers/assets.csv'), newline='') as f, \
         open(report_file, 'w') as log:

        reader = csv.DictReader(f, skipinitialspace=True)

        expected_headers = {'Email', 'Names', 'Attendance Count'}
        if not expected_headers.issubset(reader.fieldnames):
            raise ValueError(f"CSV headers mismatch: {reader.fieldnames}")

        total_sessions = config['total_sessions']
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            email = row['Email']
            name = row['Names']
            attended = int(row['Attendance Count'])

            attendance_pct = (attended / total_sessions) * 100
            message = ""

            if attendance_pct < config['thresholds']['failure']:
                message = (
                    f"URGENT: {name}, your attendance is "
                    f"{attendance_pct:.1f}%. You will fail this class."
                )
            elif attendance_pct < config['thresholds']['warning']:
                message = (
                    f"WARNING: {name}, your attendance is "
                    f"{attendance_pct:.1f}%. Please be careful."
                )

            if message:
                if config['run_mode'] == "live":
                    log.write(
                        f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n"
                    )
                    print(f"Alert logged for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

cat << 'EOF' > "$PROJECT_DIR/Helpers/assets.csv"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF


cat << 'EOF' > "$PROJECT_DIR/Helpers/config.json"
{
  "thresholds": {
    "warning": 75,
    "failure": 50
  },
  "run_mode": "live",
  "total_sessions": 15
}
EOF


cat << 'EOF' > "$PROJECT_DIR/reports/reports.log"
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF



echo "Directory structure created successfully!"


echo "SYSTEM HEALTH CHECK"

# 1. Check Python 3 installation
echo " Checking if  Python 3 is installed"
if command -v python3 &> /dev/null; then
    python_version=$(python3 --version 2>&1)
    echo " $python_version is installed"
else
    echo "      WARNING: python3 is NOT installed!"
    echo "      The attendance checker requires Python 3 to run."
    echo "      Please install Python 3 to use this application."
fi

echo " Verifying project structure"
errors=0

if [ -d "$PROJECT_DIR" ]; then
    echo "Main directory: $PROJECT_DIR"
else
    echo "  Missing: $PROJECT_DIR"
    errors=$((errors+1))
fi

if [ -f "$PROJECT_DIR/attendance_checker.py" ]; then
    echo " File: attendance_checker.py"
else
    echo " Missing: attendance_checker.py"
    errors=$((errors+1))
fi

if [ -d "$PROJECT_DIR/Helpers" ]; then
    echo " Directory: Helpers/"
else
	    echo " Missing: Helpers/"
    errors=$((errors+1))
fi

if [ -f "$PROJECT_DIR/Helpers/config.json" ]; then
    echo " File: Helpers/config.json"
else
    echo " Missing: Helpers/config.json"
    errors=$((errors+1))
fi

if [ -f "$PROJECT_DIR/Helpers/assets.csv" ]; then
    echo " File: Helpers/assets.csv"
else
    echo " Missing: Helpers/assets.csv"
    errors=$((errors+1))
fi

if [ -d "$PROJECT_DIR/reports" ]; then
    echo " Directory: reports/"
else
    echo "  Missing: reports/"
    errors=$((errors+1))
fi

if [ -f "$PROJECT_DIR/reports/reports.log" ]; then
    echo "  File: reports/reports.log"
else
    echo "  Missing: reports/reports.log"
    errors=$((errors+1))
fi

echo ""
if [ $errors -eq 0 ]; then
    echo " HEALTH CHECK PASSED All files and folders are present"
else
    echo "   HEALTH CHECK FAILED  $errors items are missing"
        echo "   Please check the errors above."
    exit 1
fi

# Task 2: Dynamic Configuration


echo "Insert a new warning :"
read warning

echo "Insert a new failure "
read failure

sed -i "s/\"warning\": [0-9]\+/\"warning\": $warning/" \
    "$PROJECT_DIR/Helpers/config.json"

sed -i "s/\"failure\": [0-9]\+/\"failure\": $failure/" \
    "$PROJECT_DIR/Helpers/config.json"

echo "Project setup complete "


echo " Configuration updated: Warning=$warn%, Failure=$fail%"

echo " Creating working directory..."
mkdir -p YourProjectDirectory

echo "   Press Ctrl+C to test the interrupt handler"



for i in {1..10}; do
    echo "   Processing... $i seconds"
    sleep 1
done

echo ""
echo "Work completed successfully!"
echo " All files are ready in: $PROJECT_DIR"
echo ""
echo "To run the attendance checker:"
echo "  cd $PROJECT_DIR"
echo "  python3 attendance_checker.py"
echo "SETUP COMPLETE!"


# Remove the trap for normal completion
trap - SIGINT
