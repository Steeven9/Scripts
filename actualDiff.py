import csv
import sys
from datetime import datetime

# input: two .csv with all the transactions
# output: differences between them


def parse_data(csv_path_actual: str, csv_path_bank: str, year: int):
    # category -> month -> list of amounts
    data_actual = []
    data_bank = []

    # Actual export
    with open(csv_path_actual, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            date = datetime.strptime(row["Date"], "%Y-%m-%d")
            payee = row["Payee"].strip()
            amount = float(row["Amount"])

            if row["Category"] == "":
                continue
            if date.year != year:
                continue

            record = {
                "date": date,
                "amount": amount,
                "payee": payee,
                "data": "Actual"
            }
            data_actual.append(record)

    # Raiffeisen export
    with open(csv_path_bank, newline="", encoding="latin-1") as f:
        reader = csv.DictReader(f, delimiter=";")
        for row in reader:
            date = datetime.strptime(row["Booked At"].split(" ")[0],
                                     "%Y-%m-%d")
            payee = row["Text"]
            amount = float(row["Credit/Debit Amount"])

            if date.year != year:
                continue

            record = {
                "date": date,
                "amount": amount,
                "payee": payee,
                "data": "Bank"
            }
            data_bank.append(record)

    data_actual.reverse()
    return (data_actual), (data_bank)


def main():
    if len(sys.argv) != 4:
        print(
            f"Usage: python {sys.argv[0]} <input_file_actual.csv> <input_file_bank.csv> <year>"
        )
        sys.exit(1)

    csv_path_actual = sys.argv[1]
    csv_path_bank = sys.argv[2]
    year = int(sys.argv[3])

    data_actual, data_bank = parse_data(csv_path_actual, csv_path_bank, year)

    orphan_rows = 0
    difference = 0
    for row in data_bank:
        found = False
        for row2 in data_actual:
            if row["date"] == row2["date"] and row["amount"] == row2["amount"]:
                found = True
        if not found:
            print(row)
            orphan_rows += 1
            difference += row["amount"]

    print(f"Total bank rows:   {len(data_bank)}")
    print(f"Total actual rows: {len(data_actual)}")
    print(f"Total mismatched:  {orphan_rows}")
    print(f"Total difference:  {difference}")


if __name__ == "__main__":
    main()
