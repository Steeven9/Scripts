import csv
import sys
from collections import defaultdict
from datetime import datetime

# input: a .csv with all the transactions
# output: categories breakdown for each month


def monthly_category_averages(csv_path, year):
    # category -> month -> list of amounts
    data = defaultdict(lambda: defaultdict(float))

    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            date = datetime.strptime(row["Date"], "%Y-%m-%d")
            category = row["Category"].strip()
            month = date.month
            amount = float(row["Amount"])

            if date.year != year:
                continue

            if category == "":
                continue

            data[category][month] += amount

    return data


def main():
    if len(sys.argv) != 4:
        print(
            f"Usage: python {sys.argv[0]} <input_file.csv> <year> <short/long>"
        )
        sys.exit(1)

    csv_path = sys.argv[1]
    year = int(sys.argv[2])
    print_full = sys.argv[3] == "long"

    averages = monthly_category_averages(csv_path, year)

    total_sum = 0
    for category in sorted(averages):
        print(f"\n{category}")
        category_sum = 0
        for month in sorted(averages[category]):
            avg = averages[category][month]
            category_sum += avg
            if print_full:
                print(f"  Month {month}: {avg:.2f}")

        total_sum += category_sum
        print(f"Total:     {category_sum:.2f}")
        print(f"Month avg: {(category_sum / 12):.2f}")

    print(f"\nTotal difference: {total_sum:.2f}")
    print(f"Month total average:  {(total_sum / 12):.2f}")


if __name__ == "__main__":
    main()
